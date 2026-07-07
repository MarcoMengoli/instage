# InStage v2 — Progetto del sistema di controllo luci DMX

> Documento di design. Nessuna riga di codice del vecchio sistema viene riutilizzata;
> il repo attuale (Python + MQTT + Express) resta come riferimento storico.

## 1. Obiettivo

Sistema per pilotare un impianto luci DMX (fino a ~30 fixture tra PAR e teste mobili,
1–2 universi) in rete locale, per **piccoli concerti**, controllabile da **Android e iPad**
con la stessa app, distribuita sia come **PWA** che come **app nativa**.

Casi d'uso principali, in ordine di priorità:

1. **Scene statiche / ambienti** — richiamo di scene predefinite con fade.
2. **Chase ed effetti automatici** — sequenze a tempo, tap tempo sui BPM del pezzo.
3. **Cue list** — scaletta dello spettacolo con pulsante GO e fade time per cue.
4. Override manuali (grand master, blackout, singoli canali/fixture) sempre disponibili.

## 2. Architettura

```
┌──────────────────────────────┐         ┌───────────────────────────────────────┐
│  App (unico codebase web)    │  REST + │  instage-server (Rust, Raspberry Pi)  │
│  • PWA servita dal Pi        │   WS    │  ┌─────────────────────────────────┐  │
│  • Android (Capacitor)       │◄───────►│  │ HTTP API (config) + WebSocket   │  │
│  • iPadOS (Capacitor)        │         │  │ (realtime: GO, override, sync)  │  │
└──────────────────────────────┘         │  ├─────────────────────────────────┤  │
                                         │  │ Engine: render loop ~40 Hz      │  │
                                         │  │ layer: scene→fx→cue→manual→GM   │  │
                                         │  ├─────────────────────────────────┤  │
                                         │  │ Output trait (multi-universo)   │  │
                                         │  └────┬──────────────┬─────────────┘  │
                                         └───────┼──────────────┼────────────────┘
                                            USB FT232R     Art-Net / sACN
                                            (hardware        (nodi futuri,
                                             attuale)         universi 2+)
```

Decisioni prese e motivazioni:

| Decisione | Scelta | Perché |
|---|---|---|
| Backend | **Rust** (obiettivo anche didattico; Go è il piano B se la curva pesa troppo) | Loop realtime senza GC, binario singolo per ARM, ecosistema sufficiente (vedi §6) |
| Frontend | **TypeScript + React + Vite**, impacchettato con **Capacitor** | Un codebase → PWA + APK Android + app iPad |
| Trasporto | **REST per configurazione, WebSocket per il realtime** | Bassa latenza, sync multi-client, niente broker |
| MQTT | **Rimosso** | Intermediario senza benefici in questo scenario |
| Output DMX | **USB FT232R subito, Art-Net/sACN dietro la stessa astrazione** | Zero acquisti ora, scala a più universi/nodi dopo |
| Profili fixture | **Formato Open Fixture Library (OFL)** | Migliaia di profili pronti (pan/tilt, color wheel, gobo…), niente profili scritti a mano |
| Persistenza | **SQLite** (via `rusqlite`) | Un file, backup banale, niente servizi extra |
| Discovery | **mDNS** (`instage.local`) | Le app trovano il server senza configurare IP |
| Autenticazione | Nessuna in v1 (rete locale); PIN opzionale in seguito | Il rischio reale è basso; il blackout accidentale si mitiga con conferme UI |

## 3. Modello dati

Tutte le entità sono definite in JSON Schema condiviso; i tipi TypeScript del frontend
vengono generati da quelli Rust (`serde` + export schema), così app e server non divergono.

- **FixtureDefinition** — profilo del faro in formato OFL: modes, canali, capability
  (dimmer, colore, pan/tilt, ruote). Importato dalla libreria OFL o creato a mano.
- **Fixture (patch)** — istanza fisica: definizione + mode + universo + indirizzo DMX + nome
  ("PAR sx palco"). Validazione anti-collisione indirizzi.
- **Group** — insieme di fixture controllate insieme ("tutti i PAR", "teste mobili").
- **Scene** — snapshot di valori per un insieme di fixture, con fade-in di default.
  Le scene sono *sparse*: toccano solo i canali che definiscono.
- **Chase** — lista ordinata di step (ogni step è una mini-scena) + timing: BPM o durata
  per step, fade tra step, direzione (avanti/ping-pong/random).
- **Effect** — generatori parametrici (sine/ramp su dimmer, color cycle, pan/tilt circle)
  applicati a un gruppo con ampiezza/velocità/fase.
- **CueList** — sequenza ordinata di cue; ogni cue = riferimenti a scene/chase/effect
  + fade time + follow/wait opzionale. Un solo cursore di playback con GO / BACK.
- **Show** — contenitore di tutto quanto sopra: un file esportabile/importabile (JSON)
  per portarsi il setup a un altro concerto.

## 4. Engine (il cuore)

Loop di render a **40 Hz** (25 ms — coerente col limite fisico DMX: un frame completo
a 250 kbaud dura ~23 ms). Ad ogni tick:

1. Ogni **layer** produce i propri valori canale (sparse):
   - `L0` Scene attive (con fade in corso interpolati)
   - `L1` Chase ed Effect (calcolati dal clock/BPM)
   - `L2` Cue list playback
   - `L3` Override manuali dalla UI (fader singoli, color picker live)
2. **Merge** dei layer: LTP (last takes precedence) per canali di colore/posizione/gobo,
   HTP (highest takes precedence) per i canali di intensità — l'informazione su quale
   canale è "intensity" viene dal profilo OFL.
3. **Grand master** moltiplica i canali intensity; **blackout** li azzera. Entrambi
   agiscono a valle di tutto: funzionano *sempre*, qualunque cosa stia suonando.
4. Il frame risultante (per universo) va ai driver di output.

Il tap tempo aggiorna un **clock BPM globale** a cui i chase si agganciano
(con moltiplicatori ×½, ×1, ×2 per chase).

### Astrazione output

```rust
trait DmxOutput: Send {
    fn send(&mut self, universe: u16, frame: &[u8; 512]) -> Result<()>;
}
```

Driver previsti:

- **OpenDmxFtdi** (Fase 1): FT232R via crate `serialport` — 250 kbaud 8N2,
  break ≥88 µs + MAB prima di ogni frame (`set_break`/`clear_break`).
  Il jitter USB su Linux è accettabile per LED/teste mobili.
- **ArtNet** (Fase 5): `ArtDmx` in UDP broadcast/unicast, un nodo per universo.
- **Sacn** (opzionale): E1.31 multicast, alternativa ad Art-Net.

La mappa `universo → driver` è configurabile a runtime.

## 5. API

### REST (configurazione, CRUD)

```
GET/POST/PUT/DELETE  /api/fixtures            patch
GET                  /api/fixture-defs         libreria OFL importata
POST                 /api/fixture-defs/import  upload JSON OFL
GET/POST/…           /api/groups | /api/scenes | /api/chases | /api/cuelists
GET/PUT              /api/settings             universi, driver output
GET/POST             /api/show/export|import   show completo come JSON
```

### WebSocket (realtime, `/ws`)

Messaggi JSON tipizzati, client→server:

```
scene.activate {sceneId, fadeMs?}     scene.release {sceneId}
chase.start {chaseId} / chase.stop    tempo.tap {}
cue.go {cueListId} / cue.back / cue.jump {index}
override.set {fixtureId, channel, value} / override.clear
master.set {value}    blackout.set {on}
```

Server→client (broadcast a tutti i connessi, così iPad e Android restano in sync):

```
state.full   {…}       snapshot iniziale alla connessione
state.delta  {…}       cosa è attivo, posizione cue, BPM, master
dmx.preview  {universe, frame}   opzionale, throttled, per la vista "canali"
```

## 6. Stack tecnico

### Backend (`instage-server/`, Rust)

| Ruolo | Crate |
|---|---|
| HTTP + WebSocket | `axum` + `tokio` |
| Serializzazione | `serde` / `serde_json`, `schemars` per generare i tipi TS |
| Seriale FTDI | `serialport` |
| Art-Net | `artnet_protocol` (o implementazione propria: il pacchetto ArtDmx è ~20 righe) |
| DB | `rusqlite` |
| mDNS | `mdns-sd` |
| Static files | `tower-http` (serve la PWA compilata) |

Architettura interna: il **render loop gira su un thread dedicato** e possiede lo stato
dell'engine; API e WS gli parlano tramite canali (`tokio::sync::mpsc` per i comandi,
`watch`/`broadcast` per lo stato verso i client). Niente lock condivisi sul percorso caldo.
È anche un ottimo perimetro per studiare Rust: ownership del frame, canali, trait object
per i driver.

Cross-compilazione per il Pi con `cross` (target `aarch64-unknown-linux-gnu`);
deploy come binario singolo + unit systemd (niente Docker necessario).

### Frontend (`instage-app/`, TypeScript)

- **React 18 + Vite + TypeScript**, state management leggero (Zustand).
- **PWA**: service worker (vite-plugin-pwa), installabile dalla home di Android/iPad.
- **Capacitor** per i pacchetti nativi Android e iPadOS (Fase 5). Nota iPad: per l'app
  nativa serve un account Apple Developer (99 $/anno) oppure sideload da Xcode
  rinnovato ogni 7 giorni; la PWA è la via gratuita nel frattempo.
- UI touch-first: fader grandi, pad XY per pan/tilt, color picker, pulsante GO enorme,
  blackout con conferma (slide-to-confirm, non un tap accidentale).
- Layout: tab **Live** (scene/chase/tap tempo), **Cues**, **Fixtures** (controllo diretto),
  **Setup** (patch, universi, import OFL).

### Struttura repo (monorepo)

```
instage/
├── docs/DESIGN.md            questo documento
├── instage-server/           backend Rust
├── instage-app/              frontend TS + Capacitor
├── shared/schema/            JSON Schema generati (contratto API)
└── legacy/                   vecchio codice Python/Express (spostato, non usato)
```

## 7. Piano a fasi

Ogni fase termina con qualcosa di usabile a un concerto vero.

- **Fase 1 — Fondamenta** ✅ *criterio: accendo e spengo luci dal telefono*
  Server Rust: stato universo, driver FT232R, render loop, patch minima a mano (JSON),
  scene statiche con fade, REST+WS. Web UI minima: griglia pulsanti scena,
  grand master, blackout. Deploy systemd sul Pi.
- **Fase 2 — Fixture e editor** — import OFL, patch dalla UI, controllo diretto fixture
  (color picker, pad pan/tilt, slider), salvataggio scene dallo stato live ("store").
- **Fase 3 — Chase, effetti, tap tempo** — step sequencer, clock BPM globale con tap,
  effetti generativi su gruppi.
- **Fase 4 — Cue list** — editor scaletta, GO/BACK, follow/wait, vista operatore.
- **Fase 5 — Nativo e scala** — pacchetti Capacitor (Android APK, iPad),
  driver Art-Net, secondo universo, export/import show.

## 8. Rischi e note

- **Timing DMX via FT232R su Linux**: il break generato via ioctl seriale ha jitter;
  per LED e teste mobili è ok, ma se qualche fixture si comporta male la mitigazione
  è passare quell'universo ad Art-Net (già previsto). Da verificare presto in Fase 1.
- **Curva di Rust**: è il rischio principale sul planning. Mitigazione: l'architettura
  (engine su thread + canali + trait driver) è identica in Go; se dopo la Fase 1 la
  velocità di sviluppo non soddisfa, il porting è contenuto.
- **iPad nativo**: vincoli Apple (vedi §6); la PWA copre il 100 % delle funzioni intanto.
- **Wi-Fi durante i live**: la rete è locale e dedicata (router/AP proprio consigliato);
  il server continua a mandare l'ultimo frame anche se tutti i client si disconnettono —
  la caduta del Wi-Fi non spegne mai le luci.

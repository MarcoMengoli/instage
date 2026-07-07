# Piano operativo — indice issue

Ogni file di questa cartella è un'issue auto-descrittiva: contesto, scope, attività,
test e acceptance criteria. Può essere copiata così com'è come issue GitHub
(titolo = prima riga, corpo = resto).

## Convenzioni

- **ID**: `ISSUE-NNN`, numerazione progressiva, mai riusata.
- **Commit**: prefisso `ISSUE-NNN:` nei messaggi.
- **Chiusura**: un'issue è chiusa solo quando *tutti* gli acceptance criteria sono
  spuntati; le spunte si aggiornano nel file stesso.
- **Labels** suggerite (riportate in testa a ogni issue): `fase-N`, `backend`,
  `frontend`, `hardware`, `infra`.

## Ordine e dipendenze

```
Fase 0  001 monorepo
Fase 1  002 engine ── 003 driver USB ── 004 resilienza
        005 modello dati ── 006 API ── 007 UI minima ── 008 deploy Pi
Fase 2  009 import OFL ── 010 UI fixture ── 011 editor scene
Fase 3  012 tap tempo ── 013 chase ── 014 effetti
Fase 4  015 cue list
Fase 5  016 art-net ── 017 capacitor ── 018 export show
```

| ID | Titolo | Fase | Dipende da |
|---|---|---|---|
| [001](001-monorepo-scaffolding.md) | Scaffolding monorepo e CI | 0 | — |
| [002](002-engine-core.md) | Engine core: stato, render loop, layer | 1 | 001 |
| [003](003-driver-ft232r.md) | Trait output + driver FT232R + driver mock | 1 | 001 |
| [004](004-resilienza-autonomia.md) | Autonomia e resilienza del server | 1 | 002, 003 |
| [005](005-modello-dati-persistenza.md) | Modello dati, SQLite, schema condiviso | 1 | 001 |
| [006](006-api-rest-websocket.md) | API REST + protocollo WebSocket | 1 | 002, 005 |
| [007](007-ui-minima-live.md) | Web UI minima: scene, master, blackout (PWA) | 1 | 006 |
| [008](008-deploy-raspberry.md) | Deploy su Raspberry Pi (cross, systemd, mDNS) | 1 | 002, 003, 007 |
| [009](009-import-ofl.md) | Libreria fixture: import formato OFL | 2 | 005 |
| [010](010-ui-controllo-fixture.md) | UI controllo diretto fixture + layer override | 2 | 007, 009 |
| [011](011-editor-scene.md) | Editor scene (store dallo stato live) | 2 | 010 |
| [012](012-clock-bpm-tap-tempo.md) | Clock BPM globale + tap tempo | 3 | 002 |
| [013](013-chase-engine.md) | Chase engine + step sequencer UI | 3 | 011, 012 |
| [014](014-effetti-generativi.md) | Effetti generativi su gruppi | 3 | 009, 012 |
| [015](015-cue-list.md) | Cue list: engine, editor, vista operatore | 4 | 011, 013 |
| [016](016-artnet-multiuniverso.md) | Driver Art-Net + multi-universo | 5 | 003 |
| [017](017-capacitor-native.md) | Pacchetti nativi Android/iPad (Capacitor) | 5 | 007+ (UI matura) |
| [018](018-export-import-show.md) | Export/import Show completo | 5 | 005, 011, 013, 015 |

## Milestone

- **M1 "prima serata"** = 001–008: si fa un concerto con scene statiche dal telefono.
- **M2 "controllo pieno"** = 009–011.
- **M3 "a tempo di musica"** = 012–014.
- **M4 "spettacolo"** = 015.
- **M5 "scala e store"** = 016–018.

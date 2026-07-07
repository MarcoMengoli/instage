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

Le issue sono pubblicate anche su GitHub (colonna "GH"); il tracker complessivo è
[#21 — Roadmap InStage v2](https://github.com/MarcoMengoli/instage/issues/21).

| ID | GH | Titolo | Fase | Dipende da |
|---|---|---|---|---|
| [001](001-monorepo-scaffolding.md) | [#3](https://github.com/MarcoMengoli/instage/issues/3) | Scaffolding monorepo e CI | 0 | — |
| [002](002-engine-core.md) | [#4](https://github.com/MarcoMengoli/instage/issues/4) | Engine core: stato, render loop, layer | 1 | 001 |
| [003](003-driver-ft232r.md) | [#5](https://github.com/MarcoMengoli/instage/issues/5) | Trait output + driver FT232R + driver mock | 1 | 001 |
| [004](004-resilienza-autonomia.md) | [#6](https://github.com/MarcoMengoli/instage/issues/6) | Autonomia e resilienza del server | 1 | 002, 003 |
| [005](005-modello-dati-persistenza.md) | [#7](https://github.com/MarcoMengoli/instage/issues/7) | Modello dati, SQLite, schema condiviso | 1 | 001 |
| [006](006-api-rest-websocket.md) | [#8](https://github.com/MarcoMengoli/instage/issues/8) | API REST + protocollo WebSocket | 1 | 002, 005 |
| [007](007-ui-minima-live.md) | [#9](https://github.com/MarcoMengoli/instage/issues/9) | Web UI minima: scene, master, blackout (PWA) | 1 | 006 |
| [008](008-deploy-raspberry.md) | [#10](https://github.com/MarcoMengoli/instage/issues/10) | Deploy su Raspberry Pi (cross, systemd, mDNS) | 1 | 002, 003, 007 |
| [009](009-import-ofl.md) | [#11](https://github.com/MarcoMengoli/instage/issues/11) | Libreria fixture: import formato OFL | 2 | 005 |
| [010](010-ui-controllo-fixture.md) | [#12](https://github.com/MarcoMengoli/instage/issues/12) | UI controllo diretto fixture + layer override | 2 | 007, 009 |
| [011](011-editor-scene.md) | [#13](https://github.com/MarcoMengoli/instage/issues/13) | Editor scene (store dallo stato live) | 2 | 010 |
| [012](012-clock-bpm-tap-tempo.md) | [#14](https://github.com/MarcoMengoli/instage/issues/14) | Clock BPM globale + tap tempo | 3 | 002 |
| [013](013-chase-engine.md) | [#15](https://github.com/MarcoMengoli/instage/issues/15) | Chase engine + step sequencer UI | 3 | 011, 012 |
| [014](014-effetti-generativi.md) | [#16](https://github.com/MarcoMengoli/instage/issues/16) | Effetti generativi su gruppi | 3 | 009, 012 |
| [015](015-cue-list.md) | [#17](https://github.com/MarcoMengoli/instage/issues/17) | Cue list: engine, editor, vista operatore | 4 | 011, 013 |
| [016](016-artnet-multiuniverso.md) | [#18](https://github.com/MarcoMengoli/instage/issues/18) | Driver Art-Net + multi-universo | 5 | 003 |
| [017](017-capacitor-native.md) | [#19](https://github.com/MarcoMengoli/instage/issues/19) | Pacchetti nativi Android/iPad (Capacitor) | 5 | 007+ (UI matura) |
| [018](018-export-import-show.md) | [#20](https://github.com/MarcoMengoli/instage/issues/20) | Export/import Show completo | 5 | 005, 011, 013, 015 |

## Milestone

- **M1 "prima serata"** = 001–008: si fa un concerto con scene statiche dal telefono.
- **M2 "controllo pieno"** = 009–011.
- **M3 "a tempo di musica"** = 012–014.
- **M4 "spettacolo"** = 015.
- **M5 "scala e store"** = 016–018.

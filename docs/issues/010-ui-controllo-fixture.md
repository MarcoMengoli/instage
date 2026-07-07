# ISSUE-010 — UI controllo diretto fixture + layer override

Labels: `fase-2`, `frontend`, `backend`
Dipende da: ISSUE-007, ISSUE-009

## Contesto

Controllo live delle singole fixture e dei gruppi: color picker, pad pan/tilt,
slider canali. Lato engine è il layer **override manuale** (L3, DESIGN §4).

## Scope

- Backend: comandi WS `override.set` a livello *fixture+capability* (non canale nudo:
  `{fixtureId, capability: 'color', value: {r,g,b}}`), tradotti in canali dal profilo;
  `override.clear` per fixture o globale. Gli override sopravvivono alle disconnessioni
  (coerente con ISSUE-004) e sono inclusi nello snapshot persistito.
- Frontend, tab **Fixtures**:
  - lista fixture/gruppi con stato corrente;
  - color picker (ruota + swatch) per fixture con canali colore;
  - pad XY pan/tilt con supporto 16-bit e pulsante "home";
  - slider generici per gli altri canali, con etichette e valori dal profilo OFL
    (enum → select, es. gobo);
  - indicatore "override attivo" + clear per fixture e "clear all".
- Throttling client dei comandi continui (picker/pad) a ~30 msg/s con coalescing
  (si manda l'ultimo valore, non la coda).

### Fuori scope

Salvataggio come scena (011), gestione gruppi avanzata (creazione gruppi va in 011).

## Attività

- [ ] Backend: risoluzione capability→canali + test (RGB, RGBW, pan/tilt 16-bit).
- [ ] Backend: override nello snapshot di stato e nella persistenza.
- [ ] Frontend: componenti `ColorWheel`, `PanTiltPad`, `ChannelSlider`, `FixtureCard`.
- [ ] Throttling/coalescing nel modulo WS.
- [ ] E2E: pad pan/tilt → engine mock riceve i canali coarse/fine attesi.

## Test

- Unit backend: capability→canali per i profili di test; override + scena →
  vince l'override (LTP), il release ripristina la scena.
- Unit frontend: coalescing (drag di 100 eventi → ≤ 30 messaggi, ultimo valore esatto).
- E2E: color picker su PAR RGB → frame mock con i valori RGB scelti.
- Manuale su tablet: il pad pan/tilt è usabile con un dito per seguire un punto sul palco.

## Acceptance criteria

- [ ] Muovere il pad con drag continuo non satura la connessione (≤ 30 msg/s) e la
      testa mobile (mock) riceve l'ultimo valore entro 100 ms dal rilascio.
- [ ] Gli override restano attivi dopo disconnessione/riconnessione del client.
- [ ] "Clear all" riporta l'output esattamente alla scena di base (test frame-diff).
- [ ] Le fixture senza una capability non mostrano il controllo relativo (UI guidata
      dal profilo, zero hardcoding per modello).

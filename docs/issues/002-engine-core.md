# ISSUE-002 — Engine core: stato universi, render loop, layer

Labels: `fase-1`, `backend`
Dipende da: ISSUE-001

## Contesto

È il cuore del sistema (DESIGN §4): un loop a ~40 Hz che fonde i layer
(scene → chase/effetti → cue → override manuali) e produce il frame DMX per universo,
con grand master e blackout a valle di tutto.

## Scope

- Stato multi-universo (`u16 → [u8; 512]`), anche se in Fase 1 se ne usa uno solo.
- Render loop su **thread dedicato** che possiede lo stato; comunicazione con il
  resto del processo solo via canali (`mpsc` per i comandi in ingresso,
  `watch`/`broadcast` per lo stato in uscita). Nessun lock condiviso sul percorso caldo.
- Layer con merge: **HTP** per canali marcati *intensity*, **LTP** per gli altri.
  (La marcatura arriva dal profilo fixture; qui basta che il tipo canale sia un input.)
- Fade lineari per attivazione/rilascio scene (durata parametrica).
- Grand master (moltiplica i canali intensity) e blackout (li azzera), applicati
  dopo il merge, sempre.
- In questa issue le "scene" sono strutture in memoria: la persistenza è ISSUE-005.

### Fuori scope

Driver hardware (ISSUE-003), chase/effetti (013/014), cue (015), API (006).

## Attività

- [ ] Tipi: `Universe`, `ChannelValue`, `LayerStack`, comando engine (enum) e
      snapshot di stato (struct serializzabile).
- [ ] Thread engine con tick a 40 Hz (tokio `interval` o thread + `sleep_until`),
      misurazione della durata del tick.
- [ ] Merge HTP/LTP con test esaustivi sui casi limite (canale toccato da più layer,
      layer vuoto, release con fade).
- [ ] Fade engine: interpolazione lineare per-canale con clock monotonico.
- [ ] Grand master + blackout a valle del merge.
- [ ] API interna: `EngineHandle` (clonabile) con metodi tipizzati che incapsulano
      l'invio sui canali.

## Test

- Unit: merge HTP/LTP, fade (valori a metà fade con clock finto), master/blackout.
- Property test (`proptest`): per qualunque sequenza di comandi, i valori restano
  in `0..=255` e blackout ⇒ tutti gli intensity a 0.
- Bench/asserzione: tick medio < 2 ms su hardware di sviluppo con 4 universi pieni.

## Acceptance criteria

- [ ] Con clock finto nei test, attivare una scena con fade 1000 ms produce i valori
      attesi a t=0/500/1000 ms.
- [ ] Blackout porta a 0 tutti i canali intensity a prescindere da scene/override attivi,
      e il rilascio del blackout ripristina esattamente lo stato precedente.
- [ ] Il render loop non contiene alcuna chiamata di I/O (verificabile a review).
- [ ] Un flood di 10.000 comandi in un secondo non fa saltare tick (test con driver
      mock che conta i frame: ~40/s ± 2).

# ISSUE-012 — Clock BPM globale + tap tempo

Labels: `fase-3`, `backend`, `frontend`
Dipende da: ISSUE-002

## Contesto

Per i concerti i chase devono andare a tempo di musica: un clock BPM globale
nell'engine, aggiornabile col tap tempo dall'app (DESIGN §4).

## Scope

- Backend: clock BPM nell'engine (fase + battito corrente, derivati dal clock
  monotonico del render loop). Range 30–300 BPM.
- Comandi WS: `tempo.tap {}` (il server calcola il BPM dalla mediana degli intervalli
  degli ultimi 4–8 tap, scartando outlier e reset dopo 2 s di pausa),
  `tempo.set {bpm}` per input manuale, `tempo.nudge {ms}` per allineare la fase.
- Snapshot di stato: BPM corrente + fase (per far lampeggiare la UI a tempo).
- Frontend: pulsante TAP grande nella tab Live, display BPM, campo di modifica
  manuale, indicatore che pulsa sul beat.

### Fuori scope

Sync MIDI clock / Ableton Link (eventuale issue futura), beat detection da microfono.

## Attività

- [ ] Clock nell'engine + API interna `beat_phase(now) -> f32`.
- [ ] Algoritmo tap (mediana + outlier rejection) con test su sequenze sintetiche.
- [ ] Messaggi WS + schema + tipi TS.
- [ ] UI TAP + indicatore beat (animazione guidata dalla fase ricevuta, con
      compensazione della latenza stimata dal round-trip WS).

## Test

- Unit: tap a 120 BPM esatti → 120 ± 1; tap con jitter ±30 ms → stabile ± 3 BPM;
  un tap isolato dopo pausa → nessun cambio.
- Unit: la fase avanza monotona e non salta al cambio BPM (il beat corrente si
  completa alla vecchia velocità, il successivo parte alla nuova).
- Manuale: tap seguendo un metronomo reale a 90/128/160 BPM → il BPM mostrato
  corrisponde e l'indicatore pulsa a tempo percepito.

## Acceptance criteria

- [ ] Tap tempo raggiungibile con un pollice dalla tab Live (nessuna navigazione).
- [ ] BPM stabile con tap umani imprecisi (test jitter automatico verde).
- [ ] Cambiare BPM non produce salti visivi nei chase in corso (verificato in 013,
      ma la garanzia di fase continua è testata qui).
- [ ] Il BPM sopravvive al riavvio del server (incluso nello snapshot di ISSUE-004).

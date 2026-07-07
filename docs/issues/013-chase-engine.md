# ISSUE-013 — Chase engine + step sequencer UI

Labels: `fase-3`, `backend`, `frontend`
Dipende da: ISSUE-011, ISSUE-012

## Contesto

Chase = sequenza di step (mini-scene) che avanza a tempo (DESIGN §3). Gira nel
layer L1 dell'engine e si aggancia al clock BPM (012). **Un chase attivo continua
per sempre finché non viene fermato**: è il caso citato nel requisito di resilienza —
se i client spariscono, il chase va avanti.

## Scope

- Backend: entità `Chase` (step = riferimento a scena esistente oppure valori inline;
  timing = divisione del beat ×¼…×4 oppure ms fissi; fade tra step 0–100 % del tempo
  step; direzione avanti / ping-pong / random con seed).
- Playback nel layer L1: più chase attivi contemporaneamente (su fixture diverse);
  se due chase toccano la stessa fixture vince l'ultimo avviato (LTP tra chase).
- Comandi WS: `chase.start/stop {chaseId}`, `chase.setSpeed {chaseId, multiplier}`.
- Persistenza: CRUD chase + inclusione nello snapshot attivo (restart ⇒ il chase
  riparte da dove il beat globale dice, ISSUE-004).
- Frontend: tab Live estesa con sezione chase (start/stop, moltiplicatore velocità);
  editor chase: lista step ordinabile, scelta scena per step, timing, anteprima.

### Fuori scope

Effetti generativi continui (014), chase su parametri singoli (è un effect).

## Attività

- [ ] Tipi + CRUD + schema per `Chase`.
- [ ] Playback engine: avanzamento step guidato da `beat_phase`, fade tra step,
      direzioni; test con clock finto.
- [ ] Comandi WS + snapshot.
- [ ] UI editor step sequencer (drag&drop, touch) + controlli Live.
- [ ] Test resilienza dedicato: chase attivo + disconnessione totale client →
      i frame continuano a ciclare (estensione dei test ISSUE-004).

## Test

- Unit: con clock finto a 120 BPM e chase ×1 da 4 step, gli step cambiano ogni 500 ms
  esatti; ping-pong produce 1-2-3-4-3-2-1-2…; random con seed è riproducibile.
- Unit: fade 50 % → a metà step i valori sono l'interpolazione esatta tra step N e N+1.
- Integrazione: `chase.start` → mock riceve frame ciclici; `chase.stop` con release
  fade → ritorno pulito al layer sottostante.
- Resilienza: kill di tutti i client con chase attivo → 60 s dopo il chase cicla ancora
  (test automatico).

## Acceptance criteria

- [ ] Un chase segue il tap tempo: dopo un tap a BPM diverso, il cambio di velocità
      avviene senza salti (fase continua, ISSUE-012).
- [ ] Il test di resilienza "chase sopravvive senza client" è verde in CI.
- [ ] Dopo restart del server, il chase attivo riprende automaticamente (snapshot).
- [ ] Creare e avviare un chase di 4 step da UI richiede < 2 minuti (verifica manuale).

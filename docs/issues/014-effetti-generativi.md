# ISSUE-014 — Effetti generativi su gruppi

Labels: `fase-3`, `backend`, `frontend`
Dipende da: ISSUE-009, ISSUE-012

## Contesto

Effetti parametrici continui calcolati dall'engine (DESIGN §3): onde di dimmer,
cicli colore, movimenti pan/tilt. Si applicano a un gruppo con offset di fase tra
le fixture (l'effetto "onda" lungo il palco).

## Scope

- Backend: entità `Effect` = { gruppo, capability target, forma d'onda
  (sine/ramp/square/random-step), rate (divisione beat o Hz), ampiezza, centro,
  **spread di fase** tra le fixture del gruppo (0–100 %) }.
- Capability supportate: intensity (onda dimmer), color hue (rainbow/cycle),
  pan/tilt (cerchi, figure a 8 = sine su entrambi con fase 90°).
- Playback nel layer L1, componibile con scene e chase (l'effetto modula sopra la
  base: es. scena blu + onda dimmer).
- Comandi WS: `effect.start/stop`, `effect.setParam {effectId, param, value}` (live).
- CRUD + snapshot attivo (come chase).
- Frontend: pannello effetti nella tab Live (start/stop + slider rate/ampiezza live);
  editor effetti semplice (form, non serve timeline).

### Fuori scope

Pixel mapping / matrici, effetti audio-reattivi, editor curve custom.

## Attività

- [ ] Generatori forma d'onda puri (`fn(phase: f32) -> f32`) con unit test.
- [ ] Applicazione a gruppo con spread di fase; risoluzione capability→canali (da 010).
- [ ] Composizione nel layer L1: effect *modula* il valore base (moltiplicativo per
      intensity, additivo con clamp per pan/tilt, rotazione hue per il colore).
- [ ] Comandi WS + CRUD + schema.
- [ ] UI pannello + editor.

## Test

- Unit: ogni waveform campionata su un periodo → valori attesi (golden);
  spread 100 % su 4 fixture → fasi 0/25/50/75 %.
- Unit: composizione — scena dimmer 200 + onda ampiezza 50 % → oscilla 100–200,
  mai fuori range.
- Integrazione: effetto pan/tilt circle su testa mobile 16-bit → i canali coarse/fine
  descrivono un cerchio (verifica su sequenza di frame mock).
- Resilienza: effetto attivo senza client → continua (come 013).

## Acceptance criteria

- [ ] "Onda dimmer lungo il palco" configurabile da UI in < 1 minuto su un gruppo
      esistente (verifica manuale).
- [ ] Gli effetti seguono il tap tempo quando il rate è in divisioni di beat.
- [ ] Cambiare un parametro live (slider) si riflette sull'output entro 100 ms
      senza discontinuità visive.
- [ ] Effetto + chase + scena sulla stessa fixture producono output deterministico
      e documentato (regole di composizione scritte in DESIGN §4).

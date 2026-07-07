# ISSUE-009 — Libreria fixture: import formato Open Fixture Library

Labels: `fase-2`, `backend`
Dipende da: ISSUE-005

## Contesto

Con ~30 fari e teste mobili, i profili canale non si scrivono a mano: si importa
il JSON di [Open Fixture Library](https://open-fixture-library.org) (DESIGN §2/§3).

## Scope

- Parser del formato fixture OFL, limitato al sottoinsieme utile:
  `modes`, `availableChannels`, capability `Intensity`, `ColorIntensity` (RGB/W/A/UV),
  `Pan`, `Tilt`, `ColorWheelIndex`/`WheelSlot`, `ShutterStrobe`, `Generic`.
  Capability non riconosciute → canale `generic` con warning, mai errore fatale.
- Endpoint `POST /api/fixture-defs/import` (upload JSON singolo) e
  `GET /api/fixture-defs` con ricerca per nome/produttore.
- Mapping OFL → `FixtureDefinition` interno; il flag *intensity* dei canali (per il
  merge HTP dell'engine) deriva dalle capability.
- 5–10 profili OFL reali committati come fixture di test (i modelli che possiede
  l'utente in primis).

### Fuori scope

Sync automatico con il repo OFL, editor grafico di profili (a mano si può sempre
scrivere il JSON), ruote gobo avanzate/matrix/pixel mapping.

## Attività

- [ ] Tipi del sottoinsieme OFL + parser con `serde` e test sui profili committati.
- [ ] Conversione in `FixtureDefinition` + persistenza.
- [ ] Endpoint import/list/get/delete con validazioni.
- [ ] Documentare in `docs/` come scaricare un profilo da OFL e importarlo.

## Test

- Unit: parsing dei profili committati (almeno: 1 PAR RGB, 1 PAR RGBW, 1 testa mobile
  con pan/tilt 16-bit, 1 dimmer 1ch); capability ignota → `generic` + warning.
- Integrazione: import via API → la definizione è patchabile e l'engine riceve i
  flag intensity corretti.
- Golden test: mapping OFL→interno stabile via snapshot.

## Acceptance criteria

- [ ] I profili dei fari reali dell'utente si importano senza modifiche a mano.
- [ ] Una testa mobile importata espone pan/tilt (anche 16-bit coarse/fine) e i canali
      colore con i tipi giusti.
- [ ] Un JSON OFL malformato restituisce 422 con il motivo, senza effetti collaterali.
- [ ] Il flag intensity dei canali derivato da OFL pilota correttamente il merge HTP
      (test end-to-end con engine mock).

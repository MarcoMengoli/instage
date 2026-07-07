# ISSUE-018 — Export/import Show completo

Labels: `fase-5`, `backend`, `frontend`
Dipende da: ISSUE-005, ISSUE-011, ISSUE-013, ISSUE-015

## Contesto

Lo "Show" è il contenitore di tutto (DESIGN §3): patch, gruppi, scene, chase,
effetti, cue list, impostazioni universi. Deve viaggiare come **un singolo file JSON**
per backup e per portare il setup a un altro concerto/altro Pi.

## Scope

- Export: `GET /api/show/export` → JSON unico, versionato (`formatVersion`),
  autoconsistente (include le FixtureDefinition usate, così l'import non dipende
  dalla libreria del server di destinazione).
- Import: `POST /api/show/import` con strategia esplicita: `replace` (sostituisce
  tutto l'esistente, con conferma) o `merge` (aggiunge con rinomina automatica dei
  conflitti). L'import è **transazionale**: o tutto o niente.
- Import di versioni precedenti del formato: migrazione automatica dove possibile,
  errore chiaro dove no.
- Frontend (tab Setup): esporta (download/share sheet), importa (file picker),
  anteprima di cosa contiene il file prima di confermare.
- Backup automatico: export su disco locale del Pi a ogni modifica strutturale
  (rotazione ultimi N).

### Fuori scope

Sync cloud, diff/merge visuale tra show.

## Attività

- [ ] Serializzazione Show completa + `formatVersion` + test round-trip.
- [ ] Import transazionale con strategie replace/merge + report esiti.
- [ ] Endpoint + UI export/import con anteprima.
- [ ] Backup automatico con rotazione.
- [ ] Documentare il formato in `docs/SHOW-FORMAT.md`.

## Test

- Round-trip: export → DB azzerato → import → export ⇒ i due export sono identici
  (a meno di id/timestamp, normalizzati nel test).
- Import su server con dati: `merge` rinomina i conflitti e non tocca l'esistente;
  `replace` sostituisce tutto.
- File corrotto / versione futura → errore chiaro, DB intatto (transazionalità).
- Manuale: export da un Pi, import su un'installazione pulita → lo show è
  utilizzabile subito (patch inclusa).

## Acceptance criteria

- [ ] Il round-trip export/import è bit-stabile (test automatico).
- [ ] Un import fallito a metà non lascia il DB in stato parziale.
- [ ] Il file esportato si apre e si importa su un server appena installato senza
      alcun prerequisito (definizioni fixture incluse).
- [ ] Il backup automatico conserva gli ultimi N export e si dimostra ripristinabile.

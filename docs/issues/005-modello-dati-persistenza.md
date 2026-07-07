# ISSUE-005 — Modello dati, persistenza SQLite, schema condiviso

Labels: `fase-1`, `backend`
Dipende da: ISSUE-001

## Contesto

Le entità (DESIGN §3): FixtureDefinition (formato OFL), Fixture/patch, Group, Scene,
Chase, Effect, CueList, Show. Il contratto è unico: tipi Rust → JSON Schema →
tipi TypeScript generati.

## Scope

- Tipi Rust con `serde` + `schemars` per: Fixture (patch), Group, Scene.
  Gli altri (Chase, Effect, CueList) si definiscono nelle rispettive issue ma lo
  scheletro dello Show li prevede già.
- Persistenza `rusqlite`: migrazioni versionate (embedded), repository CRUD.
- Validazione patch: collisione indirizzi DMX nello stesso universo → errore
  strutturato (non stringa).
- Pipeline schema: comando `cargo run --bin export-schema` → `shared/schema/*.json`;
  in `instage-app`, script `npm run gen:types` → tipi TS via `json-schema-to-typescript`.
- Check CI che fallisce se gli schemi committati non coincidono con quelli generati
  (contratto sempre in sync).

### Fuori scope

Import OFL vero e proprio (009); per ora basta che `FixtureDefinition` sia
compatibile col sottoinsieme OFL usato (modes, canali, tipo capability).

## Attività

- [ ] Tipi Rust + derive `Serialize/Deserialize/JsonSchema` + validazioni.
- [ ] Migrazioni SQLite + repository con test su DB in-memory.
- [ ] Binario `export-schema` e script `gen:types`.
- [ ] Check di sync schema in CI.
- [ ] Seed di sviluppo: 2 PAR RGB + 1 testa mobile finta, 3 scene demo.

## Test

- Unit: round-trip serde per ogni entità; violazioni di validazione
  (indirizzo 0, canale > 512, collisioni) → errori attesi.
- Integrazione: CRUD completo su SQLite in-memory; migrazione da DB vuoto e da
  DB alla versione precedente.
- CI: `gen:types` non produce diff.

## Acceptance criteria

- [ ] Un tipo modificato in Rust senza rigenerare gli schemi fa fallire la CI.
- [ ] I tipi TS generati compilano in `instage-app` con `strict: true`.
- [ ] Patchare due fixture sovrapposte restituisce un errore che indica le fixture
      e i canali in conflitto.
- [ ] Il DB sopravvive a riavvii: le entità create prima del restart esistono dopo.

# InStage

Sistema di controllo luci DMX su rete locale: backend **Rust** su Raspberry Pi,
app **React/TypeScript** (PWA + Capacitor per Android/iPad).

## Documenti chiave

- `docs/DESIGN.md` — architettura, decisioni, modello dati, API, fasi. **Leggilo prima
  di qualunque modifica strutturale**; se una modifica cambia una decisione presa lì,
  aggiorna il documento nello stesso commit.
- `docs/issues/` — piano operativo: un file per issue con test e acceptance criteria.
  Il lavoro si svolge implementando le issue nell'ordine delle dipendenze
  (vedi `docs/issues/README.md`).

## Struttura (target — vedi ISSUE-001)

```
instage-server/   backend Rust (axum + tokio, engine DMX, driver output)
instage-app/      frontend React + Vite + TS (PWA, poi Capacitor)
shared/schema/    JSON Schema generati dai tipi Rust (contratto API)
legacy/           vecchio prototipo Python/Express — non toccare, non riusare
docs/             design e issue
```

## Regole non negoziabili

1. **Autonomia del server** (DESIGN §4): l'output DMX non dipende mai dai client.
   Nessuna modifica può introdurre codice in cui una disconnessione, un errore di
   rete o un client lento cambia, blocca o spegne l'output.
2. Il render loop non fa I/O di rete/DB/disco; parla col resto via canali.
3. Grand master e blackout agiscono a valle di tutto e funzionano sempre.
4. Il contratto API vive nei tipi Rust (`schemars`) → `shared/schema` → tipi TS
   generati. Mai modificare a mano i tipi generati (skill `api-contract`).

## Workflow

- Ogni issue implementata = commit(s) con prefisso `ISSUE-NNN:` e spunta delle
  checkbox nel file issue corrispondente (skill `implement-issue`).
- Prima di considerare chiusa un'issue, tutti gli acceptance criteria devono essere
  verificati (test automatici dove possibile, manuali dove indicato).

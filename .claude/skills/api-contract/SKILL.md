---
name: api-contract
description: Procedura obbligatoria per modificare il contratto API tra backend e frontend (tipi Rust → JSON Schema → tipi TypeScript). Usa questa skill ogni volta che aggiungi o cambi un messaggio WebSocket, un endpoint REST o un'entità condivisa.
---

# Modifica del contratto API

Fonte di verità unica: **i tipi Rust** in `instage-server` con derive
`Serialize + Deserialize + schemars::JsonSchema`. Tutto il resto è generato.

## Procedura (sempre in questo ordine, stesso commit)

1. Modifica/aggiungi il tipo Rust (entità, messaggio WS, body REST) con i derive
   e registralo nell'exporter degli schemi.
2. `cd instage-server && cargo run --bin export-schema` → aggiorna `shared/schema/*.json`.
3. `cd instage-app && npm run gen:types` → aggiorna i tipi TS generati.
4. Adegua il codice frontend che ora non compila (il typecheck è la rete di sicurezza).
5. Se hai cambiato la semantica (non solo la forma), aggiorna `docs/DESIGN.md` §5.
6. Committa tipi Rust + schemi + tipi TS **insieme**: la CI fallisce se
   `shared/schema` non coincide con quanto rigenerato.

## Regole di compatibilità

- I messaggi WS hanno un campo discriminante (`type`) e i client ignorano i tipi
  sconosciuti: **aggiungere** messaggi/campi opzionali è sicuro.
- **Rinominare o rimuovere** campi è un breaking change: evitalo; se inevitabile,
  aggiorna insieme server e app (sono deployati insieme, ma le app native installate
  possono essere vecchie → mantieni la retrocompatibilità di lettura per almeno
  una versione).
- Lo snapshot persistito su disco (ISSUE-004) e il formato Show (ISSUE-018) sono
  anch'essi contratti versionati: bump di `version`/`formatVersion` + migrazione
  o scarto esplicito, mai crash su dati vecchi.

## Divieti

- Mai modificare a mano file in `shared/schema/` o i tipi TS generati.
- Mai definire in TS un tipo che rispecchia un tipo Rust: si genera.
- Mai mergiare con lo schema check della CI rosso.

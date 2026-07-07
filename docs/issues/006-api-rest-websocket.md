# ISSUE-006 — API REST + protocollo WebSocket

Labels: `fase-1`, `backend`
Dipende da: ISSUE-002, ISSUE-005

## Contesto

REST per la configurazione (CRUD), WebSocket per il realtime (DESIGN §5).
Tutti i messaggi sono tipizzati e inclusi nel contratto `shared/schema`.

## Scope

- Server axum: routing REST per `fixtures`, `groups`, `scenes`, `settings`
  (le altre risorse arrivano con le rispettive issue).
- WS `/ws`:
  - client→server: `scene.activate/release`, `override.set/clear`, `master.set`,
    `blackout.set` (i messaggi chase/cue arrivano in 013/015);
  - server→client: `state.full` alla connessione, `state.delta` broadcast a ogni
    variazione (throttled a max ~20 msg/s).
- Errori REST uniformi (RFC 7807 problem+json) e errori WS come messaggio `error`
  correlato da un `requestId` opzionale.
- Serve i file statici della web app buildata (`tower-http`), con fallback SPA.
- CORS aperto alla LAN in dev.

### Fuori scope

Autenticazione (post-v1), preview DMX via WS (nice-to-have, issue futura).

## Attività

- [ ] Layer HTTP: router, estrattori, mapping errori dominio → problem+json.
- [ ] Handler WS: handshake → invio `state.full` → loop select su
      (comandi client / broadcast stato).
- [ ] Tipi messaggio WS in Rust con `schemars`, aggiunti alla pipeline schema (005).
- [ ] Integrazione con `EngineHandle` (002): ogni messaggio WS mappa 1:1 su un
      comando engine.
- [ ] Logging strutturato (`tracing`) con request-id.

## Test

- Integrazione (server in-process + client `tokio-tungstenite`):
  1. due client connessi: il comando dal client A produce `state.delta` su A e B
     entro 100 ms;
  2. `scene.activate` con `sceneId` inesistente → messaggio `error`, connessione viva;
  3. payload JSON malformato → `error`, connessione viva, engine intatto;
  4. REST: CRUD scene end-to-end + errori di validazione → 422 problem+json.
- Snapshot test del messaggio `state.full` (stabilità del contratto).

## Acceptance criteria

- [ ] Ogni messaggio WS e ogni body REST hanno uno schema in `shared/schema`
      e i tipi TS generati.
- [ ] Un input invalido (REST o WS) non altera mai lo stato dell'engine e non chiude
      il processo; l'errore riporta il motivo.
- [ ] Due client vedono lo stesso stato entro 100 ms da qualunque comando (test 1).
- [ ] La web app buildata viene servita da `/` con fallback SPA funzionante.

# ISSUE-001 — Scaffolding monorepo e CI

Labels: `fase-0`, `infra`
Dipende da: —

## Contesto

Il repo contiene un prototipo (Python + MQTT + Express) che non verrà riusato.
Serve la struttura del nuovo sistema descritto in `docs/DESIGN.md` §6.

## Scope

- Spostare il vecchio codice in `legacy/` (nessuna cancellazione).
- Creare `instage-server/` (Rust) e `instage-app/` (React) come progetti vuoti ma
  compilanti, e `shared/schema/` per il contratto API.
- CI GitHub Actions che tiene verde tutto a ogni push.

### Fuori scope

Qualunque funzionalità: qui si prepara solo il terreno.

## Attività

- [ ] Spostare `instage/` (service Python, api Express, docker-compose) in `legacy/`.
- [ ] `instage-server/`: `cargo new`, toolchain pinnata (`rust-toolchain.toml`),
      `rustfmt.toml`, clippy in modalità `-D warnings`, un test di fumo.
- [ ] `instage-app/`: progetto Vite + React + TypeScript strict, ESLint + Prettier,
      Vitest con un test di fumo.
- [ ] `shared/schema/.gitkeep` + README che spiega che i file sono generati.
- [ ] Workflow CI: job `server` (fmt --check, clippy, test) e job `app`
      (lint, typecheck, test, build).
- [ ] README di root aggiornato: cos'è il progetto, struttura, come buildare.

## Test

- CI verde sul branch con entrambi i job.
- `cargo test` e `npm test` passano in locale da checkout pulito.

## Acceptance criteria

- [ ] Da checkout pulito, `cargo build` in `instage-server/` e `npm ci && npm run build`
      in `instage-app/` completano senza errori.
- [ ] La CI fallisce se si introduce un warning clippy o un errore di lint/typecheck.
- [ ] Il vecchio codice è in `legacy/` e non è referenziato da nulla di nuovo.
- [ ] Il README di root descrive la struttura e i comandi base.

---
name: frontend-dev
description: Convenzioni e comandi per lavorare sul frontend React/TypeScript (instage-app) — UI touch-first, PWA, client WebSocket, Capacitor. Usa questa skill prima di scrivere o modificare codice in instage-app/.
---

# Sviluppo frontend (instage-app)

## Comandi

```bash
cd instage-app
npm run dev          # dev server Vite (proxy verso il backend locale)
npm run lint         # ESLint + Prettier check
npm run typecheck    # tsc --noEmit (strict)
npm test             # Vitest
npm run test:e2e     # Playwright (richiede il server con driver mock attivo)
npm run gen:types    # rigenera i tipi TS da shared/schema (vedi skill api-contract)
npm run build        # build produzione (poi servita dal binario Rust)
```

## Regole

1. **Tipi API sempre generati.** I tipi di messaggi WS ed entità vengono da
   `shared/schema` via `npm run gen:types`: mai definirli a mano, mai modificarli
   a mano. Se manca un tipo, si aggiunge lato Rust (skill `api-contract`).
2. **Il server è la verità.** La UI mostra lo stato ricevuto (`state.full`/
   `state.delta`), non lo stato che "dovrebbe" risultare dai comandi inviati.
   Optimistic update solo per feedback immediato (< 200 ms) e sempre riconciliato
   col prossimo delta.
3. **Riconnessione automatica ovunque.** Il modulo WS riconnette con backoff
   (0.5→8 s) e risincronizza da `state.full`. Offline: banner visibile con
   "le luci restano come sono", comandi rifiutati con feedback — mai accodati
   alla cieca.
4. **Touch-first.** Target ≥ 44 px; azioni pericolose (blackout, delete, replace)
   mai su singolo tap: slide-to-confirm o conferma esplicita. GO enorme.
   Testare portrait (telefono) e landscape (tablet).
5. **Comandi continui throttled.** Fader/pad/picker: coalescing a ~30 msg/s,
   si invia l'ultimo valore, non la coda di eventi.
6. **Stato con Zustand**, slice per dominio (`connection`, `engineState`, `editor`).
   Niente stato server duplicato in stato locale dei componenti.

## Test

- Componenti: Vitest + Testing Library (comportamento, non snapshot markup).
- E2E: Playwright contro il server reale con driver mock — i test E2E verificano
  l'effetto sull'engine (frame mock), non solo la UI.
- Ogni bug di sync trovato a mano diventa un test E2E.

## Definition of done

Feature + test + lint/typecheck puliti + verifica manuale touch su viewport
mobile (DevTools va bene, device reale per le issue che lo richiedono) +
acceptance criteria dell'issue verificati.

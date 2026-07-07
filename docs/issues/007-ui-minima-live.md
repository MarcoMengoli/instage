# ISSUE-007 — Web UI minima: scene, grand master, blackout (PWA)

Labels: `fase-1`, `frontend`
Dipende da: ISSUE-006

## Contesto

La prima UI usabile a un concerto: griglia di scene, grand master, blackout.
Touch-first (telefono/tablet), installabile come PWA, sempre sincronizzata via WS.

## Scope

- Setup applicativo: React + Vite + TS strict, Zustand per lo stato, client WS
  con **riconnessione automatica** (backoff 0.5→8 s) e risincronizzazione da
  `state.full` alla riconnessione.
- Vista **Live**: griglia pulsanti scena (attiva evidenziata), slider grand master,
  blackout con **slide-to-confirm** (mai un tap secco).
- Banner di stato connessione: connesso / riconnessione in corso (con l'avviso
  "le luci restano come sono" quando offline).
- PWA: manifest, icone, service worker (`vite-plugin-pwa`) che cache-a la shell;
  l'app si apre anche offline mostrando lo stato "in attesa di connessione".
- Target touch ≥ 44 px, layout portrait (telefono) e landscape (tablet).

### Fuori scope

Controllo fixture (010), editor scene (011), Capacitor (017).

## Attività

- [ ] Store Zustand: slice `connection`, `engineState`, azioni = messaggi WS tipizzati
      (tipi generati da `shared/schema`).
- [ ] Modulo WS: connect, heartbeat/pong, riconnessione con backoff, coda comandi
      scartata quando offline (i comandi non si accodano: si rifiutano con feedback).
- [ ] Componenti: `SceneGrid`, `MasterFader`, `BlackoutSlider`, `ConnectionBanner`.
- [ ] PWA manifest + SW + icone.
- [ ] Test componenti (Vitest + Testing Library) e E2E (Playwright contro il server
      con driver mock).

## Test

- Unit: riduzione `state.delta` nello store; slide-to-confirm non scatta con tap/drag
  parziale.
- E2E: attiva scena → l'engine mock riflette i valori; disconnetti il server →
  banner riconnessione; riavvia il server → l'app torna sincronizzata senza reload.
- Manuale: installazione PWA su un Android e un iPad reali; uso con dita, non mouse.

## Acceptance criteria

- [ ] Da telefono, in < 3 tocchi dall'apertura si attiva una scena.
- [ ] Il blackout non è attivabile con un singolo tap accidentale.
- [ ] Con server riavviato mentre l'app è aperta, l'app si riconnette e mostra lo
      stato corretto senza intervento (niente reload manuale).
- [ ] Lighthouse: installabilità PWA verde su Android e iPad (Safari "Aggiungi a Home").
- [ ] E2E Playwright verdi in CI.

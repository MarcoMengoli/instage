# ISSUE-017 — Pacchetti nativi Android e iPad (Capacitor)

Labels: `fase-5`, `frontend`, `infra`
Dipende da: UI matura (almeno ISSUE-007, ISSUE-010; idealmente dopo ISSUE-015)

## Contesto

La PWA copre già Android e iPad; qui si aggiunge il packaging nativo con Capacitor
(DESIGN §6) per: icona/app "vera", schermo sempre acceso durante lo show, e margine
per future integrazioni native.

## Scope

- Integrazione Capacitor nel progetto `instage-app` (stessa codebase, zero fork).
- **Android**: APK firmato, distribuito come release GitHub (niente Play Store per ora).
- **iPadOS**: progetto Xcode generato e documentato; build con Apple Developer
  account personale (documentare anche la via sideload 7-giorni).
- Plugin nativi: keep-awake (schermo acceso), status bar nascosta in vista operatore,
  haptic feedback su GO/blackout (dove supportato).
- Discovery del server: campo manuale + tentativo `instage.local`; salvataggio
  dell'ultimo server usato. (mDNS nativo via plugin è opzionale, non bloccante.)
- Gestione lifecycle: al ritorno in foreground l'app riconnette e risincronizza
  subito (il WS in background può essere stato chiuso dall'OS).

### Fuori scope

Pubblicazione sugli store, push notification, widget.

## Attività

- [ ] Setup Capacitor + config (app id, icone, splash).
- [ ] Build Android in CI (APK firmato su tag release).
- [ ] Progetto iOS + documentazione build/sideload in `docs/MOBILE.md`.
- [ ] Plugin keep-awake + haptics + gestione foreground/background.
- [ ] Schermata di connessione al server (input + ultimo usato + test connessione).

## Test

- E2E web invariati (la codebase è la stessa).
- Manuale Android: installa APK, spegni/riaccendi schermo, metti in background 10 min
  → al ritorno l'app si risincronizza da sola; keep-awake attivo in vista operatore.
- Manuale iPad: build via Xcode su device reale, stessi test lifecycle.
- Manuale rete: cambia rete Wi-Fi del tablet → l'app segnala offline e riaggancia
  quando torna sulla rete giusta.

## Acceptance criteria

- [ ] L'APK si installa e funziona su Android 10+ senza ADB/sviluppatore.
- [ ] Su entrambe le piattaforme il rientro dal background risincronizza senza
      interazione (e ovviamente senza aver influenzato le luci — ISSUE-004).
- [ ] In vista operatore lo schermo non si spegne mai.
- [ ] `docs/MOBILE.md` permette di fare la build iPad da zero a una persona nuova.

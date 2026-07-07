# ISSUE-011 — Editor scene: store dallo stato live + gestione gruppi

Labels: `fase-2`, `frontend`, `backend`
Dipende da: ISSUE-010

## Contesto

Il modo naturale di creare scene è "prepara il look dal vivo e salvalo" (store),
come sulle console vere. Qui si aggiunge anche la gestione dei gruppi.

## Scope

- Backend: comando `scene.store {name, fixtureIds?, fadeMs}` che cattura lo stato
  *renderizzato* delle fixture indicate (o di quelle con override attivo se omesso)
  e lo salva come scena sparsa; `scene.update` per sovrascrivere una scena esistente.
- Backend: CRUD gruppi (`groups`) + uso dei gruppi nella selezione dello store.
- Frontend:
  - pulsante "Store" nella tab Fixtures: selezione fixture/gruppi → nome → salva;
  - gestione scene: rinomina, riordina (l'ordine pilota la griglia Live), elimina
    (con conferma), modifica fade di default;
  - gestione gruppi: crea/rinomina/elimina, assegna fixture.
- La griglia Live (007) si aggiorna in tempo reale su tutti i client quando le scene
  cambiano.

### Fuori scope

Editor "a freddo" canale-per-canale di una scena salvata (si può sempre: attiva →
modifica con override → re-store); chase (013).

## Attività

- [ ] Backend: snapshot valori per-fixture dallo stato engine + salvataggio sparso.
- [ ] Backend: CRUD gruppi + validazioni (gruppo con fixture inesistente → 422).
- [ ] Frontend: flusso Store (selezione → nome → conferma) in ≤ 3 passaggi.
- [ ] Frontend: schermata gestione scene con riordino drag&drop touch.
- [ ] Broadcast `state.delta` per le modifiche a scene/gruppi (tutti i client
      vedono la nuova scena subito).

## Test

- Integrazione: prepara look con override → store → clear all → attiva la scena →
  i frame mock coincidono col look preparato (frame-diff esatto).
- Unit: store "sparso" non tocca fixture non selezionate.
- E2E: crea scena da UI, appare sulla griglia Live di un secondo client senza reload.
- Manuale: riordino drag&drop con dita su tablet.

## Acceptance criteria

- [ ] Store → clear → attivazione riproduce il look in modo bit-esatto (test automatico).
- [ ] Eliminare una scena attiva la rilascia con fade, senza errori né buio improvviso.
- [ ] Le modifiche a scene/gruppi si propagano a tutti i client entro 1 s.
- [ ] Una scena storata su fixture poi rimossa dal patch non rompe l'attivazione:
      i canali orfani vengono ignorati con warning.

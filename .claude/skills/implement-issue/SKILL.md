---
name: implement-issue
description: Workflow per implementare una issue di docs/issues/ dall'inizio alla chiusura - verifica dipendenze, implementazione, test, spunta degli acceptance criteria, commit. Usa questa skill quando l'utente chiede di implementare una ISSUE-NNN o "la prossima issue".
---

# Implementare una issue

Le issue vivono in `docs/issues/NNN-*.md`; l'indice con ordine e dipendenze è
`docs/issues/README.md`.

## Workflow

1. **Leggi l'issue per intero** (contesto, scope, fuori scope, attività, test,
   acceptance criteria). Se l'utente dice "la prossima", scegli dalla tabella
   dell'indice la prima issue non completata con tutte le dipendenze chiuse.
2. **Verifica le dipendenze**: le issue elencate in "Dipende da" devono avere tutti
   gli acceptance criteria spuntati. Se no, fermati e segnalalo.
3. **Carica la skill di dominio**: `backend-dev` per lavoro in `instage-server/`,
   `frontend-dev` per `instage-app/`, entrambe se l'issue tocca tutto lo stack.
   Se tocchi il contratto API, segui `api-contract`.
4. **Implementa per attività**: segui la checklist "Attività" nell'ordine, spuntando
   le voci nel file man mano che le completi.
5. **Scrivi i test descritti nella sezione "Test"** — sono parte dello scope, non
   opzionali. I test manuali che non puoi eseguire (hardware reale, device fisici)
   restano non spuntati: elencali esplicitamente all'utente a fine lavoro.
6. **Verifica gli acceptance criteria uno per uno** ed esegui davvero la verifica
   (non spuntare per inferenza). Spunta nel file solo quelli verificati.
7. **Rispetta lo scope**: se durante il lavoro emerge qualcosa di necessario ma
   fuori scope, crea una nuova issue con la skill `new-issue` invece di allargare
   questa.
8. **Committa** con messaggi `ISSUE-NNN: descrizione`, includendo le spunte
   aggiornate del file issue nello stesso commit del codice.

## Regole

- Un'issue è chiusa solo con tutti gli acceptance criteria spuntati; se restano
  verifiche manuali, dillo chiaramente: "implementata, in attesa di verifica
  manuale X e Y".
- Se un acceptance criterion si rivela sbagliato o non verificabile, non
  modificarlo in silenzio: proponi la modifica all'utente motivandola.
- I test di resilienza esistenti (ISSUE-004) devono restare verdi qualunque cosa
  tu stia implementando.

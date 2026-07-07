---
name: new-issue
description: Crea una nuova issue in docs/issues/ seguendo il template del progetto (contesto, scope, attività, test, acceptance criteria) e aggiorna l'indice. Usa questa skill quando emerge lavoro nuovo da tracciare o l'utente chiede di creare una issue.
---

# Creare una nuova issue

1. Scegli il prossimo numero libero `NNN` (guarda `docs/issues/`, la numerazione
   non si riusa mai, anche per issue abbandonate).
2. Crea `docs/issues/NNN-slug-breve.md` con il template sotto.
3. Aggiungi la riga alla tabella di `docs/issues/README.md` (ID, titolo, fase,
   dipendenze) e, se serve, al diagramma dell'ordine.
4. Le dipendenze vanno dichiarate pensando a "cosa deve esistere perché questa
   issue sia implementabile e testabile", non all'ordine cronologico ideale.

## Template

```markdown
# ISSUE-NNN — Titolo imperativo e specifico

Labels: `fase-N`, `backend`|`frontend`|`hardware`|`infra`
Dipende da: ISSUE-XXX, ISSUE-YYY (oppure —)

## Contesto

2–4 righe: perché serve, riferimento a DESIGN.md §N se applicabile.

## Scope

Cosa include, in modo verificabile.

### Fuori scope

Cosa esplicitamente NON include (e dove finirà, se noto).

## Attività

- [ ] Passi concreti di implementazione, spuntabili.

## Test

Test automatici da scrivere e test manuali da eseguire, con procedura.

## Acceptance criteria

- [ ] Criteri osservabili e verificabili uno per uno. Ogni criterio deve poter
      ricevere un sì/no oggettivo, mai "funziona bene".
```

## Qualità dei criteri

- Ogni acceptance criterion deve essere falsificabile: se non sai descrivere come
  verificarlo, riscrivilo.
- I requisiti trasversali del progetto (autonomia dal client, master/blackout,
  contratto API generato) non si ripetono in ogni issue: valgono sempre
  (vedi CLAUDE.md); cita solo le implicazioni specifiche.

# ISSUE-015 — Cue list: engine, editor, vista operatore

Labels: `fase-4`, `backend`, `frontend`
Dipende da: ISSUE-011, ISSUE-013

## Contesto

La scaletta dello spettacolo (DESIGN §3): sequenza ordinata di cue, ognuna attiva
scene/chase/effetti con fade time; l'operatore preme **GO**. Layer L2 dell'engine.

## Scope

- Backend: entità `CueList` e `Cue` = { nome, contenuti (scene/chase/effect da
  attivare e da fermare), fadeIn ms, opzionale follow { delay ms } per cue
  automatiche }.
- Playback: un cursore per cue list; comandi WS `cue.go`, `cue.back`,
  `cue.jump {index}`, `cue.release` (ferma la cue list con fade).
  GO durante un fade in corso: il fade si completa istantaneamente e parte la
  cue successiva (comportamento standard console).
- Il cursore è nello snapshot persistito: restart a metà spettacolo ⇒ si riparte
  dalla stessa cue (requisito resilienza).
- Frontend:
  - **vista operatore**: cue corrente + prossima ben visibili, GO gigante (≥ 25 %
    dello schermo), BACK piccolo e distante, progress bar del fade, numero cue;
  - editor cue list: ordina cue, assegna contenuti da picker, fade/follow.
- Multi-client: se due operatori premono GO quasi insieme, il secondo GO entro
  500 ms viene ignorato con feedback (debounce server-side).

### Fuori scope

Timecode (SMPTE/MIDI), tracce parallele multiple, tracking per-canale stile console
teatrale (le cue qui attivano/disattivano oggetti, non tracciano canali).

## Attività

- [ ] Tipi + CRUD + schema `CueList`/`Cue`.
- [ ] Playback engine con cursore, GO/BACK/JUMP, follow con timer, snapshot.
- [ ] Debounce GO multi-client.
- [ ] UI vista operatore + editor.
- [ ] Test integrazione spettacolo simulato (sotto).

## Test

- Unit: GO avanza e applica fade; GO durante fade → completamento istantaneo + next;
  BACK torna alla cue precedente con fade; follow scatta al delay giusto (clock finto).
- Integrazione "spettacolo": cue list di 10 cue con scene+chase → sequenza di GO →
  i frame mock corrispondono allo stato atteso dopo ogni GO (golden test).
- Resilienza: kill del server alla cue 5 → restart → lo stato è la cue 5, GO
  prosegue alla 6.
- Manuale: prova generale con 2 dispositivi (operatore + backup) su uno spettacolo
  di prova.

## Acceptance criteria

- [ ] Dalla vista operatore, GO è azionabile alla cieca (pollice, senza guardare).
- [ ] Doppio GO accidentale entro 500 ms non salta due cue.
- [ ] Restart del server a metà scaletta riprende dalla cue corrente (test automatico).
- [ ] La cue successiva è sempre visibile prima di premere GO (nome + numero).

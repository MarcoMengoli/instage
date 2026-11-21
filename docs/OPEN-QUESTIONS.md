# InStage — Open Questions & Decision Log

> **Stato:** BOZZA v0.1 — 21 novembre 2026.  
> **Funzione:** impedire che decisioni non prese siano presentate come requisiti.  
> **Regola:** risolvere una domanda significa aggiornare questo file **e** gli altri documenti interessati. Non limitarsi a cambiare un mockup o a chiudere un'issue.

Documenti correlati: [Product Vision](PRODUCT-VISION.md) · [Functional Requirements](FUNCTIONAL-REQUIREMENTS.md) · [Performance Mode](PERFORMANCE-MODE.md).

## 1. Stato delle decisioni

Ogni elemento ha:
- **ID stabile** `D-...` (confermato) o `OQ-...` (aperto).
- **Fonte** della decisione: feedback esplicito del product owner, problema reale, proposta tecnica.
- **Motivo** e conseguenze sul dominio/UX.
- **Follow-up** da validare prima del codice.
- **Stato**: CONFIRMED, PROPOSED, OPEN, SUPERSEDED.

**Nota per agenti:** le ipotesi di design non sono decisioni anche se compaiono come default in un prototipo. Se un lavoro dipende da una OQ aperta, limitarsi alla parte indipendente e lasciare visibile il blocco.

## 2. Decision log: conclusioni confermate

### D-001 — Repository canonico [CONFIRMED]
- **Scelta:** nuovo prodotto nel repository `MarcoMengoli/instage`; `MarcoMengoli/instage-ai` rimane POC.
- **Conseguenza:** documentazione, ADR e sviluppo futuri appartengono a `instage`; non modificare il POC come parte dello sviluppo del nuovo prodotto senza richiesta separata.
- **Nota:** `instage` contiene anche storia legacy: non assumere che l'implementazione presente rappresenti l'architettura target.

### D-002 — POC validato come fattibilità sul palco [CONFIRMED]
- **Evidenza:** il product owner riferisce di avere usato `instage-ai` in un live, con funzionamento della tecnologia/comunicazione sufficiente allo show.
- **Non implica:** test di carico completi, target di latenza certificati, assenza di failure, qualità UX adeguata o supporto per nuovi controller.

### D-003 — Differenziazione delle interfacce [CONFIRMED]
- **Scelta:** Web UI soprattutto per scene/automazioni; Launchpad X anche per improvvisare manualmente; iRig Pads soprattutto per scene, BPM e variazioni di velocità.
- **Conseguenza:** unificare comandi e stato, non forzare UI identiche su ogni device.

### D-004 — Automatic e Performance alternative [CONFIRMED]
- **Scelta:** una prima azione di Performance prende il controllo al posto delle automazioni. Il ritorno in Automatic è esplicito.
- **Aperto:** quali pad siano considerati «prima azione»; fade/cut e semantica di ripristino.
- **Non introdurre:** un override che torna automaticamente alla scena al semplice release del pad.

### D-005 — Restart delle automazioni [CONFIRMED]
- **Scelta:** al ritorno in Automatic, effetti e automazioni selezionate **ripartono dall'inizio**.
- **Non scelto:** ripresa alla posizione temporale precedente o avanzamento invisibile in background.
- **Aperto:** beat/bar quantization, fade, seed degli effetti random e mantenimento del BPM globale.

### D-006 — Due righe distinte di controllo luce [CONFIRMED]
- **Scelta:** HOLD e TOGGLE su righe separate con corrispondenza di colonna/destinatario.
- **Motivo:** lasciare alcuni fari sempre accesi e usare altri per suonare ritmicamente.

### D-007 — HOLD momentaneo e indipendente [CONFIRMED]
- **Scelta:** premere un pad HOLD accende il suo destinatario; rilasciarlo lo spegne. Più HOLD su fari diversi restano indipendenti e simultanei.

### D-008 — TOGGLE persistente [CONFIRMED]
- **Scelta:** primo press accende e mantiene; secondo press spegne.

### D-009 — HOLD disinnesca TOGGLE sullo stesso faro [CONFIRMED]
- **Scelta:** se TOGGLE A è acceso e viene premuto HOLD A, TOGGLE A va OFF. Al release di HOLD A, A si spegne; **non ritorna** all'attivazione persistente precedente.
- **Motivo:** il comportamento additivo `HOLD OR TOGGLE` era stato proposto e poi esplicitamente scartato per lo stesso faro.

### D-010 — Evitare destinatari sovrapposti nel layout [CONFIRMED]
- **Scelta:** non usare nella superficie performance tasti «tutti i fari» o gruppi che si sovrappongono ai singoli destinatari e creano ambiguità HOLD/TOGGLE.
- **Nota:** ciò non vieta i normali gruppi di fixture nel resto del prodotto.

### D-011 — Intensità da pressione non scelta [CONFIRMED come OPEN]
- **Scelta attuale:** nessuna. Il product owner vuole ancora valutare velocity iniziale vs pressione continua.
- **Conseguenza:** l'architettura può prevedere i due segnali, ma nessuno dei due è il comportamento finale deciso.

### D-012 — Problemi del POC da risolvere [CONFIRMED come esigenze]
- TAP apparentemente instabile e scrolling involontario; input BPM macchinoso/decimali; effetto fuori fase anche con BPM giusti; moltiplicatori arbitrari; lista scene troppo estesa; creazione scene macchinosa.
- Le cause tecniche sono **sconosciute** fino a una diagnosi.

### D-013 — Layout con palette e distribuzioni [PROPOSED, non CONFIRMED]
- **Preferenza emersa:** riga 1 palette, riga 2 distribuzioni, poi righe HOLD/TOGGLE; il product owner ha chiesto esplicitamente di poter ripensare la griglia.
- **Conseguenza:** trattare la disposizione come baseline di discussione, non come schema hardcoded.

### D-014 — Quantizzazione musicale della velocità [PROPOSED]
- Il product owner ha suggerito potenze di due invece di fattori arbitrari (es. 1.389). Definizione precisa, range e significato del moltiplicatore ancora da approvare.

## 3. Domande aperte prioritarie — comportamento prodotto

### OQ-01 — Che cosa attiva Performance?
**Priorità:** BLOCKING P0. **Impatto:** state machine, UX e comando iniziale.

Se in Automatic premi un pad PALETTE o DISTRIBUZIONE (che può anche non accendere nulla), è già un ingresso in Performance? Opzioni:
- A. Qualunque pad Launchpad di Performance cambia subito modalità.
- B. Palette/distribuzione preparano una configurazione; l'ingresso avviene al primo HOLD/TOGGLE/strobo/movimento che produce output.
- C. Una gesture esplicita prima del cambio modalità.

**Motivo:** la frase «appena tocco entra la modalità Performance» esprime ingresso immediato, ma non chiarisce se includa selezioni preparatorie. Non decidere senza conferma. **Test da definire:** primo evento applicato correttamente e nessun blackout inatteso.

### OQ-02 — Ingresso: cosa fanno i fari automatici già accesi?
**Priorità:** BLOCKING P0.

- Cut istantaneo verso lo stato manuale corrente?
- Fade breve/parametrico?
- Attesa del primo evento luminoso?
- Durante la selezione palette, se nessun HOLD/TOGGLE è attivo, devono spegnersi tutte le fixture?

Definire anche il comportamento di teste mobili in movimento, strobo già attivo e canali non-dimmer. Non assumere che «vince Performance» specifichi già questi dettagli.

### OQ-03 — Ritorno ad Automatic: start e transizione
**Priorità:** BLOCKING P0.

La scena e i suoi effetti ripartono da zero (D-005). Restano da scegliere:
- Avvio immediato, prossimo beat, prossima battuta o scelta per azione?
- Fade 0/250/500/1000 ms o parametrico?
- Come si resetta la fase e il seed di chase/random/effect?
- BPM globale conservato, reset o predefinito per scena?
- Quale scena parte se nel frattempo si è cambiata selezione dalla UI?

**Test:** restart visibilmente dall'origine e senza stati intermedi accidentali.

### OQ-04 — Stato manuale quando si torna Automatic e successivamente Performance
**Priorità:** BLOCKING P0.

Che ne è dei TOGGLE rimasti attivi?
- A. Si azzerano al ritorno ad Automatic (nuova Performance parte «pulita»).
- B. Si conservano come impostazioni preparate ma non fanno luce finché non rientri.
- C. Si conservano solo in certe situazioni.

Che fare con un HOLD ancora fisicamente premuto durante il cambio? Rilascio successivo, riarmo, LED e flush devono avere regole coerenti.

### OQ-05 — Fonte del ritorno ad Automatic
**Priorità:** P1.

Da quale controllo si torna? Web UI, pulsante dedicato Launchpad, iRig, tutti? Deve essere intenzionale, non accidentalmente combinabile con pressioni comuni. Feedback confermato prima del cambio.

### OQ-06 — Palette e strategie di distribuzione
**Priorità:** P1.

- Numero palette per bank, creazione/editing, colori singoli/multipli, spazio colore e fallback.
- Distribuzioni MVP: uniforme, alternata, SX/DX, simmetrica, custom? Quali meritano davvero uno degli otto pad?
- Algoritmi per 1/2/3+ colori, 6 fixture, numero dispari di fixture, teste mobili vs PAR.
- Ordine fisico e posizione scenica persistente nello show.
- Cambio palette con fari accesi: hard cut cromatico o fade?
- Palette memorizza mapping per faro o definizione generativa con scelta «override per fixture»?

Richiesti esempi visivi verificabili. Evitare di trattare l'elenco di otto distribuzioni di un mockup come requisito.

### OQ-07 — Luminosità e pressione
**Priorità:** P1. **Non deciso esplicitamente.**

- A. Velocity iniziale determina intensità al NoteOn.
- B. Polyphonic aftertouch cambia intensità durante HOLD.
- C. Due modalità configurabili.
- D. Intensità definita altrove; il pad è solo ON/OFF.
- Cosa significa intensità del TOGGLE? Valore fissato al press, knob/master, velocity del press?
- Curva percepita, gamma, min/max e smoothing per fixture.

Test ergonomico necessario col Launchpad X; non decidere solo sulla base della disponibilità MIDI dichiarata.

### OQ-08 — Conflitti sullo stesso destinatario e proprietari dell'input
**Priorità:** BLOCKING P0.

Confermato soltanto: TOGGLE ON → HOLD press annulla TOGGLE → HOLD release spegne.
Da decidere:
- HOLD attivo → TOGGLE press: ignorato, arma per dopo, sostituisce HOLD, errore?
- Due pressioni HOLD dello stesso destinatario da due controller: multi-owner o uno solo?
- Duplicate NoteOn, NoteOff fuori ordine, note a velocity 0, reconnect.
- Press di TOGGLE ripetuti mentre il pad non è ancora stato rilasciato.

Servono modello eventi, ownership e una tabella transizioni completa prima dell'implementazione.

### OQ-09 — Disconnessione MIDI e release forzato
**Priorità:** BLOCKING P0.

- Disconnessione fisica durante HOLD: release immediato o dopo timeout?
- TOGGLE persiste quando un controller è scollegato?
- Reconnect re-inizializza stato MIDI/LED come? E se il tasto è ancora tenuto?
- Differenze tra disconnessione browser, hardware USB, restart service.

Serve test con device reale e piano fail-safe documentato.

### OQ-10 — Destinatari: fixture vs gruppi e gestione bank
**Priorità:** P1.

Le colonne controllano sempre una fixture singola? Oppure possono mappare un insieme inseparabile purché non sovrapposto? Come validare collisioni? Come cambiare bank con HOLD attivo? Come mostrare 8 slot quando le fixture sono meno/più di 8?

### OQ-11 — Righe 5–8 e pulsanti esterni Launchpad
**Priorità:** P1.

Righe 1–4 sono l'ipotesi più sviluppata. Le altre potrebbero ospitare strobo, movimenti, scene e tempo, ma è stato esplicitamente richiesto di ripensare la disposizione.
- Quante scene direttamente sulla griglia, se la UI web è il canale primario?
- Movimenti delle teste: start/stop, toggle, selezioni esclusive, step manuali?
- Strobo: pattern fisico fixture o luminosità con sequenza? Selezione, toggle o momentary?
- TAP, SYNC, restart Automatic, blackout, CLEAR: griglia o pulsanti esterni? Verificare mappabilità e feedback del modello reale.

## 4. Domande aperte — tempo e scene

### OQ-12 — Semantica esatta dei rapporti musicali
**Priorità:** BLOCKING P0.

- L'etichetta `×2` significa **due cicli nello stesso beat** o **ciclo che dura due beat**? (Convenzione da rendere univoca.)
- Quali valori: 1/8…16 o set più ridotto? Sono durate, velocità o divisioni?
- Applica al solo effetto attivo, a un gruppo o a tutto il clock/scene?
- Esisterà Free Run in Hz indipendente dal BPM?
- Cosa succede a un effetto mentre il moltiplicatore cambia: continua fase o riaggancia al beat?
- Strobo hardware con refresh DMX limitato: che cosa promettiamo?

### OQ-13 — TAP: diagnosi e algoritmo
**Priorità:** BLOCKING P0.

- Riprodurre sul POC il difetto «valori a random»: confronto taps browser, trasmissione Wi-Fi, ricezione sul Pi, stima e filtri.
- Scegliere timestamp client/tempo server/alternativa hardware, trust boundary e gestione di più controller.
- Lunghezza finestra, outlier, pause, BPM minimo/massimo, display di stima vs BPM attivo.
- UI senza scrolling: gesture, touch-action e click duplicati; controlli numerici interi.
- Obiettivi misurabili per jitter/errore su hardware reale.

Il POC descrive già mediana e intervalli server-side: non confondere il codice progettato con l'esperienza del live.

### OQ-14 — SYNC, NUDGE e gestione della fase
**Priorità:** BLOCKING P0.

- Il pulsante SYNC riallinea al beat attuale o al downbeat della battuta?
- Un effetto già in corso deve saltare fase, attendere il confine o interpolare una correzione?
- Come reagiscono chase in beat, effects in Hz, sequenze strobe e movimenti?
- Serve un comando «restart phase» per singolo effetto distinto da SYNC globale?
- Nudge in ms, beat fraction o altra unità?
- Test musicali con metronomo/audio reale e Wi-Fi con jitter.

### OQ-15 — Live UI e navigazione scene
**Priorità:** P1.

- Griglia compatta, bank, ricerca, preferiti e/o raggruppamenti?
- Dimensione card leggibile su telefono vs tablet.
- Descrizione breve, classi coinvolte, palette cromatica, etichetta strobo: quali dati derivabili automaticamente?
- Interfaccia davvero senza scroll per azioni comuni?
- Indicatore scena selezionata vs scena attiva vs modalità Performance.

### OQ-16 — Scena e Quick Store
**Priorità:** BLOCKING P0 per modello di dominio delle scene.

- La scena è uno snapshot di valori finali o una composizione di palette + distribuzione + luci + movimenti/chase/effetti?
- Quick Store salva look statico o riferimenti al comportamento dinamico?
- Differenza tra preset di Performance e scena automatizzata?
- Come vengono editate, duplicate, rinominate o riassegnate a bank?
- Che cosa accade a una scena quando cambia la palette di riferimento?
- Transazione e coerenza con show già in esecuzione; cancellazioni/riferimenti e versionamento.

## 5. Domande aperte — hardware, release e qualità

### OQ-17 — Launchpad X: modalità MIDI e feedback
**Priorità:** P1.

- Programmer Mode o altra modalità? Configurazione ad avvio e ripristino.
- Identificatori note/CC per matrice e pulsanti esterni.
- Colori LED/intensità/feedback di selezione, HOLD, TOGGLE e modo Automatic.
- Firmware/versione supportata, hotplug, stato aggiornato dopo reconnect.
- Test su Mac di sviluppo e Raspberry target; libreria MIDI e permessi.

### OQ-18 — iRig Pads: mapping esatto
**Priorità:** P1.

- Quante scene sui 16 pad? Eventuali bank.
- Quali comandi BPM, TAP, SYNC, velocità quantizzata.
- Slider, knob, encoder e pulsanti: quale mapping, curve, soglie/isteresi, feedback disponibile.
- Come scoprire/gestire configurazioni MIDI differenti sul dispositivo.

### OQ-19 — Recovery, blackout e stato iniziale
**Priorità:** BLOCKING P0.

- Stato startup: Automatic? scena precedente? safe/off? modalità ripristinata?
- Persistenza TOGGLE, scelta palette, distribuzione e note attive (HOLD non ripristinato a caso).
- Perdita USB DMX, controller, alimentazione: cosa significa «spento» con l'ultimo frame trattenuto dalla fixture?
- Blackout indipendente dal modo e comportamento al rilascio.
- Aggiornamento controllato, restore dati, rollback compatibile con versione schema.

### OQ-20 — SLO/test e pipeline CI/CD
**Priorità:** P1.

- Latenza target NoteOn → frame DMX, jitter, precisione TAP e stabilità prolungata.
- Tipi di fixture e quantità effettive.
- Test hardware in CI o banco periodico, mock/simulator, misurazioni su Raspberry.
- Branch protection, pull request workflow, tagging/versioning, artifact signing/checksum.
- Deployment systemd/single binary e rollback: scegliere dopo verifica dello stack, non creare un'altra architettura a priori.
- Nessun aggiornamento automatico durante lo spettacolo.

## 6. Ordine suggerito per le prossime sessioni

Non è una roadmap approvata; è un **ordine che riduce le decisioni bloccanti**.

1. Chiudere OQ-01/02/04/08: transizioni e semantica input hanno precedenza sull'estetica.
2. Definire OQ-06/07/10 e validare un prototipo della griglia con fari disposti realmente sul palco.
3. Progettare OQ-12/13/14: Tempo, TAP e fase con casi testabili e confronto col POC.
4. Chiudere OQ-15/16: esperienza scene, Quick Store e modello dati.
5. Progettare OQ-11/17/18: ultime quattro righe, mapping dei due controller, feedback.
6. Dopo: OQ-19/20, ADR, architettura implementativa, CI/CD, release e backlog.

Nessuna di queste fasi richiede di cambiare subito il codice.

## 7. Template per registrare una nuova decisione

```markdown
### D-0XX — Titolo [CONFIRMED]
- Data:
- Decisione:
- Fonte/contesto: feedback esplicito / test hardware / ADR
- Alternative valutate:
- Conseguenze:
- Requisiti interessati:
- Test di accettazione:
- Eventuali domande riaperte:
```

Se una decisione cambia, **non cancellarne la storia**: segnare SUPERSEDED, indicare la nuova ID e aggiornare tutte le specifiche correlate.

## 8. Protocollo di lavoro con agenti AI

Quando un agente riceve una feature:
1. Legge [PRODUCT-VISION.md](PRODUCT-VISION.md), [FUNCTIONAL-REQUIREMENTS.md](FUNCTIONAL-REQUIREMENTS.md), [PERFORMANCE-MODE.md](PERFORMANCE-MODE.md) e questo registro.
2. Identifica gli ID interessati e le OQ bloccanti.
3. Se la semantica è aperta, produce opzioni e conseguenze, **non un'implementazione silenziosamente arbitraria**.
4. Se la semantica è chiusa, propone contratti, test e modifiche minime coerenti.
5. Non usa `instage-ai` come repository in cui sviluppare il prodotto.
6. Non chiude domande aperte solo perché una demo «sembra funzionare».
7. Quando una decisione viene confermata, aggiorna decision log, requisiti e test nello stesso cambiamento.

## 9. Changelog

- **v0.1 — 2026-11-21:** prima raccolta delle decisioni della retrospettiva live e dell'analisi Launchpad/iRig; creazione registro OQ-01…OQ-20. Nessuna implementazione e nessuna architettura definitiva approvata.

# InStage — Functional Requirements

> **Stato:** BOZZA v0.1 — 21 novembre 2026.  
> **Destinatari:** prodotto, UX, architettura, QA e agenti AI.  
> **Scopo:** catalogo tracciabile di esigenze, decisioni e proposte; **non** è un ordine di implementazione.  
> **Repository del prodotto:** `MarcoMengoli/instage`.

## 0. Come interpretare i requisiti

Stati:
- **C — Confermato:** comportamento esplicitamente deciso dall'utente.
- **E — Esigenza:** obiettivo/problema espresso dall'utente, soluzione da progettare.
- **P — Proposta:** soluzione preferita o illustrativa, non ancora accettata.
- **O — Aperto:** scelta non definita che impedisce un contratto completo.
- **V — Validazione:** capacità candidata dal POC, da riesaminare.

**Non implementare automaticamente tutte le righe**: le righe P/O/V sono materiale di analisi, non requisiti normativi approvati. Gli ID sono stabili a partire da questa bozza, salvo rinomina esplicitata nel changelog. Le priorità P0/P1/P2 sono indicative finché non esiste una roadmap approvata.

Un requisito diventa pronto per sviluppo quando sono definiti: comportamento, stato di partenza, evento/comando, risultato osservabile, caso errore, test e dipendenze. Ogni decisione aperta rimanda al registro in [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md).

## 1. Glossario

| Termine | Significato di prodotto |
|---|---|
| Fixture | Faro/dispositivo fisico controllato via DMX/Art-Net, con capability e patch. |
| Destinatario performance | Unità logica controllabile da un pad, ad es. un PAR singolo. Per ora preferire destinatari disgiunti; non equivalgono automaticamente a ogni gruppo dello show. |
| Gruppo | Aggregazione riutilizzabile di fixture. Nel POC gruppi e scene hanno semantiche proprie, da non confondere con destinatari performance. |
| Palette | Definizione riutilizzabile di uno o più colori senza determinare accensione o movimento. Il modello preciso è proposto. |
| Distribuzione | Regola deterministica di assegnazione dei colori della palette alle fixture/destinatari. |
| Scene | Stato/look e potenzialmente automazioni; la semantica esatta della scena definitiva è ancora da decidere. |
| Chase | Sequenza di step temporizzati. |
| Effect | Generatore di variazioni (es. dimmer wave, colore, pan/tilt). |
| BPM | Frequenza del beat; non coincide con la fase. |
| Fase | Posizione nel ciclo/beat rispetto a un riferimento musicale. |
| Suddivisione | Rapporto del tempo di effetto al beat, idealmente espresso con valori musicali leggibili. |
| HOLD | Accensione momentanea legata al press/release di un pad. |
| TOGGLE | Accensione persistente con press successivo che inverte lo stato. |
| Automatic | Modalità in cui l'output deriva dallo show automatizzato. |
| Performance | Modalità in cui l'output deriva dal controllo manuale. |
| Pad | Controllo fisico Launchpad/iRig o equivalente logico. |
| Velocity | Valore associato all'attacco di una nota/pad. |
| Aftertouch | Informazione di pressione dopo l'attacco; per-pad e per-canale NON sono intercambiabili. |

## 2. Modalità e transizioni

| ID | Stato | Prio | Requisito / criterio osservabile |
|---|---|---|---|
| FR-MODE-001 | C | P0 | InStage prevede **Automatic** e **Performance** come modalità operative alternative. Un unico stato autorevole identifica quale modalità produce l'output. |
| FR-MODE-002 | C | P0 | Una prima azione manuale effettiva su Launchpad in Automatic provoca il passaggio a Performance e ne applica il comando (nessuna prima pressione «persa»). L'esatto insieme dei pad che causano la transizione è aperto (OQ-01). |
| FR-MODE-003 | C | P0 | In Performance i comandi manuali determinano il risultato: le scene automatiche non prevalgono su HOLD/TOGGLE. |
| FR-MODE-004 | C | P0 | Il ritorno ad Automatic è **esplicito**; non avviene per il semplice rilascio dell'ultimo pad. |
| FR-MODE-005 | C | P0 | Tornando ad Automatic, la scena/automazione selezionata e i relativi effetti **ripartono dall'inizio**; è vietato riprendere nel punto temporale precedente come se l'automazione fosse rimasta in playback. |
| FR-MODE-006 | P | P1 | Il BPM globale rimane impostato durante i cambi modalità; restart di effetti e correzione fase sono operazioni distinte. |
| FR-MODE-007 | O | P0 | Decidere se il passaggio ad Automatic avvenga immediatamente, al beat successivo o alla battuta, e quale fade usare (OQ-03). |
| FR-MODE-008 | O | P0 | Definire lo stato delle attivazioni TOGGLE/HOLD quando si torna ad Automatic e quando si rientra in Performance (OQ-04). |
| FR-MODE-009 | P | P0 | Blackout di emergenza e master hanno priorità indipendente dalla modalità, anche durante le transizioni. Verificare il dominio DMX delle fixture senza dimmer. |
| FR-MODE-010 | P | P0 | Se arriva un comando concorrente da più client durante una transizione, applicare una policy deterministica e notificare l'esito. Nessuna «doppia autorità» browser/Launchpad/server. |

## 3. Performance: palette, distribuzioni, attivazione

| ID | Stato | Prio | Requisito / criterio osservabile |
|---|---|---|---|
| FR-PERF-001 | C | P0 | Launchpad X è la superficie primaria per improvvisazione manuale. |
| FR-PERF-002 | C | P0 | Devono esistere **due righe distinte** di controlli luce: HOLD momentaneo e TOGGLE persistente. |
| FR-PERF-003 | C | P0 | Più HOLD di destinatari diversi possono essere premuti contemporaneamente; il rilascio di uno non spegne gli altri. |
| FR-PERF-004 | C | P0 | TOGGLE: prima pressione attiva il destinatario, seconda lo disattiva; non necessita mantenere la pressione. |
| FR-PERF-005 | C | P0 | Se un destinatario è acceso via TOGGLE e arriva il suo HOLD, HOLD **annulla/disinnesca** il TOGGLE e prevale; al RELEASE di quel HOLD il destinatario si spegne, non torna al vecchio TOGGLE. |
| FR-PERF-006 | C | P0 | Le due righe corrispondono agli stessi destinatari nella stessa colonna, riducendo il carico di memoria. |
| FR-PERF-007 | C | P0 | Nella griglia performance si evitano pulsanti che attivano insiemi di destinatari **sovrapposti**, per non creare conflitti fra HOLD e TOGGLE. |
| FR-PERF-008 | E | P0 | L'operatore può tenere alcune luci accese con TOGGLE mentre «suona» altre luci con HOLD. |
| FR-PERF-009 | P | P1 | Una riga di otto pad seleziona palette persistenti (colore, non accensione). Modificare palette non cancella di per sé gli HOLD attivi. |
| FR-PERF-010 | P | P1 | Una seconda riga seleziona distribuzioni persistenti, indipendenti dalla palette. Le regole determinano il colore per fixture, senza dipendere dall'ordine dei pad premuti. |
| FR-PERF-011 | P | P1 | La distribuzione può essere uniforme, alternata, sinistra/destra, simmetrica o personalizzata. Il set esatto e la semantica di ogni pattern sono APERTI (OQ-06). |
| FR-PERF-012 | P | P1 | Palette/distribuzione si applicano anche a destinatari momentaneamente spenti, così che una loro successiva attivazione abbia un colore prevedibile. |
| FR-PERF-013 | P | P1 | Cambi palette/distribuzione mentre fari sono accesi aggiornano le luci senza richiedere release/re-press. Fade cromatico da definire. |
| FR-PERF-014 | O | P0 | Decidere se la prima selezione di palette/distribuzione, mentre è Automatic, attiva subito Performance e con quale output (OQ-01). |
| FR-PERF-015 | O | P0 | Decidere se e come regolare la luminosità in funzione della velocity iniziale, dell'aftertouch continuo o di entrambe (OQ-07). |
| FR-PERF-016 | O | P1 | Definire il comportamento di TOGGLE premuto mentre HOLD sullo stesso destinatario è già attivo; gestione multi-controller sullo stesso destinatario (OQ-08). |
| FR-PERF-017 | P | P0 | Se un controller sparisce senza NoteOff/Release, le attivazioni momentanee non rimangono bloccate a tempo indefinito; policy e limite temporale da decidere (OQ-09). |
| FR-PERF-018 | P | P1 | Le palette sono editabili e riutilizzabili; l'editor distingue base cromatica e regola di distribuzione, senza mescolarle all'accensione. |
| FR-PERF-019 | O | P1 | Decidere cosa succede se i destinatari/fari cambiano fra show, bank e fixture con capability cromatiche differenti (OQ-10). |
| FR-PERF-020 | O | P1 | Definire il supporto di strobo, movimenti e ulteriori righe; la disposizione 5–8 non è ancora confermata (OQ-11). |

Per la semantica completa HOLD/TOGGLE, inclusi esempi, priorità e test, vedere [PERFORMANCE-MODE.md](PERFORMANCE-MODE.md).

## 4. Tempo, TAP, fase e velocità

| ID | Stato | Prio | Requisito / criterio osservabile |
|---|---|---|---|
| FR-TIME-001 | E | P0 | Il Tap BPM deve produrre stime **stabili e comprensibili**, senza apparire casuale. Misurare il comportamento reale prima di scegliere algoritmo e soglie. |
| FR-TIME-002 | E | P0 | Il tapping sulla Web UI non deve produrre scrolling, zoom o selezioni accidentali della pagina. |
| FR-TIME-003 | E | P0 | Inserimento manuale BPM rapido e con numeri interi; evitare decimali non necessari. Limiti min/max e step da decidere/validare. |
| FR-TIME-004 | E | P0 | BPM corretti non bastano: deve esserci modo di **riallineare la fase** al riferimento musicale senza necessariamente cambiare BPM. |
| FR-TIME-005 | P | P0 | Distinguere UX/comandi di TAP (stima BPM), SYNC (aggancio fase) e NUDGE (piccola correzione) e rendere visibile la differenza. |
| FR-TIME-006 | E | P0 | La variazione di velocità degli effetti musicali deve risultare intuitiva e musicalmente significativa. |
| FR-TIME-007 | P | P0 | Usare rapporti quantizzati a potenze di 2 (es. ×¼, ×½, ×1, ×2, ×4, ×8, eventualmente ×16) per i controlli Live sincronizzati; mantenere separata un'eventuale modalità Free Run. Convenzione durata/vs/velocità da fissare (OQ-12). |
| FR-TIME-008 | P | P0 | Il clock che governa output, chase ed effetti rimane **server-side**, indipendente dall'aggiornamento della UI e dalla connessione del telefono. |
| FR-TIME-009 | P | P0 | L'algoritmo TAP dovrebbe ridurre l'effetto del jitter Wi-Fi; valutare intervalli con timestamp client attendibili e verificati, oppure alternative hardware/server (OQ-13). |
| FR-TIME-010 | P | P1 | Un singolo TAP non deve sostituire con un valore casuale il BPM in uso; stima, valore effettivo e stato pending sono distinti. |
| FR-TIME-011 | O | P0 | Definire l'effetto di SYNC/Nudge sulle fasi di chase, effetti in beat, effetti in Hz e strobo, evitando salti pericolosi (OQ-14). |
| FR-TIME-012 | P | P1 | Slider analogici MIDI mappati a rapporti musicali discreti con soglie/isteresi, non valori arbitrari come 1.389×; mapping specifico da validare. |
| FR-TIME-013 | P | P0 | Clamp/limiti musicali e di output: il sistema non promette impulsi distinti più rapidi della frequenza effettiva del rendering/DMX; evidenzia limitazioni. |
| FR-TIME-014 | O | P1 | Definire tempi di smoothing, stima/feedback visivo e gestione di due sorgenti TAP contemporanee (OQ-13). |

### Note tecniche del POC, NON requisiti già approvati

Il POC documenta un clock server a 40 Hz, BPM interi 10–180, TAP con mediana di intervalli ricevuti dal server, `tempo.nudge` in millisecondi, chase con `speed` continuo 0.05–16, effetti temporizzati in Hz o beat. Il comportamento reale del live può differire da questa documentazione. Va riprodotto prima di modificare codice.

## 5. Scene e Web UI

| ID | Stato | Prio | Requisito / criterio osservabile |
|---|---|---|---|
| FR-SCENE-001 | E | P0 | La selezione delle scene Live deve essere **compatta**: evitare una lunga lista che imponga scroll ripetuti. |
| FR-SCENE-002 | E | P0 | Ogni scena deve poter mostrare almeno nome, **breve descrizione**, fixture/gruppi coinvolti (PAR, teste, strobo ecc.), **colori** e presenza di **strobo**. |
| FR-SCENE-003 | E | P1 | Creare scene e aggiungere elementi deve essere sensibilmente meno laborioso del POC; distinguere percorso rapido da editing dettagliato. |
| FR-SCENE-004 | P | P1 | Presentare scene in griglie compatte, eventualmente con bank/pagine, ricerca o filtri. Numero scene per pagina e segnaletica definitivi APERTI (OQ-15). |
| FR-SCENE-005 | P | P1 | Quick Store: preparare un look, catturarlo e salvarlo con pochi comandi, poi personalizzare il preset in un editor avanzato. |
| FR-SCENE-006 | O | P0 | Definire se una scena è un look statico, un set di riferimenti a palette/movimenti/chase/effetti, oppure entrambe le cose; snapshot vs definizione compositiva (OQ-16). |
| FR-SCENE-007 | P | P1 | Metadati scena calcolati automaticamente quando affidabili, con possibilità di override/descrizione manuale; non inventare descrizioni inesatte. |
| FR-SCENE-008 | P | P1 | Editor/preview non modificano l'output live finché l'utente non attiva esplicitamente una modifica o un test; salvare senza sorprese. |
| FR-SCENE-009 | P | P0 | Stato «scena selezionata» e «scena effettivamente in onda» distinguibili anche quando Performance è attiva. |
| FR-SCENE-010 | O | P1 | Definire comportamento di modifica/cancellazione di una scena selezionata o referenziata, con validazione e migrazioni (OQ-16). |

## 6. Controller e integrazione MIDI

| ID | Stato | Prio | Requisito / criterio osservabile |
|---|---|---|---|
| FR-MIDI-001 | C | P0 | Integrazione prevista per **Novation Launchpad X** e **IK Multimedia iRig Pads**. |
| FR-MIDI-002 | C | P0 | Launchpad X privilegia la performance manuale, iRig Pads richiami scene, BPM e regolazione velocità. |
| FR-MIDI-003 | P | P0 | Adapter MIDI separati dai comandi di dominio: input fisico normalizzato prima di applicare regole di modalità e luci. |
| FR-MIDI-004 | P | P0 | Supportare eventi distinti di press, release, eventuale velocity e aftertouch, con device ID, input ID e stato di connessione. |
| FR-MIDI-005 | P | P0 | Il feedback LED sui pad del Launchpad rappresenta lo **stato confermato dal server**, non l'ultima intenzione locale. |
| FR-MIDI-006 | O | P1 | Layout esatto della matrice 8×8, pulsanti esterni, pagine/bank e pattern dei LED da definire (OQ-11, OQ-17). |
| FR-MIDI-007 | O | P1 | Layout iRig dei 16 pad e mapping di slider/knob/encoder, curve e soglie da definire (OQ-18). |
| FR-MIDI-008 | P | P0 | Collegamento e scollegamento a caldo di un controller hanno esito esplicito, senza note bloccate o comando duplicato. |
| FR-MIDI-009 | P | P1 | Mapping per dispositivo configurabile e portabile per show, con preset factory e restore; policy di proprietà dei layout ancora aperta. |
| FR-MIDI-010 | P | P0 | Un controller non può impostare un modo di invio non supportato o far credere all'operatore che un comando sia stato eseguito se il server non l'ha accettato. |

## 7. Fixture, show e rendering

| ID | Stato | Prio | Requisito / criterio osservabile |
|---|---|---|---|
| FR-CORE-001 | V | P0 | Valutare il recupero dal POC di patch, import profili fixture, canali/capability, master, blackout, scene, chase, effetti e cue. |
| FR-CORE-002 | P | P0 | Il rendering live è centralizzato; i dispositivi di input non scrivono direttamente un frame DMX parallelo. |
| FR-CORE-003 | P | P0 | Rendering e comunicazione DMX non attendono I/O su storage, browser o MIDI; code limitate e policy per setpoint/trigger. |
| FR-CORE-004 | P | P0 | Una singola pressione/release applica una modifica atomica del dominio; niente mezzo frame che spegne un faro erroneamente. |
| FR-CORE-005 | P | P0 | La disposizione spaziale dei fari, necessaria alle distribuzioni, è configurata esplicitamente e non dedotta dall'indirizzo DMX. |
| FR-CORE-006 | P | P1 | Il dominio di palette/distribuzioni considera fixture non RGB, ruote colore, WHITE/AMBER/UV, dimmer virtuali, strobo e canali discreti con fallback dichiarato. |
| FR-CORE-007 | P | P0 | Dati di show, mapping e preferenze sopravvivono a riavvio secondo una policy dichiarata; lo stato dei pad momentanei non viene ripristinato come «premuto» dopo un restart. |
| FR-CORE-008 | V | P1 | Rivedere limiti reali del POC (universi, fixture, client) alla luce dell'hardware usato e di scenari di estensione futuri. |

## 8. Affidabilità, diagnosi, release (requisiti candidati)

Queste voci sono **P/V**, non una decisione architetturale chiusa. Servono a guidare analisi e test senza cristallizzare lo stack.

| ID | Stato | Prio | Requisito / criterio osservabile |
|---|---|---|---|
| FR-OPS-001 | P | P0 | Il live continua senza dipendenza da cloud, Internet o browser attivo; il server deve restare autonomo. |
| FR-OPS-002 | P | P0 | Il sistema espone in modo distinguibile stato applicativo, connessioni client/MIDI, stato output DMX e persistenza. |
| FR-OPS-003 | P | P0 | Il rilascio di input momentanei durante perdita dispositivo/client è sicuro e testabile, senza stuck-note. |
| FR-OPS-004 | P | P0 | Il blackout operativo deve rimanere accessibile anche in Performance; limiti fisici (DMX persi, alimentazione) vanno documentati. |
| FR-OPS-005 | P | P0 | Test automatici del clock con fake time, sequenze di input e merge; test reali per MIDI, rendering DMX e comportamento live. |
| FR-OPS-006 | P | P0 | CI valida formatting/lint/typecheck, test Go e frontend, contratti e build target; la definizione finale è rimandata al piano CI/CD. |
| FR-OPS-007 | P | P0 | Release installabile sul Raspberry con identificazione versione, hash, preflight, backup e rollback verificabile; non aggiornare automaticamente durante il live. |
| FR-OPS-008 | P | P1 | Telemetria locale e report diagnostico utili senza esporre dati/config sensibili o richiedere una piattaforma cloud. |
| FR-OPS-009 | O | P0 | Definire safe startup, recovery di modalità e TOGGLE dopo reboot/kill, output su perdita DMX e limiti dell'hardware (OQ-19). |
| FR-OPS-010 | O | P1 | Definire target quantitativi di latenza input→DMX, drift, jitter, resilienza e tempi di recupero; misurarli su Pi e dispositivi reali (OQ-20). |

## 9. Scenari di accettazione ad alta priorità

Questi scenari sono la base dei test; quelli che dipendono da scelte aperte devono attendere la decisione corrispondente.

### AT-PERF-001 — Due HOLD simultanei [C]
**Dato** Performance senza TOGGLE, **quando** tengo premuti HOLD su PAR SX e PAR DX, **allora** entrambi sono accesi. **Quando** rilascio HOLD PAR SX, **allora** solo PAR SX si spegne. **Quando** rilascio PAR DX, anche quello si spegne.

### AT-PERF-002 — TOGGLE e HOLD su fixture differenti [C]
**Dato** TOGGLE PAR SX attivo, **quando** premo HOLD PAR DX, **allora** sono accesi entrambi. **Quando** rilascio HOLD PAR DX, **allora** PAR SX rimane acceso e PAR DX si spegne.

### AT-PERF-003 — HOLD disinnesca TOGGLE sullo stesso destinatario [C]
**Dato** TOGGLE PAR SX attivo, **quando** premo HOLD PAR SX, **allora** la sua attivazione TOGGLE viene azzerata; **quando** rilascio HOLD PAR SX, **allora** PAR SX è spento e il TOGGLE non ritorna attivo.

### AT-PERF-004 — Pressione iniziale cambia modalità [C, con dettaglio O]
**Dato** Automatic in esecuzione, **quando** aziono un pad HOLD manuale, **allora** InStage passa a Performance e applica anche il primo HOLD. **Da completare:** che cosa avviene per un primo pad di palette/distribuzione.

### AT-MODE-001 — Rientro in Automatic [C]
**Dato** una scena automatica attiva e poi Performance, **quando** comando il ritorno ad Automatic, **allora** gli effetti e chase automatici selezionati ricominciano dall'origine prevista dalla loro definizione, non dalla posizione temporale preesistente. Il comportamento al beat, i fade e il punto iniziale esatto per generatori casuali sono da definire.

### AT-UX-001 — TAP senza scroll [E]
**Dato** una pagina Live su smartphone, **quando** l'operatore esegue una sequenza di TAP, **allora** nessun tocco fa spostare la pagina o altera controlli non correlati.

### AT-UX-002 — Scena riconoscibile [E]
**Dato** una lista Live di scene, **quando** l'operatore cerca una scena, **allora** può distinguere nome, breve descrizione, tipi di luci, colori e flag strobo senza aprire l'editor della scena. La densità informativa verrà testata su mobile.

### AT-TIME-001 — Tempo uguale, fase diversa [E]
**Dato** un effetto a 120 BPM ma in ritardo rispetto a un riferimento, **quando** applico un comando di riallineamento approvato, **allora** posso correggere la fase senza cambiare BPM, secondo policy dichiarata.

### AT-MIDI-001 — Perdita controller con HOLD [P]
**Dato** HOLD su un faro, **quando** il controller si disconnette senza NoteOff, **allora** InStage applica la policy di sicurezza approvata senza lasciare indefinitely un HOLD fantasma. Tempo e output esatti ancora da definire.

### AT-OUTPUT-001 — Fari sovrapposti [C/P]
**Dato** un layout che assegna i destinatari alle colonne HOLD e TOGGLE, **allora** non sono presenti destinatari sovrapposti nel layout performance approvato. La policy editor/validazione è ancora da decidere.

## 10. Matrice di tracciabilità e priorità preliminare

| Gruppo | Problema dal live | Scenario | Punto aperto principale |
|---|---|---|---|
| Tempo | TAP impreciso, pagina che scorre | AT-UX-001 | OQ-13 |
| Musica | BPM ma fuori fase | AT-TIME-001 | OQ-14 |
| Velocità | Moltiplicatori non musicali | FR-TIME-007 | OQ-12 |
| Scene | Lista troppo lunga | AT-UX-002 | OQ-15 |
| Scene | Store/creazione macchinosi | FR-SCENE-005 | OQ-16 |
| Performance | Improvvisazione HOLD/TOGGLE | AT-PERF-001/002/003 | OQ-07/08 |
| Modalità | Concorrenza fra show e pad | AT-MODE-001 | OQ-01/03/04 |
| Hardware | Uso Launchpad e iRig | AT-MIDI-001 | OQ-17/18 |

## 11. Contratti da produrre dopo la validazione

La fase architetturale dovrà produrre, senza anticiparli arbitrariamente:
1. State machine modalità e reset degli owner runtime.
2. Protocollo input normalizzato (press/release/velocity/aftertouch, identity del controller, lost device).
3. Modello separato per palette, distribuzione, destinatari e scene.
4. Comandi tempo e semantica rigorosa di BPM, fase, SYNC, NUDGE, rapporti.
5. Contratto di feedback controller basato su stato applicato.
6. Recovery, snapshot, incompatibilità schema e aggiornamenti.
7. Piano test prestazioni end-to-end con hardware reale.

## 12. Istruzioni per gli agenti

- Preferire implementazioni che rispettano scenari approvati e restano reversibili sulle scelte P/O.
- Non inventare default funzionali per scenari non approvati.
- Non assumere che i gruppi legacy coincidano coi destinatari performance.
- Non aggiungere una modalità ibrida che mescola Automatic e Performance: le modalità sono alternative per decisione C.
- Non modificare `instage-ai`: è il POC di riferimento.
- Non generare issue/codice da un requisito E senza aver scelto la soluzione e i test.
- Per ogni PR futura indicare ID, scenari coperti, regressioni e decisioni aperte.

---

Vedi [Product Vision](PRODUCT-VISION.md) · [Performance Mode](PERFORMANCE-MODE.md) · [Open Questions](OPEN-QUESTIONS.md).

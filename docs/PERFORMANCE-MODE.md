# InStage — Performance Mode

> **Stato:** BOZZA funzionale v0.1 — 21 novembre 2026.  
> **Questo documento definisce ciò che sappiamo e isola ciò che NON è stato deciso.**  
> **Ambito:** controllo manuale via Launchpad X (e possibili altri input), relazione con Automatic, semantica HOLD/TOGGLE, palette e distribuzione.

## 0. Regole per chi implementa

- **CONFERMATO:** comportamento approvato esplicitamente dal product owner.
- **PROPOSTA:** modello raccomandato ma non ancora approvato.
- **APERTO:** non è lecito assumere un comportamento definitivo.

La semantica confermata è più importante dei nomi di classi, package o comandi illustrativi. I pseudocodici sono **modelli concettuali**, non una API obbligatoria. Questa specifica prevale sulle ipotesi dei mockup precedenti, ma non sostituisce una successiva ADR approvata.

Link: [Product Vision](PRODUCT-VISION.md) · [Requirements](FUNCTIONAL-REQUIREMENTS.md) · [Open Questions](OPEN-QUESTIONS.md).

## 1. Obiettivo e idea di interazione

L'operatore **suona le luci**: seleziona colori e distribuzioni e accende fisicamente alcuni fari con controlli momentanei, lasciandone altri accesi stabilmente. La performance deve rimanere utilizzabile al buio, con poche azioni, memoria muscolare e risposta prevedibile, anche con pressioni multiple.

Il Launchpad X è il controller principale di questa modalità. La Web UI è principalmente la regia delle scene automatiche; l'iRig Pads è principalmente per scene e controlli di tempo. Non è necessario che i tre dispositivi abbiano interfacce identiche.

## 2. Modalità: Automatic vs Performance

### 2.1 Stati concettuali [CONFERMATO]

- **Automatic:** si riproduce una scena/automazione selezionata.
- **Performance:** la produzione dell'output è affidata ai controlli manuali; lo show automatico non ha la precedenza.
- Il **primo gesto manuale effettivo** durante Automatic causa il passaggio a Performance.
- Tornare da Performance ad Automatic richiede un **comando esplicito**.
- Al ritorno in Automatic, la scena/automazione selezionata e gli effetti **ripartono dall'inizio**, non riprendono dal tempo precedente.

Non introdurre di nascosto una modalità «Automatic + manual override temporaneo» in cui un rilascio HOLD ripristina immediatamente la scena automatica. Il prodotto ha deliberatamente scelto modalità **alternative**.

### 2.2 State machine di primo livello [schema concettuale]

```text
                 manual-performance-action
        +--------------------------------------------+
        |                                            v
   +-----------+                              +-------------+
   | AUTOMATIC |                              | PERFORMANCE |
   | play show |                              | manual show |
   +-----------+                              +-------------+
        ^                                            |
        +--------------------------------------------+
                  explicit RETURN_TO_AUTOMATIC
                 (restart selected automation)
```

**Questione aperta cruciale (OQ-01):** «azione manuale» include un pad di palette/distribuzione o soltanto un pad che produce effettivamente luce/effetto? Nell'ultimo caso le selezioni di palette sono preparatorie e non cambiano modalità.

### 2.3 Transazione di ingresso [PROPOSTA tecnica]

Una pressione che provoca il cambio modalità deve essere **atomica** con il comando che l'ha causato: non perdere il primo NoteOn né mostrare scene automatiche contemporaneamente a una performance manuale già attiva. Il momento di rilascio degli owner automatici e la policy fade/cut restano APERTI.

### 2.4 Ritorno ad Automatic [CONFERMATO + dettagli APERTI]

- Conservare il riferimento alla **scena/automazione da avviare**.
- Al comando esplicito di ritorno, iniziare un **nuovo playback** degli effetti, dall'origine della sequenza.
- Non continuare a far avanzare segretamente l'automazione per poi riprendere da dove sarebbe arrivata: sarebbe incompatibile con il restart richiesto.
- Il BPM globale potrebbe rimanere impostato (PROPOSTA ragionevole); fase, start immediato o quantizzato, fade, seed random e recovery sono APERTI.
- Non assumere implicitamente se i TOGGLE manuali vengano dimenticati, sospesi o ripristinati a un nuovo ingresso in Performance (OQ-04).

## 3. Modello dei destinatari

### 3.1 Fari gestiti nella disposizione iniziale [esempio, NON inventario hardware definitivo]

Le denominazioni emerse:
- Testa mobile sinistra
- PAR sinistra
- PAR centro-sinistra
- PAR centro-destra
- PAR destra
- Testa mobile destra

Sono **etichette di esempio** da ancorare a fixture IDs e disposizione configurata nello show. L'hardware effettivamente connesso e la numerazione DMX vanno letti dal patch reale, non indovinati.

### 3.2 Colonne corrispondenti [CONFERMATO]

HOLD e TOGGLE devono usare la stessa posizione per lo stesso destinatario, in modo che la colonna abbia un significato stabile. La matrice 8×8 offre fino a otto colonne; sei nomi qui riportati sono esempi, non vincoli.

### 3.3 Nessuna sovrapposizione dei destinatari [CONFERMATO come direzione UX]

Nel layout Performance l'operatore ha preferito **evitare tasti che mappano insiemi sovrapposti**. Per la prima versione, il disegno favorito è un destinatario singolo per colonna; eventuali gruppi inseparabili e non sovrapposti sono un'estensione da definire.

**Invariante candidato**: in un singolo bank, un fixture ID appartiene al massimo a un destinatario di HOLD/TOGGLE. Una procedura di validazione del layout deve renderlo evidente. Non affermare che tutti i gruppi generali del prodotto siano proibiti: il vincolo riguarda questa superficie di controllo.

## 4. Due righe indipendenti, stessi destinatari

### 4.1 Riga HOLD [CONFERMATO]

- Evento di **pressione**: accende il destinatario.
- Stato premuto: il destinatario rimane acceso; l'intensità può in futuro dipendere da velocity o pressione continua.
- Evento di **rilascio**: spegne il destinatario, a meno che una regola futura approvata ne modifichi esplicitamente la proprietà.
- Più pad HOLD per destinatari differenti sono **contemporanei** e indipendenti.
- Un release riguarda soltanto il destinatario dell'input rilasciato.

### 4.2 Riga TOGGLE [CONFERMATO]

- Pressione quando non attivo: attiva il destinatario persistentemente.
- Pressione successiva quando attivo: disattiva il destinatario.
- Il rilascio fisico del pad TOGGLE **non** inverte di nuovo lo stato.
- Un TOGGLE rimane attivo anche dopo che l'operatore smette di premere; l'operatore può contemporaneamente «suonare» altri destinatari via HOLD.

### 4.3 Priorità HOLD > TOGGLE sullo STESSO destinatario [CONFERMATO]

**Regola fondamentale: HOLD disinnesca il TOGGLE, non lo sospende.**

Sequenza canonica:
1. TOGGLE PAR SX: il faro si accende persistentemente.
2. Pressione HOLD PAR SX: il faro rimane acceso sotto controllo HOLD e **lo stato TOGGLE viene cancellato**.
3. Rilascio HOLD PAR SX: il faro si spegne. Non riappare il TOGGLE iniziale.
4. Una nuova pressione TOGGLE può riaccenderlo persistentemente.

Questa regola sostituisce la precedente proposta di fare un OR/addizione tra HOLD e TOGGLE dello stesso faro. Non usare la logica `holdActive || toggleActive` senza prima applicare l'evento che disinnesca TOGGLE.

### 4.4 Matrice di comportamento [CONFERMATO salvo righe marcate aperte]

| Precondizione | Evento | Nuovo stato destinatario | TOGGLE memorizzato |
|---|---|---|---|
| Spento | TOGGLE press | Acceso, persistente | ON |
| TOGGLE ON | TOGGLE press successivo | Spento | OFF |
| Spento | HOLD press | Acceso, momentaneo | OFF |
| HOLD attivo | HOLD release | Spento | OFF |
| TOGGLE ON | HOLD press (stesso destinatario) | Acceso, momentaneo | **OFF immediato** |
| HOLD dopo TOGGLE | HOLD release | **Spento** | OFF |
| TOGGLE A ON | HOLD B press | A e B accesi | A resta ON |
| HOLD A + HOLD B | HOLD A release | Solo B acceso | Non coinvolto |
| HOLD A attivo | TOGGLE A press | **APERTO**: semantica di priorità in questa direzione | **Da decidere** |
| Due controller, stesso destinatario | Un release | **APERTO**: ownership multipla | **Da decidere** |

### 4.5 Eventi idempotenti e anti-rimbalzo [PROPOSTA tecnica]

Una nota MIDI «press» è un evento diverso dalla conferma di stato. Un sistema che riceve NoteOn duplicati o ricomposti non deve fare due toggle non voluti. Si propone di:
- tracciare device ID + controllo + origine evento;
- evitare doppi TOGGLE su autorepeat/duplicati;
- distinguere `NoteOn(velocity=0)` interpretato da molti dispositivi come NoteOff, dopo verifica del protocollo specifico;
- applicare l'evento press/release nell'ordine accettato dal server;
- decidere una policy multi-client e di disconnessione prima di chiudere il contratto.

## 5. Layout 8×8: proposta di lavoro, NON assegnazione definitiva

L'utente ha proposto e progressivamente affinato questa disposizione:

| Riga | Scopo | Stato |
|---|---|---|
| 1 | **Palette**: fino a 8 combinazioni di colori | PROPOSTA condivisa, set di palette aperto |
| 2 | **Distribuzioni**: fino a 8 modalità di assegnare colori | PROPOSTA condivisa, set/pattern aperti |
| 3 | **HOLD**: accensione momentanea fino a 8 destinatari | Tipo di interazione CONFERMATO |
| 4 | **TOGGLE**: accensione persistente degli stessi destinatari | Tipo di interazione CONFERMATO |
| 5 | Strobo/pattern luminosi | IPOTESI, non stabilita |
| 6 | Movimenti delle teste mobili | IPOTESI, non stabilita |
| 7 | Scene/preset o comandi performance | APERTO |
| 8 | Tempo e velocità/rapporti musicali | IPOTESI, non stabilita |

L'utente ha esplicitamente chiesto di poter **ripensare le righe**. Non trasformare la tabella in un layout hard-coded. I pulsanti esterni del Launchpad e i bank saranno valutati separatamente; non promettere una certa disponibilità MIDI fino alla verifica del modello/modalità.

### 5.1 Etichette di esempio per colonne HOLD/TOGGLE

```text
           1      2       3       4       5       6       7      8
HOLD     [T.SX] [P.SX] [P.CSX] [P.CDX] [P.DX] [T.DX] [lib.] [lib.]
TOGGLE   [T.SX] [P.SX] [P.CSX] [P.CDX] [P.DX] [T.DX] [lib.] [lib.]
```

I due slot liberi possono servire a future fixture o funzioni **solo se** non complicano la corrispondenza e non creano sovrapposizioni.

## 6. Palette e distribuzioni

### 6.1 Responsabilità separate [PROPOSTA]

- Palette: **quali colori** usare, senza accendere di per sé un faro.
- Distribuzione: **come assegnare** i colori della palette alla disposizione/fixture.
- HOLD/TOGGLE: **quali destinatari sono attivi**.
- Pattern di movimento/strobo: comportamenti distinti da palette e accensione.

Concettualmente il modello compone:
```text
selected palette + selected distribution -> color assigned to each fixture
HOLD/TOGGLE state -> which fixture output is active
strobe/movement (if configured) -> further transformations
```

Le priorità nel renderer, fade e accesso a capability particolari richiedono una specifica successiva.

### 6.2 Distribuzioni candidate [PROPOSTA]

- Uniforme: un solo colore per tutti.
- Alternata: colori ripetuti secondo l'ordine spaziale.
- Sinistra/Destra: colore/insieme colori della zona sinistra e della zona destra.
- Simmetrica: corrispondenza speculare sul palco.
- Personalizzata: colore scelto per ciascuna fixture.

Altre idee (centro/esterno, random, blocchi) sono state mostrate nei prototipi ma **non sono approvate**. Per palette da 1, 2, 3 o più colori definire con esempi l'algoritmo, i casi dispari, fixture non RGB e spostamento della fixture. Non dedurre l'ordine dalla patch DMX.

### 6.3 Stabilità e predictability [PROPOSTA]

La distribuzione deve essere funzione deterministica della definizione della palette e della disposizione delle fixture. Premere P.SX prima di P.DX o viceversa non deve riassegnare arbitrariamente i colori. L'anteprima UI dovrebbe mostrare il risultato per ogni fixture.

### 6.4 Comportamento dei pad [da chiudere]

Palette e distribuzioni sono pensate come selezioni **persistenti ed esclusive** (una attiva per categoria). Ma la scelta se il loro tocco in Automatic faccia entrare immediatamente in Performance o serva soltanto a preparare la prossima performance è ancora **APERTA**, non deducibile da un mockup.

## 7. Sensibilità del controller: non scegliere ancora

### 7.1 Velocity vs pressione continua [APERTO]

L'utente vuole poter dosare l'intensità, ma **non ha ancora scelto** fra:
- **Velocity**: intensità definita dall'attacco iniziale e mantenuta fino al release.
- **Aftertouch**: modulazione successiva della luminosità durante la pressione.
- **Entrambi** configurabili a livello di layout/destinatario.

La pipeline degli eventi va progettata in modo estensibile per tutti e tre, ma nessun mapping definitvo prima di prova ergonomica e MIDI reale.

### 7.2 Capacità fisiche da verificare

Il Launchpad X offre informazioni di velocity e pressione per pad secondo modalità/firmware; verificare in modo empirico valore, granularità, aftertouch, NoteOn/Off, LED outbound e le modalità MIDI. iRig Pads ha capacità diverse e non deve fingere aftertouch per singolo pad se il dato non esiste.

### 7.3 Due HOLD con intensità diverse [APERTO]

Nella versione senza sovrapposizioni ogni pad controlla un destinatario distinto. Se in futuro lo stesso destinatario viene comandato da due fonti, non assumere `MAX`, `LAST_WRITE_WINS` o somma dei livelli senza decisione esplicita.

## 8. Feedback sul Launchpad [PROPOSTA]

- Pad palette/distribuzione: selezione corrente riconoscibile.
- HOLD: pad illuminato mentre il server considera l'input attivo.
- TOGGLE: LED acceso finché attivazione persistente è effettivamente ON.
- HOLD che disinnesca TOGGLE: il LED del TOGGLE si spegne immediatamente quando l'evento viene applicato, pur restando il faro acceso tramite HOLD.
- Stato di connessione, reconnessione e comando non accettato: feedback da progettare, non mostrare falso successo.
- In Automatic il feedback deve distinguere la modalità dal layout manuale e impedire equivoci su quali pad entrano in Performance.

Codifica esatta dei colori LED (es. palette cromatiche, intensità, blink) e disponibilità dei pulsanti extra: **APERTO**. La funzione non deve dipendere da letture dei soli LED: lo stato è server-side.

## 9. Relazione con strobo e movimenti [APERTO]

In discussione:
- strobo lento/veloce, doppio colpo, sequenze, ON/OFF;
- movimenti delle teste mobili (cerchi, sweep, figure, fermi);
- eventuali righe dedicate;
- rapporto con BPM globale, fase, divisioni, velocity e ritorno ad Automatic.

Il product owner ha suggerito che strobo potrebbe essere **ON/OFF**, mentre l'accensione dei fari dovrebbe avere HOLD e TOGGLE separati. Non inferire che ogni pulsante strobo sia necessariamente toggle o che tutti i fari supportino identico canale strobo. Valutare strobo fisico fixture vs sequenze dimmer (risoluzione e comportamento DMX diversi).

## 10. Input normalizzati — modello candidato per ADR

Un'architettura ragionevole potrebbe separare:

```text
Physical MIDI / Touch
    -> adapter device-specific
    -> normalized event {deviceId, controlId, eventType, value, eventId?, sourceTime?}
    -> performance command/state-machine
    -> render engine
    -> DMX/Art-Net output
    -> confirmed state & MIDI LED feedback
```

Esempi di **tipi**, non di endpoint approvati:
- `PadPressed(controller, pad, velocity)`
- `PadPressureChanged(controller, pad, pressure)`
- `PadReleased(controller, pad)`
- `PaletteSelected(paletteId)`
- `DistributionSelected(distributionId)`
- `ReturnToAutomatic()`
- `ControllerDisconnected(controller)`

Ciò evita di inserire logica di dominio nel driver MIDI o nel frontend. La scelta concreta degli owner, canali, lock, versione del protocollo e persistenza verrà definita da ADR.

## 11. Disconnessioni, shutdown e casi limite

Questi casi **devono essere analizzati** prima della release, ma le policy concrete non sono ancora tutte confermate:

1. Launchpad scollegato durante HOLD: impedire una luce momentanea bloccata indefinitamente; rilascio sintetico o TTL da stabilire.
2. Launchpad scollegato mentre TOGGLE è attivo: decidere se il latch persiste o si azzera; evitare eventi di riattacco interpretati come pressioni nuove.
3. Cambio Automatic/Performance mentre un HOLD è fisicamente tenuto: decidere se rilascio successivo deve ancora avere effetto e come re-arm.
4. Riavvio server: un HOLD fisico non può essere supposto premuto senza nuova prova; TOGGLE e modalità restaurate secondo policy dichiarata.
5. Un pad premuto molto rapidamente più volte: non saltare NoteOff o attivare/doppiare TOGGLE.
6. Due pressioni simultanee in ordine invertito: stessa composizione per fixture distinte.
7. Stato UI aggiornato in ritardo o comando respinto: correggere feedback da stato server.
8. Cambio di show o mapping mentre pad è premuto: policy di flush/release necessaria.
9. Doppia connessione dello stesso controller o due controller sullo stesso destinatario: owner e collisioni da definire.
10. Blackout durante HOLD: policy di ripresa dei livelli quando blackout viene rilasciato, senza bypass di sicurezza.
11. 0–100% intensity: linearità percepita, gamma e qualità del dimmer da calibrare per fixture.
12. Fixture senza dimmer fisico o con macro reset pericolose: non inviare raw values arbitrari.
13. Lampada spenta ma movimento attivo: distinguere beam/intensity da pan/tilt; possibilità operativa da validare.

## 12. Test e criteri di accettazione

### 12.1 Test di dominio minimi [CONFERMATO come logica]

| Test | Sequenza | Atteso |
|---|---|---|
| PT-01 | HOLD A press → HOLD B press → HOLD A release | B acceso, A spento |
| PT-02 | TOGGLE A press → HOLD B press → HOLD B release | A acceso, B spento |
| PT-03 | TOGGLE A press → HOLD A press → HOLD A release | A spento, TOGGLE A OFF |
| PT-04 | TOGGLE A press → TOGGLE A press | A spento |
| PT-05 | Automatic → primo HOLD A press | Performance attiva e A acceso nella stessa transizione |
| PT-06 | Automatic in corso → Performance → RETURN_TO_AUTOMATIC | Playback automatico riparte dall'origine, non dal precedente tempo |
| PT-07 | HOLD A, HOLD B in ordine opposto | Identico risultato su A e B |
| PT-08 | Palette diversa con fixture assegnate | Risultato deterministico secondo la distribuzione approvata (test P) |

### 12.2 Test da progettare dopo decisioni

- HOLD A attivo → TOGGLE A press (OQ-08).
- Due controller sullo stesso destinatario (OQ-08).
- Primo tocco a una palette in Automatic (OQ-01).
- Ritorno con TOGGLE ancora ON (OQ-04).
- Perdita controller durante HOLD e reconnect (OQ-09).
- Ripristino da kill/restart con show e modalità precedenti (OQ-19).
- Cambi BPM e SYNC mentre Performance ha pattern ritmici (OQ-12, OQ-14).
- Intensità con velocity/aftertouch reale su Launchpad X (OQ-07).

### 12.3 Test fisici suggeriti

Con Launchpad X e iRig Pads collegati al setup reale, misurare: ordine eventi MIDI, NoteOff, curva velocity, continuità aftertouch, latenza dal gesto all'output, LED after ACK, simultaneità di due o più pad, disconnessione e ripristino. Usare un mock per test deterministici, ma non dichiarare hardware qualificato con il solo mock.

## 13. Comportamenti esplicitamente NON voluti

- **No** ripristino automatico della scena sottostante quando l'ultimo HOLD viene rilasciato.
- **No** ripresa degli effetti automatici al tempo in cui erano stati abbandonati quando si ritorna ad Automatic.
- **No** TOGGLE occultamente ancora ON dopo HOLD sullo stesso destinatario e successivo release.
- **No** pulsanti performance che controllano aggregati sovrapposti senza una regola/validazione esplicita.
- **No** LED del Launchpad che rappresentano esclusivamente uno stato locale disallineato.
- **No** mapping di velocity/aftertouch scelto come definitivo senza test col musicista/operatore.
- **No** hardcode dei sei nomi dei fari di esempio come inventario fisso del prodotto.

## 14. Prossime decisioni

Prima di chiudere Performance Mode v1 serve risolvere, nell'ordine: OQ-01 (cosa attiva Performance), OQ-04 (stato manuale fra modalità), OQ-08 (TOGGLE premuto durante HOLD), OQ-07 (intensità), OQ-06 (set e semantica distribuzioni), OQ-11 (righe 5–8), OQ-09 (disconnect), OQ-03 (restart/fade/beat), OQ-17 (MIDI feedback e pulsanti fisici).

Gli agenti che lavorano in parallelo devono mantenere questo registro come fonte unica e non «completare» automaticamente le parti APERTE.

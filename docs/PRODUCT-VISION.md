# InStage — Product Vision

> **Stato:** BOZZA DI LAVORO — v0.1, 21 novembre 2026.  
> **Repository canonico:** `MarcoMengoli/instage`.  
> **POC di riferimento:** `MarcoMengoli/instage-ai` (non è il prodotto definitivo).  
> **Destinatari:** product owner, progettisti UX, sviluppatori e agenti AI.  
> **Regola essenziale:** non trasformare una proposta in requisito approvato.

## 1. Scopo e lettura della documentazione

Questo documento spiega **perché** realizzare InStage e come valutare le scelte. Le regole operative, gli ID dei requisiti e gli scenari verificabili sono in [FUNCTIONAL-REQUIREMENTS.md](FUNCTIONAL-REQUIREMENTS.md); il comportamento dei controller e delle modalità è in [PERFORMANCE-MODE.md](PERFORMANCE-MODE.md); i punti non decisi sono in [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md).

### Livelli di certezza

- **CONFERMATO**: decisione espressa esplicitamente dall'utente nelle sessioni di analisi.
- **ESIGENZA**: problema o obiettivo esplicito, la cui soluzione è ancora da scegliere.
- **PROPOSTA**: soluzione suggerita, non ancora approvata come comportamento definitivo.
- **APERTO**: ambiguità o decisione ancora da prendere.
- **EREDITATO/DA VALIDARE**: comportamento presente o descritto nel POC, che non diventa automaticamente requisito del nuovo prodotto.

Gli agenti **devono** rispettare la differenza fra questi stati. Non assumere che un mockup o un esempio numerico definisca una specifica definitiva. Il linguaggio MUST/SHOULD/MAY, dove usato nelle specifiche tecniche future, si applicherà solo a requisiti approvati.

## 2. Contesto e motivazione

InStage è un sistema autonomo di controllo di illuminazione per piccoli eventi e spettacoli live, incluso il contesto di una band in spazi ristretti. Deve consentire a un operatore di gestire scene ed effetti automatizzati e, quando desiderato, di eseguire una **performance luminosa manuale** con un controller fisico.

Il POC `instage-ai` è già stato **utilizzato con successo durante un concerto dal vivo**. Questo è un riscontro di fattibilità per la combinazione di hardware, stack e comunicazione sperimentata in quell'occasione, non una certificazione generale di qualità, sicurezza o assenza di bug. Durante il live sono emersi soprattutto problemi di **usabilità**, gestione musicale del tempo e rapidità di configurazione.

Problemi osservati o riferiti:
1. Il Tap BPM appare talvolta impreciso/instabile; sull'interfaccia touch il tapping può far scorrere involontariamente la pagina.
2. La modifica manuale del BPM, quando coinvolge decimali o controlli macchinosi, è scomoda.
3. BPM giusti non implicano che un effetto sia **in fase** con la musica: tempo e fase sono dimensioni distinte.
4. Velocità arbitrarie come `×1.389` sono poco significative durante un live; si desiderano rapporti musicali comprensibili, da valutare in potenze di due.
5. La lista delle scene è visivamente gradevole, ma lunga e ingombrante; costringe a scorrere.
6. La creazione e modifica di scene richiedono troppo lavoro preventivo.
7. Manca un'esperienza fluida per improvvisare con luci e controller fisici.

Questi sono **requisiti di prodotto** da affrontare; non è ancora stata diagnosticata la causa tecnica del problema TAP.

## 3. Visione

> **InStage rende possibile dirigere uno spettacolo luminoso in modo affidabile e musicale, con un'interfaccia web semplice per preparazione e automazione e una superficie fisica immediata per improvvisare dal vivo.**

La soluzione deve rendere facile ottenere un buon risultato senza una programmazione complessa, restando estensibile e sufficientemente espressiva per spettacoli più strutturati.

### I tre modi di interagire (orientamento CONFERMATO)

| Interfaccia | Ruolo prioritario | Non significa |
|---|---|---|
| Web UI | Regia: configurare show, scegliere scene automatiche, impostare BPM/effetti, osservare stato | Non obbliga a riprodurre gli 8×8 pad del Launchpad |
| Novation Launchpad X | Superficie performance: colori, distribuzione, accensione momentanea/persistente, improvvisazione | Non è una semplice scorciatoia per una lista di scene |
| IK Multimedia iRig Pads | Controllo compatto: principalmente scene, BPM e velocità | Non deve replicare tutta la matrice 8×8 |

Questi sono **ruoli preferiti**, non limiti rigidi: mapping/pagine e controlli alternativi restano da definire. Un dispositivo non deve diventare una dipendenza per il funzionamento dell'altro.

## 4. Principi del prodotto

1. **Performance-first quando si è sul palco.** Input diretti, risultati immediati, poca navigazione, feedback chiarissimo.
2. **Automazione semplice quando si è in regia.** Scene selezionabili velocemente; dati riutilizzabili; creazione di look e preset senza editor laboriosi per i casi comuni.
3. **Musicalità esplicita.** Separare BPM (frequenza), fase (allineamento) e suddivisione/velocità dell'effetto. Non confonderli nelle UI o nei contratti.
4. **Prevedibilità sopra la flessibilità astratta.** Sapere cosa succede premendo, tenendo e rilasciando un pad, soprattutto se altri sono premuti.
5. **Una sola autorità per lo stato live.** Il Raspberry/server controlla rendering, conflitti e stato; i client sono interfacce/input.
6. **Offline e locale.** Un concerto non deve dipendere da Internet, cloud, browser aperto, aggiornamenti automatici o servizi esterni.
7. **Sicurezza operativa.** Blackout d'emergenza, perdita dispositivi, riavvio, errori DMX e recovery devono avere comportamenti documentati e verificabili.
8. **Reimpiego selettivo del POC.** Conservare ciò che funziona, sostituire ciò che ostacola l'esperienza; niente riscrittura per principio né copia cieca dell'attuale dominio.
9. **Semplicità dei controlli comuni.** Avanzato e configurabile sì, ma senza rendere complessa l'operatività ordinaria.
10. **Stato e feedback coerenti.** UI e controller MIDI devono riflettere lo stesso stato effettivo, non simulare localmente un successo non confermato.

## 5. Percorsi utente principali

### UJ-01 — Preparare uno show

Un operatore configura fixture, disposizione fisica, universi e patch, definisce palette/distribuzioni, prepara scene ed effetti e salva lo show. Le azioni più comuni devono richiedere poco sforzo. Può verificare quale versione dello show è attiva, esportarla e ripristinarla.

### UJ-02 — Condurre lo show dalla Web UI

Durante un concerto l'operatore apre una vista **Live** leggibile su smartphone/tablet, seleziona rapidamente una scena senza scroll eccessivo e vede nome, descrizione breve, colori, gruppi/fixture coinvolti e indicazione di strobo. Regola il BPM senza decimali inutili e può correggere l'allineamento degli effetti.

### UJ-03 — Improvvisare con il Launchpad

Mentre è in Automatic, l'operatore interviene tramite Launchpad: InStage passa a **Performance** e i comandi manuali prevalgono. L'operatore seleziona una palette di colori, una distribuzione, tiene premuti più pad HOLD e mantiene alcuni fari accesi tramite TOGGLE. Il rilascio di un HOLD spegne il suo destinatario; se quel destinatario era stato attivato via TOGGLE, la pressione HOLD disinnesca l'attivazione persistente. I destinatari attivi delle due righe non devono sovrapporsi.

### UJ-04 — Tornare all'automazione

L'operatore comanda esplicitamente il ritorno ad Automatic: la scena/automazione selezionata riparte **dall'inizio**, non dal punto temporale lasciato in precedenza. Il BPM globale può rimanere memorizzato. Da chiarire: eventuale fade, start al beat/battuta, stato dei pad persistenti e che cosa significa precisamente «dall'inizio» per ciascun tipo di effetto.

### UJ-05 — Controllo compatto

Sull'iRig Pads l'operatore richiama scene e regola BPM/velocità da un numero contenuto di pad e controlli fisici; le curve e i rapporti musicali sono prevedibili. I controlli fisici esatti e il loro mapping vanno progettati e testati.

### UJ-06 — Recupero da un problema

Se il telefono perde connessione o un controller si disconnette, il server e il rendering hanno comportamenti definiti; non devono restare note HOLD «fantasma». Blackout e master rimangono raggiungibili anche in condizioni degradate. La procedura di aggiornamento/rollback non interrompe un live in corso.

## 6. Perimetro di prodotto

### Funzioni centrali desiderate

- Gestione di fixture, patch/universi, definizioni/capability, gruppi e disposizione sul palco.
- Show con scene e composizione di elementi luminosi/effetti.
- Tempo server-side: BPM, Tap, correzione fase, rapporti musicali.
- Vista Live delle scene compatta, informativa, rapida.
- Modalità Automatic e Performance con transizioni controllate.
- Launchpad X con eventi MIDI (pressione/rilascio; velocity e aftertouch da valutare) e feedback luminoso.
- iRig Pads con layout compatto focalizzato su scene e tempo.
- Performance: palette, distribuzioni, HOLD e TOGGLE per destinatari disgiunti, più eventuali strobo e movimenti.
- Creazione rapida di scene/asset riutilizzabili.
- Persistenza, diagnosi, backup/restore, test, release e rollback affidabili.

### Integrazioni/idee NON ancora approvate

- Specifica assegnazione di tutte le 64 celle e pulsanti esterni.
- Audio-reactivity, lettura audio dal microfono, MIDI clock, Ableton Link, SMPTE, timecode.
- Supporto a controller diversi da Launchpad X e iRig Pads.
- Distribuzioni dinamiche/procedurali complesse, morph evoluti, scripting, editor timeline.
- Deploy automatico durante il live.
- App mobile nativa (la Web UI può essere sufficiente).

Queste opzioni non devono comparire come prerequisiti impliciti dell'MVP.

## 7. Livelli concettuali (non architettura approvata)

- **Show/definizioni:** fixture, patch, disposizione, palette, distribuzioni, scene, movimenti, pattern.
- **Stato operativo:** modalità Automatic/Performance; selezioni, pressioni/attivazioni, clock, scena attiva.
- **Input adapters:** browser, MIDI Launchpad, MIDI iRig.
- **Comandi applicativi:** eventi normalizzati e validati (es. press/release, select palette, enter automatic).
- **Motore di composizione:** risolve l'output a partire dal dominio e dalle priorità.
- **Output/feedback adapters:** DMX USB, Art-Net e LED/feedback del controller.

Questa decomposizione è una **proposta da validare con ADR**; non è una prescrizione su package, goroutine o API concrete.

## 8. Baseline tecnica nota del POC e limiti della prova

La documentazione del POC descrive:
- Go + React/TypeScript; SQLite; API HTTP/WebSocket.
- Engine autonomo server-side con obiettivo 40 Hz, output DMX disaccoppiati.
- Raspberry Pi 4 ARM64 e frontend embedded nel binario.
- DMX FT232R/OpenDMX, mock esplicito e Art-Net.
- Snapshot/recovery, strumenti di test, build ARM64 e installazione controllata.
- Modello di clock basato su BPM/beat/phase e comandi TAP/nudge.
- Chases, scene, effetti, cue e UI touch.

Riferimenti tecnici del POC (repository privato: alcuni agenti potrebbero **non** avervi accesso):
- `instage-ai/README.md`
- `instage-ai/docs/ARCHITECTURE.md`
- `instage-ai/docs/TIMING.md`
- `instage-ai/docs/CONTRACT.md`
- `instage-ai/docs/EXECUTION-STATUS.md`
- `instage-ai/.github/workflows/ci.yml`

**Importante:** la documentazione storica del POC segnala test hardware ancora aperti alla data in cui fu scritta; il successivo uso reale in un live è stato riferito dal product owner e non equivale a superamento documentato di ogni test. Gli agenti non devono dichiarare qualità o supporto hardware «certificati» senza nuove evidenze.

## 9. Requisiti di qualità — obiettivi e non valori inventati

Per l'analisi successiva dovranno essere stabilite soglie misurabili di:
- latenza input MIDI → stato → DMX e jitter sotto carico;
- precisione TAP e capacità di riallineamento fase con jitter di rete;
- stabilità del playback per un live completo e comportamento alla perdita connessione;
- rapidità del workflow di selezione e creazione scene;
- leggibilità e operabilità mobile (layout responsive, scroll involontario, accessibilità);
- fluidità e coerenza del feedback sui pad;
- qualità del build/deploy/release e rollback effettivo;
- sicurezza elettrica/operativa e comportamento fail-safe compatibile con le fixture.

**Non fissare soglie numeriche** per queste metriche senza una decisione esplicita e prove strumentali. I 40 Hz descritti nel POC sono un punto di partenza tecnico, non una promessa di sincronia perfetta.

## 10. Strategia di evoluzione, senza avviare implementazioni

1. Consolidare requisiti e decisioni, riprodurre i problemi osservati nel POC.
2. Prototipare UX Live e mapping dei controller; verificare su hardware.
3. Definire modello del dominio/tempo, trade-off architetturali e ADR.
4. Identificare i componenti del POC riutilizzabili, adattabili o da sostituire.
5. Specificare test funzionali, integrazione MIDI/DMX e scenari di recovery.
6. Definire CI/CD, versioning, packaging ARM64, distribuzione e rollback.
7. Implementare incrementi verticali verificabili, mantenendo l'attuale POC intatto.

**Repository:** `instage` è il prodotto canonico; `instage-ai` resta la prova di concetto. Non sovrascrivere né migrare codice automaticamente. Non modificare la branch principale durante la sola fase di specifica.

## 11. Criteri di successo da validare

Uno spettacolo si può:
- preparare senza interazioni superflue;
- gestire da una UI Live compatta con scene distinguibili;
- seguire musicalmente regolando BPM, fase e suddivisioni;
- interrompere manualmente con Launchpad senza comportamenti ambigui;
- riprendere in Automatic dall'inizio in modo esplicito;
- svolgere anche senza Internet e senza collegamento continuo del telefono;
- recuperare da guasti comuni con procedure note.

La misura concreta di ogni criterio va convertita in acceptance test prima del rilascio.

## 12. Disciplina per gli agenti AI

1. Leggere **tutti e quattro** i documenti prima di generare design, issue o codice relativo al prodotto.
2. Usare gli ID dei requisiti per tracciabilità; linkare gli scenari nei test.
3. Non presentare decisioni **PROPOSTA/APERTA** come accettate, né scegliere silenziosamente un default.
4. Separare fatti osservati, decisioni esplicite e ipotesi.
5. Privilegiare test deterministici per clock, merge/override, press/release e rollback di stato.
6. Se una scelta aperta blocca l'implementazione, registrare opzioni, trade-off e impatto e richiedere decisione prima di implementare quella parte; proseguire pure con parti indipendenti.
7. Non inferire dal nome del repository storico che il suo codice rappresenti la nuova architettura.

---

**Documenti correlati:** [Functional Requirements](FUNCTIONAL-REQUIREMENTS.md) · [Performance Mode](PERFORMANCE-MODE.md) · [Open Questions](OPEN-QUESTIONS.md).

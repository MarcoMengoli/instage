# ISSUE-004 — Autonomia e resilienza del server

Labels: `fase-1`, `backend`
Dipende da: ISSUE-002, ISSUE-003

## Contesto

Requisito chiave (DESIGN §4 "Autonomia e resilienza"): in caso di problemi di rete
o dei client, il server **continua con l'ultima scena/chase impostata** — mai buio,
mai freeze. Questa issue rende il requisito verificabile e testato.

## Scope

- **Indipendenza dai client**: la disconnessione di qualunque client (o di tutti)
  non modifica lo stato dell'engine; scene/chase/override attivi restano attivi.
- **Backpressure**: canali di broadcast verso i client con buffer limitato; un client
  che non consuma viene scollegato (policy "drop slow consumer"), l'engine non
  aspetta mai nessuno.
- **Persistenza dello stato attivo**: snapshot (scena/chase/cue attivi, master,
  blackout, override) scritto su disco in modo debounced (es. max 1 scrittura/2 s)
  da un task separato dal render loop; al riavvio l'engine riparte da lì.
- **Isolamento panic**: handler API/WS su task tokio (un panic non abbatte il processo);
  thread engine supervisionato: se termina, viene ricreato dallo stato persistito e
  l'evento è loggato con livello error.
- **Driver flaky**: se `send` fallisce, retry con backoff esponenziale (100 ms → 5 s)
  e riapertura del device; l'engine continua a girare; stato di salute del driver
  esposto nello snapshot verso i client.

### Fuori scope

`systemd Restart=always` e watchdog di processo (ISSUE-008).

## Attività

- [ ] Task di persistenza snapshot (serde → file atomico: write + rename).
- [ ] Ripristino all'avvio: se esiste uno snapshot, l'engine parte da quello.
- [ ] Supervisore del thread engine (join + ricreazione + restore).
- [ ] Policy backpressure sul broadcast di stato (buffer N, disconnect dei ritardatari).
- [ ] Retry/riapertura driver con backoff; campo `output_health` nello snapshot.
- [ ] Test di caos (sotto).

## Test

Automatici (con driver mock e client WS di test):

1. **Client killed**: attiva scena → chiudi il socket bruscamente → per i successivi
   5 s il mock continua a ricevere ~40 frame/s con i valori della scena.
2. **Tutti i client disconnessi**: identico, con N client.
3. **Client lento**: un client che non legge non riduce il frame rate (misurato sul mock)
   e viene scollegato entro il timeout.
4. **Restart**: attiva scena + master 50 % → SIGKILL al processo → riavvio → entro 5 s
   il mock riceve frame identici a prima del kill.
5. **Driver failure**: il mock fallisce `send` per 3 s → l'engine non si ferma,
   `output_health` passa a `error` e poi torna `ok`, i frame riprendono.
6. **Panic injection**: endpoint di test (solo build di test) che panica in un handler →
   il server risponde ancora e i frame non si interrompono.

Manuali: stacca il Wi-Fi del tablet durante un fade → le luci completano il fade;
riattacca → l'app si risincronizza allo stato corrente.

## Acceptance criteria

- [ ] Tutti e 6 i test di caos automatici passano in CI.
- [ ] In nessun punto del codice una disconnessione client invoca modifiche allo
      stato engine (verificato a review: l'handler di disconnect non manda comandi).
- [ ] Lo snapshot persistito è versionato (campo `version`) e uno snapshot corrotto
      o incompatibile viene ignorato con warning (si parte puliti, non si crasha).
- [ ] Il test manuale Wi-Fi è documentato ed eseguito con esito positivo.

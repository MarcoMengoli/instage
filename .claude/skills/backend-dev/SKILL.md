---
name: backend-dev
description: Convenzioni e comandi per lavorare sul backend Rust (instage-server). Usa questa skill prima di scrivere o modificare codice in instage-server/ — engine DMX, driver di output, API axum, persistenza SQLite.
---

# Sviluppo backend (instage-server)

## Comandi

```bash
cd instage-server
cargo fmt --all              # formatta (CI usa --check)
cargo clippy --all-targets -- -D warnings
cargo test                   # unit + integrazione
cargo run                    # avvio locale (driver mock se manca l'hardware)
cargo run --bin export-schema  # rigenera shared/schema/ (vedi skill api-contract)
```

Prima di ogni commit: fmt + clippy + test devono passare. La CI è bloccante.

## Invarianti architetturali (da DESIGN.md — violarli = bug)

1. **Il render loop non fa I/O.** Nessuna chiamata rete/DB/disco/log sincrono nel
   percorso del tick. Il thread engine possiede lo stato; tutto il resto gli parla
   via canali (`mpsc` comandi in ingresso, `watch`/`broadcast` stato in uscita).
2. **Nessun lock condiviso sul percorso caldo.** Se ti serve un `Mutex` toccato dal
   tick, la struttura è sbagliata: passa dai canali.
3. **I client non sono mai una dipendenza.** Nessun codice in cui disconnessioni,
   errori di rete o client lenti modificano, bloccano o rallentano l'output DMX.
   Client lento ⇒ si scollega lui, mai si aspetta.
4. **Grand master e blackout a valle di tutto.** Qualunque nuovo layer o feature
   deve passare sotto master/blackout, mai aggirarli.
5. **I driver stanno dietro `DmxOutput`.** Nessun tipo di `serialport`/rete fuori
   dai moduli driver. Un driver che fallisce logga e riprova, non panica.
6. **Gli errori di input non abbattono nulla.** Payload invalido ⇒ errore tipizzato
   al chiamante, stato engine intatto.

## Convenzioni di codice

- Errori di dominio con `thiserror`; niente `unwrap`/`expect` fuori da test e da
  invarianti commentate.
- Ogni messaggio WS / body REST è un tipo con `Serialize + Deserialize + JsonSchema`
  registrato nella pipeline schema (skill `api-contract`).
- Test con clock finto per tutto ciò che dipende dal tempo (fade, chase, BPM):
  il tempo si inietta, non si `sleep`a nei test.
- I test di resilienza (ISSUE-004) sono il contratto del requisito chiave: se una
  modifica li fa fallire, è la modifica a essere sbagliata.

## Definition of done

Feature implementata + test (inclusi i casi di errore) + clippy/fmt puliti +
acceptance criteria dell'issue corrispondente verificati + DESIGN.md aggiornato
se una decisione è cambiata.

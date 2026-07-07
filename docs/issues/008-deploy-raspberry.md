# ISSUE-008 — Deploy su Raspberry Pi: cross-compile, systemd, mDNS

Labels: `fase-1`, `infra`, `hardware`
Dipende da: ISSUE-002, ISSUE-003, ISSUE-007

## Contesto

Chiusura della milestone M1: il sistema gira sul Pi come servizio, sopravvive a
riavvii e crash, ed è raggiungibile come `instage.local`.

## Scope

- Cross-compilazione con `cross` per il target del Pi (`aarch64-unknown-linux-gnu`;
  verificare il modello: per Pi ≤3 a 32 bit è `armv7-unknown-linux-gnueabihf`).
- Bundle: binario + web app buildata (servita dal binario) + file di config.
- Unit systemd: `Restart=always`, `RestartSec=2`, `WatchdogSec` con `sd_notify`
  dal render loop (se il loop si blocca, systemd riavvia — completa ISSUE-004).
- mDNS: annuncio `instage.local` (`mdns-sd`) + nome servizio `_instage._tcp`.
- Script `deploy.sh`: build → scp → restart servizio, idempotente.
- Regola udev per il FT232R (accesso senza root).

### Fuori scope

Immagini SD preconfezionate, provisioning del Pi da zero (documentato a mano nel README).

## Attività

- [ ] Setup `cross` + task CI che produce l'artefatto per il Pi a ogni tag.
- [ ] Unit systemd con watchdog + integrazione `sd_notify` nel loop.
- [ ] Annuncio mDNS all'avvio.
- [ ] `deploy.sh` + documentazione installazione in `docs/DEPLOY.md`.
- [ ] Regola udev documentata e inclusa.

## Test

Checklist manuale sul Pi reale (annotare gli esiti in fondo alla issue):

1. `deploy.sh` da macchina di sviluppo → servizio attivo, app su `http://instage.local`.
2. Riavvio elettrico del Pi con scena attiva → entro 30 s dal boot le luci tornano
   alla scena (persistenza ISSUE-004 + autostart).
3. `kill -9` del processo → systemd lo rialza entro 5 s, look ripristinato.
4. Blocco artificiale del loop (build di test) → watchdog systemd riavvia.
5. 24 h di run: memoria stabile (< +10 % RSS), zero restart non richiesti nei log.

## Acceptance criteria

- [ ] Tutti i 5 punti della checklist verificati sul Pi.
- [ ] Il deploy non richiede mai di compilare sul Pi.
- [ ] `docs/DEPLOY.md` permette a una persona nuova di installare da zero.
- [ ] Il servizio parte senza rete e senza adattatore USB collegato (log warning,
      driver mock), e aggancia l'hardware quando compare.

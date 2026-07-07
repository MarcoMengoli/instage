# ISSUE-003 — Trait output + driver FT232R (OpenDMX) + driver mock

Labels: `fase-1`, `backend`, `hardware`
Dipende da: ISSUE-001

## Contesto

L'uscita DMX è astratta dietro un trait (DESIGN §4) così da supportare l'adattatore
USB FT232R oggi e Art-Net domani (ISSUE-016) senza toccare l'engine.

## Scope

- Trait `DmxOutput { fn send(&mut self, universe: u16, frame: &[u8; 512]) -> Result<()> }`.
- **Driver FT232R**: porta seriale a 250 kbaud, 8N2; per ogni frame: break ≥ 88 µs,
  Mark-After-Break, start code `0x00`, 512 byte. Device configurabile
  (default `/dev/ttyUSB0`).
- **Driver mock**: registra i frame inviati (per i test) e opzionalmente li stampa
  (per lo sviluppo senza hardware).
- Gestione errori: `send` che fallisce non deve mai panicare; l'errore risale al
  supervisore (la politica di retry è in ISSUE-004).
- Mappa `universo → driver` in configurazione.

### Fuori scope

Art-Net/sACN (016), retry/riapertura automatica (004).

## Attività

- [ ] Definire il trait e il registry `universo → Box<dyn DmxOutput>`.
- [ ] Implementare `MockOutput` con contatore frame e ultimo frame ispezionabile.
- [ ] Implementare `OpenDmxOutput` con crate `serialport`
      (break via `set_break`/`clear_break` + sleep calibrato).
- [ ] Flag/config per scegliere il driver all'avvio (mock di default se il device manca,
      con warning esplicito in log).
- [ ] Documentare in `instage-server/README.md` i permessi udev per `/dev/ttyUSB0`
      (gruppo `dialout` o regola udev dedicata).

## Test

- Unit (mock): l'engine collegato al mock produce ~40 frame/s con i valori attesi.
- **Manuale su hardware** (checklist da eseguire su Raspberry + FT232R + un PAR):
  1. canale dimmer a 255 → il faro si accende al massimo;
  2. sweep 0→255 in 5 s → dimming fluido senza flicker;
  3. 30 minuti a regime → nessun frame error visibile, memoria stabile.

## Acceptance criteria

- [ ] L'engine scrive sull'uscita solo tramite il trait: nessun riferimento a
      `serialport` fuori dal modulo driver.
- [ ] Server avviabile senza hardware collegato (driver mock) senza errori fatali.
- [ ] Checklist manuale su hardware completata e annotata in fondo a questa issue.
- [ ] Un errore di `send` (es. cavo staccato) viene loggato e non termina il processo.

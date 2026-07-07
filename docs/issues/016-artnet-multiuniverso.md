# ISSUE-016 — Driver Art-Net + multi-universo

Labels: `fase-5`, `backend`, `hardware`
Dipende da: ISSUE-003

## Contesto

Con ~30 fixture i 512 canali di un universo possono non bastare. L'output è già
astratto (ISSUE-003): qui si aggiunge il driver Art-Net e la configurazione
multi-universo end-to-end (DESIGN §4).

## Scope

- Driver `ArtNetOutput`: pacchetti `ArtDmx` UDP verso IP:porta configurati
  (unicast; broadcast opzionale), mapping universo interno → net/subnet/universe
  Art-Net; sequence number gestito.
- Refresh anche in assenza di cambiamenti (≥ 1 frame/s per universo, come da
  consuetudine Art-Net keep-alive) — l'engine già manda a 40 Hz, quindi basta
  non filtrare i frame identici.
- Configurazione: più universi attivi, ognuno col proprio driver (USB, Art-Net,
  mock), modificabile da `settings` API + UI Setup.
- Patch UI: selezione universo per fixture (probabilmente già prevista in 005/010;
  qui si verifica end-to-end con 2 universi reali).
- Discovery `ArtPoll` opzionale (elencare i nodi in rete nella UI Setup) — nice to
  have, non bloccante.

### Fuori scope

sACN/E1.31 (issue futura se servirà), RDM, sync Art-Net (`ArtSync`).

## Attività

- [ ] Implementare `ArtNetOutput` (il pacchetto ArtDmx è semplice: header 18 byte
      + payload; valutare crate `artnet_protocol` vs implementazione propria).
- [ ] Config multi-universo in `settings` + validazioni (universo duplicato,
      driver mancante).
- [ ] UI Setup: gestione universi e driver.
- [ ] Test con nodo reale o software (QLC+ / DMX-Workshop come ricevitore).

## Test

- Unit: byte-golden del pacchetto ArtDmx (header, opcode, sequence, length).
- Integrazione: engine con 2 universi (1 mock + 1 Art-Net verso socket UDP di test) →
  entrambi ricevono i frame giusti a 40 Hz.
- Manuale: nodo Art-Net reale (o QLC+ in ascolto) riceve e visualizza i canali;
  fixture patchata sull'universo 2 risponde.

## Acceptance criteria

- [ ] Una fixture patchata su universo Art-Net funziona in modo indistinguibile
      da una su USB (scene, chase, effetti, cue).
- [ ] La perdita del nodo Art-Net (rete giù) non influenza l'universo USB né
      l'engine (estensione test resilienza ISSUE-004).
- [ ] Il cambio di driver di un universo non richiede restart del server.
- [ ] Con 4 universi pieni a 40 Hz il tick resta < 2 ms (bench di ISSUE-002 ripetuto).

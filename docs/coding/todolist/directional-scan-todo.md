# Directional Scan — Todolist

Checklist operativa derivata dal piano. Spuntare a implementazione avvenuta.

## Pre-implementazione

- [ ] Scegliere il tasto di ingresso modalita' e verificarlo libero.
- [ ] Decidere meccanismo di uscita (escapePops vs VK_ESCAPE esplicito).
- [ ] Confermare il nome `civvaccess_shared.scannerRadius` o il default 3.

## Core

- [ ] Creare `CivVAccess_DirectionalScan.lua` con header e `Log.info` init.
- [ ] Implementare helper `describeStep` (cella singola: revealed, glance,
      owner-change prefix).
- [ ] Implementare `scanOne(x, y, direction, radius)` con bordo mappa e
      riepilogo/troncamento.
- [ ] Implementare `scanComposite(x, y, dirA, dirB, radius)` con interleaving
      e banner composito.

## Modalita' e binding

- [ ] Implementare `enterMode()` che pusha l'handler modale.
- [ ] Binding interni Q/E/A/D/Z/C + W/X + VK_ESCAPE con helpEntries.
- [ ] `getBindings()` col tasto di ingresso e relativa helpEntry.
- [ ] Parlato: banner `speakInterrupt`, step `speakQueued`.

## Aggancio

- [ ] `include("CivVAccess_DirectionalScan")` in Boot tra CursorCore e
      BaselineHandler.
- [ ] Pubblicare il modulo in `civvaccess_shared.modules`.
- [ ] `appendAll(bindings, dirScan.bindings)` in `BaselineHandler.create()`.
- [ ] Inserire le helpEntries nella sezione corretta della help list.

## Stringhe (11 lingue)

- [ ] Aggiungere chiavi nuove a `en_US`.
- [ ] Replicare nelle altre 10 lingue con placeholder e `-- TODO: translate`.
- [ ] Riusare UNEXPLORED ed EDGE_OF_MAP esistenti.

## Test

- [ ] `tests/directional_scan_test.lua` con i 8 casi del piano.
- [ ] Registrare la suite in `tests/run.lua`.
- [ ] `./test.ps1` verde.

## Vincoli (verifica finale)

- [ ] Nessuna stringa inline.
- [ ] Nessun `tolk.speak` diretto.
- [ ] Cursore in sola lettura.
- [ ] nil gestito su Map.PlotDirection e IsRevealed.
- [ ] pcall + Log.error su ogni callout engine.
- [ ] Nessuna cache di stato di gioco.
- [ ] Nessuna modifica a src/proxy o src/engine; GUID invariato.

## Documentazione

- [ ] Sezione "Directional Scan" in `docs/hotkey-reference.md`.
- [ ] Voce in `CHANGELOG.md` sotto `## [Unreleased]`.

## Lint

- [ ] `bash lint.sh` pulito (luacheck + stylua).

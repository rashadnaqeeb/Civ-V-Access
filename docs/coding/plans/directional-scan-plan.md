# Directional Scan — Piano Implementativo

Schema tasti: Opzione C (modalita' dedicata). Riferimento simboli verificati:
`docs/coding/design/directional-scan-design.md`.

Ordine degli step per dipendenze: prima il core testabile, poi la modalita',
poi l'aggancio, poi stringhe, test e documentazione.

## Architettura del modulo

- File nuovo: `src/dlc/UI/InGame/CivVAccess_DirectionalScan.lua`.
- Espone:
  - `DirectionalScan.scanOne(x, y, direction, radius)` — core testabile.
    Ritorna una tabella di stringhe (banner + step + riepilogo/troncamento).
    NON parla: restituisce solo testo, cosi' i test lo verificano offline.
  - `DirectionalScan.scanComposite(x, y, dirA, dirB, radius)` — interleaving
    Nord/Sud, ritorna tabella di stringhe.
  - `DirectionalScan.getBindings()` — ritorna `{ bindings, helpEntries }` con
    il solo tasto di ingresso modalita', per `appendAll` in Baseline.
  - Una factory interna `enterMode()` che costruisce e pusha l'handler
    modale; le funzioni che parlano usano SpeechPipeline (banner con
    `speakInterrupt`, step successivi con `speakQueued`).

## STEP 1 — Core di scansione (scanOne)

- File: `CivVAccess_DirectionalScan.lua`. Azione: CREATE.
- Dipende: nessuna.
- Rischio: MEDIO (logica bordo mappa, fog, cambio proprieta').
- Descrizione:
  - Iterare da 1 a `radius` (default `civvaccess_shared.scannerRadius` o 3).
  - A ogni passo: `Map.PlotDirection(curX, curY, direction)` dentro `pcall`.
    Se ritorna nil -> bordo mappa: aggiungere stringa
    `Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_STEP_EDGE", dirLabel, n)` e
    interrompere, poi appendere il troncamento.
  - Aggiornare curX/curY al plot ottenuto via `:GetX()/:GetY()` per il passo
    successivo (rilettura, nessuna cache di stato).
  - Gating rivelazione: `plot:IsRevealed(Game.GetActiveTeam(), Game.IsDebugMode())`.
    Se non rivelato -> solo `Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")`.
  - Altrimenti descrizione cella: `PlotComposers.glance(plot, {})`.
  - Cambio proprieta': confrontare il token di `PlotSections.ownerIdentity(plot)`
    col token del passo precedente; se cambia e non e' "unclaimed",
    prefissare con la stringa parlata dell'owner + ". ".
  - Comporre la riga step con
    `Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_STEP", dirLabel, n, info)`.
  - Al termine completo: `Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_COMPLETE", count, dirLabel)`.
  - Troncamento bordo: `Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_TRUNCATED", count, total)`.
- Convalida: test offline scanOne (vedi STEP 6).

## STEP 2 — Core composito (scanComposite)

- File: `CivVAccess_DirectionalScan.lua`. Azione: CREATE (stessa creazione).
- Dipende: STEP 1.
- Rischio: MEDIO (interleaving corretto).
- Descrizione:
  - Banner composito iniziale (es. "Nord (NO, NE)") via
    `Text.format` con label composita.
  - Per ogni passo n da 1 a radius: emettere prima la cella in dirA a
    distanza n, poi la cella in dirB a distanza n (interleaved per step).
  - Riutilizzare la logica per-cella di scanOne (estrarre una helper interna
    `describeStep` condivisa tra scanOne e scanComposite per non duplicare).
  - Gestire il bordo mappa indipendentemente per i due rami.
- Convalida: test offline scanComposite (vedi STEP 6).

## STEP 3 — Handler modale e binding di ingresso

- File: `CivVAccess_DirectionalScan.lua`. Azione: CREATE (stessa creazione).
- Dipende: STEP 1, STEP 2.
- Rischio: MEDIO (stato sullo stack, convivenza purgeDeadEnv).
- Descrizione:
  - `enterMode()` legge `Cursor.position()` (sola lettura) per fissare il
    punto di partenza, poi costruisce un handler:
    - `name = "DirectionalScanMode"`.
    - `capturesAllInput = true`, `beaconsTransparent = true`.
    - `bindings`: Q/E/A/D/Z/C (MOD_NONE) -> scanOne nelle 6 direzioni;
      W -> scanComposite Nord (NW,NE); X -> scanComposite Sud (SW,SE);
      VK_ESCAPE -> `HandlerStack.removeByName("DirectionalScanMode", false)`
      con annuncio di uscita.
    - `helpEntries`: voci per le direzioni e per Esc.
  - Ogni binding rilegge `Cursor.position()` al momento (nessuna cache):
    il cursore non si muove, ma si rilegge per robustezza.
  - Le funzioni di scansione parlano: prima riga `speakInterrupt`, righe
    successive `speakQueued`.
  - `getBindings()` ritorna il tasto di ingresso (MOD_NONE, tasto da
    verificare libero) la cui fn chiama `enterMode()`, piu' la sua helpEntry.
- Convalida: lint; test del binding di ingresso e dei binding interni
  (findBinding + fn) con cursore e Map.PlotDirection mockati.

## STEP 4 — Aggancio in Boot e Baseline

- File: `CivVAccess_Boot.lua` (MODIFY), `CivVAccess_BaselineHandler.lua` (MODIFY).
- Dipende: STEP 3.
- Rischio: BASSO.
- Descrizione:
  - Boot: aggiungere `include("CivVAccess_DirectionalScan")` tra CursorCore
    (riga 49) e BaselineHandler (riga 94); pubblicare il modulo in
    `civvaccess_shared.modules` accanto agli altri.
  - Baseline: in `create()`, dopo gli altri `appendAll`, aggiungere
    `local dirScan = DirectionalScan.getBindings()` e
    `appendAll(bindings, dirScan.bindings)`; inserire le helpEntries nella
    sezione appropriata della help list.
- Convalida: lint; il gioco carica senza errori; il tasto entra in modalita'.

## STEP 5 — Stringhe localizzate (11 lingue)

- File: tutti i `CivVAccess_InGameStrings_*.lua` (MODIFY).
- Dipende: STEP 1-3 (nomi chiave definitivi).
- Rischio: BASSO (ripetitivo).
- Descrizione:
  - Aggiungere a `en_US` le chiavi nuove con testo inglese:
    `DIRSCAN_STEP`, `DIRSCAN_STEP_EDGE`, `DIRSCAN_TRUNCATED`,
    `DIRSCAN_COMPLETE`, le label direzione (`DIR_NW/NE/W/E/SW/SE`,
    `DIR_N_COMPOSITE`, `DIR_S_COMPOSITE`), la help key/desc di ingresso e Esc.
  - Riutilizzare `TXT_KEY_CIVVACCESS_UNEXPLORED` e `..._EDGE_OF_MAP` esistenti
    dove possibile.
  - Replicare le stesse chiavi negli altri 10 file lingua col valore en_US
    come placeholder, ognuna commentata `-- TODO: translate`.
- Convalida: lint; nessuna chiave mancante a runtime (il wrapper logga le
  chiavi mancanti).

## STEP 6 — Test

- File: `tests/directional_scan_test.lua` (CREATE), `tests/run.lua` (MODIFY).
- Dipende: STEP 1-3.
- Rischio: BASSO.
- Descrizione: usare `T.fakePlot` e un mock di `Map.PlotDirection`.
  Casi obbligatori:
  - scanOne normale (3 passi, tutti rivelati).
  - scanOne bordo mappa al passo 2 (Map.PlotDirection -> nil).
  - scanOne cella non rivelata al passo 1 (solo UNEXPLORED).
  - scanOne cambio proprieta' tra passo 1 e 2 (prefisso owner).
  - scanComposite NW+NE: verifica interleaving (dirA poi dirB per step).
  - scanComposite: banner composito presente come prima stringa.
  - binding di ingresso: pusha "DirectionalScanMode"; Esc lo rimuove.
  - Registrare la suite in `tests/run.lua` con
    `T.register("directional_scan", require("directional_scan_test"))`.
- Convalida: `./test.ps1` verde.

## STEP 7 — Documentazione

- File: `docs/hotkey-reference.md` (MODIFY), `CHANGELOG.md` (MODIFY).
- Dipende: STEP 1-6.
- Rischio: BASSO.
- Descrizione:
  - hotkey-reference: nuova sezione "Directional Scan" con il tasto di
    ingresso, le direzioni interne, la nota mirror numpad, le composite N/S.
  - CHANGELOG sotto `## [Unreleased]` / `New Features and improvements:`,
    una riga concisa dal punto di vista del giocatore con il tasto di ingresso.
- Convalida: lettura.

## Punti aperti minori

- Tasto di ingresso modalita': da scegliere e verificare libero in
  `docs/hotkey-reference.md` e nei binding Baseline prima dello STEP 3.
  Candidati mnemonici da verificare: un tasto libero singolo, senza modifier.
- Conferma del metodo di uscita: `escapePops` di un handler grezzo vs binding
  VK_ESCAPE esplicito (da decidere leggendo come BaseMenu implementa
  `escapePops`, se si usa un handler grezzo invece di BaseMenu.create).

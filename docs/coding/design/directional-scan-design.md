# Directional Scan — Documento di Design

Feature: scansione lineare direzionale a partire dal cursore, attivata da
tastiera, che legge vocalmente fino a `scannerRadius` celle in una direzione
senza spostare il cursore.

Branch: `directional-scanner`.

Stato: ANALISI COMPLETATA. Decisione schema tasti presa dal Coordinatore:
Opzione C (modalita' dedicata). Piano e todolist redatti.

## 1. Scopo

- Permettere all'utente non vedente di "guardare avanti" in una direzione
  esatta dal cursore, senza muoverlo.
- Output esclusivamente vocale tramite la pipeline centrale.
- Nessuna modifica all'engine audio core, nessuna rottura dei test esistenti.

## 2. Simboli verificati nel sorgente

Tutti i riferimenti sono stati letti direttamente dal sorgente sul branch
`directional-scanner`. Path relativi a `src/dlc/UI`.

### 2.1 Input e modifier

- `MOD_SHIFT = 1`, `MOD_CTRL = 2`, `MOD_ALT = 4`.
  Riga: `Shared/CivVAccess_InputRouter.lua:55-57`.
- AltGr collapse: se Alt e Ctrl sono entrambi premuti, Ctrl viene rimosso
  e il chord diventa solo Alt.
  Riga: `Shared/CivVAccess_InputRouter.lua:238-242`.
  Conseguenza: un chord Ctrl+Alt distinto NON e' possibile.
- `dispatch()` esegue prima un passaggio con il keycode originale, poi, solo
  se nulla scatta, un secondo passaggio con la lettera mirrorata dal numpad.
  Righe: `Shared/CivVAccess_InputRouter.lua:336-353`.
  Conseguenza chiave: un binding diretto su `VK_NUMPAD7` ha la PRECEDENZA
  sul mirror. Il commento del sorgente lo conferma (riga 341-345).

### 2.2 NUMPAD_MIRROR (stato attuale del numpad)

- Mappa: Numpad 7/8/9 = Q/W/E, 4/5/6 = A/S/D, 1/2/3 = Z/X/C.
  Righe: `Shared/CivVAccess_InputRouter.lua:73-82`.
- Il numpad NON ha binding diretti: e' interamente servito dal mirror.
  Verificato: nessun `bind(Keys.VK_NUMPAD...)` esiste nel repo.

### 2.3 HandlerStack e binding

- `HandlerStack.bind(key, mods, fn, description)` ritorna una tabella
  `{ key, mods, fn, description }`.
  Riga: `Shared/CivVAccess_HandlerStack.lua:94-95`.
- I moduli sibling espongono `getBindings()` che ritorna una tabella con
  campo `bindings`; BaselineHandler li unisce con `appendAll`.
  Righe: `InGame/CivVAccess_BaselineHandler.lua:201-208, 414-429`.
- BaselineHandler NON definisce `MOD_ALT`: i binding Alt arrivano dai
  moduli sibling (es. UnitControlMovement). Questo e' il punto di aggancio
  corretto per la nuova feature: un modulo proprio con `getBindings()`.

### 2.4 Cursore (read-only)

- `Cursor.position()` ritorna due numeri: `_x, _y`. Non un plot.
  Righe: `InGame/CivVAccess_CursorCore.lua:354-355`.
- `Cursor.move(direction)` usa `Map.PlotDirection(_x, _y, direction)`.
  Riga: `InGame/CivVAccess_CursorCore.lua:287-292`.
- Pubblicazione: `civvaccess_shared.modules.Cursor` in
  `InGame/CivVAccess_Boot.lua:206`.

### 2.5 Lettura cella

- `PlotComposers.glance(plot, opts)` ritorna una stringa unica con i token
  separati da ", ". Opzione verificata: `opts.cueOnly`.
  Righe: `InGame/CivVAccess_PlotComposers.lua:37-69`.
  Nota: il composer gestisce solo la distinzione visibile/fog. Il chiamante
  DEVE filtrare prima su `IsRevealed`, esattamente come fa il Cursor.
- `PlotSections.ownerIdentity(plot)` ritorna due valori: la stringa parlata
  e un token identita' (`"unclaimed"` oppure `"civ:<id>"`).
  Righe: `InGame/CivVAccess_PlotSectionsCore.lua:39-51`.
  Nota: non esiste alcun token `ownerSpoken` (nome errato nel prompt).
- `plot:IsRevealed(team, debug)` esiste; uso reale in
  `InGame/CivVAccess_CursorCore.lua:183`. Doc: `docs/llm-docs/lua-api/Plot.md:371`.

### 2.6 Geometria hex

- `HexGeom` espone gia' diverse funzioni utili, tra cui
  `HexGeom.cubeDistance`, `HexGeom.directionRank`, `HexGeom.plotsInRange`.
  Righe: `InGame/CivVAccess_HexGeom.lua:342, 356, 378`.
- Le sei `DirectionTypes` verificate: `DIRECTION_NORTHEAST`, `DIRECTION_EAST`,
  `DIRECTION_SOUTHEAST`, `DIRECTION_SOUTHWEST`, `DIRECTION_WEST`,
  `DIRECTION_NORTHWEST`. Non esistono DIRECTION_N / DIRECTION_S.
  Righe: `InGame/CivVAccess_HexGeom.lua:221-226`.
- `Map.PlotDirection(x, y, direction)` documentata in
  `docs/llm-docs/lua-api/Map.md:131`. Ritorna nil oltre il bordo mappa.

### 2.7 Testo e parlato

- `Text.key(keyName)` e `Text.format(keyName, ...)` con placeholder
  posizionali nel formato `{1_Nome}`, `{2_Altro}`.
  Righe: `Shared/CivVAccess_Text.lua:52, 75, 19`.
- Pipeline parlato: metodi pubblici verificati sono
  `SpeechPipeline.speakInterrupt(text)` e `SpeechPipeline.speakQueued(text)`.
  Righe: `Shared/CivVAccess_SpeechPipeline.lua:39, 56`.
  Nota: NON esiste `SpeechPipeline.speak` (nome errato nel prompt). Per una
  sequenza di celle senza interrompersi a vicenda, il metodo corretto e'
  `speakQueued`.

### 2.8 Stringhe localizzate

- Tabella: `CivVAccess_Strings["TXT_KEY_..."] = "..."`.
  Entry scalare o tabella `{ one = ..., other = ... }` per i plurali.
  Righe: `InGame/CivVAccess_InGameStrings_en_US.lua:120, 142, 162-164`.
- Chiavi gia' presenti e riutilizzabili:
  `TXT_KEY_CIVVACCESS_EDGE_OF_MAP` (`:739`),
  `TXT_KEY_CIVVACCESS_UNEXPLORED` (`:749`).
- Chiave assente, da creare se serve: `TXT_KEY_CIVVACCESS_OPEN_TERRAIN`.
- Sono presenti 11 file lingua: de_DE, en_US, es_ES, fr_FR, it_IT, ja_JP,
  ko_KR, pl_PL, pt_BR, ru_RU, zh_Hant_HK. Ogni nuova chiave va aggiunta a
  tutti e 11.

### 2.9 Test

- Struttura: `local T = require("support")`, modulo `M` con funzioni
  `M.test_*`, `return M`. Registrazione in `tests/run.lua` con
  `T.register("nome", require("nome_test"))`.
  Righe: `tests/run.lua:8, 251`, `tests/support.lua:54, 107`.
- Mock cella: `T.fakePlot(opts)`, con `p:IsRevealed(team, debug)`.
- Per il nuovo modulo: `tests/directional_scan_test.lua`, mock di
  `Map.PlotDirection` e `T.fakePlot`, registrazione in `run.lua`.

## 3. Punto di aggancio proposto

- Nuovo modulo `InGame/CivVAccess_DirectionalScan.lua` che espone
  `getBindings()` (stesso pattern di UnitControlMovement).
- `include("CivVAccess_DirectionalScan")` in `CivVAccess_Boot.lua` tra
  CursorCore (riga 49) e BaselineHandler (riga 94).
- BaselineHandler.create() chiama `appendAll(bindings, dirScan.bindings)`.
- Pubblicazione modulo in Boot via `civvaccess_shared.modules`.

## 4. DECISIONE CRITICA — schema tasti (richiede il Coordinatore)

Il prompt propone Alt+Numpad direzione per la scansione. Verifica:

- Oggi Alt+Numpad direzione e' gia' usato, via mirror, per il MOVIMENTO
  UNITA':
  - Alt+Numpad 7/9/4/6/1/3 = Alt+Q/E/A/D/Z/C = muovi unita' in direzione.
    Righe: `InGame/CivVAccess_UnitControlMovement.lua:349-364`.
  - Alt+Numpad 8/2 = Alt+W/X = sveglia / salta turno. Righe: `:370-371`.
- Bindare direttamente `VK_NUMPAD` con `MOD_ALT` e' tecnicamente possibile e
  prende la precedenza sul mirror, MA toglie all'utente l'alias numpad per
  muovere l'unita' (il tasto fisico Alt+lettera continuerebbe a funzionare).

Opzioni sul tavolo:

- Opzione A — come da prompt: ridestinare Alt+Numpad direzione alla
  scansione. Costo: si perde l'alias numpad del movimento unita'; possibile
  confusione tra "muovi" e "scandisci" sulla stessa gestualita'.
- Opzione B — chord diverso, es. Shift+Alt+Numpad direzione (mask 5).
  Da verificare che Shift+Alt+lettera sia libero. Mantiene Alt+Numpad per
  il movimento unita'.
- Opzione C — modalita' dedicata: un tasto entra in "modalita' scansione"
  (handler pushato sullo stack), poi le direzioni numpad scandiscono, Esc
  esce. Nessun conflitto di chord, coerenza gestuale piena. Piu' codice
  (gestione stack), piu' pulito a livello UX.

Ctrl+Alt e' escluso a priori per via dell'AltGr collapse.

DECISIONE: Opzione C — modalita' dedicata.

- Un tasto di ingresso (da scegliere e verificare libero) entra in
  "modalita' scansione direzionale": un handler viene pushato sullo stack
  con `capturesAllInput = true` e `beaconsTransparent = true`.
- Dentro la modalita', le direzioni SEMPLICI (senza modifier) scandiscono:
  - Q/E/A/D/Z/C = NW/NE/W/E/SW/SE (stessa gestualita' del movimento cursore).
  - W = Nord composito (NW+NE interleaved), X = Sud composito (SW+SE).
  - Il numpad arriva gratis: bindando le lettere, il secondo passaggio di
    `dispatch` mappa il numpad sulle lettere (mirror) e attiva le scansioni.
  - Esc esce dalla modalita' (`escapePops` o binding VK_ESCAPE esplicito).
- Vantaggi: zero conflitti di chord, nessuna perdita di alias, coerenza
  gestuale piena col movimento cursore, cursore fermo per tutta la modalita'.

## 5. Discrepanze rispetto al prompt allegato

- `CivVAccess_PlotSections.lua` non esiste: il file reale e'
  `CivVAccess_PlotSectionsCore.lua`, modulo globale `PlotSections`.
- `CivVAccess_InGameKeys.lua` non trovato nel repo.
- `SpeechPipeline.speak` non esiste: usare `speakInterrupt` / `speakQueued`.
- `ownerSpoken` non esiste: `ownerIdentity` ritorna `(spoken, token)`.
- `TXT_KEY_CIVVACCESS_OPEN_TERRAIN` non esiste ancora.
- I file lingua sono 11, non uno.
- Il prompt dice di aggiungere 8 binding "dentro BaselineHandler"; il
  pattern reale e' un modulo sibling con `getBindings()`.

## 6. Vincoli rispettati nel design

- Nessuna stringa inline: tutto via `Text.key` / `Text.format`.
- Nessun `tolk.speak` diretto: solo SpeechPipeline.
- Cursore in sola lettura: nessuna chiamata a `Cursor.move`.
- Gestione nil su `Map.PlotDirection` e su `IsRevealed` in ogni percorso.
- `pcall` + `Log.error` su ogni chiamata a API engine.
- Nessuna cache dello stato di gioco: rilettura a ogni step.
- Nessuna modifica a `src/proxy` o `src/engine`; GUID DLC invariato.

## 7. Rischi residui

- Valori numerici delle `DirectionTypes.*` non verificati (solo i nomi);
  irrilevante se si passano le costanti per nome.
- La scansione "Nord"/"Sud" composita richiede due direzioni interleaved
  per step: va definito l'ordine di vocalizzazione una volta scelto lo
  schema tasti.
- L'opzione C introduce un handler con stato sullo stack: va verificata la
  convivenza con `purgeDeadEnv` e con il pattern no-install-once.

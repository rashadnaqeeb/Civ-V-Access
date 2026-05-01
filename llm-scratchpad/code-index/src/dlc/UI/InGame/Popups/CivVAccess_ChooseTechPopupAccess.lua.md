# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseTechPopupAccess.lua`

206 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSETECH and BUTTONPOPUP_CHOOSE_TECH_TO_STEAL, presenting a flat tech list with mode-specific labels and an F6 shortcut to the full tech tree.

## Header comment

```
-- Choose-a-tech popup accessibility. Wraps the in-game TechPopup Context
-- (BUTTONPOPUP_CHOOSETECH for normal / free-tech picks, BUTTONPOPUP_CHOOSE_TECH_TO_STEAL
-- for espionage success) as a flat-list BaseMenu. Label shape and mode
-- filtering live in CivVAccess_ChooseTechLogic so offline tests can exercise
-- them without dofiling this install-side file.
--
-- Entry: Events.SerialEventGameMessagePopup filters by popupInfo.Type. On a
-- match we record the mode (normal / free / stealing) + stealing target,
-- then rebuild the items via setItems. The BaseMenu's default first-navigable
-- start lands the cursor on the first tech; the preamble fn reads live
-- science-per-turn and free/stealing context.
--
-- Commit: Network.SendResearch(techID, numFreeTechs, stealingTargetID, false).
-- Fourth arg is always false because this screen has no queue-append semantic
-- (only the TechTree's shift-click queues). After commit we speak a mode-
-- specific announcement and call ClosePopup() which is the base file's
-- ContextPtr:SetHide(true) + SerialEventGameMessagePopupProcessed call.
--
-- F6 escalates to the full tree via OpenTechTree() which is the base file's
-- close-then-refire-as-BUTTONPOPUP_TECH_TREE helper. The last item in the
-- list does the same thing so users without F6 muscle memory can find it by
-- arrowing to the bottom.
--
-- Currently-researching pin: in free / stealing modes the active research
-- continues while the player picks the free / stolen tech. We pin it as a
-- non-interactive Text item at the top of the list so the player hears
-- "currently researching X, N turns" before the Choice list. In normal mode
-- (the pick-next-research flow) the popup only opens when there's no current
-- research, so the pin is absent.
```

## Outline

- L53: `local priorInput = InputHandler`
- L54: `local priorShowHide = ShowHideHandler`
- L60: `local _mode = "normal"`
- L61: `local _stealingTargetID = -1`
- L63: `local function currentPlayer()`
- L69: `local function preambleFn()`
- L79: `local function commitCallback(techID)`
- L104: `local function choiceFromEntry(entry)`
- L118: `local function buildItems()`
- L156: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L170: `table.insert(mainHandler.bindings, { key = Keys.VK_F6, ... })`
- L179: `Events.SerialEventGameMessagePopup.Add(...)`

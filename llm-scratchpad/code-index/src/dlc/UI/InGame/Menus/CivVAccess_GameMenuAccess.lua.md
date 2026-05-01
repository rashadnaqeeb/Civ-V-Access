# `src/dlc/UI/InGame/Menus/CivVAccess_GameMenuAccess.lua`

378 lines · Accessibility handler for the in-game pause (Esc) menu, implemented as a three-tab BaseMenu (Actions, Details, Mods) with an inline ExitConfirm sub-handler.

## Header comment

```
-- GameMenu (Esc pause menu) accessibility. Three-tab BaseMenu.
--
-- ExitConfirm yes/no is an overlay inside this Context, not a separate
-- LuaContext -- clicking Main Menu toggles Controls.ExitConfirm visible
-- rather than queuing a new popup. We push a flat-list confirm sub on the
-- same Context (matches LoadMenu / InstalledPanel delete-confirm pattern),
-- and its tick watches ExitConfirm:IsHidden() to pop itself when any
-- other path (debug hot-reload, a future base-code edit we haven't
-- traced) dismisses the engine overlay out from under us.
--
-- Details labelFns re-query on every navigate so hotseat hand-offs show
-- the new active player's handicap without rebuilding the list. Victory
-- and game-option entries are session-fixed and use labelText.
--
-- showPanel drives MainContainer / DetailsPanel / ModsPanel to absolute
-- state (the base's OnGameDetails / OnGameMods are toggles rather than
-- setters) so the sighted view follows our tab.
```

## Outline

- L41: `local priorShowHide = OnShowHide`
- L42: `local priorInput = InputHandler`
- L44: `local DETAILS_TAB = 2`
- L45: `local MODS_TAB = 3`
- L49: `local function showPanel(active)`
- L55: `local function showMainContainer()`
- L58: `local function showDetailsPanel()`
- L61: `local function showModsPanel()`
- L67: `local function exitConfirmPrompt()`
- L79: `local function pushExitConfirmSub()`
- L133: `local function mainMenuActivate()`
- L142: `local function buildActionsItems()`
- L196: `local function leaderLabel()`
- L214: `local function civLabel()`
- L221: `local function eraLabel()`
- L232: `local function mapTypeLabel()`
- L244: `local function mapSizeLabel()`
- L252: `local function handicapLabel()`
- L260: `local function speedLabel()`
- L268: `local function buildDetailsItems()`
- L310: `local function buildModsItems()`
- L339: `local function wrappedShowHide(bIsHide, bIsInit)`
- L349: `BaseMenu.install(ContextPtr, { name = "GameMenu", tabs = { Actions, Details, Mods } })`

## Notes

- L79 `pushExitConfirmSub`: the sub's `tick` polls `Controls.ExitConfirm:IsHidden()` to self-pop when the overlay is dismissed by any path other than the Yes/No items, guarding against the overlay closing without our handler knowing.
- L133 `mainMenuActivate`: calls `OnMainMenu()` first (which makes `Controls.ExitConfirm` visible), then immediately pushes the confirm sub - the two must happen in this order so the sub's tick sees the overlay as visible.
- L339 `wrappedShowHide`: on hide, removes the ExitConfirm sub with `reactivate=false` so its focus-restoration speech doesn't fire mid-teardown.

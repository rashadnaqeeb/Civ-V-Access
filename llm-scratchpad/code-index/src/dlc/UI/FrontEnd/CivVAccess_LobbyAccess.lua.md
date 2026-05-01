# `src/dlc/UI/FrontEnd/CivVAccess_LobbyAccess.lua`

88 lines · Accessibility wiring for the Multiplayer Lobby server browser, using a two-tab PickerReader with a monkey-patched `SortAndDisplayListings` to refresh the server list on every add/remove/sort event.

## Header comment

```
-- Lobby accessibility wiring. Appended to the Lobby.lua override.
-- The same physical Lobby.{lua,xml} is instantiated from both the standard
-- Multiplayer flow and the ModMultiplayer flow [...]; we run identically in
-- both because the user-facing interactions are the same [...]
--
-- Structure: two-tab PickerReader.
--   Picker tab: one Entry per server in g_Listings [...], then a Sort-by Group
--     [...], then an optional Connect-to-IP textfield [...], then Refresh /
--     Host / Back shell Choices.
--   Reader tab: server header + per-player leaves + hosted-DLC detail +
--     Join action. [...]
--
-- Rebuild on list changes: the engine calls SortAndDisplayListings after
-- every AddServer / RemoveServer / Clear [...]
```

## Outline

- L32: `local priorShowHide = ShowHideHandler`
- L33: `local priorInput = InputHandler`
- L35: `local session = PickerReader.create()`
- L40: `local mainHandler`
- L41: `local function getHandler()`
- L49: `local baseSortAndDisplayListings = SortAndDisplayListings`
- L50: `SortAndDisplayListings = function(...)`
- L63: `local function titlePreamble()`
- L75: `local pickerItems = Lobby.buildPickerItems(session.Entry, getHandler)`
- L77: `mainHandler = session.install(ContextPtr, { ... })`

## Notes

- L50 `SortAndDisplayListings`: Monkey-patch of the base global; the preamble is also read dynamically from `Controls.TitleLabel` since its text varies by lobby mode (Internet/LAN/Pitboss/Mod).

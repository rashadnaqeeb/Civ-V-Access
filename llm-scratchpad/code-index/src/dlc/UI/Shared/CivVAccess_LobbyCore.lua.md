# `src/dlc/UI/Shared/CivVAccess_LobbyCore.lua`

318 lines · Multiplayer lobby data module providing picker and reader builders for server listings, with member-count normalization and sort column management.

## Header comment

```
-- Lobby data module. Two public fns:
--   Lobby.buildPickerItems(entryFactory, mainHandlerRef) - picker-tab items
--     for the current g_Listings (one Entry per server), followed by a
--     Sort-by Group over the five engine sort columns, an optional
--     Connect-to-IP textfield (pitboss-internet only), and shell-action
--     Choices for Refresh / Host / Back.
--   Lobby.buildReader(mainHandler, id) - reader-tab leaves for the server
--     identified by id: header fields, member list (one leaf per player),
--     hosted-DLC list, and a Join action.
-- [... design notes ...]
```

## Outline

- L22: `Lobby = {}`
- L29: `local function parseId(id)`
- L37: `local function findListingById(serverID)`
- L48: `local function parseMemberCounts(caption)`
- L61: `local function membersLabel(listing)`
- L72: `local function playerNames(listing)`
- L108: `local function addField(leaves, headerKey, value)`
- L119: `local function refreshChoiceLabel()`
- L136: `local function sortDirectionTooltip(option)`
- L151: `function Lobby.buildReader(mainHandler, id)`
- L210: `local function pickerLabel(listing)`
- L219: `function Lobby.buildPickerItems(entryFactory, mainHandlerRef)`
- L318: `return Lobby`

## Notes

- L72 `playerNames`: the `[NEWLINE]` token in MembersLabelToolTip is a literal bracketed string (not a control character); split uses plain-text `string.find(..., true)` to avoid bracket chars being interpreted as Lua pattern syntax. Also strips trailing `@<steamid>` from each name.
- L119 `refreshChoiceLabel`: reads Controls.RefreshButtonLabel live so the choice label reflects the current "Refresh" vs "Stop Refresh" toggle state without a full picker rebuild.

# `src/dlc/UI/Shared/CivVAccess_SavedGameShared.lua`

108 lines · Shared helpers for saved-game and replay header presentation, providing header field label keys, path stripping, id parsing, leader/civ resolution, and game-type labeling.

## Header comment

```
-- Shared helpers for saved-game / replay header presentation. Consumed by
-- LoadMenuCore, SaveMenuCore, and LoadReplayMenuCore. These all render a
-- picker of save files and a reader of header fields; the helpers track
-- the game's header schema (PlayerCivilization, LeaderName, CurrentEra,
-- WorldSize, Difficulty, GameSpeed, GameType) and its GameInfo lookup
-- conventions.
--
-- Extracted rather than duplicated so a schema or localization change lands
-- in one place. Dependencies: BaseMenuItems.Text (for addField) and Text.key
-- (for label resolution) -- consumers must include those first.
--
-- Consumers typically alias the exported functions to local names to keep
-- call sites terse: `local resolveLeaderCiv = SavedGameShared.resolveLeaderCiv`.
```

## Outline

- L15: `SavedGameShared = {}`
- L20: `SavedGameShared.HEADER_KEYS = {...}`
- L27: `function SavedGameShared.stripPath(filename)`
- L36: `function SavedGameShared.parseId(id)`
- L48: `function SavedGameShared.resolveLeaderCiv(header)`
- L71: `function SavedGameShared.gameTypeLabel(header)`
- L85: `function SavedGameShared.descOf(row)`
- L95: `function SavedGameShared.addField(leaves, headerKey, value)`
- L108: `return SavedGameShared`

## Notes

- L48 `SavedGameShared.resolveLeaderCiv`: header fields `LeaderName` and `CivilizationName` override the GameInfo lookup when present (hotseat / custom-name saves carry per-save player names).

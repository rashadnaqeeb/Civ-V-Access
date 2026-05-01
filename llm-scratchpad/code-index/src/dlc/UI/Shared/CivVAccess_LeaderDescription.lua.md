# `src/dlc/UI/Shared/CivVAccess_LeaderDescription.lua`

75 lines · Reads and speaks a prose portrait description for an AI leader, keyed by Leaders.Type, and binds an F2 shortcut to any BaseMenu handler.

## Header comment

```
-- Spoken leader descriptions. Civ V's diplo screens (LeaderHeadRoot,
-- DiscussionDialog, DiploTrade) show the AI leader in their animated
-- form; sighted players see the setting, dress, and symbolism; blind
-- players have no visual fallback. F2 on those screens calls
-- LeaderDescription.speakFor(iPlayer) to read a prose description of
-- the leader's portrait, keyed off Leaders.Type (Leaders table in
-- GameInfo). String entries live in CivVAccess_InGameStrings_en_US
-- under TXT_KEY_CIVVACCESS_LEADER_DESC_<LEADER_TYPE>.
```

## Outline

- L10: `LeaderDescription = {}`
- L12: `local function typeForPlayer(iPlayer)`
- L27: `function LeaderDescription.speakFor(iPlayer)`
- L54: `function LeaderDescription.bindF2(handler, getPlayerIdFn)`
- L75: `return LeaderDescription`

## Notes

- L54 `LeaderDescription.bindF2`: `getPlayerIdFn` is called at keypress time (not at bind time) to avoid caching game state across turns.

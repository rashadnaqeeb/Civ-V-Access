# `src/dlc/UI/Shared/CivVAccess_UserPrefs.lua`

150 lines · Cross-session user preference storage backed by `Modding.OpenUserData`, exposing typed get/set pairs (bool, int, float) that encode booleans as 0/1 integers.

## Header comment

```
-- Cross-session user preference storage backed by Modding.OpenUserData.
-- The engine persists key/value pairs in a per-user file outside of any
-- savegame. Writes are multiplayer-safe: user data is not part of the
-- save, the mod-hash handshake, or anything enumerated in the lobby; it
-- only shapes client-side behaviour.
--
-- Engine quirks this wrapper hides:
--   * modID is an arbitrary string (unregistered modIDs are accepted).
--   * Version must be a number; passing a string throws "bad argument #2".
--   * Handle is userdata with dot-access .GetValue / .SetValue.
--   * Number values roundtrip as-is. Boolean roundtripping is unverified,
--     so setBool encodes as 0/1 and getBool decodes with "nonzero means
--     true" so a default-shaped engine coercion can't silently flip a
--     saved setting.
--
-- Version is fixed at 1 and should only bump when we want to drop all
-- existing saved values (e.g., a breaking key-layout change). Bumping
-- silently orphans every prior row.
```

## Outline

- L20: `Prefs = Prefs or {}`
- L22: `local MOD_ID = "40a9df7b-ae9f-48db-abb5-44afe0420524"`
- L23: `local MOD_VERSION = 1`
- L25: `local _handle = nil`
- L26: `local _openAttempted = false`
- L28: `local function handle()`
- L54: `function Prefs.getBool(key, default)`
- L72: `function Prefs.setBool(key, v)`
- L86: `function Prefs.getInt(key, default)`
- L104: `function Prefs.setInt(key, v)`
- L121: `function Prefs.getFloat(key, default)`
- L139: `function Prefs.setFloat(key, v)`

## Notes

- L28 `handle`: lazy-opens the user-data store on first call and caches the handle; `_openAttempted` prevents repeated failed open attempts from logging repeatedly.
- L54 `Prefs.getBool`: decodes stored value as `v ~= 0` (not `v == true`) to tolerate engine integer coercion of persisted booleans.

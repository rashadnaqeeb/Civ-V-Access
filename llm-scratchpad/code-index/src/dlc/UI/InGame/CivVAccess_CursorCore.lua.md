# `src/dlc/UI/InGame/CivVAccess_CursorCore.lua`

437 lines · Free-roam hex cursor: owns (x, y) position and the owner-identity diff, drives all tile announcement (move, jump, coordinates, detail keys, city keys, activate, pedia) delegating composition to PlotComposers/CitySpeech/UnitSpeech.

## Header comment

```
-- Free-roam tile cursor for blind players. Holds (x, y) -- never the live
-- plot userdata, since plot handles can outlive their freshness across
-- engine ticks; we re-resolve via Map.GetPlot at every operation. Owns the
-- owner-prefix diff (last spoken identity); composers handle everything
-- else. Keeps no other state cached -- the project rule says "the only
-- acceptable cache is a live engine handle read at speech time."
```

## Outline

- L8: `Cursor = {}`
- L10: `local _x, _y = nil, nil`
- L20: `local _lastOwnerIdentity = nil`
- L22: `local function plotHere()`
- L27: `local function setCursor(plot)`
- L42: `local function capitalPlot()`
- L58: `function Cursor.init()`
- L92: `local function targetabilityPrefix(plot)`
- L154: `local function announceForMove(plot)`
- L220: `local function withCoords(plot, glance)`
- L245: `function Cursor.move(direction)`
- L276: `function Cursor.coordinates()`
- L288: `function Cursor.position()`
- L299: `function Cursor.jumpTo(x, y)`
- L325: `local function delegateDetail(composer)`
- L333: `function Cursor.economy()`
- L336: `function Cursor.combat()`
- L347: `local function topUnitAt(plot)`
- L371: `function Cursor.unitAtTile()`
- L384: `local function delegateCity(speechFn)`
- L396: `function Cursor.cityIdentity()`
- L399: `function Cursor.cityDevelopment()`
- L402: `function Cursor.cityPolitics()`
- L411: `function Cursor.activate()`
- L423: `function Cursor.pedia()`
- L432: `function Cursor._reset()`

## Notes

- L20 `_lastOwnerIdentity`: Not a cache of game state - it holds what the user last heard, which is explicitly required for the owner-prefix diff feature to work; see the block comment.
- L92 `targetabilityPrefix`: Fires on every cursor move while a ranged interface mode is active (no diff suppression), prepending "out of range" or "unseen" before the tile glance.
- L347 `topUnitAt`: Filters IsCargo and DOMAIN_AIR to avoid surfacing cargo units on the S key, unlike CursorActivate which intentionally includes them.

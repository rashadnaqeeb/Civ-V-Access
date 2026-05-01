# `src/dlc/UI/InGame/CivVAccess_CursorActivate.lua`

171 lines · Implements Enter-on-hex-cursor: collects the plot's actionable things (city, active-player military then civilian units), auto-dispatches on a single result, or presents a BaseMenu picker.

## Header comment

```
-- Enter on the hex cursor. Builds the list of things on the plot the user
-- can act on (city, active-player units split military-first) and either
-- dispatches the single entry directly, or pops a BaseMenu.create modal
-- so the user can pick which one. Entries in order: city first, military
-- units next, civilian units last. Units are filtered by owner == active
-- player (you can't select someone else's unit) and IsInvisible.
-- Air units are listed including aircraft loaded onto a carrier
-- (IsCargo). UnitFlagManager's carrier and city dropdowns surface those
-- to sighted players via the same UI.SelectUnit path; we mirror that so
-- a blind player can step the cursor onto a carrier (or air-stocked
-- city) and pick a fighter to command. Vanilla / BNW have no non-air
-- cargo (Carrier, Missile Cruiser, Nuclear Submarine all carry
-- DOMAIN_AIR), so dropping the IsCargo gate has no spurious surface.
--
-- The city entry's action mirrors vanilla's CityBannerManager OnBannerClick
-- fork and matches what Cursor.activate used to do inline: own city opens
-- the city screen (annex popup first if the city is a puppet and the
-- player may annex), a met minor opens the read-only city screen, a met
-- major opens diplomacy (or the deal screen for human opponents) with
-- the same turn-active guard LeaderSelected uses, and unmet foreigners
-- silent no-op. The unit action is just UI.SelectUnit.
```

## Outline

- L23: `CursorActivate = {}`
- L25: `local function collectSelfUnits(plot)`
- L44: `local function activateCity(plot)`
- L85: `local function buildEntries(plot)`
- L130: `function CursorActivate.run(plot)`
- L170: `CursorActivate._buildEntries = buildEntries`

## Notes

- L25 `collectSelfUnits`: Does NOT filter IsCargo, so cargo air units on a carrier tile are included - intentional to match UnitFlagManager's carrier dropdown behavior.

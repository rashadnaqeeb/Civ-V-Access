# `src/dlc/UI/InGame/CivVAccess_CitySpeech.lua`

421 lines · Pure formatters that turn a city handle into spoken strings for the three cursor number keys (1 identity, 2 development, 3 politics) and city ranged-strike previews.

## Header comment

```
-- Pure formatters that turn a city handle into speech for the three
-- cursor number keys (1 identity + combat, 2 development, 3 politics).
-- No event registration, no listeners, no state -- every call re-reads
-- the city so stale speech can't leak through a cached format.
--
-- Output shape deliberately mirrors what a sighted player sees on the
-- BNW CityBannerManager for the relevant ownership tier: met cities
-- expose identity and combat fields unconditionally, team banners add
-- production / growth / garrison, warmonger and liberation previews
-- piggy-back on the engine's own preview strings (spoken in full so
-- the player can audit consequences before attacking). Unmet cities
-- stop at the one-word "unmet" token, matching the banner tooltip.
```

## Outline

- L14: `CitySpeech = {}`
- L16: `local function activePlayerId()`
- L20: `local function activeTeamId()`
- L24: `local function isTeam(city)`
- L28: `local function isOwn(city)`
- L32: `local function isMet(city)`
- L38: `local TRAIT_TOKEN = {...}`
- L47: `local function cityStateTraitKey(player)`
- L65: `local function friendshipTierKey(city)`
- L91: `function CitySpeech.statusTokens(city)`
- L118: `function CitySpeech.connectedToken(city)`
- L127: `function CitySpeech.growthToken(city)`
- L143: `function CitySpeech.productionToken(city)`
- L163: `local function cityHpColorKey(city)`
- L179: `local function garrisonToken(city)`
- L193: `function CitySpeech.identity(city)`
- L258: `function CitySpeech.development(city)`
- L326: `function CitySpeech.politics(city)`
- L399: `function CitySpeech.rangedPreview(city, defenderUnit, defenderCity)`

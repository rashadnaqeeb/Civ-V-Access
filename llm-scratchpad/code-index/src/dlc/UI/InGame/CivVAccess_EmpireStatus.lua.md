# `src/dlc/UI/InGame/CivVAccess_EmpireStatus.lua`

1018 lines · Empire-status readouts for T/R/G/H/F/P/I (bare headline) and Shift+R/G/H/F/P/I (detail breakdown mirroring TopPanel tooltip segments), plus test seams for every formatter.

## Header comment

```
-- Empire-status readouts. Bare T/R/G/H/F/P/I speak one-line headlines drawn
-- from the engine's TopPanel readouts plus adjacent surfaces (TechPanel for
-- active research, CultureOverview for the influential-civ count). Shift +
-- R/G/H/F/P/I read the additive content of the corresponding TopPanel
-- tooltip, skipping segments the bare key already covered. Shift+T is
-- intentionally absent: the bare T already speaks the Maya long-form date,
-- which is the only thing CurrentDate's tooltip would have added.
-- [...]
-- All readouts honour the engine's "off" game options (NO_SCIENCE,
-- NO_HAPPINESS, NO_RELIGION, NO_POLICIES). Each function is a pure formatter
-- that re-queries the engine on every call - no caching, per project rule.
```

## Outline

- L46: `EmpireStatus = {}`
- L48: `local MOD_NONE = 0`
- L49: `local MOD_SHIFT = 1`
- L53: `local LABEL_HELP = "TXT_KEY_HELP"`
- L54: `local LABEL_INCOME = "TXT_KEY_EO_INCOME"`
- L55: `local LABEL_GOLDEN_AGE = "TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"`
- L56: `local LABEL_RELIGIONS = "TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"`
- L57: `local LABEL_GREAT_PEOPLE = "TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"`
- L58: `local LABEL_INFLUENCE = "TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"`
- L60: `local function speak(s)`
- L69: `local function joinClauses(...)`
- L84: `local function supplyClause(player)`
- L99: `local function shortageClause(player)`
- L124: `local function turnLine()`
- L151: `local function researchLine()`
- L179: `local function goldLine()`
- L194: `local function goldenAgeClause(player)`
- L211: `local function luxuryInventoryClause(player)`
- L226: `local function happinessLine()`
- L243: `local function faithLine()`
- L255: `local function policyLine()`
- L287: `local function influentialStats(player, activeID)`
- L303: `local function tourismLine()`
- L325: `local function newDetail()`
- L374: `local function noBasicHelp()`
- L379: `local function anarchyPrefix(player)`
- L389: `local function researchDetail()`
- L438: `local function goldDetail()`
- L508: `local function happinessResourceItems(player, resourcesHappiness, extraLuxuryHappiness)`
- L543: `local function goldenAgeDetailSegments(player, d)`
- L576: `local function happinessDetail()`
- L711: `local function faithDetail()`
- L791: `local function policyDetail()`
- L866: `local function tourismDetail()`
- L897: `local bind = HandlerStack.bind`
- L899: `function EmpireStatus.getBindings()`
- L1005: `EmpireStatus._turnLine = turnLine`
- L1006: `EmpireStatus._researchLine = researchLine`
- L1007: `EmpireStatus._goldLine = goldLine`
- L1008: `EmpireStatus._happinessLine = happinessLine`
- L1009: `EmpireStatus._faithLine = faithLine`
- L1010: `EmpireStatus._policyLine = policyLine`
- L1011: `EmpireStatus._tourismLine = tourismLine`
- L1012: `EmpireStatus._researchDetail = researchDetail`
- L1013: `EmpireStatus._goldDetail = goldDetail`
- L1014: `EmpireStatus._happinessDetail = happinessDetail`
- L1015: `EmpireStatus._faithDetail = faithDetail`
- L1016: `EmpireStatus._policyDetail = policyDetail`
- L1017: `EmpireStatus._tourismDetail = tourismDetail`

## Notes

- L325 `newDetail`: Returns a builder object with section()/add()/compose() methods; sections are separated by ". " and items within a section by ", " in the final spoken string.
- L543 `goldenAgeDetailSegments`: Called from inside happinessDetail to extend H's Shift-readout with golden-age breakdown; not a standalone detail function.

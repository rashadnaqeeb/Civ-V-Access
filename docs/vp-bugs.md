# Vox Populi bugs

A running log of bugs we hit in Vox Populi's own code and data while building
and playtesting the accessibility layer. These are defects in VP / Community
Patch itself, not in our mod: each one affects sighted plain-VP players too.
We record them here as candidates for a possible upstream pull request to the
Community Patch Project (LoneGazebo/Community-Patch-DLL).

Scope note. This is about fixing VP's own bugs. It is separate from our engine
fork's added Lua bindings, which we have deliberately chosen not to upstream
(see `.planning/vp-port.md`). A bug-fix PR carries no such decision and would
benefit everyone on plain VP.

How to use this file. Add an entry the moment a VP-side bug is identified, even
before it is fully diagnosed. Keep each entry self-contained: someone preparing
the PR should be able to write the patch from the entry alone. Mark whether the
bug is confirmed (root-caused, with an exact location) or suspected (observed,
needs repro). Pin upstream file paths and line numbers to the supported VP
release in `versions.json` and note that they drift across releases.

Pin at time of writing: Release-5.3.2 (`supported_vp` in `versions.json`).

## Entry format

- Title, one line.
- Location: upstream file and line, plus the function or section.
- Symptom: what the player observes.
- Root cause: why it happens.
- Suggested fix: the smallest correct change.
- Affects: who is hit (sighted too?), and severity.
- Status: confirmed or suspected; how we found it.

## Confirmed

### Civilopedia promotion article crashes on a null combat modifier

- Location: `(2) Vox Populi/Core Files/Overrides/CivilopediaScreen.lua`, the
  "Combat Mods" loop in the promotion-article builder. The query is at line
  3695; the failing statement is the next line, 3696.
- Symptom: opening certain unit-promotion articles in the Civilopedia produces
  an empty article. A Lua error is raised: `bad argument #2 to 'format'
  (number expected, got nil)`.
- Root cause: the loop iterates `UnitPromotions_UnitCombatMods` joined to
  `UnitCombatInfos` and formats each row's `Modifier` with `string.format("%+d",
  row.Modifier)` without a nil guard. For at least one VP promotion that row's
  `Modifier` is NULL in the database, so `row.Modifier` is nil and `%+d` (which
  requires a number) errors. The build of the whole article text happens in one
  pass, so the error aborts it and the article never renders. The sibling
  "Classes" loop immediately above (lines 3687-3692) guards every field with
  `if row.Modifier ~= nil then ...`; this loop does not. The vanilla database
  always populated the column, so the missing guard never bit before VP.
- Suggested fix: either guard the format like the sibling loop does, or fix the
  underlying data row (a `UnitPromotions_UnitCombatMods` entry with a NULL
  `Modifier` is itself the defect; the offending promotion should set a value
  or drop the row). The code guard is the robust fix and matches the adjacent
  style:

  ```
  for row in DB.Query("... UnitPromotions_UnitCombatMods ...") do
      if row.Modifier ~= nil then
          sText = sText .. "[NEWLINE][ICON_BULLET]"
              .. string.format("%+d", row.Modifier) .. "% strength against ..."
      end
  end
  ```
- Affects: everyone on plain VP (this is VP's own pedia file). The article is
  unreadable until fixed. Narrow: only the promotion(s) with the null modifier.
  No crash beyond the article; our pedia wrapper catches the error and logs it,
  so navigation survives.
- Status: confirmed 2026-06-17. Hit in a playtest log as
  `Civilopedia SelectArticle(5, 360) failed` (category 5 = promotions). Code
  read directly against the Release-5.3.2 clone. The specific promotion behind
  article index 360 is not yet identified; finding it would let us patch the
  data row instead of (or in addition to) the code.

### Player-set trade unit names are dropped across a route's lifecycle

- Location: `CvGameCoreDLL_Expansion2/CvUnit.cpp` (the makeTradeRoute path,
  around line 9170) and three spots in
  `CvGameCoreDLL_Expansion2/CvTradeClasses.cpp`: establish
  (`CvPlayerTrade::CreateTradeRoute`, around line 4465), route-completion
  rebirth (around lines 2667-2688), and the force-cancel path (the helper near
  line 37, used when a route is killed by a destination city being captured,
  war being declared, or a city-state resetting).
- Symptom: rename a Caravan or Cargo Ship, then send it on a trade route. The
  custom name is lost the instant the route is established, again every time the
  route completes a trip, and again if the route is force-cancelled.
- Root cause: none of these three lifecycle transitions reuses the renamed
  unit. Each spawns a fresh trade unit (the engine `kill`s the old one and
  `initUnit`s a new one) without copying the player-set name.
- Suggested fix: at each transition, capture the old unit's `getNameNoDesc()`
  before it is killed and `setName` it on the replacement. This is exactly what
  our fork already does (branch `civvaccess`, commit 77a110855 "Carry
  player-set trade unit names across route lifecycle"), marked with
  `CIVVACCESS:` comments at all the sites above, so the PR patch already exists.
- Affects: everyone. Cosmetic but persistent; custom unit names are a real
  organizational tool, and the loss is silent. Likely inherited from base BNW
  rather than VP-introduced, but CP/VP is still the right place to land the fix.
- Status: confirmed and fixed in our fork 2026-06-17. The strongest PR
  candidate since the implementation is done and proven in play.

### Vassal Overview shows the active player's ideology, not the viewed civ's

- Location: `(2) Vox Populi/Core Files/New UI/VassalageOverview.lua:595`.
- Symptom: the per-civ stats panel reports the wrong ideology for the civ being
  viewed, showing yours instead.
- Root cause: the whole stats block reads the displayed civ via the local
  `pPlayer` (happiness, gold, culture, tourism all use it), but the ideology
  line alone uses `g_pPlayer:GetLateGamePolicyTree()`. `g_pPlayer` is the active
  player (defined at line 15 as `Players[Game.GetActivePlayer()]`).
- Suggested fix: read `pPlayer:GetLateGamePolicyTree()`, matching every other
  stat in the block.
- Affects: sighted players too. Wrong data on the overview.
- Status: confirmed 2026-06-17, read directly against the Release-5.3.2 clone.

### Vassal Overview passes a player id to canEndVassal, which takes a team id

- Location: `(2) Vox Populi/Core Files/New UI/VassalageOverview.lua:417`:
  `pVassalTeam:CanEndVassal(g_iPlayer)`.
- Symptom: the master's "can this vassal declare independence" line can read
  wrong wherever a player id and team id diverge (team games, and any case where
  the active player's id is not equal to its team id).
- Root cause: `CvTeam::canEndVassal(TeamTypes eIndex)` takes a team id
  (confirmed in `Lua/CvLuaTeam.cpp:1476`). The two other call sites in the same
  file (lines 284, 295) correctly pass `iMasterTeam`; this one passes
  `g_iPlayer`, a player id.
- Suggested fix: pass the active player's team (`g_pPlayer:GetTeam()`) instead
  of `g_iPlayer`.
- Affects: sighted players too; latent in single player where the ids coincide.
- Status: confirmed 2026-06-17.

### Antiquity overlay reveals dig sites before the team has Archaeology

- Location: `(2) Vox Populi/Core Files/New UI/OverlayAntiquities.lua:66` (and
  the matching draw at line 136).
- Symptom: the antiquities map overlay shows regular archaeological dig sites on
  revealed tiles even before the player's team has researched Archaeology,
  giving sighted players information they should not have yet.
- Root cause: the overlay tests `pPlot:GetResourceType() == iSiteDig` with no
  team argument. The no-arg form returns the resource unconditionally; the
  team-aware form (`GetResourceType(team)`) returns it only once that team can
  see it (the resource's reveal tech, Archaeology for `RESOURCE_ARTIFACTS`). The
  hidden-artifact branch right below (line 71) at least gates on the
  Exploration/Artistry finisher policy, but the regular dig-site branch has no
  such gate.
- Suggested fix: pass the active team to `GetResourceType` for the regular
  dig-site test (and the draw at 136), matching how the rest of the game gates
  resource visibility.
- Affects: sighted players (early dig-site knowledge). Our own scanner already
  passes the team and is not affected.
- Status: confirmed 2026-06-17.

### Misspelled instant-yield text key shows a raw key

- Location: tag defined as `TXT_KEY_INSTANT_YIELD_TYPE_RESEARCH_AGREMEENT_SHORT`
  in `(1) Community Patch/Database Changes/Text/en_US/Notifications/CoreNewNotificationText.xml:721`.
- Symptom: the research-agreement row in the instant-yield notification options
  shows/speaks the raw key text instead of a label.
- Root cause: a spelling mismatch. The enum is correctly spelled
  `INSTANT_YIELD_TYPE_RESEARCH_AGREEMENT` (`CvEnums.h:3624`, and every C++ use),
  and the options UI builds the lookup key from the enum name, producing
  `..._RESEARCH_AGREEMENT_SHORT`. But the only text definition is the misspelled
  `..._AGREMEENT_SHORT` ("AGREMEENT"), so the lookup misses. (The `LuaCATS`
  annotation stub repeats the typo but is non-functional.)
- Suggested fix: rename the text tag to `..._RESEARCH_AGREEMENT_SHORT`. One
  token.
- Affects: sighted players too (raw key in the options list).
- Status: confirmed 2026-06-17.

### City-State Allies/Friends tooltip omits the per-turn influence change

- Location: `(2) Vox Populi/LUA/CityStateStatusHelper.lua:263` (Allies) and
  `:272` (Friends), inside `GetCityStateStatusToolTip`. The base BNW copy has
  the same omission at
  `Assets/DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:241` / `:250`.
- Symptom: for an Allied or Friendly city-state, the status tooltip's "Each
  turn, your Influence with them will change by ." sentence is missing its
  number. `Localization.log` records `ERR: Missing argument 2` against
  `TXT_KEY_ALLIES_CSTATE_TT` / `TXT_KEY_FRIENDS_CSTATE_TT` (260 hits in one
  playtest session).
- Root cause: the helper computes `iInfluenceChangeThisTurn` (line 252) and
  then calls `Locale.ConvertTextKey("TXT_KEY_ALLIES_CSTATE_TT", strShortDescKey)`
  with only the city-state name. The text has two placeholders,
  `{1_CityStateName}` and `{2_Num}`; the second is never supplied, so it renders
  empty. The `{2_Num}` placeholder is base BNW text (VP only appended the
  Pledge-of-Protection sentence), and the base helper drops it the same way, so
  this is inherited from base rather than VP-introduced. CP/VP is still the
  right place to land the fix.
- Suggested fix: pass the computed value,
  `Locale.ConvertTextKey("TXT_KEY_ALLIES_CSTATE_TT", strShortDescKey, iInfluenceChangeThisTurn)`,
  and the same for the Friends branch.
- Affects: sighted players too (blank number in the tooltip). It reaches our
  speech where we read `GetCityStateStatusToolTip` (the city-state diplo and
  greeting popups); our own F4 Minors Influence column computes the per-turn
  rate independently, so the number is not lost there.
- Status: confirmed 2026-06-17, from a playtest `Localization.log` plus the
  helper read against the Release-5.3.2 clone and the base BNW copy.

### Global Politics "at war with" line omits the war score

- Location: `(1) Community Patch/Core Files/Overrides/DiploGlobalRelationships.lua:167`,
  the third-party war loop.
- Symptom: on the Diplomatic Overview's Global Politics panel, a civ's "At war
  with X (Warscore: )" entry is missing its war-score number.
  `Localization.log` records `ERR: Missing argument 2` against
  `TXT_KEY_AT_WAR_WITH` (9 hits in one playtest session).
- Root cause: CP/VP redefines `TXT_KEY_AT_WAR_WITH` from vanilla's
  `At war with {1_enemy}` to `At war with {1_enemy} (Warscore: {2_Num})`
  (`(2) Vox Populi/Database Changes/Text/en_US/UI/UITextChanges.sql`), but the
  panel still calls `LocalizeAndSetText("TXT_KEY_AT_WAR_WITH", thirdName)` with
  only the enemy name. The text gained an argument the caller was never updated
  to pass, so this is a VP-introduced regression.
- Suggested fix: pass the war score as the second argument, e.g.
  `LocalizeAndSetText("TXT_KEY_AT_WAR_WITH", thirdName, pOtherPlayer:GetWarScore(iThirdPlayer))`.
- Affects: sighted players too (blank war score). We already fixed our own
  equivalent read in the F4 overview (the EngineData seam's `warScore` intent),
  so our speech states the value.
- Status: confirmed 2026-06-17, from the same playtest log; code read against
  the Release-5.3.2 clone.

## Investigated, not a bug

Kept here so these are not re-chased.

### Localization "Missing argument" log lines are benign

- Observation: `Localization.log` records `ERR: Missing argument N` for the
  militaristic city-state gift tooltip (`TXT_KEY_CITY_STATE_MILITARISTIC_TT`,
  `{@1_UniqueUnitName}` / `{@2_PrereqTech}`), a `{1_Num} from Wars` line, and a
  `{2_Sign}{1_Num} [ICON_HAPPINESS_1] Happiness in all Cities` line.
- Verdict (2026-06-17): not defects. The militaristic tooltip is rendered
  correctly: `GetCityStateTraitToolTip` in
  `(2) Vox Populi/LUA/CityStateStatusHelper.lua` uses a separate no-argument key
  (`TXT_KEY_CITY_STATE_MILITARISTIC_NO_UU_TT`) for city-states without a unique
  unit, and only renders the arg-bearing string inside the
  `IsMinorCivHasUniqueUnit()` guard, always passing both arguments. The
  `{@N_...}` form is a gender-resolution reference that logs while the visible
  text still substitutes. The other two are short breakdown fragments
  (`{1_Num} from Wars`, the happiness modifier line) assembled into larger
  tooltips with their numbers supplied at render; a standalone/preview format
  pass logs the missing arg without any player-visible defect. None leak into
  our speech (no raw placeholder in any `Speech(` line).

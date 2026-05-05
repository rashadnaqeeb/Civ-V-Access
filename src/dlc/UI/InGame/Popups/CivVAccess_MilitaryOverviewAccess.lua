-- MilitaryOverview accessibility (F3). Wraps the engine popup as a
-- two-tab TabbedShell with the supply readout served as the shell's
-- preamble (spoken between the screen title and the active tab name on
-- every open and on F1):
--
--   Units         BaseTable. One row per owned unit. Columns: Distance,
--                 Status, Moves left, Max moves, Strength, Ranged. The
--                 unit name lives on the row label rather than in a
--                 column so the user hears it once on row change instead
--                 of repeating it in a Name cell.
--
--                 Distance is the leftmost column and uses the same
--                 HexGeom formatter as the scanner ("3e", "2nw, 1ne");
--                 sortKey is the cube-distance so ascending sort puts
--                 nearest first. On the cursor's own hex the cell speaks
--                 SCANNER_HERE.
--
--                 Default row order mirrors the engine's stack layout:
--                 military first, civilian second, alphabetical within
--                 each group. Selecting a row activates the unit (engine
--                 click semantics: re-center if already selected, else
--                 select), closes the popup, and -- only when the
--                 cursor-follows-selection setting is OFF -- jumps the
--                 hex cursor onto the unit's plot. With the setting ON,
--                 UnitControlSelection's own Cursor.jumpTo (fired off
--                 SerialEventUnitSelectionChanged) handles the move so
--                 a second jump here would warp twice.
--
--   Great People  BaseMenu. Order: Great General first, Great Admiral
--                 second (flat rows, player-scoped), then specialist
--                 subgroups in decision-priority order (Scientist,
--                 Engineer, Merchant), then the cultural specialists
--                 (Writer / Artist / Musician) in DB order. Each
--                 specialist subgroup holds per-city progress rows
--                 sorted by turns ascending; subgroups are skipped when
--                 no city has any progress for that type, mirroring
--                 GPList's section-hiding. Great Prophet is omitted --
--                 prophet progress is faith-gated, not GPP-gated, and
--                 lives on the Religion Overview screen.
--
-- Promotion availability rides on the row label so the user hears it
-- first when entering a row, regardless of which column they navigate
-- to.
--
-- Cross-Context concerns: the Popups Context is sandboxed separately
-- from the InGame Context Boot owns. HexGeom is included in this
-- wrapper directly (no PopupBoot inclusion); Cursor lives in the
-- WorldView Context only and is reached through
-- civvaccess_shared.modules.Cursor for both position queries and the
-- explicit cursor jump on row activation.

include("CivVAccess_PopupBoot")
include("CivVAccess_TabbedShell")
include("CivVAccess_BaseTableCore")
include("CivVAccess_HexGeom")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Forward-declared so the activate closure can call it before OnClose
-- (which we reach via the global the engine file defines) is evaluated
-- in the closure scope.
local activateUnit

-- ===== Cell formatters ================================================

-- MovesLeft / MaxMoves are 60ths; flooring would lose road / railroad
-- remainders ("1.5" for a 90/60 unit). Round to two decimal places to
-- absorb floating-point noise, then build the string from integer parts
-- so the decimal separator stays "." regardless of LC_NUMERIC. Mirrors
-- UnitSpeech.formatMoves; kept local to avoid a Context-wide include
-- just for one helper.
local function formatMoves(sixtieths)
    local hundredths = math.floor(sixtieths * 100 / GameDefines["MOVE_DENOMINATOR"] + 0.5)
    local whole = math.floor(hundredths / 100)
    local frac = hundredths - whole * 100
    if frac == 0 then
        return tostring(whole)
    end
    if frac % 10 == 0 then
        return tostring(whole) .. "." .. tostring(frac / 10)
    end
    return tostring(whole) .. "." .. tostring(frac)
end

-- Localized status text for a unit. Mirrors the engine's priority
-- cascade in BuildUnitList. Falls through to MO_STATUS_IDLE
-- ("awaiting orders") when the engine would have hidden the status
-- column -- a unit with no fortify / sleep / sentry / heal / build /
-- automation state. The engine simply omits the cell visually; in
-- speech an empty string would leave the user wondering whether the
-- screen reader cut off, so we say the idle case explicitly.
local function unitStatusText(unit)
    if unit:IsEmbarked() then
        return Text.key("TXT_KEY_UNIT_STATUS_EMBARKED")
    end
    if unit:IsGarrisoned() then
        return Text.key("TXT_KEY_MISSION_GARRISON")
    end
    if unit:IsAutomated() then
        if unit:IsWork() then
            return Text.key("TXT_KEY_ACTION_AUTOMATE_BUILD")
        end
        return Text.key("TXT_KEY_ACTION_AUTOMATE_EXPLORE")
    end
    local activityType = unit:GetActivityType()
    if activityType == ActivityTypes.ACTIVITY_HEAL then
        return Text.key("TXT_KEY_MISSION_HEAL")
    end
    if activityType == ActivityTypes.ACTIVITY_SENTRY then
        return Text.key("TXT_KEY_MISSION_ALERT")
    end
    if unit:GetFortifyTurns() > 0 then
        return Text.key("TXT_KEY_UNIT_STATUS_FORTIFIED")
    end
    if activityType == ActivityTypes.ACTIVITY_SLEEP then
        return Text.key("TXT_KEY_MISSION_SLEEP")
    end
    local buildType = unit:GetBuildType()
    if buildType ~= -1 then
        local build = GameInfo.Builds[buildType]
        local str = Text.key(build.Description)
        local turnsLeft = unit:GetPlot():GetBuildTurnsLeft(buildType, Game.GetActivePlayer(), 0, 0)
        if turnsLeft < 4000 and turnsLeft > 0 then
            str = str .. " (" .. tostring(turnsLeft) .. ")"
        end
        return str
    end
    return Text.key("TXT_KEY_CIVVACCESS_MO_STATUS_IDLE")
end

-- displayName uses the no-civ form -- the list is the active player's
-- own units, so a "Roman" prefix on every row would just be noise.
-- Named units (rename via Alt+N, plus great-general name-pool entries)
-- wrap the type in parens after the personal name to match
-- UnitSpeech.unitName's shape elsewhere in the mod.
local function unitDisplayName(unit)
    local typeName = Text.key(unit:GetNameKey())
    if unit:HasName() then
        local personal = Text.key(unit:GetNameNoDesc())
        if typeName == "" then
            return personal
        end
        return personal .. " (" .. typeName .. ")"
    end
    return typeName
end

local function unitPediaName(unit)
    local info = GameInfo.Units[unit:GetUnitType()]
    if info == nil then
        return nil
    end
    return Text.key(info.Description)
end

local function isMilitary(unit)
    return unit:GetUnitCombatType() ~= -1 or unit:CanNuke()
end

-- Cursor module accessor. Cursor lives in the WorldView Context only;
-- the Popups Context reaches it through the cross-Context module
-- registry that Boot publishes (CLAUDE.md: civvaccess_shared.modules
-- holds the published refs). Returns nil during the brief pre-Boot
-- window where the registry isn't populated yet (the popup can't open
-- before in-game boot, so this is purely defensive).
local function cursorModule()
    return civvaccess_shared.modules and civvaccess_shared.modules.Cursor
end

-- Live cursor query with a (0, 0) fallback. The popup only opens
-- in-game so the registry should always be populated; the fallback
-- matches ScannerNav's pattern and keeps the distance column readable
-- if something goes wrong upstream.
local function cursorXY()
    local Cursor = cursorModule()
    if Cursor == nil then
        Log.warn("MilitaryOverview: Cursor module not published; using (0, 0) as distance origin")
        return 0, 0
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        Log.warn("MilitaryOverview: cursor not initialised; using (0, 0) as distance origin")
        return 0, 0
    end
    return cx, cy
end

-- Strength / ranged cells render the integer or "0" -- the engine uses
-- "-" in the visual UI but a screen reader announces that as "dash"
-- which reads as a deletion glyph rather than "no combat strength".
local function combatNumberCell(n)
    return tostring(n)
end

-- ===== Row label ======================================================

-- The row label is what BaseTable speaks when the cursor enters a new
-- row. Promotion availability rides here so the user hears it once per
-- row regardless of which column they navigate to, matching the engine
-- panel's row-anchored promotion indicator.
local function unitRowLabel(unit)
    local name = unitDisplayName(unit)
    if unit:CanPromote() then
        return name .. ", " .. Text.key("TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE")
    end
    return name
end

-- ===== Default row order ==============================================

-- Military first, civilian second, alphabetical within each group.
-- Mirrors the engine's two-stack layout (MilitaryStack above,
-- CivilianSeparator, CivilianStack below) under the default eName sort.
-- BaseTable preserves rebuildRows order when no sort column is active;
-- once the user picks a sort column the table sorts globally and the
-- two groups merge, which is the standard mod-wide BaseTable behavior
-- and consistent with EO Resources' strategic-then-luxury default.
local function rebuildUnitRows()
    local p = Players[Game.GetActivePlayer()]
    if p == nil then
        return {}
    end
    local rows = {}
    for unit in p:Units() do
        rows[#rows + 1] = unit
    end
    table.sort(rows, function(a, b)
        local aMil = isMilitary(a)
        local bMil = isMilitary(b)
        if aMil ~= bMil then
            return aMil
        end
        return Locale.Compare(unitDisplayName(a), unitDisplayName(b)) == -1
    end)
    return rows
end

-- ===== Activation =====================================================

-- Click semantics mirror the engine's UnitClicked: same unit already
-- selected re-centers the camera; otherwise select. Then close the
-- popup. The cursor jump only fires when the cursor-follows-selection
-- setting is OFF; with it ON, UnitControlSelection's
-- SerialEventUnitSelectionChanged listener already runs Cursor.jumpTo
-- on the selection event, so a second jump here would warp twice.
-- Direct Cursor.jumpTo (rather than CameraTracker.followAndJumpCursor)
-- because UI.SelectUnit doesn't reliably pan the camera, leaving the
-- camera-follow path with nothing to settle on; we know the
-- destination plot, so jump explicitly. Discard the glance return so
-- we don't double-speak: UnitControlSelection's listener already spoke
-- the unit selection text by the time we're back here.
function activateUnit(unit)
    local head = UI:GetHeadSelectedUnit()
    if head ~= nil and head:GetID() == unit:GetID() then
        UI.LookAtSelectionPlot(0)
    else
        UI.SelectUnit(unit)
    end
    OnClose()
    if not civvaccess_shared.cursorFollowsSelection then
        local Cursor = cursorModule()
        if Cursor ~= nil then
            Cursor.jumpTo(unit:GetX(), unit:GetY())
        end
    end
end

-- ===== Units tab ======================================================

local function buildUnitColumns()
    local function distanceCell(unit)
        local cx, cy = cursorXY()
        local ux, uy = unit:GetX(), unit:GetY()
        if cx == ux and cy == uy then
            return Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
        end
        return HexGeom.directionString(cx, cy, ux, uy)
    end
    local function distanceSort(unit)
        local cx, cy = cursorXY()
        return HexGeom.cubeDistance(cx, cy, unit:GetX(), unit:GetY())
    end
    return {
        {
            name = "TXT_KEY_CIVVACCESS_MO_COL_DISTANCE",
            getCell = distanceCell,
            sortKey = distanceSort,
            enterAction = activateUnit,
            pediaName = unitPediaName,
        },
        {
            name = "TXT_KEY_STATUS",
            getCell = unitStatusText,
            sortKey = unitStatusText,
            enterAction = activateUnit,
            pediaName = unitPediaName,
        },
        {
            name = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT",
            getCell = function(unit)
                return formatMoves(unit:MovesLeft())
            end,
            sortKey = function(unit)
                return unit:MovesLeft()
            end,
            enterAction = activateUnit,
            pediaName = unitPediaName,
        },
        {
            name = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES",
            getCell = function(unit)
                return formatMoves(unit:MaxMoves())
            end,
            sortKey = function(unit)
                return unit:MaxMoves()
            end,
            enterAction = activateUnit,
            pediaName = unitPediaName,
        },
        {
            name = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH",
            getCell = function(unit)
                return combatNumberCell(unit:GetBaseCombatStrength())
            end,
            sortKey = function(unit)
                return unit:GetBaseCombatStrength()
            end,
            enterAction = activateUnit,
            pediaName = unitPediaName,
        },
        {
            name = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED",
            getCell = function(unit)
                return combatNumberCell(unit:GetBaseRangedCombatStrength())
            end,
            sortKey = function(unit)
                return unit:GetBaseRangedCombatStrength()
            end,
            enterAction = activateUnit,
            pediaName = unitPediaName,
        },
    }
end

local function buildUnitsTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CIVVACCESS_MO_TAB_UNITS",
        columns = buildUnitColumns(),
        rebuildRows = rebuildUnitRows,
        rowLabel = unitRowLabel,
    })
end

-- ===== Great People tab ===============================================

-- Per-turn GPP gain for a (city, specialist) pair. Verbatim port of
-- GPList.lua's getRateOfChange (Assets/DLC/Expansion2/UI/InGame/GPList.lua,
-- lines 254-305): base specialist count + per-type buildings, multiplied
-- by player / city / golden-age / per-type modifiers. The per-type
-- modifier branch reaches into player methods that only exist in BNW
-- (GetGreatWriterRateModifier, GetGoldenAgeGreatArtistRateModifier,
-- etc.); BNW is a hard requirement of this mod, so they're guaranteed
-- present.
local function gpRateOfChange(city, specialistInfo, player)
    local iCount = city:GetSpecialistCount(specialistInfo.ID)
    local iGPPChange = specialistInfo.GreatPeopleRateChange * iCount * 100
    for building in GameInfo.Buildings({ SpecialistType = specialistInfo.Type }) do
        if city:IsHasBuilding(building.ID) then
            iGPPChange = iGPPChange + building.GreatPeopleRateChange * 100
        end
    end
    if iGPPChange <= 0 then
        return 0
    end

    local iPlayerMod = player:GetGreatPeopleRateModifier()
    local iCityMod = city:GetGreatPeopleRateModifier()
    local iGoldenAgeMod = 0
    local bGoldenAge = (player:GetGoldenAgeTurns() > 0)

    local unitClassName = specialistInfo.GreatPeopleUnitClass
    if unitClassName == "UNITCLASS_WRITER" then
        iPlayerMod = iPlayerMod + player:GetGreatWriterRateModifier()
        if bGoldenAge and player:GetGoldenAgeGreatWriterRateModifier() > 0 then
            iGoldenAgeMod = iGoldenAgeMod + player:GetGoldenAgeGreatWriterRateModifier()
        end
    elseif unitClassName == "UNITCLASS_ARTIST" then
        iPlayerMod = iPlayerMod + player:GetGreatArtistRateModifier()
        if bGoldenAge and player:GetGoldenAgeGreatArtistRateModifier() > 0 then
            iGoldenAgeMod = iGoldenAgeMod + player:GetGoldenAgeGreatArtistRateModifier()
        end
    elseif unitClassName == "UNITCLASS_MUSICIAN" then
        iPlayerMod = iPlayerMod + player:GetGreatMusicianRateModifier()
        if bGoldenAge and player:GetGoldenAgeGreatMusicianRateModifier() > 0 then
            iGoldenAgeMod = iGoldenAgeMod + player:GetGoldenAgeGreatMusicianRateModifier()
        end
    elseif unitClassName == "UNITCLASS_SCIENTIST" then
        iPlayerMod = iPlayerMod + player:GetGreatScientistRateModifier()
    elseif unitClassName == "UNITCLASS_MERCHANT" then
        iPlayerMod = iPlayerMod + player:GetGreatMerchantRateModifier()
    elseif unitClassName == "UNITCLASS_ENGINEER" then
        iPlayerMod = iPlayerMod + player:GetGreatEngineerRateModifier()
    end

    local iMod = iPlayerMod + iCityMod + iGoldenAgeMod
    iGPPChange = (iGPPChange * (100 + iMod)) / 100
    return math.floor(iGPPChange / 100)
end

-- Per-(city, specialist) row for a specialist subgroup. Sorted by turns
-- ascending: imminent (rate >= remaining) sorts first, finite turns
-- next, rate-zero last (treated as +infinity).
local function buildSpecialistCityRow(specialistInfo, unitClass, city, player)
    local iProgress = city:GetSpecialistGreatPersonProgress(specialistInfo.ID)
    local iThreshold = city:GetSpecialistUpgradeThreshold(unitClass.ID)
    local iRate = gpRateOfChange(city, specialistInfo, player)
    local cityName = Text.key(city:GetNameKey())

    local labelText
    local sortTurns
    if iRate <= 0 then
        sortTurns = math.huge
        labelText = Text.format("TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS", cityName, iProgress, iThreshold)
    else
        local turns
        if (iThreshold - iProgress) <= iRate then
            turns = 1
        else
            turns = math.floor((iThreshold - iProgress) / iRate) + 1
        end
        sortTurns = turns
        local turnsText
        if turns == 1 then
            turnsText = Text.key("TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT")
        else
            turnsText = Text.formatPlural("TXT_KEY_CIVVACCESS_MO_GP_TURNS_N", turns, turns)
        end
        labelText = Text.format("TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW", cityName, turnsText, iProgress, iThreshold, iRate)
    end
    return {
        labelText = labelText,
        sortTurns = sortTurns,
        cityID = city:GetID(),
    }
end

-- Subgroup for one specialist type. Returns nil when no city in the
-- player's empire has nonzero progress for this specialist -- mirrors
-- GPList's section-hiding so the user never lands on an empty subgroup.
local function buildSpecialistGroup(specialistInfo)
    local unitClassName = specialistInfo.GreatPeopleUnitClass
    if unitClassName == nil then
        return nil
    end
    local unitClass = GameInfo.UnitClasses[unitClassName]
    if unitClass == nil then
        return nil
    end
    local player = Players[Game.GetActivePlayer()]
    local entries = {}
    for city in player:Cities() do
        if city:GetSpecialistGreatPersonProgress(specialistInfo.ID) > 0 then
            entries[#entries + 1] = buildSpecialistCityRow(specialistInfo, unitClass, city, player)
        end
    end
    if #entries == 0 then
        return nil
    end
    table.sort(entries, function(a, b)
        if a.sortTurns ~= b.sortTurns then
            return a.sortTurns < b.sortTurns
        end
        return a.cityID < b.cityID
    end)
    local items = {}
    for i, entry in ipairs(entries) do
        items[i] = BaseMenuItems.Text({
            labelText = entry.labelText,
            pediaName = unitClass.Description,
        })
    end
    return BaseMenuItems.Group({
        labelText = Text.key(unitClass.Description),
        pediaName = unitClass.Description,
        items = items,
    })
end

-- GP meter readout: numerator / denominator phrased as "X of Y xp".
-- Tooltip (TXT_KEY_MO_GENERAL_TT / _ADMIRAL_TT) supplies the progress
-- fraction as part of its body, but the numerator and denominator are
-- the specific information carriers; reading the full tooltip would
-- pad with the same explanatory prose every time.
local function gpProgressWidget(labelKey, currentFn, thresholdFn, pediaName)
    return BaseMenuItems.Text({
        labelFn = function()
            local p = Players[Game.GetActivePlayer()]
            return Text.format("TXT_KEY_CIVVACCESS_MO_GP_PROGRESS", Text.key(labelKey), currentFn(p), thresholdFn(p))
        end,
        pediaName = pediaName,
    })
end

-- Specialist subgroup rank. Lower comes first. Anything not listed gets
-- the trailing rank (cultural specialists -- Writer / Artist / Musician
-- -- fall here). DB ID breaks ties so cultural-pair ordering stays
-- deterministic across runs.
local SPECIALIST_RANK = {
    UNITCLASS_SCIENTIST = 1,
    UNITCLASS_ENGINEER = 2,
    UNITCLASS_MERCHANT = 3,
}
local SPECIALIST_RANK_DEFAULT = 99

local function specialistRank(specialistInfo)
    return SPECIALIST_RANK[specialistInfo.GreatPeopleUnitClass] or SPECIALIST_RANK_DEFAULT
end

local function buildGreatPeopleItems()
    local items = {}
    -- GG / GA at the top. Land-vs-naval war progress is the most
    -- decision-critical of the great-people streams (combat XP either
    -- accumulates from active fighting or doesn't), so it leads.
    items[#items + 1] = gpProgressWidget("TXT_KEY_CITYVIEW_GG_PROGRGRESS", function(p)
        return p:GetCombatExperience()
    end, function(p)
        return p:GreatGeneralThreshold()
    end, "TXT_KEY_UNIT_GREAT_GENERAL")
    items[#items + 1] = gpProgressWidget("TXT_KEY_MO_GA_PROGRESS", function(p)
        return p:GetNavalCombatExperience()
    end, function(p)
        return p:GreatAdmiralThreshold()
    end, "TXT_KEY_UNIT_GREAT_ADMIRAL")
    -- Specialist subgroups in priority order. Collect first then sort
    -- so the iteration order of GameInfo.Specialists doesn't leak
    -- through.
    local specialists = {}
    for s in GameInfo.Specialists() do
        if s.GreatPeopleUnitClass ~= nil then
            specialists[#specialists + 1] = s
        end
    end
    table.sort(specialists, function(a, b)
        local ra = specialistRank(a)
        local rb = specialistRank(b)
        if ra ~= rb then
            return ra < rb
        end
        return a.ID < b.ID
    end)
    for _, s in ipairs(specialists) do
        local group = buildSpecialistGroup(s)
        if group ~= nil then
            items[#items + 1] = group
        end
    end
    return items
end

-- Hoisted so install's onShow refreshes the items each open. Subgroup
-- visibility depends on per-city progress, which can change between
-- opens (a city accrued enough Writer GPP to appear, or the previous
-- specialist resolved into a great person and the subgroup empties).
-- Without the refresh the items would freeze at first-build state.
local m_greatPeopleTab

local function buildGreatPeopleTab()
    m_greatPeopleTab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"),
            items = buildGreatPeopleItems(),
        },
    })
    return m_greatPeopleTab
end

-- ===== Supply preamble ================================================

-- Sole shell preamble: a one-line use/cap fraction. Same format whether
-- the player is over cap (use > cap) or under -- the fraction conveys
-- both the absolute count and the deficit-or-headroom on its own; over
-- cap shows e.g. "Supply: 25/20" which reads as obviously over. The
-- production-penalty percent and the per-source breakdown (base /
-- cities / population) the sighted screen shows are dropped in favour
-- of brevity here.
local function supplyPreamble()
    local p = Players[Game.GetActivePlayer()]
    if p == nil then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF", p:GetNumUnits(), p:GetNumUnitsSupplied())
end

-- ===== Install ========================================================

TabbedShell.install(ContextPtr, {
    name = "MilitaryOverview",
    displayName = Text.key("TXT_KEY_MILITARY_OVERVIEW"),
    preamble = supplyPreamble,
    tabs = {
        buildUnitsTab(),
        buildGreatPeopleTab(),
    },
    initialTabIndex = 1,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    -- Refresh GP items each open so subgroups reflect current per-city
    -- progress (sub-list visibility hinges on >0 progress; a great-
    -- person resolution between opens can empty out a subgroup).
    onShow = function()
        if m_greatPeopleTab ~= nil then
            m_greatPeopleTab.menu().setItems(buildGreatPeopleItems())
        end
    end,
})

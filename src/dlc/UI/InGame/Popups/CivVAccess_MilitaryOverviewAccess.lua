-- MilitaryOverview accessibility (F3). The popup lays out one screen:
--   * Great General and Great Admiral progress meters (top right)
--   * Supply block (left column: base supply, cities, population, cap, use,
--     remaining OR deficit+penalty when over-cap), collapsed to one line
--   * Unit list split into military (combat type != -1 or nukes) and civilian
--     stacks (right column, scrollable)
--
-- Level 0 exposes the supply widget, then a sort selector, then a drill-in
-- per non-empty unit stack, then a Great People progress group at the bottom.
-- Unit rows activate to UI.SelectUnit (or LookAtSelectionPlot if already
-- selected, matching the engine click handler), then OnClose +
-- CameraTracker.followAndJumpCursor so the hex cursor ends up on the selected
-- unit's plot. Sort is global across both unit sub-lists to mirror the engine;
-- ascending/descending toggle is deferred (one direction, matching the default
-- each header click lands on).
--
-- Great People group mirrors the engine's GPList: one drillable subgroup per
-- specialist type (Artist / Writer / Musician / Scientist / Engineer /
-- Merchant), each populated with per-city rows sorted by turns ascending.
-- Subgroups are skipped entirely when no city has any progress for that type
-- (matches GPList's section-hiding). Great General and Great Admiral are flat
-- rows in the same group (player-scoped, no per-city breakdown). Great Prophet
-- is intentionally omitted because GPList doesn't list it -- prophet progress
-- is faith-gated, not GPP-gated, and lives on the Religion Overview screen.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_PluralRules")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_CameraTracker")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Sort modes. Match the engine's eName / eStatus / eMovement / eMoves /
-- eStrength / eRanged ordering.
local SORT_NAME = 1
local SORT_STATUS = 2
local SORT_MOVEMENT = 3
local SORT_MOVES = 4
local SORT_STRENGTH = 5
local SORT_RANGED = 6

local SORT_ORDER = { SORT_NAME, SORT_STATUS, SORT_MOVEMENT, SORT_MOVES, SORT_STRENGTH, SORT_RANGED }

local SORT_LABEL_KEYS = {
    [SORT_NAME] = "TXT_KEY_NAME",
    [SORT_STATUS] = "TXT_KEY_STATUS",
    [SORT_MOVEMENT] = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT",
    [SORT_MOVES] = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES",
    [SORT_STRENGTH] = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH",
    [SORT_RANGED] = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED",
}

local m_sortMode = SORT_NAME
-- Parent-list position of the sort selector, refreshed each buildTopItems
-- run so "pick a sort mode, commit, pop back" can return the cursor to the
-- selector it just left. Varies with the supply-deficit branch (one vs two
-- supply widgets), which is why it's a live value rather than a constant.
local m_sortIndex = 1
-- Forward decl: sortSelector's inner activate calls buildTopItems to rebuild
-- the parent on sort commit, and buildTopItems calls sortSelector to install
-- it into the item list -- one side of the cycle has to be declared ahead.
local buildTopItems

-- Localized status text for a unit. Mirrors the engine's priority cascade in
-- BuildUnitList. Returns nil when the engine would have hidden the status
-- column (idle non-fortified, non-sleeping unit).
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
    return nil
end

-- MovesLeft / MaxMoves are 60ths; flooring would lose road / railroad
-- remainders ("1 of 2" for a 90/60 unit). Round to two decimal places
-- to absorb floating-point noise, then build the string from integer
-- parts so the decimal separator stays "." regardless of LC_NUMERIC
-- (a comma-decimal locale would otherwise feed "1,5" to Tolk, spoken
-- as "one comma five"). Mirrors UnitSpeech.formatMoves; kept local
-- to avoid a Context-wide include just for one helper.
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

-- Pre-compute row fields once per build so the sort compare can read scalars
-- and the announce closure can format on demand without re-querying the unit.
-- Numeric movesLeft / maxMoves drive the SORT_MOVEMENT / SORT_MOVES compare;
-- the *Text variants are the speech-ready strings rowLabel inserts.
--
-- displayName uses the no-civ form -- the list is the active player's own
-- military, so a "Roman" prefix on every row would just be noise. Named
-- units (rename via Alt+N, plus great-general name-pool entries) wrap the
-- type in parens after the personal name to match UnitSpeech.unitName's
-- shape elsewhere in the mod.
local function buildRowEntry(unit)
    local denom = GameDefines["MOVE_DENOMINATOR"]
    local typeName = Text.key(unit:GetNameKey())
    local displayName
    if unit:HasName() then
        local personal = Text.key(unit:GetNameNoDesc())
        if typeName == "" then
            displayName = personal
        else
            displayName = personal .. " (" .. typeName .. ")"
        end
    else
        displayName = typeName
    end
    return {
        unit = unit,
        unitID = unit:GetID(),
        displayName = displayName,
        status = unitStatusText(unit),
        movesLeft = unit:MovesLeft() / denom,
        maxMoves = unit:MaxMoves() / denom,
        movesLeftText = formatMoves(unit:MovesLeft()),
        maxMovesText = formatMoves(unit:MaxMoves()),
        strength = unit:GetBaseCombatStrength(),
        ranged = unit:GetBaseRangedCombatStrength(),
        hasPromotion = unit:CanPromote(),
    }
end

local function rowLabel(entry)
    local parts = { entry.displayName }
    if entry.status ~= nil then
        parts[#parts + 1] = entry.status
    end
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION", entry.movesLeftText, entry.maxMovesText)
    if entry.strength > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_MO_ROW_STRENGTH", entry.strength)
    end
    if entry.ranged > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_MO_ROW_RANGED", entry.ranged)
    end
    if entry.hasPromotion then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE")
    end
    return table.concat(parts, ", ")
end

local function pediaNameFor(unit)
    local info = GameInfo.Units[unit:GetUnitType()]
    if info == nil then
        return nil
    end
    return Text.key(info.Description)
end

-- Click semantics mirror the engine's UnitClicked: same unit already selected
-- re-centers the camera; otherwise select. Then close the popup and drop the
-- hex cursor on the engine's post-pan plot.
local function activateUnit(unit)
    local head = UI:GetHeadSelectedUnit()
    if head ~= nil and head:GetID() == unit:GetID() then
        UI.LookAtSelectionPlot(0)
    else
        UI.SelectUnit(unit)
    end
    OnClose()
    CameraTracker.followAndJumpCursor()
end

-- table.sort calls this many times per build but m_sortMode can't change
-- during a sort (table.sort is synchronous; nothing we do inside the compare
-- mutates it), so reading the upvalue each call is safe.
local function sortComparator(a, b)
    local va, vb
    if m_sortMode == SORT_NAME then
        va, vb = a.displayName, b.displayName
        if va ~= vb then
            return Locale.Compare(va, vb) == -1
        end
    elseif m_sortMode == SORT_STATUS then
        va, vb = a.status or "", b.status or ""
        if va ~= vb then
            return Locale.Compare(va, vb) == -1
        end
    elseif m_sortMode == SORT_MOVEMENT then
        va, vb = a.movesLeft, b.movesLeft
    elseif m_sortMode == SORT_MOVES then
        va, vb = a.maxMoves, b.maxMoves
    elseif m_sortMode == SORT_STRENGTH then
        va, vb = a.strength, b.strength
    elseif m_sortMode == SORT_RANGED then
        va, vb = a.ranged, b.ranged
    end
    if va == vb then
        return a.unitID < b.unitID
    end
    return va < vb
end

local function buildGroupItems(entries)
    table.sort(entries, sortComparator)
    local items = {}
    for i, entry in ipairs(entries) do
        items[i] = BaseMenuItems.Choice({
            labelText = rowLabel(entry),
            pediaName = pediaNameFor(entry.unit),
            activate = function()
                activateUnit(entry.unit)
            end,
        })
    end
    return items
end

local function collectUnits()
    local pPlayer = Players[Game.GetActivePlayer()]
    local military, civilian = {}, {}
    for unit in pPlayer:Units() do
        local entry = buildRowEntry(unit)
        if unit:GetUnitCombatType() ~= -1 or unit:CanNuke() then
            military[#military + 1] = entry
        else
            civilian[#civilian + 1] = entry
        end
    end
    return military, civilian
end

-- GP meter readout: numerator / denominator phrased as "X of Y xp". Tooltip
-- (TXT_KEY_MO_GENERAL_TT / _ADMIRAL_TT) supplies the progress fraction as part
-- of its body, but the numerator and denominator are the specific information
-- carriers; reading the full tooltip as speech would pad with the same
-- explanatory prose every time.
local function gpProgressWidget(labelKey, currentFn, thresholdFn)
    return BaseMenuItems.Text({
        labelFn = function()
            local p = Players[Game.GetActivePlayer()]
            return Text.format("TXT_KEY_CIVVACCESS_MO_GP_PROGRESS", Text.key(labelKey), currentFn(p), thresholdFn(p))
        end,
    })
end

local function supplyWidget()
    return BaseMenuItems.Text({
        labelFn = function()
            local p = Players[Game.GetActivePlayer()]
            local base = p:GetNumUnitsSuppliedByHandicap()
            local cities = p:GetNumUnitsSuppliedByCities()
            local pop = p:GetNumUnitsSuppliedByPopulation()
            local cap = p:GetNumUnitsSupplied()
            local use = p:GetNumUnits()
            local deficit = p:GetNumUnitsOutOfSupply()
            if deficit ~= 0 then
                local penalty = p:GetUnitProductionMaintenanceMod() .. "%"
                return Text.format(
                    "TXT_KEY_CIVVACCESS_MO_SUPPLY_DEFICIT",
                    use,
                    cap,
                    deficit,
                    penalty,
                    base,
                    cities,
                    pop
                )
            end
            return Text.format("TXT_KEY_CIVVACCESS_MO_SUPPLY_NORMAL", use, cap, cap - use, base, cities, pop)
        end,
    })
end

local function sortSelector(handler)
    return BaseMenuItems.Choice({
        labelFn = function()
            return Text.format("TXT_KEY_CIVVACCESS_MO_SORT_LABEL", Text.key(SORT_LABEL_KEYS[m_sortMode]))
        end,
        activate = function()
            local children = {}
            for i, mode in ipairs(SORT_ORDER) do
                local captured = mode
                children[i] = BaseMenuItems.Choice({
                    labelText = Text.key(SORT_LABEL_KEYS[captured]),
                    selectedFn = function()
                        return m_sortMode == captured
                    end,
                    activate = function()
                        m_sortMode = captured
                        handler.setItems(buildTopItems(handler))
                        handler.setIndex(m_sortIndex)
                        HandlerStack.pop()
                    end,
                })
            end
            HandlerStack.push(BaseMenu.create({
                name = "MilitaryOverview/Sort",
                displayName = Text.key("TXT_KEY_CIVVACCESS_MO_SORT_MENU"),
                items = children,
                escapePops = true,
            }))
        end,
    })
end

-- Per-turn GPP gain for a (city, specialist) pair. Verbatim port of
-- GPList.lua's getRateOfChange (Assets/DLC/Expansion2/UI/InGame/GPList.lua,
-- lines 254-305): base specialist count + per-type buildings, multiplied by
-- player / city / golden-age / per-type modifiers. The per-type modifier
-- branch reaches into player methods that only exist in BNW
-- (GetGreatWriterRateModifier, GetGoldenAgeGreatArtistRateModifier, etc.);
-- BNW is a hard requirement of this mod, so they're guaranteed present.
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
-- ascending: imminent (rate >= remaining) sorts first, finite turns next,
-- rate-zero last (treated as +infinity). Snapshots progress / threshold /
-- rate at build time matching the unit-row pattern; the menu rebuilds on
-- each onShow so values stay fresh between opens.
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

-- Subgroup for one specialist type. Returns nil when no city in the player's
-- empire has nonzero progress for this specialist -- mirrors GPList's
-- section-hiding so the user never lands on an empty subgroup.
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
        items[i] = BaseMenuItems.Text({ labelText = entry.labelText })
    end
    return BaseMenuItems.Group({
        labelText = Text.key(unitClass.Description),
        items = items,
    })
end

local function buildGreatPeopleGroup()
    local items = {}
    for specialistInfo in GameInfo.Specialists() do
        if specialistInfo.GreatPeopleUnitClass ~= nil then
            local group = buildSpecialistGroup(specialistInfo)
            if group ~= nil then
                items[#items + 1] = group
            end
        end
    end
    items[#items + 1] = gpProgressWidget("TXT_KEY_CITYVIEW_GG_PROGRGRESS", function(p)
        return p:GetCombatExperience()
    end, function(p)
        return p:GreatGeneralThreshold()
    end)
    items[#items + 1] = gpProgressWidget("TXT_KEY_MO_GA_PROGRESS", function(p)
        return p:GetNavalCombatExperience()
    end, function(p)
        return p:GreatAdmiralThreshold()
    end)
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_MO_GP_GROUP"),
        items = items,
    })
end

function buildTopItems(handler)
    local military, civilian = collectUnits()
    local items = {
        supplyWidget(),
    }
    m_sortIndex = #items + 1
    items[#items + 1] = sortSelector(handler)
    if #military > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_MO_GROUP_MILITARY"),
            items = buildGroupItems(military),
        })
    end
    if #civilian > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_MO_GROUP_CIVILIAN"),
            items = buildGroupItems(civilian),
        })
    end
    items[#items + 1] = buildGreatPeopleGroup()
    return items
end

local function onShow(handler)
    handler.setItems(buildTopItems(handler))
end

BaseMenu.install(ContextPtr, {
    name = "MilitaryOverview",
    displayName = Text.key("TXT_KEY_MILITARY_OVERVIEW"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = onShow,
    items = { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_MILITARY_OVERVIEW") }) },
})

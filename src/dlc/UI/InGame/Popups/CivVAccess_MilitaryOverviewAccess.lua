-- MilitaryOverview accessibility (F3). The popup lays out one screen:
--   * Great General and Great Admiral progress meters (top right)
--   * Supply block (left column: base supply, cities, population, cap, use,
--     remaining OR deficit+penalty when over-cap)
--   * Unit list split into military (combat type != -1 or nukes) and civilian
--     stacks (right column, scrollable)
--
-- Level 0 exposes the non-list payload as Text widgets, then a sort selector,
-- then a drill-in per non-empty unit stack. Unit rows activate to UI.SelectUnit
-- (or LookAtSelectionPlot if already selected, matching the engine click
-- handler), then OnClose + CameraTracker.followAndJumpCursor so the hex cursor
-- ends up on the selected unit's plot. Sort is global across both sub-lists to
-- mirror the engine; ascending/descending toggle is deferred (one direction,
-- matching the default each header click lands on).

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
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
    [SORT_NAME]     = "TXT_KEY_NAME",
    [SORT_STATUS]   = "TXT_KEY_STATUS",
    [SORT_MOVEMENT] = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT",
    [SORT_MOVES]    = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES",
    [SORT_STRENGTH] = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH",
    [SORT_RANGED]   = "TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED",
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
        return Locale.ConvertTextKey("TXT_KEY_UNIT_STATUS_EMBARKED")
    end
    if unit:IsGarrisoned() then
        return Locale.ConvertTextKey("TXT_KEY_MISSION_GARRISON")
    end
    if unit:IsAutomated() then
        if unit:IsWork() then
            return Locale.ConvertTextKey("TXT_KEY_ACTION_AUTOMATE_BUILD")
        end
        return Locale.ConvertTextKey("TXT_KEY_ACTION_AUTOMATE_EXPLORE")
    end
    local activityType = unit:GetActivityType()
    if activityType == ActivityTypes.ACTIVITY_HEAL then
        return Locale.ConvertTextKey("TXT_KEY_MISSION_HEAL")
    end
    if activityType == ActivityTypes.ACTIVITY_SENTRY then
        return Locale.ConvertTextKey("TXT_KEY_MISSION_ALERT")
    end
    if unit:GetFortifyTurns() > 0 then
        return Locale.ConvertTextKey("TXT_KEY_UNIT_STATUS_FORTIFIED")
    end
    if activityType == ActivityTypes.ACTIVITY_SLEEP then
        return Locale.ConvertTextKey("TXT_KEY_MISSION_SLEEP")
    end
    local buildType = unit:GetBuildType()
    if buildType ~= -1 then
        local build = GameInfo.Builds[buildType]
        local str = Locale.ConvertTextKey(build.Description)
        local turnsLeft = unit:GetPlot():GetBuildTurnsLeft(buildType, Game.GetActivePlayer(), 0, 0)
        if turnsLeft < 4000 and turnsLeft > 0 then
            str = str .. " (" .. tostring(turnsLeft) .. ")"
        end
        return str
    end
    return nil
end

-- Pre-compute row fields once per build so the sort compare can read scalars
-- and the announce closure can format on demand without re-querying the unit.
local function buildRowEntry(unit)
    local moveDenom = GameDefines["MOVE_DENOMINATOR"]
    return {
        unit = unit,
        unitID = unit:GetID(),
        displayName = Locale.Lookup(unit:GetNameKey()),
        status = unitStatusText(unit),
        movesLeft = math.floor(unit:MovesLeft() / moveDenom),
        maxMoves = math.floor(unit:MaxMoves() / moveDenom),
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
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION", entry.movesLeft, entry.maxMoves)
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
    return Locale.Lookup(info.Description)
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
            return Text.format(
                "TXT_KEY_CIVVACCESS_MO_GP_PROGRESS",
                Text.key(labelKey),
                currentFn(p),
                thresholdFn(p)
            )
        end,
    })
end

local function supplyWidget(labelKey, valueFn)
    return BaseMenuItems.Text({
        labelFn = function()
            local p = Players[Game.GetActivePlayer()]
            return Text.format("TXT_KEY_CIVVACCESS_MO_SUPPLY_LINE", Text.key(labelKey), tostring(valueFn(p)))
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

function buildTopItems(handler)
    local military, civilian = collectUnits()
    local items = {
        gpProgressWidget(
            "TXT_KEY_CITYVIEW_GG_PROGRGRESS",
            function(p) return p:GetCombatExperience() end,
            function(p) return p:GreatGeneralThreshold() end
        ),
        gpProgressWidget(
            "TXT_KEY_MO_GA_PROGRESS",
            function(p) return p:GetNavalCombatExperience() end,
            function(p) return p:GreatAdmiralThreshold() end
        ),
        supplyWidget("TXT_KEY_HANDICAP_SUPPLY",   function(p) return p:GetNumUnitsSuppliedByHandicap() end),
        supplyWidget("TXT_KEY_CITIES_SUPPLY",     function(p) return p:GetNumUnitsSuppliedByCities() end),
        supplyWidget("TXT_KEY_POPULATION_SUPPLY", function(p) return p:GetNumUnitsSuppliedByPopulation() end),
        supplyWidget("TXT_KEY_SUPPLY_CAP",        function(p) return p:GetNumUnitsSupplied() end),
        supplyWidget("TXT_KEY_SUPPLY_USE",        function(p) return p:GetNumUnits() end),
    }
    if Players[Game.GetActivePlayer()]:GetNumUnitsOutOfSupply() ~= 0 then
        items[#items + 1] = supplyWidget("TXT_KEY_SUPPLY_DEFICIT", function(p)
            return p:GetNumUnitsOutOfSupply()
        end)
        items[#items + 1] = supplyWidget("TXT_KEY_SUPPLY_DEFICIT_PENALTY", function(p)
            return p:GetUnitProductionMaintenanceMod() .. "%"
        end)
    else
        items[#items + 1] = supplyWidget("TXT_KEY_SUPPLY_REMAINING", function(p)
            return p:GetNumUnitsSupplied() - p:GetNumUnits()
        end)
    end
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
    return items
end

local function onShow(handler)
    handler.setItems(buildTopItems(handler))
end

BaseMenu.install(ContextPtr, {
    name          = "MilitaryOverview",
    displayName   = Text.key("TXT_KEY_MILITARY_OVERVIEW"),
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    onShow        = onShow,
    items         = { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_MILITARY_OVERVIEW") }) },
})

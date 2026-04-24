-- Tab action menu for the selected unit. Enumerates GameInfoActions,
-- keeps the ones the engine will accept, splits them into "commit at the
-- unit's plot" vs "pick a target", and routes each commit through the
-- right path (immediate Game.HandleAction for self-plot, HandleAction
-- + UnitTargetMode.enter for targeted).
--
-- The action set is pulled live from GameInfoActions on every open so a
-- newly-available build / promotion shows up without a stale cache.
-- Promotions and worker builds nest into a sub-Group so the top level
-- stays short (a freshly-promoted veteran with 30 qualifying promotions
-- would otherwise bury the action list).
--
-- Availability pattern mirrors base UnitPanel.lua:230-302:
--   Game.CanHandleAction(iAction, 0, 1) -> "could, if active unit"
--   Game.CanHandleAction(iAction)       -> "can, right now"
-- We show the action only when both return true. Partially-available
-- actions (visible-but-disabled in the engine UI) are omitted from
-- speech because activating one would silently no-op.

UnitActionMenu = {}

-- Action.Type / Action.SubType -> symbolic token for UnitSpeech.selfPlotConfirm.
-- Everything not in either map falls through to speaking the action's
-- localized TextKey as the confirm, so new engine actions at least say
-- something meaningful without needing a mapping update.
local SELF_PLOT_TOKENS_BY_TYPE = {
    MISSION_FORTIFY = "FORTIFY",
    MISSION_SLEEP = "SLEEP",
    MISSION_ALERT = "ALERT",
    MISSION_WAKE = "WAKE",
    COMMAND_WAKE = "WAKE",
    MISSION_AUTOMATE = "AUTOMATE",
    COMMAND_AUTOMATE_BUILD = "AUTOMATE",
    COMMAND_AUTOMATE_EXPLORE = "AUTOMATE",
    COMMAND_DELETE = "DISBAND",
    MISSION_DISBAND = "DISBAND",
    MISSION_HEAL = "HEAL",
    MISSION_PILLAGE = "PILLAGE",
    MISSION_SKIP = "SKIP",
    COMMAND_UPGRADE = "UPGRADE",
    COMMAND_CANCEL = "CANCEL",
    COMMAND_STOP_AUTOMATION = "CANCEL",
}

local function isTargetedAction(actionType)
    return type(actionType) == "string" and actionType:sub(1, 14) == "INTERFACEMODE_"
end

local function isPromotionAction(action)
    local subTypes = ActionSubTypes
    return subTypes ~= nil and action.SubType == subTypes.ACTIONSUBTYPE_PROMOTION
end

local function isBuildAction(action)
    local subTypes = ActionSubTypes
    return subTypes ~= nil and action.SubType == subTypes.ACTIONSUBTYPE_BUILD
end

local function actionLabel(action)
    local key = action.TextKey
    if key == nil or key == "" then
        key = action.Type
    end
    if type(key) ~= "string" or key == "" then
        return ""
    end
    return Text.key(key)
end

-- Static Help text from the action's underlying table (Builds.Help,
-- UnitPromotions.Help, Missions.Help, etc.). Engine defaults are "" for
-- rows that don't author one, so treat empty / nil the same.
local function staticHelpText(action)
    if type(action.Help) ~= "string" or action.Help == "" then
        return nil
    end
    return Text.key(action.Help)
end

-- Yield TXT_KEY per YieldTypes.YIELD_* id, for build-tooltip delta strings.
-- Keys mirror UnitPanel.lua TipHandler's yield branch (line ~1586).
local BUILD_YIELD_KEYS = {
    [YieldTypes.YIELD_FOOD] = "TXT_KEY_BUILD_FOOD_STRING",
    [YieldTypes.YIELD_PRODUCTION] = "TXT_KEY_BUILD_PRODUCTION_STRING",
    [YieldTypes.YIELD_GOLD] = "TXT_KEY_BUILD_GOLD_STRING",
    [YieldTypes.YIELD_SCIENCE] = "TXT_KEY_BUILD_SCIENCE_STRING",
    [YieldTypes.YIELD_CULTURE] = "TXT_KEY_BUILD_CULTURE_STRING",
    [YieldTypes.YIELD_FAITH] = "TXT_KEY_BUILD_FAITH_STRING",
}

-- Rich build tooltip mirroring UnitPanel.lua TipHandler (line ~1540-1658):
-- static Help, turn count for this plot, per-yield delta vs current,
-- resource connection, feature clearing. All pieces joined with ". " so
-- appendTooltip's sentence-level dedup can drop duplicates against the
-- label. Re-queried at announce time per the "never cache game state" rule.
local function buildActionTooltip(unit, action)
    local parts = {}
    local help = staticHelpText(action)
    if help ~= nil then
        parts[#parts + 1] = help
    end

    local iBuildID = action.MissionData
    local pBuild = GameInfo.Builds[iBuildID]
    if pBuild == nil then
        return table.concat(parts, ". ")
    end

    local plot = unit:GetPlot()
    local iActivePlayer = Game.GetActivePlayer()
    local iActiveTeam = Game.GetActiveTeam()

    local iExtraBuildRate = 0
    local iCurrentBuildID = unit:GetBuildType()
    if iCurrentBuildID == -1 or iBuildID ~= iCurrentBuildID then
        iExtraBuildRate = unit:WorkRate(true, iBuildID)
    end
    local iBuildTurns = plot:GetBuildTurnsLeft(iBuildID, iActivePlayer, iExtraBuildRate, iExtraBuildRate)
    if iBuildTurns > 1 then
        parts[#parts + 1] = Text.format("TXT_KEY_BUILD_NUM_TURNS", iBuildTurns)
    end

    local yieldParts = {}
    for iYield = 0, YieldTypes.NUM_YIELD_TYPES - 1 do
        local delta = plot:GetYieldWithBuild(iBuildID, iYield, false, iActivePlayer) - plot:CalculateYield(iYield)
        if delta ~= 0 then
            local key = BUILD_YIELD_KEYS[iYield]
            if key ~= nil then
                yieldParts[#yieldParts + 1] = Text.format(key, delta)
            end
        end
    end
    if #yieldParts > 0 then
        parts[#parts + 1] = table.concat(yieldParts, ", ")
    end

    local pImprovement
    if pBuild.ImprovementType ~= nil and pBuild.ImprovementType ~= "NONE" then
        pImprovement = GameInfo.Improvements[pBuild.ImprovementType]
    end
    if pImprovement ~= nil then
        local iResource = plot:GetResourceType(iActiveTeam)
        if iResource ~= -1 and plot:IsResourceConnectedByImprovement(pImprovement.ID) then
            if Game.GetResourceUsageType(iResource) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS then
                local pResource = GameInfo.Resources[iResource]
                if pResource ~= nil then
                    parts[#parts + 1] =
                        Text.format("TXT_KEY_BUILD_CONNECTS_RESOURCE", pResource.IconString, pResource.Description)
                end
            end
        end
    end

    local iFeature = plot:GetFeatureType()
    if iFeature ~= -1 then
        local pFeature = GameInfo.Features[iFeature]
        if pFeature ~= nil and plot:IsBuildRemovesFeature(iBuildID) then
            parts[#parts + 1] = Text.format("TXT_KEY_BUILD_FEATURE_CLEARED", pFeature.Description)
            local iFeatureProd = plot:GetFeatureProduction(iBuildID, iActiveTeam)
            if iFeatureProd > 0 then
                parts[#parts + 1] = Text.format("TXT_KEY_BUILD_FEATURE_PRODUCTION", iFeatureProd)
            end
        end
    end

    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ". ")
end

-- Collapses both CanHandleAction gates into a single yes / no read,
-- then applies the base-UI's out-of-moves filter.
--
-- Civ V's action table uses 0-based indexing into GameInfoActions, and
-- the iterator emits entries in Action-definition order.
--
-- The zero-moves branch mirrors base UnitPanel.lua:223. CanHandleAction
-- returns true for mission actions even at 0 moves because the per-mission
-- canFoo helpers only check plot legality; the real moves gate is
-- downstream in CvUnitMission::ContinueMission's `if (canMove())` block.
-- So MISSION_FOUND / MISSION_BUILD / etc. would silently no-op if we
-- passed them through. Base UI hides everything at 0 moves except cancel,
-- stop-automation, and promotions; we match that exactly.
local function isAvailable(unit, iAction, action)
    if not action.Visible then
        return false
    end
    if not Game.CanHandleAction(iAction, 0, 1) then
        return false
    end
    if not Game.CanHandleAction(iAction) then
        return false
    end
    if
        unit:MovesLeft() == 0
        and action.Type ~= "COMMAND_CANCEL"
        and action.Type ~= "COMMAND_STOP_AUTOMATION"
        and not isPromotionAction(action)
    then
        return false
    end
    return true
end

local function commitSelfPlot(action, payload)
    Game.HandleAction(payload.iAction)
    local token = SELF_PLOT_TOKENS_BY_TYPE[action.Type]
    if isPromotionAction(action) then
        token = "PROMOTION"
    elseif isBuildAction(action) then
        token = "BUILD_START"
    end
    local confirm
    if token ~= nil then
        confirm = UnitSpeech.selfPlotConfirm(token, payload)
    end
    if confirm == nil or confirm == "" then
        confirm = actionLabel(action)
    end
    if confirm ~= "" then
        SpeechPipeline.speakInterrupt(confirm)
    end
end

local function commitTargeted(unit, action, iAction)
    Game.HandleAction(iAction)
    UnitTargetMode.enter(unit, iAction, UI.GetInterfaceMode())
end

local function buildPromotionItems(unit, rows)
    local items = {}
    for _, row in ipairs(rows) do
        local iAction = row.iAction
        local action = row.action
        local label = actionLabel(action)
        local promotionName = label
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = label,
            tooltipFn = function()
                return staticHelpText(action)
            end,
            activate = function()
                commitSelfPlot(action, { iAction = iAction, promotionName = promotionName })
                HandlerStack.removeByName("UnitActionMenu", false)
            end,
        })
    end
    return items
end

local function buildBuildItems(unit, rows)
    local items = {}
    for _, row in ipairs(rows) do
        local iAction = row.iAction
        local action = row.action
        local label = actionLabel(action)
        local buildName = label
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = label,
            tooltipFn = function()
                return buildActionTooltip(unit, action)
            end,
            activate = function()
                commitSelfPlot(action, { iAction = iAction, buildName = buildName })
                HandlerStack.removeByName("UnitActionMenu", false)
            end,
        })
    end
    return items
end

local function buildTopLevelItems(unit, buckets)
    local items = {}
    for _, row in ipairs(buckets.plain) do
        local iAction = row.iAction
        local action = row.action
        local label = actionLabel(action)
        if label == "" then
            Log.warn("UnitActionMenu: action iAction=" .. tostring(iAction) .. " has no label; omitting")
        elseif isTargetedAction(action.Type) then
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
                tooltipFn = function()
                    return staticHelpText(action)
                end,
                activate = function()
                    HandlerStack.removeByName("UnitActionMenu", false)
                    commitTargeted(unit, action, iAction)
                end,
            })
        else
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
                tooltipFn = function()
                    return staticHelpText(action)
                end,
                activate = function()
                    commitSelfPlot(action, { iAction = iAction })
                    HandlerStack.removeByName("UnitActionMenu", false)
                end,
            })
        end
    end
    if #buckets.promotions > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"),
            items = buildPromotionItems(unit, buckets.promotions),
        })
    end
    if #buckets.builds > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"),
            items = buildBuildItems(unit, buckets.builds),
        })
    end
    return items
end

local function collectActions(unit)
    local buckets = { plain = {}, promotions = {}, builds = {} }
    if GameInfoActions == nil then
        Log.error("UnitActionMenu: GameInfoActions missing; no actions to list")
        return buckets
    end
    for iAction = 0, #GameInfoActions do
        local action = GameInfoActions[iAction]
        if action ~= nil and isAvailable(unit, iAction, action) then
            if isPromotionAction(action) then
                buckets.promotions[#buckets.promotions + 1] = { iAction = iAction, action = action }
            elseif isBuildAction(action) then
                buckets.builds[#buckets.builds + 1] = { iAction = iAction, action = action }
            else
                buckets.plain[#buckets.plain + 1] = { iAction = iAction, action = action }
            end
        end
    end
    return buckets
end

-- Public action lookups for the Alt-letter quick-action hotkeys in
-- UnitControl. Same isAvailable / commitSelfPlot / commitTargeted gates
-- the Tab menu uses, so a hotkey commit and a menu commit run identical
-- code (including the speech confirm path through selfPlotConfirm).

-- Find the first GameInfoActions row whose Type is in `types`, regardless
-- of whether it's currently available. Caller uses this to fetch a label
-- for the "{action} not available" failure speech. Iterates types in
-- caller order so the first listed type wins on ties.
function UnitActionMenu.findActionRow(types)
    if GameInfoActions == nil then
        return nil, nil
    end
    for _, wantType in ipairs(types) do
        for iAction = 0, #GameInfoActions do
            local action = GameInfoActions[iAction]
            if action ~= nil and action.Type == wantType then
                return iAction, action
            end
        end
    end
    return nil, nil
end

-- Localized label for an action row's TextKey, with the same fallback
-- ladder as the menu's actionLabel. Public so UnitControl can speak the
-- failure case without duplicating the lookup.
function UnitActionMenu.actionLabel(action)
    return actionLabel(action)
end

-- Find and commit the first available action whose Type is in `types`.
-- Returns true on commit, false if no listed type is currently available
-- for `unit`. Self-plot vs targeted dispatch matches the Tab menu exactly:
-- INTERFACEMODE_* enters target mode through commitTargeted, everything
-- else commits at the unit's plot through commitSelfPlot.
function UnitActionMenu.commitByType(unit, types)
    if unit == nil or GameInfoActions == nil then
        return false
    end
    for _, wantType in ipairs(types) do
        for iAction = 0, #GameInfoActions do
            local action = GameInfoActions[iAction]
            if action ~= nil and action.Type == wantType and isAvailable(unit, iAction, action) then
                if isTargetedAction(action.Type) then
                    commitTargeted(unit, action, iAction)
                else
                    commitSelfPlot(action, { iAction = iAction })
                end
                return true
            end
        end
    end
    return false
end

-- Opens the action menu for `unit`. No-op with no unit. Speaks the
-- "no actions" token and stays closed when every action is filtered.
-- Idempotent: an existing UnitActionMenu handler on the stack is
-- removed before the new push so Tab-during-menu reopens cleanly.
function UnitActionMenu.open(unit)
    if unit == nil then
        return
    end
    local buckets = collectActions(unit)
    local items = buildTopLevelItems(unit, buckets)
    if #items == 0 then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"))
        return
    end
    HandlerStack.removeByName("UnitActionMenu", false)
    local handler = BaseMenu.create({
        name = "UnitActionMenu",
        displayName = Text.key("TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(handler)
end

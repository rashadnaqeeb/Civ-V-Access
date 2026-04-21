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

-- Collapses both CanHandleAction gates into a single yes / no read.
-- Civ V's action table uses 0-based indexing into GameInfoActions, and
-- the iterator emits entries in Action-definition order.
local function isAvailable(iAction, action)
    if not action.Visible then
        return false
    end
    if not Game.CanHandleAction(iAction, 0, 1) then
        return false
    end
    if not Game.CanHandleAction(iAction) then
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
                activate = function()
                    HandlerStack.removeByName("UnitActionMenu", false)
                    commitTargeted(unit, action, iAction)
                end,
            })
        else
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
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
        if action ~= nil and isAvailable(iAction, action) then
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

-- Production queue sub-handler for the CityView accessibility hub. Owns:
--
-- - The slot-label composers (slotOneLabel for the currently-producing
--   item with its production meter percentage, slotNLabel for queued
--   slots without the meter).
-- - The slot drill-in (Move up / Move down / Remove / Back) with engine
--   net-message dispatch (GAMEMESSAGE_SWAP_ORDER / POP_ORDER) and the
--   pop-and-re-push rebuild that follows a successful mutation.
-- - The Production handler itself (push), its item builder
--   (queue slots + queue-mode toggle + Choose Production + Purchase),
--   and the wrapped onActivate that rebuilds the slot list on a popup
--   pop-back via TickPump (the engine's queue mutation isn't visible
--   through GetOrderQueueLength until the next tick).
--
-- Exposes `CityViewProduction.push` for the hub to invoke from
-- buildHubItems. No other external surface; the orchestrator's
-- `CivVAccess_CityViewAccess` only reaches for `.push`.

CityViewProduction = {}

-- ===== Local helpers (duplicated from the orchestrator) =====
-- Both helpers are tiny; duplication beats exposing private state on a
-- shared module table here. Drift risk is low because each is one
-- engine-call deep.

local function isTurnActive()
    return Players[Game.GetActivePlayer()]:IsTurnActive()
end

-- Foreign / spy-screen predicate. Duplicated from the orchestrator;
-- trivial enough that a shared module table would be more ceremony than
-- it saves. See CivVAccess_CityViewAccess.lua's isActiveOwn for the
-- rationale -- we treat both owner-mismatch and viewing-mode as foreign
-- so neither engine path slips a write through.
local function isActiveOwn(city)
    return city ~= nil and city:GetOwner() == Game.GetActivePlayer() and not UI.IsCityScreenViewingMode()
end

local function refuseForeign(textKey)
    SpeechPipeline.speakInterrupt(Text.key(textKey))
end

-- ===== Order metadata =====

local ORDER_INFO_TABLE = {
    [OrderTypes.ORDER_TRAIN] = function()
        return GameInfo.Units
    end,
    [OrderTypes.ORDER_CONSTRUCT] = function()
        return GameInfo.Buildings
    end,
    [OrderTypes.ORDER_CREATE] = function()
        return GameInfo.Projects
    end,
    [OrderTypes.ORDER_MAINTAIN] = function()
        return GameInfo.Processes
    end,
}

local function orderNameAndHelp(orderType, data1)
    local tableFn = ORDER_INFO_TABLE[orderType]
    if tableFn == nil then
        return "", ""
    end
    local info = tableFn()[data1]
    if info == nil then
        return "", ""
    end
    local name = Text.key(info.Description)
    local help = info.Help and Text.key(info.Help) or ""
    return name, help
end

local function slotTurnsLeft(city, orderType, data1, zeroIdx)
    if orderType == OrderTypes.ORDER_TRAIN then
        return city:GetUnitProductionTurnsLeft(data1, zeroIdx)
    elseif orderType == OrderTypes.ORDER_CONSTRUCT then
        return city:GetBuildingProductionTurnsLeft(data1, zeroIdx)
    elseif orderType == OrderTypes.ORDER_CREATE then
        return city:GetProjectProductionTurnsLeft(data1, zeroIdx)
    end
    return -1
end

local function isGeneratingProduction(city)
    return city:GetCurrentProductionDifferenceTimes100(false, false) > 0
end

local function slotOneLabel(city, orderType, data1)
    local name, help = orderNameAndHelp(orderType, data1)
    if orderType == OrderTypes.ORDER_MAINTAIN then
        return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS", name, help)
    end
    local needed = city:GetProductionNeeded()
    local stored = city:GetProductionTimes100() / 100
    local pct = (needed > 0) and math.floor((stored / needed) * 100) or 0
    if isGeneratingProduction(city) then
        local turns = slotTurnsLeft(city, orderType, data1, 0)
        return Text.formatPlural("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN", turns, name, turns, pct, help)
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE", name, pct, help)
end

local function slotNLabel(city, displaySlot, zeroIdx, orderType, data1)
    local name = select(1, orderNameAndHelp(orderType, data1))
    if orderType == OrderTypes.ORDER_MAINTAIN then
        return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS", displaySlot, name)
    end
    if isGeneratingProduction(city) then
        local turns = slotTurnsLeft(city, orderType, data1, zeroIdx)
        return Text.formatPlural("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN", turns, displaySlot, name, turns)
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE", displaySlot, name)
end

local pushProductionQueue -- forward; the drill-in re-enters the queue list after a mutation.

-- After Move up / Move down / Remove: drop the drill-in and the queue
-- list without re-announcing either (reactivate=false on both), then
-- rebuild the list against the new queue order and re-enter it.
local function rebuildQueueAfterMutation()
    HandlerStack.removeByName("CityView.ProdActions", false)
    HandlerStack.removeByName("CityView.Production", false)
    pushProductionQueue()
end

local function pushQueueSlotActions(zeroIdx, slotName)
    local items = {}

    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    local qLength = city:GetOrderQueueLength()

    if zeroIdx > 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"),
            onActivate = function()
                if not isActiveOwn(UI.GetHeadSelectedCity()) then
                    refuseForeign("TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION")
                    return
                end
                if not isTurnActive() then
                    return
                end
                Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_SWAP_ORDER, zeroIdx - 1)
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"))
                rebuildQueueAfterMutation()
            end,
        })
    end

    if zeroIdx < qLength - 1 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"),
            onActivate = function()
                if not isActiveOwn(UI.GetHeadSelectedCity()) then
                    refuseForeign("TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION")
                    return
                end
                if not isTurnActive() then
                    return
                end
                Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_SWAP_ORDER, zeroIdx)
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"))
                rebuildQueueAfterMutation()
            end,
        })
    end

    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"),
        onActivate = function()
            if not isActiveOwn(UI.GetHeadSelectedCity()) then
                refuseForeign("TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION")
                return
            end
            if not isTurnActive() then
                return
            end
            Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_POP_ORDER, zeroIdx)
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"))
            rebuildQueueAfterMutation()
        end,
    })

    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"),
        onActivate = function()
            HandlerStack.removeByName("CityView.ProdActions", true)
        end,
    })

    CityViewHub.pushSub("ProdActions", Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS", slotName), items)
end

-- Rebuilt on every re-activation of the Production sub-handler so the slot
-- list matches the engine's queue after a Choose Production / Purchase popup
-- closes over it. Stable tags on the fixed-position entries let the re-
-- activation path restore the cursor onto the same role item after queue
-- length changes.
local function buildProductionQueueItems()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return {}
    end

    local items = {}

    local qLength = city:GetOrderQueueLength()
    if qLength == 0 then
        local empty = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY") })
        empty._stableTag = "empty"
        items[#items + 1] = empty
    else
        for i = 0, qLength - 1 do
            local zeroIdx = i
            local displaySlot = i + 1
            local item = BaseMenuItems.Text({
                labelFn = function()
                    local c = UI.GetHeadSelectedCity()
                    if c == nil then
                        return ""
                    end
                    local orderType, data1 = c:GetOrderFromQueue(zeroIdx)
                    if orderType == nil or orderType == -1 then
                        return ""
                    end
                    if zeroIdx == 0 then
                        return slotOneLabel(c, orderType, data1)
                    end
                    return slotNLabel(c, displaySlot, zeroIdx, orderType, data1)
                end,
                -- Pedia resolves live: the slot's identity shifts when the
                -- user reorders or removes entries. Only ORDER_TRAIN and
                -- ORDER_CONSTRUCT map to pediable entries (units and
                -- buildings); projects and processes are skipped (they have
                -- no Civilopedia entry in vanilla).
                pediaNameFn = function()
                    local c = UI.GetHeadSelectedCity()
                    if c == nil then
                        return nil
                    end
                    local orderType, data1 = c:GetOrderFromQueue(zeroIdx)
                    if orderType ~= OrderTypes.ORDER_TRAIN and orderType ~= OrderTypes.ORDER_CONSTRUCT then
                        return nil
                    end
                    return select(1, orderNameAndHelp(orderType, data1))
                end,
                onActivate = function()
                    local c = UI.GetHeadSelectedCity()
                    if c == nil then
                        return
                    end
                    local orderType, data1 = c:GetOrderFromQueue(zeroIdx)
                    if orderType == nil or orderType == -1 then
                        return
                    end
                    local slotName = select(1, orderNameAndHelp(orderType, data1))
                    pushQueueSlotActions(zeroIdx, slotName)
                end,
            })
            items[#items + 1] = item
        end
    end

    -- Queue mode toggle. GetCheck() reads vanilla's checkbox state; SetCheck
    -- + OnHideQueue(newVal) writes and fires vanilla's handler so the
    -- chunk-local `productionQueueOpen` tracks too.
    local toggle = BaseMenuItems.Text({
        labelFn = function()
            local on = Controls.HideQueueButton ~= nil and Controls.HideQueueButton:IsChecked()
            local state = Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
            return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE", state)
        end,
        onActivate = function(self, menu)
            -- Controls.HideQueueButton is a global UI flag, not per-city.
            -- Toggling from a spy-screen visit would mutate the user's own
            -- queue-mode setting permanently -- vanilla has no analogue
            -- (this toggle is mod-authored). Refuse on foreign.
            if not isActiveOwn(UI.GetHeadSelectedCity()) then
                refuseForeign("TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION")
                return
            end
            if Controls.HideQueueButton == nil then
                return
            end
            local newVal = not Controls.HideQueueButton:IsChecked()
            Controls.HideQueueButton:SetCheck(newVal)
            if type(OnHideQueue) == "function" then
                OnHideQueue(newVal)
            end
            SpeechPipeline.speakInterrupt(self:announce(menu))
        end,
    })
    toggle._stableTag = "queue_mode"
    items[#items + 1] = toggle

    local chooseProd = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"),
        onActivate = function()
            local c = UI.GetHeadSelectedCity()
            if c == nil then
                return
            end
            if not isActiveOwn(c) then
                refuseForeign("TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION")
                return
            end
            local queueModeOn = Controls.HideQueueButton ~= nil and Controls.HideQueueButton:IsChecked()
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION,
                Data1 = c:GetID(),
                Data2 = -1,
                Data3 = -1,
                Option1 = (queueModeOn and c:GetOrderQueueLength() > 0),
                Option2 = false,
            })
        end,
    })
    chooseProd._stableTag = "choose_production"
    items[#items + 1] = chooseProd

    local purchase = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"),
        onActivate = function()
            local c = UI.GetHeadSelectedCity()
            if c == nil then
                return
            end
            if not isActiveOwn(c) then
                refuseForeign("TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION")
                return
            end
            local queueModeOn = Controls.HideQueueButton ~= nil and Controls.HideQueueButton:IsChecked()
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION,
                Data1 = c:GetID(),
                Data2 = -1,
                Data3 = -1,
                Option1 = (queueModeOn and c:GetOrderQueueLength() > 0),
                Option2 = true,
            })
        end,
    })
    purchase._stableTag = "purchase"
    items[#items + 1] = purchase

    return items
end

pushProductionQueue = function()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end

    local items = buildProductionQueueItems()

    local handler = BaseMenu.create({
        name = "CityView.Production",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    })

    -- Re-expose after a Choose Production / Purchase popup (or a slot drill-
    -- in) rebuilds the item list against the current queue: setItems clamps
    -- cursor to the old numeric index, then _stableTag lookup steers it
    -- back onto the same role item when queue length shifted the fixed-
    -- position entries.
    --
    -- Deferred to next tick because Game.CityPushOrder's queue mutation
    -- isn't observable through city:GetOrderQueueLength() until the engine
    -- ticks past the current frame; a synchronous rebuild right after the
    -- popup hides reads qLen=0 and produces the same empty-queue list.
    -- origOnActivate still runs first so the cursor item announces now
    -- from the old list -- fixed-position entries (choose / purchase /
    -- toggle) carry identical labels across the rebuild, and the user's
    -- cursor can only sit on one of those when returning from the popup.
    -- First open (_initialized=false) skips the rebuild because
    -- pushProductionQueue built items fresh against the live queue a
    -- moment earlier.
    local origOnActivate = handler.onActivate
    handler.onActivate = function()
        local wasInitialized = handler._initialized
        origOnActivate()
        if not wasInitialized then
            return
        end
        TickPump.runOnce(function()
            local oldIdx = (handler._indices and handler._indices[1]) or 1
            local oldTag = items[oldIdx] and items[oldIdx]._stableTag
            items = buildProductionQueueItems()
            handler.setItems(items)
            if oldTag ~= nil then
                for i, it in ipairs(items) do
                    if it._stableTag == oldTag then
                        handler.setIndex(i)
                        break
                    end
                end
            end
        end)
    end

    HandlerStack.push(handler)
end

function CityViewProduction.push()
    pushProductionQueue()
end

return CityViewProduction

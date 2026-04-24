-- ChooseProduction popup accessibility. Wraps the in-game ProductionPopup
-- (BUTTONPOPUP_CHOOSEPRODUCTION) with a two-tab BaseMenu (Produce, Purchase),
-- five groups per tab (Units, Buildings, Wonders, Other, Current queue), and
-- a preamble that mirrors the sighted top panel.
--
-- Pure builders for entry construction / sort / cost / label composition live
-- in CivVAccess_ChooseProductionLogic. This file owns the install-side wiring:
-- state, preamble, commit paths, prev/next city hotkeys, and the event
-- intercept that rebuilds tabs on each popup fire.
--
-- Entry: Events.SerialEventGameMessagePopup filters by popupInfo.Type. On a
-- match we record the city ref, set the advisor recommender, rebuild both
-- tabs' items via setItems, and hint the opening tab via setInitialTabIndex
-- (Option2 on popupInfo picks Purchase as initial). The deferred push in
-- BaseMenu.install runs onActivate next tick so our setters land before
-- openInitial reads them.
--
-- Puppets auto-manage production; we short-circuit with a "puppet"
-- announcement and close the Context (matches base's silent bail at
-- ProductionPopup.lua:788-790).
--
-- Append mode (popupInfo.Option1, shift-click entry): each commit announces
-- "added, slot N in queue" with post-commit queue length; queue-full (6)
-- closes the popup with a "queue full" announcement. Purchase tab ignores
-- append -- purchases always commit and close.
--
-- Prev / next city (comma / period) cycle via Game.DoControl, close the
-- current popup, and re-fire SerialEventGameMessagePopup for the new
-- selection so our intercept rebuilds against the new city.

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
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_CitySpeech")
include("CivVAccess_ChooseProductionLogic")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Windows VK codes for ',' / '.'. Keys.VK_OEM_COMMA / _PERIOD are not exposed
-- by the engine's Keys table; CityView's prev/next city hotkeys use the same
-- numeric-literal workaround.
local VK_OEM_COMMA = 188
local VK_OEM_PERIOD = 190

local TAB_PRODUCE = 1
local TAB_PURCHASE = 2

-- Populated on each SerialEventGameMessagePopup match; re-read by every
-- item / preamble / commit path so the city pointer stays fresh (the game-
-- core thread may invalidate city userdata across frames).
local _popupInfo = nil
local _cityOwnerID = -1
local _cityID = -1
local _appendMode = false

local function getCurrentCity()
    if _cityOwnerID < 0 or _cityID < 0 then
        return nil
    end
    local player = Players[_cityOwnerID]
    if player == nil then
        return nil
    end
    return player:GetCityByID(_cityID)
end

-- ===== Preamble =====
--
-- Re-evaluated on first open and on F1 (readHeader). Turn ticks don't fire
-- while the popup is up in single-player so snapshotting is fine. Status /
-- growth / production / connected tokens come from CitySpeech.

local function preambleFn()
    local city = getCurrentCity()
    if city == nil then
        return ""
    end
    local parts = {}
    parts[#parts + 1] = city:GetName()
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_POPULATION", city:GetPopulation())
    parts[#parts + 1] = CitySpeech.growthToken(city)
    if _appendMode then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT", city:GetOrderQueueLength())
    else
        parts[#parts + 1] = CitySpeech.productionToken(city)
    end
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD", city:FoodDifference())
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION", city:GetYieldRate(YieldTypes.YIELD_PRODUCTION))
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE", city:GetYieldRate(YieldTypes.YIELD_SCIENCE))
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD", city:GetYieldRate(YieldTypes.YIELD_GOLD))
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE", city:GetYieldRate(YieldTypes.YIELD_CULTURE))
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH", city:GetYieldRate(YieldTypes.YIELD_FAITH))
    for _, t in ipairs(CitySpeech.statusTokens(city)) do
        parts[#parts + 1] = t
    end
    local connected = CitySpeech.connectedToken(city)
    if connected ~= nil then
        parts[#parts + 1] = connected
    end
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_DEFENSE", math.floor(city:GetStrengthValue() / 100))
    return table.concat(parts, ". ") .. "."
end

-- ===== Commit =====

local function fireBannerDirty(city)
    local owner = city:GetOwner()
    local cid = city:GetID()
    Events.SpecificCityInfoDirty(owner, cid, CityUpdateTypes.CITY_UPDATE_TYPE_BANNER)
    Events.SpecificCityInfoDirty(owner, cid, CityUpdateTypes.CITY_UPDATE_TYPE_PRODUCTION)
end

local function commitProduce(city, entry)
    Game.CityPushOrder(city, entry.orderType, entry.id, false, not _appendMode, true)
    fireBannerDirty(city)
    if not _appendMode then
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING", Text.key(entry.info.Description)))
        OnClose()
        return
    end
    local qLen = city:GetOrderQueueLength()
    if qLen >= 6 then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"))
        OnClose()
        return
    end
    SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT", qLen))
end

local function commitPurchase(city, entry)
    local canPurchase = false
    if entry.orderType == OrderTypes.ORDER_TRAIN then
        canPurchase = city:IsCanPurchase(true, true, entry.id, -1, -1, entry.yieldType)
        if canPurchase then
            Game.CityPurchaseUnit(city, entry.id, entry.yieldType)
        end
    elseif entry.orderType == OrderTypes.ORDER_CONSTRUCT then
        canPurchase = city:IsCanPurchase(true, true, -1, entry.id, -1, entry.yieldType)
        if canPurchase then
            Game.CityPurchaseBuilding(city, entry.id, entry.yieldType)
        end
    elseif entry.orderType == OrderTypes.ORDER_CREATE then
        canPurchase = city:IsCanPurchase(true, true, -1, -1, entry.id, entry.yieldType)
        if canPurchase then
            Game.CityPurchaseProject(city, entry.id, entry.yieldType)
        end
    end
    if not canPurchase then
        Log.error("ChooseProductionPopupAccess: purchase failed IsCanPurchase at commit; id=" .. tostring(entry.id) .. " yield=" .. tostring(entry.yieldType))
        return
    end
    fireBannerDirty(city)
    Events.AudioPlay2DSound("AS2D_INTERFACE_CITY_SCREEN_PURCHASE")
    SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED", Text.key(entry.info.Description)))
    OnClose()
end

local function entryActivate(entry)
    return function()
        local city = getCurrentCity()
        if city == nil then
            Log.error("ChooseProductionPopupAccess: activate with no current city")
            return
        end
        if ChooseProductionLogic.isEntryDisabled(city, entry) then
            return
        end
        if entry.isProduce then
            commitProduce(city, entry)
        else
            commitPurchase(city, entry)
        end
    end
end

-- ===== Entry -> Choice item =====

local function choiceFromEntry(entry)
    return BaseMenuItems.Choice({
        labelFn = function()
            local city = getCurrentCity()
            if city == nil then
                return Text.key(entry.info.Description)
            end
            return ChooseProductionLogic.buildLabel(entry, city)
        end,
        activate = entryActivate(entry),
        pediaName = Locale.ConvertTextKey(entry.info.Description),
    })
end

local function entriesToItems(entries)
    local items = {}
    for _, e in ipairs(entries) do
        items[#items + 1] = choiceFromEntry(e)
    end
    return items
end

-- ===== Queue group =====
--
-- Read-only list of slots. Drill-in label is item name + turns; no slot-
-- position prefix (positional counts are disallowed by the concise-
-- announcement rule). Empty queue shows a single "queue is empty" text.

local function buildQueueItems(city)
    local qLen = city:GetOrderQueueLength()
    if qLen == 0 then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY") }) }
    end
    local items = {}
    for i = 1, qLen do
        local orderType, data1 = city:GetOrderFromQueue(i - 1)
        local name
        local turns
        if orderType == OrderTypes.ORDER_TRAIN then
            name = Text.key(GameInfo.Units[data1].Description)
            turns = city:GetUnitProductionTurnsLeft(data1, i - 1)
        elseif orderType == OrderTypes.ORDER_CONSTRUCT then
            name = Text.key(GameInfo.Buildings[data1].Description)
            turns = city:GetBuildingProductionTurnsLeft(data1, i - 1)
        elseif orderType == OrderTypes.ORDER_CREATE then
            name = Text.key(GameInfo.Projects[data1].Description)
            turns = city:GetProjectProductionTurnsLeft(data1, i - 1)
        elseif orderType == OrderTypes.ORDER_MAINTAIN then
            name = Text.key(GameInfo.Processes[data1].Description)
            turns = nil
        end
        local label
        if turns ~= nil then
            label = Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT", name, turns)
        else
            label = Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS", name)
        end
        items[#items + 1] = BaseMenuItems.Text({ labelText = label })
    end
    return items
end

-- ===== Tab items =====
--
-- Both tabs carry the same five groups with cached=false so a drill-in
-- re-evaluates the predicate sweep each time (avoids stale lists after
-- back-out / tab switch / back-in). The advisor recommender is re-set per
-- itemsFn so IsXxxRecommended reflects the current city after a prev/next
-- cycle.

local function makeGroups(isProduce)
    local function withCity(fn)
        return function()
            local city = getCurrentCity()
            if city == nil then
                return {}
            end
            Game.SetAdvisorRecommenderCity(city)
            return fn(city)
        end
    end
    return {
        BaseMenuItems.Group({
            textKey = "TXT_KEY_POP_UNITS",
            cached = false,
            itemsFn = withCity(function(city)
                return entriesToItems(ChooseProductionLogic.buildUnitEntries(city, isProduce))
            end),
        }),
        BaseMenuItems.Group({
            textKey = "TXT_KEY_POP_BUILDINGS",
            cached = false,
            itemsFn = withCity(function(city)
                local b, _ = ChooseProductionLogic.buildBuildingAndWonderEntries(city, isProduce)
                return entriesToItems(b)
            end),
        }),
        BaseMenuItems.Group({
            textKey = "TXT_KEY_POP_WONDERS",
            cached = false,
            itemsFn = withCity(function(city)
                local _, w = ChooseProductionLogic.buildBuildingAndWonderEntries(city, isProduce)
                return entriesToItems(w)
            end),
        }),
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CITYVIEW_OTHER",
            cached = false,
            itemsFn = withCity(function(city)
                return entriesToItems(ChooseProductionLogic.buildOtherEntries(city, isProduce))
            end),
        }),
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE",
            cached = false,
            itemsFn = withCity(buildQueueItems),
        }),
    }
end

-- ===== BaseMenu install =====

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseProductionPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"),
    preamble = preambleFn,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    tabs = {
        { name = "TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE", items = {} },
        { name = "TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE", items = {} },
    },
})

-- ===== Prev / next city =====
--
-- Closes the current popup and re-fires SerialEventGameMessagePopup with the
-- new city id. Our listener rebuilds tabs against the new city. Engine-native
-- cycle includes puppets; on a puppet the intercept's puppet branch fires
-- "puppet" and closes, and the user re-presses to advance.

local function announceNoCycle(direction)
    if direction == "next" then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"))
    else
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"))
    end
end

local function cycleCity(direction)
    local player = Players[Game.GetActivePlayer()]
    if player == nil or player:GetNumCities() <= 1 then
        announceNoCycle(direction)
        return
    end
    local control = (direction == "next") and GameInfoTypes.CONTROL_NEXTCITY or GameInfoTypes.CONTROL_PREVCITY
    Game.DoControl(control)
    local newCity = UI.GetHeadSelectedCity()
    if newCity == nil then
        Log.warn("ChooseProductionPopupAccess: cycle city returned no selection")
        return
    end
    local opt1 = _popupInfo and _popupInfo.Option1 or false
    local opt2 = _popupInfo and _popupInfo.Option2 or false
    OnClose()
    Events.SerialEventGameMessagePopup({
        Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION,
        Data1 = newCity:GetID(),
        Option1 = opt1,
        Option2 = opt2,
    })
end

table.insert(mainHandler.bindings, {
    key = VK_OEM_COMMA,
    mods = 0,
    description = "Previous city",
    fn = function() cycleCity("prev") end,
})
table.insert(mainHandler.bindings, {
    key = VK_OEM_PERIOD,
    mods = 0,
    description = "Next city",
    fn = function() cycleCity("next") end,
})

-- ===== Popup intercept =====

-- Puppet-city gate. Base's handling at ProductionPopup.lua:1067-1073 is: any
-- puppet bails silently, EXCEPT Venice (MayNotAnnex) in Purchase mode, which
-- can still spend gold on a puppet. We match that: Venice-on-puppet with
-- Option2=true opens Purchase-only (the Produce tab will naturally come back
-- empty because CanTrain / CanConstruct / CanMaintain all return false for
-- puppets, and the engine's sighted popup relies on the same filters).
local function isVenicePuppetEntry(player, city, popupInfo)
    return city:IsPuppet() and player:MayNotAnnex() and popupInfo.Option2 == true
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION then
        return
    end
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return
    end
    local city = player:GetCityByID(popupInfo.Data1)
    if city == nil then
        return
    end
    if city:IsPuppet() and not isVenicePuppetEntry(player, city, popupInfo) then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"))
        OnClose()
        return
    end

    _popupInfo = popupInfo
    _cityOwnerID = city:GetOwner()
    _cityID = city:GetID()
    _appendMode = popupInfo.Option1 == true

    Game.SetAdvisorRecommenderCity(city)

    mainHandler.setItems(makeGroups(true), TAB_PRODUCE)
    mainHandler.setItems(makeGroups(false), TAB_PURCHASE)
    -- Venice on a puppet forces Purchase regardless of Option2 (Produce is
    -- empty-by-engine-rule there). Otherwise Option2 picks the opening tab.
    local initialTab
    if isVenicePuppetEntry(player, city, popupInfo) then
        initialTab = TAB_PURCHASE
    elseif popupInfo.Option2 == true then
        initialTab = TAB_PURCHASE
    else
        initialTab = TAB_PRODUCE
    end
    mainHandler.setInitialTabIndex(initialTab)
end)

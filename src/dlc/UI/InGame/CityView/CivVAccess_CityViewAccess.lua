-- CityView accessibility. Hub handler for the city management screen.
--
-- Opens when the engine shows the CityView Context (banner click on own
-- city, Enter on a friendly hex, etc.). Every section of the screen is
-- reached through a sub-handler pushed on top of this hub. This phase
-- wires only the hub scaffold: preamble announcement, F1 re-read, Esc
-- close, next / previous city hotkeys, and auto-re-announce on
-- city-change. Hub items and sub-handlers are added in later phases.
--
-- SerialEventCityScreenDirty fires on city switches AND on turn ticks
-- while the screen is up. A city-ID compare filters out the turn-tick
-- case so only real city changes re-announce.

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

local priorInput = InputHandler

-- Windows VK codes for ',' / '.'. Civ V's Keys table doesn't expose
-- VK_OEM_COMMA / VK_OEM_PERIOD; UnitControl uses the same numeric-literal
-- workaround.
local VK_OEM_COMMA = 188
local VK_OEM_PERIOD = 190

local hubHandler -- forward; assigned after BaseMenu.install returns.

-- ===== Preamble composition =====
--
-- Re-resolved on every F1 / city-change so stale data can't leak. Matches
-- the banner's icon cascade for status tokens (CityBannerManager.lua)
-- and adds "connected" because the top panel's connected icon is a
-- CityView-only concern (the cursor's identity glance doesn't surface it).

local function statusTokens(city)
    local parts = {}
    if city:IsRazing() then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_RAZING", city:GetRazingTurns())
    end
    if city:IsResistance() then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_RESISTANCE", city:GetResistanceTurns())
    end
    if city:IsOccupied() and not city:IsNoOccupiedUnhappiness() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_OCCUPIED")
    end
    if city:IsPuppet() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_PUPPET")
    end
    if city:IsBlockaded() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_BLOCKADED")
    end
    local owner = Players[city:GetOwner()]
    if
        owner ~= nil
        and not city:IsCapital()
        and owner:IsCapitalConnectedToCity(city)
        and not city:IsBlockaded()
    then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_CONNECTED")
    end
    return parts
end

-- Growth line mirrors CitySpeech.development's fork: stopped growing when
-- food-production or zero net food, starving when negative, else the
-- turns-to-grow format key.
local function growthToken(city)
    local foodDiff100 = city:FoodDifferenceTimes100()
    if city:IsFoodProduction() or foodDiff100 == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING")
    end
    if foodDiff100 < 0 then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_STARVING")
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITY_GROWS_IN", city:GetFoodTurnsLeft())
end

local function productionToken(city)
    local prodKey = city:GetProductionNameKey()
    if prodKey == nil or prodKey == "" then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING")
    end
    if city:IsProductionProcess() then
        return Text.format("TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS", Text.key(prodKey))
    end
    local turnsLeft = 0
    if city:GetCurrentProductionDifferenceTimes100(false, false) > 0 then
        turnsLeft = city:GetProductionTurnsLeft()
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITY_PRODUCING", Text.key(prodKey), turnsLeft)
end

-- Per-turn yields in the order the plan lists (food, production, gold,
-- science, faith, tourism, culture). Food uses net FoodDifference so the
-- user hears the starvation-adjusted number; tourism uses GetBaseTourism
-- scaled down /100 to match the banner's displayed integer.
local function yieldTokens(city)
    return {
        Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD", city:FoodDifference()),
        Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION", city:GetYieldRate(YieldTypes.YIELD_PRODUCTION)),
        Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD", city:GetYieldRate(YieldTypes.YIELD_GOLD)),
        Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE", city:GetYieldRate(YieldTypes.YIELD_SCIENCE)),
        Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH", city:GetYieldRate(YieldTypes.YIELD_FAITH)),
        Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM", math.floor(city:GetBaseTourism() / 100)),
        Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE", city:GetYieldRate(YieldTypes.YIELD_CULTURE)),
    }
end

local function preamble()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return ""
    end
    local parts = {}
    parts[#parts + 1] = city:GetName()
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_POPULATION", city:GetPopulation())
    parts[#parts + 1] = growthToken(city)
    parts[#parts + 1] = productionToken(city)
    for _, t in ipairs(yieldTokens(city)) do
        parts[#parts + 1] = t
    end
    for _, t in ipairs(statusTokens(city)) do
        parts[#parts + 1] = t
    end
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_DEFENSE", math.floor(city:GetStrengthValue() / 100))
    parts[#parts + 1] =
        Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED", city:GetSpecialistCount(GameDefines.DEFAULT_SPECIALIST))
    return table.concat(parts, ". ") .. "."
end

-- ===== City navigation hotkeys =====
-- Comma / period are unbound in CIV5 control catalogs and neither NVDA nor
-- JAWS claims them, so layering on top is safe. Uses the same DoControl
-- path the vanilla banner arrows use (CityView.lua:2389) so the engine
-- fires SerialEventCityScreenDirty afterwards and our listener re-announces.
-- Pre-check city count because DoControl is silent when nothing to cycle
-- to, and the Dirty listener only fires on a real switch -- without a
-- guard, pressing `.` in a one-city empire would produce dead silence.
local function hasOtherCities()
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return false
    end
    return player:GetNumCities() > 1
end

local function nextCity()
    if not hasOtherCities() then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"))
        return
    end
    Game.DoControl(GameInfoTypes.CONTROL_NEXTCITY)
end

local function previousCity()
    if not hasOtherCities() then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"))
        return
    end
    Game.DoControl(GameInfoTypes.CONTROL_PREVCITY)
end

-- ===== SerialEventCityScreenDirty listener =====
--
-- Fires on city switches AND on turn ticks while the CityView Context is
-- visible. A city-ID compare filters turn ticks; ContextPtr:IsHidden()
-- filters pre-show firings (the engine fires Dirty when selecting a city
-- BEFORE the Context visibility flips, so we'd otherwise announce before
-- the screen is up).

local _lastCityID = nil

local function onCityScreenDirty()
    if ContextPtr:IsHidden() then
        return
    end
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    local id = city:GetID()
    if id == _lastCityID then
        return
    end
    _lastCityID = id
    if hubHandler == nil then
        return
    end
    HandlerStack.popAbove(hubHandler)
    hubHandler.readHeader()
end

-- Register once per lua_State. The closure reads civvaccess_shared's impl
-- slot, so each CityView Context load overwrites the impl pointer and the
-- listener keeps firing against the current Context's bindings (same
-- idiom Boot.lua uses for LoadScreenClose).
civvaccess_shared.cityViewDirtyImpl = onCityScreenDirty
if not civvaccess_shared.cityViewDirtyListenerInstalled then
    civvaccess_shared.cityViewDirtyListenerInstalled = true
    if Events ~= nil and Events.SerialEventCityScreenDirty ~= nil then
        Events.SerialEventCityScreenDirty.Add(function()
            local f = civvaccess_shared.cityViewDirtyImpl
            if f == nil then
                return
            end
            local ok, err = pcall(f)
            if not ok then
                Log.error("CivVAccess_CityViewAccess: onCityScreenDirty failed: " .. tostring(err))
            end
        end)
        Log.info("CivVAccess_CityViewAccess: registered SerialEventCityScreenDirty listener")
    else
        Log.warn("CivVAccess_CityViewAccess: Events.SerialEventCityScreenDirty missing")
    end
end

-- ShowHide wrapper: on hide, pop anything the user stacked on top of the
-- hub (future phases' sub-handlers) so their onDeactivate fires before
-- install's own removeByName drops the hub. On show, stamp _lastCityID so
-- a same-frame Dirty fire doesn't double-announce the header over
-- BaseMenu's first-open announce.
local function wrappedShowHide(bIsHide, _bIsInit)
    if bIsHide then
        if hubHandler ~= nil then
            HandlerStack.popAbove(hubHandler)
        end
        _lastCityID = nil
        return
    end
    local city = UI.GetHeadSelectedCity()
    _lastCityID = (city ~= nil) and city:GetID() or nil
end

-- ===== Hub item helpers =====
--
-- Hub items don't map to a base CityView Control, so the standard Button
-- factory (which resolves via Controls[controlName] and becomes non-
-- navigable when the control is missing) doesn't apply. We start from a
-- Text item, which is always navigable, and override activate to push a
-- sub-handler or fire an engine task. labelFn lets the label reflect live
-- state (unemployed count, focus selection) without rebuilding the item.

local function makeHubItem(spec, activateFn)
    local item = BaseMenuItems.Text(spec)
    item.activate = function(self, menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local ok, err = pcall(activateFn, self, menu)
        if not ok then
            Log.error("CityView hub activate failed: " .. tostring(err))
        end
    end
    return item
end

local function isTurnActive()
    return Players[Game.GetActivePlayer()]:IsTurnActive()
end

-- ===== Wonders sub-handler (§3.8) =====
--
-- Flat read-only list of wonders built in this city. Wonder detection
-- mirrors CityView.lua:1386 (world wonders via MaxGlobalInstances, national
-- wonders via MaxPlayerInstances==1 with no specialists, team wonders via
-- MaxTeamInstances). Enter is a no-op (plan §3.8: wonders are permanent
-- and indestructible); tooltip carries the effect summary.

local function isWonderBuilding(building)
    local bclass = GameInfo.BuildingClasses[building.BuildingClass]
    if bclass == nil then
        return false
    end
    if bclass.MaxGlobalInstances > 0 then
        return true
    end
    if bclass.MaxPlayerInstances == 1 and (building.SpecialistCount or 0) == 0 then
        return true
    end
    if bclass.MaxTeamInstances > 0 then
        return true
    end
    return false
end

local function cityHasAnyWonder(city)
    for building in GameInfo.Buildings() do
        if isWonderBuilding(building) and city:IsHasBuilding(building.ID) then
            return true
        end
    end
    return false
end

local function pushWonders()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    local wonders = {}
    for building in GameInfo.Buildings() do
        if isWonderBuilding(building) and city:IsHasBuilding(building.ID) then
            local name = Locale.ConvertTextKey(building.Description)
            local help = building.Help and Locale.ConvertTextKey(building.Help) or ""
            wonders[#wonders + 1] = { name = name, help = help }
        end
    end
    table.sort(wonders, function(a, b)
        return Locale.Compare(a.name, b.name) == -1
    end)
    local items = {}
    if #wonders == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY") })
    else
        for _, w in ipairs(wonders) do
            items[#items + 1] = BaseMenuItems.Text({
                labelText = w.name,
                tooltipText = (w.help ~= "") and w.help or nil,
            })
        end
    end
    HandlerStack.push(BaseMenu.create({
        name = "CityView.Wonders",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

-- ===== Great people progress sub-handler (§3.9) =====
--
-- One item per specialist type that has non-zero progress (matching the
-- base screen's own "iProgress > 0" filter). Output is "<class name>,
-- <progress> of <threshold>" -- threshold via GetSpecialistUpgradeThreshold
-- on the UnitClass's default unit, same source the base GPMeter uses.

local function cityHasAnyGreatPersonProgress(city)
    for specialistInfo in GameInfo.Specialists() do
        if city:GetSpecialistGreatPersonProgress(specialistInfo.ID) > 0 then
            return true
        end
    end
    return false
end

local function pushGreatPeople()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    local items = {}
    for specialistInfo in GameInfo.Specialists() do
        local iProgress = city:GetSpecialistGreatPersonProgress(specialistInfo.ID)
        if iProgress > 0 then
            local unitClass = GameInfo.UnitClasses[specialistInfo.GreatPeopleUnitClass]
            if unitClass ~= nil then
                local threshold = city:GetSpecialistUpgradeThreshold(unitClass.ID)
                local name = Locale.ConvertTextKey(unitClass.Description)
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY", name, iProgress, threshold),
                })
            end
        end
    end
    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY") })
    end
    HandlerStack.push(BaseMenu.create({
        name = "CityView.GreatPeople",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

-- ===== Worker focus sub-handler (§3.11) =====
--
-- Eight radio entries + Avoid Growth checkbox + Reset button. Each
-- radio uses labelFn so the ", selected" marker tracks the live focus
-- after a change -- the item doesn't need rebuilding, the label just
-- re-reads on every navigate. Avoid Growth's label follows the same
-- pattern so the checkbox state is in-band too. Reset label is static.
--
-- Tasks: SendSetCityAIFocus / SendSetCityAvoidGrowth for the radio and
-- checkbox, TASK_CHANGE_WORKING_PLOT with plotIdx=0 for reset (the
-- engine's documented "reset all forced tiles" escape hatch, used by
-- CityView.lua:2619).

local FOCUS_TYPES = {
    { focus = CityAIFocusTypes.NO_CITY_AI_FOCUS_TYPE,           key = "TXT_KEY_CITYVIEW_FOCUS_BALANCED_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FOOD,         key = "TXT_KEY_CITYVIEW_FOCUS_FOOD_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_PRODUCTION,   key = "TXT_KEY_CITYVIEW_FOCUS_PROD_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GOLD,         key = "TXT_KEY_CITYVIEW_FOCUS_GOLD_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_SCIENCE,      key = "TXT_KEY_CITYVIEW_FOCUS_RESEARCH_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_CULTURE,      key = "TXT_KEY_CITYVIEW_FOCUS_CULTURE_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GREAT_PEOPLE, key = "TXT_KEY_CITYVIEW_FOCUS_GREAT_PERSON_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FAITH,        key = "TXT_KEY_CITYVIEW_FOCUS_FAITH_TEXT" },
}

local function pushWorkerFocus()
    local items = {}
    for _, f in ipairs(FOCUS_TYPES) do
        local labelKey, focusType = f.key, f.focus
        local item = BaseMenuItems.Text({
            labelFn = function()
                local city = UI.GetHeadSelectedCity()
                if city ~= nil and city:GetFocusType() == focusType then
                    return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED", Text.key(labelKey))
                end
                return Text.key(labelKey)
            end,
        })
        item.activate = function(self, _menu)
            Events.AudioPlay2DSound("AS2D_IF_SELECT")
            local city = UI.GetHeadSelectedCity()
            if city == nil or not isTurnActive() then
                return
            end
            Network.SendSetCityAIFocus(city:GetID(), focusType)
            SpeechPipeline.speakInterrupt(
                Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED", Text.key(labelKey))
            )
        end
        items[#items + 1] = item
    end

    local avoidItem = BaseMenuItems.Text({
        labelFn = function()
            local city = UI.GetHeadSelectedCity()
            local on = (city ~= nil) and city:IsForcedAvoidGrowth()
            local state = Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
            return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH", state)
        end,
    })
    avoidItem.activate = function(self, menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local city = UI.GetHeadSelectedCity()
        if city == nil or not isTurnActive() then
            return
        end
        Network.SendSetCityAvoidGrowth(city:GetID(), not city:IsForcedAvoidGrowth())
        -- The Network call is async; speak the item's label after (labelFn
        -- reads IsForcedAvoidGrowth which won't flip until the engine
        -- applies the task). Tolerable: the engine applies locally in
        -- single-player before the next announce, and multiplayer briefly
        -- shows the previous state until the commit -- same delay a sighted
        -- player sees on the checkbox.
        SpeechPipeline.speakInterrupt(avoidItem:announce(menu))
    end
    items[#items + 1] = avoidItem

    local resetItem = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"),
    })
    resetItem.activate = function(self, _menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local city = UI.GetHeadSelectedCity()
        if city == nil or not isTurnActive() then
            return
        end
        Network.SendDoTask(city:GetID(), TaskTypes.TASK_CHANGE_WORKING_PLOT, 0, -1, false, false, false, false)
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"))
    end
    items[#items + 1] = resetItem

    HandlerStack.push(BaseMenu.create({
        name = "CityView.WorkerFocus",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

-- ===== Unemployed citizens (§3.10) =====
--
-- Hub-level action, not a sub-handler. Label carries the live count so
-- the user hears it on arrowing past without drilling in. Enter fires
-- TASK_REMOVE_SLACKER (misnamed in the engine; it assigns one citizen to
-- the best tile or specialist slot). The engine does not expose where
-- the citizen went and the vanilla UI doesn't show it either; we speak
-- "assigned" rather than inventing a destination.

local function unemployedLabel()
    local city = UI.GetHeadSelectedCity()
    local count = (city ~= nil) and city:GetSpecialistCount(GameDefines.DEFAULT_SPECIALIST) or 0
    return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION", count)
end

local function activateUnemployed()
    local city = UI.GetHeadSelectedCity()
    if city == nil or not isTurnActive() then
        return
    end
    if city:GetSpecialistCount(GameDefines.DEFAULT_SPECIALIST) <= 0 then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"))
        return
    end
    Network.SendDoTask(city:GetID(), TaskTypes.TASK_REMOVE_SLACKER, 0, -1, false, false, false, false)
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"))
end

-- ===== Buildings sub-handler (§3.7) =====
--
-- Flat list of non-wonder buildings constructed in this city. Enter opens
-- a drill-in action menu with Sell (when sellable and not puppet) and Back.
-- Sell pushes a modal confirm that speaks the engine's TXT_KEY_SELL_BUILDING_INFO
-- so blind and sighted users land on the same confirmation wording.
-- Y / Enter confirms and fires Network.SendSellBuilding, then pops back
-- to the hub so the Buildings list rebuilds; N / Esc cancels.
--
-- The engine's inline SellBuildingConfirm overlay is NOT driven here --
-- we bypass it and go straight to the network message. A sighted observer
-- wouldn't see a confirmation; acceptable because sighted users open the
-- CityView via mouse, and this path only fires from our keyboard flow.

local function makeSellConfirmHandler(buildingID, buildingName)
    local function dismiss(reactivate)
        HandlerStack.removeByName("CityView.SellConfirm", reactivate ~= false)
    end
    local function pressYes()
        local city = UI.GetHeadSelectedCity()
        if city ~= nil and isTurnActive() then
            Network.SendSellBuilding(city:GetID(), buildingID)
        end
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SELL_DONE"))
        -- Pop the modal, the drill-in, and the Buildings sub back to the
        -- hub; the hub's onActivate rebuilds items so the sold building
        -- drops from the list.
        if hubHandler ~= nil then
            HandlerStack.popAbove(hubHandler)
        else
            dismiss()
        end
    end
    local function pressNo()
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SELL_CANCELLED"))
        dismiss()
    end
    return {
        name = "CityView.SellConfirm",
        capturesAllInput = true,
        bindings = {
            { key = Keys.Y, mods = 0, description = "Confirm", fn = pressYes },
            { key = Keys.VK_RETURN, mods = 0, description = "Confirm", fn = pressYes },
            { key = Keys.N, mods = 0, description = "Cancel", fn = pressNo },
            { key = Keys.VK_ESCAPE, mods = 0, description = "Cancel", fn = pressNo },
        },
        helpEntries = {},
        onActivate = function(_self)
            local city = UI.GetHeadSelectedCity()
            if city == nil then
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SELL_CONFIRM"))
                return
            end
            local refund = city:GetSellBuildingRefund(buildingID)
            local row = GameInfo.Buildings[buildingID]
            local maint = (row ~= nil and row.GoldMaintenance) or 0
            SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_SELL_BUILDING_INFO", refund, maint))
            SpeechPipeline.speakQueued(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SELL_YES"))
        end,
    }
end

local function pushBuildingActions(city, buildingID, buildingName)
    local items = {}
    if city:IsBuildingSellable(buildingID) and not city:IsPuppet() then
        local refund = city:GetSellBuildingRefund(buildingID)
        local sellItem = BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_BUILDING_SELL", refund),
        })
        sellItem.activate = function(_self, _menu)
            Events.AudioPlay2DSound("AS2D_IF_SELECT")
            if not isTurnActive() then
                return
            end
            HandlerStack.push(makeSellConfirmHandler(buildingID, buildingName))
        end
        items[#items + 1] = sellItem
    end
    local backItem = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_BUILDING_BACK") })
    backItem.activate = function(_self, _menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        HandlerStack.removeByName("CityView.BuildingActions", true)
    end
    items[#items + 1] = backItem

    HandlerStack.push(BaseMenu.create({
        name = "CityView.BuildingActions",
        displayName = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_BUILDING_ACTIONS", buildingName),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

local function pushBuildings()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    local buildings = {}
    for building in GameInfo.Buildings() do
        if city:IsHasBuilding(building.ID) and not isWonderBuilding(building) then
            local name = Locale.ConvertTextKey(building.Description)
            local help = building.Help and Locale.ConvertTextKey(building.Help) or ""
            buildings[#buildings + 1] = { id = building.ID, name = name, help = help }
        end
    end
    table.sort(buildings, function(a, b)
        return Locale.Compare(a.name, b.name) == -1
    end)

    local items = {}
    if #buildings == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY") })
    else
        for _, b in ipairs(buildings) do
            local capturedID = b.id
            local capturedName = b.name
            local item = BaseMenuItems.Text({
                labelText = b.name,
                tooltipText = (b.help ~= "") and b.help or nil,
            })
            item.activate = function(_self, _menu)
                Events.AudioPlay2DSound("AS2D_IF_SELECT")
                local liveCity = UI.GetHeadSelectedCity()
                if liveCity == nil then
                    return
                end
                pushBuildingActions(liveCity, capturedID, capturedName)
            end
            items[#items + 1] = item
        end
    end

    HandlerStack.push(BaseMenu.create({
        name = "CityView.Buildings",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

local function cityHasAnyNonWonderBuilding(city)
    for building in GameInfo.Buildings() do
        if city:IsHasBuilding(building.ID) and not isWonderBuilding(building) then
            return true
        end
    end
    return false
end

-- ===== Specialists sub-handler (§3.6) =====
--
-- One item per specialist slot across every specialist-capable building
-- in the city, grouped by building in the label (plan-mandated shape).
-- labelFn flips "empty" / "filled" on the next read, so the state stays
-- current across Enter-driven add / remove without rebuilding the list.
-- A Manual Specialist Control toggle lands at the bottom; its checkbox
-- state mirrors pCity:IsNoAutoAssignSpecialists().
--
-- Add / remove mirror CityView's AddSpecialist / RemoveSpecialist helpers
-- (CityView.lua:2341-2385): auto-flip TASK_NO_AUTO_ASSIGN_SPECIALISTS on
-- first action, then fire TASK_ADD_SPECIALIST / TASK_REMOVE_SPECIALIST.
-- Post-action announcement compares the pre / post unemployed pool count
-- across a one-tick delay: -1 / +1 delta = pool source (short form);
-- 0 delta = engine pulled / placed a tile worker (long form explaining
-- the tile reassignment, which is otherwise invisible to the user).

local function cityHasAnySpecialistSlots(city)
    for building in GameInfo.Buildings() do
        if city:IsHasBuilding(building.ID) and city:GetNumSpecialistsAllowedByBuilding(building.ID) > 0 then
            return true
        end
    end
    return false
end

local function pushSpecialists()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end

    local specBuildings = {}
    for building in GameInfo.Buildings() do
        if city:IsHasBuilding(building.ID) then
            local slots = city:GetNumSpecialistsAllowedByBuilding(building.ID)
            if slots > 0 then
                specBuildings[#specBuildings + 1] = {
                    id = building.ID,
                    name = Locale.ConvertTextKey(building.Description),
                    slots = slots,
                    specialistType = building.SpecialistType,
                }
            end
        end
    end
    table.sort(specBuildings, function(a, b)
        return Locale.Compare(a.name, b.name) == -1
    end)

    local items = {}
    for _, sb in ipairs(specBuildings) do
        local specialistInfo = GameInfo.Specialists[sb.specialistType]
        if specialistInfo ~= nil then
            local specID = specialistInfo.ID
            local specName = Locale.ConvertTextKey(specialistInfo.Description)
            local bID, bName = sb.id, sb.name
            for slotIdx = 1, sb.slots do
                local capturedSlot = slotIdx
                local item = BaseMenuItems.Text({
                    labelFn = function()
                        local c = UI.GetHeadSelectedCity()
                        if c == nil then
                            return ""
                        end
                        local count = c:GetNumSpecialistsInBuilding(bID)
                        local stateKey = (capturedSlot <= count)
                                and "TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"
                            or "TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"
                        return Text.format(
                            "TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT",
                            bName,
                            specName,
                            capturedSlot,
                            Text.key(stateKey)
                        )
                    end,
                })
                item.activate = function(_self, _menu)
                    Events.AudioPlay2DSound("AS2D_IF_SELECT")
                    local c = UI.GetHeadSelectedCity()
                    if c == nil or not isTurnActive() then
                        return
                    end
                    if not c:IsNoAutoAssignSpecialists() then
                        Game.SelectedCitiesGameNetMessage(
                            GameMessageTypes.GAMEMESSAGE_DO_TASK,
                            TaskTypes.TASK_NO_AUTO_ASSIGN_SPECIALISTS,
                            -1,
                            -1,
                            true
                        )
                    end
                    local countBefore = c:GetNumSpecialistsInBuilding(bID)
                    local unemployedBefore = c:GetSpecialistCount(GameDefines.DEFAULT_SPECIALIST)
                    local isFilled = (capturedSlot <= countBefore)
                    if isFilled then
                        Game.SelectedCitiesGameNetMessage(
                            GameMessageTypes.GAMEMESSAGE_DO_TASK,
                            TaskTypes.TASK_REMOVE_SPECIALIST,
                            specID,
                            bID
                        )
                    else
                        if not c:IsCanAddSpecialistToBuilding(bID) then
                            SpeechPipeline.speakInterrupt(
                                Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD")
                            )
                            return
                        end
                        Game.SelectedCitiesGameNetMessage(
                            GameMessageTypes.GAMEMESSAGE_DO_TASK,
                            TaskTypes.TASK_ADD_SPECIALIST,
                            specID,
                            bID
                        )
                    end
                    TickPump.runOnce(function()
                        local c2 = UI.GetHeadSelectedCity()
                        if c2 == nil then
                            return
                        end
                        local unemployedAfter = c2:GetSpecialistCount(GameDefines.DEFAULT_SPECIALIST)
                        local delta = unemployedAfter - unemployedBefore
                        local key
                        if isFilled then
                            key = (delta == 0) and "TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"
                                or "TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"
                        else
                            key = (delta == 0) and "TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"
                                or "TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"
                        end
                        SpeechPipeline.speakInterrupt(Text.key(key))
                    end)
                end
                items[#items + 1] = item
            end
        end
    end

    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"),
        })
    end

    local manualItem = BaseMenuItems.Text({
        labelFn = function()
            local c = UI.GetHeadSelectedCity()
            local on = (c ~= nil) and c:IsNoAutoAssignSpecialists()
            local state = Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
            return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST", state)
        end,
    })
    manualItem.activate = function(self, menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local c = UI.GetHeadSelectedCity()
        if c == nil or not isTurnActive() then
            return
        end
        local newVal = not c:IsNoAutoAssignSpecialists()
        Game.SelectedCitiesGameNetMessage(
            GameMessageTypes.GAMEMESSAGE_DO_TASK,
            TaskTypes.TASK_NO_AUTO_ASSIGN_SPECIALISTS,
            -1,
            -1,
            newVal
        )
        -- Speak the item's updated label on the next tick so the labelFn
        -- reads the post-commit state.
        TickPump.runOnce(function()
            SpeechPipeline.speakInterrupt(manualItem:announce(menu))
        end)
    end
    items[#items + 1] = manualItem

    HandlerStack.push(BaseMenu.create({
        name = "CityView.Specialists",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

-- ===== Great works sub-handler (§3.12) =====
--
-- Flat list with one item per great-work slot across every great-work-
-- capable building in the city. labelFn re-reads slot occupancy on every
-- navigate so a swap in the Culture Overview (separate accessibility pass)
-- is reflected on re-enter without a rebuild. Per-building synthetic
-- theming-bonus item appended after its building's slots when
-- pCity:GetThemingBonus(bClass) > 0 -- the label carries the bonus and
-- engine's theming tooltip so the rule is audible inline.
--
-- Enter on filled non-artifact slot fires BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER,
-- matching vanilla's left-click callback at CityView.lua:393. Artifact
-- slots, empty slots, and theming items are no-op (vanilla wires no
-- callback either; the content is spoken in the label).

local GW_SLOT_TYPE_KEY = {
    GREAT_WORK_SLOT_LITERATURE = "TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING",
    GREAT_WORK_SLOT_ART_ARTIFACT = "TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART",
    GREAT_WORK_SLOT_MUSIC = "TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC",
}

local function isGreatWorkBuilding(building)
    return (building.GreatWorkCount or 0) > 0 and building.GreatWorkSlotType ~= nil
end

local function cityHasAnyGreatWorkSlots(city)
    for building in GameInfo.Buildings() do
        if isGreatWorkBuilding(building) and city:IsHasBuilding(building.ID) then
            return true
        end
    end
    return false
end

local function pushGreatWorks()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end

    local gwBuildings = {}
    for building in GameInfo.Buildings() do
        if isGreatWorkBuilding(building) and city:IsHasBuilding(building.ID) then
            local bclass = GameInfo.BuildingClasses[building.BuildingClass]
            if bclass ~= nil then
                gwBuildings[#gwBuildings + 1] = {
                    name = Locale.ConvertTextKey(building.Description),
                    bClassID = bclass.ID,
                    slotCount = building.GreatWorkCount,
                    slotType = building.GreatWorkSlotType,
                }
            end
        end
    end
    table.sort(gwBuildings, function(a, b)
        return Locale.Compare(a.name, b.name) == -1
    end)

    local items = {}
    for _, b in ipairs(gwBuildings) do
        local slotTypeLabel = Text.key(GW_SLOT_TYPE_KEY[b.slotType] or "")
        for slotI = 0, b.slotCount - 1 do
            local buildingName = b.name
            local displaySlot = slotI + 1
            local bClassID = b.bClassID
            local slotZero = slotI
            local item = BaseMenuItems.Text({
                labelFn = function()
                    local c = UI.GetHeadSelectedCity()
                    if c == nil then
                        return ""
                    end
                    local gwIndex = c:GetBuildingGreatWork(bClassID, slotZero)
                    if gwIndex >= 0 then
                        local workDesc = Game.GetGreatWorkTooltip(gwIndex, c:GetOwner())
                        return Text.format(
                            "TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED",
                            buildingName,
                            slotTypeLabel,
                            displaySlot,
                            workDesc
                        )
                    end
                    return Text.format(
                        "TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY",
                        buildingName,
                        slotTypeLabel,
                        displaySlot
                    )
                end,
            })
            item.activate = function(_self, _menu)
                Events.AudioPlay2DSound("AS2D_IF_SELECT")
                local c = UI.GetHeadSelectedCity()
                if c == nil then
                    return
                end
                local gwIndex = c:GetBuildingGreatWork(bClassID, slotZero)
                if gwIndex < 0 then
                    return
                end
                local gwType = Game.GetGreatWorkType(gwIndex)
                local gw = GameInfo.GreatWorks[gwType]
                if gw == nil or gw.GreatWorkClassType == "GREAT_WORK_ARTIFACT" then
                    return
                end
                Events.SerialEventGameMessagePopup({
                    Type = ButtonPopupTypes.BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER,
                    Data1 = gwIndex,
                    Priority = PopupPriority.Current,
                })
            end
            items[#items + 1] = item
        end
        local themeBonus = city:GetThemingBonus(b.bClassID)
        if themeBonus > 0 then
            local themeTip = city:GetThemingTooltip(b.bClassID) or ""
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format(
                    "TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS",
                    b.name,
                    themeBonus,
                    themeTip
                ),
            })
        end
    end

    if #items == 0 then
        items[#items + 1] =
            BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST") })
    end

    HandlerStack.push(BaseMenu.create({
        name = "CityView.GreatWorks",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

-- ===== Production queue sub-handler (§3.1) =====
--
-- Flat list: queue slots, queue-mode toggle, Choose Production, Purchase.
-- Slot 1 (the currently-producing item) carries the production-meter
-- percent alongside turns + help; slots 2+ skip the meter since their
-- percent is always zero until they reach slot 1. Processes
-- (ORDER_MAINTAIN) have no turns line -- they sink production indefinitely.
-- Drill-in per slot: Move up / Move down / Remove / Back. Move up is
-- suppressed on slot 1 and Move down on the last slot, same shape vanilla's
-- arrow-button array uses (CityView.lua:2238-2262). Moves fire
-- GAMEMESSAGE_SWAP_ORDER with the lower index of the pair; remove fires
-- GAMEMESSAGE_POP_ORDER. Both drop back to the queue list so the labelFn
-- rebuild catches the new ordering.
--
-- Queue mode is vanilla's `productionQueueOpen` local, surfaced through the
-- `HideQueueButton` XML checkbox and its global `OnHideQueue` handler. We
-- read via GetCheck() and write via SetCheck + OnHideQueue(newVal) so the
-- shared state and the visual checkbox track together.

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
    local name = Locale.ConvertTextKey(info.Description)
    local help = info.Help and Locale.ConvertTextKey(info.Help) or ""
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
        return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN", name, turns, pct, help)
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
        return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN", displaySlot, name, turns)
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE", displaySlot, name)
end

local pushProductionQueue -- forward; the drill-in re-enters the queue list after a mutation.

local function pushQueueSlotActions(zeroIdx, slotName)
    local items = {}

    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    local qLength = city:GetOrderQueueLength()

    if zeroIdx > 0 then
        local upItem = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP") })
        upItem.activate = function(_self, _menu)
            Events.AudioPlay2DSound("AS2D_IF_SELECT")
            if not isTurnActive() then
                return
            end
            Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_SWAP_ORDER, zeroIdx - 1)
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"))
            HandlerStack.removeByName("CityView.ProdActions", false)
            HandlerStack.removeByName("CityView.Production", false)
            pushProductionQueue()
        end
        items[#items + 1] = upItem
    end

    if zeroIdx < qLength - 1 then
        local downItem = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN") })
        downItem.activate = function(_self, _menu)
            Events.AudioPlay2DSound("AS2D_IF_SELECT")
            if not isTurnActive() then
                return
            end
            Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_SWAP_ORDER, zeroIdx)
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"))
            HandlerStack.removeByName("CityView.ProdActions", false)
            HandlerStack.removeByName("CityView.Production", false)
            pushProductionQueue()
        end
        items[#items + 1] = downItem
    end

    local removeItem = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE") })
    removeItem.activate = function(_self, _menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        if not isTurnActive() then
            return
        end
        Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_POP_ORDER, zeroIdx)
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"))
        HandlerStack.removeByName("CityView.ProdActions", false)
        HandlerStack.removeByName("CityView.Production", false)
        pushProductionQueue()
    end
    items[#items + 1] = removeItem

    local backItem = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK") })
    backItem.activate = function(_self, _menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        HandlerStack.removeByName("CityView.ProdActions", true)
    end
    items[#items + 1] = backItem

    HandlerStack.push(BaseMenu.create({
        name = "CityView.ProdActions",
        displayName = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS", slotName),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

pushProductionQueue = function()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end

    local items = {}

    local qLength = city:GetOrderQueueLength()
    if qLength == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY") })
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
            })
            item.activate = function(_self, _menu)
                Events.AudioPlay2DSound("AS2D_IF_SELECT")
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
            end
            items[#items + 1] = item
        end
    end

    -- Queue mode toggle. GetCheck() reads vanilla's checkbox state; SetCheck
    -- + OnHideQueue(newVal) writes and fires vanilla's handler so the
    -- chunk-local `productionQueueOpen` tracks too.
    local queueModeItem = BaseMenuItems.Text({
        labelFn = function()
            local on = Controls.HideQueueButton ~= nil and Controls.HideQueueButton:GetCheck()
            local state = Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
            return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE", state)
        end,
    })
    queueModeItem.activate = function(self, menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        if Controls.HideQueueButton == nil then
            return
        end
        local newVal = not Controls.HideQueueButton:GetCheck()
        Controls.HideQueueButton:SetCheck(newVal)
        if type(OnHideQueue) == "function" then
            OnHideQueue(newVal)
        end
        SpeechPipeline.speakInterrupt(queueModeItem:announce(menu))
    end
    items[#items + 1] = queueModeItem

    local chooseItem =
        BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE") })
    chooseItem.activate = function(_self, _menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local c = UI.GetHeadSelectedCity()
        if c == nil then
            return
        end
        local queueModeOn = Controls.HideQueueButton ~= nil and Controls.HideQueueButton:GetCheck()
        Events.SerialEventGameMessagePopup({
            Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION,
            Data1 = c:GetID(),
            Data2 = -1,
            Data3 = -1,
            Option1 = (queueModeOn and c:GetOrderQueueLength() > 0),
            Option2 = false,
        })
    end
    items[#items + 1] = chooseItem

    local purchaseItem =
        BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE") })
    purchaseItem.activate = function(_self, _menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local c = UI.GetHeadSelectedCity()
        if c == nil then
            return
        end
        local queueModeOn = Controls.HideQueueButton ~= nil and Controls.HideQueueButton:GetCheck()
        Events.SerialEventGameMessagePopup({
            Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION,
            Data1 = c:GetID(),
            Data2 = -1,
            Data3 = -1,
            Option1 = (queueModeOn and c:GetOrderQueueLength() > 0),
            Option2 = true,
        })
    end
    items[#items + 1] = purchaseItem

    HandlerStack.push(BaseMenu.create({
        name = "CityView.Production",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"),
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

-- ===== Hub item list =====
--
-- Rebuilt on every hub activation (initial push + sub-handler pop). The
-- canonical order from the plan is preserved even when conditional items
-- are absent, so adding the later phases' items later won't reshuffle the
-- already-present ones: Production (Phase 5) / Hex (Phase 7) / Ranged
-- Strike (Phase 8) / Buildings (Phase 3) / Wonders / Worker focus /
-- Specialists (Phase 3) / Great works (Phase 4) / Great people /
-- Unemployed / Rename (Phase 6) / Raze (Phase 6).

-- Hub items are gated per plan §3: an item is present only when its sub-
-- handler would land the user on at least one real entry, so arrowing
-- never hits a dead-end "No X." read. Worker focus and Unemployed stay
-- unconditional (focus always applies, unemployed is a hub-level action
-- whose label carries its own zero-state).
local function buildHubItems(city)
    local items = {}
    items[#items + 1] = makeHubItem(
        { labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION") },
        pushProductionQueue
    )
    if cityHasAnyNonWonderBuilding(city) then
        items[#items + 1] = makeHubItem(
            { labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS") },
            pushBuildings
        )
    end
    if cityHasAnyWonder(city) then
        items[#items + 1] = makeHubItem(
            { labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS") },
            pushWonders
        )
    end
    items[#items + 1] = makeHubItem(
        { labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS") },
        pushWorkerFocus
    )
    if cityHasAnySpecialistSlots(city) then
        items[#items + 1] = makeHubItem(
            { labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS") },
            pushSpecialists
        )
    end
    if cityHasAnyGreatWorkSlots(city) then
        items[#items + 1] = makeHubItem(
            { labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS") },
            pushGreatWorks
        )
    end
    if cityHasAnyGreatPersonProgress(city) then
        items[#items + 1] = makeHubItem(
            { labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE") },
            pushGreatPeople
        )
    end
    items[#items + 1] = makeHubItem(
        { labelFn = unemployedLabel },
        activateUnemployed
    )
    return items
end

local function rebuildHubItems()
    local city = UI.GetHeadSelectedCity()
    if city == nil or hubHandler == nil then
        return
    end
    hubHandler.setItems(buildHubItems(city))
end

local function onShow(_handler)
    rebuildHubItems()
end

-- Install uses the onShow hook for the first-show items rebuild (runs
-- before the push so onActivate reads fresh items) and wraps onActivate
-- below for the sub-pop path (install doesn't re-fire onShow when a sub-
-- handler pops back to the hub).
hubHandler = BaseMenu.install(ContextPtr, {
    name = "CityView",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"),
    priorInput = priorInput,
    priorShowHide = wrappedShowHide,
    preamble = preamble,
    onShow = onShow,
    -- Placeholder item satisfies BaseMenu.create's non-empty items
    -- invariant; onShow's setItems replaces it before first activation.
    items = { BaseMenuItems.Text({ labelText = "" }) },
})

-- Wrap onActivate so sub-handler pops back to the hub see a freshly
-- rebuilt item list (a buy / specialist change / focus change from a
-- sub may have flipped conditional items).
local _origOnActivate = hubHandler.onActivate
hubHandler.onActivate = function(self)
    rebuildHubItems()
    return _origOnActivate(self)
end

hubHandler.bindings[#hubHandler.bindings + 1] = {
    key = VK_OEM_PERIOD,
    mods = 0,
    description = "Next city",
    fn = nextCity,
}
hubHandler.bindings[#hubHandler.bindings + 1] = {
    key = VK_OEM_COMMA,
    mods = 0,
    description = "Previous city",
    fn = previousCity,
}
hubHandler.helpEntries[#hubHandler.helpEntries + 1] = {
    keyLabel = "TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT",
    description = "TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT",
}
hubHandler.helpEntries[#hubHandler.helpEntries + 1] = {
    keyLabel = "TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV",
    description = "TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV",
}

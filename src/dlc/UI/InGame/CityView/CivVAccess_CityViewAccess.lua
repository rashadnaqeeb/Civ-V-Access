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

-- ===== Hub item list =====
--
-- Rebuilt on every hub activation (initial push + sub-handler pop). The
-- canonical order from the plan is preserved even when conditional items
-- are absent, so adding the later phases' items later won't reshuffle the
-- already-present ones: Production (Phase 5) / Hex (Phase 7) / Ranged
-- Strike (Phase 8) / Buildings (Phase 3) / Wonders / Worker focus /
-- Specialists (Phase 3) / Great works (Phase 4) / Great people /
-- Unemployed / Rename (Phase 6) / Raze (Phase 6).

local function buildHubItems(city)
    local items = {}
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

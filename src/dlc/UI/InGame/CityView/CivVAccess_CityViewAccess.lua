-- CityView accessibility. Hub handler for the city management screen.
--
-- Opens when the engine shows the CityView Context (banner click on own
-- city, Enter on a friendly hex, etc.). Most sections (Wonders, Buildings,
-- Specialists, Great Works, Great People, Stats) live as drillable
-- Groups inside this single handler -- arrow onto the group, Right /
-- Enter to drill, Left to step back. Production, Manage Territory, and
-- Worker Focus keep their own pushed handlers: Production and Hex own
-- custom key dispatch (slot drill-in actions; hex movement / tile
-- activation), and Worker Focus reads as a radio-style selection
-- surface that benefits from a single-purpose sub-screen frame.
-- Hub-level actions (Ranged Strike, Unemployed, Rename, Raze) stay as
-- terminal items. The hub owns the preamble announcement, F1 re-read,
-- Esc close, next / previous city hotkeys, and auto-re-announce on
-- city-change.
--
-- SerialEventCityScreenDirty fires on city switches AND on turn ticks
-- while the screen is up. A city-ID compare filters out the turn-tick
-- case so only real city changes re-announce.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
-- Scanner / Surveyor handlers are pushed into the hex sub via shared
-- module refs, but their TXT_KEY help labels and runtime strings
-- (SCANNER_HERE etc.) resolve in this Context's CivVAccess_Strings,
-- so the per-feature baselines + locale overlays must load here.
include("CivVAccess_ScannerStrings_en_US")
include("CivVAccess_SurveyorStrings_en_US")
include("CivVAccess_PluralRules")
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
include("CivVAccess_CityStats")
include("CivVAccess_ProductionHelpText")
-- The Production and HexMap sub-handlers live in their own files so
-- this file stays focused on the hub scaffold, the inline drillable
-- Group builders (Wonders, Buildings, Specialists, Great Works, Great
-- People, Stats), the Worker Focus sub-handler push, and the terminal
-- hub actions (Ranged Strike, Unemployed, Rename, Raze). Each sub-module
-- declares a global with a single .push() entry point referenced from
-- buildHubItems below.
include("CivVAccess_CityViewProduction")
include("CivVAccess_CityViewHexMap")

local priorInput = InputHandler

-- Windows VK codes for ',' / '.'. Civ V's Keys table doesn't expose
-- VK_OEM_COMMA / VK_OEM_PERIOD; UnitControl uses the same numeric-literal
-- workaround.
local VK_OEM_COMMA = 188
local VK_OEM_PERIOD = 190

local hubHandler -- forward; assigned after BaseMenu.install returns.

-- ===== Foreign / spy-screen detection =====
--
-- Two distinct predicates because the announcement layer and the
-- write-gate layer answer different questions.
--
-- isForeign asks "is this somebody else's city?" -- the only condition
-- under which we should announce "spying" or refuse city cycling. It
-- looks at owner only.
--
-- isActiveOwn asks "is this our city AND can we write to it?" -- used
-- to gate every action that the engine refuses in viewing mode (change
-- production, work tile, buy plot, ranged strike). Viewing mode is set
-- true on plenty of own-city paths -- the PuppetCityPopup and
-- AnnexCityPopup "View City" peeks (own city, just captured), engine
-- between-turn flips, etc. Treating those as foreign would falsely
-- announce "spying" on the user's own city, which is exactly what we
-- avoid by keeping the predicates separate.
local function isForeign(city)
    return city ~= nil and city:GetOwner() ~= Game.GetActivePlayer()
end

local function isActiveOwn(city)
    return city ~= nil and city:GetOwner() == Game.GetActivePlayer() and not UI.IsCityScreenViewingMode()
end

local function refuseForeign(textKey)
    SpeechPipeline.speakInterrupt(Text.key(textKey))
end

-- Standard guard for write-actions. Speaks the foreign-refusal message only
-- when the city actually belongs to another player; on viewing-mode-on-own
-- (PuppetCityPopup peek, AnnexCityPopup peek, engine between-turn flips)
-- silently blocks because vanilla disables the equivalent button there and
-- "you do not own this city" would be a lie. Returns true when the action
-- should be skipped.
local function refuseIfNotActiveOwn(city, foreignKey)
    if isForeign(city) then
        refuseForeign(foreignKey)
        return true
    end
    return UI.IsCityScreenViewingMode()
end

-- ===== Preamble composition =====
--
-- Trimmed to identifying-and-urgent: name, status tokens (razing /
-- resistance / occupied / puppet / blockaded), growth headline, current
-- production line, population. Yields, connected indicator, defense
-- breakdown, and unemployed count live under the Stats drillable so the
-- preamble (which re-reads on every sub-handler pop) doesn't burn
-- through dozens of numbers before the user reaches an actionable item.
-- Re-resolved on every F1 / city-change so stale data can't leak.
local function preamble()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return ""
    end
    local parts = {}
    if isForeign(city) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX")
    end
    parts[#parts + 1] = city:GetName()
    for _, t in ipairs(CitySpeech.statusTokens(city)) do
        parts[#parts + 1] = t
    end
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_POPULATION", city:GetPopulation())
    parts[#parts + 1] = CitySpeech.growthToken(city)
    parts[#parts + 1] = CitySpeech.productionToken(city)
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
    if isForeign(UI.GetHeadSelectedCity()) then
        refuseForeign("TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING")
        return
    end
    if not hasOtherCities() then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"))
        return
    end
    Game.DoControl(GameInfoTypes.CONTROL_NEXTCITY)
end

local function previousCity()
    if isForeign(UI.GetHeadSelectedCity()) then
        refuseForeign("TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING")
        return
    end
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
    -- Reset _initialized so popAbove's onActivate takes the first-open
    -- branch (displayName + preamble + first item). Leaving it true would
    -- interrupt-speak the stale-city cursor item before readHeader wiped
    -- it, producing a brief speech flash.
    hubHandler._initialized = false
    HandlerStack.popAbove(hubHandler)
end

-- Register a fresh SerialEventCityScreenDirty listener on every CityView
-- include. See CivVAccess_Boot.lua's LoadScreenClose registration for why
-- we can't install-once: load-game-from-game kills the prior Context's
-- env, stranding the old listener. Dead listeners accumulate but throw
-- silently on global access; the live one runs onCityScreenDirty.
if
    Log.installEvent(
        Events,
        "SerialEventCityScreenDirty",
        Log.safeListener("CivVAccess_CityViewAccess.onCityScreenDirty", onCityScreenDirty),
        "CivVAccess_CityViewAccess"
    )
then
    Log.info("CivVAccess_CityViewAccess: registered SerialEventCityScreenDirty listener")
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
    spec.onActivate = activateFn
    return BaseMenuItems.Text(spec)
end

local function sortByLocalizedName(list)
    table.sort(list, function(a, b)
        return Locale.Compare(a.name, b.name) == -1
    end)
end

-- Every CityView sub-handler shares the same BaseMenu spec: escapePops
-- back to the hub, capturesAllInput=false so Baseline's letter capture
-- still reaches (the hub itself already walls off the map-layer). Only
-- the name, displayName, and items differ per sub.
local function pushCitySub(subName, displayName, items)
    HandlerStack.push(BaseMenu.create({
        name = "CityView." .. subName,
        displayName = displayName,
        items = items,
        escapePops = true,
        capturesAllInput = false,
    }))
end

-- Cross-file API for the CityView orchestrator. Sibling files (Production
-- sub, etc.) call CityViewHub.pushSub instead of redeclaring an identical
-- helper. Civ V's per-Context env makes module tables the standard sharing
-- mechanism here -- same pattern as CityViewProduction / CityViewHexMap.
CityViewHub = { pushSub = pushCitySub }

local function isTurnActive()
    return Players[Game.GetActivePlayer()]:IsTurnActive()
end

-- ===== Wonders drillable =====
--
-- Flat read-only list of wonders built in this city. Wonder detection
-- mirrors CityView.lua:1386 (world wonders via MaxGlobalInstances, national
-- wonders via MaxPlayerInstances==1 with no specialists, team wonders via
-- MaxTeamInstances). Enter is a no-op (wonders are permanent and
-- indestructible). The Group self-hides when the city has no wonders
-- (Group.isNavigable returns false on a child-less group).
--
-- Label is composed at speech time by GetHelpTextForBuilding (the engine
-- helper InfoTooltipInclude.lua loads into the CityView Context's env via
-- vanilla CityView.lua's include): name + per-city contributions
-- (happiness, yields, defense, specialist slots, great-people points,
-- tourism) + the prose Help text, separated by an ASCII-dash run that
-- TextFilter strips. labelFn re-evaluates on each navigate so a religion
-- adoption / policy take that flips a yield surfaces on the next read
-- without rebuilding the list.

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

-- Compose name + the engine's per-city building contributions. The
-- building is already built here, so production cost is moot --
-- ProductionHelpText.buildingHelp(includeCost=false) skips the helper's
-- cost line and re-synthesizes the maintenance line so the recurring
-- gold drain is still audible. The helper returns yields, defense,
-- specialist slots, great-people points, great-work slots, tourism, and
-- the prose Help text in one string.
local function buildingContributionsLabel(city, building)
    local name = Text.key(building.Description)
    local help = ProductionHelpText.buildingHelp(city, building, false)
    if help == nil or help == "" then
        return name
    end
    return name .. ". " .. help
end

local function buildWondersGroup(city)
    local wonders = {}
    for building in GameInfo.Buildings() do
        if isWonderBuilding(building) and city:IsHasBuilding(building.ID) then
            wonders[#wonders + 1] = { id = building.ID, name = Text.key(building.Description) }
        end
    end
    sortByLocalizedName(wonders)
    local items = {}
    for _, w in ipairs(wonders) do
        local capturedID = w.id
        local pediaName = w.name
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                local c = UI.GetHeadSelectedCity()
                if c == nil then
                    return ""
                end
                return buildingContributionsLabel(c, GameInfo.Buildings[capturedID])
            end,
            pediaName = pediaName,
        })
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"),
        items = items,
    })
end

-- ===== Great people progress drillable =====
--
-- One item per specialist type that has non-zero progress (matching the
-- base screen's own "iProgress > 0" filter). Output is "<class name>,
-- <progress> of <threshold>" -- threshold via GetSpecialistUpgradeThreshold
-- on the UnitClass's default unit, same source the base GPMeter uses.
-- Empty -> Group auto-hides.
--
-- The progress / threshold reads happen inside labelFn so a turn tick
-- while the user is drilled into the Group surfaces fresh numbers on
-- the next nav step. The membership filter (iProgress > 0) is still
-- evaluated at build time, so a specialist type that gains its first
-- progress mid-drill won't appear until the next hub re-activation.
-- Acceptable: the dominant case is watching an already-progressing
-- specialist accumulate, and the user can Esc + re-open to refresh.

local function buildGreatPeopleGroup(city)
    local items = {}
    for specialistInfo in GameInfo.Specialists() do
        if city:GetSpecialistGreatPersonProgress(specialistInfo.ID) > 0 then
            local unitClass = GameInfo.UnitClasses[specialistInfo.GreatPeopleUnitClass]
            if unitClass ~= nil then
                local capturedSpecID = specialistInfo.ID
                local capturedUnitClassID = unitClass.ID
                local name = Text.key(unitClass.Description)
                items[#items + 1] = BaseMenuItems.Text({
                    labelFn = function()
                        local c = UI.GetHeadSelectedCity()
                        if c == nil then
                            return ""
                        end
                        local prog = c:GetSpecialistGreatPersonProgress(capturedSpecID)
                        local thr = c:GetSpecialistUpgradeThreshold(capturedUnitClassID)
                        return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY", name, prog, thr)
                    end,
                    pediaName = name,
                })
            end
        end
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"),
        items = items,
    })
end

-- ===== Worker focus sub-handler =====
--
-- Pushed as its own handler rather than inlined as a drillable Group:
-- focus selection has the shape of a radio control (eight mutually
-- exclusive options where switching is the primary interaction), and
-- the sub-handler frame gives the user a clean single-purpose surface
-- for that interaction model.
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
    { focus = CityAIFocusTypes.NO_CITY_AI_FOCUS_TYPE, key = "TXT_KEY_CITYVIEW_FOCUS_BALANCED_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FOOD, key = "TXT_KEY_CITYVIEW_FOCUS_FOOD_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_PRODUCTION, key = "TXT_KEY_CITYVIEW_FOCUS_PROD_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GOLD, key = "TXT_KEY_CITYVIEW_FOCUS_GOLD_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_SCIENCE, key = "TXT_KEY_CITYVIEW_FOCUS_RESEARCH_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_CULTURE, key = "TXT_KEY_CITYVIEW_FOCUS_CULTURE_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_GREAT_PEOPLE, key = "TXT_KEY_CITYVIEW_FOCUS_GREAT_PERSON_TEXT" },
    { focus = CityAIFocusTypes.CITY_AI_FOCUS_TYPE_FAITH, key = "TXT_KEY_CITYVIEW_FOCUS_FAITH_TEXT" },
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
            onActivate = function()
                local city = UI.GetHeadSelectedCity()
                if city == nil then
                    return
                end
                if refuseIfNotActiveOwn(city, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS") then
                    return
                end
                if not isTurnActive() then
                    return
                end
                Network.SendSetCityAIFocus(city:GetID(), focusType)
                SpeechPipeline.speakInterrupt(
                    Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED", Text.key(labelKey))
                )
            end,
        })
        items[#items + 1] = item
    end

    local avoidItem = BaseMenuItems.Text({
        labelFn = function()
            local city = UI.GetHeadSelectedCity()
            local on = (city ~= nil) and city:IsForcedAvoidGrowth()
            local state = Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
            return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH", state)
        end,
        onActivate = function(self, menu)
            local city = UI.GetHeadSelectedCity()
            if city == nil then
                return
            end
            if refuseIfNotActiveOwn(city, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS") then
                return
            end
            if not isTurnActive() then
                return
            end
            Network.SendSetCityAvoidGrowth(city:GetID(), not city:IsForcedAvoidGrowth())
            -- The Network call is async; speak the item's label after
            -- (labelFn reads IsForcedAvoidGrowth which won't flip until the
            -- engine applies the task). Tolerable: the engine applies
            -- locally in single-player before the next announce, and
            -- multiplayer briefly shows the previous state until the commit
            -- -- same delay a sighted player sees on the checkbox.
            SpeechPipeline.speakInterrupt(self:announce(menu))
        end,
    })
    items[#items + 1] = avoidItem

    local resetItem = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"),
        onActivate = function()
            local city = UI.GetHeadSelectedCity()
            if city == nil then
                return
            end
            if refuseIfNotActiveOwn(city, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS") then
                return
            end
            if not isTurnActive() then
                return
            end
            Network.SendDoTask(city:GetID(), TaskTypes.TASK_CHANGE_WORKING_PLOT, 0, -1, false, false, false, false)
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"))
        end,
    })
    items[#items + 1] = resetItem

    pushCitySub("WorkerFocus", Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"), items)
end

-- ===== Unemployed citizens =====
--
-- Hub-level action, not a sub-handler. Label carries the live count so
-- the user hears it when navigated to. Enter fires TASK_REMOVE_SLACKER
-- (misnamed in the engine; it assigns one citizen to the best tile or
-- specialist slot). The engine does not expose where the citizen went
-- and the vanilla UI doesn't show it either; we speak "assigned"
-- rather than inventing a destination. The item is filtered out of nav
-- when the count is zero -- buildHubItems overrides the Text item's
-- isNavigable to read the count live, so assigning the last slacker
-- naturally hides the entry on the next Up / Down step.

local function unemployedLabel()
    local city = UI.GetHeadSelectedCity()
    local count = (city ~= nil) and city:GetSpecialistCount(GameDefines.DEFAULT_SPECIALIST) or 0
    return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION", count)
end

local function activateUnemployed()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    if refuseIfNotActiveOwn(city, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER") then
        return
    end
    if not isTurnActive() then
        return
    end
    -- Defensive: the hub item's isNavigable hides Unemployed at count
    -- zero, but the cursor doesn't auto-unfocus when an item it's sitting
    -- on becomes non-navigable. So a user who assigns the last slacker
    -- and then presses Enter again before nav-stepping away can land
    -- here with count == 0 -- catch it before firing a no-op task and
    -- speaking a misleading "assigned".
    if city:GetSpecialistCount(GameDefines.DEFAULT_SPECIALIST) <= 0 then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"))
        return
    end
    Network.SendDoTask(city:GetID(), TaskTypes.TASK_REMOVE_SLACKER, 0, -1, false, false, false, false)
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"))
end

-- ===== Buildings drillable =====
--
-- Flat list of non-wonder buildings constructed in this city. Enter on a
-- sellable, non-puppet building pushes a flat-list Yes/No confirm whose
-- displayName carries the engine's TXT_KEY_SELL_BUILDING_INFO so blind and
-- sighted users land on the same confirmation wording. Yes fires
-- Network.SendSellBuilding and pops the confirm; the hub's onActivate
-- wrapper then rebuilds items so the sold building drops out of the
-- list. No / Esc cancels via escapePops. Enter on a non-sellable building
-- is a no-op. Empty -> Group auto-hides.
--
-- The engine's inline SellBuildingConfirm overlay is NOT driven here --
-- we bypass it and go straight to the network message. A sighted observer
-- wouldn't see a confirmation; acceptable because sighted users open the
-- CityView via mouse, and this path only fires from our keyboard flow.

local function pushSellConfirmSub(buildingID)
    local subName = "CityView.SellConfirm"
    local refund = UI.GetHeadSelectedCity():GetSellBuildingRefund(buildingID)
    local maint = GameInfo.Buildings[buildingID].GoldMaintenance or 0
    local prompt = Text.format("TXT_KEY_SELL_BUILDING_INFO", refund, maint)
    local sub = BaseMenu.create({
        name = subName,
        displayName = prompt,
        -- No first so arrow-down to Yes is an explicit affirmative step;
        -- accidental Enter on the default cancels rather than sells.
        items = {
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    HandlerStack.removeByName(subName, true)
                end,
            }),
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    local city = UI.GetHeadSelectedCity()
                    -- The confirm sub can sit open across ticks. Re-check
                    -- ownership at the moment of Yes so a mid-flight
                    -- ownership flip (multiplayer conquest, trade) does
                    -- not let a sell command escape against a city we
                    -- no longer own.
                    if city ~= nil and isActiveOwn(city) and isTurnActive() then
                        Network.SendSellBuilding(city:GetID(), buildingID)
                    end
                    -- reactivate=true fires the hub's onActivate wrapper,
                    -- which calls rebuildHubItems so the Buildings group's
                    -- children are re-iterated against the post-sell
                    -- state. setItems clamps the cursor to level 1 first
                    -- item (same drop-to-root UX as the prior popAbove
                    -- path); the user re-drills into Buildings if they
                    -- want to sell another.
                    HandlerStack.removeByName(subName, true)
                end,
            }),
        },
        escapePops = true,
    })
    HandlerStack.push(sub)
end

local function buildBuildingsGroup(city)
    local buildings = {}
    for building in GameInfo.Buildings() do
        if city:IsHasBuilding(building.ID) and not isWonderBuilding(building) then
            buildings[#buildings + 1] = { id = building.ID, name = Text.key(building.Description) }
        end
    end
    sortByLocalizedName(buildings)

    local items = {}
    for _, b in ipairs(buildings) do
        local capturedID = b.id
        local pediaName = b.name
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                local c = UI.GetHeadSelectedCity()
                if c == nil then
                    return ""
                end
                return buildingContributionsLabel(c, GameInfo.Buildings[capturedID])
            end,
            pediaName = pediaName,
            onActivate = function()
                local liveCity = UI.GetHeadSelectedCity()
                if liveCity == nil then
                    return
                end
                if refuseIfNotActiveOwn(liveCity, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL") then
                    return
                end
                if not liveCity:IsBuildingSellable(capturedID) or liveCity:IsPuppet() then
                    return
                end
                if not isTurnActive() then
                    return
                end
                pushSellConfirmSub(capturedID)
            end,
        })
    end

    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"),
        items = items,
    })
end

-- ===== Specialists drillable =====
--
-- One item per specialist slot across every specialist-capable building
-- in the city, grouped by building in the label.
-- labelFn flips "empty" / "filled" on the next read, so the state stays
-- current across Enter-driven add / remove without rebuilding the list.
-- tooltipFn mirrors the base CityView tooltip's per-yield breakdown so
-- the user hears what the specialist actually does (e.g. "+6 science,
-- +3 great people points") rather than just its name.
-- A Manual Specialist Control toggle lands at the bottom; its checkbox
-- state mirrors pCity:IsNoAutoAssignSpecialists(). The Group is gated by
-- cityHasAnySpecialistSlots in buildHubItems -- without that gate, a
-- city with no specialist-bearing buildings would still show the Group
-- because the always-present manual-toggle child keeps it navigable.
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

-- Per-city yield/culture/great-people breakdown for a slot's tooltip.
-- Mirrors base CityView's specialist tooltip (Expansion2 CityView.lua:480-512):
-- iterate yields via pCity:GetSpecialistYield, pCity:GetCultureFromSpecialist
-- for the separate culture path, and the schema's flat GreatPeopleRateChange.
-- Same content for empty and filled slots — what the slot WOULD give if filled
-- is the same explanation the user wants while it's empty (the engine itself
-- just wraps the filled tooltip in parentheses for empty slots).
local function buildSpecialistTooltip(city, specID, specInfo)
    local parts = {}
    for yieldInfo in GameInfo.Yields() do
        local amt = city:GetSpecialistYield(specID, yieldInfo.ID)
        if amt > 0 then
            parts[#parts + 1] = "+" .. amt .. " " .. yieldInfo.IconString
        end
    end
    local culture = city:GetCultureFromSpecialist(specID)
    if culture > 0 then
        parts[#parts + 1] = "+" .. culture .. " [ICON_CULTURE]"
    end
    if (specInfo.GreatPeopleRateChange or 0) > 0 then
        local gpRate = specInfo.GreatPeopleRateChange
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_GP_POINTS", gpRate, gpRate)
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ", ")
end

local function buildSpecialistsGroup(city)
    local specBuildings = {}
    for building in GameInfo.Buildings() do
        if city:IsHasBuilding(building.ID) then
            local slots = city:GetNumSpecialistsAllowedByBuilding(building.ID)
            if slots > 0 then
                specBuildings[#specBuildings + 1] = {
                    id = building.ID,
                    name = Text.key(building.Description),
                    slots = slots,
                    specialistType = building.SpecialistType,
                }
            end
        end
    end
    sortByLocalizedName(specBuildings)

    local items = {}
    for _, sb in ipairs(specBuildings) do
        local specialistInfo = GameInfo.Specialists[sb.specialistType]
        if specialistInfo ~= nil then
            local specID = specialistInfo.ID
            local specName = Text.key(specialistInfo.Description)
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
                    tooltipFn = function()
                        local c = UI.GetHeadSelectedCity()
                        if c == nil then
                            return nil
                        end
                        return buildSpecialistTooltip(c, specID, specialistInfo)
                    end,
                    pediaName = specName,
                    onActivate = function()
                        local c = UI.GetHeadSelectedCity()
                        if c == nil then
                            return
                        end
                        if refuseIfNotActiveOwn(c, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST") then
                            return
                        end
                        if not isTurnActive() then
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
                    end,
                })
                items[#items + 1] = item
            end
        end
    end

    local manualItem = BaseMenuItems.Text({
        labelFn = function()
            local c = UI.GetHeadSelectedCity()
            local on = (c ~= nil) and c:IsNoAutoAssignSpecialists()
            local state = Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
            return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST", state)
        end,
        onActivate = function(self, menu)
            local c = UI.GetHeadSelectedCity()
            if c == nil then
                return
            end
            if refuseIfNotActiveOwn(c, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST") then
                return
            end
            if not isTurnActive() then
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
            -- Speak the item's updated label on the next tick so the
            -- labelFn reads the post-commit state.
            TickPump.runOnce(function()
                SpeechPipeline.speakInterrupt(self:announce(menu))
            end)
        end,
    })
    items[#items + 1] = manualItem

    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"),
        items = items,
    })
end

-- ===== Great works drillable =====
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

local function buildGreatWorksGroup(city)
    local gwBuildings = {}
    for building in GameInfo.Buildings() do
        if isGreatWorkBuilding(building) and city:IsHasBuilding(building.ID) then
            local bclass = GameInfo.BuildingClasses[building.BuildingClass]
            if bclass ~= nil then
                gwBuildings[#gwBuildings + 1] = {
                    name = Text.key(building.Description),
                    bClassID = bclass.ID,
                    slotCount = building.GreatWorkCount,
                    slotType = building.GreatWorkSlotType,
                }
            end
        end
    end
    sortByLocalizedName(gwBuildings)

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
                -- Pedia opens the housing building's entry (Louvre, British
                -- Museum, etc.) -- the great work itself has no Civilopedia
                -- page, only its container does.
                pediaName = buildingName,
                onActivate = function()
                    local c = UI.GetHeadSelectedCity()
                    if c == nil then
                        return
                    end
                    if refuseIfNotActiveOwn(c, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN") then
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
                end,
            })
            items[#items + 1] = item
        end
        local themeBonus = city:GetThemingBonus(b.bClassID)
        if themeBonus > 0 then
            local themeTip = city:GetThemingTooltip(b.bClassID) or ""
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS", b.name, themeBonus, themeTip),
            })
        end
    end

    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"),
        items = items,
    })
end

-- ===== Ranged strike =====
--
-- Gated at the hub on pCity:CanRangeStrikeNow() (same predicate vanilla
-- uses in CityBannerManager.lua:37). Activation closes the city screen,
-- puts the engine into INTERFACEMODE_CITY_RANGE_ATTACK, and pushes the
-- InGame-Context target picker (CityRangeStrikeMode).
--
-- Two-stage defer: the outer TickPump avoids mutating the city screen's
-- state mid-activate of a BaseMenu hub item (it runs after the menu's
-- activate flow has returned); the inner TickPump waits for the hub's
-- ContextPtr hide to propagate before pushing CityRangeStrike. The hub's
-- wrappedShowHide calls popAbove(hubHandler) to clean up sub-screens, and
-- fires a tick after SerialEventExitCityScreen returns -- pushing in the
-- same tick as the hide would have CityRangeStrike popped as collateral
-- damage, stranding the engine in CITY_RANGE_ATTACK with no handler bound
-- to commit or cancel.
--
-- Re-resolves the city via ownerID/cityID inside the deferred callback
-- because Events.SerialEventExitCityScreen calls UI.ClearSelectedCities,
-- so UI.GetHeadSelectedCity returns nil by the time we need to push.
-- The engine's CITY_RANGE_ATTACK mode requires a selected city, so we
-- re-select explicitly before setting the interface mode.

local function pushRangedStrike()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    if refuseIfNotActiveOwn(city, "TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED") then
        return
    end
    if not city:CanRangeStrikeNow() then
        return
    end
    local ownerID = city:GetOwner()
    local cityID = city:GetID()
    TickPump.runOnce(function()
        -- Between the hub Enter that queued this callback and the tick
        -- that drains it, the user could have pressed Esc on the hub (which
        -- closes the city screen via the same path we were about to take).
        -- If the screen is already down, honor that -- don't re-enter the
        -- attack flow for a user who just cancelled out.
        if not UI.IsCityScreenUp() then
            return
        end
        Events.SerialEventExitCityScreen()
        TickPump.runOnce(function()
            local owner = Players[ownerID]
            if owner == nil then
                Log.warn("CityRangeStrike: owner vanished between hub activate and deferred push")
                return
            end
            local cityRef = owner:GetCityByID(cityID)
            if cityRef == nil then
                Log.warn("CityRangeStrike: city vanished between hub activate and deferred push")
                return
            end
            -- Select the city BEFORE setting the interface mode. Vanilla's
            -- CityBannerManager order is SetInterfaceMode-then-SelectCity, but
            -- vanilla can rely on the banner click having already selected the
            -- city; we can't, because Events.SerialEventExitCityScreen above
            -- ran the engine's CityScreenClosed which calls UI.ClearSelected-
            -- Cities. Setting CITY_RANGE_ATTACK first triggers Bombardment.lua's
            -- BeginRangedAttack with no selected city, which reverts straight
            -- back to SELECTION. The redundant Events.InitCityRangeStrike that
            -- vanilla fires (its only listener does the same SelectCity +
            -- SetInterfaceMode pair) is dropped: with the right order here,
            -- replaying it would just re-execute no-ops.
            UI.ClearSelectionList()
            UI.SelectCity(cityRef)
            UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_CITY_RANGE_ATTACK)
            local bridge = civvaccess_shared.modules or {}
            local mode = bridge.CityRangeStrikeMode
            if mode == nil or type(mode.enter) ~= "function" then
                Log.error("CityRangeStrike: modules.CityRangeStrikeMode not published; aborting")
                UI.ClearSelectedCities()
                UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)
                return
            end
            mode.enter(cityRef)
        end)
    end)
end

-- ===== Rename =====
--
-- Hub-level item. Fires vanilla's BUTTONPOPUP_RENAME_CITY, which opens the
-- SetCityName popup Context -- already accessible via SetCityNameAccess.
-- No turn-active gate (vanilla lets you rename mid-turn or on someone
-- else's turn, since rename is a local request).

local function activateRename()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    Events.SerialEventGameMessagePopup({
        Type = ButtonPopupTypes.BUTTONPOPUP_RENAME_CITY,
        Data1 = city:GetID(),
        Data2 = -1,
        Data3 = -1,
        Option1 = false,
        Option2 = false,
    })
end

-- ===== Raze / Stop Razing =====
--
-- Mutually-exclusive pair gated by city state. Raze mirrors vanilla's
-- OnRazeButton (CityView.lua:2465): fires BUTTONPOPUP_CONFIRM_CITY_TASK with
-- TASK_RAZE as Data2, which opens the Yes/No confirmation dialog handled by
-- GenericPopupAccess. Unraze mirrors OnUnrazeButton (CityView.lua:2485):
-- fires Network.SendDoTask(TASK_UNRAZE) directly -- vanilla has no
-- confirmation popup for stopping a raze, so we don't add one either.
--
-- Raze visibility matches vanilla's RazeCityButton:SetHide false branches
-- (lines 1581-1604): occupied, not currently razing, and CanRaze(pCity,
-- false) actually true. The capital-but-could-raze case (CanRaze false /
-- CanRaze-ignoring-capital true) is dropped -- vanilla shows the button
-- disabled with a tooltip, but we'd rather omit the dead-end item.

local function canShowRaze(city)
    if not isActiveOwn(city) then
        return false
    end
    if not city:IsOccupied() or city:IsRazing() then
        return false
    end
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return false
    end
    return player:CanRaze(city, false)
end

local function activateRaze()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    Events.SerialEventGameMessagePopup({
        Type = ButtonPopupTypes.BUTTONPOPUP_CONFIRM_CITY_TASK,
        Data1 = city:GetID(),
        Data2 = TaskTypes.TASK_RAZE,
    })
end

local function activateUnraze()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    -- Defense in depth. The hub item is only built when isActiveOwn was
    -- true at build time, but ownership can flip between hub rebuild and
    -- press (multiplayer trade, conquest). Re-check at activate so the
    -- success speech can never run on a city we no longer own.
    if not isActiveOwn(city) then
        return
    end
    if not isTurnActive() then
        return
    end
    Network.SendDoTask(city:GetID(), TaskTypes.TASK_UNRAZE, -1, -1, false, false, false, false)
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"))
end

-- ===== Stats drillable =====
--
-- Outer Group whose children are the per-category groups (yields, growth,
-- culture progress, happiness, religion, trade, resources, defense, and
-- the WLTKD / resource-demanded line) returned by CityStats.buildItems.
-- That builder already returns BaseMenuItems.Group instances, so this
-- function is a thin wrapper that adds the outer "Stats" labelled group.
-- The inner groups are rebuilt fresh on every hub rebuildHubItems pass
-- (called from hub.onActivate), so a buy / specialist / focus change
-- elsewhere produces fresh numbers on the next hub re-activation.
local function buildStatsGroup(city)
    -- Use the active player (not city:GetOwner()) so a spy-screen Stats
    -- view doesn't pump the foreign player's data through trade /
    -- happiness rows. CityStats.buildItems also drops the Trade and
    -- Resources groups for foreign cities, since those are mod-authored
    -- aggregations vanilla doesn't put on the espionage view.
    local player = Players[Game.GetActivePlayer()]
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"),
        items = CityStats.buildItems(city, player),
    })
end

-- ===== Hub item list =====
--
-- Rebuilt on every hub activation (initial push + sub-handler pop from
-- Production / Hex / Worker Focus / SellConfirm). Order: Ranged Strike
-- / Stats / Production / Hex / Worker Focus / Specialists / Unemployed
-- / Buildings / Wonders / Great works / Great people / Rename / Raze.
-- Ranged Strike leads when available so the user can fire without
-- arrowing past the city's reporting items first; combat is the
-- time-critical action and the rest of the hub is read-mostly. Stats
-- follows because it absorbed the seven-yield run that used to pad
-- the preamble; the user reaches yields and the rest of the city's
-- numbers in one place near the top of the list. Worker Focus,
-- Specialists, and Unemployed cluster together under Manage Territory
-- because all four shape what the city's citizens are doing --
-- assigning by tile (territory), by building slot (specialists), as
-- one-shot pulls from the unemployed pool, or by yield preset (focus).
-- Conditional items drop out when their gating predicate is false
-- without reshuffling the survivors.
--
-- Production, Hex, and Worker Focus are terminal items that push their
-- own handlers (custom key dispatch for Production / Hex; radio-style
-- selection surface for Worker Focus). Wonders / Buildings /
-- Specialists / Great works / Great people / Stats are inline
-- drillable Groups -- an empty Group is auto-skipped by
-- Group.isNavigable, so Wonders / Buildings / Great works / Great
-- people don't need explicit gates. Specialists keeps an explicit gate
-- because its always-present manual-toggle child would otherwise keep
-- the Group navigable on a city with no specialist-bearing buildings.
local function buildHubItems(city)
    local items = {}
    -- isActiveOwn matches vanilla CityBannerManager.lua:33 which hides the
    -- range-strike button on foreign cities. CanRangeStrikeNow is purely
    -- engine-side (attack points, valid targets) and does not check
    -- ownership; without the AND the item would appear in spy-screen hubs
    -- whenever a foreign city has ammo and a target, which is intel a
    -- sighted player never sees on the espionage view.
    if isActiveOwn(city) and city:CanRangeStrikeNow() then
        items[#items + 1] =
            makeHubItem({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE") }, pushRangedStrike)
    end
    items[#items + 1] = buildStatsGroup(city)
    items[#items + 1] =
        makeHubItem({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION") }, CityViewProduction.push)
    items[#items + 1] =
        makeHubItem({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX") }, CityViewHexMap.push)
    items[#items + 1] =
        makeHubItem({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS") }, pushWorkerFocus)
    if cityHasAnySpecialistSlots(city) then
        items[#items + 1] = buildSpecialistsGroup(city)
    end
    -- Unemployed hub item's Civilopedia entry is the Citizen specialist --
    -- matches vanilla's right-click on the slacker portrait (CityView.lua:1293).
    -- isNavigable overridden to hide the entry when the city has no
    -- unemployed citizens; the cursor walks past on Up / Down without
    -- ever landing on a "0 unemployed" read.
    local slackerInfo = GameInfo.Specialists[GameDefines.DEFAULT_SPECIALIST]
    local slackerPedia = slackerInfo and Text.key(slackerInfo.Description) or nil
    local unemployedItem =
        makeHubItem({ labelFn = unemployedLabel, pediaName = slackerPedia }, activateUnemployed)
    function unemployedItem:isNavigable()
        local c = UI.GetHeadSelectedCity()
        if c == nil then
            return false
        end
        return c:GetSpecialistCount(GameDefines.DEFAULT_SPECIALIST) > 0
    end
    items[#items + 1] = unemployedItem
    items[#items + 1] = buildBuildingsGroup(city)
    items[#items + 1] = buildWondersGroup(city)
    items[#items + 1] = buildGreatWorksGroup(city)
    items[#items + 1] = buildGreatPeopleGroup(city)
    -- Rename is hidden on foreign cities to match vanilla (EditButton:SetHide(true)
    -- when the city's owner is not the active player or viewing mode is on).
    if isActiveOwn(city) then
        items[#items + 1] =
            makeHubItem({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME") }, activateRename)
        if city:IsRazing() then
            items[#items + 1] =
                makeHubItem({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE") }, activateUnraze)
        elseif canShowRaze(city) then
            items[#items + 1] =
                makeHubItem({ labelText = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE") }, activateRaze)
        end
    end
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
BaseMenuHelp.addScreenKey(hubHandler, {
    keyLabel = "TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT",
    description = "TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT",
})
BaseMenuHelp.addScreenKey(hubHandler, {
    keyLabel = "TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV",
    description = "TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV",
})

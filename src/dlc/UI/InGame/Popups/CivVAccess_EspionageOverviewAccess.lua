-- Accessibility wrapper for the engine's EspionageOverview popup
-- (BUTTONPOPUP_ESPIONAGE_OVERVIEW, BNW only). TabbedShell over what the
-- engine ships as a single popup with two visual panels: tab 1 splits the
-- engine's left column (agents) and right column (cities) into two flat
-- accessible tabs, tab 3 is intrigue messages. Sortability is dropped --
-- the engine returns spies and cities in a stable order driven by rank /
-- founded order, which is reasonable as a fixed read sequence.
--
-- Engine integration: ships an override of EspionageOverview.lua (verbatim
-- BNW copy plus an include for this module). The engine's OnPopupMessage,
-- InputHandler, ShowHideHandler, RelocateAgent, RefreshAgents,
-- RefreshMyCities, RefreshTheirCities, and RefreshIntrigue stay intact;
-- TabbedShell.install layers our handler on top via the priorInput /
-- priorShowHide chain, and we re-derive every value from live engine
-- queries (GetEspionageSpies / GetEspionageCityStatus / GetIntrigueMessages)
-- so the visual panels and our speech speak from the same engine truth.
--
-- Subflows are all routed through the local pushYesNoConfirm helper, which
-- wraps the engine's Controls.ChooseConfirm overlay (Yes / No buttons) with
-- a sub-handler that pops with reactivate=true on every exit path so the
-- espionage shell re-announces. (The shared ChooseConfirmSub hardcodes
-- reactivate=false on Yes -- correct for popups that close on commit, wrong
-- for Espionage where the screen stays open after a commit.)
--   * Stage Coup (city-state agents): onYes -> Network.SendStageCoup. Coup
--     result feedback arrives later via NotificationAdded which the engine's
--     HandleNotificationAdded surfaces in Controls.NotificationPopup, and
--     speech reaches the user via the regular NotificationAnnounce pipeline.
--   * Move Agent: pushes a sub-handler with the same Your-Cities /
--     Their-Cities split as tab 2 (flat list, no per-city drill), plus a
--     "Move to Hideout" item at the top and a "Cancel" item at the
--     bottom. Eligible cities (from GetAvailableSpyRelocationCities) commit
--     immediately; when the eligible target is an enemy capital of a major
--     civ we are not at war with, the Diplomat-vs-Spy fork uses the same
--     Yes/No sub with onNo wired as a second commit (Diplomat) instead of
--     a cancel.
--   * Move to Hideout: onYes sends Network.SendMoveSpy(..., -1, -1, false).
--
-- Refresh on Events.SerialEventEspionageScreenDirty rebuilds all three
-- tabs from live engine state. The engine fires this after every commit
-- (Move, Coup, intrigue arrival, election cycle) and we listen even with
-- the screen hidden because the engine's own Refresh listener does the
-- same -- a rebuild on a hidden screen is a no-op cost.

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
include("CivVAccess_TabbedShell")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local m_agentsTab
local m_citiesTab
local m_intrigueTab

-- ===== Helpers =====

local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

local function plotCity(x, y)
    local plot = Map.GetPlot(x, y)
    if plot == nil then
        return nil
    end
    return plot:GetPlotCity()
end

local function findAgentByID(spies, id)
    for _, s in ipairs(spies) do
        if s.AgentID == id then
            return s
        end
    end
    return nil
end

-- Established surveillance is a TurnsLeft<0 Surveillance state per engine
-- RefreshAgents (lines 538-541 in the base file). Lift the same check so
-- the spoken activity matches what the engine prints in the visual row.
local function activityKey(agent)
    if agent.State == "TXT_KEY_SPY_STATE_SURVEILLANCE" and agent.TurnsLeft and agent.TurnsLeft < 0 then
        return "TXT_KEY_SPY_STATE_ESTABLISHED_SURVEILLANCE"
    end
    return agent.State
end

-- Compose the activity tooltip body (without trailing period). Mirrors the
-- engine's per-state cascade in RefreshAgents lines 631-672 including the
-- Counter-Intel rank+policy chance breakdown so the user hears the same
-- numbers a sighted player gets from the visual tooltip.
local function activityTooltip(agent, city)
    local rank, name = agent.Rank, agent.Name
    local cityName = (city ~= nil) and city:GetName() or ""
    local state = agent.State
    if state == "TXT_KEY_SPY_STATE_UNASSIGNED" then
        return Text.format("TXT_KEY_EO_SPY_UNASSIGNED_TT", rank, name)
    elseif state == "TXT_KEY_SPY_STATE_TRAVELLING" then
        return Text.format("TXT_KEY_EO_SPY_TRAVELLING_TT", rank, name, cityName)
    elseif state == "TXT_KEY_SPY_STATE_SURVEILLANCE" then
        return Text.format("TXT_KEY_EO_SPY_SURVEILLANCE_TT", rank, name, cityName)
    elseif state == "TXT_KEY_SPY_STATE_GATHERING_INTEL" then
        return Text.format("TXT_KEY_EO_SPY_GATHERING_INTEL_TT", rank, name, cityName)
    elseif state == "TXT_KEY_SPY_STATE_RIGGING_ELECTION" then
        return Text.format("TXT_KEY_EO_SPY_RIGGING_ELECTIONS_TT", rank, name, cityName)
    elseif state == "TXT_KEY_SPY_STATE_COUNTER_INTEL" then
        local tt = Text.format("TXT_KEY_EO_SPY_COUNTER_INTEL_TT", rank, name, cityName)
        local rankChance = 0
        if rank == "TXT_KEY_SPY_RANK_1" then
            rankChance = 10
        elseif rank == "TXT_KEY_SPY_RANK_2" then
            rankChance = 20
        end
        local policyChance = activePlayer():GetPolicyCatchSpiesModifier()
        if rankChance ~= 0 then
            tt = tt
                .. ". "
                .. Text.format("TXT_KEY_EO_SPY_COUNTER_INTEL_SPY_RANK_TT", rankChance, rank, name)
        end
        if policyChance ~= 0 then
            tt = tt .. ". " .. Text.format("TXT_KEY_EO_SPY_COUNTER_INTEL_POLICY_TT", policyChance)
        end
        local final = (33 * (100 + rankChance)) / 100
        final = (final * (100 + policyChance)) / 100
        tt = tt .. ". " .. Text.format("TXT_KEY_EO_SPY_COUNTER_INTEL_SUM_TT", final)
        return tt
    elseif state == "TXT_KEY_SPY_STATE_DEAD" then
        return Text.format("TXT_KEY_EO_SPY_BUTTON_DISABLED_SPY_DEAD_TT", rank, name)
    elseif state == "TXT_KEY_SPY_STATE_MAKING_INTRODUCTIONS" then
        return Text.format("TXT_KEY_SPY_STATE_MAKING_INTRODUCTIONS_TT", rank, name, cityName)
    elseif state == "TXT_KEY_SPY_STATE_SCHMOOZING" then
        return Text.format("TXT_KEY_SPY_STATE_SCHMOOZING_TT", rank, name, cityName)
    end
    return nil
end

-- ===== View City flow =====

-- Mirrors the engine's view-city callback (RefreshAgents lines 730-751 and
-- RefreshTheirCities lines 1303-1324). Queues Controls.EmptyPopup so other
-- popups stay off the screen while the city view is up; closes the espionage
-- popup so our handler stack stays clean while the user interacts with the
-- city screen. On ExitCityScreen we dequeue the empty popup; the espionage
-- screen is already gone, so the user has to re-open it (Ctrl+E) if they
-- want to come back.
local function viewCity(city)
    if city == nil then
        return
    end
    local function onCityScreenClosed()
        UIManager:DequeuePopup(Controls.EmptyPopup)
        Events.SerialEventExitCityScreen.Remove(onCityScreenClosed)
        UI.SetCityScreenViewingMode(false)
    end
    UIManager:QueuePopup(Controls.EmptyPopup, PopupPriority.GenericPopup + 1)
    Events.SerialEventExitCityScreen.Add(onCityScreenClosed)
    UI.SetCityScreenViewingMode(true)
    UI.DoSelectCityAtPlot(city:Plot())
    -- Close espionage popup. Engine flow keeps it queued under EmptyPopup
    -- (sighted users tab back instantly); for accessibility, leaving an
    -- input-capturing handler on the stack while the city screen is up
    -- competes with CityView's own input wrapper.
    UIManager:DequeuePopup(ContextPtr)
end

-- ===== Tab 1: Agents =====

-- Build the agent row label. Distinguishing word (rank+name) leads, location
-- and activity follow, then turns left when the engine reports a finite count.
-- KIA spies short-circuit to a single-clause line ("Recruit Pickles killed in
-- action") because none of the location / activity / turns clauses apply.
local function agentRowLabel(agent)
    local rank = Text.key(agent.Rank)
    local name = Text.key(agent.Name)
    if agent.State == "TXT_KEY_SPY_STATE_DEAD" then
        return Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA", rank, name)
    end
    local city = plotCity(agent.CityX, agent.CityY)
    local where = (city ~= nil) and Text.key(city:GetName())
        or Text.key("TXT_KEY_SPY_LOCATION_UNASSIGNED")
    local activity = Text.key(activityKey(agent))
    local diplomatTail = agent.IsDiplomat and Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL") or ""
    if agent.TurnsLeft and agent.TurnsLeft > 0 then
        return Text.format(
            "TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS",
            rank,
            name,
            where,
            activity,
            agent.TurnsLeft
        ) .. diplomatTail
    end
    return Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE", rank, name, where, activity) .. diplomatTail
end

-- Forward decls so action items can call back into the move flow which in
-- turn references the tab-rebuild path.
local pushMoveSub
local rebuildAllTabs = function() end

local function agentActionItems(agent)
    local items = {}
    if agent.State == "TXT_KEY_SPY_STATE_DEAD" then
        return items
    end
    local pPlayer = activePlayer()
    local city = plotCity(agent.CityX, agent.CityY)

    -- View City. Engine RefreshAgents gates this on
    -- HasSpyEstablishedSurveillance OR IsSpySchmoozing (line 797), and hides
    -- the button outright for our own cities and city-state assignments
    -- (engine swaps to Stage Coup in the city-state branch). We hide the
    -- item entirely rather than show-disabled so the action menu stays
    -- focused on what the user can actually do.
    local cityOwner = city and Players[city:GetOwner()] or nil
    local isCityState = cityOwner ~= nil and cityOwner:IsMinorCiv()
    local isOwnCity = cityOwner ~= nil and city:GetOwner() == Game.GetActivePlayer()
    if city ~= nil and not isCityState and not isOwnCity then
        local canView = pPlayer:HasSpyEstablishedSurveillance(agent.AgentID) or pPlayer:IsSpySchmoozing(agent.AgentID)
        if canView then
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_EO_VIEW"),
                onActivate = function()
                    viewCity(city)
                end,
            })
        end
    end

    -- Stage Coup. City-state with surveillance + an existing rival ally.
    -- CanSpyStageCoup encapsulates all engine prereqs (surveillance, ally
    -- exists, ally != us). The base UI shows a disabled button with a
    -- diagnostic tooltip in the negative case; we just hide it since the
    -- action menu is short and a "disabled coup" line adds noise.
    if city ~= nil and isCityState and pPlayer:CanSpyStageCoup(agent.AgentID) then
        local rank, name = agent.Rank, agent.Name
        local ally = Players[Players[city:GetOwner()]:GetAlly()]
        local chance = pPlayer:GetCoupChanceOfSuccess(city)
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_EO_COUP"),
            tooltipText = Text.format(
                "TXT_KEY_EO_SPY_COUP_ENABLED_TT",
                rank,
                name,
                city:GetNameKey(),
                ally:GetCivilizationAdjectiveKey(),
                chance,
                rank,
                name,
                city:GetNameKey(),
                ally:GetCivilizationShortDescriptionKey(),
                rank,
                name,
                city:GetNameKey()
            ),
            onActivate = function()
                if Controls.ConfirmText ~= nil then
                    Controls.ConfirmText:LocalizeAndSetText(
                        "TXT_KEY_EO_STAGE_COUP_QUESTION",
                        rank,
                        name,
                        city:GetNameKey(),
                        ally:GetCivilizationAdjectiveKey(),
                        chance,
                        city:GetNameKey(),
                        ally:GetCivilizationDescriptionKey(),
                        city:GetNameKey(),
                        rank,
                        name,
                        city:GetNameKey()
                    )
                end
                if Controls.ChooseConfirm ~= nil then
                    Controls.ChooseConfirm:SetHide(false)
                end
                pushYesNoConfirm({
                    name = "EspionageOverview/CoupConfirm",
                    displayName = Text.format(
                        "TXT_KEY_EO_STAGE_COUP_QUESTION",
                        rank,
                        name,
                        city:GetNameKey(),
                        ally:GetCivilizationAdjectiveKey(),
                        chance,
                        city:GetNameKey(),
                        ally:GetCivilizationDescriptionKey(),
                        city:GetNameKey(),
                        rank,
                        name,
                        city:GetNameKey()
                    ),
                    onYes = function()
                        Network.SendStageCoup(Game.GetActivePlayer(), agent.AgentID)
                    end,
                })
            end,
        })
    end

    -- Move agent. Always available for non-dead spies.
    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_EO_RELOCATE"),
        onActivate = function()
            pushMoveSub(agent)
        end,
    })
    return items
end

local function buildAgentsTabItems()
    if Game.IsOption("GAMEOPTION_NO_ESPIONAGE") then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED") }) }
    end
    local pPlayer = activePlayer()
    if pPlayer:GetNumSpies() == 0 then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_ESPIONAGE_NOT_STARTED_YET") }) }
    end
    local spies = pPlayer:GetEspionageSpies()
    if #spies == 0 then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_NO_MORE_SPIES") }) }
    end
    local items = {}
    for _, agent in ipairs(spies) do
        -- GetEspionageSpies returns a fresh table allocation each call;
        -- closures key off the stable AgentID and re-resolve the agent
        -- record from live state at drill time.
        local agentId = agent.AgentID
        local city = plotCity(agent.CityX, agent.CityY)
        local label = agentRowLabel(agent)
        local tooltip = activityTooltip(agent, city)
        if agent.State == "TXT_KEY_SPY_STATE_DEAD" then
            items[#items + 1] = BaseMenuItems.Text({
                labelText = label,
                tooltipText = tooltip,
            })
        else
            items[#items + 1] = BaseMenuItems.Group({
                labelText = label,
                tooltipText = tooltip,
                itemsFn = function()
                    -- Re-resolve the agent from the live spy list each drill;
                    -- the snapshot would be wrong after a Network.Send round-
                    -- trip even if the rebuild has not fired yet.
                    local fresh = findAgentByID(activePlayer():GetEspionageSpies(), agentId)
                    if fresh == nil then
                        return {}
                    end
                    return agentActionItems(fresh)
                end,
            })
        end
    end
    return items
end

-- ===== Tab 2: Cities =====

-- Comma-joined list of non-zero espionage potential modifiers (buildings,
-- wonders, policies) for inclusion in the city row label. Mirrors the
-- engine's BuildPotentialModifierTT (EspionageOverview.lua lines 835-906)
-- but drops the "Change from buildings and wonders:" section titles so the
-- row carries data, not help text.
local function potentialBreakdownEntries(cityInfo)
    local pPlayer = Players[cityInfo.PlayerID]
    local pCity = pPlayer:GetCityByID(cityInfo.CityID)
    if pCity == nil then
        return ""
    end
    local entries = {}
    for building in GameInfo.Buildings() do
        local buildingClass = GameInfo.BuildingClasses[building.BuildingClass]
        local mod = pCity:GetBuildingEspionageModifier(building.ID)
        local globalMod = pCity:GetBuildingGlobalEspionageModifier(building.ID)
        if pCity:IsHasBuilding(building.ID) then
            if mod and mod ~= 0 then
                entries[#entries + 1] =
                    Text.format("TXT_KEY_EO_POTENTIAL_BUILDING_MOD_ENTRY", building.Description, mod)
            end
        elseif pPlayer:GetBuildingClassCount(buildingClass.ID) > 0 then
            if globalMod and globalMod ~= 0 then
                entries[#entries + 1] =
                    Text.format("TXT_KEY_EO_POTENTIAL_WONDER_MOD_ENTRY", building.Description, globalMod)
            end
        end
    end
    local i = 0
    local policyInfo = GameInfo.Policies[i]
    while policyInfo ~= nil do
        if pPlayer:HasPolicy(i) and not pPlayer:IsPolicyBlocked(i) then
            local mod = pPlayer:GetPolicyEspionageModifier(i)
            if mod ~= 0 then
                entries[#entries + 1] =
                    Text.format("TXT_KEY_EO_POTENTIAL_POLICY_MOD_ENTRY", policyInfo.Description, mod)
            end
        end
        i = i + 1
        policyInfo = GameInfo.Policies[i]
    end
    return table.concat(entries, ", ")
end

-- Breakdown is meaningful only when the player has the data to compute it:
-- own cities (we always know our own buildings/policies) and foreign cities
-- with established surveillance. City-states use the rig-election clause
-- instead of a numeric potential, and unknown-potential cities have nothing
-- to break down.
local function shouldShowBreakdown(cityInfo, isCityState, spy)
    if isCityState then
        return false
    end
    if cityInfo.BasePotential <= 0 then
        return false
    end
    if cityInfo.PlayerID == Game.GetActivePlayer() then
        return true
    end
    return spy ~= nil and spy.EstablishedSurveillance
end

-- Per-city status struct enriched with CivilizationName / CivilizationNameKey
-- the engine's RefreshMyCities and RefreshTheirCities (lines 1003-1006 and
-- 1361-1378) patch on. The engine table itself omits these fields; we mirror
-- the patch at read time rather than mutate the engine table. Name is also
-- resolved here: the engine puts pCity->getNameKey() (a raw TXT_KEY) in the
-- Name field, and our mod-authored format slots do not auto-resolve, so a
-- bare concat or our %_CITY_LABEL substitute would speak the raw key.
local function enrichCityStatus(v)
    local out = {}
    for k, val in pairs(v) do
        out[k] = val
    end
    out.Name = Text.key(v.Name)
    local pPlayer = Players[v.PlayerID]
    if pPlayer:IsMinorCiv() then
        local minor = GameInfo.MinorCivilizations[pPlayer:GetMinorCivType()]
        out.CivilizationNameKey = minor.ShortDescription
        out.CivilizationName = Text.key(minor.ShortDescription)
    else
        local civInfo = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
        out.CivilizationNameKey = civInfo.ShortDescription
        out.CivilizationName = Text.key(civInfo.ShortDescription)
    end
    return out
end

-- Resolve the spy / diplomat occupying a city, if any. Engine's
-- agentsByCity lookup (RefreshTheirCities lines 1135-1162) does the same
-- mapping. Returns the spy table (with AgentID, Name, IsDiplomat fields)
-- or nil.
local function agentInCity(playerID, cityID, spies)
    for _, s in ipairs(spies) do
        local plot = Map.GetPlot(s.CityX, s.CityY)
        if plot ~= nil then
            local c = plot:GetPlotCity()
            if c ~= nil and c:GetOwner() == playerID and c:GetID() == cityID then
                return s
            end
        end
    end
    return nil
end

-- Spy presence clause for a city row. "agent Pickles" / "diplomat Smith" /
-- empty when no spy is in the city. Spoken at the end of the city row so
-- the spy presence (informationally important but secondary to the city's
-- own identity) reads after civ + name + potential + population.
local function spyPresenceClause(spy)
    if spy == nil then
        return ""
    end
    local key = spy.IsDiplomat and "TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"
        or "TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"
    return Text.format(key, Text.key(spy.Name))
end

-- The "potential" value clause spoken on the city row. City-states get the
-- election-rig phrasing instead of a star meter (engine
-- RefreshTheirCities lines 1195-1202 hides the meter and shows the rig
-- icon for minor civs); other-civ cities without surveillance read as
-- "potential unknown"; otherwise the engine's Potential / BasePotential
-- is the value.
local function potentialClause(cityInfo, isCityState, spy)
    if isCityState then
        if spy ~= nil and spy.State == "TXT_KEY_SPY_STATE_RIGGING_ELECTION" then
            return Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE")
        end
        return Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE")
    end
    if cityInfo.BasePotential <= 0 then
        return Text.key("TXT_KEY_EO_UNKNOWN_POTENTIAL")
    end
    if cityInfo.PlayerID == Game.GetActivePlayer() then
        return Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE", cityInfo.BasePotential)
    end
    if spy ~= nil and spy.EstablishedSurveillance and cityInfo.Potential > 0 then
        return Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE", cityInfo.Potential)
    end
    return Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE", cityInfo.BasePotential)
end

-- City row label: Civ, City, population, +spy clause, potential, +breakdown.
-- Potential is held to the end so the breakdown (modifier list) follows it
-- naturally as a single trailing detail clause; sighted players read those
-- numbers off the potential-meter tooltip and we surface the same data here
-- since tab 2 has no per-row drill anymore.
local function cityRowLabel(cityInfo, isCityState, spy)
    local popText = Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION", cityInfo.Population)
    local parts = { cityInfo.CivilizationName, cityInfo.Name, popText }
    local spyClause = spyPresenceClause(spy)
    if spyClause ~= "" then
        parts[#parts + 1] = spyClause
    end
    parts[#parts + 1] = potentialClause(cityInfo, isCityState, spy)
    if shouldShowBreakdown(cityInfo, isCityState, spy) then
        local breakdown = potentialBreakdownEntries(cityInfo)
        if breakdown ~= "" then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN", breakdown)
        end
    end
    return table.concat(parts, ", ")
end

-- Flat city row. Eligible for View City (foreign non-city-state with
-- established surveillance, mirroring engine RefreshTheirCities lines 1289 /
-- 1326 / 1347's DisabledViewCityIcon gating) -> Choice that opens the city
-- screen on activate. Everything else is an inert Text row -- the row label
-- already carries civ, name, population, spy presence, potential, and the
-- modifier breakdown, so there is no further drill content worth surfacing.
local function buildCityRow(cityInfo, isCityState, spies)
    local spy = agentInCity(cityInfo.PlayerID, cityInfo.CityID, spies)
    local label = cityRowLabel(cityInfo, isCityState, spy)
    local viewable = not isCityState
        and cityInfo.PlayerID ~= Game.GetActivePlayer()
        and spy ~= nil
        and spy.EstablishedSurveillance
    if not viewable then
        return BaseMenuItems.Text({ labelText = label })
    end
    local plot = Map.GetPlot(cityInfo.CityX, cityInfo.CityY)
    local pCity = plot and plot:GetPlotCity() or nil
    if pCity == nil then
        return BaseMenuItems.Text({ labelText = label })
    end
    return BaseMenuItems.Choice({
        labelText = label,
        activate = function()
            viewCity(pCity)
        end,
    })
end

local function buildCitiesTabItems()
    if Game.IsOption("GAMEOPTION_NO_ESPIONAGE") then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED") }) }
    end
    local pPlayer = activePlayer()
    if pPlayer:GetNumSpies() == 0 then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_ESPIONAGE_NOT_STARTED_YET") }) }
    end
    local activeTeam = pPlayer:GetTeam()
    local cityStatus = pPlayer:GetEspionageCityStatus()
    local spies = pPlayer:GetEspionageSpies()
    local yourCities, theirCities = {}, {}
    for _, v in ipairs(cityStatus) do
        local enriched = enrichCityStatus(v)
        if v.PlayerID == Game.GetActivePlayer() then
            yourCities[#yourCities + 1] = enriched
        elseif v.Team ~= activeTeam then
            theirCities[#theirCities + 1] = enriched
        end
    end
    -- Section headers as Text rows (not drillable Groups) so the tab is a
    -- single flat scrollable list -- the city rows themselves carry every
    -- piece of data the old per-city drill exposed.
    local items = {}
    if #yourCities > 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_EO_YOUR_CITIES") })
        for _, ci in ipairs(yourCities) do
            items[#items + 1] = buildCityRow(ci, false, spies)
        end
    end
    if #theirCities > 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_EO_THEIR_CITIES") })
        for _, ci in ipairs(theirCities) do
            items[#items + 1] = buildCityRow(ci, Players[ci.PlayerID]:IsMinorCiv(), spies)
        end
    end
    return items
end

-- ===== Tab 3: Intrigue =====

local function intrigueRowLabel(msg)
    local turnText = Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN", msg.Turn)
    local fromText
    if msg.DiscoveringPlayer == Game.GetActivePlayer() then
        fromText = Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN", msg.SpyName or "")
    else
        local pPlayer = Players[msg.DiscoveringPlayer]
        local leader
        if pPlayer ~= nil then
            if pPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer() then
                leader = pPlayer:GetNickName()
            else
                leader = pPlayer:GetName()
            end
        else
            leader = Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN")
        end
        fromText = Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER", leader)
    end
    return table.concat({ turnText, fromText, msg.String or "" }, ". ")
end

local function buildIntrigueTabItems()
    if Game.IsOption("GAMEOPTION_NO_ESPIONAGE") then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED") }) }
    end
    local pPlayer = activePlayer()
    local messages = pPlayer:GetIntrigueMessages()
    if #messages == 0 then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_EO_NO_INTRIGUE_AVAILABLE") }) }
    end
    local items = {}
    -- Most-recent first matches the engine's default Turn-desc sort
    -- (g_IntrigueSortOptions[1].DefaultDirection = "desc"). Iterate the
    -- engine list in reverse to avoid a separate table.sort here.
    for i = #messages, 1, -1 do
        items[#items + 1] = BaseMenuItems.Text({ labelText = intrigueRowLabel(messages[i]) })
    end
    return items
end

-- ===== Confirm subs =====

-- Yes/No confirm sub against the engine's Controls.ChooseConfirm overlay.
-- Distinct from ChooseConfirmSub which hardcodes reactivate=false on Yes
-- (correct for popups that close on commit; wrong for Espionage where the
-- screen stays open after Stage Coup / Hideout, so the underlying shell
-- needs a re-announce). Yes / No / Esc all pop with reactivate=true so
-- the user lands back on a freshly-announced espionage shell. Esc and No
-- speak "canceled" first.
local function pushYesNoConfirm(opts)
    local subName = opts.name
    local sub = BaseMenu.create({
        name = subName,
        displayName = opts.displayName,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        items = {
            BaseMenuItems.Button({
                controlName = "Yes",
                textKey = opts.yesKey or "TXT_KEY_YES_BUTTON",
                activate = function()
                    local ok, err = pcall(opts.onYes)
                    if not ok then
                        Log.error(subName .. " onYes failed: " .. tostring(err))
                    end
                    HandlerStack.removeByName(subName, true)
                end,
            }),
            BaseMenuItems.Button({
                controlName = "No",
                textKey = opts.noKey or "TXT_KEY_NO_BUTTON",
                activate = function()
                    if opts.onNo ~= nil then
                        local ok, err = pcall(opts.onNo)
                        if not ok then
                            Log.error(subName .. " onNo failed: " .. tostring(err))
                        end
                    else
                        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CANCELED"))
                    end
                    HandlerStack.removeByName(subName, true)
                end,
            }),
        },
    })
    sub.onDeactivate = function()
        if Controls.ChooseConfirm ~= nil then
            Controls.ChooseConfirm:SetHide(true)
        end
    end
    HandlerStack.push(sub)
end

-- Diplomat-vs-Spy fork. Engine flow (RefreshTheirCities lines 1412-1435)
-- shows a two-button picker for major-civ capitals when not at war: Yes
-- commits as Diplomat, No commits as Spy. Reuses pushYesNoConfirm with
-- onNo as a second commit (rather than the default cancel). Esc cancels
-- the picker entirely without sending.
local function pushDiplomatPicker(agentId, targetPlayerID, targetCityID, onCommitted)
    if Controls.ConfirmText ~= nil then
        Controls.ConfirmText:LocalizeAndSetText("TXT_KEY_SPY_BE_DIPLOMAT")
    end
    if Controls.ChooseConfirm ~= nil then
        Controls.ChooseConfirm:SetHide(false)
    end
    local function commit(isDiplomat)
        Network.SendMoveSpy(Game.GetActivePlayer(), agentId, targetPlayerID, targetCityID, isDiplomat)
        onCommitted()
    end
    pushYesNoConfirm({
        name = "EspionageOverview/DiplomatPicker",
        displayName = Text.key("TXT_KEY_SPY_BE_DIPLOMAT"),
        yesKey = "TXT_KEY_DIPLOMAT_PICKER_DIPLOMAT",
        noKey = "TXT_KEY_DIPLOMAT_PICKER_SPY",
        onYes = function()
            commit(true)
        end,
        onNo = function()
            commit(false)
        end,
    })
end

-- Hideout confirm. Engine RefreshAgents lines 333-355 shows the same
-- ChooseConfirm overlay; we reuse it and route Yes -> SendMoveSpy(..., -1, -1).
local function pushHideoutConfirm(agentId, agent, onCommitted)
    if Controls.ConfirmText ~= nil then
        Controls.ConfirmText:LocalizeAndSetText("TXT_KEY_EO_MOVE_SPY_TO_HIDEOUT_CHECK", agent.Rank, agent.Name)
    end
    if Controls.ChooseConfirm ~= nil then
        Controls.ChooseConfirm:SetHide(false)
    end
    pushYesNoConfirm({
        name = "EspionageOverview/HideoutConfirm",
        displayName = Text.format("TXT_KEY_EO_MOVE_SPY_TO_HIDEOUT_CHECK", agent.Rank, agent.Name),
        onYes = function()
            Network.SendMoveSpy(Game.GetActivePlayer(), agentId, -1, -1, false)
            onCommitted()
        end,
    })
end

-- Build the relocate picker's flat city items. Eligible cities (from
-- GetAvailableSpyRelocationCities) commit immediately; ineligible cities
-- speak as read-only Text rows so the user hears their existence (not
-- just the eligible set), matching the design call to surface what
-- sighted players see even when not actionable.
local function buildMoveSubItems(agent)
    local pPlayer = activePlayer()
    local available = pPlayer:GetAvailableSpyRelocationCities(agent.AgentID) or {}
    local availableLookup = {}
    for _, v in ipairs(available) do
        availableLookup[v.PlayerID .. ":" .. v.CityID] = true
    end
    local cityStatus = pPlayer:GetEspionageCityStatus()
    local spies = pPlayer:GetEspionageSpies()
    local activeTeam = pPlayer:GetTeam()
    local pMyTeam = Teams[Game.GetActiveTeam()]
    local items = {}

    -- Hideout button at the top. Always available for non-dead, non-already-
    -- at-hideout spies; engine RelocateAgent shows it unconditionally inside
    -- the move flow. reactivate=true on the Move pop so the espionage shell
    -- re-announces after the underlying ChooseConfirm pops silently.
    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_MOVE_SPY_HIDEOUT_BUTTON"),
        onActivate = function()
            pushHideoutConfirm(agent.AgentID, agent, function()
                HandlerStack.removeByName("EspionageOverview/Move", true)
            end)
        end,
    })

    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CANCEL_BUTTON"),
        onActivate = function()
            HandlerStack.removeByName("EspionageOverview/Move", true)
        end,
    })

    local function appendCity(ci, isCityState)
        local key = ci.PlayerID .. ":" .. ci.CityID
        local spy = agentInCity(ci.PlayerID, ci.CityID, spies)
        local label = cityRowLabel(ci, isCityState, spy)
        if availableLookup[key] then
            local plot = Map.GetPlot(ci.CityX, ci.CityY)
            local pCity = plot and plot:GetPlotCity() or nil
            local needsDiplomatChoice = false
            if pCity ~= nil and pCity:IsCapital() then
                local owner = Players[ci.PlayerID]
                if not owner:IsMinorCiv() and not pMyTeam:IsAtWar(pCity:GetTeam()) then
                    needsDiplomatChoice = true
                end
            end
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
                activate = function()
                    if needsDiplomatChoice then
                        pushDiplomatPicker(agent.AgentID, ci.PlayerID, ci.CityID, function()
                            HandlerStack.removeByName("EspionageOverview/Move", true)
                        end)
                        return
                    end
                    Network.SendMoveSpy(Game.GetActivePlayer(), agent.AgentID, ci.PlayerID, ci.CityID, false)
                    HandlerStack.removeByName("EspionageOverview/Move", true)
                end,
            })
        else
            items[#items + 1] = BaseMenuItems.Text({ labelText = label })
        end
    end

    -- Group your cities then their cities, mirroring tab 2's layout. We
    -- keep the section headers as Text rows (not drillable Groups) so the
    -- user gets a flat scrollable list -- the user explicitly asked for
    -- "no longer drillable" for the move flow.
    local your, their = {}, {}
    for _, v in ipairs(cityStatus) do
        local enriched = enrichCityStatus(v)
        if v.PlayerID == Game.GetActivePlayer() then
            your[#your + 1] = enriched
        elseif v.Team ~= activeTeam then
            their[#their + 1] = enriched
        end
    end
    if #your > 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_EO_YOUR_CITIES") })
        for _, ci in ipairs(your) do
            appendCity(ci, false)
        end
    end
    if #their > 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_EO_THEIR_CITIES") })
        for _, ci in ipairs(their) do
            appendCity(ci, Players[ci.PlayerID]:IsMinorCiv())
        end
    end
    return items
end

pushMoveSub = function(agent)
    local sub = BaseMenu.create({
        name = "EspionageOverview/Move",
        displayName = Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY", Text.key(agent.Rank), Text.key(agent.Name)),
        preamble = Text.format("TXT_KEY_MOVE_SPY_INSTRUCTIONS", agent.Rank, agent.Name),
        items = buildMoveSubItems(agent),
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(sub)
end

-- ===== Install =====

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    local function makeTab(tabName)
        return TabbedShell.menuTab({
            tabName = tabName,
            menuSpec = {
                displayName = Text.key("TXT_KEY_EO_TITLE"),
                items = {},
            },
        })
    end
    m_agentsTab = makeTab("TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS")
    m_citiesTab = makeTab("TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES")
    m_intrigueTab = makeTab("TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE")

    rebuildAllTabs = function()
        m_agentsTab.menu().setItems(buildAgentsTabItems())
        m_citiesTab.menu().setItems(buildCitiesTabItems())
        m_intrigueTab.menu().setItems(buildIntrigueTabItems())
    end

    TabbedShell.install(ContextPtr, {
        name = "EspionageOverview",
        displayName = Text.key("TXT_KEY_EO_TITLE"),
        tabs = { m_agentsTab, m_citiesTab, m_intrigueTab },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(_handler)
            rebuildAllTabs()
        end,
    })

    -- Refresh on dirty. Engine fires this after every spy-state mutation
    -- (Move / Coup / intrigue arrival / election cycle / per-turn travel
    -- progression). Registered on every Context include rather than
    -- gated by an install-once flag because load-from-game wipes this
    -- Context's env (Architecture Gotchas in CLAUDE.md).
    Events.SerialEventEspionageScreenDirty.Add(function()
        if ContextPtr:IsHidden() then
            return
        end
        local ok, err = pcall(rebuildAllTabs)
        if not ok then
            Log.error("EspionageOverview dirty refresh failed: " .. tostring(err))
        end
    end)
end

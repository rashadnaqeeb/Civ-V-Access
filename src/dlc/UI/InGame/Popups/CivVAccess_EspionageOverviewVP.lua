-- VP / Community Patch espionage action builder and sub-panels. Vox Populi
-- rebuilt espionage around network points: coup is gone, the activity tooltip
-- is one engine getter (GetSpyMissionTooltip), and a spy's offensive action
-- depends on where it stands -- own city gets a counterspy-focus picker, a
-- foreign major city gets either a diplomat panel (if the spy was converted to
-- a diplomat) or an offensive mission picker, and city-states get no action
-- button (rigging is passive under VP). The diplomat panel exposes four
-- network-point-gated views: a rival's tech tree, social policies, military
-- unit list, and current trade deals.
--
-- This file is the VP branch of CivVAccess_EspionageOverviewAccess. The shell
-- (TabbedShell, Cities tab, Intrigue tab, relocate flow) is engine-neutral and
-- lives in the access wrapper; only the Agents-tab action set and these
-- VP-only sub-panels differ, so the wrapper feature-detects the VP espionage
-- body (the PopulateSelectionList vendor global) and routes through here. The
-- access wrapper passes its shared helpers in via EspionageVP.install so the
-- relocate flow, city-view helper, and tab rebuild stay single-sourced.
--
-- Every getter here is a VP / CP DLL binding absent on vanilla; the file is
-- only ever reached on the VP path, so the calls are raw (no EngineData seam).
-- None of the names are in the lint seam-guard lists.

include("CivVAccess_DealLabelShared")
-- The diplomat unit-list view renders through BaseTable, which the popup
-- include bundle does not carry; pull it in here since this VP-only file is
-- its sole consumer in the EspionageOverview Context.
include("CivVAccess_BaseTableCore")

EspionageVP = {}

-- Shared helpers handed over by the access wrapper at install time. Closures,
-- so forward-declared wrapper locals (pushMoveSub, viewCity) resolve at call
-- time rather than install time.
local ctx

function EspionageVP.install(sharedCtx)
    ctx = sharedCtx
end

-- ===== Network-point scaling =====

-- Network-point cost scaled to game speed, mirroring the vendor's
-- GetNetworkPointsScaled. Inlined rather than calling the vendor global so a
-- re-pin that renames it can't silently break our reads.
local function npScaled(info)
    local np = info.NetworkPointsNeeded
    if info.NetworkPointsScaling == true then
        np = math.floor(np * GameInfo.GameSpeeds[Game.GetGameSpeedType()].TrainPercent / 100)
    end
    return np
end

-- ===== Agent row progress + activity tooltip =====

-- The single progress value VP shows on the agent row, in the engine's own
-- priority: a finite turn countdown, else the active mission focus, else the
-- spy's stored / per-turn network points. Empty string when none applies
-- (mirrors the vendor clearing the AgentProgress label).
function EspionageVP.agentRowProgress(agent)
    if agent.TurnsLeft and agent.TurnsLeft >= 0 then
        return Text.formatPlural("TXT_KEY_CIVVACCESS_ESPIONAGE_PROGRESS_TURNS", agent.TurnsLeft, agent.TurnsLeft)
    end
    if agent.SpyFocus and agent.SpyFocus >= 0 then
        local info = GameInfo.CityEventChoices[agent.SpyFocus]
        if info ~= nil and info.MissionTooltip then
            return Text.key(info.MissionTooltip)
        end
    end
    if agent.NetworkPointsStored and agent.NetworkPointsStored >= 0 then
        return Text.format("TXT_KEY_NETWORK_POINTS", agent.NetworkPointsStored, agent.NetworkPointsPerTurn)
    end
    return ""
end

-- The engine's per-spy activity tooltip replaces the vanilla hardcoded
-- counter-intel formula. Unassigned spies (no city) get the engine's
-- needs-assignment text.
function EspionageVP.activityTooltip(agent, city)
    if city ~= nil then
        return ctx.activePlayer():GetSpyMissionTooltip(city, agent.AgentID)
    end
    return Text.key("TXT_KEY_EO_SPY_NEEDS_ASSIGNMENT_TT")
end

-- ===== City potential (security) =====

-- VP repurposed the espionage "potential" meter into a city-security value
-- (higher means harder to spy). Speak the security number when known; the
-- vanilla building / policy modifier breakdown is a vanilla-potential concept
-- and is dropped on the VP path. City-states keep the rig-election clause,
-- handled by the access wrapper.
function EspionageVP.cityPotentialClause(cityInfo)
    if cityInfo.Potential and cityInfo.Potential >= 0 then
        return Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_SECURITY", cityInfo.Potential)
    end
    return Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN")
end

-- ===== Event-choice lookups (missions / counterspy focus) =====

-- The parent CityEvent rows that group the espionage mission choices and the
-- counterspy focus choices. Each returns the event row (carrying .ID and
-- .Type) or nil if the DB lacks it.
local function espionageSetupEvent()
    for row in GameInfo.CityEvents("EspionageSetup") do
        return row
    end
    return nil
end

local function counterspyEvent()
    for row in GameInfo.CityEvents("IsCounterSpy") do
        return row
    end
    return nil
end

-- Iterate the CityEventChoices parented to an event, calling fn(info) for each.
local function forEachChoice(event, fn)
    if event == nil then
        return
    end
    for row in GameInfo.CityEvent_ParentEvents("CityEventType = '" .. event.Type .. "'") do
        local info = GameInfo.CityEventChoices[row.CityEventChoiceType]
        if info ~= nil then
            fn(info)
        end
    end
end

-- ===== Passive-bonus drillable =====

-- A drillable group whose label is the "best unlocked so far" summary line and
-- whose children list every passive bonus with its network-point threshold and
-- a locked / unlocked tag. isDiplomat picks the diplomat bonus table and
-- summary phrasing. Mirrors the vendor's PopulatePassiveBonusList /
-- PopulateDiplomatBonusList summary logic.
local function passiveBonusGroup(spy, isDiplomat)
    local bonusTable = isDiplomat and GameInfo.SpyPassiveBonusesDiplomat or GameInfo.SpyPassiveBonuses

    local bestText, bestNP = "", -1
    for row in bonusTable() do
        local np = npScaled(row)
        if np <= spy.MaxNetworkPointsStored and np > bestNP then
            bestNP = np
            bestText = Text.key(row.Help)
        end
    end

    local summary
    if isDiplomat then
        summary = Text.format("TXT_KEY_EO_PASSIVE_BONUSES_UNLOCKED_DIPLOMAT", spy.MaxNetworkPointsStored, bestText)
    elseif bestText ~= "" then
        if spy.MaxNetworkPointsStored == spy.NetworkPointsStored then
            summary = Text.format("TXT_KEY_EO_PASSIVE_BONUSES_UNLOCKED", spy.MaxNetworkPointsStored, bestText)
        else
            summary =
                Text.format("TXT_KEY_EO_PASSIVE_BONUSES_UNLOCKED_FROM_EARLIER", spy.MaxNetworkPointsStored, bestText)
        end
    else
        summary = Text.format("TXT_KEY_EO_PASSIVE_BONUSES_UNLOCKED_NOTHING_YET", spy.NetworkPointsStored)
    end

    local children = {}
    for row in bonusTable() do
        local np = npScaled(row)
        local tagKey = (np <= spy.MaxNetworkPointsStored) and "TXT_KEY_CIVVACCESS_ESPIONAGE_BONUS_UNLOCKED"
            or "TXT_KEY_CIVVACCESS_ESPIONAGE_BONUS_LOCKED"
        children[#children + 1] = BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_EO_PASSIVE_BONUS_NP_REQUIRED", np, Text.key(row.Description))
                .. ", "
                .. Text.key(tagKey),
            tooltipText = Text.key(row.Help),
        })
    end

    return BaseMenuItems.Group({ labelText = summary, items = children })
end

-- Lowest network-point threshold among bonus rows carrying a given reveal
-- flag, or 999999 when no row grants it (mirrors the vendor sentinel).
local function revealThreshold(bonusTable, flag)
    local threshold = 999999
    for row in bonusTable(flag) do
        threshold = math.min(threshold, npScaled(row))
    end
    return threshold
end

-- ===== Mission / counterspy pickers =====

-- Build a single mission/counterspy choice item. Valid choices commit on
-- activate (no select-then-confirm step, matching our event pickers); invalid
-- choices stay listed as inert rows with the engine's disabled reason on the
-- tooltip so the user hears what exists and why it is closed.
local function buildChoiceItem(info, event, agent, city, isCounterspy, displayName)
    local activeID = Game.GetActivePlayer()
    local cityName = city:GetName()

    local label
    if info.NetworkPointsNeeded and info.NetworkPointsNeeded > 0 then
        label = Text.format("TXT_KEY_EO_MISSION_COST", npScaled(info), Text.key(info.Description))
    else
        label = Text.key(info.Description)
    end

    local tooltip = Text.format(city:GetScaledEventChoiceValue(info.ID, false, agent.AgentID, activeID), cityName)
    if not isCounterspy then
        tooltip = tooltip .. ". " .. Text.format("TXT_KEY_EO_ID_KILL_CHANCE", info.SpyIDChance, info.SpyKillChance)
    end

    local valid = city:IsCityEventChoiceValidEspionage(info.ID, event.ID, agent.AgentID, activeID)
    if not valid then
        local reason
        if isCounterspy then
            reason = Text.key("TXT_KEY_EO_COUNTERSPY_CANNOT_CHANGE_ACTIVE_FOCUS_TT")
        else
            reason = city:GetDisabledTooltip(info.ID, agent.AgentID, activeID)
        end
        if reason ~= nil and reason ~= "" then
            tooltip = tooltip .. ". " .. reason
        end
        return BaseMenuItems.Text({ labelText = label, tooltipText = tooltip })
    end

    return BaseMenuItems.Choice({
        labelText = label,
        tooltipText = tooltip,
        activate = function()
            city:DoCityEventChoice(info.ID, agent.AgentID, activeID)
            ctx.rebuildAllTabs()
            -- reactivate=true: after the rebuild the shell's current row is
            -- the same spy with its updated focus, so the pop re-announces it.
            HandlerStack.removeByName(displayName, true)
        end,
    })
end

local function pushChoiceSub(agent, city, isCounterspy)
    local event = isCounterspy and counterspyEvent() or espionageSetupEvent()
    local subName = isCounterspy and "EspionageOverview/Counterspy" or "EspionageOverview/Mission"
    local displayName
    if isCounterspy then
        displayName =
            Text.format("TXT_KEY_CIVVACCESS_ESPIONAGE_COUNTERSPY_SUB", Text.key(agent.Rank), Text.key(agent.Name))
    else
        displayName = Text.format(
            "TXT_KEY_CIVVACCESS_ESPIONAGE_MISSION_SUB",
            Text.key(agent.Rank),
            Text.key(agent.Name),
            Text.key(city:GetName())
        )
    end

    local items = {}
    forEachChoice(event, function(info)
        items[#items + 1] = buildChoiceItem(info, event, agent, city, isCounterspy, subName)
    end)

    -- Offensive missions also surface the passive-bonus drillable and the
    -- network-point-gated View City action; counterspy focus (own city) has
    -- neither.
    if not isCounterspy then
        local spy = agent
        local viewThreshold = revealThreshold(GameInfo.SpyPassiveBonuses, "RevealCityScreen")
        if viewThreshold ~= 999999 then
            if spy.MaxNetworkPointsStored >= viewThreshold then
                items[#items + 1] = BaseMenuItems.Choice({
                    labelText = Text.key("TXT_KEY_POPUP_VIEW_CITY"),
                    activate = function()
                        ctx.viewCity(city)
                    end,
                })
            else
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_POPUP_VIEW_CITY"),
                    tooltipText = Text.format("TXT_KEY_EO_CITY_SCREEN_NOT_ENOUGH_NP", viewThreshold),
                })
            end
        end
        items[#items + 1] = passiveBonusGroup(spy, false)
    end

    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_EO_NO_ACTIONS_POSSIBLE") })
    end

    HandlerStack.push(BaseMenu.create({
        name = subName,
        displayName = displayName,
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    }))
end

-- ===== Diplomat panel: unit list =====

-- The rival's military units by class (combat or ranged-combat units the
-- player owns), mirroring the vendor's OnViewUnitListClicked scan.
local function buildUnitListRows(targetID)
    local pPlayer = Players[targetID]
    local rows = {}
    for uc in GameInfo.UnitClasses() do
        local count = pPlayer:GetUnitClassCount(uc.ID)
        if count > 0 then
            local unitID = pPlayer:GetSpecificUnitType(uc.Type)
            local unitInfo = (unitID ~= nil and unitID ~= -1) and GameInfo.Units[unitID] or nil
            if unitInfo ~= nil and (unitInfo.Combat > 0 or unitInfo.RangedCombat > 0) then
                rows[#rows + 1] = {
                    name = Text.key(unitInfo.Description),
                    strength = unitInfo.Combat,
                    ranged = unitInfo.RangedCombat,
                    count = count,
                }
            end
        end
    end
    return rows
end

local function dashOrNum(n)
    if n > 0 then
        return tostring(n)
    end
    return "-"
end

local function pushUnitListSub(targetID)
    local tbl = BaseTable.create({
        tabName = "TXT_KEY_EO_VIEW_UNIT_LIST",
        columns = {
            {
                name = "TXT_KEY_EO_NAME",
                getCell = function(r)
                    return r.name
                end,
                sortKey = function(r)
                    return r.name
                end,
            },
            {
                name = "TXT_KEY_CIVVACCESS_ESPIONAGE_UL_STRENGTH",
                getCell = function(r)
                    return dashOrNum(r.strength)
                end,
                sortKey = function(r)
                    return r.strength
                end,
            },
            {
                name = "TXT_KEY_CIVVACCESS_ESPIONAGE_UL_RANGED",
                getCell = function(r)
                    return dashOrNum(r.ranged)
                end,
                sortKey = function(r)
                    return r.ranged
                end,
            },
            {
                name = "TXT_KEY_EO_NUMBER_UNITS",
                getCell = function(r)
                    return tostring(r.count)
                end,
                sortKey = function(r)
                    return r.count
                end,
            },
        },
        rebuildRows = function()
            return buildUnitListRows(targetID)
        end,
        rowLabel = function(r)
            return r.name
        end,
        defaultSort = { column = 4, ascending = false },
    })
    tbl.name = "EspionageOverview/UnitList"
    -- BaseTable builds its own bindings and doesn't honor escapePops, so add an
    -- Esc binding that pops back to the diplomat panel (reactivate re-announces
    -- it).
    tbl.bindings[#tbl.bindings + 1] = {
        key = Keys.VK_ESCAPE,
        mods = 0,
        description = "Close",
        fn = function()
            HandlerStack.removeByName("EspionageOverview/UnitList", true)
        end,
    }
    HandlerStack.push(tbl)
end

-- ===== Diplomat panel: trade deals =====

-- The rival's current deals, each rendered read-only by the shared deal-label
-- helper from the rival's own seat.
local function pushTradeDealsSub(targetID)
    local items = {}
    local n = UI.GetNumCurrentDeals(targetID) or 0
    if n == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS") })
    else
        for i = 0, n - 1 do
            UI.LoadCurrentDeal(targetID, i)
            local label, pediaName = DealLabel.buildDealLabel(targetID, UI.GetScratchDeal(), false)
            items[#items + 1] = BaseMenuItems.Text({ labelText = label, pediaName = pediaName })
        end
        UI.GetScratchDeal():ClearItems()
    end

    HandlerStack.push(BaseMenu.create({
        name = "EspionageOverview/TradeDeals",
        displayName = Text.key("TXT_KEY_EO_VIEW_TRADE_DEALS"),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    }))
end

-- ===== Diplomat panel =====

-- One network-point-gated view action. Hidden entirely when no bonus grants
-- the view (threshold sentinel); listed as an inert row with the engine's
-- not-enough-NP reason when locked; a live Choice when unlocked.
local function diplomatViewItem(labelKey, notEnoughKey, threshold, maxNP, openFn)
    if threshold == 999999 then
        return nil
    end
    if maxNP >= threshold then
        return BaseMenuItems.Choice({ labelText = Text.key(labelKey), activate = openFn })
    end
    return BaseMenuItems.Text({
        labelText = Text.key(labelKey),
        tooltipText = Text.format(notEnoughKey, threshold),
    })
end

local DIPLOMAT_SUB_NAME = "EspionageOverview/Diplomat"

-- The tech-tree and policy views fire an engine popup for a different Context.
-- The engine queues that popup BEHIND the still-open espionage overview, so the
-- screen does not show (and our handler does not push) until the overview
-- closes -- leaving the user stranded in the diplomat sub. Mirror viewCity: pop
-- the diplomat sub and dismiss the overview so the read-only screen surfaces at
-- once on a clean handler stack. The user re-opens espionage (Ctrl+Shift+E) to
-- return, same as the View City flow. The unit-list / trade-deals views are our
-- own BaseMenu subs, not engine popups, so they keep the overview open behind.
local function openForeignScreen(popupArgs)
    HandlerStack.removeByName(DIPLOMAT_SUB_NAME, false)
    Events.SerialEventGameMessagePopup(popupArgs)
    ctx.closeOverview()
end

local function pushDiplomatSub(agent, city)
    local targetID = city:GetOwner()
    local maxNP = agent.MaxNetworkPointsStored
    local dt = GameInfo.SpyPassiveBonusesDiplomat

    local items = {}

    local tech = diplomatViewItem(
        "TXT_KEY_VIEW_TECH_SCREEN",
        "TXT_KEY_VIEW_TECH_SCREEN_NOT_ENOUGH_NP",
        revealThreshold(dt, "RevealTechTree"),
        maxNP,
        function()
            openForeignScreen({
                Type = ButtonPopupTypes.BUTTONPOPUP_TECH_TREE,
                Data2 = -1,
                Data4 = 1,
                Data5 = targetID,
            })
        end
    )
    if tech ~= nil then
        items[#items + 1] = tech
    end

    local policy = diplomatViewItem(
        "TXT_KEY_EO_VIEW_POLICY_SCREEN",
        "TXT_KEY_EO_VIEW_POLICY_SCREEN_NOT_ENOUGH_NP",
        revealThreshold(dt, "RevealPolicyTree"),
        maxNP,
        function()
            openForeignScreen({
                Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY,
                Data3 = 1,
                Data4 = targetID,
            })
        end
    )
    if policy ~= nil then
        items[#items + 1] = policy
    end

    local units = diplomatViewItem(
        "TXT_KEY_EO_VIEW_UNIT_LIST",
        "TXT_KEY_EO_VIEW_UNIT_LIST_NOT_ENOUGH_NP",
        revealThreshold(dt, "RevealMilitaryUnitCount"),
        maxNP,
        function()
            pushUnitListSub(targetID)
        end
    )
    if units ~= nil then
        items[#items + 1] = units
    end

    local deals = diplomatViewItem(
        "TXT_KEY_EO_VIEW_TRADE_DEALS",
        "TXT_KEY_EO_VIEW_TRADE_DEALS_NOT_ENOUGH_NP",
        revealThreshold(dt, "RevealTradeDeals"),
        maxNP,
        function()
            pushTradeDealsSub(targetID)
        end
    )
    if deals ~= nil then
        items[#items + 1] = deals
    end

    items[#items + 1] = passiveBonusGroup(agent, true)

    HandlerStack.push(BaseMenu.create({
        name = DIPLOMAT_SUB_NAME,
        displayName = Text.format(
            "TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_SUB",
            Text.key(agent.Rank),
            Text.key(agent.Name),
            Text.key(city:GetName())
        ),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    }))
end

-- ===== Agent actions =====

-- A travelling/blocked action stays listed but speaks the engine's reason on
-- activate instead of opening, so the user hears why it is unavailable rather
-- than getting silence.
local function gatedAction(label, reasonTT, openFn)
    if reasonTT ~= nil then
        return {
            label = label,
            tooltip = reasonTT,
            onActivate = function()
                SpeechPipeline.speakInterrupt(reasonTT)
            end,
        }
    end
    return { label = label, onActivate = openFn }
end

-- Action specs for a spy under VP, in the same {label, tooltip?, onActivate}
-- shape the vanilla builder uses, so the access wrapper's one-vs-many handling
-- is unchanged. Counterspy (own city) / diplomat or mission (foreign major) /
-- relocate; city-states get only relocate (no offensive action under VP).
function EspionageVP.agentActions(agent)
    if agent.State == "TXT_KEY_SPY_STATE_DEAD" then
        return {}
    end
    local pPlayer = ctx.activePlayer()
    local city = ctx.plotCity(agent.CityX, agent.CityY)
    local actions = {}
    local travelling = agent.State == "TXT_KEY_SPY_STATE_TRAVELLING"

    if city ~= nil then
        local owner = Players[city:GetOwner()]
        if city:GetOwner() == Game.GetActivePlayer() then
            -- Own city: counterspy focus.
            local reason
            if travelling then
                reason = Text.format("TXT_KEY_EO_COUNTERSPY_TRAVELING_TOOLTIP", agent.Rank, agent.Name, city:GetName())
            elseif agent.NumTurnsMovementBlocked and agent.NumTurnsMovementBlocked > 0 then
                reason = Text.format(
                    "TXT_KEY_EO_COUNTERSPY_CANNOT_CHANGE_FOCUS_TT",
                    agent.Rank,
                    agent.Name,
                    agent.NumTurnsMovementBlocked
                )
            end
            actions[#actions + 1] = gatedAction(Text.key("TXT_KEY_EO_COUNTERSPY"), reason, function()
                pushChoiceSub(agent, city, true)
            end)
        elseif not owner:IsMinorCiv() then
            -- Foreign major city: diplomat panel or offensive missions.
            if pPlayer:IsSpyDiplomat(agent.AgentID) then
                local reason = travelling
                        and Text.format("TXT_KEY_EO_DIPLOMAT_TRAVELING_TOOLTIP", agent.Rank, agent.Name, city:GetName())
                    or nil
                actions[#actions + 1] = gatedAction(Text.key("TXT_KEY_EO_DIPLOMAT"), reason, function()
                    pushDiplomatSub(agent, city)
                end)
            else
                local reason = travelling
                        and Text.format("TXT_KEY_EO_MISSIONS_TRAVELING_TOOLTIP", agent.Rank, agent.Name, city:GetName())
                    or nil
                actions[#actions + 1] = gatedAction(Text.key("TXT_KEY_EO_MISSIONS"), reason, function()
                    pushChoiceSub(agent, city, false)
                end)
            end
        end
    end

    -- Relocate: disabled by counterspy lockout or a vassal-diplomat binding.
    local relocateReason
    if agent.NumTurnsMovementBlocked and agent.NumTurnsMovementBlocked > 0 then
        relocateReason =
            Text.format("TXT_KEY_EO_COUNTERSPY_CANNOT_MOVE_TT", agent.Rank, agent.Name, agent.NumTurnsMovementBlocked)
    elseif agent.VassalDiplomatPlayer and agent.VassalDiplomatPlayer >= 0 then
        relocateReason = Text.format(
            "TXT_KEY_EO_VASSAL_DIPLOMAT_CANNOT_MOVE_TT",
            agent.Rank,
            agent.Name,
            Players[agent.VassalDiplomatPlayer]:GetCivilizationShortDescription()
        )
    end
    actions[#actions + 1] = gatedAction(Text.key("TXT_KEY_EO_RELOCATE"), relocateReason, function()
        ctx.pushMoveSub(agent)
    end)

    return actions
end

return EspionageVP

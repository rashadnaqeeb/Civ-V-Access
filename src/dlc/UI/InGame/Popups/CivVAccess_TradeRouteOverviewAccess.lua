-- Trade Route Overview accessibility (Ctrl+T). Wraps the engine popup as a
-- three-tab TabbedShell, every tab a flat BaseMenu list of route Groups.
--
--   Your trade routes      pPlayer:GetTradeRoutes()
--                          Routes the active player currently runs (caravans
--                          and cargo ships you have in flight).
--   Available trade routes pPlayer:GetTradeRoutesAvailable()
--                          Routes the active player could establish from
--                          idle trade units.
--   Trade routes with you  pPlayer:GetTradeRoutesToYou()
--                          Routes other civs run that terminate in your
--                          cities (their bonuses, your destination).
--
-- The three accessors return rows with the same field shape (see
-- TradeRouteOverview.lua DisplayData), so the row builder is shared.
--
-- Drill structure mirrors the engine's tooltip
-- (BuildTradeRouteToolTipString) but reorganized so each drillable
-- carries its own headline number on the label. Drilling reveals only
-- the per-source breakdown. Routes with no breakdown to show (domestic
-- food/production routes, where the helper returns nil) collapse to a
-- non-drillable Text leaf so the drillable cue doesn't fire on rows
-- with nothing behind them.
--
-- Engine integration: ships an override of TradeRouteOverview.lua (verbatim
-- BNW copy + an include for this module). The engine's OnPopupMessage,
-- OnClose, ShowHideHandler, InputHandler, RegisterSortOptions, TabSelect,
-- and per-tab RefreshContent stay intact; TabbedShell.install layers our
-- handler on top via priorInput / priorShowHide chains. onShow rebuilds
-- every tab's items so a fresh open after a turn change reflects updated
-- TurnsLeft / GPT values.

include("CivVAccess_PopupBoot")
include("CivVAccess_TabbedShell")
include("CivVAccess_TradeRouteRow")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Tab handles, set during install; module-level so the show hook can
-- rebuild items per tab on every open.
local m_yoursTab
local m_availableTab
local m_withYouTab

-- Split engine markup text on a literal token (e.g. "[NEWLINE]" for
-- per-line splits, "[NEWLINE][NEWLINE]" for paragraph splits), trimming
-- and dropping empty segments. Plain-string find (4th arg true) so the
-- token is matched literally instead of being interpreted as a Lua
-- pattern.
local function splitOn(s, token)
    local out = {}
    if s == nil or s == "" then
        return out
    end
    local cursor = 1
    while true do
        local startIdx, endIdx = s:find(token, cursor, true)
        if startIdx == nil then
            local trimmed = s:sub(cursor):match("^%s*(.-)%s*$")
            if trimmed ~= "" then
                out[#out + 1] = trimmed
            end
            return out
        end
        local trimmed = s:sub(cursor, startIdx - 1):match("^%s*(.-)%s*$")
        if trimmed ~= "" then
            out[#out + 1] = trimmed
        end
        cursor = endIdx + 1
    end
end

-- Parse the engine tooltip into per-section line lists. Each section's
-- first line is its header (e.g. "Your Revenue:"), its last line is its
-- total ("Total: +X gold per turn"), and any middle lines are the
-- per-source breakdown.
--
-- BuildTradeRouteGoldToolTipString in TradeRouteHelpers.lua emits an
-- unconditional [NEWLINE] before strTotal on top of conditional blocks
-- that already ended with one, which collapses into a stray
-- [NEWLINE][NEWLINE] separator and splits "Your Revenue: ..." away from
-- its trailing "Total: +X" into two adjacent top-level chunks. Reattach
-- any single-line continuation chunk to the section above so each
-- section keeps its total intact.
local function parseSections(tooltip)
    local sections = {}
    for _, chunk in ipairs(splitOn(tooltip, "[NEWLINE][NEWLINE]")) do
        local lines = splitOn(chunk, "[NEWLINE]")
        if #lines == 1 and #sections > 0 then
            local prev = sections[#sections]
            prev[#prev + 1] = lines[1]
        elseif #lines > 0 then
            sections[#sections + 1] = lines
        end
    end
    return sections
end

local LUA_PATTERN_SPECIAL_CHARS = "[%(%)%.%%%+%-%*%?%[%]%^%$]"

-- Strip a leader-name prefix from a total line. The engine's
-- TRADEE_TOTAL and THEIR_SCIENCE_TOTAL keys begin with the other
-- party's leader name ("Nebuchadnezzar II Total: 2.5 Gold") to
-- disambiguate whose total this is when the line is read alone in a
-- tooltip. Our section header already says YOUR / THEIR, so the leader
-- name is redundant and reads awkwardly when joined with the header.
local function stripLeaderPrefix(line, leaderNames)
    if line == nil or line == "" or leaderNames == nil then
        return line
    end
    for _, name in ipairs(leaderNames) do
        if name ~= nil and name ~= "" then
            local escaped = name:gsub(LUA_PATTERN_SPECIAL_CHARS, "%%%0")
            local stripped, n = line:gsub("^" .. escaped .. "%s+", "")
            if n > 0 then
                return stripped
            end
        end
    end
    return line
end

-- Build one drillable (or text leaf) for a tooltip section. The label
-- combines the section header with its total so the user hears the
-- headline number ("Your Revenue. Total: +1.7 gold per turn") without
-- having to drill. The drill carries only the per-source breakdown --
-- the total isn't repeated inside.
--
-- Sections with no breakdown (1-2 lines: header alone, or header +
-- total) collapse to a Text leaf so the drillable cue only fires when
-- there's something behind it. The trailing-colon trim on the header
-- avoids a "Your Revenue:. Total: ..." double-colon when the engine's
-- header string ends in a colon.
local function buildSectionItem(lines, leaderNames)
    if #lines == 0 then
        return nil
    end
    if #lines == 1 then
        return BaseMenuItems.Text({ labelText = stripLeaderPrefix(lines[1], leaderNames) })
    end
    local header = lines[1]:gsub("[%s:]+$", "")
    local total = stripLeaderPrefix(lines[#lines], leaderNames)
    local label = header .. ". " .. total
    if #lines == 2 then
        return BaseMenuItems.Text({ labelText = label })
    end
    local detailItems = {}
    for i = 2, #lines - 1 do
        detailItems[#detailItems + 1] = BaseMenuItems.Text({ labelText = lines[i] })
    end
    return BaseMenuItems.Group({
        labelText = label,
        items = detailItems,
    })
end

local function fetchTooltip(route)
    local pPlayer = Players[route.FromID]
    if pPlayer == nil then
        return nil
    end
    local tt
    local ok, err = pcall(function()
        tt = BuildTradeRouteToolTipString(pPlayer, route.FromCity, route.ToCity, route.Domain)
    end)
    if not ok then
        Log.error("TradeRouteOverview: BuildTradeRouteToolTipString failed: " .. tostring(err))
        return nil
    end
    return tt
end

-- Both endpoints' leader names, in the same form the engine helpers use
-- when embedding them in TRADEE_TOTAL / THEIR_SCIENCE_TOTAL: NickName in
-- multiplayer when the player has set one, otherwise the leader's
-- localized name. The list feeds stripLeaderPrefix above; either
-- endpoint can appear as the prefixed name (active player when we view
-- inbound routes, foreign leader when we view outbound routes).
local function leaderNamesForRoute(route)
    local names = {}
    local function add(playerID)
        local p = Players[playerID]
        if p == nil then
            return
        end
        local nick = p:GetNickName()
        if nick ~= nil and nick ~= "" and Game:IsNetworkMultiPlayer() then
            names[#names + 1] = nick
            return
        end
        local name = p:GetName()
        if name ~= nil and name ~= "" then
            names[#names + 1] = name
        end
    end
    add(route.FromID)
    add(route.ToID)
    return names
end

-- The CP DLL registers Game.IsCustomModOption (the sanctioned
-- "Community Patch present" probe). Only then do the VP-only sort keys
-- and the route metrics / corporation surfaces appear.
local function isCP()
    return Game.IsCustomModOption ~= nil
end

-- Route length (hex path distance) and one-way trip turns, both from
-- VP-only bindings on the origin player. Used for sorting and for the
-- per-row metric clauses; nil when the bindings are absent (vanilla) or
-- the city handles are missing.
local function routeLength(route)
    local pPlayer = Players[route.FromID]
    if pPlayer == nil or pPlayer.GetTradeConnectionDistance == nil then
        return nil
    end
    if route.FromCity == nil or route.ToCity == nil then
        return nil
    end
    return pPlayer:GetTradeConnectionDistance(route.FromCity, route.ToCity, route.Domain)
end

local function routeTripTurns(route)
    local pPlayer = Players[route.FromID]
    if pPlayer == nil or pPlayer.GetTradeRouteTurns == nil then
        return nil
    end
    if route.FromCity == nil or route.ToCity == nil then
        return nil
    end
    return pPlayer:GetTradeRouteTurns(route.FromCity, route.ToCity, route.Domain)
end

-- ===== Vox Populi route extras and actions ============================
--
-- Everything below the row's base label (yields / turns-left) is VP-only
-- and gated by binding / field presence so vanilla rows are unchanged:
-- vanilla GetTradeRoutes omits UnitID / culture / TradeConnectionType, and
-- the deployed vanilla TradeRouteOverview.lua defines neither LookAtOrRecall
-- nor g_CurrentTab.

-- Per-row metric and status clauses appended after the base label:
-- corporation franchise status (all tabs), the already-trading and
-- city-state trade-quest flags (Available tab only, mirroring VP's red "!"
-- and trade-quest icon), then route length and one-way trip turns.
-- Recomputed on every announce so the values stay live; the engine reads
-- are cheap and the Available-tab snapshots (ctx) are rebuilt each open.
local function routeExtras(route, tabKind, ctx)
    local parts = {}

    local franchise = TradeRouteRow.franchiseStatus(route, tabKind == "AvailableTR")
    if franchise ~= nil then
        parts[#parts + 1] = franchise
    end

    if tabKind == "AvailableTR" and ctx ~= nil then
        if
            ctx.blockedSet ~= nil
            and route.TradeConnectionType == TradeConnectionTypes.TRADE_CONNECTION_INTERNATIONAL
            and route.ToCityName ~= nil
            and ctx.blockedSet[route.ToCityName .. "#" .. tostring(route.ToCivilizationType)]
        then
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_TRO_ALREADY_TRADING")
        end
        if ctx.questText ~= nil then
            local quest = ctx.questText(route)
            if quest ~= nil then
                parts[#parts + 1] = quest
            end
        end
    end

    local length = routeLength(route)
    if length ~= nil and length > 0 then
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE", length, length)
    end
    local trip = routeTripTurns(route)
    if trip ~= nil and trip > 0 then
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_TRO_TRIP_TURNS", trip, trip)
    end

    return parts
end

-- Drop the hex cursor on a Your-routes trade unit and speak the landing.
-- UI.LookAt / SerialEventUnitFlagSelected mirror VP's own locate (camera
-- pan plus flag select) for sighted spectators; Cursor.jumpTo supplies the
-- spoken position a blind player needs.
local function locateUnit(route)
    local pPlayer = Players[route.FromID]
    if pPlayer == nil then
        return
    end
    local pUnit = pPlayer:GetUnitByID(route.UnitID)
    if pUnit == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_TRO_UNIT_NOT_FOUND"))
        return
    end
    local plot = pUnit:GetPlot()
    UI.LookAt(plot, 0)
    Events.SerialEventUnitFlagSelected(route.FromID, route.UnitID)
    local Cursor = civvaccess_shared.modules and civvaccess_shared.modules.Cursor
    if Cursor == nil then
        Log.warn("TradeRouteOverview locate: Cursor module not published")
        return
    end
    local text = Cursor.jumpTo(plot:GetX(), plot:GetY())
    if text ~= nil and text ~= "" then
        SpeechPipeline.speakQueued(text)
    end
end

-- Establish or relocate by delegating to VP's own LookAtOrRecall, which
-- owns the mission dispatch (and closes the popup on success). It branches
-- on the vendor global g_CurrentTab, which our TabbedShell does not track,
-- so set it for the call and restore it after. We only reach this from
-- rows where availableAction already confirmed the unit can act, so the
-- vendor call always fires a mission rather than silently no-opping.
local function commitAvailableMission(route)
    if LookAtOrRecall == nil then
        Log.warn("TradeRouteOverview: LookAtOrRecall absent; cannot establish route")
        return
    end
    local saved = g_CurrentTab
    g_CurrentTab = "AvailableTR"
    local ok, err = pcall(LookAtOrRecall, {}, route)
    g_CurrentTab = saved
    if not ok then
        Log.error("TradeRouteOverview establish/relocate failed: " .. tostring(err))
    end
end

-- Snapshot the Available tab's per-rebuild context: which destination
-- cities the player already runs an international route to (the blocked
-- flag), a closure for the active city-state trade-quest check, and the
-- selected trade unit's eligibility for establishing / relocating. Rebuilt
-- on every open and turn start; VP closes the screen on unit-selection
-- change (its OnDirty), so the eligibility snapshot can't outlive its unit.
local function buildAvailableContext()
    local ctx = { blockedSet = {} }
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return ctx
    end

    for _, r in ipairs(pPlayer:GetTradeRoutes() or {}) do
        if r.ToCityName ~= nil then
            ctx.blockedSet[r.ToCityName .. "#" .. tostring(r.ToCivilizationType)] = true
        end
    end

    -- GetActiveQuestText (CityStateStatusHelper) is included by VP's
    -- TradeRouteOverview.lua; absent on vanilla. Mirror VP's own test: a
    -- minor-civ destination whose active-quest text carries the
    -- international-trade icon has a trade-route quest available.
    if GetActiveQuestText ~= nil then
        ctx.questText = function(route)
            local toPlayer = Players[route.ToID]
            if toPlayer == nil or not toPlayer:IsMinorCiv() then
                return nil
            end
            local txt = GetActiveQuestText(route.FromID, route.ToID)
            if txt ~= nil and txt:find("ICON_INTERNATIONAL_TRADE", 1, true) then
                return Text.key("TXT_KEY_CIVVACCESS_TRADE_DEST_QUEST")
            end
            return nil
        end
    end

    -- Establish / relocate need the selected unit; gate on the VP-only
    -- LookAtOrRecall (which performs the mission) and IsRecalledTrader.
    if LookAtOrRecall ~= nil then
        local sel = UI.GetHeadSelectedUnit()
        if
            sel ~= nil
            and sel.IsTrade ~= nil
            and sel:IsTrade()
            and not sel:IsRecalledTrader()
            and not sel:IsAutomated()
            and sel:MovesLeft() > 0
        then
            ctx.eligible = true
            ctx.originCity = sel:GetPlot():GetPlotCity()
            ctx.domain = sel:GetDomainType()
            ctx.newHomeSet = {}
            if pPlayer.GetPotentialTradeUnitNewHomeCity ~= nil then
                for _, h in ipairs(pPlayer:GetPotentialTradeUnitNewHomeCity(sel) or {}) do
                    ctx.newHomeSet[h.X .. "#" .. h.Y] = true
                end
            end
        end
    end

    return ctx
end

-- Decide which Available-tab action a route offers for the selected trade
-- unit, mirroring VP's send-vs-relocate branch: establish when the unit
-- sits in this route's origin city with the matching domain; relocate when
-- the unit is elsewhere and this origin is one of its potential new homes.
-- Returns "establish" / "relocate" / nil.
local function availableAction(route, ctx)
    if ctx == nil or not ctx.eligible then
        return nil
    end
    if route.FromCity == ctx.originCity and route.Domain == ctx.domain then
        return "establish"
    end
    if route.FromCity ~= ctx.originCity and route.FromCity ~= nil then
        local key = route.FromCity:GetX() .. "#" .. route.FromCity:GetY()
        if ctx.newHomeSet[key] then
            return "relocate"
        end
    end
    return nil
end

-- The action item placed first inside a route's drill. locate is its own
-- reimplementation (it needs the unit plot for the cursor); establish /
-- relocate delegate to the vendor mission.
local function buildActionItem(route, actionKind)
    if actionKind == "locate" then
        return BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_TRO_LOCATE_UNIT"),
            onActivate = function()
                locateUnit(route)
            end,
        })
    end
    local labelKey = actionKind == "relocate" and "TXT_KEY_CIVVACCESS_TRO_RELOCATE"
        or "TXT_KEY_CIVVACCESS_TRO_ESTABLISH"
    return BaseMenuItems.Text({
        labelText = Text.key(labelKey),
        onActivate = function()
            commitAvailableMission(route)
        end,
    })
end

-- A route is drillable when it has a per-source gold breakdown OR an
-- action (locate / establish / relocate). BuildTradeRouteToolTipString
-- returns nil when the international gold total is zero -- domestic
-- food/production routes, unestablished routes, etc. -- so a route with
-- neither breakdown nor action collapses to a Text leaf carrying just the
-- row label, keeping the drillable cue silent on rows with nothing behind
-- them. The eager probe is the engine helper itself; the same helper runs
-- again inside itemsFn on each drill so the per-source breakdown reflects
-- current live values without waiting for the per-turn rebuild
-- (cached=false). The action item, when present, is the first drill child.
local function buildRouteItem(route, isInbound, tabKind, ctx)
    local actionKind
    if tabKind == "YourTR" and route.UnitID ~= nil then
        actionKind = "locate"
    elseif tabKind == "AvailableTR" then
        actionKind = availableAction(route, ctx)
    end

    local labelFn = function()
        local base = TradeRouteRow.rowLabel(route, isInbound)
        local extras = routeExtras(route, tabKind, ctx)
        if #extras > 0 then
            base = base .. " " .. table.concat(extras, ". ") .. "."
        end
        return base
    end

    local probe = fetchTooltip(route)
    local hasBreakdown = probe ~= nil and probe ~= ""
    if actionKind == nil and not hasBreakdown then
        return BaseMenuItems.Text({ labelFn = labelFn })
    end
    return BaseMenuItems.Group({
        labelFn = labelFn,
        cached = false,
        itemsFn = function()
            local items = {}
            if actionKind ~= nil then
                items[#items + 1] = buildActionItem(route, actionKind)
            end
            local tt = fetchTooltip(route)
            local names = leaderNamesForRoute(route)
            for _, lines in ipairs(parseSections(tt)) do
                local item = buildSectionItem(lines, names)
                if item ~= nil then
                    items[#items + 1] = item
                end
            end
            -- No action and the tooltip emptied between probe and drill
            -- (helper threw, or the international gold total dropped to
            -- zero in the same turn). Rare; speak something rather than
            -- leave the Group empty, which BaseMenuItems.Group treats as
            -- non-navigable and would drop the route from the list
            -- mid-screen.
            if #items == 0 then
                items[1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"),
                })
            end
            return items
        end,
    })
end

-- Sort options exposed via the pulldown at the top of each tab. Five
-- of the engine's 13 sortable columns -- the ones a player actually
-- uses -- framed as "what I receive" so the same option name maps to
-- the right field on either tab direction:
--   GOLD / SCIENCE  -> outbound (Yours/Available) reads From*; inbound
--                      (With You) reads To*. The active player is the
--                      anchor either way.
--   FOOD / PRODUCTION -> always To* (these yields land at the
--                        destination; for outbound domestic routes the
--                        destination is one of our cities, on inbound
--                        the destination is us either way).
--   PRESSURE        -> always destination-side, regardless of tab.
--                      Religion pressure is interesting from the
--                      "spreading toward" framing rather than the
--                      receiving-civ framing.
-- Sort direction is descending (largest first) so the top-of-list
-- routes are the ones the player most wants to see.
-- Culture, trip-turns, and route-length are Vox Populi trade surfaces
-- (culture is a VP-only trade yield; trip / length come from VP-only
-- bindings). Gating them on the CP-DLL probe keeps the vanilla picker's
-- five options unchanged; on VP they extend it. CULTURE sorts descending
-- like the other yields (most received first); TRIP / LENGTH sort
-- ascending so the shortest routes lead, which is what the "shortest"
-- label promises.
local SORT_KEYS_BASE = { "GOLD", "SCIENCE", "FOOD", "PRODUCTION", "PRESSURE" }
local SORT_KEYS_VP = { "CULTURE", "TRIP", "LENGTH" }

local SORT_LABEL_KEYS = {
    GOLD = "TXT_KEY_CIVVACCESS_TRO_SORT_GOLD",
    SCIENCE = "TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE",
    FOOD = "TXT_KEY_CIVVACCESS_TRO_SORT_FOOD",
    PRODUCTION = "TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION",
    PRESSURE = "TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE",
    CULTURE = "TXT_KEY_CIVVACCESS_TRO_SORT_CULTURE",
    TRIP = "TXT_KEY_CIVVACCESS_TRO_SORT_TRIP",
    LENGTH = "TXT_KEY_CIVVACCESS_TRO_SORT_LENGTH",
}

local SORT_ASCENDING = { TRIP = true, LENGTH = true }

local function currentSortKeys()
    local keys = {}
    for _, k in ipairs(SORT_KEYS_BASE) do
        keys[#keys + 1] = k
    end
    if isCP() then
        for _, k in ipairs(SORT_KEYS_VP) do
            keys[#keys + 1] = k
        end
    end
    return keys
end

local SORT_SUB_NAME = "TradeRouteOverviewSort"

-- Module-level current sort. Persists across tab switches and within-
-- session reopens so the user's pick sticks. Load-from-game wipes the
-- env (see Architecture Gotchas) and resets this back to the default,
-- which is fine -- the user picks a sort each session anyway. Default
-- to GOLD so the screen opens on the most relevant ordering instead
-- of an alphabetical list the user has to scroll through.
local m_currentSort = "GOLD"

-- Forward-declared at install; the sort sub-menu's Choice activate
-- calls this to re-sort and re-render every tab when the user picks a
-- new key.
local m_rebuildAllTabs

local function sortValue(route, sortKey, isInbound)
    if sortKey == "GOLD" then
        return isInbound and (route.ToGPT or 0) or (route.FromGPT or 0)
    elseif sortKey == "SCIENCE" then
        return isInbound and (route.ToScience or 0) or (route.FromScience or 0)
    elseif sortKey == "CULTURE" then
        return isInbound and (route.ToCulture or 0) or (route.FromCulture or 0)
    elseif sortKey == "FOOD" then
        return route.ToFood or 0
    elseif sortKey == "PRODUCTION" then
        return route.ToProduction or 0
    elseif sortKey == "PRESSURE" then
        return route.ToPressure or 0
    elseif sortKey == "TRIP" then
        return routeTripTurns(route) or 0
    elseif sortKey == "LENGTH" then
        return routeLength(route) or 0
    end
    return 0
end

local function sortRoutes(routes, isInbound)
    local ascending = SORT_ASCENDING[m_currentSort]
    table.sort(routes, function(a, b)
        local va = sortValue(a, m_currentSort, isInbound)
        local vb = sortValue(b, m_currentSort, isInbound)
        if ascending then
            return va < vb
        end
        return va > vb
    end)
end

-- Push the sort-picker as its own BaseMenu sub-handler. Each Choice
-- commits a new sort and pops itself; selectedFn marks the current
-- pick so the user hears "selected, gold received" while browsing the
-- list. initialIndex lands the cursor on the current pick instead of
-- the top, so a "no change" pop is one Esc rather than first
-- navigating off the current pick.
local function pushSortPicker()
    local options = {}
    local initialIndex
    for i, key in ipairs(currentSortKeys()) do
        if key == m_currentSort then
            initialIndex = i
        end
        local k = key
        options[#options + 1] = BaseMenuItems.Choice({
            textKey = SORT_LABEL_KEYS[k],
            selectedFn = function()
                return m_currentSort == k
            end,
            activate = function()
                m_currentSort = k
                if m_rebuildAllTabs ~= nil then
                    m_rebuildAllTabs()
                end
                HandlerStack.removeByName(SORT_SUB_NAME, true)
            end,
        })
    end
    local sub = BaseMenu.create({
        name = SORT_SUB_NAME,
        displayName = Text.key("TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"),
        items = options,
        initialIndex = initialIndex,
        escapePops = true,
    })
    HandlerStack.push(sub)
end

-- Top-of-tab pulldown. Choice kind so Right arrow stays a no-op
-- (Right would drill on a Group; we want Enter-to-open semantics
-- only). Label re-resolves on each nav so picking a new sort updates
-- the spoken label without rebuilding the parent item.
local function buildSortPulldown()
    return BaseMenuItems.Choice({
        labelFn = function()
            return Text.format("TXT_KEY_CIVVACCESS_TRO_SORT_LABEL", Text.key(SORT_LABEL_KEYS[m_currentSort]))
        end,
        activate = pushSortPicker,
    })
end

local function buildItemsFromRoutes(routes, isInbound, tabKind)
    sortRoutes(routes, isInbound)
    -- Available-tab context (blocked / quest / unit eligibility) is
    -- snapshotted once per rebuild and shared across this tab's rows.
    local ctx = (tabKind == "AvailableTR") and buildAvailableContext() or nil
    local items = { buildSortPulldown() }
    for _, route in ipairs(routes) do
        items[#items + 1] = buildRouteItem(route, isInbound, tabKind, ctx)
    end
    if #routes == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"),
        })
    end
    return items
end

local function buildItemsViaAccessor(accessor, isInbound, tabKind)
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return {}
    end
    return buildItemsFromRoutes(pPlayer[accessor](pPlayer) or {}, isInbound, tabKind)
end

-- ===== Install =========================================================

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    local function makeTab(tabName)
        return TabbedShell.menuTab({
            tabName = tabName,
            menuSpec = {
                displayName = Text.key("TXT_KEY_TRADE_ROUTE_OVERVIEW"),
                items = {},
            },
        })
    end
    m_yoursTab = makeTab("TXT_KEY_CIVVACCESS_TRO_TAB_YOURS")
    m_availableTab = makeTab("TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE")
    m_withYouTab = makeTab("TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU")

    local function rebuildAllTabs()
        m_yoursTab.menu().setItems(buildItemsViaAccessor("GetTradeRoutes", false, "YourTR"))
        m_availableTab.menu().setItems(buildItemsViaAccessor("GetTradeRoutesAvailable", false, "AvailableTR"))
        m_withYouTab.menu().setItems(buildItemsViaAccessor("GetTradeRoutesToYou", true, "TRWithYou"))
    end
    m_rebuildAllTabs = rebuildAllTabs

    TabbedShell.install(ContextPtr, {
        name = "TradeRouteOverview",
        displayName = Text.key("TXT_KEY_TRADE_ROUTE_OVERVIEW"),
        tabs = { m_yoursTab, m_availableTab, m_withYouTab },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(_handler)
            rebuildAllTabs()
        end,
    })

    -- Routes the active player runs are recomputed on every turn; if the
    -- user keeps the popup open across End Turn, the snapshot TradeRouteRow
    -- .rowLabel closes over (FromGPT, ToGPT, TurnsLeft, ...) goes stale on
    -- the old labels until rebuild. Re-rebuild on ActivePlayerTurnStart so
    -- the user always hears current turn values. Guard on IsHidden so we
    -- don't waste work when the popup isn't open. Registered on every
    -- Context include rather than gated by an install-once flag because
    -- load-from-game wipes this Context's env and re-registers a fresh
    -- listener (see Architecture Gotchas in CLAUDE.md).
    Events.ActivePlayerTurnStart.Add(function()
        if ContextPtr:IsHidden() then
            return
        end
        rebuildAllTabs()
    end)
end

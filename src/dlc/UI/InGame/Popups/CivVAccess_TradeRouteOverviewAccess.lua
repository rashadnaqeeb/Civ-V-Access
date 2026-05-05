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

-- Compose the per-side endpoint identifier for a route row. Three
-- cases. Own city is the bare city name -- the user already knows which
-- civ they are, so the parenthetical civ name only adds noise. City-
-- state endpoints read as "the city-state of X" so the row makes the
-- CS-ness explicit without naming the placeholder "City-State" minor
-- civ ("Sidon (Sidon)" was the prior wording). Foreign major civs
-- reuse the choose-trade-route popup's "Civ, City" framing so the two
-- screens read consistently when the user moves between them.
local function cityIdentifier(playerID, cityName)
    if playerID == Game.GetActivePlayer() then
        return cityName
    end
    local pPlayer = Players[playerID]
    if pPlayer == nil then
        return cityName
    end
    if pPlayer:IsMinorCiv() then
        return Text.format("TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF", cityName)
    end
    return Text.format(
        "TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL",
        Text.key(pPlayer:GetCivilizationShortDescriptionKey()),
        cityName
    )
end

local function domainLabel(domain)
    if domain == DomainTypes.DOMAIN_SEA then
        return Text.key("TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA")
    end
    return Text.key("TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND")
end

local function appendIf(list, entry)
    if entry ~= nil and entry ~= "" then
        list[#list + 1] = entry
    end
end

-- Origin's side: GPT, science, religion pressure that flow back to the
-- origin city. Field names match the engine's GetTradeRoutes shape (see
-- TradeRouteOverview.lua DisplayData).
local function originSideList(route)
    local entries = {}
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_GOLD, route.FromGPT or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_SCIENCE, route.FromScience or 0))
    appendIf(entries, TradeRouteRow.pressureEntry(route.FromReligion or 0, route.FromPressure or 0))
    return table.concat(entries, ", ")
end

-- Destination's side: GPT, science, religion pressure plus food / production
-- (the latter two flow on intra-civ routes and the engine reports them as 0
-- on international routes).
local function destinationSideList(route)
    local entries = {}
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_GOLD, route.ToGPT or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_SCIENCE, route.ToScience or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_FOOD, route.ToFood or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_PRODUCTION, route.ToProduction or 0))
    appendIf(entries, TradeRouteRow.pressureEntry(route.ToReligion or 0, route.ToPressure or 0))
    return table.concat(entries, ", ")
end

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

-- Row label mirrors the choose-international-trade-route popup's row format:
-- header, then "you get {yields}" (active player's gain), then "they get
-- {yields}" (other party's gain), then turns-left when valid. Joined with
-- ". " and a trailing period so each clause reads as its own sentence.
--
-- "You" is always the active player, so the side-mapping flips by tab
-- direction: outbound routes (Yours / Available) put the active player at
-- the origin, inbound routes (With You) put them at the destination. The
-- engine's TurnsLeft is negative on routes that haven't been established
-- (Available tab) and on some transitional states; we mirror the engine's
-- own >= 0 guard from TradeRouteOverview.lua DisplayData and omit the
-- clause rather than speak nonsense like "minus 8 turns left."
local function rowLabel(route, isInbound)
    local parts = {}
    parts[#parts + 1] = Text.format(
        "TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER",
        domainLabel(route.Domain),
        cityIdentifier(route.FromID, route.FromCityName),
        cityIdentifier(route.ToID, route.ToCityName)
    )

    local originYields = originSideList(route)
    local destinationYields = destinationSideList(route)
    if route.FromID == route.ToID then
        -- Domestic route: both endpoints are the active player's cities
        -- (the With-You tab can't reach this branch -- inbound routes
        -- by definition have a foreign origin). "You get / they get"
        -- is meaningless when both sides are us, so frame each side by
        -- the city that earns the yields.
        if originYields ~= "" then
            parts[#parts + 1] = Text.format(
                "TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS",
                route.FromCityName,
                originYields
            )
        end
        if destinationYields ~= "" then
            parts[#parts + 1] = Text.format(
                "TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS",
                route.ToCityName,
                destinationYields
            )
        end
    else
        local yourSide, theirSide
        if isInbound then
            yourSide = destinationYields
            theirSide = originYields
        else
            yourSide = originYields
            theirSide = destinationYields
        end
        if yourSide ~= "" then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET", yourSide)
        end
        if theirSide ~= "" then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET", theirSide)
        end
    end

    local turns = route.TurnsLeft
    if turns ~= nil and turns >= 0 then
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT", turns, turns)
    end

    return table.concat(parts, ". ") .. "."
end

-- A route is drillable only when the engine has a per-source breakdown
-- to show. BuildTradeRouteToolTipString returns nil when the route's
-- international gold total is zero -- domestic food/production routes,
-- routes that haven't been established yet, etc. Those cases collapse to
-- a Text leaf carrying just the row label, so the drillable cue stays
-- silent on rows with nothing behind them. The eager probe is the
-- engine helper itself; the same helper runs again inside itemsFn on
-- each drill so the per-source breakdown reflects current live values
-- without waiting for the per-turn rebuild (cached=false).
local function buildRouteItem(route, isInbound)
    local labelFn = function()
        return rowLabel(route, isInbound)
    end
    local probe = fetchTooltip(route)
    if probe == nil or probe == "" then
        return BaseMenuItems.Text({ labelFn = labelFn })
    end
    return BaseMenuItems.Group({
        labelFn = labelFn,
        cached = false,
        itemsFn = function()
            local tt = fetchTooltip(route)
            local names = leaderNamesForRoute(route)
            local items = {}
            for _, lines in ipairs(parseSections(tt)) do
                local item = buildSectionItem(lines, names)
                if item ~= nil then
                    items[#items + 1] = item
                end
            end
            -- Tooltip emptied between probe and drill (helper threw, or
            -- the international gold total dropped to zero in the same
            -- turn). Rare; speak something rather than leave the Group
            -- empty, which BaseMenuItems.Group treats as non-navigable
            -- and would drop the route from the list mid-screen.
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
local SORT_KEYS = { "GOLD", "SCIENCE", "FOOD", "PRODUCTION", "PRESSURE" }

local SORT_LABEL_KEYS = {
    GOLD = "TXT_KEY_CIVVACCESS_TRO_SORT_GOLD",
    SCIENCE = "TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE",
    FOOD = "TXT_KEY_CIVVACCESS_TRO_SORT_FOOD",
    PRODUCTION = "TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION",
    PRESSURE = "TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE",
}

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
    elseif sortKey == "FOOD" then
        return route.ToFood or 0
    elseif sortKey == "PRODUCTION" then
        return route.ToProduction or 0
    elseif sortKey == "PRESSURE" then
        return route.ToPressure or 0
    end
    return 0
end

local function sortRoutes(routes, isInbound)
    table.sort(routes, function(a, b)
        return sortValue(a, m_currentSort, isInbound) > sortValue(b, m_currentSort, isInbound)
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
    for i, key in ipairs(SORT_KEYS) do
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
            return Text.format(
                "TXT_KEY_CIVVACCESS_TRO_SORT_LABEL",
                Text.key(SORT_LABEL_KEYS[m_currentSort])
            )
        end,
        activate = pushSortPicker,
    })
end

local function buildItemsFromRoutes(routes, isInbound)
    sortRoutes(routes, isInbound)
    local items = { buildSortPulldown() }
    for _, route in ipairs(routes) do
        items[#items + 1] = buildRouteItem(route, isInbound)
    end
    if #routes == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"),
        })
    end
    return items
end

local function buildItemsViaAccessor(accessor, isInbound)
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return {}
    end
    return buildItemsFromRoutes(pPlayer[accessor](pPlayer) or {}, isInbound)
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
        m_yoursTab.menu().setItems(buildItemsViaAccessor("GetTradeRoutes", false))
        m_availableTab.menu().setItems(buildItemsViaAccessor("GetTradeRoutesAvailable", false))
        m_withYouTab.menu().setItems(buildItemsViaAccessor("GetTradeRoutesToYou", true))
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
    -- user keeps the popup open across End Turn, the snapshot rowLabel
    -- closes over (FromGPT, ToGPT, TurnsLeft, ...) goes stale on the
    -- old labels until rebuild. Re-rebuild on ActivePlayerTurnStart so
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

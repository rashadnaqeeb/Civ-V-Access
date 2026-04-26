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
-- Each row's drill-in is the engine's own tooltip
-- (BuildTradeRouteToolTipString) split per [NEWLINE] line. The engine sets
-- that same tooltip on every cell of the row -- gold cells, science cells,
-- religion cells, etc. -- so a sighted player sees one rich tooltip from any
-- cell hover. We surface the same tooltip line by line so a screen-reader
-- user steps through the same content without trying to navigate cells.
--
-- Engine integration: ships an override of TradeRouteOverview.lua (verbatim
-- BNW copy + an include for this module). The engine's OnPopupMessage,
-- OnClose, ShowHideHandler, InputHandler, RegisterSortOptions, TabSelect,
-- and per-tab RefreshContent stay intact; TabbedShell.install layers our
-- handler on top via priorInput / priorShowHide chains. onShow rebuilds
-- every tab's items so a fresh open after a turn change reflects updated
-- TurnsLeft / GPT values.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
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
include("CivVAccess_TabbedShell")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Tab handles, set during install; module-level so the show hook can
-- rebuild items per tab on every open.
local m_yoursTab
local m_availableTab
local m_withYouTab

-- Civ name resolver. Mirrors the engine's GetCivName() inside SetData,
-- including the city-state branch that swaps to the minor civ short
-- description so "Sidon" reads instead of "City-State". Lifted out of
-- the engine helper to keep us independent of whether the engine's tab
-- RefreshContent has run (we drive our own data fetch).
local function civName(playerID)
    local civType = PreGame.GetCivilization(playerID)
    local civ = GameInfo.Civilizations[civType]
    if civ == nil then
        return Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    local minorCiv = GameInfo.Civilizations["CIVILIZATION_MINOR"]
    if minorCiv ~= nil and civ.ID == minorCiv.ID then
        local minor = Players[playerID]
        local minorType = minor:GetMinorCivType()
        local minorInfo = GameInfo.MinorCivilizations[minorType]
        if minorInfo ~= nil then
            return Text.key(minorInfo.ShortDescription)
        end
    end
    return Text.key(civ.Description)
end

local function domainLabel(domain)
    if domain == DomainTypes.DOMAIN_SEA then
        return Text.key("TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA")
    end
    return Text.key("TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND")
end

-- Yield format keys: reuse the engine's own ones so the spoken text matches
-- what a sighted player reads in the trade-route picker tooltip line for
-- line. Each takes one number arg (times100 / 100 -> e.g. "+1.06 [ICON_GOLD]
-- Gold per turn").
local YIELD_TYPE_KEYS = {
    [YieldTypes.YIELD_GOLD] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_GOLD",
    [YieldTypes.YIELD_SCIENCE] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_SCIENCE",
    [YieldTypes.YIELD_FOOD] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_FOOD",
    [YieldTypes.YIELD_PRODUCTION] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_PRODUCTION",
}

local function yieldEntry(yieldType, valueTimes100)
    if valueTimes100 == 0 then
        return nil
    end
    local key = YIELD_TYPE_KEYS[yieldType]
    if key == nil then
        return nil
    end
    return Text.format(key, valueTimes100 / 100)
end

local function pressureEntry(religionId, amount)
    if religionId == 0 or amount == 0 then
        return nil
    end
    local name = Text.key(Game.GetReligionName(religionId))
    if name == nil or name == "" then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE", amount, name)
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
    appendIf(entries, yieldEntry(YieldTypes.YIELD_GOLD, route.FromGPT or 0))
    appendIf(entries, yieldEntry(YieldTypes.YIELD_SCIENCE, route.FromScience or 0))
    appendIf(entries, pressureEntry(route.FromReligion or 0, route.FromPressure or 0))
    return table.concat(entries, ", ")
end

-- Destination's side: GPT, science, religion pressure plus food / production
-- (the latter two flow on intra-civ routes and the engine reports them as 0
-- on international routes).
local function destinationSideList(route)
    local entries = {}
    appendIf(entries, yieldEntry(YieldTypes.YIELD_GOLD, route.ToGPT or 0))
    appendIf(entries, yieldEntry(YieldTypes.YIELD_SCIENCE, route.ToScience or 0))
    appendIf(entries, yieldEntry(YieldTypes.YIELD_FOOD, route.ToFood or 0))
    appendIf(entries, yieldEntry(YieldTypes.YIELD_PRODUCTION, route.ToProduction or 0))
    appendIf(entries, pressureEntry(route.ToReligion or 0, route.ToPressure or 0))
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

-- Build a level-1 section item from one [NEWLINE][NEWLINE]-separated chunk
-- of the trade-route tooltip. Each chunk starts with a heading line
-- ("YOUR REVENUE", "THEIR REVENUE", "YOUR SCIENCE GAIN",
-- "THEIR SCIENCE GAIN"; engine localisations vary) followed by per-source
-- breakdown lines and the section's Total line. The heading becomes the
-- level-1 label; the rest becomes the level-2 list. Single-line sections
-- collapse to a Text leaf rather than an empty drill-in.
local function buildSectionItem(section)
    local lines = splitOn(section, "[NEWLINE]")
    if #lines == 0 then
        return nil
    end
    local header = lines[1]
    if #lines == 1 then
        return BaseMenuItems.Text({ labelText = header })
    end
    local detailItems = {}
    for i = 2, #lines do
        detailItems[#detailItems + 1] = BaseMenuItems.Text({ labelText = lines[i] })
    end
    return BaseMenuItems.Group({
        labelText = header,
        items = detailItems,
    })
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
    local fromCiv = civName(route.FromID)
    local toCiv = civName(route.ToID)

    local parts = {}
    parts[#parts + 1] = Text.format(
        "TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER",
        domainLabel(route.Domain),
        route.FromCityName,
        fromCiv,
        route.ToCityName,
        toCiv
    )

    local yourSide, theirSide
    if isInbound then
        yourSide = destinationSideList(route)
        theirSide = originSideList(route)
    else
        yourSide = originSideList(route)
        theirSide = destinationSideList(route)
    end
    if yourSide ~= "" then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET", yourSide)
    end
    if theirSide ~= "" then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET", theirSide)
    end

    local turns = route.TurnsLeft
    if turns ~= nil and turns >= 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT", turns)
    end

    return table.concat(parts, ". ") .. "."
end

-- Capture the route as a snapshot for the label closure, but rebuild the
-- drill-in items live on every drill (cached=false) so the tooltip
-- reflects current turn yields if the user pages between tabs across a
-- turn change.
local function buildRouteGroup(route, isInbound)
    return BaseMenuItems.Group({
        labelFn = function()
            return rowLabel(route, isInbound)
        end,
        cached = false,
        itemsFn = function()
            local pPlayer = Players[route.FromID]
            if pPlayer == nil then
                return {
                    BaseMenuItems.Text({
                        labelText = Text.key("TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"),
                    }),
                }
            end
            local tt
            local ok, err = pcall(function()
                tt = BuildTradeRouteToolTipString(pPlayer, route.FromCity, route.ToCity, route.Domain)
            end)
            if not ok then
                Log.error("TradeRouteOverview: BuildTradeRouteToolTipString failed: " .. tostring(err))
                tt = nil
            end
            local items = {}
            for _, section in ipairs(splitOn(tt, "[NEWLINE][NEWLINE]")) do
                local item = buildSectionItem(section)
                if item ~= nil then
                    items[#items + 1] = item
                end
            end
            if #items == 0 then
                items[1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"),
                })
            end
            return items
        end,
    })
end

-- Default sort: FromCityName ascending. Matches the engine's default
-- (g_SortOptions row "FromCityHeader" carries CurrentDirection="asc"
-- on initial load), so users hear routes in the same order a sighted
-- player sees on open.
local function sortRoutes(routes)
    table.sort(routes, function(a, b)
        local ka = a.FromCityName or ""
        local kb = b.FromCityName or ""
        return Locale.Compare(ka, kb) == -1
    end)
end

local function buildItemsFromRoutes(routes, isInbound)
    sortRoutes(routes)
    local items = {}
    for _, route in ipairs(routes) do
        items[#items + 1] = buildRouteGroup(route, isInbound)
    end
    if #items == 0 then
        items[1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"),
        })
    end
    return items
end

local function buildYoursItems()
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return {}
    end
    return buildItemsFromRoutes(pPlayer:GetTradeRoutes() or {}, false)
end

local function buildAvailableItems()
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return {}
    end
    return buildItemsFromRoutes(pPlayer:GetTradeRoutesAvailable() or {}, false)
end

local function buildWithYouItems()
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return {}
    end
    return buildItemsFromRoutes(pPlayer:GetTradeRoutesToYou() or {}, true)
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
    TabbedShell.install(ContextPtr, {
        name = "TradeRouteOverview",
        displayName = Text.key("TXT_KEY_TRADE_ROUTE_OVERVIEW"),
        tabs = { m_yoursTab, m_availableTab, m_withYouTab },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(_handler)
            m_yoursTab.menu().setItems(buildYoursItems())
            m_availableTab.menu().setItems(buildAvailableItems())
            m_withYouTab.menu().setItems(buildWithYouItems())
        end,
    })
end

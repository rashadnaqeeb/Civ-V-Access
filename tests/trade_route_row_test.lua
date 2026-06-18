-- Tests for the shared TradeRouteRow additions used by the Trade Route
-- Overview's Vox Populi pass: culture in the origin / destination yield
-- lists (a VP-only trade yield, absent on vanilla), and the corporation
-- franchiseStatus branch (franchised / can-create / cannot-create / none).
-- Pure functions over a route table plus city / player stubs; no menu or
-- handler-stack involvement.

local T = require("support")
local M = {}

-- Yield + franchise source strings the row functions resolve through
-- Text.format / Text.key. Installed via the Locale resolver; CivVAccess_
-- Strings is cleared so mod keys fall through to this map too.
local STRINGS = {
    TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_GOLD = "{1_Num} gold",
    TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_SCIENCE = "{1_Num} science",
    TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_CULTURE = "{1_Num} culture",
    TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_FOOD = "{1_Num} food",
    TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_PRODUCTION = "{1_Num} production",
    TXT_KEY_CIVVACCESS_TRADE_ROUTE_FRANCHISED = "franchised",
    TXT_KEY_CIVVACCESS_TRADE_ROUTE_CAN_FRANCHISE = "would create a franchise",
    TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_FRANCHISE = "cannot create a franchise",
    TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER = "{1_Domain} route, {2_From} to {3_To}",
    TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND = "land",
    TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET = "you get {1_Yields}",
    TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET = "they get {1_Yields}",
    TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS = "{1_City} gets {2_Yields}",
    TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT = "{1_Num} turns left",
}

local origPlayers

local function setup()
    -- Pin YieldTypes to the canonical BNW layout before TradeRouteRow
    -- builds its YIELD_KEYS table from it. Another suite
    -- (scanner_classification) reassigns the global YieldTypes to a 1-based
    -- layout without restoring it, so an inherited table would mismatch the
    -- ids this suite passes; pinning keeps the dofile and the calls
    -- self-consistent regardless of suite order.
    YieldTypes = {
        YIELD_FOOD = 0,
        YIELD_PRODUCTION = 1,
        YIELD_GOLD = 2,
        YIELD_SCIENCE = 3,
        YIELD_CULTURE = 4,
        YIELD_FAITH = 5,
    }
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_TradeRouteRow.lua")
    -- Mod keys resolve from CivVAccess_Strings first; clear it so this
    -- suite's Locale map is the single source even if another suite loaded
    -- the real strings table earlier.
    CivVAccess_Strings = {}
    T.installLocaleStrings(STRINGS)
    origPlayers = Players
end

local function teardown()
    Players = origPlayers
end

-- ===== Yield-side culture =====

function M.test_origin_side_list_includes_culture()
    setup()
    -- FromGPT 200 -> 2 gold, FromScience 0 dropped, FromCulture 350 -> 3.5
    -- culture. Times100 representation divided by yieldEntry.
    local route = { FromGPT = 200, FromScience = 0, FromCulture = 350, FromReligion = 0, FromPressure = 0 }
    local out = TradeRouteRow.originSideList(route)
    T.eq(out, "2 gold, 3.5 culture")
    teardown()
end

function M.test_origin_side_list_drops_culture_when_absent()
    setup()
    -- Vanilla GetTradeRoutes has no FromCulture field; the entry must not
    -- appear (and must not error on the nil).
    local route = { FromGPT = 100, FromScience = 0, FromReligion = 0, FromPressure = 0 }
    local out = TradeRouteRow.originSideList(route)
    T.eq(out, "1 gold")
    teardown()
end

function M.test_destination_side_list_includes_culture_after_science()
    setup()
    local route = {
        ToGPT = 0,
        ToScience = 200,
        ToCulture = 500,
        ToFood = 0,
        ToProduction = 0,
        ToReligion = 0,
        ToPressure = 0,
    }
    local out = TradeRouteRow.destinationSideList(route)
    T.eq(out, "2 science, 5 culture")
    teardown()
end

-- ===== Row-label sections =====

-- A domestic route (FromID == ToID == active player) keeps both city
-- identifiers as bare names, so the section split is exercised without
-- stubbing the foreign-civ cityIdentifier branch. DOMAIN_SEA is left
-- absent so domainLabel resolves to the land key.
function M.test_row_label_sections_split_clauses()
    setup()
    local origGame = Game
    Game = {
        GetActivePlayer = function()
            return 0
        end,
    }
    local route = {
        Domain = nil,
        FromID = 0,
        ToID = 0,
        FromCityName = "Rome",
        ToCityName = "Antium",
        FromGPT = 200,
        FromScience = 0,
        FromReligion = 0,
        FromPressure = 0,
        ToFood = 200,
        ToGPT = 0,
        ToScience = 0,
        ToProduction = 0,
        ToReligion = 0,
        ToPressure = 0,
        TurnsLeft = 12,
    }
    local sections = TradeRouteRow.rowLabelSections(route, false)
    -- Header, the origin city's gold, the destination city's food, turns.
    T.eq(#sections, 4)
    T.eq(sections[1], "land route, Rome to Antium")
    T.eq(sections[2], "Rome gets 2 gold")
    T.eq(sections[3], "Antium gets 2 food")
    T.eq(sections[4], "12 turns left")
    -- The joined label is the same clauses with ". " separators.
    T.eq(TradeRouteRow.rowLabel(route, false), table.concat(sections, ". ") .. ".")
    Game = origGame
    teardown()
end

-- ===== Franchise status =====

local function mkCity(opts)
    local c = {}
    if opts.franchisedBy ~= nil then
        function c:IsFranchised(playerID)
            return opts.franchisedBy == playerID
        end
    end
    if opts.hasOffice ~= nil then
        function c:HasOffice()
            return opts.hasOffice
        end
    end
    return c
end

-- Wire Players[fromID] with a CanCreateFranchiseInCity stub returning the
-- given verdict.
local function withPlayer(fromID, canCreate)
    Players = {
        [fromID] = {
            CanCreateFranchiseInCity = function(_self, _from, _to)
                return canCreate
            end,
        },
    }
end

function M.test_franchise_status_nil_on_vanilla()
    setup()
    -- Vanilla CvLuaCity has no IsFranchised binding; status must degrade to
    -- nil rather than erroring.
    local route = { FromID = 5, FromCity = mkCity({ hasOffice = true }), ToCity = mkCity({}) }
    T.eq(TradeRouteRow.franchiseStatus(route, true), nil)
    teardown()
end

function M.test_franchise_status_franchised()
    setup()
    local route = {
        FromID = 5,
        FromCity = mkCity({ hasOffice = true }),
        ToCity = mkCity({ franchisedBy = 5 }),
    }
    -- Franchised wins on any tab, regardless of isAvailable.
    T.eq(TradeRouteRow.franchiseStatus(route, false), "franchised")
    teardown()
end

function M.test_franchise_status_can_create_on_available()
    setup()
    withPlayer(5, true)
    local route = {
        FromID = 5,
        FromCity = mkCity({ hasOffice = true }),
        ToCity = mkCity({ franchisedBy = -1 }),
    }
    T.eq(TradeRouteRow.franchiseStatus(route, true), "would create a franchise")
    teardown()
end

function M.test_franchise_status_cannot_create_on_available()
    setup()
    withPlayer(5, false)
    local route = {
        FromID = 5,
        FromCity = mkCity({ hasOffice = true }),
        ToCity = mkCity({ franchisedBy = -1 }),
    }
    T.eq(TradeRouteRow.franchiseStatus(route, true), "cannot create a franchise")
    teardown()
end

function M.test_franchise_status_nil_when_not_available_and_unfranchised()
    setup()
    -- Off the Available tab, an unfranchised destination reports nothing
    -- even when the origin holds an office (the can-create check is
    -- Available-only, matching where VP offers it).
    local route = {
        FromID = 5,
        FromCity = mkCity({ hasOffice = true }),
        ToCity = mkCity({ franchisedBy = -1 }),
    }
    T.eq(TradeRouteRow.franchiseStatus(route, false), nil)
    teardown()
end

return M

-- MultiplayerRewards tests. Real production modules dofiled and reset:
-- SpeechPipeline (with the _speakAction seam capturing sink),
-- TextFilter, Text, MessageBuffer, MultiplayerRewards. Seams substituted:
-- Game.IsNetworkMultiPlayer (controllable), GameEvents.CivVAccessGoody-
-- HutReceived / CivVAccessBarbarianCampCleared and Events.NaturalWonder-
-- Revealed (capture listeners so tests can drive synthetic events),
-- GameInfo / Locale / Map (per-suite stubs to drive the goody / wonder
-- text composition).
--
-- Routing through real Text.format / Text.key (rather than stubbing
-- Locale.ConvertTextKey behind the module's Text-wrapper boundary) keeps
-- the tests sensitive to changes in the wrapper's argument-passing
-- convention. The Locale stub installed here is what Text.format
-- ultimately calls into for non-CIVVACCESS keys.

local T = require("support")
local M = {}

local spoken
local goodyListeners
local barbListeners
local naturalWonderListeners
local isMP

local function fireGoody(playerID, eGoody, iSpecialValue)
    for _, fn in ipairs(goodyListeners) do
        fn(playerID, eGoody, iSpecialValue)
    end
end

local function fireBarb(playerID, x, y, iNumGold)
    for _, fn in ipairs(barbListeners) do
        fn(playerID, x, y, iNumGold)
    end
end

local function fireWonder(x, y)
    for _, fn in ipairs(naturalWonderListeners) do
        fn(x, y)
    end
end

local function setup()
    -- Polyfill must be re-applied since prior suites may have mutated
    -- Locale / Game / GameInfo. The polyfill sentinel skips when
    -- ContextPtr is set, but it's nil in tests so applying again is safe.
    spoken = {}
    isMP = true

    -- Module-scoped fakes overwrite the polyfill / prior suite state.
    Game = Game or {}
    Game.IsNetworkMultiPlayer = function(_self)
        return isMP
    end
    Game.GetActivePlayer = function()
        return 0
    end

    -- Locale stub: a tiny formatter that recognizes the keys this module
    -- and our fixtures actually produce. Production builds yieldString as
    -- a concatenation of localized fragments; we keep the shape so tests
    -- can substring-assert over the final speech text.
    --
    -- Recursive resolution: the real engine's Locale.ConvertTextKey
    -- resolves nested TXT_KEY_* tokens passed as substitution args (so a
    -- caller can pass info.Description -- a key string -- and have it
    -- render as the human-readable name). Mirroring that here lets the
    -- natural-wonder test pass the same shape production passes.
    local strings = {
        TXT_KEY_GOODY_GOLD = "+%s Gold from a ruin",
        TXT_KEY_GOODY_BARE = "Found ancient ruins",
        TXT_KEY_BARB_CAMP_CLEARED = "Cleared barbarian camp, gained %s gold",
        TXT_KEY_POP_NATURAL_WONDER_FOUND_TT = "Discovered %s",
        TXT_KEY_FEATURE_GALAPAGOS = "Galapagos",
        TXT_KEY_FEATURE_PLAIN = "Plain Wonder",
        TXT_KEY_PEDIA_NO_YIELD = "no yield",
        TXT_KEY_POP_NATURAL_WONDER_FOUND_HAPPY = ", %s happiness",
        TXT_KEY_POP_NATURAL_WONDER_FOUND_PROMOTE = ", grants %s",
        TXT_KEY_PROMOTION_FAITH_HEALER = "Faith Healer",
    }
    Locale.ConvertTextKey = function(key, ...)
        local fmt = strings[key]
        if fmt == nil then
            return key
        end
        local resolved = {}
        for i, v in ipairs({ ... }) do
            if type(v) == "string" and strings[v] ~= nil then
                resolved[i] = strings[v]
            else
                resolved[i] = tostring(v)
            end
        end
        if not fmt:find("%%") then
            return fmt
        end
        return string.format(fmt, unpack(resolved))
    end

    GameInfo = {
        GoodyHuts = {
            [1] = { Type = "GOODY_GOLD", Description = "TXT_KEY_GOODY_GOLD" },
            [2] = { Type = "GOODY_MAP", Description = "TXT_KEY_GOODY_BARE" },
        },
        Features = {
            [10] = {
                Type = "FEATURE_GALAPAGOS",
                Description = "TXT_KEY_FEATURE_GALAPAGOS",
                NaturalWonder = true,
                InBorderHappiness = 2,
                AdjacentUnitFreePromotion = "PROMOTION_FAITH_HEALER",
            },
            [11] = {
                Type = "FEATURE_PLAIN",
                Description = "TXT_KEY_FEATURE_PLAIN",
                NaturalWonder = true,
                InBorderHappiness = 0,
            },
            [12] = {
                Type = "FEATURE_FOREST",
                NaturalWonder = false,
            },
        },
        Yields = {
            [0] = { IconString = "[ICON_FOOD]" },
            [2] = { IconString = "[ICON_GOLD]" },
        },
        UnitPromotions = {
            PROMOTION_FAITH_HEALER = { Description = "TXT_KEY_PROMOTION_FAITH_HEALER" },
        },
    }
    -- Feature_YieldChanges is a query callable returning an iterator over
    -- rows. Production passes "FeatureType = 'X'" as the filter; the test
    -- stub parses the type out of the query and serves a per-feature
    -- yield list.
    local yieldRows = {
        FEATURE_GALAPAGOS = { { Yield = 2, YieldType = 2 } },
        FEATURE_PLAIN = {},
    }
    GameInfo.Feature_YieldChanges = function(condition)
        local featureType = condition:match("'([^']+)'")
        local rows = yieldRows[featureType] or {}
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end

    Map = Map or {}
    Map.GetPlot = function(x, _y)
        if x == 5 then
            return {
                GetFeatureType = function()
                    return 10
                end,
            }
        end
        if x == 6 then
            return {
                GetFeatureType = function()
                    return 11
                end,
            }
        end
        if x == 7 then
            return {
                GetFeatureType = function()
                    return 12
                end,
            }
        end
        return nil
    end

    -- Capture listeners. GameEvents needs to be reset per-test because
    -- installListeners pushes onto whatever is registered.
    goodyListeners = {}
    barbListeners = {}
    naturalWonderListeners = {}

    GameEvents = {
        CivVAccessGoodyHutReceived = {
            Add = function(fn)
                goodyListeners[#goodyListeners + 1] = fn
            end,
        },
        CivVAccessBarbarianCampCleared = {
            Add = function(fn)
                barbListeners[#barbListeners + 1] = fn
            end,
        },
    }
    Events = Events or {}
    Events.NaturalWonderRevealed = {
        Add = function(fn)
            naturalWonderListeners[#naturalWonderListeners + 1] = fn
        end,
    }

    -- Fresh civvaccess_shared wipes any MessageBuffer state from a prior
    -- test. installListeners doesn't reset the buffer itself, but the
    -- module table is loaded fresh below.
    civvaccess_shared = {}

    -- Real production modules. SpeechPipeline._speakAction is the seam
    -- between speakQueued / speakInterrupt and the underlying tolk call;
    -- substituting it captures the post-filter text both modes produce.
    SpeechPipeline = nil
    Text = nil
    TextFilter = nil
    MessageBuffer = nil
    MultiplayerRewards = nil
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MultiplayerRewards.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, mode = interrupt and "interrupt" or "queued" }
    end
    MultiplayerRewards.installListeners()
end

-- Goody hut --------------------------------------------------------------

function M.test_goody_hut_in_mp_speaks_and_appends()
    setup()
    fireGoody(0, 1, 50)
    T.eq(#spoken, 1)
    T.eq(spoken[1].mode, "queued")
    T.eq(spoken[1].text, "+50 Gold from a ruin")
    local snap = MessageBuffer._snapshot()
    T.eq(#snap.entries, 1)
    T.eq(snap.entries[1].category, "notification")
    T.eq(snap.entries[1].text, "+50 Gold from a ruin")
end

function M.test_goody_hut_in_sp_is_silent()
    setup()
    isMP = false
    fireGoody(0, 1, 50)
    T.eq(#spoken, 0, "SP rides the popup path -- this module must not double-announce")
    -- Either an absent buffer (the typical state after setup wipes
    -- civvaccess_shared) or an empty entries list is fine; the load-
    -- bearing assertion is "no entries appended," not the precise shape
    -- of the underlying state table.
    local snap = MessageBuffer._snapshot()
    T.truthy(snap == nil or #snap.entries == 0, "SP path must not seed the message buffer")
end

function M.test_goody_hut_for_other_player_is_silent()
    setup()
    -- The hook fires for any active-player receive, but Civ V's lua state
    -- is shared across MP clients; receiveGoody only calls the hook for
    -- the active player slot, so a foreign playerID landing here would be
    -- a defense-in-depth signal that the engine fork drifted. Stay silent.
    fireGoody(1, 1, 50)
    T.eq(#spoken, 0)
end

function M.test_goody_hut_unknown_eGoody_logs_and_skips()
    setup()
    local warned = {}
    Log.warn = function(msg)
        warned[#warned + 1] = msg
    end
    fireGoody(0, 999, 0)
    T.eq(#spoken, 0)
    T.eq(#warned, 1)
end

-- Barbarian camp ---------------------------------------------------------

function M.test_barb_camp_in_mp_speaks_and_appends()
    setup()
    fireBarb(0, 12, 7, 25)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "Cleared barbarian camp, gained 25 gold")
    local snap = MessageBuffer._snapshot()
    T.eq(#snap.entries, 1)
    T.eq(snap.entries[1].category, "notification")
end

function M.test_barb_camp_in_sp_is_silent()
    setup()
    isMP = false
    fireBarb(0, 12, 7, 25)
    T.eq(#spoken, 0)
end

function M.test_barb_camp_for_other_player_is_silent()
    setup()
    fireBarb(1, 12, 7, 25)
    T.eq(#spoken, 0)
end

-- Natural wonder ---------------------------------------------------------

function M.test_natural_wonder_in_mp_full_payload()
    setup()
    fireWonder(5, 0)
    T.eq(#spoken, 1)
    -- Galapagos in our fixture: yields { Yield=2, YieldType=2 }, happiness
    -- 2, promotion PROMOTION_FAITH_HEALER. Substring presence over the
    -- post-filter speech text -- TextFilter strips [ICON_*] markup so we
    -- assert on the surviving yield count, not the icon token.
    local s = spoken[1].text
    T.truthy(s:find("Galapagos", 1, true), "wonder name in announcement")
    T.truthy(s:find(" 2 ", 1, true), "yield count in announcement")
    T.truthy(s:find("happiness", 1, true), "happiness tail in announcement")
    T.truthy(s:find("Faith Healer", 1, true), "promotion tail in announcement")
    local snap = MessageBuffer._snapshot()
    T.eq(snap.entries[1].category, "notification")
end

function M.test_natural_wonder_no_yield_falls_back_to_no_yield_marker()
    setup()
    fireWonder(6, 0) -- FEATURE_PLAIN: no yields, no happiness, no promotion
    T.eq(#spoken, 1)
    T.truthy(spoken[1].text:find("no yield", 1, true), "empty yield list emits the no-yield marker")
end

function M.test_natural_wonder_in_sp_is_silent()
    setup()
    isMP = false
    fireWonder(5, 0)
    T.eq(#spoken, 0)
end

function M.test_natural_wonder_skips_non_wonder_feature()
    setup()
    fireWonder(7, 0) -- FEATURE_FOREST: NaturalWonder=false
    T.eq(#spoken, 0, "non-wonder features must not emit a discovery line")
end

function M.test_natural_wonder_skips_nil_plot()
    setup()
    fireWonder(99, 99) -- Map.GetPlot returns nil
    T.eq(#spoken, 0)
end

-- installListeners resilience -------------------------------------------

function M.test_install_warns_when_engine_fork_hooks_missing()
    -- Reset to a fresh polyfill state before installing without GameEvents.
    spoken = {}
    isMP = true

    local warned = {}
    Log.warn = function(msg)
        warned[#warned + 1] = msg
    end
    GameEvents = nil
    Events = Events or {}
    naturalWonderListeners = {}
    Events.NaturalWonderRevealed = {
        Add = function(fn)
            naturalWonderListeners[#naturalWonderListeners + 1] = fn
        end,
    }

    civvaccess_shared = {}
    MultiplayerRewards = nil
    MessageBuffer = nil
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MultiplayerRewards.lua")
    MultiplayerRewards.installListeners()

    -- Goody, barb, and TeamMeet hooks should warn; natural wonder still wires.
    T.eq(#warned, 3, "three missing GameEvents hooks expected to warn")
    T.eq(#naturalWonderListeners, 1, "the vanilla event still wires up")
end

return M

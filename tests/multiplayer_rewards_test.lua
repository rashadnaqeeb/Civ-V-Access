-- MultiplayerRewards tests. Real production modules dofiled and reset:
-- SpeechPipeline (with the _speakAction seam capturing sink),
-- TextFilter, Text, MessageBuffer, MultiplayerRewards. Seams substituted:
-- Game.IsNetworkMultiPlayer / Game.GetActiveTeam (controllable),
-- GameEvents.CivVAccessGoodyHutReceived / CivVAccessBarbarianCampCleared /
-- NaturalWonderDiscovered / TeamMeet / CivVAccessCityStateGreeting (capture
-- listeners so tests can drive synthetic events), GameInfo / Locale /
-- Players / Teams (per-suite stubs to drive the goody / wonder / gift /
-- first-contact text composition).
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
local wonderListeners
local greetingListeners
local teamMeetListeners
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

local function fireWonder(eTeam, eFeature, x, y, bFirst)
    for _, fn in ipairs(wonderListeners) do
        fn(eTeam, eFeature, x, y, bFirst)
    end
end

local function fireGreeting(minorCivID, iData2, iData3, iFirst, szSuffix)
    for _, fn in ipairs(greetingListeners) do
        fn(minorCivID, iData2, iData3, iFirst, szSuffix)
    end
end

local function fireTeamMeet(eTeamMet, eTeamMoving)
    for _, fn in ipairs(teamMeetListeners) do
        fn(eTeamMet, eTeamMoving)
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
    Game.GetActiveTeam = function()
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
    -- natural-wonder and gift tests pass the same shape production passes.
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
        -- Vanilla / LekMod gift keys (empty-suffix path).
        TXT_KEY_CITY_STATE_GIFT_FIRST = "%s Gold, first to meet",
        TXT_KEY_CITY_STATE_GIFT_OTHER = "%s Gold",
        TXT_KEY_CITY_STATE_GIFT_FAITH_FIRST = "%s Faith, first to meet",
        TXT_KEY_CITY_STATE_GIFT_FAITH_OTHER = "%s Faith",
        -- Community Patch / Vox Populi gift keys (suffix path).
        TXT_KEY_MINOR_CIV_CONTACT_BONUS_NOTHING = "nothing gained",
        TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP = "%s influence with this %s city-state",
        TXT_KEY_MINOR_CIV_FIRST_CONTACT_BONUS_GOLD = "%s Gold from this %s city-state",
        TXT_KEY_MINOR_CIV_CONTACT_BONUS_GOLD = "%s Gold from this %s city-state",
        TXT_KEY_MINOR_CIV_FIRST_CONTACT_BONUS_UNIT = "a %s from this %s city-state",
        TXT_KEY_UNIT_WARRIOR = "Warrior",
        TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY = "friendly",
        TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE = "hostile",
        TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL = "neutral",
        TXT_KEY_CITY_STATE_PERSONALITY_IRRATIONAL = "irrational",
        -- Major-civ first contact.
        TXT_KEY_NOTIFICATION_SUMMARY_MET_MINOR_CIV = "You have met %s",
        TXT_KEY_LEADER_NAPOLEON = "Napoleon",
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
        },
        Yields = {
            [0] = { IconString = "[ICON_FOOD]" },
            [2] = { IconString = "[ICON_GOLD]" },
        },
        UnitPromotions = {
            PROMOTION_FAITH_HEALER = { Description = "TXT_KEY_PROMOTION_FAITH_HEALER" },
        },
        Units = {
            [3] = { Description = "TXT_KEY_UNIT_WARRIOR" },
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

    -- Minor-civ personality lookup for the CP/VP gift path. Keyed by the
    -- minor civ player id the greeting hook carries.
    MinorCivPersonalityTypes = {
        MINOR_CIV_PERSONALITY_FRIENDLY = 0,
        MINOR_CIV_PERSONALITY_NEUTRAL = 1,
        MINOR_CIV_PERSONALITY_HOSTILE = 2,
        MINOR_CIV_PERSONALITY_IRRATIONAL = 3,
    }
    -- Minor civ 22 is the only city-state the gift tests meet; make it
    -- friendly so the CP/VP gift text exercises the personality clause.
    -- Player 7 is the major-civ leader the TeamMeet tests greet.
    Players = {
        [7] = {
            GetNameKey = function()
                return "TXT_KEY_LEADER_NAPOLEON"
            end,
        },
        [22] = {
            GetPersonality = function()
                return MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY
            end,
        },
    }

    -- TeamMeet fixtures. Active team is 0; team 5 is a major civ led by
    -- player 7, team 8 a minor civ, team 9 barbarians.
    Teams = {
        [5] = {
            IsMinorCiv = function()
                return false
            end,
            IsBarbarian = function()
                return false
            end,
            GetLeaderID = function()
                return 7
            end,
        },
        [8] = {
            IsMinorCiv = function()
                return true
            end,
            IsBarbarian = function()
                return false
            end,
            GetLeaderID = function()
                return 0
            end,
        },
        [9] = {
            IsMinorCiv = function()
                return false
            end,
            IsBarbarian = function()
                return true
            end,
            GetLeaderID = function()
                return 0
            end,
        },
    }

    -- Capture listeners. GameEvents needs to be reset per-test because
    -- installListeners pushes onto whatever is registered.
    goodyListeners = {}
    barbListeners = {}
    wonderListeners = {}
    greetingListeners = {}
    teamMeetListeners = {}

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
        NaturalWonderDiscovered = {
            Add = function(fn)
                wonderListeners[#wonderListeners + 1] = fn
            end,
        },
        TeamMeet = {
            Add = function(fn)
                teamMeetListeners[#teamMeetListeners + 1] = fn
            end,
        },
        CivVAccessCityStateGreeting = {
            Add = function(fn)
                greetingListeners[#greetingListeners + 1] = fn
            end,
        },
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
    fireWonder(0, 10, 5, 4, true) -- active team, Galapagos
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
    fireWonder(0, 11, 6, 4, false) -- FEATURE_PLAIN: no yields, no happiness, no promotion
    T.eq(#spoken, 1)
    T.truthy(spoken[1].text:find("no yield", 1, true), "empty yield list emits the no-yield marker")
end

function M.test_natural_wonder_in_sp_is_silent()
    setup()
    isMP = false
    fireWonder(0, 10, 5, 4, true)
    T.eq(#spoken, 0)
end

function M.test_natural_wonder_for_other_team_is_silent()
    setup()
    -- NaturalWonderDiscovered fires for every team that reveals a wonder;
    -- only the active team's own discovery should announce, matching the
    -- suppressed popup's active-team gate.
    fireWonder(1, 10, 5, 4, true)
    T.eq(#spoken, 0)
end

-- City-state meeting gift ------------------------------------------------

function M.test_city_state_gift_vanilla_gold_only()
    setup()
    fireGreeting(22, 30, 0, 0, "") -- 30 gold, not first, no faith, empty suffix
    T.eq(#spoken, 1)
    T.eq(spoken[1].mode, "queued")
    T.eq(spoken[1].text, "30 Gold")
    local snap = MessageBuffer._snapshot()
    T.eq(snap.entries[1].category, "notification")
end

function M.test_city_state_gift_vanilla_first_gold_and_faith()
    setup()
    fireGreeting(22, 60, 8, 1, "") -- 60 gold + 8 faith, first to meet
    T.eq(#spoken, 1)
    local s = spoken[1].text
    T.truthy(s:find("60 Gold, first to meet", 1, true), "gold gift, first-to-meet form")
    T.truthy(s:find("8 Faith, first to meet", 1, true), "faith gift, first-to-meet form")
end

function M.test_city_state_gift_aggressor_empty_suffix_is_silent()
    setup()
    fireGreeting(22, 0, 0, 0, "") -- no gold, no faith (aggressor) -> nothing to say
    T.eq(#spoken, 0)
end

function M.test_city_state_gift_in_sp_is_silent()
    setup()
    isMP = false
    fireGreeting(22, 30, 0, 0, "")
    T.eq(#spoken, 0)
end

function M.test_city_state_gift_cp_gold_with_personality()
    setup()
    -- CP/VP rich path: GOLD suffix, value in iData2, friendly personality
    -- (minor 22). The gift key resolves with the personality clause.
    fireGreeting(22, 25, 5, 1, "GOLD")
    T.eq(#spoken, 1)
    local s = spoken[1].text
    T.truthy(s:find("25 Gold from this friendly city-state", 1, true), "value + personality clause")
end

function M.test_city_state_gift_cp_unit_resolves_unit_name()
    setup()
    -- UNIT suffix: iData2 is a unit type id, resolved to the unit name.
    fireGreeting(22, 3, 5, 1, "UNIT")
    T.eq(#spoken, 1)
    T.truthy(spoken[1].text:find("Warrior", 1, true), "unit gift names the unit")
end

function M.test_city_state_gift_cp_friendship_only()
    setup()
    -- No primary gift value but a friendship boost: the friendship-only
    -- fallback branch.
    fireGreeting(22, 0, 5, 0, "GOLD")
    T.eq(#spoken, 1)
    T.truthy(spoken[1].text:find("influence", 1, true), "friendship-only fallback")
end

function M.test_city_state_gift_cp_nothing_is_announced()
    setup()
    -- Aggressor under the gifts model: value 0, friendship 0, suffix still
    -- set. Mirrors the modded popup's "nothing" line.
    fireGreeting(22, 0, 0, 1, "UNKNOWN")
    T.eq(#spoken, 1)
    T.truthy(spoken[1].text:find("nothing gained", 1, true), "nothing-gained line")
end

-- Major-civ first contact ------------------------------------------------

function M.test_team_meet_major_civ_in_mp_speaks()
    setup()
    fireTeamMeet(0, 5) -- active team 0 meets major civ team 5
    T.eq(#spoken, 1)
    T.truthy(spoken[1].text:find("Napoleon", 1, true), "major civ leader named")
end

function M.test_team_meet_in_sp_is_silent()
    setup()
    isMP = false
    fireTeamMeet(0, 5)
    T.eq(#spoken, 0)
end

function M.test_team_meet_minor_civ_is_silent()
    setup()
    -- City-states ride NOTIFICATION_MET_MINOR; this handler must not
    -- double-announce them.
    fireTeamMeet(0, 8)
    T.eq(#spoken, 0)
end

function M.test_team_meet_barbarian_is_silent()
    setup()
    fireTeamMeet(9, 0) -- active team is eTeamMoving; other team 9 is barbarians
    T.eq(#spoken, 0)
end

function M.test_team_meet_other_teams_is_silent()
    setup()
    -- Neither team is the active team: a meeting between two other civs.
    fireTeamMeet(5, 8)
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

    civvaccess_shared = {}
    MultiplayerRewards = nil
    MessageBuffer = nil
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MultiplayerRewards.lua")
    MultiplayerRewards.installListeners()

    -- All five signals route through GameEvents now (goody, barb, natural
    -- wonder, TeamMeet, city-state greeting), so a nil registry warns once
    -- per signal.
    T.eq(#warned, 5, "five missing GameEvents hooks expected to warn")
end

return M

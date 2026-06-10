-- CongressDescription tests. Seams substituted: SpeechPipeline._speakAction
-- (capturing sink via T.captureSpeech), Log.warn (capture). The module,
-- Text, and the real strings baselines (congress + wonder, since the alias
-- table reaches into the wonder keys) are loaded for real; speakForType is
-- a speech boundary, so the text reaching Tolk is asserted verbatim against
-- the strings table. The alias targets are long literal keys typed in two
-- files, so each alias is asserted against the table entry it must resolve
-- to; a typo on either side would silently turn the splash into the
-- fallback in-game.

local T = require("support")
local M = {}

local spoken

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_WonderDescStrings_en_US.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_CongressDescStrings_en_US.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_CongressDescription.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()
end

function M.test_founding_session_speaks_its_description()
    setup()
    CongressDescription.speakForType("LEAGUE_SPECIAL_SESSION_START_WORLD_CONGRESS")
    T.eq(#spoken, 1)
    T.eq(
        spoken[1].text,
        CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_SPECIAL_SESSION_START_WORLD_CONGRESS"]
    )
    T.truthy(spoken[1].interrupt, "description speaks via interrupt")
end

-- The other two pre-UN sessions share the founding session's painting and
-- must speak the same string through the alias table. The pipeline is
-- reset between the calls because identical back-to-back announcements
-- are suppressed.
function M.test_shared_session_aliases_speak_the_founding_description()
    setup()
    local want = CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_SPECIAL_SESSION_START_WORLD_CONGRESS"]
    CongressDescription.speakForType("LEAGUE_SPECIAL_SESSION_WELCOME_CITY_STATES")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, want)
    SpeechPipeline._reset()
    spoken = T.captureSpeech()
    CongressDescription.speakForType("LEAGUE_SPECIAL_SESSION_LEADERSHIP_COUNCIL")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, want)
end

-- The UN session's splash is the UN wonder's own texture; the ISS project's
-- art is the same painting as the ISS wonder splash. Both must resolve to
-- the wonder description strings rather than congress-prefixed copies.
function M.test_un_session_and_iss_project_reuse_wonder_strings()
    setup()
    CongressDescription.speakForType("LEAGUE_SPECIAL_SESSION_START_UNITED_NATIONS")
    CongressDescription.speakForType("LEAGUE_PROJECT_INTERNATIONAL_SPACE_STATION")
    T.eq(#spoken, 2)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_WONDERDESC_BUILDING_UNITED_NATIONS"])
    T.eq(spoken[2].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_WONDERDESC_BUILDING_INTERNATIONAL_SPACE_STATION"])
end

function M.test_projects_speak_their_own_descriptions()
    setup()
    CongressDescription.speakForType("LEAGUE_PROJECT_WORLD_FAIR")
    CongressDescription.speakForType("LEAGUE_PROJECT_WORLD_GAMES")
    T.eq(#spoken, 2)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_PROJECT_WORLD_FAIR"])
    T.eq(spoken[2].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_PROJECT_WORLD_GAMES"])
end

function M.test_nil_type_speaks_fallback()
    setup()
    CongressDescription.speakForType(nil)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_MISSING"])
end

function M.test_unknown_type_falls_back_and_warns()
    setup()
    local warns = {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    CongressDescription.speakForType("LEAGUE_PROJECT_NOT_A_REAL_ROW")
    Log.warn = function() end
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_MISSING"])
    local moduleWarned = false
    for _, msg in ipairs(warns) do
        if msg:find("CongressDescription") and msg:find("LEAGUE_PROJECT_NOT_A_REAL_ROW") then
            moduleWarned = true
        end
    end
    T.truthy(moduleWarned, "missing entry for a named type must log the type")
end

-- BNW ships five distinct splash paintings across sessions and projects;
-- two reuse wonder strings and three carry congress entries (the shared
-- session painting counts once), and the expansion is frozen. Catches an
-- entry lost to a syntax slip or a key prefix typo.
function M.test_baseline_carries_all_3_paintings()
    setup()
    local count = 0
    for key, text in pairs(CivVAccess_Strings) do
        if key:find("^TXT_KEY_CIVVACCESS_CONGRESSDESC_") and not key:find("_MISSING$") then
            count = count + 1
            T.truthy(type(text) == "string" and #text > 0, key .. " must be nonempty")
        end
    end
    T.eq(count, 3)
end

return M

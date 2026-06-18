-- GreatWorkDescription tests. Seams substituted: SpeechPipeline._speakAction
-- (capturing sink via T.captureSpeech), Log.warn (capture). The module,
-- Text, and the GWDesc strings baseline are loaded for real; speakForType
-- is a speech boundary, so the description text reaching Tolk is asserted
-- verbatim against the strings table.

local T = require("support")
local M = {}

local spoken

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_GreatWorkDescStrings_en_US.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_GreatWorkDescription.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()
end

function M.test_art_type_speaks_its_description()
    setup()
    GreatWorkDescription.speakForType("GREAT_WORK_MONA_LISA")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_GWDESC_GREAT_WORK_MONA_LISA"])
    T.truthy(spoken[1].interrupt, "description speaks via interrupt")
end

function M.test_nil_type_speaks_fallback()
    setup()
    GreatWorkDescription.speakForType(nil)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_GWDESC_MISSING"])
end

function M.test_unknown_type_falls_back_and_warns()
    setup()
    local warns = {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    GreatWorkDescription.speakForType("GREAT_WORK_NOT_A_REAL_ROW")
    Log.warn = function() end
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_GWDESC_MISSING"])
    -- Text.keyOrNil logs the missing TXT_KEY itself; the module adds its
    -- own warn naming the work type so the log places the failure.
    local moduleWarned = false
    for _, msg in ipairs(warns) do
        if msg:find("GreatWorkDescription") and msg:find("GREAT_WORK_NOT_A_REAL_ROW") then
            moduleWarned = true
        end
    end
    T.truthy(moduleWarned, "missing entry for a named type must log the type")
end

-- BNW ships exactly 94 GREAT_WORK_ART rows and the expansion is frozen, so
-- the baseline must carry exactly 94 painting entries plus the two
-- class-level backgrounds for writing and music (GREAT_WORK_LITERATURE,
-- GREAT_WORK_MUSIC), for 96 GWDESC_GREAT_WORK_ keys in all. MISSING and the
-- help label use non-GREAT_WORK key shapes. Catches an entry lost to a
-- syntax slip or a key prefix typo.
function M.test_baseline_carries_all_descriptions()
    setup()
    local count = 0
    for key, text in pairs(CivVAccess_Strings) do
        if key:find("^TXT_KEY_CIVVACCESS_GWDESC_GREAT_WORK_") then
            count = count + 1
            T.truthy(type(text) == "string" and #text > 0, key .. " must be nonempty")
        end
    end
    T.eq(count, 96)
    T.truthy(CivVAccess_Strings["TXT_KEY_CIVVACCESS_GWDESC_GREAT_WORK_LITERATURE"], "writing class background")
    T.truthy(CivVAccess_Strings["TXT_KEY_CIVVACCESS_GWDESC_GREAT_WORK_MUSIC"], "music class background")
end

return M

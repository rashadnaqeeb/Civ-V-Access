-- NaturalWonderDescription tests. Seams substituted: SpeechPipeline._speakAction
-- (capturing sink via T.captureSpeech), Log.warn (capture). The module,
-- Text, and the NWDesc strings baseline are loaded for real; speakForType
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
    dofile("src/dlc/UI/InGame/CivVAccess_NaturalWonderDescStrings_en_US.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_NaturalWonderDescription.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()
end

function M.test_wonder_type_speaks_its_description()
    setup()
    NaturalWonderDescription.speakForType("FEATURE_FUJI")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_FUJI"])
    T.truthy(spoken[1].interrupt, "description speaks via interrupt")
end

function M.test_nil_type_speaks_fallback()
    setup()
    NaturalWonderDescription.speakForType(nil)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_MISSING"])
end

function M.test_unknown_type_falls_back_and_warns()
    setup()
    local warns = {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    NaturalWonderDescription.speakForType("FEATURE_NOT_A_REAL_ROW")
    Log.warn = function() end
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_MISSING"])
    -- Text.keyOrNil logs the missing TXT_KEY itself; the module adds its
    -- own warn naming the feature type so the log places the failure.
    local moduleWarned = false
    for _, msg in ipairs(warns) do
        if msg:find("NaturalWonderDescription") and msg:find("FEATURE_NOT_A_REAL_ROW") then
            moduleWarned = true
        end
    end
    T.truthy(moduleWarned, "missing entry for a named type must log the type")
end

-- BNW ships exactly 17 natural wonders and the expansion is frozen, so
-- the baseline must carry exactly 17 wonder entries (plus MISSING, which
-- uses a non-FEATURE key shape). Catches an entry lost to a syntax slip
-- or a key prefix typo.
function M.test_baseline_carries_all_17_wonders()
    setup()
    local count = 0
    for key, text in pairs(CivVAccess_Strings) do
        if key:find("^TXT_KEY_CIVVACCESS_NWDESC_FEATURE_") then
            count = count + 1
            T.truthy(type(text) == "string" and #text > 0, key .. " must be nonempty")
        end
    end
    T.eq(count, 17)
end

return M

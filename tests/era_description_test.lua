-- EraDescription tests. Seams substituted: SpeechPipeline._speakAction
-- (capturing sink via T.captureSpeech), Log.warn (capture). The module,
-- Text, and the real strings baseline are loaded for real; speakForType is
-- a speech boundary, so the text reaching Tolk is asserted verbatim against
-- the strings table.

local T = require("support")
local M = {}

local spoken

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_EraDescStrings_en_US.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_EraDescription.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()
end

function M.test_era_speaks_its_description()
    setup()
    EraDescription.speakForType("ERA_RENAISSANCE")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_ERA_RENAISSANCE"])
    T.truthy(spoken[1].interrupt, "description speaks via interrupt")
end

function M.test_nil_type_speaks_fallback()
    setup()
    EraDescription.speakForType(nil)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_MISSING"])
end

function M.test_unknown_type_falls_back_and_warns()
    setup()
    local warns = {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    EraDescription.speakForType("ERA_NOT_A_REAL_ROW")
    Log.warn = function() end
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_MISSING"])
    local moduleWarned = false
    for _, msg in ipairs(warns) do
        if msg:find("EraDescription") and msg:find("ERA_NOT_A_REAL_ROW") then
            moduleWarned = true
        end
    end
    T.truthy(moduleWarned, "missing entry for a named era must log the type")
end

-- BNW ships seven era splash paintings (every era except Ancient, which
-- the game starts in), and the expansion is frozen. Catches an entry lost
-- to a syntax slip or a key prefix typo.
function M.test_baseline_carries_all_7_paintings()
    setup()
    local count = 0
    for key, text in pairs(CivVAccess_Strings) do
        if key:find("^TXT_KEY_CIVVACCESS_ERADESC_") and not key:find("_MISSING$") then
            count = count + 1
            T.truthy(type(text) == "string" and #text > 0, key .. " must be nonempty")
        end
    end
    T.eq(count, 7)
end

return M

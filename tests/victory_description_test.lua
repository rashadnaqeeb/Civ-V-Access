-- VictoryDescription tests. Seams substituted: SpeechPipeline._speakAction
-- (capturing sink via T.captureSpeech), Log.warn (capture). The module,
-- Text, and the VictoryDesc strings baseline are loaded for real;
-- speakForKey is a speech boundary, so the description text reaching Tolk
-- is asserted verbatim against the strings table.

local T = require("support")
local M = {}

local spoken

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_VictoryDescStrings_en_US.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_VictoryDescription.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()
end

function M.test_victory_type_speaks_its_description()
    setup()
    VictoryDescription.speakForKey("VICTORY_CULTURAL")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_VICTORY_CULTURAL"])
    T.truthy(spoken[1].interrupt, "description speaks via interrupt")
end

function M.test_defeat_key_speaks_the_defeat_description()
    setup()
    VictoryDescription.speakForKey("DEFEAT")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_DEFEAT"])
end

function M.test_nil_key_speaks_fallback()
    setup()
    VictoryDescription.speakForKey(nil)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_MISSING"])
end

function M.test_unknown_key_falls_back_and_warns()
    setup()
    local warns = {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    VictoryDescription.speakForKey("VICTORY_NOT_A_REAL_ROW")
    Log.warn = function() end
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_MISSING"])
    -- Text.keyOrNil logs the missing TXT_KEY itself; the module adds its
    -- own warn naming the art key so the log places the failure.
    local moduleWarned = false
    for _, msg in ipairs(warns) do
        if msg:find("VictoryDescription") and msg:find("VICTORY_NOT_A_REAL_ROW") then
            moduleWarned = true
        end
    end
    T.truthy(moduleWarned, "missing entry for a named key must log the key")
end

-- BNW ships exactly five victory types plus the hardcoded defeat art, and
-- the expansion is frozen, so the baseline must carry exactly 6 entries
-- (plus MISSING). Catches an entry lost to a syntax slip or a key prefix
-- typo.
function M.test_baseline_carries_all_6_backgrounds()
    setup()
    local count = 0
    for key, text in pairs(CivVAccess_Strings) do
        if key:find("^TXT_KEY_CIVVACCESS_VICTORYDESC_") and not key:find("_MISSING$") then
            count = count + 1
            T.truthy(type(text) == "string" and #text > 0, key .. " must be nonempty")
        end
    end
    T.eq(count, 6)
end

return M

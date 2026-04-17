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
include("CivVAccess_BaselineHandler")

-- Boot fires any time a new in-game Context loads, which may include the
-- pre-game setup flow, not just a real loaded game. Civ V runs the entire
-- session on one lua_State, so there's no state-level discriminator.
-- Events.LoadScreenClose is the reliable "we are actually in a game now"
-- signal; defer the in-game boot actions to it.
local function onInGameBoot()
    Log.info("in-game boot")
    HandlerStack.removeByName("Baseline")
    HandlerStack.push(BaselineHandler.create())
    TickPump.install(ContextPtr)
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_BOOT_INGAME"))
end

if Events ~= nil and Events.LoadScreenClose ~= nil then
    -- Guard against multiple in-game contexts each registering a listener
    -- within the same lua_State; civvaccess_shared persists across contexts.
    if not civvaccess_shared.ingameListenerInstalled then
        civvaccess_shared.ingameListenerInstalled = true
        Events.LoadScreenClose.Add(onInGameBoot)
        Log.info("CivVAccess_Boot: registered LoadScreenClose listener")
    end
else
    Log.warn("CivVAccess_Boot: Events.LoadScreenClose missing; in-game boot will not fire")
end

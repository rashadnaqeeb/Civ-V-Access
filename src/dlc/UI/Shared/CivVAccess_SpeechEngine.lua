-- Thin wrapper around the tolk global injected by the proxy DLL. Only
-- SpeechPipeline should call this; feature code goes through SpeechPipeline.

SpeechEngine = {}

local _missingWarned = false

local function tolkMissing()
    if not _missingWarned then
        _missingWarned = true
        if Log and Log.error then
            Log.error("SpeechEngine: tolk global not present; speech disabled. Is the proxy DLL loaded?")
        end
    end
end

function SpeechEngine.isAvailable()
    return tolk ~= nil and tolk.isLoaded ~= nil and tolk.isLoaded()
end

function SpeechEngine.say(text, interrupt)
    if tolk == nil or tolk.output == nil then
        tolkMissing()
        return
    end
    tolk.output(text, interrupt and true or false)
end

function SpeechEngine.stop()
    if tolk == nil or tolk.silence == nil then
        tolkMissing()
        return
    end
    tolk.silence()
end

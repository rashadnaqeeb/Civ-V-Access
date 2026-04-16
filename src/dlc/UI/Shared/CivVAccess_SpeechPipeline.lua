-- Central announcement pipeline. All feature code speaks through here.
-- Pipeline: caller -> SpeechPipeline -> TextFilter -> SpeechEngine -> Tolk.

SpeechPipeline = {}

local DEDUPE_WINDOW_SECONDS = 0.05

local _enabled = true
local _lastInterruptText = nil
local _lastInterruptTime = 0

-- Swappable seams for tests.
SpeechPipeline._timeSource = os.clock
SpeechPipeline._speakAction = function(text, interrupt)
    SpeechEngine.say(text, interrupt)
end

function SpeechPipeline.isActive()
    return _enabled
end

function SpeechPipeline.setEnabled(enabled)
    _enabled = enabled and true or false
end

function SpeechPipeline._reset()
    _lastInterruptText = nil
    _lastInterruptTime = 0
    _enabled = true
end

function SpeechPipeline.speakInterrupt(text)
    if not _enabled then return end
    local filtered = TextFilter.filter(text)
    if filtered == nil or filtered == "" then return end
    local now = SpeechPipeline._timeSource()
    if filtered == _lastInterruptText and (now - _lastInterruptTime) < DEDUPE_WINDOW_SECONDS then
        return
    end
    _lastInterruptText = filtered
    _lastInterruptTime = now
    SpeechPipeline._speakAction(filtered, true)
end

function SpeechPipeline.speakQueued(text)
    if not _enabled then return end
    local filtered = TextFilter.filter(text)
    if filtered == nil or filtered == "" then return end
    SpeechPipeline._speakAction(filtered, false)
end

function SpeechPipeline.stop()
    SpeechEngine.stop()
end

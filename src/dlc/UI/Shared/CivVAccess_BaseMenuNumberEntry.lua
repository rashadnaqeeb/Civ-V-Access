-- Modal number-entry sub-handler pushed above a BaseMenu when the user must
-- enter an integer without a live XML EditBox. Used by the diplomacy trade
-- screen's Available tab: gold / gold-per-turn / strategic amounts don't have
-- an EditBox until the item is placed, so BaseMenuItems.Textfield and
-- BaseMenuEditMode (both driven off a live control) don't fit.
--
-- Owns a Lua-side digit buffer and speaks the running total on each keystroke
-- because there is no engine HWND text control for the screen reader to echo
-- against. capturesAllInput = true so digit keys don't leak into type-ahead
-- search or nav bindings on the menu below.
--
-- Distinct from BaseMenuEditMode:
--   EditMode wraps a real EditBox, sets _editMode=true so install swallows
--   the Enter KEYUP, and lets WM_CHARs reach the engine control.
--   NumberEntry owns its own buffer, binds every digit / Backspace / Enter /
--   Esc, and has no engine control to focus.
--
-- opts:
--   promptLabel  string,   spoken on push ("enter <promptLabel>, max <max>")
--   maxValue     number,   Enter clamps over-max to this; announced on clamp
--   onCommit     fn(n),    called with final integer 1..maxValue on Enter
--   onCancel     fn() optional, called on Esc and empty/zero Enter

BaseMenuNumberEntry = {}

local SUB_NAME = "NumberEntry"

-- Speak the current buffer (running total). When the buffer is empty after a
-- Backspace, speak an explicit sentinel so the user hears that the field is
-- now empty rather than silence that could be confused with a missed keypress.
local function speakBuffer(buffer)
    if buffer == "" then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"))
    else
        SpeechPipeline.speakInterrupt(buffer)
    end
end

function BaseMenuNumberEntry.push(opts)
    if type(opts) ~= "table" then
        Log.error("BaseMenuNumberEntry.push: opts must be a table")
        return
    end
    if type(opts.onCommit) ~= "function" then
        Log.error("BaseMenuNumberEntry.push: opts.onCommit must be a function")
        return
    end
    local promptLabel = opts.promptLabel or ""
    local maxValue = opts.maxValue
    local onCommit = opts.onCommit
    local onCancel = opts.onCancel

    local buffer = ""
    local sub = {
        name = SUB_NAME,
        capturesAllInput = true,
    }

    local function cancel()
        HandlerStack.removeByName(SUB_NAME, true)
        if type(onCancel) == "function" then
            local ok, err = pcall(onCancel)
            if not ok then
                Log.error("BaseMenuNumberEntry onCancel failed: " .. tostring(err))
            end
        end
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CANCELED"))
    end

    local function commit()
        local n = tonumber(buffer)
        if n == nil or n <= 0 then
            cancel()
            return
        end
        local clamped = (maxValue ~= nil and n > maxValue) and maxValue or n
        -- Run onCommit BEFORE pop so any caller-driven rebuild (drawer
        -- setItems) finishes before the pop fires parent onActivate. The
        -- parent's speakInterrupt during reactivation would otherwise
        -- announce stale items.
        local ok, err = pcall(onCommit, clamped)
        if not ok then
            Log.error("BaseMenuNumberEntry onCommit failed: " .. tostring(err))
        end
        HandlerStack.removeByName(SUB_NAME, true)
        -- speakQueued appends after the parent's reactivation announce so
        -- the user hears "<current item>, <committed number>" -- both the
        -- position they land on and confirmation of what committed. Works
        -- for clamped and unclamped alike; always informative.
        SpeechPipeline.speakQueued(tostring(clamped))
    end

    local function appendDigit(ch)
        buffer = buffer .. ch
        speakBuffer(buffer)
    end

    local function backspace()
        if buffer ~= "" then
            buffer = buffer:sub(1, -2)
        end
        speakBuffer(buffer)
    end

    local bind = HandlerStack.bind
    local bindings = {}
    -- Top-row digits 0-9: Keys["0"] .. Keys["9"] (printable ASCII bare per
    -- the engine's Keys enum convention).
    for i = 0, 9 do
        local ch = tostring(i)
        local key = Keys[ch]
        if key ~= nil then
            bindings[#bindings + 1] = bind(key, 0, function()
                appendDigit(ch)
            end, "Digit " .. ch)
        end
    end
    -- Numpad digits 0-9: VK_NUMPAD0 .. VK_NUMPAD9 (special keys use VK_ per
    -- the engine's convention). Paired with top-row so users whose screen
    -- reader rebinds the numpad still have a working path.
    for i = 0, 9 do
        local vk = Keys["VK_NUMPAD" .. i]
        if vk ~= nil then
            local ch = tostring(i)
            bindings[#bindings + 1] = bind(vk, 0, function()
                appendDigit(ch)
            end, "Numpad " .. ch)
        end
    end
    bindings[#bindings + 1] = bind(Keys.VK_BACK, 0, backspace, "Backspace")
    bindings[#bindings + 1] = bind(Keys.VK_RETURN, 0, commit, "Commit")
    bindings[#bindings + 1] = bind(Keys.VK_ESCAPE, 0, cancel, "Cancel")

    sub.bindings = bindings
    sub.helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ENTER",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL",
        },
    }

    -- Prompt on push. Must fire before HandlerStack.push so onActivate
    -- (empty by default) doesn't clobber it.
    local prompt
    if maxValue ~= nil then
        prompt = Text.format("TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT", promptLabel, tostring(maxValue))
    else
        prompt = promptLabel
    end
    SpeechPipeline.speakInterrupt(prompt)

    HandlerStack.push(sub)
end

return BaseMenuNumberEntry

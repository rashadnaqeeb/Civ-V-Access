-- BaseMenuNumberEntry tests. Exercises buffer management (digit append,
-- Backspace, empty Backspace), commit paths (valid integer, over-max clamp,
-- empty/zero = cancel), cancel paths (Esc, empty Enter, zero Enter), and
-- speech output on each keystroke.

local T = require("support")
local M = {}

local warns, errors, speaks

local function setup()
    warns, errors = {}, {}
    Log.warn = function(m)
        warns[#warns + 1] = m
    end
    Log.error = function(m)
        errors[#errors + 1] = m
    end
    Log.info = function() end
    Log.debug = function() end

    UI.ShiftKeyDown = function()
        return false
    end
    UI.CtrlKeyDown = function()
        return false
    end
    UI.AltKeyDown = function()
        return false
    end
    Events.AudioPlay2DSound = function() end

    speaks = {}
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        speaks[#speaks + 1] = { text = text, interrupt = interrupt }
    end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuNumberEntry.lua")
    HandlerStack._reset()
end

-- Dispatch a synthetic keydown through InputRouter so the binding walk runs
-- the same way production does.
local function press(vk, mods)
    local WM_KEYDOWN = 256
    InputRouter.dispatch(vk, mods or 0, WM_KEYDOWN)
end

local function pressDigit(ch)
    press(Keys[tostring(ch)])
end

local function pressNumpad(n)
    press(Keys["VK_NUMPAD" .. n])
end

-- Helpers --------------------------------------------------------------

local function onCommitCapture()
    local committed = {}
    return committed, function(n)
        committed[#committed + 1] = n
    end
end

local function onCancelCapture()
    local canceled = { count = 0 }
    return canceled, function()
        canceled.count = canceled.count + 1
    end
end

-- Push --------------------------------------------------------------------

function M.test_push_rejects_non_table_opts()
    setup()
    BaseMenuNumberEntry.push("nope")
    T.truthy(#errors >= 1, "non-table opts rejected with error")
    T.eq(HandlerStack.count(), 0, "nothing pushed on invalid opts")
end

function M.test_push_rejects_missing_onCommit()
    setup()
    BaseMenuNumberEntry.push({ promptLabel = "X", maxValue = 10 })
    T.truthy(#errors >= 1, "missing onCommit rejected with error")
    T.eq(HandlerStack.count(), 0)
end

function M.test_push_speaks_prompt_with_max()
    setup()
    BaseMenuNumberEntry.push({
        promptLabel = "Gold",
        maxValue = 340,
        onCommit = function() end,
    })
    T.eq(HandlerStack.count(), 1)
    T.eq(speaks[1].text, "enter Gold, max 340")
    T.truthy(speaks[1].interrupt, "prompt is interrupt-speech")
end

function M.test_push_without_max_speaks_prompt_only()
    setup()
    BaseMenuNumberEntry.push({
        promptLabel = "Amount",
        onCommit = function() end,
    })
    T.eq(speaks[1].text, "Amount")
end

function M.test_push_sets_capturesAllInput()
    setup()
    BaseMenuNumberEntry.push({ promptLabel = "X", maxValue = 10, onCommit = function() end })
    local top = HandlerStack.active()
    T.truthy(top.capturesAllInput, "captures all input so digits don't leak to type-ahead below")
end

-- Digit entry -------------------------------------------------------------

function M.test_digit_appends_and_speaks_running_total()
    setup()
    BaseMenuNumberEntry.push({ promptLabel = "Gold", maxValue = 999, onCommit = function() end })
    speaks = {}
    pressDigit(3)
    pressDigit(4)
    pressDigit(0)
    T.eq(speaks[1].text, "3")
    T.eq(speaks[2].text, "34")
    T.eq(speaks[3].text, "340")
end

function M.test_numpad_digits_also_append()
    setup()
    BaseMenuNumberEntry.push({ promptLabel = "Gold", maxValue = 999, onCommit = function() end })
    speaks = {}
    pressNumpad(1)
    pressNumpad(2)
    T.eq(speaks[1].text, "1")
    T.eq(speaks[2].text, "12")
end

-- Backspace ---------------------------------------------------------------

function M.test_backspace_removes_last_digit()
    setup()
    BaseMenuNumberEntry.push({ promptLabel = "G", maxValue = 999, onCommit = function() end })
    pressDigit(1)
    pressDigit(2)
    pressDigit(3)
    speaks = {}
    press(Keys.VK_BACK)
    T.eq(speaks[1].text, "12", "backspace removed the 3")
end

function M.test_backspace_on_empty_speaks_empty_sentinel()
    setup()
    BaseMenuNumberEntry.push({ promptLabel = "G", maxValue = 999, onCommit = function() end })
    speaks = {}
    press(Keys.VK_BACK)
    T.eq(speaks[1].text, "empty", "user hears an explicit empty sentinel")
end

function M.test_backspace_to_empty_speaks_empty_sentinel()
    setup()
    BaseMenuNumberEntry.push({ promptLabel = "G", maxValue = 999, onCommit = function() end })
    pressDigit(5)
    speaks = {}
    press(Keys.VK_BACK)
    T.eq(speaks[1].text, "empty", "buffer drained back to empty announces the sentinel")
end

-- Commit paths -----------------------------------------------------------

function M.test_commit_valid_number_calls_onCommit_and_pops()
    setup()
    local committed, onCommit = onCommitCapture()
    BaseMenuNumberEntry.push({ promptLabel = "G", maxValue = 999, onCommit = onCommit })
    pressDigit(4)
    pressDigit(2)
    press(Keys.VK_RETURN)
    T.eq(#committed, 1, "onCommit fired once")
    T.eq(committed[1], 42, "onCommit received parsed integer")
    T.eq(HandlerStack.count(), 0, "handler popped after commit")
end

function M.test_commit_over_max_clamps_and_announces()
    setup()
    local committed, onCommit = onCommitCapture()
    BaseMenuNumberEntry.push({ promptLabel = "G", maxValue = 340, onCommit = onCommit })
    pressDigit(5)
    pressDigit(0)
    pressDigit(0)
    speaks = {}
    press(Keys.VK_RETURN)
    T.eq(committed[1], 340, "clamped to max")
    T.eq(speaks[1].text, "340", "clamped value announced so user hears what committed")
    T.falsy(speaks[1].interrupt, "committed value is queued so it tails parent re-announce")
end

function M.test_commit_unclamped_still_announces_committed_value()
    setup()
    local committed, onCommit = onCommitCapture()
    BaseMenuNumberEntry.push({ promptLabel = "G", maxValue = 340, onCommit = onCommit })
    pressDigit(4)
    pressDigit(2)
    speaks = {}
    press(Keys.VK_RETURN)
    T.eq(committed[1], 42)
    -- Always speak the committed value so the user confirms what went in,
    -- even when not clamped.
    T.eq(speaks[1].text, "42")
end

function M.test_commit_empty_buffer_treated_as_cancel()
    setup()
    local committed, onCommit = onCommitCapture()
    local canceled, onCancel = onCancelCapture()
    BaseMenuNumberEntry.push({
        promptLabel = "G",
        maxValue = 340,
        onCommit = onCommit,
        onCancel = onCancel,
    })
    press(Keys.VK_RETURN)
    T.eq(#committed, 0, "empty buffer does not commit")
    T.eq(canceled.count, 1, "empty buffer fires onCancel")
    T.eq(HandlerStack.count(), 0, "handler popped")
end

function M.test_commit_zero_treated_as_cancel()
    setup()
    local committed, onCommit = onCommitCapture()
    local canceled, onCancel = onCancelCapture()
    BaseMenuNumberEntry.push({
        promptLabel = "G",
        maxValue = 340,
        onCommit = onCommit,
        onCancel = onCancel,
    })
    pressDigit(0)
    press(Keys.VK_RETURN)
    T.eq(#committed, 0, "zero does not commit")
    T.eq(canceled.count, 1, "zero fires onCancel")
end

function M.test_onCommit_error_is_logged_and_handler_still_pops()
    setup()
    BaseMenuNumberEntry.push({
        promptLabel = "G",
        maxValue = 340,
        onCommit = function()
            error("callback exploded")
        end,
    })
    pressDigit(5)
    press(Keys.VK_RETURN)
    T.truthy(#errors >= 1, "error logged")
    T.eq(HandlerStack.count(), 0, "handler popped even when onCommit throws")
end

-- Cancel -----------------------------------------------------------------

function M.test_esc_cancels_without_committing()
    setup()
    local committed, onCommit = onCommitCapture()
    local canceled, onCancel = onCancelCapture()
    BaseMenuNumberEntry.push({
        promptLabel = "G",
        maxValue = 340,
        onCommit = onCommit,
        onCancel = onCancel,
    })
    pressDigit(1)
    pressDigit(2)
    press(Keys.VK_ESCAPE)
    T.eq(#committed, 0, "esc does not commit")
    T.eq(canceled.count, 1, "onCancel fires")
    T.eq(HandlerStack.count(), 0, "handler popped")
end

function M.test_cancel_announces_canceled_keyword()
    setup()
    BaseMenuNumberEntry.push({
        promptLabel = "G",
        maxValue = 340,
        onCommit = function() end,
    })
    speaks = {}
    press(Keys.VK_ESCAPE)
    T.eq(speaks[1].text, "canceled")
end

function M.test_cancel_without_onCancel_still_pops()
    setup()
    BaseMenuNumberEntry.push({
        promptLabel = "G",
        maxValue = 340,
        onCommit = function() end,
    })
    press(Keys.VK_ESCAPE)
    T.eq(HandlerStack.count(), 0, "handler popped when onCancel is not supplied")
end

-- Modal barrier ----------------------------------------------------------

function M.test_captures_all_input_blocks_arrow_keys()
    setup()
    -- Set up an underlying handler that records its arrow-key binding firing.
    local arrowFired = false
    local underlying = {
        name = "under",
        bindings = {
            HandlerStack.bind(Keys.VK_UP, 0, function()
                arrowFired = true
            end, "Up"),
        },
        helpEntries = {},
    }
    HandlerStack.push(underlying)
    BaseMenuNumberEntry.push({ promptLabel = "G", maxValue = 10, onCommit = function() end })
    press(Keys.VK_UP)
    T.falsy(arrowFired, "arrow key blocked by capturesAllInput barrier")
end

return M

-- Help overlay tests. Exercises the full pipeline: collect helpEntries from
-- the current stack, build Button items from each, push a Help handler via
-- BaseMenu.create. Runs against real HandlerStack, InputRouter, BaseMenu,
-- and Help modules (no mocks for production code).

local T = require("support")
local M = {}

local speaks
local warns

local function setup()
    warns = {}
    Log.warn  = function(msg) warns[#warns + 1] = msg end
    Log.error = function(msg) warns[#warns + 1] = msg end
    Log.info  = function() end
    Log.debug = function() end

    UI.ShiftKeyDown = function() return false end
    UI.CtrlKeyDown  = function() return false end
    UI.AltKeyDown   = function() return false end

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
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_PullDownProbe.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Help.lua")
    HandlerStack._reset()
    TickPump._reset()
end

local function itemCount(handler)
    -- Help pushes items at level 1 in a single list.
    return #handler._items
end

local function speakTextAt(i)
    return speaks[i] and speaks[i].text or nil
end

-- Wiring ----------------------------------------------------------------

function M.test_help_open_pushes_handler_named_Help()
    setup()
    HandlerStack.push({
        name = "base", helpEntries = {
            { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN",
              description = "TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS" },
        },
    })
    Help.open()
    T.eq(HandlerStack.active().name, "Help")
end

function M.test_help_announces_screen_name_on_open()
    setup()
    HandlerStack.push({ name = "base", helpEntries = {} })
    speaks = {}
    Help.open()
    T.eq(speakTextAt(1), "Help", "first speech is the screen name")
end

function M.test_help_items_are_keyLabel_comma_description()
    setup()
    HandlerStack.push({
        name = "base", helpEntries = {
            { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN",
              description = "TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS" },
        },
    })
    Help.open()
    local handler = HandlerStack.active()
    T.eq(itemCount(handler), 1)
    -- After push, the active item speaks at a queued speak.
    -- Find the first spoken help entry (after "Help" displayName).
    local got = speakTextAt(2) or ""
    T.truthy(got:find("Up or down", 1, true), "speaks the key label")
    T.truthy(got:find("Navigate items", 1, true), "speaks the description")
end

function M.test_help_collects_from_stack_before_pushing_itself()
    setup()
    HandlerStack.push({
        name = "base", helpEntries = {
            { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN",
              description = "TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC",
              description = "TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL" },
        },
    })
    Help.open()
    -- Both entries from the underlying handler show up as items. The Help
    -- handler sits on top but its own helpEntries (navigating help) don't
    -- contribute to *its own* item list.
    T.eq(itemCount(HandlerStack.active()), 2)
end

function M.test_help_self_entries_describe_navigation_not_base_menu()
    setup()
    HandlerStack.push({ name = "base", helpEntries = {} })
    Help.open()
    local help = HandlerStack.active()
    -- Help replaces the auto-populated BaseMenu helpEntries with a short
    -- curated list. Should include escape + ? for closing.
    local seen = {}
    for _, e in ipairs(help.helpEntries) do seen[e.keyLabel] = true end
    T.truthy(seen["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"])
    T.truthy(seen["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"])
    T.falsy(seen["TXT_KEY_CIVVACCESS_HELP_KEY_F1"],
        "F1 read-header not applicable to help list")
end

function M.test_help_escape_pops_handler()
    setup()
    HandlerStack.push({ name = "base", helpEntries = {} })
    Help.open()
    T.eq(HandlerStack.active().name, "Help")
    -- Escape is wired by BaseMenu.create when spec.escapePops is set.
    local consumed = InputRouter.dispatch(Keys.VK_ESCAPE, 0, 256)
    T.truthy(consumed)
    T.eq(HandlerStack.active().name, "base",
        "Esc pops Help, restoring the base handler")
end

function M.test_help_shift_question_pops_handler()
    setup()
    HandlerStack.push({ name = "base", helpEntries = {} })
    Help.open()
    T.eq(HandlerStack.active().name, "Help")
    -- Shift+? while Help is on top: InputRouter skips the Help.open pre-walk
    -- gate (top is Help), so Help's own binding fires and pops.
    UI.ShiftKeyDown = function() return true end
    local consumed = InputRouter.dispatch(191, 1, 256)
    T.truthy(consumed)
    T.eq(HandlerStack.active().name, "base")
end

-- Dedupe + barrier behavior through the end-to-end path -----------------

function M.test_help_respects_captures_barrier_below()
    setup()
    HandlerStack.push({
        name = "bottom", helpEntries = {
            { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_F1",
              description = "TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER" },
        },
    })
    HandlerStack.push({
        name = "middle-barrier", capturesAllInput = true, helpEntries = {
            { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_TAB",
              description = "TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB" },
        },
    })
    Help.open()
    -- Only the barrier's entries (inclusive) reach the list; bottom is hidden.
    T.eq(itemCount(HandlerStack.active()), 1)
end

function M.test_help_dedupes_keyLabel_top_wins()
    setup()
    HandlerStack.push({
        name = "bottom", helpEntries = {
            { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC",
              description = "TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL" },
        },
    })
    HandlerStack.push({
        name = "top", helpEntries = {
            { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC",
              description = "TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE" },
        },
    })
    Help.open()
    -- Both entries share keyLabel "Escape"; top's "Close" wins.
    T.eq(itemCount(HandlerStack.active()), 1)
    local handler = HandlerStack.active()
    -- Help builds one item per entry; find what was spoken when the cursor
    -- landed on the only item. We can inspect the item's labelText directly.
    local label = handler._items[1].labelText
    T.truthy(label:find("Close", 1, true), "top handler's description wins")
    T.falsy(label:find("Cancel", 1, true))
end

return M

-- PickerReader cross-tab behavior. Focused on the two-tab activate/restore
-- contract so regressions in BaseMenu's switchTab / cycleTab don't silently
-- break the pedia flow. BaseMenu + BaseMenuItems + TypeAheadSearch are
-- loaded for real; engine globals come from Polyfill. Every test drives
-- through the real session.install path so the install-site wiring
-- (onActivate, nameFn, Ctrl+arrow hooks) stays under test.

local T = require("support")
local M = {}

local warns, errors
local speaks

local WM_KEYDOWN = 256

local function setup()
    warns, errors = {}, {}
    Log.warn  = function(m) warns[#warns + 1]  = m end
    Log.error = function(m) errors[#errors + 1] = m end
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
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuHelp.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuEditMode.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_PickerReader.lua")

    HandlerStack._reset()
    TickPump._reset()
    Controls = {}

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"]            = "disabled"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"]             = "cleared"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"]            = "selected"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"]        = "empty"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] = "no selection"
    CivVAccess_Strings["TXT_KEY_INSTALL_PICKER_TAB"]                    = "Picker"
    CivVAccess_Strings["TXT_KEY_INSTALL_READER_TAB"]                    = "Content"
end

local function makeContextPtr()
    return {
        SetShowHideHandler = function(self, fn) self._sh = fn end,
        SetInputHandler    = function(self, fn) self._in = fn end,
        _hidden            = false,
        IsHidden           = function(self) return self._hidden end,
        SetUpdate          = function(self, fn) self._update = fn end,
    }
end

-- Install a PickerReader with a nested picker (Alpha, Group{Bravo, Charlie},
-- Delta) and an optional custom reader factory. The default reader is a
-- flat two-Text-leaf list at autoDrillToLevel = 1; pass readerFactory(id)
-- -> { items, autoDrillToLevel } to override per-test. buildCalls logs
-- every builder invocation for rebuild / no-wrap assertions.
local function installFixture(readerFactory)
    local session = PickerReader.create()
    local buildCalls = {}
    local builder = function(handler, id)
        buildCalls[#buildCalls + 1] = id
        if readerFactory ~= nil then
            return readerFactory(id)
        end
        return {
            items = {
                BaseMenuItems.Text({ labelText = "first leaf " .. id }),
                BaseMenuItems.Text({ labelText = "second leaf " .. id }),
            },
            autoDrillToLevel = 1,
        }
    end
    local pickerItems = {
        session.Entry({ id = "A", labelText = "Alpha", buildReader = builder }),
        BaseMenuItems.Group({
            labelText = "Group",
            items = {
                session.Entry({ id = "B", labelText = "Bravo",   buildReader = builder }),
                session.Entry({ id = "C", labelText = "Charlie", buildReader = builder }),
            },
        }),
        session.Entry({ id = "D", labelText = "Delta", buildReader = builder }),
    }
    local ctx = makeContextPtr()
    local handler = session.install(ctx, {
        name          = "InstalledPedia",
        displayName   = "Installed Pedia",
        pickerTabName = "TXT_KEY_INSTALL_PICKER_TAB",
        readerTabName = "TXT_KEY_INSTALL_READER_TAB",
        pickerItems   = pickerItems,
    })
    -- Mimic the engine's show sequence that BaseMenu.install wires: the
    -- ShowHide closure pushes the handler onto HandlerStack + fires
    -- onActivate. Without it the menu isn't active and InputRouter
    -- dispatch goes nowhere.
    ctx._sh(false, false)
    return session, handler, ctx, buildCalls
end

-- Reader factory: two section Groups + autoDrillToLevel = 2 so activation
-- lands inside the first section (not on its header). Used by tests that
-- care about section-drill semantics.
local function sectionedReader(id)
    return {
        items = {
            BaseMenuItems.Group({
                labelText = "Section A for " .. id,
                items = {
                    BaseMenuItems.Text({ labelText = "body 1 " .. id }),
                    BaseMenuItems.Text({ labelText = "body 2 " .. id }),
                },
            }),
            BaseMenuItems.Group({
                labelText = "Section B for " .. id,
                items = {
                    BaseMenuItems.Text({ labelText = "body 3 " .. id }),
                },
            }),
        },
        autoDrillToLevel = 2,
    }
end

local function textsSpoken()
    local out = {}
    for _, s in ipairs(speaks) do out[#out + 1] = s.text end
    return out
end

local function spokeText(needle)
    for _, s in ipairs(speaks) do
        if tostring(s.text):find(needle, 1, true) then return true end
    end
    return false
end

-- Tests ------------------------------------------------------------------

function M.test_handler_starts_on_picker_tab_level_1()
    setup()
    local _, h = installFixture()
    T.eq(h._tabIndex, 1, "starts on picker tab")
    T.eq(h._level, 1, "starts at level 1")
end

function M.test_entry_activation_swaps_reader_items_and_switches_tab()
    setup()
    local _, h, _, buildCalls = installFixture(sectionedReader)

    -- Alpha -> Group (down) -> drill (right) -> activate Bravo (enter).
    InputRouter.dispatch(Keys.VK_DOWN,   0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RIGHT,  0, WM_KEYDOWN)
    T.eq(h._level, 2, "drilled into Group")

    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)

    T.eq(buildCalls[#buildCalls], "B", "buildReader called with entry id")
    T.eq(h._tabIndex, 2, "switched to reader tab after activation")
    -- autoDrillToLevel = 2 drills from section Group into its first body.
    T.eq(h._level, 2, "reader auto-drilled into first section")
end

function M.test_entry_activation_reading_first_body_line()
    setup()
    local _, _, _, _ = installFixture(sectionedReader)

    InputRouter.dispatch(Keys.VK_DOWN,   0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RIGHT,  0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)

    T.truthy(spokeText("body 1"),
        "first body line announced after reader auto-drill")
end

function M.test_same_entry_reactivated_rebuilds_reader()
    setup()
    local _, h, _, buildCalls = installFixture()
    -- Activate Alpha.
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(buildCalls[#buildCalls], "A")
    local firstCalls = #buildCalls
    -- Shift+Tab back to picker; install's restorePickerCursor lands on Alpha.
    InputRouter.dispatch(Keys.VK_TAB, 1, WM_KEYDOWN)
    T.eq(h._tabIndex, 1, "back to picker")
    -- Re-activate Alpha.
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#buildCalls, firstCalls + 1, "buildReader re-fired (no stale cache)")
    T.eq(buildCalls[#buildCalls], "A", "buildReader called with same id")
end

function M.test_switch_to_reader_tab_programmatically_re_announces()
    setup()
    local _, h = installFixture()

    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    speaks = {}
    h.switchToTab(2)
    T.truthy(#speaks > 0, "programmatic same-tab switch still announces")
end

function M.test_empty_build_result_keeps_user_on_picker()
    setup()
    local _, h = installFixture(function()
        return { items = {}, autoDrillToLevel = 1 }
    end)

    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)

    T.eq(h._tabIndex, 1, "empty build stays on picker")
    T.truthy(spokeText("empty"), "empty-reader announcement spoken")
end

function M.test_autoDrill_level_one_stays_at_level_one()
    setup()
    local _, h = installFixture()

    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)

    T.eq(h._tabIndex, 2, "switched to reader")
    T.eq(h._level, 1, "flat reader stays at level 1")
end

function M.test_tab_cycling_preserves_reader_items_after_selection()
    setup()
    local _, h, _, buildCalls = installFixture()

    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    local calls = #buildCalls
    -- Shift+Tab -> picker.
    InputRouter.dispatch(Keys.VK_TAB, 1, WM_KEYDOWN)
    -- Tab -> reader.
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)

    T.eq(#buildCalls, calls, "buildReader not called on Tab cycling")
    T.eq(h._tabIndex, 2, "back on reader tab")
end

-- Install-path reader-tab hook coverage -----------------------------------

function M.test_install_reader_nameFn_speaks_article_title_not_content()
    setup()
    local _, handler, _, buildCalls = installFixture()
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(buildCalls[#buildCalls], "A", "build fired for Alpha")
    T.eq(handler._tabIndex, 2, "switched to reader")
    T.truthy(spokeText("Alpha"), "article title 'Alpha' spoken on reader switch")
    T.falsy(spokeText("Content"), "static 'Content' tab name suppressed by nameFn")
end

function M.test_install_reader_nameFn_empty_when_no_selection()
    setup()
    local _, handler = installFixture()
    -- Tab into reader before picking anything. nameFn returns empty so
    -- the static "Content" tab-name speech is suppressed; placeholder still
    -- speaks.
    speaks = {}
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(handler._tabIndex, 2, "tabbed to reader")
    T.falsy(spokeText("Content"),
        "Content tab-name suppressed when no article selected")
end

function M.test_install_reader_ctrl_down_advances_article()
    setup()
    local _, _, _, buildCalls = installFixture()
    -- Land on Alpha so selectedId is set.
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(buildCalls[#buildCalls], "A")
    local callsBefore = #buildCalls
    speaks = {}
    -- Ctrl+Down should advance to Bravo (next in flat order: A, B, C, D).
    InputRouter.dispatch(Keys.VK_DOWN, 2, WM_KEYDOWN)
    T.eq(buildCalls[#buildCalls], "B", "Ctrl+Down advanced to next entry")
    T.eq(#buildCalls, callsBefore + 1, "buildReader fired once for the new entry")
    T.truthy(spokeText("Bravo"), "Bravo article title announced on Ctrl+Down")
end

function M.test_install_reader_ctrl_up_goes_to_previous_article()
    setup()
    local _, _, _, buildCalls = installFixture()
    -- Start on Charlie by drilling into group + picking second entry.
    InputRouter.dispatch(Keys.VK_DOWN,   0, WM_KEYDOWN) -- Alpha -> Group
    InputRouter.dispatch(Keys.VK_RIGHT,  0, WM_KEYDOWN) -- drill group
    InputRouter.dispatch(Keys.VK_DOWN,   0, WM_KEYDOWN) -- Bravo -> Charlie
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- activate Charlie
    T.eq(buildCalls[#buildCalls], "C")
    speaks = {}
    InputRouter.dispatch(Keys.VK_UP, 2, WM_KEYDOWN) -- Ctrl+Up
    T.eq(buildCalls[#buildCalls], "B", "Ctrl+Up moved to previous entry")
end

function M.test_install_reader_ctrl_up_at_first_article_is_noop()
    setup()
    local _, _, _, buildCalls = installFixture()
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- Alpha
    local callsBefore = #buildCalls
    InputRouter.dispatch(Keys.VK_UP, 2, WM_KEYDOWN)
    T.eq(#buildCalls, callsBefore,
        "Ctrl+Up at first article does not re-fire buildReader (no wrap)")
end

function M.test_install_reader_ctrl_down_at_last_article_is_noop()
    setup()
    local _, _, _, buildCalls = installFixture()
    -- Navigate to Delta (last entry).
    InputRouter.dispatch(Keys.VK_END,    0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(buildCalls[#buildCalls], "D")
    local callsBefore = #buildCalls
    InputRouter.dispatch(Keys.VK_DOWN, 2, WM_KEYDOWN)
    T.eq(#buildCalls, callsBefore,
        "Ctrl+Down at last article does not re-fire buildReader (no wrap)")
end

function M.test_install_reader_ctrl_keys_on_picker_tab_use_default_behavior()
    setup()
    local _, handler, _, buildCalls = installFixture()
    -- Still on picker, selectedId is nil. Ctrl+Down at level 1 is the
    -- default "next sibling group" navigation; with our flat-ish picker
    -- it just moves cursor, never invokes buildReader.
    T.eq(handler._tabIndex, 1, "on picker tab")
    InputRouter.dispatch(Keys.VK_DOWN, 2, WM_KEYDOWN)
    T.eq(#buildCalls, 0, "picker-tab Ctrl+Down does not trigger article nav")
end

return M

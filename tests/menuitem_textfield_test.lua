-- BaseMenuItems.Textfield announcement + resolution tests. EditMode coverage
-- lives in menu_test. This suite exercises the factory-level surface:
-- control lookup, priorCallback validation, focus-announce composition,
-- blank sentinel, and visibility-wrapper gating.

local T = require("support")
local M = {}

local warns, errors
local speaks

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
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenu.lua")
    HandlerStack._reset()

    civvaccess_shared.pullDownProbeInstalled = false
    civvaccess_shared.pullDownCallbacks      = {}
    civvaccess_shared.pullDownEntries        = {}
    civvaccess_shared.sliderProbeInstalled   = false
    civvaccess_shared.sliderCallbacks        = {}
    civvaccess_shared.checkBoxProbeInstalled = false
    civvaccess_shared.checkBoxCallbacks      = {}

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"]  = "edit"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "blank"
end

local function populateControls(map)
    Controls = {}
    for name, c in pairs(map) do Controls[name] = c end
end

-- Resolution --------------------------------------------------------

function M.test_missing_editbox_logs_warn()
    setup()
    populateControls({})
    BaseMenuItems.Textfield({ controlName = "Missing", textKey = "LBL" })
    T.truthy(#warns >= 1, "missing-control warn logged")
end

function M.test_non_function_priorCallback_is_rejected()
    setup()
    local eb = Polyfill.makeEditBox()
    populateControls({ E = eb })
    local ok = pcall(BaseMenuItems.Textfield, {
        controlName = "E", textKey = "LBL",
        priorCallback = "not a function",
    })
    T.falsy(ok, "non-function priorCallback fails assertion")
end

-- Focus announcement ------------------------------------------------

function M.test_focus_announce_includes_current_text()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    local h = BaseMenu.create({ name = "T", displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    T.eq(speaks[1].text, "Screen")
    T.eq(speaks[2].text, "LBL, edit, Athens")
end

function M.test_focus_announce_blank_when_empty()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local h = BaseMenu.create({ name = "T", displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "LBL, edit, blank")
end

function M.test_focus_announce_updates_when_text_changes_between_visits()
    setup()
    local a = Polyfill.makeEditBox({ text = "first" })
    local b = Polyfill.makeEditBox({ text = "second" })
    populateControls({ A = a, B = b })
    local h = BaseMenu.create({ name = "T", displayName = "Screen",
        items = {
            BaseMenuItems.Textfield({ controlName = "A", textKey = "LBL_A" }),
            BaseMenuItems.Textfield({ controlName = "B", textKey = "LBL_B" }),
        } })
    HandlerStack.push(h)
    speaks = {}
    a:SetText("changed")
    local WM_KEYDOWN = 256
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(speaks[1].text, "LBL_B, edit, second")
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(speaks[2].text, "LBL_A, edit, changed",
        "re-read on second visit reflects latest text, not cached")
end

-- Visibility proxy --------------------------------------------------

function M.test_visibilityControlName_hidden_wrapper_skips_item()
    setup()
    local eb    = Polyfill.makeEditBox({ text = "" })
    local wrap  = Polyfill.makeButton()
    wrap:SetHide(true)
    local after = Polyfill.makeCheckBox()
    populateControls({ E = eb, Wrapper = wrap, After = after })
    local h = BaseMenu.create({ name = "T", displayName = "Screen",
        items = {
            BaseMenuItems.Textfield({ controlName = "E",
                visibilityControlName = "Wrapper", textKey = "LBL_E" }),
            BaseMenuItems.Checkbox({ controlName = "After", textKey = "LBL_A" }),
        } })
    HandlerStack.push(h)
    T.eq(h._index, 2,
        "first-navigable skipped the textfield because its wrapper is hidden")
end

function M.test_visibilityControlName_visible_wrapper_allows_item()
    setup()
    local eb   = Polyfill.makeEditBox({ text = "hi" })
    local wrap = Polyfill.makeButton()
    wrap:SetHide(false)
    populateControls({ E = eb, Wrapper = wrap })
    local h = BaseMenu.create({ name = "T", displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E",
            visibilityControlName = "Wrapper", textKey = "LBL" }) } })
    HandlerStack.push(h)
    T.eq(h._index, 1)
    T.eq(speaks[2].text, "LBL, edit, hi")
end

function M.test_missing_visibilityControl_logs_warn()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    BaseMenuItems.Textfield({ controlName = "E",
        visibilityControlName = "Missing", textKey = "LBL" })
    local foundMissing = false
    for _, w in ipairs(warns) do
        if w:find("visibility control") then foundMissing = true end
    end
    T.truthy(foundMissing, "missing-visibility-control warn logged")
end

return M

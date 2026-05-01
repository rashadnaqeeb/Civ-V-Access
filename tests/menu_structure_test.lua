-- BaseMenu structural and navigation tests. Covers factory validation,
-- edge cases (empty items / setItems / capturesAllInput / shouldActivate
-- / deferActivate / dynamic-item features), nested groups (drill / wrap
-- / Ctrl up-down jumps / pulldown-advanced behavior), type-ahead search
-- + Choice.selectedFn announce-on-current-value, and the Ctrl+I pedia
-- dispatch chord. The shared setup() and helpers are duplicated across
-- the four menu_*_test files so each suite is self-contained.
local T = require("support")
local M = {}

local warns, errors
local speaks
local sounds
local _test_pd_mt = nil

local function resetPDMetatable()
    local proto = Polyfill.makePullDown()
    _test_pd_mt = {
        __index = {
            GetButton = proto.GetButton,
            ClearEntries = proto.ClearEntries,
            BuildEntry = proto.BuildEntry,
            CalculateInternals = proto.CalculateInternals,
            RegisterSelectionCallback = proto.RegisterSelectionCallback,
            IsHidden = proto.IsHidden,
            IsDisabled = proto.IsDisabled,
            SetHide = proto.SetHide,
            SetDisabled = proto.SetDisabled,
        },
    }
end

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

    sounds = {}
    Events.AudioPlay2DSound = function(id)
        sounds[#sounds + 1] = id
    end

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
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuTabs.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuInstall.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuEditMode.lua")
    HandlerStack._reset()
    TickPump._reset()

    civvaccess_shared.pullDownProbeInstalled = false
    civvaccess_shared.pullDownCallbacks = {}
    civvaccess_shared.pullDownEntries = {}
    civvaccess_shared.sliderProbeInstalled = false
    civvaccess_shared.sliderCallbacks = {}
    civvaccess_shared.checkBoxProbeInstalled = false
    civvaccess_shared.checkBoxCallbacks = {}
    civvaccess_shared.buttonProbeInstalled = false
    civvaccess_shared.buttonCallbacks = {}

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "on"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "off"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "edit"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "blank"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "editing {1_Label}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restored"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "no match for {1_Buffer}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "search cleared"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "selected"

    resetPDMetatable()
end

local WM_KEYDOWN = 256

-- Helpers --------------------------------------------------------------

local function populateControls(map)
    Controls = {}
    for name, c in pairs(map) do
        Controls[name] = c
    end
end

local function patchProbeFromPullDown(pd)
    PullDownProbe.ensureInstalled(pd)
end

local function makePullDownWithMetatable()
    if _test_pd_mt == nil then
        resetPDMetatable()
    end
    return Polyfill.makePullDownWithMetatable(_test_pd_mt)
end

local function registerSliderCallback(slider, fn)
    slider:RegisterSliderCallback(fn)
    civvaccess_shared.sliderCallbacks[slider] = fn
end

local function registerCheckHandler(cb, fn)
    cb:RegisterCheckHandler(fn)
    civvaccess_shared.checkBoxCallbacks = civvaccess_shared.checkBoxCallbacks or {}
    civvaccess_shared.checkBoxCallbacks[cb] = fn
end

-- Stub Controls matching the shape button-list tests expect.
local ctrlState
local function makeCtrl(name)
    return setmetatable({ _name = name }, {
        __index = {
            IsHidden = function(self)
                return ctrlState[self._name].hidden
            end,
            IsDisabled = function(self)
                return ctrlState[self._name].disabled
            end,
        },
    })
end
local function setCtrls(names)
    Controls = {}
    ctrlState = {}
    for _, name in ipairs(names) do
        ctrlState[name] = { hidden = false, disabled = false }
        Controls[name] = makeCtrl(name)
    end
end
local function makeContextPtr()
    return {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
end

local function buttonSpec(names)
    local items = {}
    for _, name in ipairs(names) do
        items[#items + 1] = BaseMenuItems.Button({
            controlName = name,
            textKey = "LABEL_" .. name,
            activate = function() end,
        })
    end
    return items
end


-- Factory ----------------------------------------------------------------

function M.test_create_requires_name_and_displayName()
    setup()
    populateControls({})
    local ok = pcall(BaseMenu.create, { items = {} })
    T.falsy(ok, "missing name/displayName should fail")
end

function M.test_create_requires_items_or_tabs()
    setup()
    populateControls({})
    local ok = pcall(BaseMenu.create, { name = "X", displayName = "x" })
    T.falsy(ok, "no items/tabs should fail")
end

function M.test_create_shape_matches_handler_contract()
    setup()
    setCtrls({ "A", "B" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Button({ controlName = "A", textKey = "LBL_A", activate = function() end }),
            BaseMenuItems.Button({ controlName = "B", textKey = "LBL_B", activate = function() end }),
        },
    })
    T.eq(h.capturesAllInput, true)
    T.eq(type(h.bindings), "table")
    T.eq(type(h.onActivate), "function")
    T.eq(type(h.onDeactivate), "function")
    T.eq(type(h.setItems), "function")
    T.eq(type(h.refresh), "function")
end

function M.test_missing_control_logs_warn_and_keeps_item()
    setup()
    populateControls({})
    BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Checkbox({ controlName = "Missing", textKey = "LBL" }),
        },
    })
    T.truthy(#warns >= 1, "missing-control warn logged")
end

-- Empty items -----------------------------------------------------------

function M.test_empty_items_onActivate_speaks_displayName_only()
    setup()
    populateControls({})
    local h = BaseMenu.create({ name = "S", displayName = "Splash", items = {} })
    HandlerStack.push(h)
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "Splash")
end

function M.test_empty_items_onEnter_is_safe_noop()
    setup()
    populateControls({})
    local h = BaseMenu.create({ name = "S", displayName = "Splash", items = {} })
    HandlerStack.push(h)
    sounds, speaks, warns = {}, {}, {}
    local consumed = InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.truthy(consumed, "Enter still consumed by barrier")
    T.eq(#sounds, 0)
    T.eq(#speaks, 0)
    T.eq(#warns, 0, "empty Enter is silent")
end

-- shouldActivate --------------------------------------------------------

function M.test_shouldActivate_false_skips_push()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        shouldActivate = function()
            return false
        end,
    })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 0, "push skipped")
    T.eq(#speaks, 0, "no speech")
end

function M.test_shouldActivate_true_pushes()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        shouldActivate = function()
            return true
        end,
    })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1)
end

-- deferActivate ---------------------------------------------------------

function M.test_deferActivate_delays_push_to_update_tick()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "D",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        deferActivate = true,
    })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 0, "push not synchronous with show")
    T.eq(#speaks, 0)
    T.eq(ctx._update, TickPump.tick, "TickPump owns Update")
    TickPump.tick()
    T.eq(HandlerStack.count(), 1, "push runs on deferred tick")
    T.eq(speaks[1].text, "Screen")
end

function M.test_deferActivate_hide_before_tick_cancels_push()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "D",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        deferActivate = true,
    })
    ctx._sh(false, false)
    ctx._sh(true, false)
    TickPump.tick()
    T.eq(HandlerStack.count(), 0, "no push after cancel")
    T.eq(#speaks, 0)
end

function M.test_deferActivate_hidden_at_tick_skips_push()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "D",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        deferActivate = true,
    })
    ctx._sh(false, false)
    ctx._hidden = true
    TickPump.tick()
    T.eq(HandlerStack.count(), 0, "IsHidden check blocks push")
end

-- setItems --------------------------------------------------------------

function M.test_setItems_replaces_items_single_tab()
    setup()
    local a = Polyfill.makeCheckBox()
    local b = Polyfill.makeCheckBox()
    populateControls({ A = a })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "A", textKey = "FIRST" }) },
    })
    HandlerStack.push(h)
    speaks = {}
    h.setItems({
        BaseMenuItems.Checkbox({ control = a, labelText = "A2" }),
        BaseMenuItems.Checkbox({ control = b, labelText = "B2" }),
    })
    T.eq(#h._items, 2)
    T.eq(h._items[2].labelText, "B2")
    T.eq(#speaks, 0, "setItems does not announce on swap")
end

function M.test_setItems_replaces_tab_items_by_index()
    setup()
    local a = Polyfill.makeCheckBox()
    local b = Polyfill.makeCheckBox()
    populateControls({ A = a, B = b })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            { name = "TAB_A", items = { BaseMenuItems.Checkbox({ controlName = "A", textKey = "LA" }) } },
            { name = "TAB_B", items = { BaseMenuItems.Checkbox({ controlName = "B", textKey = "LB" }) } },
        },
    })
    HandlerStack.push(h)
    h.setItems({
        BaseMenuItems.Checkbox({ control = b, labelText = "B-NEW-1" }),
        BaseMenuItems.Checkbox({ control = b, labelText = "B-NEW-2" }),
    }, 2)
    T.eq(#h.tabs[2]._items, 2)
    T.eq(h.tabs[2]._items[1].labelText, "B-NEW-1")
    T.eq(#h.tabs[1]._items, 1, "tab 1 items untouched")
end

function M.test_setItems_clamps_cursor_when_out_of_range()
    setup()
    local a = Polyfill.makeCheckBox()
    local b = Polyfill.makeCheckBox()
    local c = Polyfill.makeCheckBox()
    populateControls({ A = a, B = b, C = c })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({ controlName = "A", textKey = "LA" }),
            BaseMenuItems.Checkbox({ controlName = "B", textKey = "LB" }),
            BaseMenuItems.Checkbox({ controlName = "C", textKey = "LC" }),
        },
    })
    HandlerStack.push(h)
    h._indices[1] = 3
    h.setItems({ BaseMenuItems.Checkbox({ control = a, labelText = "A" }) })
    T.eq(h._indices[1], 1, "cursor clamped to first valid item after shrink")
end

-- Dynamic-item features --------------------------------------------------

function M.test_labelText_overrides_textKey_lookup()
    setup()
    local cb = Polyfill.makeCheckBox()
    populateControls({ C = cb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "C", labelText = "PreLocalized Option" }) },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "PreLocalized Option, off", "labelText used verbatim")
end

function M.test_control_ref_bypasses_controlName_lookup()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = true })
    Controls = {}
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ control = cb, textKey = "DIRECT" }) },
    })
    HandlerStack.push(h)
    T.eq(#warns, 0, "no missing-control warnings")
    T.eq(speaks[2].text, "DIRECT, on")
end

-- capturesAllInput barrier ----------------------------------------------

function M.test_capturesAllInput_blocks_lower_handlers()
    setup()
    setCtrls({ "A" })
    local lowerFired = 0
    HandlerStack.push({
        name = "lower",
        capturesAllInput = false,
        bindings = {
            {
                key = 65,
                mods = 0,
                fn = function()
                    lowerFired = lowerFired + 1
                end,
            },
        },
    })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = buttonSpec({ "A" }) })
    HandlerStack.push(h)
    local consumed = InputRouter.dispatch(65, 0, WM_KEYDOWN)
    T.truthy(consumed, "barrier swallows unbound key")
    T.eq(lowerFired, 0)
end

-- Nested menus ---------------------------------------------------------
--
-- Groups drill via Right / Enter; Left at level > 1 goes back up a level.
-- Esc never drills out — it bypasses to the screen's priorInput at any level.
-- Up/Down at level > 1 cross into sibling groups on past-end. Ctrl+Up/Down
-- jumps to prev/next group at the current level's parent.

local MOD_CTRL = 2

local function buttonItem(name, label)
    return BaseMenuItems.Button({
        controlName = name,
        textKey = label or ("LBL_" .. name),
        activate = function() end,
    })
end

local function groupItem(label, children)
    return BaseMenuItems.Group({
        labelText = label,
        items = children,
    })
end

function M.test_group_drill_on_enter_enters_first_child()
    setup()
    setCtrls({ "A", "GCHILD1", "GCHILD2" })
    local child1 = buttonItem("GCHILD1", "Child One")
    local child2 = buttonItem("GCHILD2", "Child Two")
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            buttonItem("A", "Leaf A"),
            groupItem("Group One", { child1, child2 }),
        },
    })
    HandlerStack.push(h)
    -- Move to the group and Enter.
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._level, 2, "drilled to level 2")
    T.eq(h._indices[2], 1, "cursor on first child")
    T.eq(speaks[1].text, "Child One")
end

function M.test_group_drill_on_right()
    setup()
    setCtrls({ "GCHILD1" })
    local child = buttonItem("GCHILD1", "Only Child")
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupItem("Group", { child }) } })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(h._level, 2)
    T.eq(speaks[1].text, "Only Child")
end

function M.test_left_at_level_2_goes_back()
    setup()
    setCtrls({ "CHILD" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { groupItem("Parent", { buttonItem("CHILD", "Child") }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    T.eq(h._level, 2)
    speaks = {}
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(h._level, 1, "left at level 2 returns to 1")
    T.eq(speaks[1].text, "Parent", "re-announces the group on back")
end

function M.test_esc_at_level_2_bypasses_to_priorInput_without_drilling_back()
    setup()
    setCtrls({ "CHILD" })
    local bypassed = false
    local ctx = {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
    local handler = BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        priorInput = function()
            bypassed = true
            return true
        end,
        items = { groupItem("Parent", { buttonItem("CHILD", "Child") }) },
    })
    ctx._sh(false, false)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(handler._level, 2)
    ctx._in(256, Keys.VK_ESCAPE, 0)
    T.truthy(bypassed, "Esc at level > 1 delegates to priorInput rather than drilling out")
    T.eq(handler._level, 2, "Esc did not change level")
end

function M.test_esc_at_level_1_bypasses_to_priorInput()
    setup()
    setCtrls({ "A" })
    local bypassed = false
    local ctx = {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        priorInput = function()
            bypassed = true
            return true
        end,
        items = { buttonItem("A", "Leaf") },
    })
    ctx._sh(false, false)
    ctx._in(256, Keys.VK_ESCAPE, 0)
    T.truthy(bypassed, "Esc at level 1 delegated to priorInput")
end

function M.test_down_at_level_2_past_last_wraps_to_next_group_first_child()
    setup()
    setCtrls({ "A", "B", "C", "D" })
    local groupA = groupItem("Group A", { buttonItem("A", "A1"), buttonItem("B", "A2") })
    local groupB = groupItem("Group B", { buttonItem("C", "B1"), buttonItem("D", "B2") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupA, groupB } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill into A
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- step within A
    T.eq(h._indices[2], 2)
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- past last -> cross to B
    T.eq(h._indices[1], 2, "parent advanced to Group B")
    T.eq(h._indices[2], 1, "cursor on first child of B")
    T.eq(speaks[1].text, "Group B", "parent context announced")
    T.eq(speaks[2].text, "B1", "first child queued after parent")
end

function M.test_up_at_level_2_past_first_wraps_to_prev_group_last_child()
    setup()
    setCtrls({ "A", "B", "C", "D" })
    local groupA = groupItem("Group A", { buttonItem("A", "A1"), buttonItem("B", "A2") })
    local groupB = groupItem("Group B", { buttonItem("C", "B1"), buttonItem("D", "B2") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupA, groupB } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- on Group B
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill into B
    T.eq(h._indices[2], 1)
    speaks = {}
    InputRouter.dispatch(Keys.VK_UP, 0, WM_KEYDOWN) -- past first -> cross to A
    T.eq(h._indices[1], 1, "parent moved back to Group A")
    T.eq(h._indices[2], 2, "cursor on last child of A")
    T.eq(speaks[1].text, "Group A")
    T.eq(speaks[2].text, "A2")
end

function M.test_cross_parent_skips_leaves_at_parent_level()
    setup()
    setCtrls({ "LEAF1", "A1", "A2", "LEAF2", "B1" })
    local groupA = groupItem("A", { buttonItem("A1"), buttonItem("A2") })
    local groupB = groupItem("B", { buttonItem("B1") })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            buttonItem("LEAF1", "Leaf1"),
            groupA,
            buttonItem("LEAF2", "Leaf2"),
            groupB,
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- on Group A
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- A2
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- past end -> skip Leaf2 -> B
    T.eq(h._indices[1], 4, "jumped across Leaf2 to Group B")
    T.eq(h._indices[2], 1)
    T.eq(speaks[1].text, "B")
end

function M.test_home_at_level_2_stays_within_group()
    setup()
    setCtrls({ "A1", "A2", "B1" })
    local groupA = groupItem("A", { buttonItem("A1"), buttonItem("A2") })
    local groupB = groupItem("B", { buttonItem("B1") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupA, groupB } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill into A
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- A2
    InputRouter.dispatch(Keys.VK_HOME, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 1, "still in group A")
    T.eq(h._indices[2], 1, "on first child of A")
end

function M.test_ctrl_down_at_level_1_jumps_across_leaves_to_next_group()
    setup()
    setCtrls({ "LEAF", "G1C", "G2C" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            buttonItem("LEAF", "Leaf"),
            groupItem("Group 1", { buttonItem("G1C", "C1") }),
            groupItem("Group 2", { buttonItem("G2C", "C2") }),
        },
    })
    HandlerStack.push(h)
    UI.CtrlKeyDown = function()
        return true
    end
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, MOD_CTRL, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "skipped Leaf, landed on Group 1")
    T.eq(speaks[1].text, "Group 1")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_CTRL, WM_KEYDOWN)
    T.eq(h._indices[1], 3, "advanced to Group 2")
end

function M.test_ctrl_up_at_level_2_jumps_to_prev_group_first_child()
    setup()
    setCtrls({ "A1", "B1", "B2" })
    local groupA = groupItem("A", { buttonItem("A1") })
    local groupB = groupItem("B", { buttonItem("B1"), buttonItem("B2") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupA, groupB } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- on Group B
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill B
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- B2
    UI.CtrlKeyDown = function()
        return true
    end
    speaks = {}
    InputRouter.dispatch(Keys.VK_UP, MOD_CTRL, WM_KEYDOWN)
    T.eq(h._indices[1], 1, "parent moved to Group A")
    T.eq(h._indices[2], 1, "landed on first child of A")
    T.eq(speaks[1].text, "A")
end

function M.test_empty_group_is_skipped_in_navigation()
    setup()
    setCtrls({ "A1", "C1" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Group({ labelText = "Full A", items = { buttonItem("A1", "A One") } }),
            BaseMenuItems.Group({ labelText = "Empty", items = {} }),
            BaseMenuItems.Group({ labelText = "Full C", items = { buttonItem("C1", "C One") } }),
        },
    })
    HandlerStack.push(h)
    T.eq(h._indices[1], 1, "open lands on first non-empty group")
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 3, "Down skips the empty group")
    T.eq(speaks[1].text, "Full C")
end

function M.test_group_with_only_non_navigable_children_is_skipped()
    setup()
    setCtrls({ "A1", "HIDDEN", "C1" })
    ctrlState.HIDDEN.hidden = true
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Group({ labelText = "Full A", items = { buttonItem("A1", "A One") } }),
            BaseMenuItems.Group({ labelText = "OnlyHidden", items = { buttonItem("HIDDEN", "Hidden Child") } }),
            BaseMenuItems.Group({ labelText = "Full C", items = { buttonItem("C1", "C One") } }),
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 3, "Down skips group whose only child is hidden")
    T.eq(speaks[1].text, "Full C")
end

function M.test_nested_group_with_inner_drillable_stays_navigable()
    setup()
    setCtrls({ "DEEP" })
    local innerGroup = BaseMenuItems.Group({ labelText = "Inner", items = { buttonItem("DEEP", "Leaf") } })
    local outerGroup = BaseMenuItems.Group({ labelText = "Outer", items = { innerGroup } })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { outerGroup } })
    HandlerStack.push(h)
    T.truthy(outerGroup:isNavigable(), "outer group navigable when inner has a leaf")
    T.truthy(innerGroup:isNavigable(), "inner group navigable")
    speaks = {}
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill into outer
    T.eq(h._level, 2, "drilled into outer")
    T.eq(speaks[1].text, "Inner", "inner group announced")
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill into inner
    T.eq(h._level, 3, "drilled into inner")
    T.eq(speaks[2].text, "Leaf", "leaf announced")
end

function M.test_nested_group_with_only_empty_inner_is_hidden()
    setup()
    setCtrls({ "REAL" })
    local emptyInner = BaseMenuItems.Group({ labelText = "EmptyInner", items = {} })
    local hollowOuter = BaseMenuItems.Group({ labelText = "Hollow", items = { emptyInner } })
    local realGroup = BaseMenuItems.Group({ labelText = "Real", items = { buttonItem("REAL", "Leaf") } })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { realGroup, hollowOuter },
    })
    HandlerStack.push(h)
    T.falsy(hollowOuter:isNavigable(), "outer group with only empty inner is hidden")
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 1, "Down has nowhere to go; cursor stays on Real")
end

function M.test_group_itemsFn_is_called_lazily_and_cached()
    setup()
    setCtrls({ "C" })
    local calls = 0
    local group = BaseMenuItems.Group({
        labelText = "Lazy",
        itemsFn = function()
            calls = calls + 1
            return { buttonItem("C", "Child") }
        end,
    })
    T.eq(calls, 0, "not called at spec time")
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { group } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    T.eq(calls, 1)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN) -- back
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill again
    T.eq(calls, 1, "children cached after first drill")
end

function M.test_pulldown_fallback_fires_per_entry_button_callback()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    -- Shared metatable so the button probe's patch covers every entry
    -- button built for this pulldown.
    local btnProto = Polyfill.makeButton()
    local btnMt = {
        __index = {
            SetText = btnProto.SetText,
            GetText = btnProto.GetText,
            SetVoid1 = btnProto.SetVoid1,
            GetVoid1 = btnProto.GetVoid1,
            IsHidden = btnProto.IsHidden,
            IsDisabled = btnProto.IsDisabled,
            SetHide = btnProto.SetHide,
            SetDisabled = btnProto.SetDisabled,
            RegisterCallback = btnProto.RegisterCallback,
        },
    }
    -- Pre-build instances with buttons that share the metatable, then
    -- register the probe from the first of those buttons before any
    -- per-button RegisterCallback calls.
    local inst1 = { Button = Polyfill.makeButtonWithMetatable(btnMt) }
    local inst2 = { Button = Polyfill.makeButtonWithMetatable(btnMt) }
    PullDownProbe.ensureButtonInstalled(inst1.Button)
    pd:ClearEntries()
    pd:BuildEntry("InstanceOne", inst1)
    pd:BuildEntry("InstanceOne", inst2)
    inst1.Button:SetText("Temperate")
    inst2.Button:SetText("Cool")
    -- No top-level RegisterSelectionCallback: per-entry click callbacks
    -- only. Mirrors the map-script option dropdown pattern.
    local fired = {}
    inst1.Button:RegisterCallback(Mouse.eLClick, function()
        fired[#fired + 1] = "t"
    end)
    inst2.Button:RegisterCallback(Mouse.eLClick, function()
        fired[#fired + 1] = "c"
    end)

    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- drill into sub
    T.eq(HandlerStack.count(), 2, "sub pushed via per-entry fallback")
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- commit second entry
    T.eq(#fired, 1)
    T.eq(fired[1], "c", "second entry's per-button callback fired")
    T.eq(HandlerStack.count(), 1, "sub popped after commit")
end

function M.test_pulldown_inner_button_disabled_marks_inactivatable()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:RegisterSelectionCallback(function() end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Only Option")
    -- Base code pattern: disable the pulldown's inner button, not the
    -- pulldown userdata itself (e.g., map-size-locked maps).
    pd:GetButton():SetDisabled(true)
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    local item = h._items[1]
    T.falsy(item:isActivatable(), "inner button disabled blocks activation")
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1, "sub not pushed when button disabled")
    -- Announcement should carry the disabled suffix.
    local found = false
    for _, s in ipairs(speaks) do
        if s.text and s.text:find("disabled") then
            found = true
        end
    end
    T.truthy(found, "disabled suffix announced")
end

function M.test_pulldown_entry_announce_fn_replaces_entry_text()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:ClearEntries()
    pd:RegisterSelectionCallback(function() end)
    local i1, i2 = {}, {}
    pd:BuildEntry("InstanceOne", i1)
    pd:BuildEntry("InstanceOne", i2)
    i1.Button:SetText("Plain A")
    i2.Button:SetText("Plain B")
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Pulldown({
                controlName = "PD",
                textKey = "LBL_PD",
                entryAnnounceFn = function(inst, idx)
                    return "rich " .. idx
                end,
            }),
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- drill
    local richHeard = {}
    for _, s in ipairs(speaks) do
        richHeard[s.text] = true
    end
    T.truthy(richHeard["rich 1"], "override used for first entry announce")
    -- Move to second entry and confirm its override announce too.
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "rich 2")
end

function M.test_pulldown_no_callback_at_all_logs_warn()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:ClearEntries()
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Lonely")
    -- Neither top-level callback nor per-button click callback registered.
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
    HandlerStack.push(h)
    warns = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1, "sub not pushed with no callback")
    T.truthy(#warns >= 1, "warn logged")
end

function M.test_group_cached_false_rebuilds_on_every_drill()
    setup()
    setCtrls({ "C" })
    local calls = 0
    local group = BaseMenuItems.Group({
        labelText = "Dynamic",
        cached = false,
        itemsFn = function()
            calls = calls + 1
            return { buttonItem("C", "Child") }
        end,
    })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { group } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.truthy(calls >= 2, "itemsFn re-runs on second drill with cached=false")
end

function M.test_hidden_group_is_skipped_in_navigation()
    setup()
    setCtrls({ "HIDE_BOX", "A", "C" })
    ctrlState.HIDE_BOX.hidden = true
    local hiddenGroup = BaseMenuItems.Group({
        labelText = "HiddenGroup",
        visibilityControlName = "HIDE_BOX",
        items = { buttonItem("A") },
    })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            buttonItem("C", "Leaf"),
            hiddenGroup,
        },
    })
    HandlerStack.push(h)
    -- Only one navigable item at top level: Leaf.
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 1, "hidden group skipped in wrap")
end

function M.test_single_sibling_group_wraps_circularly_within_itself()
    setup()
    setCtrls({ "A1", "A2" })
    local only = groupItem("Solo", { buttonItem("A1", "A1"), buttonItem("A2", "A2") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { only } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- A2
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- past end, only 1 group -> wrap self
    T.eq(h._indices[1], 1, "still same parent")
    T.eq(h._indices[2], 1, "wrapped to first child")
    T.eq(speaks[1].text, "A1")
end

function M.test_slider_at_level_2_left_right_adjusts_not_back()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    slider:RegisterSliderCallback(function(v)
        label:SetText(tostring(math.floor(v * 100 + 0.5)))
    end)
    local group = groupItem("Options", {
        BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL_S" }),
    })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { group } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    T.eq(h._level, 2)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- slider adjust, NOT back
    T.eq(h._level, 2, "still at level 2: right adjusted the slider")
    T.eq(slider:GetValue(), 0.51)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN) -- slider decrement
    T.eq(h._level, 2, "still at level 2: left adjusted the slider")
    T.eq(slider:GetValue(), 0.50)
end

function M.test_level_reset_on_hide_then_reopen()
    setup()
    setCtrls({ "CHILD" })
    local ctx = {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
    local handler = BaseMenu.install(
        ctx,
        { name = "T", displayName = "Screen", items = { groupItem("P", { buttonItem("CHILD", "C") }) } }
    )
    ctx._sh(false, false)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(handler._level, 2)
    ctx._sh(true, false)
    ctx._sh(false, false)
    T.eq(handler._level, 1, "level reset to 1 on reopen")
end

-- Type-ahead search ------------------------------------------------------

local function installForSearch(labelledItems)
    local ctx = makeContextPtr()
    local names = {}
    for _, it in ipairs(labelledItems) do
        names[#names + 1] = it.name
    end
    setCtrls(names)
    local specItems = {}
    for _, it in ipairs(labelledItems) do
        specItems[#specItems + 1] = BaseMenuItems.Button({
            controlName = it.name,
            labelText = it.label,
            activate = function() end,
        })
    end
    local handler = BaseMenu.install(ctx, { name = "T", displayName = "Screen", items = specItems })
    ctx._sh(false, false)
    return ctx, handler
end

local function keydown(ctx, vk)
    return ctx._in(WM_KEYDOWN, vk, 0)
end
local function vkLetter(c)
    return string.byte(string.upper(c))
end

function M.test_search_letter_moves_to_first_match()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Banana" },
        { name = "C", label = "Cherry" },
    })
    speaks = {}
    T.truthy(keydown(ctx, vkLetter("b")), "letter consumed by search")
    T.eq(h._indices[1], 2, "cursor moved to Banana")
    T.truthy(h._search:isSearchActive())
end

function M.test_search_no_match_speaks_and_stays_active()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Banana" },
    })
    speaks = {}
    keydown(ctx, vkLetter("z"))
    T.truthy(h._search:isSearchActive())
    local saw = false
    for _, s in ipairs(speaks) do
        if s.text == "no match for z" then
            saw = true
            break
        end
    end
    T.truthy(saw, "no-match announcement fired")
end

function M.test_search_escape_clears_instead_of_going_back()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Banana" },
    })
    keydown(ctx, vkLetter("a"))
    T.truthy(h._search:isSearchActive())
    speaks = {}
    keydown(ctx, Keys.VK_ESCAPE)
    T.falsy(h._search:isSearchActive(), "Escape cleared search")
    T.eq(h._level, 1, "Escape did not change level")
    T.eq(speaks[1] and speaks[1].text, "search cleared")
end

function M.test_search_down_navigates_results_not_items()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Apricot" },
        { name = "C", label = "Banana" },
    })
    keydown(ctx, vkLetter("a"))
    T.eq(h._indices[1], 1, "first result: Apple")
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "Down within results: Apricot")
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 3, "Down again: Banana (substring match)")
end

function M.test_search_backspace_to_empty_clears()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
    })
    keydown(ctx, vkLetter("a"))
    T.truthy(h._search:isSearchActive())
    keydown(ctx, Keys.VK_BACK)
    T.falsy(h._search:isSearchActive(), "backspace-to-empty clears search")
end

function M.test_search_enter_activates_current_result()
    setup()
    local ctx = makeContextPtr()
    setCtrls({ "A", "B" })
    local fired = 0
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                labelText = "Apple",
                activate = function() end,
            }),
            BaseMenuItems.Button({
                controlName = "B",
                labelText = "Banana",
                activate = function()
                    fired = fired + 1
                end,
            }),
        },
    })
    ctx._sh(false, false)
    keydown(ctx, vkLetter("b"))
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(fired, 1, "Enter activates the search-selected item")
end

function M.test_search_clears_on_drill()
    setup()
    setCtrls({ "CHILD" })
    local ctx = makeContextPtr()
    local handler = BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = {
            groupItem("PARENT", {
                BaseMenuItems.Button({
                    controlName = "CHILD",
                    labelText = "Apple",
                    activate = function() end,
                }),
            }),
        },
    })
    ctx._sh(false, false)
    keydown(ctx, vkLetter("p"))
    T.truthy(handler._search:isSearchActive())
    -- Right drills into the group (search was matching parent-level labels).
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(handler._level, 2)
    T.falsy(handler._search:isSearchActive(), "search cleared on drill")
end

function M.test_setIndex_clears_active_search()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Banana" },
    })
    keydown(ctx, vkLetter("a"))
    T.truthy(h._search:isSearchActive(), "search started by typing a")
    h.setIndex(2)
    T.falsy(h._search:isSearchActive(), "programmatic setIndex cleared stale search")
    T.eq(h._indices[1], 2, "cursor moved to requested slot")
end

function M.test_search_ignored_when_ctrl_held()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
    })
    UI.CtrlKeyDown = function()
        return true
    end
    keydown(ctx, vkLetter("a"))
    -- The modal capturesAllInput barrier still absorbs Ctrl+A, but the
    -- critical guarantee is that it did not feed the search buffer.
    T.falsy(h._search:isSearchActive(), "Ctrl+A must not start a type-ahead search")
end

-- Choice.selectedFn: browse-then-commit screens (ScenariosMenu, CustomMod,
-- LoadTutorial) need the announce to include "selected" for the row that
-- the screen's own selection state currently points at, and need activate
-- to re-announce so the user gets audio confirmation when they commit
-- (Enter on a Choice without selectedFn would rely on the screen's close
-- path to speak, which browse screens don't trigger -- they just flip a
-- flag and wait for Start).
function M.test_choice_selectedfn_prepends_selected_and_reannounces()
    setup()
    populateControls({})
    local currentSelection = nil
    local choiceA = BaseMenuItems.Choice({
        labelText = "Apple",
        selectedFn = function()
            return currentSelection == "A"
        end,
        activate = function()
            currentSelection = "A"
        end,
    })
    local choiceB = BaseMenuItems.Choice({
        labelText = "Banana",
        selectedFn = function()
            return currentSelection == "B"
        end,
        activate = function()
            currentSelection = "B"
        end,
    })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = { choiceA, choiceB } })
    HandlerStack.push(h)

    -- Nothing selected yet: neither announce prepends "selected".
    T.eq(choiceA:announce(h), "Apple")
    T.eq(choiceB:announce(h), "Banana")

    -- Activate A; the activate fires, currentSelection flips, and the
    -- item re-announces through speakInterrupt so the user hears
    -- "selected, Apple" without having to arrow away and back.
    speaks = {}
    choiceA:activate(h)
    T.eq(currentSelection, "A", "activate ran user fn")
    local reannounce = speaks[#speaks]
    T.truthy(reannounce ~= nil, "activate re-announces")
    T.eq(reannounce.text, "selected, Apple")
    T.eq(reannounce.interrupt, true)

    -- B still announces plain (it's not the selection target anymore).
    T.eq(choiceB:announce(h), "Banana")
    -- A now announces with the prefix on subsequent nav too.
    T.eq(choiceA:announce(h), "selected, Apple")
end

function M.test_choice_without_selectedfn_does_not_reannounce()
    setup()
    populateControls({})
    local fired = false
    local choice = BaseMenuItems.Choice({
        labelText = "Apple",
        activate = function()
            fired = true
        end,
    })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = { choice } })
    HandlerStack.push(h)

    speaks = {}
    choice:activate(h)
    T.eq(fired, true)
    -- Without selectedFn we skip the re-announce entirely (the caller
    -- opted into the browse-then-commit pattern only by supplying one).
    T.eq(#speaks, 0, "no re-announce without selectedFn")
    T.eq(choice:announce(h), "Apple", "no 'selected' prefix without selectedFn")
end

-- Pulldown sub-menus precompute per-entry "this matches the committed
-- value" at activate time and pass it into buildChoice. The entry whose
-- button text equals the pulldown's current value announces with the
-- "selected" prefix so the user can identify the committed pick while
-- browsing the sub. Non-matching entries stay unprefixed.
function M.test_pulldown_sub_entry_announces_selected_for_current_value()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:ClearEntries()
    pd:RegisterSelectionCallback(function() end)
    local inst1 = {}
    pd:BuildEntry("InstanceOne", inst1)
    inst1.Button:SetText("Easy")
    local inst2 = {}
    pd:BuildEntry("InstanceOne", inst2)
    inst2.Button:SetText("Hard")
    -- Parent pulldown's committed value is "Hard".
    pd:GetButton():SetText("Hard")

    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)

    local sub = HandlerStack.active()
    T.eq(sub.name, "T/PD_PullDown")
    T.eq(sub._items[1]:announce(sub), "Easy", "non-matching entry has no 'selected' prefix")
    T.eq(sub._items[2]:announce(sub), "selected, Hard", "matching entry announces with 'selected' prefix")
end

function M.test_choice_selectedfn_skips_reannounce_when_activate_pops_handler()
    setup()
    populateControls({})
    -- Simulates a Select*-style screen: activate commits then closes the
    -- screen (HandlerStack.pop). The parent's own onActivate will speak;
    -- our re-announce would race against that and produce a stutter.
    local choice
    choice = BaseMenuItems.Choice({
        labelText = "Apple",
        selectedFn = function()
            return true
        end,
        activate = function()
            HandlerStack.pop()
        end,
    })
    local parent = BaseMenu.create({
        name = "PARENT",
        displayName = "Parent",
        items = { BaseMenuItems.Button({ controlName = "X", textKey = "X", activate = function() end }) },
    })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = { choice } })
    setCtrls({ "X" })
    HandlerStack.push(parent)
    HandlerStack.push(h)

    speaks = {}
    choice:activate(h)
    -- HandlerStack.pop reactivates parent which speaks its own content.
    -- The critical invariant is that no "selected, Apple" entry appears
    -- after that -- the child's re-announce was suppressed.
    for _, s in ipairs(speaks) do
        T.truthy(s.text ~= "selected, Apple", "suppressed re-announce after handler pop")
    end
end

-- Ctrl+I pedia dispatch ---------------------------------------------------
--
-- Guards the plan §4.1 Civilopedia wiring: BaseMenu.create binds Ctrl+I
-- and dispatches to Events.SearchForPediaEntry when the focused item
-- carries pediaName (static) or pediaNameFn (dynamic, re-resolved each
-- press). Items without either silently no-op. The binding itself is
-- gated on the Game global's presence so FrontEnd Contexts (where
-- Civilopedia isn't loaded) don't advertise a chord that can't work.

local function withPediaStub(fn)
    local captured = {}
    Events.SearchForPediaEntry = function(name)
        captured[#captured + 1] = name
    end
    fn(captured)
    Events.SearchForPediaEntry = nil
end

function M.test_ctrl_i_fires_pedia_event_with_static_name()
    setup()
    setCtrls({ "A", "B" })
    withPediaStub(function(captured)
        local h = BaseMenu.create({
            name = "T",
            displayName = "Test",
            items = {
                BaseMenuItems.Button({
                    controlName = "A",
                    textKey = "LBL_A",
                    pediaName = "Library",
                    activate = function() end,
                }),
                BaseMenuItems.Button({ controlName = "B", textKey = "LBL_B", activate = function() end }),
            },
        })
        HandlerStack.push(h)
        InputRouter.dispatch(Keys.I, MOD_CTRL, WM_KEYDOWN)
        T.eq(#captured, 1, "one pedia event fired")
        T.eq(captured[1], "Library", "fired with the focused item's pediaName")
    end)
end

function M.test_ctrl_i_resolves_pediaNameFn_dynamically()
    setup()
    setCtrls({ "A" })
    withPediaStub(function(captured)
        local resolveCount = 0
        local current = "Warrior"
        local h = BaseMenu.create({
            name = "T",
            displayName = "Test",
            items = {
                BaseMenuItems.Button({
                    controlName = "A",
                    textKey = "LBL",
                    pediaNameFn = function()
                        resolveCount = resolveCount + 1
                        return current
                    end,
                    activate = function() end,
                }),
            },
        })
        HandlerStack.push(h)
        InputRouter.dispatch(Keys.I, MOD_CTRL, WM_KEYDOWN)
        current = "Archer"
        InputRouter.dispatch(Keys.I, MOD_CTRL, WM_KEYDOWN)
        T.eq(#captured, 2)
        T.eq(captured[1], "Warrior")
        T.eq(captured[2], "Archer", "pediaNameFn re-resolves each press")
        T.truthy(resolveCount >= 2)
    end)
end

function M.test_ctrl_i_noop_when_item_has_no_pediaName()
    setup()
    setCtrls({ "A" })
    withPediaStub(function(captured)
        local h = BaseMenu.create({
            name = "T",
            displayName = "Test",
            items = {
                BaseMenuItems.Button({ controlName = "A", textKey = "LBL", activate = function() end }),
            },
        })
        HandlerStack.push(h)
        InputRouter.dispatch(Keys.I, MOD_CTRL, WM_KEYDOWN)
        T.eq(#captured, 0, "no pedia event fired for an item without pediaName")
    end)
end

function M.test_ctrl_i_pediaNameFn_error_logged_and_swallowed()
    setup()
    setCtrls({ "A" })
    withPediaStub(function(captured)
        local h = BaseMenu.create({
            name = "T",
            displayName = "Test",
            items = {
                BaseMenuItems.Button({
                    controlName = "A",
                    textKey = "LBL",
                    pediaNameFn = function()
                        error("boom")
                    end,
                    activate = function() end,
                }),
            },
        })
        HandlerStack.push(h)
        InputRouter.dispatch(Keys.I, MOD_CTRL, WM_KEYDOWN)
        T.eq(#captured, 0, "fn error prevents pedia fire")
        T.truthy(#errors >= 1, "error logged")
    end)
end

function M.test_ctrl_i_binding_absent_in_frontend()
    setup()
    setCtrls({ "A" })
    -- Simulate FrontEnd by clearing the Game global -- BaseMenu.create
    -- gates the Ctrl+I binding on Game's presence so it doesn't claim
    -- the key in pre-game menus where Civilopedia isn't loaded. Events.X
    -- is not a usable gate (the engine auto-creates event slots on access,
    -- so Events.SearchForPediaEntry is non-nil even in FrontEnd).
    local savedGame = Game
    Game = nil
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                textKey = "LBL",
                pediaName = "Library",
                activate = function() end,
            }),
        },
    })
    Game = savedGame
    local hasCtrlI = false
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.I and b.mods == MOD_CTRL then
            hasCtrlI = true
        end
    end
    T.falsy(hasCtrlI, "no Ctrl+I binding in FrontEnd (Game == nil)")
end


return M

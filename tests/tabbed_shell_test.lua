-- TabbedShell tests. Loads HandlerStack, InputRouter, BaseMenu, and the
-- shell. Speech is captured via SpeechPipeline._speakAction so suites can
-- assert spoken text + interrupt flag in order.

local T = require("support")
local M = {}

local warns, errors
local speaks

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
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuHelp.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuTabs.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TabbedShell.lua")
    HandlerStack._reset()
    TickPump._reset()

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TS_SCREEN"] = "TestScreen"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TS_TAB_A"] = "TabA"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TS_TAB_B"] = "TabB"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TS_TAB_C"] = "TabC"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TS_ITEM_A"] = "ItemA"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TS_ITEM_B"] = "ItemB"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TS_ITEM_C"] = "ItemC"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "no match"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "search cleared"
end

-- Build a minimal stub tab object that records lifecycle calls. Lets tests
-- exercise the shell without coupling to BaseMenu specifics.
local function stubTab(opts)
    opts = opts or {}
    local calls = { activated = {}, deactivated = 0 }
    local tab = {
        tabName = opts.tabName or "TXT_KEY_CIVVACCESS_TS_TAB_A",
        bindings = opts.bindings or {},
        helpEntries = opts.helpEntries or {},
        _calls = calls,
    }
    tab.onTabActivated = function(self, announce)
        calls.activated[#calls.activated + 1] = announce
        if announce then
            SpeechPipeline.speakInterrupt(Text.key(self.tabName))
        end
        if opts.contentText ~= nil then
            SpeechPipeline.speakQueued(opts.contentText)
        end
    end
    tab.onTabDeactivated = function()
        calls.deactivated = calls.deactivated + 1
    end
    if opts.handleSearchInput ~= nil then
        tab.handleSearchInput = opts.handleSearchInput
    end
    return tab
end

-- Factory --------------------------------------------------------------

function M.test_create_requires_name_and_displayName()
    setup()
    local ok = pcall(TabbedShell.create, { tabs = { stubTab() } })
    T.falsy(ok, "missing name/displayName should fail")
end

function M.test_create_requires_at_least_one_tab()
    setup()
    local ok = pcall(TabbedShell.create, {
        name = "X",
        displayName = "X",
        tabs = {},
    })
    T.falsy(ok, "empty tabs should fail")
end

function M.test_create_validates_tab_contract()
    setup()
    local ok = pcall(TabbedShell.create, {
        name = "X",
        displayName = "X",
        tabs = { { tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A" } },
    })
    T.falsy(ok, "tab missing onTabActivated should fail")
end

function M.test_create_shape()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { stubTab(), stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B" }) },
    })
    T.eq(h.capturesAllInput, true)
    T.eq(type(h.bindings), "table")
    T.eq(type(h.helpEntries), "table")
    T.eq(type(h.onActivate), "function")
    T.eq(type(h.onDeactivate), "function")
    T.eq(type(h.activeTabIndex), "function")
    T.eq(h.activeTabIndex(), 1)
end

function M.test_initial_tab_index_honored()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { stubTab(), stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B" }) },
        initialTabIndex = 2,
    })
    T.eq(h.activeTabIndex(), 2)
end

function M.test_initial_tab_index_out_of_range_rejected()
    setup()
    local ok = pcall(TabbedShell.create, {
        name = "X",
        displayName = "X",
        tabs = { stubTab() },
        initialTabIndex = 5,
    })
    T.falsy(ok)
end

-- Lifecycle ------------------------------------------------------------

function M.test_first_open_speaks_screen_then_chains_first_tab_content()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = {
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A", contentText = "ItemA" }),
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B", contentText = "ItemB" }),
        },
    })
    HandlerStack.push(h)
    -- Speech: speakInterrupt("TestScreen"), speakQueued tab name ("TabA"),
    -- then activeTab onTabActivated(false) which does NOT re-speak tabName
    -- but does speakQueued("ItemA").
    T.eq(#speaks, 3)
    T.eq(speaks[1].text, "TestScreen")
    T.eq(speaks[1].interrupt, true)
    T.eq(speaks[2].text, "TabA")
    T.eq(speaks[2].interrupt, false)
    T.eq(speaks[3].text, "ItemA")
    T.eq(speaks[3].interrupt, false)
    T.eq(h._tabs[1]._calls.activated[1], false)
end

function M.test_tab_cycle_speaks_tabName_interrupt_then_content_queued()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = {
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A", contentText = "ItemA" }),
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B", contentText = "ItemB" }),
        },
    })
    HandlerStack.push(h)
    -- Reset speech log so we only see what cycling produces.
    speaks = {}
    -- Find Tab binding and fire it.
    local tabFn
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            tabFn = b.fn
            break
        end
    end
    T.truthy(tabFn, "Tab binding present")
    tabFn()
    T.eq(h.activeTabIndex(), 2)
    -- Tab B speaks tabName interrupt + content queued.
    T.eq(#speaks, 2)
    T.eq(speaks[1].text, "TabB")
    T.eq(speaks[1].interrupt, true)
    T.eq(speaks[2].text, "ItemB")
    T.eq(speaks[2].interrupt, false)
    -- Tab A was deactivated.
    T.eq(h._tabs[1]._calls.deactivated, 1)
    -- Tab B was activated with announce=true.
    T.eq(h._tabs[2]._calls.activated[1], true)
end

function M.test_shift_tab_cycles_backward_with_wrap()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = {
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A" }),
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B" }),
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_C" }),
        },
    })
    HandlerStack.push(h)
    local shiftTabFn
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 1 then
            shiftTabFn = b.fn
            break
        end
    end
    T.truthy(shiftTabFn)
    -- From tab 1, Shift+Tab wraps to tab 3.
    shiftTabFn()
    T.eq(h.activeTabIndex(), 3)
    -- Tab forward wraps back to 1.
    local tabFn
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            tabFn = b.fn
            break
        end
    end
    tabFn()
    T.eq(h.activeTabIndex(), 1)
end

function M.test_cycle_with_one_tab_is_no_op()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { stubTab() },
    })
    HandlerStack.push(h)
    speaks = {}
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            b.fn()
        end
    end
    T.eq(#speaks, 0, "single-tab cycle should be silent")
end

function M.test_reactivation_speaks_tab_name()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A", contentText = "ItemA" }) },
    })
    HandlerStack.push(h)
    speaks = {}
    -- Re-fire onActivate (simulates a sub pop above the shell).
    h.onActivate()
    -- announce=true on re-activation: tab speaks tabName interrupt + content queued.
    T.eq(#speaks, 2)
    T.eq(speaks[1].text, "TabA")
    T.eq(speaks[1].interrupt, true)
    T.eq(speaks[2].text, "ItemA")
end

function M.test_deactivate_calls_active_tab_deactivate()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { stubTab(), stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B" }) },
    })
    HandlerStack.push(h)
    -- Pop fires shell.onDeactivate which deactivates the active tab.
    HandlerStack.pop()
    T.eq(h._tabs[1]._calls.deactivated, 1)
    T.eq(h._tabs[2]._calls.deactivated, 0)
end

-- Bindings composition -------------------------------------------------

function M.test_bindings_compose_shell_first_then_active_tab()
    setup()
    local tabA = stubTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A",
        bindings = {
            { key = Keys.A, mods = 0, fn = function() end, description = "from tabA" },
        },
    })
    local tabB = stubTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B",
        bindings = {
            { key = Keys.B, mods = 0, fn = function() end, description = "from tabB" },
        },
    })
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { tabA, tabB },
    })
    -- On first tab: shell bindings (Tab/Shift+Tab/F1) + tabA's "A" binding.
    -- Shell entries come first.
    local hasA, hasB = false, false
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.A then
            hasA = true
        end
        if b.key == Keys.B then
            hasB = true
        end
    end
    T.truthy(hasA, "tabA's A binding present while tabA is active")
    T.falsy(hasB, "tabB's B binding absent while tabA is active")

    -- Cycle forward and check bindings flip.
    HandlerStack.push(h)
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            b.fn()
            break
        end
    end
    hasA, hasB = false, false
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.A then
            hasA = true
        end
        if b.key == Keys.B then
            hasB = true
        end
    end
    T.falsy(hasA, "tabA's A binding gone after cycle")
    T.truthy(hasB, "tabB's B binding present after cycle")
end

function M.test_active_tab_tab_and_esc_bindings_filtered()
    setup()
    local tab = stubTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A",
        bindings = {
            -- Tab gets filtered (shell owns).
            { key = Keys.VK_TAB, mods = 0, fn = function() end, description = "tab's own Tab" },
            -- Esc gets filtered (shell owns).
            { key = Keys.VK_ESCAPE, mods = 0, fn = function() end, description = "tab's own Esc" },
            -- Other keys pass through.
            { key = Keys.X, mods = 0, fn = function() end, description = "tab's X" },
        },
    })
    local h = TabbedShell.create({
        name = "X",
        displayName = "X",
        tabs = { tab },
    })
    -- Shell defines exactly one Tab(0), one Tab(SHIFT), one F1. The tab's
    -- redundant Tab/Esc must not appear.
    local tabBindings, escBindings, xBinding = 0, 0, 0
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            tabBindings = tabBindings + 1
        elseif b.key == Keys.VK_ESCAPE and (b.mods or 0) == 0 then
            escBindings = escBindings + 1
        elseif b.key == Keys.X then
            xBinding = xBinding + 1
        end
    end
    T.eq(tabBindings, 1, "exactly one Tab(0) binding (shell's)")
    T.eq(escBindings, 0, "no Esc binding (filtered, shell's install owns Esc)")
    T.eq(xBinding, 1, "tab's other bindings preserved")
end

function M.test_help_entries_compose_shell_then_active_tab()
    setup()
    local tabA = stubTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A",
        helpEntries = { { keyLabel = "TXT_KEY_AAA", description = "tabA help" } },
    })
    local tabB = stubTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B",
        helpEntries = { { keyLabel = "TXT_KEY_BBB", description = "tabB help" } },
    })
    local h = TabbedShell.create({
        name = "X",
        displayName = "X",
        tabs = { tabA, tabB },
    })
    local foundA, foundB = false, false
    for _, e in ipairs(h.helpEntries) do
        if e.keyLabel == "TXT_KEY_AAA" then
            foundA = true
        end
        if e.keyLabel == "TXT_KEY_BBB" then
            foundB = true
        end
    end
    T.truthy(foundA)
    T.falsy(foundB)
    -- Cycle and re-check.
    HandlerStack.push(h)
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            b.fn()
            break
        end
    end
    foundA, foundB = false, false
    for _, e in ipairs(h.helpEntries) do
        if e.keyLabel == "TXT_KEY_AAA" then
            foundA = true
        end
        if e.keyLabel == "TXT_KEY_BBB" then
            foundB = true
        end
    end
    T.falsy(foundA)
    T.truthy(foundB)
end

function M.test_rebuildExposed_picks_up_active_tab_help_mutation()
    -- Screens that swap a tab's helpEntries in place (e.g. tech tree's
    -- grid/tree mode toggle) call rebuildExposed to recompose the shell
    -- handler's helpEntries so the ? overlay reads the active set.
    setup()
    local tab = stubTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A",
        helpEntries = { { keyLabel = "TXT_KEY_BEFORE", description = "before" } },
    })
    local h = TabbedShell.create({
        name = "X",
        displayName = "X",
        tabs = { tab },
    })
    local function findKey(label)
        for _, e in ipairs(h.helpEntries) do
            if e.keyLabel == label then
                return true
            end
        end
        return false
    end
    T.truthy(findKey("TXT_KEY_BEFORE"))
    tab.helpEntries = { { keyLabel = "TXT_KEY_AFTER", description = "after" } }
    -- Mutation alone doesn't update the shell's composed list; rebuild
    -- is what propagates.
    T.truthy(findKey("TXT_KEY_BEFORE"), "mutation without rebuild leaves stale help")
    h.rebuildExposed()
    T.falsy(findKey("TXT_KEY_BEFORE"))
    T.truthy(findKey("TXT_KEY_AFTER"))
end

-- F1 readShellHeader ---------------------------------------------------

function M.test_f1_reads_displayName_then_active_tab_name()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = {
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A" }),
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B" }),
        },
    })
    HandlerStack.push(h)
    speaks = {}
    -- Reset SpeechPipeline dedup window so the F1 re-speak of displayName
    -- isn't filtered as a same-text-within-50ms duplicate of the open-time
    -- speakInterrupt.
    SpeechPipeline._reset()
    local f1Fn
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_F1 and (b.mods or 0) == 0 then
            f1Fn = b.fn
            break
        end
    end
    T.truthy(f1Fn)
    f1Fn()
    T.eq(#speaks, 2)
    T.eq(speaks[1].text, "TestScreen")
    T.eq(speaks[1].interrupt, true)
    T.eq(speaks[2].text, "TabA")
    T.eq(speaks[2].interrupt, false)
end

-- handleSearchInput pass-through ---------------------------------------

function M.test_handleSearchInput_delegates_to_active_tab()
    setup()
    local capturedA = {}
    local capturedB = {}
    local tabA = stubTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A",
        handleSearchInput = function(_self, vk, mods)
            capturedA[#capturedA + 1] = { vk = vk, mods = mods }
            return true
        end,
    })
    local tabB = stubTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B",
        handleSearchInput = function(_self, vk, mods)
            capturedB[#capturedB + 1] = { vk = vk, mods = mods }
            return false
        end,
    })
    local h = TabbedShell.create({
        name = "X",
        displayName = "X",
        tabs = { tabA, tabB },
    })
    HandlerStack.push(h)
    local consumed = h.handleSearchInput(h, 0x41, 0)
    T.eq(consumed, true)
    T.eq(#capturedA, 1)
    T.eq(capturedA[1].vk, 0x41)
    -- After cycling to tab B:
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            b.fn()
            break
        end
    end
    consumed = h.handleSearchInput(h, 0x42, 0)
    T.eq(consumed, false)
    T.eq(#capturedB, 1)
    T.eq(capturedB[1].vk, 0x42)
    -- Tab A was not called the second time.
    T.eq(#capturedA, 1)
end

function M.test_handleSearchInput_returns_false_when_active_tab_lacks_hook()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "X",
        tabs = { stubTab() }, -- no handleSearchInput
    })
    HandlerStack.push(h)
    local consumed = h.handleSearchInput(h, 0x41, 0)
    T.eq(consumed, false)
end

-- switchToTab ----------------------------------------------------------

function M.test_switchToTab_jumps_to_arbitrary_index()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = {
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A" }),
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B" }),
            stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_C" }),
        },
    })
    HandlerStack.push(h)
    speaks = {}
    h.switchToTab(3)
    T.eq(h.activeTabIndex(), 3)
    -- Tab C was activated with announce=true.
    T.eq(h._tabs[3]._calls.activated[1], true)
    T.eq(speaks[1].text, "TabC")
    T.eq(speaks[1].interrupt, true)
end

function M.test_switchToTab_same_index_is_noop()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { stubTab(), stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B" }) },
    })
    HandlerStack.push(h)
    speaks = {}
    h.switchToTab(1)
    T.eq(#speaks, 0)
end

function M.test_switchToTab_out_of_range_is_silent_noop()
    setup()
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { stubTab(), stubTab({ tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B" }) },
    })
    HandlerStack.push(h)
    speaks = {}
    h.switchToTab(99)
    T.eq(h.activeTabIndex(), 1)
    T.eq(#speaks, 0)
end

-- BaseMenu adapter via TabbedShell.menuTab -----------------------------

function M.test_menuTab_chains_first_open_speech_after_shell_displayName()
    setup()
    -- Build a BaseMenu-backed tab. The BaseMenu's Text item produces an
    -- announce string that should be spoken *queued* after the shell's
    -- speakInterrupt(displayName), since silentDisplayName is forced on.
    local tab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A",
        menuSpec = {
            displayName = "MenuADisplay",
            items = {
                BaseMenuItems.Text({ labelText = "ItemA" }),
            },
        },
    })
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { tab },
    })
    HandlerStack.push(h)
    -- Expected: speakInterrupt(TestScreen), speakQueued(tabName "TabA"),
    -- then BaseMenu.onActivate first-open speech: speakQueued for first
    -- item. The BaseMenu's own displayName speech is suppressed because
    -- silentDisplayName=true.
    T.eq(speaks[1].text, "TestScreen")
    T.eq(speaks[1].interrupt, true)
    T.eq(speaks[2].text, "TabA")
    T.eq(speaks[2].interrupt, false)
    -- The first item gets spoken queued at some point; it must not interrupt.
    local sawItem = false
    for _, s in ipairs(speaks) do
        if s.text == "ItemA" then
            T.eq(s.interrupt, false, "ItemA must chain (queued), not interrupt")
            sawItem = true
        end
    end
    T.truthy(sawItem, "ItemA was spoken")
    -- BaseMenu's own displayName must NOT have been spoken.
    for _, s in ipairs(speaks) do
        T.truthy(s.text ~= "MenuADisplay", "BaseMenu displayName must be silent")
    end
end

function M.test_menuTab_cycle_speaks_tabName_then_content_queued()
    setup()
    local tabA = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A",
        menuSpec = {
            displayName = "A",
            items = { BaseMenuItems.Text({ labelText = "ItemA" }) },
        },
    })
    local tabB = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_B",
        menuSpec = {
            displayName = "B",
            items = { BaseMenuItems.Text({ labelText = "ItemB" }) },
        },
    })
    local h = TabbedShell.create({
        name = "X",
        displayName = "TestScreen",
        tabs = { tabA, tabB },
    })
    HandlerStack.push(h)
    speaks = {}
    -- Cycle forward.
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            b.fn()
            break
        end
    end
    -- TabB speaks tabName interrupt, then BaseMenu's first-open speakQueued
    -- for ItemB.
    T.eq(speaks[1].text, "TabB")
    T.eq(speaks[1].interrupt, true)
    local sawItem = false
    for i = 2, #speaks do
        if speaks[i].text == "ItemB" then
            T.eq(speaks[i].interrupt, false)
            sawItem = true
        end
    end
    T.truthy(sawItem)
    -- Now cycle back to A. BaseMenu A is in re-activation state. With
    -- _chainSpeech wiring it should speakQueued for ItemA after the shell's
    -- speakInterrupt of TabA -- not clobber it.
    speaks = {}
    for _, b in ipairs(h.bindings) do
        if b.key == Keys.VK_TAB and (b.mods or 0) == 0 then
            b.fn()
            break
        end
    end
    T.eq(speaks[1].text, "TabA")
    T.eq(speaks[1].interrupt, true)
    sawItem = false
    for i = 2, #speaks do
        if speaks[i].text == "ItemA" then
            T.eq(speaks[i].interrupt, false, "re-activation content must chain queued")
            sawItem = true
        end
    end
    T.truthy(sawItem, "ItemA re-spoken on cycle back")
end

function M.test_menuTab_handleSearchInput_routes_through_basemenu()
    setup()
    local tab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_TS_TAB_A",
        menuSpec = {
            displayName = "A",
            items = {
                BaseMenuItems.Text({ labelText = "Apple" }),
                BaseMenuItems.Text({ labelText = "Banana" }),
            },
        },
    })
    local h = TabbedShell.create({
        name = "X",
        displayName = "X",
        tabs = { tab },
    })
    HandlerStack.push(h)
    speaks = {}
    -- Press 'B' (0x42). BaseMenu's type-ahead should jump to "Banana" and
    -- speak it.
    local consumed = h.handleSearchInput(h, 0x42, 0)
    T.eq(consumed, true)
    local sawBanana = false
    for _, s in ipairs(speaks) do
        if s.text and s.text:find("Banana") then
            sawBanana = true
        end
    end
    T.truthy(sawBanana, "type-ahead routed through BaseMenu")
end

return M

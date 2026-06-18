-- Alt+Up / Alt+Down section review for BaseMenu items. Covers the section
-- builder (BaseMenuItems.buildSections: control-part boundaries, tooltip
-- sentence boundaries, [NEWLINE] splits, dedup, disabled marker, empty-drop,
-- decimal preservation, verbose exclusion) and the navigator wired into the
-- BaseMenu handler (forward / backward walk, edge clamp, fresh-enter,
-- per-item reset, single-section fallback). Shared setup lives in
-- tests/menu_test_setup.lua.
local T = require("support")
local Setup = require("menu_test_setup")
local M = {}

local speaks = Setup.speaks
local setCtrls = Setup.setCtrls
local clearArr = Setup.clearArr

local WM_KEYDOWN = 256
local MOD_ALT = 4
local MOD_NONE = 0

local function setup()
    Setup.fresh()
    -- Deterministic: keep the landing announce free of the verbose position
    -- tag so per-section assertions aren't perturbed by a prior suite that
    -- left verbosity on. Sections never include verbose metadata regardless.
    civvaccess_shared.verbosity = false
end

local function lastSpeak()
    return speaks[#speaks].text
end

-- Section builder --------------------------------------------------------

function M.test_control_parts_and_tooltip_each_a_section()
    setup()
    local s = BaseMenuItems.buildSections({ "Library", "you have 2" }, false, "Boosts science. Costs 5 gold")
    T.eq(#s, 4)
    T.eq(s[1], "Library")
    T.eq(s[2], "you have 2")
    T.eq(s[3], "Boosts science")
    T.eq(s[4], "Costs 5 gold")
end

function M.test_tooltip_newline_becomes_section_break()
    setup()
    local s = BaseMenuItems.buildSections({ "Granary" }, false, "Line one[NEWLINE]Line two")
    T.eq(#s, 3)
    T.eq(s[1], "Granary")
    T.eq(s[2], "Line one")
    T.eq(s[3], "Line two")
end

function M.test_tooltip_sentence_duplicating_control_part_dropped()
    setup()
    local s = BaseMenuItems.buildSections({ "Fullscreen" }, false, "Fullscreen. Extra detail")
    T.eq(#s, 2, "tooltip sentence equal to a control part is not a separate section")
    T.eq(s[1], "Fullscreen")
    T.eq(s[2], "Extra detail")
end

function M.test_disabled_marker_is_a_section()
    setup()
    local s = BaseMenuItems.buildSections({ "Build Wonder" }, true, nil)
    T.eq(#s, 2)
    T.eq(s[1], "Build Wonder")
    T.eq(s[2], "disabled")
end

function M.test_decimal_not_split_into_sections()
    setup()
    local s = BaseMenuItems.buildSections({ "Route" }, false, "Gold base: 1.06[NEWLINE]Total: 5 Gold")
    T.eq(#s, 3)
    T.eq(s[2], "Gold base: 1.06", "fractional value survives sentence splitting")
    T.eq(s[3], "Total: 5 Gold")
end

function M.test_empty_after_filter_section_dropped()
    setup()
    local s = BaseMenuItems.buildSections({ "   ", "Real" }, false, nil)
    T.eq(#s, 1, "whitespace-only control part never becomes a silent section")
    T.eq(s[1], "Real")
end

function M.test_verbose_tags_excluded_from_sections()
    setup()
    civvaccess_shared.verbosity = true
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_BUTTON"] = "button"
    setCtrls({ "A" })
    local item = BaseMenuItems.Button({
        controlName = "A",
        labelText = "Library",
        tooltipText = "A tip",
        activate = function() end,
    })
    local text, sections = item:announce(nil)
    T.eq(text, "Library, button. A tip", "spoken string still carries the verbose kind tag")
    T.eq(#sections, 2, "the kind tag is not a reviewable section")
    T.eq(sections[1], "Library")
    T.eq(sections[2], "A tip")
    civvaccess_shared.verbosity = false
end

-- Navigator --------------------------------------------------------------

local function pushButton(label, tooltipFn)
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                labelText = label,
                tooltipFn = tooltipFn,
                activate = function() end,
            }),
        },
    })
    HandlerStack.push(h)
    return h
end

function M.test_alt_down_walks_sections_then_clamps()
    setup()
    pushButton("Library", function()
        return "Boosts science[NEWLINE]Costs 5 gold"
    end)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Library", "first Alt+Down lands on section one")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Boosts science")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Costs 5 gold")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Costs 5 gold", "Alt+Down past the end re-speaks the last section")
end

function M.test_alt_up_walks_back_then_clamps()
    setup()
    pushButton("Library", function()
        return "Boosts science[NEWLINE]Costs 5 gold"
    end)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN) -- on section 3
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_UP, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Boosts science")
    InputRouter.dispatch(Keys.VK_UP, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Library")
    InputRouter.dispatch(Keys.VK_UP, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Library", "Alt+Up before the first section re-speaks section one")
end

function M.test_alt_up_from_fresh_enters_at_first_section()
    setup()
    pushButton("Library", function()
        return "Boosts science"
    end)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_UP, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Library", "Alt+Up from the fresh state enters at section one, not silence")
end

function M.test_moving_to_new_item_resets_sections()
    setup()
    setCtrls({ "A", "B" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                labelText = "Library",
                tooltipFn = function()
                    return "Boosts science"
                end,
                activate = function() end,
            }),
            BaseMenuItems.Button({
                controlName = "B",
                labelText = "Granary",
                tooltipFn = function()
                    return "Stores food"
                end,
                activate = function() end,
            }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN) -- section 1 of Library
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN) -- section 2 of Library
    InputRouter.dispatch(Keys.VK_DOWN, MOD_NONE, WM_KEYDOWN) -- move cursor to Granary
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Granary", "section cursor resets to the new item's first section")
end

function M.test_single_section_item_clamps_on_repeat()
    setup()
    pushButton("Close", nil) -- no tooltip: one section
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Close")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Close", "single-section item just re-speaks on repeat")
end

-- sectionsFn override -----------------------------------------------------

local function pushButtonWithSpec(spec)
    setCtrls({ "A" })
    spec.controlName = "A"
    spec.activate = spec.activate or function() end
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Button(spec) },
    })
    HandlerStack.push(h)
    return h
end

function M.test_sectionsfn_supplies_sections_verbatim()
    setup()
    -- A label that auto-split would leave as one blob (comma-joined, no
    -- [NEWLINE]); the explicit sectionsFn hands over the discrete pieces.
    pushButtonWithSpec({
        labelText = "Pottery, 10 turns, Cost 60",
        sectionsFn = function()
            return { "Pottery", "10 turns", "Cost 60" }
        end,
    })
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Pottery")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "10 turns")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Cost 60")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Cost 60", "clamps on the last supplied section")
end

function M.test_sectionsfn_error_falls_back_to_auto_split()
    setup()
    pushButtonWithSpec({
        labelText = "Library",
        tooltipFn = function()
            return "Boosts science"
        end,
        sectionsFn = function()
            error("builder blew up")
        end,
    })
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Library", "broken sectionsFn falls back to auto-split section one")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Boosts science", "fallback auto-split still yields the tooltip section")
end

return M

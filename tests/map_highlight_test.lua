-- MapHighlight: the on-screen cursor / scanner rings for sighted companions.
-- Pure engine-fire surface (no speech), so the suite captures the two hex-
-- overlay events and pins what reaches them: the clear-then-set ordering
-- that prevents a leftover ring, the two distinct clear-exempt styles that
-- keep the rings safe from the game's style-scoped clears and independently
-- clearable, the exact ring colors (a wrong color is a silent visual failure
-- for the partner), the toggle gate, and applyEnabled's clear-vs-redraw fork.
-- The flicker-free design hinges on the cursor style being TempBorder and the
-- scanner style being EditorHexStyle1 -- styles BNW never clears -- so the
-- suite asserts those literals to flag any drift onto a cleared style.

local T = require("support")
local M = {}

local CURSOR_STYLE = "TempBorder"
local SCANNER_STYLE = "EditorHexStyle1"

local calls

local function setup()
    calls = {}
    civvaccess_shared = civvaccess_shared or {}
    -- nil so MapHighlight seeds from Prefs (default true) at dofile; tests
    -- that want it off flip the live field after load.
    civvaccess_shared.mapHighlightEnabled = nil

    Prefs = Prefs or {}
    Prefs.getBool = function(_key, default)
        return default
    end
    Prefs.setBool = function(_key, _value) end

    Events = Events or {}
    Events.SerialEventHexHighlight = function(hex, on, color, style)
        calls[#calls + 1] = { op = "highlight", hex = hex, on = on, color = color, style = style }
    end
    Events.ClearHexHighlightStyle = function(style)
        calls[#calls + 1] = { op = "clear", style = style }
    end

    -- Cursor is consulted only by applyEnabled (redraw on toggle-on). Default
    -- to a placed cursor; the nil-position case overrides this.
    Cursor = {
        position = function()
            return 4, 7
        end,
    }

    dofile("src/dlc/UI/InGame/CivVAccess_MapHighlight.lua")
end

local function disable()
    civvaccess_shared.mapHighlightEnabled = false
end

local function firstOf(op)
    for _, c in ipairs(calls) do
        if c.op == op then
            return c
        end
    end
    return nil
end

-- ===== setCursor =====

function M.test_setCursor_clears_then_sets_own_style()
    setup()
    MapHighlight.setCursor(4, 7)
    T.eq(#calls, 2, "setCursor must clear then set, exactly two fires")
    T.eq(calls[1].op, "clear", "clear must come first so no ring lingers on the previous tile")
    T.eq(calls[1].style, CURSOR_STYLE)
    T.eq(calls[2].op, "highlight")
    T.eq(calls[2].style, CURSOR_STYLE)
    T.eq(calls[2].on, true)
    T.eq(calls[2].hex.x, 4, "hex carries the grid x")
    T.eq(calls[2].hex.y, 7, "hex carries the grid y")
end

function M.test_setCursor_uses_cyan()
    setup()
    MapHighlight.setCursor(0, 0)
    local hl = firstOf("highlight")
    T.truthy(hl)
    T.eq(hl.color.x, 0, "cyan red component")
    T.eq(hl.color.y, 1, "cyan green component")
    T.eq(hl.color.z, 1, "cyan blue component")
    T.eq(hl.color.w, 1, "full alpha")
end

function M.test_setCursor_no_op_when_disabled()
    setup()
    disable()
    MapHighlight.setCursor(4, 7)
    T.eq(#calls, 0, "disabled setCursor must not touch the overlay")
end

-- ===== setScanner =====

function M.test_setScanner_clears_then_sets_own_style()
    setup()
    MapHighlight.setScanner(2, 9)
    T.eq(#calls, 2)
    T.eq(calls[1].op, "clear")
    T.eq(calls[1].style, SCANNER_STYLE)
    T.eq(calls[2].op, "highlight")
    T.eq(calls[2].style, SCANNER_STYLE)
    T.eq(calls[2].hex.x, 2)
    T.eq(calls[2].hex.y, 9)
end

function M.test_setScanner_uses_orange()
    setup()
    MapHighlight.setScanner(0, 0)
    local hl = firstOf("highlight")
    T.truthy(hl)
    T.eq(hl.color.x, 1, "orange red component")
    T.eq(hl.color.y, 0.5, "orange green component")
    T.eq(hl.color.z, 0, "orange blue component")
end

function M.test_setScanner_no_op_when_disabled()
    setup()
    disable()
    MapHighlight.setScanner(2, 9)
    T.eq(#calls, 0)
end

-- ===== clears =====

function M.test_clearScanner_touches_only_scanner_style()
    setup()
    MapHighlight.clearScanner()
    T.eq(#calls, 1)
    T.eq(calls[1].op, "clear")
    T.eq(calls[1].style, SCANNER_STYLE)
end

function M.test_clearCursor_touches_only_cursor_style()
    setup()
    MapHighlight.clearCursor()
    T.eq(#calls, 1)
    T.eq(calls[1].op, "clear")
    T.eq(calls[1].style, CURSOR_STYLE)
end

function M.test_clears_ignore_disabled_flag()
    -- clearAll must fire even when disabled: applyEnabled(off) relies on it
    -- to tear the rings down, and gating on the now-false flag would skip
    -- the very clear it needs.
    setup()
    disable()
    MapHighlight.clearAll()
    local cursorCleared, scannerCleared = false, false
    for _, c in ipairs(calls) do
        if c.op == "clear" and c.style == CURSOR_STYLE then
            cursorCleared = true
        elseif c.op == "clear" and c.style == SCANNER_STYLE then
            scannerCleared = true
        end
    end
    T.truthy(cursorCleared, "clearAll must clear the cursor style even when disabled")
    T.truthy(scannerCleared, "clearAll must clear the scanner style even when disabled")
end

-- ===== applyEnabled =====

function M.test_applyEnabled_off_clears_both_no_highlight()
    setup()
    disable()
    MapHighlight.applyEnabled()
    T.eq(firstOf("highlight"), nil, "toggling off must not draw a ring")
    local cleared = 0
    for _, c in ipairs(calls) do
        if c.op == "clear" then
            cleared = cleared + 1
        end
    end
    T.eq(cleared, 2, "toggling off must clear both rings")
end

function M.test_applyEnabled_on_redraws_cursor_at_current_position()
    setup()
    Cursor.position = function()
        return 11, 3
    end
    MapHighlight.applyEnabled()
    local hl = firstOf("highlight")
    T.truthy(hl, "toggling on must redraw the cursor ring immediately")
    T.eq(hl.style, CURSOR_STYLE)
    T.eq(hl.hex.x, 11)
    T.eq(hl.hex.y, 3)
end

function M.test_applyEnabled_on_no_cursor_yet_draws_nothing()
    -- Pre-Cursor.init: position is (nil, nil). applyEnabled must not try to
    -- ring a nil tile; the first cursor move will draw it once placed.
    setup()
    Cursor.position = function()
        return nil, nil
    end
    MapHighlight.applyEnabled()
    T.eq(firstOf("highlight"), nil, "no ring before the cursor is placed")
end

return M

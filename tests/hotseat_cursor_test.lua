-- HotseatCursor tests. Engine seams stubbed: Game.IsHotSeat /
-- GetGameTurn, Players[i] (per-player IsHuman / Units / GetCapitalCity),
-- Map.GetPlot (saved-position lookup), Cursor.position / Cursor.jumpTo
-- (capturing stubs). Events.GameplaySetActivePlayer captures the
-- registered listener so tests can fire synthetic transitions.

local T = require("support")
local M = {}

local activePlayerListeners
local jumpCalls
local cursorPos
local hotseat
local gameTurn

local function fireActivePlayerChanged(iActive, iPrev)
    for _, fn in ipairs(activePlayerListeners) do
        fn(iActive, iPrev)
    end
end

local function makePlot(x, y)
    return {
        GetX = function()
            return x
        end,
        GetY = function()
            return y
        end,
    }
end

local function makeUnit(x, y, isFound)
    local plot = makePlot(x, y)
    return {
        IsFound = function()
            return isFound
        end,
        GetPlot = function()
            return plot
        end,
    }
end

-- units: list of unit specs; capitalAt: { x, y } or nil.
local function makePlayer(opts)
    opts = opts or {}
    local units = opts.units or {}
    local capital = nil
    if opts.capitalAt ~= nil then
        local plot = makePlot(opts.capitalAt[1], opts.capitalAt[2])
        capital = { Plot = function() return plot end }
    end
    return {
        IsHuman = function()
            return opts.human ~= false
        end,
        Units = function()
            local i = 0
            return function()
                i = i + 1
                return units[i]
            end
        end,
        GetCapitalCity = function()
            return capital
        end,
    }
end

local function setup()
    dofile("src/dlc/UI/InGame/CivVAccess_HotseatCursorRestore.lua")

    HotseatCursor._reset()

    hotseat = true
    gameTurn = 5
    Game.IsHotSeat = function()
        return hotseat
    end
    Game.GetGameTurn = function()
        return gameTurn
    end

    activePlayerListeners = {}
    Events.GameplaySetActivePlayer = {
        Add = function(fn)
            activePlayerListeners[#activePlayerListeners + 1] = fn
        end,
    }

    cursorPos = { x = 7, y = 7 }
    jumpCalls = {}
    Cursor = {
        position = function()
            return cursorPos.x, cursorPos.y
        end,
        jumpTo = function(x, y)
            jumpCalls[#jumpCalls + 1] = { x = x, y = y }
            cursorPos = { x = x, y = y }
            return ""
        end,
    }

    Players = {}
    Map.GetPlot = function(x, y)
        return makePlot(x, y)
    end

    HotseatCursor.installListeners()
end

-- Hotseat gate ------------------------------------------------------------

function M.test_no_listener_registered_outside_hotseat()
    -- The install-time gate must skip Add when the session isn't hotseat,
    -- so a single-player or networked-MP game pays nothing for the module.
    setup()
    -- Reset and re-install with hotseat off.
    HotseatCursor._reset()
    activePlayerListeners = {}
    hotseat = false
    HotseatCursor.installListeners()
    T.eq(#activePlayerListeners, 0, "non-hotseat install must not register a listener")
end

function M.test_handler_inert_if_hotseat_flips_off_after_install()
    -- Defensive: if Game.IsHotSeat were ever to flip post-install (engine
    -- doesn't do this, but the runtime gate is the second line of defense),
    -- the handler must do nothing.
    setup()
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    Players[1] = makePlayer({ capitalAt = { 20, 20 } })
    hotseat = false
    fireActivePlayerChanged(1, 0)
    T.eq(#jumpCalls, 0)
end

-- Save on handoff ---------------------------------------------------------

function M.test_human_prior_player_cursor_saved()
    setup()
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    Players[1] = makePlayer({ capitalAt = { 20, 20 } })
    cursorPos = { x = 33, y = 44 }
    fireActivePlayerChanged(1, 0)
    -- Simulate the round trip: AI turns happen, then back to player 0.
    -- Restore must use the position we saved when 0 handed off.
    cursorPos = { x = 99, y = 99 } -- whatever player 1 had at their end
    fireActivePlayerChanged(0, 1)
    -- The most recent jumpTo is the restore for player 0.
    local last = jumpCalls[#jumpCalls]
    T.eq(last.x, 33, "restore uses player 0's saved x")
    T.eq(last.y, 44, "restore uses player 0's saved y")
end

function M.test_ai_prior_player_cursor_not_saved()
    -- Prior is AI: skip save. The next time that AI becomes active again,
    -- the restore branch sees no saved entry and (correctly) falls back to
    -- whatever target rules the player has. AIs don't get cursor restore
    -- (handled by the IsHuman gate inside targetForPlayer), but the save
    -- branch is what we're testing here.
    setup()
    Players[0] = makePlayer({ human = false })
    Players[1] = makePlayer({ capitalAt = { 20, 20 } })
    cursorPos = { x = 33, y = 44 }
    fireActivePlayerChanged(1, 0) -- AI 0 -> human 1
    T.eq(#jumpCalls, 1, "restore fires for human 1")
    T.eq(jumpCalls[1].x, 20, "human 1 restore -- no saved -> capital fallback")
    T.eq(jumpCalls[1].y, 20)
    -- Confirm: cycling back to human 0 (now hypothetically human-converted)
    -- would NOT find a saved value, since we never saved when AI was prior.
    Players[0] = makePlayer({ capitalAt = { 10, 10 }, human = true })
    cursorPos = { x = 7, y = 7 }
    fireActivePlayerChanged(0, 1)
    -- saved[0] doesn't exist. Capital fallback = (10, 10).
    local last = jumpCalls[#jumpCalls]
    T.eq(last.x, 10)
    T.eq(last.y, 10)
end

-- Restore branches: turn 0 / saved / capital ------------------------------

function M.test_turn_zero_restores_to_settler_even_if_saved()
    -- Spec: turn 0 always seeds to settler, ignoring any saved position.
    -- Saved should only matter from turn 1 onward.
    setup()
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    Players[1] = makePlayer({
        units = { makeUnit(50, 60, true) },
        capitalAt = { 20, 20 },
    })
    cursorPos = { x = 33, y = 44 }
    -- Start on a non-zero turn so a saved value gets recorded for player 1.
    gameTurn = 5
    fireActivePlayerChanged(1, 0) -- saves 0 at (33,44), restores 1 (turn 5)
    cursorPos = { x = 70, y = 80 }
    fireActivePlayerChanged(0, 1) -- saves 1 at (70,80)
    -- Now flip to turn 0 and switch back to player 1. The saved entry
    -- exists, but settler must win.
    gameTurn = 0
    fireActivePlayerChanged(1, 0)
    local last = jumpCalls[#jumpCalls]
    T.eq(last.x, 50, "turn 0 restore goes to settler x, not saved x")
    T.eq(last.y, 60, "turn 0 restore goes to settler y, not saved y")
end

function M.test_turn_zero_falls_back_to_capital_if_no_settler()
    -- Pathological: turn 0 with no settler unit. The settler-lookup falls
    -- through to saved (none) and then capital. This branch shouldn't
    -- happen in normal play (every civ starts with a settler) but the
    -- fallback chain has to be order-preserved.
    setup()
    gameTurn = 0
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    Players[1] = makePlayer({
        units = {}, -- no settler
        capitalAt = { 20, 20 },
    })
    fireActivePlayerChanged(1, 0)
    T.eq(jumpCalls[1].x, 20, "no settler at turn 0 -> capital")
    T.eq(jumpCalls[1].y, 20)
end

function M.test_saved_position_used_after_turn_zero()
    setup()
    gameTurn = 3
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    Players[1] = makePlayer({ capitalAt = { 20, 20 } })
    -- Round trip: 0 -> 1 -> 0. The second transition must restore from
    -- the saved entry, NOT capital.
    cursorPos = { x = 33, y = 44 }
    fireActivePlayerChanged(1, 0)
    cursorPos = { x = 70, y = 80 }
    fireActivePlayerChanged(0, 1) -- saves 1 at (70,80), restores 0 at saved (33,44)
    local last = jumpCalls[#jumpCalls]
    T.eq(last.x, 33)
    T.eq(last.y, 44)
end

function M.test_capital_fallback_when_no_saved()
    -- Session-start scenario: a fresh load of a hotseat save, the saved
    -- table is empty. The first transition to a player with no saved
    -- entry uses capital.
    setup()
    gameTurn = 50 -- well past turn 0
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    Players[1] = makePlayer({ capitalAt = { 99, 88 } })
    -- AI turn was prior; nothing got saved for player 1. First time we
    -- arrive at 1 in this session, fall back to capital.
    Players[2] = makePlayer({ human = false })
    fireActivePlayerChanged(1, 2)
    T.eq(jumpCalls[1].x, 99)
    T.eq(jumpCalls[1].y, 88)
end

function M.test_no_op_when_target_player_has_no_capital_and_no_saved()
    -- Player with no capital city (razed last city, somehow reached human-
    -- active again) and no saved entry: handler returns without calling
    -- jumpTo. Cursor stays where it was; better than crashing on a nil
    -- plot lookup.
    setup()
    gameTurn = 50
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    Players[1] = makePlayer({ capitalAt = nil })
    fireActivePlayerChanged(1, 0)
    T.eq(#jumpCalls, 0, "no target -> no jump")
end

-- AI active -- restore branch -----------------------------------------------

function M.test_no_restore_when_active_player_is_ai()
    setup()
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    Players[1] = makePlayer({ human = false })
    fireActivePlayerChanged(1, 0)
    -- 0 (human) handed off to 1 (AI). 0's cursor is saved, but no restore
    -- happens for 1.
    T.eq(#jumpCalls, 0)
end

-- Edge cases on event args --------------------------------------------------

function M.test_negative_prev_player_skips_save()
    -- Engine could fire with iPrev = -1 at session boundaries. Guard
    -- against indexing Players[-1] or saving a bogus key.
    setup()
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    -- Even with cursorPos set, iPrev = -1 must not try to save.
    cursorPos = { x = 33, y = 44 }
    fireActivePlayerChanged(0, -1)
    -- Restore for player 0 still happens (turn != 0 here, no saved -> capital).
    T.eq(jumpCalls[1].x, 10)
    T.eq(jumpCalls[1].y, 10)
end

function M.test_negative_active_player_skips_restore()
    setup()
    Players[0] = makePlayer({ capitalAt = { 10, 10 } })
    cursorPos = { x = 33, y = 44 }
    fireActivePlayerChanged(-1, 0)
    -- Save for 0 happened (it's human). No restore.
    T.eq(#jumpCalls, 0)
    -- Confirm save by cycling forward.
    Players[1] = makePlayer({ capitalAt = { 20, 20 } })
    fireActivePlayerChanged(0, 1)
    -- Now restoring 0: saved exists at (33, 44).
    local last = jumpCalls[#jumpCalls]
    T.eq(last.x, 33)
    T.eq(last.y, 44)
end

return M

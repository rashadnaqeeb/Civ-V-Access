-- CombatLog: per-AI-turn capture of combat-readout text. Tests exercise
-- the AI-turn gate (only records between TurnEnd and the next TurnStart),
-- the reset-on-TurnEnd contract, and the survives-across-the-player-turn
-- behavior the F7 popup depends on.

local T = require("support")
local M = {}

local activePlayerListeners

local function setup()
    civvaccess_shared = {}
    activePlayerListeners = {}
    Events = {
        ActivePlayerTurnEnd = { Add = function(_) end },
        ActivePlayerTurnStart = { Add = function(_) end },
        GameplaySetActivePlayer = {
            Add = function(fn)
                activePlayerListeners[#activePlayerListeners + 1] = fn
            end,
        },
    }
    Game = Game or {}
    Game.IsHotSeat = function()
        return false
    end
    CombatLog = nil
    dofile("src/dlc/UI/InGame/CivVAccess_CombatLog.lua")
    CombatLog.installListeners()
end

-- During the player's own turn (boot priming flips _inAiTurn false),
-- a recordCombat call is a no-op: combats the player initiated speak in
-- real time and don't belong on the per-AI-turn log.
function M.test_player_turn_records_nothing()
    setup()
    CombatLog.recordCombat("Roman Warrior hit Greek Spearman")
    T.eq(civvaccess_shared.combatLog, nil, "no list created during player turn")
end

-- After ActivePlayerTurnEnd fires, the AI-turn window is open and combat
-- text accumulates onto civvaccess_shared.combatLog in call order.
function M.test_ai_turn_collects_combats_in_order()
    setup()
    CombatLog._onTurnEnd()
    CombatLog.recordCombat("first combat", 3, 4)
    CombatLog.recordCombat("second combat", 5, 6)
    CombatLog.recordCombat("third combat")
    local list = civvaccess_shared.combatLog
    T.eq(type(list), "table", "list created on first record")
    T.eq(#list, 3, "all three combats logged")
    T.eq(list[1].text, "first combat")
    T.eq(list[1].x, 3, "combat plot x retained for the jump")
    T.eq(list[1].y, 4, "combat plot y retained for the jump")
    T.eq(list[2].text, "second combat")
    -- Plotless combats (e.g. an air sweep that found no interceptor) still
    -- log their text; the popup renders those as plain text, no jump.
    T.eq(list[3].text, "third combat")
    T.eq(list[3].x, nil, "plotless combat has no jump coords")
end

-- The list must persist through the player's next turn so F7 can show it.
-- Only the *next* TurnEnd resets it (re-opening the window for the new
-- AI turn).
function M.test_list_survives_player_turn_until_next_turn_end()
    setup()
    CombatLog._onTurnEnd()
    CombatLog.recordCombat("ai combat")
    CombatLog._onTurnStart()
    -- Player turn now in progress. List still readable for F7.
    T.eq(#civvaccess_shared.combatLog, 1, "list intact through player turn")
    -- Player initiates an attack: the speech path calls recordCombat but
    -- the gate rejects (window closed). List stays the same.
    CombatLog.recordCombat("player-initiated combat")
    T.eq(#civvaccess_shared.combatLog, 1, "player-turn combat does not append")
    T.eq(civvaccess_shared.combatLog[1].text, "ai combat", "list contents unchanged")
    -- Player ends turn. The new AI turn window opens; prior list cleared.
    CombatLog._onTurnEnd()
    T.eq(civvaccess_shared.combatLog, nil, "list cleared at next TurnEnd")
end

-- Reinstalling listeners (load-game-from-game) clears prior shared state
-- and resets the AI-turn flag. A combat recorded after reinstall but
-- before the next TurnEnd is dropped (window is closed at install).
function M.test_reinstall_resets_state()
    setup()
    CombatLog._onTurnEnd()
    CombatLog.recordCombat("game1 combat")
    -- Simulate load-game-from-game: civvaccess_shared survives, but the
    -- new Boot calls installListeners, which clears it and re-arms.
    CombatLog.installListeners()
    T.eq(civvaccess_shared.combatLog, nil, "shared list cleared on install")
    CombatLog.recordCombat("would-be combat")
    T.eq(civvaccess_shared.combatLog, nil, "window closed after install until TurnEnd")
end

-- Hotseat path -----------------------------------------------------------

-- In a non-hotseat session, the GameplaySetActivePlayer listener is not
-- registered. Single-human-many-AI games run as hotseat at the engine
-- level too, but this branch covers SP / networked MP.
function M.test_no_active_player_listener_outside_hotseat()
    setup()
    T.eq(#activePlayerListeners, 0, "non-hotseat install must not register a player-change listener")
end

-- In a hotseat session, GameplaySetActivePlayer fires only on actual
-- active-player change (CvGame.cpp:5584). Engine-side, AI combats during
-- the AI batch were scoped to the prior human's visibility, so the
-- accumulated log is from THEIR view -- the next human never had those
-- events fired for their team. Drop the log on the swap so it doesn't
-- bleed across players.
function M.test_hotseat_active_player_change_clears_log()
    setup()
    Game.IsHotSeat = function()
        return true
    end
    CombatLog.installListeners()
    T.eq(#activePlayerListeners, 1, "hotseat install must register the player-change listener")
    -- Simulate the AI window populating the log.
    CombatLog._onTurnEnd()
    CombatLog.recordCombat("ai-window combat")
    T.eq(#civvaccess_shared.combatLog, 1)
    -- Active player change: the log goes away.
    activePlayerListeners[1](1, 0)
    T.eq(civvaccess_shared.combatLog, nil, "active-player change clears the AI-window log in hotseat")
end

return M

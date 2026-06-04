-- CombatLog: rolling capture of combat-readout text for the F7 Turn Log.
-- Tests exercise the always-record contract (combat on your own turn lands
-- too, not just AI-turn combat), the clear-on-TurnEnd lifecycle, and the
-- hotseat active-player-change clear.

local T = require("support")
local M = {}

local activePlayerListeners

local function setup()
    civvaccess_shared = {}
    activePlayerListeners = {}
    Events = {
        ActivePlayerTurnEnd = { Add = function(_) end },
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

-- The core record path: combats accumulate in call order with their plot
-- coords retained, and crucially they record with no prior TurnEnd -- i.e.
-- combat the player causes on their own turn lands on the log, which is the
-- whole point of the rolling log (a gate here used to drop those).
function M.test_records_combat_in_order_during_own_turn()
    setup()
    CombatLog.recordCombat("first combat", 3, 4)
    CombatLog.recordCombat("second combat", 5, 6)
    CombatLog.recordCombat("third combat")
    local list = civvaccess_shared.combatLog
    T.eq(type(list), "table", "list created on first record, no TurnEnd needed")
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

-- Lifecycle: a combat recorded during the AI turn survives into the player's
-- next turn (only TurnEnd clears), the player's own-turn combat appends on
-- top, and the following TurnEnd clears the whole window for a fresh start.
function M.test_accumulates_across_turn_boundary_until_turn_end()
    setup()
    -- AI turn (after the player ended their turn) records a combat.
    CombatLog._onTurnEnd()
    CombatLog.recordCombat("ai combat")
    -- Player's next turn is now in progress; the list is still readable for F7
    -- (nothing clears it at turn start) and the player's own combat appends.
    T.eq(#civvaccess_shared.combatLog, 1, "AI combat intact through to the player's turn")
    CombatLog.recordCombat("player combat")
    T.eq(#civvaccess_shared.combatLog, 2, "player-turn combat appends, not dropped")
    T.eq(civvaccess_shared.combatLog[2].text, "player combat")
    -- Player ends turn: the window clears for the next cycle.
    CombatLog._onTurnEnd()
    T.eq(civvaccess_shared.combatLog, nil, "list cleared at TurnEnd")
end

-- Reinstalling listeners (load-game-from-game) clears prior shared state,
-- then recording resumes immediately -- no window to wait for.
function M.test_reinstall_clears_then_records()
    setup()
    CombatLog.recordCombat("game1 combat")
    -- Simulate load-game-from-game: civvaccess_shared survives, but the new
    -- Boot calls installListeners, which clears it and re-arms.
    CombatLog.installListeners()
    T.eq(civvaccess_shared.combatLog, nil, "shared list cleared on install")
    CombatLog.recordCombat("game2 combat")
    T.eq(#civvaccess_shared.combatLog, 1, "records immediately after reinstall")
    T.eq(civvaccess_shared.combatLog[1].text, "game2 combat")
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
    CombatLog.recordCombat("prior-human combat")
    T.eq(#civvaccess_shared.combatLog, 1)
    -- Active player change: the log goes away.
    activePlayerListeners[1](1, 0)
    T.eq(civvaccess_shared.combatLog, nil, "active-player change clears the log in hotseat")
end

return M

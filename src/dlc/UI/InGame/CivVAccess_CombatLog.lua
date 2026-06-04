-- Rolling combat log for the F7 Turn Log. Captures the spoken combat-
-- readout text for every combat resolved in the active player's view --
-- both combats the player initiates on their own turn and combats that
-- resolve while they wait on the AI -- and parks the array on
-- civvaccess_shared so NotificationLogPopupAccess can list each one under
-- the Turn Log tab's Combat Log group, each entry jumping to the combat's
-- tile.
--
-- Lifecycle. The list is cleared at ActivePlayerTurnEnd and accumulates
-- from then through the AI turn and into the player's next turn, until the
-- following TurnEnd clears it again. So at any point during your turn the
-- group shows the combat you waited through plus whatever combat you've
-- caused so far this turn; ending your turn starts a fresh window. The
-- list lives on civvaccess_shared because the F7 popup Context reads it
-- across the Context boundary.
--
-- Hotseat. AI turns process while the active player is whoever just ended
-- (CvPlayer.cpp:15812 only calls setActivePlayer inside setTurnActive for
-- humans, so AI setTurnActive runs doTurn / doTurnUnits without changing
-- the active player). Combat events during the AI batch are scoped to that
-- human's team via setVisualizeCombat / isActiveVisible, so the log
-- accumulates from their visibility -- not the visibility of the next
-- human about to take over. To avoid leaking AI-window combats from the
-- prior human's view to the next, the hotseat path also clears the log on
-- Events.GameplaySetActivePlayer (which fires only on actual active-player
-- change at CvGame.cpp:5584). A single human against many AIs has no
-- GameplaySetActivePlayer firing between rounds, so their log is preserved
-- across the AI batch as in single-player.

CombatLog = {}

-- x / y are the combat's target plot (nil for the rare plotless combat
-- strings, e.g. an air sweep that found no interceptor). The F7 popup turns
-- entries with a plot into jump targets and renders the rest as plain text.
function CombatLog.recordCombat(text, x, y)
    local list = civvaccess_shared.combatLog
    if list == nil then
        list = {}
        civvaccess_shared.combatLog = list
    end
    list[#list + 1] = { text = text, x = x, y = y }
end

function CombatLog._onTurnEnd()
    civvaccess_shared.combatLog = nil
end

function CombatLog._onActivePlayerChanged()
    civvaccess_shared.combatLog = nil
end

-- Registers fresh listeners on every call. See CivVAccess_Boot.lua's
-- LoadScreenClose registration for the rationale: prior-Context listener
-- closures die on load-game-from-game.
function CombatLog.installListeners()
    civvaccess_shared.combatLog = nil
    Log.installEvent(Events, "ActivePlayerTurnEnd", CombatLog._onTurnEnd, "CombatLog")
    if Game.IsHotSeat() then
        Log.installEvent(
            Events,
            "GameplaySetActivePlayer",
            CombatLog._onActivePlayerChanged,
            "CombatLog",
            "in hotseat session"
        )
    end
end

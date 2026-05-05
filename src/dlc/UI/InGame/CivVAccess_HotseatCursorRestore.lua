-- Hotseat-only per-player cursor save / restore. In a hotseat session,
-- save each human player's cursor at end-of-turn and restore it when
-- their next turn begins. Turn 0 seeds to the player's settler instead
-- of using a saved position so each player starts looking at their own
-- founder. Without a saved position (e.g. session start from a loaded
-- save), falls back to the player's capital city.
--
-- Per-session, in-memory only. Saved (x, y) on a different map are the
-- wrong cells, so a load-from-game wipes the table; the capital fallback
-- is the explicit recovery for that case. installListeners runs from
-- onInGameBoot at LoadScreenClose, which is the load-from-game seam.
--
-- Hooked to Events.GameplaySetActivePlayer. The event fires before the
-- PlayerChange password popup appears, with both the new and previous
-- active player IDs as args, so the prior player's cursor save and the
-- new player's restore happen in one event handler. Restoration is
-- silent: Cursor.jumpTo composes a glance string but never speaks; the
-- caller (us) discards it. PlotAudio cues still emit if the user has
-- them enabled, which is the normal cursor-move behavior.

HotseatCursor = {}

local saved = {}

local function findSettler(player)
    for unit in player:Units() do
        if unit ~= nil and unit:IsFound() then
            return unit:GetPlot()
        end
    end
    return nil
end

local function targetForPlayer(ePlayer)
    local player = Players[ePlayer]
    if not player:IsHuman() then
        return nil
    end
    if Game.GetGameTurn() == 0 then
        local plot = findSettler(player)
        if plot ~= nil then
            return plot
        end
    end
    local pos = saved[ePlayer]
    if pos ~= nil then
        return Map.GetPlot(pos.x, pos.y)
    end
    local capital = player:GetCapitalCity()
    if capital ~= nil then
        return capital:Plot()
    end
    return nil
end

function HotseatCursor._onActivePlayerChanged(iActive, iPrev)
    if not Game.IsHotSeat() then
        return
    end
    if iPrev ~= nil and iPrev >= 0 then
        local priorPlayer = Players[iPrev]
        if priorPlayer ~= nil and priorPlayer:IsHuman() then
            local x, y = Cursor.position()
            if x ~= nil then
                saved[iPrev] = { x = x, y = y }
            end
        end
    end
    if iActive == nil or iActive < 0 then
        return
    end
    local plot = targetForPlayer(iActive)
    if plot == nil then
        return
    end
    Cursor.jumpTo(plot:GetX(), plot:GetY())
end

function HotseatCursor.installListeners()
    saved = {}
    if not Game.IsHotSeat() then
        Log.info("HotseatCursor: not a hotseat session, skipping listener registration")
        return
    end
    if
        Log.installEvent(
            Events,
            "GameplaySetActivePlayer",
            HotseatCursor._onActivePlayerChanged,
            "HotseatCursor",
            "cursor restore disabled"
        )
    then
        Log.info("HotseatCursor: installed")
    end
end

function HotseatCursor._reset()
    saved = {}
end

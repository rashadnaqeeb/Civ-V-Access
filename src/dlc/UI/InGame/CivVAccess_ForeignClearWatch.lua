-- Speaks one line at the start of every player turn covering goody huts
-- (ancient ruins) and barbarian camps that some other civ cleared on a
-- plot the active team could see during the AI turn just past. Camps and
-- ruins are tallied separately and joined with the AND key when both are
-- non-zero. The same line lands in civvaccess_shared.foreignClearDelta
-- (a single-element array, mirroring foreignUnitDelta's shape so the F7
-- consumer can iterate uniformly) and in MessageBuffer under the reveal
-- category. Single-player and MP behave identically; the engine fork hooks
-- this watcher subscribes to fire in both modes.
--
-- Strategy is event-driven counters scoped to the AI turn window. The fork
-- hooks (CivVAccessForeignBarbCampCleared, CivVAccessForeignGoodyCleared)
-- fire during the AI turn whenever a non-active player clears one of these
-- improvements. We tick a counter for each event whose plot is currently
-- visible to the active team and whose actor isn't a teammate. At
-- TurnStart the counters drive the announcement string and reset to zero
-- via the TurnEnd handler that fires next.
--
-- Visibility filter mirrors the sighted-player rule: only clears on plots
-- in the active team's current line of sight count. A plot you've revealed
-- but is fogged when the clear happens does not contribute -- a sighted
-- player wouldn't see the camp / ruin disappear in fog either, so a screen-
-- reader user shouldn't get a phantom announcement for it.
--
-- Teammate filter: same-team actors are skipped. A teammate sharing vision
-- with you clearing a camp is conceptually the same event as you clearing
-- it; reusing the unit-control combat / pickup announcements keeps the
-- semantics consistent without double-narration.
--
-- Counts-only by design. Naming the actor would either expose info a
-- sighted player wouldn't have at the moment of clearing (the camp /
-- ruin just vanishes; nothing labels who did it) or would require a
-- per-event narration that floods turn-start in the late game. The plan
-- doc has the full rationale; in short, count is the maximum information
-- a sighted player would extract by inspection.

ForeignClearWatch = {}

-- Module-local counters reset every TurnEnd. Hooks tick these up during
-- the AI turn; TurnStart flushes them into one summary line.
local _camps = 0
local _ruins = 0

local function isCountableClear(actorID, iX, iY)
    local actor = Players[actorID]
    if actor == nil then
        return false
    end
    local activeTeam = Game.GetActiveTeam()
    if actor:GetTeam() == activeTeam then
        return false
    end
    local plot = Map.GetPlot(iX, iY)
    if plot == nil then
        return false
    end
    return plot:IsVisible(activeTeam, false)
end

function ForeignClearWatch._onForeignBarbCampCleared(actorID, iX, iY)
    local ok, err = pcall(function()
        if isCountableClear(actorID, iX, iY) then
            _camps = _camps + 1
        end
    end)
    if not ok then
        Log.error("ForeignClearWatch: barb-camp hook failed: " .. tostring(err))
    end
end

function ForeignClearWatch._onForeignGoodyCleared(actorID, iX, iY)
    local ok, err = pcall(function()
        if isCountableClear(actorID, iX, iY) then
            _ruins = _ruins + 1
        end
    end)
    if not ok then
        Log.error("ForeignClearWatch: goody-hut hook failed: " .. tostring(err))
    end
end

function ForeignClearWatch._onTurnEnd()
    local ok, err = pcall(function()
        _camps = 0
        _ruins = 0
        civvaccess_shared.foreignClearDelta = nil
    end)
    if not ok then
        Log.error("ForeignClearWatch: TurnEnd reset failed: " .. tostring(err))
    end
end

function ForeignClearWatch._onTurnStart()
    local ok, err = pcall(function()
        if _camps == 0 and _ruins == 0 then
            civvaccess_shared.foreignClearDelta = nil
            return
        end
        local parts = {}
        if _camps > 0 then
            parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART", _camps, _camps)
        end
        if _ruins > 0 then
            parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART", _ruins, _ruins)
        end
        local body = table.concat(parts, Text.key("TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"))
        local line = Text.key("TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX")
            .. body
            .. Text.key("TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX")
        civvaccess_shared.foreignClearDelta = { line }
        -- Speech is gated by the foreignClearAnnounce setting; the F7
        -- Turn Log entry above lands either way so the user can review
        -- the clears manually when speech is off. Queued (not interrupt)
        -- to share the turn-boundary lane with NotificationAnnounce,
        -- RevealAnnounce, and ForeignUnitWatch -- interrupting here
        -- would cut whichever of those is currently speaking.
        if civvaccess_shared.foreignClearAnnounce then
            SpeechPipeline.speakQueued(line)
        end
        MessageBuffer.append(line, "reveal")
    end)
    if not ok then
        Log.error("ForeignClearWatch: TurnStart flush failed: " .. tostring(err))
    end
end

-- Registers fresh listeners on every call. Same rationale as
-- ForeignUnitWatch: load-game-from-game kills prior-Context closures, so
-- an install-once guard would lock the watcher to a stranded listener.
function ForeignClearWatch.installListeners()
    _camps = 0
    _ruins = 0
    civvaccess_shared.foreignClearDelta = nil
    if Events ~= nil and Events.ActivePlayerTurnEnd ~= nil then
        Events.ActivePlayerTurnEnd.Add(ForeignClearWatch._onTurnEnd)
    else
        Log.warn("ForeignClearWatch: Events.ActivePlayerTurnEnd missing")
    end
    if Events ~= nil and Events.ActivePlayerTurnStart ~= nil then
        Events.ActivePlayerTurnStart.Add(ForeignClearWatch._onTurnStart)
    else
        Log.warn("ForeignClearWatch: Events.ActivePlayerTurnStart missing")
    end
    if GameEvents ~= nil and GameEvents.CivVAccessForeignBarbCampCleared ~= nil then
        GameEvents.CivVAccessForeignBarbCampCleared.Add(ForeignClearWatch._onForeignBarbCampCleared)
    else
        Log.warn(
            "ForeignClearWatch: GameEvents.CivVAccessForeignBarbCampCleared missing; foreign barb-camp announces disabled (engine fork not deployed?)"
        )
    end
    if GameEvents ~= nil and GameEvents.CivVAccessForeignGoodyCleared ~= nil then
        GameEvents.CivVAccessForeignGoodyCleared.Add(ForeignClearWatch._onForeignGoodyCleared)
    else
        Log.warn(
            "ForeignClearWatch: GameEvents.CivVAccessForeignGoodyCleared missing; foreign goody-hut announces disabled (engine fork not deployed?)"
        )
    end
end

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

-- Module-local counters reset every TurnEnd. Hooks tick the matching
-- entry up during the AI turn; TurnStart flushes them into one summary
-- line. Keyed table rather than two scalars so the per-category bump
-- collapses into a single dispatcher.
local _counts = { camps = 0, ruins = 0 }

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

local function bumpClear(category, actorID, iX, iY)
    local ok, err = pcall(function()
        if isCountableClear(actorID, iX, iY) then
            _counts[category] = _counts[category] + 1
        end
    end)
    if not ok then
        Log.error("ForeignClearWatch: " .. category .. " hook failed: " .. tostring(err))
    end
end

function ForeignClearWatch._onForeignBarbCampCleared(actorID, iX, iY)
    bumpClear("camps", actorID, iX, iY)
end

function ForeignClearWatch._onForeignGoodyCleared(actorID, iX, iY)
    bumpClear("ruins", actorID, iX, iY)
end

function ForeignClearWatch._onTurnEnd()
    local ok, err = pcall(function()
        _counts.camps = 0
        _counts.ruins = 0
        civvaccess_shared.foreignClearDelta = nil
    end)
    if not ok then
        Log.error("ForeignClearWatch: TurnEnd reset failed: " .. tostring(err))
    end
end

function ForeignClearWatch._onTurnStart()
    local ok, err = pcall(function()
        if _counts.camps == 0 and _counts.ruins == 0 then
            civvaccess_shared.foreignClearDelta = nil
            return
        end
        local parts = {}
        if _counts.camps > 0 then
            parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART", _counts.camps, _counts.camps)
        end
        if _counts.ruins > 0 then
            parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART", _counts.ruins, _counts.ruins)
        end
        local body = table.concat(parts, Text.key("TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"))
        local line = Text.key("TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX")
            .. body
            .. Text.key("TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX")
        civvaccess_shared.foreignClearDelta = { line }
        -- Speech is gated by the foreignClearWatchAnnounce setting; the
        -- F7 Turn Log entry above lands either way so the user can
        -- review the clears manually when speech is off. Queued (not
        -- interrupt) to share the turn-boundary lane with Notification-
        -- Announce, RevealAnnounce, and ForeignUnitWatch -- interrupting
        -- here would cut whichever of those is currently speaking.
        if civvaccess_shared.foreignClearWatchAnnounce then
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
    _counts.camps = 0
    _counts.ruins = 0
    civvaccess_shared.foreignClearDelta = nil
    Log.installEvent(Events, "ActivePlayerTurnEnd", ForeignClearWatch._onTurnEnd, "ForeignClearWatch")
    Log.installEvent(Events, "ActivePlayerTurnStart", ForeignClearWatch._onTurnStart, "ForeignClearWatch")
    Log.installEvent(GameEvents, "CivVAccessForeignBarbCampCleared",
        ForeignClearWatch._onForeignBarbCampCleared, "ForeignClearWatch",
        "foreign barb-camp announces disabled (engine fork not deployed?)")
    Log.installEvent(GameEvents, "CivVAccessForeignGoodyCleared",
        ForeignClearWatch._onForeignGoodyCleared, "ForeignClearWatch",
        "foreign goody-hut announces disabled (engine fork not deployed?)")
end

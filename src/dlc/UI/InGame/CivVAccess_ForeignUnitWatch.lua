-- Speaks up to four lines at the start of every player turn covering
-- foreign units that entered or walked out of the active team's view
-- during the AI turn just past. Splits hostile (at-war + barb) from
-- neutral (every foreign owner you can see who isn't at war with you,
-- civilians included). The same lines (as a flat array of non-empty
-- strings) are parked on civvaccess_shared so NotificationLogPopupAccess
-- can prepend them at the top of F7 for the duration of the player's
-- turn.
--
-- Strategy is snapshot-diff at turn boundaries. A unit walks-into-view
-- and back-out within the same AI turn nets to nothing in the diff and
-- produces no announcement, which is the desired behaviour for screen-
-- reader users (transient appearances aren't actionable). Single-
-- player only by design: simultaneous-turn multiplayer has no clean
-- turn boundary to anchor the snapshot pair to.
--
-- War declared during the AI turn. A unit that was in your view as
-- neutral at end of turn and is still in your view at the next turn-
-- start, but whose owner is now at war with you, is included in the
-- hostile-entered list. The bucket transition is the announce signal:
-- the engine fires its own war-declared notification, but doesn't say
-- "and they have units in your face." Without this synthesized entry
-- the unit silently changes bucket without a word to the user. Peace
-- the other way (hostile to neutral mid-turn) isn't synthesized: the
-- engine's peace notification covers it and "now neutral in view"
-- isn't actionable.
--
-- Destroyed and captured units are excluded from both directions. A
-- unit in the prior snapshot but not in the current visible set is
-- "left" only if Players[i]:GetUnitByID(id) still resolves -- the unit
-- is alive under its original owner and has walked into fog. If the
-- engine no longer has it under that owner, it's been destroyed or
-- captured, and we drop it: the combat readout already speaks kills
-- the active player participated in, and there's no clean engine-side
-- signal to distinguish capture from death without an event listener
-- (which we deliberately don't have here -- snapshot-diff is the whole
-- design). A captured civilian that's still in the same plot under the
-- new owner does show up in the entered list under the new owner's
-- bucket on the next turn, so the user isn't completely blind to the
-- transition; they just don't hear an explicit "left" line for the
-- old-owner instance.
--
-- Bucket is locked at snapshot time per side. For the entered list
-- (and the war-reclassified entries) we bucket against current world
-- state at announce time. For left we use the bucket cached on the
-- snapshot entry. A unit you last saw as neutral that walks into fog
-- after a war declaration still announces as a neutral departure: we
-- describe what you saw, not retcon the bucket. The engine's own war-
-- declared notification covers the war event itself.
--
-- Game-load priming. The snapshot is module-local state and dies on
-- env reload (load-game-from-game or fresh-process load). install-
-- Listeners primes _snapshot from current visibility so the first
-- diff after a load doesn't announce every visible foreign unit as
-- freshly entered. civvaccess_shared.foreignUnitDelta gets cleared at
-- the same time so F7 doesn't show stale strings carried over from a
-- prior session via the shared table.

ForeignUnitWatch = {}

-- Snapshot entry shape:
-- { ownerId, unitId, civAdjKey, unitDescKey, bucket = "hostile" | "neutral" }
local _snapshot = {}

local function globalKey(ownerId, unitId)
    return tostring(ownerId) .. ":" .. tostring(unitId)
end

-- "hostile" / "neutral" / nil. Nil for own player, dead players, and
-- teammates -- those don't belong in either announcement bucket.
local function classifyOwner(ownerId, activePlayerId, activeTeam)
    if ownerId == activePlayerId then
        return nil
    end
    local owner = Players[ownerId]
    if owner == nil or not owner:IsAlive() then
        return nil
    end
    if owner:IsBarbarian() then
        return "hostile"
    end
    local ownerTeam = owner:GetTeam()
    if ownerTeam == activeTeam then
        return nil
    end
    if Teams[activeTeam]:IsAtWar(ownerTeam) then
        return "hostile"
    end
    return "neutral"
end

-- Caller (buildVisibleSet) has already proved Players[ownerId] alive,
-- so the lookup here doesn't need a nil guard. The unit description
-- row check guards a real edge case (mod content with missing
-- Description) and stays.
local function unitMetadata(unit, ownerId, bucket)
    local civAdjKey = Players[ownerId]:GetCivilizationAdjectiveKey()
    local row = GameInfo.Units[unit:GetUnitType()]
    local unitDescKey = row and row.Description or nil
    return {
        ownerId = ownerId,
        unitId = unit:GetID(),
        civAdjKey = civAdjKey,
        unitDescKey = unitDescKey,
        bucket = bucket,
    }
end

-- Walks every foreign player slot up through the barbarian index and
-- collects visible-to-active-team units into a keyed table. Visibility
-- filter mirrors ScannerBackendUnits (IsVisible AND not IsInvisible) so
-- stealth and recon-blocking behave the same here.
local function buildVisibleSet()
    local set = {}
    local activePlayerId = Game.GetActivePlayer()
    local activeTeam = Game.GetActiveTeam()
    local maxIndex = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 63
    for i = 0, maxIndex do
        if i ~= activePlayerId then
            local player = Players[i]
            if player ~= nil and player:IsAlive() then
                local bucket = classifyOwner(i, activePlayerId, activeTeam)
                if bucket ~= nil then
                    for unit in player:Units() do
                        if not unit:IsInvisible(activeTeam, false) then
                            local plot = unit:GetPlot()
                            if plot ~= nil and plot:IsVisible(activeTeam, false) then
                                local meta = unitMetadata(unit, i, bucket)
                                if meta.civAdjKey ~= nil and meta.unitDescKey ~= nil then
                                    set[globalKey(i, unit:GetID())] = meta
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return set
end

-- "3 Arabian Warrior" form, comma-joined, sorted alphabetically by
-- (civAdjKey, unitDescKey). Sorting matters: pairs() on the counts
-- table is non-deterministic, and an unsorted output reorders the
-- list every turn even when the content is identical, which sounds
-- "wrong" to a screen-reader user who's tracking a familiar list. No
-- plural form -- Civ V's text data has no TXT_KEY_UNIT_*_PLURAL keys,
-- hand-rolling per-unit / per-locale plural rules is a maintenance
-- trap, and screen readers parse "3 Warrior" as plural from context.
local function formatList(entries)
    local counts = {}
    local order = {}
    for _, e in ipairs(entries) do
        local key = e.civAdjKey .. "|" .. e.unitDescKey
        local bucket = counts[key]
        if bucket == nil then
            counts[key] = {
                count = 1,
                civ = Text.key(e.civAdjKey),
                unit = Text.key(e.unitDescKey),
            }
            order[#order + 1] = key
        else
            bucket.count = bucket.count + 1
        end
    end
    table.sort(order)
    local pieces = {}
    for _, k in ipairs(order) do
        local b = counts[k]
        if b.count > 1 then
            pieces[#pieces + 1] = tostring(b.count) .. " " .. b.civ .. " " .. b.unit
        else
            pieces[#pieces + 1] = b.civ .. " " .. b.unit
        end
    end
    return table.concat(pieces, ", ")
end

local function formatLine(entries, txtKey)
    if #entries == 0 then
        return ""
    end
    return Text.format(txtKey, formatList(entries))
end

function ForeignUnitWatch._onTurnEnd()
    local ok, err = pcall(function()
        _snapshot = buildVisibleSet()
        civvaccess_shared.foreignUnitDelta = nil
    end)
    if not ok then
        Log.error("ForeignUnitWatch: TurnEnd snapshot failed: " .. tostring(err))
    end
end

function ForeignUnitWatch._onTurnStart()
    local ok, err = pcall(function()
        local current = buildVisibleSet()

        local hE, hL, nE, nL = {}, {}, {}, {}

        -- Walk current: newly visible go into the appropriate entered
        -- bucket. Already-visible units that flipped neutral -> hostile
        -- (war declared mid-AI-turn while the unit stood in your view)
        -- get synthesized into hostile-entered so the announcement
        -- carries the new threat list, not just the engine's bare war
        -- notification.
        for key, curr in pairs(current) do
            local prev = _snapshot[key]
            if prev == nil then
                if curr.bucket == "hostile" then
                    hE[#hE + 1] = curr
                else
                    nE[#nE + 1] = curr
                end
            elseif prev.bucket == "neutral" and curr.bucket == "hostile" then
                hE[#hE + 1] = curr
            end
        end

        -- Walk snapshot: units no longer visible go into the left bucket
        -- only when the engine still has them under their original
        -- owner. GetUnitByID returns nil for both deaths and captures;
        -- we drop both per the design (see file header).
        for key, prev in pairs(_snapshot) do
            if current[key] == nil then
                local owner = Players[prev.ownerId]
                if owner ~= nil and owner:GetUnitByID(prev.unitId) ~= nil then
                    if prev.bucket == "hostile" then
                        hL[#hL + 1] = prev
                    else
                        nL[#nL + 1] = prev
                    end
                end
            end
        end

        -- Stable order: entered before left, hostile before neutral.
        -- Keeps the audible shape predictable for the user.
        local rawLines = {
            formatLine(hE, "TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"),
            formatLine(hL, "TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"),
            formatLine(nE, "TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"),
            formatLine(nL, "TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"),
        }
        local nonEmpty = {}
        for _, line in ipairs(rawLines) do
            if line ~= "" then
                nonEmpty[#nonEmpty + 1] = line
            end
        end

        if #nonEmpty > 0 then
            civvaccess_shared.foreignUnitDelta = nonEmpty
            -- Speech is gated by the foreignUnitWatchAnnounce setting;
            -- the F7 Turn Log entry above lands either way so the user
            -- can review the diff manually when speech is off. First
            -- line interrupts: turn-start summary isn't a follow-up to
            -- anything specific, and the project default is speak-
            -- Interrupt unless we have a reason to queue. The remaining
            -- lines queue so the four-line summary plays as a single
            -- coherent block instead of cutting itself off.
            if civvaccess_shared.foreignUnitWatchAnnounce then
                SpeechPipeline.speakInterrupt(nonEmpty[1])
                for i = 2, #nonEmpty do
                    SpeechPipeline.speakQueued(nonEmpty[i])
                end
            end
        else
            civvaccess_shared.foreignUnitDelta = nil
        end

        _snapshot = current
    end)
    if not ok then
        Log.error("ForeignUnitWatch: TurnStart diff failed: " .. tostring(err))
    end
end

-- Registers fresh listeners on every call. See CivVAccess_Boot.lua's
-- LoadScreenClose registration for the rationale: prior-Context listener
-- closures die on load-game-from-game.
function ForeignUnitWatch.installListeners()
    _snapshot = buildVisibleSet()
    civvaccess_shared.foreignUnitDelta = nil
    if Events ~= nil and Events.ActivePlayerTurnEnd ~= nil then
        Events.ActivePlayerTurnEnd.Add(ForeignUnitWatch._onTurnEnd)
    else
        Log.warn("ForeignUnitWatch: Events.ActivePlayerTurnEnd missing")
    end
    if Events ~= nil and Events.ActivePlayerTurnStart ~= nil then
        Events.ActivePlayerTurnStart.Add(ForeignUnitWatch._onTurnStart)
    else
        Log.warn("ForeignUnitWatch: Events.ActivePlayerTurnStart missing")
    end
end

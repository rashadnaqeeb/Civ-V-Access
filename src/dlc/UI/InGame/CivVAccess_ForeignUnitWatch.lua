-- Speaks up to four lines at the start of every player turn covering
-- foreign units that entered or walked out of the active team's view
-- during the AI turn just past. Splits hostile (at-war + barb) from
-- neutral (every foreign owner you can see who isn't at war with you,
-- civilians included). For the F7 Turn Log the diff is parked on
-- civvaccess_shared in two shapes: foreignUnitEntered carries the entered
-- units as structured per-unit metadata (owner / unit ids) so the popup can
-- re-resolve each to a live plot and offer a jump; foreignUnitDelta carries
-- the left-view units as a flat array of aggregated strings (no jump -- a
-- departed unit sits in fog). Both clear at the next turn end.
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
-- Visibility walk and metadata recording live in ForeignUnitSnapshot;
-- this module owns the per-bucket vocabulary and the diff.
local _snapshot = {}

-- "hostile" / "neutral" / nil. Nil for own player and teammates -- those
-- don't belong in either announcement bucket. ForeignUnitSnapshot.collect
-- already gates on the owner being alive, so this only classifies live
-- foreign players.
local function classifyOwner(ownerId, activePlayerId, activeTeam)
    if ownerId == activePlayerId then
        return nil
    end
    local owner = Players[ownerId]
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

local function buildVisibleSet()
    return ForeignUnitSnapshot.collect(classifyOwner)
end

local function formatLine(entries, txtKey)
    if #entries == 0 then
        return ""
    end
    return Text.format(txtKey, ForeignUnitSnapshot.formatList(entries))
end

function ForeignUnitWatch._onTurnEnd()
    local ok, err = pcall(function()
        _snapshot = buildVisibleSet()
        civvaccess_shared.foreignUnitDelta = nil
        civvaccess_shared.foreignUnitEntered = nil
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
        local hLstr = formatLine(hL, "TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT")
        local nLstr = formatLine(nL, "TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT")
        local rawLines = {
            formatLine(hE, "TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"),
            hLstr,
            formatLine(nE, "TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"),
            nLstr,
        }
        local nonEmpty = {}
        for _, line in ipairs(rawLines) do
            if line ~= "" then
                nonEmpty[#nonEmpty + 1] = line
            end
        end

        -- Speech + message scrollback get all four aggregated lines.
        -- Speech is gated by the foreignUnitWatchAnnounce setting; the
        -- scrollback and F7 surfaces land either way so the user can
        -- review the diff manually when speech is off. All lines queue:
        -- NotificationAnnounce and RevealAnnounce also fire around the
        -- turn boundary and queue everything, so interrupting here would
        -- cut whichever of them happens to be speaking when the diff lands.
        if #nonEmpty > 0 then
            if civvaccess_shared.foreignUnitWatchAnnounce then
                for _, line in ipairs(nonEmpty) do
                    SpeechPipeline.speakQueued(line)
                end
            end
            for _, line in ipairs(nonEmpty) do
                MessageBuffer.append(line, "reveal")
            end
        end

        -- F7 Turn Log split. Entered units are parked as structured per-
        -- unit metadata (owner / unit ids) so the popup can re-resolve each
        -- to a live plot and offer a jump. Left units stay aggregated text:
        -- a departed unit's live plot is in fog, so there's nothing safe to
        -- jump to.
        if #hE > 0 or #nE > 0 then
            civvaccess_shared.foreignUnitEntered = { hostile = hE, neutral = nE }
        else
            civvaccess_shared.foreignUnitEntered = nil
        end
        local leftLines = {}
        if hLstr ~= "" then
            leftLines[#leftLines + 1] = hLstr
        end
        if nLstr ~= "" then
            leftLines[#leftLines + 1] = nLstr
        end
        if #leftLines > 0 then
            civvaccess_shared.foreignUnitDelta = leftLines
        else
            civvaccess_shared.foreignUnitDelta = nil
        end

        _snapshot = current
    end)
    if not ok then
        Log.error("ForeignUnitWatch: TurnStart diff failed: " .. tostring(err))
    end
end

-- Live mutators on the F7 entered set, called by RevealAnnounce as the
-- player's own movement brings foreign units into view or pushes them into
-- fog mid-turn. The turn-start diff above seeds foreignUnitEntered with the
-- AI batch's newly visible units; these keep it current through the player's
-- turn so the F7 group reflects what the player can actually see right now,
-- not just the turn-boundary snapshot. bucketKey is "hostile" / "neutral"
-- (the sub-table the F7 renderer groups by); metas carry the same
-- { ownerId, unitId, civAdjKey, unitDescKey } shape the turn-start path uses.

local function enteredKeySet(list)
    local seen = {}
    for _, m in ipairs(list) do
        seen[ForeignUnitSnapshot.unitKey(m.ownerId, m.unitId)] = true
    end
    return seen
end

-- Append metas to one bucket, skipping any unit already present. Creates the
-- shared structure if the turn-start diff parked nothing this turn.
function ForeignUnitWatch.addEntered(bucketKey, metas)
    if #metas == 0 then
        return
    end
    local entered = civvaccess_shared.foreignUnitEntered
    if entered == nil then
        entered = { hostile = {}, neutral = {} }
        civvaccess_shared.foreignUnitEntered = entered
    end
    local list = entered[bucketKey]
    local seen = enteredKeySet(list)
    for _, m in ipairs(metas) do
        local key = ForeignUnitSnapshot.unitKey(m.ownerId, m.unitId)
        if not seen[key] then
            seen[key] = true
            list[#list + 1] = m
        end
    end
end

-- Drop the given units (by owner / unit id) from both buckets. A unit the
-- player just lost sight of leaves the list entirely rather than lingering
-- as a stale "no longer in view" entry.
function ForeignUnitWatch.removeEntered(metas)
    if #metas == 0 then
        return
    end
    local entered = civvaccess_shared.foreignUnitEntered
    if entered == nil then
        return
    end
    local drop = {}
    for _, m in ipairs(metas) do
        drop[ForeignUnitSnapshot.unitKey(m.ownerId, m.unitId)] = true
    end
    for _, bucketKey in ipairs({ "hostile", "neutral" }) do
        local list = entered[bucketKey]
        if list ~= nil then
            local kept = {}
            for _, m in ipairs(list) do
                if not drop[ForeignUnitSnapshot.unitKey(m.ownerId, m.unitId)] then
                    kept[#kept + 1] = m
                end
            end
            entered[bucketKey] = kept
        end
    end
end

-- Registers fresh listeners on every call. See CivVAccess_Boot.lua's
-- LoadScreenClose registration for the rationale: prior-Context listener
-- closures die on load-game-from-game.
function ForeignUnitWatch.installListeners()
    _snapshot = buildVisibleSet()
    civvaccess_shared.foreignUnitDelta = nil
    civvaccess_shared.foreignUnitEntered = nil
    Log.installEvent(Events, "ActivePlayerTurnEnd", ForeignUnitWatch._onTurnEnd, "ForeignUnitWatch")
    Log.installEvent(Events, "ActivePlayerTurnStart", ForeignUnitWatch._onTurnStart, "ForeignUnitWatch")
end

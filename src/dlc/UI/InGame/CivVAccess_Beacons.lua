-- Spatial-audio bookmark beacons. Toggle Ctrl+Shift+digit on a bookmarked
-- slot and a looping point-source sounds from the bookmark's position; the
-- cursor is the listener. Pan and pitch encode bearing only; volume encodes
-- distance only. All three parameters recompute on every cursor move so a
-- player can hunt the cursor toward (or away from) the source by ear.
--
-- Pan: cosine of the screen-space bearing (-1 west, +1 east). Pitch: sine
-- (-1 south, +1 north). Both are pulled from HexGeom.unitVector, which
-- handles the pointy-top odd-r row-vs-column scaling so due-NE doesn't
-- collapse onto due-N. The unit-vector invariant means every point on a
-- circle around the beacon shares the same bearing audio; only volume
-- distinguishes which circle. Pitch is applied as a multiplicative
-- playback rate (2^(pitch_input * SEMI_RANGE / 12)) around the source's
-- baked centre, so beacon.wav itself sits at the "due east / due west"
-- pitch.
--
-- Volume: linear fade from 1.0 at distance 0 to 0 at VOL_MAX_DIST hexes
-- (uses Map.PlotDistance for true integer hex distance). Past
-- VOL_MAX_DIST the beacon goes silent without a floor; the user can hear
-- it again by walking the cursor closer.
--
-- Lifecycle: beacons play only while BaselineHandler (the in-game map
-- cursor handler) is on top of the HandlerStack. Push something above it
-- (popup, sub-screen) and the looping voices stop; the activation state
-- persists, so closing the sub returns to the same active beacons. New
-- game / hot-seat player change clears activation state.
--
-- Voices are allocated once per session via audio.load_voice (one
-- ma_sound per slot, ten slots, sharing one beacon.wav file). The proxy's
-- audio.cancel_all skips looping sounds, so PlotAudio's per-cursor-move
-- cancel does not silence active beacons.

Beacons = {}

local SLOT_KEYS = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

-- Pitch spread: pitch_input of +1 (due north) plays one octave above the
-- source, -1 (due south) plays one octave below. Tuned by ear; revisit
-- if the north / south spread reads as too dramatic or too subtle.
local SEMI_RANGE = 12

-- Volume reaches 0 at this hex distance. Beyond is silence; there is no
-- floor (the user wanted complete fadeout, not a residual hum).
local VOL_MAX_DIST = 30

local MOD_CTRL_SHIFT = 3

-- Recompute and push pan / pitch / volume for one active beacon. Reads
-- the bookmark cell live each call so a relocated bookmark picks up on
-- the next cursor step without any explicit notification path. Distance
-- past VOL_MAX_DIST clamps to 0; pan / pitch in that case are still set
-- (they're free) so a quiet beacon's bearing still reads correctly the
-- moment volume comes back.
local function updateBeaconParams(h, cx, cy, bx, by)
    local pan, pitch = HexGeom.unitVector(cx, cy, bx, by)
    local dist = Map.PlotDistance(cx, cy, bx, by)
    local vol = 1 - dist / VOL_MAX_DIST
    if vol < 0 then
        vol = 0
    end
    local pitchRate = 2 ^ ((pitch * SEMI_RANGE) / 12)
    audio.set_pan(h, pan)
    audio.set_pitch(h, pitchRate)
    audio.set_volume(h, vol)
end

-- Allocate one looping ma_sound per bookmark slot at first in-game boot.
-- Re-entered Contexts (load-from-game) skip the work because the audio
-- bank slots survive at the proxy level; civvaccess_shared.beaconHandles
-- is the install-once guard. load_voice (not plain load) so each slot
-- gets its own ma_sound -- pan / pitch / volume are per-sound state, so
-- a shared handle could not give us independent beacons.
function Beacons.loadAll()
    if civvaccess_shared.beaconHandles ~= nil then
        return
    end
    if audio == nil then
        Log.warn("Beacons.loadAll: audio binding missing")
        return
    end
    local handles = {}
    local loaded, missed = 0, 0
    for _, slot in ipairs(SLOT_KEYS) do
        local h = audio.load_voice("beacon")
        if h == nil then
            Log.error("Beacons.loadAll: load_voice returned nil for slot " .. slot)
            missed = missed + 1
        else
            handles[slot] = h
            -- Looping is the marker the proxy's cancel_all uses to skip
            -- a sound; set once here so every active-beacon path can rely
            -- on it. Volume starts at 0 so a stray play before the first
            -- cursor-move parameter push doesn't blast the user.
            audio.set_loop(h, true)
            audio.set_volume(h, 0)
            loaded = loaded + 1
        end
    end
    civvaccess_shared.beaconHandles = handles
    Log.info("Beacons.loadAll: loaded " .. tostring(loaded) .. ", missed " .. tostring(missed))
end

-- Wipe activation state for a new game / new hot-seat player. The voice
-- handles themselves stay allocated (they're per-session, not per-game)
-- so re-activation is a stop-then-play, not a reload.
function Beacons.resetForNewGame()
    -- Stop any looping voices left running from the prior game / player so
    -- the new session starts in a clean audio state. The activeBeacons
    -- table is per-game; the handles are per-session.
    local handles = civvaccess_shared.beaconHandles
    if handles ~= nil and audio ~= nil then
        for _, h in pairs(handles) do
            audio.stop(h)
        end
    end
    civvaccess_shared.activeBeacons = {}
end

-- Stop every looping voice without touching activeBeacons, so resume can
-- reactivate the same set later. Called from Scanner / Baseline onSuspend
-- when a sub-handler pushes above us.
function Beacons.suspend()
    local handles = civvaccess_shared.beaconHandles
    if handles == nil or audio == nil then
        return
    end
    for _, h in pairs(handles) do
        audio.stop(h)
    end
end

-- Restart every active beacon at fresh parameters. Called from
-- BaselineHandler.onActivate when we return to the top of the stack.
-- Pulls a live cursor and live bookmark each time -- both can have moved
-- while we were suspended (the cursor most often, but a relocate-bookmark
-- flow could shift the source too).
function Beacons.resume()
    local active = civvaccess_shared.activeBeacons
    if active == nil then
        return
    end
    local handles = civvaccess_shared.beaconHandles
    if handles == nil or audio == nil then
        return
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        return
    end
    for slot, isActive in pairs(active) do
        if isActive then
            local b = civvaccess_shared.bookmarks[slot]
            local h = handles[slot]
            if b == nil or h == nil then
                -- Active flag set but the underlying bookmark or voice
                -- is missing. resetForNewGame is supposed to clear active
                -- in lockstep with the bookmark store; reaching here means
                -- some path desynced them. Clear the flag so the next
                -- resume / onCursorMove doesn't re-fire the warning.
                Log.warn("Beacons.resume: slot " .. tostring(slot) .. " active but bookmark or handle missing; clearing")
                active[slot] = false
            else
                updateBeaconParams(h, cx, cy, b.x, b.y)
                audio.play(h)
            end
        end
    end
end

-- Cursor-move hook. Cheap when no beacons are active (one table read,
-- early return). Called from CursorCore.setCursor on every cursor mutation
-- (move, jump, scope-edge no-op already short-circuits before setCursor
-- runs).
function Beacons.onCursorMove()
    local active = civvaccess_shared.activeBeacons
    if active == nil then
        return
    end
    local handles = civvaccess_shared.beaconHandles
    if handles == nil or audio == nil then
        return
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        return
    end
    for slot, isActive in pairs(active) do
        if isActive then
            local b = civvaccess_shared.bookmarks[slot]
            local h = handles[slot]
            if b == nil or h == nil then
                -- Active flag set but the underlying bookmark or voice is
                -- missing. Stop the voice (it would otherwise loop with
                -- whatever stale params it last received) and clear the
                -- flag so the warning fires once, not on every cursor
                -- move. resetForNewGame is the only intended path to
                -- desync these; reaching here means a real bug elsewhere.
                Log.warn("Beacons.onCursorMove: slot " .. tostring(slot) .. " active but bookmark or handle missing; stopping")
                if h ~= nil then
                    audio.stop(h)
                end
                active[slot] = false
            else
                updateBeaconParams(h, cx, cy, b.x, b.y)
            end
        end
    end
end

-- Returns the spoken feedback for the toggle keystroke. Empty bookmark
-- slot speaks the no-bookmark prompt rather than going silent so the user
-- can tell a stray Ctrl+Shift+N from a real activation.
function Beacons.toggle(slot)
    local b = civvaccess_shared.bookmarks[slot]
    if b == nil then
        return Text.key("TXT_KEY_CIVVACCESS_BEACON_NO_BOOKMARK")
    end
    local handles = civvaccess_shared.beaconHandles
    local h = handles and handles[slot] or nil
    if h == nil or audio == nil then
        Log.warn("Beacons.toggle: no voice handle for slot " .. tostring(slot))
        return ""
    end
    local active = civvaccess_shared.activeBeacons
    -- The literal slot string is what bookmarks.lua and the binding both
    -- key off; the spoken number is the same digit parsed back to an
    -- integer for natural number agreement in target locales (e.g.
    -- French where "balise 1" reads better than "balise 01").
    local slotNum = tonumber(slot)
    if active[slot] then
        active[slot] = false
        audio.stop(h)
        return Text.format("TXT_KEY_CIVVACCESS_BEACON_DEACTIVATED", slotNum)
    end
    active[slot] = true
    local cx, cy = Cursor.position()
    if cx ~= nil then
        updateBeaconParams(h, cx, cy, b.x, b.y)
    end
    audio.play(h)
    return Text.format("TXT_KEY_CIVVACCESS_BEACON_ACTIVATED", slotNum)
end

-- Hot-seat: same hook Bookmarks uses. The new player's bookmarks are
-- different cells; carrying activation state across would point beacons
-- at the wrong positions. Stop and clear, same as a fresh game.
function Beacons._onActivePlayerChanged(iActive, _iPrev)
    if iActive == nil or iActive < 0 then
        return
    end
    if not Game.IsHotSeat() then
        return
    end
    Beacons.resetForNewGame()
end

function Beacons.installListeners()
    if not Game.IsHotSeat() then
        return
    end
    if
        Log.installEvent(
            Events,
            "GameplaySetActivePlayer",
            Beacons._onActivePlayerChanged,
            "Beacons",
            "hotseat per-player beacon reset disabled"
        )
    then
        Log.info("Beacons: installed hotseat listener")
    end
end

local bind = HandlerStack.bind
local speak = SpeechPipeline.speakInterrupt

function Beacons.getBindings()
    local bindings = {}
    for _, slot in ipairs(SLOT_KEYS) do
        bindings[#bindings + 1] = bind(Keys[slot], MOD_CTRL_SHIFT, function()
            speak(Beacons.toggle(slot))
        end, "Toggle beacon slot " .. slot)
    end
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_BEACON_HELP_KEY",
            description = "TXT_KEY_CIVVACCESS_BEACON_HELP_DESC",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

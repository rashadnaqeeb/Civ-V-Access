-- Beacons: ten looping voices keyed off Bookmarks slots, with pan/pitch/
-- volume pushed every cursor move. Each test exercises a path the others
-- don't: toggle on/off, the empty-slot speak, onCursorMove computes and
-- pushes the right parameters, the volume floor at the configured max
-- distance, the degenerate-vector path at distance zero, the cheap-path
-- early return when no beacons are active, the audibility policy
-- (cursor-on-map handler -> play, anything else -> stop, beaconsTransparent
-- handlers pass through the top-down walk), refresh idempotency (no
-- redundant audio.play to avoid clicks), the desync recovery in refresh
-- (active flag set but bookmark missing), loadAll is idempotent,
-- resetForNewGame wipes activation. The actual stereo-bus mixing (pan,
-- pitch as playback-rate) is owned by miniaudio in the proxy and is not
-- exercised here -- the offline harness asserts that the right values
-- reach the audio bridge, not what the bridge does with them.

local T = require("support")
local M = {}

-- Beacons.lua is dofile'd inside setup so every test gets a fresh module
-- table with its module-scope `local bind = HandlerStack.bind` etc. resolved
-- against this suite's stubs rather than whatever module loaded it last.
local function setup()
    -- Module-scope locals in Beacons.lua reference HandlerStack.bind and
    -- SpeechPipeline.speakInterrupt at load time, so both must exist as
    -- globals before the dofile. HandlerStack.count / .at are how
    -- Beacons.refresh reads the current stack to evaluate the audibility
    -- policy; we drive a small fake stack in _stack and let the helpers
    -- below populate it for each scenario.
    HandlerStack = {
        _stack = {},
        bind = function(key, mods, fn, description)
            return { key = key, mods = mods, fn = fn, description = description }
        end,
        count = function()
            return #HandlerStack._stack
        end,
        at = function(i)
            return HandlerStack._stack[i]
        end,
    }
    SpeechPipeline = SpeechPipeline or {}
    SpeechPipeline.speakInterrupt = function() end

    -- Text.format / Text.key. The real lookup goes through CivVAccess_Strings
    -- which run.lua already loaded; falling back to the key string is fine
    -- since the suite checks for the substituted-arg shape rather than the
    -- exact English wording.
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    -- Reset shared state. resetForNewGame stops voices and inits the
    -- activeBeacons table; tests that want to skip the stop call (i.e.
    -- those checking loadAll behavior in isolation) reset by hand.
    -- beaconPlaying is the per-slot "currently audible" flag refresh
    -- tracks to keep audio.play idempotent.
    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.bookmarks = {}
    civvaccess_shared.beaconHandles = nil
    civvaccess_shared.activeBeacons = nil
    civvaccess_shared.beaconPlaying = nil

    -- Cursor stub. Tests that exercise onCursorMove / resume override
    -- this on a per-test basis.
    Cursor = {
        _x = nil,
        _y = nil,
        position = function()
            return Cursor._x, Cursor._y
        end,
    }

    -- Map.PlotDistance is the volume axis. The polyfill default returns 0
    -- which would land every test on max volume; per-test stubs install a
    -- coordinate-aware distance.
    Map.PlotDistance = function(_x1, _y1, _x2, _y2)
        return 0
    end

    -- HotSeat off so installListeners is a no-op; tests don't exercise the
    -- listener path.
    Game.IsHotSeat = function()
        return false
    end

    audio._reset()
    dofile("src/dlc/UI/InGame/CivVAccess_Beacons.lua")
end

-- Helper: counts audio.set_pan / set_pitch / set_volume calls for a slot.
local function findCall(op, slot)
    for _, c in ipairs(audio._calls) do
        if c.op == op and (slot == nil or c.id == slot) then
            return c
        end
    end
    return nil
end

-- Stack-population helpers. Beacons.refresh walks HandlerStack._stack
-- from the top to find the first non-beaconsTransparent handler, and
-- only plays beacons when that handler's name is "Baseline" or "Scanner".
local function setBaselineScannerStack()
    HandlerStack._stack = {
        { name = "Baseline" },
        { name = "Scanner" },
    }
end

local function setBlockingTopStack()
    HandlerStack._stack = {
        { name = "Baseline" },
        { name = "Scanner" },
        { name = "SomePopup" },
    }
end

local function setTransparentTargetingStack()
    HandlerStack._stack = {
        { name = "Baseline" },
        { name = "Scanner" },
        { name = "UnitTargetMode", beaconsTransparent = true },
    }
end

-- ===== loadAll =====

function M.test_loadAll_allocates_ten_voices_and_sets_each_looping()
    setup()
    Beacons.loadAll()
    -- Ten distinct slot integers stored under SLOT_KEYS.
    local handles = civvaccess_shared.beaconHandles
    local count = 0
    for _, _ in pairs(handles) do
        count = count + 1
    end
    T.eq(count, 10)
    -- Each voice marked looping at boot so cancel_all skips it.
    local loops = {}
    for _, c in ipairs(audio._calls) do
        if c.op == "set_loop" then
            loops[c.id] = c.v
        end
    end
    for _, h in pairs(handles) do
        T.eq(loops[h], true, "every beacon voice must be set looping at loadAll")
    end
end

function M.test_loadAll_is_idempotent()
    setup()
    Beacons.loadAll()
    local firstHandles = civvaccess_shared.beaconHandles
    audio._reset()
    Beacons.loadAll()
    -- Second call must early-return: no new load_voice calls and the
    -- handles table reference is preserved (not re-built).
    T.eq(#audio._calls, 0, "loadAll must short-circuit on subsequent calls")
    T.eq(civvaccess_shared.beaconHandles, firstHandles)
end

-- ===== toggle =====

function M.test_toggle_activates_populates_flag_and_plays_voice()
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBaselineScannerStack()
    civvaccess_shared.bookmarks["3"] = { x = 5, y = 7 }
    Cursor._x, Cursor._y = 0, 0
    audio._reset()

    local spoken = Beacons.toggle("3")

    T.truthy(spoken:find("3"), "activated message must include the slot number")
    T.eq(civvaccess_shared.activeBeacons["3"], true)
    local h = civvaccess_shared.beaconHandles["3"]
    T.truthy(findCall("play", h), "audio.play must fire on activation under an audible top")
end

function M.test_toggle_deactivates_clears_flag_and_stops_voice()
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBaselineScannerStack()
    civvaccess_shared.bookmarks["5"] = { x = 1, y = 1 }
    Cursor._x, Cursor._y = 0, 0

    Beacons.toggle("5")
    audio._reset()
    local spoken = Beacons.toggle("5")

    T.truthy(spoken:find("5"))
    T.eq(civvaccess_shared.activeBeacons["5"], false)
    local h = civvaccess_shared.beaconHandles["5"]
    T.truthy(findCall("stop", h), "audio.stop must fire on deactivation")
    T.eq(findCall("play", h), nil, "audio.play must not fire on deactivation")
end

function M.test_toggle_empty_slot_speaks_no_bookmark_and_no_audio()
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBaselineScannerStack()
    -- No bookmark set for slot "8".
    audio._reset()

    local spoken = Beacons.toggle("8")

    T.truthy(spoken ~= "" and spoken ~= nil, "empty slot must return a non-empty prompt")
    T.eq(civvaccess_shared.activeBeacons["8"], nil)
    T.eq(#audio._calls, 0, "no audio calls when the slot has no bookmark")
end

function M.test_toggle_under_blocking_top_arms_without_playing()
    -- A non-cursor-on-map handler on top of Baseline / Scanner silences
    -- the policy. Toggling a beacon in this state arms the slot but does
    -- not play audio; the next refresh that lands on an audible top
    -- starts the voice.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBlockingTopStack()
    civvaccess_shared.bookmarks["4"] = { x = 1, y = 0 }
    Cursor._x, Cursor._y = 0, 0
    audio._reset()

    Beacons.toggle("4")

    T.eq(civvaccess_shared.activeBeacons["4"], true, "active flag still set under blocking top")
    local h = civvaccess_shared.beaconHandles["4"]
    T.eq(findCall("play", h), nil, "no audio.play fires while a blocking handler is on top")

    -- Blocking handler pops; next refresh fires audio.play.
    setBaselineScannerStack()
    audio._reset()
    Beacons.refresh()
    T.truthy(findCall("play", h), "refresh starts the armed beacon once the top clears")
end

-- ===== onCursorMove =====

function M.test_onCursorMove_pushes_pan_pitch_and_volume_for_active_beacon()
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    civvaccess_shared.bookmarks["1"] = { x = 10, y = 0 }
    civvaccess_shared.activeBeacons["1"] = true
    Cursor._x, Cursor._y = 0, 0
    -- Beacon is due east of the cursor at hex distance 10. PlotDistance
    -- returns the integer hex distance the proxy uses for volume.
    Map.PlotDistance = function()
        return 10
    end
    audio._reset()

    Beacons.onCursorMove()

    local h = civvaccess_shared.beaconHandles["1"]
    local pan = findCall("set_pan", h)
    local pitch = findCall("set_pitch", h)
    local vol = findCall("set_volume", h)

    T.truthy(pan, "set_pan must fire on cursor move")
    T.truthy(pitch, "set_pitch must fire on cursor move")
    T.truthy(vol, "set_volume must fire on cursor move")
    -- Due east: pan ~ +1, pitch ~ 1.0 (rate unchanged at zero north/south).
    T.truthy(pan.v > 0.99, "due-east beacon should pan full right; got " .. tostring(pan.v))
    T.truthy(math.abs(pitch.v - 1.0) < 0.001, "due-east pitch rate is 1.0; got " .. tostring(pitch.v))
    -- Volume = 1 - 10/30 = 0.6667.
    T.truthy(math.abs(vol.v - (1 - 10 / 30)) < 0.001, "volume linear in distance; got " .. tostring(vol.v))
end

function M.test_onCursorMove_volume_floor_silences_beyond_max_distance()
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    civvaccess_shared.bookmarks["2"] = { x = 100, y = 0 }
    civvaccess_shared.activeBeacons["2"] = true
    Cursor._x, Cursor._y = 0, 0
    Map.PlotDistance = function()
        return 50
    end
    audio._reset()

    Beacons.onCursorMove()

    local h = civvaccess_shared.beaconHandles["2"]
    local vol = findCall("set_volume", h)
    T.eq(vol.v, 0, "volume must clamp to 0 past max distance, not go negative")
end

function M.test_onCursorMove_at_distance_zero_neutralizes_pan_and_pitch()
    -- The unitVector early-return on mag==0 is the difference between
    -- "centered audio" and "NaN reaches the audio engine". Asserting the
    -- exact (0,0) return defends the contract for the on-source case.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    civvaccess_shared.bookmarks["4"] = { x = 5, y = 5 }
    civvaccess_shared.activeBeacons["4"] = true
    Cursor._x, Cursor._y = 5, 5
    Map.PlotDistance = function()
        return 0
    end
    audio._reset()

    Beacons.onCursorMove()

    local h = civvaccess_shared.beaconHandles["4"]
    T.eq(findCall("set_pan", h).v, 0)
    -- 2^0 = 1.0 (no pitch shift) when the unit vector collapses.
    T.eq(findCall("set_pitch", h).v, 1)
    T.eq(findCall("set_volume", h).v, 1)
end

function M.test_onCursorMove_no_active_beacons_makes_no_audio_calls()
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    Cursor._x, Cursor._y = 3, 3
    audio._reset()

    Beacons.onCursorMove()

    T.eq(#audio._calls, 0, "no audio traffic when no beacons are active")
end

function M.test_onCursorMove_desync_silently_skips()
    -- onCursorMove trusts the active set: the desync recovery (active flag
    -- set but bookmark missing) lives in refresh, where it pairs naturally
    -- with the per-slot beaconPlaying cleanup. onCursorMove just skips the
    -- bad slot so a single dropped frame doesn't double-fire stop calls.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    civvaccess_shared.activeBeacons["6"] = true
    -- Bookmark "6" intentionally absent.
    Cursor._x, Cursor._y = 0, 0
    audio._reset()

    Beacons.onCursorMove()

    T.eq(#audio._calls, 0, "onCursorMove must not touch audio for a desync slot")
end

-- ===== refresh =====

function M.test_refresh_starts_active_beacons_when_audible()
    -- Replaces the old resume() test: under an audible top, refresh
    -- starts every active slot whose bookmark exists. Drives the
    -- "popup pops, beacons should resume" path the BaselineHandler /
    -- ScannerHandler used to wire through onActivate hooks.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBaselineScannerStack()
    civvaccess_shared.bookmarks["1"] = { x = 1, y = 0 }
    civvaccess_shared.bookmarks["7"] = { x = 0, y = 1 }
    civvaccess_shared.activeBeacons["1"] = true
    civvaccess_shared.activeBeacons["7"] = true
    Cursor._x, Cursor._y = 0, 0
    audio._reset()

    Beacons.refresh()

    local h1 = civvaccess_shared.beaconHandles["1"]
    local h7 = civvaccess_shared.beaconHandles["7"]
    T.truthy(findCall("play", h1))
    T.truthy(findCall("play", h7))
end

function M.test_refresh_stops_voices_when_top_blocks_audibility()
    -- Replaces the old suspend() test. Drive an audible refresh first to
    -- mark the slots playing, then push a non-transparent handler and
    -- refresh again -- only previously-playing slots get stop calls,
    -- and the active flags stay set so the next audible refresh restarts
    -- them.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBaselineScannerStack()
    civvaccess_shared.bookmarks["2"] = { x = 0, y = 1 }
    civvaccess_shared.activeBeacons["2"] = true
    Cursor._x, Cursor._y = 0, 0
    Beacons.refresh()

    setBlockingTopStack()
    audio._reset()
    Beacons.refresh()

    local h = civvaccess_shared.beaconHandles["2"]
    T.truthy(findCall("stop", h), "blocking top must stop the previously-playing slot")
    T.eq(civvaccess_shared.activeBeacons["2"], true, "active flag must stay set across stop")
end

function M.test_refresh_treats_beaconsTransparent_as_passthrough()
    -- The Tab unit-action menu and the target / strike / gift pickers all
    -- mark themselves beaconsTransparent so the policy walk skips past
    -- them and the cursor-on-map layer below stays the effective top.
    -- Beacons must keep playing in those flows.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setTransparentTargetingStack()
    civvaccess_shared.bookmarks["1"] = { x = 1, y = 0 }
    civvaccess_shared.activeBeacons["1"] = true
    Cursor._x, Cursor._y = 0, 0
    audio._reset()

    Beacons.refresh()

    local h = civvaccess_shared.beaconHandles["1"]
    T.truthy(findCall("play", h), "beaconsTransparent handler must not silence the policy")
end

function M.test_refresh_idempotent_under_steady_state()
    -- audio.play in the proxy re-arms the source (stop + seek-to-0 +
    -- start), so a redundant refresh that re-plays a still-playing slot
    -- would click on every push / pop. The per-slot beaconPlaying flag
    -- guards against that: a refresh whose desired state matches the
    -- current state must produce zero audio calls for that slot.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBaselineScannerStack()
    civvaccess_shared.bookmarks["3"] = { x = 1, y = 0 }
    civvaccess_shared.activeBeacons["3"] = true
    Cursor._x, Cursor._y = 0, 0
    Beacons.refresh()

    audio._reset()
    Beacons.refresh()

    local h = civvaccess_shared.beaconHandles["3"]
    T.eq(findCall("play", h), nil, "no replay on a redundant refresh")
    T.eq(findCall("stop", h), nil, "no stop on a redundant refresh")
end

function M.test_refresh_desync_clears_flag_and_warns()
    -- Active flag set but bookmark gone. resetForNewGame is supposed to
    -- keep them in lockstep; reaching this state means a bug elsewhere.
    -- refresh stops the voice (which may have been looping with stale
    -- params), drops the per-slot playing flag, clears the active flag,
    -- and logs once so the warning doesn't refire on every refresh.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBaselineScannerStack()
    civvaccess_shared.activeBeacons["9"] = true
    -- Bookmark "9" intentionally absent.
    Cursor._x, Cursor._y = 0, 0
    audio._reset()
    local warned
    Log.warn = function(msg)
        warned = msg
    end

    Beacons.refresh()

    T.eq(civvaccess_shared.activeBeacons["9"], false, "stale-active flag must be cleared")
    T.truthy(warned and warned:find("9"), "warn must fire and identify the slot")
    local h = civvaccess_shared.beaconHandles["9"]
    T.eq(findCall("play", h), nil, "no play on a desync slot")
end

-- ===== resetForNewGame =====

function M.test_resetForNewGame_stops_playing_voices_and_clears_active_table()
    -- resetForNewGame clears the active table and routes through refresh,
    -- which stops only the slots that were actually playing. The previous
    -- "blanket stop every handle" was conservative against a save/load
    -- transition leaking running voices; refresh's per-slot tracking is
    -- precise instead -- the slots not playing don't need stop calls
    -- because they're not playing.
    setup()
    Beacons.loadAll()
    Beacons.resetForNewGame()
    setBaselineScannerStack()
    civvaccess_shared.bookmarks["1"] = { x = 1, y = 0 }
    civvaccess_shared.bookmarks["2"] = { x = 0, y = 1 }
    civvaccess_shared.activeBeacons["1"] = true
    civvaccess_shared.activeBeacons["2"] = true
    Cursor._x, Cursor._y = 0, 0
    -- Drive an audible refresh so both slots are marked playing.
    Beacons.refresh()
    audio._reset()

    Beacons.resetForNewGame()

    T.eq(civvaccess_shared.activeBeacons["1"], nil)
    T.eq(civvaccess_shared.activeBeacons["2"], nil)
    local h1 = civvaccess_shared.beaconHandles["1"]
    local h2 = civvaccess_shared.beaconHandles["2"]
    T.truthy(findCall("stop", h1), "previously-playing slot 1 must be stopped")
    T.truthy(findCall("stop", h2), "previously-playing slot 2 must be stopped")
end

return M

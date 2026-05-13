-- Beacon master volume. Drives the proxy's dedicated beacon sound group
-- (g_beaconGroup in src/proxy/proxy.c), which sits in parallel with the
-- per-hex group g_mainGroup that the main "Master volume" slider feeds.
-- The two faders are fully independent: moving one does not attenuate
-- the other. This is what lets the user balance bookmark beacons against
-- the per-hex terrain cues -- raise beacons to make them dominant, drop
-- them to fade them into the background, lower master to quiet the per-
-- hex layer without losing beacon clarity, etc.
--
-- Range. Slider operates in [0, 1] and is the absolute group volume; the
-- engine master sits at 1.0 in normal operation and only drops to 0 on
-- focus loss, so the slider value passes through unmodified.
--
-- Set is pushed straight to the proxy via audio.set_beacon_master_volume.
-- Get is cached on civvaccess_shared so repeat reads in the Settings
-- screen don't round-trip through user data. BeaconVolume.restore() at
-- in-game boot mirrors VolumeControl.restore -- the proxy's group
-- volume defaults to the static initializer until Lua pushes the
-- persisted value over it.
--
-- Migration. Prior to this build the slider stored a [0, 5] multiplier
-- on the engine master under "BeaconMaxVolume". To preserve users'
-- effective beacon level across the format change, BeaconVolume.get()
-- detects an absent new pref with a present old pref and writes the
-- migrated value once: new = old_multiplier * persisted_master, clamped
-- to [0, 1]. After that, the new pref is the source of truth and the
-- old key is left orphaned (no read path remains).

BeaconVolume = BeaconVolume or {}

local PREF_KEY = "BeaconGroupVolume"
local OLD_PREF_KEY = "BeaconMaxVolume"

-- Match VolumeControl's DEFAULT_VOLUME so a fresh install with neither
-- pref persisted plays beacons at the same effective level as the old
-- build's defaults (multiplier 1.0 * engine master 0.1 = 0.1).
local DEFAULT = 0.1

-- Slider top. The proxy clamps group volume to [0, 1] and the Settings
-- UI maps slider position [0, 1] to volume [0, MAX], so exposing this
-- as 1.0 keeps the slider semantics simple: handle position equals
-- group volume directly.
BeaconVolume.MAX = 1.0

local function clamp(v)
    if type(v) ~= "number" then
        return DEFAULT
    end
    if v < 0 then
        return 0
    end
    if v > BeaconVolume.MAX then
        return BeaconVolume.MAX
    end
    return v
end

-- Returns the migrated value if the old pref is present and the new one
-- is not. Otherwise returns nil and the caller treats that as "no
-- migration needed." Reads VolumeControl-level state directly via Prefs
-- so the migration does not depend on VolumeControl having been loaded
-- (BeaconVolume can be a shared-Context include from a path that
-- doesn't import VolumeControl).
local function migrateFromOldPref()
    local newVal = Prefs.getFloat(PREF_KEY, nil)
    if newVal ~= nil then
        return nil
    end
    local oldMultiplier = Prefs.getFloat(OLD_PREF_KEY, nil)
    if oldMultiplier == nil then
        return nil
    end
    -- Mirrors VolumeControl.lua's DEFAULT_VOLUME. If MasterVolume isn't
    -- set, the user was on the old default master (0.1), so use that.
    local oldMaster = Prefs.getFloat("MasterVolume", 0.1)
    local migrated = clamp(oldMultiplier * oldMaster)
    Prefs.setFloat(PREF_KEY, migrated)
    Log.info("BeaconVolume: migrated old multiplier "
        .. tostring(oldMultiplier) .. " * master "
        .. tostring(oldMaster) .. " -> group volume "
        .. tostring(migrated))
    return migrated
end

function BeaconVolume.get()
    if civvaccess_shared.beaconGroupVolume == nil then
        local migrated = migrateFromOldPref()
        if migrated ~= nil then
            civvaccess_shared.beaconGroupVolume = migrated
        else
            civvaccess_shared.beaconGroupVolume = clamp(Prefs.getFloat(PREF_KEY, DEFAULT))
        end
    end
    return civvaccess_shared.beaconGroupVolume
end

function BeaconVolume.set(v)
    local clamped = clamp(v)
    civvaccess_shared.beaconGroupVolume = clamped
    Prefs.setFloat(PREF_KEY, clamped)
    if audio ~= nil then
        audio.set_beacon_master_volume(clamped)
    end
end

-- Push the persisted value to the proxy. Call after PlotAudio.loadAll
-- so the audio engine is initialized; before that, audio.set_beacon_
-- master_volume is a no-op against the (uninitialized) group and our
-- intent would silently miss the first ensure_audio's seed call.
function BeaconVolume.restore()
    local v = BeaconVolume.get()
    if audio ~= nil then
        audio.set_beacon_master_volume(v)
    end
end

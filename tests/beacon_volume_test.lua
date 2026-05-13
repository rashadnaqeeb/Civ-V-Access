-- BeaconVolume tests. Exercises the get / set / restore pipeline plus
-- the one-time migration from the old "BeaconMaxVolume" multiplier pref
-- to the new "BeaconGroupVolume" absolute group volume. Prefs is monkey-
-- patched to a fake handle so reads / writes round-trip without needing
-- the engine's user-data file.

local T = require("support")
local M = {}

local prefsStore

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    civvaccess_shared = {}
    audio._reset()

    -- Fake Prefs. Returns the stored value when present, the default
    -- otherwise (matching the real getFloat contract). The real Prefs
    -- module self-degrades to defaults when Modding is absent, which
    -- would hide bugs in our setter (no roundtrip).
    prefsStore = {}
    Prefs.getFloat = function(key, default)
        local v = prefsStore[key]
        if v == nil then
            return default
        end
        return v
    end
    Prefs.setFloat = function(key, v)
        prefsStore[key] = v
    end

    dofile("src/dlc/UI/Shared/CivVAccess_BeaconVolume.lua")
end

function M.test_get_returns_default_on_first_read_with_no_prefs()
    setup()
    -- Default matches VolumeControl's DEFAULT_VOLUME so a fresh install
    -- plays beacons at the same level as the old build's defaults.
    T.eq(BeaconVolume.get(), 0.1)
end

function M.test_get_caches_on_shared_after_first_read()
    setup()
    BeaconVolume.get()
    T.eq(civvaccess_shared.beaconGroupVolume, 0.1, "first get hydrates the cache")
end

function M.test_get_reads_persisted_new_pref()
    setup()
    prefsStore["BeaconGroupVolume"] = 0.42
    T.eq(BeaconVolume.get(), 0.42)
end

function M.test_set_persists_to_new_pref_key()
    setup()
    BeaconVolume.set(0.3)
    T.eq(prefsStore["BeaconGroupVolume"], 0.3)
end

function M.test_set_pushes_to_audio_proxy_beacon_master_volume()
    setup()
    BeaconVolume.set(0.55)
    local last = audio._calls[#audio._calls]
    T.eq(
        last.op,
        "set_beacon_master_volume",
        "set must reach the proxy via the beacon-master entry point, not set_master_volume"
    )
    T.eq(last.v, 0.55)
end

function M.test_set_clamps_above_one()
    setup()
    BeaconVolume.set(2.0)
    T.eq(BeaconVolume.get(), 1, "absolute group volume must clamp at MAX=1")
    T.eq(prefsStore["BeaconGroupVolume"], 1)
end

function M.test_set_clamps_below_zero()
    setup()
    BeaconVolume.set(-0.5)
    T.eq(BeaconVolume.get(), 0)
    T.eq(prefsStore["BeaconGroupVolume"], 0)
end

function M.test_restore_pushes_persisted_value_to_proxy()
    setup()
    prefsStore["BeaconGroupVolume"] = 0.2
    BeaconVolume.restore()
    local last = audio._calls[#audio._calls]
    T.eq(last.op, "set_beacon_master_volume")
    T.eq(last.v, 0.2)
end

function M.test_migration_from_old_multiplier_times_master()
    -- Old pref was a [0, 5] multiplier on the engine master under
    -- "BeaconMaxVolume". Effective beacon level was old_multiplier *
    -- master. To preserve effective level across the format change, the
    -- first read converts old_multiplier * MasterVolume into the new
    -- absolute group volume and writes it under the new key.
    setup()
    prefsStore["BeaconMaxVolume"] = 2.0
    prefsStore["MasterVolume"] = 0.3
    -- (no BeaconGroupVolume yet)
    T.eq(BeaconVolume.get(), 0.6, "migrated value = 2.0 * 0.3")
    T.eq(prefsStore["BeaconGroupVolume"], 0.6, "migration must persist to the new key")
end

function M.test_migration_clamps_to_one()
    setup()
    -- A user who had the old slider maxed (5x) with master cranked (0.5)
    -- would compute to 2.5; the new absolute scale caps at 1.0. Make
    -- sure the migration clamps rather than persisting an out-of-range
    -- value.
    prefsStore["BeaconMaxVolume"] = 5.0
    prefsStore["MasterVolume"] = 0.5
    T.eq(BeaconVolume.get(), 1.0, "migration must clamp to [0, 1]")
end

function M.test_migration_skipped_when_new_pref_already_set()
    -- If the user already has the new pref, the old pref must not
    -- overwrite it (else opening Settings once on the new build then
    -- launching again would re-migrate and clobber the user's choice).
    setup()
    prefsStore["BeaconMaxVolume"] = 4.0
    prefsStore["MasterVolume"] = 0.5
    prefsStore["BeaconGroupVolume"] = 0.7
    T.eq(BeaconVolume.get(), 0.7, "existing new pref wins over migration")
end

function M.test_migration_uses_master_default_when_master_unset()
    -- The old default master was 0.1; users who never opened the
    -- VolumeControl slider have no MasterVolume key. Migration must
    -- fall back to that 0.1 default so the conversion math still runs.
    setup()
    prefsStore["BeaconMaxVolume"] = 2.0
    -- no MasterVolume
    T.eq(BeaconVolume.get(), 0.2, "migrated value = 2.0 * 0.1 (default master)")
end

return M

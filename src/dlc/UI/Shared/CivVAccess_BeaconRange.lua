-- Audible hex distance for the beacon volume falloff. Beacons fade
-- linearly from full volume at distance 0 to silent at this many hexes;
-- past it, the bookmark's voice goes silent. Tuning the value lets the
-- user pick how aggressively beacons "shrink down" as they walk away
-- from a bookmark cell -- a small range turns beacons into a
-- here-or-not signal, a large range lets distant beacons stay barely
-- audible across the whole map.
--
-- Stored as an integer hex count to keep the spoken value clean
-- ("audible distance, 30 hexes"). The Settings UI's VirtualSlider
-- expects a [0,1] handle, so toUnit / fromUnit map between the
-- normalized form and the integer range with rounding to STEP-multiples
-- so each slider tick lands on a whole-hex value.
--
-- Beacons.updateBeaconParams reads BeaconRange.get() live each cursor
-- step, so a slider tweak takes effect on the next move without any
-- explicit notification path.

BeaconRange = BeaconRange or {}

local PREF_KEY = "BeaconAudibleHexDistance"
-- Default mirrors the previous hard-coded VOL_MAX_DIST so users who never
-- touched the setting hear the same falloff they had before the slider
-- existed.
local DEFAULT = 30
-- Range bounds. MIN at 5 keeps the falloff a meaningful gradient (anything
-- smaller and the beacon is just a here / not-here ping). MAX at 100
-- comfortably covers Civ V's standard map sizes (huge is 128x80, but hex
-- PlotDistance across that diagonal is well under 100 in practice). STEP
-- 1 quantizes to whole hexes; the user wanted single-hex precision on
-- arrow-key nudges. BIG_STEP is 20 so PgUp/PgDn (or whatever the big-
-- nudge binding is) still spans the range in five presses.
local MIN = 5
local MAX = 100
local STEP = 1
local BIG_STEP = 20

local function clamp(v)
    if type(v) ~= "number" then
        return DEFAULT
    end
    v = math.floor(v + 0.5)
    if v < MIN then
        return MIN
    end
    if v > MAX then
        return MAX
    end
    return v
end

function BeaconRange.get()
    if civvaccess_shared.beaconAudibleHexes == nil then
        civvaccess_shared.beaconAudibleHexes = clamp(Prefs.getInt(PREF_KEY, DEFAULT))
    end
    return civvaccess_shared.beaconAudibleHexes
end

function BeaconRange.set(hexes)
    local clamped = clamp(hexes)
    civvaccess_shared.beaconAudibleHexes = clamped
    Prefs.setInt(PREF_KEY, clamped)
end

-- VirtualSlider helpers. The slider operates in [0,1]; the labelFn /
-- setValue closures in Settings round to a STEP-multiple inside [MIN,
-- MAX] so each tick lands on an integer hex value.
function BeaconRange.toUnit(hexes)
    return (clamp(hexes) - MIN) / (MAX - MIN)
end

function BeaconRange.fromUnit(t)
    if type(t) ~= "number" then
        return DEFAULT
    end
    if t < 0 then
        t = 0
    end
    if t > 1 then
        t = 1
    end
    local raw = MIN + t * (MAX - MIN)
    local stepped = math.floor(raw / STEP + 0.5) * STEP
    if stepped < MIN then
        stepped = MIN
    end
    if stepped > MAX then
        stepped = MAX
    end
    return stepped
end

-- Slider step sizes in [0,1] terms so a small nudge maps to one hex
-- and a big nudge to BIG_STEP hexes. Exposed so the Settings caller
-- doesn't need to know the bounds.
BeaconRange.STEP_UNIT = STEP / (MAX - MIN)
BeaconRange.BIG_STEP_UNIT = BIG_STEP / (MAX - MIN)

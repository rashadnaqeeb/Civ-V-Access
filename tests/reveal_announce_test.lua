-- RevealAnnounce hide-direction tests. The reveal direction has been in
-- production without dedicated tests; this suite covers the new hide
-- diff so its diff / aggregation / install-time priming each have a
-- distinct failure mode the suite would catch.

local T = require("support")
local M = {}

-- ===== Fixture builders =====

local function makeUnit(opts)
    opts = opts or {}
    local u = {
        _id = opts.id or 1,
        _owner = opts.owner,
        _unitType = opts.unitType or 100,
        _plot = opts.plot,
        _invisible = opts.invisible or false,
    }
    function u:GetID()
        return self._id
    end
    -- The reveal direction walks plots and reads unit:GetOwner() to
    -- bucket the unit; the hide direction iterates Players[i]:Units()
    -- and uses i directly. installForeign stamps _owner so the reveal
    -- path can find it.
    function u:GetOwner()
        return self._owner
    end
    function u:GetUnitType()
        return self._unitType
    end
    function u:GetPlot()
        return self._plot
    end
    function u:IsInvisible(_team, _debug)
        return self._invisible
    end
    return u
end

local function makePlayer(opts)
    opts = opts or {}
    local p = {
        _alive = opts.alive ~= false,
        _barb = opts.barb or false,
        _team = opts.team or 0,
        _adj = opts.adj or "TXT_KEY_CIV_ROME_ADJECTIVE",
        _units = opts.units or {},
    }
    function p:IsAlive()
        return self._alive
    end
    function p:IsBarbarian()
        return self._barb
    end
    function p:GetTeam()
        return self._team
    end
    function p:GetCivilizationAdjectiveKey()
        return self._adj
    end
    function p:Units()
        local i = 0
        return function()
            i = i + 1
            return self._units[i]
        end
    end
    function p:GetUnitByID(id)
        for _, u in ipairs(self._units) do
            if u:GetID() == id then
                return u
            end
        end
        return nil
    end
    return p
end

local function visiblePlot()
    return T.fakePlot({ visible = true })
end

local function fogPlot()
    return T.fakePlot({ visible = false })
end

-- ===== Test setup =====

-- Captured listeners and TickPump.runOnce calls so tests can introspect
-- whether the recorders gated on the enabled flag.
local fowListeners
local revealedListeners
local tickRunOnceCount

local function setup()
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Players = {}
    Teams = { [0] = T.fakeTeam() }
    GameInfo = {
        Units = {
            [100] = { Description = "TXT_KEY_UNIT_WARRIOR" },
            [101] = { Description = "TXT_KEY_UNIT_SPEARMAN" },
        },
        Resources = {},
        Features = {},
        Improvements = {},
    }
    GameDefines = GameDefines or {}
    GameDefines.MAX_CIV_PLAYERS = 2
    civvaccess_shared = { revealAnnounce = true }

    Text = Text or {}
    Text.key = function(k)
        if k == "TXT_KEY_CIV_ROME_ADJECTIVE" then
            return "Roman"
        end
        if k == "TXT_KEY_CIV_ARABIA_ADJECTIVE" then
            return "Arabian"
        end
        if k == "TXT_KEY_CIV_BARBARIAN_ADJECTIVE" then
            return "Barbarian"
        end
        if k == "TXT_KEY_UNIT_WARRIOR" then
            return "Warrior"
        end
        if k == "TXT_KEY_UNIT_SPEARMAN" then
            return "Spearman"
        end
        if k == "TXT_KEY_CIVVACCESS_HIDDEN_HEADER" then
            return "Hidden"
        end
        if k == "TXT_KEY_CIVVACCESS_REVEAL_HEADER" then
            return "Revealed"
        end
        return k
    end
    Text.format = function(k, arg)
        if k == "TXT_KEY_CIVVACCESS_REVEAL_ENEMY" then
            return "Enemy: " .. tostring(arg)
        end
        if k == "TXT_KEY_CIVVACCESS_REVEAL_UNITS" then
            return "Units: " .. tostring(arg)
        end
        if k == "TXT_KEY_CIVVACCESS_REVEAL_COUNT" then
            return tostring(arg) .. " tiles revealed"
        end
        return k
    end

    SpeechPipeline = {
        _calls = {},
    }
    SpeechPipeline.speakInterrupt = function(s)
        SpeechPipeline._calls[#SpeechPipeline._calls + 1] = { mode = "interrupt", text = s }
    end
    SpeechPipeline.speakQueued = function(s)
        SpeechPipeline._calls[#SpeechPipeline._calls + 1] = { mode = "queued", text = s }
    end

    fowListeners = {}
    revealedListeners = {}
    Events = Events or {}
    Events.HexFOWStateChanged = {
        Add = function(fn)
            fowListeners[#fowListeners + 1] = fn
        end,
    }
    GameEvents = {
        CivVAccessPlotRevealed = {
            Add = function(fn)
                revealedListeners[#revealedListeners + 1] = fn
            end,
        },
    }

    -- TickPump stub. RevealAnnounce.scheduleFlush calls TickPump.frame
    -- and runOnce; tests count runOnce invocations to verify the
    -- enabled-flag gate without exercising the real flush queue.
    tickRunOnceCount = 0
    TickPump = {
        runOnce = function(_fn)
            tickRunOnceCount = tickRunOnceCount + 1
        end,
        frame = function()
            return 0
        end,
    }

    -- Reset module so installListeners primes a fresh snapshot.
    RevealAnnounce = nil
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_RevealAnnounce.lua")
end

local function installForeign(id, opts)
    opts = opts or {}
    -- Stamp ownership on each unit so the reveal direction's plot scan
    -- can route plot:GetLayerUnit(...).GetOwner() back to this slot.
    for _, u in ipairs(opts.units or {}) do
        u._owner = id
    end
    Players[id] = makePlayer({
        team = opts.team or id,
        adj = opts.adj,
        barb = opts.barb,
        units = opts.units or {},
    })
    if opts.atWar then
        Teams[0]._atWar[opts.team or id] = true
    end
end

local function fireFOW(plot)
    -- Hex coordinate doesn't matter for the recorder's plot lookup
    -- because we stub Map.GetPlot directly. fowType is also irrelevant:
    -- the recorder filters on plot:IsVisible, not on the integer.
    Map.GetPlot = function(_x, _y)
        return plot
    end
    for _, fn in ipairs(fowListeners) do
        fn({ x = 0, y = 0 }, 0, false)
    end
end

-- ===== Tests =====

-- Snapshot has a hostile unit on a visible plot. Move it to a fogged
-- plot before flushing: hide diff catches it and emits the Hidden line
-- with the Enemy: sub-payload.
function M.test_hostile_unit_walks_into_fog()
    setup()
    local unit = makeUnit({ id = 1, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { unit },
    })
    RevealAnnounce.installListeners()
    unit._plot = fogPlot()
    RevealAnnounce._flush()
    T.eq(#SpeechPipeline._calls, 1, "exactly one queued line")
    T.eq(SpeechPipeline._calls[1].mode, "queued", "hide line uses speakQueued")
    T.eq(SpeechPipeline._calls[1].text, "Hidden: Enemy: Roman Warrior")
end

-- A neutral unit going into fog routes through the Units: sub-payload,
-- not the Enemy: one. Failure mode this catches: bucket cross-wired.
function M.test_neutral_unit_walks_into_fog()
    setup()
    local unit = makeUnit({ id = 1, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { unit },
    })
    RevealAnnounce.installListeners()
    unit._plot = fogPlot()
    RevealAnnounce._flush()
    T.eq(SpeechPipeline._calls[1].text, "Hidden: Units: Roman Warrior")
end

-- A unit removed from its owner's roster (death or capture) drops out
-- of the diff entirely. Without the still-alive guard a killed unit
-- would announce as "Hidden" alongside the combat readout.
function M.test_destroyed_unit_dropped()
    setup()
    local unit = makeUnit({ id = 1, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { unit },
    })
    RevealAnnounce.installListeners()
    Players[1]._units = {}
    RevealAnnounce._flush()
    T.eq(#SpeechPipeline._calls, 0, "destroyed unit must not announce as hidden")
end

-- Unit still visible at flush time means the diff finds nothing. No
-- hide line, no spurious "Hidden:" header without a payload.
function M.test_persistent_unit_no_announce()
    setup()
    local unit = makeUnit({ id = 1, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { unit },
    })
    RevealAnnounce.installListeners()
    RevealAnnounce._flush()
    T.eq(#SpeechPipeline._calls, 0, "persistent units do not announce")
end

-- Hostile and neutral units both hide in the same flush. The line
-- carries both sub-payloads under the single Hidden: header,
-- separated by ". ". Reveal-payload buckets ordering (enemy then
-- units) is preserved in the hide line.
function M.test_enemy_and_neutral_split_into_one_line()
    setup()
    local hostile = makeUnit({ id = 1, plot = visiblePlot() })
    local neutral = makeUnit({ id = 2, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { hostile },
    })
    installForeign(2, {
        adj = "TXT_KEY_CIV_ARABIA_ADJECTIVE",
        units = { neutral },
    })
    RevealAnnounce.installListeners()
    hostile._plot = fogPlot()
    neutral._plot = fogPlot()
    RevealAnnounce._flush()
    T.eq(#SpeechPipeline._calls, 1, "single combined hide line")
    T.eq(SpeechPipeline._calls[1].text,
        "Hidden: Enemy: Roman Warrior. Units: Arabian Warrior",
        "enemy sub-payload precedes units sub-payload")
end

-- Three same-type same-civ hides aggregate with a count prefix.
-- Failure mode: each instance listed individually, e.g.
-- "Hidden: Enemy: Roman Warrior, Roman Warrior, Roman Warrior".
function M.test_aggregation_with_count_prefix()
    setup()
    local a = makeUnit({ id = 1, plot = visiblePlot() })
    local b = makeUnit({ id = 2, plot = visiblePlot() })
    local c = makeUnit({ id = 3, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { a, b, c },
    })
    RevealAnnounce.installListeners()
    a._plot = fogPlot()
    b._plot = fogPlot()
    c._plot = fogPlot()
    RevealAnnounce._flush()
    T.eq(SpeechPipeline._calls[1].text, "Hidden: Enemy: 3 Roman Warrior")
end

-- A flush with neither reveal events nor anything left to hide is
-- silent. This guards against the early-return removal accidentally
-- reintroducing a "Revealed" or "Hidden" line spoken with no payload.
function M.test_empty_flush_silent()
    setup()
    RevealAnnounce.installListeners()
    RevealAnnounce._flush()
    T.eq(#SpeechPipeline._calls, 0, "empty flush stays silent")
end

-- The recorder gates on isEnabled before scheduling a flush. When
-- disabled, firing a HexFOWStateChanged event must NOT call
-- TickPump.runOnce, which is the sole side effect that kicks off a
-- flush in production.
function M.test_disabled_recorder_does_not_schedule()
    setup()
    civvaccess_shared.revealAnnounce = false
    RevealAnnounce.installListeners()
    fireFOW(fogPlot())
    T.eq(tickRunOnceCount, 0,
        "disabled flag must short-circuit the recorder before scheduleFlush")
end

-- Reveal direction collects unit metadata (civ adj + name) and runs it
-- through formatUnitList, same as hide. Failure modes this test
-- catches: reveal drops the civ adjective ("Enemy: Warrior, Warrior"),
-- reveal lists each instance separately ("Roman Warrior, Roman
-- Warrior" instead of "2 Roman Warrior"), or the wrong sub-payload key
-- routes the line ("Units:" instead of "Enemy:" for an at-war owner).
function M.test_reveal_uses_civ_adjective_and_aggregates()
    setup()
    local unit1 = makeUnit({ id = 1 })
    local unit2 = makeUnit({ id = 2 })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { unit1, unit2 },
    })
    -- Plot the reveal walks. Both units sit here so the plot scan
    -- collects them as two enemyUnits entries that aggregate to "2".
    local plot = T.fakePlot({
        visible = true,
        plotIndex = 1,
        layerUnits = { unit1, unit2 },
    })
    -- shouldSkipPlot calls GetImprovementType, which fakePlot doesn't
    -- expose. NO_IMPROVEMENT keeps the plot in announcePlots.
    plot.GetImprovementType = function()
        return -1
    end
    unit1._plot = plot
    unit2._plot = plot
    Map.GetPlot = function()
        return plot
    end
    Map.GetPlotByIndex = function(idx)
        if idx == 1 then
            return plot
        end
        return nil
    end
    ToGridFromHex = function(hx, hy)
        return hx, hy
    end

    RevealAnnounce.installListeners()
    -- Fire CivVAccessPlotRevealed so the plot enters firstReveals
    -- (driving the count) and HexFOWStateChanged so it enters
    -- nowVisible (driving the unit-payload collection).
    for _, fn in ipairs(revealedListeners) do
        fn(0, 0, 0)
    end
    for _, fn in ipairs(fowListeners) do
        fn({ x = 0, y = 0 }, 0, false)
    end

    RevealAnnounce._flush()

    T.eq(#SpeechPipeline._calls, 1, "single combined reveal line")
    T.eq(SpeechPipeline._calls[1].text,
        "1 tiles revealed: Enemy: 2 Roman Warrior",
        "civ adjective prefixes the unit and identical units aggregate")
end

-- Snapshot is rebuilt at the end of every flush. After the first hide
-- announces, a second flush with the same state must NOT re-announce
-- the same unit -- the snapshot now reflects the post-flush world, so
-- there's no diff. Failure mode: snapshot updates skipped, or updated
-- before the diff runs.
function M.test_snapshot_refreshes_after_flush()
    setup()
    local unit = makeUnit({ id = 1, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { unit },
    })
    RevealAnnounce.installListeners()
    unit._plot = fogPlot()
    RevealAnnounce._flush()
    T.eq(#SpeechPipeline._calls, 1, "first flush announces")
    RevealAnnounce._flush()
    T.eq(#SpeechPipeline._calls, 1, "second flush silent -- snapshot already reflects the hide")
end

return M

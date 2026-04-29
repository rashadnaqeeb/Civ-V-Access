-- ForeignUnitWatch: snapshot-diff at turn boundaries, four-line output
-- (hostile/neutral entered/left). Tests exercise the diff buckets, the
-- skip-rules, and the deterministic aggregation ordering.

local T = require("support")
local M = {}

-- ===== Fixture builders =====

-- Minimal foreign-unit fixture surface: GetID, GetUnitType, GetPlot,
-- IsInvisible. Enough for buildVisibleSet's filter and unitMetadata's
-- lookups. The unit's plot is provided by the caller so visibility can
-- be controlled per-test.
local function makeUnit(opts)
    opts = opts or {}
    local u = {
        _id = opts.id or 1,
        _unitType = opts.unitType or 100,
        _plot = opts.plot,
        _invisible = opts.invisible or false,
    }
    function u:GetID()
        return self._id
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

-- Player fixture supports IsAlive, IsBarbarian, GetTeam, GetCivilization-
-- AdjectiveKey, Units(), GetUnitByID. The diff calls all of these.
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

local function setup()
    -- Game.GetActivePlayer returns 0; activeTeam returns 0. Foreign
    -- player slots start at 1+ so they don't collide with active.
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
            [102] = { Description = "TXT_KEY_UNIT_WORKER" },
        },
    }
    GameDefines = GameDefines or {}
    GameDefines.MAX_CIV_PLAYERS = 2  -- iterate slots 0..2 inclusive (active + 2 foreign)
    civvaccess_shared = {
        foreignUnitWatchAnnounce = true,
    }

    Text = Text or {}
    Text.key = function(k)
        -- Resolve the same TXT keys the strings file would provide.
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
        if k == "TXT_KEY_UNIT_WORKER" then
            return "Worker"
        end
        return k
    end
    Text.format = function(k, list)
        if k == "TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED" then
            return "New hostile units in view: " .. list
        end
        if k == "TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT" then
            return "Hostile units no longer in view: " .. list
        end
        if k == "TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED" then
            return "New neutral units in view: " .. list
        end
        if k == "TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT" then
            return "Neutral units no longer in view: " .. list
        end
        return k
    end

    -- SpeechPipeline capture so tests can assert what was spoken.
    SpeechPipeline = {
        _calls = {},
    }
    SpeechPipeline.speakInterrupt = function(s)
        SpeechPipeline._calls[#SpeechPipeline._calls + 1] = { mode = "interrupt", text = s }
    end
    SpeechPipeline.speakQueued = function(s)
        SpeechPipeline._calls[#SpeechPipeline._calls + 1] = { mode = "queued", text = s }
    end

    Events = {
        ActivePlayerTurnEnd = { Add = function(_) end },
        ActivePlayerTurnStart = { Add = function(_) end },
    }

    -- Reset module so installListeners runs fresh.
    ForeignUnitWatch = nil
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ForeignUnitWatch.lua")
end

-- Install a foreign player at slot `id` with units on visible plots.
local function installForeign(id, opts)
    opts = opts or {}
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

local function speechTexts()
    local out = {}
    for _, c in ipairs(SpeechPipeline._calls) do
        out[#out + 1] = c.text
    end
    return out
end

-- ===== Tests =====

function M.test_empty_initial_state_no_announce()
    setup()
    ForeignUnitWatch.installListeners()
    -- Boot prime then immediate TurnStart (simulates load with no foreigners).
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "no speech when there's nothing to diff")
    T.eq(civvaccess_shared.foreignUnitDelta, nil, "delta cleared when empty")
end

function M.test_neutral_unit_enters_view()
    setup()
    ForeignUnitWatch.installListeners()  -- prime: empty
    -- TurnEnd captures empty snapshot.
    ForeignUnitWatch._onTurnEnd()
    -- Now a foreign neutral unit becomes visible.
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 1)
    T.eq(SpeechPipeline._calls[1].mode, "queued", "all lines queue")
    T.eq(SpeechPipeline._calls[1].text, "New neutral units in view: Roman Warrior")
end

function M.test_hostile_unit_enters_view()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 1)
    T.eq(SpeechPipeline._calls[1].text, "New hostile units in view: Roman Warrior")
end

function M.test_unit_walks_into_fog()
    setup()
    ForeignUnitWatch.installListeners()
    -- Snapshot has the unit (visible).
    local plot = visiblePlot()
    local unit = makeUnit({ id = 1, plot = plot })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { unit },
    })
    ForeignUnitWatch._onTurnEnd()
    -- Move unit to a fogged plot.
    unit._plot = fogPlot()
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 1)
    T.eq(SpeechPipeline._calls[1].text, "Neutral units no longer in view: Roman Warrior")
end

function M.test_unit_destroyed_silently_drops()
    setup()
    ForeignUnitWatch.installListeners()
    local plot = visiblePlot()
    local unit = makeUnit({ id = 1, plot = plot })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { unit },
    })
    ForeignUnitWatch._onTurnEnd()
    -- Remove the unit from its owner entirely (simulates death).
    Players[1]._units = {}
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "destroyed unit drops, no left announce")
end

function M.test_persistent_unit_no_delta()
    setup()
    ForeignUnitWatch.installListeners()
    local plot = visiblePlot()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { makeUnit({ id = 1, plot = plot }) },
    })
    ForeignUnitWatch._onTurnEnd()
    -- Unit still visible at TurnStart.
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "no speech for persistent units")
end

function M.test_war_declared_mid_turn_unit_still_visible()
    setup()
    ForeignUnitWatch.installListeners()
    local plot = visiblePlot()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { makeUnit({ id = 1, plot = plot }) },
    })
    -- Snapshot: unit visible as neutral (not at war).
    ForeignUnitWatch._onTurnEnd()
    -- Mid-AI-turn: war declared.
    Teams[0]._atWar[1] = true
    -- TurnStart: same unit, now hostile.
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 1, "war reclassification synthesizes one announcement")
    T.eq(SpeechPipeline._calls[1].text, "New hostile units in view: Roman Warrior",
        "neutral->hostile while in view announces as hostile entered")
end

function M.test_peace_declared_mid_turn_no_announce()
    setup()
    ForeignUnitWatch.installListeners()
    local plot = visiblePlot()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = plot }) },
    })
    ForeignUnitWatch._onTurnEnd()
    -- Peace declared mid-turn.
    Teams[0]._atWar[1] = false
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "hostile->neutral while in view does not announce")
end

function M.test_aggregation_same_civ_same_unit_type()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = {
            makeUnit({ id = 1, plot = visiblePlot() }),
            makeUnit({ id = 2, plot = visiblePlot() }),
            makeUnit({ id = 3, plot = visiblePlot() }),
        },
    })
    ForeignUnitWatch._onTurnStart()
    T.eq(SpeechPipeline._calls[1].text, "New hostile units in view: 3 Roman Warrior",
        "three same-type same-civ units aggregate with count prefix")
end

function M.test_aggregation_two_civs_alphabetic_order()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    -- Install Rome first, then Arabia. Without sorting the output order
    -- depends on pairs() iteration (non-deterministic).
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    installForeign(2, {
        adj = "TXT_KEY_CIV_ARABIA_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 2, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    -- TXT_KEY_CIV_ARABIA_ADJECTIVE sorts before TXT_KEY_CIV_ROME_ADJECTIVE
    -- alphabetically (sort happens on the raw key, before resolution).
    T.eq(SpeechPipeline._calls[1].text,
        "New hostile units in view: Arabian Warrior, Roman Warrior",
        "civs ordered deterministically by adjective key")
end

function M.test_skip_own_units()
    setup()
    -- Active player slot 0 has units.
    Players[0] = makePlayer({
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "own units never announced")
end

function M.test_skip_teammate_units()
    setup()
    -- Foreign player on the active team (team 0). Should be skipped.
    installForeign(1, {
        team = 0,
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "teammate units never announced")
end

function M.test_skip_dead_player_units()
    setup()
    Players[1] = makePlayer({
        alive = false,
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "dead-player units never announced")
end

function M.test_skip_invisible_units()
    setup()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = visiblePlot(), invisible = true }) },
    })
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "invisible-to-team units never announced")
end

function M.test_skip_units_on_fogged_plots()
    setup()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = fogPlot() }) },
    })
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "units on fogged plots never announced")
end

function M.test_barbarian_treated_as_hostile()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    Players[1] = makePlayer({
        team = 1,
        barb = true,
        adj = "TXT_KEY_CIV_BARBARIAN_ADJECTIVE",
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    T.eq(SpeechPipeline._calls[1].text,
        "New hostile units in view: Barbarian Warrior",
        "barbarians always classified hostile regardless of war state")
end

function M.test_multiple_lines_speech_order()
    setup()
    -- Snapshot has 1 hostile + 1 neutral. Both walk into fog.
    -- TurnStart adds 1 new hostile + 1 new neutral. Expect four lines:
    -- hostile entered, hostile left, neutral entered, neutral left.
    local snapshotHostile = makeUnit({ id = 1, plot = visiblePlot() })
    local snapshotNeutral = makeUnit({ id = 2, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { snapshotHostile },
    })
    installForeign(2, {
        adj = "TXT_KEY_CIV_ARABIA_ADJECTIVE",
        units = { snapshotNeutral },
    })
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    -- Walk both into fog and add a fresh hostile + neutral.
    snapshotHostile._plot = fogPlot()
    snapshotNeutral._plot = fogPlot()
    Players[1]._units[#Players[1]._units + 1] =
        makeUnit({ id = 3, unitType = 101, plot = visiblePlot() })  -- new hostile Spearman
    Players[2]._units[#Players[2]._units + 1] =
        makeUnit({ id = 4, unitType = 102, plot = visiblePlot() })  -- new neutral Worker
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 4, "four buckets, four lines")
    T.eq(SpeechPipeline._calls[1].mode, "queued", "all lines queue")
    T.eq(SpeechPipeline._calls[1].text, "New hostile units in view: Roman Spearman")
    T.eq(SpeechPipeline._calls[2].mode, "queued")
    T.eq(SpeechPipeline._calls[2].text, "Hostile units no longer in view: Roman Warrior")
    T.eq(SpeechPipeline._calls[3].mode, "queued")
    T.eq(SpeechPipeline._calls[3].text, "New neutral units in view: Arabian Worker")
    T.eq(SpeechPipeline._calls[4].mode, "queued")
    T.eq(SpeechPipeline._calls[4].text, "Neutral units no longer in view: Arabian Warrior")
end

function M.test_delta_stored_for_f7()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    T.truthy(civvaccess_shared.foreignUnitDelta, "delta stored")
    T.eq(#civvaccess_shared.foreignUnitDelta, 1, "one non-empty line")
    T.eq(civvaccess_shared.foreignUnitDelta[1], "New hostile units in view: Roman Warrior")
end

function M.test_announce_off_silent_but_delta_still_set()
    setup()
    civvaccess_shared.foreignUnitWatchAnnounce = false
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    T.eq(#SpeechPipeline._calls, 0, "no speech when announce setting is off")
    T.truthy(civvaccess_shared.foreignUnitDelta,
        "delta still written so F7 turn log shows the diff")
    T.eq(#civvaccess_shared.foreignUnitDelta, 1)
end

function M.test_delta_cleared_on_turn_end()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    T.truthy(civvaccess_shared.foreignUnitDelta, "delta set after turn start")
    ForeignUnitWatch._onTurnEnd()
    T.eq(civvaccess_shared.foreignUnitDelta, nil,
        "delta cleared on next turn end so F7 doesn't show stale info")
end

return M

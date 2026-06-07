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

local function makePlayer(opts)
    opts = opts or {}
    return T.fakePlayer({
        adj = opts.adj or "TXT_KEY_CIV_ROME_ADJECTIVE",
        team = opts.team or 0,
        barb = opts.barb,
        alive = opts.alive,
        units = opts.units,
    })
end

local function visiblePlot()
    return T.fakePlot({ visible = true })
end

local function fogPlot()
    return T.fakePlot({ visible = false })
end

-- ===== Test setup =====

local spoken

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
    GameDefines.MAX_CIV_PLAYERS = 2 -- iterate slots 0..2 inclusive (active + 2 foreign)
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

    -- Load the real SpeechPipeline + TextFilter and patch the lower
    -- _speakAction seam so assertions go through the production filter +
    -- gating path. spoken is repopulated on every setup() call.
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()

    Events = {
        ActivePlayerTurnEnd = { Add = function(_) end },
        ActivePlayerTurnStart = { Add = function(_) end },
    }

    -- Reset module so installListeners runs fresh.
    ForeignUnitWatch = nil
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ForeignUnitSnapshot.lua")
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

-- ===== Tests =====

function M.test_empty_initial_state_no_announce()
    setup()
    ForeignUnitWatch.installListeners()
    -- Boot prime then immediate TurnStart (simulates load with no foreigners).
    ForeignUnitWatch._onTurnStart()
    T.eq(#spoken, 0, "no speech when there's nothing to diff")
    T.eq(civvaccess_shared.foreignUnitDelta, nil, "delta cleared when empty")
end

function M.test_neutral_unit_enters_view()
    setup()
    ForeignUnitWatch.installListeners() -- prime: empty
    -- TurnEnd captures empty snapshot.
    ForeignUnitWatch._onTurnEnd()
    -- Now a foreign neutral unit becomes visible.
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    T.eq(#spoken, 1)
    T.eq(spoken[1].interrupt, false, "all lines queue")
    T.eq(spoken[1].text, "New neutral units in view: Roman Warrior")
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
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "New hostile units in view: Roman Warrior")
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
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "Neutral units no longer in view: Roman Warrior")
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
    T.eq(#spoken, 0, "destroyed unit drops, no left announce")
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
    T.eq(#spoken, 0, "no speech for persistent units")
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
    T.eq(#spoken, 1, "war reclassification synthesizes one announcement")
    T.eq(
        spoken[1].text,
        "New hostile units in view: Roman Warrior",
        "neutral->hostile while in view announces as hostile entered"
    )
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
    T.eq(#spoken, 0, "hostile->neutral while in view does not announce")
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
    T.eq(
        spoken[1].text,
        "New hostile units in view: 3 Roman Warrior",
        "three same-type same-civ units aggregate with count prefix"
    )
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
    T.eq(
        spoken[1].text,
        "New hostile units in view: Arabian Warrior, Roman Warrior",
        "civs ordered deterministically by adjective key"
    )
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
    T.eq(#spoken, 0, "own units never announced")
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
    T.eq(#spoken, 0, "teammate units never announced")
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
    T.eq(#spoken, 0, "dead-player units never announced")
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
    T.eq(#spoken, 0, "invisible-to-team units never announced")
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
    T.eq(#spoken, 0, "units on fogged plots never announced")
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
    T.eq(
        spoken[1].text,
        "New hostile units in view: Barbarian Warrior",
        "barbarians always classified hostile regardless of war state"
    )
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
    Players[1]._units[#Players[1]._units + 1] = makeUnit({ id = 3, unitType = 101, plot = visiblePlot() }) -- new hostile Spearman
    Players[2]._units[#Players[2]._units + 1] = makeUnit({ id = 4, unitType = 102, plot = visiblePlot() }) -- new neutral Worker
    ForeignUnitWatch._onTurnStart()
    T.eq(#spoken, 4, "four buckets, four lines")
    T.eq(spoken[1].interrupt, false, "all lines queue")
    T.eq(spoken[1].text, "New hostile units in view: Roman Spearman")
    T.eq(spoken[2].interrupt, false)
    T.eq(spoken[2].text, "Hostile units no longer in view: Roman Warrior")
    T.eq(spoken[3].interrupt, false)
    T.eq(spoken[3].text, "New neutral units in view: Arabian Worker")
    T.eq(spoken[4].interrupt, false)
    T.eq(spoken[4].text, "Neutral units no longer in view: Arabian Warrior")
end

-- Entered units are parked as structured per-unit metadata (owner / unit
-- ids plus the display keys) rather than a flat string, so the F7 popup can
-- re-resolve each to a live plot and offer a jump.
function M.test_entered_units_stored_structured_for_f7()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 7, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    local entered = civvaccess_shared.foreignUnitEntered
    T.truthy(entered, "entered metadata stored")
    T.eq(#entered.hostile, 1, "one hostile entered unit")
    T.eq(entered.hostile[1].ownerId, 1)
    T.eq(entered.hostile[1].unitId, 7)
    T.eq(entered.hostile[1].civAdjKey, "TXT_KEY_CIV_ROME_ADJECTIVE")
    T.eq(entered.hostile[1].unitDescKey, "TXT_KEY_UNIT_WARRIOR")
    T.eq(#entered.neutral, 0, "no neutral entered units")
    -- The string delta carries only left-view lines; nothing left here.
    T.eq(civvaccess_shared.foreignUnitDelta, nil, "no left-view lines, delta nil")
end

-- Left-view units take the other path: an aggregated string on the delta
-- (no jump -- a departed unit's live plot is in fog), and no entered metadata.
function M.test_left_units_stored_as_string_delta()
    setup()
    ForeignUnitWatch.installListeners()
    local unit = makeUnit({ id = 1, plot = visiblePlot() })
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { unit },
    })
    ForeignUnitWatch._onTurnEnd() -- snapshot has the unit visible
    unit._plot = fogPlot() -- it walks into fog
    ForeignUnitWatch._onTurnStart()
    T.truthy(civvaccess_shared.foreignUnitDelta, "left delta stored")
    T.eq(#civvaccess_shared.foreignUnitDelta, 1)
    T.eq(civvaccess_shared.foreignUnitDelta[1], "Hostile units no longer in view: Roman Warrior")
    T.eq(civvaccess_shared.foreignUnitEntered, nil, "nothing entered this turn")
end

function M.test_announce_off_silent_but_entered_still_stored()
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
    T.eq(#spoken, 0, "no speech when announce setting is off")
    T.eq(MessageBuffer._snapshot(), nil, "buffer stays empty when speech is off")
    T.truthy(civvaccess_shared.foreignUnitEntered, "entered metadata still written so F7 shows the diff")
    T.eq(#civvaccess_shared.foreignUnitEntered.hostile, 1)
end

-- With announce on, each spoken diff line also lands in the message buffer
-- under the reveal category: the buffer mirrors what was spoken.
function M.test_announce_on_buffers_reveal_lines()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    local s = MessageBuffer._snapshot()
    T.truthy(s, "buffer populated when announce is on")
    T.eq(#s.entries, 1, "the one diff line buffered")
    T.eq(s.entries[1].text, "New hostile units in view: Roman Warrior")
    T.eq(s.entries[1].category, "reveal")
end

-- Live mutators -----------------------------------------------------------
-- RevealAnnounce calls addEntered / removeEntered as the player's own
-- movement reveals or hides foreign units mid-turn, keeping the F7 entered
-- set current between turn-start diffs.

-- A unit revealed by movement joins its bucket; the same unit revealed again
-- (walked out of view and back) must not double-list.
function M.test_add_entered_appends_and_dedups()
    setup()
    civvaccess_shared.foreignUnitEntered = { hostile = {}, neutral = {} }
    ForeignUnitWatch.addEntered("hostile", {
        { ownerId = 1, unitId = 7, civAdjKey = "TXT_KEY_CIV_ROME_ADJECTIVE", unitDescKey = "TXT_KEY_UNIT_WARRIOR" },
    })
    T.eq(#civvaccess_shared.foreignUnitEntered.hostile, 1, "unit added to hostile bucket")
    ForeignUnitWatch.addEntered("hostile", {
        { ownerId = 1, unitId = 7, civAdjKey = "TXT_KEY_CIV_ROME_ADJECTIVE", unitDescKey = "TXT_KEY_UNIT_WARRIOR" },
    })
    T.eq(#civvaccess_shared.foreignUnitEntered.hostile, 1, "re-revealed unit not duplicated")
end

-- When the turn-start diff parked nothing, the first movement reveal has to
-- create the shared structure (both buckets) rather than index a nil table.
function M.test_add_entered_creates_structure_when_absent()
    setup()
    civvaccess_shared.foreignUnitEntered = nil
    ForeignUnitWatch.addEntered("neutral", {
        { ownerId = 2, unitId = 3, civAdjKey = "TXT_KEY_CIV_ROME_ADJECTIVE", unitDescKey = "TXT_KEY_UNIT_WARRIOR" },
    })
    local entered = civvaccess_shared.foreignUnitEntered
    T.truthy(entered, "structure created when nothing parked this turn")
    T.eq(#entered.neutral, 1)
    T.eq(#entered.hostile, 0, "hostile bucket initialized empty")
end

-- A unit pushed into fog is dropped from whichever bucket holds it; others
-- in both buckets stay.
function M.test_remove_entered_drops_matching_across_buckets()
    setup()
    civvaccess_shared.foreignUnitEntered = {
        hostile = {
            { ownerId = 1, unitId = 7, civAdjKey = "k", unitDescKey = "k" },
            { ownerId = 1, unitId = 8, civAdjKey = "k", unitDescKey = "k" },
        },
        neutral = {
            { ownerId = 2, unitId = 9, civAdjKey = "k", unitDescKey = "k" },
        },
    }
    ForeignUnitWatch.removeEntered({
        { ownerId = 1, unitId = 7 },
        { ownerId = 2, unitId = 9 },
    })
    local entered = civvaccess_shared.foreignUnitEntered
    T.eq(#entered.hostile, 1, "hostile unit 7 removed, 8 kept")
    T.eq(entered.hostile[1].unitId, 8)
    T.eq(#entered.neutral, 0, "neutral unit 9 removed")
end

function M.test_entered_and_delta_cleared_on_turn_end()
    setup()
    ForeignUnitWatch.installListeners()
    ForeignUnitWatch._onTurnEnd()
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { makeUnit({ id = 1, plot = visiblePlot() }) },
    })
    ForeignUnitWatch._onTurnStart()
    T.truthy(civvaccess_shared.foreignUnitEntered, "entered set after turn start")
    ForeignUnitWatch._onTurnEnd()
    T.eq(civvaccess_shared.foreignUnitEntered, nil, "entered cleared on next turn end so F7 doesn't show stale info")
    T.eq(civvaccess_shared.foreignUnitDelta, nil, "delta cleared on next turn end")
end

return M

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

-- Captured listeners and TickPump.runOnce calls so tests can introspect
-- whether the recorders gated on the enabled flag.
local fowListeners
local revealedListeners
local tickRunOnceCount
local spoken

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
        if k == "TXT_KEY_CIVVACCESS_GONE_HEADER" then
            return "Gone"
        end
        if k == "TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND" then
            return " and "
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

    -- Load the real SpeechPipeline + TextFilter and patch the lower
    -- _speakAction seam so assertions go through the production filter +
    -- gating path. spoken is repopulated on every setup() call.
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()

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
    dofile("src/dlc/UI/InGame/CivVAccess_ForeignUnitSnapshot.lua")
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
    T.eq(#spoken, 1, "exactly one queued line")
    T.eq(spoken[1].interrupt, false, "hide line uses speakQueued")
    T.eq(spoken[1].text, "Hidden: Enemy: Roman Warrior")
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
    T.eq(spoken[1].text, "Hidden: Units: Roman Warrior")
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
    T.eq(#spoken, 0, "destroyed unit must not announce as hidden")
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
    T.eq(#spoken, 0, "persistent units do not announce")
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
    T.eq(#spoken, 1, "single combined hide line")
    T.eq(
        spoken[1].text,
        "Hidden: Enemy: Roman Warrior. Units: Arabian Warrior",
        "enemy sub-payload precedes units sub-payload"
    )
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
    T.eq(spoken[1].text, "Hidden: Enemy: 3 Roman Warrior")
end

-- A flush with neither reveal events nor anything left to hide is
-- silent. This guards against the early-return removal accidentally
-- reintroducing a "Revealed" or "Hidden" line spoken with no payload.
function M.test_empty_flush_silent()
    setup()
    RevealAnnounce.installListeners()
    RevealAnnounce._flush()
    T.eq(#spoken, 0, "empty flush stays silent")
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
    T.eq(tickRunOnceCount, 0, "disabled flag must short-circuit the recorder before scheduleFlush")
end

-- Reveal direction collects unit metadata (civ adj + name) and runs it
-- through formatUnitList, same as hide. Failure modes this test
-- catches: reveal drops the civ adjective ("Enemy: Warrior, Warrior"),
-- reveal lists each instance separately ("Roman Warrior, Roman
-- Warrior" instead of "2 Roman Warrior"), or the wrong sub-payload key
-- routes the line ("Units:" instead of "Enemy:" for an at-war owner).
function M.test_reveal_uses_civ_adjective_and_aggregates()
    setup()
    -- Units start in fog so the install-time _visibleUnits snapshot
    -- doesn't capture them; the reveal walk's snapshot gate would
    -- otherwise filter them out as already-known.
    local unit1 = makeUnit({ id = 1, plot = fogPlot() })
    local unit2 = makeUnit({ id = 2, plot = fogPlot() })
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
    -- Player moves; the units are now on a visible plot. Their
    -- _plot becomes the reveal plot AFTER installListeners' snapshot
    -- ran, so they're not in _visibleUnits.
    unit1._plot = plot
    unit2._plot = plot
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

    T.eq(#spoken, 1, "single combined reveal line")
    T.eq(
        spoken[1].text,
        "1 tile revealed: Enemy: 2 Roman Warrior",
        "civ adjective prefixes the unit and identical units aggregate"
    )
end

-- Snapshot gate on the reveal direction. A foreign unit already in
-- _visibleUnits at flush time (entered view during the AI turn, or
-- was already on a known-visible plot) must NOT re-announce when the
-- player's move flickers fog->visible on its plot. Without this gate,
-- walking in / out of vision range of a known foreign unit re-emits
-- "Revealed: enemy <unit>" on every visibility transition, and at
-- TurnStart it duplicates ForeignUnitWatch's "entered" line.
function M.test_known_visible_unit_skipped_on_revisit()
    setup()
    local unit = makeUnit({ id = 1 })
    local plot = T.fakePlot({
        visible = true,
        plotIndex = 1,
        layerUnits = { unit },
    })
    plot.GetImprovementType = function()
        return -1
    end
    unit._plot = plot
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        atWar = true,
        units = { unit },
    })
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

    -- Install snapshots the unit (already on a visible plot).
    RevealAnnounce.installListeners()
    -- Revisit only: HexFOWStateChanged fires, but no CivVAccessPlot-
    -- Revealed (the plot's been revealed before).
    for _, fn in ipairs(fowListeners) do
        fn({ x = 0, y = 0 }, 0, false)
    end
    RevealAnnounce._flush()
    T.eq(#spoken, 0, "known-visible unit must not re-announce on revisit")
end

-- Cities are only announced on first-reveal of their plot. A revisit
-- (HexFOWStateChanged on a previously-revealed plot) must not re-emit
-- "Revealed: <city>" -- once you've discovered London, walking back
-- into vision range shouldn't repeat it. Failure mode this catches:
-- city collection runs unconditionally on every plot in announcePlots.
function M.test_city_not_re_announced_on_revisit()
    setup()
    local plot = T.fakePlot({
        visible = true,
        plotIndex = 1,
        city = {
            GetName = function()
                return "London"
            end,
            GetOwner = function()
                return 1
            end,
        },
    })
    plot.GetImprovementType = function()
        return -1
    end
    -- Foreign owner of the city, on a different team than active.
    installForeign(1, {
        adj = "TXT_KEY_CIV_ROME_ADJECTIVE",
        team = 1,
        units = {},
    })
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
    -- Revisit only -- no CivVAccessPlotRevealed.
    for _, fn in ipairs(fowListeners) do
        fn({ x = 0, y = 0 }, 0, false)
    end
    RevealAnnounce._flush()
    T.eq(#spoken, 0, "known city must not re-announce on a fog->visible flicker")
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
    T.eq(#spoken, 1, "first flush announces")
    RevealAnnounce._flush()
    T.eq(#spoken, 1, "second flush silent -- snapshot already reflects the hide")
end

-- ===== Gone-on-revisit =====

-- Improvement-type indices for the gone tests. Real engine indices are
-- enum-defined; here they're arbitrary positive integers paired with
-- GameInfo.Improvements rows that supply the .Type / .Goody fields the
-- gone-classifier reads.
local CAMP_IMP = 7
local RUIN_IMP = 8

local function installCampAndRuinRows()
    GameInfo.Improvements[CAMP_IMP] = { Type = "IMPROVEMENT_BARBARIAN_CAMP" }
    GameInfo.Improvements[RUIN_IMP] = { Type = "IMPROVEMENT_GOODY_HUT", Goody = true }
end

-- Wire the Map globals RevealAnnounce reads at install time (the
-- bootstrap walk uses GetNumPlots + GetPlotByIndex) AND at flush time
-- (recordNowVisible uses GetPlot + ToGridFromHex; gone walk uses
-- GetPlotByIndex). Must be called BEFORE installListeners so the
-- bootstrap snapshots the right state. plotIndex maps directly to the
-- list index minus one for simplicity.
local function installPlotMap(plots)
    Map.GetPlotByIndex = function(idx)
        for _, p in ipairs(plots) do
            if p:GetPlotIndex() == idx then
                return p
            end
        end
        return nil
    end
    Map.GetNumPlots = function()
        local maxIdx = -1
        for _, p in ipairs(plots) do
            if p:GetPlotIndex() > maxIdx then
                maxIdx = p:GetPlotIndex()
            end
        end
        return maxIdx + 1
    end
    Map.GetPlot = function(x, y)
        for _, p in ipairs(plots) do
            if p:GetX() == x and p:GetY() == y then
                return p
            end
        end
        return nil
    end
    ToGridFromHex = function(hx, hy)
        return hx, hy
    end
end

-- Fire a HexFOWStateChanged event for a plot the player is now seeing
-- again (no first-reveal hook). Assumes installPlotMap already ran so
-- recordNowVisible can find the plot via Map.GetPlot.
local function fireRevisit(plot)
    for _, fn in ipairs(fowListeners) do
        fn({ x = plot:GetX(), y = plot:GetY() }, 0, false)
    end
end

-- Fire BOTH CivVAccessPlotRevealed and HexFOWStateChanged so the plot
-- ends up in _firstReveals AND _nowVisible: the gone-detection gate
-- (`not firstReveals`) must keep these out of the diff.
local function fireFirstReveal(plot)
    for _, fn in ipairs(revealedListeners) do
        fn(0, plot:GetX(), plot:GetY())
    end
    for _, fn in ipairs(fowListeners) do
        fn({ x = plot:GetX(), y = plot:GetY() }, 0, false)
    end
end

-- Camp on a previously-revealed plot, now empty. The bootstrap walk at
-- installListeners snapshots the plot's revealed-type as "camp"; on
-- revisit, GetImprovementType returns -1 (camp cleared in fog), and the
-- diff fires. Singular form drops the count.
function M.test_camp_gone_on_revisit()
    setup()
    installCampAndRuinRows()
    local plot = T.fakePlot({ visible = true, plotIndex = 1, improvement = CAMP_IMP })
    plot.GetImprovementType = function()
        return -1
    end
    installPlotMap({ plot })
    RevealAnnounce.installListeners()
    fireRevisit(plot)
    RevealAnnounce._flush()
    T.eq(#spoken, 1, "single gone line")
    T.eq(spoken[1].interrupt, false, "gone uses speakQueued")
    T.eq(spoken[1].text, "Gone: barbarian camp")
end

-- Goody hut path. Classification is by .Goody flag, so the same logic
-- routes ancient ruins regardless of the row's exact Type string.
function M.test_ruin_gone_on_revisit()
    setup()
    installCampAndRuinRows()
    local plot = T.fakePlot({ visible = true, plotIndex = 1, improvement = RUIN_IMP })
    plot.GetImprovementType = function()
        return -1
    end
    installPlotMap({ plot })
    RevealAnnounce.installListeners()
    fireRevisit(plot)
    RevealAnnounce._flush()
    T.eq(spoken[1].text, "Gone: ancient ruins")
end

-- A first-reveal plot has no prior state to diff against. Even if the
-- engine claims revealed-type is camp at this moment, firstReveals[idx]
-- gates the diff out. Failure mode: gate slips and a phantom gone
-- announces on first-reveal.
function M.test_first_reveal_does_not_announce_gone()
    setup()
    installCampAndRuinRows()
    -- Plot has no entry in the bootstrap-time map (simulating a brand
    -- new plot the player hasn't seen before): plot's revealed-type is
    -- empty at install, so the snapshot is empty for this idx.
    local plot = T.fakePlot({ visible = true, plotIndex = 1, improvement = -1 })
    plot.GetImprovementType = function()
        return CAMP_IMP
    end
    installPlotMap({ plot })
    RevealAnnounce.installListeners()
    fireFirstReveal(plot)
    RevealAnnounce._flush()
    for _, call in ipairs(spoken) do
        T.falsy(call.text:find("Gone"), "first-reveal must not produce a Gone line")
    end
end

-- Camp still there on revisit. Bootstrap snapshots "camp"; revisit's
-- GetImprovementType also returns CAMP_IMP. Diff is zero. No speech.
-- (Note: shouldSkipPlot also filters this plot out of announcePlots,
-- but the gone walk iterates nowVisible directly, so the diff still
-- runs -- it just produces no count.)
function M.test_persistent_camp_no_gone()
    setup()
    installCampAndRuinRows()
    local plot = T.fakePlot({ visible = true, plotIndex = 1, improvement = CAMP_IMP })
    plot.GetImprovementType = function()
        return CAMP_IMP
    end
    installPlotMap({ plot })
    RevealAnnounce.installListeners()
    fireRevisit(plot)
    RevealAnnounce._flush()
    T.eq(#spoken, 0, "still-there camp does not announce as gone")
end

-- Two camps gone in the same flush aggregate via Text.formatPlural.
-- Failure mode: each detection emits its own line, or the formatter
-- picks the singular form for count > 1.
function M.test_two_camps_aggregate_with_plural()
    setup()
    installCampAndRuinRows()
    local plot1 = T.fakePlot({ x = 0, y = 0, visible = true, plotIndex = 1, improvement = CAMP_IMP })
    plot1.GetImprovementType = function()
        return -1
    end
    local plot2 = T.fakePlot({ x = 1, y = 0, visible = true, plotIndex = 2, improvement = CAMP_IMP })
    plot2.GetImprovementType = function()
        return -1
    end
    installPlotMap({ plot1, plot2 })
    RevealAnnounce.installListeners()
    fireRevisit(plot1)
    fireRevisit(plot2)
    RevealAnnounce._flush()
    T.eq(#spoken, 1, "single combined gone line")
    T.eq(spoken[1].text, "Gone: 2 barbarian camps")
end

-- One of each in the same flush joins with the AND key, mirroring
-- ForeignClearWatch's "Someone else has claimed N camps and N ruins."
function M.test_camp_and_ruin_joined_with_and()
    setup()
    installCampAndRuinRows()
    local plot1 = T.fakePlot({ x = 0, y = 0, visible = true, plotIndex = 1, improvement = CAMP_IMP })
    plot1.GetImprovementType = function()
        return -1
    end
    local plot2 = T.fakePlot({ x = 1, y = 0, visible = true, plotIndex = 2, improvement = RUIN_IMP })
    plot2.GetImprovementType = function()
        return -1
    end
    installPlotMap({ plot1, plot2 })
    RevealAnnounce.installListeners()
    fireRevisit(plot1)
    fireRevisit(plot2)
    RevealAnnounce._flush()
    T.eq(spoken[1].text, "Gone: barbarian camp and ancient ruins")
end

-- After the first gone announcement, the snapshot stores nil for this
-- plot. A second revisit (no further state change) must NOT re-announce
-- -- otherwise every walk past a once-cleared site would repeat the
-- line. Failure mode: snapshot update skipped after the diff fires.
function M.test_repeat_revisit_does_not_re_announce()
    setup()
    installCampAndRuinRows()
    local plot = T.fakePlot({ visible = true, plotIndex = 1, improvement = CAMP_IMP })
    plot.GetImprovementType = function()
        return -1
    end
    installPlotMap({ plot })
    RevealAnnounce.installListeners()
    fireRevisit(plot)
    RevealAnnounce._flush()
    T.eq(#spoken, 1, "first revisit announces once")
    fireRevisit(plot)
    RevealAnnounce._flush()
    T.eq(#spoken, 1, "second revisit silent -- snapshot reflects post-flush state")
end

-- Lifecycle path that the bootstrap can't cover: plot the player has
-- never seen at install (snapshot empty for it), then first-revealed
-- during gameplay with a camp, then walked away, camp cleared in fog,
-- walked back. The first-reveal flush has to write the snapshot even
-- though the diff itself is gated out for first-reveals -- otherwise
-- the subsequent revisit has no prior to compare and silently misses
-- the gone announce. Failure mode: snapshot only updates on revisits.
function M.test_first_reveal_writes_snapshot_for_later_diff()
    setup()
    installCampAndRuinRows()
    -- Plot has no revealed improvement at install (player has never
    -- seen it). _currentImp drives GetImprovementType so the test can
    -- mutate the plot's current state across phases.
    local plot = T.fakePlot({ visible = true, plotIndex = 1, improvement = -1 })
    plot._currentImp = CAMP_IMP
    plot.GetImprovementType = function(self)
        return self._currentImp
    end
    installPlotMap({ plot })
    RevealAnnounce.installListeners()
    -- Phase 1: first reveal of the plot, camp present. Snapshot must
    -- now record "camp" for this idx so a later revisit has a baseline.
    fireFirstReveal(plot)
    RevealAnnounce._flush()
    for _, call in ipairs(spoken) do
        T.falsy(call.text:find("Gone"), "first-reveal phase must not produce a Gone line")
    end
    local callsAfterFirstReveal = #spoken
    -- Phase 2: walk back later. Camp cleared in fog meanwhile.
    plot._currentImp = -1
    fireRevisit(plot)
    RevealAnnounce._flush()
    T.eq(#spoken, callsAfterFirstReveal + 1, "revisit produces exactly one new line")
    T.eq(spoken[#spoken].text, "Gone: barbarian camp")
end

return M

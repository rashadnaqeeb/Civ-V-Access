-- UnitSpeech formatter tests. Exercises the shapes listed in the plan:
-- selection direction prefix, embarked prefix, HP at max vs below-max,
-- always-on moves, promotion-available toggle, per-rung status cascade,
-- first-match wins when two rungs apply, and the info dump's skip-if-
-- zero + HP-last invariants.

local T = require("support")
local M = {}

-- Minimal unit stub that implements every method UnitSpeech reads.
-- Defaults produce a full-HP, fresh melee warrior at (0, 0). opts
-- overrides let each test express only the diffs it cares about.
local function mkUnit(opts)
    opts = opts or {}
    local u = {
        _x = opts.x or 0,
        _y = opts.y or 0,
        _owner = opts.owner or 0,
        _unitType = opts.unitType or 100,
        _embarked = opts.embarked or false,
        _damage = opts.damage or 0,
        _moves = opts.moves or 60,
        _maxMoves = opts.maxMoves or 120,
        _canPromote = opts.canPromote or false,
        _garrisoned = opts.garrisoned or false,
        _automated = opts.automated or false,
        _work = opts.work or false,
        _trade = opts.trade or false,
        _fortifyTurns = opts.fortifyTurns or 0,
        _activity = opts.activity or ActivityTypes.ACTIVITY_AWAKE,
        _buildType = opts.buildType or -1,
        _promotions = opts.promotions or {},
        _level = opts.level or 1,
        _xp = opts.xp or 0,
        _xpNeeded = opts.xpNeeded or 15,
        _combat = opts.combat or 10,
        _ranged = opts.ranged or 0,
        _range = opts.range or 0,
        _upgradeType = opts.upgradeType or -1,
        _upgradePrice = opts.upgradePrice or 0,
        _canUpgradeRightNow = opts.canUpgradeRightNow or false,
        _isCombat = (opts.isCombat ~= false),
        _team = opts.team or 0,
        _plot = opts.plot,
        _outOfAttacks = opts.outOfAttacks or false,
        _domain = opts.domain or DomainTypes.DOMAIN_LAND,
        _hasName = opts.hasName or false,
        _nameNoDesc = opts.nameNoDesc or "",
        _queue = opts.queue or {},
    }
    function u:GetX()
        return self._x
    end
    function u:GetY()
        return self._y
    end
    function u:GetPlot()
        return self._plot
    end
    function u:GetUnitType()
        return self._unitType
    end
    function u:GetOwner()
        return self._owner
    end
    function u:GetMissionQueue()
        return self._queue
    end
    function u:GetNameKey()
        local row = GameInfo.Units[self._unitType]
        return row and row.Description or ""
    end
    function u:HasName()
        return self._hasName or false
    end
    function u:GetNameNoDesc()
        return self._nameNoDesc or ""
    end
    function u:IsEmbarked()
        return self._embarked
    end
    function u:GetDamage()
        return self._damage
    end
    function u:MovesLeft()
        return self._moves
    end
    function u:MaxMoves()
        return self._maxMoves
    end
    function u:CanPromote()
        return self._canPromote
    end
    function u:IsGarrisoned()
        return self._garrisoned
    end
    function u:IsAutomated()
        return self._automated
    end
    function u:IsWork()
        return self._work
    end
    function u:IsTrade()
        return self._trade
    end
    function u:GetFortifyTurns()
        return self._fortifyTurns
    end
    function u:GetActivityType()
        return self._activity
    end
    function u:GetBuildType()
        return self._buildType
    end
    function u:IsHasPromotion(id)
        return self._promotions[id] or false
    end
    function u:GetLevel()
        return self._level
    end
    function u:GetExperience()
        return self._xp
    end
    function u:ExperienceNeeded()
        return self._xpNeeded
    end
    function u:GetBaseCombatStrength()
        return self._combat
    end
    function u:GetBaseRangedCombatStrength()
        return self._ranged
    end
    function u:Range()
        return self._range
    end
    function u:GetUpgradeUnitType()
        return self._upgradeType
    end
    function u:UpgradePrice()
        return self._upgradePrice
    end
    function u:CanUpgradeRightNow(bOnlyTestVisible)
        -- Engine binding expects a number, not a Lua boolean -- passing
        -- `true` throws at runtime. Mirror that strictness here so a
        -- regression in the caller fails the test instead of silently
        -- working against the mock.
        assert(
            type(bOnlyTestVisible) == "number",
            "CanUpgradeRightNow expects a number; got " .. type(bOnlyTestVisible)
        )
        return self._canUpgradeRightNow
    end
    function u:IsCombatUnit()
        return self._isCombat
    end
    function u:GetTeam()
        return self._team
    end
    function u:GetID()
        return opts.id or 1
    end
    function u:IsOutOfAttacks()
        return self._outOfAttacks
    end
    function u:CargoSpace()
        return opts.cargoSpace or 0
    end
    function u:GetDomainType()
        return self._domain
    end
    function u:GetReligion()
        return opts.religion or ReligionTypes.NO_RELIGION
    end
    return u
end

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    -- Required by UnitSpeech.statusToken's ACTIVITY_MISSION rung (calls
    -- Waypoints.queuedActionStatusFor for any own unit). Tests that
    -- exercise the queued-action rung stub queuedActionStatusFor and set
    -- their own UI fixtures; loading the real module here is enough for
    -- the rest.
    civvaccess_shared = civvaccess_shared or {}
    dofile("src/dlc/UI/InGame/CivVAccess_WaypointsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitSpeech.lua")

    GameInfo = GameInfo or {}
    GameInfo.Units = {}
    GameInfo.Units[100] = { Description = "Warrior" }
    GameInfo.Units[101] = { Description = "Swordsman" }
    GameInfo.Builds = {}
    -- Stub UnitPromotions iterator. Tests that care about specific
    -- promotion ids set GameInfo.UnitPromotions themselves.
    GameInfo.UnitPromotions = function()
        return function()
            return nil
        end
    end

    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Players = {}
    -- Owner of every unit in this suite unless a test overrides. The
    -- adjective "Roman" feeds UnitSpeech.unitName via the shared
    -- TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV format key, so name strings
    -- read "Roman Warrior" instead of bare "Warrior".
    Players[0] = T.fakePlayer({ adj = "Roman" })
    GameDefines = GameDefines or {}
    GameDefines.MAX_HIT_POINTS = 100
    GameDefines.MOVE_DENOMINATOR = 60
    -- Reset UI.GetHeadSelectedUnit each setup so a prior suite's fixture
    -- (cursor_test installs a fakeUnit) can't leak into the queued-rung
    -- branch of statusToken, which compares head:GetID against unit:GetID.
    UI = UI or {}
    UI.GetHeadSelectedUnit = function()
        return nil
    end
end

-- ===== Selection: direction prefix =====

function M.test_selection_zero_delta_no_direction_prefix()
    setup()
    local u = mkUnit({ x = 5, y = 5 })
    local out = UnitSpeech.selection(u, 5, 5)
    T.truthy(not out:find("^%d"), "zero-delta must not start with a direction token: " .. out)
    T.truthy(out:find("^Roman Warrior"), "zero-delta must start with name: " .. out)
end

function M.test_selection_non_zero_delta_leads_with_direction()
    setup()
    local u = mkUnit({ x = 3, y = 0 })
    local out = UnitSpeech.selection(u, 0, 0)
    -- 3 hexes east: directionString yields "3e". Assert direction
    -- leads the string so screen readers hear orientation first.
    T.truthy(out:find("^3e, Roman Warrior"), "direction must lead: " .. out)
end

-- ===== Selection: embarked prefix =====

function M.test_selection_embarked_prefix_on_name()
    setup()
    local u = mkUnit({ embarked = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("embarked Roman Warrior", 1, true), "embarked prefix expected: " .. out)
end

function M.test_selection_not_embarked_no_prefix()
    setup()
    local u = mkUnit({ embarked = false })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("embarked", 1, true), "no embarked prefix when not embarked: " .. out)
end

-- ===== Selection: named unit (Alt+N rename or great-general name pool) =====

function M.test_selection_named_unit_wraps_civ_form_in_parens()
    setup()
    local u = mkUnit({ hasName = true, nameNoDesc = "George" })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(
        out:find("^George %(Roman Warrior%)"),
        "named unit must lead with personal name and wrap civ form in parens: " .. out
    )
end

function M.test_selection_named_unit_embarked_combines_prefix_and_paren_form()
    setup()
    local u = mkUnit({ hasName = true, nameNoDesc = "George", embarked = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("embarked George %(Roman Warrior%)"), "embarked prefix must wrap the personal-name form: " .. out)
end

-- ===== Selection: religious unit stamps the religion before the type word =====

function M.test_selection_religious_unit_inserts_religion_between_civ_and_type()
    setup()
    GameInfo.Units[200] = { Description = "Missionary" }
    -- Game.GetReligionName returns either a custom string or a TXT_KEY_*.
    -- Stub it to return a plain string so Text.key passes it through.
    Game.GetReligionName = function(_e)
        return "Buddhism"
    end
    local u = mkUnit({ unitType = 200, religion = 7 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("^Roman Buddhism Missionary"), "religion must sit between civ adjective and type: " .. out)
end

function M.test_selection_no_religion_falls_back_to_plain_civ_form()
    setup()
    -- A religious unit type whose stamped religion is NO_RELIGION (e.g. a
    -- freshly-spawned Great Prophet from a city with only a pantheon) must
    -- fall through to the bare "Roman Missionary" form, no extra token.
    GameInfo.Units[200] = { Description = "Missionary" }
    Game.GetReligionName = function(_e)
        return "Buddhism"
    end
    local u = mkUnit({ unitType = 200, religion = ReligionTypes.NO_RELIGION })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("^Roman Missionary"), "no religion must produce plain civ form: " .. out)
    T.truthy(not out:find("Buddhism", 1, true), "must not surface religion when none stamped: " .. out)
end

function M.test_selection_pantheon_stamp_does_not_surface_as_religion()
    setup()
    -- RELIGION_PANTHEON is the engine's "this unit pre-dates a real religion"
    -- sentinel; the missionary spread / inquisitor heresy paths gate on
    -- eReligion > RELIGION_PANTHEON, so speech must mirror that filter.
    GameInfo.Units[200] = { Description = "Missionary" }
    Game.GetReligionName = function(_e)
        return "Pantheon"
    end
    local u = mkUnit({ unitType = 200, religion = ReligionTypes.RELIGION_PANTHEON })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("Pantheon", 1, true), "pantheon-only must not be surfaced: " .. out)
end

function M.test_selection_named_religious_unit_wraps_civ_religion_form_in_parens()
    -- Three variables interact in this path: HasName -> personal-name
    -- prefix, civ adj -> "Roman" lead, religion -> stamp adjacent to type.
    -- A future refactor of unitName that builds typeForm without the
    -- religion arg would still pass the existing named-unit and
    -- religion-only tests; this test catches that combined-path drop.
    setup()
    GameInfo.Units[200] = { Description = "Great Prophet" }
    Game.GetReligionName = function(_e)
        return "Buddhism"
    end
    local u = mkUnit({
        unitType = 200,
        religion = 7,
        hasName = true,
        nameNoDesc = "George",
    })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(
        out:find("^George %(Roman Buddhism Great Prophet%)"),
        "named religious unit must wrap civ + religion + type in parens after personal name: " .. out
    )
end

function M.test_selection_religion_resolves_txt_key_form()
    setup()
    -- Game.GetReligionName for a non-custom religion returns the TXT_KEY_
    -- form ("TXT_KEY_RELIGION_BUDDHISM"). UnitSpeech.unitReligion routes
    -- through Text.key, which resolves TXT_KEY_* via Locale.ConvertTextKey.
    GameInfo.Units[200] = { Description = "Missionary" }
    Game.GetReligionName = function(_e)
        return "TXT_KEY_RELIGION_BUDDHISM"
    end
    local origConvert = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(key)
        if key == "TXT_KEY_RELIGION_BUDDHISM" then
            return "Buddhism"
        end
        return origConvert and origConvert(key) or key
    end
    local u = mkUnit({ unitType = 200, religion = 7 })
    local out = UnitSpeech.selection(u, 0, 0)
    Locale.ConvertTextKey = origConvert
    T.truthy(out:find("^Roman Buddhism Missionary"), "TXT_KEY religion must resolve to its localized form: " .. out)
end

-- ===== Selection: HP =====

function M.test_selection_hp_at_max_no_hp_token()
    setup()
    local u = mkUnit({ damage = 0 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("hp", 1, true), "full-HP unit must not speak hp: " .. out)
end

function M.test_selection_hp_below_max_speaks_fraction()
    setup()
    local u = mkUnit({ damage = 40 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("60/100 hp", 1, true), "damaged unit must speak fraction: " .. out)
end

-- ===== Selection: moves always =====

function M.test_selection_moves_always_announced_full()
    setup()
    local u = mkUnit({ moves = 120, maxMoves = 120 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("2/2 moves", 1, true), "full moves must be announced: " .. out)
end

function M.test_selection_moves_always_announced_zero()
    setup()
    local u = mkUnit({ moves = 0, maxMoves = 120 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("0/2 moves", 1, true), "zero moves must still be announced: " .. out)
end

-- Roads cost 30 / 60, so a 2-MP unit that crosses one road tile ends with
-- 90 / 60 left -- the fraction has to survive into speech, otherwise the
-- user can't tell it apart from a unit with a flat 60 / 60 remaining and
-- misses that another road step is still affordable this turn.
function M.test_selection_moves_announced_with_road_remainder()
    setup()
    local u = mkUnit({ moves = 90, maxMoves = 120 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("1.5/2 moves", 1, true), "road remainder must speak as 1.5: " .. out)
end

function M.test_selection_moves_announced_with_half_move()
    setup()
    local u = mkUnit({ moves = 30, maxMoves = 120 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("0.5/2 moves", 1, true), "half-move must not floor to 0: " .. out)
end

-- ===== Selection: promotion available =====

function M.test_selection_promotion_available_on()
    setup()
    local u = mkUnit({ canPromote = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("promotion available", 1, true), "expected promotion available: " .. out)
end

function M.test_selection_promotion_available_off()
    setup()
    local u = mkUnit({ canPromote = false })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("promotion available", 1, true), "no promotion token when canPromote=false: " .. out)
end

-- ===== Selection: status cascade, one rung at a time =====

function M.test_selection_status_garrisoned()
    setup()
    local u = mkUnit({ garrisoned = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_MISSION_GARRISON", 1, true), "garrison status expected: " .. out)
end

function M.test_selection_status_automate_build()
    setup()
    local u = mkUnit({ automated = true, work = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_ACTION_AUTOMATE_BUILD", 1, true), "automate-build expected: " .. out)
end

-- Automated workers spend most of their time on a build mission. UnitList's
-- cascade returns just "automated" (the build column hides because the
-- icon is shown elsewhere); a blind player needs to hear what the worker
-- is actually doing or there's no way to know an automated worker is
-- progressing vs idle.
function M.test_selection_status_automate_build_with_active_build()
    setup()
    GameInfo.Builds[7] = { Description = "Build Farm" }
    local plot = T.fakePlot({ x = 0, y = 0 })
    plot._buildTurns[7] = 4
    local u = mkUnit({ automated = true, work = true, buildType = 7, plot = plot })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("Build Farm 5 turns", 1, true), "build with turns expected: " .. out)
    T.truthy(out:find("TXT_KEY_ACTION_AUTOMATE_BUILD", 1, true), "automate token expected too: " .. out)
    -- Build is the distinguishing rung (every automated worker shares the
    -- "automated" token; only the build differs), so it leads.
    local buildPos = out:find("Build Farm", 1, true)
    local autoPos = out:find("TXT_KEY_ACTION_AUTOMATE_BUILD", 1, true)
    T.truthy(buildPos < autoPos, "build should precede automate token: " .. out)
end

function M.test_selection_status_automate_trade()
    setup()
    local u = mkUnit({ automated = true, trade = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_ACTION_AUTOMATE_TRADE", 1, true), "automate-trade expected: " .. out)
end

function M.test_selection_status_automate_explore()
    setup()
    local u = mkUnit({ automated = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_ACTION_AUTOMATE_EXPLORE", 1, true), "automate-explore expected: " .. out)
end

function M.test_selection_status_heal()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_HEAL })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_MISSION_HEAL", 1, true), "heal status expected: " .. out)
end

function M.test_selection_status_alert()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_SENTRY })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_MISSION_ALERT", 1, true), "alert status expected: " .. out)
end

function M.test_selection_status_fortified()
    setup()
    local u = mkUnit({ fortifyTurns = 3 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_UNIT_STATUS_FORTIFIED", 1, true), "fortified status expected: " .. out)
end

function M.test_selection_status_sleep()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_SLEEP })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_MISSION_SLEEP", 1, true), "sleep status expected: " .. out)
end

function M.test_selection_status_building_with_turns()
    setup()
    GameInfo.Builds[7] = { Description = "Build Farm" }
    local plot = T.fakePlot({ x = 0, y = 0 })
    plot._buildTurns[7] = 4
    local u = mkUnit({ buildType = 7, plot = plot })
    local out = UnitSpeech.selection(u, 0, 0)
    -- Base code adds +1 to turns-left (see UnitPanel.lua:392).
    T.truthy(out:find("Build Farm 5 turns", 1, true), "building status with turns expected: " .. out)
end

-- A unit on ACTIVITY_MISSION that is NOT the selected unit still gets the
-- full per-leg detail: statusToken prices the path for any own unit via
-- queuedActionStatusFor, passing the glanced unit (not the head-selected
-- one), so a cursor read over a moving unit reads its segments and ETA.
function M.test_selection_status_queued_mission_non_selected_gets_detail()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION, x = 0, y = 0 })
    UI.GetHeadSelectedUnit = function()
        return mkUnit({ x = 5, y = 5 })
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function(unit)
        T.truthy(unit == u, "statusToken should price the glanced unit, not the selected one")
        return { chunks = { { kind = "move", segments = { "3e" }, turns = 2 } } }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    T.truthy(out:find("queued move, 2 turns: 3e, arrive", 1, true), "non-selected unit detail expected: " .. out)
end

-- Engine-fork variant: when the unit IS the head-selected one and
-- WaypointsCore returns a chunked queue status, the rung renders one
-- chunk per kind joined by "then" with ", arrive" once at the end.
-- These tests stub Waypoints directly so statusToken's chunk renderer
-- is exercised in isolation from compute()'s engine-API plumbing.
function M.test_selection_status_queued_mission_with_single_waypoint()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION, x = 0, y = 0 })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function()
        return { chunks = { { kind = "move", segments = { "3e" }, turns = 2 } } }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    T.truthy(out:find("queued move, 2 turns: 3e, arrive", 1, true), "single-waypoint rung expected: " .. out)
end

-- Multi-segment move chunk: every additional stop adds a ", then SEG"
-- so the user hears each segment in chronological order, with "arrive"
-- only on the final stop.
function M.test_selection_status_queued_mission_with_multiple_waypoints()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION, x = 0, y = 0 })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function()
        return { chunks = { { kind = "move", segments = { "2ne", "2e", "1ne" }, turns = 3 } } }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    T.truthy(
        out:find("queued move, 3 turns: 2ne, then 2e, then 1ne, arrive", 1, true),
        "multi-waypoint rung expected: " .. out
    )
end

-- Singular "turn" form for a one-turn queue.
function M.test_selection_status_queued_mission_one_turn_plural()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION, x = 0, y = 0 })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function()
        return { chunks = { { kind = "move", segments = { "1e" }, turns = 1 } } }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    T.truthy(out:find("queued move, 1 turn: 1e, arrive", 1, true), "singular-turn rung expected: " .. out)
end

-- Route-to chunk: the route name is substituted into the chunk template
-- so the user hears "queued road" instead of "queued move", and the
-- turn count reflects build turns rather than movement turns.
function M.test_selection_status_queued_mission_route_chunk_uses_route_name()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION, x = 0, y = 0 })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function()
        return {
            chunks = {
                { kind = "route", segments = { "1e", "1e", "1e" }, turns = 9, routeName = "road" },
            },
        }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    T.truthy(
        out:find("queued road, 9 turns: 1e, then 1e, then 1e, arrive", 1, true),
        "route chunk rung expected: " .. out
    )
end

-- Mixed queue: a route chunk followed by a move chunk renders as two
-- labeled chunks joined by "then", with one trailing "arrive". The
-- player hears the transition from build-road to plain-move and knows
-- the queue ends at the final move's destination.
function M.test_selection_status_queued_mission_mixed_chunks_render_both_labels()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION, x = 0, y = 0 })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function()
        return {
            chunks = {
                { kind = "route", segments = { "1e", "1e", "1e" }, turns = 9, routeName = "road" },
                { kind = "move", segments = { "2e", "1ne" }, turns = 2 },
            },
        }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    T.truthy(
        out:find("queued road, 9 turns: 1e, then 1e, then 1e, then queued move, 2 turns: 2e, then 1ne, arrive", 1, true),
        "mixed-queue rung expected: " .. out
    )
end

-- Falls back to the bare "queued move" when Waypoints has no status
-- (empty queue, all path-bearing legs unreachable, etc.).
function M.test_selection_status_queued_mission_falls_back_when_no_waypoints()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function()
        return nil
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    T.truthy(out:find("queued move", 1, true), "queued move fallback expected: " .. out)
    T.truthy(not out:find("turn", 1, true), "no turns suffix when waypoints unavailable: " .. out)
end

function M.test_selection_status_building_alone_when_no_queued_chunks()
    -- A worker executing a build has ACTIVITY_MISSION set by the engine.
    -- When Waypoints has nothing queued beyond the active build, the
    -- status reads only the build rung -- no trailing "queued move"
    -- bare fallback.
    setup()
    GameInfo.Builds[7] = { Description = "Build Farm" }
    local plot = T.fakePlot({ x = 0, y = 0 })
    plot._buildTurns[7] = 4
    local u = mkUnit({ buildType = 7, plot = plot, activity = ActivityTypes.ACTIVITY_MISSION })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("Build Farm 5 turns", 1, true), "building should be present: " .. out)
    T.truthy(not out:find("queued", 1, true), "queued fallback must not fire when no chunks: " .. out)
end

-- A worker mid-build of a road as part of a route-to queue: the build
-- folds into the head queued route chunk. Result is one unified
-- announcement -- "queued road, 9 turns: 3 turns here, then ..." -- with
-- the current build's remaining turns as the first segment ("here") and
-- summed into the chunk's total. No separate "Build Road N turns"
-- prefix; the build is implicit in the "queued road" label.
function M.test_selection_status_build_folds_into_head_route_chunk()
    setup()
    -- Build row needs a RouteType for the fold-detection to find a
    -- match. Routes table needs an entry for that key whose Description
    -- resolves to the same lowercased name the chunk carries.
    GameInfo.Builds[7] = { Description = "Build Road", RouteType = "ROUTE_ROAD" }
    GameInfo.Routes = GameInfo.Routes or {}
    GameInfo.Routes["ROUTE_ROAD"] = { Description = "TXT_KEY_ROUTE_ROAD" }
    local origConvert = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(key, ...)
        if key == "TXT_KEY_ROUTE_ROAD" then
            return "Road"
        end
        return origConvert(key, ...)
    end
    local plot = T.fakePlot({ x = 0, y = 0 })
    plot._buildTurns[7] = 2
    local u = mkUnit({ buildType = 7, plot = plot, activity = ActivityTypes.ACTIVITY_MISSION })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function()
        return {
            chunks = {
                { kind = "route", segments = { "1e", "1e" }, turns = 6, routeName = "road" },
            },
        }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    Locale.ConvertTextKey = origConvert
    T.truthy(
        out:find("queued road, 9 turns: 3 turns here, then 1e, then 1e, arrive", 1, true),
        "build should fold into queued route: " .. out
    )
    T.truthy(not out:find("Build Road", 1, true), "no separate 'Build Road' prefix when folded: " .. out)
end

-- A worker mid-build of a non-route improvement (Farm) with a queued
-- move: the build doesn't fold into the queued chunk -- different
-- semantics. Both render side by side, joined by ", ".
function M.test_selection_status_build_and_queued_side_by_side_when_kinds_differ()
    setup()
    -- Farm has no RouteType so the fold condition can't match.
    GameInfo.Builds[8] = { Description = "Build Farm" }
    local plot = T.fakePlot({ x = 0, y = 0 })
    plot._buildTurns[8] = 4
    local u = mkUnit({ buildType = 8, plot = plot, activity = ActivityTypes.ACTIVITY_MISSION })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origStatus = Waypoints.queuedActionStatusFor
    Waypoints.queuedActionStatusFor = function()
        return {
            chunks = {
                { kind = "move", segments = { "2e", "1ne" }, turns = 2 },
            },
        }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.queuedActionStatusFor = origStatus
    T.truthy(
        out:find("Build Farm 5 turns, queued move, 2 turns: 2e, then 1ne, arrive", 1, true),
        "non-route build should render alongside queued move: " .. out
    )
end

-- ===== Selection: cascade first-match-wins =====

function M.test_selection_status_garrison_wins_over_fortify()
    -- A garrisoned unit inside a city has FortifyTurns > 0 as a side
    -- effect (the garrison mission fortifies). UnitList's cascade puts
    -- garrison first so the user hears the more specific rung.
    setup()
    local u = mkUnit({ garrisoned = true, fortifyTurns = 3 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_MISSION_GARRISON", 1, true), "garrison should win: " .. out)
    T.truthy(not out:find("FORTIFIED", 1, true), "fortified must not also fire: " .. out)
end

function M.test_selection_status_heal_wins_over_fortify()
    -- Heal is "fortify until healed", and the unit has FortifyTurns > 0
    -- while healing. Cascade's heal-before-fortified ordering keeps the
    -- more informative rung.
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_HEAL, fortifyTurns = 1 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("TXT_KEY_MISSION_HEAL", 1, true), "heal should win over fortified: " .. out)
    T.truthy(not out:find("FORTIFIED", 1, true), "fortified token must not appear: " .. out)
end

-- ===== Info dump =====

function M.test_info_skip_zero_ranged_on_melee()
    setup()
    local u = mkUnit({ combat = 10, ranged = 0 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("10 melee", 1, true), "combat strength expected: " .. out)
    T.truthy(not out:find("ranged", 1, true), "zero-ranged must be skipped: " .. out)
end

function M.test_info_ranged_unit_speaks_range_and_strength()
    setup()
    local u = mkUnit({ combat = 4, ranged = 9, range = 2 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("9 ranged, range 2", 1, true), "ranged strength + range expected: " .. out)
end

function M.test_info_hp_leads_after_name()
    setup()
    local u = mkUnit({ damage = 30, combat = 10, ranged = 9, range = 2, upgradeType = 101, upgradePrice = 120 })
    local out = UnitSpeech.info(u)
    -- HP leads the condition block: the first comma-separated token after
    -- the name. Split on ", " (the name carries no comma) and inspect
    -- index 2 to avoid a brittle prefix assertion.
    local parts = {}
    for part in (out .. ", "):gmatch("(.-), ") do
        parts[#parts + 1] = part
    end
    T.truthy(#parts >= 2, "info must produce a name and HP: " .. out)
    T.truthy(parts[2]:find("hp", 1, true), "HP must follow the name: " .. tostring(parts[2]))
end

function M.test_info_promotions_stay_last()
    setup()
    GameInfo.UnitPromotions = function()
        local rows = { { ID = 1, Description = "Shock" } }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    -- Upgrade is the token just ahead of promotions in the order; having
    -- both present proves promotions still wins the tail.
    local u = mkUnit({
        combat = 10,
        upgradeType = 101,
        upgradePrice = 120,
        canUpgradeRightNow = true,
        promotions = { [1] = true },
    })
    local out = UnitSpeech.info(u)
    local parts = {}
    for part in (out .. ", "):gmatch("(.-), ") do
        parts[#parts + 1] = part
    end
    T.truthy(parts[#parts]:find("promotions", 1, true), "promotions must be the final token: " .. out)
end

function M.test_info_upgrade_speaks_only_when_available()
    setup()
    local u1 = mkUnit({ upgradeType = -1 })
    local out1 = UnitSpeech.info(u1)
    T.truthy(not out1:find("upgrade", 1, true), "no upgrade line when unit has no upgrade path: " .. out1)

    -- Unit has an upgrade target (e.g. Warrior -> Swordsman) but the
    -- player hasn't unlocked the prereq tech yet. The engine's
    -- CanUpgradeRightNow gate rejects it; we must stay silent rather
    -- than spamming an unactionable cost.
    setup()
    local u2 = mkUnit({ upgradeType = 101, upgradePrice = 120, canUpgradeRightNow = false })
    local out2 = UnitSpeech.info(u2)
    T.truthy(not out2:find("upgrade", 1, true), "no upgrade line when CanUpgradeRightNow is false: " .. out2)

    setup()
    local u3 = mkUnit({ upgradeType = 101, upgradePrice = 120, canUpgradeRightNow = true })
    local out3 = UnitSpeech.info(u3)
    T.truthy(out3:find("upgrade to Swordsman, 120 gold", 1, true), "upgrade line expected: " .. out3)
end

function M.test_info_promotions_list_iterates_has_promotion()
    setup()
    GameInfo.UnitPromotions = function()
        local rows = {
            { ID = 1, Description = "Shock" },
            { ID = 2, Description = "Drill" },
            { ID = 3, Description = "Formation" },
        }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    local u = mkUnit({ promotions = { [1] = true, [3] = true } })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("promotions: Shock, Formation", 1, true), "only held promotions listed: " .. out)
end

-- ===== Info dump: moves fraction (always, regardless of ownership) =====

function M.test_info_friendly_speaks_moves_fraction()
    setup()
    local u = mkUnit({ moves = 60, maxMoves = 180 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("1/3 moves", 1, true), "moves fraction expected: " .. out)
end

function M.test_info_enemy_speaks_moves_fraction()
    setup()
    local u = mkUnit({ team = 1, moves = 0, maxMoves = 240 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("0/4 moves", 1, true), "moves fraction spoken for enemies too: " .. out)
end

-- ===== Aircraft: range + rebase range replaces moves fraction =====

-- Aircraft moves fractions are degenerate (every action calls finishMoves
-- so MovesLeft is a binary "has acted" flag, not a movement budget). Base
-- UnitPanel.lua's DOMAIN_AIR branch swaps the movement stat for the strike
-- range, surfacing strike+rebase in the tooltip. We mirror that.
function M.test_selection_aircraft_speaks_range_and_rebase_not_moves()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_AIR, range = 8, moves = 60, maxMoves = 60 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("range 8, rebase range 16", 1, true), "expected strike+rebase pair: " .. out)
    T.truthy(not out:find("/", 1, true), "moves fraction must not appear for aircraft: " .. out)
end

function M.test_info_aircraft_speaks_range_and_rebase_not_moves()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_AIR, range = 6, ranged = 65, moves = 60, maxMoves = 60, combat = 0 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("range 6, rebase range 12", 1, true), "expected strike+rebase pair: " .. out)
    T.truthy(not out:find("moves", 1, true), "moves fraction must not appear for aircraft: " .. out)
end

-- The friendly ranged-strength token embeds its own "range N" string. For
-- aircraft we surface range alongside rebase range in the reach token, so
-- the strength line drops the embedded range to avoid speaking it twice.
function M.test_info_aircraft_ranged_strength_drops_embedded_range()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_AIR, range = 8, ranged = 70, combat = 0 })
    local out = UnitSpeech.info(u)
    -- Strength still announced.
    T.truthy(out:find("70 ranged", 1, true), "ranged strength expected: " .. out)
    -- Regression signature: if RANGED_STRENGTH (friendly with embedded
    -- range) leaked through for aircraft alongside the air reach token,
    -- "range 8" would appear twice. With RANGED_STRENGTH_ONLY it appears
    -- once -- only inside the reach token, which also carries rebase range.
    T.truthy(not out:find("range 8, range 8", 1, true), "embedded range must not duplicate: " .. out)
end

-- Rebase multiplier is read live from GameDefines so a mod that alters
-- AIR_UNIT_REBASE_RANGE_MULTIPLIER would still speak the correct number.
function M.test_aircraft_rebase_multiplier_is_live()
    setup()
    local saved = GameDefines.AIR_UNIT_REBASE_RANGE_MULTIPLIER
    GameDefines.AIR_UNIT_REBASE_RANGE_MULTIPLIER = 300
    local u = mkUnit({ domain = DomainTypes.DOMAIN_AIR, range = 5 })
    local out = UnitSpeech.selection(u, 0, 0)
    GameDefines.AIR_UNIT_REBASE_RANGE_MULTIPLIER = saved
    T.truthy(out:find("range 5, rebase range 15", 1, true), "expected 5*3=15: " .. out)
end

-- DOMAIN_LAND units keep the moves fraction -- the aircraft branch must
-- not leak into ground units.
function M.test_selection_land_unit_keeps_moves_fraction()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_LAND, moves = 60, maxMoves = 120 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("1/2 moves", 1, true), "land units must keep moves fraction: " .. out)
end

-- ===== Aircraft: out-of-moves "done for the turn" signal =====

-- With the moves fraction dropped, a friendly aircraft that has used
-- its action this turn (strike / rebase / sweep all call finishMoves)
-- needs an explicit "out of moves" token so the user can tell it can't
-- act anymore.
function M.test_selection_aircraft_zero_moves_speaks_out_of_moves()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_AIR, range = 8, moves = 0, maxMoves = 60 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("out of moves", 1, true), "expected out-of-moves token: " .. out)
end

function M.test_info_aircraft_zero_moves_speaks_out_of_moves()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_AIR, range = 8, ranged = 70, combat = 0, moves = 0, maxMoves = 60 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("out of moves", 1, true), "expected out-of-moves token in info: " .. out)
end

function M.test_selection_aircraft_full_moves_omits_out_of_moves()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_AIR, range = 8, moves = 60, maxMoves = 60 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("out of moves", 1, true), "no token when aircraft can still act: " .. out)
end

-- Land units already convey 0-moves through the fraction, so the
-- aircraft-specific token must not fire on them.
function M.test_selection_land_zero_moves_omits_out_of_moves()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_LAND, moves = 0, maxMoves = 120 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("out of moves", 1, true), "land units must not get the air token: " .. out)
end

-- Foreign-unit move state isn't on the sighted unit flag, so parity
-- says we don't surface the token for enemy aircraft.
function M.test_selection_enemy_aircraft_zero_moves_omits_out_of_moves()
    setup()
    local u = mkUnit({ domain = DomainTypes.DOMAIN_AIR, range = 8, moves = 0, maxMoves = 60, team = 1 })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("out of moves", 1, true), "enemy aircraft must not speak the token: " .. out)
end

-- ===== Info dump: out-of-attacks =====

function M.test_info_speaks_out_of_attacks_when_friendly_combat_with_moves()
    setup()
    local u = mkUnit({ moves = 60, maxMoves = 120, outOfAttacks = true })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("out of attacks", 1, true), "out-of-attacks expected: " .. out)
end

function M.test_info_omits_out_of_attacks_when_unit_can_still_attack()
    setup()
    local u = mkUnit({ moves = 60, maxMoves = 120, outOfAttacks = false })
    local out = UnitSpeech.info(u)
    T.truthy(not out:find("out of attacks", 1, true), "no token when attack budget remains: " .. out)
end

-- 0-moves unit can't attack regardless of attack budget; suppress the token
-- so it doesn't pile onto the moves fraction's already-zero readout.
function M.test_info_omits_out_of_attacks_when_unit_has_zero_moves()
    setup()
    local u = mkUnit({ moves = 0, maxMoves = 120, outOfAttacks = true })
    local out = UnitSpeech.info(u)
    T.truthy(not out:find("out of attacks", 1, true), "0-moves redundant case must suppress: " .. out)
end

-- Civilians have a 0-attack budget so the engine returns IsOutOfAttacks=true
-- by default; gate on IsCombatUnit to avoid speaking it on Settlers etc.
function M.test_info_omits_out_of_attacks_on_non_combat_unit()
    setup()
    local u = mkUnit({ isCombat = false, outOfAttacks = true, moves = 60 })
    local out = UnitSpeech.info(u)
    T.truthy(not out:find("out of attacks", 1, true), "non-combat units must not speak the token: " .. out)
end

-- Foreign-unit attack budgets aren't visible on a sighted unit flag, so
-- parity says we don't surface it for them either.
function M.test_info_omits_out_of_attacks_on_enemy()
    setup()
    local u = mkUnit({ team = 1, outOfAttacks = true, moves = 60 })
    local out = UnitSpeech.info(u)
    T.truthy(not out:find("out of attacks", 1, true), "enemy out-of-attacks must not speak: " .. out)
end

function M.test_selection_speaks_out_of_attacks_when_friendly_combat_with_moves()
    setup()
    local u = mkUnit({ moves = 60, maxMoves = 120, outOfAttacks = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("out of attacks", 1, true), "out-of-attacks expected on selection: " .. out)
end

function M.test_selection_omits_out_of_attacks_when_unit_has_zero_moves()
    setup()
    local u = mkUnit({ moves = 0, maxMoves = 120, outOfAttacks = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("out of attacks", 1, true), "0-moves redundant case must suppress on selection: " .. out)
end

-- ===== Info dump: enemy HP =====

-- Sighted players read enemy HP off the plot hover tooltip
-- (PlotMouseoverInclude.lua) as a numeric "current / max" line, so the
-- info dump speaks the same exact fraction for friendlies and enemies.
-- Regression guard: catches anyone reintroducing an enemy-only band.
function M.test_info_enemy_speaks_exact_fraction()
    setup()
    local u = mkUnit({ team = 1, damage = 40 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("60/100 hp", 1, true), "enemy must speak exact fraction: " .. out)
end

-- ===== Info dump: enemy-scoped omissions =====

function M.test_info_enemy_ranged_omits_range_distance()
    setup()
    local u = mkUnit({ team = 1, combat = 4, ranged = 9, range = 2 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("9 ranged", 1, true), "ranged strength still spoken: " .. out)
    T.truthy(not out:find("range 2", 1, true), "range distance hidden on enemies: " .. out)
end

function M.test_info_enemy_omits_level_xp()
    setup()
    local u = mkUnit({ team = 1, level = 3, xp = 20, xpNeeded = 45 })
    local out = UnitSpeech.info(u)
    T.truthy(not out:find("level", 1, true), "level hidden on enemies: " .. out)
    T.truthy(not out:find("xp", 1, true), "xp hidden on enemies: " .. out)
end

function M.test_info_enemy_omits_upgrade()
    setup()
    local u = mkUnit({ team = 1, upgradeType = 101, upgradePrice = 120 })
    local out = UnitSpeech.info(u)
    T.truthy(not out:find("upgrade", 1, true), "upgrade line hidden on enemies: " .. out)
end

function M.test_info_enemy_keeps_promotions()
    -- Promotion list is visible on enemy unit flags (iconified) and
    -- UnitFlagManager shows them, so we keep them in the info line too.
    setup()
    GameInfo.UnitPromotions = function()
        local rows = { { ID = 1, Description = "Shock" } }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    local u = mkUnit({ team = 1, promotions = { [1] = true } })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("promotions: Shock", 1, true), "enemy promotions still spoken: " .. out)
end

-- ===== Info dump: status cascade mirrors unit flag visibility =====

function M.test_info_friendly_speaks_fortified_status()
    setup()
    local u = mkUnit({ fortifyTurns = 3 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("TXT_KEY_UNIT_STATUS_FORTIFIED", 1, true), "friendly fortified expected: " .. out)
end

function M.test_info_friendly_speaks_sleep_status()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_SLEEP })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("TXT_KEY_MISSION_SLEEP", 1, true), "friendly sleep expected: " .. out)
end

function M.test_info_enemy_speaks_fortified()
    setup()
    local u = mkUnit({ team = 1, fortifyTurns = 3 })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("TXT_KEY_UNIT_STATUS_FORTIFIED", 1, true), "enemy fortified expected: " .. out)
end

function M.test_info_enemy_omits_sleep_status()
    -- Sleep isn't rendered on a foreign unit flag; mirroring that, the
    -- enemy branch skips everything except the fortified shield.
    setup()
    local u = mkUnit({ team = 1, activity = ActivityTypes.ACTIVITY_SLEEP })
    local out = UnitSpeech.info(u)
    T.truthy(not out:find("SLEEP", 1, true), "enemy sleep must not speak: " .. out)
end

function M.test_info_enemy_omits_heal_status()
    setup()
    local u = mkUnit({ team = 1, activity = ActivityTypes.ACTIVITY_HEAL })
    local out = UnitSpeech.info(u)
    T.truthy(not out:find("HEAL", 1, true), "enemy heal must not speak: " .. out)
end

function M.test_info_embarked_prefixes_name()
    setup()
    local u = mkUnit({ embarked = true })
    local out = UnitSpeech.info(u)
    T.truthy(out:find("embarked Roman Warrior", 1, true), "info must embarked-prefix name: " .. out)
end

function M.test_info_hp_precedes_status()
    setup()
    local u = mkUnit({ fortifyTurns = 3, damage = 40 })
    local out = UnitSpeech.info(u)
    local iHp = out:find("hp", 1, true)
    local iStatus = out:find("TXT_KEY_UNIT_STATUS_FORTIFIED", 1, true)
    T.truthy(iHp ~= nil, "HP expected in output: " .. out)
    T.truthy(iStatus ~= nil, "fortified expected in output: " .. out)
    T.truthy(iHp < iStatus, "HP leads the condition block, before status: " .. out)
end

function M.test_info_status_speaks_before_level_xp()
    -- Status (fortified / sleeping / healing / ...) is the first thing
    -- a user wants to hear about a unit after its core stats; level / xp
    -- is long and rarely action-bearing, so it sits after status.
    setup()
    local u = mkUnit({ fortifyTurns = 3, level = 2, xp = 10, xpNeeded = 30 })
    local out = UnitSpeech.info(u)
    local iStatus = out:find("TXT_KEY_UNIT_STATUS_FORTIFIED", 1, true)
    local iLevel = out:find("level", 1, true)
    T.truthy(iStatus ~= nil, "fortified expected in output: " .. out)
    T.truthy(iLevel ~= nil, "level/xp expected in output: " .. out)
    T.truthy(iStatus < iLevel, "status must precede level/xp: " .. out)
end

-- ===== Move result =====

function M.test_move_result_clean_arrival()
    setup()
    local u = mkUnit({ x = 4, y = 4, moves = 60 })
    local out = UnitSpeech.moveResult(u, 4, 4)
    T.truthy(out:find("moved", 1, true), "clean arrival expected: " .. out)
    T.truthy(out:find("1 move left", 1, true), "moves-left should be 1: " .. out)
end

function M.test_move_result_short_stop()
    setup()
    local u = mkUnit({ x = 2, y = 2, moves = 0 })
    local out = UnitSpeech.moveResult(u, 4, 4)
    T.truthy(out:find("stopped short", 1, true), "short-stop expected: " .. out)
    T.falsy(out:find("turns till arrival", 1, true), "no-turns branch should omit ETA: " .. out)
end

function M.test_move_result_short_stop_with_turns()
    setup()
    local u = mkUnit({ x = 2, y = 2, moves = 0 })
    local out = UnitSpeech.moveResult(u, 4, 4, 3)
    T.truthy(out:find("stopped short", 1, true), "short-stop expected: " .. out)
    T.truthy(out:find("3", 1, true), "turns count should appear: " .. out)
    T.truthy(out:find("turns till arrival", 1, true), "ETA phrasing expected: " .. out)
end

function M.test_move_result_short_stop_zero_turns_is_bare()
    -- After the pathfinder-offset correction in onUnitMoveCompleted,
    -- an unreachable-after-stop with 0 remaining turns falls back to
    -- the bare "stopped short" phrasing rather than reporting "0 turns
    -- till arrival." Same for negative values.
    setup()
    local u = mkUnit({ x = 2, y = 2, moves = 0 })
    local outZero = UnitSpeech.moveResult(u, 4, 4, 0)
    T.falsy(outZero:find("turns till arrival", 1, true), "zero-turn fallback: " .. outZero)
    local outNeg = UnitSpeech.moveResult(u, 4, 4, -1)
    T.falsy(outNeg:find("turns till arrival", 1, true), "neg-turn fallback: " .. outNeg)
end

-- ===== Self-plot confirm =====

function M.test_self_plot_confirm_known_tokens()
    setup()
    T.eq(UnitSpeech.selfPlotConfirm("FORTIFY"), "fortified")
    T.eq(UnitSpeech.selfPlotConfirm("SLEEP"), "sleeping")
    T.eq(UnitSpeech.selfPlotConfirm("AUTOMATE"), "automated")
    T.eq(UnitSpeech.selfPlotConfirm("HEAL"), "healing")
    T.eq(UnitSpeech.selfPlotConfirm("PILLAGE"), "pillaged")
    T.eq(UnitSpeech.selfPlotConfirm("SKIP"), "skipped")
    T.eq(UnitSpeech.selfPlotConfirm("UPGRADE"), "upgraded")
    T.eq(UnitSpeech.selfPlotConfirm("CANCEL"), "canceled")
end

function M.test_self_plot_confirm_build_start_uses_payload()
    setup()
    local out = UnitSpeech.selfPlotConfirm("BUILD_START", { buildName = "Build Farm" })
    T.truthy(out:find("started Build Farm", 1, true), "build-start payload expected: " .. out)
end

function M.test_self_plot_confirm_unknown_token_empty()
    setup()
    T.eq(UnitSpeech.selfPlotConfirm("NOT_A_REAL_TOKEN"), "")
end

-- ===== Combat preview =====
-- The four preview functions (melee / ranged / city-melee / city-ranged)
-- carry the most decision-critical drift getters: GetCombatDamage,
-- GetMaxDefenseStrength, and Plot:DefenseModifier, all routed through
-- EngineData. These characterization tests pin the rendered core line --
-- name, strengths, prediction, and the two damage numbers -- so a change
-- to the call wiring (including the EngineData migration) that alters any
-- of those numbers breaks the test. Per-side modifier breakdowns are held
-- at neutral, so the spoken line is the core line alone.

-- Deterministic stand-in for the engine's C++ GetCombatDamage, which is
-- unreachable offline. It only has to be stable and depend on its inputs,
-- so the attacker's and defender's calls (which pass the two strengths in
-- opposite order) yield different, hand-checkable numbers. The tests pin
-- the rendered numbers; the EngineData migration routes the same arguments
-- here, so the numbers are unchanged by it.
local function fakeCombatDamage(myStr, oppStr, curDmg)
    return math.floor(myStr / oppStr * 18) + math.floor(curDmg / 10)
end

-- Metatable that absorbs the long tail of per-side modifier getters the
-- attackerMods / defenderMods passes read. Boolean-shaped names (Is/Has/No
-- prefixes) degrade to false, every other getter to 0, so every modifier
-- branch is skipped and the modifier list stays empty. Methods whose return
-- shape matters (strengths, damage, nil-checked handles) are defined
-- explicitly on the mocks below and take precedence over this fallback.
local function combatFallback()
    return {
        __index = function(_, key)
            if key:match("^Is") or key:match("^Has") or key:match("^No") then
                return function()
                    return false
                end
            end
            return function()
                return 0
            end
        end,
    }
end

-- Combatant mock for the preview paths. opts drives the core line:
-- attackStrength / defenseStrength / rangedStrength (engine-native, times
-- 100), rangeDamage, captureChance, plus identity (owner / unitType /
-- team). GetCombatDamage uses the shared deterministic stand-in.
local function mkCombatUnit(opts)
    opts = opts or {}
    local u = {}
    function u:GetOwner()
        return opts.owner or 0
    end
    function u:GetTeam()
        return opts.team or 0
    end
    function u:GetUnitType()
        return opts.unitType or 100
    end
    function u:GetNameKey()
        local row = GameInfo.Units[opts.unitType or 100]
        return row and row.Description or ""
    end
    function u:HasName()
        return opts.hasName or false
    end
    function u:GetNameNoDesc()
        return opts.nameNoDesc or ""
    end
    function u:GetReligion()
        return opts.religion or ReligionTypes.NO_RELIGION
    end
    function u:GetPlot()
        return opts.plot
    end
    function u:GetDomainType()
        return opts.domain or DomainTypes.DOMAIN_LAND
    end
    function u:GetUnitClassType()
        return -1
    end
    function u:GetUnitCombatType()
        return -1
    end
    function u:GetDamage()
        return opts.damage or 0
    end
    function u:IsCombatUnit()
        return opts.isCombat ~= false
    end
    function u:IsEmbarked()
        return opts.embarked or false
    end
    function u:GetEmbarkedUnitDefense()
        return opts.embarkedDefense or 0
    end
    function u:IsRangedSupportFire()
        return opts.rangedSupportFire or false
    end
    -- nil-checked handle: a non-nil return would make the preview try to
    -- read a fire-support unit's damage, so this must stay nil unless a
    -- test wants support fire.
    function u:GetFireSupportUnit(_owner, _x, _y)
        return opts.fireSupport
    end
    function u:GetMaxAttackStrength(_from, _to, _defender)
        return opts.attackStrength or 0
    end
    function u:GetMaxDefenseStrength(_to, _attacker, _fromRanged)
        return opts.defenseStrength or 0
    end
    function u:GetMaxRangedCombatStrength(_unit, _city, _attacking, _ranged)
        return opts.rangedStrength or 0
    end
    function u:GetRangeCombatDamage(_unit, _city, _rand)
        return opts.rangeDamage or 0
    end
    function u:GetCombatDamage(s1, s2, curDmg, _rand, _atkCity, _defCity)
        return fakeCombatDamage(s1, s2, curDmg)
    end
    function u:GetCaptureChance(_defender)
        return opts.captureChance or 0
    end
    function u:GetAirStrikeDefenseDamage(_attacker, _rand)
        return opts.airStrikeDefense or 0
    end
    function u:GetInterceptorCount(_plot, _defender, _a, _b)
        return opts.interceptorCount or 0
    end
    return setmetatable(u, combatFallback())
end

-- City defender mock for the city-preview paths. Strength / hit points /
-- damage drive the rendered line; the fallback covers any modifier getter.
local function mkCombatCity(opts)
    opts = opts or {}
    local c = {}
    function c:GetName()
        return opts.name or "Babylon"
    end
    function c:GetOwner()
        return opts.owner or 1
    end
    function c:GetStrengthValue()
        return opts.strength or 0
    end
    function c:GetMaxHitPoints()
        return opts.maxHP or 200
    end
    function c:GetDamage()
        return opts.damage or 0
    end
    function c:GetAirStrikeDefenseDamage(_attacker, _rand)
        return opts.airStrikeDefense or 0
    end
    return setmetatable(c, combatFallback())
end

-- Plot mock with the two ground-shape probes attackerMods / defenderMods
-- read that T.fakePlot lacks; everything else (DefenseModifier, terrain,
-- ownership, river crossings) comes from fakePlot.
local function mkCombatPlot(opts)
    opts = opts or {}
    local p = T.fakePlot(opts)
    function p:IsOpenGround()
        return opts.openGround or false
    end
    function p:IsRoughGround()
        return opts.roughGround or false
    end
    return p
end

-- Player mock with the always-called combat modifier getters T.fakePlayer
-- lacks. Neutral (0) so no attacker/defender bonus surfaces.
local function mkCombatPlayer(adj)
    local p = T.fakePlayer({ adj = adj })
    p.GetAttackBonusTurns = function()
        return 0
    end
    p.GetCombatBonusVsLargerCiv = function()
        return 0
    end
    p.GetCombatBonusVsHigherTech = function()
        return 0
    end
    p.GetFoundedReligionEnemyCityCombatMod = function()
        return 0
    end
    p.GetFoundedReligionFriendlyCityCombatMod = function()
        return 0
    end
    p.GetTraitGoldenAgeCombatModifier = function()
        return 0
    end
    p.GetTraitCityStateCombatModifier = function()
        return 0
    end
    return p
end

-- Shared scaffold for the combat-preview tests: engine number formatters,
-- a fixed combat prediction, neutral combat players, and the GameInfo
-- class / terrain rows the modifier passes look up at class id -1 / terrain
-- id -1.
local function combatSetup()
    setup()
    Locale.ToLower = function(s)
        return s:lower()
    end
    Locale.ToNumber = function(n, _fmt)
        return tostring(n)
    end
    Game.GetCombatPrediction = function(_actor, _defender)
        return CombatPredictionTypes.COMBAT_PREDICTION_MAJOR_VICTORY
    end
    Players[0] = mkCombatPlayer("Roman")
    Players[1] = mkCombatPlayer("Persian")
    GameInfo.UnitClasses = { [-1] = { Description = "Test Class" } }
    GameInfo.Terrains = { [-1] = { Description = "Test Terrain" } }
end

function M.test_melee_preview_core_line()
    combatSetup()
    local actor = mkCombatUnit({ owner = 0, unitType = 100, attackStrength = 1000, plot = mkCombatPlot({}) })
    local defender = mkCombatUnit({ owner = 1, team = 1, unitType = 101, defenseStrength = 500 })
    local targetPlot = mkCombatPlot({})
    local out = UnitSpeech.meleePreview(actor, defender, targetPlot)
    -- attackStrength 1000 -> "10", defenseStrength 500 -> "5".
    -- to-them: fakeCombatDamage(1000, 500, 0) = floor(36) = 36.
    -- to-me:   fakeCombatDamage(500, 1000, 0) = floor(9)  = 9.
    T.truthy(out:find("Persian Swordsman", 1, true), "defender name expected: " .. out)
    T.truthy(out:find("10 vs 5", 1, true), "strengths expected: " .. out)
    T.truthy(out:find("major victory", 1, true), "prediction expected: " .. out)
    T.truthy(out:find("9 damage to me", 1, true), "damage-to-me expected: " .. out)
    T.truthy(out:find("36 to them", 1, true), "damage-to-them expected: " .. out)
    T.truthy(not out:find("bonuses", 1, true), "no modifier list when all mods neutral: " .. out)
end

function M.test_melee_preview_support_fire_and_capture_chance()
    combatSetup()
    local support = mkCombatUnit({ owner = 1, team = 1, unitType = 101, rangeDamage = 7 })
    local actor = mkCombatUnit({
        owner = 0,
        unitType = 100,
        attackStrength = 1000,
        captureChance = 40,
        fireSupport = support,
        plot = mkCombatPlot({}),
    })
    local defender = mkCombatUnit({ owner = 1, team = 1, unitType = 101, defenseStrength = 500 })
    local out = UnitSpeech.meleePreview(actor, defender, mkCombatPlot({}))
    -- supportDmg = support:GetRangeCombatDamage = 7; folds into the
    -- attacker's input damage and onto the defender's output.
    T.truthy(out:find("support fire 7", 1, true), "support fire line expected: " .. out)
    T.truthy(out:find("capture chance 40 percent", 1, true), "capture chance expected: " .. out)
end

function M.test_melee_preview_zero_strength_suppressed()
    combatSetup()
    local actor = mkCombatUnit({ owner = 0, attackStrength = 0, plot = mkCombatPlot({}) })
    local defender = mkCombatUnit({ owner = 1, team = 1, unitType = 101, defenseStrength = 500 })
    local out = UnitSpeech.meleePreview(actor, defender, mkCombatPlot({}))
    T.eq(out, "")
end

function M.test_ranged_preview_core_line()
    combatSetup()
    local actor = mkCombatUnit({ owner = 0, unitType = 100, rangedStrength = 900, rangeDamage = 25 })
    -- Defender has no ranged strength, so theirStrength falls through to
    -- GetMaxDefenseStrength (the migrated read) -> 500 -> "5".
    local defender = mkCombatUnit({ owner = 1, team = 1, unitType = 101, defenseStrength = 500 })
    local out = UnitSpeech.rangedPreview(actor, defender, mkCombatPlot({}))
    T.truthy(out:find("Persian Swordsman", 1, true), "defender name expected: " .. out)
    T.truthy(out:find("9 vs 5", 1, true), "strengths expected: " .. out)
    T.truthy(out:find("major victory", 1, true), "prediction expected: " .. out)
    T.truthy(out:find("25 damage to them", 1, true), "ranged damage expected: " .. out)
    T.truthy(not out:find("bonuses", 1, true), "no modifier list when all mods neutral: " .. out)
end

function M.test_ranged_preview_zero_strength_suppressed()
    combatSetup()
    local actor = mkCombatUnit({ owner = 0, rangedStrength = 0 })
    local defender = mkCombatUnit({ owner = 1, team = 1, unitType = 101, defenseStrength = 500 })
    local out = UnitSpeech.rangedPreview(actor, defender, mkCombatPlot({}))
    T.eq(out, "")
end

function M.test_city_melee_preview_core_line()
    combatSetup()
    local actor = mkCombatUnit({ owner = 0, unitType = 100, attackStrength = 1000, plot = mkCombatPlot({}) })
    local city = mkCombatCity({ name = "Babylon", owner = 1, strength = 500, maxHP = 200 })
    local out = UnitSpeech.cityMeleePreview(actor, city, mkCombatPlot({}))
    -- to-them (city): fakeCombatDamage(1000, 500, 0) = 36.
    -- to-me:          fakeCombatDamage(500, 1000, 0) = 9.
    T.truthy(out:find("city Babylon", 1, true), "city name expected: " .. out)
    T.truthy(out:find("10 vs 5", 1, true), "strengths expected: " .. out)
    T.truthy(out:find("9 damage to me", 1, true), "damage-to-me expected: " .. out)
    T.truthy(out:find("36 to them", 1, true), "damage-to-city expected: " .. out)
    T.truthy(not out:find("victory", 1, true), "city preview has no prediction verdict: " .. out)
end

-- City and unit HP caps clamp the two damage numbers. A huge attack
-- strength would compute past the city's max HP / the unit's max HP; the
-- preview reports the capped values.
function M.test_city_melee_preview_caps_damage_at_max_hp()
    combatSetup()
    local actor = mkCombatUnit({ owner = 0, unitType = 100, attackStrength = 100000, plot = mkCombatPlot({}) })
    local city = mkCombatCity({ name = "Babylon", owner = 1, strength = 100, maxHP = 200 })
    local out = UnitSpeech.cityMeleePreview(actor, city, mkCombatPlot({}))
    -- to-them = fakeCombatDamage(100000, 100, 0) = 18000, capped to maxHP 200.
    T.truthy(out:find("200 to them", 1, true), "city damage capped at max HP: " .. out)
end

function M.test_city_ranged_preview_core_line()
    combatSetup()
    local actor = mkCombatUnit({ owner = 0, unitType = 100, rangedStrength = 900, rangeDamage = 25 })
    local city = mkCombatCity({ name = "Babylon", owner = 1, strength = 500, maxHP = 200 })
    local out = UnitSpeech.cityRangedPreview(actor, city, mkCombatPlot({}))
    T.truthy(out:find("city Babylon", 1, true), "city name expected: " .. out)
    T.truthy(out:find("9 vs 5", 1, true), "strengths expected: " .. out)
    T.truthy(out:find("25 damage to them", 1, true), "ranged damage to city expected: " .. out)
end

-- ===== Combat result =====

function M.test_combat_result_both_sides_take_damage()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Warrior",
        attackerDamage = 12,
        attackerFinalDamage = 12,
        attackerMaxHP = 100,
        defenderName = "Swordsman",
        defenderDamage = 30,
        defenderFinalDamage = 30,
        defenderMaxHP = 100,
    })
    T.truthy(out:find("attacker Warrior %-12 hp"), "attacker damage expected: " .. out)
    T.truthy(out:find("defender Swordsman %-30 hp"), "defender damage expected: " .. out)
    T.truthy(not out:find("killed"), "no kill when both survive: " .. out)
end

-- Kill threshold must respect the per-side max HP the event sends, not
-- the unit default. A city with 200 max HP taking 150 damage is at
-- 25% HP -- alive; the old hardcoded 100 check would have spuriously
-- announced it destroyed.
function M.test_combat_result_kill_threshold_uses_event_max_hp()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Warrior",
        attackerDamage = 0,
        attackerFinalDamage = 0,
        attackerMaxHP = 100,
        defenderName = "Swordsman",
        defenderDamage = 150,
        defenderFinalDamage = 150,
        defenderMaxHP = 200,
    })
    T.truthy(out:find("defender Swordsman %-150 hp"), "damage expected: " .. out)
    T.truthy(not out:find("killed"), "city at 25%% HP must not be reported killed: " .. out)
end

function M.test_combat_result_defender_killed_appends_kill_line()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Warrior",
        attackerDamage = 0,
        attackerFinalDamage = 0,
        attackerMaxHP = 100,
        defenderName = "Swordsman",
        defenderDamage = 100,
        defenderFinalDamage = 100,
        defenderMaxHP = 100,
    })
    T.truthy(out:find("Swordsman killed", 1, true), "kill line expected: " .. out)
end

-- Captured city: HP went to max (engine signals "down") but the city
-- was taken, not destroyed. The defender outcome line swaps "killed"
-- for "captured" so the combat readout pins the outcome to the combat
-- itself; SerialEventCityCaptured still speaks the ownership-aware
-- "We captured X" / "We lost X" alongside.
function M.test_combat_result_captured_city_uses_captured_line()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Warrior",
        attackerDamage = 5,
        attackerFinalDamage = 5,
        attackerMaxHP = 100,
        defenderName = "Babylon",
        defenderDamage = 50,
        defenderFinalDamage = 200,
        defenderMaxHP = 200,
        defenderCaptured = true,
    })
    T.truthy(not out:find("Babylon killed", 1, true), "captured city must not say killed: " .. out)
    T.truthy(out:find("Babylon captured", 1, true), "captured line expected: " .. out)
    T.truthy(out:find("Babylon %-50 hp"), "damage line still expected: " .. out)
end

-- Ranged combat routinely leaves the attacker undamaged. The prior
-- "skip if zero" formatter dropped the attacker from the readout
-- entirely, leaving the user unsure who fired. Both sides must always
-- be named.
function M.test_combat_result_zero_damage_attacker_still_named_unhurt()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Crossbowman",
        attackerDamage = 0,
        attackerFinalDamage = 0,
        attackerMaxHP = 100,
        defenderName = "Warrior",
        defenderDamage = 25,
        defenderFinalDamage = 25,
        defenderMaxHP = 100,
    })
    T.truthy(out:find("attacker Crossbowman unhurt", 1, true), "attacker must speak even at 0 damage: " .. out)
    T.truthy(out:find("defender Warrior %-25 hp"), "defender damage still expected: " .. out)
end

function M.test_combat_result_zero_damage_defender_still_named_unhurt()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Warrior",
        attackerDamage = 10,
        attackerFinalDamage = 10,
        attackerMaxHP = 100,
        defenderName = "Spearman",
        defenderDamage = 0,
        defenderFinalDamage = 0,
        defenderMaxHP = 100,
    })
    T.truthy(out:find("attacker Warrior %-10 hp"), "attacker damage still expected: " .. out)
    T.truthy(out:find("defender Spearman unhurt", 1, true), "defender must speak even at 0 damage: " .. out)
end

-- Air-strike intercept. The engine fork lumps interceptor damage into
-- the attacker's total damage; the intercept clause names who fired
-- without splitting attribution. Sits between damage lines and any
-- kill line.
function M.test_combat_result_intercepted_appends_intercept_clause()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Bomber",
        attackerDamage = 30,
        attackerFinalDamage = 30,
        attackerMaxHP = 100,
        defenderName = "Warrior",
        defenderDamage = 10,
        defenderFinalDamage = 10,
        defenderMaxHP = 100,
        interceptorName = "Persian Fighter",
    })
    T.truthy(out:find("intercepted by Persian Fighter", 1, true), "intercept clause expected: " .. out)
    T.truthy(out:find("attacker Bomber %-30 hp"), "attacker damage still present: " .. out)
end

-- nil interceptor (non-air combat, or air strike with no interceptor
-- available) must not introduce a stray intercept clause.
function M.test_combat_result_no_interceptor_no_intercept_clause()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Warrior",
        attackerDamage = 12,
        attackerFinalDamage = 12,
        attackerMaxHP = 100,
        defenderName = "Swordsman",
        defenderDamage = 30,
        defenderFinalDamage = 30,
        defenderMaxHP = 100,
        interceptorName = nil,
    })
    T.truthy(not out:find("intercept", 1, true), "no intercept clause when interceptor is nil: " .. out)
end

-- City-as-attacker (city ranged strike) reuses the combat formatter with
-- a bare-city-name attacker. City takes no damage from its own strike,
-- so the attacker line falls into the unhurt branch.
function M.test_combat_result_city_attacker_uses_bare_city_name()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Babylon",
        attackerDamage = 0,
        attackerFinalDamage = 0,
        attackerMaxHP = 200,
        defenderName = "Roman Warrior",
        defenderDamage = 15,
        defenderFinalDamage = 15,
        defenderMaxHP = 100,
    })
    T.truthy(
        out:find("attacker Babylon unhurt", 1, true),
        "city attacker should read as unhurt with bare name: " .. out
    )
    T.truthy(out:find("defender Roman Warrior %-15 hp"), "defender damage expected: " .. out)
end

-- Air sweep into ground AA prepends "interception" so the user knows the
-- damage line came from a sweep, not a strike. Defender (the AA) takes
-- zero damage in this engine path; the unhurt branch handles that
-- naturally.
function M.test_combat_result_sweep_one_way_prepends_interception()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "American Fighter",
        attackerDamage = 8,
        attackerFinalDamage = 8,
        attackerMaxHP = 100,
        defenderName = "Roman Anti-Aircraft Gun",
        defenderDamage = 0,
        defenderFinalDamage = 0,
        defenderMaxHP = 100,
        combatKind = 1,
    })
    T.truthy(out:find("^interception"), "interception prefix expected: " .. out)
    T.truthy(out:find("Roman Anti%-Aircraft Gun unhurt"), "AA unhurt expected: " .. out)
end

function M.test_combat_result_sweep_dogfight_prepends_dogfight()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "American Fighter",
        attackerDamage = 12,
        attackerFinalDamage = 12,
        attackerMaxHP = 100,
        defenderName = "Roman Fighter",
        defenderDamage = 18,
        defenderFinalDamage = 18,
        defenderMaxHP = 100,
        combatKind = 2,
    })
    T.truthy(out:find("^dogfight"), "dogfight prefix expected: " .. out)
end

-- combatKind nil / 0 must not introduce a stray prefix on normal combat.
function M.test_combat_result_normal_combat_no_kind_prefix()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Warrior",
        attackerDamage = 12,
        attackerFinalDamage = 12,
        attackerMaxHP = 100,
        defenderName = "Swordsman",
        defenderDamage = 30,
        defenderFinalDamage = 30,
        defenderMaxHP = 100,
    })
    T.truthy(not out:find("interception"), "no interception prefix on normal combat: " .. out)
    T.truthy(not out:find("dogfight"), "no dogfight prefix on normal combat: " .. out)
end

-- Bomber killed by intercept: the intercept clause appears before the
-- kill line, keeping "Bomber killed" as the readout's tail.
function M.test_combat_result_intercept_kill_keeps_kill_line_last()
    setup()
    local out = UnitSpeech.combatResult({
        attackerName = "Bomber",
        attackerDamage = 100,
        attackerFinalDamage = 100,
        attackerMaxHP = 100,
        defenderName = "Warrior",
        defenderDamage = 0,
        defenderFinalDamage = 0,
        defenderMaxHP = 100,
        interceptorName = "Persian Fighter",
    })
    local interceptPos = out:find("intercepted by Persian Fighter", 1, true)
    local killPos = out:find("Bomber killed", 1, true)
    T.truthy(interceptPos ~= nil, "intercept clause expected: " .. out)
    T.truthy(killPos ~= nil, "kill line expected: " .. out)
    T.truthy(interceptPos < killPos, "intercept must precede kill: " .. out)
end

-- ===== Nuclear strike =====
-- Composed string from the engine fork's NukeStart / NukeUnitAffected /
-- NukeCityAffected / NukeEnd hook stream. Sections elide when empty so
-- an inert nuke reads cleanly.
function M.test_nuclear_strike_full_payload()
    setup()
    local out = UnitSpeech.nuclearStrikeResult({
        launcherCivAdj = "Roman",
        targetName = "Babylon",
        cities = {
            { displayName = "Babylon", hpDelta = 50, popDelta = 3, wasDestroyed = false },
        },
        units = {
            { displayName = "Babylonian Worker", hpDelta = 100, killed = true },
            { displayName = "Babylonian Warrior", hpDelta = 8, killed = false },
        },
    })
    T.truthy(out:find("^Roman nuclear strike"), "header must lead: " .. out)
    T.truthy(out:find("target Babylon", 1, true), "target line expected: " .. out)
    T.truthy(out:find("casualties Babylon %-50 hp %-3 pop"), "city damage + pop expected: " .. out)
    T.truthy(out:find("units"), "units section expected: " .. out)
    T.truthy(out:find("Babylonian Worker %-100 hp killed"), "killed unit expected: " .. out)
    T.truthy(out:find("Babylonian Warrior %-8 hp"), "damaged unit expected: " .. out)
    T.truthy(not out:find("destroyed"), "no destroyed marker on alive city: " .. out)
    T.truthy(not out:find("no targets hit"), "no inert clause when entities affected: " .. out)
end

function M.test_nuclear_strike_destroyed_city_drops_pop_clause()
    setup()
    local out = UnitSpeech.nuclearStrikeResult({
        launcherCivAdj = "American",
        targetName = "Rome",
        cities = {
            { displayName = "Rome", hpDelta = 200, popDelta = 0, wasDestroyed = true },
        },
        units = {},
    })
    T.truthy(out:find("Rome %-200 hp destroyed"), "destroyed marker expected: " .. out)
    T.truthy(not out:find("pop"), "pop clause must elide on destroyed city: " .. out)
    T.truthy(not out:find("units"), "units section must elide when empty: " .. out)
end

function M.test_nuclear_strike_no_targets_announces_inert()
    setup()
    local out = UnitSpeech.nuclearStrikeResult({
        launcherCivAdj = "American",
        targetName = nil,
        cities = {},
        units = {},
    })
    T.truthy(out:find("^American nuclear strike"), "header expected: " .. out)
    T.truthy(out:find("no targets hit", 1, true), "inert clause expected: " .. out)
    T.truthy(not out:find("target "), "no target clause when nothing on plot: " .. out)
end

function M.test_nuclear_strike_units_only_no_target_city()
    setup()
    local out = UnitSpeech.nuclearStrikeResult({
        launcherCivAdj = "American",
        targetName = nil,
        cities = {},
        units = {
            { displayName = "Roman Worker", hpDelta = 100, killed = true },
        },
    })
    T.truthy(out:find("units Roman Worker %-100 hp killed"), "units section expected: " .. out)
    T.truthy(not out:find("casualties"), "no casualties clause when no city affected: " .. out)
    T.truthy(not out:find("no targets hit"), "no inert clause when units affected: " .. out)
end

-- Combatant-name lookup helper. The single point of "playerId + unitId
-- -> display name" resolution; called by UnitControl.onCombatResolved
-- to label combat-result speech.
function M.test_combatant_name_resolves_via_player_lookup()
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    Players[0].GetUnitByID = function(_, id)
        if id == 1 then
            return mkUnit({ unitType = 100 })
        end
        return nil
    end
    T.eq(UnitSpeech.combatantName(0, 1), "Roman Warrior")
end

function M.test_combatant_name_returns_empty_when_unit_gone()
    setup()
    Players[0] = {
        GetUnitByID = function()
            return nil
        end,
    }
    T.eq(UnitSpeech.combatantName(0, 999), "")
end

function M.test_combatant_name_returns_empty_when_player_missing()
    setup()
    T.eq(UnitSpeech.combatantName(42, 1), "")
end

-- ===== City combatant name =====
-- Mirror of combatantName for cities. Used by onCombatResolved to label
-- city defenders in combat-result speech.
function M.test_city_combatant_name_resolves_via_player_lookup()
    setup()
    Players[5] = {
        GetCityByID = function(_, id)
            if id == 7 then
                return {
                    GetName = function()
                        return "Athens"
                    end,
                }
            end
            return nil
        end,
    }
    T.eq(UnitSpeech.cityCombatantName(5, 7), "Athens")
end

function M.test_city_combatant_name_returns_empty_when_city_gone()
    setup()
    Players[5] = {
        GetCityByID = function()
            return nil
        end,
    }
    T.eq(UnitSpeech.cityCombatantName(5, 99), "")
end

function M.test_city_combatant_name_returns_empty_when_player_missing()
    setup()
    T.eq(UnitSpeech.cityCombatantName(42, 1), "")
end

return M

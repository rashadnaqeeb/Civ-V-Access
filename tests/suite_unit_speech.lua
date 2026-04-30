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
    return u
end

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    -- Required by UnitSpeech.statusToken's ACTIVITY_MISSION rung (calls
    -- Waypoints.finalAndTurns when the head-selected unit matches). The
    -- module's lookup paths short-circuit on the polyfill's nil
    -- UI.GetHeadSelectedUnit, so loading is enough; tests that exercise
    -- the queued-to rung set their own UI / Waypoints fixtures.
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
    T.truthy(
        out:find("embarked George %(Roman Warrior%)"),
        "embarked prefix must wrap the personal-name form: " .. out
    )
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

function M.test_selection_status_queued_mission()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("queued move", 1, true), "queued move status expected: " .. out)
end

-- Engine-fork variant: when the unit IS the head-selected one and
-- WaypointsCore has a final waypoint + total-turn count, the rung
-- becomes "queued move <dir>, N turns". This path stubs Waypoints
-- directly so the test isolates statusToken's branching from the
-- pathfinder-driven WaypointsCore internals.
function M.test_selection_status_queued_mission_with_waypoints()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION, x = 0, y = 0 })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origFinal = Waypoints.finalAndTurns
    Waypoints.finalAndTurns = function()
        return { x = 3, y = 0, turns = 2 }
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.finalAndTurns = origFinal
    T.truthy(out:find("queued move 3e, 2 turns", 1, true), "queued-to rung expected: " .. out)
end

-- Falls back to the bare "queued move" when Waypoints has no final
-- (empty queue, all path-bearing legs unreachable, etc.).
function M.test_selection_status_queued_mission_falls_back_when_no_waypoints()
    setup()
    local u = mkUnit({ activity = ActivityTypes.ACTIVITY_MISSION })
    UI.GetHeadSelectedUnit = function()
        return u
    end
    local origFinal = Waypoints.finalAndTurns
    Waypoints.finalAndTurns = function()
        return nil
    end
    local out = UnitSpeech.selection(u, 0, 0)
    Waypoints.finalAndTurns = origFinal
    T.truthy(out:find("queued move", 1, true), "queued move fallback expected: " .. out)
    T.truthy(not out:find("turns", 1, true), "no turns suffix when waypoints unavailable: " .. out)
end

function M.test_selection_status_building_wins_over_queued_mission()
    -- A worker executing a build has ACTIVITY_MISSION set by the engine.
    -- The cascade puts the build rung first so the user hears the more
    -- specific "Build Farm 5 turns" instead of a bare "queued move".
    setup()
    GameInfo.Builds[7] = { Description = "Build Farm" }
    local plot = T.fakePlot({ x = 0, y = 0 })
    plot._buildTurns[7] = 4
    local u = mkUnit({ buildType = 7, plot = plot, activity = ActivityTypes.ACTIVITY_MISSION })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("Build Farm 5 turns", 1, true), "building should win: " .. out)
    T.truthy(not out:find("queued move", 1, true), "queued move must not also fire: " .. out)
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

function M.test_info_hp_always_last()
    setup()
    local u = mkUnit({ damage = 30, combat = 10, ranged = 9, range = 2, upgradeType = 101, upgradePrice = 120 })
    local out = UnitSpeech.info(u)
    -- HP fraction must be the final comma-separated token. Split on
    -- ", " and inspect the tail to avoid a brittle prefix assertion.
    local parts = {}
    for part in (out .. ", "):gmatch("(.-), ") do
        parts[#parts + 1] = part
    end
    T.truthy(#parts > 0, "info must produce parts: " .. out)
    local last = parts[#parts]
    T.truthy(last:find("hp", 1, true), "last token must be HP: " .. tostring(last))
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

function M.test_info_hp_stays_last_when_status_present()
    setup()
    local u = mkUnit({ fortifyTurns = 3, damage = 40 })
    local out = UnitSpeech.info(u)
    local parts = {}
    for part in (out .. ", "):gmatch("(.-), ") do
        parts[#parts + 1] = part
    end
    T.truthy(#parts > 0, "info must produce parts: " .. out)
    T.truthy(parts[#parts]:find("hp", 1, true), "HP must stay the final token: " .. out)
    T.truthy(out:find("TXT_KEY_UNIT_STATUS_FORTIFIED", 1, true), "fortified must appear before HP: " .. out)
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

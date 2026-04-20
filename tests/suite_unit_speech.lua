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
        _isCombat = (opts.isCombat ~= false),
        _plot = opts.plot,
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
    function u:IsCombatUnit()
        return self._isCombat
    end
    return u
end

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
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
    Players = {}
    GameDefines = GameDefines or {}
    GameDefines.MAX_HIT_POINTS = 100
    GameDefines.MOVE_DENOMINATOR = 60
end

-- ===== Selection: direction prefix =====

function M.test_selection_zero_delta_no_direction_prefix()
    setup()
    local u = mkUnit({ x = 5, y = 5 })
    local out = UnitSpeech.selection(u, 5, 5)
    T.truthy(not out:find("^%d"), "zero-delta must not start with a direction token: " .. out)
    T.truthy(out:find("^Warrior"), "zero-delta must start with name: " .. out)
end

function M.test_selection_non_zero_delta_leads_with_direction()
    setup()
    local u = mkUnit({ x = 3, y = 0 })
    local out = UnitSpeech.selection(u, 0, 0)
    -- 3 hexes east: directionString yields "3e". Assert direction
    -- leads the string so screen readers hear orientation first.
    T.truthy(out:find("^3e, Warrior"), "direction must lead: " .. out)
end

-- ===== Selection: embarked prefix =====

function M.test_selection_embarked_prefix_on_name()
    setup()
    local u = mkUnit({ embarked = true })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(out:find("embarked Warrior", 1, true), "embarked prefix expected: " .. out)
end

function M.test_selection_not_embarked_no_prefix()
    setup()
    local u = mkUnit({ embarked = false })
    local out = UnitSpeech.selection(u, 0, 0)
    T.truthy(not out:find("embarked", 1, true), "no embarked prefix when not embarked: " .. out)
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
    T.truthy(out:find("10 combat", 1, true), "combat strength expected: " .. out)
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
    T.truthy(not out1:find("upgrade", 1, true), "no upgrade line when unit can't upgrade: " .. out1)

    setup()
    local u2 = mkUnit({ upgradeType = 101, upgradePrice = 120 })
    local out2 = UnitSpeech.info(u2)
    T.truthy(out2:find("upgrade to Swordsman, 120 gold", 1, true), "upgrade line expected: " .. out2)
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

-- ===== Move result =====

function M.test_move_result_clean_arrival()
    setup()
    local u = mkUnit({ x = 4, y = 4, moves = 60 })
    local out = UnitSpeech.moveResult(u, 4, 4)
    T.truthy(out:find("moved", 1, true), "clean arrival expected: " .. out)
    T.truthy(out:find("1 moves left", 1, true), "moves-left should be 1: " .. out)
end

function M.test_move_result_short_stop()
    setup()
    local u = mkUnit({ x = 2, y = 2, moves = 0 })
    local out = UnitSpeech.moveResult(u, 4, 4)
    T.truthy(out:find("stopped short", 1, true), "short-stop expected: " .. out)
end

-- ===== Self-plot confirm =====

function M.test_self_plot_confirm_known_tokens()
    setup()
    T.eq(UnitSpeech.selfPlotConfirm("FORTIFY"), "fortified")
    T.eq(UnitSpeech.selfPlotConfirm("SLEEP"), "sleeping")
    T.eq(UnitSpeech.selfPlotConfirm("AUTOMATE"), "automated")
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
    Players[0] = {
        GetUnitByID = function(_, id)
            if id == 1 then
                return mkUnit({ unitType = 100 })
            end
            return nil
        end,
    }
    Players[1] = {
        GetUnitByID = function(_, id)
            if id == 2 then
                return mkUnit({ unitType = 101 })
            end
            return nil
        end,
    }
    local out = UnitSpeech.combatResult({
        attackerPlayer = 0,
        attackerUnit = 1,
        attackerInitialDamage = 0,
        attackerFinalDamage = 12,
        defenderPlayer = 1,
        defenderUnit = 2,
        defenderInitialDamage = 0,
        defenderFinalDamage = 30,
    })
    T.truthy(out:find("attacker Warrior %-12 hp"), "attacker damage expected: " .. out)
    T.truthy(out:find("defender Swordsman %-30 hp"), "defender damage expected: " .. out)
    T.truthy(not out:find("killed"), "no kill when both survive: " .. out)
end

function M.test_combat_result_defender_killed_appends_kill_line()
    setup()
    Players[0] = {
        GetUnitByID = function()
            return mkUnit({ unitType = 100 })
        end,
    }
    Players[1] = {
        GetUnitByID = function()
            return mkUnit({ unitType = 101 })
        end,
    }
    local out = UnitSpeech.combatResult({
        attackerPlayer = 0,
        attackerUnit = 1,
        attackerInitialDamage = 0,
        attackerFinalDamage = 0,
        defenderPlayer = 1,
        defenderUnit = 2,
        defenderInitialDamage = 0,
        defenderFinalDamage = 100,
    })
    T.truthy(out:find("Swordsman killed", 1, true), "kill line expected: " .. out)
end

return M

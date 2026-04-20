-- Test support: assertion helpers and a flat registration/runner model.
-- Suites return a table of test_*/Test* functions; the runner aggregates.

local T = {}
T.cases = {}

function T.case(name, fn)
    T.cases[#T.cases + 1] = { name = name, fn = fn }
end

function T.register(prefix, mod)
    -- Sort keys for deterministic execution order.
    local keys = {}
    for k in pairs(mod) do
        if type(k) == "string" and (k:match("^test") or k:match("^Test")) then
            keys[#keys + 1] = k
        end
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
        T.case(prefix .. "." .. k, mod[k])
    end
end

local function fmt(v)
    if type(v) == "string" then return string.format("%q", v) end
    return tostring(v)
end

function T.eq(actual, expected, note)
    if actual ~= expected then
        error((note and (note .. ": ") or "")
            .. "expected " .. fmt(expected) .. ", got " .. fmt(actual), 2)
    end
end

function T.truthy(v, note)
    if not v then error((note or "expected truthy") .. ", got " .. fmt(v), 2) end
end

function T.falsy(v, note)
    if v then error((note or "expected falsy") .. ", got " .. fmt(v), 2) end
end

-- Fake engine handles for cursor / plot-section tests. These are NOT in
-- CivVAccess_Polyfill because the polyfill only ships engine-wide globals
-- (Map, Game, Players, ...). Per-test-case fixtures (a specific plot's
-- terrain / units / fog state) are scenario data and live with the tests.
function T.fakePlot(opts)
    opts = opts or {}
    local p = {
        _x = opts.x or 0,
        _y = opts.y or 0,
        _isCity = opts.isCity or false,
        _city = opts.city,
        _isRevealed = (opts.revealed ~= false),
        _isVisible  = (opts.visible  ~= false),
        _isLake = opts.lake or false,
        _isHills = opts.hills or false,
        _isMountain = opts.mountain or false,
        _isFreshWater = opts.freshWater or false,
        _isTradeRoute = opts.tradeRoute or false,
        _isImpPillaged = opts.improvementPillaged or false,
        _isRoutePillaged = opts.routePillaged or false,
        _terrain = opts.terrain or -1,
        _feature = opts.feature or -1,
        _resource = opts.resource or -1,
        _resourceQty = opts.resourceQty or 0,
        _improvement = opts.improvement or -1,
        _route = opts.route or -1,
        _owner = (opts.owner == nil) and -1 or opts.owner,
        _units = opts.units or {},
        _layerUnits = opts.layerUnits or {},
        _isWOfRiver = opts.wOfRiver or false,
        _isNWOfRiver = opts.nwOfRiver or false,
        _isNEOfRiver = opts.neOfRiver or false,
        _yields = opts.yields or {},
        _workingCity = opts.workingCity,
        _defenseMod = opts.defenseMod or 0,
        _buildTurns = opts.buildTurns or {},
    }
    function p:GetX() return self._x end
    function p:GetY() return self._y end
    function p:IsCity() return self._isCity end
    function p:GetPlotCity() return self._city end
    function p:IsRevealed(_team, _debug) return self._isRevealed end
    function p:IsVisible(_team, _debug) return self._isVisible end
    function p:IsLake() return self._isLake end
    function p:IsHills() return self._isHills end
    function p:IsMountain() return self._isMountain end
    function p:IsFreshWater() return self._isFreshWater end
    function p:IsTradeRoute() return self._isTradeRoute end
    function p:IsImprovementPillaged() return self._isImpPillaged end
    function p:IsRoutePillaged() return self._isRoutePillaged end
    function p:GetTerrainType() return self._terrain end
    function p:GetFeatureType() return self._feature end
    function p:GetResourceType(_team) return self._resource end
    function p:GetNumResource() return self._resourceQty end
    function p:GetRevealedImprovementType(_team, _debug) return self._improvement end
    function p:GetRevealedRouteType(_team, _debug) return self._route end
    function p:GetRevealedOwner(_team, _debug) return self._owner end
    function p:GetOwner() return self._owner end
    function p:GetNumUnits() return #self._units end
    function p:GetUnit(i) return self._units[i + 1] end
    function p:GetNumLayerUnits() return #self._layerUnits end
    function p:GetLayerUnit(i) return self._layerUnits[i + 1] end
    function p:IsWOfRiver() return self._isWOfRiver end
    function p:IsNWOfRiver() return self._isNWOfRiver end
    function p:IsNEOfRiver() return self._isNEOfRiver end
    function p:CalculateYield(yid, _disp) return self._yields[yid] or 0 end
    function p:GetWorkingCity() return self._workingCity end
    function p:DefenseModifier(_team, _ignoreBuilding, _help) return self._defenseMod end
    function p:GetBuildTurnsLeft(buildId, _player, _extra1, _extra2)
        return self._buildTurns[buildId] or 0
    end
    return p
end

function T.fakeUnit(opts)
    opts = opts or {}
    local u = {
        _owner = opts.owner or 0,
        _team = opts.team or 0,
        _isInvisible = opts.invisible or false,
        _isCargo = opts.cargo or false,
        _domain = opts.domain or DomainTypes.DOMAIN_LAND,
        _hasName = opts.hasName or false,
        _nameKey = opts.nameKey or "Warrior",
        _nameNoDesc = opts.nameNoDesc or "Genghis",
        _damage = opts.damage or 0,
        _isCombatUnit = (opts.combat ~= false),
    }
    function u:GetOwner() return self._owner end
    function u:GetTeam() return self._team end
    function u:IsInvisible(_team, _debug) return self._isInvisible end
    function u:IsCargo() return self._isCargo end
    function u:GetDomainType() return self._domain end
    function u:HasName() return self._hasName end
    function u:GetNameKey() return self._nameKey end
    function u:GetNameNoDesc() return self._nameNoDesc end
    function u:GetDamage() return self._damage end
    function u:IsCombatUnit() return self._isCombatUnit end
    function u:GetPlot() return self._plot end
    return u
end

function T.fakePlayer(opts)
    opts = opts or {}
    local p = {
        _adj = opts.adj or "Roman",
        _shortDesc = opts.shortDesc or "Rome",
        _isMinor = opts.isMinor or false,
        _team = opts.team or 0,
        _capital = opts.capital,
        _nick = opts.nick,
    }
    function p:GetCivilizationAdjectiveKey() return self._adj end
    function p:GetCivilizationShortDescriptionKey() return self._shortDesc end
    function p:IsMinorCiv() return self._isMinor end
    function p:GetTeam() return self._team end
    function p:GetCapitalCity() return self._capital end
    function p:GetNickName() return self._nick end
    return p
end

function T.fakeCity(opts)
    opts = opts or {}
    local c = {
        _name = opts.name or "Rome",
        _owner = opts.owner or 0,
        _id = opts.id or 1,
        _plot = opts.plot,
    }
    function c:GetName() return self._name end
    function c:GetOwner() return self._owner end
    function c:GetID() return self._id end
    function c:Plot() return self._plot end
    return c
end

function T.fakeTeam(opts)
    opts = opts or {}
    local team = {
        _atWar = opts.atWar or {},
    }
    function team:IsAtWar(other) return self._atWar[other] or false end
    return team
end

function T.run()
    local passed, failed = 0, {}
    for _, c in ipairs(T.cases) do
        local ok, err = pcall(c.fn)
        if ok then
            passed = passed + 1
        else
            failed[#failed + 1] = { name = c.name, err = err }
        end
    end
    print(string.format("%d passed, %d failed (of %d)",
        passed, #failed, #T.cases))
    for _, f in ipairs(failed) do
        print("  FAIL " .. f.name)
        print("       " .. tostring(f.err))
    end
    return #failed == 0
end

return T

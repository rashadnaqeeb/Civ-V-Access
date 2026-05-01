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
    if type(v) == "string" then
        return string.format("%q", v)
    end
    return tostring(v)
end

function T.eq(actual, expected, note)
    if actual ~= expected then
        error((note and (note .. ": ") or "") .. "expected " .. fmt(expected) .. ", got " .. fmt(actual), 2)
    end
end

function T.truthy(v, note)
    if not v then
        error((note or "expected truthy") .. ", got " .. fmt(v), 2)
    end
end

function T.falsy(v, note)
    if v then
        error((note or "expected falsy") .. ", got " .. fmt(v), 2)
    end
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
        _plotIndex = opts.plotIndex or 0,
        _isCity = opts.isCity or false,
        _city = opts.city,
        _isRevealed = (opts.revealed ~= false),
        _isVisible = (opts.visible ~= false),
        _isLake = opts.lake or false,
        _isHills = opts.hills or false,
        _isMountain = opts.mountain or false,
        _isFreshWater = opts.freshWater or false,
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
        _isRiver = opts.river or false,
        _yields = opts.yields or {},
        _workingCity = opts.workingCity,
        _defenseMod = opts.defenseMod or 0,
        _buildTurns = opts.buildTurns or {},
        _isWater = opts.water or false,
        _plotType = opts.plotType or PlotTypes.PLOT_LAND,
        _hasVisibleEnemy = opts.hasVisibleEnemy or false,
        _friendlyStackCount = opts.friendlyStackCount or 0,
    }
    function p:GetX()
        return self._x
    end
    function p:GetY()
        return self._y
    end
    function p:GetPlotIndex()
        return self._plotIndex
    end
    function p:IsCity()
        return self._isCity
    end
    function p:GetPlotCity()
        return self._city
    end
    function p:IsRevealed(_team, _debug)
        return self._isRevealed
    end
    function p:IsVisible(_team, _debug)
        return self._isVisible
    end
    function p:IsLake()
        return self._isLake
    end
    function p:IsHills()
        return self._isHills
    end
    function p:IsMountain()
        return self._isMountain
    end
    function p:IsFreshWater()
        return self._isFreshWater
    end
    function p:IsImprovementPillaged()
        return self._isImpPillaged
    end
    function p:IsRoutePillaged()
        return self._isRoutePillaged
    end
    function p:GetTerrainType()
        return self._terrain
    end
    function p:GetFeatureType()
        return self._feature
    end
    function p:GetResourceType(_team)
        return self._resource
    end
    function p:GetNumResource()
        return self._resourceQty
    end
    function p:GetRevealedImprovementType(_team, _debug)
        return self._improvement
    end
    function p:GetRevealedRouteType(_team, _debug)
        return self._route
    end
    function p:GetRevealedOwner(_team, _debug)
        return self._owner
    end
    function p:GetOwner()
        return self._owner
    end
    function p:IsOwned()
        return self._owner >= 0
    end
    function p:GetNumUnits()
        return #self._units
    end
    function p:GetUnit(i)
        return self._units[i + 1]
    end
    -- Mirror engine semantics: iLayerID = -1 (default) returns base
    -- units plus every non-base layer. We don't model per-layer indexing
    -- here -- a fixture that needs a unit on a specific non-base layer
    -- (e.g. trade) sets _layerUnits; everything else uses _units.
    function p:GetNumLayerUnits(_iLayerID)
        return #self._units + #self._layerUnits
    end
    function p:GetLayerUnit(i, _iLayerID)
        local idx = i + 1
        if idx <= #self._units then
            return self._units[idx]
        end
        return self._layerUnits[idx - #self._units]
    end
    function p:IsWOfRiver()
        return self._isWOfRiver
    end
    function p:IsNWOfRiver()
        return self._isNWOfRiver
    end
    function p:IsNEOfRiver()
        return self._isNEOfRiver
    end
    function p:IsRiver()
        return self._isRiver
    end
    function p:CalculateYield(yid, _disp)
        return self._yields[yid] or 0
    end
    function p:GetYield(yid)
        return self._yields[yid] or 0
    end
    function p:GetWorkingCity()
        return self._workingCity
    end
    function p:DefenseModifier(_team, _ignoreBuilding, _help)
        return self._defenseMod
    end
    function p:GetBuildTurnsLeft(buildId, _player, _extra1, _extra2)
        return self._buildTurns[buildId] or 0
    end
    function p:IsWater()
        return self._isWater
    end
    function p:GetPlotType()
        return self._plotType
    end
    function p:GetRouteType()
        return self._route
    end
    function p:IsVisibleEnemyUnit(_player)
        return self._hasVisibleEnemy
    end
    function p:GetNumFriendlyUnitsOfType(_unit)
        return self._friendlyStackCount
    end
    function p:IsImpassable()
        return self._isMountain
    end
    -- Geometric LoS probe. Tests that need fine-grained LoS results pass
    -- opts.canSeePlot = function(target, team, range, dir) -> bool. Default
    -- behavior matches the engine's "always sees self / sees everywhere" --
    -- only the cursor targetability suite overrides it. HasLineOfSight is
    -- the engine fork's pure-LoS sibling; it delegates to the same opts hook
    -- since the underlying obstruction question is the same.
    function p:CanSeePlot(target, team, range, dir)
        if opts.canSeePlot ~= nil then
            return opts.canSeePlot(target, team, range, dir)
        end
        return true
    end
    function p:HasLineOfSight(target, team)
        if opts.canSeePlot ~= nil then
            return opts.canSeePlot(target, team, nil, nil)
        end
        return true
    end
    -- Vanilla CvPlot::IsFriendlyTerritory: false when unowned (NO_TEAM),
    -- true on same team, true for city-state OB / major OB grant. Tests
    -- pass an _isFriendly map keyed by player to model OB grants.
    function p:IsFriendlyTerritory(player)
        if self._owner == -1 then
            return false
        end
        if self._owner == player then
            return true
        end
        return (opts.isFriendlyTerritory or {})[player] or false
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
        _unitType = opts.unitType or -1,
        _maxMoves = opts.maxMoves or 120,
        _movesLeft = opts.movesLeft or opts.maxMoves or 120,
        _promotions = opts.promotions or {},
        _plot = opts.plot,
        _embarked = opts.embarked or false,
        _garrisoned = opts.garrisoned or false,
        _automated = opts.automated or false,
        _work = opts.work or false,
        _trade = opts.trade or false,
        _fortifyTurns = opts.fortifyTurns or 0,
        _activity = opts.activity or (ActivityTypes and ActivityTypes.ACTIVITY_AWAKE) or 0,
        _buildType = opts.buildType or -1,
    }
    function u:GetOwner()
        return self._owner
    end
    function u:GetTeam()
        return self._team
    end
    function u:IsInvisible(_team, _debug)
        return self._isInvisible
    end
    function u:IsCargo()
        return self._isCargo
    end
    function u:GetDomainType()
        return self._domain
    end
    function u:HasName()
        return self._hasName
    end
    function u:GetNameKey()
        return self._nameKey
    end
    function u:GetNameNoDesc()
        return self._nameNoDesc
    end
    function u:GetDamage()
        return self._damage
    end
    function u:IsCombatUnit()
        return self._isCombatUnit
    end
    function u:GetPlot()
        return self._plot
    end
    function u:GetUnitType()
        return self._unitType
    end
    function u:MaxMoves()
        return self._maxMoves
    end
    function u:MovesLeft()
        return self._movesLeft
    end
    function u:IsHasPromotion(id)
        return self._promotions[id] or false
    end
    function u:IsEmbarked()
        return self._embarked
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
    function u:GetID()
        return opts.id or 1
    end
    function u:GetMissionQueue()
        return opts.missionQueue or {}
    end
    function u:GetX()
        return opts.x or 0
    end
    function u:GetY()
        return opts.y or 0
    end
    -- Ranged attack accessors. Default range matches an early Composite
    -- Bowman (2 hexes); IsRangeAttackIgnoreLOS defaults false (only air
    -- and a few promoted melee-ranged units bypass LoS).
    function u:Range()
        return opts.range or 2
    end
    function u:IsRangeAttackIgnoreLOS()
        return opts.ignoresLoS or false
    end
    -- Cargo capacity. 0 means "not a carrier" (the common case across tests
    -- that don't care about based-aircraft announcements). Tests that
    -- exercise carrier behavior set opts.cargoSpace explicitly.
    function u:CargoSpace()
        return opts.cargoSpace or 0
    end
    function u:GetTransportUnit()
        return opts.transportUnit
    end
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
        _isBarbarian = opts.isBarbarian or opts.barb or false,
        _alive = (opts.alive ~= false),
        _units = opts.units or {},
        _dofWith = opts.dofWith or {},
        _friendsWith = opts.friendsWith or {},
        _alliesWith = opts.alliesWith or {},
    }
    function p:GetCivilizationAdjectiveKey()
        return self._adj
    end
    function p:GetCivilizationShortDescriptionKey()
        return self._shortDesc
    end
    function p:IsMinorCiv()
        return self._isMinor
    end
    function p:GetTeam()
        return self._team
    end
    function p:GetCapitalCity()
        return self._capital
    end
    function p:Cities()
        local list = opts.cities or (self._capital and { self._capital }) or {}
        local i = 0
        return function()
            i = i + 1
            return list[i]
        end
    end
    function p:IsBarbarian()
        return self._isBarbarian
    end
    function p:IsAlive()
        return self._alive
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
            if u.GetID and u:GetID() == id then
                return u
            end
        end
        return nil
    end
    function p:IsDoF(other)
        return self._dofWith[other] or false
    end
    function p:IsFriends(other)
        return self._friendsWith[other] or false
    end
    function p:IsAllies(other)
        return self._alliesWith[other] or false
    end
    return p
end

function T.fakeCity(opts)
    opts = opts or {}
    local c = {
        _name = opts.name or "Rome",
        _owner = opts.owner or 0,
        _id = opts.id or 1,
        _plot = opts.plot,
        _originalOwner = (opts.originalOwner == nil) and (opts.owner or 0) or opts.originalOwner,
        _isOriginalCapital = opts.isOriginalCapital or false,
    }
    function c:GetName()
        return self._name
    end
    function c:GetOwner()
        return self._owner
    end
    function c:GetID()
        return self._id
    end
    function c:Plot()
        return self._plot
    end
    function c:GetOriginalOwner()
        return self._originalOwner
    end
    function c:IsOriginalCapital()
        return self._isOriginalCapital
    end
    return c
end

function T.fakeTeam(opts)
    opts = opts or {}
    local team = {
        _atWar = opts.atWar or {},
        _defensivePact = opts.defensivePact or {},
        _hasMet = opts.hasMet or {},
        _techs = opts.techs or {},
        _openBorders = opts.openBorders or {},
        _canEmbark = opts.canEmbark or false,
    }
    function team:IsAtWar(other)
        return self._atWar[other] or false
    end
    function team:IsDefensivePact(other)
        return self._defensivePact[other] or false
    end
    function team:IsHasMet(other)
        return self._hasMet[other] or false
    end
    function team:IsHasTech(tech)
        return self._techs[tech] or false
    end
    function team:IsAllowsOpenBordersToTeam(other)
        return self._openBorders[other] or false
    end
    function team:CanEmbark()
        return self._canEmbark
    end
    return team
end

-- Install a single fake player whose Cities() yields one city flagged as
-- the active player's original capital. Used by HexGeom.coordinateString
-- callers (the S-key coord readout, the optional cursor / scanner coord
-- segments) which scan every player slot for IsOriginalCapital +
-- GetOriginalOwner matching the active player. opts.slot is the player
-- slot to install under (default 0); opts.originalOwner is the original
-- owner stamped on the city (default opts.slot, so the captured-capital
-- variant explicitly passes a different value). Returns the capital plot
-- so the caller can route Map.GetPlot through it.
function T.installOriginalCapital(capX, capY, opts)
    opts = opts or {}
    local slot = opts.slot or 0
    local originalOwner = opts.originalOwner
    if originalOwner == nil then
        originalOwner = slot
    end
    local capPlot = T.fakePlot({ x = capX, y = capY })
    local capCity = T.fakeCity({
        owner = slot,
        originalOwner = originalOwner,
        isOriginalCapital = true,
        plot = capPlot,
    })
    Players[slot] = T.fakePlayer({
        capital = capCity,
        cities = { capCity },
    })
    return capPlot
end

-- Install a Map that resolves plotIndex 1-based against `plots`. Chebyshev
-- distance for simplicity; GetPlot does a linear (x, y) lookup. Shared by
-- every scanner test suite that exercises plot-backed entries.
function T.installMap(plots)
    Map.GetNumPlots = function()
        return #plots
    end
    Map.GetPlotByIndex = function(i)
        return plots[i + 1]
    end
    Map.PlotDistance = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
    Map.GetPlot = function(x, y)
        for _, p in ipairs(plots) do
            if p:GetX() == x and p:GetY() == y then
                return p
            end
        end
        return nil
    end
end

-- Install the UI / OptionsManager globals that the recommendations
-- pipeline reads. Shared by the scanner backend suite and the cursor
-- plot-section suite. Defaults are "everything off"; tests opt in to
-- the gates they care about by passing canFound / canWork / hideRecs.
function T.installRecGlobals(opts)
    opts = opts or {}
    UI = UI or {}
    UI.CanSelectionListFound = function()
        return opts.canFound == true
    end
    UI.CanSelectionListWork = function()
        return opts.canWork == true
    end
    OptionsManager = OptionsManager or {}
    OptionsManager.IsNoTileRecommendations = function()
        return opts.hideRecs == true
    end
end

-- Install a Players[0] stub with the rec-specific methods (cities,
-- rec lists, CanFound, GetNumResourceAvailable). Returns the stub so
-- tests can monkey-patch further. `cantFoundAt` is a list of {x, y}
-- pairs that should fail CanFound; everywhere else returns true.
function T.installRecPlayer(opts)
    opts = opts or {}
    local p = {
        _numCities = opts.numCities or 0,
        _settlerPlots = opts.settlerPlots or {},
        _workerRecs = opts.workerRecs or {},
        _cantFoundAt = opts.cantFoundAt or {},
        _resources = opts.resources or {},
    }
    function p:GetNumCities()
        return self._numCities
    end
    function p:GetRecommendedFoundCityPlots()
        return self._settlerPlots
    end
    function p:GetRecommendedWorkerPlots()
        return self._workerRecs
    end
    function p:CanFound(x, y)
        for _, v in ipairs(self._cantFoundAt) do
            if v[1] == x and v[2] == y then
                return false
            end
        end
        return true
    end
    function p:GetNumResourceAvailable(resId)
        return self._resources[resId] or 0
    end
    Players[0] = p
    return p
end

-- Build a ScanEntry with test-friendly defaults. `opts.backend` overrides
-- the placeholder `{ name = "test" }` for suites that exercise Nav's
-- backend-dispatch paths (ValidateEntry / FormatName). `opts.key`
-- overrides the default "test:<plotIndex>:<name>" synthetic key when a
-- test needs a specific identity (e.g. two entries with the same plot /
-- name but distinct identities).
function T.mkEntry(cat, sub, name, plotIndex, opts)
    opts = opts or {}
    return {
        plotIndex = plotIndex,
        backend = opts.backend or { name = "test" },
        data = {},
        category = cat,
        subcategory = sub,
        itemName = name,
        key = opts.key or ("test:" .. tostring(plotIndex) .. ":" .. tostring(name)),
        sortKey = opts.sortKey or 0,
    }
end

-- Install a Locale.ConvertTextKey stub backed by the supplied { key = format }
-- map. The format string supports the engine's positional `{N_Tag}`
-- substitution; unmapped keys come back as themselves so missing-key
-- assertions still see the raw key.
function T.installLocaleStrings(map)
    Locale.ConvertTextKey = function(key, ...)
        local fmt = map[key] or key
        local args = { ... }
        if #args == 0 then
            return fmt
        end
        return (fmt:gsub("{(%d+)_[^}]*}", function(n)
            local v = args[tonumber(n)]
            if v == nil then
                return ""
            end
            return tostring(v)
        end))
    end
end

-- Replace SpeechPipeline._speakAction with a capturing stub that records
-- every speech call as { text, interrupt }. Returns the capture table so
-- the suite can assert against it; subsequent setup() calls re-issue this
-- helper to reset the table.
function T.captureSpeech()
    local spoken = {}
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, interrupt = interrupt }
    end
    return spoken
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
    print(string.format("%d passed, %d failed (of %d)", passed, #failed, #T.cases))
    for _, f in ipairs(failed) do
        print("  FAIL " .. f.name)
        print("       " .. tostring(f.err))
    end
    return #failed == 0
end

return T

-- Aircraft count tokens for carriers (X/Y always when capacity > 0)
-- and city plots (X/Y only when at least one aircraft is stationed).
-- Mirrors the iteration UnitFlagManager's UpdateCargo / UpdateCityCargo
-- do, so tests fail if our enumeration filter or threshold drifts from
-- the base game's behavior.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    civvaccess_shared = civvaccess_shared or {}
    dofile("src/dlc/UI/InGame/CivVAccess_WaypointsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitSpeech.lua")

    GameInfo = GameInfo or {}
    GameInfo.Buildings = function()
        return function()
            return nil
        end
    end
    GameDefines = GameDefines or {}
    GameDefines.BASE_CITY_AIR_STACKING = 6
end

-- Build a plot with a fixed unit list. Carrier path needs GetUnit(i) and
-- GetNumUnits; city path additionally needs IsCity / GetPlotCity. Kept
-- minimal to avoid coupling to support.lua's broader fakePlot stub.
local function mkPlot(units, opts)
    opts = opts or {}
    return {
        _units = units,
        _isCity = opts.isCity or false,
        _city = opts.city,
        IsCity = function(self)
            return self._isCity
        end,
        GetPlotCity = function(self)
            return self._city
        end,
        GetNumUnits = function(self)
            return #self._units
        end,
        GetUnit = function(self, i)
            return self._units[i + 1]
        end,
    }
end

local function mkCarrier(opts)
    opts = opts or {}
    local plot = opts.plot
    return {
        GetID = function()
            return opts.id or 1
        end,
        CargoSpace = function()
            return opts.capacity or 3
        end,
        GetPlot = function()
            return plot
        end,
    }
end

local function mkCargo(transportId)
    return {
        IsCargo = function()
            return true
        end,
        GetTransportUnit = function()
            return {
                GetID = function()
                    return transportId
                end,
            }
        end,
        GetDomainType = function()
            return DomainTypes.DOMAIN_AIR
        end,
    }
end

local function mkAirInCity()
    return {
        IsCargo = function()
            return false
        end,
        GetTransportUnit = function()
            return nil
        end,
        GetDomainType = function()
            return DomainTypes.DOMAIN_AIR
        end,
    }
end

local function mkLandUnit()
    return {
        IsCargo = function()
            return false
        end,
        GetTransportUnit = function()
            return nil
        end,
        GetDomainType = function()
            return DomainTypes.DOMAIN_LAND
        end,
    }
end

-- ===== cargoAircraftToken =====

function M.test_cargo_token_empty_when_no_capacity()
    setup()
    local plot = mkPlot({})
    local unit = {
        GetID = function()
            return 1
        end,
        CargoSpace = function()
            return 0
        end,
        GetPlot = function()
            return plot
        end,
    }
    T.eq(UnitSpeech.cargoAircraftToken(unit), "")
end

function M.test_cargo_token_zero_count_still_speaks()
    setup()
    local plot = mkPlot({})
    local carrier = mkCarrier({ id = 7, capacity = 3, plot = plot })
    local out = UnitSpeech.cargoAircraftToken(carrier)
    -- Empty carrier still announces capacity so the user knows this unit
    -- carries aircraft. Format is "{cur}/{max} aircraft".
    T.eq(out, "0/3 aircraft")
end

function M.test_cargo_token_counts_only_this_carriers_cargo()
    setup()
    local plot
    local cargo1 = mkCargo(7)
    local cargo2 = mkCargo(7)
    local otherCargo = mkCargo(99)
    plot = mkPlot({ cargo1, cargo2, otherCargo })
    local carrier = mkCarrier({ id = 7, capacity = 3, plot = plot })
    T.eq(UnitSpeech.cargoAircraftToken(carrier), "2/3 aircraft")
end

function M.test_cargo_token_skips_non_cargo_units()
    setup()
    local plot
    local cargo = mkCargo(7)
    local landUnit = mkLandUnit()
    plot = mkPlot({ cargo, landUnit })
    local carrier = mkCarrier({ id = 7, capacity = 3, plot = plot })
    T.eq(UnitSpeech.cargoAircraftToken(carrier), "1/3 aircraft")
end

-- ===== cityAircraftToken =====

function M.test_city_token_empty_when_not_a_city()
    setup()
    local plot = mkPlot({ mkAirInCity() }, { isCity = false })
    T.eq(UnitSpeech.cityAircraftToken(plot), "")
end

function M.test_city_token_empty_when_zero_aircraft()
    setup()
    local city = {
        IsHasBuilding = function()
            return false
        end,
    }
    local plot = mkPlot({ mkLandUnit() }, { isCity = true, city = city })
    -- Zero aircraft suppresses entirely so every city tile doesn't
    -- announce "0/6 aircraft".
    T.eq(UnitSpeech.cityAircraftToken(plot), "")
end

function M.test_city_token_speaks_count_with_base_capacity()
    setup()
    local city = {
        IsHasBuilding = function()
            return false
        end,
    }
    local plot = mkPlot({ mkAirInCity(), mkAirInCity() }, { isCity = true, city = city })
    T.eq(UnitSpeech.cityAircraftToken(plot), "2/6 aircraft")
end

function M.test_city_token_skips_non_air_units_in_count()
    setup()
    -- Mixed plot: a garrisoned land defender plus two stationed aircraft.
    -- Only the air units count toward the city's air total -- mirrors
    -- UpdateCityCargo's flat DOMAIN_AIR filter without a units-on-tile leak.
    local city = {
        IsHasBuilding = function()
            return false
        end,
    }
    local plot = mkPlot({ mkLandUnit(), mkAirInCity(), mkAirInCity() }, { isCity = true, city = city })
    T.eq(UnitSpeech.cityAircraftToken(plot), "2/6 aircraft")
end

function M.test_city_token_includes_building_modifiers_in_max()
    setup()
    -- Two buildings: an Airport-equivalent (+2 air) the city has, and an
    -- unrelated +0 entry that should not affect totals. The city owns
    -- only the +2 building.
    GameInfo.Buildings = function()
        local rows = {
            { ID = 10, AirModifier = 2 },
            { ID = 20, AirModifier = 0 },
        }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    local city = {
        IsHasBuilding = function(self, id)
            return id == 10
        end,
    }
    local plot = mkPlot({ mkAirInCity() }, { isCity = true, city = city })
    T.eq(UnitSpeech.cityAircraftToken(plot), "1/8 aircraft")
end

function M.test_city_token_ignores_unowned_building_modifiers()
    setup()
    GameInfo.Buildings = function()
        local rows = { { ID = 10, AirModifier = 2 } }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    local city = {
        IsHasBuilding = function()
            return false
        end,
    }
    local plot = mkPlot({ mkAirInCity() }, { isCity = true, city = city })
    -- Building exists in the catalog but the city doesn't own it; the
    -- modifier must not be applied. Mirrors CvCity::ChangeMaxAirUnits
    -- only firing on building gain.
    T.eq(UnitSpeech.cityAircraftToken(plot), "1/6 aircraft")
end

return M

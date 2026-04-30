-- Units section. Walks plot:GetLayerUnit(-1) so the iteration covers
-- every plot layer, not just base. Trade units (caravans, cargo ships
-- on a route) live on TRADE_UNIT_MAP_LAYER (CvTradeClasses.h) and are
-- absent from plot:GetNumUnits(); base game's GetUnitsString skips them
-- because the trade overview surfaces them separately, but the cursor's
-- job is to announce everything visibly on the tile, so we include them.
-- Each survivor is gated by IsInvisible(activeTeam, isDebug); cargo
-- (inside a transport) and air (parked in a city / on a carrier) are
-- skipped -- they're not "on the tile" in the spatial sense the cursor
-- cares about.

-- UnitSpeech.unitName produces the personal-name-aware "George (Roman
-- Warrior)" / "Tomyris (Persian Great General)" form for named units
-- and the bare civ-adjective form otherwise. The embarked prefix
-- ("embarked George (Roman Warrior)") is added on top here.
local function unitDescription(unit)
    local body = UnitSpeech.unitName(unit)
    if unit:IsEmbarked() then
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED", body)
    end
    return body
end

local function describeUnit(unit, activeTeam, isDebug)
    if unit:IsInvisible(activeTeam, isDebug) then
        return nil
    end
    if unit:IsCargo() then
        return nil
    end
    if unit:GetDomainType() == DomainTypes.DOMAIN_AIR then
        return nil
    end
    local s = unitDescription(unit)
    local damage = unit:GetDamage()
    if damage > 0 then
        s = s .. ", " .. Text.format("TXT_KEY_CIVVACCESS_HP_FORMAT", GameDefines.MAX_HIT_POINTS - damage)
    end
    -- Mirror the unit flag's status channel: fortified lights up the
    -- shield flag for any visible unit; the deeper rungs (sleep, alert,
    -- heal, automate, build) only show in the owning player's UnitList
    -- panel. UnitSpeech.statusToken gates by ownership, so enemies
    -- here only surface the fortified shield.
    local status = UnitSpeech.statusToken(unit)
    if status ~= "" then
        s = s .. ", " .. status
    end
    local cargo = UnitSpeech.cargoAircraftToken(unit)
    if cargo ~= "" then
        s = s .. ", " .. cargo
    end
    return s
end

PlotSectionUnits = {
    Read = function(plot)
        local team = Game.GetActiveTeam()
        local isDebug = Game.IsDebugMode()
        local out = {}

        local n = plot:GetNumLayerUnits(-1)
        for i = 0, n - 1 do
            local u = plot:GetLayerUnit(i, -1)
            if u ~= nil then
                local desc = describeUnit(u, team, isDebug)
                if desc ~= nil then
                    out[#out + 1] = desc
                end
            end
        end

        return out
    end,
}

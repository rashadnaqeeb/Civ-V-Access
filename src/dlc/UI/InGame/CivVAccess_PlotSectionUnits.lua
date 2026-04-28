-- Units section. Walks plot:GetNumUnits(), gating each survivor with
-- IsInvisible(activeTeam, isDebug) and skipping cargo (inside a transport)
-- and air (parked in a city / on a carrier) -- they're not "on the tile"
-- in the spatial sense the cursor cares about. Base game's GetUnitsString
-- iterates only GetNumUnits; GetNumLayerUnits returns the same list plus
-- trade units, so iterating both double-counts regular units.

-- The civ-adjective form lives in UnitSpeech.unitName via the shared
-- TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV format. Named units (great
-- generals, named admirals) wrap that form in parens after the personal
-- name -- "Tomyris (Persian Great General)" -- which selection / info
-- speech don't surface so the wrapper stays here.
local function unitDescription(unit)
    local typeName = UnitSpeech.unitName(unit)
    local body
    if unit:HasName() then
        local personalName = Text.key(unit:GetNameNoDesc())
        if typeName ~= "" then
            body = personalName .. " (" .. typeName .. ")"
        else
            body = personalName
        end
    else
        body = typeName
    end
    if unit:IsEmbarked() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_EMBARKED_PREFIX") .. " " .. body
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

        local n = plot:GetNumUnits()
        for i = 0, n - 1 do
            local u = plot:GetUnit(i)
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

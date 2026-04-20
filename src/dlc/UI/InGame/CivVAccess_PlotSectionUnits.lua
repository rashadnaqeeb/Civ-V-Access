-- Units section. Walks plot:GetNumUnits(), gating each survivor with
-- IsInvisible(activeTeam, isDebug) and skipping cargo (inside a transport)
-- and air (parked in a city / on a carrier) -- they're not "on the tile"
-- in the spatial sense the cursor cares about. Base game's GetUnitsString
-- iterates only GetNumUnits; GetNumLayerUnits returns the same list plus
-- trade units, so iterating both double-counts regular units.

local function unitDescription(unit)
    local owner = Players[unit:GetOwner()]
    -- Multiplayer nickname path mirrors PlotMouseoverInclude.GetUnitsString.
    -- Test the return value, not the method's existence: the method exists
    -- on every Player object, returning nil/"" in singleplayer.
    local nick = owner:GetNickName()
    if nick ~= nil and nick ~= "" then
        return Text.format("TXT_KEY_MULTIPLAYER_UNIT_TT",
            nick, owner:GetCivilizationAdjectiveKey(), unit:GetNameKey())
    end
    if unit:HasName() then
        local desc = Text.format("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV",
            owner:GetCivilizationAdjectiveKey(), unit:GetNameKey())
        return Text.key(unit:GetNameNoDesc()) .. " (" .. desc .. ")"
    end
    return Text.format("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV",
        owner:GetCivilizationAdjectiveKey(), unit:GetNameKey())
end

local function describeUnit(unit, activeTeam, isDebug)
    if unit:IsInvisible(activeTeam, isDebug) then return nil end
    if unit:IsCargo() then return nil end
    if unit:GetDomainType() == DomainTypes.DOMAIN_AIR then return nil end
    local s = unitDescription(unit)
    local damage = unit:GetDamage()
    if damage > 0 then
        s = s .. ", " .. Text.format("TXT_KEY_CIVVACCESS_HP_FORMAT",
            GameDefines.MAX_HIT_POINTS - damage)
    end
    return s
end

PlotSectionUnits = {
    Read = function(plot)
        local team    = Game.GetActiveTeam()
        local isDebug = Game.IsDebugMode()
        local out = {}

        local n = plot:GetNumUnits()
        for i = 0, n - 1 do
            local u = plot:GetUnit(i)
            if u ~= nil then
                local desc = describeUnit(u, team, isDebug)
                if desc ~= nil then out[#out + 1] = desc end
            end
        end

        return out
    end,
}

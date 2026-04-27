-- Units section. Walks plot:GetNumUnits(), gating each survivor with
-- IsInvisible(activeTeam, isDebug) and skipping cargo (inside a transport)
-- and air (parked in a city / on a carrier) -- they're not "on the tile"
-- in the spatial sense the cursor cares about. Base game's GetUnitsString
-- iterates only GetNumUnits; GetNumLayerUnits returns the same list plus
-- trade units, so iterating both double-counts regular units.

local function unitDescription(unit)
    local owner = Players[unit:GetOwner()]
    -- Always the civ-adjective form. Base game's GetUnitsString branches
    -- on GetNickName for the MULTIPLAYER_UNIT_TT template, but in both
    -- single- and multi-player the engine returns a non-empty placeholder
    -- (profile name / "Player N"), leaving the player's own name
    -- announced in front of their own unit every time. The civ adjective
    -- ("Arabian Warrior") already disambiguates owner.
    local body
    if unit:HasName() then
        local desc =
            Text.format("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", owner:GetCivilizationAdjectiveKey(), unit:GetNameKey())
        body = Text.key(unit:GetNameNoDesc()) .. " (" .. desc .. ")"
    else
        body =
            Text.format("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", owner:GetCivilizationAdjectiveKey(), unit:GetNameKey())
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

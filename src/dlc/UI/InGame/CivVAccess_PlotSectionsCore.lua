-- Plot description sections. Each section is { Read = function(plot, ctx) }
-- returning a list of zero or more localized tokens; composers join the
-- non-empty ones with ", ". Sections are stateless across calls; the ctx
-- table is a per-Compose scratch space so an earlier section can flag a
-- decision that affects a later section (currently: feature.NaturalWonder
-- suppresses terrain).
--
-- The Owner section here is NOT in the per-move composer -- the cursor's
-- owner-prefix diff already speaks owner identity, and on a city tile
-- TXT_KEY_CITY_OF / TXT_KEY_CITY_STATE_OF carries the full banner. Owner
-- lives in the registry so callers (Cursor) can borrow the same identity
-- builder without reimplementing the city / civ / unclaimed branching.
--
-- Per-section visibility rules: revealed-but-fogged plots get terrain /
-- plotType / feature / improvement / route / owner via the GetRevealed*
-- family; live-only data (yields, units, build progress) is gated by the
-- composer at compose time, not in the section itself. PlotMouseoverInclude
-- (Expansion2) is the canonical reference for which fields stale safely.

PlotSections = {}

local function lookupName(table, id)
    local row = GameInfo[table][id]
    if row == nil then return nil end
    return Text.key(row.Description)
end

-- Owner identity used by the cursor's prefix diff and (offline) by tests.
-- Returns two values: the spoken string ("Arabia", "Rome, Arabian",
-- "unclaimed") and an opaque identity token used only for diffing across
-- moves. Two plots with the same identity token never re-trigger the prefix.
-- Caller must guarantee the plot is revealed; unexplored is a visibility
-- state, not an ownership state, and lives in the Cursor's gate.
function PlotSections.ownerIdentity(plot)
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    if plot:IsCity() then
        local city = plot:GetPlotCity()
        local owner = Players[city:GetOwner()]
        if owner:IsMinorCiv() then
            local civKey = owner:GetCivilizationShortDescriptionKey()
            local spoken = Text.format("TXT_KEY_CITY_STATE_OF", civKey)
            return spoken, "city:" .. tostring(city:GetID())
        end
        local adj  = owner:GetCivilizationAdjectiveKey()
        local name = city:GetName()
        local spoken = Text.format("TXT_KEY_CITY_OF", adj, name)
        return spoken, "city:" .. tostring(city:GetID())
    end
    local ownerId = plot:GetRevealedOwner(team, debug)
    if ownerId < 0 then
        return Text.key("TXT_KEY_CIVVACCESS_UNCLAIMED"), "unclaimed"
    end
    local owner = Players[ownerId]
    -- Prefer the bare civ description over the OWNED_CIV templated form so
    -- the prefix stays a single noun ("Arabia.") rather than the templated
    -- "Arabian territory" string the engine tooltip uses. Tooltip context
    -- is screen real estate; ours is speech, where the bare name is faster.
    local spoken = Text.key(owner:GetCivilizationShortDescriptionKey())
    return spoken, "civ:" .. tostring(ownerId)
end

-- The City section speaks the city banner unconditionally on a city tile.
-- This duplicates the cursor's owner-prefix on first entry (both will say
-- "Rome, Arabian"), which is the design's accepted cost: it ensures the
-- city is announced even on entry paths that don't trigger the prefix
-- diff (Recenter onto a tile whose identity already matched). The diff
-- saves the user from hearing "Arabia" every step within Arabia; the City
-- section makes sure they always hear "Rome" when they land on Rome.
PlotSections.city = {
    Read = function(plot)
        if not plot:IsCity() then return {} end
        local city = plot:GetPlotCity()
        local owner = Players[city:GetOwner()]
        if owner:IsMinorCiv() then
            return { Text.format("TXT_KEY_CITY_STATE_OF",
                owner:GetCivilizationShortDescriptionKey()) }
        end
        return { Text.format("TXT_KEY_CITY_OF",
            owner:GetCivilizationAdjectiveKey(), city:GetName()) }
    end,
}

PlotSections.terrain = {
    Read = function(plot, ctx)
        if ctx.suppressTerrain then return {} end
        if plot:IsLake() then
            return { Text.key("TXT_KEY_CIVVACCESS_LAKE") }
        end
        local id = plot:GetTerrainType()
        if id < 0 then return {} end
        local name = lookupName("Terrains", id)
        if name == nil then return {} end
        return { name }
    end,
}

PlotSections.plotType = {
    Read = function(plot, ctx)
        -- Plot type is suppressed for ocean (terrain already covers it) and
        -- for flat (the default carries no information). Hills and mountain
        -- are the only spoken cases.
        if plot:IsMountain() then
            -- Mountain suppresses terrain too: the underlying engine often
            -- assigns mountain over snow/tundra, but "mountain" is the
            -- distinguishing fact. Mirror PlotMouseoverInclude's bMountain
            -- guard.
            ctx.suppressTerrain = true
            return { Text.key("TXT_KEY_CIVVACCESS_MOUNTAIN") }
        end
        if plot:IsHills() then
            return { Text.key("TXT_KEY_CIVVACCESS_HILLS") }
        end
        return {}
    end,
}

-- "Special" features describe the tile fully on their own (jungle on plains
-- is just "jungle"). Mirrors IsFeatureSpecial in PlotMouseoverInclude. The
-- engine's check uses GameInfoTypes lookups; we use type strings against
-- GameInfo.Features rows, which works the same way without needing the
-- GameInfoTypes global polyfilled.
local SPECIAL_FEATURE_TYPES = {
    FEATURE_JUNGLE = true,
    FEATURE_MARSH  = true,
    FEATURE_OASIS  = true,
    FEATURE_ICE    = true,
}

PlotSections.feature = {
    Read = function(plot, ctx)
        local id = plot:GetFeatureType()
        if id == nil or id < 0 then return {} end
        local row = GameInfo.Features[id]
        if row == nil then return {} end
        if row.NaturalWonder or SPECIAL_FEATURE_TYPES[row.Type] then
            ctx.suppressTerrain = true
        end
        return { Text.key(row.Description) }
    end,
}

PlotSections.resource = {
    Read = function(plot)
        local team = Game.GetActiveTeam()
        local id = plot:GetResourceType(team)
        if id == nil or id < 0 then return {} end
        local row = GameInfo.Resources[id]
        if row == nil then return {} end
        local name = Text.key(row.Description)
        local qty  = plot:GetNumResource()
        local out  = {}
        if qty > 1 then
            out[#out + 1] = tostring(qty) .. " " .. name
        else
            out[#out + 1] = name
        end
        -- Tech-required-to-use note. Game key takes the tech's Description
        -- text-key (not the resolved name) because the engine's format string
        -- uses the {@N_Tag} form that resolves the arg as another text key.
        -- The BNW tooltip (PlotMouseoverInclude.lua:233) does the same.
        local techType = row.TechCityTrade
        if techType ~= nil and GameInfoTypes ~= nil then
            local techId = GameInfoTypes[techType]
            if techId ~= nil and techId >= 0 then
                local pTeam = Teams[team]
                if pTeam ~= nil and not pTeam:GetTeamTechs():HasTech(techId) then
                    local techRow = GameInfo.Technologies[techId]
                    if techRow ~= nil then
                        out[#out + 1] = Text.format(
                            "TXT_KEY_PLOTROLL_REQUIRES_TECH_TO_USE",
                            techRow.Description)
                    end
                end
            end
        end
        return out
    end,
}

PlotSections.improvement = {
    Read = function(plot)
        local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
        local id = plot:GetRevealedImprovementType(team, debug)
        if id == nil or id < 0 then return {} end
        local name = lookupName("Improvements", id)
        if name == nil then return {} end
        if plot:IsImprovementPillaged() then
            return { name .. " " .. Text.key("TXT_KEY_CIVVACCESS_PILLAGED_SUFFIX") }
        end
        return { name }
    end,
}

PlotSections.route = {
    Read = function(plot)
        local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
        local id = plot:GetRevealedRouteType(team, debug)
        if id == nil or id < 0 then return {} end
        local name = lookupName("Routes", id)
        if name == nil then return {} end
        if plot:IsRoutePillaged() then
            return { name .. " " .. Text.key("TXT_KEY_CIVVACCESS_PILLAGED_SUFFIX") }
        end
        return { name }
    end,
}

-- Plot description sections. Each section is { Read = function(plot, ctx) }
-- returning a list of zero or more localized tokens; composers join the
-- non-empty ones with ", ". Sections are stateless across calls. The ctx
-- table is a per-Compose scratch space reserved for future cross-section
-- coordination; no current section reads or writes it.
--
-- The Owner section here is NOT in the per-move composer -- the cursor's
-- owner-prefix diff already speaks owner identity. Owner lives in the
-- registry so the Cursor can borrow the same builder without
-- reimplementing the civ / unclaimed branching. The City section below
-- handles the city banner (TXT_KEY_CITY_OF / TXT_KEY_CITY_STATE_OF) on
-- city tiles independently of owner identity.
--
-- Per-section visibility rules: revealed-but-fogged plots get terrain /
-- plot-shape / feature / improvement / route / owner via the GetRevealed*
-- family; live-only data (yields, units, build progress) is gated by the
-- composer at compose time, not in the section itself. PlotMouseoverInclude
-- (Expansion2) is the canonical reference for which fields stale safely.

PlotSections = {}

local function lookupName(table, id)
    local row = GameInfo[table][id]
    if row == nil then
        return nil
    end
    return Text.key(row.Description)
end

-- Owner identity used by the cursor's prefix diff and (offline) by tests.
-- Returns two values: the spoken string ("Arabia", "unclaimed") and an
-- opaque identity token used only for diffing across moves. Two plots
-- with the same identity token never re-trigger the prefix. City tiles
-- intentionally share the civ-owner identity of the surrounding territory
-- so stepping civ-tile -> city-tile-of-same-civ doesn't fire a redundant
-- prefix; the City section in the glance announces the city banner on
-- its own. Caller must guarantee the plot is revealed; unexplored is a
-- visibility state, not an ownership state, and lives in the Cursor's gate.
function PlotSections.ownerIdentity(plot)
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
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
-- It is the sole source of "Rome, Arabian" -- the cursor's owner-prefix
-- treats a city tile as part of its civ's territory, so stepping into a
-- city of the civ you're already in speaks only the banner here, not the
-- prefix and the banner. Entries from a different civ or unclaimed get
-- the civ-name prefix, then this section names the city.
PlotSections.city = {
    Read = function(plot)
        if not plot:IsCity() then
            return {}
        end
        local city = plot:GetPlotCity()
        local owner = Players[city:GetOwner()]
        local banner
        if owner:IsMinorCiv() then
            banner = Text.format("TXT_KEY_CITY_STATE_OF", owner:GetCivilizationShortDescriptionKey())
        else
            banner = Text.format("TXT_KEY_CITY_OF", owner:GetCivilizationAdjectiveKey(), city:GetName())
        end
        local tokens = { banner }
        local aircraft = UnitSpeech.cityAircraftToken(plot)
        if aircraft ~= "" then
            tokens[#tokens + 1] = aircraft
        end
        return tokens
    end,
}

-- Features that describe the tile fully on their own, so the underlying
-- terrain name is redundant in speech. The single-terrain set comes from
-- CIV5Features.xml Feature_TerrainBooleans: jungle / marsh / oasis / flood
-- plains each appear on exactly one terrain (grass / grass / desert /
-- desert in G&K and BNW; jungle shifts to plains in base). ICE is
-- multi-terrain (coast + ocean) but is suppressed by policy: both read as
-- impassable and the distinction isn't actionable at speech speed.
--
-- Natural wonders (NaturalWonder flag) are handled separately and suppress
-- everything including hills / mountain -- Natural_Wonder_Placement
-- rewrites the core tile (most to mountain via ChangeCoreTileToMountain),
-- so the wonder name stands alone.
local FEATURE_SUPPRESSES_TERRAIN = {
    FEATURE_JUNGLE = true,
    FEATURE_MARSH = true,
    FEATURE_OASIS = true,
    FEATURE_FLOOD_PLAINS = true,
    FEATURE_ICE = true,
}

-- Combined terrain-shape section: feature + hills + terrain with the
-- right suppression rules in one place. Output order is feature, hills,
-- terrain; the feature leads because it's the distinguishing-fact-first
-- choice ("jungle, hills" reads faster than "hills, jungle").
-- ctx.cueOnly suppresses tokens the audio cue layer already carries:
-- base terrain, mountain, lake, and non-wonder feature names. Hills and
-- natural-wonder names always speak (no audio representation in the v1
-- palette). See AudioCueMode / PlotAudio and the audio-cues plan.
PlotSections.terrainShape = {
    Read = function(plot, ctx)
        ctx = ctx or {}
        if plot:IsLake() then
            if ctx.cueOnly then
                return {}
            end
            return { Text.key("TXT_KEY_CIVVACCESS_LAKE") }
        end
        local fid = plot:GetFeatureType()
        local fRow = fid ~= nil and fid >= 0 and GameInfo.Features[fid] or nil
        if fRow and fRow.NaturalWonder then
            return { Text.key(fRow.Description) }
        end
        if plot:IsMountain() then
            if ctx.cueOnly then
                return {}
            end
            return { Text.key("TXT_KEY_CIVVACCESS_MOUNTAIN") }
        end
        local tokens = {}
        if fRow and not ctx.cueOnly then
            tokens[#tokens + 1] = Text.key(fRow.Description)
        end
        if plot:IsHills() then
            tokens[#tokens + 1] = Text.key("TXT_KEY_CIVVACCESS_HILLS")
        end
        if not ctx.cueOnly then
            if not (fRow and FEATURE_SUPPRESSES_TERRAIN[fRow.Type]) then
                local tName = lookupName("Terrains", plot:GetTerrainType())
                if tName ~= nil then
                    tokens[#tokens + 1] = tName
                end
            end
        end
        return tokens
    end,
}

PlotSections.resource = {
    Read = function(plot)
        local team = Game.GetActiveTeam()
        local id = plot:GetResourceType(team)
        if id == nil or id < 0 then
            return {}
        end
        local row = GameInfo.Resources[id]
        if row == nil then
            return {}
        end
        local name = Text.key(row.Description)
        local qty = plot:GetNumResource()
        local out = {}
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
                        out[#out + 1] = Text.format("TXT_KEY_PLOTROLL_REQUIRES_TECH_TO_USE", techRow.Description)
                    end
                end
            end
        end
        return out
    end,
}

-- Improvement and route share the same shape: revealed-ID lookup against a
-- GameInfo table, negative-id bail, optional pillaged-suffix decoration.
local function pillagedSection(getRevealedId, infoTable, isPillaged)
    return {
        Read = function(plot)
            local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
            local id = getRevealedId(plot, team, debug)
            if id == nil or id < 0 then
                return {}
            end
            local name = lookupName(infoTable, id)
            if name == nil then
                return {}
            end
            if isPillaged(plot) then
                return { Text.format("TXT_KEY_CIVVACCESS_PILLAGED_NAMED", name) }
            end
            return { name }
        end,
    }
end

PlotSections.improvement = pillagedSection(
    function(p, t, d)
        return p:GetRevealedImprovementType(t, d)
    end,
    "Improvements",
    function(p)
        return p:IsImprovementPillaged()
    end
)

PlotSections.route = pillagedSection(
    function(p, t, d)
        return p:GetRevealedRouteType(t, d)
    end,
    "Routes",
    function(p)
        return p:IsRoutePillaged()
    end
)

-- AI tile-recommendation marker. Speaks when the cursor lands on a
-- plot the engine currently flags with a settler / worker anchor.
-- Two tokens: the prefix-formatted name and the reason tooltip (the
-- composer joins them with ", ", producing "recommendation: X, Y").
-- Settler priority over worker when both match; if the settler path
-- is gated out (CanFound now false, for instance) the worker path
-- still gets a chance, so a plot that both a Settler-in-stack and a
-- Worker-in-stack consider recommended still announces the worker's
-- build when settling is blocked. Non-recommended plots return {}.

local function settlerRecTokens(player, plot, x, y)
    if not Recommendations.settlerActive(player) then
        return nil
    end
    if not Recommendations.settlerContains(player, x, y) then
        return nil
    end
    if not player:CanFound(x, y) then
        return nil
    end
    local name = Text.key("TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE")
    local tokens = { Text.format("TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX", name) }
    local reason = Recommendations.settlerReason(plot, player)
    if reason ~= nil and reason ~= "" then
        tokens[#tokens + 1] = reason
    end
    return tokens
end

local function workerRecTokens(player, plot, x, y)
    if not Recommendations.workerActive() then
        return nil
    end
    local rec = Recommendations.workerRecAt(player, x, y)
    if rec == nil then
        return nil
    end
    local row = GameInfo.Builds and GameInfo.Builds[rec.buildType]
    if row == nil or row.Description == nil then
        return nil
    end
    local name = Text.key(row.Description)
    local tokens = { Text.format("TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX", name) }
    local reason = Recommendations.workerReason(plot, rec.buildType)
    if reason ~= nil and reason ~= "" then
        tokens[#tokens + 1] = reason
    end
    return tokens
end

PlotSections.recommendation = {
    Read = function(plot)
        if not Recommendations.allowed() then
            return {}
        end
        local player = Players[Game.GetActivePlayer()]
        if player == nil then
            return {}
        end
        local x, y = plot:GetX(), plot:GetY()
        return settlerRecTokens(player, plot, x, y) or workerRecTokens(player, plot, x, y) or {}
    end,
}

-- Tail-fact "btw, this hex is on the selected unit's queued path." Reads
-- the same WaypointsCore cache the scanner uses, so the K of N numbers
-- agree across the cursor glance and the scanner readout for one
-- selection frame.
PlotSections.waypoint = {
    Read = function(plot)
        local hit = Waypoints.atXY(plot:GetX(), plot:GetY())
        if hit == nil then
            return {}
        end
        return { Text.format("TXT_KEY_CIVVACCESS_PLOT_WAYPOINT", hit.index, hit.total) }
    end,
}

-- MCP bridge endpoint. The proxy injects an `rpc` table (poll / respond)
-- hardwired to a mailbox directory under Documents\My Games; the external
-- MCP server (tools/mcp/) drops one request at a time into it. The proxy
-- watches that directory on its own thread and hands the request over in
-- memory, so rpc.poll() is a lock-and-pop with no file access -- see the
-- mailbox block in src/proxy/proxy.c for why the game thread must never
-- wait on that directory. A TickPump subscriber consumes at most one
-- request per tick, executes the named query against live game state on
-- the game thread, and hands back a JSON reply through rpc.respond (which
-- does write inline, but only ever after a request actually arrived).
-- Queries are whitelisted and read-only -- except point_cursor,
-- which moves the mod's own map cursor (mod-side state, never game state)
-- so the assistant can physically point at a tile. Every value is read
-- fresh at execution time (no caching), and map reads are filtered through
-- IsRevealed for the active team so a reply never contains anything the
-- player couldn't know from the game itself.
--
-- Request: one line of tab-separated fields: <id> <query> [<arg> ...].
-- Response: a JSON envelope {id, turn, activePlayer, ok, data | error}.
-- The id is caller-chosen and echoed verbatim so the server can discard
-- a stale response left over from an earlier, abandoned request.
--
-- The TickPump subscription is re-established on every onInGameBoot; see
-- CivVAccess_Boot.lua for why install-once guards are wrong across
-- load-from-game. TickPump may run a subscriber more than once per frame;
-- poll() empties the handoff slot, so the extra call reads nothing.

Rpc = {}

local SUBSCRIBER_NAME = "Rpc"
-- find_resource caps its plot list; totals are always reported in full.
local MAX_RESULT_PLOTS = 25

-- === JSON encoder ===
-- Encode-only; requests arrive in the flat tab-separated form above, so
-- nothing on this side ever parses JSON. Tables with a [1] element encode
-- as arrays, other non-empty tables as objects, empty tables as [] (every
-- empty table we emit is a result list).

local ESCAPES = {
    ['"'] = '\\"',
    ["\\"] = "\\\\",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
}

local function escapeChar(c)
    return ESCAPES[c] or string.format("\\u%04x", string.byte(c))
end

local function encode(v)
    local t = type(v)
    if v == nil then
        return "null"
    elseif t == "boolean" then
        return tostring(v)
    elseif t == "number" then
        -- JSON has no NaN / infinity; null is the least-wrong encoding and
        -- the server side treats it as "value unavailable".
        if v ~= v or v == math.huge or v == -math.huge then
            return "null"
        end
        if v == math.floor(v) and math.abs(v) < 2 ^ 31 then
            return string.format("%d", v)
        end
        return string.format("%.14g", v)
    elseif t == "string" then
        return '"' .. v:gsub('[%z\1-\31"\\]', escapeChar) .. '"'
    elseif t == "table" then
        local parts = {}
        if v[1] ~= nil then
            for i = 1, #v do
                parts[#parts + 1] = encode(v[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        end
        for k, val in pairs(v) do
            parts[#parts + 1] = encode(tostring(k)) .. ":" .. encode(val)
        end
        if #parts == 0 then
            return "[]"
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return encode(tostring(v))
end

Rpc._encode = encode

-- === Query helpers ===

-- Resolve a GameInfo row from what the MCP server sends: an exact Type
-- ("RESOURCE_IRON"), a bare name to prefix-and-upcase ("iron"), or a
-- localized display name compared case-insensitively ("Iron", "Eisen").
local function resolveRow(tableName, prefix, arg)
    if arg == nil or arg == "" then
        return nil
    end
    local rows = GameInfo[tableName]
    local row = rows[arg]
    if row ~= nil then
        return row
    end
    row = rows[prefix .. arg:upper():gsub(" ", "_")]
    if row ~= nil then
        return row
    end
    local wanted = Locale.ToLower(arg)
    for candidate in rows() do
        if Locale.ToLower(Text.key(candidate.Description)) == wanted then
            return candidate
        end
    end
    return nil
end

-- === Queries ===
-- Each takes string args straight from the request line and returns a
-- table for the envelope's data field, or raises; the dispatcher turns a
-- raise into an ok=false reply. Exposed on Rpc._queries as the offline
-- suite's seam.

local queries = {}
Rpc._queries = queries

function queries.ping()
    local me = Game.GetActivePlayer()
    local p = Players[me]
    local w, h = Map.GetGridSize()
    local alive = 0
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if Players[i]:IsAlive() then
            alive = alive + 1
        end
    end
    return {
        civilization = p:GetCivilizationShortDescription(),
        era = Text.key(GameInfo.Eras[p:GetCurrentEra()].Description),
        mapWidth = w,
        mapHeight = h,
        majorCivsAlive = alive,
        isNetworkMultiplayer = Game.IsNetworkMultiPlayer(),
    }
end

-- The player's own city closest to (x, y): localized name and distance.
-- "Nearest" for a resource means nearest to the empire, not the capital --
-- a wide empire's frontier city is usually the relevant anchor.
local function nearestOwnCity(p, x, y)
    local best, bestDist
    for city in p:Cities() do
        local d = Map.PlotDistance(city:GetX(), city:GetY(), x, y)
        if bestDist == nil or d < bestDist then
            best, bestDist = city, d
        end
    end
    if best == nil then
        return nil, nil
    end
    return best:GetName(), bestDist
end

function queries.find_resource(name)
    local res = resolveRow("Resources", "RESOURCE_", name)
    if res == nil then
        error("unknown resource: " .. tostring(name))
    end
    local me = Game.GetActivePlayer()
    local p = Players[me]
    local team = p:GetTeam()
    local capital = p:GetCapitalCity()
    local cx, cy
    if capital ~= nil then
        cx, cy = capital:GetX(), capital:GetY()
    end
    local hits = {}
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        -- GetResourceType(team) applies the reveal tech itself; the
        -- IsRevealed gate keeps unexplored map out of the reply.
        if plot:IsRevealed(team, false) and plot:GetResourceType(team) == res.ID then
            local entry = {
                x = plot:GetX(),
                y = plot:GetY(),
                quantity = plot:GetNumResource(),
                improved = plot:GetImprovementType() ~= -1,
            }
            if cx ~= nil then
                entry.distanceFromCapital = Map.PlotDistance(cx, cy, entry.x, entry.y)
            end
            local cityName, cityDist = nearestOwnCity(p, entry.x, entry.y)
            if cityName ~= nil then
                entry.nearestCity = cityName
                entry.distanceFromNearestCity = cityDist
                -- Third ring of a city is as far as border growth or tile
                -- purchase reaches: the operational "you can grab this".
                entry.withinCityRange = cityDist <= 3
            end
            local owner = plot:GetOwner()
            if owner >= 0 then
                entry.owner = Players[owner]:GetCivilizationShortDescription()
                entry.ownedByYou = owner == me
            end
            hits[#hits + 1] = entry
        end
    end
    table.sort(hits, function(a, b)
        return (a.distanceFromNearestCity or a.distanceFromCapital or 0)
            < (b.distanceFromNearestCity or b.distanceFromCapital or 0)
    end)
    local listed = {}
    for i = 1, math.min(#hits, MAX_RESULT_PLOTS) do
        listed[i] = hits[i]
    end
    return {
        resource = Text.key(res.Description),
        resourceType = res.Type,
        totalRevealed = #hits,
        plots = listed,
    }
end

local CATEGORIES = {
    resource = {
        table = "Resources",
        prefix = "RESOURCE_",
        get = function(plot, team)
            return plot:GetResourceType(team)
        end,
    },
    terrain = {
        table = "Terrains",
        prefix = "TERRAIN_",
        get = function(plot)
            return plot:GetTerrainType()
        end,
    },
    feature = {
        table = "Features",
        prefix = "FEATURE_",
        get = function(plot)
            return plot:GetFeatureType()
        end,
    },
    improvement = {
        table = "Improvements",
        prefix = "IMPROVEMENT_",
        get = function(plot)
            return plot:GetImprovementType()
        end,
    },
}

function queries.count_in_borders(category, typeName)
    local cat = CATEGORIES[category]
    if cat == nil then
        error("unknown category: " .. tostring(category) .. " (expected resource, terrain, feature, or improvement)")
    end
    local row = resolveRow(cat.table, cat.prefix, typeName)
    if row == nil then
        error("unknown " .. category .. ": " .. tostring(typeName))
    end
    local me = Game.GetActivePlayer()
    local team = Players[me]:GetTeam()
    local count = 0
    local quantity = 0
    local improvedCount = 0
    local ownedTiles = 0
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot:GetOwner() == me then
            ownedTiles = ownedTiles + 1
            if cat.get(plot, team) == row.ID then
                count = count + 1
                if category == "resource" then
                    quantity = quantity + plot:GetNumResource()
                    if plot:GetImprovementType() ~= -1 then
                        improvedCount = improvedCount + 1
                    end
                end
            end
        end
    end
    -- ownedTiles disambiguates a zero: "0 grassland of 7 owned tiles" is a
    -- plains start; "0 of 0" is an empire with no territory yet.
    local data = {
        name = Text.key(row.Description),
        type = row.Type,
        category = category,
        tiles = count,
        ownedTiles = ownedTiles,
    }
    if category == "resource" then
        data.totalQuantity = quantity
        data.improvedTiles = improvedCount
    end
    return data
end

-- === Map dump ===
-- One fat read: the entire revealed map in a compact, layer-per-aspect
-- form. All spatial analysis (landmasses, mountain ranges, civ positions,
-- border reports) happens in the MCP server's geometry module; this side
-- only exports honestly. Layer encoding: an array of `height` strings,
-- one per row (y = 0 first, the map's south edge), `width` chars each.
-- "?" always means unrevealed. Terrain / feature / owner chars are
-- allocated on first encounter and described in the reply's legends, so
-- engine variants (VP, LekMod) that add rows need no maintenance here.

local LEGEND_POOL = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

-- Allocator for one layer's legend: maps a stable key (type ID / player
-- ID) to a single char, building the char -> info legend as it goes.
local function legendAllocator()
    local assigned = {}
    local legend = {}
    local count = 0
    local function charFor(key, info)
        local c = assigned[key]
        if c == nil then
            count = count + 1
            -- "+" after 62 distinct values: unreachable for terrains and
            -- features, and 63+ simultaneous known owners exceeds the
            -- engine's own player cap. Kept so exhaustion degrades to a
            -- shared bucket instead of an error.
            c = count <= #LEGEND_POOL and LEGEND_POOL:sub(count, count) or "+"
            assigned[key] = c
            legend[c] = info
        end
        return c
    end
    return charFor, legend
end

local PLOT_TYPE_CHARS = {} -- populated lazily; PlotTypes is engine-injected

local function plotTypeChar(pt)
    if PLOT_TYPE_CHARS.mountain == nil then
        PLOT_TYPE_CHARS[PlotTypes.PLOT_MOUNTAIN] = "M"
        PLOT_TYPE_CHARS[PlotTypes.PLOT_HILLS] = "H"
        PLOT_TYPE_CHARS[PlotTypes.PLOT_LAND] = "F"
        PLOT_TYPE_CHARS[PlotTypes.PLOT_OCEAN] = "W"
        PLOT_TYPE_CHARS.mountain = true
    end
    return PLOT_TYPE_CHARS[pt] or "x"
end

function queries.dump_map()
    local me = Game.GetActivePlayer()
    local p = Players[me]
    local myTeam = p:GetTeam()
    local w, h = Map.GetGridSize()

    local terrainChar, terrainLegend = legendAllocator()
    local featureChar, featureLegend = legendAllocator()
    local ownerChar, ownerLegend = legendAllocator()

    local visRows, plotRows, terrainRows, featureRows, riverRows, ownerRows = {}, {}, {}, {}, {}, {}
    local cities = {}
    local resources = {}
    local resourceTypes = {}
    local naturalWonders = {}

    for y = 0, h - 1 do
        local vis, plotT, terr, feat, river, own = {}, {}, {}, {}, {}, {}
        for x = 0, w - 1 do
            local plot = Map.GetPlot(x, y)
            local i = x + 1
            if not plot:IsRevealed(myTeam, false) then
                vis[i], plotT[i], terr[i], feat[i], river[i], own[i] = "?", "?", "?", "?", "?", "?"
            else
                vis[i] = plot:IsVisible(myTeam, false) and "1" or "0"
                plotT[i] = plotTypeChar(plot:GetPlotType())

                local trow = GameInfo.Terrains[plot:GetTerrainType()]
                terr[i] = terrainChar(trow.ID, {
                    type = trow.Type,
                    name = Text.key(trow.Description),
                })

                local fid = plot:GetFeatureType()
                if fid == -1 then
                    feat[i] = "-"
                else
                    local frow = GameInfo.Features[fid]
                    feat[i] = featureChar(frow.ID, {
                        type = frow.Type,
                        name = Text.key(frow.Description),
                    })
                    if frow.NaturalWonder then
                        naturalWonders[#naturalWonders + 1] = {
                            x = x,
                            y = y,
                            name = Text.key(frow.Description),
                        }
                    end
                end

                river[i] = string.format(
                    "%d",
                    (plot:IsWOfRiver() and 1 or 0) + (plot:IsNWOfRiver() and 2 or 0) + (plot:IsNEOfRiver() and 4 or 0)
                )

                local owner = plot:GetRevealedOwner(myTeam, false)
                if owner < 0 then
                    own[i] = "-"
                else
                    own[i] = ownerChar(owner, { player = owner })
                end

                local rid = plot:GetResourceType(myTeam)
                if rid ~= -1 then
                    local rrow = GameInfo.Resources[rid]
                    if resourceTypes[rrow.Type] == nil then
                        resourceTypes[rrow.Type] = {
                            name = Text.key(rrow.Description),
                            -- 0 bonus, 1 luxury, 2 strategic
                            usage = rrow.ResourceUsage,
                            -- Copies the player already counts: total
                            -- available (imports included) and the
                            -- own-supply share, so "new luxury for you"
                            -- is a verified claim, not a guess.
                            youHave = p:GetNumResourceAvailable(rid, true),
                            youOwn = p:GetNumResourceAvailable(rid, false),
                        }
                    end
                    resources[#resources + 1] = { x = x, y = y, t = rrow.Type }
                end

                -- Cities on revealed plots. IsCity reads live state, so a
                -- city founded or razed while the plot sat fogged shows /
                -- vanishes earlier than the player's last sighting would;
                -- the engine exposes no last-known-city binding to be more
                -- honest with. The visible flag marks which entries are
                -- current knowledge versus remembered ground.
                if plot:IsCity() then
                    local city = plot:GetPlotCity()
                    cities[#cities + 1] = {
                        x = x,
                        y = y,
                        name = city:GetName(),
                        owner = city:GetOwner(),
                        capital = city:IsCapital(),
                        visible = vis[i] == "1",
                    }
                end
            end
        end
        local r = y + 1
        visRows[r] = table.concat(vis)
        plotRows[r] = table.concat(plotT)
        terrainRows[r] = table.concat(terr)
        featureRows[r] = table.concat(feat)
        riverRows[r] = table.concat(river)
        ownerRows[r] = table.concat(own)
    end

    local players = {}
    for id = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local pl = Players[id]
        if pl ~= nil and pl:IsEverAlive() and not pl:IsBarbarian() and Teams[myTeam]:IsHasMet(pl:GetTeam()) then
            players[#players + 1] = {
                id = id,
                civ = pl:GetCivilizationShortDescription(),
                minor = pl:IsMinorCiv(),
                alive = pl:IsAlive(),
                you = id == me,
            }
        end
    end

    -- Diplomacy among met players. Wars, declared friendships, and
    -- defensive pacts are all public knowledge in-game once both parties
    -- are met (the diplomacy overview shows them), and every entry in
    -- `players` is met, so pairwise reads over this list leak nothing.
    -- A city-state's ally is shown on its diplo screen; when the ally is
    -- a civ the player hasn't met, the game says so without naming it,
    -- and hasUnmetAlly mirrors that exactly.
    for _, entry in ipairs(players) do
        local pl = Players[entry.id]
        local t = pl:GetTeam()
        if entry.minor then
            local ally = pl:GetAlly()
            if ally ~= nil and ally >= 0 then
                if Teams[myTeam]:IsHasMet(Players[ally]:GetTeam()) then
                    entry.allyId = ally
                else
                    entry.hasUnmetAlly = true
                end
            end
        elseif entry.alive then
            local wars, friends, pacts = {}, {}, {}
            for _, other in ipairs(players) do
                if other.id ~= entry.id and other.alive then
                    local ot = Players[other.id]:GetTeam()
                    if Teams[t]:IsAtWar(ot) then
                        wars[#wars + 1] = other.id
                    end
                    if not entry.minor and not other.minor then
                        if pl:IsDoF(other.id) then
                            friends[#friends + 1] = other.id
                        end
                        if t ~= ot and Teams[t]:IsDefensivePact(ot) then
                            pacts[#pacts + 1] = other.id
                        end
                    end
                end
            end
            entry.atWarWith = wars
            entry.friendsWith = friends
            entry.defensivePactsWith = pacts
        end
    end

    -- Foreign settlers the player can see right now: expansion pressure a
    -- sighted player reads off the map. Majors only (city-states never
    -- build settlers); visible-now, so the list changes between calls.
    local foreignSettlers = {}
    for id = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pl = Players[id]
        if pl ~= nil and id ~= me and pl:IsAlive() and Teams[myTeam]:IsHasMet(pl:GetTeam()) then
            for unit in pl:Units() do
                if unit:IsFound() and unit:GetPlot():IsVisible(myTeam, false) then
                    foreignSettlers[#foreignSettlers + 1] = {
                        x = unit:GetX(),
                        y = unit:GetY(),
                        owner = id,
                    }
                end
            end
        end
    end

    -- The mod's map cursor, read live. Unset until Cursor.init has run
    -- (LoadScreenClose), and meaningful to the player as "the tile I was
    -- last looking at" -- the natural anchor for "describe from here".
    local cursor = nil
    local cursorX, cursorY = Cursor.position()
    if cursorX ~= nil then
        cursor = { x = cursorX, y = cursorY }
    end

    local capital = p:GetCapitalCity()
    return {
        width = w,
        height = h,
        wrapX = Map.IsWrapX(),
        capital = capital ~= nil and { x = capital:GetX(), y = capital:GetY() } or nil,
        cursor = cursor,
        layers = {
            visibility = visRows,
            plotType = plotRows,
            terrain = terrainRows,
            feature = featureRows,
            river = riverRows,
            owner = ownerRows,
        },
        legends = {
            terrain = terrainLegend,
            feature = featureLegend,
            owner = ownerLegend,
        },
        cities = cities,
        resources = resources,
        resourceTypes = resourceTypes,
        naturalWonders = naturalWonders,
        players = players,
        foreignSettlers = foreignSettlers,
    }
end

-- === Settle-spot facts ===
-- Live engine reads the map dump can't answer: founding legality (the
-- engine's own rule, min city distance included), fresh water, coast,
-- river adjacency, and settler travel turns via the fork pathfinder.
-- The MCP server merges these with its dump-side ring analysis.

function queries.evaluate_settle(xs, ys)
    local x, y = tonumber(xs), tonumber(ys)
    if x == nil or y == nil then
        error("evaluate_settle needs numeric x and y")
    end
    local plot = Map.GetPlot(x, y)
    if plot == nil then
        error("no plot at (" .. tostring(xs) .. ", " .. tostring(ys) .. ")")
    end
    local me = Game.GetActivePlayer()
    local p = Players[me]
    local data = {
        canFound = p:CanFound(x, y),
        freshWater = plot:IsFreshWater(),
        coastal = plot:IsCoastalLand(),
        riverAdjacent = plot:IsRiver(),
    }
    -- Travel turns per settler the player owns, priced by the engine
    -- pathfinder through the seam. Omitted entirely without the fork --
    -- an absent field reads as "unknown", never as "unreachable".
    if EngineData.forkPresent() then
        local settlers = {}
        for unit in p:Units() do
            if unit:IsFound() then
                local _, ok, turns = EngineData.computePath(unit, unit:GetPlot(), plot)
                local entry = {
                    x = unit:GetX(),
                    y = unit:GetY(),
                    reachable = ok == true,
                }
                if ok then
                    entry.turns = turns
                end
                settlers[#settlers + 1] = entry
            end
        end
        data.yourSettlers = settlers
    end
    return data
end

-- === War report data ===
-- Every visible unit belonging to anyone the player is at war with
-- (barbarians included), plus the player's own units and city health --
-- the raw material for the MCP server's war-report clustering. Reuses
-- ScannerBackendUnits.Scan so hostility, visibility, and role
-- classification are the exact rules the in-game scanner applies; the
-- bridge and the scanner can never disagree about what is visible or
-- what counts as an enemy. Fresh enumeration per call (Scan reads live
-- engine state); the scanner's own stored snapshot is never touched.

local function unitEntry(unit, scanEntry)
    return {
        x = unit:GetX(),
        y = unit:GetY(),
        name = scanEntry.itemName,
        role = scanEntry.subcategory,
        hp = unit:GetCurrHitPoints(),
        maxHp = unit:GetMaxHitPoints(),
        embarked = unit:IsEmbarked(),
    }
end

function queries.list_hostiles()
    local me = Game.GetActivePlayer()
    local myTeam = Game.GetActiveTeam()
    local hostiles, mine = {}, {}
    for _, e in ipairs(ScannerBackendUnits.Scan(me, myTeam)) do
        if e.category == "units_enemy" or e.category == "units_my" then
            local owner = Players[e.data.ownerId]
            local unit = owner:GetUnitByID(e.data.unitId)
            -- Scan just returned the unit, but re-resolve and re-check
            -- anyway: entries carry ids, not handles, and a dead unit
            -- yields nil.
            if unit ~= nil and not unit:IsDead() then
                local u = unitEntry(unit, e)
                if e.category == "units_my" then
                    u.movesLeft = unit:MovesLeft() / GameDefines.MOVE_DENOMINATOR
                    mine[#mine + 1] = u
                else
                    u.civ = owner:GetCivilizationShortDescription()
                    u.barbarian = owner:IsBarbarian()
                    hostiles[#hostiles + 1] = u
                end
            end
        end
    end

    local myCities = {}
    for city in Players[me]:Cities() do
        myCities[#myCities + 1] = {
            name = city:GetName(),
            x = city:GetX(),
            y = city:GetY(),
            damage = city:GetDamage(),
            maxHp = city:GetMaxHitPoints(),
        }
    end

    -- Cities of civs the player is at war with, only while their plot is
    -- actually visible -- city health is banner information a sighted
    -- player reads off the screen, and the banner needs sight.
    local enemyCities = {}
    for id = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local pl = Players[id]
        if pl ~= nil and pl:IsAlive() and Teams[myTeam]:IsAtWar(pl:GetTeam()) then
            for city in pl:Cities() do
                if city:Plot():IsVisible(myTeam, false) then
                    enemyCities[#enemyCities + 1] = {
                        name = city:GetName(),
                        civ = pl:GetCivilizationShortDescription(),
                        x = city:GetX(),
                        y = city:GetY(),
                        damage = city:GetDamage(),
                        maxHp = city:GetMaxHitPoints(),
                    }
                end
            end
        end
    end

    return {
        hostileUnits = hostiles,
        yourUnits = mine,
        yourCities = myCities,
        visibleEnemyCities = enemyCities,
    }
end

-- === Cursor pointing ===
-- Moves the mod's map cursor to a tile and speaks the landing glance, so
-- the assistant can point at a location and the player can explore from
-- it with their normal cursor and surveyor keys. Mod-side state only.
-- Cursor.jumpTo carries the same scope guard as manual movement, so a
-- scoped mode (city-view hex picker, strike targeting) rejects the jump
-- with its edge-of-scope message rather than teleporting out of scope.

function queries.point_cursor(xs, ys)
    local x, y = tonumber(xs), tonumber(ys)
    if x == nil or y == nil then
        error("point_cursor needs numeric x and y")
    end
    if Map.GetPlot(x, y) == nil then
        error("no plot at (" .. tostring(xs) .. ", " .. tostring(ys) .. ")")
    end
    local glance = Cursor.jumpTo(x, y)
    if glance ~= nil and glance ~= "" then
        SpeechPipeline.speakInterrupt(glance)
    end
    return { x = x, y = y, spoken = glance or "" }
end

-- === Dispatch ===

local function respond(envelope)
    if not rpc.respond(encode(envelope)) then
        Log.error("Rpc: response write failed (id=" .. tostring(envelope.id) .. ")")
    end
end

function Rpc._poll()
    local line = rpc.poll()
    if line == nil then
        return
    end
    local fields = {}
    for f in line:gmatch("[^\t\r\n]+") do
        fields[#fields + 1] = f
    end
    local id, name = fields[1], fields[2]
    if id == nil or name == nil then
        Log.warn("Rpc: malformed request: " .. tostring(line))
        respond({ id = id or "", ok = false, error = "malformed request" })
        return
    end
    local envelope = {
        id = id,
        turn = Game.GetGameTurn(),
        activePlayer = Game.GetActivePlayer(),
    }
    -- The origin of the coordinates the player hears in game (original
    -- capital, per HexGeom.coordinateString). The MCP server uses it to
    -- express every x/y it emits or accepts in that same system; absent
    -- before the first city exists.
    local originX, originY = HexGeom.originCapital()
    if originX ~= nil then
        local gridW, gridH = Map.GetGridSize()
        envelope.coordOrigin = {
            x = originX,
            y = originY,
            mapWidth = gridW,
            mapHeight = gridH,
            wrapX = Map.IsWrapX(),
        }
    end
    local fn = queries[name]
    if fn == nil then
        envelope.ok = false
        envelope.error = "unknown query: " .. name
        Log.warn("Rpc: " .. envelope.error)
    else
        local okCall, result = pcall(fn, unpack(fields, 3))
        if okCall then
            envelope.ok = true
            envelope.data = result
        else
            -- Strip Lua's "file:line: " prefix from the reply; the full
            -- string still goes to the log, where file and line are useful.
            Log.error("Rpc: query '" .. name .. "' failed: " .. tostring(result))
            envelope.ok = false
            envelope.error = (tostring(result):gsub("^.-:%d+: ", ""))
        end
    end
    respond(envelope)
end

function Rpc.installListeners()
    if rpc == nil then
        Log.warn(
            "CivVAccess_Rpc: proxy rpc table missing -- the installed proxy "
                .. "predates the MCP bridge; run ./build-proxy.ps1 then "
                .. "./deploy.ps1. MCP queries will go unanswered."
        )
        return
    end
    TickPump.subscribe(SUBSCRIBER_NAME, Rpc._poll)
end

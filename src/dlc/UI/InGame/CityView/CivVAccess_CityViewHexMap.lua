-- Hex map sub-handler for the CityView accessibility hub. Peeled out of
-- CivVAccess_CityViewAccess.lua. Owns:
--
-- - Cursor-driven tile inspection within the city's reach (city center,
--   workable ring, and every purchasable plot including culture grabs
--   beyond the ring).
-- - The scope predicate (hexMapScope) and per-tile announcer
--   (hexTileAnnouncement) installed on civvaccess_shared so the generic
--   Cursor module routes through them without knowing about CityView.
-- - The Enter actions (citizen toggle via TASK_CHANGE_WORKING_PLOT, plot
--   buy via Network.SendCityBuyPlot, the unaffordable / center / blocked
--   no-op branches), plus the L (list worked tiles) chord.
-- - The Scanner / Surveyor binding pull-in (the hub's
--   capturesAllInput=true would otherwise wall those off).
--
-- Exposes `CityViewHexMap.push` for the hub to invoke from buildHubItems.
-- No other external surface; the orchestrator's
-- `CivVAccess_CityViewAccess` only reaches for `.push`.
--
-- Cursor / ScannerNav / PlotComposers / ScannerHandler / SurveyorCore
-- live in Boot's WorldView Context; Civ V sandboxes Lua globals per
-- Context so they aren't visible here directly. Boot publishes them
-- on civvaccess_shared.modules; capturing the refs at file-include
-- time gives us the same singleton state without re-including (which
-- would fragment _x/_y, _snapshot, etc. across Contexts). A nil here
-- would mean Boot hasn't completed for this lua_State -- pushHexMap
-- guards against that at call time and bails loudly.

CityViewHexMap = {}

local _hexDeps = civvaccess_shared.modules or {}
local Cursor = _hexDeps.Cursor
local ScannerNav = _hexDeps.ScannerNav
local ScannerHandler = _hexDeps.ScannerHandler
local SurveyorCore = _hexDeps.SurveyorCore
local PlotComposers = _hexDeps.PlotComposers
local HexGeom = _hexDeps.HexGeom

-- ===== Local helpers (duplicated from the orchestrator) =====

local function isTurnActive()
    return Players[Game.GetActivePlayer()]:IsTurnActive()
end

-- ===== Hex-map predicates =====

-- GetCityIndexPlot iterates the FULL 37-plot 3-hex ring regardless of
-- city size, so a plot being "in the ring" at this level just means it's
-- in the navigation radius -- NOT that the city actually owns it or can
-- work it. Use this for the engine-facing plot index (TASK_CHANGE_WORKING_PLOT
-- wants the ring-relative index) but NEVER as the "is this plot mine"
-- signal -- that's isInWorkingArea below.
local function plotIndexInRing(city, plot)
    if plot == nil or city == nil then
        return nil
    end
    local px, py = plot:GetX(), plot:GetY()
    for i = 0, city:GetNumCityPlots() - 1 do
        local p = city:GetCityIndexPlot(i)
        if p ~= nil and p:GetX() == px and p:GetY() == py then
            return i
        end
    end
    return nil
end

-- Is the plot actually part of this city's working area (owned by this
-- city, within its effective reach -- not just within the max 3-hex ring).
-- plot:GetWorkingCity() is the engine's "which of my cities claims this
-- tile" accessor; a size-1 city's small effective radius means most of
-- its navigation ring returns nil / a different city here. Guard the
-- owner comparison too so a neighbour's city with the same per-player
-- id doesn't falsely match.
local function isInWorkingArea(city, plot)
    if city == nil or plot == nil then
        return false
    end
    local workingCity = plot:GetWorkingCity()
    if workingCity == nil then
        return false
    end
    return workingCity:GetID() == city:GetID() and workingCity:GetOwner() == city:GetOwner()
end

-- Worked and pinned are orthogonal engine flags, not a single state:
-- pinned tiles whose citizen was displaced (enemy adjacent, blockade) end
-- up pinned-but-not-worked, and the flag doesn't auto-clear. Report each
-- axis independently. Blocked is the can't-be-worked bucket (CanWork false)
-- and short-circuits the worked word since "not worked, blocked" would be
-- redundant. Pinned is appended afterward when set regardless of the
-- worked-axis outcome so the rare pinned+blocked or pinned+not-worked
-- states still surface.
local function workedStateTokens(city, plot)
    local tokens = {}
    if not city:CanWork(plot) then
        tokens[#tokens + 1] = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED")
    elseif city:IsWorkingPlot(plot) then
        tokens[#tokens + 1] = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED")
    else
        tokens[#tokens + 1] = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED")
    end
    if city:IsForcedWorkingPlot(plot) then
        tokens[#tokens + 1] = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED")
    end
    return tokens
end

local function hexTileAnnouncement(plot)
    local city = UI.GetHeadSelectedCity()
    if city == nil or plot == nil then
        return ""
    end
    local parts = {}
    local px, py = plot:GetX(), plot:GetY()
    local isCenter = (px == city:GetX() and py == city:GetY())
    -- Three disjoint cases that lead the announcement:
    -- 1) Center -- the yield line and glance cover it; skip state.
    -- 2) In working area (this city owns and can reach the tile) -- emit
    --    worked / pinned / blocked tokens.
    -- 3) Purchasable -- emit buy cost (affordable or "cannot afford"). A
    --    tile can be in nav ring but not working area (out of current
    --    radius) and not purchasable (already owned by another city of
    --    ours); we fall through silently for those -- the glance tells
    --    the user who owns it.
    if not isCenter then
        if isInWorkingArea(city, plot) then
            for _, t in ipairs(workedStateTokens(city, plot)) do
                parts[#parts + 1] = t
            end
        elseif city:CanBuyPlotAt(px, py, true) then
            local cost = city:GetBuyPlotCost(px, py)
            if city:CanBuyPlotAt(px, py, false) then
                parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST", cost)
            else
                parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE", cost)
            end
        end
    end
    -- contextCity collapses economy's "controlled by <this city>" line to just
    -- "controlled" -- the user already knows which city they're managing.
    -- Split-ring tiles (another of our cities owns the plot) still get the
    -- full "controlled by X" since that IS distinguishing info.
    local yieldText = PlotComposers.economy(plot, { contextCity = city })
    if yieldText ~= nil and yieldText ~= "" then
        parts[#parts + 1] = yieldText
    end
    local glance = PlotComposers.glance(plot, {})
    if glance ~= nil and glance ~= "" then
        parts[#parts + 1] = glance
    end
    if #parts == 0 then
        return ""
    end
    return table.concat(parts, ". ") .. "."
end

local function hexMapScope(x, y)
    local c = UI.GetHeadSelectedCity()
    if c == nil then
        return false
    end
    -- City center always in scope.
    if x == c:GetX() and y == c:GetY() then
        return true
    end
    local plot = Map.GetPlot(x, y)
    if plot == nil then
        return false
    end
    -- Any tile this city actually owns (covers worked, blocked, out-of-
    -- current-radius-but-owned edge cases).
    if isInWorkingArea(c, plot) then
        return true
    end
    -- Any purchasable tile, including unaffordable ones so the user can
    -- hear the cost and decide to save for it.
    if c:CanBuyPlotAt(x, y, true) then
        return true
    end
    return false
end

local function activateHexTile()
    local city = UI.GetHeadSelectedCity()
    if city == nil or not isTurnActive() then
        return
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        return
    end
    local plot = Map.GetPlot(cx, cy)
    if plot == nil then
        return
    end
    -- City center is a no-op; announcement already told the user.
    if cx == city:GetX() and cy == city:GetY() then
        return
    end
    -- Owned tile in this city's working area: try to toggle citizen
    -- assignment. The engine's TASK_CHANGE_WORKING_PLOT wants the 37-plot
    -- ring index, which plotIndexInRing resolves. Skip when CanWork is
    -- false (blocked, out of radius) -- the task wouldn't apply and speech
    -- already explained why.
    if isInWorkingArea(city, plot) then
        if not city:CanWork(plot) then
            return
        end
        local ringIdx = plotIndexInRing(city, plot)
        if ringIdx == 0 then
            return
        end
        if ringIdx == nil then
            -- isInWorkingArea said this plot is one of ours but it's not
            -- in the 37-plot ring GetCityIndexPlot enumerates. Vanilla's
            -- max city radius is 3 so this shouldn't reach, but the
            -- engine drops citizen-toggle silently if we still send the
            -- task; log so the failure is visible if a mod or future
            -- expansion widens the working area.
            Log.warn(
                "CityView hex: plot ("
                    .. tostring(cx)
                    .. ","
                    .. tostring(cy)
                    .. ") in working area but outside ring of city "
                    .. tostring(city:GetID())
            )
            return
        end
        Network.SendDoTask(city:GetID(), TaskTypes.TASK_CHANGE_WORKING_PLOT, ringIdx, -1, false, false, false, false)
        TickPump.runOnce(function()
            SpeechPipeline.speakInterrupt(hexTileAnnouncement(Map.GetPlot(cx, cy)))
        end)
        return
    end
    if city:CanBuyPlotAt(cx, cy, true) then
        if not city:CanBuyPlotAt(cx, cy, false) then
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"))
            return
        end
        Network.SendCityBuyPlot(city:GetID(), cx, cy)
        Events.AudioPlay2DSound("AS2D_INTERFACE_BUY_TILE")
        TickPump.runOnce(function()
            SpeechPipeline.speakInterrupt(hexTileAnnouncement(Map.GetPlot(cx, cy)))
        end)
    end
end

-- L: speak every tile this city is currently working as one utterance,
-- ordered by cube distance from the live cursor (then directionRank to
-- mirror the scanner / surveyor tiebreak). The city center is filtered
-- because it's auto-worked, not a citizen choice -- IsWorkingPlot returns
-- true for it but the player never "picks" the center. The pinned suffix
-- only appears on tiles the player has explicitly forced; auto-assigned
-- worked tiles are bare.
local function listWorkedTilesFromCursor()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        return
    end
    local cityX, cityY = city:GetX(), city:GetY()
    local entries = {}
    for i = 0, city:GetNumCityPlots() - 1 do
        local plot = city:GetCityIndexPlot(i)
        if plot ~= nil and city:IsWorkingPlot(plot) then
            local px, py = plot:GetX(), plot:GetY()
            if not (px == cityX and py == cityY) then
                entries[#entries + 1] = {
                    plot = plot,
                    px = px,
                    py = py,
                    distance = HexGeom.cubeDistance(cx, cy, px, py),
                    rank = HexGeom.directionRank(cx, cy, px, py),
                }
            end
        end
    end
    if #entries == 0 then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_LIST_NONE"))
        return
    end
    table.sort(entries, function(a, b)
        if a.distance ~= b.distance then
            return a.distance < b.distance
        end
        return a.rank < b.rank
    end)
    local parts = {}
    for _, e in ipairs(entries) do
        local pieces = {}
        if e.distance == 0 then
            pieces[#pieces + 1] = Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
        else
            pieces[#pieces + 1] = HexGeom.directionString(cx, cy, e.px, e.py)
        end
        local glance = PlotComposers.glance(e.plot, {})
        if glance ~= nil and glance ~= "" then
            pieces[#pieces + 1] = glance
        end
        if city:IsForcedWorkingPlot(e.plot) then
            pieces[#pieces + 1] = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED")
        end
        parts[#parts + 1] = table.concat(pieces, ", ")
    end
    SpeechPipeline.speakInterrupt(table.concat(parts, ". ") .. ".")
end

local function pushHexMap()
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return
    end
    -- Required module refs. Cursor + ScannerNav + PlotComposers + HexGeom are
    -- load-bearing; ScannerHandler / SurveyorCore are optional extras wired
    -- at push time. A missing Cursor means the sub is unusable -- bail before
    -- any shared state mutation so a broken Boot doesn't leave mapScope
    -- dangling and permanently jam the world cursor.
    if Cursor == nil or ScannerNav == nil or PlotComposers == nil or HexGeom == nil then
        Log.error("CityView hex: civvaccess_shared.modules missing required entries; hex sub unavailable")
        return
    end

    local MOD_NONE = 0
    local function moveDir(dir)
        return function()
            SpeechPipeline.speakInterrupt(Cursor.move(dir))
        end
    end
    local function popSelf()
        HandlerStack.removeByName("CityView.HexMap", true)
    end

    -- The hub's capturesAllInput=true swallows every key not bound on a
    -- handler above it, so Scanner / Surveyor bindings from Baseline would
    -- be dead while CityView is up. Pull them in at push time. Scanner's
    -- gatherEntries already respects civvaccess_shared.mapScope, so its
    -- snapshot is auto-scoped to this city. Surveyor deliberately sweeps
    -- its radius ignoring the scope predicate (plan §3.4): its radius cap
    -- is the real bound, and scoping it would hide info a sighted player
    -- glances at. Pull helpEntries too so F1 lists every key.
    local bindings = {
        { key = Keys.VK_ESCAPE, mods = MOD_NONE, description = "Back", fn = popSelf },
        { key = Keys.VK_RETURN, mods = MOD_NONE, description = "Activate tile", fn = activateHexTile },
        { key = Keys.L, mods = MOD_NONE, description = "List worked tiles", fn = listWorkedTilesFromCursor },
        { key = Keys.Q, mods = MOD_NONE, description = "Move NW", fn = moveDir(DirectionTypes.DIRECTION_NORTHWEST) },
        { key = Keys.E, mods = MOD_NONE, description = "Move NE", fn = moveDir(DirectionTypes.DIRECTION_NORTHEAST) },
        { key = Keys.A, mods = MOD_NONE, description = "Move W", fn = moveDir(DirectionTypes.DIRECTION_WEST) },
        { key = Keys.D, mods = MOD_NONE, description = "Move E", fn = moveDir(DirectionTypes.DIRECTION_EAST) },
        { key = Keys.Z, mods = MOD_NONE, description = "Move SW", fn = moveDir(DirectionTypes.DIRECTION_SOUTHWEST) },
        { key = Keys.C, mods = MOD_NONE, description = "Move SE", fn = moveDir(DirectionTypes.DIRECTION_SOUTHEAST) },
        -- Tile readouts ported from BaselineHandler so the same chord
        -- speaks the same answer in the hex sub. Cursor.economy / .combat
        -- read the live plot, so the hex-sub scoping flows through naturally.
        {
            key = Keys.W,
            mods = MOD_NONE,
            description = "Economy details",
            fn = function()
                SpeechPipeline.speakInterrupt(Cursor.economy())
            end,
        },
        {
            key = Keys.X,
            mods = MOD_NONE,
            description = "Combat details",
            fn = function()
                SpeechPipeline.speakInterrupt(Cursor.combat())
            end,
        },
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE",
            description = "TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER",
            description = "TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_LIST",
            description = "TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_LIST",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK",
            description = "TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT",
        },
    }
    -- Surveyor keys come first so their per-feature help reads before
    -- the scanner's generic page-cycling chords -- the user's mental
    -- model is "specific (Q radius, A resources...) above general
    -- (PageUp/Down to walk a snapshot)".
    if type(SurveyorCore) == "table" and type(SurveyorCore.getBindings) == "function" then
        local surv = SurveyorCore.getBindings()
        for _, b in ipairs(surv.bindings or {}) do
            bindings[#bindings + 1] = b
        end
        for _, h in ipairs(surv.helpEntries or {}) do
            helpEntries[#helpEntries + 1] = h
        end
    else
        Log.warn("CityView hex: SurveyorCore not loaded; surveyor keys unreachable in hex sub")
    end
    if type(ScannerHandler) == "table" and type(ScannerHandler.create) == "function" then
        local scanner = ScannerHandler.create()
        for _, b in ipairs(scanner.bindings or {}) do
            bindings[#bindings + 1] = b
        end
        for _, h in ipairs(scanner.helpEntries or {}) do
            helpEntries[#helpEntries + 1] = h
        end
    else
        Log.warn("CityView hex: ScannerHandler not loaded; scanner keys unreachable in hex sub")
    end

    -- Install scope + announcer right before push so onActivate's Cursor.jumpTo
    -- sees them. HandlerStack.push invokes onActivate before recording the
    -- handler on the stack and returns false if it threw, in which case the
    -- handler is NOT on the stack and onDeactivate will never fire -- so we
    -- have to roll back the hooks manually below.
    civvaccess_shared.mapScope = hexMapScope
    civvaccess_shared.mapAnnouncer = hexTileAnnouncement

    local pushed = HandlerStack.push({
        name = "CityView.HexMap",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"),
        -- False so `.` / `,` on the hub still bubble for next/prev city.
        -- Scanner / Surveyor / movement bindings live on this handler; the
        -- hub's own up/down menu keys pass through harmlessly.
        capturesAllInput = false,
        bindings = bindings,
        helpEntries = helpEntries,
        onActivate = function()
            -- Mode landmark first (interrupt clears any hub speech), then
            -- jumpTo routes the city-center tile read through our announcer
            -- hook. Queue rather than interrupt so the mode word isn't eaten
            -- by the tile read that follows it.
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"))
            local c = UI.GetHeadSelectedCity()
            if c ~= nil then
                local tileSpeech = Cursor.jumpTo(c:GetX(), c:GetY())
                if tileSpeech ~= nil and tileSpeech ~= "" then
                    SpeechPipeline.speakQueued(tileSpeech)
                end
            end
        end,
        onDeactivate = function()
            civvaccess_shared.mapScope = nil
            civvaccess_shared.mapAnnouncer = nil
        end,
    })
    if not pushed then
        civvaccess_shared.mapScope = nil
        civvaccess_shared.mapAnnouncer = nil
    end
end

function CityViewHexMap.push()
    pushHexMap()
end

return CityViewHexMap

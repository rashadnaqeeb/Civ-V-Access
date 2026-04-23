-- City-ranged-strike target picker. Pushed above Baseline / Scanner after
-- the city screen closes and the engine enters INTERFACEMODE_CITY_RANGE_ATTACK.
-- Structurally a sibling to UnitTargetMode: Space speaks target preview,
-- Enter commits the strike, Esc cancels. Cursor-driven targeting via
-- civvaccess_shared.mapScope + mapAnnouncer so Baseline's Q/E/A/D/Z/C fall
-- through to the scoped Cursor; Alt+QAZEDC is swallowed to prevent the
-- direct-move binding from dispatching while the engine holds an attack
-- interface mode.
--
-- Scope predicate is authoritative CanRangeStrikeAt -- navigation only
-- lands on valid targets. CanRangeStrikeNow gates the entry point (hub
-- item is hidden when false), so at least one valid target is guaranteed
-- to exist when enter() runs.
--
-- Exit (commit OR cancel OR external pop) drops back to the world map;
-- the city screen does NOT re-open. Matches the sighted banner-click
-- flow: bombarding from a banner leaves you on the world, not in the
-- city screen.

CityRangeStrikeMode = {}

local MOD_NONE = 0
local MOD_ALT = 4

local bind = HandlerStack.bind

local function speakInterrupt(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakInterrupt(text)
end

local function resolveCity(ownerID, cityID)
    local owner = Players[ownerID]
    if owner == nil then
        return nil
    end
    return owner:GetCityByID(cityID)
end

-- First non-invisible enemy unit at plot (plot defender priority). Mirrors
-- UnitTargetMode.firstEnemyUnit. Used for the Space preview fallback when
-- the plot has no enemy city.
local function topEnemyUnitAt(plot)
    if plot == nil then
        return nil
    end
    local team = Game.GetActiveTeam()
    local activePlayer = Game.GetActivePlayer()
    local isDebug = Game.IsDebugMode()
    for i = 0, plot:GetNumUnits() - 1 do
        local u = plot:GetUnit(i)
        if u ~= nil and not u:IsInvisible(team, isDebug) and u:GetOwner() ~= activePlayer then
            return u
        end
    end
    return nil
end

-- Per-tile announcement used by both Cursor.move (via mapAnnouncer) and
-- the Space preview. Scope ensures only valid targets reach this; the
-- plot either has an enemy city or at least one visible enemy unit.
-- City preview prefers CitySpeech.identity (name, pop, defense, HP);
-- unit preview uses UnitSpeech.info (name, strength, moves, HP color).
-- The engine exposes no Lua-side city-to-target damage function, so the
-- preview is target identity only -- the user decides from HP and
-- strength whether to commit.
local function targetAnnouncement(plot)
    if plot == nil then
        return ""
    end
    local targetCity = plot:GetPlotCity()
    local activePlayer = Game.GetActivePlayer()
    if targetCity ~= nil and targetCity:GetOwner() ~= activePlayer then
        return CitySpeech.identity(targetCity)
    end
    local unit = topEnemyUnitAt(plot)
    if unit ~= nil then
        return UnitSpeech.info(unit)
    end
    return ""
end

-- Initial landing target: first plot inside the city's max strike range
-- (3 hexes covers policy-bumped cities; CanRangeStrikeAt filters the rest).
-- Iterates by expanding ring so the first match is spatially close to the
-- city rather than whatever the iteration order would otherwise pick.
local function findFirstTarget(city)
    local cx, cy = city:GetX(), city:GetY()
    for r = 1, 3 do
        for dx = -r, r do
            for dy = -r, r do
                local plot = Map.PlotXYWithRangeCheck(cx, cy, dx, dy, r)
                if plot ~= nil then
                    local px, py = plot:GetX(), plot:GetY()
                    if city:CanRangeStrikeAt(px, py, true, true) then
                        return plot
                    end
                end
            end
        end
    end
    return nil
end

-- Abandon-entry path. Called on any bail before the handler is on the
-- stack (nil city, CanRangeStrikeNow flipped false between hub activate
-- and the deferred enter(), no reachable target, HandlerStack.push
-- returning false). The caller has already put the engine into
-- CITY_RANGE_ATTACK with a selected city, so every bail has to unwind
-- that state or the user is stranded in an attack mode with no binding.
local function abandonEntry()
    civvaccess_shared.mapScope = nil
    civvaccess_shared.mapAnnouncer = nil
    ScannerNav.invalidate()
    UI.ClearSelectedCities()
    UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)
end

function CityRangeStrikeMode.enter(city)
    if city == nil then
        Log.warn("CityRangeStrikeMode.enter: nil city; aborting")
        abandonEntry()
        return
    end
    if not city:CanRangeStrikeNow() then
        Log.warn("CityRangeStrikeMode.enter: CanRangeStrikeNow false; aborting")
        abandonEntry()
        return
    end
    local ownerID = city:GetOwner()
    local cityID = city:GetID()

    -- Resolve the first valid target up-front. CanRangeStrikeNow is the
    -- engine's "can fire" gate but doesn't guarantee a reachable plot
    -- from Lua's side (mods, timing, or an offset larger than our 3-hex
    -- search box would all produce this). Bail with user feedback rather
    -- than leave the cursor stranded outside the strike zone.
    local initialTarget = findFirstTarget(city)
    if initialTarget == nil then
        Log.warn("CityRangeStrikeMode.enter: CanRangeStrikeNow true but no target found in 3-hex search; aborting")
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"))
        abandonEntry()
        return
    end

    local scope = function(x, y)
        local c = resolveCity(ownerID, cityID)
        if c == nil then
            return false
        end
        return c:CanRangeStrikeAt(x, y, true, true)
    end

    local self = {
        name = "CityRangeStrike",
        capturesAllInput = false,
    }

    local function popHandler()
        HandlerStack.removeByName("CityRangeStrike", false)
    end

    local function commitStrike()
        local c = resolveCity(ownerID, cityID)
        if c == nil then
            popHandler()
            return
        end
        local cx, cy = Cursor.position()
        if cx == nil then
            popHandler()
            return
        end
        if not c:CanRangeStrikeAt(cx, cy, true, true) then
            speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"))
            return
        end
        -- Engine uses GAMEMESSAGE_DO_TASK / TASK_RANGED_ATTACK against the
        -- currently selected-cities list (see WorldView.lua:519). The
        -- activation flow selected the city before entering this mode,
        -- so the task targets the right attacker.
        Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_RANGED_ATTACK, cx, cy)
        popHandler()
    end

    local noop = function() end
    self.bindings = {
        bind(Keys.VK_SPACE, MOD_NONE, function()
            local cx, cy = Cursor.position()
            if cx == nil then
                return
            end
            speakInterrupt(targetAnnouncement(Map.GetPlot(cx, cy)))
        end, "Target preview"),
        bind(Keys.VK_RETURN, MOD_NONE, commitStrike, "Commit strike"),
        bind(Keys.VK_ESCAPE, MOD_NONE, function()
            popHandler()
            speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CANCELED"))
        end, "Cancel"),
        -- Alt+QAZEDC no-ops: Baseline binds these to direct-move, which
        -- would move a unit while the engine holds CITY_RANGE_ATTACK
        -- interface mode. Match UnitTargetMode's block pattern.
        bind(Keys.Q, MOD_ALT, noop, "Block direct-move NW"),
        bind(Keys.E, MOD_ALT, noop, "Block direct-move NE"),
        bind(Keys.A, MOD_ALT, noop, "Block direct-move W"),
        bind(Keys.D, MOD_ALT, noop, "Block direct-move E"),
        bind(Keys.Z, MOD_ALT, noop, "Block direct-move SW"),
        bind(Keys.C, MOD_ALT, noop, "Block direct-move SE"),
    }
    self.helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_MOVE",
            description = "TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_MOVE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_PREVIEW",
            description = "TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_PREVIEW",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_COMMIT",
            description = "TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_COMMIT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_CANCEL",
            description = "TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_CANCEL",
        },
    }

    self.onActivate = function()
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"))
        -- initialTarget was resolved at entry and used as the gate for
        -- whether to push at all, so we can jump directly without re-
        -- scanning. If it has moved / died in the frame between entry
        -- and push, Cursor.jumpTo's scope guard will reject and return
        -- an edge string, which we skip speaking.
        local tileSpeech = Cursor.jumpTo(initialTarget:GetX(), initialTarget:GetY())
        if tileSpeech ~= nil and tileSpeech ~= "" then
            SpeechPipeline.speakQueued(tileSpeech)
        end
    end

    self.onDeactivate = function()
        civvaccess_shared.mapScope = nil
        civvaccess_shared.mapAnnouncer = nil
        ScannerNav.invalidate()
        UI.ClearSelectedCities()
        -- Return to SELECTION so the engine exits CITY_RANGE_ATTACK. Esc,
        -- commit, and any external pop all land here.
        UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)
    end

    -- Install hooks before push so onActivate's Cursor.jumpTo sees them.
    -- HandlerStack.push runs onActivate before recording; if it throws,
    -- push returns false and onDeactivate never fires, so we have to roll
    -- back the hooks and the engine mode manually. Mirrors pushHexMap.
    civvaccess_shared.mapScope = scope
    civvaccess_shared.mapAnnouncer = targetAnnouncement
    ScannerNav.invalidate()

    local pushed = HandlerStack.push(self)
    if not pushed then
        abandonEntry()
    end
end

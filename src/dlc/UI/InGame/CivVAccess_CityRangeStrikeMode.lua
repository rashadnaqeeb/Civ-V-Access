-- City-ranged-strike target picker. Pushed above Baseline / Scanner after
-- the city screen closes and the engine enters INTERFACEMODE_CITY_RANGE_ATTACK.
-- Structurally a sibling to UnitTargetMode: free Q/E/A/D/Z/C cursor movement
-- via Baseline (no mapScope -- the cursor roams the whole map and Baseline's
-- per-tile speech reads what's there), Space speaks a strike-specific preview
-- ("out of range" or target identity), Enter commits, Esc cancels. Alt+QAZEDC
-- is swallowed to block Baseline's direct-move while the engine holds an
-- attack interface mode.
--
-- CanRangeStrikeNow gates the hub item, so at least one valid target exists
-- on entry. Cursor is jumped to a nearby valid target as a starting point;
-- from there the user navigates freely and Space tells them whether each
-- plot is strikeable. The commit-time CanRangeStrikeAt check is the
-- authoritative validity gate; a stray Enter on an invalid plot speaks
-- "cannot strike" and stays in the mode.
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

-- Defender unit on the plot the city would actually strike. Mirrors the
-- engine's getBestDefender call at CvCity.cpp:14425 (canRangedStrikeTarget):
-- at-war filter, civilians allowed (cities accept workers / settlers /
-- great people as ranged targets). bTestPotentialEnemy stays off because
-- the gate it triggers routes through isPotentialEnemy, a Firaxis stub
-- that always returns false and would drop every defender. The 7th arg
-- (bNoncombatAllowed) is the engine fork's CvLuaPlot extension; the
-- vanilla binding stops at bTestCanMove and would silently miss civilians.
local function topStrikableTargetAt(plot)
    if plot == nil then
        return nil
    end
    return plot:GetBestDefender(-1, Game.GetActivePlayer(), nil, 1, 0, 0, 1)
end

-- Diagnostic walk for a city strike attempt at (tx, ty). Returns nil if
-- the strike is legal (caller should speak the preview / commit), or a
-- TXT key naming the specific failure reason. Mirrors UnitTargetMode's
-- commitFailureReason pattern: instead of a blanket "cannot strike",
-- drill into the same gates the engine's canRangeStrikeAt walks
-- (CvCity.cpp:14299) so the user hears why -- range, visibility, LoS
-- (when CAN_CITY_USE_INDIRECT_FIRE is off), city-on-city ban, no defender.
local function strikeFailureReason(city, plot, tx, ty)
    if plot == nil then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE")
    end
    if city:CanRangeStrikeAt(tx, ty) then
        return nil
    end
    local team = Players[city:GetOwner()]:GetTeam()
    local cityX, cityY = city:GetX(), city:GetY()
    if Map.PlotDistance(cityX, cityY, tx, ty) > GameDefines.CITY_ATTACK_RANGE then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE")
    end
    if not plot:IsVisible(team, Game.IsDebugMode()) then
        return Text.key("TXT_KEY_CIVVACCESS_TARGET_UNSEEN")
    end
    local indirectFireOn = (GameDefines.CAN_CITY_USE_INDIRECT_FIRE or 0) ~= 0
    if not indirectFireOn and not city:Plot():HasLineOfSight(plot, team) then
        return Text.key("TXT_KEY_CIVVACCESS_TARGET_UNSEEN")
    end
    if topStrikableTargetAt(plot) == nil then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
    end
    -- Fall-through covers the city-on-city ban (CvCity.cpp:14342 rejects
    -- when target plot is a city) and any other engine reason we haven't
    -- modeled. Generic "cannot strike" rather than inventing a specific
    -- string for an edge case.
    return Text.key("TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE")
end

local function targetAnnouncement(city, plot, x, y)
    local reason = strikeFailureReason(city, plot, x, y)
    if reason ~= nil then
        return reason
    end
    local unit = topStrikableTargetAt(plot)
    if unit == nil then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE")
    end
    return CitySpeech.rangedPreview(city, unit, nil)
end

-- Initial landing target: first plot inside the city's max strike range
-- (3 hexes covers policy-bumped cities; CanRangeStrikeAt filters the rest).
-- Iterates by expanding ring so the first match is spatially close to the
-- city rather than whatever the iteration order would otherwise pick.
-- Convenience-only -- nil result is fine, the cursor just stays where the
-- user was and they can roam to find a target on their own.
local function findFirstTarget(city)
    local cx, cy = city:GetX(), city:GetY()
    for r = 1, 3 do
        for dx = -r, r do
            for dy = -r, r do
                local plot = Map.PlotXYWithRangeCheck(cx, cy, dx, dy, r)
                if plot ~= nil then
                    local px, py = plot:GetX(), plot:GetY()
                    if city:CanRangeStrikeAt(px, py) then
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
-- and the deferred enter(), HandlerStack.push returning false). The
-- caller has already put the engine into CITY_RANGE_ATTACK with a
-- selected city, so every bail has to unwind that state or the user is
-- stranded in an attack mode with no binding.
local function abandonEntry()
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

    -- Convenience landing: jump cursor to a nearby valid target on entry
    -- so the user starts on something they can fire at. CanRangeStrikeNow
    -- guarantees at least one target exists; findFirstTarget may still
    -- miss it if the city's range exceeds our 3-hex search box (modded
    -- ranges, etc.), in which case the cursor stays put and the user
    -- navigates manually.
    local initialTarget = findFirstTarget(city)

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
        local reason = strikeFailureReason(c, Map.GetPlot(cx, cy), cx, cy)
        if reason ~= nil then
            speakInterrupt(reason)
            return
        end
        -- Re-select the city right before sending. The engine's late-firing
        -- UnitSelectionChanged from CityScreenClosed (it re-selects whatever
        -- unit was selected before the city screen) clears the engine's
        -- selected-cities list, so by the time the user presses Enter the
        -- list our enter() populated may be empty. SelectedCitiesGameNetMessage
        -- iterates the current list, so an empty list = silent no-op (we'd
        -- still speak "fired" because the local-side checks all pass).
        UI.SelectCity(c)
        -- Engine uses GAMEMESSAGE_DO_TASK / TASK_RANGED_ATTACK against the
        -- currently selected-cities list (see WorldView.lua:519).
        Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_RANGED_ATTACK, cx, cy)
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"))
        popHandler()
    end

    local noop = function() end
    self.bindings = {
        bind(Keys.VK_SPACE, MOD_NONE, function()
            local c = resolveCity(ownerID, cityID)
            if c == nil then
                return
            end
            local cx, cy = Cursor.position()
            if cx == nil then
                return
            end
            speakInterrupt(targetAnnouncement(c, Map.GetPlot(cx, cy), cx, cy))
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
    -- Movement help is provided by Baseline's cursor entry; we don't
    -- duplicate it here. Listing only the strike-specific keys.
    self.helpEntries = {
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
        if initialTarget ~= nil then
            local tileSpeech = Cursor.jumpTo(initialTarget:GetX(), initialTarget:GetY())
            if tileSpeech ~= nil and tileSpeech ~= "" then
                SpeechPipeline.speakQueued(tileSpeech)
            end
        end
    end

    self.onDeactivate = function()
        UI.ClearSelectedCities()
        -- Return to SELECTION so the engine exits CITY_RANGE_ATTACK. Esc,
        -- commit, and any external pop all land here.
        UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)
    end

    local pushed = HandlerStack.push(self)
    if not pushed then
        abandonEntry()
    end
end

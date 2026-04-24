-- Free-roam tile cursor for blind players. Holds (x, y) -- never the live
-- plot userdata, since plot handles can outlive their freshness across
-- engine ticks; we re-resolve via Map.GetPlot at every operation. Owns the
-- owner-prefix diff (last spoken identity); composers handle everything
-- else. Keeps no other state cached -- the project rule says "the only
-- acceptable cache is a live engine handle read at speech time."

Cursor = {}

local _x, _y = nil, nil
-- Not a violation of the "never cache game state" rule: this holds "what the
-- user last heard from us," not a copy of any live game fact. The prefix diff
-- IS the feature, and a diff inherently needs a retained previous value --
-- there is no live source of "the announcement I already made." Re-querying
-- the previous tile's current ownership on each move would be strictly worse:
-- if an owner changed between two cursor steps, the player still needs to
-- hear the new name, which only happens by comparing against the retained
-- announced identity rather than against a freshly-read (and now-changed)
-- value that would match the new tile and silently suppress the prefix.
local _lastOwnerIdentity = nil

local function plotHere()
    if _x == nil then
        return nil
    end
    return Map.GetPlot(_x, _y)
end

local function setCursor(plot)
    _x, _y = plot:GetX(), plot:GetY()
    -- Flag 0 is the standard animated pan used by every base-game
    -- interactive camera move (unit select, city pan, diplomacy pan).
    -- Flag 2 appears in one spot (InGame.lua's city-screen exit) and
    -- empirically does not produce a pan from this Context.
    UI.LookAt(plot, 0)
end

-- Capital of the active player. Returns nil during the brief window before
-- the first city is settled; callers must handle nil. Re-resolved on every
-- call rather than cached -- the city ID can change (capture, destruction)
-- and a stale ID would silently stop matching the player's actual capital.
local function capitalPlot()
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return nil
    end
    local capital = player:GetCapitalCity()
    if capital == nil then
        return nil
    end
    return capital:Plot()
end

-- ===== Initialization =====
-- Pick the selected unit's plot if any, otherwise the capital. Boot.lua
-- calls this from the LoadScreenClose handler -- this is the "actually in
-- a game" signal; running earlier would land in pre-game-setup state.
function Cursor.init()
    local target = nil
    local unit = UI.GetHeadSelectedUnit()
    if unit ~= nil then
        target = unit:GetPlot()
    end
    if target == nil then
        target = capitalPlot()
    end
    if target == nil then
        Log.warn("Cursor.init: no selected unit and no capital; cursor unset until first move attempt")
        return
    end
    setCursor(target)
    _lastOwnerIdentity = nil
end

-- ===== Movement =====
-- Visibility is a separate axis from ownership: unexplored tiles speak the
-- "unexplored" token on every entry (a silent move loses the user across a
-- block of fog of war), fogged tiles get a leading "fog" marker over the
-- stale GetRevealed* data, and visible tiles read fully. The owner-identity
-- diff only tracks real ownership states (unclaimed / civ / city); it is
-- not touched while unexplored, so an Arabia → unexplored → Arabia walk
-- doesn't re-fire the prefix on re-entry.
local function announceForMove(plot)
    local cueEnabled = AudioCueMode.isCueEnabled()
    local cueOnly = AudioCueMode.isCueOnly()

    if cueEnabled then
        PlotAudio.emit(plot)
    end

    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    if not plot:IsRevealed(team, debug) then
        -- Unexplored always speaks regardless of mode: the cue palette has
        -- no "unexplored" sound, and silence would be indistinguishable
        -- from a broken cue pipeline.
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED") .. "."
    end

    local spoken, identity = PlotSections.ownerIdentity(plot)
    local glance = PlotComposers.glance(plot, { cueOnly = cueOnly })
    local prefix = ""
    if identity ~= _lastOwnerIdentity then
        _lastOwnerIdentity = identity
        prefix = spoken .. ". "
    end
    if glance == "" then
        if prefix == "" then
            return ""
        end
        return spoken .. "."
    end
    return prefix .. glance .. "."
end

-- Scoped-mode hooks. A screen that restricts the cursor to a subset of
-- the map (CityView's hex sub-handler, future Phase 8 range-strike target
-- picker) installs civvaccess_shared.mapScope as `(x, y) -> bool`, and
-- optionally civvaccess_shared.mapAnnouncer as `(plot) -> string`. The
-- hooks are generic -- Cursor doesn't know about CityView or ranges.
-- Both hooks read live on every call; no caching. The "cache" exception
-- in the project rules is about game state, not mod-installed callables.
function Cursor.move(direction)
    if _x == nil then
        Log.warn("Cursor.move before init; ignoring")
        return ""
    end
    local next = Map.PlotDirection(_x, _y, direction)
    if next == nil then
        return Text.key("TXT_KEY_CIVVACCESS_EDGE_OF_MAP")
    end
    local scope = civvaccess_shared.mapScope
    if scope ~= nil and not scope(next:GetX(), next:GetY()) then
        return Text.key("TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE")
    end
    setCursor(next)
    local announcer = civvaccess_shared.mapAnnouncer
    if announcer ~= nil then
        return announcer(next)
    end
    return announceForMove(next)
end

-- ===== Orientation =====
-- Direction-string composition lives in HexGeom so every cursor-relative
-- caller (S key here, scanner's End, surveyor) produces byte-identical
-- output. Direction is cursor -> capital: the user hears the bearing
-- they'd travel to reach the capital.
function Cursor.orient()
    if _x == nil then
        Log.warn("Cursor.orient before init")
        return ""
    end
    local cap = capitalPlot()
    if cap == nil then
        -- The design notes a settled session is guaranteed to have a
        -- capital, so the only way here is during the pre-first-settle
        -- window or after losing all cities (the player has lost the
        -- game). Speak "unclaimed" as the closest-meaning token rather
        -- than silently dropping the request.
        return Text.key("TXT_KEY_CIVVACCESS_UNCLAIMED")
    end
    local kx, ky = cap:GetX(), cap:GetY()
    if _x == kx and _y == ky then
        return Text.key("TXT_KEY_CIVVACCESS_AT_CAPITAL")
    end
    return HexGeom.directionString(_x, _y, kx, ky)
end

-- ===== Position accessor / programmatic jump =====
-- Scanner navigation needs to read the cursor's current (x, y) to
-- compute distances and capture the pre-jump cell for Backspace.
-- Returns (nil, nil) until Cursor.init has placed the cursor.
function Cursor.position()
    return _x, _y
end

-- Place the cursor at an arbitrary (x, y) that the caller already
-- resolved (scanner's Home key, auto-move-driven cycle jump).
-- Returns the same glance text Cursor.move produces, so the caller
-- can decide whether to speak it (explicit Home) or suppress it
-- (auto-move side-effect during a cycle — the cycle's own
-- announcement already covers for it).
function Cursor.jumpTo(x, y)
    local plot = Map.GetPlot(x, y)
    if plot == nil then
        Log.warn("Cursor.jumpTo: no plot at (" .. tostring(x) .. ", " .. tostring(y) .. ")")
        return ""
    end
    -- Same scope guard as Cursor.move: a scoped mode (hex sub, ranged-strike
    -- target picker) may not have reset pre-jump state on every boundary, so
    -- a scanner Backspace / other programmatic jump could otherwise land the
    -- cursor outside the scope and leave Cursor.move anchored to an unreachable
    -- cell until the user hunts their way back in. Reject here instead.
    local scope = civvaccess_shared.mapScope
    if scope ~= nil and not scope(x, y) then
        return Text.key("TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE")
    end
    setCursor(plot)
    local announcer = civvaccess_shared.mapAnnouncer
    if announcer ~= nil then
        return announcer(plot)
    end
    return announceForMove(plot)
end

-- ===== Detail keys (W and X) =====
local function delegateDetail(composer)
    if _x == nil then
        Log.warn("Cursor detail key before init")
        return ""
    end
    return composer(plotHere())
end

function Cursor.economy()
    return delegateDetail(PlotComposers.economy)
end
function Cursor.combat()
    return delegateDetail(PlotComposers.combat)
end

-- ===== Unit-at-tile (S key) =====
-- Scans plot units with the same visibility filters PlotSectionUnits
-- uses (skip invisible / cargo / air), then prefers the first combat
-- unit and falls back to the first civilian. Civ V is 1UPT so the
-- priority almost always picks the one military; the fallback exists
-- for tiles with only a civilian (worker / settler / great person)
-- and for embarked-in-stack edge cases where the civilian is alone.
local function topUnitAt(plot)
    local team = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    local civilian = nil
    local n = plot:GetNumUnits()
    for i = 0, n - 1 do
        local u = plot:GetUnit(i)
        if
            u ~= nil
            and not u:IsInvisible(team, isDebug)
            and not u:IsCargo()
            and u:GetDomainType() ~= DomainTypes.DOMAIN_AIR
        then
            if u:IsCombatUnit() then
                return u
            end
            if civilian == nil then
                civilian = u
            end
        end
    end
    return civilian
end

function Cursor.unitAtTile()
    if _x == nil then
        Log.warn("Cursor.unitAtTile before init")
        return ""
    end
    local unit = topUnitAt(plotHere())
    if unit == nil then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_NO_UNITS")
    end
    return UnitSpeech.info(unit)
end

-- ===== City info keys (1, 2, 3) =====
local function delegateCity(speechFn)
    if _x == nil then
        Log.warn("Cursor city key before init")
        return ""
    end
    local plot = plotHere()
    if not plot:IsCity() then
        return Text.key("TXT_KEY_CIVVACCESS_NO_CITY")
    end
    return speechFn(plot:GetPlotCity())
end

function Cursor.cityIdentity()
    return delegateCity(CitySpeech.identity)
end
function Cursor.cityDevelopment()
    return delegateCity(CitySpeech.development)
end
function Cursor.cityPolitics()
    return delegateCity(CitySpeech.politics)
end

-- ===== Activation (Enter) =====
-- Delegates to CursorActivate, which gathers the plot's acts-on-Enter
-- entries (city + active-player units), auto-picks when there's one,
-- and pops a BaseMenu picker otherwise. Cursor.lua owns cursor state;
-- CursorActivate owns the "what can Enter do here" fan-out.
function Cursor.activate()
    if _x == nil then
        Log.warn("Cursor.activate before init")
        return
    end
    CursorActivate.run(plotHere())
end

-- Test seam: lets suites reset between cases without exposing the
-- locals. Production never calls this.
function Cursor._reset()
    _x, _y = nil, nil
    _lastOwnerIdentity = nil
end

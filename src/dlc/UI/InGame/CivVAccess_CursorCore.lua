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
    -- Beacons recompute pan / pitch / volume from the cursor as listener.
    -- Cheap (early-returns when no beacons are active) and unconditional
    -- on cue-mode -- spatial audio is its own feature, not a cue-mode
    -- output. Guarded against the pre-Beacons-include window because
    -- setCursor is defined here but called only after LoadScreenClose,
    -- by which point the Beacons global is populated.
    if Beacons ~= nil then
        Beacons.onCursorMove()
    end
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

-- ===== Targetability prefix =====
-- When the engine is in a ranged-attack interface mode (unit ranged strike,
-- airstrike, city ranged strike), prepend an "unseen" or "out of range" tag
-- so the user can tell at cursor-move time whether the current tile would
-- accept a strike. Sighted players read the same answer off the red-overlay
-- and arrow visuals (Bombardment.lua); the engine's CanRangeStrikeAt is
-- their gate, but it requires a valid target on the plot, so we can't use
-- it here -- we want the prefix on every plot, target or not. Geometry
-- check only; no fog-of-war / target-validity reasoning.
--
-- LoS uses Plot:HasLineOfSight (engine fork binding), which calls
-- CvPlot::canSeePlot with the range and facing gates short-circuited so
-- the answer is "is the visibility ray blocked by terrain" alone -- the
-- range axis we report separately as "out of range" via Map.PlotDistance.
-- Air units / IsRangeAttackIgnoreLOS skip the LoS step (engine does the
-- same in canEverRangeStrikeAt). The attacker's own plot returns no
-- prefix (distance 0, LoS trivially true).
local function targetabilityPrefix(plot)
    local mode = UI.GetInterfaceMode()
    local attackerPlot, team, range, ignoresLoS
    if mode == InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK or mode == InterfaceModeTypes.INTERFACEMODE_AIRSTRIKE then
        local unit = UI.GetHeadSelectedUnit()
        if unit == nil then
            -- Engine should have a head-selected unit while one of the unit
            -- ranged interface modes is live; nil here is a state race we
            -- want a Lua.log breadcrumb for rather than swallowing.
            Log.warn("targetabilityPrefix: ranged interface mode " .. tostring(mode) .. " with no head-selected unit")
            return ""
        end
        attackerPlot = unit:GetPlot()
        team = unit:GetTeam()
        range = unit:Range()
        ignoresLoS = unit:GetDomainType() == DomainTypes.DOMAIN_AIR or unit:IsRangeAttackIgnoreLOS()
    elseif mode == InterfaceModeTypes.INTERFACEMODE_CITY_RANGE_ATTACK then
        local city = UI.GetHeadSelectedCity()
        if city == nil then
            Log.warn("targetabilityPrefix: CITY_RANGE_ATTACK with no head-selected city")
            return ""
        end
        attackerPlot = city:Plot()
        team = Players[city:GetOwner()]:GetTeam()
        range = GameDefines.CITY_ATTACK_RANGE
        -- Cities skip LoS when CAN_CITY_USE_INDIRECT_FIRE is set; BNW's
        -- default flips it on (1) so any in-range visible plot is fair game,
        -- base / G&K leave it off (0) and need the Bresenham. Read at
        -- runtime so a mod-tweaked GlobalDefines value flows through.
        ignoresLoS = (GameDefines.CAN_CITY_USE_INDIRECT_FIRE or 0) ~= 0
    else
        return ""
    end
    -- Fog markers in the glance already convey "you can't strike here," so
    -- skip on non-visible plots (fogged or unexplored) to avoid duplicating
    -- the signal. The engine's canEverRangeStrikeAt also gates on isVisible
    -- before the LoS Bresenham, so this matches the engine's own answer.
    if not plot:IsVisible(team, Game.IsDebugMode()) then
        return ""
    end
    local ax, ay = attackerPlot:GetX(), attackerPlot:GetY()
    local tx, ty = plot:GetX(), plot:GetY()
    if ax == tx and ay == ty then
        return ""
    end
    if not ignoresLoS and not attackerPlot:HasLineOfSight(plot, team) then
        return Text.key("TXT_KEY_CIVVACCESS_TARGET_UNSEEN") .. ", "
    end
    if Map.PlotDistance(ax, ay, tx, ty) > range then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE") .. ", "
    end
    return ""
end

-- ===== Movement =====
-- Visibility is a separate axis from ownership: unexplored tiles speak the
-- "unexplored" token on every entry (a silent move loses the user across a
-- block of fog of war), fogged tiles get a leading "fog" marker over the
-- stale GetRevealed* data, and visible tiles read fully. The owner-identity
-- diff only tracks real ownership states (unclaimed / civ / city); it is
-- not touched while unexplored, so an Arabia → unexplored → Arabia walk
-- doesn't re-fire the prefix on re-entry.
-- prevPlot is supplied by Cursor.move (the cell we just left) so PlotAudio
-- can resolve a river / bridge crossing on the edge between the two. Jumps
-- (Cursor.jumpTo, scanner Home, auto-move) leave it nil; the crossing layer
-- only fires for actual cursor steps.
local function announceForMove(plot, prevPlot)
    local cueEnabled = AudioCueMode.isCueEnabled()
    local cueOnly = AudioCueMode.isCueOnly()

    if cueEnabled then
        PlotAudio.emit(plot, prevPlot)
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
    local ownerPrefix = ""
    -- borderAlwaysAnnounce flips the prefix from "fires on crossings only"
    -- (the _lastOwnerIdentity diff) to "fires on every move into civ-owned
    -- territory; silent on unclaimed". The diff state is still kept in sync
    -- so flipping the toggle off mid-game doesn't immediately re-fire on
    -- the next step.
    if civvaccess_shared.borderAlwaysAnnounce then
        if identity ~= "unclaimed" then
            ownerPrefix = spoken .. ". "
        end
        _lastOwnerIdentity = identity
    elseif identity ~= _lastOwnerIdentity then
        _lastOwnerIdentity = identity
        ownerPrefix = spoken .. ". "
    end
    -- Targetability tag fires every move while a ranged interface mode is
    -- active (no diff suppression -- the user needs to know where each tile
    -- stands, not just on changes). Composed before the owner-identity
    -- prefix so the fastest-changing fact ("can I strike here") leads.
    local targetPrefix = targetabilityPrefix(plot)
    if glance == "" then
        if ownerPrefix ~= "" then
            -- ownerPrefix ends in ". " for concatenation with glance; with
            -- no glance to lead into, strip the trailing space so the
            -- sentence terminates cleanly.
            return targetPrefix .. ownerPrefix:sub(1, -2)
        end
        if targetPrefix ~= "" then
            -- Featureless plot (open ocean, mostly) inside a ranged mode:
            -- the targetability tag is the only thing the player would
            -- otherwise hear. Strip the trailing ", " since there's
            -- nothing for it to lead into.
            return targetPrefix:sub(1, -3) .. "."
        end
        return ""
    end
    return targetPrefix .. ownerPrefix .. glance .. "."
end

-- Wrap a move/jump glance with the user's cursor-coord setting. Read
-- civvaccess_shared.cursorCoordMode live so Settings flips take effect on
-- the next keystroke without a re-install. Off (default) and pre-capital
-- (HexGeom returns "") both leave the glance untouched. A nil or empty
-- glance is preserved as-is: scoped-mode announcers (CityView) use that
-- as their "stay silent" signal, and overlaying a bare coord would break
-- the contract. Edge-of-map and edge-of-scope short-circuit Cursor.move
-- before this point; they don't get coords either because the cursor
-- didn't move.
local function withCoords(plot, glance)
    local mode = civvaccess_shared.cursorCoordMode
    if mode == nil or mode == "off" then
        return glance
    end
    if glance == nil or glance == "" then
        return glance
    end
    local coord = HexGeom.coordinateString(plot:GetX(), plot:GetY())
    if coord == "" then
        return glance
    end
    if mode == "prepend" then
        return coord .. ". " .. glance
    end
    return glance .. " " .. coord .. "."
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
    local prev = Map.GetPlot(_x, _y)
    setCursor(next)
    local announcer = civvaccess_shared.mapAnnouncer
    local glance
    if announcer ~= nil then
        glance = announcer(next)
    else
        glance = announceForMove(next, prev)
    end
    return withCoords(next, glance)
end

-- ===== Coordinates =====
-- Cursor position expressed as (x, y) relative to the active player's
-- original capital. HexGeom owns the math (offset-correction + wrap
-- folding) so every coordinate caller -- this S+Shift bind, the optional
-- cursor-move prefix, and the scanner's optional coord append -- speaks
-- byte-identical numbers. Empty return before the original capital
-- exists; the binding speaks nothing in that window.
function Cursor.coordinates()
    if _x == nil then
        Log.warn("Cursor.coordinates before init")
        return ""
    end
    return HexGeom.coordinateString(_x, _y)
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
    local glance
    if announcer ~= nil then
        glance = announcer(plot)
    else
        glance = announceForMove(plot)
    end
    return withCoords(plot, glance)
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
    local n = plot:GetNumLayerUnits(-1)
    for i = 0, n - 1 do
        local u = plot:GetLayerUnit(i, -1)
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

-- ===== City info keys (1, 2, 3, 4) =====
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
function Cursor.cityReligion()
    return delegateCity(CitySpeech.religion)
end
function Cursor.cityDiplomatic()
    return delegateCity(CitySpeech.diplomatic)
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

-- ===== Civilopedia picker (Ctrl+I) =====
-- Opens the pedia for everything on the plot that has an article
-- (dedup'd). Delegates to CursorPedia for the enumeration and picker
-- layout, same split-of-responsibility as activate / CursorActivate.
function Cursor.pedia()
    if _x == nil then
        Log.warn("Cursor.pedia before init")
        return
    end
    CursorPedia.run(plotHere())
end

-- Test seam: lets suites reset between cases without exposing the
-- locals. Production never calls this.
function Cursor._reset()
    _x, _y = nil, nil
    _lastOwnerIdentity = nil
end

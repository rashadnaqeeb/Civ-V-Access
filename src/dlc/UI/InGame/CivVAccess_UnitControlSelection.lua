-- Unit selection / cycling / info-readout half of the unit-control split.
-- Owns the two cycle bindings (./,) and their Ctrl variants (whole-list
-- cycling that ignores the engine's ReadyToSelect filter), the ? info
-- key, and the Ctrl+? recenter-cursor-on-selected-unit binding. Also
-- owns the UnitSelectionChanged listener that announces newly selected
-- units, including the user-vs-engine origin discriminator.
--
-- Speech policy: user-initiated selection (cycle keys) interrupts;
-- engine-driven selection (turn start, unit death, end of move/combat
-- reselection) queues. UnitSelectionChanged fires for both, so cycle
-- sites stamp a short-lived "user-initiated" timestamp the listener
-- consumes if fresh. Time-based staleness (USER_SELECTION_WINDOW_SECONDS)
-- handles the case where the engine drops the selection request
-- (Game.CycleUnits with no eligible target) so the flag doesn't leak
-- into a later engine-driven selection.

UnitControlSelection = {}

local MOD_NONE = 0
local MOD_CTRL = 2

-- Windows VK codes for ',' '.' '/' -- Civ V's Keys table exposes
-- VK_OEM_3 / VK_OEM_PLUS / VK_OEM_MINUS but not these three.
local VK_OEM_COMMA = 188
local VK_OEM_PERIOD = 190
local VK_OEM_2 = 191

local USER_SELECTION_WINDOW_SECONDS = 0.1
local _userSelectionAt = -math.huge

function UnitControlSelection.markUserInitiatedSelection()
    _userSelectionAt = os.clock()
end

local function consumeUserInitiatedSelection()
    if (os.clock() - _userSelectionAt) < USER_SELECTION_WINDOW_SECONDS then
        _userSelectionAt = -math.huge
        return true
    end
    return false
end

local speakInterrupt = SpeechPipeline.speakInterrupt
local speakQueued = SpeechPipeline.speakQueued

local function selectedUnit()
    return UI.GetHeadSelectedUnit()
end

-- Plain . / , go through Game.CycleUnits, which walks the engine's own
-- per-player list (CvUnitCycler) and applies its ReadyToSelect filter --
-- units that have moved, are fortified, sleeping, or automated are
-- skipped. Forward=true is the base-game "CycleLeft" button (the layout
-- has left = "go to next", right = "go back"); we pass through unchanged.
function UnitControlSelection.cycleAll(forward)
    UnitControlSelection.markUserInitiatedSelection()
    Game.CycleUnits(true, forward and true or false, false)
end

-- Ctrl+. / Ctrl+, walk Game.GetCycleUnits(), the engine fork's exposure
-- of CvPlayer::GetUnitCycler(). Order is whatever the engine has built;
-- it persists across creation/destruction the same way as the engine's
-- own next-unit binding. We drop the ReadyToSelect filter so every
-- active-player unit is a target (the whole point of the Ctrl variant
-- is "show me everyone, including units I've already moved").
function UnitControlSelection.cycleAllUnits(forward)
    UnitControlSelection.markUserInitiatedSelection()
    local list = Game.GetCycleUnits()
    local n = #list
    if n == 0 then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"))
        return
    end
    local activePlayer = Game.GetActivePlayer()
    local player = Players[activePlayer]
    if player == nil then
        return
    end
    local current = selectedUnit()
    local startIdx
    if current ~= nil and current:GetOwner() == activePlayer then
        local cid = current:GetID()
        for i, id in ipairs(list) do
            if id == cid then
                startIdx = i
                break
            end
        end
    end
    -- Engine's Cycle: when current isn't in the list, step starts at the
    -- head (forward) or tail (backward).
    local idx
    if startIdx == nil then
        idx = forward and 1 or n
    elseif forward then
        idx = startIdx + 1
        if idx > n then
            idx = 1
        end
    else
        idx = startIdx - 1
        if idx < 1 then
            idx = n
        end
    end
    -- Walk until a live unit is found. Bounded by n so a list with a
    -- stale ID (engine cycler hasn't pruned a just-killed unit) doesn't
    -- spin.
    for _ = 1, n do
        local unit = player:GetUnitByID(list[idx])
        if unit ~= nil then
            UI.SelectUnit(unit)
            return
        end
        if forward then
            idx = idx + 1
            if idx > n then
                idx = 1
            end
        else
            idx = idx - 1
            if idx < 1 then
                idx = n
            end
        end
    end
end

-- Info key: prepend the cursor-to-unit direction string so the user
-- hears "where the selected unit sits relative to my current cursor"
-- before the unit readout. HexGeom.directionString returns "" when the
-- cursor is on the unit's plot (zero delta), in which case we skip the
-- prefix and speak info unchanged.
local function speakInfo()
    local unit = selectedUnit()
    if unit == nil then
        return
    end
    local info = UnitSpeech.info(unit)
    local cx, cy = Cursor.position()
    if cx ~= nil then
        local dir = HexGeom.directionString(cx, cy, unit:GetX(), unit:GetY())
        if dir ~= "" then
            info = dir .. ", " .. info
        end
    end
    speakInterrupt(info)
end

-- Counterpart to onUnitSelectionChanged's auto-jump: when the user has
-- wandered the cursor away from the unit they were last working with,
-- snap it back without forcing a re-cycle. Silent on no-unit, matching
-- every other selection-keyed binding in this file.
local function recenterOnUnit()
    local unit = selectedUnit()
    if unit == nil then
        return
    end
    speakInterrupt(Cursor.jumpTo(unit:GetX(), unit:GetY()))
end

local function onUnitSelectionChanged(playerID, unitID, _hexI, _hexJ, _hexK, isSelected)
    if not isSelected then
        return
    end
    if playerID ~= Game.GetActivePlayer() then
        return
    end
    -- Skip when the city-strike picker is on top. The engine's
    -- CityScreenClosed re-selects the previously-selected unit on a
    -- delayed tick, and announcing it here would steal focus from the
    -- strike target the user just landed on. Gate on the handler-stack
    -- name rather than UI.GetInterfaceMode: the engine briefly bounces
    -- out of CITY_RANGE_ATTACK on entry (Bombardment.OnCityInfoDirty
    -- reverts when the unit-select clears the engine's city selection),
    -- and the late unit-select event tends to land during that gap, so
    -- a mode check would be racy.
    local top = HandlerStack.active()
    if top ~= nil and top.name == "CityRangeStrike" then
        return
    end
    -- If target mode is active for a different unit, unwind it. Covers
    -- unit cycling (. / ,), mouse reselect, and actor death flipping
    -- selection to another unit. Same-unit re-selects leave it in place.
    local targetActorID = UnitTargetMode.currentActorID()
    if targetActorID ~= nil and targetActorID ~= unitID then
        HandlerStack.removeByName("UnitTargetMode", false)
    end
    local player = Players[playerID]
    if player == nil then
        return
    end
    local unit = player:GetUnitByID(unitID)
    if unit == nil then
        return
    end
    local prevX, prevY = Cursor.position()
    local text = UnitSpeech.selection(unit, prevX, prevY)
    if consumeUserInitiatedSelection() then
        speakInterrupt(text)
    else
        speakQueued(text)
    end
    -- Settings toggle: when off, suppress the auto-jump so the cursor
    -- stays put. The direction string baked into the selection text above
    -- already tells the player where the new selection sits relative to
    -- the cursor's current position. The explicit "speak current unit"
    -- hotkey jumps independently and stays live so the player can still
    -- recenter on demand.
    if not civvaccess_shared.cursorFollowsSelection then
        return
    end
    Cursor.jumpTo(unit:GetX(), unit:GetY())
end

local bind = HandlerStack.bind

function UnitControlSelection.getBindings()
    local bindings = {
        bind(VK_OEM_PERIOD, MOD_NONE, function()
            UnitControlSelection.cycleAll(true)
        end, "Next unit"),
        bind(VK_OEM_COMMA, MOD_NONE, function()
            UnitControlSelection.cycleAll(false)
        end, "Previous unit"),
        bind(VK_OEM_PERIOD, MOD_CTRL, function()
            UnitControlSelection.cycleAllUnits(true)
        end, "Next unit (including acted)"),
        bind(VK_OEM_COMMA, MOD_CTRL, function()
            UnitControlSelection.cycleAllUnits(false)
        end, "Previous unit (including acted)"),
        bind(VK_OEM_2, MOD_NONE, speakInfo, "Unit info"),
        bind(VK_OEM_2, MOD_CTRL, recenterOnUnit, "Recenter cursor on selected unit"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

-- Registers a fresh listener on every call (per CLAUDE.md's no-install-
-- once-guards rule for load-game-from-game survival).
function UnitControlSelection.installListeners()
    if Events == nil then
        Log.error("UnitControlSelection.installListeners: Events table missing")
        return
    end
    if Events.UnitSelectionChanged ~= nil then
        Events.UnitSelectionChanged.Add(onUnitSelectionChanged)
    else
        Log.warn("UnitControlSelection: Events.UnitSelectionChanged missing")
    end
end

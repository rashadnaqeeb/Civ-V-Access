-- Tests for DirectionalScan: the line-of-tiles reader entered with plain L.
-- scanOne / scanComposite are pure (they read the map and return spoken lines
-- without speaking), so they're exercised directly against fakePlot fixtures
-- and a Map.PlotDirection mock. The mode wiring (push, Escape, a direction key
-- voicing a scan) is exercised against the real HandlerStack plus speech /
-- cursor stubs.

local T = require("support")
local M = {}

-- Captured speech: speakLines feeds the real SpeechPipeline in-game; here a
-- stub records interrupt / queued calls so tests can assert the voiced stream.
local spoken

-- Coordinate-keyed Map.PlotDirection stub. Idempotent (no per-call counters)
-- so glance's incidental neighbor lookups -- PlotSectionRiver probes adjacent
-- plots in NW / NE / W -- don't desync a ray's outward walk. A query for an
-- unregistered (x, y, dir) returns nil, which the scan reads as the map edge.
local mapReg

local function resetMap()
    mapReg = {}
    Map.PlotDirection = function(x, y, dir)
        return mapReg[x .. "," .. y .. "," .. dir]
    end
end

-- Register a ray of plots walking `dir` outward from (startX, startY). Each
-- plot must carry unique coordinates (set via fakePlot {x=, y=}) so the walk
-- transitions resolve deterministically.
local function registerRay(startX, startY, dir, plots)
    local cx, cy = startX, startY
    for _, p in ipairs(plots) do
        mapReg[cx .. "," .. cy .. "," .. dir] = p
        cx, cy = p:GetX(), p:GetY()
    end
end

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitSpeech.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_RecommendationsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_WaypointsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionUnits.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionRiver.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotComposers.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_AudioCueMode.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotAudio.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_DirectionalScan.lua")

    HandlerStack._reset()
    HandlerStack.commonHelpEntries = {}

    audio._reset()
    civvaccess_shared.plotAudioHandles = nil
    civvaccess_shared.audioCueMode = AudioCueMode.MODE_SPEECH
    civvaccess_shared.borderAlwaysAnnounce = nil
    civvaccess_shared.scannerRadius = nil
    civvaccess_shared.dirScanRadius = nil
    civvaccess_shared.verbosity = false

    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsDebugMode = function()
        return false
    end

    Players = {}
    Teams = { [0] = T.fakeTeam() }
    GameInfo = {}
    GameInfo.Terrains = {}
    GameInfo.Features = {}
    GameInfo.Resources = {}
    GameInfo.Improvements = {}
    GameInfo.Routes = {}
    GameInfo.Builds = function()
        return function()
            return nil
        end
    end
    GameInfo.Technologies = {}

    Map.PlotDirection = function()
        return nil
    end
    Map.GetPlot = function()
        return nil
    end
    Map.IsWrapX = function()
        return false
    end

    UI.LookAt = function(_plot, _flag) end
    UI.GetHeadSelectedUnit = function()
        return nil
    end
    UI.GetHeadSelectedCity = function()
        return nil
    end
    UI.GetInterfaceMode = function()
        return InterfaceModeTypes.INTERFACEMODE_SELECTION
    end
    UI.CanSelectionListWork = nil
    UI.CanSelectionListFound = nil

    -- Speech + cursor stubs. DirectionalScan resolves both globals at call
    -- time, so replacing the tables here routes the mode's voicing through the
    -- capture without loading the real pipeline / cursor.
    spoken = {}
    SpeechPipeline = {
        speakInterrupt = function(text)
            spoken[#spoken + 1] = { interrupt = true, text = text }
        end,
        speakQueued = function(text)
            spoken[#spoken + 1] = { interrupt = false, text = text }
        end,
        stop = function() end,
    }
    Cursor = {
        position = function()
            return 0, 0
        end,
    }

    resetMap()
end

local function plains(opts)
    opts = opts or {}
    opts.terrain = opts.terrain or 1
    return T.fakePlot(opts)
end

local function joined(lines)
    return table.concat(lines, " || ")
end

local function findBinding(handler, key)
    for _, b in ipairs(handler.bindings) do
        if b.key == key then
            return b
        end
    end
    return nil
end

-- ===== scanOne =====

function M.test_scan_one_reads_each_step_then_summarizes()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, {
        plains({ x = 1, y = 0 }),
        plains({ x = 2, y = 0 }),
        plains({ x = 3, y = 0 }),
    })
    local lines = DirectionalScan.scanOne(0, 0, DirectionTypes.DIRECTION_EAST, 3)
    -- Three step lines plus the closing summary.
    T.eq(#lines, 4, "three steps plus summary")
    local text = joined(lines)
    T.truthy(text:find("Plains", 1, true), "each revealed tile names its terrain: " .. text)
    T.truthy(lines[1]:find("east", 1, true), "step line carries the heading: " .. lines[1])
    T.truthy(lines[1]:find("1", 1, true), "step line carries the distance: " .. lines[1])
    T.truthy(lines[4]:find("3 tiles scanned", 1, true), "summary counts the reach: " .. lines[4])
end

function M.test_scan_one_stops_at_map_edge()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    -- Only one tile exists east; step two falls off the map.
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, { plains({ x = 1, y = 0 }) })
    local lines = DirectionalScan.scanOne(0, 0, DirectionTypes.DIRECTION_EAST, 3)
    local text = joined(lines)
    T.truthy(text:find("edge of map", 1, true), "edge step is announced: " .. text)
    T.truthy(text:find("1 tile scanned", 1, true), "truncated summary counts tiles read: " .. text)
    -- step 1 line, edge line, truncated summary -- no further steps.
    T.eq(#lines, 3, "scan stops at the edge")
end

function M.test_scan_one_unexplored_tile_hides_detail()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, {
        plains({ x = 1, y = 0, revealed = false }),
    })
    local lines = DirectionalScan.scanOne(0, 0, DirectionTypes.DIRECTION_EAST, 1)
    local text = joined(lines)
    T.truthy(text:find("unexplored", 1, true), "never-seen tile reads unexplored: " .. text)
    T.falsy(text:find("Plains", 1, true), "unexplored tile must not leak terrain: " .. text)
end

function M.test_scan_one_stops_at_first_unexplored()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    -- A revealed tile, then fog, then another revealed tile the ray must never
    -- reach: the scan stops at the fog boundary.
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, {
        plains({ x = 1, y = 0 }),
        plains({ x = 2, y = 0, revealed = false }),
        plains({ x = 3, y = 0 }),
    })
    local lines = DirectionalScan.scanOne(0, 0, DirectionTypes.DIRECTION_EAST, 3)
    local text = joined(lines)
    T.truthy(text:find("unexplored", 1, true), "the fog tile is announced: " .. text)
    T.truthy(text:find("fog reached", 1, true), "a fog summary explains the short scan: " .. text)
    T.falsy(text:find("east 3", 1, true), "the ray stops at fog and never reads the tile beyond: " .. text)
    -- step 1, fog step 2, fog summary -- tile 3 is never read.
    T.eq(#lines, 3, "scan stops at the first unexplored tile")
end

function M.test_scan_one_prefixes_owner_on_border_crossing()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    Players[3] = T.fakePlayer({ shortDesc = "Arabia", adj = "Arabian" })
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, {
        plains({ x = 1, y = 0, owner = -1 }),
        plains({ x = 2, y = 0, owner = 3 }),
    })
    local lines = DirectionalScan.scanOne(0, 0, DirectionTypes.DIRECTION_EAST, 2)
    T.falsy(lines[1]:find("Arabia", 1, true), "unclaimed first tile names no owner: " .. lines[1])
    T.truthy(lines[2]:find("Arabia", 1, true), "crossing into Arabia names the civ: " .. lines[2])
end

function M.test_scan_announces_owner_from_cursor_tile()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    Players[3] = T.fakePlayer({ shortDesc = "Arabia", adj = "Arabian" })
    -- The cursor sits on unclaimed land; the first tile east belongs to Arabia.
    -- Seeding the owner comparison from the cursor tile makes the very first
    -- step name the civilization, which an unseeded scan would have missed.
    Map.GetPlot = function()
        return plains({ x = 0, y = 0, owner = -1 })
    end
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, {
        plains({ x = 1, y = 0, owner = 3 }),
    })
    DirectionalScan.enterMode()
    spoken = {}
    findBinding(HandlerStack.active(), Keys.D).fn()
    T.truthy(
        spoken[1].text:find("Arabia", 1, true),
        "first step names the civ crossed into from the cursor tile: " .. spoken[1].text
    )
end

-- ===== scanComposite =====

function M.test_scan_composite_banners_then_interleaves_rays()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    registerRay(0, 0, DirectionTypes.DIRECTION_NORTHWEST, {
        plains({ x = -1, y = 1 }),
        plains({ x = -2, y = 2 }),
    })
    registerRay(0, 0, DirectionTypes.DIRECTION_NORTHEAST, {
        plains({ x = 1, y = 1 }),
        plains({ x = 2, y = 2 }),
    })
    local lines = DirectionalScan.scanComposite(
        0,
        0,
        DirectionTypes.DIRECTION_NORTHWEST,
        DirectionTypes.DIRECTION_NORTHEAST,
        2,
        "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_N"
    )
    -- banner, NW1, NE1, NW2, NE2, summary
    T.eq(#lines, 6, "banner plus two interleaved steps each plus summary")
    T.truthy(lines[1]:find("north", 1, true), "banner names the composite heading: " .. lines[1])
    T.truthy(lines[2]:find("northwest", 1, true), "first step is the NW ray: " .. lines[2])
    T.truthy(lines[3]:find("northeast", 1, true), "second step is the NE ray: " .. lines[3])
    T.truthy(lines[6]:find("4 tiles scanned", 1, true), "summary counts both rays: " .. lines[6])
end

function M.test_scan_composite_stops_each_ray_at_its_own_boundary()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    -- The NW ray has two tiles; the NE ray has only one, then falls off the
    -- map. Each ray must stop at its own boundary while the other continues.
    registerRay(0, 0, DirectionTypes.DIRECTION_NORTHWEST, {
        plains({ x = -1, y = 1 }),
        plains({ x = -2, y = 2 }),
    })
    registerRay(0, 0, DirectionTypes.DIRECTION_NORTHEAST, {
        plains({ x = 1, y = 1 }),
    })
    local lines = DirectionalScan.scanComposite(
        0,
        0,
        DirectionTypes.DIRECTION_NORTHWEST,
        DirectionTypes.DIRECTION_NORTHEAST,
        2,
        "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_N"
    )
    local text = joined(lines)
    T.truthy(text:find("edge of map", 1, true), "the short ray announces its edge: " .. text)
    T.truthy(text:find("3 tiles scanned", 1, true), "summary counts both rays' revealed tiles: " .. text)
end

-- ===== mode wiring =====

function M.test_enter_mode_pushes_dedicated_capturing_handler()
    setup()
    DirectionalScan.enterMode()
    T.eq(HandlerStack.count(), 1, "entering pushes one handler")
    local active = HandlerStack.active()
    T.eq(active.name, "DirectionalScanMode")
    T.truthy(active.capturesAllInput, "mode must capture all input")
    T.eq(spoken[#spoken].text, Text.key("TXT_KEY_CIVVACCESS_DIRSCAN_ENTER"))
end

function M.test_escape_binding_exits_mode()
    setup()
    DirectionalScan.enterMode()
    local esc = findBinding(HandlerStack.active(), Keys.VK_ESCAPE)
    T.truthy(esc, "mode binds Escape")
    esc.fn()
    T.eq(HandlerStack.count(), 0, "Escape pops the mode")
end

function M.test_direction_key_voices_a_scan()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, {
        plains({ x = 1, y = 0 }),
        plains({ x = 2, y = 0 }),
    })
    DirectionalScan.enterMode()
    -- Clear the entry announcement so we observe only the scan voicing.
    spoken = {}
    local east = findBinding(HandlerStack.active(), Keys.D)
    T.truthy(east, "mode binds D to the east scan")
    east.fn()
    T.truthy(#spoken >= 2, "a scan voices at least one step plus the summary")
    T.truthy(spoken[1].interrupt, "the scan's first line interrupts prior speech")
    T.falsy(spoken[2].interrupt, "later lines queue behind the first")
end

-- ===== radius management =====

function M.test_radius_defaults_to_three()
    setup()
    -- dirScanRadius cleared in setup; getRadius should return 3.
    GameInfo.Terrains[1] = { Description = "Plains" }
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, {
        plains({ x = 1, y = 0 }),
        plains({ x = 2, y = 0 }),
        plains({ x = 3, y = 0 }),
    })
    -- Pass nil radius so resolveRadius falls back to the shared value.
    local lines = DirectionalScan.scanOne(0, 0, DirectionTypes.DIRECTION_EAST, nil)
    -- Default is 3: three step lines plus the closing summary.
    T.eq(#lines, 4, "default radius of 3 yields three steps plus summary: " .. #lines)
end

function M.test_radius_clamp_min()
    setup()
    -- Force an out-of-range value directly into shared; getRadius must clamp.
    civvaccess_shared.dirScanRadius = 0
    GameInfo.Terrains[1] = { Description = "Plains" }
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, {
        plains({ x = 1, y = 0 }),
    })
    local lines = DirectionalScan.scanOne(0, 0, DirectionTypes.DIRECTION_EAST, nil)
    -- Clamped to 1: one step plus summary.
    T.eq(#lines, 2, "radius below min is clamped to 1: " .. #lines)
    T.eq(civvaccess_shared.dirScanRadius, 1, "getRadius rewrites the clamped value into shared")
end

function M.test_radius_clamp_max()
    setup()
    -- Force an out-of-range value directly into shared; getRadius must clamp.
    civvaccess_shared.dirScanRadius = 99
    GameInfo.Terrains[1] = { Description = "Plains" }
    -- Register exactly 10 tiles so the scan runs to the max.
    local ray = {}
    for i = 1, 10 do
        ray[i] = plains({ x = i, y = 0 })
    end
    registerRay(0, 0, DirectionTypes.DIRECTION_EAST, ray)
    local lines = DirectionalScan.scanOne(0, 0, DirectionTypes.DIRECTION_EAST, nil)
    -- Clamped to 10: ten steps plus summary.
    T.eq(#lines, 11, "radius above max is clamped to 10: " .. #lines)
    T.eq(civvaccess_shared.dirScanRadius, 10, "getRadius rewrites the clamped value into shared")
end

function M.test_numpad_plus_increases_radius()
    setup()
    civvaccess_shared.dirScanRadius = 5
    DirectionalScan.enterMode()
    spoken = {}
    local plus = findBinding(HandlerStack.active(), Keys.VK_ADD)
    T.truthy(plus, "enterMode binds VK_ADD for radius grow")
    plus.fn()
    T.eq(civvaccess_shared.dirScanRadius, 6, "VK_ADD increments dirScanRadius")
    T.truthy(#spoken >= 1, "VK_ADD speaks the new radius")
    T.truthy(spoken[1].interrupt, "radius announcement interrupts prior speech")
    T.truthy(spoken[1].text:find("6", 1, true), "new radius is announced: " .. tostring(spoken[1].text))
end

function M.test_numpad_minus_decreases_radius()
    setup()
    civvaccess_shared.dirScanRadius = 5
    DirectionalScan.enterMode()
    spoken = {}
    local minus = findBinding(HandlerStack.active(), Keys.VK_SUBTRACT)
    T.truthy(minus, "enterMode binds VK_SUBTRACT for radius shrink")
    minus.fn()
    T.eq(civvaccess_shared.dirScanRadius, 4, "VK_SUBTRACT decrements dirScanRadius")
    T.truthy(#spoken >= 1, "VK_SUBTRACT speaks the new radius")
    T.truthy(spoken[1].text:find("4", 1, true), "new radius is announced: " .. tostring(spoken[1].text))
end

function M.test_numpad_plus_clamps_at_max()
    setup()
    civvaccess_shared.dirScanRadius = 10
    DirectionalScan.enterMode()
    spoken = {}
    findBinding(HandlerStack.active(), Keys.VK_ADD).fn()
    T.eq(civvaccess_shared.dirScanRadius, 10, "VK_ADD does not exceed max radius")
    T.truthy(spoken[1].text:find("max", 1, true), "max-clamp announcement contains 'max': " .. tostring(spoken[1].text))
end

function M.test_numpad_minus_clamps_at_min()
    setup()
    civvaccess_shared.dirScanRadius = 1
    DirectionalScan.enterMode()
    spoken = {}
    findBinding(HandlerStack.active(), Keys.VK_SUBTRACT).fn()
    T.eq(civvaccess_shared.dirScanRadius, 1, "VK_SUBTRACT does not go below min radius")
    T.truthy(spoken[1].text:find("min", 1, true), "min-clamp announcement contains 'min': " .. tostring(spoken[1].text))
end

function M.test_getbindings_includes_numpad_star()
    setup()
    local b = DirectionalScan.getBindings()
    local found = false
    for _, entry in ipairs(b.bindings) do
        if entry.key == Keys.VK_MULTIPLY then
            found = true
            break
        end
    end
    T.truthy(found, "getBindings includes a VK_MULTIPLY entry for numpad-star entry")
end

function M.test_getbindings_has_radius_help_entry()
    setup()
    local b = DirectionalScan.getBindings()
    local found = false
    for _, entry in ipairs(b.helpEntries) do
        if entry.keyLabel == "TXT_KEY_CIVVACCESS_DIRSCAN_HELP_KEY_RADIUS" then
            found = true
            break
        end
    end
    T.truthy(found, "getBindings helpEntries includes the radius key entry")
end

return M

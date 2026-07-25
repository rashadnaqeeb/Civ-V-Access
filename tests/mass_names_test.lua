-- MassNames: membership clustering, name resolution, merges, dormancy,
-- persistence, and the Ctrl+N entry points. Each case drives the real
-- module against a small fake hex world; the persistence cases re-dofile
-- the module to simulate a load boundary against the polyfill's
-- in-memory ModUserData store.

local T = require("support")
local M = {}

local spoken

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    HandlerStack._reset()
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    civvaccess_shared.messageBuffer = nil
    -- Reinstall a fresh in-memory user-data store on every setup (the
    -- bookmarks suite's failure-path tests leave broken OpenUserData
    -- stubs behind, so the polyfill's store can't be relied on here).
    -- The bucket outlives reloadModule, which is what lets the
    -- persistence cases cross a simulated load boundary.
    local userDataBucket = {}
    Modding.OpenUserData = function()
        return {
            GetValue = function(key)
                return userDataBucket[key]
            end,
            SetValue = function(key, value)
                userDataBucket[key] = value
            end,
        }
    end
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsDebugMode = function()
        return false
    end
    Game.IsHotSeat = function()
        return false
    end
    MassNames = nil
    dofile("src/dlc/UI/InGame/CivVAccess_MassNames.lua")
end

-- Fresh module over the same store / world: the load-boundary half of the
-- persistence cases (hydrate + rebuild come from installListeners).
local function reloadModule()
    MassNames = nil
    dofile("src/dlc/UI/InGame/CivVAccess_MassNames.lua")
end

-- Build a world from { x, y, water=, lake=, revealed= } specs; plotIndex
-- follows spec order from 0. Adjacency is axial-hex: the six engine
-- directions map to fixed offsets, symmetric pairs (E/W, NE/SW, SE/NW).
local function world(specs)
    local byXY, plots = {}, {}
    for i, spec in ipairs(specs) do
        local p = T.fakePlot({
            x = spec.x,
            y = spec.y,
            plotIndex = i - 1,
            water = spec.water,
            lake = spec.lake,
            revealed = spec.revealed,
        })
        plots[i] = p
        byXY[spec.x .. ":" .. spec.y] = p
    end
    Map.GetNumPlots = function()
        return #plots
    end
    Map.GetPlotByIndex = function(i)
        return plots[i + 1]
    end
    Map.GetPlot = function(x, y)
        return byXY[x .. ":" .. y]
    end
    local OFF = {
        [DirectionTypes.DIRECTION_NORTHEAST] = { 0, 1 },
        [DirectionTypes.DIRECTION_EAST] = { 1, 0 },
        [DirectionTypes.DIRECTION_SOUTHEAST] = { 1, -1 },
        [DirectionTypes.DIRECTION_SOUTHWEST] = { 0, -1 },
        [DirectionTypes.DIRECTION_WEST] = { -1, 0 },
        [DirectionTypes.DIRECTION_NORTHWEST] = { -1, 1 },
    }
    Map.PlotDirection = function(x, y, dir)
        local o = OFF[dir]
        return byXY[(x + o[1]) .. ":" .. (y + o[2])]
    end
    return plots
end

function M.test_name_resolves_across_cluster_not_across_gap()
    setup()
    world({ { x = 0, y = 0 }, { x = 1, y = 0 }, { x = 2, y = 0 }, { x = 4, y = 0 } })
    MassNames.installListeners()
    T.eq(MassNames.setName(1, "homeland"), "Named homeland")
    T.eq(MassNames.resolve(0).name, "homeland", "west end of the strip")
    T.eq(MassNames.resolve(2).name, "homeland", "east end of the strip")
    T.eq(MassNames.resolve(3), nil, "separate island stays unnamed")
end

function M.test_land_and_water_cluster_separately_at_the_coast()
    setup()
    world({ { x = 0, y = 0 }, { x = 1, y = 0, water = true }, { x = 2, y = 0, water = true } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    T.eq(MassNames.resolve(1), nil, "adjacent sea must not inherit the land name")
    MassNames.setName(1, "bigsea")
    T.eq(MassNames.resolve(2).name, "bigsea")
    T.eq(MassNames.resolve(0).name, "homeland")
end

function M.test_incremental_reveal_extends_named_mass()
    setup()
    local plots = world({ { x = 0, y = 0 }, { x = 1, y = 0, revealed = false } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    T.eq(MassNames.resolve(1), nil, "unrevealed plot has no mass")
    plots[2]._isRevealed = true
    MassNames._onPlotRevealed(0, 1, 0)
    T.eq(MassNames.resolve(1).name, "homeland")
end

function M.test_live_merge_keeps_older_name_and_announces_once()
    setup()
    local plots = world({ { x = 0, y = 0 }, { x = 1, y = 0, revealed = false }, { x = 2, y = 0 } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    MassNames.setName(2, "eastreach")
    T.eq(#spoken, 0, "direct setName does not speak; the input handler does")
    plots[2]._isRevealed = true
    MassNames._onPlotRevealed(0, 1, 0)
    T.eq(MassNames.resolve(2).name, "homeland", "older name wins the merged mass")
    T.eq(#spoken, 1, "exactly one merge line")
    T.eq(spoken[1].text, "eastreach is part of homeland")
    T.eq(spoken[1].interrupt, false, "merge line queues rather than interrupts")
    local entries = civvaccess_shared.messageBuffer.entries
    T.eq(entries[#entries].text, "eastreach is part of homeland")
    T.eq(entries[#entries].category, "reveal")
end

function M.test_merge_of_identical_names_is_silent()
    setup()
    local plots = world({ { x = 0, y = 0 }, { x = 1, y = 0, revealed = false }, { x = 2, y = 0 } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    MassNames.setName(2, "homeland")
    plots[2]._isRevealed = true
    MassNames._onPlotRevealed(0, 1, 0)
    T.eq(MassNames.resolve(1).name, "homeland")
    T.eq(#spoken, 0, "same spoken name on both sides: nothing audible changed")
end

function M.test_rebuild_merge_is_silent_and_survives_reload()
    setup()
    -- Phase 1: connector unrevealed; two masses, two names.
    world({ { x = 0, y = 0 }, { x = 1, y = 0, revealed = false }, { x = 2, y = 0 } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    MassNames.setName(2, "eastreach")
    -- Phase 2: a later save where the connector is revealed. The merge
    -- happened off-screen; boot's rebuild must not re-announce it.
    reloadModule()
    world({ { x = 0, y = 0 }, { x = 1, y = 0 }, { x = 2, y = 0 } })
    MassNames.installListeners()
    T.eq(#spoken, 0, "rebuild-time merges are not news")
    T.eq(MassNames.resolve(1).name, "homeland")
end

function M.test_dormant_name_wakes_when_anchor_is_revealed()
    setup()
    -- Phase 1: both masses explored and named.
    world({ { x = 0, y = 0 }, { x = 4, y = 0 } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    MassNames.setName(1, "farisle")
    -- Phase 2: an earlier save where the far isle was never explored.
    reloadModule()
    local plots = world({ { x = 0, y = 0 }, { x = 4, y = 0, revealed = false } })
    MassNames.installListeners()
    T.eq(MassNames.resolve(0).name, "homeland")
    T.eq(MassNames.resolve(1), nil, "dormant name attaches to nothing")
    plots[2]._isRevealed = true
    MassNames._onPlotRevealed(0, 4, 0)
    T.eq(MassNames.resolve(1).name, "farisle", "re-exploring the anchor wakes the name")
end

function M.test_waking_dormant_name_into_named_cluster_announces_merge()
    setup()
    -- Phase 1: two named masses, connector unexplored.
    world({ { x = 0, y = 0 }, { x = 1, y = 0, revealed = false }, { x = 2, y = 0, revealed = false } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    -- Reveal the east plot in isolation so it can carry its own name.
    world({ { x = 0, y = 0 }, { x = 1, y = 0, revealed = false }, { x = 2, y = 0 } })
    MassNames.installListeners()
    MassNames.setName(2, "eastreach")
    -- Phase 2: earlier save again -- east anchor unexplored, connector
    -- explored, so the whole strip minus the anchor is one homeland mass.
    reloadModule()
    local plots = world({ { x = 0, y = 0 }, { x = 1, y = 0 }, { x = 2, y = 0, revealed = false } })
    MassNames.installListeners()
    T.eq(MassNames.resolve(1).name, "homeland")
    -- Revealing the anchor merges the dormant eastreach into homeland.
    plots[3]._isRevealed = true
    MassNames._onPlotRevealed(0, 2, 0)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "eastreach is part of homeland")
    T.eq(MassNames.resolve(2).name, "homeland")
end

function M.test_blank_name_cancels_and_separators_are_stripped()
    setup()
    world({ { x = 0, y = 0 } })
    MassNames.installListeners()
    T.eq(MassNames.setName(0, "   "), nil, "blank commit is a cancel")
    T.eq(MassNames.resolve(0), nil)
    T.eq(MassNames.setName(0, "a,b;c"), "Named abc", "wire-format separators stripped")
    T.eq(MassNames.resolve(0).name, "abc")
end

function M.test_rename_updates_record_in_place()
    setup()
    world({ { x = 0, y = 0 }, { x = 1, y = 0 } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    MassNames.setName(1, "newland")
    T.eq(MassNames.resolve(0).name, "newland", "rename from any cell of the cluster")
    reloadModule()
    world({ { x = 0, y = 0 }, { x = 1, y = 0 } })
    MassNames.installListeners()
    T.eq(MassNames.resolve(1).name, "newland", "single renamed record persisted")
    T.eq(#spoken, 0, "one record only: nothing to merge on rebuild")
end

function M.test_resolve_self_heals_when_the_event_path_missed_a_reveal()
    setup()
    local plots = world({ { x = 0, y = 0 }, { x = 1, y = 0, revealed = false } })
    MassNames.installListeners()
    MassNames.setName(0, "homeland")
    -- Reveal without firing the event: the membership map is now stale.
    plots[2]._isRevealed = true
    T.eq(MassNames.resolve(1).name, "homeland", "lookup rebuilds and answers correctly")
end

function M.test_open_rename_refuses_unexplored_and_lake_tiles()
    setup()
    world({
        { x = 9, y = 9, revealed = false },
        { x = 5, y = 5, water = true, lake = true },
    })
    MassNames.installListeners()
    -- Minimal cursor seam: openRename's only dependency is position()
    -- returning the cursor (x, y); CursorCore's full dependency tree
    -- isn't load-bearing for these cases.
    Cursor = {
        position = function()
            return 9, 9
        end,
    }
    T.eq(MassNames.openRename(), "unexplored")
    Cursor.position = function()
        return 5, 5
    end
    T.eq(MassNames.openRename(), "no landmass or ocean here")
    T.eq(HandlerStack.count(), 0, "no input handler pushed on refusal")
end

function M.test_open_rename_prompts_captures_typing_and_commits()
    setup()
    world({ { x = 0, y = 0 }, { x = 1, y = 0 } })
    MassNames.installListeners()
    Cursor = {
        position = function()
            return 0, 0
        end,
    }
    T.eq(MassNames.openRename(), "Name landmass, type and press Enter")
    local handler = HandlerStack.at(HandlerStack.count())
    T.eq(handler.name, "MassNameInput")
    -- Type "hi 2" then Enter. Letters arrive as uppercase VKs and buffer
    -- lowercase; leading space on an empty buffer is dropped.
    handler.handleSearchInput(handler, Keys.VK_SPACE, 0)
    handler.handleSearchInput(handler, Keys.H, 0)
    handler.handleSearchInput(handler, Keys.I, 0)
    handler.handleSearchInput(handler, Keys.VK_SPACE, 0)
    handler.handleSearchInput(handler, Keys["2"], 0)
    handler.handleSearchInput(handler, Keys.VK_RETURN, 0)
    T.eq(HandlerStack.count(), 0, "commit pops the input handler")
    T.eq(spoken[#spoken].text, "Named hi 2")
    T.eq(MassNames.resolve(1).name, "hi 2")
    -- Re-open on the named mass: rename prompt, then Escape cancels.
    T.eq(MassNames.openRename(), "Rename hi 2, type and press Enter")
    handler = HandlerStack.at(HandlerStack.count())
    handler.handleSearchInput(handler, Keys.X, 0)
    handler.handleSearchInput(handler, Keys.VK_ESCAPE, 0)
    T.eq(HandlerStack.count(), 0, "escape pops the input handler")
    T.eq(MassNames.resolve(1).name, "hi 2", "escape discards the typed text")
end

return M

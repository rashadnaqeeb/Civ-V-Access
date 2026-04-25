-- TaskList-module tests. Covers the file-scope TaskListUpdate listener
-- that mirrors engine task pushes into civvaccess_shared.tasks, and the
-- Shift+T readout that filters to active (status 0) tasks and concatenates
-- via TextFilter.filter. Silent paths (no mirror, all-completed) are
-- explicitly asserted because a wrong value reaching Tolk is a silent
-- failure for the blind player.

local T = require("support")
local M = {}

local spoken
local listener

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")

    listener = nil
    Events = Events or {}
    Events.TaskListUpdate = {
        Add = function(fn)
            listener = fn
        end,
    }

    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.tasks = nil

    -- Re-dofile every setup so file-scope listener registration runs
    -- against the captured Add stub. Production loads this once per
    -- WorldView Context include, but the offline harness has no Context;
    -- dofile is the equivalent.
    dofile("src/dlc/UI/InGame/CivVAccess_TaskList.lua")

    SpeechPipeline._reset()
    spoken = {}
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, interrupt = interrupt }
    end
end

function M.test_listener_registers_at_file_scope()
    setup()
    T.truthy(listener, "TaskListUpdate listener must register at file scope")
end

function M.test_listener_writes_to_civvaccess_shared_tasks()
    setup()
    listener({ Index = 0, TaskStatus = 0, Text = "Capture Constantinople" })
    T.eq(civvaccess_shared.tasks[0].status, 0)
    T.eq(civvaccess_shared.tasks[0].text, "Capture Constantinople")
end

function M.test_silent_when_mirror_unset()
    -- The common case: no scenario, no tasks ever pushed, Shift+T must
    -- be a no-op (not an error).
    setup()
    civvaccess_shared.tasks = nil
    TaskList._speakActiveTasks()
    T.eq(#spoken, 0)
end

function M.test_silent_when_mirror_empty()
    -- After resetForNewGame the mirror is an empty table; same no-op.
    setup()
    TaskList.resetForNewGame()
    TaskList._speakActiveTasks()
    T.eq(#spoken, 0)
end

function M.test_speaks_only_active_tasks()
    setup()
    listener({ Index = 0, TaskStatus = 0, Text = "Active task one" })
    listener({ Index = 1, TaskStatus = 1, Text = "Completed task" })
    listener({ Index = 2, TaskStatus = 0, Text = "Active task two" })
    listener({ Index = 3, TaskStatus = 2, Text = "Failed task" })
    TaskList._speakActiveTasks()
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "Active task one. Active task two")
    T.eq(spoken[1].interrupt, true)
end

function M.test_silent_when_all_tasks_completed_or_failed()
    -- Filtering yields zero active entries; speak nothing rather than
    -- speaking an empty string.
    setup()
    listener({ Index = 0, TaskStatus = 1, Text = "Done" })
    listener({ Index = 1, TaskStatus = 2, Text = "Failed" })
    TaskList._speakActiveTasks()
    T.eq(#spoken, 0)
end

function M.test_status_update_overwrites_in_place()
    -- Engine flips TaskStatus from incomplete to complete by re-firing
    -- TaskListUpdate at the same Index. Mirror must overwrite, not append.
    setup()
    listener({ Index = 0, TaskStatus = 0, Text = "First task" })
    listener({ Index = 0, TaskStatus = 1, Text = "First task" })
    TaskList._speakActiveTasks()
    T.eq(#spoken, 0)
end

function M.test_reset_for_new_game_clears_mirror()
    -- civvaccess_shared persists across game-to-game transitions on the
    -- shared lua_State, so a fresh game must reset the mirror to avoid
    -- speaking the prior game's tasks.
    setup()
    listener({ Index = 0, TaskStatus = 0, Text = "Old game task" })
    TaskList.resetForNewGame()
    TaskList._speakActiveTasks()
    T.eq(#spoken, 0)
end

function M.test_iterates_in_engine_order()
    -- 0..maxIndex with nil holes (Index 1 missing) matches the engine's
    -- TaskList.lua render loop. Active entries at 0 and 2 speak in that
    -- order regardless of insertion sequence.
    setup()
    listener({ Index = 2, TaskStatus = 0, Text = "Second" })
    listener({ Index = 0, TaskStatus = 0, Text = "First" })
    TaskList._speakActiveTasks()
    T.eq(spoken[1].text, "First. Second")
end

return M

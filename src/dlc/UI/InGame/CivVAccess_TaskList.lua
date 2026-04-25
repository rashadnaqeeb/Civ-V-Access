-- Read-only mirror of the engine's task list. Shift+T speaks active
-- (status 0) tasks via TextFilter.filter, joined by ". ". With no active
-- tasks (or no task list at all -- the common case outside scenarios) the
-- key is a silent no-op.
--
-- Why mirror at all (the "never cache game state" rule has an exception
-- here): tasks live in the engine's TaskList Context's sandboxed env
-- globals (g_aTaskString / g_aTaskStatus). There is no engine API to
-- query them, and Civ V's per-Context Lua sandbox blocks reads across
-- Contexts. Events.TaskListUpdate is the only signal the engine offers
-- for task content, so a synchronously-updated mirror is the only path
-- to a Shift+T readout. The mirror matches engine state for as long as
-- we don't drop an event; the engine's own TaskList.lua has the same
-- shape for the same reason.
--
-- Listener registers at file scope (matching the engine's TaskList.lua)
-- rather than the mod's usual installListeners() pattern, so it's live
-- before LoadScreenClose. Scenario task pushes from C++ can fire during
-- game setup, before the LoadScreenClose-driven boot path runs; later-
-- registered listeners would miss them. The file is re-evaluated on
-- every WorldView Context include (fresh-game and load-game-from-game),
-- so a fresh-env closure supplants any stranded prior-game listener
-- per the same rationale as Boot.lua's LoadScreenClose registration.

TaskList = {}

local MOD_SHIFT = 1
-- Engine TaskListInfo.TaskStatus enum: 0 incomplete, 1 complete, 2 failed.
local STATUS_ACTIVE = 0

local function onTaskListUpdate(info)
    local mirror = civvaccess_shared.tasks
    if mirror == nil then
        mirror = {}
        civvaccess_shared.tasks = mirror
    end
    mirror[info.Index] = { status = info.TaskStatus, text = info.Text }
end

if Events ~= nil and Events.TaskListUpdate ~= nil then
    Events.TaskListUpdate.Add(onTaskListUpdate)
else
    Log.warn("TaskList: Events.TaskListUpdate missing; Shift+T will speak nothing")
end

-- Tasks are per-game. The mirror lives on civvaccess_shared which survives
-- across games on the shared lua_State (main-menu exit and re-load runs
-- the same Lua process), so a fresh game needs an explicit reset to avoid
-- speaking the prior game's tasks. The engine's own TaskList Context
-- effectively forgets tasks across save/load too (its globals are Lua-only
-- with no Restore), so the engine UI and our readout stay consistent.
function TaskList.resetForNewGame()
    civvaccess_shared.tasks = {}
end

local function speakActiveTasks()
    local mirror = civvaccess_shared.tasks
    if mirror == nil then
        return
    end
    -- Iterate 0..maxIndex with nil holes, mirroring the engine TaskList.lua
    -- render loop so the readout order matches what a sighted player sees.
    local maxIndex = -1
    for idx in pairs(mirror) do
        if idx > maxIndex then
            maxIndex = idx
        end
    end
    if maxIndex < 0 then
        return
    end
    local parts = {}
    for i = 0, maxIndex do
        local entry = mirror[i]
        if entry ~= nil and entry.status == STATUS_ACTIVE then
            parts[#parts + 1] = entry.text
        end
    end
    if #parts == 0 then
        return
    end
    SpeechPipeline.speakInterrupt(TextFilter.filter(table.concat(parts, ". ")))
end

local bind = HandlerStack.bind

function TaskList.getBindings()
    local bindings = {
        bind(Keys.T, MOD_SHIFT, speakActiveTasks, "Read active tasks"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY",
            description = "TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

-- Test seam. The Shift+T binding's callback is otherwise reachable only
-- through the dispatcher, which the offline harness doesn't drive.
TaskList._speakActiveTasks = speakActiveTasks

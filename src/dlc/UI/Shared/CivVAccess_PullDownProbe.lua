-- Engine PullDowns expose RegisterSelectionCallback / BuildEntry / ClearEntries
-- but no public accessor for the registered callback or the entries. FormHandler
-- needs both to synthesize a keyboard sub-menu. This module wraps those three
-- methods on the shared PullDown metatable so every call still reaches the
-- engine (mouse path stays intact) while we record what we need on
-- civvaccess_shared.
--
-- PullDown.install(sample) must run BEFORE the screen's own code registers
-- callbacks / builds entries. The per-screen override prepends an include of
-- this file at the very top of the game's .lua; the sample is a PullDown
-- grabbed from Controls (available after XML parse, before top-level Lua runs).
--
-- State layout on civvaccess_shared:
--   pullDownProbeInstalled   bool, guards the one-time patch
--   pullDownCallbacks        pulldown -> fn last registered
--   pullDownEntries          pulldown -> { instance, instance, ... } in BuildEntry order;
--                            cleared when the screen calls ClearEntries.
--
-- Each instance is the `controlTable` the game's own code passed to BuildEntry,
-- so instance.Button is the per-entry button; read Button:GetText() /
-- Button:GetVoid1() / Button:GetVoid2() at activation time.

PullDownProbe = {}

civvaccess_shared = civvaccess_shared or {}

-- ensureInstalled is the public entry point. Idempotent; the first caller
-- patches the metatable, subsequent calls are no-ops regardless of Context.
function PullDownProbe.ensureInstalled(samplePullDown)
    if civvaccess_shared.pullDownProbeInstalled then return true end
    if samplePullDown == nil then
        Log.warn("PullDownProbe: ensureInstalled called without a sample pulldown")
        return false
    end
    local mt = getmetatable(samplePullDown)
    if mt == nil then
        Log.warn("PullDownProbe: sample has no accessible metatable; probe disabled")
        return false
    end
    local idx = mt.__index
    if type(idx) ~= "table" then
        Log.warn("PullDownProbe: metatable __index is not a table; probe disabled")
        return false
    end

    civvaccess_shared.pullDownCallbacks = civvaccess_shared.pullDownCallbacks or {}
    civvaccess_shared.pullDownEntries   = civvaccess_shared.pullDownEntries   or {}

    local origReg = idx.RegisterSelectionCallback
    if type(origReg) ~= "function" then
        Log.warn("PullDownProbe: RegisterSelectionCallback missing on metatable")
        return false
    end
    idx.RegisterSelectionCallback = function(self, fn)
        civvaccess_shared.pullDownCallbacks[self] = fn
        return origReg(self, fn)
    end

    local origBuild = idx.BuildEntry
    if type(origBuild) == "function" then
        idx.BuildEntry = function(self, stem, instance, ...)
            local list = civvaccess_shared.pullDownEntries[self]
            if list == nil then
                list = {}
                civvaccess_shared.pullDownEntries[self] = list
            end
            list[#list + 1] = instance
            return origBuild(self, stem, instance, ...)
        end
    else
        Log.warn("PullDownProbe: BuildEntry missing on metatable")
    end

    local origClear = idx.ClearEntries
    if type(origClear) == "function" then
        idx.ClearEntries = function(self, ...)
            civvaccess_shared.pullDownEntries[self] = nil
            return origClear(self, ...)
        end
    else
        Log.warn("PullDownProbe: ClearEntries missing on metatable")
    end

    civvaccess_shared.pullDownProbeInstalled = true
    Log.info("PullDownProbe: metatable patched")
    return true
end

function PullDownProbe.callbackFor(pulldown)
    local t = civvaccess_shared.pullDownCallbacks
    return t and t[pulldown] or nil
end

function PullDownProbe.entriesFor(pulldown)
    local t = civvaccess_shared.pullDownEntries
    return t and t[pulldown] or nil
end

-- Install from any Controls.X PullDown found in the current Context. Walks a
-- short list of known-stable screen-local names; returns true if patched.
function PullDownProbe.installFromControls(names)
    if civvaccess_shared.pullDownProbeInstalled then return true end
    if type(Controls) ~= "userdata" and type(Controls) ~= "table" then
        return false
    end
    for _, name in ipairs(names or {}) do
        local c = Controls[name]
        if c ~= nil then
            return PullDownProbe.ensureInstalled(c)
        end
    end
    return false
end

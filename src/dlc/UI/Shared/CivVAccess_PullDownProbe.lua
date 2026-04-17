-- Engine PullDowns and Sliders expose Register*Callback / BuildEntry /
-- ClearEntries / SetValue, but no public accessor for the registered
-- callback. MenuItems needs both to:
--   * synthesize a keyboard sub-menu from a PullDown's entries
--   * fire the screen's SliderCallback after programmatic SetValue, since
--     the engine does not auto-fire it outside mouse drags
-- This module wraps those methods on the shared PullDown/Slider metatables
-- so every call still reaches the engine (mouse path stays intact) while
-- we record what we need on civvaccess_shared.
--
-- ensureInstalled* must run BEFORE the screen's own top-level code
-- registers callbacks or builds entries. The per-screen override prepends
-- an include that invokes installFromControls so the sample controls
-- used to reach each metatable are available right after XML parse.
--
-- Engine userdata metatables have `__index` as a C function (dispatching
-- against an internal method table), not a Lua table, so we cannot assign
-- new keys to an __index table. Instead we replace __index with a Lua
-- function that handles the methods we care about and forwards the rest
-- to the original __index function. This path is also exercised in tests
-- via setmetatable, where __index may be either a table or a function.
--
-- State layout on civvaccess_shared:
--   pullDownProbeInstalled   bool, guards the pulldown patch
--   sliderProbeInstalled     bool, guards the slider patch
--   pullDownCallbacks        pulldown -> fn last registered
--   pullDownEntries          pulldown -> { instance, instance, ... }
--                            cleared when the screen calls ClearEntries
--   sliderCallbacks          slider -> fn last registered
--
-- PullDown instance is the `controlTable` passed to BuildEntry, so
-- instance.Button is the per-entry button; read at activation time.

PullDownProbe = {}

civvaccess_shared = civvaccess_shared or {}

-- Resolve an original method from a metatable whose __index may be a
-- table (tests, Polyfill) or a function (engine userdata). Returns nil
-- if the method is not exposed.
local function resolveMethod(origIndex, sample, name)
    if type(origIndex) == "table" then
        return origIndex[name]
    end
    if type(origIndex) == "function" then
        return origIndex(sample, name)
    end
    return nil
end

-- Replace mt.__index with a function that intercepts a fixed set of
-- methods by name, and forwards everything else to the original __index.
-- Works whether the original is a table or a function. The interceptor
-- map is { [methodName] = wrappedFn } where wrappedFn is the closure we
-- return when the user's code reads that method.
local function patchIndex(mt, interceptors)
    local origIndex = mt.__index
    mt.__index = function(self, key)
        local fn = interceptors[key]
        if fn ~= nil then return fn end
        if type(origIndex) == "table" then return origIndex[key] end
        return origIndex(self, key)
    end
end

-- ---------- PullDown ----------

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

    local origReg   = resolveMethod(mt.__index, samplePullDown, "RegisterSelectionCallback")
    local origBuild = resolveMethod(mt.__index, samplePullDown, "BuildEntry")
    local origClear = resolveMethod(mt.__index, samplePullDown, "ClearEntries")
    if type(origReg) ~= "function" then
        Log.warn("PullDownProbe: RegisterSelectionCallback missing on metatable")
        return false
    end

    civvaccess_shared.pullDownCallbacks = civvaccess_shared.pullDownCallbacks or {}
    civvaccess_shared.pullDownEntries   = civvaccess_shared.pullDownEntries   or {}
    local callbacks = civvaccess_shared.pullDownCallbacks
    local entries   = civvaccess_shared.pullDownEntries

    local interceptors = {}
    interceptors.RegisterSelectionCallback = function(self, fn)
        callbacks[self] = fn
        return origReg(self, fn)
    end
    if type(origBuild) == "function" then
        interceptors.BuildEntry = function(self, stem, instance, ...)
            local list = entries[self]
            if list == nil then list = {}; entries[self] = list end
            list[#list + 1] = instance
            return origBuild(self, stem, instance, ...)
        end
    else
        Log.warn("PullDownProbe: BuildEntry missing on metatable")
    end
    if type(origClear) == "function" then
        interceptors.ClearEntries = function(self, ...)
            entries[self] = nil
            return origClear(self, ...)
        end
    else
        Log.warn("PullDownProbe: ClearEntries missing on metatable")
    end

    patchIndex(mt, interceptors)
    civvaccess_shared.pullDownProbeInstalled = true
    Log.info("PullDownProbe: pulldown metatable patched")
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

-- ---------- Slider ----------

function PullDownProbe.ensureSliderInstalled(sampleSlider)
    if civvaccess_shared.sliderProbeInstalled then return true end
    if sampleSlider == nil then
        Log.warn("PullDownProbe: ensureSliderInstalled called without a sample slider")
        return false
    end
    local mt = getmetatable(sampleSlider)
    if mt == nil then
        Log.warn("PullDownProbe: slider sample has no accessible metatable; slider probe disabled")
        return false
    end

    -- Guard against the pulldown and slider sharing a metatable: if we
    -- already patched __index for pulldowns, the slider's metatable is
    -- a distinct object and needs its own patch. If they happen to be
    -- the same table, we add slider interceptors on top of the existing
    -- patch by re-wrapping.
    local origReg = resolveMethod(mt.__index, sampleSlider, "RegisterSliderCallback")
    if type(origReg) ~= "function" then
        Log.warn("PullDownProbe: RegisterSliderCallback missing on metatable")
        return false
    end

    civvaccess_shared.sliderCallbacks = civvaccess_shared.sliderCallbacks or {}
    local callbacks = civvaccess_shared.sliderCallbacks

    patchIndex(mt, {
        RegisterSliderCallback = function(self, fn)
            callbacks[self] = fn
            return origReg(self, fn)
        end,
    })
    civvaccess_shared.sliderProbeInstalled = true
    Log.info("PullDownProbe: slider metatable patched")
    return true
end

function PullDownProbe.sliderCallbackFor(slider)
    local t = civvaccess_shared.sliderCallbacks
    return t and t[slider] or nil
end

-- ---------- CheckBox ----------

function PullDownProbe.ensureCheckBoxInstalled(sampleCheckBox)
    if civvaccess_shared.checkBoxProbeInstalled then return true end
    if sampleCheckBox == nil then
        Log.warn("PullDownProbe: ensureCheckBoxInstalled called without a sample checkbox")
        return false
    end
    local mt = getmetatable(sampleCheckBox)
    if mt == nil then
        Log.warn("PullDownProbe: checkbox sample has no accessible metatable; checkbox probe disabled")
        return false
    end

    local origReg = resolveMethod(mt.__index, sampleCheckBox, "RegisterCheckHandler")
    if type(origReg) ~= "function" then
        Log.warn("PullDownProbe: RegisterCheckHandler missing on metatable")
        return false
    end

    civvaccess_shared.checkBoxCallbacks = civvaccess_shared.checkBoxCallbacks or {}
    local callbacks = civvaccess_shared.checkBoxCallbacks

    patchIndex(mt, {
        RegisterCheckHandler = function(self, fn)
            callbacks[self] = fn
            return origReg(self, fn)
        end,
    })
    civvaccess_shared.checkBoxProbeInstalled = true
    Log.info("PullDownProbe: checkbox metatable patched")
    return true
end

function PullDownProbe.checkBoxCallbackFor(checkbox)
    local t = civvaccess_shared.checkBoxCallbacks
    return t and t[checkbox] or nil
end

-- ---------- Bulk install ----------

-- Walk a list of known-stable control names for each widget kind. First
-- resolvable sample of each kind is enough since its metatable is shared
-- with every widget of that kind in the lua_State.
function PullDownProbe.installFromControls(pullDownNames, sliderNames, checkBoxNames)
    if type(Controls) ~= "userdata" and type(Controls) ~= "table" then
        return
    end
    if not civvaccess_shared.pullDownProbeInstalled then
        for _, name in ipairs(pullDownNames or {}) do
            local c = Controls[name]
            if c ~= nil then
                if PullDownProbe.ensureInstalled(c) then break end
            end
        end
    end
    if not civvaccess_shared.sliderProbeInstalled then
        for _, name in ipairs(sliderNames or {}) do
            local c = Controls[name]
            if c ~= nil then
                if PullDownProbe.ensureSliderInstalled(c) then break end
            end
        end
    end
    if not civvaccess_shared.checkBoxProbeInstalled then
        for _, name in ipairs(checkBoxNames or {}) do
            local c = Controls[name]
            if c ~= nil then
                if PullDownProbe.ensureCheckBoxInstalled(c) then break end
            end
        end
    end
end

-- Engine PullDowns and Sliders expose Register*Callback / BuildEntry /
-- ClearEntries / SetValue, but no public accessor for the registered
-- callback. BaseMenuItems needs both to:
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
--   buttonProbeInstalled     bool, guards the button patch
--   pullDownCallbacks        pulldown -> fn last registered
--   pullDownEntries          pulldown -> { instance, instance, ... }
--                            cleared when the screen calls ClearEntries
--   sliderCallbacks          slider -> fn last registered
--   buttonCallbacks          button -> { [mouseEvent] = fn, ... }
--                            captured per-button click callbacks, keyed by
--                            mouse event number (typically Mouse.eLClick).
--                            Lets Pulldown fall back to per-entry callbacks
--                            when a pulldown was wired with per-button
--                            RegisterCallback instead of one top-level
--                            RegisterSelectionCallback (map-script option
--                            dropdowns do this; each entry's button
--                            captures its own closure over the option id +
--                            value).
--
-- PullDown instance is the `controlTable` passed to BuildEntry, so
-- instance.Button is the per-entry button; read at activation time.

PullDownProbe = {}

civvaccess_shared = civvaccess_shared or {}

-- Capture `type` as an upvalue. The __index and RegisterCallback closures we
-- install on shared engine userdata metatables outlive the Context that
-- installed them (metatables are shared across the session's single
-- lua_State; Contexts each have their own _ENV and are torn down
-- independently). A global lookup from a dead Context's _ENV returns nil and
-- crashes every subsequent widget method dispatch. The upvalue holds a
-- direct reference to the function, surviving Context teardown.
local type = type

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
-- Works whether the original is a table or a function. Per-slider /
-- pulldown re-patch composes naturally because each call captures the
-- prior __index in its closure: a slider patch on a metatable already
-- wrapped for pulldown still forwards non-slider methods to the prior
-- pulldown layer, which forwards everything else to the engine.
local function patchIndex(mt, interceptors)
    local origIndex = mt.__index
    mt.__index = function(self, key)
        local fn = interceptors[key]
        if fn ~= nil then
            return fn
        end
        if type(origIndex) == "table" then
            return origIndex[key]
        end
        return origIndex(self, key)
    end
end

-- Shared install scaffold. Each typed ensure*Installed function below
-- delegates here with its own interceptor builder. The scaffold owns the
-- install-once flag, sample-nil and metatable-nil guards, primary-method
-- resolution, callback-table init, patch installation, and success log;
-- per-widget logic lives in buildInterceptors and decides whether the
-- prerequisites it needs are present (returning nil aborts).
local function installProbe(label, flagField, sample, primaryMethod, callbackField, buildInterceptors)
    if civvaccess_shared[flagField] then
        return true
    end
    local lowerLabel = label:lower()
    if sample == nil then
        Log.warn("PullDownProbe: ensure" .. label .. "Installed called without a sample " .. lowerLabel)
        return false
    end
    local mt = getmetatable(sample)
    if mt == nil then
        Log.warn(
            "PullDownProbe: "
                .. lowerLabel
                .. " sample has no accessible metatable; "
                .. lowerLabel
                .. " probe disabled"
        )
        return false
    end
    local origPrimary = resolveMethod(mt.__index, sample, primaryMethod)
    if type(origPrimary) ~= "function" then
        Log.warn("PullDownProbe: " .. primaryMethod .. " missing on metatable")
        return false
    end
    civvaccess_shared[callbackField] = civvaccess_shared[callbackField] or {}
    local callbacks = civvaccess_shared[callbackField]
    local interceptors = buildInterceptors(origPrimary, callbacks, mt, sample)
    if interceptors == nil then
        return false
    end
    patchIndex(mt, interceptors)
    civvaccess_shared[flagField] = true
    Log.info("PullDownProbe: " .. lowerLabel .. " metatable patched")
    return true
end

-- ---------- PullDown ----------

function PullDownProbe.ensureInstalled(samplePullDown)
    return installProbe(
        "PullDown",
        "pullDownProbeInstalled",
        samplePullDown,
        "RegisterSelectionCallback",
        "pullDownCallbacks",
        function(origReg, callbacks, mt, sample)
            civvaccess_shared.pullDownEntries = civvaccess_shared.pullDownEntries or {}
            local entries = civvaccess_shared.pullDownEntries
            local origBuild = resolveMethod(mt.__index, sample, "BuildEntry")
            local origClear = resolveMethod(mt.__index, sample, "ClearEntries")

            local interceptors = {}
            interceptors.RegisterSelectionCallback = function(self, fn)
                callbacks[self] = fn
                return origReg(self, fn)
            end
            if type(origBuild) == "function" then
                interceptors.BuildEntry = function(self, stem, instance, ...)
                    local list = entries[self]
                    if list == nil then
                        list = {}
                        entries[self] = list
                    end
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
            return interceptors
        end
    )
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
    return installProbe(
        "Slider",
        "sliderProbeInstalled",
        sampleSlider,
        "RegisterSliderCallback",
        "sliderCallbacks",
        function(origReg, callbacks)
            return {
                RegisterSliderCallback = function(self, fn)
                    callbacks[self] = fn
                    return origReg(self, fn)
                end,
            }
        end
    )
end

function PullDownProbe.sliderCallbackFor(slider)
    local t = civvaccess_shared.sliderCallbacks
    return t and t[slider] or nil
end

-- ---------- CheckBox ----------

function PullDownProbe.ensureCheckBoxInstalled(sampleCheckBox)
    return installProbe(
        "CheckBox",
        "checkBoxProbeInstalled",
        sampleCheckBox,
        "RegisterCheckHandler",
        "checkBoxCallbacks",
        function(origReg, callbacks)
            return {
                RegisterCheckHandler = function(self, fn)
                    callbacks[self] = fn
                    return origReg(self, fn)
                end,
            }
        end
    )
end

function PullDownProbe.checkBoxCallbackFor(checkbox)
    local t = civvaccess_shared.checkBoxCallbacks
    return t and t[checkbox] or nil
end

-- ---------- Button ----------
--
-- Captures per-button RegisterCallback(mouseEvent, fn). Mostly useful for
-- pulldown entry buttons whose dropdown was wired with per-entry click
-- callbacks rather than one pulldown-level RegisterSelectionCallback.
-- Guard on `type(mouseEvent) == "number"` so we ignore other callers
-- (EditBox:RegisterCallback takes a single function argument with no
-- mouse event; don't capture those).

function PullDownProbe.ensureButtonInstalled(sampleButton)
    return installProbe(
        "Button",
        "buttonProbeInstalled",
        sampleButton,
        "RegisterCallback",
        "buttonCallbacks",
        function(origReg, callbacks)
            return {
                RegisterCallback = function(self, mouseEvent, fn)
                    if type(mouseEvent) == "number" and type(fn) == "function" then
                        local perButton = callbacks[self]
                        if perButton == nil then
                            perButton = {}
                            callbacks[self] = perButton
                        end
                        perButton[mouseEvent] = fn
                    end
                    return origReg(self, mouseEvent, fn)
                end,
            }
        end
    )
end

function PullDownProbe.buttonCallbackFor(button, mouseEvent)
    local t = civvaccess_shared.buttonCallbacks
    if t == nil then
        return nil
    end
    local perButton = t[button]
    if perButton == nil then
        return nil
    end
    return perButton[mouseEvent]
end

-- ---------- Bulk install ----------

-- Walk a list of known-stable control names for each widget kind. First
-- resolvable sample of each kind is enough since its metatable is shared
-- with every widget of that kind in the lua_State.
function PullDownProbe.installFromControls(pullDownNames, sliderNames, checkBoxNames, buttonNames)
    if type(Controls) ~= "userdata" and type(Controls) ~= "table" then
        return
    end
    local kinds = {
        { flag = "pullDownProbeInstalled", names = pullDownNames, ensure = PullDownProbe.ensureInstalled },
        { flag = "sliderProbeInstalled", names = sliderNames, ensure = PullDownProbe.ensureSliderInstalled },
        { flag = "checkBoxProbeInstalled", names = checkBoxNames, ensure = PullDownProbe.ensureCheckBoxInstalled },
        { flag = "buttonProbeInstalled", names = buttonNames, ensure = PullDownProbe.ensureButtonInstalled },
    }
    for _, kind in ipairs(kinds) do
        if not civvaccess_shared[kind.flag] then
            for _, name in ipairs(kind.names or {}) do
                local c = Controls[name]
                if c ~= nil and kind.ensure(c) then
                    break
                end
            end
        end
    end
end

-- Shared setup, helpers, and state for the four menu_*_test suites
-- (menu_widgets, menu_interactions, menu_lifecycle, menu_structure).
--
-- The four suites split a single BaseMenu test corpus by topic. Their
-- setup, helper functions, and mutable state tables (warns / errors /
-- speaks / sounds / ctrlState) are word-for-word identical, so they live
-- here as a single module to keep the four suites in sync.
--
-- Usage from each suite:
--
--   local Setup = require("menu_test_setup")
--   local warns, errors = Setup.warns, Setup.errors
--   local speaks, sounds = Setup.speaks, Setup.sounds
--   local resetPDMetatable = Setup.resetPDMetatable
--   local makePullDownWithMetatable = Setup.makePullDownWithMetatable
--   local populateControls = Setup.populateControls
--   local patchProbeFromPullDown = Setup.patchProbeFromPullDown
--   local registerSliderCallback = Setup.registerSliderCallback
--   local registerCheckHandler = Setup.registerCheckHandler
--   local makeCtrl, setCtrls = Setup.makeCtrl, Setup.setCtrls
--   local ctrlState = Setup.ctrlState
--   local makeContextPtr, buttonSpec = Setup.makeContextPtr, Setup.buttonSpec
--   local clearArr = Setup.clearArr
--   local function setup() Setup.fresh() end
--
-- The state tables live on Setup and are mutated in place across calls.
-- Test files alias them once at the top so a test body's `speaks` /
-- `ctrlState` references remain valid across the test's `setup()` calls.
-- For mid-test resets (e.g. drop a "selection announce" event before
-- asserting a follow-on dispatch), use `clearArr(speaks)` rather than
-- `speaks = {}` -- the latter rebinds the file-local without redirecting
-- the closures that the dofile'd modules installed (Log.warn,
-- SpeechPipeline._speakAction, Events.AudioPlay2DSound).

local Setup = {}

Setup.warns = {}
Setup.errors = {}
Setup.speaks = {}
Setup.sounds = {}
Setup.ctrlState = {}
Setup._test_pd_mt = nil

local function clearArr(t)
    for k in pairs(t) do
        t[k] = nil
    end
end
Setup.clearArr = clearArr

function Setup.resetPDMetatable()
    local proto = Polyfill.makePullDown()
    Setup._test_pd_mt = {
        __index = {
            GetButton = proto.GetButton,
            ClearEntries = proto.ClearEntries,
            BuildEntry = proto.BuildEntry,
            CalculateInternals = proto.CalculateInternals,
            RegisterSelectionCallback = proto.RegisterSelectionCallback,
            IsHidden = proto.IsHidden,
            IsDisabled = proto.IsDisabled,
            SetHide = proto.SetHide,
            SetDisabled = proto.SetDisabled,
        },
    }
end

function Setup.makePullDownWithMetatable()
    if Setup._test_pd_mt == nil then
        Setup.resetPDMetatable()
    end
    return Polyfill.makePullDownWithMetatable(Setup._test_pd_mt)
end

function Setup.populateControls(map)
    Controls = {}
    for name, c in pairs(map) do
        Controls[name] = c
    end
end

function Setup.patchProbeFromPullDown(pd)
    PullDownProbe.ensureInstalled(pd)
end

function Setup.registerSliderCallback(slider, fn)
    slider:RegisterSliderCallback(fn)
    civvaccess_shared.sliderCallbacks[slider] = fn
end

function Setup.registerCheckHandler(cb, fn)
    cb:RegisterCheckHandler(fn)
    civvaccess_shared.checkBoxCallbacks = civvaccess_shared.checkBoxCallbacks or {}
    civvaccess_shared.checkBoxCallbacks[cb] = fn
end

function Setup.makeCtrl(name)
    return setmetatable({ _name = name }, {
        __index = {
            IsHidden = function(self)
                return Setup.ctrlState[self._name].hidden
            end,
            IsDisabled = function(self)
                return Setup.ctrlState[self._name].disabled
            end,
        },
    })
end

function Setup.setCtrls(names)
    Controls = {}
    clearArr(Setup.ctrlState)
    for _, name in ipairs(names) do
        Setup.ctrlState[name] = { hidden = false, disabled = false }
        Controls[name] = Setup.makeCtrl(name)
    end
end

function Setup.makeContextPtr()
    return {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
end

function Setup.buttonSpec(names)
    local items = {}
    for _, name in ipairs(names) do
        items[#items + 1] = BaseMenuItems.Button({
            controlName = name,
            textKey = "LABEL_" .. name,
            activate = function() end,
        })
    end
    return items
end

function Setup.fresh()
    clearArr(Setup.warns)
    clearArr(Setup.errors)
    Log.warn = function(m)
        Setup.warns[#Setup.warns + 1] = m
    end
    Log.error = function(m)
        Setup.errors[#Setup.errors + 1] = m
    end
    Log.info = function() end
    Log.debug = function() end

    UI.ShiftKeyDown = function()
        return false
    end
    UI.CtrlKeyDown = function()
        return false
    end
    UI.AltKeyDown = function()
        return false
    end

    clearArr(Setup.sounds)
    Events.AudioPlay2DSound = function(id)
        Setup.sounds[#Setup.sounds + 1] = id
    end

    clearArr(Setup.speaks)
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        Setup.speaks[#Setup.speaks + 1] = { text = text, interrupt = interrupt }
    end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_PullDownProbe.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuHelp.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuTabs.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuInstall.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuEditMode.lua")
    HandlerStack._reset()
    TickPump._reset()

    civvaccess_shared.pullDownProbeInstalled = false
    civvaccess_shared.pullDownCallbacks = {}
    civvaccess_shared.pullDownEntries = {}
    civvaccess_shared.sliderProbeInstalled = false
    civvaccess_shared.sliderCallbacks = {}
    civvaccess_shared.checkBoxProbeInstalled = false
    civvaccess_shared.checkBoxCallbacks = {}
    civvaccess_shared.buttonProbeInstalled = false
    civvaccess_shared.buttonCallbacks = {}

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "on"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "off"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "edit"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "blank"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "editing {1_Label}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restored"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "no match for {1_Buffer}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "search cleared"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "selected"

    Setup.resetPDMetatable()
end

return Setup

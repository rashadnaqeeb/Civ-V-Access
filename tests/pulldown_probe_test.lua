-- PullDownProbe tests. Uses a PullDown built from the polyfill factory with
-- its methods promoted onto a shared __index metatable -- the same shape the
-- engine uses, so the probe's monkey-patch applies across all PullDowns
-- created from that factory.

local T = require("support")
local M = {}

local warns
local _shared_mt

local function setup()
    warns = {}
    Log.warn  = function(m) warns[#warns + 1] = m end
    Log.info  = function() end
    Log.error = function() end
    Log.debug = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_PullDownProbe.lua")

    civvaccess_shared.pullDownProbeInstalled = false
    civvaccess_shared.pullDownCallbacks      = {}
    civvaccess_shared.pullDownEntries        = {}
    civvaccess_shared.sliderProbeInstalled   = false
    civvaccess_shared.sliderCallbacks        = {}
    civvaccess_shared.checkBoxProbeInstalled = false
    civvaccess_shared.checkBoxCallbacks      = {}

    -- Fresh metatable per setup so one test's patched __index does not bleed
    -- into another. Instance factory strips methods so lookup falls through.
    local proto = Polyfill.makePullDown()
    _shared_mt = { __index = {
        GetButton                  = proto.GetButton,
        ClearEntries               = proto.ClearEntries,
        BuildEntry                 = proto.BuildEntry,
        CalculateInternals         = proto.CalculateInternals,
        RegisterSelectionCallback  = proto.RegisterSelectionCallback,
        IsHidden                   = proto.IsHidden,
        IsDisabled                 = proto.IsDisabled,
        SetHide                    = proto.SetHide,
        SetDisabled                = proto.SetDisabled,
    }}
end

local function makePD()
    local pd = Polyfill.makePullDown()
    pd.GetButton, pd.ClearEntries, pd.BuildEntry, pd.CalculateInternals = nil, nil, nil, nil
    pd.RegisterSelectionCallback, pd.IsHidden, pd.IsDisabled = nil, nil, nil
    pd.SetHide, pd.SetDisabled = nil, nil
    return setmetatable(pd, _shared_mt)
end

-- ---------------------------------------------------------------------

function M.test_install_idempotent()
    setup()
    local pd = makePD()
    local ok1 = PullDownProbe.ensureInstalled(pd)
    local ok2 = PullDownProbe.ensureInstalled(pd)
    T.truthy(ok1)
    T.truthy(ok2)
    T.eq(civvaccess_shared.pullDownProbeInstalled, true)
end

function M.test_register_selection_callback_is_captured()
    setup()
    local pd = makePD()
    PullDownProbe.ensureInstalled(pd)
    local fn = function() end
    pd:RegisterSelectionCallback(fn)
    T.eq(PullDownProbe.callbackFor(pd), fn)
end

function M.test_build_entry_records_instances_in_order()
    setup()
    local pd = makePD()
    PullDownProbe.ensureInstalled(pd)
    pd:ClearEntries()
    local i1, i2 = {}, {}
    pd:BuildEntry("InstanceOne", i1)
    pd:BuildEntry("InstanceOne", i2)
    local list = PullDownProbe.entriesFor(pd)
    T.eq(#list, 2)
    T.eq(list[1], i1)
    T.eq(list[2], i2)
end

function M.test_clear_entries_wipes_list()
    setup()
    local pd = makePD()
    PullDownProbe.ensureInstalled(pd)
    pd:BuildEntry("InstanceOne", {})
    pd:BuildEntry("InstanceOne", {})
    T.eq(#PullDownProbe.entriesFor(pd), 2)
    pd:ClearEntries()
    T.eq(PullDownProbe.entriesFor(pd), nil, "entries table cleared for pd")
end

function M.test_install_on_sample_affects_other_pulldowns()
    setup()
    local a = makePD()
    PullDownProbe.ensureInstalled(a)
    local b = makePD()  -- shares the same __index table now patched
    b:RegisterSelectionCallback(function() end)
    T.truthy(PullDownProbe.callbackFor(b), "patch covers sibling pulldowns")
end

function M.test_install_logs_warn_when_sample_has_no_metatable()
    setup()
    local bare = {}  -- no metatable
    local ok = PullDownProbe.ensureInstalled(bare)
    T.falsy(ok)
    T.truthy(#warns >= 1)
end

function M.test_install_without_sample_logs_warn()
    setup()
    local ok = PullDownProbe.ensureInstalled(nil)
    T.falsy(ok)
    T.truthy(#warns >= 1)
end

-- Slider probe --------------------------------------------------------

function M.test_slider_probe_captures_callback()
    setup()
    local protoS = Polyfill.makeSlider()
    local sliderMt = { __index = {
        SetValue                = protoS.SetValue,
        GetValue                = protoS.GetValue,
        RegisterSliderCallback  = protoS.RegisterSliderCallback,
        SetVoid1                = protoS.SetVoid1,
        GetVoid1                = protoS.GetVoid1,
        IsHidden                = protoS.IsHidden,
        IsDisabled              = protoS.IsDisabled,
    }}
    local function mkSlider()
        local s = Polyfill.makeSlider()
        s.SetValue, s.GetValue, s.RegisterSliderCallback = nil, nil, nil
        s.SetVoid1, s.GetVoid1, s.IsHidden, s.IsDisabled = nil, nil, nil, nil
        return setmetatable(s, sliderMt)
    end

    local sld = mkSlider()
    T.truthy(PullDownProbe.ensureSliderInstalled(sld))
    local fn = function() end
    sld:RegisterSliderCallback(fn)
    T.eq(PullDownProbe.sliderCallbackFor(sld), fn)
end

function M.test_slider_probe_with_function_index()
    setup()
    -- Engine userdata metatables expose __index as a function; verify the
    -- probe handles that path by constructing an artificial function-index
    -- metatable.
    local protoS = Polyfill.makeSlider()
    local methodTable = {
        SetValue                = protoS.SetValue,
        GetValue                = protoS.GetValue,
        RegisterSliderCallback  = protoS.RegisterSliderCallback,
    }
    local sliderMt = {
        __index = function(self, key) return methodTable[key] end,
    }
    local function mkSlider()
        local s = Polyfill.makeSlider()
        s.SetValue, s.GetValue, s.RegisterSliderCallback = nil, nil, nil
        s.SetVoid1, s.GetVoid1, s.IsHidden, s.IsDisabled = nil, nil, nil, nil
        s.SetHide, s.SetDisabled = nil, nil
        return setmetatable(s, sliderMt)
    end

    local sld = mkSlider()
    T.truthy(PullDownProbe.ensureSliderInstalled(sld))
    local fn = function() end
    sld:RegisterSliderCallback(fn)
    T.eq(PullDownProbe.sliderCallbackFor(sld), fn)
    -- Non-probed methods still work via the wrapped __index.
    sld:SetValue(0.75)
    T.eq(sld:GetValue(), 0.75)
end

-- CheckBox probe ------------------------------------------------------

function M.test_checkbox_probe_captures_handler()
    setup()
    local proto = Polyfill.makeCheckBox()
    local mt = { __index = {
        IsChecked            = proto.IsChecked,
        SetCheck             = proto.SetCheck,
        RegisterCheckHandler = proto.RegisterCheckHandler,
    }}
    local function mkCB()
        local c = Polyfill.makeCheckBox()
        c.IsChecked, c.SetCheck, c.RegisterCheckHandler = nil, nil, nil
        c.IsHidden, c.IsDisabled, c.SetHide, c.SetDisabled = nil, nil, nil, nil
        return setmetatable(c, mt)
    end

    local cb = mkCB()
    T.truthy(PullDownProbe.ensureCheckBoxInstalled(cb))
    local fn = function() end
    cb:RegisterCheckHandler(fn)
    T.eq(PullDownProbe.checkBoxCallbackFor(cb), fn)
end

return M

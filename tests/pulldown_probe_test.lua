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

return M

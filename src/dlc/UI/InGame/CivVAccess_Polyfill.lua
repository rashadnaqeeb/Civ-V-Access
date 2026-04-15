-- Stubs engine globals for the offline test harness. In-game, ContextPtr is
-- always present, so this file no-ops and the real engine globals win.
-- Sentinel: ContextPtr (present in every Civ V UI Context, absent in tests).

if ContextPtr ~= nil then return end

civvaccess_shared = civvaccess_shared or {}

Locale = Locale or {
    ConvertTextKey = function(key) return key end,
}

UI = UI or {
    ShiftKeyDown = function() return false end,
    CtrlKeyDown  = function() return false end,
    AltKeyDown   = function() return false end,
}

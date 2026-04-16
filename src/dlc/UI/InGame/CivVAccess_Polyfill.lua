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

-- Windows virtual-key codes. Subset that the mod's bindings actually name by
-- Keys.* rather than numeric literal; grow this list as new bindings appear.
Keys = Keys or {
    VK_RETURN = 13,
    VK_ESCAPE = 27,
    VK_END    = 35,
    VK_HOME   = 36,
    VK_LEFT   = 37,
    VK_UP     = 38,
    VK_RIGHT  = 39,
    VK_DOWN   = 40,
}

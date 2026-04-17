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

Events = Events or {
    AudioPlay2DSound = function(_scriptID) end,
}

-- Windows virtual-key codes. Subset that the mod's bindings actually name by
-- Keys.* rather than numeric literal; grow this list as new bindings appear.
Keys = Keys or {
    VK_SPACE  = 32,
    VK_RETURN = 13,
    VK_ESCAPE = 27,
    VK_TAB    =  9,
    VK_END    = 35,
    VK_HOME   = 36,
    VK_LEFT   = 37,
    VK_UP     = 38,
    VK_RIGHT  = 39,
    VK_DOWN   = 40,
}

-- Widget factories for FormHandler unit tests. The engine backs these with
-- userdata + metatables; offline we use plain tables with methods so tests
-- can inspect and drive them. Real engine semantics mirrored:
--   Slider  - SetValue clamps 0..1 then fires the slider callback
--   CheckBox - SetCheck(v) stores the bool; IsChecked returns it
--   PullDown - BuildEntry appends an instance; RegisterSelectionCallback
--              stores the fn; GetButton returns the label button
Polyfill = Polyfill or {}

function Polyfill.makeLabel(initialText)
    local self = { _text = initialText or "" }
    function self:SetText(s) self._text = s or "" end
    function self:GetText()  return self._text end
    function self:LocalizeAndSetText(k, ...) self._text = Locale.ConvertTextKey(k, ...) end
    function self:IsHidden() return false end
    function self:IsDisabled() return false end
    function self:SetHide() end
    function self:SetDisabled() end
    function self:SetAlpha() end
    return self
end

function Polyfill.makeButton()
    local self = { _void1 = nil, _void2 = nil, _text = "" }
    function self:SetText(s) self._text = s or "" end
    function self:GetText() return self._text end
    function self:LocalizeAndSetText(k, ...) self._text = Locale.ConvertTextKey(k, ...) end
    function self:LocalizeAndSetToolTip() end
    function self:SetToolTipString() end
    function self:SetVoid1(v) self._void1 = v end
    function self:SetVoid2(v) self._void2 = v end
    function self:SetVoids(v1, v2) self._void1, self._void2 = v1, v2 end
    function self:GetVoid1() return self._void1 end
    function self:GetVoid2() return self._void2 end
    function self:SetHide() end
    function self:SetDisabled() end
    return self
end

function Polyfill.makeSlider(opts)
    opts = opts or {}
    local self = {
        _value   = opts.value or 0,
        _hidden  = false,
        _disabled = false,
        _cb      = nil,
        _void1   = nil,
    }
    function self:SetValue(v)
        if v < 0 then v = 0 elseif v > 1 then v = 1 end
        self._value = v
        if self._cb then self._cb(v, self._void1) end
    end
    function self:GetValue() return self._value end
    function self:RegisterSliderCallback(fn) self._cb = fn end
    function self:SetVoid1(v) self._void1 = v end
    function self:GetVoid1() return self._void1 end
    function self:IsHidden() return self._hidden end
    function self:IsDisabled() return self._disabled end
    function self:SetHide(h) self._hidden = h and true or false end
    function self:SetDisabled(d) self._disabled = d and true or false end
    return self
end

function Polyfill.makeCheckBox(opts)
    opts = opts or {}
    local self = {
        _checked  = opts.checked and true or false,
        _hidden   = false,
        _disabled = false,
        _cb       = nil,
    }
    function self:IsChecked() return self._checked end
    function self:SetCheck(v)
        self._checked = v and true or false
        if self._cb then self._cb(self._checked) end
    end
    function self:RegisterCheckHandler(fn) self._cb = fn end
    function self:IsHidden() return self._hidden end
    function self:IsDisabled() return self._disabled end
    function self:SetHide(h) self._hidden = h and true or false end
    function self:SetDisabled(d) self._disabled = d and true or false end
    return self
end

function Polyfill.makePullDown()
    local button = Polyfill.makeButton()
    local self = {
        _button    = button,
        _entries   = {},
        _selectCB  = nil,
        _hidden    = false,
        _disabled  = false,
    }
    function self:GetButton() return self._button end
    function self:ClearEntries() self._entries = {} end
    function self:BuildEntry(_stem, instance)
        instance = instance or {}
        instance.Button = instance.Button or Polyfill.makeButton()
        self._entries[#self._entries + 1] = instance
        return instance
    end
    function self:CalculateInternals() end
    function self:RegisterSelectionCallback(fn) self._selectCB = fn end
    function self:IsHidden() return self._hidden end
    function self:IsDisabled() return self._disabled end
    function self:SetHide(h) self._hidden = h and true or false end
    function self:SetDisabled(d) self._disabled = d and true or false end
    return self
end

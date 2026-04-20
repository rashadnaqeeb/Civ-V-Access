-- Stubs engine globals for the offline test harness. In-game, ContextPtr is
-- always present, so this file no-ops and the real engine globals win.
-- Sentinel: ContextPtr (present in every Civ V UI Context, absent in tests).

if ContextPtr ~= nil then return end

civvaccess_shared = civvaccess_shared or {}

Locale = Locale or {
    ConvertTextKey = function(key) return key end,
}

UI = UI or {
    ShiftKeyDown      = function() return false end,
    CtrlKeyDown       = function() return false end,
    AltKeyDown        = function() return false end,
    LookAt            = function(_plot, _flag) end,
    GetHeadSelectedUnit = function() return nil end,
}

Events = Events or {
    AudioPlay2DSound = function(_scriptID) end,
}

-- Map / Game / Players / Teams / GameInfo are populated by the engine in-game.
-- Offline tests overwrite these tables per-suite to drive the cursor; the
-- polyfill's job is just to ensure the names resolve so the Cursor / sections
-- modules dofile without indexing nil at top level. Stub functions return
-- engine-equivalent "nothing here" sentinels so a section that runs against
-- the bare polyfill (no test setup) silently produces no output rather than
-- crashing.
Map = Map or {
    GetPlot       = function(_x, _y) return nil end,
    GetPlotXY     = function(_x, _y, _dx, _dy) return nil end,
    PlotDirection = function(_x, _y, _dir) return nil end,
    PlotDistance  = function(_x1, _y1, _x2, _y2) return 0 end,
    GetGridSize   = function() return 0, 0 end,
    GetNumPlots   = function() return 0 end,
    IsWrapX       = function() return false end,
    IsWrapY       = function() return false end,
}

Game = Game or {
    GetActivePlayer = function() return 0 end,
    GetActiveTeam   = function() return 0 end,
    IsDebugMode     = function() return false end,
}

Players  = Players  or {}
Teams    = Teams    or {}
GameInfo = GameInfo or {}

DirectionTypes = DirectionTypes or {
    NO_DIRECTION         = -1,
    DIRECTION_NORTHEAST  = 0,
    DIRECTION_EAST       = 1,
    DIRECTION_SOUTHEAST  = 2,
    DIRECTION_SOUTHWEST  = 3,
    DIRECTION_WEST       = 4,
    DIRECTION_NORTHWEST  = 5,
}

-- Engine values are PLOT_MOUNTAIN=0, PLOT_HILLS=1, PLOT_LAND=2, PLOT_OCEAN=3.
-- Tests can assert against these names regardless of the underlying number.
PlotTypes = PlotTypes or {
    NO_PLOT       = -1,
    PLOT_MOUNTAIN = 0,
    PLOT_HILLS    = 1,
    PLOT_LAND     = 2,
    PLOT_OCEAN    = 3,
}

FeatureTypes = FeatureTypes or { NO_FEATURE = -1 }
TerrainTypes = TerrainTypes or { NO_TERRAIN = -1 }
ResourceTypes = ResourceTypes or { NO_RESOURCE = -1 }
ImprovementTypes = ImprovementTypes or { NO_IMPROVEMENT = -1 }
RouteTypes = RouteTypes or { NO_ROUTE = -1 }

YieldTypes = YieldTypes or {
    YIELD_FOOD       = 0,
    YIELD_PRODUCTION = 1,
    YIELD_GOLD       = 2,
    YIELD_SCIENCE    = 3,
    YIELD_CULTURE    = 4,
    YIELD_FAITH      = 5,
}

DomainTypes = DomainTypes or {
    DOMAIN_LAND  = 0,
    DOMAIN_SEA   = 1,
    DOMAIN_AIR   = 2,
    DOMAIN_HOVER = 3,
}

GameDefines = GameDefines or { MAX_HIT_POINTS = 100 }

-- Mouse event constants. Engine exposes these; offline we just need a few
-- distinct numbers for tests that register per-button click callbacks.
Mouse = Mouse or {
    eLClick  = 1,
    eRClick  = 2,
    eMClick  = 3,
}

-- Civ V's Keys enum: letter keys are `Keys.<letter>` (no VK_ prefix),
-- special keys use VK_. Grow this list as new bindings appear.
Keys = Keys or {
    VK_BACK   =  8,
    VK_TAB    =  9,
    VK_RETURN = 13,
    VK_ESCAPE = 27,
    VK_SPACE  = 32,
    VK_END    = 35,
    VK_HOME   = 36,
    VK_LEFT   = 37,
    VK_UP     = 38,
    VK_RIGHT  = 39,
    VK_DOWN   = 40,
    A         = 65,
    C         = 67,
    D         = 68,
    E         = 69,
    N         = 78,
    Q         = 81,
    S         = 83,
    W         = 87,
    X         = 88,
    Y         = 89,
    Z         = 90,
    VK_F1     = 112,
    VK_F2     = 113,
}

-- Widget factories for BaseMenu + BaseMenuItems unit tests. The engine backs these with
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
    local self = {
        _void1 = nil, _void2 = nil, _text = "",
        _hasFocus = false, _hidden = false, _disabled = false,
        _cbs = {},
    }
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
    function self:IsHidden() return self._hidden end
    function self:IsDisabled() return self._disabled end
    function self:SetHide(h) self._hidden = h and true or false end
    function self:SetDisabled(d) self._disabled = d and true or false end
    function self:TakeFocus() self._hasFocus = true end
    function self:RegisterCallback(mouseEvent, fn) self._cbs[mouseEvent] = fn end
    return self
end

-- Slider / CheckBox polyfills intentionally do NOT fire the registered
-- callback from SetValue / SetCheck: the real engine only fires those on
-- mouse interaction, not on programmatic state changes. BaseMenuItems.Slider
-- / BaseMenuItems.Checkbox invoke the captured callback via PullDownProbe
-- after each SetValue / SetCheck, and the polyfill mirrors that so tests
-- exercise the same code path as the game.
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
    end
    function self:RegisterCheckHandler(fn) self._cb = fn end
    function self:IsHidden() return self._hidden end
    function self:IsDisabled() return self._disabled end
    function self:SetHide(h) self._hidden = h and true or false end
    function self:SetDisabled(d) self._disabled = d and true or false end
    return self
end

function Polyfill.makeEditBox(opts)
    opts = opts or {}
    local self = {
        _text      = opts.text or "",
        _hidden    = false,
        _disabled  = false,
        _cb        = nil,
        _hasFocus  = false,
    }
    function self:GetText() return self._text end
    function self:SetText(s) self._text = s or "" end
    function self:ClearString() self._text = "" end
    function self:RegisterCallback(fn) self._cb = fn end
    function self:TakeFocus() self._hasFocus = true end
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

-- Strip instance methods off a makePullDown polyfill and attach `mt` so
-- method lookups fall through to __index. Tests use this to simulate the
-- engine's shared-metatable dispatch so PullDownProbe can patch the
-- metatable exactly as it does in-game. Keeping the strip list in one
-- place protects against drift if makePullDown gains a new method.
function Polyfill.makePullDownWithMetatable(mt)
    local pd = Polyfill.makePullDown()
    pd.GetButton                 = nil
    pd.ClearEntries              = nil
    pd.BuildEntry                = nil
    pd.CalculateInternals        = nil
    pd.RegisterSelectionCallback = nil
    pd.IsHidden                  = nil
    pd.IsDisabled                = nil
    pd.SetHide                   = nil
    pd.SetDisabled               = nil
    return setmetatable(pd, mt)
end

-- Strip instance methods off a makeButton polyfill and attach `mt` so
-- method lookups fall through to __index. Used by tests that exercise the
-- button probe's per-click RegisterCallback capture.
function Polyfill.makeButtonWithMetatable(mt)
    local b = Polyfill.makeButton()
    b.SetText             = nil
    b.GetText             = nil
    b.LocalizeAndSetText  = nil
    b.LocalizeAndSetToolTip = nil
    b.SetToolTipString    = nil
    b.SetVoid1            = nil
    b.SetVoid2            = nil
    b.SetVoids            = nil
    b.GetVoid1            = nil
    b.GetVoid2            = nil
    b.IsHidden            = nil
    b.IsDisabled          = nil
    b.SetHide             = nil
    b.SetDisabled         = nil
    b.TakeFocus           = nil
    b.RegisterCallback    = nil
    return setmetatable(b, mt)
end

-- Polymorphic item factories for the Menu container. Each factory validates
-- its spec, resolves control references, and returns a table with a common
-- method interface: isNavigable / isActivatable / announce / activate / adjust.
-- The Menu container calls these methods without knowing the item kind, so
-- new kinds (drill-in, production picker) slot in without touching Menu.
--
-- Shared speech composition: table.concat(parts, ", ") + optional "disabled"
-- suffix + tooltip (deduped against existing segments). The tooltip dedupe
-- drops sentences that repeat a label/value the user just heard.
--
-- Common spec fields (all item kinds):
--   controlName              XML id on Controls. Required unless `control` is
--                            supplied for InstanceManager-built widgets with
--                            no stable Controls.X entry.
--   control                  direct userdata, wins over controlName.
--   textKey / labelText      label source (TXT_KEY or pre-localized literal).
--   labelFn                  fn(control) returning a label string; used when
--                            the label is driven by the engine at runtime.
--   tooltipKey / tooltipText static tooltip sources (TXT_KEY vs literal).
--   tooltipFn                fn(control) returning a dynamic tooltip string.

MenuItems = {}

local STEP_SMALL = 0.01
local STEP_BIG   = 0.10

-- Label / tooltip resolution ----------------------------------------------

local function resolveLabel(item)
    if item.labelText ~= nil then return item.labelText end
    if item.labelFn ~= nil then
        local ok, result = pcall(item.labelFn, item._control)
        if not ok then
            Log.error("MenuItems labelFn '" .. tostring(item.controlName)
                .. "' failed: " .. tostring(result))
            return ""
        end
        return result or ""
    end
    return Text.key(item.textKey)
end

local function resolveTooltip(item)
    if item.tooltipFn ~= nil then
        local ok, result = pcall(item.tooltipFn, item._control)
        if not ok then
            Log.error("MenuItems tooltipFn '" .. tostring(item.controlName)
                .. "' failed: " .. tostring(result))
            return nil
        end
        if result == nil or result == "" then return nil end
        return tostring(result)
    end
    if item.tooltipText ~= nil and item.tooltipText ~= "" then
        return item.tooltipText
    end
    if item.tooltipKey == nil then return nil end
    local t = Text.key(item.tooltipKey)
    if t == nil or t == "" then return nil end
    return t
end

-- Drop any tooltip sentence that duplicates an existing ", "-separated
-- segment in `base`. Sentences separated by ". " in localized tooltip text.
-- Adapted from oni-access's WidgetOps.AppendTooltip.
local function appendTooltip(base, tooltip)
    if tooltip == nil or tooltip == "" then return base end
    if base == nil or base == "" then return tooltip end

    local seen = {}
    for segment in string.gmatch(base, "([^,]+)") do
        local trimmed = segment:match("^%s*(.-)%s*$")
        if trimmed ~= "" then seen[trimmed] = true end
    end

    local novel = {}
    for sentence in string.gmatch(tooltip, "([^%.]+)") do
        local trimmed = sentence:match("^%s*(.-)%s*$")
        if trimmed ~= "" and not seen[trimmed] then
            novel[#novel + 1] = trimmed
        end
    end

    if #novel == 0 then return base end
    return base .. ", " .. table.concat(novel, ", ")
end

MenuItems.appendTooltip = appendTooltip
MenuItems.labelOf       = resolveLabel

-- Shared navigability / activability --------------------------------------

local function isNavigable(self)
    if self._control == nil or self._control:IsHidden() then return false end
    if self._visibilityControl ~= nil and self._visibilityControl:IsHidden() then
        return false
    end
    return true
end

local function isActivatable(self)
    if not isNavigable(self) then return false end
    return not self._control:IsDisabled()
end

local function composeSpeech(item, parts)
    if not isActivatable(item) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
    end
    local base = table.concat(parts, ", ")
    return appendTooltip(base, resolveTooltip(item))
end

-- Resolution helpers ------------------------------------------------------

local function resolveControl(spec, kind)
    if spec.control ~= nil then return spec.control end
    assert(type(spec.controlName) == "string",
        kind .. " needs controlName or control")
    local c = Controls[spec.controlName]
    if c == nil then
        Log.warn("MenuItems " .. kind .. ": missing control '"
            .. spec.controlName .. "'")
    end
    return c
end

local function assertLabel(spec, kind)
    assert(type(spec.textKey) == "string"
        or type(spec.labelText) == "string"
        or type(spec.labelFn) == "function",
        kind .. " needs textKey, labelText, or labelFn")
end

local function assertTooltip(spec, kind)
    assert(spec.tooltipFn == nil or type(spec.tooltipFn) == "function",
        kind .. ".tooltipFn must be a function if provided")
end

local function copyCommonFields(spec, item)
    item.controlName = spec.controlName
    item.textKey     = spec.textKey
    item.labelText   = spec.labelText
    item.labelFn     = spec.labelFn
    item.tooltipKey  = spec.tooltipKey
    item.tooltipText = spec.tooltipText
    item.tooltipFn   = spec.tooltipFn
end

-- Button ------------------------------------------------------------------

function MenuItems.Button(spec)
    assertLabel(spec, "Button")
    assertTooltip(spec, "Button")
    assert(type(spec.activate) == "function",
        "Button '" .. tostring(spec.controlName) .. "' needs activate fn")
    local item = {
        kind      = "button",
        _control  = resolveControl(spec, "Button"),
        _activate = spec.activate,
    }
    copyCommonFields(spec, item)
    item.isNavigable   = isNavigable
    item.isActivatable = isActivatable
    function item:announce(menu)
        return composeSpeech(self, { resolveLabel(self) })
    end
    function item:activate(menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local ok, err = pcall(self._activate)
        if not ok then
            Log.error("Menu '" .. tostring(menu.name) .. "' button '"
                .. tostring(self.controlName) .. "' activate failed: "
                .. tostring(err))
        end
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Checkbox ----------------------------------------------------------------

local function checkboxValue(item)
    local on = item._control:IsChecked()
    return Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON"
                       or "TXT_KEY_CIVVACCESS_CHECK_OFF")
end

function MenuItems.Checkbox(spec)
    assertLabel(spec, "Checkbox")
    assertTooltip(spec, "Checkbox")
    local item = {
        kind     = "checkbox",
        _control = resolveControl(spec, "Checkbox"),
    }
    copyCommonFields(spec, item)
    item.isNavigable   = isNavigable
    item.isActivatable = isActivatable
    function item:announce(menu)
        return composeSpeech(self, { resolveLabel(self), checkboxValue(self) })
    end
    function item:activate(menu)
        local c = self._control
        local newValue = not c:IsChecked()
        c:SetCheck(newValue)
        local cb = PullDownProbe.checkBoxCallbackFor(c)
        if cb == nil then
            Log.warn("Menu checkbox '" .. tostring(self.controlName)
                .. "': callback not captured, game state will not update")
        else
            local ok, err = pcall(cb, newValue)
            if not ok then
                Log.error("Menu checkbox '" .. tostring(self.controlName)
                    .. "' callback failed: " .. tostring(err))
            end
        end
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Slider ------------------------------------------------------------------

local function sliderCompositeLabel(item)
    local labelCtrl = item._labelControl
    if labelCtrl == nil then return nil end
    local ok, value = pcall(function() return labelCtrl:GetText() end)
    if not ok or value == nil or value == "" then return nil end
    return tostring(value)
end

local function clampUnit(v)
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

local function fireSliderCallback(item, newValue)
    local cb = PullDownProbe.sliderCallbackFor(item._control)
    if cb == nil then
        Log.warn("Menu slider '" .. tostring(item.controlName)
            .. "': callback not captured, game state will not update")
        return
    end
    local void1
    local okV, v = pcall(function() return item._control:GetVoid1() end)
    if okV then void1 = v end
    local ok, err = pcall(cb, newValue, void1)
    if not ok then
        Log.error("Menu slider '" .. tostring(item.controlName)
            .. "' callback failed: " .. tostring(err))
    end
end

function MenuItems.Slider(spec)
    assertLabel(spec, "Slider")
    assertTooltip(spec, "Slider")
    assert(type(spec.labelControlName) == "string",
        "Slider '" .. tostring(spec.controlName) .. "' needs labelControlName")
    local labelCtrl = Controls[spec.labelControlName]
    if labelCtrl == nil then
        Log.warn("MenuItems Slider '" .. tostring(spec.controlName)
            .. "': missing label control '" .. spec.labelControlName .. "'")
    end
    local item = {
        kind             = "slider",
        _control         = resolveControl(spec, "Slider"),
        _labelControl    = labelCtrl,
        labelControlName = spec.labelControlName,
        step             = spec.step    or STEP_SMALL,
        bigStep          = spec.bigStep or STEP_BIG,
    }
    copyCommonFields(spec, item)
    item.isNavigable   = isNavigable
    item.isActivatable = isActivatable
    function item:announce(menu)
        -- Civ V's composite slider label is populated by the screen's
        -- RegisterSliderCallback with a "Label: Value" string; the textKey
        -- is just a format template. Read the label control when populated;
        -- otherwise fall back to the textKey.
        local composite = sliderCompositeLabel(self)
        local parts
        if composite ~= nil and composite ~= "" then
            parts = { composite }
        else
            parts = { resolveLabel(self) }
        end
        return composeSpeech(self, parts)
    end
    function item:activate(menu)
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    function item:adjust(menu, dir, big)
        if not isActivatable(self) then return end
        local delta = (big and self.bigStep or self.step) * dir
        local c = self._control
        local cur = c:GetValue()
        local next = clampUnit(cur + delta)
        if next == cur then
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        c:SetValue(next)
        fireSliderCallback(self, next)
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    return item
end

-- Pulldown ----------------------------------------------------------------

local function pulldownCurrentValue(item)
    local c = item._control
    local ok, btn = pcall(function() return c:GetButton() end)
    if not ok or btn == nil then return nil end
    local ok2, text = pcall(function() return btn:GetText() end)
    if not ok2 or text == nil or text == "" then return nil end
    return tostring(text)
end

-- Child item class for pulldown entries. Not a public factory; built inline
-- when Pulldown.activate opens the sub-menu. Forwards the live entry's
-- void1/void2 to the captured selection callback and pops the child.
local function buildChoice(button, callback, parentControlName)
    local choice = {
        kind      = "choice",
        _control  = button,
        _button   = button,
        _callback = callback,
    }
    function choice:isNavigable()   return self._button ~= nil end
    function choice:isActivatable() return self._button ~= nil end
    function choice:announce(menu)
        local ok, t = pcall(function() return self._button:GetText() end)
        if not ok or t == nil or t == "" then
            Log.warn("Menu pulldown '" .. tostring(parentControlName)
                .. "' entry has no text")
            return ""
        end
        return t
    end
    function choice:activate(menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local v1, v2
        pcall(function() v1 = self._button:GetVoid1(); v2 = self._button:GetVoid2() end)
        local ok, err = pcall(self._callback, v1, v2)
        if not ok then
            Log.error("Menu pulldown '" .. tostring(parentControlName)
                .. "' callback failed: " .. tostring(err))
        end
        HandlerStack.removeByName(menu.name, true)
    end
    function choice:adjust(menu, dir, big) end
    return choice
end

function MenuItems.Pulldown(spec)
    assertLabel(spec, "Pulldown")
    assertTooltip(spec, "Pulldown")
    local item = {
        kind     = "pulldown",
        _control = resolveControl(spec, "Pulldown"),
    }
    copyCommonFields(spec, item)
    item.isNavigable   = isNavigable
    item.isActivatable = isActivatable
    function item:announce(menu)
        local v = pulldownCurrentValue(self)
        local parts
        if v ~= nil and v ~= "" then
            parts = { resolveLabel(self), v }
        else
            parts = { resolveLabel(self) }
        end
        return composeSpeech(self, parts)
    end
    function item:activate(menu)
        local pulldown = self._control
        local callback = PullDownProbe.callbackFor(pulldown)
        local entries  = PullDownProbe.entriesFor(pulldown)
        if callback == nil or entries == nil or #entries == 0 then
            Log.warn("Menu '" .. menu.name .. "' pulldown '"
                .. tostring(self.controlName) .. "': "
                .. (callback == nil and "callback not captured"
                                     or "no entries captured"))
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local subName = menu.name .. "/" .. tostring(self.controlName) .. "_PullDown"
        local childItems = {}
        for i, inst in ipairs(entries) do
            childItems[i] = buildChoice(inst.Button, callback, self.controlName)
        end
        local child = Menu.create({
            name        = subName,
            displayName = resolveLabel(self),
            items       = childItems,
            escapePops  = true,
        })
        HandlerStack.push(child)
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Textfield ---------------------------------------------------------------

local function textfieldCurrentValue(item)
    local ok, text = pcall(function() return item._control:GetText() end)
    if not ok or text == nil or text == "" then
        return Text.key("TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK")
    end
    return tostring(text)
end

-- Shared with EditMode in Menu.lua for commit-value announcement.
MenuItems._textfieldCurrentValue = textfieldCurrentValue

function MenuItems.Textfield(spec)
    assertLabel(spec, "Textfield")
    assertTooltip(spec, "Textfield")
    assert(spec.priorCallback == nil or type(spec.priorCallback) == "function",
        "Textfield '" .. tostring(spec.controlName)
        .. "' priorCallback must be a function")
    local item = {
        kind          = "textfield",
        _control      = resolveControl(spec, "Textfield"),
        priorCallback = spec.priorCallback,
    }
    copyCommonFields(spec, item)
    if spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl    = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn("MenuItems Textfield '" .. tostring(spec.controlName)
                .. "': missing visibility control '"
                .. spec.visibilityControlName .. "'")
        end
    end
    item.isNavigable   = isNavigable
    item.isActivatable = isActivatable
    function item:announce(menu)
        return composeSpeech(self, {
            resolveLabel(self),
            Text.key("TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"),
            textfieldCurrentValue(self),
        })
    end
    function item:activate(menu)
        Menu._pushEdit(menu, self)
    end
    function item:adjust(menu, dir, big) end
    return item
end

return MenuItems

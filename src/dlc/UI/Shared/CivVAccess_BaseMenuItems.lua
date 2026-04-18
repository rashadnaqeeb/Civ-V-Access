-- Polymorphic item factories for the BaseMenu container. Each factory validates
-- its spec, resolves control references, and returns a table with a common
-- method interface: isNavigable / isActivatable / announce / activate / adjust.
-- The BaseMenu container calls these methods without knowing the item kind, so
-- new kinds (drill-in, production picker) slot in without touching BaseMenu.
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

BaseMenuItems = {}

local STEP_SMALL = 0.01
local STEP_BIG   = 0.10

-- Label / tooltip resolution ----------------------------------------------

local function resolveLabel(item)
    if item.labelText ~= nil then return item.labelText end
    if item.labelFn ~= nil then
        local ok, result = pcall(item.labelFn, item._control)
        if not ok then
            Log.error("BaseMenuItems labelFn '" .. tostring(item.controlName)
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
            Log.error("BaseMenuItems tooltipFn '" .. tostring(item.controlName)
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

BaseMenuItems.appendTooltip = appendTooltip
BaseMenuItems.labelOf       = resolveLabel

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
    -- Dispatch through the method so item kinds without a _control (Choice,
    -- future drill-in kinds) use their own isActivatable rather than the
    -- shared control-based one which would always return false for them.
    if not item:isActivatable() then
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
        Log.warn("BaseMenuItems " .. kind .. ": missing control '"
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

function BaseMenuItems.Button(spec)
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
            Log.error("BaseMenu '" .. tostring(menu.name) .. "' button '"
                .. tostring(self.controlName) .. "' activate failed: "
                .. tostring(err))
        end
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Text --------------------------------------------------------------------
--
-- Informational list entry with no widget backing. Navigable (Up/Down land
-- on it) but activation is a no-op: Enter plays the standard click and
-- returns. Used by the Help overlay where each entry is "keyLabel,
-- description" read-only text -- there's no XML control, no disabled state,
-- no tooltip dedup needed. Reuses composeSpeech would call _control:IsDisabled
-- which would NPE, so announce builds the speech directly.

function BaseMenuItems.Text(spec)
    assertLabel(spec, "Text")
    assertTooltip(spec, "Text")
    local item = { kind = "text" }
    copyCommonFields(spec, item)
    function item:isNavigable() return true end
    function item:isActivatable() return true end
    function item:announce(menu)
        return appendTooltip(resolveLabel(self), resolveTooltip(self))
    end
    function item:activate(menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
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

function BaseMenuItems.Checkbox(spec)
    assertLabel(spec, "Checkbox")
    assertTooltip(spec, "Checkbox")
    assert(spec.activateCallback == nil or type(spec.activateCallback) == "function",
        "Checkbox.activateCallback must be a function if provided")
    local item = {
        kind              = "checkbox",
        _control          = resolveControl(spec, "Checkbox"),
        _activateCallback = spec.activateCallback,
    }
    if spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl    = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn("BaseMenuItems Checkbox '" .. tostring(spec.controlName)
                .. "': missing visibility control '"
                .. spec.visibilityControlName .. "'")
        end
    end
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
        -- Prefer an explicit activateCallback: base-game screens that wire
        -- checkboxes via Controls.X:RegisterCallback(Mouse.eLClick, ...)
        -- rather than RegisterCheckHandler are not captured by the probe.
        local cb = self._activateCallback or PullDownProbe.checkBoxCallbackFor(c)
        if cb == nil then
            Log.warn("BaseMenu checkbox '" .. tostring(self.controlName)
                .. "': callback not captured, game state will not update")
        else
            local ok, err = pcall(cb, newValue)
            if not ok then
                Log.error("BaseMenu checkbox '" .. tostring(self.controlName)
                    .. "' callback failed: " .. tostring(err))
            end
        end
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Choice ------------------------------------------------------------------
--
-- Flat list entry for a selection screen (Select{MapType,MapSize,Difficulty,
-- GameSpeed,Civilization}, pulldown-style sub-menus, scrollable picker
-- screens). Unlike Button, Choice does not require a stable Controls.X
-- reference: selection screens build their entries via InstanceManager and
-- each entry's data lives in GameInfo / captured closures, not in a named
-- control.
--
-- Spec:
--   textKey / labelText / labelFn   label source (one required)
--   tooltipKey / tooltipText / tooltipFn  optional tooltip
--   activate                         fn() called on Enter / Space
--   visibilityControl                optional live userdata; isNavigable
--                                    returns false while it IsHidden
--   visibilityControlName            alternative: look up Controls.X
--
-- No _control field: items without a widget are always navigable unless
-- a visibility control gates them. Selection is expected to drive the
-- screen's own close / commit path (e.g. OnBack), which fires ShowHide and
-- pops the handler; Choice itself does not touch the handler stack.

function BaseMenuItems.Choice(spec)
    assertLabel(spec, "Choice")
    assertTooltip(spec, "Choice")
    assert(type(spec.activate) == "function",
        "Choice needs activate fn")
    local item = {
        kind               = "choice",
        _activate          = spec.activate,
        _visibilityControl = spec.visibilityControl,
    }
    if item._visibilityControl == nil and spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl    = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn("BaseMenuItems Choice: missing visibility control '"
                .. spec.visibilityControlName .. "'")
        end
    end
    copyCommonFields(spec, item)
    function item:isNavigable()
        if self._visibilityControl ~= nil and self._visibilityControl:IsHidden() then
            return false
        end
        return true
    end
    function item:isActivatable() return self:isNavigable() end
    function item:announce(menu)
        return composeSpeech(self, { resolveLabel(self) })
    end
    function item:activate(menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local ok, err = pcall(self._activate)
        if not ok then
            Log.error("BaseMenu '" .. tostring(menu.name) .. "' choice activate failed: "
                .. tostring(err))
        end
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
        Log.warn("BaseMenu slider '" .. tostring(item.controlName)
            .. "': callback not captured, game state will not update")
        return
    end
    local void1
    local okV, v = pcall(function() return item._control:GetVoid1() end)
    if okV then void1 = v end
    local ok, err = pcall(cb, newValue, void1)
    if not ok then
        Log.error("BaseMenu slider '" .. tostring(item.controlName)
            .. "' callback failed: " .. tostring(err))
    end
end

function BaseMenuItems.Slider(spec)
    assertLabel(spec, "Slider")
    assertTooltip(spec, "Slider")
    assert(type(spec.labelControlName) == "string",
        "Slider '" .. tostring(spec.controlName) .. "' needs labelControlName")
    local labelCtrl = Controls[spec.labelControlName]
    if labelCtrl == nil then
        Log.warn("BaseMenuItems Slider '" .. tostring(spec.controlName)
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
-- when Pulldown.activate opens the sub-menu.
--
-- Two activation modes:
--   useVoids = true  -> invoke callback(button:GetVoid1(), button:GetVoid2()).
--                      This is the top-level RegisterSelectionCallback path
--                      used by most pulldowns (Select* pulldowns set voids
--                      on each entry and the callback dispatches by id).
--   useVoids = false -> invoke callback() with no args. Used when the
--                      callback came from per-button RegisterCallback (the
--                      map-script option dropdowns wire each entry's button
--                      with its own closure capturing the option id and
--                      value; the closure takes no args).
local function buildChoice(button, callback, useVoids, parentControlName, announceOverride)
    local choice = {
        kind      = "choice",
        _button   = button,
        _callback = callback,
        _useVoids = useVoids,
    }
    function choice:isNavigable()   return self._button ~= nil end
    function choice:isActivatable() return self._button ~= nil end
    function choice:announce(menu)
        -- Pulldowns with a spec.entryAnnounceFn (civ pulldowns, etc.)
        -- supply per-entry rich text that replaces the button-text
        -- default. Override is a thunk the Pulldown activate built with
        -- the inst+index closed over.
        if announceOverride ~= nil then
            local ok, t = pcall(announceOverride)
            if not ok then
                Log.warn("BaseMenu pulldown '" .. tostring(parentControlName)
                    .. "' entryAnnounceFn failed: " .. tostring(t))
            elseif t ~= nil and t ~= "" then
                return tostring(t)
            end
        end
        local ok, t = pcall(function() return self._button:GetText() end)
        if not ok or t == nil or t == "" then
            Log.warn("BaseMenu pulldown '" .. tostring(parentControlName)
                .. "' entry has no text")
            return ""
        end
        -- Per-entry tooltip (info.Help for handicaps, civ.Description for
        -- civs, possibleValue.ToolTip for map-script options). Best-effort:
        -- some Button userdata may not expose GetToolTipString.
        local tipOk, tip = pcall(function() return self._button:GetToolTipString() end)
        if tipOk and tip ~= nil and tip ~= "" then
            return BaseMenuItems.appendTooltip(t, tostring(tip))
        end
        return t
    end
    function choice:activate(menu)
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local ok, err
        if self._useVoids then
            local v1, v2
            pcall(function() v1 = self._button:GetVoid1(); v2 = self._button:GetVoid2() end)
            ok, err = pcall(self._callback, v1, v2)
        else
            ok, err = pcall(self._callback)
        end
        if not ok then
            Log.error("BaseMenu pulldown '" .. tostring(parentControlName)
                .. "' callback failed: " .. tostring(err))
        end
        HandlerStack.removeByName(menu.name, true)
    end
    function choice:adjust(menu, dir, big) end
    return choice
end

function BaseMenuItems.Pulldown(spec)
    assertLabel(spec, "Pulldown")
    assertTooltip(spec, "Pulldown")
    assert(spec.valueFn == nil or type(spec.valueFn) == "function",
        "Pulldown.valueFn must be a function if provided")
    assert(spec.entryAnnounceFn == nil or type(spec.entryAnnounceFn) == "function",
        "Pulldown.entryAnnounceFn must be a function if provided")
    local item = {
        kind              = "pulldown",
        _control          = resolveControl(spec, "Pulldown"),
        _valueFn          = spec.valueFn,
        _entryAnnounceFn  = spec.entryAnnounceFn,
    }
    if spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl    = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn("BaseMenuItems Pulldown '" .. tostring(spec.controlName)
                .. "': missing visibility control '"
                .. spec.visibilityControlName .. "'")
        end
    end
    copyCommonFields(spec, item)
    item.isNavigable = isNavigable
    -- Pulldowns override the shared isActivatable to also check the inner
    -- button's IsDisabled. Base code commonly disables the clickable area
    -- via pulldown:GetButton():SetDisabled(true) rather than the pulldown
    -- userdata itself -- e.g., AdvancedSetup disables the Map Size
    -- pulldown's button when the selected map locks to one size. Without
    -- this both-sides check, the pulldown would still report activatable
    -- and let the user open a no-op sub-menu.
    function item:isActivatable()
        if not isNavigable(self) then return false end
        if self._control:IsDisabled() then return false end
        local ok, btn = pcall(function() return self._control:GetButton() end)
        if ok and btn ~= nil then
            local okD, disabled = pcall(function() return btn:IsDisabled() end)
            if okD and disabled then return false end
        end
        return true
    end
    function item:announce(menu)
        -- Team-style pulldowns don't set the button's text; instead a
        -- sibling label (e.g. Controls.TeamLabel) holds the selected
        -- value. Callers pass valueFn to source the value from there.
        local v
        if self._valueFn ~= nil then
            local ok, result = pcall(self._valueFn, self._control)
            if ok and result ~= nil then v = tostring(result) end
        end
        if v == nil then v = pulldownCurrentValue(self) end
        local label = resolveLabel(self)
        local parts
        -- If labelFn was sourced from the button's own text (the civ /
        -- slot pulldown pattern), label and value are identical; emit
        -- once rather than "X, X".
        if v ~= nil and v ~= "" and v ~= label then
            parts = { label, v }
        else
            parts = { label }
        end
        return composeSpeech(self, parts)
    end
    function item:activate(menu)
        local pulldown = self._control
        local topCallback = PullDownProbe.callbackFor(pulldown)
        local entries     = PullDownProbe.entriesFor(pulldown)
        if entries == nil or #entries == 0 then
            Log.warn("BaseMenu '" .. menu.name .. "' pulldown '"
                .. tostring(self.controlName) .. "': no entries captured")
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        -- Two wiring patterns. Most pulldowns have a single
        -- RegisterSelectionCallback that dispatches by void. Map-script
        -- option dropdowns instead wire each entry's button with its own
        -- RegisterCallback(Mouse.eLClick, fn) closure. Prefer the top-level
        -- path when present; otherwise fall back to per-entry button
        -- callbacks (captured by the button probe).
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local subName = menu.name .. "/" .. tostring(self.controlName) .. "_PullDown"
        local childItems = {}
        local currentText = pulldownCurrentValue(self)
        local initialIndex
        local fallbackUsed = 0
        local entryAnnounceFn = self._entryAnnounceFn
        for i, inst in ipairs(entries) do
            local cb = topCallback
            local useVoids = topCallback ~= nil
            if cb == nil then
                cb = PullDownProbe.buttonCallbackFor(inst.Button, Mouse.eLClick)
                if cb ~= nil then fallbackUsed = fallbackUsed + 1 end
            end
            local announceOverride
            if entryAnnounceFn ~= nil then
                local idx = i
                announceOverride = function() return entryAnnounceFn(inst, idx) end
            end
            childItems[i] = buildChoice(inst.Button, cb, useVoids,
                self.controlName, announceOverride)
            if initialIndex == nil and currentText ~= nil then
                local ok, t = pcall(function() return inst.Button:GetText() end)
                if ok and t ~= nil and tostring(t) == currentText then
                    initialIndex = i
                end
            end
        end
        if topCallback == nil and fallbackUsed == 0 then
            Log.warn("BaseMenu '" .. menu.name .. "' pulldown '"
                .. tostring(self.controlName)
                .. "': no top-level callback and no per-entry fallbacks captured")
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        local child = BaseMenu.create({
            name         = subName,
            displayName  = resolveLabel(self),
            items        = childItems,
            initialIndex = initialIndex,
            escapePops   = true,
        })
        HandlerStack.push(child)
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Group -------------------------------------------------------------------
--
-- Nested drill-in item. Announces its label like a button; on Right / Enter
-- the menu switches to the group's children list (one level deeper). The
-- children list can be provided statically as `items`, or lazily as
-- `itemsFn` returning the child list on first access. The result is cached
-- on the instance: subsequent drills into the same Group object reuse the
-- same child objects so indices stay stable and child state (Textfield
-- originalText, cached closures) is preserved across navigation. To force
-- a rebuild (e.g. after Add AI / Remove / Defaults), rebuild the parent
-- list with fresh Group instances rather than mutating an existing one.
--
-- Spec:
--   textKey / labelText / labelFn    label source (one required)
--   tooltipKey / tooltipText / tooltipFn  optional tooltip
--   items                            static array of child items; OR
--   itemsFn                          fn() -> array
--   cached                           default true; when false the itemsFn
--                                    rebuilds on every drill. Use for
--                                    dynamic lists whose contents can
--                                    change between drills without an
--                                    explicit rebuild hook (e.g. game-
--                                    option checkboxes reshaped by a
--                                    map-script pulldown selection).
--                                    Ignored when `items` is provided.
--   visibilityControlName / visibilityControl  gates isNavigable on the
--                                    parent's list (screen-wide conditions
--                                    like random-world-size hiding the
--                                    slots group)
--
-- Groups are not leaves: activate drills; adjust is a no-op (Right drilling
-- is handled by the menu container via kind checks).

function BaseMenuItems.Group(spec)
    assertLabel(spec, "Group")
    assertTooltip(spec, "Group")
    assert(type(spec.items) == "table" or type(spec.itemsFn) == "function",
        "Group needs items or itemsFn")
    local item = {
        kind     = "group",
        _items   = spec.items,
        _itemsFn = spec.itemsFn,
        _cached  = spec.cached ~= false,
        _cache   = nil,
    }
    if spec.visibilityControl ~= nil then
        item._visibilityControl = spec.visibilityControl
    elseif spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl    = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn("BaseMenuItems Group: missing visibility control '"
                .. spec.visibilityControlName .. "'")
        end
    end
    copyCommonFields(spec, item)
    function item:isNavigable()
        if self._visibilityControl ~= nil and self._visibilityControl:IsHidden() then
            return false
        end
        return true
    end
    function item:isActivatable() return self:isNavigable() end
    function item:children()
        if self._cached and self._cache ~= nil then return self._cache end
        local built
        if self._itemsFn ~= nil then
            local ok, result = pcall(self._itemsFn)
            if not ok then
                Log.error("BaseMenuItems Group '"
                    .. tostring(self.textKey or self.labelText or "?")
                    .. "' itemsFn failed: " .. tostring(result))
                built = {}
            else
                built = result or {}
            end
        else
            built = self._items or {}
        end
        if self._cached then self._cache = built end
        return built
    end
    function item:announce(menu)
        return composeSpeech(self, { resolveLabel(self) })
    end
    -- The menu container handles drill semantics (kind == "group" branch in
    -- onEnter / onRight); activate is here for symmetry so any caller that
    -- uses item:activate gets the same drill effect via the container.
    function item:activate(menu)
        -- No-op here: drilling is handled by the container. We could
        -- forward to the container, but doing so would duplicate the kind
        -- check already present in onEnter.
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

-- Shared with EditMode in BaseMenu.lua for commit-value announcement.
BaseMenuItems._textfieldCurrentValue = textfieldCurrentValue

function BaseMenuItems.Textfield(spec)
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
            Log.warn("BaseMenuItems Textfield '" .. tostring(spec.controlName)
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
        BaseMenu._pushEdit(menu, self)
    end
    function item:adjust(menu, dir, big) end
    return item
end

return BaseMenuItems

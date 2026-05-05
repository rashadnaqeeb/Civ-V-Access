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
local STEP_BIG = 0.10

-- Label / tooltip resolution ----------------------------------------------

local function resolveLabel(item)
    if item.labelText ~= nil then
        return item.labelText
    end
    if item.labelFn ~= nil then
        local ok, result = pcall(item.labelFn, item._control)
        if not ok then
            Log.error("BaseMenuItems labelFn '" .. tostring(item.controlName) .. "' failed: " .. tostring(result))
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
            Log.error("BaseMenuItems tooltipFn '" .. tostring(item.controlName) .. "' failed: " .. tostring(result))
            return nil
        end
        if result == nil or result == "" then
            return nil
        end
        return tostring(result)
    end
    if item.tooltipText ~= nil and item.tooltipText ~= "" then
        return item.tooltipText
    end
    if item.tooltipKey == nil then
        return nil
    end
    local t = Text.key(item.tooltipKey)
    if t == nil or t == "" then
        return nil
    end
    return t
end

-- Drop any tooltip sentence that duplicates an existing ", "-separated
-- segment in `base`. Sentences separated by ". " in localized tooltip text.
--
-- Tooltip sentences join the base with ". " and join each other with ". "
-- as well, so multi-line engine tooltips (GetTourismTooltip,
-- GetThemingTooltip, etc.) get readable pauses between lines instead of
-- one undelimited blob. [NEWLINE] tokens inside the tooltip are normalized
-- to ". " up front so each engine line participates in both the dedup
-- pass and the period-joined output. ":%." artifacts the normalization
-- can leave behind (line ends with ":") are cleaned up downstream by
-- TextFilter's `:%.` rule.
--
-- Sentence boundaries are period-followed-by-whitespace (or end of string),
-- not bare period. A bare period inside a number ("1.06 Gold") or
-- abbreviation is not a boundary; trade-route tooltips report fractional
-- values via the engine's "{1_Num: number #.#}" format and any sentence
-- splitter that treats every "." as terminal mangles them into "1. 06".
local function appendTooltip(base, tooltip)
    if tooltip == nil or tooltip == "" then
        return base
    end
    if base == nil or base == "" then
        return tooltip
    end

    tooltip = tooltip:gsub("%[NEWLINE%]", ". ")

    local seen = {}
    for segment in string.gmatch(base, "([^,]+)") do
        local trimmed = segment:match("^%s*(.-)%s*$")
        if trimmed ~= "" then
            seen[trimmed] = true
        end
    end

    -- Mark every period-followed-by-whitespace boundary with NUL, then
    -- split on NUL. The period itself is dropped (the join below supplies
    -- one back); any period not followed by whitespace (e.g. the "." in
    -- "1.06") survives untouched inside its segment.
    local marked = tooltip:gsub("%.%s+", "\0")
    local novel = {}
    for sentence in string.gmatch(marked, "([^%z]+)") do
        local trimmed = sentence:match("^%s*(.-)%s*$")
        -- Strip a single trailing period so the join's ". " separator
        -- doesn't double up ("Foo." + ". " + "Bar" -> "Foo.. Bar").
        trimmed = trimmed:gsub("%.$", "")
        if trimmed ~= "" and not seen[trimmed] then
            novel[#novel + 1] = trimmed
        end
    end

    if #novel == 0 then
        return base
    end
    return base .. ". " .. table.concat(novel, ". ")
end

BaseMenuItems.appendTooltip = appendTooltip
BaseMenuItems.labelOf = resolveLabel
BaseMenuItems.tooltipOf = resolveTooltip

-- Single source of the activation ack sound. Item activates call this only
-- when an action actually ran successfully (pcall returned ok for handler-
-- bound kinds; unconditional for kinds whose action is the click itself,
-- like opening a pulldown sub-menu). A thrown handler or a no-op kind
-- (Text without onActivate) stays silent so the user doesn't hear
-- confirmation for something that didn't happen.
function BaseMenuItems.clickAck()
    Events.AudioPlay2DSound("AS2D_IF_SELECT")
end

-- Shared navigability / activability --------------------------------------

local function isNavigable(self)
    if self._control == nil or self._control:IsHidden() then
        return false
    end
    if self._visibilityControl ~= nil and self._visibilityControl:IsHidden() then
        return false
    end
    return true
end

local function isActivatable(self)
    if not isNavigable(self) then
        return false
    end
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
    if spec.control ~= nil then
        return spec.control
    end
    Log.check(type(spec.controlName) == "string", kind .. " needs controlName or control")
    local c = Controls[spec.controlName]
    if c == nil then
        Log.warn("BaseMenuItems " .. kind .. ": missing control '" .. spec.controlName .. "'")
    end
    return c
end

local function assertLabel(spec, kind)
    Log.check(
        type(spec.textKey) == "string" or type(spec.labelText) == "string" or type(spec.labelFn) == "function",
        kind .. " needs textKey, labelText, or labelFn"
    )
end

local function assertTooltip(spec, kind)
    Log.check(
        spec.tooltipFn == nil or type(spec.tooltipFn) == "function",
        kind .. ".tooltipFn must be a function if provided"
    )
end

local function copyCommonFields(spec, item)
    item.controlName = spec.controlName
    item.textKey = spec.textKey
    item.labelText = spec.labelText
    item.labelFn = spec.labelFn
    item.tooltipKey = spec.tooltipKey
    item.tooltipText = spec.tooltipText
    item.tooltipFn = spec.tooltipFn
    -- Civilopedia search string for the Ctrl+I shortcut in BaseMenu.create.
    -- Items that map to a pediable entity (building, wonder, specialist,
    -- unit, etc.) set pediaName to the entity's already-localized display
    -- name (the string Events.SearchForPediaEntry matches on); dynamic
    -- items whose underlying entity changes across navigates use pediaNameFn
    -- to re-resolve at Ctrl+I time. Absent fields mean Ctrl+I no-ops.
    item.pediaName = spec.pediaName
    item.pediaNameFn = spec.pediaNameFn
end

-- Button ------------------------------------------------------------------

function BaseMenuItems.Button(spec)
    assertLabel(spec, "Button")
    assertTooltip(spec, "Button")
    Log.check(type(spec.activate) == "function", "Button '" .. tostring(spec.controlName) .. "' needs activate fn")
    local item = {
        kind = "button",
        _control = resolveControl(spec, "Button"),
        _activate = spec.activate,
    }
    copyCommonFields(spec, item)
    item.isNavigable = isNavigable
    item.isActivatable = isActivatable
    function item:announce(menu)
        return composeSpeech(self, { resolveLabel(self) })
    end
    function item:activate(menu)
        local ok, err = pcall(self._activate)
        if not ok then
            Log.error(
                "BaseMenu '"
                    .. tostring(menu.name)
                    .. "' button '"
                    .. tostring(self.controlName)
                    .. "' activate failed: "
                    .. tostring(err)
            )
            return
        end
        BaseMenuItems.clickAck()
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Text --------------------------------------------------------------------
--
-- Informational list entry with no widget backing. Navigable (Up/Down land
-- on it); by default activation is a no-op. Items that supply onActivate
-- run that hook and, on success, play the click ack. Items without
-- onActivate re-speak their label on Enter so the user gets keypress
-- feedback without a misleading click.
--
-- Used by the Help overlay where each entry is "keyLabel, description"
-- read-only text -- there's no XML control, no disabled state, no tooltip
-- dedup needed. Reuses composeSpeech would call _control:IsDisabled which
-- would NPE, so announce builds the speech directly.

function BaseMenuItems.Text(spec)
    assertLabel(spec, "Text")
    assertTooltip(spec, "Text")
    Log.check(
        spec.onActivate == nil or type(spec.onActivate) == "function",
        "Text onActivate must be a function if provided"
    )
    local item = { kind = "text" }
    copyCommonFields(spec, item)
    -- Optional activation hook. Called with (self, menu) under pcall;
    -- errors surface via Log.error so a broken handler can't silently
    -- kill the menu. Click ack fires only on pcall success.
    item._onActivate = spec.onActivate
    function item:isNavigable()
        return true
    end
    function item:isActivatable()
        return true
    end
    function item:announce(menu)
        return appendTooltip(resolveLabel(self), resolveTooltip(self))
    end
    function item:activate(menu)
        if self._onActivate == nil then
            -- No action to perform; re-speak the label so the user hears
            -- that the keypress registered on a read-only item.
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        local ok, err = pcall(self._onActivate, self, menu)
        if not ok then
            Log.error("BaseMenu '" .. tostring(menu and menu.name) .. "' Text onActivate failed: " .. tostring(err))
            return
        end
        BaseMenuItems.clickAck()
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Checkbox ----------------------------------------------------------------

local function checkboxValue(item)
    local on = item._control:IsChecked()
    return Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
end

function BaseMenuItems.Checkbox(spec)
    assertLabel(spec, "Checkbox")
    assertTooltip(spec, "Checkbox")
    Log.check(
        spec.activateCallback == nil or type(spec.activateCallback) == "function",
        "Checkbox.activateCallback must be a function if provided"
    )
    local item = {
        kind = "checkbox",
        _control = resolveControl(spec, "Checkbox"),
        _activateCallback = spec.activateCallback,
    }
    if spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn(
                "BaseMenuItems Checkbox '"
                    .. tostring(spec.controlName)
                    .. "': missing visibility control '"
                    .. spec.visibilityControlName
                    .. "'"
            )
        end
    end
    copyCommonFields(spec, item)
    item.isNavigable = isNavigable
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
        local committed = false
        if cb == nil then
            Log.warn(
                "BaseMenu checkbox '"
                    .. tostring(self.controlName)
                    .. "': callback not captured, game state will not update"
            )
        else
            local ok, err = pcall(cb, newValue)
            if not ok then
                Log.error("BaseMenu checkbox '" .. tostring(self.controlName) .. "' callback failed: " .. tostring(err))
            else
                committed = true
            end
        end
        if committed then
            BaseMenuItems.clickAck()
        end
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
--   selectedFn                       optional fn() -> bool. When truthy,
--                                    the announcement prepends "selected"
--                                    and activate re-announces after the
--                                    spec's activate fires, so the user
--                                    hears confirmation on a browse-then-
--                                    commit screen (ScenariosMenu etc.
--                                    where the list highlights a row and
--                                    a separate Start commits). Leave nil
--                                    for select-and-close screens where
--                                    activation pops the handler anyway.
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
    Log.check(type(spec.activate) == "function", "Choice needs activate fn")
    Log.check(
        spec.selectedFn == nil or type(spec.selectedFn) == "function",
        "Choice.selectedFn must be a function if provided"
    )
    local item = {
        kind = "choice",
        _activate = spec.activate,
        _selectedFn = spec.selectedFn,
        _visibilityControl = spec.visibilityControl,
    }
    if item._visibilityControl == nil and spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn("BaseMenuItems Choice: missing visibility control '" .. spec.visibilityControlName .. "'")
        end
    end
    copyCommonFields(spec, item)
    function item:isNavigable()
        if self._visibilityControl ~= nil and self._visibilityControl:IsHidden() then
            return false
        end
        return true
    end
    function item:isActivatable()
        return self:isNavigable()
    end
    function item:announce(menu)
        local parts = {}
        if self._selectedFn ~= nil then
            local ok, sel = pcall(self._selectedFn)
            if not ok then
                Log.error("BaseMenuItems Choice selectedFn failed: " .. tostring(sel))
            elseif sel then
                parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CHOICE_SELECTED")
            end
        end
        parts[#parts + 1] = resolveLabel(self)
        return composeSpeech(self, parts)
    end
    function item:activate(menu)
        local ok, err = pcall(self._activate)
        if not ok then
            Log.error("BaseMenu '" .. tostring(menu.name) .. "' choice activate failed: " .. tostring(err))
            return
        end
        BaseMenuItems.clickAck()
        -- Re-announce gives audio confirmation on browse-then-commit
        -- screens whose activate just flips a selection flag (the menu
        -- stays open, no other speech to collide with). Skip when the
        -- user's activate popped this handler off the stack: select-and-
        -- close screens (Select* pickers, Pulldown sub-menus) close
        -- synchronously inside activate, and the parent's own
        -- onActivate speakInterrupt is already in flight -- adding our
        -- own would race against it and produce a stutter.
        if self._selectedFn ~= nil and HandlerStack.active() == menu then
            SpeechPipeline.speakInterrupt(self:announce(menu))
        end
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Slider ------------------------------------------------------------------

local function sliderCompositeLabel(item)
    local labelCtrl = item._labelControl
    if labelCtrl == nil then
        return nil
    end
    local ok, value = pcall(function()
        return labelCtrl:GetText()
    end)
    if not ok or value == nil or value == "" then
        return nil
    end
    return tostring(value)
end

local function clampUnit(v)
    if v < 0 then
        return 0
    end
    if v > 1 then
        return 1
    end
    return v
end

local function fireSliderCallback(item, newValue)
    local cb = PullDownProbe.sliderCallbackFor(item._control)
    if cb == nil then
        Log.warn(
            "BaseMenu slider '" .. tostring(item.controlName) .. "': callback not captured, game state will not update"
        )
        return
    end
    local void1
    local okV, v = pcall(function()
        return item._control:GetVoid1()
    end)
    if okV then
        void1 = v
    end
    local ok, err = pcall(cb, newValue, void1)
    if not ok then
        Log.error("BaseMenu slider '" .. tostring(item.controlName) .. "' callback failed: " .. tostring(err))
    end
end

function BaseMenuItems.Slider(spec)
    assertLabel(spec, "Slider")
    assertTooltip(spec, "Slider")
    Log.check(
        type(spec.labelControlName) == "string",
        "Slider '" .. tostring(spec.controlName) .. "' needs labelControlName"
    )
    local labelCtrl = Controls[spec.labelControlName]
    if labelCtrl == nil then
        Log.warn(
            "BaseMenuItems Slider '"
                .. tostring(spec.controlName)
                .. "': missing label control '"
                .. spec.labelControlName
                .. "'"
        )
    end
    local item = {
        kind = "slider",
        _control = resolveControl(spec, "Slider"),
        _labelControl = labelCtrl,
        labelControlName = spec.labelControlName,
        step = spec.step or STEP_SMALL,
        bigStep = spec.bigStep or STEP_BIG,
    }
    copyCommonFields(spec, item)
    item.isNavigable = isNavigable
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
        if not isActivatable(self) then
            return
        end
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
    local ok, btn = pcall(function()
        return c:GetButton()
    end)
    if not ok or btn == nil then
        return nil
    end
    local ok2, text = pcall(function()
        return btn:GetText()
    end)
    if not ok2 or text == nil or text == "" then
        return nil
    end
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
--
-- isSelected: pre-computed boolean that the Pulldown activator sets when
-- this entry's text matches the pulldown's current value. When true, the
-- announce prepends "selected" so the user can identify the committed
-- pick while browsing the sub-menu. No re-announce-on-activate: a sub-
-- menu entry's activate pops the sub, and the parent's re-announce on
-- pop already speaks the new value.
--
-- onSelected: optional spec.onSelected(v1, v2) hook fired after the engine
-- callback has run successfully. Lets the parent screen rebuild dependent
-- state (e.g. CultureOverview's per-civ row list when the perspective
-- pulldown picks a new player). Skipped when the engine callback raises so
-- a failed selection doesn't trigger a partial rebuild.
local function buildChoice(button, callback, useVoids, parentControlName, announceOverride, isSelected, onSelected)
    local choice = {
        kind = "choice",
        _button = button,
        _callback = callback,
        _useVoids = useVoids,
        _isSelected = isSelected,
        _onSelected = onSelected,
    }
    function choice:isNavigable()
        return self._button ~= nil
    end
    function choice:isActivatable()
        return self._button ~= nil
    end
    function choice:announce(menu)
        local text
        -- Pulldowns with a spec.entryAnnounceFn (civ pulldowns, etc.)
        -- supply per-entry rich text that replaces the button-text
        -- default. Override is a thunk the Pulldown activate built with
        -- the inst+index closed over.
        if announceOverride ~= nil then
            local ok, t = pcall(announceOverride)
            if not ok then
                Log.warn(
                    "BaseMenu pulldown '" .. tostring(parentControlName) .. "' entryAnnounceFn failed: " .. tostring(t)
                )
            elseif t ~= nil and t ~= "" then
                text = tostring(t)
            end
        end
        if text == nil then
            local ok, t = pcall(function()
                return self._button:GetText()
            end)
            if not ok or t == nil or t == "" then
                Log.warn("BaseMenu pulldown '" .. tostring(parentControlName) .. "' entry has no text")
                return ""
            end
            text = t
            -- Per-entry tooltip (info.Help for handicaps, civ.Description for
            -- civs, possibleValue.ToolTip for map-script options). Best-effort:
            -- some Button userdata may not expose GetToolTipString.
            local tipOk, tip = pcall(function()
                return self._button:GetToolTipString()
            end)
            if tipOk and tip ~= nil and tip ~= "" then
                text = BaseMenuItems.appendTooltip(text, tostring(tip))
            end
        end
        if self._isSelected then
            return Text.format("TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED", text)
        end
        return text
    end
    function choice:activate(menu)
        local ok, err
        local v1, v2
        if self._useVoids then
            pcall(function()
                v1 = self._button:GetVoid1()
                v2 = self._button:GetVoid2()
            end)
            ok, err = pcall(self._callback, v1, v2)
        else
            ok, err = pcall(self._callback)
        end
        if not ok then
            Log.error("BaseMenu pulldown '" .. tostring(parentControlName) .. "' callback failed: " .. tostring(err))
        else
            BaseMenuItems.clickAck()
            if self._onSelected ~= nil then
                local okS, errS = pcall(self._onSelected, v1, v2)
                if not okS then
                    Log.error(
                        "BaseMenu pulldown '"
                            .. tostring(parentControlName)
                            .. "' onSelected failed: "
                            .. tostring(errS)
                    )
                end
            end
        end
        HandlerStack.removeByName(menu.name, true)
    end
    function choice:adjust(menu, dir, big) end
    return choice
end

function BaseMenuItems.Pulldown(spec)
    assertLabel(spec, "Pulldown")
    assertTooltip(spec, "Pulldown")
    Log.check(
        spec.valueFn == nil or type(spec.valueFn) == "function",
        "Pulldown.valueFn must be a function if provided"
    )
    Log.check(
        spec.entryAnnounceFn == nil or type(spec.entryAnnounceFn) == "function",
        "Pulldown.entryAnnounceFn must be a function if provided"
    )
    Log.check(
        spec.onSelected == nil or type(spec.onSelected) == "function",
        "Pulldown.onSelected must be a function if provided"
    )
    local item = {
        kind = "pulldown",
        _control = resolveControl(spec, "Pulldown"),
        _valueFn = spec.valueFn,
        _entryAnnounceFn = spec.entryAnnounceFn,
        _onSelected = spec.onSelected,
    }
    if spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn(
                "BaseMenuItems Pulldown '"
                    .. tostring(spec.controlName)
                    .. "': missing visibility control '"
                    .. spec.visibilityControlName
                    .. "'"
            )
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
        if not isNavigable(self) then
            return false
        end
        if self._control:IsDisabled() then
            return false
        end
        local ok, btn = pcall(function()
            return self._control:GetButton()
        end)
        if ok and btn ~= nil then
            local okD, disabled = pcall(function()
                return btn:IsDisabled()
            end)
            if okD and disabled then
                return false
            end
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
            if ok and result ~= nil then
                v = tostring(result)
            end
        end
        if v == nil then
            v = pulldownCurrentValue(self)
        end
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
        local entries = PullDownProbe.entriesFor(pulldown)
        if entries == nil or #entries == 0 then
            Log.warn(
                "BaseMenu '" .. menu.name .. "' pulldown '" .. tostring(self.controlName) .. "': no entries captured"
            )
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        -- Two wiring patterns. Most pulldowns have a single
        -- RegisterSelectionCallback that dispatches by void. Map-script
        -- option dropdowns instead wire each entry's button with its own
        -- RegisterCallback(Mouse.eLClick, fn) closure. Prefer the top-level
        -- path when present; otherwise fall back to per-entry button
        -- callbacks (captured by the button probe).
        local subName = menu.name .. "/" .. tostring(self.controlName) .. "_PullDown"
        local childItems = {}
        local currentText = pulldownCurrentValue(self)
        local initialIndex
        local fallbackUsed = 0
        local entryAnnounceFn = self._entryAnnounceFn
        local onSelected = self._onSelected
        for i, inst in ipairs(entries) do
            local cb = topCallback
            local useVoids = topCallback ~= nil
            if cb == nil then
                cb = PullDownProbe.buttonCallbackFor(inst.Button, Mouse.eLClick)
                if cb ~= nil then
                    fallbackUsed = fallbackUsed + 1
                end
            end
            local announceOverride
            if entryAnnounceFn ~= nil then
                local idx = i
                announceOverride = function()
                    return entryAnnounceFn(inst, idx)
                end
            end
            local isSelected = false
            if currentText ~= nil then
                local ok, t = pcall(function()
                    return inst.Button:GetText()
                end)
                if ok and t ~= nil and tostring(t) == currentText then
                    isSelected = true
                    if initialIndex == nil then
                        initialIndex = i
                    end
                end
            end
            childItems[i] =
                buildChoice(inst.Button, cb, useVoids, self.controlName, announceOverride, isSelected, onSelected)
        end
        if topCallback == nil and fallbackUsed == 0 then
            Log.warn(
                "BaseMenu '"
                    .. menu.name
                    .. "' pulldown '"
                    .. tostring(self.controlName)
                    .. "': no top-level callback and no per-entry fallbacks captured"
            )
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        BaseMenuItems.clickAck()
        local child = BaseMenu.create({
            name = subName,
            displayName = resolveLabel(self),
            items = childItems,
            initialIndex = initialIndex,
            escapePops = true,
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
--
-- A Group with no navigable children is itself non-navigable: the parent's
-- nav (Up/Down, cross-group jump, search corpus, first-valid-on-open) skips
-- it so empty drillables don't appear in the list (e.g. a Wonders group on
-- the production chooser disappears when the city has no wonders to build).
-- For cached=false groups this re-evaluates each check, so children() may
-- be invoked once per nav step; cached=true groups pay it once.

function BaseMenuItems.Group(spec)
    assertLabel(spec, "Group")
    assertTooltip(spec, "Group")
    Log.check(type(spec.items) == "table" or type(spec.itemsFn) == "function", "Group needs items or itemsFn")
    local item = {
        kind = "group",
        _items = spec.items,
        _itemsFn = spec.itemsFn,
        _cached = spec.cached ~= false,
        _cache = nil,
    }
    if spec.visibilityControl ~= nil then
        item._visibilityControl = spec.visibilityControl
    elseif spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn("BaseMenuItems Group: missing visibility control '" .. spec.visibilityControlName .. "'")
        end
    end
    copyCommonFields(spec, item)
    function item:isNavigable()
        if self._visibilityControl ~= nil and self._visibilityControl:IsHidden() then
            return false
        end
        for _, child in ipairs(self:children()) do
            if child:isNavigable() then
                return true
            end
        end
        return false
    end
    function item:isActivatable()
        return self:isNavigable()
    end
    function item:children()
        if self._cached and self._cache ~= nil then
            return self._cache
        end
        local built
        if self._itemsFn ~= nil then
            local ok, result = pcall(self._itemsFn)
            if not ok then
                Log.error(
                    "BaseMenuItems Group '"
                        .. tostring(self.textKey or self.labelText or "?")
                        .. "' itemsFn failed: "
                        .. tostring(result)
                )
                built = {}
            else
                built = result or {}
            end
        else
            built = self._items or {}
        end
        if self._cached then
            self._cache = built
        end
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
    local ok, text = pcall(function()
        return item._control:GetText()
    end)
    if not ok or text == nil or text == "" then
        return Text.key("TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK")
    end
    return tostring(text)
end

-- Shared with BaseMenuEditMode for commit-value announcement.
BaseMenuItems._textfieldCurrentValue = textfieldCurrentValue

function BaseMenuItems.Textfield(spec)
    assertLabel(spec, "Textfield")
    assertTooltip(spec, "Textfield")
    Log.check(
        spec.priorCallback == nil or type(spec.priorCallback) == "function",
        "Textfield '" .. tostring(spec.controlName) .. "' priorCallback must be a function"
    )
    local item = {
        kind = "textfield",
        _control = resolveControl(spec, "Textfield"),
        priorCallback = spec.priorCallback,
    }
    copyCommonFields(spec, item)
    if spec.visibilityControlName ~= nil then
        item.visibilityControlName = spec.visibilityControlName
        item._visibilityControl = Controls[spec.visibilityControlName]
        if item._visibilityControl == nil then
            Log.warn(
                "BaseMenuItems Textfield '"
                    .. tostring(spec.controlName)
                    .. "': missing visibility control '"
                    .. spec.visibilityControlName
                    .. "'"
            )
        end
    end
    item.isNavigable = isNavigable
    item.isActivatable = isActivatable
    function item:announce(menu)
        return composeSpeech(self, {
            resolveLabel(self),
            Text.key("TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"),
            textfieldCurrentValue(self),
        })
    end
    function item:activate(menu)
        BaseMenuEditMode.push(menu, self)
    end
    function item:adjust(menu, dir, big) end
    return item
end

-- Virtual slider / toggle ------------------------------------------------
--
-- Settings-menu items for preferences that have no Civ V XML widget behind
-- them (mod-side prefs like master volume or scanner auto-move). Unlike
-- Slider / Checkbox, these don't read or write a Controls.X userdata; they
-- delegate to a getValue / setValue pair the caller supplies, and the
-- caller's setValue is responsible for any persistence + side effects
-- (Prefs.setX, audio.set_master_volume, etc.).

-- VirtualSlider: kind "slider" so BaseMenu's onLeft / onRight call adjust.
-- Caller supplies getValue() -> number in [0,1], setValue(number), and a
-- labelFn(value) -> string used by announce so the speech reads the live
-- value without a Controls label control.
function BaseMenuItems.VirtualSlider(spec)
    assertLabel(spec, "VirtualSlider")
    assertTooltip(spec, "VirtualSlider")
    Log.check(type(spec.getValue) == "function", "VirtualSlider needs getValue fn")
    Log.check(type(spec.setValue) == "function", "VirtualSlider needs setValue fn")
    Log.check(type(spec.labelFn) == "function", "VirtualSlider needs labelFn(value) fn")
    local item = {
        kind = "slider",
        _getValue = spec.getValue,
        _setValue = spec.setValue,
        _labelFn = spec.labelFn,
        step = spec.step or STEP_SMALL,
        bigStep = spec.bigStep or STEP_BIG,
    }
    copyCommonFields(spec, item)
    function item:isNavigable()
        return true
    end
    function item:isActivatable()
        return true
    end
    function item:announce(menu)
        local ok, value = pcall(self._getValue)
        if not ok then
            Log.error("BaseMenuItems VirtualSlider getValue failed: " .. tostring(value))
            return resolveLabel(self)
        end
        local ok2, label = pcall(self._labelFn, value)
        if not ok2 then
            Log.error("BaseMenuItems VirtualSlider labelFn failed: " .. tostring(label))
            return resolveLabel(self)
        end
        return appendTooltip(label, resolveTooltip(self))
    end
    function item:activate(menu)
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    function item:adjust(menu, dir, big)
        local ok, cur = pcall(self._getValue)
        if not ok then
            Log.error("BaseMenuItems VirtualSlider getValue failed: " .. tostring(cur))
            return
        end
        local delta = (big and self.bigStep or self.step) * dir
        local next = cur + delta
        if next < 0 then
            next = 0
        end
        if next > 1 then
            next = 1
        end
        if next == cur then
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        local okSet, err = pcall(self._setValue, next)
        if not okSet then
            Log.error("BaseMenuItems VirtualSlider setValue failed: " .. tostring(err))
            return
        end
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    return item
end

-- VirtualToggle: kind "checkbox" semantics on a bool getValue / setValue
-- pair. activate flips the value via setValue and re-announces. Same
-- announcement shape as the XML-backed Checkbox: "Label, on" / "Label, off".
function BaseMenuItems.VirtualToggle(spec)
    assertLabel(spec, "VirtualToggle")
    assertTooltip(spec, "VirtualToggle")
    Log.check(type(spec.getValue) == "function", "VirtualToggle needs getValue fn")
    Log.check(type(spec.setValue) == "function", "VirtualToggle needs setValue fn")
    local item = {
        kind = "checkbox",
        _getValue = spec.getValue,
        _setValue = spec.setValue,
    }
    copyCommonFields(spec, item)
    function item:isNavigable()
        return true
    end
    function item:isActivatable()
        return true
    end
    function item:announce(menu)
        local ok, value = pcall(self._getValue)
        if not ok then
            Log.error("BaseMenuItems VirtualToggle getValue failed: " .. tostring(value))
            return resolveLabel(self)
        end
        local stateKey = value and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF"
        local base = Text.format("TXT_KEY_CIVVACCESS_LABEL_STATE", resolveLabel(self), Text.key(stateKey))
        return appendTooltip(base, resolveTooltip(self))
    end
    function item:activate(menu)
        local ok, cur = pcall(self._getValue)
        if not ok then
            Log.error("BaseMenuItems VirtualToggle getValue failed: " .. tostring(cur))
            return
        end
        local okSet, err = pcall(self._setValue, not cur)
        if not okSet then
            Log.error("BaseMenuItems VirtualToggle setValue failed: " .. tostring(err))
            return
        end
        BaseMenuItems.clickAck()
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    function item:adjust(menu, dir, big) end
    return item
end

return BaseMenuItems

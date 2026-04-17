-- Reusable handler for mixed-widget form screens (Options, AdvancedSetup,
-- MPGameSetup, StagingRoom). Where SimpleListHandler assumes a flat list of
-- buttons with one verb (Enter), FormHandler supports item kinds --
-- button, checkbox, slider, pulldown, textfield -- each with its own
-- activation and announcement. Multi-tab screens use Tab / Shift+Tab to
-- cycle through tabs.
--
-- Spec shape:
--   name          (string, required) unique-ish handler name for the stack
--   displayName   (string, required) spoken on activation
--   priorShowHide (fn, optional) screen's existing ShowHideHandler; chained first
--   priorInput    (fn, optional) screen's existing InputHandler; fallback for
--                 unbound keys and Esc (matches SimpleListHandler.install)
--   Either a single `items` list OR a `tabs` list; never both.
--   items         array of item specs (see below); shape when spec has no tabs
--   tabs          array of { name = "TXT_KEY_*", showPanel = fn, items = {...} }
--                 when present, item list is per tab and Tab/Shift+Tab cycles;
--                 showPanel is called on tab change to hide/show engine panels
--                 (caller supplies so we do not re-implement the screen's own
--                 OnCategory / tab-visibility logic).
--
-- Common item fields (apply to every kind):
--   controlName              XML ID on Controls; resolved at create() into
--                            _control. Optional if `control` is passed.
--   control                  direct userdata reference; wins over controlName.
--                            For widgets built via InstanceManager that have
--                            no stable Controls.X (dynamic GameOption
--                            checkboxes, map-script DropDown options).
--   textKey                  TXT_KEY_* for the spoken label. Mutually
--                            exclusive with labelText.
--   labelText                pre-localized literal for widgets whose label
--                            comes from the engine (e.g. GameOption.Description
--                            already run through Locale.ConvertTextKey).
--   tooltipKey / tooltipText static tooltip sources (TXT_KEY vs literal).
--   tooltipFn                fn(control) returning a string; evaluated at
--                            announce time. Escape hatch for tooltips set
--                            via SetToolTipString (Play Now settings summary,
--                            disabled-reason hints).
--
-- Kind-specific fields:
--   { kind = "button",   controlName, textKey, activate }
--     Enter invokes activate(); same contract as SimpleListHandler items.
--
--   { kind = "checkbox", controlName, textKey }
--     Enter or Space toggle SetCheck + fire the registered check handler by
--     reading the post-toggle IsChecked state. Announce label + on/off.
--
--   { kind = "slider",   controlName, labelControlName, textKey, [step, bigStep] }
--     Left / Right adjust by step (default 0.01); Shift+Left / Shift+Right by
--     bigStep (default 0.10); Home / End snap to 0 / 1. After SetValue the
--     sibling label control (populated by the screen's RegisterSliderCallback)
--     carries the user-visible formatted value; we re-read it and speak
--     "<label> <value>".
--
--   { kind = "pulldown", controlName, textKey }
--     Enter pushes a sub-SimpleListHandler built from the probe's captured
--     entries, whose activate invokes the probe's captured callback with the
--     entry button's voids. If probe state is missing (callback not yet
--     registered or entries not yet built), Enter announces the current value
--     and logs a Log.warn per the no-silent-failures rule.
--
--   { kind = "textfield", controlName, textKey, [priorCallback],
--     [visibilityControlName] }
--     Enter on the item flips the form into an `_editing` mode: the
--     EditBox's text is snapshotted, cleared, and given engine focus, a
--     wrapping callback chains to priorCallback on every character, and
--     the handler's own bindings shrink to Escape (cancel, restore the
--     snapshot) and Enter (commit, preserve the typed text). While
--     editing, capturesAllInput is false so unbound keys -- every
--     printable character, Backspace, arrows for caret movement -- fall
--     through the mod's InputRouter and reach the focused EditBox for
--     native engine handling (including IME composition). On exit the
--     prior callback is reinstated and focus is parked on
--     `focusParkControl` so arrow keys reach the form's navigation
--     bindings again.
--     priorCallback, if given, is the EditBox's already-registered
--     callback (typically a validator) so typing keeps driving the
--     screen's per-character commit; the original is restored on exit.
--     visibilityControlName, if given, points at a wrapper Box whose
--     SetHide controls whether the EditBox is visually present (common
--     for MaxTurnsEditbox / TurnTimerEditbox containers). FormHandler's
--     isNavigable skips the item when that wrapper is hidden.
--     Announcement on focus: "<label>, edit, <current text or 'blank'>".
--
-- Navigation: Up / Down wrap within the current tab. Tab / Shift+Tab cycle
-- tabs when the spec has tabs. Home / End are reserved for slider snap,
-- not list navigation, to avoid collision. Esc bypasses the
-- capturesAllInput barrier and routes to priorInput (screen's own Back / OnNo).
--
-- Dynamic item lists: a screen whose widgets are rebuilt by the engine
-- (InstanceManager stacks) should re-emit items via handler.setItems(items
-- [, tabIndex]) after each rebuild. The cursor clamps silently if its slot
-- no longer exists; no announcement on swap.

FormHandler = {}

-- Forward declarations so switchTab can call parkFocus (defined further
-- down with the textfield edit-mode helpers).
local parkFocus

-- Kinds ----------------------------------------------------------------

local STEP_SMALL = 0.01
local STEP_BIG   = 0.10

-- Speech composition follows the oni-access pattern: segments joined by
-- ", " (comma-space) so the screen reader pauses between them, and the
-- tooltip is appended last as a single segment after the full value.
-- Format: "<label>, <value>[, disabled][, <tooltip>]"
-- Buttons have no value, so their base form is just "<label>".
-- Tooltip dedupes against existing segments so a checkbox whose label
-- and tooltip are the same phrase does not get announced twice.

local function labelOf(item)
    -- labelText takes precedence: dynamic widgets built by the engine
    -- (InstanceManager-backed GameOption checkboxes etc.) carry labels that
    -- are already localized strings, not TXT_KEY lookups.
    if item.labelText ~= nil then return item.labelText end
    return Text.key(item.textKey)
end

local function resolveTooltip(item)
    -- Priority: tooltipFn (dynamic), tooltipText (pre-localized literal),
    -- tooltipKey (static TXT_KEY). tooltipFn is the escape hatch for
    -- buttons whose tooltip is assigned at runtime via SetToolTipString.
    if item.tooltipFn ~= nil then
        local ok, result = pcall(item.tooltipFn, item._control)
        if not ok then
            Log.error("FormHandler tooltipFn '"
                .. tostring(item.controlName) .. "' failed: " .. tostring(result))
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
-- segment in `base`. Sentences are separated by ". " in localized tooltip
-- text. Adapted from oni-access's WidgetOps.AppendTooltip.
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

local function isNavigable(item)
    if item._control == nil or item._control:IsHidden() then return false end
    -- Wrapper-hide pattern: engine hides a parent Box rather than the child
    -- widget (MaxTurnsEditbox, TurnTimerEditbox). Honor the wrapper so the
    -- cursor does not stop on a widget the user cannot see.
    if item._visibilityControl ~= nil and item._visibilityControl:IsHidden() then
        return false
    end
    return true
end

local function isActivatable(item)
    if not isNavigable(item) then return false end
    return not item._control:IsDisabled()
end

-- Base announcement = label, plus value for widgets that have one. Disabled
-- adds ", disabled" between label/value and the tooltip.
local function checkboxValue(item)
    local on = item._control:IsChecked()
    return Text.key(on and "TXT_KEY_CIVVACCESS_CHECK_ON" or "TXT_KEY_CIVVACCESS_CHECK_OFF")
end

local function sliderValue(item)
    local labelCtrl = item._labelControl
    if labelCtrl == nil then return nil end
    local ok, value = pcall(function() return labelCtrl:GetText() end)
    if not ok or value == nil or value == "" then return nil end
    return tostring(value)
end

local function pulldownValue(item)
    local c = item._control
    local ok, btn = pcall(function() return c:GetButton() end)
    if not ok or btn == nil then return nil end
    local ok2, text = pcall(function() return btn:GetText() end)
    if not ok2 or text == nil or text == "" then return nil end
    return tostring(text)
end

local function textfieldValue(item)
    local ok, text = pcall(function() return item._control:GetText() end)
    if not ok or text == nil or text == "" then
        return Text.key("TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK")
    end
    return tostring(text)
end

local function buildSpeech(self, item)
    local parts
    local kind = item.kind

    if kind == "slider" then
        -- Civ V's options sliders use a "composite" label control whose
        -- text is set by the slider's own callback to a pre-formatted
        -- "Label: Value" string (e.g. "Map Info Delay: 1 seconds"). In
        -- that case the textKey is only a format template with an
        -- unresolved {1_Num} placeholder -- announcing it would just
        -- duplicate the label portion and leak the placeholder. Use the
        -- label control text as the whole announcement when present;
        -- fall back to the textKey label otherwise.
        local v = sliderValue(item)
        if v ~= nil and v ~= "" then
            parts = { v }
        else
            parts = { labelOf(item) }
        end
    elseif kind == "checkbox" then
        parts = { labelOf(item), checkboxValue(item) }
    elseif kind == "pulldown" then
        local v = pulldownValue(item)
        if v ~= nil and v ~= "" then
            parts = { labelOf(item), v }
        else
            parts = { labelOf(item) }
        end
    elseif kind == "textfield" then
        parts = { labelOf(item), Text.key("TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"),
                  textfieldValue(item) }
    else
        parts = { labelOf(item) }
    end

    if not isActivatable(item) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
    end
    local base = table.concat(parts, ", ")
    return appendTooltip(base, resolveTooltip(item))
end

local function speakItem(self, item, interrupt)
    local fn = interrupt and SpeechPipeline.speakInterrupt or SpeechPipeline.speakQueued
    fn(buildSpeech(self, item))
end

-- Item resolution -----------------------------------------------------

local function resolveItems(self, items, context)
    local out = {}
    for i, item in ipairs(items) do
        assert(type(item.kind) == "string", context .. " item " .. i .. ".kind required")
        assert(type(item.textKey) == "string" or type(item.labelText) == "string",
            context .. " item " .. i .. " needs textKey (TXT_KEY) or labelText (literal)")
        assert(item.tooltipFn == nil or type(item.tooltipFn) == "function",
            context .. " item " .. i .. ".tooltipFn must be a function if provided")
        local resolved = {
            kind         = item.kind,
            textKey      = item.textKey,
            labelText    = item.labelText,
            tooltipKey   = item.tooltipKey,
            tooltipText  = item.tooltipText,
            tooltipFn    = item.tooltipFn,
            controlName  = item.controlName,
            activate     = item.activate,
        }
        -- A direct `control` userdata wins over a name lookup. Dynamic
        -- widgets built via InstanceManager have no stable Controls.X
        -- entry; the caller hands us the live handle. controlName is
        -- still accepted as a descriptive label for logs.
        if item.control ~= nil then
            resolved._control = item.control
        else
            assert(type(item.controlName) == "string",
                context .. " item " .. i .. " needs controlName or control")
            resolved._control = Controls[item.controlName]
            if resolved._control == nil then
                Log.warn("FormHandler '" .. self.name .. "': missing control '"
                    .. item.controlName .. "' in " .. context)
            end
        end
        if item.kind == "slider" then
            assert(type(item.labelControlName) == "string",
                context .. " item " .. i .. " (slider) needs labelControlName")
            resolved.labelControlName = item.labelControlName
            resolved._labelControl    = Controls[item.labelControlName]
            resolved.step             = item.step    or STEP_SMALL
            resolved.bigStep          = item.bigStep or STEP_BIG
            if resolved._labelControl == nil then
                Log.warn("FormHandler '" .. self.name .. "': missing label control '"
                    .. item.labelControlName .. "' for slider '"
                    .. tostring(item.controlName or "(unnamed)") .. "'")
            end
        elseif item.kind == "button" then
            assert(type(item.activate) == "function",
                context .. " item " .. i .. " (button) needs activate fn")
        elseif item.kind == "textfield" then
            assert(item.priorCallback == nil or type(item.priorCallback) == "function",
                context .. " item " .. i .. " (textfield) priorCallback must be a function")
            resolved.priorCallback = item.priorCallback
            if item.visibilityControlName ~= nil then
                resolved.visibilityControlName = item.visibilityControlName
                resolved._visibilityControl    = Controls[item.visibilityControlName]
                if resolved._visibilityControl == nil then
                    Log.warn("FormHandler '" .. self.name .. "': missing visibility control '"
                        .. item.visibilityControlName .. "' for textfield '"
                        .. tostring(item.controlName or "(unnamed)") .. "'")
                end
            end
        end
        out[#out + 1] = resolved
    end
    return out
end

local function currentItems(self)
    if self.tabs then
        local t = self.tabs[self._tabIndex]
        return t and t._items or {}
    end
    return self._items or {}
end

-- Navigation ----------------------------------------------------------

local function nextValidIndex(items, start, step)
    return Nav.next(items, start, step, isNavigable)
end

local function moveTo(self, newIndex)
    if newIndex == nil or newIndex == self._index then return end
    self._index = newIndex
    speakItem(self, currentItems(self)[newIndex], true)
end

-- Tabs ---------------------------------------------------------------

local function switchTab(self, newTabIndex)
    if self.tabs == nil then return end
    local n = #self.tabs
    if n == 0 then return end
    if newTabIndex < 1 then newTabIndex = n end
    if newTabIndex > n then newTabIndex = 1 end
    if newTabIndex == self._tabIndex then return end
    self._tabIndex = newTabIndex
    local tab = self.tabs[newTabIndex]
    if type(tab.showPanel) == "function" then
        local ok, err = pcall(tab.showPanel)
        if not ok then
            Log.error("FormHandler '" .. self.name .. "' showPanel for tab '"
                .. tostring(tab.name) .. "' failed: " .. tostring(err))
        end
    end
    -- Tab switch makes a new panel visible, and the engine auto-focuses
    -- the first EditBox in that panel. Once an EditBox holds engine focus
    -- arrow keys are consumed by caret movement before reaching our
    -- InputHandler. Park focus off the EditBox so form navigation keeps
    -- working. Same call as the install-time show path.
    parkFocus(self)
    local items = currentItems(self)
    local first = nextValidIndex(items, 0, 1)
    self._index = first or 1
    SpeechPipeline.speakInterrupt(Text.key(tab.name))
    if first ~= nil then
        SpeechPipeline.speakQueued(buildSpeech(self, items[first]))
    end
end

local function cycleTab(self, step)
    if self.tabs == nil then return end
    switchTab(self, self._tabIndex + step)
end

-- Activation ---------------------------------------------------------

local function activateButton(self, item)
    Events.AudioPlay2DSound("AS2D_IF_SELECT")
    local ok, err = pcall(item.activate)
    if not ok then
        Log.error("FormHandler '" .. self.name .. "' button '"
            .. tostring(item.controlName) .. "' activate failed: " .. tostring(err))
    end
end

-- Invoke the checkbox's registered RegisterCheckHandler with the new
-- state. The engine only fires it on user mouse interaction; a
-- programmatic SetCheck flips the visual but leaves the game's own
-- OptionsManager / PreGame setter unrun, so "Apply" would persist the
-- pre-toggle value. We call the captured handler manually.
local function fireCheckHandler(item, newValue)
    local cb = PullDownProbe.checkBoxCallbackFor(item._control)
    if cb == nil then
        Log.warn("FormHandler checkbox '" .. tostring(item.controlName)
            .. "': callback not captured, game state will not update")
        return
    end
    local ok, err = pcall(cb, newValue)
    if not ok then
        Log.error("FormHandler checkbox '" .. tostring(item.controlName)
            .. "' callback failed: " .. tostring(err))
    end
end

local function activateCheckbox(self, item)
    local c = item._control
    local newValue = not c:IsChecked()
    c:SetCheck(newValue)
    fireCheckHandler(item, newValue)
    Events.AudioPlay2DSound("AS2D_IF_SELECT")
    SpeechPipeline.speakInterrupt(buildSpeech(self, item))
end

local function clampUnit(v)
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

-- Call the slider's registered callback with the new value. The engine
-- fires RegisterSliderCallback only on mouse interaction; programmatic
-- SetValue does not, so the game's OptionsManager / PreGame setter never
-- runs and the label-side text never updates. We invoke the captured
-- callback manually, with signature (newValue, void1) to match the game
-- handlers (e.g. OnUIVolumeSliderValueChanged).
local function fireSliderCallback(item, newValue)
    local cb = PullDownProbe.sliderCallbackFor(item._control)
    if cb == nil then
        Log.warn("FormHandler slider '" .. tostring(item.controlName)
            .. "': callback not captured, game state will not update")
        return
    end
    local void1
    local ok, v = pcall(function() return item._control:GetVoid1() end)
    if ok then void1 = v end
    local ok2, err = pcall(cb, newValue, void1)
    if not ok2 then
        Log.error("FormHandler slider '" .. tostring(item.controlName)
            .. "' callback failed: " .. tostring(err))
    end
end

local function adjustSlider(self, item, delta)
    local c = item._control
    local cur = c:GetValue()
    local next = clampUnit(cur + delta)
    if next == cur then
        -- Still announce so the user learns they are at an end; label text
        -- already reflects the clamp from the last SetValue.
        SpeechPipeline.speakInterrupt(buildSpeech(self, item))
        return
    end
    c:SetValue(next)
    fireSliderCallback(item, next)
    SpeechPipeline.speakInterrupt(buildSpeech(self, item))
end

local function snapSlider(self, item, targetValue)
    local c = item._control
    c:SetValue(targetValue)
    fireSliderCallback(item, targetValue)
    SpeechPipeline.speakInterrupt(buildSpeech(self, item))
end

local function activatePullDown(self, item)
    local pulldown = item._control
    local callback = PullDownProbe.callbackFor(pulldown)
    local entries  = PullDownProbe.entriesFor(pulldown)
    if callback == nil or entries == nil or #entries == 0 then
        Log.warn("FormHandler '" .. self.name .. "' pulldown '"
            .. tostring(item.controlName) .. "': "
            .. (callback == nil and "callback not captured" or "no entries captured"))
        SpeechPipeline.speakInterrupt(buildSpeech(self, item))
        return
    end
    -- Match the click feedback on button / checkbox activation: the user
    -- just committed to a sub-menu, so the same "AS2D_IF_SELECT" confirms
    -- the action regardless of keyboard-vs-mouse entry.
    Events.AudioPlay2DSound("AS2D_IF_SELECT")
    -- Keep live button references only; read text and voids at speech /
    -- fire time so a between-push-and-select refresh of the pulldown is
    -- reflected in what the user hears and what we forward to the callback.
    local subButtons = {}
    for i, inst in ipairs(entries) do
        subButtons[i] = inst.Button
    end

    local subName = self.name .. "/" .. tostring(item.controlName) .. "_PullDown"
    local sub = {
        name             = subName,
        capturesAllInput = true,
        _index           = 1,
    }

    local function liveEntryText(btn)
        if btn == nil then return nil end
        local ok, t = pcall(function() return btn:GetText() end)
        if not ok or t == nil or t == "" then return nil end
        return t
    end

    local function speakSub(i)
        local btn = subButtons[i]
        local text = liveEntryText(btn)
        if text == nil then
            Log.warn("FormHandler pulldown '" .. tostring(item.controlName)
                .. "' entry " .. i .. " has no text; announcing label")
            SpeechPipeline.speakInterrupt(labelOf(item))
            return
        end
        SpeechPipeline.speakInterrupt(text)
    end

    local function walk(step)
        local n = #subButtons
        if n == 0 then return end
        local i = sub._index + step
        if i > n then i = 1 end
        if i < 1 then i = n end
        sub._index = i
        speakSub(i)
    end

    local function fire()
        local btn = subButtons[sub._index]
        if btn == nil then return end
        Events.AudioPlay2DSound("AS2D_IF_SELECT")
        local v1, v2
        pcall(function() v1 = btn:GetVoid1(); v2 = btn:GetVoid2() end)
        local ok, err = pcall(callback, v1, v2)
        if not ok then
            Log.error("FormHandler pulldown '" .. tostring(item.controlName)
                .. "' callback failed: " .. tostring(err))
        end
        HandlerStack.removeByName(subName, true)
    end

    local function cancel()
        HandlerStack.removeByName(subName, true)
    end

    sub.bindings = {
        { key = Keys.VK_UP,     mods = 0, description = "Previous entry",
          fn = function() walk(-1) end },
        { key = Keys.VK_DOWN,   mods = 0, description = "Next entry",
          fn = function() walk( 1) end },
        { key = Keys.VK_RETURN, mods = 0, description = "Select entry",
          fn = fire },
        { key = Keys.VK_ESCAPE, mods = 0, description = "Cancel",
          fn = cancel },
    }

    function sub.onActivate()
        SpeechPipeline.speakInterrupt(labelOf(item))
        speakSub(sub._index)
    end

    HandlerStack.push(sub)
end

-- Textfield edit mode ------------------------------------------------
--
-- Not a separate handler: the form itself swaps into `_editing = true`
-- with a smaller bindings array (Escape / Enter) and capturesAllInput
-- off so unbound keys fall through to the engine-focused EditBox.
-- A pushed sub-handler would sit *above* the form, and unbound keydowns
-- would walk into the form's own capturesAllInput=true and be eaten
-- before ever reaching the engine's EditBox router -- that was the bug
-- that motivated folding the sub in as a state.

parkFocus = function(self)
    -- parkFocus is called on show and on every tab switch. TakeFocus is
    -- EditBox-only in Civ V, so most park targets (buttons) will make the
    -- pcall fail. Log once per handler then set _parkDisabled so repeated
    -- tab switches don't spam the log. A real "release EditBox focus"
    -- strategy needs an XML-side parking EditBox, but adding one to the
    -- focus chain creates its own arrow-key interception problems -- so
    -- for now we prefer a silent no-op to a working-but-regression fix.
    if self._parkDisabled then return end
    if self._focusParkControl == nil then return end
    local park = Controls[self._focusParkControl]
    if park == nil then
        Log.warn("FormHandler '" .. self.name
            .. "' focus-park control '" .. tostring(self._focusParkControl)
            .. "' not found; disabling park for this handler")
        self._parkDisabled = true
        return
    end
    local ok, err = pcall(function() park:TakeFocus() end)
    if not ok then
        Log.warn("FormHandler '" .. self.name
            .. "' focus-park TakeFocus failed, disabling park for this handler: "
            .. tostring(err))
        self._parkDisabled = true
    end
end

local function enterEdit(self, item)
    local editBox = item._control
    local okGet, text = pcall(function() return editBox:GetText() end)
    if not okGet then
        Log.error("FormHandler '" .. self.name .. "' textfield '"
            .. tostring(item.controlName) .. "' GetText failed: " .. tostring(text))
    end
    self._editingItem         = item
    self._editingOriginal     = (okGet and text) or ""
    self._editingPriorCallback = item.priorCallback

    local okClear, errClear = pcall(function() editBox:SetText("") end)
    if not okClear then
        Log.error("FormHandler '" .. self.name .. "' textfield '"
            .. tostring(item.controlName) .. "' clear SetText failed: " .. tostring(errClear))
    end

    -- Wrapping callback chains per-character to the screen's validator
    -- so typing keeps driving the screen's own state (e.g. SetMaxTurns).
    -- Does not own the Enter pop: that is the edit-mode binding below.
    local priorCallback = item.priorCallback
    local function wrappingCallback(text, control, bIsEnter)
        if priorCallback then
            local ok, err = pcall(priorCallback, text, control, bIsEnter)
            if not ok then
                Log.error("FormHandler '" .. self.name .. "' textfield '"
                    .. tostring(item.controlName) .. "' prior callback failed: "
                    .. tostring(err))
            end
        end
    end

    local okReg, errReg = pcall(function() editBox:RegisterCallback(wrappingCallback) end)
    if not okReg then
        Log.error("FormHandler '" .. self.name .. "' textfield '"
            .. tostring(item.controlName) .. "' RegisterCallback failed: " .. tostring(errReg))
    end

    -- Defer TakeFocus to the next tick: calling it synchronously from
    -- inside a KEYDOWN handler seems to leave focus in a state the engine
    -- revokes when the matching KEYUP runs ~1 frame later, so subsequent
    -- WM_CHAR events arrive at our Context with no focused widget and the
    -- typed characters go nowhere. Letting the Enter KEYDOWN/KEYUP pair
    -- complete before we steal focus sidesteps that.
    TickPump.runOnce(function()
        if not self._editing or self._editingItem ~= item then
            -- User exited edit mode before the tick fired (Esc before
            -- the first frame). Don't steal focus.
            return
        end
        local okFocus, errFocus = pcall(function() editBox:TakeFocus() end)
        if not okFocus then
            Log.error("FormHandler '" .. self.name .. "' textfield '"
                .. tostring(item.controlName) .. "' TakeFocus failed: " .. tostring(errFocus))
        end
    end)

    self.bindings         = self._editBindings
    self.capturesAllInput = false
    self._editing         = true

    SpeechPipeline.speakInterrupt(
        Text.format("TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING", labelOf(item)))
end

local function exitEdit(self, restore)
    local item = self._editingItem
    if item == nil then return end
    local editBox = item._control
    local priorCallback = self._editingPriorCallback

    if restore then
        local ok, err = pcall(function() editBox:SetText(self._editingOriginal or "") end)
        if not ok then
            Log.error("FormHandler '" .. self.name .. "' textfield '"
                .. tostring(item.controlName) .. "' restore SetText failed: " .. tostring(err))
        end
    elseif priorCallback ~= nil then
        -- Commit path: EditBoxes without CallOnChar only fire their callback
        -- on Enter, and our VK_RETURN binding just intercepted that Enter to
        -- exit edit mode, so the screen's Set*_Cached never ran. Invoke the
        -- prior callback manually with the typed text and bIsEnter=true so
        -- the screen commits the value the same way a native Enter would.
        -- Safe for CallOnChar EditBoxes too: the setter/validator is
        -- idempotent, so one extra call with the final text is a no-op.
        local okGet, text = pcall(function() return editBox:GetText() end)
        local ok, err = pcall(priorCallback, (okGet and text) or "", editBox, true)
        if not ok then
            Log.error("FormHandler '" .. self.name .. "' textfield '"
                .. tostring(item.controlName) .. "' commit callback failed: " .. tostring(err))
        end
    end

    local okReg, errReg = pcall(function() editBox:RegisterCallback(priorCallback) end)
    if not okReg then
        Log.error("FormHandler '" .. self.name .. "' textfield '"
            .. tostring(item.controlName) .. "' restore RegisterCallback failed: " .. tostring(errReg))
    end

    parkFocus(self)

    local labelText = labelOf(item)
    self._editingItem          = nil
    self._editingOriginal      = nil
    self._editingPriorCallback = nil
    self.bindings              = self._navBindings
    self.capturesAllInput      = true
    self._editing              = false

    if restore then
        SpeechPipeline.speakInterrupt(
            Text.format("TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED", labelText))
    else
        -- Commit: read the just-saved text back so the user hears confirmation
        -- of the new value (rather than a silent exit). textfieldValue
        -- substitutes "blank" when the field is empty.
        SpeechPipeline.speakInterrupt(textfieldValue(item))
    end
end

local function onActivate(self, item)
    if not isActivatable(item) then
        SpeechPipeline.speakInterrupt(buildSpeech(self, item))
        return
    end
    local kind = item.kind
    if kind == "button" then
        activateButton(self, item)
    elseif kind == "checkbox" then
        activateCheckbox(self, item)
    elseif kind == "pulldown" then
        activatePullDown(self, item)
    elseif kind == "textfield" then
        enterEdit(self, item)
    elseif kind == "slider" then
        -- Slider Enter = no-op, just re-announce so the user can relocate.
        SpeechPipeline.speakInterrupt(buildSpeech(self, item))
    end
end

-- Key bindings -------------------------------------------------------

local function onUp(self)
    moveTo(self, nextValidIndex(currentItems(self), self._index, -1))
end

local function onDown(self)
    moveTo(self, nextValidIndex(currentItems(self), self._index, 1))
end

local function onLeft(self, big)
    local item = currentItems(self)[self._index]
    if item == nil then return end
    if item.kind == "slider" and isActivatable(item) then
        adjustSlider(self, item, -(big and item.bigStep or item.step))
    end
end

local function onRight(self, big)
    local item = currentItems(self)[self._index]
    if item == nil then return end
    if item.kind == "slider" and isActivatable(item) then
        adjustSlider(self, item, (big and item.bigStep or item.step))
    end
end

local function onHome(self)
    local item = currentItems(self)[self._index]
    if item and item.kind == "slider" and isActivatable(item) then
        snapSlider(self, item, 0)
    end
end

local function onEnd(self)
    local item = currentItems(self)[self._index]
    if item and item.kind == "slider" and isActivatable(item) then
        snapSlider(self, item, 1)
    end
end

local function onEnter(self)
    local item = currentItems(self)[self._index]
    if item == nil then return end
    if not isNavigable(item) then
        Log.warn("FormHandler '" .. self.name .. "': Enter on invalid item")
        return
    end
    onActivate(self, item)
end

local function onTab(self)
    cycleTab(self, 1)
end

local function onShiftTab(self)
    cycleTab(self, -1)
end

-- Public API ---------------------------------------------------------

local MOD_SHIFT = 1

function FormHandler.create(spec)
    assert(type(spec) == "table", "FormHandler.create requires a spec table")
    assert(type(spec.name) == "string" and spec.name ~= "", "spec.name required")
    assert(type(spec.displayName) == "string" and spec.displayName ~= "",
        "spec.displayName required")
    assert(spec.tabs == nil or spec.items == nil,
        "spec must have EITHER tabs OR items, not both")

    local self = {
        name             = spec.name,
        displayName      = spec.displayName,
        capturesAllInput = true,
        _index           = 1,
        _tabIndex        = 1,
        -- Name of a non-EditBox control the form can TakeFocus on to
        -- release an engine-held EditBox focus: applied on screen show,
        -- on every tab switch (engine auto-focuses the first EditBox in
        -- the newly visible panel), and on exit from textfield edit mode.
        -- The engine has no ClearFocus API; only way to defocus an
        -- EditBox is to TakeFocus on a different widget.
        _focusParkControl = spec.focusParkControl,
        -- _initialized gates the first-open setup (reset cursor to first
        -- item, speak displayName + tab + item). Re-activations from the
        -- same open (pulldown sub-handler pop) preserve cursor position
        -- and just re-announce where the user is.
        _initialized     = false,
        -- Textfield edit-mode state. While _editing is true the handler
        -- swaps self.bindings to self._editBindings and flips
        -- capturesAllInput off so typing falls through to the focused
        -- EditBox. See enterEdit / exitEdit for the full state machine.
        _editing                  = false,
        _editingItem              = nil,
        _editingOriginal          = nil,
        _editingPriorCallback     = nil,
    }

    if spec.tabs then
        assert(type(spec.tabs) == "table" and #spec.tabs > 0,
            "spec.tabs must be a non-empty array")
        local tabs = {}
        for i, tab in ipairs(spec.tabs) do
            assert(type(tab.name) == "string",
                "tab " .. i .. ".name (TXT_KEY) required")
            assert(type(tab.items) == "table",
                "tab " .. i .. ".items required")
            tabs[i] = {
                name      = tab.name,
                showPanel = tab.showPanel,
                _items    = resolveItems(self, tab.items, "tab " .. i),
            }
        end
        self.tabs = tabs
    else
        assert(type(spec.items) == "table", "spec.items or spec.tabs required")
        self._items = resolveItems(self, spec.items, "items")
    end

    self._navBindings = {
        { key = Keys.VK_UP,     mods = 0,          description = "Previous item",
          fn = function() onUp(self) end },
        { key = Keys.VK_DOWN,   mods = 0,          description = "Next item",
          fn = function() onDown(self) end },
        { key = Keys.VK_LEFT,   mods = 0,          description = "Decrease / prev tab",
          fn = function() onLeft(self, false) end },
        { key = Keys.VK_RIGHT,  mods = 0,          description = "Increase / next tab",
          fn = function() onRight(self, false) end },
        { key = Keys.VK_LEFT,   mods = MOD_SHIFT,  description = "Decrease by big step",
          fn = function() onLeft(self, true) end },
        { key = Keys.VK_RIGHT,  mods = MOD_SHIFT,  description = "Increase by big step",
          fn = function() onRight(self, true) end },
        { key = Keys.VK_HOME,   mods = 0,          description = "Slider to minimum",
          fn = function() onHome(self) end },
        { key = Keys.VK_END,    mods = 0,          description = "Slider to maximum",
          fn = function() onEnd(self) end },
        { key = Keys.VK_RETURN, mods = 0,          description = "Activate",
          fn = function() onEnter(self) end },
        { key = Keys.VK_SPACE,  mods = 0,          description = "Activate",
          fn = function() onEnter(self) end },
        { key = Keys.VK_TAB,    mods = 0,          description = "Next tab",
          fn = function() onTab(self) end },
        { key = Keys.VK_TAB,    mods = MOD_SHIFT,  description = "Previous tab",
          fn = function() onShiftTab(self) end },
    }
    -- Narrow binding set for textfield edit mode. All other keys fall
    -- through (capturesAllInput=false) to the engine-focused EditBox.
    self._editBindings = {
        { key = Keys.VK_ESCAPE, mods = 0, description = "Cancel edit",
          fn = function() exitEdit(self, true) end },
        { key = Keys.VK_RETURN, mods = 0, description = "Commit edit",
          fn = function() exitEdit(self, false) end },
    }
    self.bindings = self._navBindings

    function self.onActivate()
        local items = currentItems(self)
        if not self._initialized then
            -- Fresh screen open: jump to tab 1's first valid item and
            -- speak displayName + tab name + item.
            if self.tabs then
                self._tabIndex = 1
                local tab = self.tabs[1]
                if type(tab.showPanel) == "function" then
                    local ok, err = pcall(tab.showPanel)
                    if not ok then
                        Log.error("FormHandler '" .. self.name .. "' initial showPanel: "
                            .. tostring(err))
                    end
                end
                items = currentItems(self)
            end
            local first = nextValidIndex(items, 0, 1)
            self._index = first or 1
            self._initialized = true
            SpeechPipeline.speakInterrupt(self.displayName)
            if self.tabs then
                SpeechPipeline.speakQueued(Text.key(self.tabs[self._tabIndex].name))
            end
            if first ~= nil then
                SpeechPipeline.speakQueued(buildSpeech(self, items[first]))
            end
            return
        end

        -- Re-activation (e.g., pulldown sub-handler just popped). Preserve
        -- cursor position; just re-announce the current widget. Validate
        -- the cursor first: a pulldown selection can flip item visibility
        -- (e.g., Scenario check toggles MaxTurns-related rows), so the
        -- cached _index might now point at a hidden or out-of-range slot.
        local item = items[self._index]
        if item == nil or not isNavigable(item) then
            local next = nextValidIndex(items, self._index - 1, 1)
            if next == nil then return end
            self._index = next
            item = items[next]
        end
        SpeechPipeline.speakInterrupt(buildSpeech(self, item))
    end

    -- onDeactivate intentionally preserves _index / _tabIndex so a pushed
    -- sub-handler (pulldown sub-mode) can pop back and the user lands
    -- where they were. The ShowHide(hide=true) path clears _initialized
    -- so the next screen open starts fresh.
    function self.onDeactivate()
    end

    -- Replace the item list used for navigation. For single-tab forms,
    -- tabIndex is ignored. For tabbed forms, it defaults to the currently
    -- active tab. Intended for screens whose widgets are built by
    -- InstanceManager (dynamic checkboxes, dependent pulldowns): the
    -- access file walks the manager, produces fresh items with direct
    -- `control` references, and calls setItems to swap them in.
    --
    -- No announcement on swap; if the cursor position is no longer valid
    -- in the new list we silently clamp to the first valid item. Callers
    -- should re-invoke whenever the engine re-populates the stack.
    function self.setItems(items, tabIndex)
        assert(type(items) == "table", "setItems: items must be a table")
        if self.tabs then
            tabIndex = tabIndex or self._tabIndex
            assert(self.tabs[tabIndex] ~= nil,
                "setItems: tab " .. tostring(tabIndex) .. " out of range")
            self.tabs[tabIndex]._items = resolveItems(self, items,
                "setItems tab " .. tabIndex)
        else
            self._items = resolveItems(self, items, "setItems")
        end
        -- Clamp the cursor if it now points past the end or at a hidden slot.
        -- Only matters when the mutated list is the one the cursor is in;
        -- swapping an inactive tab's items is invisible until the user
        -- switches to it, and switchTab already re-validates on entry.
        if not self.tabs or tabIndex == self._tabIndex then
            local curr = currentItems(self)
            local item = curr[self._index]
            if item == nil or not isNavigable(item) then
                local next = nextValidIndex(curr, (self._index or 1) - 1, 1)
                self._index = next or 1
            end
        end
    end

    return self
end

function FormHandler.install(ContextPtr, spec)
    local handler = FormHandler.create(spec)
    local priorShowHide = spec.priorShowHide
    local priorInput    = spec.priorInput

    -- enterEdit defers its TakeFocus to the next tick via TickPump.runOnce,
    -- so the Context must be tick-driven for the deferred call to fire.
    TickPump.install(ContextPtr)

    ContextPtr:SetShowHideHandler(function(bIsHide, bIsInit)
        if priorShowHide then
            local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
            if not ok then
                Log.error("FormHandler '" .. handler.name
                    .. "' prior ShowHide: " .. tostring(err))
            end
        end
        HandlerStack.removeByName(handler.name, false)
        if bIsHide then
            handler._initialized = false
            return
        end
        -- Park focus on a non-EditBox control before push so arrow keys are
        -- not swallowed by a base-screen TakeFocus on an EditBox (e.g.,
        -- ChangePassword's ShowHideHandler focuses the Old/New password box).
        parkFocus(handler)
        HandlerStack.push(handler)
    end)

    ContextPtr:SetInputHandler(function(msg, wp, lp)
        -- During edit mode, claim the KEYUP of Enter so the engine's
        -- default Enter-release handling doesn't revoke focus from the
        -- EditBox we just took focus on. Symptom without this: WM_CHARs
        -- reach the Context but the EditBox ends up empty on commit.
        if handler._editing and msg == 257 and wp == Keys.VK_RETURN then
            return true
        end
        if (msg == 256 or msg == 260) and wp == Keys.VK_ESCAPE then
            -- Esc has three meanings depending on state:
            --   on the form (non-edit): bypass to the screen's Back / OnNo.
            --   on the form in edit mode: route to the edit-mode binding so
            --     the text is restored and edit mode exits -- the user is
            --     *not* trying to close the screen.
            --   on a pushed sub (pulldown): let the sub's Esc cancel it.
            local top = HandlerStack.active()
            if top == handler and not handler._editing then
                if priorInput then return priorInput(msg, wp, lp) end
                return false
            end
            local mods = InputRouter.currentModifierMask()
            if InputRouter.dispatch(wp, mods, msg) then return true end
            if priorInput then return priorInput(msg, wp, lp) end
            return false
        end
        local mods = InputRouter.currentModifierMask()
        if InputRouter.dispatch(wp, mods, msg) then return true end
        if priorInput then return priorInput(msg, wp, lp) end
        return false
    end)

    return handler
end

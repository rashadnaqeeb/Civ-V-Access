-- Edit-mode sub-handler pushed when the user activates a textfield item on a
-- FormHandler. Passthrough-only by design: the engine owns typing, backspace,
-- arrows, and IME composition, so the sub-handler just carves out a known
-- starting state and owns Escape / Enter for cancel / commit.
--
-- On push: snapshot current text, clear the EditBox, take engine focus,
-- announce. The wrapping callback is installed on the EditBox so the
-- screen's own per-character validator (item.priorCallback) keeps running
-- as the user types; on pop, the prior callback is restored.
--
-- Binding contract:
--   Escape : restore snapshot, pop, announce restored.
--   Enter  : pop and -- if item.commitFn is provided -- call it to drive
--            the screen's natural commit (OnAccept / OnOK / OnSave). A
--            screen where the EditBox's prior callback already handles
--            commit on bIsEnter=true (SaveMenu's OnEditBoxChange) still
--            works because that callback fires from the engine before
--            our Enter binding runs in the Context InputHandler pass.
--            Screens without a commit shortcut leave commitFn nil; Enter
--            simply returns the user to the form so they can navigate to
--            an Accept button and activate it there.
--
-- Enter is bound at the sub-handler level rather than deriving the pop
-- from the wrapping callback because the engine fires the Context
-- InputHandler after the EditBox callback, and FormHandler's Enter
-- binding on the textfield item would re-push the sub otherwise.

TextFieldSubHandler = {}

local function announce(key, labelText)
    SpeechPipeline.speakInterrupt(Text.format(key, labelText))
end

function TextFieldSubHandler.push(parentName, item, labelText, focusParkName)
    local editBox = item._control
    if editBox == nil then
        Log.warn("TextFieldSubHandler: missing EditBox for '"
            .. tostring(item.controlName) .. "'")
        return
    end

    local subName = parentName .. "/" .. tostring(item.controlName) .. "_TextField"
    local priorCallback = item.priorCallback
    local commitFn      = item.commitFn
    local originalText

    local sub = {
        name             = subName,
        capturesAllInput = false,
    }

    -- Installed on the EditBox for the sub-handler's lifetime so the
    -- screen's own validator keeps running as the user types. Does NOT
    -- pop on bIsEnter=true; the sub's Enter binding owns that, because
    -- the engine calls this callback before it propagates Enter to the
    -- Context InputHandler, and popping here would cause FormHandler's
    -- textfield Enter binding to re-push the sub on the subsequent pass.
    local function wrappingCallback(text, control, bIsEnter)
        if priorCallback then
            local ok, err = pcall(priorCallback, text, control, bIsEnter)
            if not ok then
                Log.error("TextFieldSubHandler '" .. subName
                    .. "' prior callback failed: " .. tostring(err))
            end
        end
    end

    local function onEscape()
        local ok, err = pcall(function() editBox:SetText(originalText or "") end)
        if not ok then
            Log.error("TextFieldSubHandler '" .. subName
                .. "' restore SetText failed: " .. tostring(err))
        end
        HandlerStack.removeByName(subName, true)
        announce("TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED", labelText)
    end

    local function onEnter()
        HandlerStack.removeByName(subName, true)
        if commitFn then
            announce("TXT_KEY_CIVVACCESS_TEXTFIELD_COMMITTED", labelText)
            local ok, err = pcall(commitFn)
            if not ok then
                Log.error("TextFieldSubHandler '" .. subName
                    .. "' commit failed: " .. tostring(err))
            end
        end
    end

    sub.bindings = {
        { key = Keys.VK_ESCAPE, mods = 0, description = "Cancel edit",
          fn = onEscape },
        { key = Keys.VK_RETURN, mods = 0, description = "Commit edit",
          fn = onEnter },
    }

    function sub.onActivate()
        local okGet, text = pcall(function() return editBox:GetText() end)
        originalText = okGet and text or ""
        local okClear, errClear = pcall(function() editBox:SetText("") end)
        if not okClear then
            Log.error("TextFieldSubHandler '" .. subName
                .. "' clear SetText failed: " .. tostring(errClear))
        end
        local okReg, errReg = pcall(function()
            editBox:RegisterCallback(wrappingCallback)
        end)
        if not okReg then
            Log.error("TextFieldSubHandler '" .. subName
                .. "' RegisterCallback failed: " .. tostring(errReg))
        end
        local okFocus, errFocus = pcall(function() editBox:TakeFocus() end)
        if not okFocus then
            Log.error("TextFieldSubHandler '" .. subName
                .. "' TakeFocus failed: " .. tostring(errFocus))
        end
        announce("TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING", labelText)
    end

    function sub.onDeactivate()
        local ok, err = pcall(function()
            editBox:RegisterCallback(priorCallback)
        end)
        if not ok then
            Log.error("TextFieldSubHandler '" .. subName
                .. "' restore RegisterCallback failed: " .. tostring(err))
        end
        -- Park engine focus on a non-EditBox control so the form's arrow-key
        -- bindings can receive input again. The engine has no ClearFocus API,
        -- so TakeFocus on a different widget is the only way to defocus the
        -- EditBox. If the screen closes on commit (common case) this is a
        -- harmless no-op since the whole Context tears down next frame.
        if focusParkName ~= nil then
            local park = Controls[focusParkName]
            if park == nil then
                Log.warn("TextFieldSubHandler '" .. subName
                    .. "' focus-park control '" .. tostring(focusParkName)
                    .. "' not found")
            else
                local okPark, errPark = pcall(function() park:TakeFocus() end)
                if not okPark then
                    Log.error("TextFieldSubHandler '" .. subName
                        .. "' focus-park TakeFocus failed: " .. tostring(errPark))
                end
            end
        end
    end

    HandlerStack.push(sub)
end

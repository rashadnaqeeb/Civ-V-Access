-- Edit-mode sub-handler for BaseMenuItems.Textfield. Pushed above the menu
-- when Textfield.activate fires. capturesAllInput is false so every printable
-- character / Backspace / caret arrow falls through the mod's InputRouter to
-- the engine-focused EditBox.
--
-- The sub also sets _editMode = true, a flag that BaseMenuCore's install
-- InputHandler reads to swallow the Enter KEYUP (msg 257). Without that
-- swallow, the engine's default Enter-release revokes focus from the EditBox
-- we just took focus on and typed characters end up nowhere. The flag is the
-- only coupling back to Core; setting it from this file is fine because
-- install reads it off the active handler by name.
--
-- Enter commits: reads the current text and invokes priorCallback with
-- bIsEnter=true so non-CallOnChar EditBoxes (OptionsMenu's email, SMTP host,
-- MaxTurns / TurnTimer fields) still persist to OptionsManager / PreGame,
-- then parks focus + pops. Esc restores the snapshot.
--
-- The pop triggers BaseMenu.onActivate which re-announces the current item
-- (with its updated value). We then speakInterrupt the committed value or
-- "<label> restored" so the user hears explicit confirmation.

BaseMenuEditMode = {}

function BaseMenuEditMode.push(menu, textfieldItem)
    local editBox = textfieldItem._control
    local priorCallback = textfieldItem.priorCallback
    local errCtx = "BaseMenu '" .. menu.name .. "' textfield '" .. tostring(textfieldItem.controlName) .. "'"

    local function safe(op, fn)
        local ok, result = pcall(fn)
        if not ok then
            Log.error(errCtx .. " " .. op .. " failed: " .. tostring(result))
        end
        return ok, result
    end

    local okGet, text = safe("GetText", function()
        return editBox:GetText()
    end)
    local originalText = (okGet and text) or ""

    safe("clear SetText", function()
        editBox:SetText("")
    end)

    -- Wrapping callback chains every character to the screen's validator so
    -- typing keeps driving the screen's own state (e.g. SetMaxTurns). Does
    -- not own the Enter-pop: that is the edit-mode Esc/Enter bindings.
    local function wrappingCallback(t, control, bIsEnter)
        if priorCallback then
            safe("prior callback", function()
                priorCallback(t, control, bIsEnter)
            end)
        end
    end

    safe("RegisterCallback", function()
        editBox:RegisterCallback(wrappingCallback)
    end)

    local subName = menu.name .. "/" .. tostring(textfieldItem.controlName) .. "_Edit"
    local sub = {
        name = subName,
        capturesAllInput = false,
        _editMode = true,
    }

    local function exit(restore)
        if restore then
            safe("restore SetText", function()
                editBox:SetText(originalText)
            end)
        elseif priorCallback ~= nil then
            -- Non-CallOnChar EditBoxes only fire priorCallback on Enter, and
            -- our Enter binding just intercepted that Enter. Invoke prior
            -- manually with bIsEnter=true so the screen commits the value
            -- the same way a native Enter would. Safe for CallOnChar boxes
            -- too (the setter/validator is idempotent).
            local okG, typed = safe("commit GetText", function()
                return editBox:GetText()
            end)
            local committed = (okG and typed) or ""
            safe("commit callback", function()
                priorCallback(committed, editBox, true)
            end)
        end
        safe("restore RegisterCallback", function()
            editBox:RegisterCallback(priorCallback)
        end)
        HandlerStack.removeByName(subName, true)
        if restore then
            SpeechPipeline.speakInterrupt(
                Text.format("TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED", BaseMenuItems.labelOf(textfieldItem))
            )
        else
            -- Speak committed value (blank sentinel if empty) so the user
            -- hears explicit confirmation of what was saved.
            SpeechPipeline.speakInterrupt(BaseMenuItems._textfieldCurrentValue(textfieldItem))
        end
    end

    sub.bindings = {
        {
            key = Keys.VK_ESCAPE,
            mods = 0,
            description = "Cancel edit",
            fn = function()
                exit(true)
            end,
        },
        {
            key = Keys.VK_RETURN,
            mods = 0,
            description = "Commit edit",
            fn = function()
                exit(false)
            end,
        },
    }
    -- Edit-mode overrides the menu's Esc binding with "Cancel edit" semantics.
    -- Authoring these explicitly means ? help shows the edit-mode meaning
    -- (not the menu's "Cancel") while edit mode is on top -- the keyLabel
    -- dedupe in collectHelpEntries drops the menu's entry in favor of ours.
    sub.helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ENTER",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT",
        },
    }

    SpeechPipeline.speakInterrupt(
        Text.format("TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING", BaseMenuItems.labelOf(textfieldItem))
    )

    HandlerStack.push(sub)

    -- Defer TakeFocus: calling it synchronously from inside a KEYDOWN
    -- handler leaves focus in a state the engine revokes when the matching
    -- KEYUP runs ~1 frame later, and subsequent WM_CHARs arrive with no
    -- focused widget. Letting the Enter pair complete before we steal focus
    -- sidesteps that.
    TickPump.runOnce(function()
        if HandlerStack.active() ~= sub then
            -- User exited edit mode before the tick fired (Esc before the
            -- first frame). Don't steal focus.
            return
        end
        safe("TakeFocus", function()
            editBox:TakeFocus()
        end)
    end)
end

return BaseMenuEditMode

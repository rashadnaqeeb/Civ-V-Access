-- Modal text entry over a dedicated off-screen engine EditBox. The box is
-- the character source, so typed text follows the player's keyboard layout
-- (Cyrillic, accented Latin, and whatever composition the engine's own
-- rename fields support) instead of a hand-rolled virtual-key-to-ASCII
-- map, which can only ever produce a-z, 0-9 and space. Callers own all
-- prompt speech; open() pushes a barrier handler whose Enter binding reads
-- the typed text back with GetText, and Escape cancels. Typing echo is the
-- screen reader's job, as it was for the virtual-key captures.
--
-- The focus dance mirrors BaseMenuEditMode (the menu-Textfield flavor of
-- the same engine machinery):
--   * The box is wiped with ClearString + SetText on open -- a focused
--     EditBox keeps a typing buffer separate from the displayed text, and
--     GetText reads the buffer, so both must clear or a prior capture's
--     text leaks into this one.
--   * TakeFocus is deferred one tick so the opening chord's KEYUP can't
--     revoke the just-taken focus, with an active-handler guard for an
--     Escape that lands before the first frame.
--   * Close hides then reshows the box: Civ V has no focus-release call
--     and only drops focus when the focused control is hidden (the
--     ChatAccess pattern for persistent boxes). Without it, focus lingers
--     and later keystrokes keep filling the box's buffer. Seated in
--     onDeactivate so every removal path -- commit, Escape, a stack drain
--     or dead-env purge -- releases it.
--
-- capturesAllInput keeps typed keys out of the handlers below (the
-- engine's focus routing delivers characters to the box regardless of what
-- our Lua dispatch returns, so the barrier costs nothing). _editMode makes
-- InputRouter suspend its Shift+? / F12 overlay hooks -- those chords are
-- characters headed for the box while a capture is up -- and makes
-- BaseMenu.install-seated screens swallow the Enter KEYUP.

EditCapture = {}

-- opts:
--   name        handler name on the stack (also the removeByName key).
--   control     the EditBox userdata; the caller resolves Controls.X in
--               the Context that declares the box.
--   onCommit    fn(text) -> spoken string or nil. Runs on Enter, after the
--               pop, with whatever was typed (possibly ""), so it may push
--               handlers of its own. The returned string is spoken.
--   onCancel    optional fn() -> spoken string or nil; same contract on
--               Escape.
--   onChar      optional fn(text); fires per keystroke with the box's
--               current text while this capture is active (the box needs
--               CallOnChar). Used to mirror the query into a visible
--               engine control for a sighted partner.
--   helpEntries optional override for the Enter / Escape help rows.
function EditCapture.open(opts)
    local name = opts.name
    local control = opts.control
    local onCommit = opts.onCommit
    local errCtx = "EditCapture '" .. tostring(name) .. "'"
    Log.check(control ~= nil, errCtx .. ": control is nil (entry box missing from the Context's XML)")
    Log.check(type(onCommit) == "function", errCtx .. ": onCommit must be a function")

    local function safe(op, fn)
        local ok, result = pcall(fn)
        if not ok then
            Log.error(errCtx .. " " .. op .. " failed: " .. tostring(result))
        end
        return ok, result
    end

    local function speak(msg)
        if msg ~= nil and msg ~= "" then
            SpeechPipeline.speakInterrupt(msg)
        end
    end

    safe("open ClearString", function()
        control:ClearString()
    end)
    safe("open SetText", function()
        control:SetText("")
    end)

    local sub = {
        name = name,
        capturesAllInput = true,
        _editMode = true,
        helpEntries = opts.helpEntries or {
            {
                keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ENTER",
                description = "TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT",
            },
            {
                keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC",
                description = "TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT",
            },
        },
    }

    sub.onDeactivate = function()
        safe("focus release SetHide", function()
            control:SetHide(true)
        end)
        TickPump.runOnce(function()
            safe("focus release reshow", function()
                control:SetHide(false)
            end)
        end)
    end

    sub.bindings = {
        {
            key = Keys.VK_RETURN,
            mods = 0,
            description = "Commit text entry",
            fn = function()
                local okG, typed = safe("commit GetText", function()
                    return control:GetText()
                end)
                local text = ""
                if okG and typed ~= nil then
                    text = tostring(typed)
                end
                HandlerStack.removeByName(name)
                local okC, msg = safe("onCommit", function()
                    return onCommit(text)
                end)
                if okC then
                    speak(msg)
                end
            end,
        },
        {
            key = Keys.VK_ESCAPE,
            mods = 0,
            description = "Cancel text entry",
            fn = function()
                HandlerStack.removeByName(name)
                if opts.onCancel ~= nil then
                    local ok, msg = safe("onCancel", opts.onCancel)
                    if ok then
                        speak(msg)
                    end
                end
            end,
        },
    }

    if opts.onChar ~= nil then
        local onChar = opts.onChar
        -- The callback stays bound after close (RegisterCallback rejects
        -- nil), so it self-neutralizes by checking that this capture is
        -- still the active handler. Enter fires are dropped: the Enter
        -- binding above owns the single commit.
        safe("RegisterCallback", function()
            control:RegisterCallback(function(text, _, bIsEnter)
                if bIsEnter or HandlerStack.active() ~= sub then
                    return
                end
                local ok, err = pcall(onChar, text)
                if not ok then
                    Log.error(errCtx .. " onChar failed: " .. tostring(err))
                end
            end)
        end)
    end

    HandlerStack.push(sub)

    TickPump.runOnce(function()
        if HandlerStack.active() ~= sub then
            -- User exited before the tick fired. Don't steal focus.
            return
        end
        safe("TakeFocus", function()
            control:TakeFocus()
        end)
    end)
end

return EditCapture

-- SetCityName (rename-city dialog) accessibility. Textfield plus Accept /
-- Cancel. The popup opens straight into edit mode so the user can type
-- immediately; Enter commits via OnAccept (gated on the AcceptButton's
-- disabled state, which Validate drives per-keystroke through CallOnChar=1),
-- Esc cancels edit (then a second Esc closes via the vendor InputHandler).
-- Buttons remain navigable if the user exits edit mode and walks the menu.
--
-- Enter on an invalid name (less than 3 non-whitespace chars, or any of
-- the engine's reserved characters) speaks the reason and cancels the
-- popup so the user isn't stranded with a silently-disabled Accept button.
-- Cancel + speech are deferred one tick so they fire after BaseMenuEditMode's
-- own commit announce, which would otherwise interrupt our reason.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function nameFailureReason(text)
    local nonWhite = 0
    for i = 1, #text do
        if string.byte(text, i) ~= 32 then
            nonWhite = nonWhite + 1
        end
    end
    if nonWhite < 3 then
        return Text.key("TXT_KEY_CIVVACCESS_RENAME_TOO_SHORT")
    end
    return Text.key("TXT_KEY_CIVVACCESS_RENAME_INVALID_CHARS")
end

local textfieldItem = BaseMenuItems.Textfield({
    controlName   = "EditCityName",
    textKey       = "TXT_KEY_PRODPANEL_CITY_NAME",
    priorCallback = function(text, control, bIsEnter)
        Validate(text, control, bIsEnter)
        if not bIsEnter then
            return
        end
        if not Controls.AcceptButton:IsDisabled() then
            OnAccept()
            return
        end
        local reason = nameFailureReason(text)
        TickPump.runOnce(function()
            OnCancel()
            SpeechPipeline.speakInterrupt(reason)
        end)
    end,
})

BaseMenu.install(ContextPtr, {
    name          = "SetCityName",
    displayName   = Text.key("TXT_KEY_NAME_CITY_TITLE"),
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    onShow        = function(handler)
        TickPump.runOnce(function()
            if HandlerStack.active() ~= handler then
                return
            end
            BaseMenuEditMode.push(handler, textfieldItem)
        end)
    end,
    items         = {
        textfieldItem,
        BaseMenuItems.Button({
            controlName = "AcceptButton",
            textKey     = "TXT_KEY_ACCEPT_BUTTON",
            activate    = function() OnAccept() end,
        }),
        BaseMenuItems.Button({
            controlName = "CancelButton",
            textKey     = "TXT_KEY_CANCEL_BUTTON",
            activate    = function() OnCancel() end,
        }),
    },
})

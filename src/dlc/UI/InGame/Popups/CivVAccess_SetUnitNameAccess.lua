-- SetUnitName (rename-unit dialog) accessibility. Textfield plus Accept /
-- Cancel, identical shape to SetCityName. See SetCityNameAccess header for
-- the auto-edit-mode and invalid-name-cancels flow.

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
    controlName   = "EditUnitName",
    textKey       = "TXT_KEY_UNIT_NAME",
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
    name          = "SetUnitName",
    displayName   = Text.key("TXT_KEY_NAME_UNIT_TITLE"),
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

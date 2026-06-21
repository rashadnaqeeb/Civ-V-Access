-- NewEraPopup accessibility. DescriptionLabel is populated with
-- "TXT_KEY_POP_NEW_ERA_DESCRIPTION" formatted against the era. Single
-- Close button dismisses via OnClose. F2 reads a prose description of the
-- era's splash painting (see CivVAccess_EraDescription).

include("CivVAccess_PopupBoot")
include("CivVAccess_EraDescStrings_en_US")
include("CivVAccess_EraDescription")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- The vendor file resolves the new era from popupInfo (Data1 is the Eras
-- row ID), but that state is file-local and invisible to this wrapper.
-- Capture the same field off the same event the vendor's OnPopup
-- subscribes to, with the same Type filter. The ID is a stable handle;
-- F2 re-queries GameInfo through it at keypress time.
local capturedEraID = nil
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_NEW_ERA then
        return
    end
    capturedEraID = popupInfo.Data1
end)

-- Returns Eras.Type of the era just entered, else nil (nothing captured
-- yet).
local function eraType()
    if capturedEraID == nil then
        return nil
    end
    local row = GameInfo.Eras[capturedEraID]
    if row == nil then
        return nil
    end
    return row.Type
end

-- Shared by the F1 preamble and the Alt+Up/Down review, which splits the era
-- description on any newlines.
local function descriptionFragments()
    return { Controls.DescriptionLabel:GetText() or "" }
end

local handler = BaseMenu.install(ContextPtr, {
    name = "NewEraPopup",
    displayName = Text.key("TXT_KEY_POP_NEW_ERA_TITLE"),
    preamble = function()
        return Text.joinNonEmpty(descriptionFragments())
    end,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    items = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey = "TXT_KEY_CLOSE",
            activate = function()
                OnClose()
            end,
        }),
    },
})

RewardReview.install(handler, descriptionFragments)

EraDescription.bindF2(handler, eraType)

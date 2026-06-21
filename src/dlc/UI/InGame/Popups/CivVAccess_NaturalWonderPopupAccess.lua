-- NaturalWonderPopup accessibility. WonderLabel holds the feature name
-- (set from feature.Description in OnPopup); DescriptionLabel holds the
-- yield/happiness/promotion/gold summary. Single Close button dismisses
-- via OnCloseButtonClicked. F2 reads a prose description of the wonder's
-- portrait art (see CivVAccess_NaturalWonderDescription).

include("CivVAccess_PopupBoot")
include("CivVAccess_NaturalWonderDescStrings_en_US")
include("CivVAccess_NaturalWonderDescription")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- The vendor file resolves the wonder's plot from popupInfo (Data1 and
-- Data2 are the plot's x and y), but that state is file-local and
-- invisible to this wrapper. Capture the same two fields off the same
-- event the vendor's OnPopup subscribes to, with the same Type filter.
-- The coordinates are a stable handle; F2 re-queries the plot's feature
-- through them at keypress time.
local capturedX = nil
local capturedY = nil
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_NATURAL_WONDER_REWARD then
        return
    end
    capturedX = popupInfo.Data1
    capturedY = popupInfo.Data2
end)

-- Returns Features.Type of the natural wonder on the captured plot, else
-- nil (nothing captured yet).
local function wonderFeatureType()
    if capturedX == nil then
        return nil
    end
    local plot = Map.GetPlot(capturedX, capturedY)
    local row = GameInfo.Features[plot:GetFeatureType()]
    if row == nil or not row.NaturalWonder then
        return nil
    end
    return row.Type
end

-- Wonder name then description. Shared by the F1 preamble (joined) and the
-- Alt+Up/Down review so the two cannot drift; joinNonEmpty drops either when
-- empty, matching the prior branch logic.
local function fragments()
    return { Controls.WonderLabel:GetText() or "", Controls.DescriptionLabel:GetText() or "" }
end

local function preamble()
    return Text.joinNonEmpty(fragments())
end

local handler = BaseMenu.install(ContextPtr, {
    name = "NaturalWonderPopup",
    displayName = Text.key("TXT_KEY_POP_NATURAL_WONDER_FOUND"),
    preamble = preamble,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    items = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey = "TXT_KEY_CLOSE",
            activate = function()
                OnCloseButtonClicked()
            end,
        }),
    },
})

RewardReview.install(handler, fragments)

NaturalWonderDescription.bindF2(handler, wonderFeatureType)

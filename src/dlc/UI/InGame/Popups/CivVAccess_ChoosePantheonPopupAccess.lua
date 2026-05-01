-- ChoosePantheonPopup accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_FOUND_PANTHEON.
-- Serves two related screens: the original pantheon founder (Data2 > 0)
-- and the Reformation bonus belief picker (Data2 == 0). Both walk a list
-- of beliefs sorted by short-description locale order.
--
-- Flow: pick a belief -> SelectPantheon(beliefID) shows the ChooseConfirm
-- overlay with the formatted "found {Belief}?" prompt -> we push
-- ChooseConfirmSub which navigates the overlay's Yes / No buttons.
-- Unusually, Pantheon's overlay buttons are named "Yes" / "No" rather
-- than "ConfirmYes" / "ConfirmNo" (the pattern the other Choose* popups
-- use), so we pass the control names through. On Yes, OnYes fires
-- Network.SendFoundPantheon and OnClose dismisses.

include("CivVAccess_PopupBoot")
include("CivVAccess_ChooseConfirmSub")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function preambleText()
    local c = Controls.PanelTitle
    if c == nil then
        return ""
    end
    local ok, text = pcall(function()
        return c:GetText()
    end)
    if not ok or text == nil then
        return ""
    end
    return tostring(text)
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChoosePantheonPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

local function buildItems(popupInfo)
    local bPantheons = popupInfo.Data2 and popupInfo.Data2 > 0
    local available = bPantheons and Game.GetAvailablePantheonBeliefs() or Game.GetAvailableReformationBeliefs()

    local rows = {}
    for _, beliefID in ipairs(available) do
        local belief = GameInfo.Beliefs[beliefID]
        if belief ~= nil then
            rows[#rows + 1] = {
                ID = belief.ID,
                Name = Text.key(belief.ShortDescription),
                Description = Text.key(belief.Description),
            }
        end
    end
    table.sort(rows, function(a, b)
        return Locale.Compare(a.Name, b.Name) < 0
    end)

    local items = {}
    for _, row in ipairs(rows) do
        local beliefID = row.ID
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = row.Name,
            tooltipText = row.Description,
            activate = function()
                SelectPantheon(beliefID)
                ChooseConfirmSub.push({
                    yesControl = "Yes",
                    noControl = "No",
                    onYes = function()
                        OnYes()
                    end,
                })
            end,
        })
    end
    return items
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON then
        return
    end
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChoosePantheonPopupAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)

-- ChooseGoodyHutReward accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_GOODY_HUT_REWARD.
-- Base's PopulateItems["GoodyHutBonuses"] walks GameInfo.GoodyHuts in index
-- order, filters each by pPlayer:CanGetGoody(pPlot, iGoodyType, pUnit), and
-- spawns one Button per eligible bonus inside Controls.ItemStack. Selection
-- is tracked in a global SelectedItems = {{iGoodyType, controlTable}};
-- ConfirmButton stays disabled until g_NumberOfFreeItems == #SelectedItems
-- (always 1 today -- the base errors hard on > 1), and fires
-- CommitItems["GoodyHutBonuses"] which sends Network.SendGoodyChoice.
--
-- Our listener fires after base's on the same popup event. We rebuild a
-- parallel BaseMenu item list: one Choice per eligible GoodyHut plus a
-- trailing Confirm Button targeting the real ConfirmButton control. Enter
-- on a Choice replaces SelectedItems with {{iGoodyType, stub}} and enables
-- Confirm (matching base's single-select branch without touching the
-- sighted SelectionAnim, which the blind player cannot observe anyway).
-- Enter on Confirm runs the base's CommitItems closure (which reads
-- pUnit / pPlot from base's file locals) and hides the popup.
--
-- deferActivate=true on install means the push fires next tick via
-- TickPump, so onActivate reads items that our listener populates after
-- base's listener returns but before the next frame's push.

include("CivVAccess_PopupBoot")
include("CivVAccess_ChoosePopupCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler
local selectionStub = ChoosePopupCommon.selectionStub

local function buildItems(popupInfo)
    local playerID = popupInfo.Data1
    local pPlayer = Players[playerID]
    if pPlayer == nil then
        return {}
    end
    local pUnit = pPlayer:GetUnitByID(popupInfo.Data2)
    if pUnit == nil then
        return {}
    end
    local pPlot = pUnit:GetPlot()
    if pPlot == nil then
        return {}
    end

    local items = {}
    local iIndex = 0
    for info in GameInfo.GoodyHuts() do
        local iGoodyType = iIndex
        if pPlayer:CanGetGoody(pPlot, iGoodyType, pUnit) then
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = Text.key(info.ChooseDescription),
                selectedFn = function()
                    return #SelectedItems > 0 and SelectedItems[1][1] == iGoodyType
                end,
                activate = function()
                    SelectedItems = { { iGoodyType, selectionStub() } }
                    if Controls.ConfirmButton ~= nil then
                        Controls.ConfirmButton:SetDisabled(false)
                    end
                end,
            })
        end
        iIndex = iIndex + 1
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "ConfirmButton",
        textKey = "TXT_KEY_OK_BUTTON",
        activate = function()
            CommitItems["GoodyHutBonuses"](SelectedItems, playerID)
            ContextPtr:SetHide(true)
        end,
    })

    return items
end

ChoosePopupCommon.install({
    contextPtr = ContextPtr,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    handlerName = "ChooseGoodyHutReward",
    displayKey = "TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD",
    popupType = ButtonPopupTypes.BUTTONPOPUP_CHOOSE_GOODY_HUT_REWARD,
    buildItems = buildItems,
})

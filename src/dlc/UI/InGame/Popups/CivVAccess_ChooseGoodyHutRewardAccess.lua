-- ChooseGoodyHutReward accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_GOODY_HUT_REWARD.
-- Base's PopulateItems["GoodyHutBonuses"] walks GameInfo.GoodyHuts in index
-- order, filters each by pPlayer:CanGetGoody(pPlot, iGoodyType, pUnit), and
-- spawns one Button per eligible bonus. Vanilla flow is click-row-then-
-- click-Confirm; we collapse it to a flat list where Enter on a row commits
-- and hides immediately. Bonus labels come from mod-authored
-- TXT_KEY_CIVVACCESS_GOODY_LABEL_<TYPE> -- vanilla's ChooseDescription
-- ("Convince the lost tribe to become a Worker for your civilization") is
-- sighted flavor text and reads poorly through speech.
--
-- Each row's activate calls CommitItems["GoodyHutBonuses"] (which reads
-- pUnit / pPlot from base's file locals captured by base's OnPopup, fired
-- on the same SerialEventGameMessagePopup before our listener) and hides
-- the popup. SelectedItems is passed as a fresh single-entry array per
-- click; the second slot carries a SelectionAnim stub so a stray mouse
-- click on a row while our sub-handler is active doesn't throw.
--
-- Row text is "<short label>, <vanilla flavor description>": the
-- distinguishing word leads (so screen reader users can disambiguate
-- without listening through a full sentence), the flavor sentence
-- follows for context.
--
-- deferActivate=true on install means the push fires next tick via
-- TickPump, so onActivate reads items that our listener populates after
-- base's listener returns but before the next frame's push.

include("CivVAccess_PopupBoot")
include("CivVAccess_ChoosePopupCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler
local selectionStub = ChoosePopupCommon.selectionStub

local function labelFor(info)
    local description = Text.key(info.ChooseDescription)
    local key = "TXT_KEY_CIVVACCESS_GOODY_LABEL_" .. info.Type:gsub("^GOODY_", "")
    if CivVAccess_Strings[key] == nil then
        return description
    end
    return Text.key(key) .. ", " .. description
end

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
                labelText = labelFor(info),
                activate = function()
                    CommitItems["GoodyHutBonuses"]({ { iGoodyType, selectionStub() } }, playerID)
                    ContextPtr:SetHide(true)
                end,
            })
        end
        iIndex = iIndex + 1
    end

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

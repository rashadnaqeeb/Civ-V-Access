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

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- SelectedItems entries have shape {key, controlTable}. The base's click
-- handler indexes v[2].SelectionAnim on re-selection, so we supply a stub
-- whose :SetHide is a no-op. That keeps the mirror robust against a stray
-- mouse click on a row while our sub-handler is active.
local function selectionStub()
    return { SelectionAnim = { SetHide = function() end } }
end

local function preambleText()
    local parts = {}
    local t = Controls.TitleLabel and Controls.TitleLabel:GetText() or ""
    if t ~= "" then
        parts[#parts + 1] = t
    end
    local d = Controls.DescriptionLabel and Controls.DescriptionLabel:GetText() or ""
    if d ~= "" then
        parts[#parts + 1] = d
    end
    return table.concat(parts, ", ")
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseGoodyHutReward",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

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
                labelText = Locale.ConvertTextKey(info.ChooseDescription),
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

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_GOODY_HUT_REWARD then
        return
    end
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChooseGoodyHutRewardAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)

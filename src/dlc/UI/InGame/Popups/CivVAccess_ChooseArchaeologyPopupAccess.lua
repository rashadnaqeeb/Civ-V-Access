-- ChooseArchaeologyPopup accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_ARCHAEOLOGY.
-- Offers up to three options on a completed dig, driven by the plot's
-- artifact type and the player's free Great Work slots:
--
-- Not a written artifact (bWrittenArtifact false):
--   - Player 1 artifact (if an artifact slot is open), choice value 2
--   - Player 2 artifact (if applicable and artifact slot is open),
--     choice value 3
--   - Landmark, choice value 1
-- Written artifact (bWrittenArtifact true):
--   - Create Great Work of Writing (if a literature slot is open),
--     choice value 5
--   - Cultural Renaissance (culture burst), choice value 4
--
-- bShow2ndPlayer is false for barbarian-camp and ancient-ruin artifacts;
-- those have only one participant. Flow: pick option -> base
-- SelectArchaeologyChoice stashes g_iChoice and shows the ChooseConfirm
-- overlay -> we push ChooseConfirmSub. Yes fires Network.SendArchaeologyChoice
-- via base's OnConfirmYes (and, for choice 5, also re-fires
-- BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER to show the splash).

include("CivVAccess_PopupBoot")
include("CivVAccess_ChooseConfirmSub")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function preambleText()
    return Text.joinVisibleControls({
        "ArchDescLeadIn",
        "ArchDescTitle",
        "ArchDescLine1",
        "ArchDescLine2",
        "ArchDescLine3",
        "ArchDescLine4",
        "ArchDescLine5",
    })
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseArchaeologyPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

local function confirmActivate(choice)
    return function()
        SelectArchaeologyChoice(choice)
        ChooseConfirmSub.push({
            onYes = function()
                OnConfirmYes()
            end,
        })
    end
end

-- Options that have a 2nd-player participant. Matches base's bShow2ndPlayer
-- flag which is false for barbarian-camp / ancient-ruin artifacts.
local TWO_PLAYER_CLASSES = {
    ARTIFACT_BATTLE_RANGED = true,
    ARTIFACT_BATTLE_MELEE = true,
    ARTIFACT_RAZED_CITY = true,
    ARTIFACT_WRITING = true,
}

local function buildItems()
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return {}
    end
    local pPlot = pPlayer:GetNextDigCompletePlot()
    if pPlot == nil then
        return {}
    end

    local artifactClasses = GameInfo.GreatWorkArtifactClasses
    local bArtSlotOpen = pPlayer:HasAvailableGreatWorkSlot(GameInfo.GreatWorkSlots.GREAT_WORK_SLOT_ART_ARTIFACT.ID)
    local bWritingSlotOpen = pPlayer:HasAvailableGreatWorkSlot(GameInfo.GreatWorkSlots.GREAT_WORK_SLOT_LITERATURE.ID)
    local bWrittenArtifact = pPlot:HasWrittenArtifact()
    local iTypeID = pPlot:GetArchaeologyArtifactType()
    local pPlayer1 = Players[pPlot:GetArchaeologyArtifactPlayer1()]
    local pPlayer2 = Players[pPlot:GetArchaeologyArtifactPlayer2()]

    local bShow2ndPlayer = false
    for key in pairs(TWO_PLAYER_CLASSES) do
        local row = artifactClasses[key]
        if row ~= nil and row.ID == iTypeID then
            bShow2ndPlayer = true
            break
        end
    end

    local items = {}

    if not bWrittenArtifact and bArtSlotOpen and pPlayer1 ~= nil then
        local civKey = pPlayer1:GetCivilizationAdjectiveKey()
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.format("TXT_KEY_CHOOSE_ARCH_ARTIFACT_HEADER", Text.key(civKey)),
            tooltipText = Text.key("TXT_KEY_CHOOSE_ARCH_ARTIFACT_RESULT"),
            activate = confirmActivate(2),
        })
    end

    if bWrittenArtifact and bWritingSlotOpen and pPlayer1 ~= nil then
        local civKey = pPlayer1:GetCivilizationAdjectiveKey()
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.format("TXT_KEY_CHOOSE_ARCH_WRITING_HEADER", Text.key(civKey)),
            tooltipText = Text.key("TXT_KEY_CHOOSE_ARCH_WRITTEN_ARTIFACT_RESULT"),
            activate = confirmActivate(5),
        })
    end

    if not bWrittenArtifact and bArtSlotOpen and bShow2ndPlayer and pPlayer2 ~= nil then
        local civKey = pPlayer2:GetCivilizationAdjectiveKey()
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.format("TXT_KEY_CHOOSE_ARCH_ARTIFACT_HEADER", Text.key(civKey)),
            tooltipText = Text.key("TXT_KEY_CHOOSE_ARCH_ARTIFACT_RESULT"),
            activate = confirmActivate(3),
        })
    end

    if not bWrittenArtifact then
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.key("TXT_KEY_CHOOSE_ARCH_LANDMARK_HEADER"),
            tooltipText = Text.key("TXT_KEY_CHOOSE_ARCH_LANDMARK_RESULT"),
            activate = confirmActivate(1),
        })
    else
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.key("TXT_KEY_CHOOSE_ARCH_RENAISSANCE_HEADER"),
            tooltipText = Text.key("TXT_KEY_CHOOSE_ARCH_RENAISSANCE_RESULT"),
            activate = confirmActivate(4),
        })
    end

    return items
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_ARCHAEOLOGY then
        return
    end
    local ok, items = pcall(buildItems)
    if not ok then
        Log.error("ChooseArchaeologyPopupAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)

-- CityStateDiploPopup accessibility. BUTTONPOPUP_CITY_STATE_DIPLO; single
-- Context, deferred items (payload-bound on popup event), live rebuild on
-- SerialEventGameDataDirty, Give / Take drills via setItems swap,
-- BullyConfirm as pushed sub.
--
-- Disabled actions are shown, not hidden: base renders them with warning-
-- color text plus a tooltip explaining why (need N influence, cooldown,
-- etc.), without calling SetDisabled on the button itself. The button's own
-- IsDisabled stays false; enablement is inferred from the anim-highlight
-- child (PledgeAnim, BuyoutAnim, SmallGiftAnim, etc.) which base hides in
-- the same branch that color-wraps the label. That anim hide is the
-- sighted cue and what we read.
--
-- BullyConfirm orchestration: base's Gold / Unit Tribute handlers set a
-- pending-action flag, show the overlay, and close TakeStack / restore
-- ButtonStack underneath. We rebuild root items BEFORE pushing the sub so
-- a No / Esc cancel lands on a menu that matches the visible stack. The
-- sub's onDeactivate hides the overlay as a belt-and-braces guard for the
-- Esc path, which bypasses base's Yes / No handlers.
--
-- Find On Map is skipped: the camera pan is a visual cue that doesn't
-- translate; a cursor-jump analogue would be scope expansion. Quest info
-- stays activatable but only for KILL_CAMP quests, matching base's own
-- narrow scope -- base only wires UI.LookAt for that quest type.

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
include("CivVAccess_CameraTracker")
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

local minorCivID = -1

-- Snapshot the popup payload so rebuilds (driven by
-- SerialEventGameDataDirty, not by the original popup event) can identify
-- which minor civ this popup is for. Base keeps its own g_iMinorCivID
-- local but it's not reachable from here.
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO then
        minorCivID = popupInfo.Data1
    end
end)

local function isVisible(controlName)
    local c = Controls[controlName]
    return c ~= nil and not c:IsHidden()
end

local function preambleText()
    local title = Controls.TitleLabel:GetText() or ""
    local body = Controls.DescriptionLabel:GetText() or ""
    if title ~= "" and body ~= "" then
        return title .. ", " .. body
    end
    if title ~= "" then
        return title
    end
    return body
end

local mainHandler

local function infoRow(headerKey, textControl, tooltipControl, onActivate)
    local tipControl = tooltipControl or textControl
    return BaseMenuItems.Text({
        labelFn = function()
            local value = Controls[textControl]:GetText() or ""
            local header = Text.key(headerKey)
            if value == "" then
                return header
            end
            return header .. ", " .. value
        end,
        tooltipFn = function()
            return Controls[tipControl]:GetToolTipString()
        end,
        onActivate = onActivate,
    })
end

local function activateQuestInfo()
    -- Re-check at press time rather than baking the predicate into the item
    -- at build time: dirty rebuilds are skipped while BullyConfirm is up, so
    -- a frozen predicate can go stale across cancel paths.
    if minorCivID < 0 then
        return
    end
    local minor = Players[minorCivID]
    if minor == nil then
        return
    end
    -- Match base's narrow scope: only KILL_CAMP has a displayed plot.
    if
        not minor:IsMinorCivDisplayedQuestForPlayer(Game.GetActivePlayer(), MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)
    then
        return
    end
    OnQuestInfoClicked()
    CameraTracker.followAndJumpCursor()
end

local function actionRow(spec)
    local btnName = spec.button
    local labelName = spec.label
    local enabled = spec.anim == nil or isVisible(spec.anim)

    if enabled then
        return BaseMenuItems.Button({
            controlName = btnName,
            labelFn = function()
                return Controls[labelName]:GetText()
            end,
            tooltipFn = function()
                return Controls[btnName]:GetToolTipString()
            end,
            activate = spec.activate,
        })
    end

    return BaseMenuItems.Text({
        labelFn = function()
            return (Controls[labelName]:GetText() or "") .. ", " .. Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
        end,
        tooltipFn = function()
            return Controls[btnName]:GetToolTipString()
        end,
    })
end

local buildRootItems
local buildGiveItems
local buildTakeItems
local pushBullyConfirm

buildGiveItems = function()
    local items = {}
    items[#items + 1] = actionRow({
        button = "SmallGiftButton",
        label = "SmallGift",
        anim = "SmallGiftAnim",
        activate = function()
            OnSmallGold()
        end,
    })
    items[#items + 1] = actionRow({
        button = "MediumGiftButton",
        label = "MediumGift",
        anim = "MediumGiftAnim",
        activate = function()
            OnMediumGold()
        end,
    })
    items[#items + 1] = actionRow({
        button = "LargeGiftButton",
        label = "LargeGift",
        anim = "LargeGiftAnim",
        activate = function()
            OnBigGold()
        end,
    })
    items[#items + 1] = actionRow({
        button = "UnitGiftButton",
        label = "UnitGift",
        anim = "UnitGiftAnim",
        -- OnGiftUnit dequeues the popup and enters INTERFACEMODE_GIFT_UNIT,
        -- which by itself is a hex-click-only mode and unreachable from
        -- the keyboard. Push GiftMode above Baseline so Space previews,
        -- Enter commits, Esc cancels. Dequeue happens before the push, so
        -- this popup's handler is gone by the time GiftMode lands.
        activate = function()
            OnGiftUnit()
            local GM = civvaccess_shared.modules and civvaccess_shared.modules.GiftMode
            if GM ~= nil then
                GM.enter(minorCivID, "unit")
            else
                Log.warn("CityStateDiploPopup: GiftMode missing from civvaccess_shared.modules")
            end
        end,
    })
    items[#items + 1] = actionRow({
        button = "TileImprovementGiftButton",
        label = "TileImprovementGift",
        anim = "TileImprovementGiftAnim",
        -- OnGiftTileImprovement gates on pMinor:CanMajorGiftTileImprovement
        -- before dequeue + mode-set; if the gate refuses (no eligible
        -- Great General + Citadel build), the popup stays up and the
        -- engine mode never changes. Only push GiftMode if the gate
        -- passed, detected by checking GetInterfaceMode after the call.
        activate = function()
            OnGiftTileImprovement()
            if UI.GetInterfaceMode() == InterfaceModeTypes.INTERFACEMODE_GIFT_TILE_IMPROVEMENT then
                local GM = civvaccess_shared.modules and civvaccess_shared.modules.GiftMode
                if GM ~= nil then
                    GM.enter(minorCivID, "improvement")
                else
                    Log.warn("CityStateDiploPopup: GiftMode missing from civvaccess_shared.modules")
                end
            end
        end,
    })
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "ExitGiveButton",
        textKey = "TXT_KEY_BACK_BUTTON",
        activate = function()
            OnCloseGive()
            mainHandler.setItems(buildRootItems())
            mainHandler.refresh()
        end,
    })
    return items
end

buildTakeItems = function()
    local items = {}
    items[#items + 1] = actionRow({
        button = "GoldTributeButton",
        label = "GoldTributeLabel",
        anim = "GoldTributeAnim",
        activate = function()
            -- Base's handler sets pending, shows BullyConfirm overlay,
            -- closes TakeStack, restores ButtonStack. Rebuild to root
            -- before pushing the Confirm sub so a No / Esc cancel lands
            -- on a menu that matches the visible stack.
            OnGoldTributeButtonClicked()
            mainHandler.setItems(buildRootItems())
            pushBullyConfirm()
        end,
    })
    items[#items + 1] = actionRow({
        button = "UnitTributeButton",
        label = "UnitTributeLabel",
        anim = "UnitTributeAnim",
        activate = function()
            OnUnitTributeButtonClicked()
            mainHandler.setItems(buildRootItems())
            pushBullyConfirm()
        end,
    })
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "ExitTakeButton",
        textKey = "TXT_KEY_BACK_BUTTON",
        activate = function()
            OnCloseTake()
            mainHandler.setItems(buildRootItems())
            mainHandler.refresh()
        end,
    })
    return items
end

buildRootItems = function()
    local items = {}

    items[#items + 1] = infoRow("TXT_KEY_POP_CSTATE_STATUS", "StatusInfo", "StatusInfo")
    items[#items + 1] = infoRow("TXT_KEY_POP_CSTATE_PERSONALITY", "PersonalityInfo", "PersonalityInfo")
    items[#items + 1] = infoRow("TXT_KEY_POP_CSTATE_TRAIT", "TraitInfo", "TraitInfo")
    items[#items + 1] = infoRow("TXT_KEY_POP_CSTATE_QUESTS", "QuestInfo", "QuestInfo", activateQuestInfo)
    items[#items + 1] = infoRow("TXT_KEY_POP_CSTATE_ALLIED_WITH", "AllyText", "AllyText")
    if isVisible("ResourcesInfo") then
        items[#items + 1] = infoRow("TXT_KEY_POP_CSTATE_RESOURCES", "ResourcesInfo", "ResourcesInfo")
    end

    if isVisible("PeaceButton") then
        items[#items + 1] = actionRow({
            button = "PeaceButton",
            label = "PeaceLabel",
            activate = function()
                OnPeaceButtonClicked()
            end,
        })
    end
    if isVisible("GiveButton") then
        items[#items + 1] = BaseMenuItems.Button({
            controlName = "GiveButton",
            labelFn = function()
                return Controls.GiveLabel:GetText()
            end,
            tooltipFn = function()
                return Controls.GiveButton:GetToolTipString()
            end,
            activate = function()
                OnGiveButtonClicked()
                mainHandler.setItems(buildGiveItems())
                mainHandler.refresh()
            end,
        })
    end
    if isVisible("PledgeButton") then
        items[#items + 1] = actionRow({
            button = "PledgeButton",
            label = "PledgeLabel",
            anim = "PledgeAnim",
            activate = function()
                OnPledgeButtonClicked()
            end,
        })
    end
    if isVisible("RevokePledgeButton") then
        items[#items + 1] = actionRow({
            button = "RevokePledgeButton",
            label = "RevokePledgeLabel",
            anim = "RevokePledgeAnim",
            activate = function()
                OnRevokePledgeButtonClicked()
            end,
        })
    end
    if isVisible("TakeButton") then
        items[#items + 1] = BaseMenuItems.Button({
            controlName = "TakeButton",
            labelFn = function()
                return Controls.TakeLabel:GetText()
            end,
            tooltipFn = function()
                return Controls.TakeButton:GetToolTipString()
            end,
            activate = function()
                OnTakeButtonClicked()
                mainHandler.setItems(buildTakeItems())
                mainHandler.refresh()
            end,
        })
    end
    if isVisible("WarButton") then
        items[#items + 1] = actionRow({
            button = "WarButton",
            label = "WarLabel",
            -- OnWarButtonClicked opens BUTTONPOPUP_DECLAREWARMOVE which is
            -- its own confirmation popup. Our popup stays visible in the
            -- background until that resolves.
            activate = function()
                OnWarButtonClicked()
            end,
        })
    end
    if isVisible("NoUnitSpawningButton") then
        items[#items + 1] = actionRow({
            button = "NoUnitSpawningButton",
            label = "NoUnitSpawningLabel",
            activate = function()
                OnStopStartSpawning()
            end,
        })
    end
    if isVisible("BuyoutButton") then
        items[#items + 1] = actionRow({
            button = "BuyoutButton",
            label = "BuyoutLabel",
            anim = "BuyoutAnim",
            activate = function()
                OnBuyoutButtonClicked()
            end,
        })
    end

    return items
end

pushBullyConfirm = function()
    local sub = BaseMenu.create({
        name = "BullyConfirm",
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"),
        preamble = function()
            return Controls.BullyConfirmLabel:GetText() or ""
        end,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        items = {
            BaseMenuItems.Button({
                controlName = "YesBully",
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    -- reactivate=false because OnYesBully dequeues the
                    -- popup; reactivating the parent mid-teardown would
                    -- speak stale items.
                    HandlerStack.removeByName("BullyConfirm", false)
                    OnYesBully()
                end,
            }),
            BaseMenuItems.Button({
                controlName = "NoBully",
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    OnNoBully()
                    HandlerStack.removeByName("BullyConfirm", true)
                end,
            }),
        },
    })
    sub.onDeactivate = function()
        -- Esc (escapePops) skips both button callbacks; hide the overlay
        -- here so sighted state matches. Idempotent for Yes / No paths
        -- where OnYesBully / OnNoBully already hid it.
        if Controls.BullyConfirm ~= nil then
            Controls.BullyConfirm:SetHide(true)
        end
        if Controls.BGBlock ~= nil then
            Controls.BGBlock:SetHide(false)
        end
    end
    HandlerStack.push(sub)
end

mainHandler = BaseMenu.install(ContextPtr, {
    name = "CityStateDiploPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
    onShow = function(handler)
        handler.setItems(buildRootItems())
    end,
})

-- Live rebuild. Base's OnGameDataDirty re-runs OnDisplay on every dirty
-- firing while visible; we mirror by rebuilding items and refreshing the
-- preamble. refresh() no-ops on unchanged preamble so incidental dirty
-- events stay silent; action-driven ones surface the new flavor paragraph
-- as a speakInterrupt. We skip only while BullyConfirm is up -- other
-- transient subs (Help, etc.) let the rebuild through so state stays
-- current under them.
Events.SerialEventGameDataDirty.Add(function()
    if ContextPtr:IsHidden() then
        return
    end
    local active = HandlerStack.active()
    if active ~= nil and active.name == "BullyConfirm" then
        return
    end
    mainHandler.setItems(buildRootItems())
    mainHandler.refresh()
end)

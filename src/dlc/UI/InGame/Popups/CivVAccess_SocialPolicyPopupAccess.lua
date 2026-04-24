-- SocialPolicyPopup accessibility. BUTTONPOPUP_CHOOSEPOLICY wraps the BNW
-- social-policy screen as a two-tab BaseMenu: Policies (9 classical branches,
-- each drillable for its policies in unlock-order) and Ideology (3 level
-- groups of tenet slots, plus public opinion and switch-ideology). Tab 2 is a
-- no-op "not yet embraced" placeholder when the player has no ideology, and a
-- disabled notice when GAMEOPTION_NO_POLICIES is set.
--
-- Pure helpers (branch status, tier ordering, slot gating, speech composition,
-- preamble) live in CivVAccess_SocialPolicyLogic for offline-test coverage.
-- This file owns install-side wiring: item builders, activation dispatch,
-- confirm-sub pushes for the four game overlays (PolicyConfirm, ChooseTenet,
-- TenetConfirm, ChangeIdeologyConfirm), event listeners, and the priorShowHide
-- wrap that cleans up subs on hide.
--
-- Confirm subs are local helpers rather than ChooseConfirmSub because this
-- screen has no Controls.ConfirmText (ChooseConfirmSub's preamble source) and
-- its button names are Yes/No (not ConfirmYes/ConfirmNo). Each helper spells
-- out its overlay's Yes/No control names and hides the overlay on every exit
-- path via onDeactivate so Esc/No/Yes all leave a clean state.
--
-- popupInfo.Data2 == 2 opens to the Ideology tab. The SerialEventGameMessagePopup
-- listener captures that into _openToIdeologyTab and calls setInitialTabIndex
-- before install's onShow runs (the listener fires synchronously during the
-- base OnPopupMessage dispatch, well before UIManager:QueuePopup's ShowHide).
--
-- Load-from-game: popup Contexts re-initialize, so the listeners register
-- fresh on every include with no install-once guards. Dead prior-game
-- listeners throw on first global access and the engine catches them per-
-- listener; the current live one fires.

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
include("CivVAccess_SocialPolicyLogic")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local TAB_POLICIES = 1
local TAB_IDEOLOGY = 2

local SUB_POLICY_CONFIRM = "PolicyConfirm"
local SUB_TENET_PICKER = "TenetPicker"
local SUB_TENET_CONFIRM = "TenetConfirm"
local SUB_CHANGE_IDEOLOGY = "ChangeIdeologyConfirm"

-- Set by the SerialEventGameMessagePopup listener when popupInfo.Data2 == 2.
-- Read by onShow (via setInitialTabIndex) and cleared so subsequent opens
-- without Data2=2 don't inherit the flag.
local _openToIdeologyTab = false

local mainHandler

local function currentPlayer()
    return Players[Game.GetActivePlayer()]
end

local function currentIdeology()
    local player = currentPlayer()
    if player == nil then
        return -1
    end
    return player:GetLateGamePolicyTree()
end

-- ========== Confirm subs ==========
--
-- Each overlay is a child of the SocialPolicyPopup Context toggled by the base
-- code's SetHide calls. Our sub doesn't own the visual state — the game's own
-- OnYes/OnNo handles that when the user commits via the sub. onDeactivate
-- redundantly hides the overlay as a backstop for the Esc path (where no base
-- callback runs).

local function pushPolicyConfirm(name, isBranch, successKey)
    local promptKey = isBranch
            and "TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"
        or "TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"
    local sub = BaseMenu.create({
        name = SUB_POLICY_CONFIRM,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"),
        preamble = Text.format(promptKey, name),
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        items = {
            BaseMenuItems.Button({
                controlName = "Yes",
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    HandlerStack.removeByName(SUB_POLICY_CONFIRM, false)
                    local ok, err = pcall(OnYes)
                    if not ok then
                        Log.error("SocialPolicyPopupAccess OnYes failed: " .. tostring(err))
                    end
                    SpeechPipeline.speakInterrupt(Text.format(successKey, name))
                end,
            }),
            BaseMenuItems.Button({
                controlName = "No",
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    HandlerStack.removeByName(SUB_POLICY_CONFIRM, true)
                    local ok, err = pcall(OnNo)
                    if not ok then
                        Log.error("SocialPolicyPopupAccess OnNo failed: " .. tostring(err))
                    end
                end,
            }),
        },
    })
    sub.onDeactivate = function()
        if Controls.PolicyConfirm ~= nil then
            Controls.PolicyConfirm:SetHide(true)
        end
        if Controls.BGBlock ~= nil then
            Controls.BGBlock:SetHide(false)
        end
    end
    HandlerStack.push(sub)
end

local function pushTenetConfirm(name)
    local sub = BaseMenu.create({
        name = SUB_TENET_CONFIRM,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"),
        preamble = Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET", name),
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        items = {
            BaseMenuItems.Button({
                controlName = "TenetConfirmYes",
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    HandlerStack.removeByName(SUB_TENET_CONFIRM, false)
                    local ok, err = pcall(OnTenetConfirmYes)
                    if not ok then
                        Log.error("SocialPolicyPopupAccess OnTenetConfirmYes failed: " .. tostring(err))
                    end
                    HandlerStack.removeByName(SUB_TENET_PICKER, true)
                    SpeechPipeline.speakInterrupt(
                        Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET", name)
                    )
                end,
            }),
            BaseMenuItems.Button({
                controlName = "TenetConfirmNo",
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    HandlerStack.removeByName(SUB_TENET_CONFIRM, true)
                    local ok, err = pcall(OnTenetConfirmNo)
                    if not ok then
                        Log.error("SocialPolicyPopupAccess OnTenetConfirmNo failed: " .. tostring(err))
                    end
                end,
            }),
        },
    })
    sub.onDeactivate = function()
        if Controls.TenetConfirm ~= nil then
            Controls.TenetConfirm:SetHide(true)
        end
    end
    HandlerStack.push(sub)
end

local function pushTenetPicker(level)
    local player = currentPlayer()
    local ideologyID = currentIdeology()
    if player == nil or ideologyID < 0 then
        return
    end
    local available = player:GetAvailableTenets(level) or {}
    local items = {}
    for _, tenetID in ipairs(available) do
        local tenetRow = GameInfo.Policies[tenetID]
        if tenetRow ~= nil then
            local id = tenetID
            local row = tenetRow
            local name = Text.key(row.Description)
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = SocialPolicyLogic.buildTenetPickerChoice(row),
                activate = function()
                    local ok, err = pcall(ChooseTenet, id, row.Description)
                    if not ok then
                        Log.error("SocialPolicyPopupAccess ChooseTenet failed: " .. tostring(err))
                        return
                    end
                    pushTenetConfirm(name)
                end,
            })
        end
    end
    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"),
        })
    end
    local sub = BaseMenu.create({
        name = SUB_TENET_PICKER,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    sub.onDeactivate = function()
        if Controls.ChooseTenet ~= nil then
            Controls.ChooseTenet:SetHide(true)
        end
        local ok, err = pcall(OnCancel)
        if not ok then
            Log.error("SocialPolicyPopupAccess OnCancel failed: " .. tostring(err))
        end
    end
    HandlerStack.push(sub)
end

local function pushChangeIdeologyConfirm()
    local sub = BaseMenu.create({
        name = SUB_CHANGE_IDEOLOGY,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"),
        -- LabelConfirmChangeIdeology is populated by ChooseChangeIdeology()
        -- with a full localized sentence (anarchy turns, tenet count delta,
        -- preferred ideology name, unhappiness). Speaking it verbatim gives
        -- the user all the info a sighted player sees.
        preamble = function()
            if Controls.LabelConfirmChangeIdeology ~= nil then
                local ok, text = pcall(function()
                    return Controls.LabelConfirmChangeIdeology:GetText()
                end)
                if ok and text ~= nil and text ~= "" then
                    return tostring(text)
                end
            end
            return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY")
        end,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        items = {
            BaseMenuItems.Button({
                controlName = "ChangeIdeologyConfirmYes",
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    HandlerStack.removeByName(SUB_CHANGE_IDEOLOGY, false)
                    local ok, err = pcall(OnChangeIdeologyConfirmYes)
                    if not ok then
                        Log.error(
                            "SocialPolicyPopupAccess OnChangeIdeologyConfirmYes failed: " .. tostring(err)
                        )
                    end
                    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"))
                end,
            }),
            BaseMenuItems.Button({
                controlName = "ChangeIdeologyConfirmNo",
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    HandlerStack.removeByName(SUB_CHANGE_IDEOLOGY, true)
                    local ok, err = pcall(OnChangeIdeologyConfirmNo)
                    if not ok then
                        Log.error(
                            "SocialPolicyPopupAccess OnChangeIdeologyConfirmNo failed: " .. tostring(err)
                        )
                    end
                end,
            }),
        },
    })
    sub.onDeactivate = function()
        if Controls.ChangeIdeologyConfirm ~= nil then
            Controls.ChangeIdeologyConfirm:SetHide(true)
        end
    end
    HandlerStack.push(sub)
end

-- ========== Activation dispatch ==========

local function activatePolicy(policyRow, branchRow)
    local player = currentPlayer()
    if player == nil then
        return
    end
    -- IsPolicyBlocked gate is load-bearing: game's PolicySelected fires
    -- BUTTONPOPUP_CONFIRM_POLICY_BRANCH_SWITCH when a policy is adoptable but
    -- blocked by an active opposing branch. That path does not set
    -- m_gPolicyID or show Controls.PolicyConfirm, so pushing our confirm sub
    -- unconditionally would land Yes on a stale m_gPolicyID. Skip the blocked
    -- path entirely; the user already hears "blocked" via policyStatus.
    if not player:CanAdoptPolicy(policyRow.ID) or player:IsPolicyBlocked(policyRow.ID) then
        return
    end
    local name = Text.key(policyRow.Description)
    local ok, err = pcall(PolicySelected, policyRow.ID)
    if not ok then
        Log.error("SocialPolicyPopupAccess PolicySelected failed: " .. tostring(err))
        return
    end
    pushPolicyConfirm(name, false, "TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED")
end

local function activateBranchUnlock(branchRow)
    local player = currentPlayer()
    if player == nil then
        return
    end
    if
        not player:CanUnlockPolicyBranch(branchRow.ID)
        or player:IsPolicyBranchBlocked(branchRow.ID)
    then
        return
    end
    local name = Text.key(branchRow.Description)
    local ok, err = pcall(PolicyBranchSelected, branchRow.ID)
    if not ok then
        Log.error("SocialPolicyPopupAccess PolicyBranchSelected failed: " .. tostring(err))
        return
    end
    pushPolicyConfirm(name, true, "TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED")
end

local function activateSlot(level, slotIndex)
    local player = currentPlayer()
    if player == nil then
        return
    end
    local ideologyID = currentIdeology()
    if ideologyID < 0 then
        return
    end
    local status = SocialPolicyLogic.slotStatus(player, ideologyID, level, slotIndex)
    if status ~= "available" then
        return
    end
    local ok, err = pcall(TenetSelect, level * 10 + slotIndex)
    if not ok then
        Log.error("SocialPolicyPopupAccess TenetSelect failed: " .. tostring(err))
        return
    end
    pushTenetPicker(level)
end

local function activateSwitchIdeology()
    if Controls.SwitchIdeologyButton == nil or Controls.SwitchIdeologyButton:IsDisabled() then
        return
    end
    local ok, err = pcall(ChooseChangeIdeology)
    if not ok then
        Log.error("SocialPolicyPopupAccess ChooseChangeIdeology failed: " .. tostring(err))
        return
    end
    pushChangeIdeologyConfirm()
end

-- ========== Branch drill-in items ==========

local function buildBranchChildren(branchRow)
    local items = {}
    local opener, interior, finisher = SocialPolicyLogic.sortBranchPolicies(branchRow)
    local branch = branchRow

    -- "Open branch" item when the branch can be unlocked right now. Lives at
    -- the top of the drill so the user encounters it first on entry.
    local player = currentPlayer()
    if
        player ~= nil
        and not player:IsPolicyBranchUnlocked(branch.ID)
        and player:CanUnlockPolicyBranch(branch.ID)
        and not player:IsPolicyBranchBlocked(branch.ID)
    then
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return Text.format(
                    "TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM",
                    Text.key(branch.Description)
                )
            end,
            onActivate = function()
                activateBranchUnlock(branch)
            end,
        })
    end

    if opener ~= nil then
        local op = opener
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return SocialPolicyLogic.buildPolicySpeech(currentPlayer(), op, branch)
            end,
        })
    end

    for _, policy in ipairs(interior) do
        local pol = policy
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return SocialPolicyLogic.buildPolicySpeech(currentPlayer(), pol, branch)
            end,
            onActivate = function()
                activatePolicy(pol, branch)
            end,
        })
    end

    if finisher ~= nil then
        local fin = finisher
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return SocialPolicyLogic.buildPolicySpeech(currentPlayer(), fin, branch)
            end,
        })
    end

    return items
end

-- ========== Ideology slot items ==========

local function buildLevelChildren(level)
    local items = {}
    local slotCount = SocialPolicyLogic.IDEOLOGY_LEVEL_SLOTS[level]
    for slotIndex = 1, slotCount do
        local lvl = level
        local idx = slotIndex
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                local ideologyID = currentIdeology()
                if ideologyID < 0 then
                    return ""
                end
                return SocialPolicyLogic.buildSlotSpeech(currentPlayer(), ideologyID, lvl, idx)
            end,
            onActivate = function()
                activateSlot(lvl, idx)
            end,
        })
    end
    return items
end

-- ========== Tab item builders ==========

local function closeItem()
    return BaseMenuItems.Button({
        controlName = "CloseButton",
        textKey = "TXT_KEY_CLOSE",
        activate = function()
            OnClose()
        end,
    })
end

local function buildPoliciesTabItems()
    local items = {}
    for _, branch in ipairs(SocialPolicyLogic.classicalBranches()) do
        local br = branch
        items[#items + 1] = BaseMenuItems.Group({
            labelFn = function()
                return SocialPolicyLogic.buildBranchSpeech(currentPlayer(), br)
            end,
            itemsFn = function()
                return buildBranchChildren(br)
            end,
            cached = false,
        })
    end
    items[#items + 1] = closeItem()
    return items
end

local function buildIdeologyTabItems()
    if Game.IsOption ~= nil and GameOptionTypes ~= nil and Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES) then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"),
            }),
            closeItem(),
        }
    end

    local ideologyID = currentIdeology()
    if ideologyID < 0 then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"),
            }),
            closeItem(),
        }
    end

    local items = {}
    local levelKeys = {
        "TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1",
        "TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2",
        "TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3",
    }
    for level = 1, 3 do
        local lvl = level
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key(levelKeys[level]),
            itemsFn = function()
                return buildLevelChildren(lvl)
            end,
            cached = false,
        })
    end

    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local player = currentPlayer()
            if player == nil then
                return ""
            end
            return SocialPolicyLogic.buildPublicOpinionSpeech(player)
        end,
    })

    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local disabled = Controls.SwitchIdeologyButton ~= nil
                and Controls.SwitchIdeologyButton:IsDisabled()
            if disabled then
                return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED")
            end
            return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY")
        end,
        onActivate = function()
            activateSwitchIdeology()
        end,
    })

    items[#items + 1] = closeItem()
    return items
end

-- ========== Lifecycle ==========

-- Wrap the base game's ShowHideHandler so that on hide we pop any sub
-- handlers we pushed before the install's outer wrapper removes the main
-- handler. Otherwise orphan subs stay on the stack and steal input from
-- whatever comes next (baseline, scanner, a re-opened popup).
local function wrappedPriorShowHide(bIsHide, bIsInit)
    if bIsHide then
        HandlerStack.removeByName(SUB_TENET_CONFIRM, false)
        HandlerStack.removeByName(SUB_TENET_PICKER, false)
        HandlerStack.removeByName(SUB_POLICY_CONFIRM, false)
        HandlerStack.removeByName(SUB_CHANGE_IDEOLOGY, false)
    end
    if priorShowHide ~= nil then
        local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
        if not ok then
            Log.error("SocialPolicyPopupAccess prior ShowHide failed: " .. tostring(err))
        end
    end
end

mainHandler = BaseMenu.install(ContextPtr, {
    name = "SocialPolicyPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"),
    preamble = function()
        local player = currentPlayer()
        if player == nil then
            return ""
        end
        return SocialPolicyLogic.buildPreamble(player)
    end,
    priorInput = priorInput,
    priorShowHide = wrappedPriorShowHide,
    onShow = function(handler)
        handler.setInitialTabIndex(_openToIdeologyTab and TAB_IDEOLOGY or TAB_POLICIES)
        _openToIdeologyTab = false
        handler.setItems(buildPoliciesTabItems(), TAB_POLICIES)
        handler.setItems(buildIdeologyTabItems(), TAB_IDEOLOGY)
    end,
    tabs = {
        {
            name = "TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES",
            items = {},
        },
        {
            name = "TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY",
            items = {},
        },
    },
})

-- ========== Event listeners ==========
--
-- No install-once guards (CLAUDE.md rule): popup Contexts re-initialize on
-- load-from-game, so listeners register fresh on every include. Dead
-- prior-game listeners throw on global-access and the engine catches them
-- per-listener; the current live one fires.

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY then
        return
    end
    _openToIdeologyTab = (popupInfo.Data2 == 2)
end)

Events.EventPoliciesDirty.Add(function()
    if ContextPtr:IsHidden() then
        return
    end
    local ok1, err1 = pcall(function()
        mainHandler.setItems(buildPoliciesTabItems(), TAB_POLICIES)
    end)
    if not ok1 then
        Log.error("SocialPolicyPopupAccess Dirty/Policies rebuild failed: " .. tostring(err1))
    end
    local ok2, err2 = pcall(function()
        mainHandler.setItems(buildIdeologyTabItems(), TAB_IDEOLOGY)
    end)
    if not ok2 then
        Log.error("SocialPolicyPopupAccess Dirty/Ideology rebuild failed: " .. tostring(err2))
    end
    mainHandler.refresh()
end)

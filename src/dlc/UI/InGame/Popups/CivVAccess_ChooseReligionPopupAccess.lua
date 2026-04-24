-- ChooseReligionPopup accessibility. Shares one Context across two phases
-- (BUTTONPOPUP_FOUND_RELIGION; Option1=true=founding, Option1=false=enhance):
-- founding picks Pantheon / Founder / Follower + optional Bonus (Byzantines)
-- and lets the player name the religion; enhance picks Follower 2 + Enhancer
-- on the already-founded religion.
--
-- Layout:
--   religion row     Group (founding) -> religion-list drill; Choice
--                    (enhance) -> read-only display of the player's own
--                    religion. Gated on visibility of ReligionPanel so the
--                    user doesn't land on it before one is picked.
--   name row         Choice; activate opens ChangeReligionName sub in
--                    founding mode, no-op in enhance mode. Gated on
--                    ReligionPanel.
--   6 belief slots   Group each; itemsFn (cached=false) rebuilds the
--                    candidate-belief list on every drill and applies the
--                    v ~= g_Beliefs[N] dedup guards base's On*BeliefClick
--                    handlers use. Locked slots (already-committed,
--                    "available later", Byzantines-only) fall out as empty
--                    children whose drill just re-announces the label.
--   confirm          Button bound to Controls.FoundReligion; its IsDisabled
--                    mirrors CheckifCanCommit so the "disabled" narration
--                    tracks commit readiness without us replicating the
--                    gating logic.
--
-- Confirm overlay: after FoundReligion fires the engine's ChooseConfirm
-- prompt, we push ChooseConfirmSub with control names Yes/No (the overlay
-- uses those, not the ConfirmYes/ConfirmNo that other Choose* popups use).
--
-- Rename sub: ChangeReligionName opens the engine's ChangeNamePopup
-- overlay; we push a sub-handler with Textfield + ChangeNameOKButton /
-- ChangeNameDefaultButton / ChangeNameCancelButton. OK calls
-- OnChangeNameOK; if that leaves ChangeNameError visible (empty-name
-- rejection), we speak the error and stay in the sub; on success the
-- overlay hides and the sub pops. Cancel / Esc hide the overlay through
-- the sub's onDeactivate.

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
include("CivVAccess_ChooseConfirmSub")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local mainHandler -- forward declared, assigned after install

-- Slot metadata. slotIndex matches the g_Beliefs[] key the base script uses;
-- nameKey is the engine TXT_KEY for the slot's short label; picker is the
-- accessor for available-belief IDs; dedup lists slot indices whose
-- already-picked belief this session must be excluded (mirrors the
-- v ~= g_Beliefs[N] guards in base's On*BeliefClick).
local SLOT_PANTHEON = {
    slotIndex = 1,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_PANTHEON_BELIEF",
    picker = function() return Game.GetAvailablePantheonBeliefs() end,
    dedup = { 6 },
}
local SLOT_FOUNDER = {
    slotIndex = 2,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_FOUNDER_BELIEF",
    picker = function() return Game.GetAvailableFounderBeliefs() end,
    dedup = { 6 },
}
local SLOT_FOLLOWER = {
    slotIndex = 3,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_FOLLOWER_BELIEF",
    picker = function() return Game.GetAvailableFollowerBeliefs() end,
    dedup = { 6 },
}
local SLOT_FOLLOWER2 = {
    slotIndex = 4,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_FOLLOWER_BELIEF2",
    picker = function() return Game.GetAvailableFollowerBeliefs() end,
    dedup = {},
}
local SLOT_ENHANCER = {
    slotIndex = 5,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_SPREAD_BELIEF",
    picker = function() return Game.GetAvailableEnhancerBeliefs() end,
    dedup = {},
}
local SLOT_BONUS = {
    slotIndex = 6,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_BONUS_BELIEF",
    picker = function() return Game.GetAvailableBonusBeliefs() end,
    dedup = { 1, 2, 3 },
}

-- Slot-state classifier. Returns one of "editable", "committed", "later",
-- "byzantines_only". Replicates the dispatch in base's RefreshExistingBeliefs
-- (HasCreatedReligion / HasCreatedPantheon / Byzantines trait branches).
local function slotState(slot, pPlayer)
    local hasReligion = pPlayer:HasCreatedReligion()
    local hasPantheon = pPlayer:HasCreatedPantheon()
    local hasByzantine = pPlayer:IsTraitBonusReligiousBelief()
    if slot == SLOT_PANTHEON then
        if hasReligion or hasPantheon then
            return "committed"
        end
        return "editable"
    end
    if slot == SLOT_FOUNDER or slot == SLOT_FOLLOWER then
        if hasReligion then
            return "committed"
        end
        return "editable"
    end
    if slot == SLOT_FOLLOWER2 or slot == SLOT_ENHANCER then
        if hasReligion then
            return "editable"
        end
        return "later"
    end
    -- SLOT_BONUS
    if not hasByzantine then
        return "byzantines_only"
    end
    if hasReligion then
        return "committed"
    end
    return "editable"
end

local function slotLabel(slot)
    local pPlayer = Players[Game.GetActivePlayer()]
    local slotName = Text.key(slot.nameKey)
    local state = slotState(slot, pPlayer)
    if state == "later" then
        return Text.format("TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER", slotName)
    end
    if state == "byzantines_only" then
        return Text.format("TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY", slotName)
    end
    local beliefID = g_Beliefs[slot.slotIndex]
    if beliefID ~= nil then
        local beliefName = Locale.Lookup(GameInfo.Beliefs[beliefID].ShortDescription)
        return Text.format("TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN", slotName, beliefName)
    end
    return Text.format("TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN", slotName)
end

-- Drill-in children for an editable slot. Rebuilt on every drill
-- (cached=false on the Group) so dedup reflects the latest g_Beliefs state.
local function buildBeliefChoices(slot)
    local dedup = {}
    for _, idx in ipairs(slot.dedup) do
        local bid = g_Beliefs[idx]
        if bid ~= nil then
            dedup[bid] = true
        end
    end
    local rows = {}
    for _, id in ipairs(slot.picker()) do
        if not dedup[id] then
            local b = GameInfo.Beliefs[id]
            rows[#rows + 1] = {
                id = id,
                name = Locale.Lookup(b.ShortDescription),
                description = Locale.Lookup(b.Description),
            }
        end
    end
    table.sort(rows, function(a, b)
        return Locale.Compare(a.name, b.name) < 0
    end)
    local items = {}
    for _, row in ipairs(rows) do
        local beliefID = row.id
        local beliefName = row.name
        local beliefDesc = row.description
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = beliefName,
            tooltipText = beliefDesc,
            activate = function()
                g_Beliefs[slot.slotIndex] = beliefID
                CheckifCanCommit()
                mainHandler._goBackLevel()
            end,
        })
    end
    return items
end

local function buildSlotItem(slot)
    return BaseMenuItems.Group({
        labelFn = function()
            return slotLabel(slot)
        end,
        -- Description of whatever belief currently fills the slot. Committed
        -- slots can't be drilled to hear the description, so surfacing it
        -- here is the only path. composeSpeech dedupes sentences that repeat
        -- label segments, so slots with belief name inlined in the label
        -- don't re-announce the name twice.
        tooltipFn = function()
            local beliefID = g_Beliefs[slot.slotIndex]
            if beliefID == nil then
                return nil
            end
            return Locale.Lookup(GameInfo.Beliefs[beliefID].Description)
        end,
        itemsFn = function()
            local pPlayer = Players[Game.GetActivePlayer()]
            if slotState(slot, pPlayer) ~= "editable" then
                return {}
            end
            return buildBeliefChoices(slot)
        end,
        cached = false,
        -- ReligionPanel is hidden until the user picks a religion (founding)
        -- or is auto-populated in enhance. Gating here keeps the user off
        -- slot rows whose drill couldn't progress anyway.
        visibilityControlName = "ReligionPanel",
    })
end

-- Religion picker -----------------------------------------------------------

local function buildReligionChoices()
    local pActivePlayer = Players[Game.GetActivePlayer()]
    local pActiveTeam = Teams[Game.GetActiveTeam()]
    local taken = {}
    for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pPlayer = Players[iPlayer]
        if pPlayer:IsEverAlive() and pPlayer:HasCreatedReligion() then
            local eReligion = pPlayer:GetReligionCreatedByPlayer()
            if pActiveTeam:IsHasMet(pPlayer:GetTeam()) then
                taken[eReligion] = pPlayer:GetName()
            else
                taken[eReligion] = Text.key("TXT_KEY_CHOOSE_RELIGION_UNMET_PLAYER")
            end
        end
    end
    local religions = {}
    for row in GameInfo.Religions("Type <> 'RELIGION_PANTHEON'") do
        religions[#religions + 1] = {
            id = row.ID,
            name = Locale.Lookup(row.Description),
            descKey = row.Description,
            iconAtlas = row.IconAtlas,
            portraitIndex = row.PortraitIndex,
            takenBy = taken[row.ID],
        }
    end
    table.sort(religions, function(a, b)
        return Locale.Compare(a.name, b.name) < 0
    end)
    local items = {}
    for _, entry in ipairs(religions) do
        local religionID = entry.id
        local religionName = entry.name
        local religionDescKey = entry.descKey
        local iconAtlas = entry.iconAtlas
        local portraitIndex = entry.portraitIndex
        local takenBy = entry.takenBy
        if takenBy == nil then
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = religionName,
                activate = function()
                    SelectReligion(religionID, religionDescKey, iconAtlas, portraitIndex)
                    mainHandler._goBackLevel()
                end,
            })
        else
            -- Taken religions are surfaced with their founder so the user
            -- can orient (sighted players see the list greyed out with the
            -- same info). isActivatable flips to false so arrow-Enter
            -- re-announces the label with a "disabled" suffix.
            local choice = BaseMenuItems.Choice({
                labelText = Text.format("TXT_KEY_CHOOSE_RELIGION_ALREADY_FOUNDED", religionDescKey, takenBy),
                activate = function() end,
            })
            choice.isActivatable = function()
                return false
            end
            items[#items + 1] = choice
        end
    end
    return items
end

local function religionPickerLabel()
    if g_CurrentReligionName == nil or g_CurrentReligionName == "" then
        return Text.key("TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED")
    end
    return Text.format("TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED", Locale.Lookup(g_CurrentReligionName))
end

local function buildReligionPickerItem(isFounding)
    if isFounding then
        return BaseMenuItems.Group({
            labelFn = religionPickerLabel,
            itemsFn = buildReligionChoices,
            cached = false,
        })
    end
    return BaseMenuItems.Choice({
        labelFn = religionPickerLabel,
        activate = function() end,
    })
end

-- Name row ------------------------------------------------------------------

-- Name row is gated on ReligionPanel visibility, which is only set once
-- SelectReligion has populated g_CurrentReligionName. The labelFn never
-- runs before the name is set.
local function nameRowLabel()
    return Text.format("TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW", Locale.Lookup(g_CurrentReligionName))
end

local function pushNameEditSub()
    ChangeReligionName() -- open the engine overlay and seed NewName

    local function onOK()
        OnChangeNameOK()
        -- Base hides ChangeNamePopup on success, leaves it visible with
        -- ChangeNameError shown on empty-name rejection. If the popup is
        -- still up, speak the error and stay in the sub; otherwise pop.
        if Controls.ChangeNamePopup:IsHidden() then
            HandlerStack.removeByName("ChangeReligionName", true)
            return
        end
        local err = Controls.ChangeNameError
        if not err:IsHidden() then
            local t = err:GetText()
            if t ~= nil and t ~= "" then
                SpeechPipeline.speakInterrupt(tostring(t))
            end
        end
    end

    local function onCancel()
        OnChangeNameCancel()
        HandlerStack.removeByName("ChangeReligionName", true)
    end

    local sub = BaseMenu.create({
        name = "ChangeReligionName",
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"),
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        items = {
            BaseMenuItems.Textfield({
                controlName = "NewName",
                textKey = "TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD",
            }),
            BaseMenuItems.Button({
                controlName = "ChangeNameOKButton",
                textKey = "TXT_KEY_OK_BUTTON",
                activate = onOK,
            }),
            BaseMenuItems.Button({
                controlName = "ChangeNameDefaultButton",
                textKey = "TXT_KEY_DEFAULT_BUTTON",
                activate = function()
                    OnChangeNameDefault()
                end,
            }),
            BaseMenuItems.Button({
                controlName = "ChangeNameCancelButton",
                textKey = "TXT_KEY_CANCEL_BUTTON",
                activate = onCancel,
            }),
        },
    })
    sub.onDeactivate = function()
        Controls.ChangeNamePopup:SetHide(true)
    end
    HandlerStack.push(sub)
end

local function buildNameRowItem(isFounding)
    if isFounding then
        return BaseMenuItems.Choice({
            labelFn = nameRowLabel,
            activate = pushNameEditSub,
            visibilityControlName = "ReligionPanel",
        })
    end
    return BaseMenuItems.Choice({
        labelFn = nameRowLabel,
        activate = function() end,
        visibilityControlName = "ReligionPanel",
    })
end

-- Confirm -------------------------------------------------------------------

local function confirmLabel(c)
    return tostring(c:GetText())
end

local function buildConfirmItem()
    return BaseMenuItems.Button({
        controlName = "FoundReligion",
        labelFn = confirmLabel,
        activate = function()
            FoundReligion() -- shows ChooseConfirm overlay
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

-- Item assembly -------------------------------------------------------------

local function buildItems(popupInfo)
    local isFounding = popupInfo.Option1 == true
    return {
        buildReligionPickerItem(isFounding),
        buildNameRowItem(isFounding),
        buildSlotItem(SLOT_PANTHEON),
        buildSlotItem(SLOT_FOUNDER),
        buildSlotItem(SLOT_FOLLOWER),
        buildSlotItem(SLOT_FOLLOWER2),
        buildSlotItem(SLOT_ENHANCER),
        buildSlotItem(SLOT_BONUS),
        buildConfirmItem(),
    }
end

-- Install -------------------------------------------------------------------

local function preambleText()
    if g_bFoundingReligion then
        return Text.key("TXT_KEY_CHOOSE_RELIGION_TITLE")
    end
    return Text.key("TXT_KEY_CHOOSE_RELIGION_TITLE_ENHANCE")
end

mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseReligionPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_FOUND_RELIGION then
        return
    end
    -- DisplayName tracks phase; install passed the founding key as a
    -- placeholder since BaseMenu.create requires a non-empty string at
    -- create time.
    if popupInfo.Option1 == true then
        mainHandler.displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION")
    else
        mainHandler.displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION")
    end
    mainHandler.setItems(buildItems(popupInfo))
end)

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
--
-- Engine awareness: Community Patch rewrites this screen. Our vp vendor
-- recipe re-exposes everything the wrapper drives (SelectReligion,
-- ChangeReligionName, OnYes, OnChangeName*, FoundReligion, the handlers,
-- and the state globals), but four contracts still differ from vanilla
-- and branch on the IS_CP probe below: the committed-belief table
-- (g_tSelectedBeliefs with its own slot numbering vs g_Beliefs), the
-- commit validator (ValidateSelection vs CheckifCanCommit), the current
-- religion name (g_strCurrentReligionName holds localized text vs
-- g_CurrentReligionName holding a text key), and "already has a
-- religion" (OwnsReligion -- religions can change hands under VP -- vs
-- HasCreatedReligion). CP also scores offered beliefs (BeliefAdvisor
-- suffixes) and ships a Tooltip column whose text replaces Description
-- on hover for the faith-building beliefs; we append it when it differs.

include("CivVAccess_PopupBoot")
include("CivVAccess_ChooseConfirmSub")
include("CivVAccess_BeliefAdvisor")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Engine probe. The vendor file ran before this include, so under CP the
-- recipe-promoted g_tSelectedBeliefs global already exists; vanilla
-- defines g_Beliefs instead.
local IS_CP = g_tSelectedBeliefs ~= nil

local mainHandler -- forward declared, assigned after install

-- The committed-belief table and the slot key for it. Vanilla's g_Beliefs
-- uses 4=Follower 2, 5=Enhancer, 6=Bonus; CP's g_tSelectedBeliefs uses
-- 4=Bonus, 5=Follower 2, 6=Enhancer.
local function beliefsTable()
    if IS_CP then
        return g_tSelectedBeliefs
    end
    return g_Beliefs
end

local function slotIdx(slot)
    if IS_CP then
        return slot.cpIndex
    end
    return slot.slotIndex
end

-- "Already has a religion" gate. CP's UI gates on ownership because
-- religions can change hands under VP; OwnsReligion doesn't exist on
-- vanilla, where founding is the only way to have one.
local function hasReligion(pPlayer)
    if pPlayer.OwnsReligion ~= nil then
        return pPlayer:OwnsReligion()
    end
    return pPlayer:HasCreatedReligion()
end

-- The religion a player holds, or nil. Mirrors each engine's own
-- religion-list builder (CP filters out pantheon-only ownership).
local function foundedReligionOf(pPlayer)
    if pPlayer.OwnsReligion ~= nil then
        if pPlayer:OwnsReligion() then
            local eReligion = pPlayer:GetOwnedReligion()
            if eReligion > ReligionTypes.RELIGION_PANTHEON then
                return eReligion
            end
        end
        return nil
    end
    if pPlayer:HasCreatedReligion() then
        return pPlayer:GetReligionCreatedByPlayer()
    end
    return nil
end

-- Commit-readiness refresh after a slot pick (drives the FoundReligion
-- button's disabled state, which our confirm item narrates).
local function validateCommit()
    if CheckifCanCommit ~= nil then
        CheckifCanCommit()
    else
        ValidateSelection()
    end
end

-- Current religion name for the picker / name rows. Vanilla stores the
-- religion's text key (custom names pass through Text.key unchanged);
-- CP stores already-localized text.
local function currentReligionName()
    if IS_CP then
        return g_strCurrentReligionName
    end
    if g_CurrentReligionName == nil then
        return nil
    end
    return Text.key(g_CurrentReligionName)
end

-- Slot metadata. slotIndex matches the g_Beliefs[] key the vanilla base
-- script uses, cpIndex the g_tSelectedBeliefs key in CP's BeliefSlots
-- enum; nameKey is the engine TXT_KEY for the slot's short label; picker
-- is the accessor for available-belief IDs; dedup (assigned below, after
-- all six exist) lists slots whose already-picked belief this session
-- must be excluded (mirrors the exclusion guards both engines' belief
-- click handlers use).
local SLOT_PANTHEON = {
    slotIndex = 1,
    cpIndex = 1,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_PANTHEON_BELIEF",
    picker = function()
        return Game.GetAvailablePantheonBeliefs()
    end,
}
local SLOT_FOUNDER = {
    slotIndex = 2,
    cpIndex = 2,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_FOUNDER_BELIEF",
    picker = function()
        return Game.GetAvailableFounderBeliefs()
    end,
}
local SLOT_FOLLOWER = {
    slotIndex = 3,
    cpIndex = 3,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_FOLLOWER_BELIEF",
    picker = function()
        return Game.GetAvailableFollowerBeliefs()
    end,
}
local SLOT_FOLLOWER2 = {
    slotIndex = 4,
    cpIndex = 5,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_FOLLOWER_BELIEF2",
    picker = function()
        return Game.GetAvailableFollowerBeliefs()
    end,
}
local SLOT_ENHANCER = {
    slotIndex = 5,
    cpIndex = 6,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_SPREAD_BELIEF",
    picker = function()
        return Game.GetAvailableEnhancerBeliefs()
    end,
}
local SLOT_BONUS = {
    slotIndex = 6,
    cpIndex = 4,
    nameKey = "TXT_KEY_CHOOSE_RELIGION_BONUS_BELIEF",
    picker = function()
        return Game.GetAvailableBonusBeliefs()
    end,
}
SLOT_PANTHEON.dedup = { SLOT_BONUS }
SLOT_FOUNDER.dedup = { SLOT_BONUS }
SLOT_FOLLOWER.dedup = { SLOT_BONUS }
SLOT_FOLLOWER2.dedup = {}
SLOT_ENHANCER.dedup = {}
SLOT_BONUS.dedup = { SLOT_PANTHEON, SLOT_FOUNDER, SLOT_FOLLOWER }

-- Slot-state classifier. Returns one of "editable", "committed", "later",
-- "byzantines_only". Replicates the dispatch in base's
-- RefreshExistingBeliefs (already-has-religion / HasCreatedPantheon /
-- Byzantines trait branches; see hasReligion for the per-engine gate).
local function slotState(slot, pPlayer)
    local owned = hasReligion(pPlayer)
    local hasPantheon = pPlayer:HasCreatedPantheon()
    local hasByzantine = pPlayer:IsTraitBonusReligiousBelief()
    if slot == SLOT_PANTHEON then
        if owned or hasPantheon then
            return "committed"
        end
        return "editable"
    end
    if slot == SLOT_FOUNDER or slot == SLOT_FOLLOWER then
        if owned then
            return "committed"
        end
        return "editable"
    end
    if slot == SLOT_FOLLOWER2 or slot == SLOT_ENHANCER then
        if owned then
            return "editable"
        end
        return "later"
    end
    -- SLOT_BONUS
    if not hasByzantine then
        return "byzantines_only"
    end
    if owned then
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
    local beliefID = beliefsTable()[slotIdx(slot)]
    if beliefID ~= nil then
        local beliefName = Text.key(GameInfo.Beliefs[beliefID].ShortDescription)
        return Text.format("TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN", slotName, beliefName)
    end
    return Text.format("TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN", slotName)
end

-- Drill-in children for an editable slot. Rebuilt on every drill
-- (cached=false on the Group) so dedup reflects the latest committed-
-- belief state.
local function buildBeliefChoices(slot)
    local dedup = {}
    for _, dedupSlot in ipairs(slot.dedup) do
        local bid = beliefsTable()[slotIdx(dedupSlot)]
        if bid ~= nil then
            dedup[bid] = true
        end
    end
    local rows = {}
    local offeredIDs = {}
    for _, id in ipairs(slot.picker()) do
        if not dedup[id] then
            local b = GameInfo.Beliefs[id]
            local description = Text.key(b.Description)
            local tooltip = description
            -- CP's Tooltip column replaces the hover text; for the
            -- faith-building beliefs it carries the building's full
            -- stats. Append it where it adds anything (the column reads
            -- nil on vanilla and equals Description for most beliefs).
            if b.Tooltip ~= nil then
                local extended = Text.key(b.Tooltip)
                if extended ~= description then
                    tooltip = description .. ", " .. extended
                end
            end
            rows[#rows + 1] = {
                id = id,
                name = Text.key(b.ShortDescription),
                tooltip = tooltip,
            }
            offeredIDs[#offeredIDs + 1] = id
        end
    end
    table.sort(rows, function(a, b)
        return Locale.Compare(a.name, b.name) < 0
    end)

    -- Engine advisor ranking (empty map on vanilla).
    local advisor = BeliefAdvisor.labelSuffixes(offeredIDs)

    local items = {}
    for _, row in ipairs(rows) do
        local beliefID = row.id
        local beliefLabel = row.name
        if advisor[beliefID] ~= nil then
            beliefLabel = beliefLabel .. ", " .. advisor[beliefID]
        end
        local beliefTooltip = row.tooltip
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = beliefLabel,
            tooltipText = beliefTooltip,
            activate = function()
                beliefsTable()[slotIdx(slot)] = beliefID
                validateCommit()
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
            local beliefID = beliefsTable()[slotIdx(slot)]
            if beliefID == nil then
                return nil
            end
            return Text.key(GameInfo.Beliefs[beliefID].Description)
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
        if pPlayer:IsEverAlive() then
            local eReligion = foundedReligionOf(pPlayer)
            if eReligion ~= nil then
                if pActiveTeam:IsHasMet(pPlayer:GetTeam()) then
                    taken[eReligion] = pPlayer:GetName()
                else
                    taken[eReligion] = Text.key("TXT_KEY_CHOOSE_RELIGION_UNMET_PLAYER")
                end
            end
        end
    end
    local religions = {}
    for row in GameInfo.Religions("Type <> 'RELIGION_PANTHEON'") do
        religions[#religions + 1] = {
            id = row.ID,
            name = Text.key(row.Description),
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
                    -- Vanilla's SelectReligion expects the religion's text
                    -- key (it localizes when it builds the name label);
                    -- CP's expects already-localized text.
                    if IS_CP then
                        SelectReligion(religionID, religionName, iconAtlas, portraitIndex)
                    else
                        SelectReligion(religionID, religionDescKey, iconAtlas, portraitIndex)
                    end
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
    local name = currentReligionName()
    if name == nil or name == "" then
        return Text.key("TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED")
    end
    return Text.format("TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED", name)
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
-- SelectReligion has populated the current-name global. The labelFn never
-- runs before the name is set.
local function nameRowLabel()
    return Text.format("TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW", currentReligionName())
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

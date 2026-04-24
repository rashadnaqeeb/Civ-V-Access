-- DiscussionDialog (BNW) accessibility. Follow-up screen to LeaderHeadRoot:
-- the AI has spoken, and the human picks from up to 8 response buttons
-- whose text, tooltips, and visibility are recomputed per DiploUIState.
--
-- Same open-speech and F1 contract as LeaderHeadRoot: on show we speak
-- only the leader title (onShow populates handler.displayName from
-- Controls.TitleText); F1 re-reads the full live preamble (mood +
-- leader speech). The leader speech changes as the AI sends follow-up
-- AILeaderMessage events; the function preamble resolves fresh each
-- F1 press so the user always gets the current text. The game plays a
-- voice clip for every message, so state changes are already announced
-- audibly -- the user knows to press F1 for text.
--
-- Three sibling overlays exist on this screen that BaseMenu can't model
-- as items directly: DenounceConfirm (yes/no denounce modal), WarConfirm
-- (yes/no war modal, reachable from the CONFRONT_YOU_KILLED_MY_SPY
-- state), and LeaderPanel (scrolling list of co-op-war targets). Each
-- opens as a visual overlay when the user picks the button that opens
-- it; we push a child BaseMenu handler whose onDeactivate hides the
-- overlay so Esc closes both handler and overlay in one step. The
-- child's activate either fires the base commit fn (Yes / No, pick a
-- leader) and pops the handler, or the user escapes out via escapePops.
--
-- Per-button activate dispatches to the base OnButton1..8 handlers;
-- afterActivate() checks whether any overlay just became visible and
-- pushes the matching child handler. The base button handlers remain
-- unchanged, so mouse-driven interaction keeps working for sighted
-- testers.

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
local priorShowHide = OnShowHide

-- Preamble --------------------------------------------------------------

local function composePreamble()
    local parts = {}
    local mood = Controls.MoodText:GetText()
    if mood ~= nil and mood ~= "" then
        parts[#parts + 1] = tostring(mood)
    end
    local speech = Controls.LeaderSpeech:GetText()
    if speech ~= nil and speech ~= "" then
        parts[#parts + 1] = tostring(speech)
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ", ")
end

local function readTooltip(ctrl)
    local ok, tip = pcall(function()
        return ctrl:GetToolTipString()
    end)
    if not ok or tip == nil or tip == "" then
        return nil
    end
    return tostring(tip)
end

-- Sub-handler: DenounceConfirm -----------------------------------------
--
-- Yes/No modal asking the player to confirm denouncing the AI. The base
-- wires OnDenonceConfirmYes / OnDenounceConfirmNo to the GridButtons;
-- the modal is just Controls.DenounceConfirm. Our handler wraps the two
-- actions as Choice items and uses onDeactivate to ensure the overlay
-- is hidden on Esc / Yes / No alike.

local DENOUNCE_SUB_NAME = "DiscussionDialog/DenounceConfirm"

local function pushDenounceConfirmSub()
    local labelText = Controls.DenounceLabel:GetText()
    if labelText == nil or labelText == "" then
        labelText = nil
    end
    local sub = BaseMenu.create({
        name = DENOUNCE_SUB_NAME,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"),
        preamble = labelText,
        escapePops = true,
        items = {
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    OnDenonceConfirmYes()
                    HandlerStack.removeByName(DENOUNCE_SUB_NAME, true)
                end,
            }),
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    OnDenounceConfirmNo()
                    HandlerStack.removeByName(DENOUNCE_SUB_NAME, true)
                end,
            }),
        },
    })
    sub.onDeactivate = function()
        Controls.DenounceConfirm:SetHide(true)
    end
    HandlerStack.push(sub)
end

-- Sub-handler: WarConfirm ----------------------------------------------
--
-- Yes/No modal for declaring war out of the CONFRONT_YOU_KILLED_MY_SPY
-- state. Same shape as DenounceConfirm.

local WAR_SUB_NAME = "DiscussionDialog/WarConfirm"

local function pushWarConfirmSub()
    local sub = BaseMenu.create({
        name = WAR_SUB_NAME,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"),
        preamble = Text.key("TXT_KEY_CONFIRM_WAR"),
        escapePops = true,
        items = {
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    OnWarConfirmYes()
                    HandlerStack.removeByName(WAR_SUB_NAME, true)
                end,
            }),
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    OnWarConfirmNo()
                    HandlerStack.removeByName(WAR_SUB_NAME, true)
                end,
            }),
        },
    })
    sub.onDeactivate = function()
        Controls.WarConfirm:SetHide(true)
    end
    HandlerStack.push(sub)
end

-- Sub-handler: LeaderPanel ---------------------------------------------
--
-- Scrolling list of civs the AI could ally with against in a co-op war.
-- The base game populates this via g_InstanceManager and wires each row
-- to OnLeaderSelect(leaderId) via button void1. We don't want to read
-- those instance controls back (InstanceManager doesn't give us stable
-- names); instead we re-run the same IsWarAgainstThirdPartyPlayerValid
-- walk to enumerate candidates and invoke OnLeaderSelect directly with
-- each leader's id. Leader names come from Players[i]:GetName(), which
-- returns the localized civ/leader name the engine put on the button.

local LEADER_PANEL_SUB_NAME = "DiscussionDialog/LeaderPanel"

local function buildLeaderItems()
    local items = {}
    for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if IsWarAgainstThirdPartyPlayerValid(iPlayer) then
            local leaderId = iPlayer
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = Players[iPlayer]:GetName(),
                activate = function()
                    OnLeaderSelect(leaderId)
                    HandlerStack.removeByName(LEADER_PANEL_SUB_NAME, true)
                end,
            })
        end
    end
    return items
end

local function pushLeaderPanelSub()
    local items = buildLeaderItems()
    if #items == 0 then
        -- Base already skipped opening the panel in this case, but guard
        -- anyway: empty children would strand the user in a menu with
        -- nothing to pick.
        return
    end
    local sub = BaseMenu.create({
        name = LEADER_PANEL_SUB_NAME,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"),
        escapePops = true,
        items = items,
    })
    sub.onDeactivate = function()
        -- Matches OnCloseLeaderPanelButton's visual state: re-enable the
        -- eight discussion buttons and hide the leader panel so the
        -- sighted UI returns to the discussion root.
        OnCloseLeaderPanelButton()
    end
    HandlerStack.push(sub)
end

-- Overlay detection -----------------------------------------------------
--
-- Runs after every button activate. The three overlays are mutually
-- exclusive (a single button activation opens at most one), so a single
-- visibility check at the end catches whichever just opened. We do not
-- push if the matching sub is already on the stack (e.g. a follow-up
-- AILeaderMessage could re-trigger the same branch; don't double-push).

local function hasSub(name)
    for i = 1, HandlerStack.count() do
        if HandlerStack.at(i).name == name then
            return true
        end
    end
    return false
end

local function afterActivate()
    if not Controls.DenounceConfirm:IsHidden() and not hasSub(DENOUNCE_SUB_NAME) then
        pushDenounceConfirmSub()
        return
    end
    if not Controls.WarConfirm:IsHidden() and not hasSub(WAR_SUB_NAME) then
        pushWarConfirmSub()
        return
    end
    if not Controls.LeaderPanel:IsHidden() and not hasSub(LEADER_PANEL_SUB_NAME) then
        pushLeaderPanelSub()
        return
    end
end

-- Install ---------------------------------------------------------------

local buttonFns = {
    OnButton1,
    OnButton2,
    OnButton3,
    OnButton4,
    OnButton5,
    OnButton6,
    OnButton7,
    OnButton8,
}

local function makeButtonItem(idx)
    local labelCtrlName = "Button" .. idx .. "Label"
    return BaseMenuItems.Button({
        controlName = "Button" .. idx,
        -- Button labels live on a sibling Label control, not the
        -- GridButton itself (XML defines <Label ID="Button{N}Label"/>
        -- as a child and LeaderMessageHandler writes to Button{N}Label).
        labelFn = function()
            return Controls[labelCtrlName]:GetText()
        end,
        tooltipFn = readTooltip,
        activate = function()
            buttonFns[idx]()
            afterActivate()
        end,
    })
end

BaseMenu.install(ContextPtr, {
    name = "DiscussionDialog",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"),
    preamble = composePreamble,
    silentFirstOpen = true,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = function(handler)
        local title = Controls.TitleText:GetText()
        if title ~= nil and title ~= "" then
            handler.displayName = tostring(title)
        end
    end,
    items = {
        makeButtonItem(1),
        makeButtonItem(2),
        makeButtonItem(3),
        makeButtonItem(4),
        makeButtonItem(5),
        makeButtonItem(6),
        makeButtonItem(7),
        makeButtonItem(8),
    },
})

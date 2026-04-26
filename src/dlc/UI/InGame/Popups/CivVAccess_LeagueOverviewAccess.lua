-- Accessibility wrapper for the engine's LeagueOverview popup
-- (BUTTONPOPUP_LEAGUE_OVERVIEW). Three-tab TabbedShell over what the engine
-- presents as a single non-tabbed screen: tab 1 status / members, tab 2
-- current proposals (View / Propose / Vote modes), tab 3 ongoing effects.
--
-- The screen is opened by the engine's existing entry points (Diplomacy
-- "World Congress" button, additional-info dropdown, league notifications)
-- and by our Ctrl+L binding on BaselineHandler. The engine's OnClose path
-- already closes the popup on Events.GameplaySetActivePlayer (line 124),
-- so we do not register our own listener -- the close cascades through
-- ShowHide which pops our handler.
--
-- Engine integration: ships an override of LeagueOverview.{lua,xml} (verbatim
-- BNW copies plus an include for this module). The engine's OnPopup,
-- InputHandler, ShowHideHandler, Update, View, RenameLeague, OnClose, and
-- the entire VoteController / ProposalController chain stay intact;
-- TabbedShell.install layers our handler on top via priorInput / priorShowHide
-- chains. We replicate the controller logic mod-side (see
-- CivVAccess_LeagueOverviewVote / _Proposal) so we never trigger the engine
-- ChooseProposalPopup / ResolutionChoicePopup / ChangeNamePopup overlays --
-- only the ChooseConfirm overlay (commit confirmation) is reused via
-- ChooseConfirmSub since its Controls.ConfirmYes / ConfirmNo wiring is
-- exactly what the shared sub-handler expects.
--
-- Refresh on Events.SerialEventLeagueScreenDirty rebuilds all three tabs
-- from live league state. Vote-mode preservation is handled inside the
-- vote controller's syncToCurrent: pending allocations survive across
-- refreshes for proposals whose IDs still appear; vanished proposals drop
-- their entries; new proposals get fresh entries with votes = 0.

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
include("CivVAccess_TabbedShell")
include("CivVAccess_Help")
include("CivVAccess_ChooseConfirmSub")
include("CivVAccess_LeagueOverviewRow")
include("CivVAccess_LeagueOverviewVote")
include("CivVAccess_LeagueOverviewProposal")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Module-level state, valid for one open session of the popup. Cleared on
-- hide so the next open starts with fresh controllers (no stale pending
-- votes / proposals carried across re-opens). Tab handles let onShow's
-- rebuild reach into each tab's inner BaseMenu via menu().setItems.
local m_statusTab
local m_proposalsTab
local m_effectsTab
local m_leagueId = -1
local m_voteController = nil
local m_proposalController = nil

-- Look up the active league's integer ID. League handles do not expose
-- a GetID method; the engine's notification path passes the ID via popup
-- Data1 (we cannot access that for our hotkey-initiated opens), so we
-- derive it by walking the GetLeague iteration and matching the active
-- league handle. BNW only ever has one active league; first non-nil wins
-- when no specific match is needed.
local function findLeagueIdFor(pLeague)
    if pLeague == nil then
        return -1
    end
    for i = 0, math.max(Game.GetNumLeaguesEverFounded() - 1, 0) do
        if Game.GetLeague(i) == pLeague then
            return i
        end
    end
    return -1
end

local function activeLeague()
    if Game.GetNumActiveLeagues() == 0 then
        return nil
    end
    return Game.GetActiveLeague()
end

-- Mode discrimination mirroring engine Update() lines 159-190. Pure derivation
-- from live league state; called once per tab rebuild so transitions between
-- modes (session start / end, proposals exhausted) take effect on the next
-- dirty-refresh without explicit hooks.
local function modeFor(pLeague, activePlayer)
    if pLeague == nil then
        return "View"
    end
    if not pLeague:IsInSession() then
        if pLeague:CanPropose(activePlayer) and pLeague:GetRemainingProposalsForMember(activePlayer) > 0 then
            return "Propose"
        end
        return "View"
    end
    if pLeague:GetRemainingVotesForMember(activePlayer) > 0 then
        return "Vote"
    end
    return "View"
end

-- No-league fallback message. Engine picks one of two strings in Update()
-- lines 222-228 based on whether the prereq tech exists and whether
-- GAMEOPTION_NO_LEAGUES is set; we mirror that exact branch.
local function noLeagueFallbackText()
    local requiredTech = GameInfo.Technologies("AllowsWorldCongress == 1")()
    if requiredTech == nil or Game.IsOption("GAMEOPTION_NO_LEAGUES") then
        return Text.key("TXT_KEY_LEAGUE_NOT_FOUNDED_GAME_SETTINGS")
    end
    return Text.format("TXT_KEY_LEAGUE_NOT_FOUNDED", Text.key(requiredTech.Description))
end

-- Tab 1 -------------------------------------------------------------------

-- Rename: trigger engine RenameLeague to surface the ChangeNamePopup overlay
-- (which prefills Controls.NewName with the current name and gives us a
-- focusable EditBox), then push a sub-handler containing one Textfield
-- bound to that EditBox. Enter commits via Network.SendLeagueEditName and
-- pops; Esc cancels via escapePops; either path hides the engine overlay
-- in onDeactivate so the underlying screen reads clean again.
local function pushRenameSub(activePlayer, leagueId)
    -- Trigger the engine overlay first; it is what surfaces Controls.NewName
    -- as a focusable EditBox. If it fails, abort -- pushing a Textfield
    -- handler against a hidden control would strand the user in a
    -- sub-handler with no live input and nothing to commit.
    if type(RenameLeague) ~= "function" then
        Log.error("LeagueOverview rename: engine RenameLeague unavailable")
        return
    end
    local ok, err = pcall(RenameLeague)
    if not ok then
        Log.error("LeagueOverview rename: engine RenameLeague failed: " .. tostring(err))
        return
    end
    local sub = BaseMenu.create({
        name = "LeagueOverviewRename",
        displayName = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_RENAME"),
        items = {
            BaseMenuItems.Textfield({
                controlName = "NewName",
                textKey = "TXT_KEY_CIVVACCESS_LEAGUE_RENAME",
                priorCallback = function(_, isEnter)
                    if not isEnter then
                        return
                    end
                    local nameCtrl = Controls.NewName
                    if nameCtrl == nil then
                        return
                    end
                    local okName, name = pcall(function()
                        return nameCtrl:GetText()
                    end)
                    if okName and name ~= nil and name ~= "" then
                        Network.SendLeagueEditName(leagueId, activePlayer, name)
                    end
                    HandlerStack.removeByName("LeagueOverviewRename", true)
                end,
            }),
        },
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    -- Single hide on every exit path (commit, Esc, sibling pop). The Textfield
    -- priorCallback no longer hides redundantly.
    sub.onDeactivate = function()
        if Controls.ChangeNamePopup ~= nil then
            Controls.ChangeNamePopup:SetHide(true)
        end
    end
    HandlerStack.push(sub)
end

local function memberDetailsTooltip(pLeague, member, activePlayer)
    local raw = pLeague:GetMemberDetails(member.playerID, activePlayer)
    return TextFilter.filter(tostring(raw or ""))
end

local function buildStatusTabItems(pLeague, activePlayer, leagueId)
    if pLeague == nil then
        return { BaseMenuItems.Text({ labelText = noLeagueFallbackText() }) }
    end
    local items = {}
    items[#items + 1] = BaseMenuItems.Text({
        labelText = LeagueOverviewRow.leagueName(pLeague),
    })
    if pLeague:CanChangeCustomName(activePlayer) then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_RENAME"),
            onActivate = function()
                pushRenameSub(activePlayer, leagueId)
            end,
        })
    end
    items[#items + 1] = BaseMenuItems.Text({
        labelText = LeagueOverviewRow.formatStatusPill(pLeague),
    })
    for _, member in ipairs(LeagueOverviewRow.orderedMembers(pLeague)) do
        items[#items + 1] = BaseMenuItems.Group({
            labelText = LeagueOverviewRow.formatMember(pLeague, member, activePlayer),
            items = {
                BaseMenuItems.Text({
                    labelText = memberDetailsTooltip(pLeague, member, activePlayer),
                }),
            },
        })
    end
    return items
end

-- Tab 2 -------------------------------------------------------------------

-- View All: read-only browse of the resolution catalog. Three sections that
-- match engine PopulateViewAllResolutionsPopup (line 915): Enacted (all
-- active), Possible (inactive where Possible == true), Other (inactive
-- where Possible == false). Per-row label is the bare resolution name --
-- no direction prefix, no proposer clause, no on-hold marker -- since
-- these are catalog entries, not proposals. Drill-in is one Text row
-- containing the full filtered GetResolutionDetails string (the engine's
-- pre-formatted opaque tooltip).
local function buildViewAllResolutionGroup(pLeague, candidate, activePlayer)
    local name = pLeague:GetResolutionName(candidate.Type, candidate.ResolutionId, candidate.ProposerDecision, false)
    local detailsText =
        pLeague:GetResolutionDetails(candidate.Type, activePlayer, candidate.ResolutionId, candidate.ProposerDecision)
    return BaseMenuItems.Group({
        labelText = tostring(name or ""),
        items = {
            BaseMenuItems.Text({ labelText = TextFilter.filter(tostring(detailsText or "")) }),
        },
    })
end

local function buildViewAllSection(headerKey, candidates, pLeague, activePlayer)
    if #candidates == 0 then
        return nil
    end
    local children = {}
    for _, candidate in ipairs(candidates) do
        children[#children + 1] = buildViewAllResolutionGroup(pLeague, candidate, activePlayer)
    end
    return BaseMenuItems.Group({
        labelText = Text.key(headerKey),
        items = children,
    })
end

local function pushViewAll(pLeague, activePlayer)
    local active, inactiveEnactable, inactiveOther = LeagueOverviewProposal.collectCandidates(pLeague, activePlayer)
    -- Engine View All filters inactives by Possible (not by Disabled-for-this-
    -- player). collectCandidates split by Disabled, so re-bucket here.
    local possible = {}
    local other = {}
    for _, src in ipairs({ inactiveEnactable, inactiveOther }) do
        for _, r in ipairs(src) do
            if r.Possible then
                possible[#possible + 1] = r
            else
                other[#other + 1] = r
            end
        end
    end
    local items = {}
    local sActive = buildViewAllSection("TXT_KEY_LEAGUE_OVERVIEW_ACTIVE_RESOLUTIONS", active, pLeague, activePlayer)
    if sActive ~= nil then
        items[#items + 1] = sActive
    end
    local sPossible =
        buildViewAllSection("TXT_KEY_LEAGUE_OVERVIEW_INACTIVE_RESOLUTIONS", possible, pLeague, activePlayer)
    if sPossible ~= nil then
        items[#items + 1] = sPossible
    end
    local sOther = buildViewAllSection("TXT_KEY_LEAGUE_OVERVIEW_OTHER_RESOLUTIONS", other, pLeague, activePlayer)
    if sOther ~= nil then
        items[#items + 1] = sOther
    end
    local sub = BaseMenu.create({
        name = "LeagueOverviewViewAll",
        displayName = Text.key("TXT_KEY_LEAGUE_OVERVIEW_VIEW_ALL_RESOLUTIONS"),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(sub)
end

-- Commit confirm: reuse ChooseConfirmSub via the engine's existing
-- Controls.ChooseConfirm / ConfirmText / ConfirmYes / ConfirmNo widgets.
-- We set ConfirmText ourselves (engine CommitConfirm sets it the same
-- way) and bypass the engine OnConfirmYes wiring -- our onYes runs the
-- commit and closes the popup directly.
local function pushCommitConfirm(unspentDelegates, onConfirm)
    if Controls.ConfirmText ~= nil then
        if unspentDelegates then
            Controls.ConfirmText:LocalizeAndSetText("TXT_KEY_LEAGUE_OVERVIEW_CONFIRM_MISSING_VOTES")
        else
            Controls.ConfirmText:LocalizeAndSetText("TXT_KEY_LEAGUE_OVERVIEW_CONFIRM")
        end
    end
    if Controls.ChooseConfirm ~= nil then
        Controls.ChooseConfirm:SetHide(false)
    end
    ChooseConfirmSub.push({ onYes = onConfirm })
end

local function onClose()
    local ok, err = pcall(OnClose)
    if not ok then
        Log.error("LeagueOverview onClose: engine OnClose failed: " .. tostring(err))
    end
end

-- Read-only proposal row for View / Propose modes (no vote control).
local function readOnlyProposalRow(pLeague, proposal, activePlayer)
    return BaseMenuItems.Text({
        labelText = LeagueOverviewRow.formatProposal(pLeague, proposal, activePlayer),
    })
end

-- Builds the Vote / Propose / View mode actions line. Vote mode reads the
-- live remaining-delegates count via labelFn so adjusts within the same
-- session reflect on the next nav read.
local function buildActionsLine(mode, pLeague, activePlayer)
    if mode == "Vote" then
        return BaseMenuItems.Text({
            labelFn = function()
                local n = m_voteController and m_voteController:availableVotes() or 0
                if n == 1 then
                    return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING_ONE")
                end
                return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING", n)
            end,
        })
    end
    if mode == "Propose" then
        local available = pLeague:GetRemainingProposalsForMember(activePlayer)
        if available == 1 then
            return BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE_ONE") })
        end
        return BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE", available),
        })
    end
    return BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS") })
end

local function buildViewAllButton(pLeague, activePlayer)
    return BaseMenuItems.Button({
        controlName = "ViewAllResolutionsButton",
        textKey = "TXT_KEY_LEAGUE_OVERVIEW_VIEW_ALL_RESOLUTIONS",
        activate = function()
            pushViewAll(pLeague, activePlayer)
        end,
    })
end

local function rebuildAllTabs() end -- forward decl; real fn defined after install

local function buildVoteFooter(pLeague, activePlayer)
    return {
        BaseMenuItems.Button({
            controlName = "ResetButton",
            textKey = "TXT_KEY_LEAGUE_OVERVIEW_RESET_VOTES",
            activate = function()
                if m_voteController == nil then
                    return
                end
                m_voteController:reset()
                local n = m_voteController:availableVotes()
                if n == 1 then
                    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING_ONE"))
                else
                    SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING", n))
                end
            end,
        }),
        BaseMenuItems.Button({
            controlName = "CommitButton",
            textKey = "TXT_KEY_LEAGUE_OVERVIEW_COMMIT_VOTES",
            activate = function()
                if m_voteController == nil then
                    return
                end
                local controller = m_voteController
                pushCommitConfirm(controller:hasUnspentDelegates(), function()
                    controller:commit(onClose)
                end)
            end,
        }),
        buildViewAllButton(pLeague, activePlayer),
    }
end

local function buildProposeFooter(pLeague, activePlayer)
    return {
        BaseMenuItems.Button({
            controlName = "ResetButton",
            textKey = "TXT_KEY_LEAGUE_OVERVIEW_RESET_PROPOSALS",
            activate = function()
                if m_proposalController == nil then
                    return
                end
                m_proposalController:reset()
                rebuildAllTabs()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "CommitButton",
            textKey = "TXT_KEY_LEAGUE_OVERVIEW_COMMIT_PROPOSALS",
            activate = function()
                if m_proposalController == nil then
                    return
                end
                local controller = m_proposalController
                pushCommitConfirm(false, function()
                    controller:commit(onClose)
                end)
            end,
        }),
        buildViewAllButton(pLeague, activePlayer),
    }
end

local function buildProposalsTabItems(pLeague, activePlayer)
    if pLeague == nil then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE") }) }
    end
    local mode = modeFor(pLeague, activePlayer)
    local items = { buildActionsLine(mode, pLeague, activePlayer) }
    local proposals = LeagueOverviewVote.collectProposals(pLeague, activePlayer)

    if mode == "Vote" then
        if m_voteController == nil then
            m_voteController = LeagueOverviewVote.create(pLeague, activePlayer, m_leagueId, proposals)
        else
            m_voteController:syncToCurrent(pLeague, proposals)
        end
    elseif mode == "Propose" then
        if m_proposalController == nil then
            m_proposalController = LeagueOverviewProposal.create(pLeague, activePlayer, m_leagueId)
        end
    end

    -- Empty-proposal placeholder is the same row in every mode; emit once
    -- before the per-mode body so each branch can focus on its real shape.
    if #proposals == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"),
        })
    elseif mode == "Vote" then
        for _, proposal in ipairs(proposals) do
            if proposal.OnHold then
                items[#items + 1] = readOnlyProposalRow(pLeague, proposal, activePlayer)
            else
                local idx = m_voteController:findEntryByProposalID(proposal.ID)
                if idx ~= nil then
                    items[#items + 1] = LeagueOverviewVote.row(m_voteController, idx, pLeague, activePlayer)
                end
            end
        end
    else
        for _, proposal in ipairs(proposals) do
            items[#items + 1] = readOnlyProposalRow(pLeague, proposal, activePlayer)
        end
    end

    if mode == "Vote" then
        for _, btn in ipairs(buildVoteFooter(pLeague, activePlayer)) do
            items[#items + 1] = btn
        end
    elseif mode == "Propose" then
        for slotIdx = 1, m_proposalController.numSlots do
            items[#items + 1] = LeagueOverviewProposal.slotItem(m_proposalController, slotIdx, pLeague, activePlayer)
        end
        for _, btn in ipairs(buildProposeFooter(pLeague, activePlayer)) do
            items[#items + 1] = btn
        end
    else
        items[#items + 1] = buildViewAllButton(pLeague, activePlayer)
    end

    return items
end

-- Tab 3 -------------------------------------------------------------------

local function buildEffectsTabItems(pLeague, activePlayer)
    if pLeague == nil then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE") }) }
    end
    local effects = pLeague:GetCurrentEffectsSummary() or {}
    if #effects == 0 then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_LEAGUE_OVERVIEW_EFFECT_SUMMARY_NONE") }) }
    end
    local items = {}
    for _, effect in ipairs(effects) do
        items[#items + 1] = BaseMenuItems.Text({ labelText = TextFilter.filter(tostring(effect)) })
    end
    return items
end

-- Install -----------------------------------------------------------------

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    local function makeTab(tabName)
        return TabbedShell.menuTab({
            tabName = tabName,
            menuSpec = {
                displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"),
                items = {},
            },
        })
    end
    m_statusTab = makeTab("TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS")
    m_proposalsTab = makeTab("TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS")
    m_effectsTab = makeTab("TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS")

    rebuildAllTabs = function()
        local pLeague = activeLeague()
        local activePlayer = Game.GetActivePlayer()
        m_leagueId = findLeagueIdFor(pLeague)
        m_statusTab.menu().setItems(buildStatusTabItems(pLeague, activePlayer, m_leagueId))
        m_proposalsTab.menu().setItems(buildProposalsTabItems(pLeague, activePlayer))
        m_effectsTab.menu().setItems(buildEffectsTabItems(pLeague, activePlayer))
    end

    TabbedShell.install(ContextPtr, {
        name = "LeagueOverview",
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"),
        tabs = { m_statusTab, m_proposalsTab, m_effectsTab },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(_handler)
            -- Drop pending state across re-opens. Engine's UpdateFull does
            -- the same with View() rebuilding fresh ProposalController /
            -- VoteController instances.
            m_voteController = nil
            m_proposalController = nil
            rebuildAllTabs()
        end,
    })

    -- Refresh on dirty. Engine fires this when other civs commit votes /
    -- proposals during the session, when the league name changes, when
    -- city-state ally swaps shift the vote pool, etc. Vote-mode pending
    -- allocations survive the rebuild via syncToCurrent inside the
    -- controller. Registered on every Context include rather than gated
    -- by an install-once flag because load-from-game wipes this Context's
    -- env and re-registers a fresh listener (Architecture Gotchas in
    -- CLAUDE.md).
    Events.SerialEventLeagueScreenDirty.Add(function()
        if ContextPtr:IsHidden() then
            return
        end
        local ok, err = pcall(rebuildAllTabs)
        if not ok then
            Log.error("LeagueOverview dirty refresh failed: " .. tostring(err))
        end
    end)
end

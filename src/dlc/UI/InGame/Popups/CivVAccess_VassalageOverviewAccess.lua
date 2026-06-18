-- civvaccess-seam-exempt: VP-only screen, gated off vanilla by a CP
-- capability probe, so it runs on exactly one engine and calls VP-only
-- vassalage Team bindings (IsVassalOfSomeone / GetMaster / GetNumVassals /
-- GetNumTurnsIsVassal / IsVassal) raw. Both-engines callers route those same
-- bindings through CivVAccess_EngineData.vassalInfo; this marker waives the
-- lint seam guard's drift sweep for this file so those names can stay in its
-- list. It does NOT waive the fork-binding sweep (those crash no-fork VP, a
-- supported mode); fork bindings still route through EngineData. See lint.ps1.
--
-- Vassal Overview accessibility (Vox Populi only; Ctrl+V or the
-- Additional Information dropdown / DiploCorner button). Wraps the
-- Community Patch VassalageOverview popup (BUTTONPOPUP_MODDER_11) as a
-- two-tab PickerReader mirroring the vendor's master-detail layout:
-- the picker lists the relevant civilizations (your vassals when you
-- are a master, the master team's players when you are someone's
-- vassal) plus a drillable Vassal Benefits group; Enter on a civ runs
-- the vendor's own selection handler (arming its detail-pane buttons
-- and tax slider for that civ) and opens the reader with the details.
--
-- Reader, master view (one of our vassals): vassal type and tenure; a
-- Statistics group mirroring the vendor's intelligence readout
-- (population with the maintenance it costs us, approval, gold with
-- the unit-maintenance share we pay, trade routes, ideology, culture,
-- tourism, religion, faith, science, current research); a Taxation
-- group (tax slider in 5-percent steps driving the vendor slider so
-- its Apply enable-state stays live, schedule rows, gold received,
-- Apply Changes); the treatment row with the DLL's factor breakdown
-- on the tooltip; an Independence group (the can-declare row with the
-- DLL conditions tooltip plus the four escape-condition ratios);
-- Liberate Vassal last.
--
-- Reader, vassal view (our master): type and tenure, the
-- can-declare-independence row, comparison statistics against the
-- master, the read-only taxes levied on us, Request Independence
-- last. Player-vs-team value pairs collapse to one number when equal
-- (singleton teams, the common case) so the ear isn't fed the same
-- number twice.
--
-- The three commit actions route through the vendor's own click
-- handlers so its Yes/No confirm overlay shows for a sighted
-- spectator; a pushed confirm sub speaks the vendor ConfirmLabel text
-- and drives the vendor Yes/No callbacks (BullyConfirm precedent).
-- Esc on the reader bounces to the picker (PickerReader default);
-- Esc on the picker falls through to the vendor InputHandler, which
-- closes the screen.
--
-- Two vendor display bugs deliberately not mirrored: the vendor's
-- ideology stat reads the ACTIVE player's ideology instead of the
-- vassal's, and its CanEndVassal call passes a player id where the
-- binding takes a team id (correct only while player ids equal team
-- ids). We read the vassal's ideology and pass the team id.

include("CivVAccess_PopupBoot")
include("CivVAccess_PickerReader")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- ===== Live-state helpers (no-cache rule: re-query per announce) ========

local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

local function activeTeamId()
    return activePlayer():GetTeam()
end

local function activeTeam()
    return Teams[activeTeamId()]
end

local function formatNumber(n)
    return Locale.ToNumber(n or 0, "#.##")
end

local function playerDisplayName(p)
    if p:GetNickName() ~= "" and Game.IsGameMultiPlayer() and p:IsHuman() then
        return p:GetNickName()
    end
    return p:GetName()
end

local function civShortName(p)
    return Text.key(GameInfo.Civilizations[p:GetCivilizationType()].ShortDescription)
end

local function vassalTypeText(vassalTeam, masterTeamId)
    if vassalTeam:IsVoluntaryVassal(masterTeamId) then
        return Text.key("TXT_KEY_VO_VASSAL_TYPE_VOLUNTARY")
    end
    return Text.key("TXT_KEY_VO_VASSAL_TYPE_CAPITULATED")
end

local function turnsText(vassalTeam)
    local n = vassalTeam:GetNumTurnsIsVassal()
    return Text.format("TXT_KEY_VO_TURNS", n, Game.GetGameTurn() - n)
end

-- "Now versus when vassalage started" ratio, with the vendor's special
-- cases for a zero start value.
local function startRatioPercent(now, start)
    if start ~= 0 then
        return math.floor(now * 100 / start)
    end
    if now == 0 then
        return 0
    end
    return 100
end

local function ratioPercent(num, den)
    if den == 0 then
        return 0
    end
    return math.floor(num * 100 / den)
end

-- Player-value / team-value display pairs ("23 (31)"). Collapsed to the
-- bare number when the two are equal so singleton teams (the common
-- case) don't speak the same number twice.
local function valuePair(playerVal, teamVal)
    if playerVal == teamVal then
        return tostring(playerVal)
    end
    return Text.format("TXT_KEY_VO_MASTER_VALUE_DISPLAY", playerVal, teamVal)
end

local function percentPair(playerPct, teamPct)
    if playerPct == teamPct then
        return playerPct .. "%"
    end
    return Text.format("TXT_KEY_VO_MASTER_VALUE_DISPLAY_PERCENT_PLAYER", playerPct, teamPct)
end

local TIER_KEYS = {
    ecstatic = "TXT_KEY_CIVVACCESS_STATUS_TIER_ECSTATIC",
    happy = "TXT_KEY_CIVVACCESS_STATUS_TIER_HAPPY",
    content = "TXT_KEY_CIVVACCESS_STATUS_TIER_CONTENT",
    unhappy = "TXT_KEY_CIVVACCESS_STATUS_TIER_UNHAPPY",
    veryUnhappy = "TXT_KEY_CIVVACCESS_STATUS_TIER_VERY_UNHAPPY",
    superUnhappy = "TXT_KEY_CIVVACCESS_STATUS_TIER_SUPER_UNHAPPY",
}

-- Approval-model happiness clause, same composition as the bare-H
-- empire readout (percent, tier word, citizen counts). The surplus
-- branch is unreachable on VP balance but kept for a balance-off CP
-- session where this Context could still load.
local function happinessText(p)
    local s = EngineData.happinessSummary(p)
    if s.mode == "approval" then
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_APPROVAL", s.value)
            .. ", "
            .. Text.key(TIER_KEYS[s.state])
            .. ", "
            .. Text.formatPlural(
                "TXT_KEY_CIVVACCESS_STATUS_CITIZEN_COUNTS",
                s.unhappyCitizens,
                s.happyCitizens,
                s.unhappyCitizens
            )
    end
    if s.value < 0 then
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_UNHAPPY", -s.value)
    end
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_HAPPY", s.value)
end

-- Current research mirror of the vendor's tech box: name plus turns
-- while researching, last tech when idle-finished, the engine's
-- choose-research summary otherwise.
local function researchText(p)
    local current = p:GetCurrentResearch()
    if current ~= -1 then
        local label =
            Text.format("TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING", Text.key(GameInfo.Technologies[current].Description))
        if p:GetScienceTimes100() > 0 then
            local turns = p:GetResearchTurnsLeft(current, true)
            label = label .. ", " .. Text.formatPlural("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS", turns, turns)
        end
        return label
    end
    local recent = Teams[p:GetTeam()]:GetTeamTechs():GetLastTechAcquired()
    if recent ~= -1 then
        return Text.key(GameInfo.Technologies[recent].Description) .. ", " .. Text.key("TXT_KEY_RESEARCH_FINISHED")
    end
    return Text.key("TXT_KEY_NOTIFICATION_SUMMARY_NEW_RESEARCH")
end

-- Vendor-mirrored tax schedule lines (when taxes were last set, when
-- they can next change). asVassal selects the master-perspective
-- phrasings of the never-set / ready states.
local function taxScheduleTexts(masterTeam, taxedPlayer, asVassal)
    local total = Game.GetMinimumVassalTaxTurns()
    local since = masterTeam:GetNumTurnsSinceVassalTaxSet(taxedPlayer)
    local left = total - since
    local setText
    if since == -1 then
        setText = Text.key(asVassal and "TXT_KEY_VO_TAX_TURN_NOT_SET_EVER_MASTER" or "TXT_KEY_VO_TAX_TURN_NOT_SET_EVER")
    else
        setText = Text.format("TXT_KEY_VO_TAX_TURN_SET", Game.GetGameTurn() - since)
    end
    local availText
    if left <= 0 or since == -1 then
        availText = Text.key(asVassal and "TXT_KEY_VO_TAX_CHANGE_READY_MASTER" or "TXT_KEY_VO_TAX_CHANGE_READY")
    else
        availText = Text.format("TXT_KEY_VO_TAX_TURN_AVAILABLE", Game.GetGameTurn() + left)
    end
    return setText, availText
end

local TREATMENT_KEYS = {
    [0] = "TXT_KEY_VO_TREATMENT_CONTENT",
    [1] = "TXT_KEY_VO_TREATMENT_DISAGREE",
    [2] = "TXT_KEY_VO_TREATMENT_MISTREATED",
    [3] = "TXT_KEY_VO_TREATMENT_UNHAPPY",
    [4] = "TXT_KEY_VO_TREATMENT_ENSLAVED",
}

-- ===== Confirm sub (vendor Yes/No overlay wrap) =========================
--
-- The action buttons call the vendor's own click handlers, which raise
-- the Confirm overlay and seat the action type / target into the Yes
-- button's voids. This sub speaks the vendor's ConfirmLabel and drives
-- the vendor OnYes / OnNo. Liberate (0) and independence (2) dequeue
-- the popup inside OnYes, so the sub is dropped without reactivation
-- first; the tax change (1) keeps the screen open, so OnYes commits
-- first and the reactivation announce reads the post-commit state.
local function pushConfirm()
    local sub = BaseMenu.create({
        name = "VassalageConfirm",
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"),
        preamble = function()
            return Controls.ConfirmLabel:GetText() or ""
        end,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        items = {
            BaseMenuItems.Button({
                controlName = "Yes",
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    local kind = Controls.Yes:GetVoid1()
                    local value = Controls.Yes:GetVoid2()
                    if kind == 1 then
                        OnYes(kind, value)
                        HandlerStack.removeByName("VassalageConfirm", true)
                    else
                        HandlerStack.removeByName("VassalageConfirm", false)
                        OnYes(kind, value)
                    end
                end,
            }),
            BaseMenuItems.Button({
                controlName = "No",
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    OnNo()
                    HandlerStack.removeByName("VassalageConfirm", true)
                end,
            }),
        },
    })
    sub.onDeactivate = function()
        -- Esc (escapePops) skips both vendor callbacks; hide the overlay
        -- here so the sighted state matches. Idempotent for the Yes / No
        -- paths where OnYes / OnNo already hid it.
        if Controls.Confirm ~= nil then
            Controls.Confirm:SetHide(true)
        end
        if Controls.BGBlock ~= nil then
            Controls.BGBlock:SetHide(false)
        end
    end
    HandlerStack.push(sub)
end

-- ===== Tax slider (master view) =========================================
--
-- Custom slider-shaped item over the vendor's TaxSlider. Adjust steps
-- the pending rate by 5 percent (Shift: 10), writes the vendor slider,
-- and fires the vendor's own TaxSliderUpdate (the engine never fires
-- slider callbacks on programmatic SetValue) so the visual label and
-- the Apply button's enable logic stay in lockstep with what we speak.
local function taxSliderItem(ePlayer)
    local item = { kind = "slider" }
    local function pendingTax()
        return PercentToTaxValue(Controls.TaxSlider:GetValue())
    end
    local function canAdjust()
        return activeTeam():CanSetVassalTax(ePlayer)
    end
    local function tooSoonText()
        local total = Game.GetMinimumVassalTaxTurns()
        local since = activeTeam():GetNumTurnsSinceVassalTaxSet(ePlayer)
        return Text.format("TXT_KEY_VO_TAX_TOO_SOON", total, total - since)
    end
    function item:isNavigable()
        return true
    end
    function item:isActivatable()
        return canAdjust()
    end
    function item:announce()
        local text = Text.format("TXT_KEY_VO_TAX_RATE", pendingTax())
        if Verbosity.isOn() then
            text = text .. ", " .. Text.key("TXT_KEY_CIVVACCESS_KIND_SLIDER")
        end
        if not canAdjust() then
            text = text .. ", " .. Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
            text = BaseMenuItems.appendTooltip(text, tooSoonText())
        end
        return text
    end
    function item:activate(menu)
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    function item:adjust(menu, dir, big)
        if not canAdjust() then
            SpeechPipeline.speakInterrupt(self:announce(menu))
            return
        end
        local step = big and 10 or 5
        local target = pendingTax() + dir * step
        target = math.min(math.max(target, Game.GetMinimumVassalTax()), Game.GetMaximumVassalTax())
        local fraction = TaxValueToPercent(target)
        Controls.TaxSlider:SetValue(fraction)
        TaxSliderUpdate(fraction)
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    return item
end

-- ===== Reader, master view (one of our vassals) =========================

local function buildVassalStatisticsItems(ePlayer)
    return {
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_POPULATION_STAT") .. ", " .. Players[ePlayer]:GetTotalPopulation()
            end,
            tooltipFn = function()
                local cost = activePlayer():GetVassalGoldMaintenance(Players[ePlayer]:GetTeam(), true, false)
                return "-" .. cost .. "[ICON_GOLD]. " .. Text.key("TXT_KEY_VO_POPULATION_MAINTENANCE")
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_HAPPINESS_STAT") .. ", " .. happinessText(Players[ePlayer])
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_GROSS_GPT_STAT")
                    .. ", "
                    .. formatNumber(Players[ePlayer]:CalculateGrossGold())
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_GOLD_PER_TURN_STAT")
                    .. ", "
                    .. formatNumber(Players[ePlayer]:CalculateGoldRateTimes100() / 100)
            end,
            tooltipFn = function()
                local cost = activePlayer():GetVassalGoldMaintenance(Players[ePlayer]:GetTeam(), false, true)
                return "-" .. cost .. "[ICON_GOLD]. " .. Text.key("TXT_KEY_VO_UNIT_MAINTENANCE")
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local p = Players[ePlayer]
                return Text.key("TXT_KEY_VO_TRADE_ROUTES_STAT")
                    .. ", "
                    .. Text.format(
                        "TXT_KEY_VO_TRADE_ROUTES_LABEL",
                        p:GetNumInternationalTradeRoutesUsed(),
                        p:GetNumInternationalTradeRoutesAvailable()
                    )
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local e = Players[ePlayer]:GetLateGamePolicyTree()
                if e ~= -1 then
                    return Text.format("TXT_KEY_VO_IDEOLOGY", GameInfo.PolicyBranchTypes[e].Description)
                end
                return Text.key("TXT_KEY_VO_NO_IDEOLOGY")
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_CULTURE_STAT")
                    .. ", "
                    .. formatNumber(Players[ePlayer]:GetTotalJONSCulturePerTurnTimes100() / 100)
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_TOURISM_STAT") .. ", " .. EngineData.tourism(Players[ePlayer])
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local e = Players[ePlayer]:GetMajorityReligion()
                if e ~= -1 then
                    return Text.format("TXT_KEY_VO_MAJORITY_RELIGION", GameInfo.Religions[e].Description)
                end
                return Text.key("TXT_KEY_VO_NO_RELIGION")
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_FAITH_STAT")
                    .. ", "
                    .. formatNumber(Players[ePlayer]:GetTotalFaithPerTurnTimes100() / 100)
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_SCIENCE_STAT")
                    .. ", "
                    .. formatNumber(Players[ePlayer]:GetScienceTimes100() / 100)
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return researchText(Players[ePlayer])
            end,
        }),
    }
end

local function buildVassalTaxItems(ePlayer)
    return {
        taxSliderItem(ePlayer),
        BaseMenuItems.Text({
            labelFn = function()
                local setText = taxScheduleTexts(activeTeam(), ePlayer, false)
                return setText
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local _, availText = taxScheduleTexts(activeTeam(), ePlayer, false)
                return availText
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.format("TXT_KEY_VO_TAX_CONTRIBUTION", activePlayer():GetVassalTaxContribution(ePlayer))
            end,
            tooltipFn = function()
                return Text.format(
                    "TXT_KEY_VO_TAX_GPT_RECEIVED_TT",
                    activePlayer():GetVassalTaxContribution(ePlayer),
                    activeTeam():GetVassalTax(ePlayer),
                    Players[ePlayer]:CalculateGrossGold()
                )
            end,
        }),
        BaseMenuItems.Button({
            controlName = "ApplyChanges",
            labelFn = function()
                local neverSet = activeTeam():GetNumTurnsSinceVassalTaxSet(ePlayer) == -1
                return Text.key(neverSet and "TXT_KEY_SET_TAXES" or "TXT_KEY_APPLY_CHANGES")
            end,
            tooltipFn = function()
                local neverSet = activeTeam():GetNumTurnsSinceVassalTaxSet(ePlayer) == -1
                return Text.key(neverSet and "TXT_KEY_SET_TAXES_TT" or "TXT_KEY_APPLY_CHANGES_TT")
            end,
            activate = function()
                OnApplyChangesClicked(ePlayer)
                pushConfirm()
            end,
        }),
    }
end

local function buildVassalIndependenceItems(ePlayer)
    local function vassalTeam()
        return Teams[Players[ePlayer]:GetTeam()]
    end
    return {
        BaseMenuItems.Text({
            labelFn = function()
                local can = vassalTeam():CanEndVassal(activeTeamId())
                return Text.format(
                    "TXT_KEY_VO_INDEPENDENCE_POSSIBLE_MASTER",
                    Text.key(can and "TXT_KEY_DECLARE_WAR_YES" or "TXT_KEY_DECLARE_WAR_NO")
                )
            end,
            tooltipFn = function()
                return activePlayer():GetVassalIndependenceTooltipAsMaster(ePlayer)
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local v = vassalTeam()
                return Text.key("TXT_KEY_VO_CITY_PERCENT")
                    .. " "
                    .. startRatioPercent(v:GetNumCities(), v:GetNumCitiesWhenVassalMade())
                    .. "%"
            end,
            tooltipFn = function()
                local v = vassalTeam()
                return Text.format(
                    "TXT_KEY_VO_CITY_PERCENT_TT",
                    v:GetNumCities(),
                    v:GetNumCitiesWhenVassalMade(),
                    Players[ePlayer]:GetNumCities()
                )
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local v = vassalTeam()
                return Text.key("TXT_KEY_VO_POP_PERCENT")
                    .. " "
                    .. startRatioPercent(v:GetTotalPopulation(), v:GetTotalPopulationWhenVassalMade())
                    .. "%"
            end,
            tooltipFn = function()
                local v = vassalTeam()
                return Text.format(
                    "TXT_KEY_VO_POP_PERCENT_TT",
                    v:GetTotalPopulation(),
                    v:GetTotalPopulationWhenVassalMade(),
                    Players[ePlayer]:GetTotalPopulation()
                )
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_CITY_PERCENT")
                    .. " "
                    .. ratioPercent(vassalTeam():GetNumCities(), activeTeam():GetNumCities())
                    .. "%"
            end,
            tooltipFn = function()
                return Text.format(
                    "TXT_KEY_VO_MASTER_CITY_PERCENT_TT",
                    vassalTeam():GetNumCities(),
                    activeTeam():GetNumCities(),
                    Players[ePlayer]:GetNumCities()
                )
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_POP_PERCENT")
                    .. " "
                    .. ratioPercent(vassalTeam():GetTotalPopulation(), activeTeam():GetTotalPopulation())
                    .. "%"
            end,
            tooltipFn = function()
                return Text.format(
                    "TXT_KEY_VO_MASTER_POP_PERCENT_TT",
                    vassalTeam():GetTotalPopulation(),
                    activeTeam():GetTotalPopulation(),
                    Players[ePlayer]:GetTotalPopulation()
                )
            end,
        }),
    }
end

local function buildVassalReaderItems(ePlayer)
    -- Run the vendor's own selection handler first: it arms the detail
    -- pane's buttons (SetVoid targets, callbacks, disable states) and
    -- seats the tax slider, which the action items below drive.
    Log.tryCall("VassalageOverview VassalSelected", VassalSelected, ePlayer)
    return {
        BaseMenuItems.Text({
            labelFn = function()
                return vassalTypeText(Teams[Players[ePlayer]:GetTeam()], activeTeamId())
            end,
            tooltipFn = function()
                local voluntary = Teams[Players[ePlayer]:GetTeam()]:IsVoluntaryVassal(activeTeamId())
                return Text.key(
                    voluntary and "TXT_KEY_VO_VASSAL_TYPE_VOLUNTARY_TT" or "TXT_KEY_VO_VASSAL_TYPE_CAPITULATED_TT"
                )
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return turnsText(Teams[Players[ePlayer]:GetTeam()])
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_VO_STATISTICS"),
            cached = false,
            itemsFn = function()
                return buildVassalStatisticsItems(ePlayer)
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_VO_TAXES"),
            cached = false,
            itemsFn = function()
                return buildVassalTaxItems(ePlayer)
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local level = Players[ePlayer]:GetVassalTreatmentLevel(Game.GetActivePlayer())
                return Text.format("TXT_KEY_VO_TREATMENT", Text.key(TREATMENT_KEYS[level]))
            end,
            tooltipFn = function()
                return Players[ePlayer]:GetVassalTreatmentToolTip(Game.GetActivePlayer())
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_VO_INDEPENDENCE"),
            cached = false,
            itemsFn = function()
                return buildVassalIndependenceItems(ePlayer)
            end,
        }),
        BaseMenuItems.Button({
            controlName = "LiberateCiv",
            textKey = "TXT_KEY_VO_LIBERATE_VASSAL",
            tooltipFn = function()
                local vTeamId = Players[ePlayer]:GetTeam()
                local tt = Text.format("TXT_KEY_VO_LIBERATE_VASSAL_TT", Teams[vTeamId]:GetName())
                if not activeTeam():CanLiberateVassal(vTeamId) then
                    local minTurns = Game.GetMinimumVassalLiberateTurns()
                    tt = tt
                        .. "[NEWLINE]"
                        .. Text.format(
                            "TXT_KEY_VO_LIBERATE_VASSAL_TOO_SOON",
                            minTurns,
                            minTurns - Teams[vTeamId]:GetNumTurnsIsVassal()
                        )
                end
                return tt
            end,
            activate = function()
                OnLiberateCivClicked(Players[ePlayer]:GetTeam())
                pushConfirm()
            end,
        }),
    }
end

-- ===== Reader, vassal view (our master) =================================

local function buildMasterStatisticsItems(ePlayer)
    local function masterPlayer()
        return Players[ePlayer]
    end
    local function masterTeam()
        return Teams[Players[ePlayer]:GetTeam()]
    end
    return {
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_YOUR_POP")
                    .. ", "
                    .. valuePair(activePlayer():GetTotalPopulation(), activeTeam():GetTotalPopulation())
            end,
            tooltipKey = "TXT_KEY_VO_MASTER_YOUR_POP_TT",
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_THEIR_POP")
                    .. ", "
                    .. valuePair(masterPlayer():GetTotalPopulation(), masterTeam():GetTotalPopulation())
            end,
            tooltipKey = "TXT_KEY_VO_MASTER_THEIR_POP_TT",
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_VIEW_POP_PERCENT")
                    .. ", "
                    .. percentPair(
                        ratioPercent(activePlayer():GetTotalPopulation(), masterPlayer():GetTotalPopulation()),
                        ratioPercent(activeTeam():GetTotalPopulation(), masterTeam():GetTotalPopulation())
                    )
            end,
            tooltipFn = function()
                return Text.format("TXT_KEY_VO_MASTER_VIEW_POP_PERCENT_TT", playerDisplayName(masterPlayer()))
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_POP_STARTED_PERCENT")
                    .. ", "
                    .. startRatioPercent(
                        activeTeam():GetTotalPopulation(),
                        activeTeam():GetTotalPopulationWhenVassalMade()
                    )
                    .. "%"
            end,
            tooltipFn = function()
                return Text.format("TXT_KEY_VO_MASTER_POP_STARTED_PERCENT_TT", masterTeam():GetName())
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_YOUR_CITIES")
                    .. ", "
                    .. valuePair(activePlayer():GetNumCities(), activeTeam():GetNumCities())
            end,
            tooltipKey = "TXT_KEY_VO_MASTER_YOUR_CITIES_TT",
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_THEIR_CITIES")
                    .. ", "
                    .. valuePair(masterPlayer():GetNumCities(), masterTeam():GetNumCities())
            end,
            tooltipKey = "TXT_KEY_VO_MASTER_THEIR_CITIES_TT",
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_CITIES_PERCENT")
                    .. ", "
                    .. percentPair(
                        ratioPercent(activePlayer():GetNumCities(), masterPlayer():GetNumCities()),
                        ratioPercent(activeTeam():GetNumCities(), masterTeam():GetNumCities())
                    )
            end,
            tooltipFn = function()
                return Text.format("TXT_KEY_VO_MASTER_CITIES_PERCENT_TT", playerDisplayName(masterPlayer()))
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.key("TXT_KEY_VO_MASTER_CITIES_STARTED_PERCENT")
                    .. ", "
                    .. startRatioPercent(activeTeam():GetNumCities(), activeTeam():GetNumCitiesWhenVassalMade())
                    .. "%"
            end,
            tooltipFn = function()
                return Text.format("TXT_KEY_VO_MASTER_CITIES_STARTED_PERCENT_TT", masterTeam():GetName())
            end,
        }),
    }
end

local function buildMasterTaxItems(ePlayer)
    local function masterTeam()
        return Teams[Players[ePlayer]:GetTeam()]
    end
    return {
        BaseMenuItems.Text({
            labelFn = function()
                return Text.format("TXT_KEY_VO_TAX_RATE", masterTeam():GetVassalTax(Game.GetActivePlayer()))
            end,
            tooltipFn = function()
                return Text.format(
                    "TXT_KEY_VO_TAX_RATE_MASTER_TT",
                    masterTeam():GetVassalTax(Game.GetActivePlayer()),
                    masterTeam():GetName()
                )
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local setText = taxScheduleTexts(masterTeam(), Game.GetActivePlayer(), true)
                return setText
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local _, availText = taxScheduleTexts(masterTeam(), Game.GetActivePlayer(), true)
                return availText
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.format(
                    "TXT_KEY_VO_TAX_CONTRIBUTION_MASTER",
                    activePlayer():GetExpensePerTurnFromVassalTaxes()
                )
            end,
            tooltipFn = function()
                return Text.format(
                    "TXT_KEY_VO_TAX_GPT_TAKEN_TT",
                    activePlayer():GetExpensePerTurnFromVassalTaxes(),
                    masterTeam():GetVassalTax(Game.GetActivePlayer()),
                    activePlayer():CalculateGrossGold()
                )
            end,
        }),
    }
end

local function buildMasterReaderItems(ePlayer)
    Log.tryCall("VassalageOverview MasterSelected", MasterSelected, ePlayer)
    local function masterTeamId()
        return Players[ePlayer]:GetTeam()
    end
    return {
        BaseMenuItems.Text({
            labelFn = function()
                return vassalTypeText(activeTeam(), masterTeamId())
            end,
            tooltipFn = function()
                local voluntary = activeTeam():IsVoluntaryVassal(masterTeamId())
                return Text.format(
                    voluntary and "TXT_KEY_VO_MASTER_TYPE_VOLUNTARY_TT" or "TXT_KEY_VO_MASTER_TYPE_CAPITULATED_TT",
                    playerDisplayName(Players[ePlayer])
                )
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return turnsText(activeTeam())
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                local can = activeTeam():CanEndVassal(masterTeamId())
                return Text.format(
                    "TXT_KEY_VO_INDEPENDENCE_POSSIBLE_MASTER",
                    Text.key(can and "TXT_KEY_DECLARE_WAR_YES" or "TXT_KEY_DECLARE_WAR_NO")
                )
            end,
            tooltipFn = function()
                return activePlayer():GetVassalIndependenceTooltipAsVassal(ePlayer)
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_VO_STATISTICS"),
            cached = false,
            itemsFn = function()
                return buildMasterStatisticsItems(ePlayer)
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_VO_TAXES"),
            cached = false,
            itemsFn = function()
                return buildMasterTaxItems(ePlayer)
            end,
        }),
        BaseMenuItems.Button({
            controlName = "RequestIndependence",
            textKey = "TXT_KEY_VO_REQUEST_INDEPENDENCE",
            tooltipFn = function()
                local team = activeTeam()
                local tt = Text.format("TXT_KEY_VO_REQUEST_INDEPENDENCE_TT", Teams[masterTeamId()]:GetName())
                if not team:CanEndVassal(masterTeamId()) then
                    local minTurns
                    if team:IsVoluntaryVassal(masterTeamId()) then
                        minTurns = Game.GetMinimumVoluntaryVassalTurns()
                    else
                        minTurns = Game.GetMinimumVassalTurns()
                    end
                    local n = team:GetNumTurnsIsVassal()
                    if n < minTurns then
                        tt = tt
                            .. "[NEWLINE]"
                            .. Text.format("TXT_KEY_VO_REQUEST_INDEPENDENCE_TOO_SOON", minTurns, minTurns - n)
                    else
                        tt = tt .. "[NEWLINE]" .. Text.key("TXT_KEY_VO_REQUEST_INDEPENDENCE_CONDITION_NOT_MET")
                    end
                end
                return tt
            end,
            activate = function()
                OnRequestIndependenceClicked(Teams[masterTeamId()]:GetLeaderID())
                pushConfirm()
            end,
        }),
    }
end

-- ===== Picker ===========================================================

-- Players whose team is our vassal (master view rows).
local function vassalPlayers()
    local list = {}
    local ourTeam = activeTeamId()
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local p = Players[i]
        if i ~= Game.GetActivePlayer() and p:IsEverAlive() and p:IsAlive() and Teams[p:GetTeam()]:IsVassal(ourTeam) then
            list[#list + 1] = i
        end
    end
    return list
end

-- Players on the team we are the vassal of (vassal view rows).
local function masterPlayers()
    local list = {}
    local team = activeTeam()
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local p = Players[i]
        if i ~= Game.GetActivePlayer() and p:IsEverAlive() and p:IsAlive() and team:IsVassal(p:GetTeam()) then
            list[#list + 1] = i
        end
    end
    return list
end

-- The picker row's fragments: identity (leader, civ) as one section, then an
-- optional team marker, the vassal-type word, and the tenure. Shared by the
-- joined labelFn and the Alt+Up/Down sectionsFn so the spoken row and its
-- section list can't drift. Re-queried live each call (no cache).
local function civEntryParts(ePlayer, role)
    local p = Players[ePlayer]
    local vassalTeam, masterTeamId
    if role == "vassal" then
        vassalTeam = Teams[p:GetTeam()]
        masterTeamId = activeTeamId()
    else
        vassalTeam = activeTeam()
        masterTeamId = p:GetTeam()
    end
    local parts = { playerDisplayName(p) .. ", " .. civShortName(p) }
    if Teams[p:GetTeam()]:GetNumMembers() > 1 then
        parts[#parts + 1] = Text.format("TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME", p:GetTeam() + 1)
    end
    parts[#parts + 1] = vassalTypeText(vassalTeam, masterTeamId)
    parts[#parts + 1] = turnsText(vassalTeam)
    return parts
end

local function civEntry(pr, ePlayer, role)
    return pr.Entry({
        id = role .. ":" .. tostring(ePlayer),
        labelFn = function()
            return table.concat(civEntryParts(ePlayer, role), ", ")
        end,
        sectionsFn = function()
            return civEntryParts(ePlayer, role)
        end,
        buildReader = function()
            if role == "vassal" then
                return { items = buildVassalReaderItems(ePlayer) }
            end
            return { items = buildMasterReaderItems(ePlayer) }
        end,
    })
end

local BENEFIT_KEYS = {
    "TXT_KEY_VO_BENEFITS_OPEN_BORDERS",
    "TXT_KEY_VO_BENEFITS_YIELD_PERCENTAGE",
    "TXT_KEY_VO_BENEFITS_HAPPINESS_PERCENTAGE",
    "TXT_KEY_VO_BENEFITS_RELIGION_MOD",
    "TXT_KEY_VO_BENEFITS_TOURISM_MOD",
    "TXT_KEY_VO_BENEFITS_DIPLOMAT",
    "TXT_KEY_VO_BENEFITS_IDEOLOGY",
    "TXT_KEY_VO_BENEFITS_LEVY",
}

local function benefitsGroup()
    local children = {}
    for _, key in ipairs(BENEFIT_KEYS) do
        children[#children + 1] = BaseMenuItems.Text({ textKey = key })
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_VO_VASSAL_BENEFITS"),
        items = children,
    })
end

local function buildPickerItems(pr)
    local items = {}
    if activeTeam():IsVassalOfSomeone() then
        for _, i in ipairs(masterPlayers()) do
            items[#items + 1] = civEntry(pr, i, "master")
        end
    else
        local vassals = vassalPlayers()
        for _, i in ipairs(vassals) do
            items[#items + 1] = civEntry(pr, i, "vassal")
        end
        if #vassals == 0 then
            items[#items + 1] = BaseMenuItems.Text({ textKey = "TXT_KEY_VO_NO_VASSALS" })
        end
    end
    items[#items + 1] = benefitsGroup()
    return items
end

-- ===== Preamble =========================================================

local function worldVassalCount()
    local n = 0
    for i = 0, GameDefines.MAX_CIV_TEAMS - 1 do
        if Teams[i]:GetMaster() ~= -1 then
            n = n + 1
        end
    end
    return n
end

local function preambleText()
    local team = activeTeam()
    local started = team:GetCurrentEra() >= Game.GetVassalageEnabledEra() or team:IsVassalOfSomeone()
    if not started then
        return Text.key("TXT_KEY_VASSALAGE_NOT_STARTED_YET")
    end
    local parts = {}
    if team:IsVassalOfSomeone() then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_VO_VASSAL_OF", Teams[team:GetMaster()]:GetName())
    elseif team:GetNumVassals() == 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_VO_NO_VASSALS")
    else
        parts[#parts + 1] = Text.format("TXT_KEY_VO_NUM_OUR_VASSALS", team:GetNumVassals())
    end
    parts[#parts + 1] = Text.format("TXT_KEY_VO_NUM_WORLD_VASSALS", worldVassalCount())
    return table.concat(parts, ", ")
end

-- ===== Install ==========================================================

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    local pr = PickerReader.create()
    pr.install(ContextPtr, {
        name = "VassalageOverview",
        displayName = Text.key("TXT_KEY_VO"),
        pickerTabName = "TXT_KEY_CIVVACCESS_VO_TAB_CIVS",
        readerTabName = "TXT_KEY_CIVVACCESS_VO_TAB_DETAILS",
        preamble = preambleText,
        pickerItems = buildPickerItems(pr),
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        -- Roles and rosters shift between opens (capitulation, liberation,
        -- conquest); rebuild the picker on every show.
        onShow = function(handler)
            handler.setItems(buildPickerItems(pr), 1)
        end,
    })
end

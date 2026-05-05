-- Available-tab item builder for the diplomacy trade screen. Composes
-- the legal placement options for one side at a time: Gold, Gold-per-
-- turn, Resources
-- (luxury / strategic sub-groups), boolean diplo items, Cities,
-- Other Players (Make Peace / Declare War), and Votes. Each leaf
-- queries g_Deal:IsPossibleToTradeItem live; illegal items either
-- surface as "<label>, disabled" with the engine's stated reason
-- (boolean / gold path) or are dropped (Other Players, Votes).
--
-- Shared helpers live on the TradeLogicAccess module (`prefix`,
-- `sidePlayer`, `sideIsUs`, `pocketTooltipFn`, `turnsSuffix`,
-- `dealDuration`, `peaceDuration`, `afterLocalDealChange`,
-- `emptyPlaceholder`). This file only needs them at call time, not at
-- load time, so the orchestrator's include order does not create a
-- circular-load problem.

TradeLogicAvailable = {}

-- Build a "<label>, disabled" pocket leaf whose announcement appends the
-- engine's live tooltip on the corresponding base-game control. Mirrors
-- what sighted players see: the base UI greys the pocket control and
-- sets a SetToolTipString explaining why; we surface the same disabled
-- state and the same reason on first navigation, same as enabled items
-- (whose tooltipFn 4de4407 wired). Takes a pre-composed `label` string
-- so callers can include the duration suffix on items where it's
-- meaningful (the "30 turns" applies whether the item is currently legal
-- or not).
local function disabledPocketLeaf(label, controlName)
    return BaseMenuItems.Text({
        labelText = Text.format("TXT_KEY_CIVVACCESS_LABEL_DISABLED", label),
        tooltipFn = TradeLogicAccess.pocketTooltipFn(controlName),
    })
end

-- ", you have N" / ", they have N" suffix attached to every Available-tab
-- leaf that has a stock count: gold, gold per turn, strategic resources,
-- luxuries. Phrasing the bare number as "you have N" / "they have N"
-- keeps it from being misread as the trade quantity (per CLAUDE.md's
-- "Phrase stock counts as 'you have N'" rule), and the side-aware subject
-- avoids saying "you have 2" when it's actually the AI's stock that the
-- user is browsing on the Their Offer drawer. Returns "" when n is nil so
-- callers can append unconditionally.
local function stockSuffix(side, n)
    if n == nil then
        return ""
    end
    local key = TradeLogicAccess.sideIsUs(side) and "TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"
        or "TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"
    return ", " .. Text.format(key, n)
end

-- BNW gates lump-sum gold trades on a Declaration of Friendship between
-- the two civs (peace deals exempt); the base UI sets
-- TXT_KEY_DIPLO_NEED_DOF_TT_ONE_LINE on the pocket-gold control's tooltip
-- in that state, which disabledPocketLeaf reads live.
local function availableGoldLeaf(side)
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local other = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local pocketControlName = TradeLogicAccess.prefix(side) .. "PocketGold"
    local pPlayer = Players[iPlayer]
    local stock = pPlayer and pPlayer:GetGold() or 0
    local label = Text.key("TXT_KEY_DIPLO_GOLD") .. stockSuffix(side, stock)
    if not g_Deal:IsPossibleToTradeItem(iPlayer, other, TradeableItems.TRADE_ITEM_GOLD, 1) then
        return disabledPocketLeaf(label, pocketControlName)
    end
    return BaseMenuItems.Text({
        labelText = label,
        tooltipFn = TradeLogicAccess.pocketTooltipFn(pocketControlName),
        onActivate = function()
            local maxGold = g_Deal:GetGoldAvailable(iPlayer, -1) or 0
            if maxGold <= 0 then
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"))
                return
            end
            BaseMenuNumberEntry.push({
                promptLabel = Text.key("TXT_KEY_DIPLO_GOLD"),
                maxValue = maxGold,
                onCommit = function(amount)
                    g_Deal:AddGoldTrade(iPlayer, amount)
                    TradeLogicAccess.afterLocalDealChange()
                end,
            })
        end,
    })
end

-- GPT has its own engine-side gate (RefreshPocketLumpGold's
-- IsPossibleToTradeItem check on TRADE_ITEM_GOLD_PER_TURN). The base UI
-- greys the control without setting a tooltip; disabledPocketLeaf handles
-- that path with a silent no-op on Enter.
local function availableGoldPerTurnLeaf(side)
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local other = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local dealDur = TradeLogicAccess.dealDuration()
    local pPlayer = Players[iPlayer]
    -- "PER TURN" lives in the label so "you have 50" reads as 50 gold per
    -- turn, parallel to the offered amount in the Offering tab.
    local rate = pPlayer and pPlayer:CalculateGoldRate() or 0
    local label = Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN")
        .. TradeLogicAccess.turnsSuffix(dealDur)
        .. stockSuffix(side, rate)
    local pocketControlName = TradeLogicAccess.prefix(side) .. "PocketGoldPerTurn"
    if not g_Deal:IsPossibleToTradeItem(iPlayer, other, TradeableItems.TRADE_ITEM_GOLD_PER_TURN, 1, dealDur) then
        return disabledPocketLeaf(label, pocketControlName)
    end
    return BaseMenuItems.Text({
        labelText = label,
        tooltipFn = TradeLogicAccess.pocketTooltipFn(pocketControlName),
        onActivate = function()
            local pPlayer = Players[iPlayer]
            local maxGPT = pPlayer and pPlayer:CalculateGoldRate() or 0
            if maxGPT <= 0 then
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"))
                return
            end
            BaseMenuNumberEntry.push({
                promptLabel = Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN"),
                maxValue = maxGPT,
                onCommit = function(amount)
                    g_Deal:AddGoldPerTurnTrade(iPlayer, amount, TradeLogicAccess.dealDuration())
                    TradeLogicAccess.afterLocalDealChange()
                end,
            })
        end,
    })
end

-- Resource leaf: luxury (one-quantity activate) or strategic (prompt for
-- amount). Shared builder; isStrategic branches on the activation path.
local function availableResourceLeaf(side, resType, resInfo)
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local resName = Text.key(resInfo.Description)
    local pediaName = resName
    local isStrategic = resInfo.ResourceUsage == 1
    local dealDur = TradeLogicAccess.dealDuration()
    local label = resName .. TradeLogicAccess.turnsSuffix(dealDur)
    if not isStrategic then
        -- Append the tradeable copy count so the player knows up-front
        -- whether giving this away costs the only copy (1) or just an
        -- extra. Phrased "you have N" / "they have N" rather than a bare
        -- number so it can't be misread as a trade quantity -- luxuries
        -- are always 1-quantity. Mirrors the engine's "(N)" pocket suffix.
        local qty = g_Deal:GetNumResource(iPlayer, resType) or 0
        local luxuryLabel = resName .. TradeLogicAccess.turnsSuffix(dealDur) .. stockSuffix(side, qty)
        return BaseMenuItems.Text({
            labelText = luxuryLabel,
            pediaName = pediaName,
            onActivate = function()
                -- Luxuries are 1-quantity; engine hardcodes to 1 in
                -- PocketResource handlers.
                g_Deal:AddResourceTrade(iPlayer, resType, 1, TradeLogicAccess.dealDuration())
                TradeLogicAccess.afterLocalDealChange()
            end,
        })
    end
    -- Strategic: prompt for amount, capped at g_Deal:GetNumResource.
    local strategicQty = g_Deal:GetNumResource(iPlayer, resType) or 0
    local strategicLabel = label .. stockSuffix(side, strategicQty)
    return BaseMenuItems.Text({
        labelText = strategicLabel,
        pediaName = pediaName,
        onActivate = function()
            local maxQty = g_Deal:GetNumResource(iPlayer, resType) or 0
            if maxQty <= 0 then
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"))
                return
            end
            BaseMenuNumberEntry.push({
                promptLabel = resName,
                maxValue = maxQty,
                onCommit = function(amount)
                    g_Deal:AddResourceTrade(iPlayer, resType, amount, TradeLogicAccess.dealDuration())
                    TradeLogicAccess.afterLocalDealChange()
                end,
            })
        end,
    })
end

-- Boolean diplomacy leaf (Embassy / Open Borders / DP / RA / TA / DoF).
-- Legality is re-queried live via IsPossibleToTradeItem; when illegal we
-- surface the same "<label>, disabled" leaf the gold path uses, with the
-- engine's per-side / per-state tooltip read live from the matching base
-- control on Enter (each boolean's RefreshPocket handler builds its own
-- contextual tooltip in TradeLogic.lua, e.g. "no tech" / "they already
-- have one"). controlSuffix is the base-control name without the Us /
-- Them prefix (e.g. "PocketAllowEmbassy").
local function availableBooleanLeaf(side, labelKey, itemConstant, controlSuffix, addFn, bothSides)
    if itemConstant == nil then
        return nil
    end
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    -- Legality for boolean items all follow the same 4-arg signature
    -- IsPossibleToTradeItem(from, to, type, duration) (matching TradeLogic's
    -- RefreshPocketEmbassy / OpenBorders / DP / RA / TA / DoF handlers).
    local dealDur = TradeLogicAccess.dealDuration()
    local label = Text.key(labelKey) .. TradeLogicAccess.turnsSuffix(dealDur)
    local pocketControlName = TradeLogicAccess.prefix(side) .. controlSuffix
    if not g_Deal:IsPossibleToTradeItem(iPlayer, otherPlayer, itemConstant, dealDur) then
        return disabledPocketLeaf(label, pocketControlName)
    end
    -- Engine's RefreshPocket{Embassy,OpenBorders,DefensivePact,
    -- ResearchAgreement,TradeAgreement,DoF} sets a contextual tooltip on the
    -- pocket control in both enabled and disabled states. Read live so the
    -- announce reflects whatever the engine last computed.
    return BaseMenuItems.Text({
        labelText = label,
        tooltipFn = TradeLogicAccess.pocketTooltipFn(pocketControlName),
        onActivate = function()
            if bothSides then
                addFn(g_iUs)
                addFn(g_iThem)
            else
                addFn(iPlayer)
            end
            TradeLogicAccess.afterLocalDealChange()
        end,
    })
end

-- Resources group: Luxury and Strategic as separate sub-groups. Iterate
-- GameInfo.Resources once, filter by legality, partition into the two
-- buckets. g_Deal:IsPossibleToTradeItem does the per-resource legality
-- check the engine uses in RefreshPocketResources.
local function availableResourceGroups(side)
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local luxuries = {}
    local strategics = {}
    for row in GameInfo.Resources() do
        local resType = row.ID
        if row.ResourceUsage == 1 or row.ResourceUsage == 2 then
            if g_Deal:IsPossibleToTradeItem(iPlayer, otherPlayer, TradeableItems.TRADE_ITEM_RESOURCES, resType, 1) then
                local item = availableResourceLeaf(side, resType, row)
                if row.ResourceUsage == 1 then
                    strategics[#strategics + 1] = item
                else
                    luxuries[#luxuries + 1] = item
                end
            end
        end
    end
    -- Engine sets per-side / per-state tooltips on Us/ThemPocketLuxury and
    -- Us/ThemPocketStrategic in RefreshPocketLuxury / RefreshPocketStrategic
    -- ("can be traded" / "no luxuries available", etc.). Surface the parent
    -- pocket's live tooltip on the group label so the user hears the same
    -- summary sighted players read on hover.
    local p = TradeLogicAccess.prefix(side)
    local groups = {}
    if #luxuries > 0 then
        groups[#groups + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_TRADE_ITEM_LUXURY_RESOURCES"),
            tooltipFn = TradeLogicAccess.pocketTooltipFn(p .. "PocketLuxury"),
            items = luxuries,
        })
    end
    if #strategics > 0 then
        groups[#groups + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_TRADE_ITEM_STRATEGIC_RESOURCES"),
            tooltipFn = TradeLogicAccess.pocketTooltipFn(p .. "PocketStrategic"),
            items = strategics,
        })
    end
    return groups
end

-- Votes group: one leaf per (proposal, voter choice, enact/repeal) entry
-- in g_LeagueVoteList. The list is flattened by UpdateLeagueVotes at
-- display time; here we re-run it so we see current state, then filter by
-- legality.
local function availableVotesGroup(side)
    if type(UpdateLeagueVotes) == "function" then
        local ok, err = pcall(UpdateLeagueVotes)
        if not ok then
            Log.error("TradeLogicAvailable UpdateLeagueVotes failed: " .. tostring(err))
        end
    end
    if g_LeagueVoteList == nil or #g_LeagueVoteList == 0 then
        return nil
    end
    local pLeague
    if Game.GetNumActiveLeagues and Game.GetNumActiveLeagues() > 0 then
        pLeague = Game.GetActiveLeague()
    end
    if pLeague == nil then
        return nil
    end
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local items = {}
    for i, tVote in ipairs(g_LeagueVoteList) do
        local iNumVotes = pLeague:GetCoreVotesForMember(iPlayer)
        if
            iNumVotes > 0
            and g_Deal:IsPossibleToTradeItem(
                iPlayer,
                otherPlayer,
                TradeableItems.TRADE_ITEM_VOTE_COMMITMENT,
                tVote.ID,
                tVote.VoteChoice,
                iNumVotes,
                tVote.Repeal
            )
        then
            local proposal = GetVoteText(pLeague, i, tVote.Repeal, tVote.ProposerChoice)
            local choice = pLeague:GetTextForChoice(tVote.VoteDecision, tVote.VoteChoice)
            local label = tostring(proposal) .. ", " .. tostring(choice)
            local id, voteChoice, repeal = tVote.ID, tVote.VoteChoice, tVote.Repeal
            -- Mirror RefreshPocketVotes: GetVoteTooltip(pLeague, i, repeal,
            -- iNumVotes) is the same call the engine makes when populating
            -- cInstance.Button's tooltip on each pocket vote row.
            local capturedIndex = i
            local capturedRepeal = repeal
            local capturedNumVotes = iNumVotes
            items[#items + 1] = BaseMenuItems.Text({
                labelText = label,
                tooltipFn = function()
                    if Game.GetNumActiveLeagues == nil or Game.GetNumActiveLeagues() == 0 then
                        return nil
                    end
                    local pL = Game.GetActiveLeague()
                    if pL == nil or type(GetVoteTooltip) ~= "function" then
                        return nil
                    end
                    return GetVoteTooltip(pL, capturedIndex, capturedRepeal, capturedNumVotes)
                end,
                onActivate = function()
                    g_Deal:AddVoteCommitment(iPlayer, id, voteChoice, iNumVotes, repeal)
                    TradeLogicAccess.afterLocalDealChange()
                end,
            })
        end
    end
    if #items == 0 then
        return nil
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_TRADE_ITEM_VOTES"),
        tooltipFn = TradeLogicAccess.pocketTooltipFn(TradeLogicAccess.prefix(side) .. "PocketVote"),
        items = items,
    })
end

-- Cities group: enumerate this side's cities, filter by legality.
local function availableCitiesGroup(side)
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local pPlayer = Players[iPlayer]
    if pPlayer == nil then
        return nil
    end
    local items = {}
    for pCity in pPlayer:Cities() do
        if
            g_Deal:IsPossibleToTradeItem(
                iPlayer,
                otherPlayer,
                TradeableItems.TRADE_ITEM_CITIES,
                pCity:GetX(),
                pCity:GetY()
            )
        then
            local name = pCity:GetName()
            local pop = pCity:GetPopulation()
            local cityID = pCity:GetID()
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format("TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING", name, tostring(pop)),
                onActivate = function()
                    g_Deal:AddCityTrade(iPlayer, cityID)
                    TradeLogicAccess.afterLocalDealChange()
                end,
            })
        end
    end
    if #items == 0 then
        return nil
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_DIPLO_CITIES"),
        tooltipFn = TradeLogicAccess.pocketTooltipFn(TradeLogicAccess.prefix(side) .. "PocketCities"),
        items = items,
    })
end

-- Other players group: Make Peace With <civ> and Declare War On <civ> for
-- each legal target. Iterates major civs the active team has met. Civs
-- where the action would be illegal are dropped rather than surfaced as
-- disabled-with-reason: the most common reason ("Not at war") would force
-- the user to walk past every peaceful civ when looking for a war target,
-- and the engine's own peace/war chooser only earns its keep visually -- a
-- list-only reader gains nothing from a long list of "disabled, not at
-- war" entries.
local function availableOtherPlayersGroup(side)
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local makePeace = {}
    local declareWar = {}
    local maxCivs = (GameDefines.MAX_CIV_PLAYERS or 64)
    for i = 0, maxCivs - 1 do
        local pl = Players[i]
        if pl ~= nil and pl:IsEverAlive() and not pl:IsBarbarian() and i ~= iPlayer and i ~= otherPlayer then
            local theirTeam = pl:GetTeam()
            local name = pl:GetName()
            local leaderInfo = GameInfo.Leaders[pl:GetLeaderType()]
            local pediaName = leaderInfo and Text.key(leaderInfo.Description) or nil
            if
                g_Deal:IsPossibleToTradeItem(
                    iPlayer,
                    otherPlayer,
                    TradeableItems.TRADE_ITEM_THIRD_PARTY_PEACE,
                    theirTeam
                )
            then
                local capturedTeam = theirTeam
                makePeace[#makePeace + 1] = BaseMenuItems.Text({
                    labelText = name,
                    pediaName = pediaName,
                    onActivate = function()
                        g_Deal:AddThirdPartyPeace(iPlayer, capturedTeam, TradeLogicAccess.peaceDuration())
                        TradeLogicAccess.afterLocalDealChange()
                    end,
                })
            end
            if
                g_Deal:IsPossibleToTradeItem(iPlayer, otherPlayer, TradeableItems.TRADE_ITEM_THIRD_PARTY_WAR, theirTeam)
            then
                local capturedTeam = theirTeam
                declareWar[#declareWar + 1] = BaseMenuItems.Text({
                    labelText = name,
                    pediaName = pediaName,
                    onActivate = function()
                        g_Deal:AddThirdPartyWar(iPlayer, capturedTeam)
                        TradeLogicAccess.afterLocalDealChange()
                    end,
                })
            end
        end
    end
    if #makePeace == 0 and #declareWar == 0 then
        return nil
    end
    local subs = {}
    if #makePeace > 0 then
        subs[#subs + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"),
            items = makePeace,
        })
    end
    if #declareWar > 0 then
        subs[#subs + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"),
            items = declareWar,
        })
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"),
        tooltipFn = TradeLogicAccess.pocketTooltipFn(TradeLogicAccess.prefix(side) .. "PocketOtherPlayer"),
        items = subs,
    })
end

function TradeLogicAvailable.buildAvailableItems(side)
    if g_Deal == nil or TradeableItems == nil then
        return { TradeLogicAccess.emptyPlaceholder("TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE") }
    end
    local items = {}
    -- Gold + GPT as flat leaves at the top of the list.
    items[#items + 1] = availableGoldLeaf(side)
    items[#items + 1] = availableGoldPerTurnLeaf(side)

    -- Resources group (luxury / strategic sub-groups).
    for _, g in ipairs(availableResourceGroups(side)) do
        items[#items + 1] = g
    end

    -- Boolean diplomatic items, in the plan's order. controlSuffix is the
    -- engine pocket-control name without Us / Them prefix; when the leaf
    -- is disabled we read that control's tooltip live so the user hears
    -- the engine's stated reason.
    local function addBoolean(key, constant, controlSuffix, addFn, bothSides)
        local it = availableBooleanLeaf(side, key, constant, controlSuffix, addFn, bothSides)
        if it ~= nil then
            items[#items + 1] = it
        end
    end
    addBoolean("TXT_KEY_DIPLO_ALLOW_EMBASSY", TradeableItems.TRADE_ITEM_ALLOW_EMBASSY, "PocketAllowEmbassy", function(p)
        g_Deal:AddAllowEmbassy(p)
    end, false)
    addBoolean("TXT_KEY_DIPLO_OPEN_BORDERS", TradeableItems.TRADE_ITEM_OPEN_BORDERS, "PocketOpenBorders", function(p)
        g_Deal:AddOpenBorders(p, TradeLogicAccess.dealDuration())
    end, false)
    addBoolean("TXT_KEY_DIPLO_DEF_PACT", TradeableItems.TRADE_ITEM_DEFENSIVE_PACT, "PocketDefensivePact", function(p)
        g_Deal:AddDefensivePact(p, TradeLogicAccess.dealDuration())
    end, true)
    addBoolean(
        "TXT_KEY_DIPLO_RESCH_AGREEMENT",
        TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT,
        "PocketResearchAgreement",
        function(p)
            g_Deal:AddResearchAgreement(p, TradeLogicAccess.dealDuration())
        end,
        true
    )
    addBoolean(
        "TXT_KEY_DIPLO_TRADE_AGREEMENT",
        TradeableItems.TRADE_ITEM_TRADE_AGREEMENT,
        "PocketTradeAgreement",
        function(p)
            g_Deal:AddTradeAgreement(p, TradeLogicAccess.dealDuration())
        end,
        false
    )

    -- Cities.
    local cities = availableCitiesGroup(side)
    if cities ~= nil then
        items[#items + 1] = cities
    end

    -- Other Players (Make Peace / Declare War).
    local others = availableOtherPlayersGroup(side)
    if others ~= nil then
        items[#items + 1] = others
    end

    -- Votes.
    local votes = availableVotesGroup(side)
    if votes ~= nil then
        items[#items + 1] = votes
    end

    return items
end

return TradeLogicAvailable

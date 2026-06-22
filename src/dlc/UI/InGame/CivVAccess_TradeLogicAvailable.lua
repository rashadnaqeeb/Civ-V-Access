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

-- Already-placed suppression -------------------------------------------------
--
-- The base / VP mouse UI hides a pocket control the moment its item lands on
-- the deal table (DisplayDeal: gold / GPT / resources / booleans / cities /
-- votes all SetHide(true) their pocket on placement), so a sighted player can
-- never place the same item twice. Our Available list is rebuilt from
-- g_Deal:IsPossibleToTradeItem instead, and that engine gate does NOT consider
-- pending deal contents -- it reports an item tradeable even after it's already
-- on the table. Without mirroring the pocket-hide, an already-placed item stays
-- offered, and re-activating it makes the engine push a duplicate entry: every
-- boolean (e.g. Allow Embassy) gets scored again by the AI valuation, and a
-- duplicate resource entry collides in DisplayDeal's per-resource table render
-- and crashes the game. collectPlacedKeys walks g_Deal once per side and the
-- Available builders skip any item whose key is already placed.

-- Normalize a vote "repeal" flag to "1" / "0". The placed-side value comes
-- from g_Deal:GetNextItem (flag1) and the available-side value from
-- g_LeagueVoteList (tVote.Repeal); one may be a boolean and the other a 0/1
-- number, and Lua treats numeric 0 as truthy, so a bare `x and 1 or 0` would
-- collapse both to 1. Compare against the true tokens explicitly so both
-- representations key the same way.
local function repealFlag(x)
    return (x == true or x == 1) and "1" or "0"
end

-- True iff `itemType` equals the engine constant named `name`, guarding the
-- nil constants that don't exist on the active engine (MAPS / TECHS /
-- VASSALAGE are Community Patch additions, absent on vanilla).
local function isType(itemType, name)
    local constant = TradeableItems[name]
    return constant ~= nil and itemType == constant
end

-- Map a placed deal entry to a stable key the matching Available builder can
-- reproduce. Multi-instance types (resources, techs, cities, third-party,
-- votes) key by their distinguishing data so only the exact placed entry is
-- suppressed; single-flag booleans key by the item constant. Returns nil for
-- types we don't surface in Available (e.g. peace treaty), which never match.
local function placedKey(itemType, data1, data2, flag1)
    if isType(itemType, "TRADE_ITEM_GOLD") then
        return "gold"
    elseif isType(itemType, "TRADE_ITEM_GOLD_PER_TURN") then
        return "gpt"
    elseif isType(itemType, "TRADE_ITEM_RESOURCES") then
        return "res:" .. tostring(data1)
    elseif isType(itemType, "TRADE_ITEM_TECHS") then
        return "tech:" .. tostring(data1)
    elseif isType(itemType, "TRADE_ITEM_CITIES") then
        return "city:" .. tostring(data1) .. "," .. tostring(data2)
    elseif isType(itemType, "TRADE_ITEM_THIRD_PARTY_PEACE") then
        return "tpp:" .. tostring(data1)
    elseif isType(itemType, "TRADE_ITEM_THIRD_PARTY_WAR") then
        return "tpw:" .. tostring(data1)
    elseif isType(itemType, "TRADE_ITEM_VOTE_COMMITMENT") then
        return "vote:" .. tostring(data1) .. ":" .. tostring(data2) .. ":" .. repealFlag(flag1)
    end
    local booleans = {
        "TRADE_ITEM_ALLOW_EMBASSY",
        "TRADE_ITEM_OPEN_BORDERS",
        "TRADE_ITEM_DEFENSIVE_PACT",
        "TRADE_ITEM_RESEARCH_AGREEMENT",
        "TRADE_ITEM_DECLARATION_OF_FRIENDSHIP",
        "TRADE_ITEM_TRADE_AGREEMENT",
        "TRADE_ITEM_MAPS",
        "TRADE_ITEM_VASSALAGE",
        "TRADE_ITEM_VASSALAGE_REVOKE",
    }
    for _, name in ipairs(booleans) do
        if isType(itemType, name) then
            return "type:" .. tostring(itemType)
        end
    end
    return nil
end

-- Set of placed-item keys contributed by `side` (mirrors the side filter the
-- Offering builder uses: an entry belongs to us when its fromPlayer is the
-- active player). Re-iterates g_Deal live every build; no caching.
local function collectPlacedKeys(side)
    local placed = {}
    if g_Deal == nil or TradeableItems == nil then
        return placed
    end
    local bFromUs = TradeLogicAccess.sideIsUs(side)
    local active = Game and Game.GetActivePlayer and Game.GetActivePlayer() or 0
    g_Deal:ResetIterator()
    local itemType, _, _, data1, data2, _, flag1, fromPlayer = g_Deal:GetNextItem()
    while itemType ~= nil do
        if (fromPlayer == active) == bFromUs then
            local key = placedKey(itemType, data1, data2, flag1)
            if key ~= nil then
                placed[key] = true
            end
        end
        itemType, _, _, data1, data2, _, flag1, fromPlayer = g_Deal:GetNextItem()
    end
    return placed
end

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

-- BNW gates lump-sum gold trades on a Declaration of Friendship between
-- the two civs (peace deals exempt); the base UI sets
-- TXT_KEY_DIPLO_NEED_DOF_TT_ONE_LINE on the pocket-gold control's tooltip
-- in that state, which disabledPocketLeaf reads live.
local function availableGoldLeaf(side, placed)
    if placed["gold"] then
        return nil
    end
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local other = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local pocketControlName = TradeLogicAccess.prefix(side) .. "PocketGold"
    local pPlayer = Players[iPlayer]
    local stock = pPlayer and pPlayer:GetGold() or 0
    local label = Text.key("TXT_KEY_DIPLO_GOLD") .. TradeLogicAccess.stockSuffix(side, stock)
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
local function availableGoldPerTurnLeaf(side, placed)
    if placed["gpt"] then
        return nil
    end
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local other = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local dealDur = TradeLogicAccess.dealDuration()
    local pPlayer = Players[iPlayer]
    -- "PER TURN" lives in the label so "you have 50" reads as 50 gold per
    -- turn, parallel to the offered amount in the Offering tab.
    local rate = pPlayer and pPlayer:CalculateGoldRate() or 0
    local label = Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN")
        .. TradeLogicAccess.turnsSuffix(dealDur)
        .. TradeLogicAccess.stockSuffix(side, rate)
    local pocketControlName = TradeLogicAccess.prefix(side) .. "PocketGoldPerTurn"
    if not g_Deal:IsPossibleToTradeItem(iPlayer, other, TradeableItems.TRADE_ITEM_GOLD_PER_TURN, 1, dealDur) then
        return disabledPocketLeaf(label, pocketControlName)
    end
    return BaseMenuItems.Text({
        labelText = label,
        tooltipFn = TradeLogicAccess.pocketTooltipFn(pocketControlName),
        onActivate = function()
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
        local qty = EngineData.dealResourceCount(g_Deal, iPlayer, resType) or 0
        local luxuryLabel = resName .. TradeLogicAccess.turnsSuffix(dealDur) .. TradeLogicAccess.stockSuffix(side, qty)
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
    local strategicQty = EngineData.dealResourceCount(g_Deal, iPlayer, resType) or 0
    local strategicLabel = label .. TradeLogicAccess.stockSuffix(side, strategicQty)
    return BaseMenuItems.Text({
        labelText = strategicLabel,
        pediaName = pediaName,
        onActivate = function()
            local maxQty = EngineData.dealResourceCount(g_Deal, iPlayer, resType) or 0
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
local function availableBooleanLeaf(side, placed, labelKey, itemConstant, controlSuffix, addFn, bothSides, turnTimed)
    if itemConstant == nil then
        return nil
    end
    if placed["type:" .. itemConstant] then
        return nil
    end
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    -- Legality for boolean items all follow the same 4-arg signature
    -- IsPossibleToTradeItem(from, to, type, duration) (matching TradeLogic's
    -- RefreshPocketEmbassy / OpenBorders / DP / RA / TA / DoF handlers).
    local dealDur = TradeLogicAccess.dealDuration()
    -- Embassy is permanent and DoF's duration is engine-defined (not deal-
    -- duration), so those callers pass turnTimed=false to suppress the
    -- suffix. OB/DP/RA expire with the deal duration and keep it.
    local labelDur = turnTimed and dealDur or nil
    local label = Text.key(labelKey) .. TradeLogicAccess.turnsSuffix(labelDur)
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

-- An owned resource that can't currently be traded, surfaced as a disabled
-- leaf with the engine's stated reason -- mirroring the greyed pocket entry
-- LekMod shows (vanilla / VP drop these instead, gated by a nil reason in the
-- seam). Label carries the stock count like the enabled leaf.
local function disabledResourceLeaf(side, row, reason, qty)
    local label = Text.key(row.Description) .. TradeLogicAccess.stockSuffix(side, qty)
    return BaseMenuItems.Text({
        labelText = Text.format("TXT_KEY_CIVVACCESS_LABEL_DISABLED", label),
        tooltipText = reason,
        pediaName = Text.key(row.Description),
    })
end

-- Resources group: Luxury and Strategic as separate sub-groups. Iterate
-- GameInfo.Resources once, filter by legality, partition into the two
-- buckets. g_Deal:IsPossibleToTradeItem does the per-resource legality
-- check the engine uses in RefreshPocketResources.
local function availableResourceGroups(side, placed)
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local luxuries = {}
    local strategics = {}
    for row in GameInfo.Resources() do
        local resType = row.ID
        if (row.ResourceUsage == 1 or row.ResourceUsage == 2) and not placed["res:" .. resType] then
            local item
            if g_Deal:IsPossibleToTradeItem(iPlayer, otherPlayer, TradeableItems.TRADE_ITEM_RESOURCES, resType, 1) then
                item = availableResourceLeaf(side, resType, row)
            else
                -- Owned but untradeable: LekMod greys it with a reason (partner
                -- already owns the luxury, embargo, unresearched strategic).
                -- nil reason on vanilla / VP keeps the old drop-it behavior.
                local qty = EngineData.dealResourceCount(g_Deal, iPlayer, resType) or 0
                if qty > 0 then
                    local reasonKey, reasonArg =
                        EngineData.resourceTradeBlockedReason(g_Deal, iPlayer, otherPlayer, row)
                    if reasonKey ~= nil then
                        local reason = reasonArg and Text.format(reasonKey, reasonArg) or Text.key(reasonKey)
                        item = disabledResourceLeaf(side, row, reason, qty)
                    end
                end
            end
            if item ~= nil then
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

-- Technologies group (Community Patch tech trading). Mirrors the resource
-- groups: per-tech legality via IsPossibleToTradeItem, omitted when no
-- tech is currently tradeable. Per-tech tooltip mirrors RefreshPocketTechs
-- (GetShortHelpTextForTech, a CP vendor global). Gated on the CP-only
-- pocket stack control so engines without tech trading never build it.
local function availableTechsGroup(side, placed)
    local pfx = TradeLogicAccess.prefix(side)
    if Controls[pfx .. "PocketTechnologyStack"] == nil or TradeableItems.TRADE_ITEM_TECHS == nil then
        return nil
    end
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local items = {}
    for row in GameInfo.Technologies() do
        local techID = row.ID
        if
            not placed["tech:" .. techID]
            and g_Deal:IsPossibleToTradeItem(iPlayer, otherPlayer, TradeableItems.TRADE_ITEM_TECHS, techID)
        then
            local label = Text.key(row.Description)
            items[#items + 1] = BaseMenuItems.Text({
                labelText = label,
                pediaName = label,
                tooltipFn = function()
                    if type(GetShortHelpTextForTech) ~= "function" then
                        return nil
                    end
                    return GetShortHelpTextForTech(techID, false)
                end,
                onActivate = function()
                    g_Deal:AddTechTrade(iPlayer, techID)
                    TradeLogicAccess.afterLocalDealChange()
                end,
            })
        end
    end
    if #items == 0 then
        return nil
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_DIPLO_ITEMS_TECHNOLOGIES"),
        tooltipFn = TradeLogicAccess.pocketTooltipFn(pfx .. "PocketTechnology"),
        items = items,
    })
end

-- Votes group: one leaf per (proposal, voter choice, enact/repeal) entry
-- in g_LeagueVoteList. The list is flattened by UpdateLeagueVotes at
-- display time; here we re-run it so we see current state, then filter by
-- legality.
local function availableVotesGroup(side, placed)
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
            and not placed["vote:" .. tVote.ID .. ":" .. tVote.VoteChoice .. ":" .. repealFlag(tVote.Repeal)]
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
local function availableCitiesGroup(side, placed)
    local iPlayer = TradeLogicAccess.sidePlayer(side)
    local otherPlayer = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
    local pPlayer = Players[iPlayer]
    if pPlayer == nil then
        return nil
    end
    local items = {}
    for pCity in pPlayer:Cities() do
        if
            not placed["city:" .. pCity:GetX() .. "," .. pCity:GetY()]
            and g_Deal:IsPossibleToTradeItem(
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
local function availableOtherPlayersGroup(side, placed)
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
                not placed["tpp:" .. theirTeam]
                and g_Deal:IsPossibleToTradeItem(
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
                not placed["tpw:" .. theirTeam]
                and g_Deal:IsPossibleToTradeItem(
                    iPlayer,
                    otherPlayer,
                    TradeableItems.TRADE_ITEM_THIRD_PARTY_WAR,
                    theirTeam
                )
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
    -- Items already on the deal table for this side are hidden from Available,
    -- mirroring the base UI's pocket-hide on placement. See collectPlacedKeys.
    local placed = collectPlacedKeys(side)
    local items = {}
    -- Gold + GPT as flat leaves at the top of the list.
    local gold = availableGoldLeaf(side, placed)
    if gold ~= nil then
        items[#items + 1] = gold
    end
    local gpt = availableGoldPerTurnLeaf(side, placed)
    if gpt ~= nil then
        items[#items + 1] = gpt
    end

    -- Resources group (luxury / strategic sub-groups).
    for _, g in ipairs(availableResourceGroups(side, placed)) do
        items[#items + 1] = g
    end

    -- Technologies (Community Patch; nil on engines without tech trading).
    local techs = availableTechsGroup(side, placed)
    if techs ~= nil then
        items[#items + 1] = techs
    end

    -- Boolean diplomatic items, in the plan's order. controlSuffix is the
    -- engine pocket-control name without Us / Them prefix; when the leaf
    -- is disabled we read that control's tooltip live so the user hears
    -- the engine's stated reason.
    local function addBoolean(key, constant, controlSuffix, addFn, bothSides, turnTimed)
        local it = availableBooleanLeaf(side, placed, key, constant, controlSuffix, addFn, bothSides, turnTimed)
        if it ~= nil then
            items[#items + 1] = it
        end
    end
    -- World map (Community Patch; the control only exists there). Sits
    -- before Embassy, matching CP's pocket-stack order.
    local pfx = TradeLogicAccess.prefix(side)
    if Controls[pfx .. "PocketTradeMap"] ~= nil then
        addBoolean("TXT_KEY_DIPLO_TRADE_MAP", TradeableItems.TRADE_ITEM_MAPS, "PocketTradeMap", function(p)
            g_Deal:AddMapTrade(p)
        end, false, false)
    end
    addBoolean("TXT_KEY_DIPLO_ALLOW_EMBASSY", TradeableItems.TRADE_ITEM_ALLOW_EMBASSY, "PocketAllowEmbassy", function(p)
        g_Deal:AddAllowEmbassy(p)
    end, false, false)
    addBoolean("TXT_KEY_DIPLO_OPEN_BORDERS", TradeableItems.TRADE_ITEM_OPEN_BORDERS, "PocketOpenBorders", function(p)
        g_Deal:AddOpenBorders(p, TradeLogicAccess.dealDuration())
    end, false, true)
    addBoolean("TXT_KEY_DIPLO_DEF_PACT", TradeableItems.TRADE_ITEM_DEFENSIVE_PACT, "PocketDefensivePact", function(p)
        g_Deal:AddDefensivePact(p, TradeLogicAccess.dealDuration())
    end, true, true)
    addBoolean(
        "TXT_KEY_DIPLO_RESCH_AGREEMENT",
        TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT,
        "PocketResearchAgreement",
        function(p)
            g_Deal:AddResearchAgreement(p, TradeLogicAccess.dealDuration())
        end,
        true,
        true
    )
    -- Vassalage pair (Community Patch; the controls only exist there).
    -- CP's pocket handlers keep each one-sided: adding for one side clears
    -- any entry the other side had.
    if Controls[pfx .. "PocketVassalage"] ~= nil then
        addBoolean("TXT_KEY_DIPLO_VASSALAGE", TradeableItems.TRADE_ITEM_VASSALAGE, "PocketVassalage", function(p)
            g_Deal:AddVassalageTrade(p)
            local other = p == g_iUs and g_iThem or g_iUs
            g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_VASSALAGE, other)
        end, false, false)
    end
    if Controls[pfx .. "PocketRevokeVassalage"] ~= nil then
        addBoolean(
            "TXT_KEY_DIPLO_VASSALAGE_REVOKE",
            TradeableItems.TRADE_ITEM_VASSALAGE_REVOKE,
            "PocketRevokeVassalage",
            function(p)
                g_Deal:AddRevokeVassalageTrade(p)
                local other = p == g_iUs and g_iThem or g_iUs
                g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_VASSALAGE_REVOKE, other)
            end,
            false,
            false
        )
    end
    -- Engine TradeLogic.lua only un-hides UsPocketDoF when g_bPVPTrade is
    -- true (AI has its own dedicated DoF interface). IsPossibleToTradeItem
    -- doesn't filter on PvP-ness for us, so gate on both-sides-human.
    if Players[g_iUs]:IsHuman() and Players[g_iThem]:IsHuman() then
        addBoolean(
            "TXT_KEY_DIPLO_DECLARATION_OF_FRIENDSHIP",
            TradeableItems.TRADE_ITEM_DECLARATION_OF_FRIENDSHIP,
            "PocketDoF",
            function(p)
                g_Deal:AddDeclarationOfFriendship(p)
            end,
            true,
            false
        )
    end

    -- Cities.
    local cities = availableCitiesGroup(side, placed)
    if cities ~= nil then
        items[#items + 1] = cities
    end

    -- Other Players (Make Peace / Declare War).
    local others = availableOtherPlayersGroup(side, placed)
    if others ~= nil then
        items[#items + 1] = others
    end

    -- Votes.
    local votes = availableVotesGroup(side, placed)
    if votes ~= nil then
        items[#items + 1] = votes
    end

    return items
end

return TradeLogicAvailable

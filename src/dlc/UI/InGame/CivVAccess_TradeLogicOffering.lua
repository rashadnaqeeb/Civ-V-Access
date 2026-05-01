-- Offering-tab item builder for the diplomacy trade screen, peeled out
-- of CivVAccess_TradeLogicAccess.lua. Walks the live g_Deal and emits
-- one BaseMenu item per placed entry on the side requested. Read-only
-- branch (AI demand / request / offer, or g_bTradeReview) drops the
-- onActivate paths so items announce but cannot be removed.
--
-- Shared helpers live on the TradeLogicAccess module (`prefix`,
-- `sidePlayer`, `sideIsUs`, `pocketTooltipFn`, `turnsSuffix`,
-- `clearEngineTable`, `afterLocalDealChange`, `emptyPlaceholder`).
-- This file only needs them at call time, not at load time, so the
-- orchestrator's include order (orchestrator includes this file before
-- defining the helpers) does not create a circular-load problem.

TradeLogicOffering = {}

-- Build a single Offering-tab item for one entry type. Returns nil if
-- the item type isn't one we surface. Forward-declared so
-- buildOfferingItems below can reference it; the assignment happens at
-- the end of this file.
local offeringItem

function TradeLogicOffering.buildOfferingItems(side, readOnly)
    local items = {}
    if g_Deal == nil then
        items[#items + 1] = TradeLogicAccess.emptyPlaceholder("TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY")
        return items
    end
    local bFromUs = TradeLogicAccess.sideIsUs(side)

    g_Deal:ResetIterator()
    -- 8-tuple: itemType, duration, finalTurn, data1, data2, data3, flag1,
    -- fromPlayer. finalTurn is an engine-computed expiry we don't read;
    -- data3 is load-bearing for votes (proposer choice) so it's captured.
    local itemType, duration, _, data1, data2, data3, flag1, fromPlayer = g_Deal:GetNextItem()
    if itemType ~= nil then
        repeat
            -- Only show items contributed by this side.
            local active = Game and Game.GetActivePlayer and Game.GetActivePlayer() or 0
            local entryFromUs = fromPlayer == active
            if entryFromUs == bFromUs then
                local item = offeringItem(itemType, data1, data2, data3, flag1, duration, side, readOnly)
                if item ~= nil then
                    items[#items + 1] = item
                end
            end
            itemType, duration, _, data1, data2, data3, flag1, fromPlayer = g_Deal:GetNextItem()
        until itemType == nil
    end

    if #items == 0 then
        items[#items + 1] = TradeLogicAccess.emptyPlaceholder("TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY")
    end
    return items
end

offeringItem = function(itemType, data1, data2, data3, flag1, duration, side, readOnly)
    local p = TradeLogicAccess.prefix(side)
    local iPlayer = TradeLogicAccess.sidePlayer(side)

    if itemType == TradeableItems.TRADE_ITEM_PEACE_TREATY then
        -- Non-activatable: engine forbids removal. Text re-announces on
        -- Enter by default.
        return BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_DIPLO_PEACE_TREATY", duration or 0),
        })
    end

    if itemType == TradeableItems.TRADE_ITEM_GOLD then
        local editName = p .. "GoldAmount"
        local control = Controls[editName]
        local goldTooltipFn = TradeLogicAccess.pocketTooltipFn(p .. "TableGold")
        if control == nil or readOnly then
            -- Read-only drawer or missing EditBox (unlikely): fall through
            -- to a plain Text item showing label + amount.
            return BaseMenuItems.Text({
                labelText = Text.format(
                    "TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT",
                    Text.key("TXT_KEY_DIPLO_GOLD"),
                    data1 or 0
                ),
                tooltipFn = goldTooltipFn,
            })
        end
        return BaseMenuItems.Textfield({
            controlName = editName,
            labelText = Text.key("TXT_KEY_DIPLO_GOLD"),
            tooltipFn = goldTooltipFn,
            -- Engine ChangeGoldTrade(0) keeps a 0-amount entry in the
            -- deal; for accessibility we treat 0 / empty on Enter as
            -- "remove" so the user can clear an offer without hunting
            -- for the engine's separate UsTableGold remove button.
            priorCallback = function(text, ctrl, isEnter)
                if isEnter then
                    local n = tonumber(text)
                    if n == nil or n == 0 then
                        g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_GOLD, iPlayer)
                        TradeLogicAccess.afterLocalDealChange()
                        return
                    end
                end
                ChangeGoldAmount(text, ctrl, isEnter)
            end,
        })
    end

    if itemType == TradeableItems.TRADE_ITEM_GOLD_PER_TURN then
        local editName = p .. "GoldPerTurnAmount"
        local control = Controls[editName]
        local gptTooltipFn = TradeLogicAccess.pocketTooltipFn(p .. "TableGoldPerTurn")
        if control == nil or readOnly then
            return BaseMenuItems.Text({
                labelText = Text.format(
                    "TXT_KEY_CIVVACCESS_DIPLO_GOLD_PER_TURN_LINE",
                    Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN"),
                    data1 or 0,
                    Text.format("TXT_KEY_DIPLO_TURNS", duration or 0)
                ),
                tooltipFn = gptTooltipFn,
            })
        end
        return BaseMenuItems.Textfield({
            controlName = editName,
            labelText = Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN") .. TradeLogicAccess.turnsSuffix(duration),
            tooltipFn = gptTooltipFn,
            priorCallback = function(text, ctrl, isEnter)
                if isEnter then
                    local n = tonumber(text)
                    if n == nil or n == 0 then
                        g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_GOLD_PER_TURN, iPlayer)
                        TradeLogicAccess.afterLocalDealChange()
                        return
                    end
                end
                ChangeGoldPerTurnAmount(text, ctrl, isEnter)
            end,
        })
    end

    if itemType == TradeableItems.TRADE_ITEM_RESOURCES then
        local resInfo = GameInfo.Resources[data1]
        local resName = resInfo and Text.key(resInfo.Description) or "?"
        local pediaName = resInfo and Text.key(resInfo.Description) or nil
        local isStrategic = resInfo and resInfo.ResourceUsage == 1
        if isStrategic and not readOnly then
            -- Strategic amount is editable via an IM-built AmountEdit on
            -- the live instance. Reach it directly rather than via
            -- Controls[name] which doesn't index IM children.
            local tbl = TradeLogicAccess.sideIsUs(side) and g_UsTableResources or g_ThemTableResources
            local inst = tbl and tbl[data1]
            local editBox = inst and inst.AmountEdit
            if editBox ~= nil then
                local rType = data1
                return BaseMenuItems.Textfield({
                    control = editBox,
                    labelText = resName .. TradeLogicAccess.turnsSuffix(duration),
                    pediaName = pediaName,
                    priorCallback = function(text, ctrl, isEnter)
                        if isEnter then
                            local n = tonumber(text)
                            if n == nil or n == 0 then
                                g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_RESOURCES, iPlayer, rType)
                                TradeLogicAccess.afterLocalDealChange()
                                return
                            end
                        end
                        ChangeResourceAmount(text, ctrl, isEnter)
                    end,
                })
            end
        end
        -- Luxury (or strategic in read-only): Text with optional quantity.
        local qty = data2 or 0
        local label
        if isStrategic then
            label = Text.format("TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING", resName, tostring(qty))
        else
            label = resName
        end
        label = label .. TradeLogicAccess.turnsSuffix(duration)
        if readOnly then
            return BaseMenuItems.Text({ labelText = label, pediaName = pediaName })
        end
        local rType = data1
        return BaseMenuItems.Text({
            labelText = label,
            pediaName = pediaName,
            onActivate = function()
                g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_RESOURCES, iPlayer, rType)
                TradeLogicAccess.clearEngineTable()
                TradeLogicAccess.afterLocalDealChange()
            end,
        })
    end

    if itemType == TradeableItems.TRADE_ITEM_CITIES then
        local plot = Map.GetPlot(data1, data2)
        local city = plot and plot:GetPlotCity()
        local cityID = city and city:GetID()
        local label
        if city ~= nil then
            label =
                Text.format("TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING", city:GetName(), tostring(city:GetPopulation()))
        else
            label = Text.key("TXT_KEY_RAZED_CITY")
        end
        if readOnly or cityID == nil then
            return BaseMenuItems.Text({ labelText = label })
        end
        return BaseMenuItems.Text({
            labelText = label,
            onActivate = function()
                -- Engine's TableCityHandler does RemoveCityTrade(playerID,
                -- cityID); iterator gives us (x, y) in data1/data2, so
                -- convert through the plot's city handle.
                g_Deal:RemoveCityTrade(iPlayer, cityID)
                TradeLogicAccess.clearEngineTable()
                TradeLogicAccess.afterLocalDealChange()
            end,
        })
    end

    if
        itemType == TradeableItems.TRADE_ITEM_THIRD_PARTY_PEACE
        or itemType == TradeableItems.TRADE_ITEM_THIRD_PARTY_WAR
    then
        -- data1 is the target team id; DisplayOtherPlayerItem resolves
        -- team -> player -> civ name. Mirror that.
        local iOtherPlayer = -1
        for i = 0, (GameDefines.MAX_CIV_PLAYERS or 64) - 1 do
            local pl = Players[i]
            if pl and pl:IsEverAlive() and pl:GetTeam() == data1 then
                iOtherPlayer = i
                break
            end
        end
        local otherPlayerObj = iOtherPlayer >= 0 and Players[iOtherPlayer] or nil
        local otherName = otherPlayerObj and otherPlayerObj:GetName() or "?"
        local leaderInfo = otherPlayerObj and GameInfo.Leaders[otherPlayerObj:GetLeaderType()] or nil
        local pediaName = leaderInfo and Text.key(leaderInfo.Description) or nil
        local labelKey = (itemType == TradeableItems.TRADE_ITEM_THIRD_PARTY_PEACE)
                and "TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"
            or "TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"
        local label = Text.format(labelKey, otherName)
        if readOnly then
            return BaseMenuItems.Text({ labelText = label, pediaName = pediaName })
        end
        local teamId = data1
        local capturedType = itemType
        return BaseMenuItems.Text({
            labelText = label,
            pediaName = pediaName,
            onActivate = function()
                g_Deal:RemoveByType(capturedType, iPlayer, teamId)
                TradeLogicAccess.clearEngineTable()
                TradeLogicAccess.afterLocalDealChange()
            end,
        })
    end

    if itemType == TradeableItems.TRADE_ITEM_VOTE_COMMITMENT then
        local pLeague = (Game and Game.GetNumActiveLeagues and Game.GetNumActiveLeagues() > 0)
                and Game.GetActiveLeague()
            or nil
        local iVoteIndex = (type(GetLeagueVoteIndexFromData) == "function")
                and GetLeagueVoteIndexFromData(data1, data2, flag1)
            or nil
        local tVote = iVoteIndex and g_LeagueVoteList and g_LeagueVoteList[iVoteIndex]
        local label
        if pLeague ~= nil and tVote ~= nil and type(GetVoteText) == "function" then
            local proposal = GetVoteText(pLeague, iVoteIndex, flag1, data3)
            local choice = pLeague:GetTextForChoice(tVote.VoteDecision, tVote.VoteChoice)
            label = tostring(proposal) .. ", " .. tostring(choice)
        else
            label = Text.key("TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN")
        end
        -- Mirror the engine's per-vote table tooltip: GetVoteTooltip with
        -- (pLeague, iVoteIndex, flag1, data3) -- TradeLogic.lua:2106 passes
        -- the same arguments when populating cInstance.Button's tooltip.
        local capturedFlag1 = flag1
        local capturedData3 = data3
        local capturedIndex = iVoteIndex
        local voteTooltipFn = function()
            if Game.GetNumActiveLeagues == nil or Game.GetNumActiveLeagues() == 0 then
                return nil
            end
            local pL = Game.GetActiveLeague()
            if pL == nil or capturedIndex == nil or type(GetVoteTooltip) ~= "function" then
                return nil
            end
            return GetVoteTooltip(pL, capturedIndex, capturedFlag1, capturedData3)
        end
        if readOnly or pLeague == nil or tVote == nil then
            return BaseMenuItems.Text({ labelText = label, tooltipFn = voteTooltipFn })
        end
        local resolutionId = tVote.ID
        local voteChoice = tVote.VoteChoice
        local repeal = tVote.Repeal
        local capturedLeague = pLeague
        return BaseMenuItems.Text({
            labelText = label,
            tooltipFn = voteTooltipFn,
            onActivate = function()
                local numVotes = capturedLeague:GetCoreVotesForMember(iPlayer)
                g_Deal:RemoveVoteCommitment(iPlayer, resolutionId, voteChoice, numVotes, repeal)
                TradeLogicAccess.clearEngineTable()
                TradeLogicAccess.afterLocalDealChange()
            end,
        })
    end

    -- Boolean diplomacy items: AllowEmbassy, OpenBorders, DefensivePact,
    -- ResearchAgreement, TradeAgreement, DeclarationOfFriendship. Each has
    -- the same remove shape: RemoveByType(type, player). DoF and DP remove
    -- from BOTH sides (engine invariant); our remove fires the matching
    -- side too. pocketSuffix names the engine pocket control whose tooltip
    -- we read live for the placed-item announcement -- when an item is in
    -- the deal the table-row control has no tooltip (engine never sets one
    -- for booleans), but the pocket control's tooltip (set on the most
    -- recent RefreshPocketX pass) carries the descriptive copy plus the
    -- engine's "already in deal" reason.
    local booleanSpecs = {
        [TradeableItems.TRADE_ITEM_ALLOW_EMBASSY] = {
            key = "TXT_KEY_DIPLO_ALLOW_EMBASSY",
            bothSides = false,
            pocketSuffix = "PocketAllowEmbassy",
        },
        [TradeableItems.TRADE_ITEM_OPEN_BORDERS] = {
            key = "TXT_KEY_DIPLO_OPEN_BORDERS",
            bothSides = false,
            pocketSuffix = "PocketOpenBorders",
        },
        [TradeableItems.TRADE_ITEM_DEFENSIVE_PACT] = {
            key = "TXT_KEY_DIPLO_DEF_PACT",
            bothSides = true,
            pocketSuffix = "PocketDefensivePact",
        },
        [TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT] = {
            key = "TXT_KEY_DIPLO_RESCH_AGREEMENT",
            bothSides = true,
            pocketSuffix = "PocketResearchAgreement",
        },
        [TradeableItems.TRADE_ITEM_TRADE_AGREEMENT] = {
            key = "TXT_KEY_DIPLO_TRADE_AGREEMENT",
            bothSides = false,
            pocketSuffix = "PocketTradeAgreement",
        },
        [TradeableItems.TRADE_ITEM_DECLARATION_OF_FRIENDSHIP] = {
            key = "TXT_KEY_DIPLO_DECLARATION_OF_FRIENDSHIP",
            bothSides = true,
            pocketSuffix = "PocketDoF",
        },
    }
    local bSpec = booleanSpecs[itemType]
    if bSpec ~= nil then
        local label = Text.key(bSpec.key) .. TradeLogicAccess.turnsSuffix(duration)
        local tipFn = TradeLogicAccess.pocketTooltipFn(TradeLogicAccess.prefix(side) .. bSpec.pocketSuffix)
        if readOnly then
            return BaseMenuItems.Text({ labelText = label, tooltipFn = tipFn })
        end
        local capturedType = itemType
        local bothSides = bSpec.bothSides
        return BaseMenuItems.Text({
            labelText = label,
            tooltipFn = tipFn,
            onActivate = function()
                g_Deal:RemoveByType(capturedType, iPlayer)
                if bothSides then
                    -- Engine invariant: DP/RA/DoF/TA must be symmetric;
                    -- the base TableDefensivePactHandler wipes both sides.
                    local other = TradeLogicAccess.sideIsUs(side) and g_iThem or g_iUs
                    g_Deal:RemoveByType(capturedType, other)
                end
                TradeLogicAccess.clearEngineTable()
                TradeLogicAccess.afterLocalDealChange()
            end,
        })
    end

    return nil
end

return TradeLogicOffering

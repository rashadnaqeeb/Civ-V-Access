-- Shared logic for the diplomacy trade screen accessibility layer. Loaded
-- from three Context wrappers (AI DiploTrade, PvP SimpleDiploTrade, review
-- DiploCurrentDeals) via include; each Context gets its own function table
-- bound to that Context's Controls / globals.
--
-- The screen has a flat top-level BaseMenu with six items (Your Offer, Their
-- Offer, an AI query slot, Propose, Cancel, Modify). Activating Your / Their
-- Offer pushes a drawer -- a tabbed BaseMenu with Offering (items on the
-- table) and Available (items that could be placed). Read-only states
-- (AI demand / request / offer, or g_bTradeReview) push a flat Offering-only
-- drawer instead.
--
-- Reads of TradeLogic state rely on eight g_* names we promoted to globals
-- in our shipped TradeLogic.lua override (g_Deal, g_iUs, g_iThem,
-- g_iDiploUIState, g_bTradeReview, g_LeagueVoteList, g_UsTableResources,
-- g_ThemTableResources). The base file declares them `local` at chunk
-- scope, which Lua 5.1 hides from the next included chunk -- so without
-- the promotion, every read here would see nil and every build* function
-- would return its empty-placeholder path.
--
-- Rebuild triggers: any state change that could flip an item's visibility
-- or label (AI responded, remote PvP peer proposed/withdrew, active player
-- changed, deal wiped). Listeners register fresh on every Context include
-- per CLAUDE.md's no-install-once-guards rule -- dead listeners from a
-- prior game throw harmlessly on first global access under the engine's
-- per-listener pcall.

TradeLogicAccess = {}

local DRAWER_NAME = "DiploTrade/Drawer"

-- Single upvalue per Context for the top handler and the open drawer, if
-- any. _handler is set in onShow and nilled in onDeactivate; _drawerHandler
-- is set when the drawer is pushed and nilled in its onDeactivate. The
-- rebuild closure is a module-scope fn; its closures over these upvalues
-- re-resolve on each rebuild call.
local _handler = nil
local _drawerHandler = nil
local _descriptor = nil

-- TradeLogic's g_iDealDuration / g_iPeaceDuration are file-locals, not
-- globals; we can't reach them from our own file. Re-query the engine each
-- time the values are needed.
local function dealDuration()
    return (Game and Game.GetDealDuration and Game.GetDealDuration()) or 30
end

local function peaceDuration()
    return (GameDefines and GameDefines.PEACE_TREATY_LENGTH)
        or (Game and Game.GetPeaceDuration and Game.GetPeaceDuration())
        or 10
end

-- Per-item duration suffix for labels. Returns "" when the item has no
-- meaningful duration (lump gold, cities, third-party, vote, instant)
-- so the caller can append unconditionally. Game speed sets the value
-- once per session; we re-query each call rather than caching so a
-- mid-session save-load with a different speed (engine prevents this in
-- practice, but cheap insurance) doesn't read a stale number.
local function turnsSuffix(duration)
    if duration == nil or duration <= 0 then
        return ""
    end
    return ", " .. Text.format("TXT_KEY_DIPLO_TURNS", duration)
end

-- State classification ----------------------------------------------------

-- Read-only: the user can browse but not place / remove. AI is demanding
-- or proposing, or we're reviewing a historical deal. Checked live on each
-- rebuild -- DIPLO_UI_STATE can flip as AILeaderMessage fires.
local function isReadOnly()
    if g_bTradeReview then
        return true
    end
    if g_iDiploUIState == nil or DiploUIStateTypes == nil then
        return false
    end
    local s = g_iDiploUIState
    return s == DiploUIStateTypes.DIPLO_UI_STATE_TRADE_AI_MAKES_DEMAND
        or s == DiploUIStateTypes.DIPLO_UI_STATE_TRADE_AI_MAKES_REQUEST
        or s == DiploUIStateTypes.DIPLO_UI_STATE_TRADE_AI_MAKES_OFFER
end

-- HUMAN_DEMAND: human demanding from AI. Engine hides UsPanel / UsGlass;
-- we mirror by omitting "Your Offer" from the flat list.
local function isHumanDemand()
    if g_iDiploUIState == nil or DiploUIStateTypes == nil then
        return false
    end
    return g_iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_HUMAN_DEMAND
end

local function sidePlayer(side)
    if side == "us" then
        return g_iUs
    end
    return g_iThem
end

local function sideIsUs(side)
    return side == "us"
end

-- Control-name helpers. Pocket / Table / Panel controls are prefixed "Us"
-- or "Them" uniformly, so a sided caller passes "us" / "them" and we
-- interpolate. Luxury / Strategic / Vote resource instance tables share the
-- same convention (g_UsTableResources vs g_ThemTableResources).
local function prefix(side)
    return sideIsUs(side) and "Us" or "Them"
end

-- Drawer rebuild trigger. Called from onCommit / onRemove after a
-- g_Deal:Add* or Remove* mutation completes, and from the module's top-
-- level rebuild() on external events. Idempotent: no-op if the drawer is
-- not currently pushed.
local function rebuildDrawer()
    if _drawerHandler == nil then
        return
    end
    local found = false
    for i = 1, HandlerStack.count() do
        if HandlerStack.at(i) == _drawerHandler then
            found = true
            break
        end
    end
    if not found then
        _drawerHandler = nil
        return
    end
    local side = _drawerHandler._civvaccess_side
    if side == nil then
        return
    end
    local readOnly = isReadOnly()
    if _drawerHandler.tabs ~= nil then
        -- Editable: two tabs. Rebuild both so the user's cursor position is
        -- preserved on the active tab and the inactive tab is fresh on
        -- next visit.
        _drawerHandler.setItems(TradeLogicAccess.buildOfferingItems(side, false), 1)
        _drawerHandler.setItems(TradeLogicAccess.buildAvailableItems(side), 2)
    else
        _drawerHandler.setItems(TradeLogicAccess.buildOfferingItems(side, readOnly))
    end
end

-- Fire after a local-side placement / removal. DoUIDealChangedByHuman
-- updates engine button labels; DisplayDeal repaints the game's own table
-- rows. Both run the same work the mouse-click handlers do.
local function afterLocalDealChange()
    if type(DisplayDeal) == "function" then
        local ok, err = pcall(DisplayDeal)
        if not ok then
            Log.error("TradeLogicAccess DisplayDeal failed: " .. tostring(err))
        end
    end
    if type(DoUIDealChangedByHuman) == "function" then
        local ok, err = pcall(DoUIDealChangedByHuman)
        if not ok then
            Log.error("TradeLogicAccess DoUIDealChangedByHuman failed: " .. tostring(err))
        end
    end
    TradeLogicAccess.rebuild()
end

-- Closure over a base-game control name that returns its current
-- SetToolTipString live. Used as `tooltipFn` on items whose engine
-- counterpart owns a contextual tooltip the user should hear (disabled
-- reason, descriptive copy, cost / duration text). Returns nil when the
-- control or its tooltip is missing so appendTooltip skips silently.
local function pocketTooltipFn(controlName)
    return function()
        local c = Controls[controlName]
        if c == nil then
            return nil
        end
        return c:GetToolTipString()
    end
end

-- Offering-tab items ------------------------------------------------------

-- Forward declaration: offeringItem is called by buildOfferingItems below
-- but needs the full state-machine switch inline, so it's defined after.
local offeringItem

-- DoClearTable mirrors the engine's own post-remove repaint; called after
-- every mutation that removes a placed item so the engine's InstanceManager
-- rows drop their contents before DisplayDeal rebuilds them.
local function clearEngineTable()
    if type(DoClearTable) ~= "function" then
        return
    end
    local ok, err = pcall(DoClearTable)
    if not ok then
        Log.error("TradeLogicAccess DoClearTable failed: " .. tostring(err))
    end
end

-- Walk the live deal and emit one item per placed entry. Peace Treaty is
-- non-activatable (engine forbids removal). Amount items (Gold, GPT,
-- Strategic) become Textfield items bound to the existing XML EditBox so
-- BaseMenuEditMode.push handles commit through TradeLogic's own
-- RegisterCallback handlers. Other placed items become Text items whose
-- Enter removes from the deal.
-- Placeholder Text item appended when a drawer tab would otherwise be
-- empty. Without it, BaseMenu's tab-switch / first-open announce skips
-- silently on zero items, leaving the user unsure whether the tab is
-- empty or the handler is broken.
local function emptyPlaceholder(textKey)
    return BaseMenuItems.Text({ labelText = Text.key(textKey) })
end

function TradeLogicAccess.buildOfferingItems(side, readOnly)
    local items = {}
    if g_Deal == nil then
        items[#items + 1] = emptyPlaceholder("TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY")
        return items
    end
    local bFromUs = sideIsUs(side)

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
        items[#items + 1] = emptyPlaceholder("TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY")
    end
    return items
end

-- Build a single Offering-tab item for one entry type. Returns nil if the
-- item type isn't one we surface.
offeringItem = function(itemType, data1, data2, data3, flag1, duration, side, readOnly)
    local p = prefix(side)
    local iPlayer = sidePlayer(side)

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
        local goldTooltipFn = pocketTooltipFn(p .. "TableGold")
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
                        afterLocalDealChange()
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
        local gptTooltipFn = pocketTooltipFn(p .. "TableGoldPerTurn")
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
            labelText = Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN") .. turnsSuffix(duration),
            tooltipFn = gptTooltipFn,
            priorCallback = function(text, ctrl, isEnter)
                if isEnter then
                    local n = tonumber(text)
                    if n == nil or n == 0 then
                        g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_GOLD_PER_TURN, iPlayer)
                        afterLocalDealChange()
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
            local tbl = sideIsUs(side) and g_UsTableResources or g_ThemTableResources
            local inst = tbl and tbl[data1]
            local editBox = inst and inst.AmountEdit
            if editBox ~= nil then
                local rType = data1
                return BaseMenuItems.Textfield({
                    control = editBox,
                    labelText = resName .. turnsSuffix(duration),
                    pediaName = pediaName,
                    priorCallback = function(text, ctrl, isEnter)
                        if isEnter then
                            local n = tonumber(text)
                            if n == nil or n == 0 then
                                g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_RESOURCES, iPlayer, rType)
                                afterLocalDealChange()
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
        label = label .. turnsSuffix(duration)
        if readOnly then
            return BaseMenuItems.Text({ labelText = label, pediaName = pediaName })
        end
        local rType = data1
        return BaseMenuItems.Text({
            labelText = label,
            pediaName = pediaName,
            onActivate = function()
                g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_RESOURCES, iPlayer, rType)
                clearEngineTable()
                afterLocalDealChange()
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
                clearEngineTable()
                afterLocalDealChange()
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
                clearEngineTable()
                afterLocalDealChange()
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
                clearEngineTable()
                afterLocalDealChange()
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
        local label = Text.key(bSpec.key) .. turnsSuffix(duration)
        local tipFn = pocketTooltipFn(prefix(side) .. bSpec.pocketSuffix)
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
                    local other = sideIsUs(side) and g_iThem or g_iUs
                    g_Deal:RemoveByType(capturedType, other)
                end
                clearEngineTable()
                afterLocalDealChange()
            end,
        })
    end

    return nil
end

-- Available-tab items -----------------------------------------------------

-- Gold / GPT leaves push NumberEntry on activate with an engine-derived
-- max. onCommit invokes the engine's own Add* function, then
-- afterLocalDealChange repaints + rebuilds.

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
        tooltipFn = pocketTooltipFn(controlName),
    })
end

-- BNW gates lump-sum gold trades on a Declaration of Friendship between
-- the two civs (peace deals exempt); the base UI sets
-- TXT_KEY_DIPLO_NEED_DOF_TT_ONE_LINE on the pocket-gold control's tooltip
-- in that state, which disabledPocketLeaf reads live.
local function availableGoldLeaf(side)
    local iPlayer = sidePlayer(side)
    local other = sideIsUs(side) and g_iThem or g_iUs
    local pocketControlName = prefix(side) .. "PocketGold"
    if not g_Deal:IsPossibleToTradeItem(iPlayer, other, TradeableItems.TRADE_ITEM_GOLD, 1) then
        return disabledPocketLeaf(Text.key("TXT_KEY_DIPLO_GOLD"), pocketControlName)
    end
    return BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_DIPLO_GOLD"),
        tooltipFn = pocketTooltipFn(pocketControlName),
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
                    afterLocalDealChange()
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
    local iPlayer = sidePlayer(side)
    local other = sideIsUs(side) and g_iThem or g_iUs
    local label = Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN") .. turnsSuffix(dealDuration())
    local pocketControlName = prefix(side) .. "PocketGoldPerTurn"
    if not g_Deal:IsPossibleToTradeItem(iPlayer, other, TradeableItems.TRADE_ITEM_GOLD_PER_TURN, 1, dealDuration()) then
        return disabledPocketLeaf(label, pocketControlName)
    end
    return BaseMenuItems.Text({
        labelText = label,
        tooltipFn = pocketTooltipFn(pocketControlName),
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
                    g_Deal:AddGoldPerTurnTrade(iPlayer, amount, dealDuration())
                    afterLocalDealChange()
                end,
            })
        end,
    })
end

-- Resource leaf: luxury (one-quantity activate) or strategic (prompt for
-- amount). Shared builder; isStrategic branches on the activation path.
local function availableResourceLeaf(side, resType, resInfo)
    local iPlayer = sidePlayer(side)
    local resName = Text.key(resInfo.Description)
    local pediaName = resName
    local isStrategic = resInfo.ResourceUsage == 1
    local label = resName .. turnsSuffix(dealDuration())
    if not isStrategic then
        -- Append the tradeable copy count so the player knows up-front
        -- whether giving this away costs the only copy (1) or just an
        -- extra. Phrased "you have N" rather than a bare number so it
        -- can't be misread as a trade quantity -- luxuries are always
        -- 1-quantity. Mirrors the engine's "(N)" pocket suffix.
        local qty = g_Deal:GetNumResource(iPlayer, resType) or 0
        local luxuryLabel = resName
            .. turnsSuffix(dealDuration())
            .. ", "
            .. Text.format("TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE", qty)
        return BaseMenuItems.Text({
            labelText = luxuryLabel,
            pediaName = pediaName,
            onActivate = function()
                -- Luxuries are 1-quantity; engine hardcodes to 1 in
                -- PocketResource handlers.
                g_Deal:AddResourceTrade(iPlayer, resType, 1, dealDuration())
                afterLocalDealChange()
            end,
        })
    end
    -- Strategic: prompt for amount, capped at g_Deal:GetNumResource.
    return BaseMenuItems.Text({
        labelText = label,
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
                    g_Deal:AddResourceTrade(iPlayer, resType, amount, dealDuration())
                    afterLocalDealChange()
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
    local iPlayer = sidePlayer(side)
    local otherPlayer = sideIsUs(side) and g_iThem or g_iUs
    -- Legality for boolean items all follow the same 4-arg signature
    -- IsPossibleToTradeItem(from, to, type, duration) (matching TradeLogic's
    -- RefreshPocketEmbassy / OpenBorders / DP / RA / TA / DoF handlers).
    local label = Text.key(labelKey) .. turnsSuffix(dealDuration())
    local pocketControlName = prefix(side) .. controlSuffix
    if not g_Deal:IsPossibleToTradeItem(iPlayer, otherPlayer, itemConstant, dealDuration()) then
        return disabledPocketLeaf(label, pocketControlName)
    end
    -- Engine's RefreshPocket{Embassy,OpenBorders,DefensivePact,
    -- ResearchAgreement,TradeAgreement,DoF} sets a contextual tooltip on the
    -- pocket control in both enabled and disabled states. Read live so the
    -- announce reflects whatever the engine last computed.
    return BaseMenuItems.Text({
        labelText = label,
        tooltipFn = pocketTooltipFn(pocketControlName),
        onActivate = function()
            if bothSides then
                addFn(g_iUs)
                addFn(g_iThem)
            else
                addFn(iPlayer)
            end
            afterLocalDealChange()
        end,
    })
end

-- Resources group: Luxury and Strategic as separate sub-groups. Iterate
-- GameInfo.Resources once, filter by legality, partition into the two
-- buckets. g_Deal:IsPossibleToTradeItem does the per-resource legality
-- check the engine uses in RefreshPocketResources.
local function availableResourceGroups(side)
    local iPlayer = sidePlayer(side)
    local otherPlayer = sideIsUs(side) and g_iThem or g_iUs
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
    local p = prefix(side)
    local groups = {}
    if #luxuries > 0 then
        groups[#groups + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_TRADE_ITEM_LUXURY_RESOURCES"),
            tooltipFn = pocketTooltipFn(p .. "PocketLuxury"),
            items = luxuries,
        })
    end
    if #strategics > 0 then
        groups[#groups + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_TRADE_ITEM_STRATEGIC_RESOURCES"),
            tooltipFn = pocketTooltipFn(p .. "PocketStrategic"),
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
            Log.error("TradeLogicAccess UpdateLeagueVotes failed: " .. tostring(err))
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
    local iPlayer = sidePlayer(side)
    local otherPlayer = sideIsUs(side) and g_iThem or g_iUs
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
                    afterLocalDealChange()
                end,
            })
        end
    end
    if #items == 0 then
        return nil
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_TRADE_ITEM_VOTES"),
        tooltipFn = pocketTooltipFn(prefix(side) .. "PocketVote"),
        items = items,
    })
end

-- Cities group: enumerate this side's cities, filter by legality.
local function availableCitiesGroup(side)
    local iPlayer = sidePlayer(side)
    local otherPlayer = sideIsUs(side) and g_iThem or g_iUs
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
                    afterLocalDealChange()
                end,
            })
        end
    end
    if #items == 0 then
        return nil
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_DIPLO_CITIES"),
        tooltipFn = pocketTooltipFn(prefix(side) .. "PocketCities"),
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
    local iPlayer = sidePlayer(side)
    local otherPlayer = sideIsUs(side) and g_iThem or g_iUs
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
                        g_Deal:AddThirdPartyPeace(iPlayer, capturedTeam, peaceDuration())
                        afterLocalDealChange()
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
                        afterLocalDealChange()
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
        tooltipFn = pocketTooltipFn(prefix(side) .. "PocketOtherPlayer"),
        items = subs,
    })
end

function TradeLogicAccess.buildAvailableItems(side)
    if g_Deal == nil or TradeableItems == nil then
        return { emptyPlaceholder("TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE") }
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
        g_Deal:AddOpenBorders(p, dealDuration())
    end, false)
    addBoolean("TXT_KEY_DIPLO_DEF_PACT", TradeableItems.TRADE_ITEM_DEFENSIVE_PACT, "PocketDefensivePact", function(p)
        g_Deal:AddDefensivePact(p, dealDuration())
    end, true)
    addBoolean(
        "TXT_KEY_DIPLO_RESCH_AGREEMENT",
        TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT,
        "PocketResearchAgreement",
        function(p)
            g_Deal:AddResearchAgreement(p, dealDuration())
        end,
        true
    )
    addBoolean(
        "TXT_KEY_DIPLO_TRADE_AGREEMENT",
        TradeableItems.TRADE_ITEM_TRADE_AGREEMENT,
        "PocketTradeAgreement",
        function(p)
            g_Deal:AddTradeAgreement(p, dealDuration())
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

-- Drawer push -------------------------------------------------------------

local function pushDrawer(side)
    local readOnly = isReadOnly()
    local label = sideIsUs(side) and Text.key("TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER")
        or Text.key("TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER")
    local spec
    if readOnly then
        spec = {
            name = DRAWER_NAME,
            displayName = label,
            escapePops = true,
            items = TradeLogicAccess.buildOfferingItems(side, true),
        }
    else
        spec = {
            name = DRAWER_NAME,
            displayName = label,
            escapePops = true,
            tabs = {
                {
                    name = "TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING",
                    items = TradeLogicAccess.buildOfferingItems(side, false),
                },
                {
                    name = "TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE",
                    items = TradeLogicAccess.buildAvailableItems(side),
                },
            },
        }
    end
    local drawer = BaseMenu.create(spec)
    drawer._civvaccess_side = side
    local priorDeactivate = drawer.onDeactivate
    drawer.onDeactivate = function()
        if type(priorDeactivate) == "function" then
            pcall(priorDeactivate)
        end
        _drawerHandler = nil
    end
    _drawerHandler = drawer
    HandlerStack.push(drawer)
end

-- Top-level items ---------------------------------------------------------

-- Your / Their Offer items, exported so Contexts whose top-level list is
-- not "pocket + action buttons" (DiploCurrentDeals: deal picker + drawer
-- entries) can compose them into their own topItemsFn. useVisibilityControl
-- gates the item on Us/ThemPanel -- DiploTrade and SimpleDiploTrade have
-- those controls, DiploCurrentDeals does not.
function TradeLogicAccess.buildYourOfferItem(useVisibilityControl)
    local spec = {
        labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"),
        activate = function()
            pushDrawer("us")
        end,
    }
    if useVisibilityControl then
        spec.visibilityControlName = "UsPanel"
    end
    return BaseMenuItems.Choice(spec)
end

function TradeLogicAccess.buildTheirOfferItem(useVisibilityControl)
    local spec = {
        labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"),
        activate = function()
            pushDrawer("them")
        end,
    }
    if useVisibilityControl then
        spec.visibilityControlName = "ThemPanel"
    end
    return BaseMenuItems.Choice(spec)
end

-- Action-button leaf for the trade screen's bottom row (Propose / Cancel /
-- Modify / What*-query). Surfaces hidden or disabled buttons as "<label>,
-- disabled" Text leaves rather than dropping them from navigation, so the
-- user can find the buttons even when the engine has greyed them out --
-- a hidden button is functionally a disabled one for our purposes. The
-- disabled leaf carries the engine's live tooltip via tooltipFn so the
-- reason auto-announces alongside the label. fallbackLabel fills in
-- when the engine never set the button's text (e.g. a query button
-- that's never been shown this session).
local function actionButtonLeaf(controlName, activate, fallbackLabel)
    local control = Controls[controlName]
    if control == nil then
        return nil
    end
    local hidOk, hidden = pcall(function()
        return control:IsHidden()
    end)
    local disOk, disabled = pcall(function()
        return control:IsDisabled()
    end)
    local inactive = (hidOk and hidden) or (disOk and disabled)
    if inactive then
        local label = ""
        local okT, t = pcall(function()
            return control:GetText()
        end)
        if okT and t ~= nil then
            label = tostring(t)
        end
        if label == "" then
            label = fallbackLabel or controlName
        end
        return BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_CIVVACCESS_LABEL_DISABLED", label),
            tooltipFn = pocketTooltipFn(controlName),
        })
    end
    return BaseMenuItems.Button({
        controlName = controlName,
        labelFn = function(c)
            return c:GetText()
        end,
        tooltipFn = function(c)
            return c:GetToolTipString()
        end,
        activate = activate,
    })
end

local function buildTopItems(descriptor)
    local items = {}

    -- Gate "Your Offer" / "Their Offer" on Us/ThemPanel visibility only when
    -- the screen is editable. In AI_MAKES_DEMAND / AI_MAKES_REQUEST the
    -- engine's DoDemandState(true) hides UsPanel, UsGlass, ThemPanel, and
    -- ThemGlass and overlays TableCover -- the layout becomes a
    -- non-interactive readout for sighted users. The deal still lives in
    -- g_Deal, though, and a screen-reader user has no other way to hear
    -- what's being asked. Skip the gate in any read-only AI state so the
    -- drawers stay reachable; pushDrawer's read-only branch builds the
    -- Offering-only flat list (no Available tab), which is the right
    -- surface for inspect-but-don't-modify. AI_MAKES_OFFER doesn't hide
    -- the panels (bDemandOn is false there), so the gate would be a no-op
    -- regardless -- folding it in keeps the rule "editable: gate, read-
    -- only: ungate" simple. Editable-Human-Demand still drops Your Offer
    -- via the explicit isHumanDemand() check below.
    local gateOnPanel = not isReadOnly()

    if not isHumanDemand() then
        items[#items + 1] = TradeLogicAccess.buildYourOfferItem(gateOnPanel)
    end

    items[#items + 1] = TradeLogicAccess.buildTheirOfferItem(gateOnPanel)

    -- AI query buttons: in AI Context only. Engine hides 4 of 5 at any
    -- given time and the absent ones aren't useful in their inactive state
    -- (WhatWillEndThisWar at peace, WhatConcessions when not requesting,
    -- etc.), so we use plain Button items whose isNavigable hides them
    -- when the engine does -- only the relevant query for the current
    -- state shows up.
    if descriptor.kind == "AI" then
        local queries = {
            { name = "WhatDoYouWantButton", activate = OnWhatDoesAIWant },
            { name = "WhatWillYouGiveMeButton", activate = OnWhatWillAIGive },
            { name = "WhatWillMakeThisWorkButton", activate = OnEqualizeDeal },
            { name = "WhatWillEndThisWarButton", activate = OnEqualizeDeal },
            { name = "WhatConcessionsButton", activate = OnEqualizeDeal },
        }
        for _, q in ipairs(queries) do
            if Controls[q.name] ~= nil and type(q.activate) == "function" then
                items[#items + 1] = BaseMenuItems.Button({
                    controlName = q.name,
                    labelFn = function(c)
                        return c:GetText()
                    end,
                    tooltipFn = function(c)
                        return c:GetToolTipString()
                    end,
                    activate = q.activate,
                })
            end
        end
    end

    -- Propose. Base TradeLogic registers OnPropose on ProposeButton and
    -- relies on Void1 (PROPOSE_TYPE / WITHDRAW_TYPE / ACCEPT_TYPE) to pick
    -- the path; DoUpdateButtons sets the right Void1 per state. Read it
    -- live so a "Propose" press in TRADE, "Demand" in HUMAN_DEMAND, and
    -- "Accept" in TRADE_AI_MAKES_OFFER all dispatch correctly through the
    -- engine's own callback.
    if Controls.ProposeButton ~= nil and type(OnPropose) == "function" then
        local item = actionButtonLeaf("ProposeButton", function()
            local okV, void1 = pcall(function()
                return Controls.ProposeButton:GetVoid1()
            end)
            OnPropose((okV and void1) or 0)
        end, Text.key("TXT_KEY_DIPLO_PROPOSE"))
        if item ~= nil then
            items[#items + 1] = item
        end
    end

    -- Cancel / Refuse. Same Void1 pattern (CANCEL_TYPE vs REFUSE_TYPE).
    if Controls.CancelButton ~= nil and type(OnBack) == "function" then
        local item = actionButtonLeaf("CancelButton", function()
            local okV, void1 = pcall(function()
                return Controls.CancelButton:GetVoid1()
            end)
            OnBack((okV and void1) or 0)
        end, Text.key("TXT_KEY_DIPLO_CANCEL"))
        if item ~= nil then
            items[#items + 1] = item
        end
    end

    -- Modify (PvP only; control is nil in AI / Review so factory returns nil).
    if Controls.ModifyButton ~= nil and type(OnModify) == "function" then
        local item = actionButtonLeaf("ModifyButton", OnModify, Text.key("TXT_KEY_DIPLO_MODIFY"))
        if item ~= nil then
            items[#items + 1] = item
        end
    end

    return items
end

-- Rebuild + install -------------------------------------------------------

-- Resolve the top-items builder for a descriptor. Contexts whose top level
-- is not the standard pocket+action list (DiploCurrentDeals: deal picker +
-- drawer entries) supply descriptor.topItemsFn to replace the default.
local function effectiveTopItems(descriptor)
    if type(descriptor.topItemsFn) == "function" then
        local ok, result = pcall(descriptor.topItemsFn, descriptor)
        if not ok then
            Log.error("TradeLogicAccess topItemsFn failed: " .. tostring(result))
            return {}
        end
        return result or {}
    end
    return buildTopItems(descriptor)
end

function TradeLogicAccess.rebuild()
    if _handler == nil or _descriptor == nil then
        return
    end
    _handler.setItems(effectiveTopItems(_descriptor))
    rebuildDrawer()
    _handler.refresh()
end

function TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, descriptor)
    _descriptor = descriptor

    local handler = BaseMenu.install(ContextPtr, {
        name = descriptor.name,
        displayName = descriptor.fallbackDisplayName or Text.key("TXT_KEY_CIVVACCESS_SCREEN_TRADE"),
        preamble = descriptor.preambleFn,
        silentFirstOpen = descriptor.silentFirstOpen,
        deferActivate = descriptor.deferActivate,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onTab = descriptor.onTab,
        onShiftTab = descriptor.onShiftTab,
        onEscape = descriptor.onEscape,
        suppressReactivateOnHide = descriptor.suppressReactivateOnHide,
        onShow = function(h)
            _handler = h
            _drawerHandler = nil
            if type(descriptor.displayNameFn) == "function" then
                local ok, name = pcall(descriptor.displayNameFn)
                if ok and name ~= nil and name ~= "" then
                    h.displayName = tostring(name)
                end
            end
            h.setItems(effectiveTopItems(descriptor))
        end,
        items = {},
    })

    -- Wrap onDeactivate to clear the module upvalues when the Context
    -- hides. BaseMenu.install's ShowHide handler fires onDeactivate via
    -- removeByName before it un-sets _initialized.
    local priorDeactivate = handler.onDeactivate
    handler.onDeactivate = function()
        if type(priorDeactivate) == "function" then
            pcall(priorDeactivate)
        end
        _handler = nil
        _drawerHandler = nil
    end

    -- Register rebuild listeners. Fresh on every Context include per
    -- CLAUDE.md's no-install-once rule. Dead listeners from a prior game
    -- throw on first access under the engine's per-listener pcall; the
    -- newest live listener still fires.
    --
    -- Skipped for DiploCurrentDeals (descriptor.skipStandardListeners):
    -- none of these events apply to a deal-review session. Rebuild there
    -- fires only from the deal-picker's own onActivate.
    if not descriptor.skipStandardListeners then
        local function rebuildIfLive()
            TradeLogicAccess.rebuild()
        end
        if descriptor.kind == "AI" and Events.AILeaderMessage ~= nil then
            Events.AILeaderMessage.Add(rebuildIfLive)
        end
        if LuaEvents.OpenAILeaderDiploTrade ~= nil then
            LuaEvents.OpenAILeaderDiploTrade.Add(rebuildIfLive)
        end
        if LuaEvents.OpenSimpleDiploTrade ~= nil then
            LuaEvents.OpenSimpleDiploTrade.Add(rebuildIfLive)
        end
        if Events.ClearDiplomacyTradeTable ~= nil then
            Events.ClearDiplomacyTradeTable.Add(rebuildIfLive)
        end
        if Events.OpenPlayerDealScreenEvent ~= nil then
            Events.OpenPlayerDealScreenEvent.Add(rebuildIfLive)
        end
        if Events.GameplaySetActivePlayer ~= nil then
            Events.GameplaySetActivePlayer.Add(rebuildIfLive)
        end
    end

    return handler
end

return TradeLogicAccess

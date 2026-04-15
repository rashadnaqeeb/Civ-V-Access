# Deal

Methods on Deal handles (diplomacy trade deals).

Extracted from 356 call sites across 33 distinct methods in the shipped game Lua.

## Methods

### AddAllowEmbassy
- `g_Deal:AddAllowEmbassy(g_iUs)`
- `g_Deal:AddAllowEmbassy(g_iThem)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:2396`

### AddCityTrade
- `g_Deal:AddCityTrade(playerID, cityID)`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2380`

### AddDeclarationOfFriendship
- `g_Deal:AddDeclarationOfFriendship(g_iUs)`
- `g_Deal:AddDeclarationOfFriendship(g_iThem)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:2433`

### AddDefensivePact
- `g_Deal:AddDefensivePact(g_iUs, g_iDealDuration)`
- `g_Deal:AddDefensivePact(g_iThem, g_iDealDuration)`
- 12 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2121`

### AddGoldPerTurnTrade
- `g_Deal:AddGoldPerTurnTrade(g_iUs, iGoldPerTurn, g_iDealDuration)`
- `g_Deal:AddGoldPerTurnTrade(g_iThem, iGoldPerTurn, g_iDealDuration)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1988`

### AddGoldTrade
- `g_Deal:AddGoldTrade(g_iUs, iAmount)`
- `g_Deal:AddGoldTrade(g_iThem, iAmount)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1888`

### AddOpenBorders
- `g_Deal:AddOpenBorders(g_iUs, g_iDealDuration)`
- `g_Deal:AddOpenBorders(g_iThem, g_iDealDuration)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2078`

### AddPeaceTreaty
- `g_Deal:AddPeaceTreaty(g_iUs, GameDefines.PEACE_TREATY_LENGTH)`
- `g_Deal:AddPeaceTreaty(g_iThem, GameDefines.PEACE_TREATY_LENGTH)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:295`

### AddResearchAgreement
- `g_Deal:AddResearchAgreement(g_iUs, g_iDealDuration)`
- `g_Deal:AddResearchAgreement(g_iThem, g_iDealDuration)`
- 12 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2157`

### AddResourceTrade
- `g_Deal:AddResourceTrade(g_iUs, resourceId, iAmount, g_iDealDuration)`
- `g_Deal:AddResourceTrade(g_iThem, resourceId, iAmount, g_iDealDuration)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2237`

### AddThirdPartyPeace
- `g_Deal:AddThirdPartyPeace(iWho, iOtherTeam, GameDefines.PEACE_TREATY_LENGTH)`
- `g_Deal:AddThirdPartyPeace(iWho, iOtherPlayer, GameDefines.PEACE_TREATY_LENGTH)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:3282`

### AddThirdPartyWar
- `g_Deal:AddThirdPartyWar(iWho, iOtherTeam)`
- `g_Deal:AddThirdPartyWar(iWho, iOtherPlayer)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:3280`

### AddTradeAgreement
- `g_Deal:AddTradeAgreement(g_iUs, g_iDealDuration)`
- `g_Deal:AddTradeAgreement(g_iThem, g_iDealDuration)`
- 12 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2193`

### AddVoteCommitment
- `g_Deal:AddVoteCommitment(iFromPlayer, iResolutionID, iVoteChoice, iNumVotes, bRepeal)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:2815`

### ChangeGoldPerTurnTrade
- `g_Deal:ChangeGoldPerTurnTrade(g_iUs, iGoldPerTurn, g_iDealDuration)`
- `g_Deal:ChangeGoldPerTurnTrade(g_iThem, iGoldPerTurn, g_iDealDuration)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2045`

### ChangeGoldTrade
- `g_Deal:ChangeGoldTrade(g_iUs, iGold)`
- `g_Deal:ChangeGoldTrade(g_iThem, iGold)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1940`

### ChangeResourceTrade
- `g_Deal:ChangeResourceTrade(g_iUs, iResourceID, iNumResource, g_iDealDuration)`
- `g_Deal:ChangeResourceTrade(g_iThem, iResourceID, iNumResource, g_iDealDuration)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2346`

### ClearItems
- `g_Deal:ClearItems()`
- `deal:ClearItems()`
- 16 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:227`

### GetGoldAvailable
- `g_Deal:GetGoldAvailable(g_iUs, iItemToBeChanged)`
- `g_Deal:GetGoldAvailable(g_iThem, iItemToBeChanged)`
- `g_Deal:GetGoldAvailable(iPlayer, iItemToBeChanged)`
- `g_Deal:GetGoldAvailable(g_iUs, TradeableItems.TRADE_ITEM_GOLD)`
- `g_Deal:GetGoldAvailable(g_iThem, TradeableItems.TRADE_ITEM_GOLD)`
- 33 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1008`

### GetNextItem
- `g_Deal:GetNextItem()`
- `deal:GetNextItem()`
- 14 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:644`

### GetNumItems
- `g_Deal:GetNumItems()`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:490`

### GetNumResource
- `g_Deal:GetNumResource(g_iUs, resourceId)`
- `g_Deal:GetNumResource(g_iThem, resourceId)`
- `g_Deal:GetNumResource(iPlayer, iResourceID)`
- `g_Deal:GetNumResource(g_iUs, resType)`
- `g_Deal:GetNumResource(g_iThem, resType)`
- 16 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:2614`

### GetOtherPlayer
- `g_Deal:GetOtherPlayer(g_iUs)`
- `deal:GetOtherPlayer(data.LeaderId)`
- 4 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:323`

### IsPossibleToTradeItem
- `g_Deal:IsPossibleToTradeItem(iPlayer, g_iUs, TradeableItems.TRADE_ITEM_TRADE_AGREEMENT, g_iDealDuration)`
- `g_Deal:IsPossibleToTradeItem(iPlayer, g_iUs, TradeableItems.TRADE_ITEM_RESOURCES, iResourceLoop, 1)`
- `g_Deal:IsPossibleToTradeItem(g_iUs, g_iThem, TradeableItems.TRADE_ITEM_GOLD, 1)`
- `g_Deal:IsPossibleToTradeItem(g_iThem, g_iUs, TradeableItems.TRADE_ITEM_GOLD, 1)`
- `g_Deal:IsPossibleToTradeItem(g_iUs, g_iThem, TradeableItems.TRADE_ITEM_GOLD_PER_TURN, 1, g_iDealDuration)`
- ...and 23 more distinct call shapes
- 71 callsites. Example: `UI/InGame/Popups/DiploRelationships.lua:325`

### RemoveByType
- `g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_GOLD, g_iUs)`
- `g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_GOLD, g_iThem)`
- `g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_GOLD_PER_TURN, g_iUs)`
- `g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_GOLD_PER_TURN, g_iThem)`
- `g_Deal:RemoveByType(TradeableItems.TRADE_ITEM_OPEN_BORDERS, g_iUs)`
- ...and 11 more distinct call shapes
- 44 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1907`

### RemoveCityTrade
- `g_Deal:RemoveCityTrade(playerID, cityID)`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2425`

### RemoveResourceTrade
- `g_Deal:RemoveResourceTrade(resourceId)`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2251`

### RemoveThirdPartyPeace
- `g_Deal:RemoveThirdPartyPeace(firstParty, iOtherTeam)`
- `g_Deal:RemoveThirdPartyPeace(firstParty, iOtherPlayer)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:3326`

### RemoveThirdPartyWar
- `g_Deal:RemoveThirdPartyWar(firstParty, iOtherTeam)`
- `g_Deal:RemoveThirdPartyWar(firstParty, iOtherPlayer)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:3347`

### RemoveVoteCommitment
- `g_Deal:RemoveVoteCommitment(iFromPlayer, iResolutionID, iVoteChoice, iNumVotes, bRepeal)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:2884`

### ResetIterator
- `g_Deal:ResetIterator()`
- `deal:ResetIterator()`
- 7 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:643`

### SetFromPlayer
- `g_Deal:SetFromPlayer(g_iUs)`
- 15 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:138`

### SetToPlayer
- `g_Deal:SetToPlayer(g_iThem)`
- 15 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:139`

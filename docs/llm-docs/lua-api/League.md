# League

Methods on League handles (World Congress / United Nations). BNW only.

Extracted from 94 call sites across 41 distinct methods in the shipped game Lua.

## Methods

### CalculateStartingVotesForMember
- `pLeague:CalculateStartingVotesForMember(Game.GetActivePlayer())`
- `league:CalculateStartingVotesForMember(iPlayer)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:553`

### CanChangeCustomName
- `pLeague:CanChangeCustomName(iActivePlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:151`

### CanPropose
- `pLeague:CanPropose(iActivePlayer)`
- `league:CanPropose(iPlayer)`
- `league:CanPropose(playerID)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:163`

### CanProposeEnact
- `league:CanProposeEnact(resolutionType, activePlayerId, choiceId)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:316`

### CanProposeEnactAnyChoice
- `league:CanProposeEnactAnyChoice(resolutionType, activePlayerId)`
- `league:CanProposeEnactAnyChoice(resolutionType, kNoPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:294`

### CanProposeRepeal
- `league:CanProposeRepeal(resolutionId, activePlayerId)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:255`

### GetActiveResolutions
- `league:GetActiveResolutions()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:249`

### GetChoicesForDecision
- `pLeague:GetChoicesForDecision(iVoterDecision)`
- `league:GetChoicesForDecision(resolutionDecisionId, activePlayerId)`
- `league:GetChoicesForDecision(decisionId, activePlayerId)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:2773`

### GetCoreVotesForMember
- `pLeague:GetCoreVotesForMember(iFromPlayer)`
- `pLeague:GetCoreVotesForMember(g_iUs)`
- `pLeague:GetCoreVotesForMember(g_iThem)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:2812`

### GetCurrentEffectsSummary
- `pLeague:GetCurrentEffectsSummary()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:206`

### GetEnactProposals
- `pLeague:GetEnactProposals()`
- `league:GetEnactProposals()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/DeclareWarPopup.lua:275`

### GetEnactProposalsOnHold
- `league:GetEnactProposalsOnHold()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:390`

### GetHostMember
- `league:GetHostMember()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:354`

### GetInactiveResolutions
- `league:GetInactiveResolutions()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:288`

### GetLeagueSplashDescription
- `pLeague:GetLeagueSplashDescription(iGoverningSpecialSession, bFirstSession)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueSplash.lua:40`

### GetLeagueSplashNextEraDetails
- `pLeague:GetLeagueSplashNextEraDetails(iGoverningSpecialSession, bFirstSession)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueSplash.lua:42`

### GetLeagueSplashThisEraDetails
- `pLeague:GetLeagueSplashThisEraDetails(iGoverningSpecialSession, bFirstSession)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueSplash.lua:41`

### GetLeagueSplashTitle
- `pLeague:GetLeagueSplashTitle(iGoverningSpecialSession, bFirstSession)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueSplash.lua:39`

### GetMemberContribution
- `pLeague:GetMemberContribution(iPlayerLoop, iProjectLoop)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueProjectPopup.lua:71`

### GetMemberContributionTier
- `pLeague:GetMemberContributionTier(iPlayerLoop, iProjectLoop)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueProjectPopup.lua:74`

### GetMemberDetails
- `league:GetMemberDetails(iPlayer, iActivePlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:370`

### GetName
- `pLeague:GetName()`
- `league:GetName()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:143`

### GetProjectBuildingCostPerPlayer
- `pLeague:GetProjectBuildingCostPerPlayer(iBuildingID)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:131`

### GetProjectCostPerPlayer
- `pLeague:GetProjectCostPerPlayer(tLeagueProject.ID)`
- `pLeague:GetProjectCostPerPlayer(id)`
- 2 callsites. Example: `DLC/Expansion2/UI/Civilopedia/CivilopediaScreen.lua:3024`

### GetProjectDetails
- `pLeague:GetProjectDetails(GameInfo.LeagueProjects[tProject.Type].ID, Game.GetActivePlayer())`
- `pLeague:GetProjectDetails(tProject.ID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:421`

### GetProjectRewardTierDetails
- `pLeague:GetProjectRewardTierDetails(1, m_iProject)`
- `pLeague:GetProjectRewardTierDetails(2, m_iProject)`
- `pLeague:GetProjectRewardTierDetails(3, m_iProject)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueProjectPopup.lua:255`

### GetRemainingProposalsForMember
- `pLeague:GetRemainingProposalsForMember(iActivePlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:162`

### GetRemainingVotesForMember
- `pLeague:GetRemainingVotesForMember(iActivePlayer)`
- `league:GetRemainingVotesForMember(iPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:186`

### GetRepealProposals
- `pLeague:GetRepealProposals()`
- `league:GetRepealProposals()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/DeclareWarPopup.lua:268`

### GetRepealProposalsOnHold
- `league:GetRepealProposalsOnHold()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:391`

### GetResolutionDetails
- `league:GetResolutionDetails(v.Type, activePlayerId, v.ID, choice)`
- `league:GetResolutionDetails(resolutionType, activePlayerId, resolutionId, proposerDecision)`
- `league:GetResolutionDetails(resolutionType, activePlayerId, resolutionId, choiceId)`
- `league:GetResolutionDetails(proposal.Type, controller.ActivePlayerId, -1, choiceId)`
- `league:GetResolutionDetails(proposal.Type, controller.ActivePlayerId, -1, proposal.ProposerDecision)`
- 9 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:443`

### GetResolutionName
- `league:GetResolutionName(v.Type, v.ID, choice, false)`
- `league:GetResolutionName(resolutionType, resolutionId, proposerDecision, false)`
- `pLeague:GetResolutionName(proposal.Type, data1, proposal.ProposerDecision, true)`
- `league:GetResolutionName(proposal.Type, -1, choiceId, false)`
- `league:GetResolutionName(proposal.Type, -1, proposal.ProposerDecision, false)`
- ...and 1 more distinct call shapes
- 10 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:442`

### GetSpentVotesForMember
- `league:GetSpentVotesForMember(iPlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:368`

### GetTextForChoice
- `pLeague:GetTextForChoice(tVote.VoteDecision, tVote.VoteChoice)`
- `pLeague:GetTextForChoice(iVoterDecision, data2)`
- `league:GetTextForChoice(resolutionDecisionId, choiceId)`
- `league:GetTextForChoice(decisionId, choiceId)`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:2097`

### GetTurnsUntilSession
- `pLeague:GetTurnsUntilSession()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:161`

### GetTurnsUntilVictorySession
- `pLeague:GetTurnsUntilVictorySession()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:195`

### IsInSession
- `pLeague:IsInSession()`
- `league:IsInSession()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:159`

### IsInSpecialSession
- `pLeague:IsInSpecialSession()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:180`

### IsMember
- `league:IsMember(player:GetID())`
- `league:IsMember(playerID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:345`

### IsProjectActive
- `pLeague:IsProjectActive(iProjectLoop)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueProjectPopup.lua:61`

### IsProjectComplete
- `pLeague:IsProjectComplete(iProjectLoop)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueProjectPopup.lua:61`

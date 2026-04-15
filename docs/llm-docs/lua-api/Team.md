# Team

Methods on Team handles. Obtain via `Teams[teamID]` or `pPlayer:GetTeam()` (returns team ID).

Extracted from 720 call sites across 41 distinct methods in the shipped game Lua.

## Methods

### CanChangeWarPeace
- `pActiveTeam:CanChangeWarPeace(g_iAITeam)`
- 3 callsites. Example: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:146`

### CanDeclareWar
- `g_pTeam:CanDeclareWar(Players[ ePlayer ]:GetTeam())`
- `g_pTeam:CanDeclareWar(pOtherPlayer:GetTeam())`
- `pActiveTeam:CanDeclareWar(g_iAITeam)`
- 11 callsites. Example: `UI/InGame/DiploList.lua:181`

### CanEmbark
- `pTeam:CanEmbark()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1729`

### GetCurrentEra
- `pTeam:GetCurrentEra()`
- 5 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:325`

### GetID
- `pTeam:GetID()`
- `pOtherTeam:GetID()`
- `g_pTeam:GetID()`
- 46 callsites. Example: `UI/InGame/Popups/DiploVotePopup.lua:73`

### GetLeaderID
- `Teams[eRivalTeam]:GetLeaderID()`
- `pTeam:GetLeaderID()`
- `team:GetLeaderID()`
- `pOtherTeam:GetLeaderID()`
- `Teams[iPreviousVoteCast]:GetLeaderID()`
- 30 callsites. Example: `UI/InGame/PopupsGeneric/DeclareWarMovePopup.lua:47`

### GetLiberatedByTeam
- `Teams[pPlayer:GetTeam()]:GetLiberatedByTeam()`
- `Teams[iTeam]:GetLiberatedByTeam()`
- `Teams[pTeam]:GetLiberatedByTeam()`
- 10 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:390`

### GetNameKey
- `Teams[eRivalTeam]:GetNameKey()`
- `Teams[eOtherTeam]:GetNameKey()`
- 18 callsites. Example: `UI/InGame/PopupsGeneric/DeclareWarMovePopup.lua:21`

### GetNumMembers
- `pTeam:GetNumMembers()`
- `pOtherTeam:GetNumMembers()`
- `g_pTeam:GetNumMembers()`
- `pLoopTeam:GetNumMembers()`
- 26 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:283`

### GetNumTurnsLockedIntoWar
- `pActiveTeam:GetNumTurnsLockedIntoWar(g_iAITeam)`
- 3 callsites. Example: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:170`

### GetProjectCount
- `Teams[pPlayer:GetTeam()]:GetProjectCount(proj)`
- `Teams[iTeam]:GetProjectCount(apolloProj)`
- `Teams[iTeam]:GetProjectCount(proj)`
- `Teams[pTeam]:GetProjectCount(apolloProj)`
- 31 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:460`

### GetProjectedVotesFromCivs
- `pTeam:GetProjectedVotesFromCivs()`
- 3 callsites. Example: `DLC/Expansion/UI/InGame/Popups/VictoryProgress.lua:769`

### GetProjectedVotesFromLiberatedMinors
- `pTeam:GetProjectedVotesFromLiberatedMinors()`
- 3 callsites. Example: `DLC/Expansion/UI/InGame/Popups/VictoryProgress.lua:789`

### GetProjectedVotesFromMinorAllies
- `pTeam:GetProjectedVotesFromMinorAllies()`
- 3 callsites. Example: `DLC/Expansion/UI/InGame/Popups/VictoryProgress.lua:779`

### GetScore
- `pTeam:GetScore()`
- 2 callsites. Example: `UI/InGame/WorldView/MPList.lua:412`

### GetTeamTechs
- `pTeam:GetTeamTechs()`
- `activeTeam:GetTeamTechs()`
- `pActiveTeam:GetTeamTechs()`
- `g_pUsTeam:GetTeamTechs()`
- `team:GetTeamTechs()`
- 62 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:2011`

### GetTotalProjectedVotes
- `pTeam:GetTotalProjectedVotes()`
- `Teams[curTeam]:GetTotalProjectedVotes()`
- 5 callsites. Example: `DLC/Expansion/UI/InGame/Popups/VictoryProgress.lua:849`

### GetTotalSecuredVotes
- `Teams[curTeam]:GetTotalSecuredVotes()`
- `Teams[pTeam]:GetTotalSecuredVotes()`
- 4 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:435`

### HasEmbassyAtTeam
- `g_pThemTeam:HasEmbassyAtTeam(g_iUsTeam)`
- `g_pUsTeam:HasEmbassyAtTeam(g_iThemTeam)`
- `pTeam:HasEmbassyAtTeam(g_iTeam)`
- `g_pTeam:HasEmbassyAtTeam(iTeam)`
- 20 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:1143`

### IsAlive
- `pLoopTeam:IsAlive()`
- `pTeam:IsAlive()`
- 6 callsites. Example: `UI/InGame/Popups/VoteResultsPopup.lua:215`

### IsAllowEmbassyTradingAllowed
- `g_pThemTeam:IsAllowEmbassyTradingAllowed()`
- `g_pUsTeam:IsAllowEmbassyTradingAllowed()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:1133`

### IsAllowsOpenBordersToTeam
- `g_pUsTeam:IsAllowsOpenBordersToTeam(g_iThemTeam)`
- `pTeam:IsAllowsOpenBordersToTeam(g_iTeam)`
- `g_pTeam:IsAllowsOpenBordersToTeam(iTeam)`
- 10 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1093`

### IsAtWar
- `g_pTeam:IsAtWar(iOtherTeam)`
- `pTeam:IsAtWar(iOtherTeam)`
- `g_pUsTeam:IsAtWar(g_iThemTeam)`
- `pActiveTeam:IsAtWar(g_iAITeam)`
- `g_pTeam:IsAtWar(pOtherPlayer:GetTeam())`
- ...and 19 more distinct call shapes
- 118 callsites. Example: `UI/InGame/DiploList.lua:167`

### IsDefensivePact
- `g_pUsTeam:IsDefensivePact(g_iThemTeam)`
- `g_pTeam:IsDefensivePact(iTeam)`
- 5 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1135`

### IsDefensivePactTradingAllowed
- `g_pUsTeam:IsDefensivePactTradingAllowed()`
- `g_pThemTeam:IsDefensivePactTradingAllowed()`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1133`

### IsEverAlive
- `pOtherTeam:IsEverAlive()`
- 3 callsites. Example: `UI/InGame/Popups/DiploVotePopup.lua:42`

### IsForcePeace
- `pActiveTeam:IsForcePeace(g_iAITeam)`
- `Teams[iFromTeam]:IsForcePeace(iLoopTeam)`
- 8 callsites. Example: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:187`

### IsHasMet
- `pTeam:IsHasMet(Game.GetActiveTeam())`
- `pTeam:IsHasMet(iOtherTeam)`
- `activeTeam:IsHasMet(pPlayer:GetTeam())`
- `g_pTeam:IsHasMet(iOtherTeam)`
- `g_pUsTeam:IsHasMet(iThirdTeam)`
- ...and 18 more distinct call shapes
- 146 callsites. Example: `UI/InGame/Popups/Demographics.lua:336`

### IsHasResearchAgreement
- `g_pUsTeam:IsHasResearchAgreement(g_iThemTeam)`
- `g_pTeam:IsHasResearchAgreement(iTeam)`
- 5 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1189`

### IsHasTech
- `pTeam:IsHasTech(techID)`
- `team:IsHasTech(techID)`
- `pTeam:IsHasTech(GameInfoTypes["TECH_EXPLORATION"])`
- `Teams[iTeam]:IsHasTech(iTech)`
- `pTeam:IsHasTech(GameInfoTypes["TECH_LINE_OF_BATTLE"])`
- ...and 1 more distinct call shapes
- 12 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:1017`

### IsHasTradeAgreement
- `g_pUsTeam:IsHasTradeAgreement(g_iThemTeam)`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1237`

### IsHomeOfUnitedNations
- `pTeam:IsHomeOfUnitedNations()`
- 8 callsites. Example: `UI/InGame/Popups/VoteResultsPopup.lua:154`

### IsHuman
- `pTeam:IsHuman()`
- `pOtherTeam:IsHuman()`
- `Teams[eRivalTeam]:IsHuman()`
- 14 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VoteResultsPopup.lua:204`

### IsMinorCiv
- `pTeam:IsMinorCiv()`
- `Teams[eRivalTeam]:IsMinorCiv()`
- `pLoopTeam:IsMinorCiv()`
- `Teams[eTeamMet]:IsMinorCiv()`
- 47 callsites. Example: `UI/InGame/Popups/VoteResultsPopup.lua:35`

### IsOpenBordersTradingAllowed
- `g_pUsTeam:IsOpenBordersTradingAllowed()`
- `g_pThemTeam:IsOpenBordersTradingAllowed()`
- `Teams[Game.GetActiveTeam()]:IsOpenBordersTradingAllowed()`
- 7 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1080`

### IsOpenBordersTradingAllowedWithTeam
- `Teams[Game.GetActiveTeam()]:IsOpenBordersTradingAllowedWithTeam(plot:GetTeam())`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/DeclareWarPopup.lua:673`

### IsResearchAgreementTradingAllowed
- `g_pUsTeam:IsResearchAgreementTradingAllowed()`
- `g_pThemTeam:IsResearchAgreementTradingAllowed()`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1187`

### IsTradeAgreementTradingAllowed
- `g_pUsTeam:IsTradeAgreementTradingAllowed()`
- `g_pThemTeam:IsTradeAgreementTradingAllowed()`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1235`

### Meet
- `pTeam:Meet(vaticanTeamID, true)`
- `pTeam:Meet(meccaTeamID, true)`
- `pTeam:Meet(byzantineTeamID, true)`
- `pTeam:Meet(jerusalemTeamID, true)`
- `pTeam:Meet(iOtherTeam)`
- 13 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:984`

### SetHasTech
- `pTeam:SetHasTech(iTechIndex, true)`
- `pTeam:SetHasTech(iScientificMethodIndex, true)`
- 2 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1269`

### UpdateEmbarkGraphics
- `Teams[iTeamID]:UpdateEmbarkGraphics()`
- 2 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1781`

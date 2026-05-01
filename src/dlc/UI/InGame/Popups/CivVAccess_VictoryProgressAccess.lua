-- Victory Progress accessibility (F8 / Who is winning). Wraps the engine
-- VictoryProgress popup as a single BaseMenu landing page: the cross-civ
-- score ranking populates the top of the list, then five Group items
-- (My Score, Domination, Science, Diplomatic, Cultural) drill into per-
-- victory-condition flat lists. Right or Enter on a Group drills in;
-- Left walks back up; Esc closes the popup outright; F8 toggles it shut
-- (matches the engine's own Data1==1 toggle behavior).
--
-- Strict vanilla parity per section: every line corresponds to something
-- the vanilla F8 main panel or its detail subscreen shows. Diplomatic has
-- no per-civ list because vanilla's was commented out; Cultural reports
-- influence percent (the engine grid's tooltip) without trend or turns-
-- to-influential, since those live on CultureOverview, not F8.
--
-- Top-level rows rebuild on every show via onShow -> setItems so the
-- score ranking tracks the engine across turn ends. Section Group items
-- carry cached=false so each drill rebuilds its child list from a fresh
-- query (matches the no-cache rule).
--
-- Engine integration: ships an override of VictoryProgress.lua (verbatim
-- BNW copy + an include for this module). The engine's OnPopup, OnBack,
-- ShowHideHandler, InputHandler, and GameplaySetActivePlayer wiring stay
-- intact; BaseMenu.install layers our handler on top via priorInput /
-- priorShowHide chains.

include("CivVAccess_PopupBoot")
include("CivVAccess_OverviewCivLabels")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

VictoryProgressAccess = VictoryProgressAccess or {}

-- ===== Player / team helpers ==========================================

local activePlayerId = OverviewCivLabels.activePlayerId
local activeTeamId = OverviewCivLabels.activeTeamId
local isMP = OverviewCivLabels.isMP
local playerHasMet = OverviewCivLabels.playerHasMet
local civDisplayName = OverviewCivLabels.civDisplayName

-- Strip trailing colon + whitespace so engine label strings ("Delegates you
-- Control:") concatenate cleanly into "Label, value" speech lines.
local function stripColon(s)
    if s == nil then
        return ""
    end
    return (s):gsub(":%s*$", "")
end

-- Civilopedia search string for a civ row's leader article. Nil when the
-- target has no useful pedia entry: the active player (the user's own
-- leader) and unmet civs (placeholder name, no concrete leader to look
-- up). Mirrors WhosWinningPopupAccess's hookup convention.
local function leaderPediaNameFor(pPlayer)
    if pPlayer:GetID() == activePlayerId() then
        return nil
    end
    if not playerHasMet(pPlayer) then
        return nil
    end
    return Text.key(GameInfo.Leaders[pPlayer:GetLeaderType()].Description)
end

-- Iterator over major civs that have ever been alive in the game (returns
-- (id, pPlayer) pairs). Vanilla VictoryProgress filters every list by
-- IsMinorCiv==false and IsEverAlive==true; we centralize that.
local function eachMajorEverAlive()
    local i = -1
    return function()
        while true do
            i = i + 1
            if i >= GameDefines.MAX_CIV_PLAYERS then
                return nil
            end
            local p = Players[i]
            if p ~= nil and not p:IsMinorCiv() and p:IsEverAlive() then
                return i, p
            end
        end
    end
end

-- ===== Score list (landing page top) ===================================

-- Per-row text for the cross-civ score ranking. Mirrors vanilla
-- PopulateScoreScreen but speaks "name, score N" / "name, score N, capital
-- lost" instead of vanilla's visual gray-out + sword overlay.
local function scoreRowText(rank, pPlayer)
    local rankPrefix = Text.format("TXT_KEY_NUMBERING_FORMAT", rank)
    local name = rankPrefix .. " " .. civDisplayName(pPlayer)
    local score = pPlayer:GetScore()
    if pPlayer:IsHasLostCapital() then
        return Text.format("TXT_KEY_CIVVACCESS_VP_SCORE_ROW_LOST", name, score)
    end
    return Text.format("TXT_KEY_CIVVACCESS_VP_SCORE_ROW", name, score)
end

local function buildScoreRowItems()
    local players = {}
    for id, _ in eachMajorEverAlive() do
        players[#players + 1] = id
    end
    table.sort(players, function(a, b)
        return Players[b]:GetScore() < Players[a]:GetScore()
    end)
    local items = {}
    for rank, id in ipairs(players) do
        local pPlayer = Players[id]
        items[#items + 1] = BaseMenuItems.Text({
            labelText = scoreRowText(rank, pPlayer),
            pediaName = leaderPediaNameFor(pPlayer),
        })
    end
    return items
end

-- ===== My Score section ================================================

-- One key/value Text item for a score component. Hidden when the gating
-- option suppresses it (no-science strips Tech / Future Tech, no-policies
-- strips Policies, no-religion strips Religion).
local function scoreLine(labelKey, valueFn)
    return BaseMenuItems.Text({
        labelFn = function()
            return Text.format(
                "TXT_KEY_CIVVACCESS_VP_LABEL_VALUE",
                stripColon(Text.key(labelKey)),
                valueFn()
            )
        end,
    })
end

local function remainingTurns()
    local r = Game.GetMaxTurns() - Game.GetElapsedGameTurns()
    if r < 0 then
        r = 0
    end
    return r
end

local function buildMyScoreItems()
    if not PreGame.IsVictory(GameInfo.Victories["VICTORY_TIME"].ID) then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_VP_TIME_VICTORY_DISABLED"),
            }),
        }
    end
    local p = Players[activePlayerId()]
    local items = {
        scoreLine("TXT_KEY_VP_CITIES", function() return p:GetScoreFromCities() end),
        scoreLine("TXT_KEY_VP_POPULATION", function() return p:GetScoreFromPopulation() end),
        scoreLine("TXT_KEY_VP_LAND", function() return p:GetScoreFromLand() end),
        scoreLine("TXT_KEY_VP_WONDERS", function() return p:GetScoreFromWonders() end),
    }
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
        items[#items + 1] = scoreLine("TXT_KEY_VP_TECH", function() return p:GetScoreFromTechs() end)
        items[#items + 1] = scoreLine("TXT_KEY_VP_FUTURE_TECH", function() return p:GetScoreFromFutureTech() end)
    end
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES) then
        items[#items + 1] = scoreLine("TXT_KEY_VP_POLICIES", function() return p:GetScoreFromPolicies() end)
    end
    items[#items + 1] = scoreLine("TXT_KEY_VP_GREAT_WORKS", function() return p:GetScoreFromGreatWorks() end)
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
        items[#items + 1] = scoreLine("TXT_KEY_VP_RELIGION", function() return p:GetScoreFromReligion() end)
    end
    if PreGame.GetLoadWBScenario() then
        items[#items + 1] = scoreLine("TXT_KEY_VP_SCENARIO1", function() return p:GetScoreFromScenario1() end)
        items[#items + 1] = scoreLine("TXT_KEY_VP_SCENARIO2", function() return p:GetScoreFromScenario2() end)
        items[#items + 1] = scoreLine("TXT_KEY_VP_SCENARIO3", function() return p:GetScoreFromScenario3() end)
        items[#items + 1] = scoreLine("TXT_KEY_VP_SCENARIO4", function() return p:GetScoreFromScenario4() end)
    end
    items[#items + 1] = scoreLine("TXT_KEY_VP_SCORE", function() return p:GetScore() end)
    items[#items + 1] = scoreLine("TXT_KEY_VP_TURNS", remainingTurns)
    return items
end

-- ===== Domination section ==============================================

-- Compute the leading team and the "who controls whose original capital"
-- map in a single pass over teams. Mirrors vanilla's two-loop structure:
-- per team count majors and held capitals, then walk all major civs and
-- attribute each original capital to its current owning player. The
-- iLeadingNumCapitals - iLeadingNumPlayersOnTeam comparison rewards solo
-- conquerors over teammates dividing capitals.
local function dominationState()
    local aiCapitalOwner = {}
    local iLeadingTeam = -1
    local iLeadingNumCapitals = 0
    local iLeadingNumPlayersOnTeam = 0
    local iLeadingPlayer = -1
    local bAnyoneLostCapital = false

    for iTeam = 0, GameDefines.MAX_CIV_TEAMS - 1 do
        local iNumCapitals = 0
        local iNumPlayersOnTeam = 0
        local iPlayerOnTeam = -1
        for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
            local p = Players[iPlayer]
            if p ~= nil and not p:IsMinorCiv() and p:IsEverAlive() and p:GetTeam() == iTeam then
                if p:IsHasLostCapital() then
                    bAnyoneLostCapital = true
                end
                iPlayerOnTeam = iPlayer
                iNumPlayersOnTeam = iNumPlayersOnTeam + 1
                for pCity in p:Cities() do
                    if pCity:IsOriginalMajorCapital() then
                        iNumCapitals = iNumCapitals + 1
                        aiCapitalOwner[pCity:GetOriginalOwner()] = iPlayer
                    end
                end
            end
        end
        if (iNumCapitals - iNumPlayersOnTeam) > (iLeadingNumCapitals - iLeadingNumPlayersOnTeam) then
            iLeadingTeam = iTeam
            iLeadingNumCapitals = iNumCapitals
            iLeadingNumPlayersOnTeam = iNumPlayersOnTeam
            iLeadingPlayer = iPlayerOnTeam
        end
    end

    return {
        capitalOwner = aiCapitalOwner,
        leadingTeam = iLeadingTeam,
        leadingNumCapitals = iLeadingNumCapitals,
        leadingNumPlayersOnTeam = iLeadingNumPlayersOnTeam,
        leadingPlayer = iLeadingPlayer,
        anyoneLostCapital = bAnyoneLostCapital,
    }
end

-- Leading-team summary string. Returns nil for the rare case (vanilla's
-- "weird circumstance" branch) where someone lost a capital but no team is
-- ahead — vanilla hides the label there; we omit the row.
local function dominationLeadingLine(state)
    if state.leadingTeam == -1 then
        if state.anyoneLostCapital then
            return nil
        end
        return Text.key("TXT_KEY_VP_DIPLO_NEW_CAPITALS_REMAINING")
    end
    if state.leadingNumPlayersOnTeam > 1 then
        return Text.format(
            "TXT_KEY_VP_DIPLO_CAPITALS_TEAM_LEADING",
            state.leadingTeam + 1,
            state.leadingNumCapitals
        )
    end
    if state.leadingPlayer == activePlayerId() then
        return Text.format(
            "TXT_KEY_VP_DIPLO_CAPITALS_ACTIVE_PLAYER_LEADING",
            state.leadingNumCapitals
        )
    end
    local pLeader = Players[state.leadingPlayer]
    local activeT = Teams[activeTeamId()]
    if pLeader:GetNickName() ~= "" and pLeader:IsHuman() then
        return Text.format(
            "TXT_KEY_VP_DIPLO_CAPITALS_PLAYER_LEADING",
            pLeader:GetNickName(),
            state.leadingNumCapitals
        )
    end
    if not activeT:IsHasMet(pLeader:GetTeam()) then
        return Text.format(
            "TXT_KEY_VP_DIPLO_CAPITALS_UNMET_PLAYER_LEADING",
            state.leadingNumCapitals
        )
    end
    return Text.format(
        "TXT_KEY_VP_DIPLO_CAPITALS_PLAYER_LEADING",
        pLeader:GetName(),
        state.leadingNumCapitals
    )
end

-- Per-civ capital sentence. Picks one of vanilla's TT_* tooltip strings
-- based on (active-player? known? has lost capital? known dominator?)
-- combinations. The TT_* strings already read as full sentences so we use
-- them directly — same content vanilla shows in its hover tooltip.
local function dominationCivSentence(pPlayer, dominatingPlayerId)
    local iPlayer = pPlayer:GetID()
    local hasMetSubject = playerHasMet(pPlayer)

    -- Find the original capital city object once for sentences that need
    -- the city name. May be nil if the civ never founded one or every
    -- copy was razed without surviving to a new owner; vanilla returns
    -- "no capital" sentences in that case.
    local function findOriginalCapital(pHolder)
        for pCity in pHolder:Cities() do
            if pCity:IsOriginalMajorCapital() and pCity:GetOriginalOwner() == iPlayer then
                return pCity
            end
        end
        return nil
    end

    if dominatingPlayerId == nil then
        if iPlayer == activePlayerId() then
            return Text.key("TXT_KEY_VP_DIPLO_TT_YOU_NO_CAPITAL")
        end
        if hasMetSubject then
            local name
            if isMP() and pPlayer:GetNickName() ~= "" then
                name = pPlayer:GetNickName()
            else
                name = pPlayer:GetName()
            end
            return Text.format("TXT_KEY_VP_DIPLO_TT_KNOWN_NO_CAPITAL", name)
        end
        return Text.key("TXT_KEY_VP_DIPLO_TT_UNKNOWN_NO_CAPITAL")
    end

    local pDominator = Players[dominatingPlayerId]
    local iDominator = pDominator:GetID()
    local dominatorMet = Teams[pDominator:GetTeam()]:IsHasMet(activeTeamId()) or isMP()

    -- Subject still holds their own original capital.
    if iPlayer == iDominator then
        if not hasMetSubject then
            return Text.key("TXT_KEY_VP_DIPLO_TT_UNMET_CONTROLS_THEIR_CAPITAL")
        end
        local capital = findOriginalCapital(pPlayer)
        local capName = capital ~= nil and capital:GetNameKey() or ""
        if iPlayer == activePlayerId() then
            return Text.format("TXT_KEY_VP_DIPLO_TT_YOU_CONTROL_YOUR_CAPITAL", capName)
        end
        local subjectName
        if isMP() and pPlayer:GetNickName() ~= "" then
            subjectName = pPlayer:GetNickName()
        else
            subjectName = pPlayer:GetName()
        end
        return Text.format(
            "TXT_KEY_VP_DIPLO_TT_SOMEONE_CONTROLS_THEIR_CAPITAL",
            subjectName,
            capName
        )
    end

    -- Subject's original capital is held by someone else.
    local capital = findOriginalCapital(pDominator)
    local capName = capital ~= nil and capital:GetNameKey() or ""
    if hasMetSubject and dominatorMet then
        if iPlayer == activePlayerId() then
            local domName
            if isMP() and pDominator:GetNickName() ~= "" then
                domName = pDominator:GetNickName()
            else
                domName = pDominator:GetName()
            end
            return Text.format(
                "TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_YOUR_CAPITAL",
                domName,
                capName
            )
        end
        if iDominator == activePlayerId() then
            return Text.format(
                "TXT_KEY_VP_DIPLO_TT_YOU_CONTROL_OTHER_PLAYER_CAPITAL",
                capName,
                pPlayer:GetCivilizationShortDescriptionKey()
            )
        end
        local domName
        if isMP() and pDominator:GetNickName() ~= "" then
            domName = pDominator:GetNickName()
        else
            domName = pDominator:GetName()
        end
        return Text.format(
            "TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_OTHER_PLAYER_CAPITAL",
            domName,
            capName,
            pPlayer:GetCivilizationShortDescriptionKey()
        )
    end
    if hasMetSubject and not dominatorMet then
        return Text.format(
            "TXT_KEY_VP_DIPLO_TT_UNMET_PLAYER_CONTROLS_OTHER_PLAYER_CAPITAL",
            capName,
            pPlayer:GetCivilizationShortDescriptionKey()
        )
    end
    if dominatorMet then
        local domName
        if isMP() and pDominator:GetNickName() ~= "" then
            domName = pDominator:GetNickName()
        else
            domName = pDominator:GetName()
        end
        return Text.format(
            "TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_UNMET_PLAYER_CAPITAL",
            domName
        )
    end
    return Text.key("TXT_KEY_VP_DIPLO_TT_UNMET_PLAYER_CONTROLS_UNMET_PLAYER_CAPITAL")
end

-- Count of capitals held by each major civ (the post-conquest aggregate
-- vanilla doesn't surface but we sort by since the user asked for sort
-- order matching the section's metric).
local function capitalsHeldByPlayer(state, iPlayer)
    local count = 0
    for ownedBy in pairs(state.capitalOwner) do
        if state.capitalOwner[ownedBy] == iPlayer then
            count = count + 1
        end
    end
    return count
end

-- Append a "(team N)" suffix when the civ is on a multi-member team, so
-- the speech distinguishes teammates the way vanilla's grid does with the
-- "Team 1" labels under each icon.
local function appendTeamSuffix(line, pPlayer)
    local pTeam = Teams[pPlayer:GetTeam()]
    if pTeam:GetNumMembers() <= 1 then
        return line
    end
    return line .. ", " .. Text.format("TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX", pPlayer:GetTeam() + 1)
end

local function buildDominationItems()
    if not PreGame.IsVictory(GameInfo.Victories["VICTORY_DOMINATION"].ID) then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_VP_DOMINATION_VICTORY_DISABLED"),
            }),
        }
    end
    local state = dominationState()
    local items = {}
    local leading = dominationLeadingLine(state)
    if leading ~= nil and leading ~= "" then
        items[#items + 1] = BaseMenuItems.Text({ labelText = leading })
    end

    -- Sort: civs whose original capital is currently held by themselves go
    -- last (they aren't conquering anyone); among "leaders," sort by total
    -- capitals held descending. For civs whose capital is held by another
    -- player, fall through to order by player ID as a stable tiebreak.
    local rows = {}
    for id, _ in eachMajorEverAlive() do
        rows[#rows + 1] = id
    end
    table.sort(rows, function(a, b)
        local heldA = capitalsHeldByPlayer(state, a)
        local heldB = capitalsHeldByPlayer(state, b)
        if heldA ~= heldB then
            return heldA > heldB
        end
        return a < b
    end)

    for _, id in ipairs(rows) do
        local pPlayer = Players[id]
        local sentence = dominationCivSentence(pPlayer, state.capitalOwner[id])
        sentence = appendTeamSuffix(sentence, pPlayer)
        items[#items + 1] = BaseMenuItems.Text({
            labelText = sentence,
            pediaName = leaderPediaNameFor(pPlayer),
        })
    end
    return items
end

-- ===== Science section =================================================

-- Apollo prereq tech set, computed once at file-load (the dependency tree
-- doesn't change mid-game). Mirrors vanilla's recursive GetPreReqs walk.
local g_TechPreReqList = {}
local g_TechPreReqSet = {}

local function collectPrereqs(techType)
    if g_TechPreReqSet[techType] ~= nil then
        return
    end
    g_TechPreReqSet[techType] = true
    g_TechPreReqList[#g_TechPreReqList + 1] = techType
    for row in GameInfo.Technology_PrereqTechs{TechType = techType} do
        collectPrereqs(row.PrereqTech)
    end
end

if GameInfo.Projects ~= nil and GameInfo.Projects["PROJECT_APOLLO_PROGRAM"] ~= nil then
    collectPrereqs(GameInfo.Projects["PROJECT_APOLLO_PROGRAM"].TechPrereq)
end

local function activeTeamPrereqsResearched()
    local pTeam = Teams[activeTeamId()]
    local got = 0
    for _, t in ipairs(g_TechPreReqList) do
        local tech = GameInfo.Technologies[t]
        if tech ~= nil and pTeam:IsHasTech(tech.ID) then
            got = got + 1
        end
    end
    return got, #g_TechPreReqList
end

-- Engine project thresholds: 3 boosters, 1 cockpit, 1 stasis chamber, 1
-- engine in BNW vanilla (see XML Project_VictoryThresholds). Re-query
-- per call so a Mod altering thresholds is honored.
local function projectThreshold(typeKey)
    local row = GameInfo.Project_VictoryThresholds{ProjectType = typeKey}()
    return row ~= nil and row.Threshold or 0
end

local function teamPartCount(pTeam, projTypeKey)
    local proj = GameInfoTypes[projTypeKey]
    if proj == nil or proj == -1 then
        return 0, 0
    end
    local threshold = projectThreshold(projTypeKey)
    local built = pTeam:GetProjectCount(proj)
    if built > threshold then
        built = threshold
    end
    return built, threshold
end

-- Produce a comma-joined list of built parts ("2 boosters, cockpit").
-- Returns nil if no parts are built. Booster count is always announced as
-- a number; cockpit / chamber / engine are present-or-absent (their
-- threshold is 1 in vanilla so a count word would be redundant).
local function partsBuiltSummary(pTeam)
    local parts = {}
    local boosters = teamPartCount(pTeam, "PROJECT_SS_BOOSTER")
    if boosters > 0 then
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS", boosters, boosters)
    end
    local cockpit = teamPartCount(pTeam, "PROJECT_SS_COCKPIT")
    if cockpit > 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT")
    end
    local chamber = teamPartCount(pTeam, "PROJECT_SS_STASIS_CHAMBER")
    if chamber > 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER")
    end
    local engine = teamPartCount(pTeam, "PROJECT_SS_ENGINE")
    if engine > 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE")
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ", ")
end

-- Returns (apolloBuilt, totalParts) for sort comparison. totalParts counts
-- threshold-clamped parts (so a hypothetical mod allowing extras doesn't
-- make a player out-rank a fully-built spaceship just by spamming).
local function teamApolloAndParts(pTeam)
    local apolloProj = GameInfoTypes["PROJECT_APOLLO_PROGRAM"]
    local apolloBuilt = apolloProj ~= nil and apolloProj ~= -1 and pTeam:GetProjectCount(apolloProj) >= 1
    local count = 0
    count = count + teamPartCount(pTeam, "PROJECT_SS_BOOSTER")
    count = count + teamPartCount(pTeam, "PROJECT_SS_COCKPIT")
    count = count + teamPartCount(pTeam, "PROJECT_SS_STASIS_CHAMBER")
    count = count + teamPartCount(pTeam, "PROJECT_SS_ENGINE")
    return apolloBuilt, count
end

local function scienceCivLine(pPlayer)
    local pTeam = Teams[pPlayer:GetTeam()]
    local apollo, _ = teamApolloAndParts(pTeam)
    local name = civDisplayName(pPlayer)
    if not apollo then
        return Text.format("TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO", name)
    end
    local parts = partsBuiltSummary(pTeam)
    if parts == nil then
        return Text.format("TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE", name)
    end
    return Text.format("TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS", name, parts)
end

local function buildScienceItems()
    if not PreGame.IsVictory(GameInfo.Victories["VICTORY_SPACE_RACE"].ID) then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_VP_SCIENCE_VICTORY_DISABLED"),
            }),
        }
    end

    local items = {}

    -- Active team's progress: mirrors vanilla's main panel. Pre-Apollo
    -- shows prereq fraction; post-Apollo shows the parts list (we omit
    -- a "no parts" line there since it duplicates the per-civ row that
    -- follows for the active player anyway).
    local pTeam = Teams[activeTeamId()]
    local apolloProj = GameInfoTypes["PROJECT_APOLLO_PROGRAM"]
    if apolloProj ~= nil and apolloProj ~= -1 then
        if pTeam:GetProjectCount(apolloProj) >= 1 then
            local parts = partsBuiltSummary(pTeam)
            if parts == nil then
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"),
                })
            else
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.format("TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS", parts),
                })
            end
        else
            local got, total = activeTeamPrereqsResearched()
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.formatPlural("TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS", total, got, total),
            })
        end

        -- Count of teams that have built Apollo. Mirrors vanilla's
        -- TXT_KEY_VP_DIPLO_PROJECT_PLAYERS_COMPLETE line under the icon.
        local numApollo = 0
        for _, v in pairs(Teams) do
            if v.GetProjectCount and v:GetProjectCount(apolloProj) >= 1 then
                numApollo = numApollo + 1
            end
        end
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.format(
                "TXT_KEY_VP_DIPLO_PROJECT_PLAYERS_COMPLETE",
                numApollo,
                "TXT_KEY_PROJECT_APOLLO_PROGRAM"
            ),
        })
    end

    -- Per-civ rows sorted by Apollo first, then parts count, then player ID
    -- as stable tiebreak. Mirrors vanilla CompareSpaceRace.
    local rows = {}
    for id, _ in eachMajorEverAlive() do
        rows[#rows + 1] = id
    end
    table.sort(rows, function(a, b)
        local apolloA, partsA = teamApolloAndParts(Teams[Players[a]:GetTeam()])
        local apolloB, partsB = teamApolloAndParts(Teams[Players[b]:GetTeam()])
        if apolloA ~= apolloB then
            return apolloA
        end
        if partsA ~= partsB then
            return partsA > partsB
        end
        return a < b
    end)
    for _, id in ipairs(rows) do
        local pPlayer = Players[id]
        items[#items + 1] = BaseMenuItems.Text({
            labelText = scienceCivLine(pPlayer),
            pediaName = leaderPediaNameFor(pPlayer),
        })
    end

    return items
end

-- ===== Diplomatic section ==============================================

local function buildDiplomaticItems()
    local victoryInfo = GameInfo.Victories["VICTORY_DIPLOMATIC"]
    if victoryInfo == nil or not PreGame.IsVictory(victoryInfo.ID) then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_VP_DIPLO_VICTORY_DISABLED"),
            }),
        }
    end

    -- Already won? Vanilla collapses to a single line.
    if Game.GetVictory() == victoryInfo.ID then
        local pTeam = Teams[Game.GetWinner()]
        local pLeader = Players[pTeam:GetLeaderID()]
        local name
        if isMP() and pLeader:GetNickName() ~= "" and pLeader:IsHuman() then
            name = pLeader:GetNickName()
        else
            name = Text.key(pLeader:GetNameKey())
        end
        return {
            BaseMenuItems.Text({
                labelText = Text.format("TXT_KEY_VP_DIPLO_SOMEONE_WON", name),
            }),
        }
    end

    -- Three states with distinct speech, diverging from vanilla which
    -- conflates the first two and shows "0 of 12 delegates" against a
    -- mechanic that doesn't yet exist:
    --   1. No League exists -> just the inactive line. Voting hasn't
    --      started, so delegate counts would be misleading noise.
    --   2. League exists, UN not active -> inactive line + delegates,
    --      since voting is live in the World Congress phase even though
    --      the UN-specific World Leader proposal isn't unlocked yet.
    --   3. UN active -> active line + turns until next victory session
    --      + delegates.
    local items = {}
    local pLeague = nil
    if Game.GetNumActiveLeagues() > 0 then
        pLeague = Game.GetActiveLeague()
    end

    if pLeague == nil then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_VP_DIPLO_UN_INACTIVE"),
        })
        return items
    end

    if Game.IsUnitedNationsActive() then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_VP_DIPLO_UN_ACTIVE"),
        })
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.format(
                "TXT_KEY_CIVVACCESS_VP_LABEL_VALUE",
                stripColon(Text.key("TXT_KEY_VP_DIPLO_TURNS_UNTIL_SESSION")),
                pLeague:GetTurnsUntilVictorySession()
            ),
        })
    else
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_VP_DIPLO_UN_INACTIVE"),
        })
    end

    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.format(
            "TXT_KEY_CIVVACCESS_VP_LABEL_VALUE",
            stripColon(Text.key("TXT_KEY_VP_DIPLO_DELEGATES_CONTROLLED")),
            pLeague:CalculateStartingVotesForMember(activePlayerId())
        ),
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.format(
            "TXT_KEY_CIVVACCESS_VP_LABEL_VALUE",
            stripColon(Text.key("TXT_KEY_VP_DIPLO_DELEGATES_NEEDED")),
            Game.GetVotesNeededForDiploVictory()
        ),
    })

    return items
end

-- ===== Cultural section ================================================

local function influencePercentOf(otherPlayerId)
    local p = Players[activePlayerId()]
    local other = Players[otherPlayerId]
    local culture = other:GetJONSCultureEverGenerated()
    if culture <= 0 then
        return 0
    end
    return (p:GetInfluenceOn(otherPlayerId) / culture) * 100
end

local function buildCulturalItems()
    local cultureVictory = GameInfo.Victories["VICTORY_CULTURAL"]
    if cultureVictory == nil or not PreGame.IsVictory(cultureVictory.ID) then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_VP_CULTURE_VICTORY_DISABLED"),
            }),
        }
    end

    -- Vanilla's cultural grid excludes the active player (you don't influence
    -- yourself). Sort the rest by influence percent descending so the closest-
    -- to-Influential opponents are first.
    local rows = {}
    for id, _ in eachMajorEverAlive() do
        if id ~= activePlayerId() then
            rows[#rows + 1] = id
        end
    end
    table.sort(rows, function(a, b)
        return influencePercentOf(a) > influencePercentOf(b)
    end)

    local items = {}
    for _, id in ipairs(rows) do
        local pOther = Players[id]
        local pct = influencePercentOf(id)
        local key
        if playerHasMet(pOther) then
            key = "TXT_KEY_VP_CULTURE_INFLUENCE"
        else
            key = "TXT_KEY_VP_CULTURE_INFLUENCE_UNMET"
        end
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.format(key, pct, pOther:GetCivilizationShortDescriptionKey()),
            pediaName = leaderPediaNameFor(pOther),
        })
    end
    return items
end

-- ===== Section group factory ==========================================

-- pediaKey routes Ctrl+I to the section's matching Civilopedia concept
-- article. The text-key form is what searchableTextKeyList is indexed by
-- (CivilopediaScreen.lua:283 indexes Concepts by Description).
local function sectionGroup(buttonKey, builder, pediaKey)
    return BaseMenuItems.Group({
        labelText = Text.key(buttonKey),
        cached = false,
        itemsFn = builder,
        pediaName = pediaKey,
    })
end

-- ===== Landing-page items ==============================================

local function buildLandingItems()
    local items = buildScoreRowItems()
    items[#items + 1] = sectionGroup("TXT_KEY_CIVVACCESS_VP_BUTTON_MY_SCORE", buildMyScoreItems,
        "TXT_KEY_VICTORY_2050ARRIVES_HEADING3_TITLE")
    items[#items + 1] = sectionGroup("TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION", buildDominationItems,
        "TXT_KEY_VICTORY_DOMINATION_HEADING3_TITLE")
    items[#items + 1] = sectionGroup("TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE", buildScienceItems,
        "TXT_KEY_VICTORY_SCIENCE_HEADING3_TITLE")
    items[#items + 1] = sectionGroup("TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC", buildDiplomaticItems,
        "TXT_KEY_VICTORY_DIPLOMATIC_HEADING3_TITLE")
    items[#items + 1] = sectionGroup("TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL", buildCulturalItems,
        "TXT_KEY_VICTORY_CULTURAL_HEADING3_TITLE")
    return items
end

-- ===== Module exports for tests ========================================

VictoryProgressAccess.scoreRowText = scoreRowText
VictoryProgressAccess.civDisplayName = civDisplayName
VictoryProgressAccess.dominationState = dominationState
VictoryProgressAccess.dominationLeadingLine = dominationLeadingLine
VictoryProgressAccess.dominationCivSentence = dominationCivSentence
VictoryProgressAccess.partsBuiltSummary = partsBuiltSummary
VictoryProgressAccess.influencePercentOf = influencePercentOf
VictoryProgressAccess.buildLandingItems = buildLandingItems
VictoryProgressAccess.stripColon = stripColon

-- ===== Install =========================================================

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    local handler = BaseMenu.install(ContextPtr, {
        name = "VictoryProgress",
        displayName = Text.key("TXT_KEY_VP_TITLE"),
        items = buildLandingItems(),
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        -- Re-source rows on every show so the score ranking, victory
        -- enable / disable state, and section content refresh against
        -- the engine. setItems also resets the cursor to the first
        -- navigable row, which is the rank-1 civ — the user's intended
        -- landing position.
        onShow = function(h)
            h.setItems(buildLandingItems())
        end,
    })

    -- F8 toggles the screen shut while open, matching the engine's own
    -- Data1==1 toggle behavior. Append a binding to the handler's array
    -- after install so it composes alongside the BaseMenu defaults.
    if handler ~= nil and type(handler.bindings) == "table" then
        handler.bindings[#handler.bindings + 1] = {
            key = Keys.VK_F8,
            mods = 0,
            description = "Close Victory Progress",
            fn = function()
                UIManager:DequeuePopup(ContextPtr)
            end,
        }
    end
end

-- Pure helpers for ChooseTechPopupAccess. Same split as ChooseProductionLogic:
-- this module has no ContextPtr / Events / InputHandler surface so offline
-- tests can exercise mode filtering, advisor compositing, and label shape
-- against stubbed Players / GameInfo / Game tables.

ChooseTechLogic = {}

-- Advisor icon order matches the sighted popup's AdvisorStack (TechPopup.xml
-- declares ScienceRecommendation / ForeignRecommendation / EconomicRecommendation
-- / MilitaryRecommendation). Engine ships full-sentence keys only; multi-advisor
-- techs read each sentence end-to-end.
ChooseTechLogic.ADVISORS = {
    { name = "ECONOMIC", key = "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_ECONOMIC" },
    { name = "MILITARY", key = "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_MILITARY" },
    { name = "SCIENCE",  key = "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_SCIENCE" },
    { name = "FOREIGN",  key = "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_FOREIGN" },
}

-- Requires Game.SetAdvisorRecommenderTech(playerID) to have been called before
-- Game.IsTechRecommended can answer correctly. Caller sets once per itemsFn.
-- Returns "" when no advisor recommends so callers can skip the separator.
function ChooseTechLogic.advisorSuffix(techID)
    local parts = {}
    for _, adv in ipairs(ChooseTechLogic.ADVISORS) do
        local t = AdvisorTypes["ADVISOR_" .. adv.name]
        if t ~= nil and Game.IsTechRecommended(techID, t) then
            parts[#parts + 1] = Text.key(adv.key)
        end
    end
    return table.concat(parts, " ")
end

-- Mode predicate. Mirrors TechPopup.lua's RefreshDisplay branches:
--   normal    -> player:CanResearch(id)
--   free      -> player:CanResearch(id) AND player:CanResearchForFree(id)
--   stealing  -> player:CanResearch(id) AND target team has it
-- CanResearch is the outer prereq/ownership gate for every mode; CanResearchForFree
-- alone admits techs the engine rejects at commit (silent no-op, user hears "gained X"
-- but nothing researched).
local function isEligible(player, tech, mode, targetTeam)
    local id = tech.ID
    if not player:CanResearch(id) then
        return false
    end
    if mode == "free" then
        return player:CanResearchForFree(id)
    end
    if mode == "stealing" then
        return targetTeam ~= nil and targetTeam:IsHasTech(id)
    end
    return true
end

-- Entries in vanilla GameInfo.Technologies iteration order. The currently-
-- researching tech is returned separately (second return value) so the
-- access layer can pin it as a Text item and skip it in the Choice list.
-- `stealingTargetID` is -1 outside stealing mode.
function ChooseTechLogic.buildEntries(playerID, mode, stealingTargetID)
    local player = Players[playerID]
    local current = player:GetCurrentResearch()
    local targetTeam = nil
    if mode == "stealing" and stealingTargetID ~= nil and stealingTargetID >= 0 then
        local opp = Players[stealingTargetID]
        if opp ~= nil then
            targetTeam = Teams[opp:GetTeam()]
        end
    end

    local entries = {}
    local currentEntry = nil
    for tech in GameInfo.Technologies() do
        if isEligible(player, tech, mode, targetTeam) then
            local queuePos = player:GetQueuePosition(tech.ID)
            if queuePos == -1 then
                queuePos = nil
            end
            local entry = {
                techID = tech.ID,
                info = tech,
                queuePosition = queuePos,
                isCurrent = (tech.ID == current),
                mode = mode,
            }
            if entry.isCurrent and mode ~= "normal" then
                currentEntry = entry
            else
                entries[#entries + 1] = entry
            end
        end
    end
    return entries, currentEntry
end

-- Dashed section dividers in engine help text ("-------------------------")
-- leak through TextFilter (which only strips bracket markup). Screen readers
-- announce runs of hyphens as "dash dash dash"; collapse them to a comma so
-- the surrounding sentences remain audibly separated.
function ChooseTechLogic.cleanHelpText(filteredHelp, techName)
    if filteredHelp == nil or filteredHelp == "" then
        return ""
    end
    local s = filteredHelp
    -- GetHelpTextForTech leads with the upper-cased tech name; drop it since
    -- we already led the label with the name in its natural case.
    if techName ~= nil and techName ~= "" then
        local upper = techName:upper()
        if s:sub(1, #upper) == upper then
            s = s:sub(#upper + 1)
        end
    end
    s = s:gsub("%-%-%-+", ",")
    s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("^,%s*", ""):gsub("%s+$", "")
    return s
end

-- Label composition. Order:
--   1. tech name          (distinguishing info leads)
--   2. status             (free / currently researching / queued N) when non-default
--   3. turns              ("N turns") when science > 0 and mode is not stealing
--   4. advisor suffix     (engine sentences, in ECONOMIC/MILITARY/SCIENCE/FOREIGN order)
--   5. cleaned help text  (cost / leads-to / unlocks prose)
-- Help text is appended last because it's the longest; the user can stop
-- listening once they hear the information they need. GetHelpTextForTech is
-- an engine global defined by TechHelpInclude (pulled in by the base file we
-- override), so it's reachable from our same-Context include.
function ChooseTechLogic.buildLabel(entry, player)
    local parts = { Text.key(entry.info.Description) }

    local statusKey
    if entry.mode == "free" then
        statusKey = "TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"
    elseif entry.isCurrent then
        statusKey = "TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"
    elseif entry.queuePosition ~= nil then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED", entry.queuePosition)
        statusKey = nil
    end
    if statusKey ~= nil then
        parts[#parts + 1] = Text.key(statusKey)
    end

    if player:GetScience() > 0 and entry.mode ~= "stealing" then
        parts[#parts + 1] = Text.format(
            "TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS",
            player:GetResearchTurnsLeft(entry.techID, true)
        )
    end

    local advisors = ChooseTechLogic.advisorSuffix(entry.techID)
    if advisors ~= "" then
        parts[#parts + 1] = advisors
    end

    local help = TextFilter.filter(GetHelpTextForTech(entry.techID))
    if help ~= "" then
        parts[#parts + 1] = ChooseTechLogic.cleanHelpText(help, Text.key(entry.info.Description))
    end

    return table.concat(parts, ", ")
end

return ChooseTechLogic

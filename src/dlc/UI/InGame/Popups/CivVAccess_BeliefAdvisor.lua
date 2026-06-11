-- Advisor-recommendation ranking for the belief pickers (Pantheon /
-- Reformation list and the religion founding / enhance slot drills).
-- Community Patch scores every offered belief (Game.ScoreBelief) and
-- decorates the three highest scores with gold / silver / bronze trophy
-- icons plus an advisor-recommendation tooltip, suppressed when the
-- player turned basic help off. Vanilla has no scoring (Game.ScoreBelief
-- unregistered), so every lookup misses there and labels stay bare.

BeliefAdvisor = {}

-- Map of beliefID -> localized label suffix for the offered list, empty
-- for unranked beliefs. Mirrors the vendor's ranking exactly: the three
-- highest scores in the list are the tier thresholds and ties share a
-- tier, so more than three beliefs can carry trophies.
function BeliefAdvisor.labelSuffixes(beliefIDs)
    local suffixes = {}
    if Game.ScoreBelief == nil or OptionsManager.IsNoBasicHelp() then
        return suffixes
    end
    local ePlayer = Game.GetActivePlayer()
    local scores = {}
    local rank1, rank2, rank3 = 0, 0, 0
    for _, beliefID in ipairs(beliefIDs) do
        local score = Game.ScoreBelief(ePlayer, beliefID)
        scores[beliefID] = score
        if score >= rank1 then
            rank3 = rank2
            rank2 = rank1
            rank1 = score
        elseif score >= rank2 then
            rank3 = rank2
            rank2 = score
        elseif score >= rank3 then
            rank3 = score
        end
    end
    for beliefID, score in pairs(scores) do
        if score >= rank1 then
            suffixes[beliefID] = Text.key("TXT_KEY_CIVVACCESS_ADVISOR_TROPHY_GOLD")
        elseif score >= rank2 then
            suffixes[beliefID] = Text.key("TXT_KEY_CIVVACCESS_ADVISOR_TROPHY_SILVER")
        elseif score >= rank3 then
            suffixes[beliefID] = Text.key("TXT_KEY_CIVVACCESS_ADVISOR_TROPHY_BRONZE")
        end
    end
    return suffixes
end

return BeliefAdvisor

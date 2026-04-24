-- Pure helpers for TechTreeAccess. No ContextPtr / Events surface so
-- offline tests can exercise status determination, landing-speech shape,
-- queue-row composition, and NavigableGraph wiring without dofiling the
-- install-side access file.
--
-- buildGraph caches adjacency at screen-open time. Engine-side tech data
-- (GameInfo.Technology_PrereqTechs, GridY, ID) is static across a session,
-- so memoization is safe; the NavigableGraph cursor still honors the
-- lambda-per-call contract at its abstraction level.
--
-- Status tokens describe the baseline game state (researched / current /
-- available / unavailable / locked), independent of mode. Mode-specific
-- rejection messages live in commitEligibility; the tree landing speech
-- does not filter by mode so browsing stays predictable across all three.

TechTreeLogic = {}

local function sortTechs(list)
    table.sort(list, function(a, b)
        if a.GridY ~= b.GridY then
            return a.GridY < b.GridY
        end
        return a.ID < b.ID
    end)
    return list
end

-- Build parent / child / root lookup tables from Technology_PrereqTechs.
-- Returns a config table ready for NavigableGraph.new.
function TechTreeLogic.buildGraph()
    local parentsByType = {}
    local childrenByType = {}
    for row in GameInfo.Technology_PrereqTechs() do
        local childTech = GameInfo.Technologies[row.TechType]
        local parentTech = GameInfo.Technologies[row.PrereqTech]
        if childTech ~= nil and parentTech ~= nil then
            parentsByType[childTech.Type] = parentsByType[childTech.Type] or {}
            parentsByType[childTech.Type][#parentsByType[childTech.Type] + 1] = parentTech
            childrenByType[parentTech.Type] = childrenByType[parentTech.Type] or {}
            childrenByType[parentTech.Type][#childrenByType[parentTech.Type] + 1] = childTech
        end
    end
    for _, list in pairs(parentsByType) do
        sortTechs(list)
    end
    for _, list in pairs(childrenByType) do
        sortTechs(list)
    end
    local roots = {}
    for tech in GameInfo.Technologies() do
        if parentsByType[tech.Type] == nil then
            roots[#roots + 1] = tech
        end
    end
    sortTechs(roots)
    return {
        getParents = function(tech)
            return parentsByType[tech.Type] or {}
        end,
        getChildren = function(tech)
            return childrenByType[tech.Type] or {}
        end,
        getRoots = function()
            return roots
        end,
        _roots = roots,
    }
end

-- Baseline status, ignoring mode. The tree shows every tech; the commit
-- path handles mode-specific eligibility separately.
function TechTreeLogic.statusKey(player, techID)
    local team = Teams[player:GetTeam()]
    if team:GetTeamTechs():HasTech(techID) then
        return "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"
    end
    if player:GetCurrentResearch() == techID then
        return "TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"
    end
    if player:CanResearch(techID) then
        return "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"
    end
    if player:CanEverResearch(techID) then
        return "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"
    end
    return "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"
end

-- Unlocks prose via the shared filterHelpText pipeline: converts
-- [NEWLINE] section breaks to commas, strips markup, drops the
-- upper-cased name prefix, and collapses dash-runs.
local function unlocksProse(techID, techName)
    return ChooseTechLogic.filterHelpText(GetHelpTextForTech(techID), techName)
end

-- Flat corpus for TypeAheadSearch. Each entry pairs a tech with the
-- search label "name, unlocks prose" (name only if prose is empty). The
-- pre-comma name segment gets TypeAheadSearch's inSegment=0 ranking so
-- matches on the tech name beat matches inside the unlocks text -- e.g.
-- typing "knight" ranks the tech literally named Knight (if one exists)
-- above Chivalry, which matches only via "Unlocks Knight" prose. Static
-- across a session, so built once at screen-open.
function TechTreeLogic.buildSearchCorpus()
    local out = {}
    for tech in GameInfo.Technologies() do
        local name = Text.key(tech.Description)
        local prose = unlocksProse(tech.ID, name)
        local label = (prose == "") and name or (name .. ", " .. prose)
        out[#out + 1] = { tech = tech, label = label }
    end
    return out
end

-- Seed the NavigableGraph cursor onto `tech` with a sibling list that
-- matches what the user would have if they'd arrived by NavigateDown from
-- the tech's first parent (or Left/Right across the root set when `tech`
-- is itself a root). Both the initial-cursor landing and the search-driven
-- landing use this so Left/Right behaves the same either way.
function TechTreeLogic.seedCursorSiblings(cursor, tech, graph)
    local parents = graph.getParents(tech)
    if #parents == 0 then
        cursor.moveToWithSiblings(tech, graph.getRoots())
    else
        cursor.moveToWithSiblings(tech, graph.getChildren(parents[1]))
    end
end

-- Tree-tab landing speech spoken on every arrow move. Order: name, status,
-- queue slot (if queued and not current), turns (if researchable and
-- science > 0), unlocks. Distinguishing info — the tech name — leads so
-- the user can key-spam past recognized entries.
function TechTreeLogic.buildLandingSpeech(techID, player)
    local info = GameInfo.Technologies[techID]
    local name = Text.key(info.Description)
    local parts = { name }

    local status = TechTreeLogic.statusKey(player, techID)
    parts[#parts + 1] = Text.key(status)

    local queuePos = player:GetQueuePosition(techID)
    local isCurrent = (status == "TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT")
    if queuePos > 1 and not isCurrent then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED", queuePos - 1)
    end

    local researched = (status == "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED")
    if not researched and player:GetScience() > 0 then
        parts[#parts + 1] =
            Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS", player:GetResearchTurnsLeft(techID, true))
    end

    local prose = unlocksProse(techID, name)
    if prose ~= "" then
        parts[#parts + 1] = prose
    end

    return table.concat(parts, ", ")
end

-- Rows for the queue tab: current research first (position 1), then each
-- queued item in engine-reported order. Empty when no tech is current and
-- nothing is queued.
function TechTreeLogic.buildQueueRows(player)
    local rows = {}
    for tech in GameInfo.Technologies() do
        local pos = player:GetQueuePosition(tech.ID)
        if pos ~= -1 then
            rows[#rows + 1] = { techID = tech.ID, info = tech, position = pos }
        end
    end
    table.sort(rows, function(a, b)
        return a.position < b.position
    end)
    return rows
end

-- Queue row speech. Name, "current" or "queued slot N", turns, unlocks.
-- Status is redundant here (position already implies current-vs-queued),
-- so it's omitted; that's the one composition difference from the tree
-- landing format the plan §Queue tab calls for.
function TechTreeLogic.buildQueueRowSpeech(row, player)
    local name = Text.key(row.info.Description)
    local parts = { name }
    if row.position == 1 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN")
    else
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED", row.position - 1)
    end
    if player:GetScience() > 0 then
        parts[#parts + 1] =
            Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS", player:GetResearchTurnsLeft(row.techID, true))
    end
    local prose = unlocksProse(row.techID, name)
    if prose ~= "" then
        parts[#parts + 1] = prose
    end
    return table.concat(parts, ", ")
end

-- Determine mode from live state: stealing target wins over free-tech
-- count wins over normal. stealingTargetID is the stock TechTree.lua
-- upvalue set by OnDisplay; pass -1 when not stealing.
function TechTreeLogic.currentMode(player, stealingTargetID)
    if stealingTargetID ~= nil and stealingTargetID >= 0 then
        return "stealing"
    end
    if player:GetNumFreeTechs() > 0 then
        return "free"
    end
    return "normal"
end

-- Commit gate. Returns (true, nil) when the engine will accept the call
-- and (false, rejectKey) when we should speak a rejection and skip
-- SendResearch entirely.
--
-- Normal mode allows techs whose prereqs are not yet met: Network.Send-
-- Research auto-queues unmet prereqs ahead of the requested tech (both
-- for Enter and Shift+Enter). Only HasTech (already researched) and
-- !CanEverResearch (locked — wrong civ, unique-per-civ taken) are hard
-- rejects in normal mode.
--
-- Free mode still needs CanResearch (outer gate) AND CanResearchForFree
-- (the engine silently rejects commits that miss the second check).
-- Stealing mode needs CanResearch AND the opponent team to actually
-- own the tech.
function TechTreeLogic.commitEligibility(player, techID, mode, stealingTargetID)
    local team = Teams[player:GetTeam()]
    if team:GetTeamTechs():HasTech(techID) then
        return false, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"
    end
    if not player:CanEverResearch(techID) then
        return false, "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"
    end
    if mode == "free" then
        if not player:CanResearch(techID) or not player:CanResearchForFree(techID) then
            return false, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"
        end
        return true, nil
    end
    if mode == "stealing" then
        if stealingTargetID == nil or stealingTargetID < 0 then
            return false, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"
        end
        if not player:CanResearch(techID) then
            return false, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"
        end
        local opp = Players[stealingTargetID]
        if opp == nil then
            return false, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"
        end
        local targetTeam = Teams[opp:GetTeam()]
        if not targetTeam:IsHasTech(techID) then
            return false, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"
        end
        return true, nil
    end
    return true, nil
end

-- Initial cursor: current research, else the first CanResearch tech in
-- (GridY, ID) order, else the first root. Engine guarantees at least one
-- root tech, so the triple fallback always terminates on something
-- speakable.
function TechTreeLogic.pickInitialCursor(player, graph)
    local current = player:GetCurrentResearch()
    if current ~= -1 then
        local info = GameInfo.Technologies[current]
        if info ~= nil then
            return info
        end
    end
    local sorted = {}
    for tech in GameInfo.Technologies() do
        sorted[#sorted + 1] = tech
    end
    sortTechs(sorted)
    for _, tech in ipairs(sorted) do
        if player:CanResearch(tech.ID) then
            return tech
        end
    end
    return graph._roots[1] or sorted[1]
end

return TechTreeLogic

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
        local turns = player:GetResearchTurnsLeft(techID, true)
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS", turns, turns)
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
        local turns = player:GetResearchTurnsLeft(row.techID, true)
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS", turns, turns)
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

-- ===== Grid mode =====
--
-- Grid mode walks the visual tech tree layout instead of the prereq DAG.
-- Each tech has GridX (era column) and GridY (row within the column).
-- byColumn groups techs by GridX, sorted ascending by GridY. Up / Down
-- walks that list at the cursor's column; Left / Right steps exactly one
-- column over and snaps to whichever tech in the adjacent column sits
-- nearest a caller-supplied "intended row" (so a sequence of horizontal
-- moves through ragged columns doesn't drift permanently away from the
-- row the user committed to with their last vertical move). Static across
-- a session.
function TechTreeLogic.buildGrid()
    local byColumn = {}
    for tech in GameInfo.Technologies() do
        if tech.GridX ~= nil and tech.GridY ~= nil then
            byColumn[tech.GridX] = byColumn[tech.GridX] or {}
            byColumn[tech.GridX][#byColumn[tech.GridX] + 1] = tech
        end
    end
    for _, list in pairs(byColumn) do
        table.sort(list, function(a, b)
            return a.GridY < b.GridY
        end)
    end
    return { byColumn = byColumn }
end

-- Find the next tech under arrow nav.
--   axis "column" (Up / Down): walk byColumn[tech.GridX] in GridY order;
--     dir +1 returns the next tech with GridY > tech.GridY, -1 the
--     previous. Silent at the column edge.
--   axis "row" (Left / Right): step exactly one column over (GridX + dir)
--     and return whichever tech in that column is nearest intendedGridY.
--     Silent when no column exists at GridX + dir or it has no techs.
--     Tiebreak on equal distance prefers the smaller GridY (visually
--     higher); since byColumn is sorted ascending, we get this for free
--     by only replacing on strictly smaller distance.
-- intendedGridY persists across consecutive horizontal moves; the caller
-- reseeds it from the cursor's GridY whenever a vertical move lands.
function TechTreeLogic.gridNeighbor(grid, tech, axis, dir, intendedGridY)
    if axis == "column" then
        local list = grid.byColumn[tech.GridX]
        if list == nil then
            return nil
        end
        local current = tech.GridY
        if dir > 0 then
            for i = 1, #list do
                if list[i].GridY > current then
                    return list[i]
                end
            end
        else
            for i = #list, 1, -1 do
                if list[i].GridY < current then
                    return list[i]
                end
            end
        end
        return nil
    end
    local targetX = tech.GridX + dir
    local list = grid.byColumn[targetX]
    if list == nil or #list == 0 then
        return nil
    end
    local target = intendedGridY or tech.GridY
    local best = list[1]
    local bestDist = math.abs(best.GridY - target)
    for i = 2, #list do
        local cand = list[i]
        local dist = math.abs(cand.GridY - target)
        if dist < bestDist then
            best = cand
            bestDist = dist
        end
    end
    return best
end

-- ===== Era prefix =====
--
-- Era ID for a tech (e.g. "ERA_CLASSICAL"). Used as the comparison key
-- between cursor moves to detect an era boundary. Returns nil for techs
-- whose Era column is empty (no vanilla tech does this, but tolerate it).
function TechTreeLogic.eraID(techID)
    local techInfo = GameInfo.Technologies[techID]
    if techInfo == nil then
        return nil
    end
    return techInfo.Era
end

-- Localized era display name for a tech's era (e.g. "Classical Era").
-- Returns nil if the tech has no era or the era's Description key is
-- missing. Name is reread per call -- no caching, per project rule.
function TechTreeLogic.eraName(techID)
    local techInfo = GameInfo.Technologies[techID]
    if techInfo == nil or techInfo.Era == nil then
        return nil
    end
    local eraInfo = GameInfo.Eras[techInfo.Era]
    if eraInfo == nil or eraInfo.Description == nil then
        return nil
    end
    return Text.key(eraInfo.Description)
end

-- Era boundary prefix for the landing speech. When the new tech's era
-- differs from prevEraID, returns ("<Era Name>. ", newEraID) so the era
-- announcement leads the speech and screen readers get a stronger pause
-- before the tech name. Otherwise returns ("", prevEraID). Caller passes
-- nil prevEraID on first landing of an open so the era announces; resets
-- to nil on screen hide.
function TechTreeLogic.eraPrefix(prevEraID, newTechID)
    local newEra = TechTreeLogic.eraID(newTechID)
    if newEra == nil or newEra == prevEraID then
        return "", prevEraID
    end
    local name = TechTreeLogic.eraName(newTechID)
    if name == nil then
        -- Era exists but its display name is missing (Description key
        -- absent). Advance prev anyway so a subsequent move into a third,
        -- fully-described era compares against this one rather than the
        -- one before it -- otherwise the boundary announces twice.
        return "", newEra
    end
    return name .. ". ", newEra
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

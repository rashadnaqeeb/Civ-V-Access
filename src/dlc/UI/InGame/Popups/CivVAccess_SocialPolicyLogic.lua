-- Pure helpers for SocialPolicyPopupAccess. No ContextPtr / Events surface so
-- offline tests can exercise branch status, unlock ordering, slot gating, and
-- speech composition against a stubbed GameInfo + fakePlayer without dofiling
-- the install-side access file.
--
-- Branch policies are ordered by GridY (then GridX, then ID). In BNW the
-- visual grid aligns with the prereq DAG (Firaxis draws each policy one row
-- below its prereqs), so a GridY sort matches what sighted players see and
-- also produces unlock-wave tiers for AND-merge branches (Commerce, Aesthetics,
-- Patronage). BFS over Policy_PrereqPolicies would give the same ordering in
-- practice but without the match-sighted-UI guarantee.
--
-- Opener / finisher identity is read from branchRow.FreePolicy and
-- branchRow.FreeFinishingPolicy (BNW column names). Both are Type strings
-- resolved against GameInfo.Policies at speech time.
--
-- Blocker name: the engine's IsPolicyBranchBlocked returns a boolean without
-- exposing which branch did the blocking, and the game's own tooltip doesn't
-- name the blocker either, so the status word is just "blocked". Matches what
-- sighted players see.

SocialPolicyLogic = {}

-- Level slot counts match the XML widget inventory:
--   IdeologyButton11..17 (7 slots at level 1)
--   IdeologyButton21..24 (4 slots at level 2)
--   IdeologyButton31..33 (3 slots at level 3)
SocialPolicyLogic.IDEOLOGY_LEVEL_SLOTS = { 7, 4, 3 }

-- ========== Branch enumeration ==========

-- Classical (non-ideology) branches, in GameInfo.PolicyBranchTypes data order.
-- Ideologies have PurchaseByLevel=true in BNW; classical branches do not.
function SocialPolicyLogic.classicalBranches()
    local branches = {}
    local i = 0
    while true do
        local branch = GameInfo.PolicyBranchTypes[i]
        if branch == nil then
            break
        end
        if not branch.PurchaseByLevel then
            branches[#branches + 1] = branch
        end
        i = i + 1
    end
    return branches
end

-- Split a branch's policies into (opener, interior-sorted, finisher).
-- Opener and finisher are identified by the branch row's FreePolicy and
-- FreeFinishingPolicy Type strings; interior is everything else in the branch,
-- sorted by GridY then GridX then ID so unlock-tier order matches the sighted
-- layout.
function SocialPolicyLogic.sortBranchPolicies(branchRow)
    local branchType = branchRow.Type
    local openerType = branchRow.FreePolicy
    local finisherType = branchRow.FreeFinishingPolicy
    local opener, finisher
    local interior = {}
    for policy in GameInfo.Policies() do
        if policy.PolicyBranchType == branchType then
            if openerType ~= nil and policy.Type == openerType then
                opener = policy
            elseif finisherType ~= nil and policy.Type == finisherType then
                finisher = policy
            else
                interior[#interior + 1] = policy
            end
        end
    end
    table.sort(interior, function(a, b)
        if a.GridY ~= b.GridY then
            return a.GridY < b.GridY
        end
        if a.GridX ~= b.GridX then
            return a.GridX < b.GridX
        end
        return a.ID < b.ID
    end)
    return opener, interior, finisher
end

function SocialPolicyLogic.adoptedCount(player, branchRow)
    local _, interior = SocialPolicyLogic.sortBranchPolicies(branchRow)
    local count = 0
    for _, pol in ipairs(interior) do
        if player:HasPolicy(pol.ID) then
            count = count + 1
        end
    end
    return count, #interior
end

-- ========== Status resolution ==========

-- Branch status token plus a payload value (era type string for locked-era).
-- Order matters: finished wins over opened wins over blocked; locked-religion
-- wins over locked-era because BNW's Piety has LockedWithoutReligion=true and
-- no EraPrereq, so religion is the only lock reason on that branch. For other
-- branches with EraPrereq only, locked-era fires; adoptable otherwise.
function SocialPolicyLogic.branchStatus(player, branchRow)
    local branchID = branchRow.ID
    if player:IsPolicyBranchFinished(branchID) then
        return "finished"
    end
    if player:IsPolicyBranchUnlocked(branchID) then
        if player:IsPolicyBranchBlocked(branchID) then
            return "blocked"
        end
        return "opened"
    end
    if player:CanUnlockPolicyBranch(branchID) then
        return "adoptable"
    end
    -- "locked-religion" only when religion genuinely isn't founded yet. The
    -- engine's LockedWithoutReligion gate blocks until any religion exists in
    -- the world, but CanUnlockPolicyBranch also returns false for other
    -- reasons (culture, era). Without the Game.GetNumReligionsFounded check
    -- a Piety branch that's merely unaffordable would falsely say "requires
    -- a founded religion."
    if branchRow.LockedWithoutReligion and Game.GetNumReligionsFounded() == 0 then
        return "locked-religion"
    end
    if branchRow.EraPrereq ~= nil then
        local eraID = GameInfoTypes[branchRow.EraPrereq]
        if eraID ~= nil then
            local pTeam = Teams[player:GetTeam()]
            if pTeam ~= nil and pTeam:GetCurrentEra() < eraID then
                return "locked-era", branchRow.EraPrereq
            end
        end
    end
    return "locked"
end

-- Policy status token plus the list of missing prereq policy names when locked.
-- Opener and finisher are informational (not separately pickable): they show up
-- in the drill list so the user knows the branch's full shape but aren't Enter
-- targets.
function SocialPolicyLogic.policyStatus(player, policyRow, branchRow)
    if branchRow.FreePolicy ~= nil and policyRow.Type == branchRow.FreePolicy then
        return "opener"
    end
    if branchRow.FreeFinishingPolicy ~= nil and policyRow.Type == branchRow.FreeFinishingPolicy then
        return "finisher"
    end
    if player:HasPolicy(policyRow.ID) then
        return "adopted"
    end
    if player:IsPolicyBlocked(policyRow.ID) then
        return "blocked"
    end
    if player:CanAdoptPolicy(policyRow.ID) then
        return "adoptable"
    end
    local missing = {}
    for row in GameInfo.Policy_PrereqPolicies() do
        if row.PolicyType == policyRow.Type then
            local prereq = GameInfo.Policies[row.PrereqPolicy]
            if prereq ~= nil and not player:HasPolicy(prereq.ID) then
                missing[#missing + 1] = Text.key(prereq.Description)
            end
        end
    end
    return "locked", missing
end

-- Slot status tokens:
--   "filled", tenetID
--   "available"
--   "blocked-sequential", priorSlotIndex   (level 1, slot > 1 and slot-1 empty)
--   "blocked-crosslevel", crossLevel, crossSlot  (level 2/3 gate on level-1/2 slot index+1)
--   "locked-culture"                       (gate open, no culture and no free picks)
function SocialPolicyLogic.slotStatus(player, ideologyID, level, slotIndex)
    local tenetID = player:GetTenet(ideologyID, level, slotIndex)
    if tenetID >= 0 then
        return "filled", tenetID
    end
    if level == 1 then
        if slotIndex > 1 then
            local prev = player:GetTenet(ideologyID, 1, slotIndex - 1)
            if prev < 0 then
                return "blocked-sequential", slotIndex - 1
            end
        end
    elseif level == 2 then
        local cross = player:GetTenet(ideologyID, 1, slotIndex + 1)
        if cross < 0 then
            return "blocked-crosslevel", 1, slotIndex + 1
        end
    elseif level == 3 then
        local cross = player:GetTenet(ideologyID, 2, slotIndex + 1)
        if cross < 0 then
            return "blocked-crosslevel", 2, slotIndex + 1
        end
    end
    if
        player:GetJONSCulture() < player:GetNextPolicyCost()
        and player:GetNumFreePolicies() == 0
        and player:GetNumFreeTenets() == 0
    then
        return "locked-culture"
    end
    return "available"
end

-- ========== Speech composition ==========

local function statusSpeechBranch(status, payload)
    if status == "opened" then
        return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED")
    elseif status == "finished" then
        return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED")
    elseif status == "adoptable" then
        return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE")
    elseif status == "blocked" then
        return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED")
    elseif status == "locked-era" then
        local eraRow = GameInfo.Eras[payload]
        local eraName = eraRow and eraRow.Description and Text.key(eraRow.Description) or payload
        return Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA", eraName)
    elseif status == "locked-religion" then
        return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION")
    end
    return Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED")
end

-- Engine Help text for branches, policies, and tenets leads with
-- [COLOR_POSITIVE_TEXT]Name[ENDCOLOR][NEWLINE] which TextFilter reduces to
-- "Name " at the head of the string. The spoken item already leads with
-- the name from Description, so the prefix must be stripped to avoid
-- duplicate narration ("Oligarchy, adoptable, Oligarchy Garrisoned ...").
-- Case-insensitive match; trims the whitespace / punctuation that follows
-- the name.
local function stripLeadingName(text, name)
    if text == nil or text == "" or name == nil or name == "" then
        return text or ""
    end
    if text:lower():sub(1, #name) == name:lower() then
        return (text:sub(#name + 1):gsub("^[%s,%.:;]+", ""))
    end
    return text
end

local function filterHelp(helpKey, name)
    if helpKey == nil or helpKey == "" then
        return ""
    end
    local raw = Text.key(helpKey)
    if raw == nil or raw == "" then
        return ""
    end
    return stripLeadingName(TextFilter.filter(raw), name)
end

function SocialPolicyLogic.buildBranchSpeech(player, branchRow)
    local name = Text.key(branchRow.Description)
    local parts = { name }
    local status, payload = SocialPolicyLogic.branchStatus(player, branchRow)
    parts[#parts + 1] = statusSpeechBranch(status, payload)
    local adopted, total = SocialPolicyLogic.adoptedCount(player, branchRow)
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT", adopted, total)
    local flavor = filterHelp(branchRow.Help, name)
    if flavor ~= "" then
        parts[#parts + 1] = flavor
    end
    return table.concat(parts, ", ")
end

function SocialPolicyLogic.buildPolicySpeech(player, policyRow, branchRow)
    local name = Text.key(policyRow.Description)
    local parts = { name }
    local status, missing = SocialPolicyLogic.policyStatus(player, policyRow, branchRow)
    if status == "opener" then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER")
    elseif status == "finisher" then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER")
    elseif status == "adopted" then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED")
    elseif status == "adoptable" then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE")
    elseif status == "blocked" then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED")
    else
        if missing ~= nil and #missing > 0 then
            parts[#parts + 1] = Text.format(
                "TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES",
                table.concat(missing, ", ")
            )
        else
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED")
        end
    end
    local effect = filterHelp(policyRow.Help, name)
    if effect ~= "" then
        parts[#parts + 1] = effect
    end
    return table.concat(parts, ", ")
end

function SocialPolicyLogic.buildPreamble(player)
    local parts = {}
    local cur = player:GetJONSCulture()
    local cost = player:GetNextPolicyCost()
    local per = player:GetTotalJONSCulturePerTurn()
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE", cur, cost, per)
    if per > 0 then
        local needed = cost - cur
        local turns
        if needed <= 0 then
            turns = 0
        else
            turns = math.floor(needed / per) + 1
        end
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS", turns, turns)
    end
    local freePolicies = player:GetNumFreePolicies()
    if freePolicies > 0 then
        parts[#parts + 1] =
            Text.formatPlural("TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES", freePolicies, freePolicies)
    end
    local freeTenets = player:GetNumFreeTenets()
    if freeTenets > 0 then
        parts[#parts + 1] =
            Text.formatPlural("TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS", freeTenets, freeTenets)
    end
    return table.concat(parts, ", ")
end

function SocialPolicyLogic.buildSlotSpeech(player, ideologyID, level, slotIndex)
    local status, p1, p2 = SocialPolicyLogic.slotStatus(player, ideologyID, level, slotIndex)
    if status == "filled" then
        local tenetRow = GameInfo.Policies[p1]
        if tenetRow == nil then
            return Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE", slotIndex)
        end
        local name = Text.key(tenetRow.Description)
        local effect = filterHelp(tenetRow.Help, name)
        if effect ~= "" then
            return Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED", slotIndex, name, effect)
        end
        return Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY", slotIndex, name)
    elseif status == "available" then
        return Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE", slotIndex)
    elseif status == "blocked-sequential" then
        return Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT", slotIndex, p1)
    elseif status == "blocked-crosslevel" then
        return Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS", slotIndex, p1, p2)
    elseif status == "locked-culture" then
        return Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE", slotIndex)
    end
    return ""
end

function SocialPolicyLogic.buildTenetPickerChoice(policyRow)
    local name = Text.key(policyRow.Description)
    local effect = filterHelp(policyRow.Help, name)
    if effect == "" then
        return name
    end
    return name .. ", " .. effect
end

function SocialPolicyLogic.buildPublicOpinionSpeech(player)
    local opinionType = player:GetPublicOpinionType()
    local key
    if PublicOpinionTypes ~= nil then
        if opinionType == PublicOpinionTypes.PUBLIC_OPINION_DISSIDENTS then
            key = "TXT_KEY_CO_PUBLIC_OPINION_DISSIDENTS"
        elseif opinionType == PublicOpinionTypes.PUBLIC_OPINION_CIVIL_RESISTANCE then
            key = "TXT_KEY_CO_PUBLIC_OPINION_CIVIL_RESISTANCE"
        elseif opinionType == PublicOpinionTypes.PUBLIC_OPINION_REVOLUTIONARY_WAVE then
            key = "TXT_KEY_CO_PUBLIC_OPINION_REVOLUTIONARY_WAVE"
        end
    end
    if key == nil then
        key = "TXT_KEY_CO_PUBLIC_OPINION_CONTENT"
    end
    -- Prefix with the engine's own section header ("PUBLIC OPINION") so the
    -- bare opinion word ("Content", "Dissidents", ...) has a frame; sighted
    -- players see this header right above the value on the same screen.
    local parts = { Text.key("TXT_KEY_CO_VICTORY_PUBLIC_OPINION_HEADER"), Text.key(key) }
    local unhappiness = player:GetPublicOpinionUnhappiness()
    if unhappiness > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS", unhappiness)
    end
    return table.concat(parts, ", ")
end

return SocialPolicyLogic

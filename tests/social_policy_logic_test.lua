-- SocialPolicyLogic tests. Exercises branch iteration, policy tier sort,
-- branch / policy / slot status resolution, speech composition (branch,
-- policy, preamble, slot, tenet picker), and the sequential + cross-level
-- slot gating that gets reproduced from the base game's UpdateDisplay.

local T = require("support")
local M = {}

-- ========== Fixtures ==========

local function branchRow(opts)
    return {
        ID = opts.ID,
        Type = opts.Type,
        Description = opts.Description or opts.Type,
        -- Help key prefixed "HELP_" rather than suffixed "_HELP" so it does
        -- not collide with the leading-name strip in buildBranchSpeech.
        Help = opts.Help or ("HELP_" .. opts.Type),
        EraPrereq = opts.EraPrereq,
        FreePolicy = opts.FreePolicy,
        FreeFinishingPolicy = opts.FreeFinishingPolicy,
        LockedWithoutReligion = opts.LockedWithoutReligion or false,
        PurchaseByLevel = opts.PurchaseByLevel or false,
    }
end

local function policyRow(opts)
    return {
        ID = opts.ID,
        Type = opts.Type,
        Description = opts.Description or opts.Type,
        -- Help key prefixed "HELP_" rather than suffixed "_HELP" so it does
        -- not collide with the leading-name strip.
        Help = opts.Help or ("HELP_" .. opts.Type),
        PolicyBranchType = opts.PolicyBranchType,
        GridX = opts.GridX or 1,
        GridY = opts.GridY or 1,
        Level = opts.Level or 0,
    }
end

local function installDB(branches, policies, prereqs, eras)
    local branchMap = {}
    for _, b in ipairs(branches) do
        branchMap[b.ID] = b
        branchMap[b.Type] = b
    end
    setmetatable(branchMap, {
        __call = function()
            local i = 0
            return function()
                i = i + 1
                return branches[i]
            end
        end,
    })

    local policyMap = {}
    for _, p in ipairs(policies) do
        policyMap[p.ID] = p
        policyMap[p.Type] = p
    end
    setmetatable(policyMap, {
        __call = function()
            local i = 0
            return function()
                i = i + 1
                return policies[i]
            end
        end,
    })

    GameInfo = GameInfo or {}
    GameInfo.PolicyBranchTypes = branchMap
    GameInfo.Policies = policyMap
    GameInfo.Policy_PrereqPolicies = function()
        local i = 0
        return function()
            i = i + 1
            return prereqs[i]
        end
    end
    GameInfo.Eras = eras or {}

    GameInfoTypes = {}
    for _, b in ipairs(branches) do
        GameInfoTypes[b.Type] = b.ID
    end
    if eras ~= nil then
        for k, era in pairs(eras) do
            if type(k) == "number" then
                GameInfoTypes[era.Type] = era.ID
            end
        end
    end
end

local function fakePlayer(opts)
    opts = opts or {}
    local p = {
        _team = opts.team or 0,
        _has = opts.has or {},
        _canAdopt = opts.canAdopt or {},
        _blocked = opts.blocked or {},
        _branchUnlocked = opts.branchUnlocked or {},
        _branchBlocked = opts.branchBlocked or {},
        _branchFinished = opts.branchFinished or {},
        _canUnlock = opts.canUnlock or {},
        _ideology = opts.ideology == nil and -1 or opts.ideology,
        _tenets = opts.tenets or {},
        _available = opts.available or {},
        _culture = opts.culture or 0,
        _nextCost = opts.nextCost or 25,
        _perTurn = opts.perTurn or 0,
        _freePolicies = opts.freePolicies or 0,
        _freeTenets = opts.freeTenets or 0,
        _opinionType = opts.opinionType or 0,
        _opinionUnhappiness = opts.opinionUnhappiness or 0,
    }
    function p:GetTeam()
        return self._team
    end
    function p:HasPolicy(id)
        return self._has[id] or false
    end
    function p:CanAdoptPolicy(id)
        return self._canAdopt[id] or false
    end
    function p:IsPolicyBlocked(id)
        return self._blocked[id] or false
    end
    function p:IsPolicyBranchUnlocked(id)
        return self._branchUnlocked[id] or false
    end
    function p:IsPolicyBranchBlocked(id)
        return self._branchBlocked[id] or false
    end
    function p:IsPolicyBranchFinished(id)
        return self._branchFinished[id] or false
    end
    function p:CanUnlockPolicyBranch(id)
        return self._canUnlock[id] or false
    end
    function p:GetLateGamePolicyTree()
        return self._ideology
    end
    function p:GetTenet(ideologyID, level, slot)
        local key = string.format("%d:%d:%d", ideologyID, level, slot)
        return self._tenets[key] or -1
    end
    function p:GetAvailableTenets(level)
        return self._available[level] or {}
    end
    function p:GetJONSCulture()
        return self._culture
    end
    function p:GetNextPolicyCost()
        return self._nextCost
    end
    function p:GetTotalJONSCulturePerTurn()
        return self._perTurn
    end
    function p:GetNumFreePolicies()
        return self._freePolicies
    end
    function p:GetNumFreeTenets()
        return self._freeTenets
    end
    function p:GetPublicOpinionType()
        return self._opinionType
    end
    function p:GetPublicOpinionUnhappiness()
        return self._opinionUnhappiness
    end
    return p
end

local function installTeams(currentEra)
    Teams = setmetatable({}, {
        __index = function()
            return {
                GetCurrentEra = function()
                    return currentEra or 0
                end,
            }
        end,
    })
end

local function setup(opts)
    opts = opts or {}
    Log = Log
        or {
            debug = function() end,
            info = function() end,
            warn = function() end,
            error = function() end,
        }
    -- branchStatus calls Game.GetNumReligionsFounded() on the locked-religion
    -- path. Default to zero so the Piety-style tests match the "no religion
    -- in world" case; opts.religionsFounded overrides for the inverted test.
    Game = Game or {}
    Game.GetNumReligionsFounded = function()
        return opts.religionsFounded or 0
    end
    Locale = Locale or {}
    T.installLocaleStrings({})

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    CivVAccess_Strings = CivVAccess_Strings or {}
    -- Only strings the logic module references, per-test. Full production set
    -- lives in CivVAccess_InGameStrings_en_US and isn't needed here.
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "opened"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "finished"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "adoptable"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "locked, requires {1_Era}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] = "locked, requires a founded religion"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "locked"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "blocked"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num} of {2_Total} adopted"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] = "opener"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] = "finisher"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "adopted"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "adoptable"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "blocked"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "locked"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "locked, requires {1_Prereqs}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] =
        "{1_Cur} of {2_Cost} culture, {3_Per} per turn"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = "{1_Turns} turns to next policy"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = "{1_Num} free policies available"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = "{1_Num} free tenets available"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "slot {1_Num}, {2_Name}, {3_Effect}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "slot {1_Num}, {2_Name}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] = "slot {1_Num}, empty, available"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] =
        "slot {1_Num}, empty, requires slot {2_Req}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
        "slot {1_Num}, empty, requires level {2_Level} slot {3_Req}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] =
        "slot {1_Num}, empty, insufficient culture"

    dofile("src/dlc/UI/InGame/Popups/CivVAccess_SocialPolicyLogic.lua")
end

-- Tradition-style branch with opener, two tiers, finisher.
-- Interior policies: Aristocracy (GridY=1), Oligarchy (GridY=1), Legalism
-- (GridY=2, prereq Oligarchy), Landed Elite (GridY=3, prereq Legalism),
-- Monarchy (GridY=3, prereq Legalism).
local function tradition()
    local branches = {
        branchRow({
            ID = 0,
            Type = "BRANCH_TRAD",
            FreePolicy = "POL_TRAD_OPENER",
            FreeFinishingPolicy = "POL_TRAD_FINISHER",
        }),
    }
    local policies = {
        policyRow({ ID = 0, Type = "POL_TRAD_OPENER", PolicyBranchType = "BRANCH_TRAD", GridY = 0, GridX = 1 }),
        policyRow({ ID = 1, Type = "POL_ARISTOCRACY", PolicyBranchType = "BRANCH_TRAD", GridY = 1, GridX = 1 }),
        policyRow({ ID = 2, Type = "POL_OLIGARCHY", PolicyBranchType = "BRANCH_TRAD", GridY = 1, GridX = 2 }),
        policyRow({ ID = 3, Type = "POL_LEGALISM", PolicyBranchType = "BRANCH_TRAD", GridY = 2, GridX = 2 }),
        policyRow({ ID = 4, Type = "POL_LANDED_ELITE", PolicyBranchType = "BRANCH_TRAD", GridY = 3, GridX = 1 }),
        policyRow({ ID = 5, Type = "POL_MONARCHY", PolicyBranchType = "BRANCH_TRAD", GridY = 3, GridX = 3 }),
        policyRow({ ID = 6, Type = "POL_TRAD_FINISHER", PolicyBranchType = "BRANCH_TRAD", GridY = 4, GridX = 2 }),
    }
    local prereqs = {
        { PolicyType = "POL_LEGALISM", PrereqPolicy = "POL_OLIGARCHY" },
        { PolicyType = "POL_LANDED_ELITE", PrereqPolicy = "POL_LEGALISM" },
        { PolicyType = "POL_MONARCHY", PrereqPolicy = "POL_LEGALISM" },
    }
    return branches, policies, prereqs
end

-- ========== classicalBranches ==========

function M.test_classicalBranches_excludes_PurchaseByLevel()
    setup()
    local branches = {
        branchRow({ ID = 0, Type = "B0" }),
        branchRow({ ID = 1, Type = "B1" }),
        branchRow({ ID = 2, Type = "B_IDE_FREEDOM", PurchaseByLevel = true }),
    }
    installDB(branches, {}, {})
    local got = SocialPolicyLogic.classicalBranches()
    T.eq(#got, 2)
    T.eq(got[1].Type, "B0")
    T.eq(got[2].Type, "B1")
end

function M.test_classicalBranches_preserves_data_order()
    setup()
    local branches = {
        branchRow({ ID = 0, Type = "FIRST" }),
        branchRow({ ID = 1, Type = "SECOND" }),
        branchRow({ ID = 2, Type = "THIRD" }),
    }
    installDB(branches, {}, {})
    local got = SocialPolicyLogic.classicalBranches()
    T.eq(got[1].Type, "FIRST")
    T.eq(got[3].Type, "THIRD")
end

-- ========== sortBranchPolicies ==========

function M.test_sortBranchPolicies_opener_by_FreePolicy()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local opener = SocialPolicyLogic.sortBranchPolicies(branches[1])
    T.eq(opener.Type, "POL_TRAD_OPENER")
end

function M.test_sortBranchPolicies_finisher_by_FreeFinishingPolicy()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local _, _, finisher = SocialPolicyLogic.sortBranchPolicies(branches[1])
    T.eq(finisher.Type, "POL_TRAD_FINISHER")
end

function M.test_sortBranchPolicies_interior_by_GridY_then_GridX()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local _, interior = SocialPolicyLogic.sortBranchPolicies(branches[1])
    -- Expected order: Aristocracy (1,1), Oligarchy (1,2), Legalism (2,2),
    -- Landed Elite (3,1), Monarchy (3,3).
    T.eq(#interior, 5)
    T.eq(interior[1].Type, "POL_ARISTOCRACY")
    T.eq(interior[2].Type, "POL_OLIGARCHY")
    T.eq(interior[3].Type, "POL_LEGALISM")
    T.eq(interior[4].Type, "POL_LANDED_ELITE")
    T.eq(interior[5].Type, "POL_MONARCHY")
end

function M.test_sortBranchPolicies_excludes_other_branches()
    setup()
    local branches = {
        branchRow({ ID = 0, Type = "A", FreePolicy = "A_OPENER" }),
        branchRow({ ID = 1, Type = "B", FreePolicy = "B_OPENER" }),
    }
    local policies = {
        policyRow({ ID = 0, Type = "A_OPENER", PolicyBranchType = "A", GridY = 0 }),
        policyRow({ ID = 1, Type = "A_POLICY", PolicyBranchType = "A", GridY = 1 }),
        policyRow({ ID = 2, Type = "B_OPENER", PolicyBranchType = "B", GridY = 0 }),
        policyRow({ ID = 3, Type = "B_POLICY", PolicyBranchType = "B", GridY = 1 }),
    }
    installDB(branches, policies, {})
    local _, interior = SocialPolicyLogic.sortBranchPolicies(branches[1])
    T.eq(#interior, 1)
    T.eq(interior[1].Type, "A_POLICY")
end

-- ========== adoptedCount ==========

function M.test_adoptedCount_excludes_opener_and_finisher()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    -- Player holds opener (0), Aristocracy (1), Legalism (3), finisher (6).
    -- Only Aristocracy and Legalism count.
    local p = fakePlayer({ has = { [0] = true, [1] = true, [3] = true, [6] = true } })
    local adopted, total = SocialPolicyLogic.adoptedCount(p, branches[1])
    T.eq(adopted, 2)
    T.eq(total, 5)
end

-- ========== branchStatus ==========

function M.test_branchStatus_finished_wins_over_opened()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    installTeams()
    local p = fakePlayer({ branchUnlocked = { [0] = true }, branchFinished = { [0] = true } })
    T.eq(SocialPolicyLogic.branchStatus(p, branches[1]), "finished")
end

function M.test_branchStatus_blocked_when_unlocked_and_blocked()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    installTeams()
    local p = fakePlayer({ branchUnlocked = { [0] = true }, branchBlocked = { [0] = true } })
    T.eq(SocialPolicyLogic.branchStatus(p, branches[1]), "blocked")
end

function M.test_branchStatus_opened_when_unlocked_not_blocked()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    installTeams()
    local p = fakePlayer({ branchUnlocked = { [0] = true } })
    T.eq(SocialPolicyLogic.branchStatus(p, branches[1]), "opened")
end

function M.test_branchStatus_adoptable_when_CanUnlock()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    installTeams()
    local p = fakePlayer({ canUnlock = { [0] = true } })
    T.eq(SocialPolicyLogic.branchStatus(p, branches[1]), "adoptable")
end

function M.test_branchStatus_locked_era_reports_era_type()
    setup()
    local branches = {
        branchRow({ ID = 0, Type = "B_RAT", EraPrereq = "ERA_RENAISSANCE" }),
    }
    local eras = { [0] = { ID = 0, Type = "ERA_ANCIENT" }, [1] = { ID = 1, Type = "ERA_RENAISSANCE" } }
    installDB(branches, {}, {}, eras)
    installTeams(0)
    local p = fakePlayer({})
    local status, payload = SocialPolicyLogic.branchStatus(p, branches[1])
    T.eq(status, "locked-era")
    T.eq(payload, "ERA_RENAISSANCE")
end

function M.test_branchStatus_locked_religion_when_no_religion_founded()
    setup({ religionsFounded = 0 })
    -- Piety in BNW: LockedWithoutReligion=true, no EraPrereq. With no religion
    -- in the world the branch falls through to the religion-lock message.
    local branches = {
        branchRow({ ID = 0, Type = "B_PIETY", LockedWithoutReligion = true }),
    }
    installDB(branches, {}, {}, {})
    installTeams(0)
    local p = fakePlayer({})
    T.eq(SocialPolicyLogic.branchStatus(p, branches[1]), "locked-religion")
end

function M.test_branchStatus_plain_locked_when_religion_founded_but_unaffordable()
    setup({ religionsFounded = 1 })
    -- Piety with a religion founded but player can't afford yet. Must NOT
    -- say "requires a founded religion" — that would mislead.
    local branches = {
        branchRow({ ID = 0, Type = "B_PIETY", LockedWithoutReligion = true }),
    }
    installDB(branches, {}, {}, {})
    installTeams(0)
    local p = fakePlayer({})
    T.eq(SocialPolicyLogic.branchStatus(p, branches[1]), "locked")
end

function M.test_branchStatus_plain_locked_when_no_reason_matches()
    setup()
    -- No era prereq, no religion lock, not adoptable yet. Falls through to
    -- plain "locked" (culture/other internal reason the engine hides from us).
    local branches = {
        branchRow({ ID = 0, Type = "B" }),
    }
    installDB(branches, {}, {}, {})
    installTeams(0)
    local p = fakePlayer({})
    T.eq(SocialPolicyLogic.branchStatus(p, branches[1]), "locked")
end

-- ========== policyStatus ==========

function M.test_policyStatus_opener_identified()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local p = fakePlayer({})
    T.eq(SocialPolicyLogic.policyStatus(p, policies[1], branches[1]), "opener")
end

function M.test_policyStatus_finisher_identified()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local p = fakePlayer({})
    T.eq(SocialPolicyLogic.policyStatus(p, policies[7], branches[1]), "finisher")
end

function M.test_policyStatus_adopted_when_HasPolicy()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local p = fakePlayer({ has = { [2] = true } })
    T.eq(SocialPolicyLogic.policyStatus(p, policies[3], branches[1]), "adopted")
end

function M.test_policyStatus_adoptable_when_CanAdopt()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local p = fakePlayer({ canAdopt = { [2] = true } })
    T.eq(SocialPolicyLogic.policyStatus(p, policies[3], branches[1]), "adoptable")
end

function M.test_policyStatus_blocked_beats_locked()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local p = fakePlayer({ blocked = { [2] = true } })
    T.eq(SocialPolicyLogic.policyStatus(p, policies[3], branches[1]), "blocked")
end

function M.test_policyStatus_locked_returns_missing_prereq_names()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    -- Landed Elite needs Legalism; player has nothing.
    local p = fakePlayer({})
    local status, missing = SocialPolicyLogic.policyStatus(p, policies[5], branches[1])
    T.eq(status, "locked")
    T.eq(#missing, 1)
    T.eq(missing[1], "POL_LEGALISM")
end

function M.test_policyStatus_locked_lists_all_AND_prereqs()
    setup()
    -- Commerce-style AND-merge: a policy with two prereq rows in Policy_PrereqPolicies.
    local branches = {
        branchRow({ ID = 0, Type = "B", FreePolicy = "B_OP", FreeFinishingPolicy = "B_FN" }),
    }
    local policies = {
        policyRow({ ID = 0, Type = "B_OP", PolicyBranchType = "B", GridY = 0 }),
        policyRow({ ID = 1, Type = "B_P1", PolicyBranchType = "B", GridY = 1 }),
        policyRow({ ID = 2, Type = "B_P2", PolicyBranchType = "B", GridY = 1 }),
        policyRow({ ID = 3, Type = "B_MERGE", PolicyBranchType = "B", GridY = 2 }),
        policyRow({ ID = 4, Type = "B_FN", PolicyBranchType = "B", GridY = 3 }),
    }
    local prereqs = {
        { PolicyType = "B_MERGE", PrereqPolicy = "B_P1" },
        { PolicyType = "B_MERGE", PrereqPolicy = "B_P2" },
    }
    installDB(branches, policies, prereqs)
    local p = fakePlayer({})
    local status, missing = SocialPolicyLogic.policyStatus(p, policies[4], branches[1])
    T.eq(status, "locked")
    T.eq(#missing, 2)
end

-- ========== buildBranchSpeech ==========

function M.test_buildBranchSpeech_starts_with_branch_description()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    installTeams()
    local p = fakePlayer({ branchUnlocked = { [0] = true } })
    local speech = SocialPolicyLogic.buildBranchSpeech(p, branches[1])
    -- Assertions check raw keys since the harness's Locale passthrough
    -- returns keys as-is. Verifies Description leads and status/count follow.
    T.truthy(speech:find("^BRANCH_TRAD,"), "speech should lead with branch name, got: " .. speech)
    T.truthy(speech:find("opened"), "status missing: " .. speech)
end

function M.test_buildBranchSpeech_includes_count_and_flavor()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    installTeams()
    local p = fakePlayer({
        branchUnlocked = { [0] = true },
        has = { [0] = true, [1] = true, [3] = true },
    })
    local speech = SocialPolicyLogic.buildBranchSpeech(p, branches[1])
    T.truthy(speech:find("2 of 5 adopted"), "missing count, got: " .. speech)
    T.truthy(speech:find("HELP_BRANCH_TRAD"), "missing flavor key, got: " .. speech)
end

-- ========== buildPolicySpeech ==========

function M.test_buildPolicySpeech_locked_includes_all_prereqs()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local p = fakePlayer({})
    local speech = SocialPolicyLogic.buildPolicySpeech(p, policies[5], branches[1])
    T.truthy(speech:find("^POL_LANDED_ELITE,"), "should lead with name: " .. speech)
    T.truthy(speech:find("locked, requires POL_LEGALISM"), "should list prereq: " .. speech)
end

function M.test_buildPolicySpeech_adoptable_has_no_prereq_noise()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    local p = fakePlayer({ canAdopt = { [2] = true } })
    local speech = SocialPolicyLogic.buildPolicySpeech(p, policies[3], branches[1])
    T.falsy(speech:find("requires"), "adoptable speech should not say 'requires': " .. speech)
    T.truthy(speech:find("adoptable"), "should say adoptable: " .. speech)
end

function M.test_buildPolicySpeech_strips_leading_name_from_help()
    setup()
    local branches, policies, prereqs = tradition()
    installDB(branches, policies, prereqs)
    -- Game's help text leads with "Name " (from [COLOR_POSITIVE_TEXT]Name
    -- [ENDCOLOR][NEWLINE] once TextFilter collapses the markup). The logic
    -- must strip that prefix so the spoken item isn't "Name, status, Name
    -- effect."
    local origLocale = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(k, ...)
        if k == "HELP_POL_OLIGARCHY" then
            return "POL_OLIGARCHY Garrisoned units cost no maintenance"
        end
        return origLocale(k, ...)
    end
    local p = fakePlayer({ canAdopt = { [2] = true } })
    local speech = SocialPolicyLogic.buildPolicySpeech(p, policies[3], branches[1])
    Locale.ConvertTextKey = origLocale
    T.truthy(speech:find("^POL_OLIGARCHY, adoptable,"), "name and status lead: " .. speech)
    T.truthy(speech:find("Garrisoned units"), "effect present: " .. speech)
    -- The name must appear exactly once (at the head). If the strip failed,
    -- the help would contribute a second "POL_OLIGARCHY" after "adoptable".
    local _, count = speech:gsub("POL_OLIGARCHY", "")
    T.eq(count, 1, "name should appear once, got " .. tostring(count) .. " in: " .. speech)
end

-- ========== buildPreamble ==========

function M.test_buildPreamble_culture_clause_always_present()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ culture = 8, nextCost = 25, perTurn = 3 })
    local speech = SocialPolicyLogic.buildPreamble(p)
    T.truthy(speech:find("8 of 25 culture"), "culture clause missing: " .. speech)
    T.truthy(speech:find("3 per turn"), "per-turn clause missing: " .. speech)
end

function M.test_buildPreamble_omits_turns_when_per_turn_is_zero()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ culture = 8, nextCost = 25, perTurn = 0 })
    local speech = SocialPolicyLogic.buildPreamble(p)
    T.falsy(speech:find("turns to next policy"), "turns should be omitted: " .. speech)
end

function M.test_buildPreamble_appends_free_policies_and_free_tenets()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({
        culture = 0,
        nextCost = 25,
        perTurn = 0,
        freePolicies = 1,
        freeTenets = 2,
    })
    local speech = SocialPolicyLogic.buildPreamble(p)
    T.truthy(speech:find("1 free policies"), "free policies clause missing: " .. speech)
    T.truthy(speech:find("2 free tenets"), "free tenets clause missing: " .. speech)
end

function M.test_buildPreamble_skips_zero_free_counts()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ culture = 8, nextCost = 25, perTurn = 3 })
    local speech = SocialPolicyLogic.buildPreamble(p)
    T.falsy(speech:find("free policies"), "zero free should be omitted: " .. speech)
    T.falsy(speech:find("free tenets"), "zero free should be omitted: " .. speech)
end

-- ========== slotStatus ==========

function M.test_slotStatus_filled_when_tenet_present()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ tenets = { ["9:1:1"] = 100 } })
    local status, payload = SocialPolicyLogic.slotStatus(p, 9, 1, 1)
    T.eq(status, "filled")
    T.eq(payload, 100)
end

function M.test_slotStatus_available_level1_slot1_when_affordable()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ freeTenets = 1 })
    T.eq(SocialPolicyLogic.slotStatus(p, 9, 1, 1), "available")
end

function M.test_slotStatus_blocked_sequential_when_prior_empty()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ freeTenets = 1 })
    local status, priorIdx = SocialPolicyLogic.slotStatus(p, 9, 1, 3)
    T.eq(status, "blocked-sequential")
    T.eq(priorIdx, 2)
end

function M.test_slotStatus_level2_blocked_crosslevel_when_level1_next_empty()
    setup()
    installDB({}, {}, {})
    -- Level 2 slot 1 requires level 1 slot 2 filled. Neither filled -> blocked.
    local p = fakePlayer({ freeTenets = 1 })
    local status, crossLevel, crossSlot = SocialPolicyLogic.slotStatus(p, 9, 2, 1)
    T.eq(status, "blocked-crosslevel")
    T.eq(crossLevel, 1)
    T.eq(crossSlot, 2)
end

function M.test_slotStatus_level3_blocked_crosslevel_on_level2()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ freeTenets = 1 })
    local status, crossLevel, crossSlot = SocialPolicyLogic.slotStatus(p, 9, 3, 1)
    T.eq(status, "blocked-crosslevel")
    T.eq(crossLevel, 2)
    T.eq(crossSlot, 2)
end

function M.test_slotStatus_locked_culture_when_gate_open_but_broke()
    setup()
    installDB({}, {}, {})
    -- Gate open (level 1 slot 1), no culture, no free picks.
    local p = fakePlayer({ culture = 0, nextCost = 25, freePolicies = 0, freeTenets = 0 })
    T.eq(SocialPolicyLogic.slotStatus(p, 9, 1, 1), "locked-culture")
end

function M.test_slotStatus_level2_opens_when_level1_next_is_filled()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({
        freeTenets = 1,
        tenets = { ["9:1:2"] = 42 },
    })
    T.eq(SocialPolicyLogic.slotStatus(p, 9, 2, 1), "available")
end

-- ========== buildSlotSpeech ==========

function M.test_buildSlotSpeech_filled_speaks_name_and_effect()
    setup()
    local policies = {
        policyRow({ ID = 100, Type = "TEN_A", Help = "HELP_TEN_A" }),
    }
    installDB({}, policies, {})
    local p = fakePlayer({ tenets = { ["9:1:1"] = 100 } })
    local speech = SocialPolicyLogic.buildSlotSpeech(p, 9, 1, 1)
    T.eq(speech, "slot 1, TEN_A, HELP_TEN_A")
end

function M.test_buildSlotSpeech_filled_name_only_when_help_empty()
    setup()
    local policies = {
        policyRow({ ID = 100, Type = "TEN_A", Help = "" }),
    }
    installDB({}, policies, {})
    local p = fakePlayer({ tenets = { ["9:1:1"] = 100 } })
    local speech = SocialPolicyLogic.buildSlotSpeech(p, 9, 1, 1)
    T.eq(speech, "slot 1, TEN_A")
end

function M.test_buildSlotSpeech_available_says_available()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ freeTenets = 1 })
    T.eq(SocialPolicyLogic.buildSlotSpeech(p, 9, 1, 1), "slot 1, empty, available")
end

function M.test_buildSlotSpeech_blocked_sequential_names_prior_slot()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ freeTenets = 1 })
    local speech = SocialPolicyLogic.buildSlotSpeech(p, 9, 1, 3)
    T.truthy(speech:find("requires slot 2"), "should name blocker: " .. speech)
end

function M.test_buildSlotSpeech_crosslevel_names_level_and_slot()
    setup()
    installDB({}, {}, {})
    local p = fakePlayer({ freeTenets = 1 })
    local speech = SocialPolicyLogic.buildSlotSpeech(p, 9, 2, 1)
    T.truthy(speech:find("requires level 1 slot 2"), "should name cross-gate: " .. speech)
end

-- ========== buildTenetPickerChoice ==========

function M.test_buildTenetPickerChoice_name_and_effect()
    setup()
    installDB({}, {}, {})
    local row = policyRow({ ID = 50, Type = "TEN", Help = "HELP_TEN" })
    local speech = SocialPolicyLogic.buildTenetPickerChoice(row)
    T.eq(speech, "TEN, HELP_TEN")
end

function M.test_buildTenetPickerChoice_name_only_when_no_effect()
    setup()
    installDB({}, {}, {})
    local row = policyRow({ ID = 50, Type = "TEN", Help = "" })
    local speech = SocialPolicyLogic.buildTenetPickerChoice(row)
    T.eq(speech, "TEN")
end

return M

-- Civilopedia data module. Two public fns:
--   Civilopedia.buildPickerItems(entryFactory) - top-level picker (one Group
--     per category; children built lazily from the pedia's own sortedList).
--   Civilopedia.buildReader(handler, category, entryID) - reader-tab content
--     for one article: a flat array of leaves (title, stats, text sections,
--     free-form text, BB text, relationship links), harvested from the
--     rendered Controls after CivilopediaCategory[cat].SelectArticle.
--
-- Why scrape Controls instead of querying GameInfo directly: per-category
-- schemas diverge in non-obvious ways (Concepts uses Summary/Extended/
-- DesignNotes; Techs use Help/Strategy/Civilopedia/Quote; Civilizations have
-- no text columns at all but populate a FFTextStack; home pages write into
-- BBTextStack). SelectArticle is the game's own per-category renderer -- it
-- does all that work for us. After it fires, the visible text is in Labels
-- inside Cost / GameInfo / Strategy / History / ... Frame ancestors, plus
-- InstanceManager-allocated instances inside FFTextStack / BBTextStack /
-- relationship frames. We read all of those. This mirrors the approach the
-- prior-generation CivVAccessibility mod took for pedia reading.
--
-- Never cache: rebuild the reader on every activation. Controls are live
-- userdata so we hold no snapshot -- their :GetText() returns the current
-- value each call.
--
-- Link follow: relationship-frame buttons hold their target article ID in
-- Void1 and a localized label in the tooltip. We emit an activatable Choice
-- leaf per link; activation calls SelectArticle on the target category and
-- rebuilds the reader tab in place (handler.setItems + programmatic
-- switchToTab force-re-announce).

Civilopedia = {}

Civilopedia.CATEGORY = {
    HOME_PAGE = 1,
    GAME_CONCEPTS = 2,
    TECH = 3,
    UNITS = 4,
    PROMOTIONS = 5,
    BUILDINGS = 6,
    WONDERS = 7,
    POLICIES = 8,
    PEOPLE = 9,
    CIVILIZATIONS = 10,
    CITY_STATES = 11,
    TERRAIN = 12,
    RESOURCES = 13,
    IMPROVEMENTS = 14,
    BELIEFS = 15,
    WORLD_CONGRESS = 16,
}

-- Reader tab is the second tab installed by CivVAccess_CivilopediaAccess via
-- PickerReader.install. Hardcoded because PickerReader's internal tab
-- indexing isn't exposed; follow-link rebuild uses this to know which tab
-- to setItems on.
local READER_TAB_IDX = 2

local function categoryLabelKey(cat)
    return "TXT_KEY_PEDIA_CATEGORY_" .. tostring(cat) .. "_LABEL"
end

-- Stat frames: single-Label frames with a fixed header. headerKey is the
-- base-game TXT_KEY the pedia XML uses for the same label; resolving via
-- Text.key keeps our speech aligned with what sighted users see and picks
-- up localized text automatically. Order is the reading order inside the
-- narrow stack.
local STAT_FRAMES = {
    { frame = "CostFrame", label = "CostLabel", headerKey = "TXT_KEY_PEDIA_COST_LABEL" },
    { frame = "MaintenanceFrame", label = "MaintenanceLabel", headerKey = "TXT_KEY_PEDIA_MAINT_LABEL" },
    { frame = "HappinessFrame", label = "HappinessLabel", headerKey = "TXT_KEY_PEDIA_HAPPINESS_LABEL" },
    { frame = "UnmoddedHappinessFrame", label = "UnmoddedHappinessLabel", headerKey = "TXT_KEY_PEDIA_HAPPINESS_LABEL" },
    { frame = "CultureFrame", label = "CultureLabel", headerKey = "TXT_KEY_PEDIA_CULTURE_LABEL" },
    { frame = "FaithFrame", label = "FaithLabel", headerKey = "TXT_KEY_PEDIA_FAITH_LABEL" },
    { frame = "DefenseFrame", label = "DefenseLabel", headerKey = "TXT_KEY_PEDIA_DEFENSE_LABEL" },
    { frame = "FoodFrame", label = "FoodLabel", headerKey = "TXT_KEY_PEDIA_FOOD_LABEL" },
    { frame = "GoldChangeFrame", label = "GoldChangeLabel", headerKey = "TXT_KEY_PEDIA_GOLD_LABEL" },
    { frame = "GoldFrame", label = "GoldLabel", headerKey = "TXT_KEY_PEDIA_GOLD_LABEL" },
    { frame = "ScienceFrame", label = "ScienceLabel", headerKey = "TXT_KEY_PEDIA_SCIENCE_LABEL" },
    {
        frame = "ProductionFrame",
        label = "ProductionLabel",
        headerKey = "TXT_KEY_PEDIA_PRODUCTION_LABEL",
    },
    { frame = "GreatPeopleFrame", label = "GreatPeopleLabel", headerKey = "TXT_KEY_PEDIA_GP_LABEL" },
    { frame = "CombatFrame", label = "CombatLabel", headerKey = "TXT_KEY_PEDIA_COMBAT_LABEL" },
    {
        frame = "RangedCombatFrame",
        label = "RangedCombatLabel",
        headerKey = "TXT_KEY_PEDIA_RANGEDCOMBAT_LABEL",
    },
    { frame = "RangedCombatRangeFrame", label = "RangedCombatRangeLabel", headerKey = "TXT_KEY_PEDIA_RANGE_LABEL" },
    { frame = "MovementFrame", label = "MovementLabel", headerKey = "TXT_KEY_PEDIA_MOVEMENT_LABEL" },
    {
        frame = "CombatTypeFrame",
        label = "CombatTypeLabel",
        headerKey = "TXT_KEY_PEDIA_COMBATTYPE_LABEL",
    },
    { frame = "YieldFrame", label = "YieldLabel", headerKey = "TXT_KEY_PEDIA_YIELD_LABEL" },
    {
        frame = "MountainYieldFrame",
        label = "MountainYieldLabel",
        headerKey = "TXT_KEY_PEDIA_MOUNTAINADJYIELD_LABEL",
    },
    { frame = "MovementCostFrame", label = "MovementCostLabel", headerKey = "TXT_KEY_PEDIA_MOVECOST_LABEL" },
    { frame = "CombatModFrame", label = "CombatModLabel", headerKey = "TXT_KEY_PEDIA_COMBATMOD_LABEL" },
    { frame = "LivedFrame", label = "LivedLabel", headerKey = "TXT_KEY_PEDIA_LIVED_LABEL" },
    { frame = "TitlesFrame", label = "TitlesLabel", headerKey = "TXT_KEY_PEDIA_TITLES_LABEL" },
    {
        frame = "PrereqEraFrame",
        label = "PrereqEraLabel",
        headerKey = "TXT_KEY_PEDIA_PREREQ_ERA_LABEL",
    },
    {
        frame = "PolicyBranchFrame",
        label = "PolicyBranchLabel",
        headerKey = "TXT_KEY_PEDIA_POLICYBRANCH_LABEL",
    },
    { frame = "TenetLevelFrame", label = "TenetLevelLabel", headerKey = "TXT_KEY_PEDIA_TENET_LEVEL" },
}

-- Text frames: single-Label frames holding prose. Headers are dropped at
-- harvest time; the header words ("Summary:", "Strategy:", etc.) add
-- nothing the body prose doesn't already convey, so no headerKey is
-- needed here.
local TEXT_FRAMES = {
    { frame = "HomePageBlurbFrame", label = "HomePageBlurbLabel" },
    { frame = "GameInfoFrame", label = "GameInfoLabel" },
    { frame = "AbilitiesFrame", label = "AbilitiesLabel" },
    { frame = "SummaryFrame", label = "SummaryLabel" },
    { frame = "ExtendedFrame", label = "ExtendedLabel" },
    { frame = "DNotesFrame", label = "DNotesLabel" },
    { frame = "StrategyFrame", label = "StrategyLabel" },
    { frame = "HistoryFrame", label = "HistoryLabel" },
    { frame = "QuoteFrame", label = "QuoteLabel" },
    { frame = "SilentQuoteFrame", label = "SilentQuoteLabel" },
}

-- Relationship frames: each holds an InstanceManager-allocated grid of
-- buttons (icons labeled with a target article's tooltip, carrying the
-- target's row ID in Void1). Visible frames produce one activatable leaf
-- per instance; activation follows the link by calling SelectArticle on
-- the target category and rebuilding the reader.
--
-- The manager field references the InstanceManager directly -- the base-
-- game pedia's `local g_XManager` declarations are stripped in our
-- override so these references resolve at load time. A `category = nil`
-- entry means "display-only" (Traits, GreatWorks, Replaces when the
-- current article's category isn't Units or Buildings) -- leaves are
-- emitted as plain (non-activatable) Text.
local RELATIONSHIP_DEFS = {
    {
        frame = "PrereqTechFrame",
        manager = g_PrereqTechManager,
        button = "PrereqTechButton",
        category = Civilopedia.CATEGORY.TECH,
        headerKey = "TXT_KEY_PEDIA_PREREQ_TECH_LABEL",
    },
    {
        frame = "LeadsToTechFrame",
        manager = g_LeadsToTechManager,
        button = "LeadsToTechButton",
        category = Civilopedia.CATEGORY.TECH,
        headerKey = "TXT_KEY_PEDIA_LEADS_TO_TECH_LABEL",
    },
    {
        frame = "ObsoleteTechFrame",
        manager = g_ObsoleteTechManager,
        button = "ObsoleteTechButton",
        category = Civilopedia.CATEGORY.TECH,
        headerKey = "TXT_KEY_PEDIA_OBSOLETE_TECH_LABEL",
    },
    {
        frame = "RevealTechsFrame",
        manager = g_RevealTechsManager,
        button = "RevealTechButton",
        category = Civilopedia.CATEGORY.TECH,
        headerKey = "TXT_KEY_PEDIA_REVEAL_TECH_LABEL",
    },
    {
        frame = "UnlockedUnitsFrame",
        manager = g_UnlockedUnitsManager,
        button = "UnlockedUnitButton",
        category = Civilopedia.CATEGORY.UNITS,
        headerKey = "TXT_KEY_PEDIA_UNIT_UNLOCK_LABEL",
    },
    {
        frame = "UnlockedBuildingsFrame",
        manager = g_UnlockedBuildingsManager,
        button = "UnlockedBuildingButton",
        category = Civilopedia.CATEGORY.BUILDINGS,
        headerKey = "TXT_KEY_PEDIA_BLDG_UNLOCK_LABEL",
    },
    {
        frame = "UnlockedProjectsFrame",
        manager = g_UnlockedProjectsManager,
        button = "UnlockedProjectButton",
        category = Civilopedia.CATEGORY.WONDERS,
        headerKey = "TXT_KEY_PEDIA_PROJ_UNLOCK_LABEL",
    },
    {
        frame = "RevealedResourcesFrame",
        manager = g_RevealedResourcesManager,
        button = "RevealedResourceButton",
        category = Civilopedia.CATEGORY.RESOURCES,
        headerKey = "TXT_KEY_PEDIA_RESRC_RVL_LABEL",
    },
    {
        frame = "RequiredResourcesFrame",
        manager = g_RequiredResourcesManager,
        button = "RequiredResourceButton",
        category = Civilopedia.CATEGORY.RESOURCES,
        headerKey = "TXT_KEY_PEDIA_REQ_RESRC_LABEL",
    },
    {
        frame = "LocalResourcesFrame",
        manager = g_LocalResourcesManager,
        button = "LocalResourceButton",
        category = Civilopedia.CATEGORY.RESOURCES,
        headerKey = "TXT_KEY_PEDIA_LOCAL_RESRC_LABEL",
    },
    {
        frame = "WorkerActionsFrame",
        manager = g_WorkerActionsManager,
        button = "WorkerActionButton",
        category = Civilopedia.CATEGORY.IMPROVEMENTS,
        headerKey = "TXT_KEY_PEDIA_WORKER_ACTION_LABEL",
    },
    {
        frame = "FreePromotionsFrame",
        manager = g_PromotionsManager,
        button = "PromotionButton",
        category = Civilopedia.CATEGORY.PROMOTIONS,
        headerKey = "TXT_KEY_PEDIA_FREEPROMOTIONS_LABEL",
    },
    {
        frame = "RequiredPromotionsFrame",
        manager = g_RequiredPromotionsManager,
        button = "RequiredPromotionButton",
        category = Civilopedia.CATEGORY.PROMOTIONS,
        headerKey = "TXT_KEY_PEDIA_REQ_PROMOTIONS_LABEL",
    },
    {
        frame = "RequiredBuildingsFrame",
        manager = g_RequiredBuildingsManager,
        button = "RequiredBuildingButton",
        category = Civilopedia.CATEGORY.BUILDINGS,
        headerKey = "TXT_KEY_PEDIA_REQ_BLDG_LABEL",
    },
    {
        frame = "RequiredPoliciesFrame",
        manager = g_RequiredPoliciesManager,
        button = "RequiredPolicyButton",
        category = Civilopedia.CATEGORY.POLICIES,
        headerKey = "TXT_KEY_PEDIA_PREREQ_POLICY_LABEL",
    },
    {
        frame = "SpecialistsFrame",
        manager = g_SpecialistsManager,
        button = "SpecialistButton",
        category = Civilopedia.CATEGORY.PEOPLE,
        headerKey = "TXT_KEY_PEDIA_SPEC_LABEL",
    },
    {
        frame = "LeadersFrame",
        manager = g_LeadersManager,
        button = "LeaderButton",
        category = Civilopedia.CATEGORY.CIVILIZATIONS,
        headerKey = "TXT_KEY_PEDIA_LEADERS_LABEL",
    },
    {
        frame = "CivilizationsFrame",
        manager = g_CivilizationsManager,
        button = "CivilizationButton",
        category = Civilopedia.CATEGORY.CIVILIZATIONS,
        headerKey = "TXT_KEY_PEDIA_CIVILIZATIONS_LABEL",
    },
    {
        frame = "UniqueUnitsFrame",
        manager = g_UniqueUnitsManager,
        button = "UniqueUnitButton",
        category = Civilopedia.CATEGORY.UNITS,
        headerKey = "TXT_KEY_PEDIA_UNIQUEUNIT_LABEL",
    },
    {
        frame = "UniqueBuildingsFrame",
        manager = g_UniqueBuildingsManager,
        button = "UniqueBuildingButton",
        category = Civilopedia.CATEGORY.BUILDINGS,
        headerKey = "TXT_KEY_PEDIA_UNIQUEBLDG_LABEL",
    },
    {
        frame = "UniqueImprovementsFrame",
        manager = g_UniqueImprovementsManager,
        button = "UniqueImprovementButton",
        category = Civilopedia.CATEGORY.IMPROVEMENTS,
        headerKey = "TXT_KEY_PEDIA_UNIQUEIMPRV_LABEL",
    },
    {
        frame = "UpgradeFrame",
        manager = g_UpgradeManager,
        button = "UpgradeButton",
        category = Civilopedia.CATEGORY.UNITS,
        headerKey = "TXT_KEY_COMMAND_UPGRADE",
    },
    {
        frame = "FeaturesFrame",
        manager = g_FeaturesManager,
        button = "FeatureButton",
        category = Civilopedia.CATEGORY.TERRAIN,
        headerKey = "TXT_KEY_PEDIA_FEATURES_LABEL",
    },
    {
        frame = "TerrainsFrame",
        manager = g_TerrainsManager,
        button = "TerrainButton",
        category = Civilopedia.CATEGORY.TERRAIN,
        headerKey = "TXT_KEY_PEDIA_TERRAINS_LABEL",
    },
    {
        frame = "ImprovementsFrame",
        manager = g_ImprovementsManager,
        button = "ImprovementButton",
        category = Civilopedia.CATEGORY.IMPROVEMENTS,
        headerKey = "TXT_KEY_PEDIA_IMPROVEMENTS_LABEL",
    },
    -- Context-dependent target category; resolved at scrape time from the
    -- current article's category.
    {
        frame = "ReplacesFrame",
        manager = g_ReplacesManager,
        button = "ReplaceButton",
        category = "ctx_replaces",
        headerKey = "TXT_KEY_PEDIA_REPLACES_LABEL",
    },
    {
        frame = "ResourcesFoundFrame",
        manager = g_ResourcesFoundManager,
        button = "ResourceFoundButton",
        category = "ctx_resources_found",
        headerKey = "TXT_KEY_PEDIA_RESOURCESFOUND_LABEL",
    },
    -- Display-only (no navigation): the relationship has no single link
    -- target that makes sense to navigate to.
    {
        frame = "TraitsFrame",
        manager = g_TraitsManager,
        button = "TraitButton",
        category = nil,
        headerKey = "TXT_KEY_PEDIA_TRAITS_LABEL",
    },
    {
        frame = "GreatWorksFrame",
        manager = g_GreatWorksManager,
        button = "GreatWorksButton",
        category = nil,
        headerKey = "TXT_KEY_PEDIA_GREAT_WORKS_LABEL",
    },
}

-- Control-access helpers ------------------------------------------------

local function ctrlText(ctrl)
    if ctrl == nil then
        return ""
    end
    return ctrl:GetText() or ""
end

local function ctrlHidden(ctrl)
    return ctrl == nil or ctrl:IsHidden()
end

-- Canonical Entry id format. Picker and follow-link paths both build ids
-- through this so link-follow in tuple-entryID categories (WorldCongress
-- uses {resolution, option}) syncs the picker cursor correctly.
local function makeEntryID(cat, entryID)
    if type(entryID) == "table" then
        return tostring(cat) .. ":" .. tostring(entryID[1]) .. ":" .. tostring(entryID[2])
    end
    return tostring(cat) .. ":" .. tostring(entryID)
end

local function addLeaf(leaves, header, body)
    if body == nil or body == "" then
        return
    end
    local text
    if header == nil or header == "" then
        text = body
    else
        text = header .. ": " .. body
    end
    leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = text })
end

-- Resolve a def's headerKey to a speakable string via the Text wrapper
-- (missing keys surface in Lua.log). Strips the trailing ":" that base-
-- game TXT_KEY_PEDIA_*_LABEL values ship with so call sites can always
-- add their own ": " separator without doubling up.
local function headerFor(def)
    if def.headerKey == nil or def.headerKey == "" then
        return ""
    end
    local h = Text.key(def.headerKey)
    if type(h) == "string" and h:sub(-1) == ":" then
        return h:sub(1, -2)
    end
    return h
end

-- Resolve a relationship's target category. Most defs have a fixed
-- category; the "ctx_*" sentinels defer to the current article's
-- category (ReplacesFrame → current cat; ResourcesFoundFrame flips
-- between Terrain and Resources).
local function resolveRelationshipCategory(def, currentCat)
    local c = def.category
    if c == nil then
        return nil
    end
    if type(c) == "number" then
        return c
    end
    if c == "ctx_replaces" then
        return currentCat
    elseif c == "ctx_resources_found" then
        if currentCat == Civilopedia.CATEGORY.TERRAIN then
            return Civilopedia.CATEGORY.RESOURCES
        elseif currentCat == Civilopedia.CATEGORY.RESOURCES then
            return Civilopedia.CATEGORY.TERRAIN
        end
        return Civilopedia.CATEGORY.RESOURCES
    end
    return nil
end

-- Forward declaration: followLink closes over handler + target cat/id and
-- rebuilds the reader in place. Defined below the scraper so the scraper
-- can reference it without a cycle.
local followLink

-- Section / picker enumeration ------------------------------------------

-- Sequential-key text-key patterns: categories whose sections are labeled
-- TXT_KEY_<PREFIX>_0 .. <PREFIX>_N in the base pedia. Matches the prior-
-- generation mod's SECTION_TEXT_KEYS table.
local SECTION_TEXT_KEY_PREFIX = {
    [Civilopedia.CATEGORY.GAME_CONCEPTS] = "TXT_KEY_GAME_CONCEPT_SECTION_",
    [Civilopedia.CATEGORY.PROMOTIONS] = "TXT_KEY_PROMOTIONS_SECTION_",
    [Civilopedia.CATEGORY.WONDERS] = "TXT_KEY_WONDER_SECTION_",
    [Civilopedia.CATEGORY.PEOPLE] = "TXT_KEY_PEOPLE_SECTION_",
    [Civilopedia.CATEGORY.CIVILIZATIONS] = "TXT_KEY_CIVILIZATIONS_SECTION_",
    [Civilopedia.CATEGORY.TERRAIN] = "TXT_KEY_TERRAIN_SECTION_",
    [Civilopedia.CATEGORY.RESOURCES] = "TXT_KEY_RESOURCES_SECTION_",
    [Civilopedia.CATEGORY.BELIEFS] = "TXT_KEY_PEDIA_BELIEFS_CATEGORY_",
    [Civilopedia.CATEGORY.WORLD_CONGRESS] = "TXT_KEY_PEDIA_WORLD_CONGRESS_CATEGORY_",
}

-- Return an ordered list of { key = N, label = "...", articles = [...] }
-- for a category. Section ordering matches the pedia's left-sidebar: era-
-- grouped for Tech/Units/Buildings (with an optional Faith section at key 0
-- when religion is on), branch-grouped for Policies, trait-grouped for
-- City-States, and sequential-TXT_KEY-labeled for the rest. Flat categories
-- (Home, Improvements) return a single unlabeled section.
local function getSections(cat)
    local sections = {}
    if sortedList == nil then
        Log.warn("Civilopedia: sortedList global not found for cat " .. tostring(cat))
        return sections
    end
    local sl = sortedList[cat]
    if sl == nil then
        return sections
    end
    local CAT = Civilopedia.CATEGORY

    if cat == CAT.HOME_PAGE or cat == CAT.IMPROVEMENTS then
        if sl[1] and #sl[1] > 0 then
            sections[#sections + 1] = { key = 1, label = "", articles = sl[1] }
        end
        return sections
    end

    if cat == CAT.TECH then
        for era in GameInfo.Eras() do
            if sl[era.ID] and #sl[era.ID] > 0 then
                sections[#sections + 1] = {
                    key = era.ID,
                    label = Text.key(era.Description),
                    articles = sl[era.ID],
                }
            end
        end
        return sections
    end

    if cat == CAT.UNITS or cat == CAT.BUILDINGS then
        -- Optional Faith section at key 0 when religion is active; era
        -- sections then start at key 1 (not era.ID 0 directly).
        local offset = 0
        local religionOn = (Game == nil) or (not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION))
        if religionOn and sl[0] and #sl[0] > 0 then
            sections[#sections + 1] = {
                key = 0,
                label = Text.key("TXT_KEY_PEDIA_RELIGIOUS"),
                articles = sl[0],
            }
            offset = 1
        end
        for era in GameInfo.Eras() do
            local k = era.ID + offset
            if sl[k] and #sl[k] > 0 then
                sections[#sections + 1] = {
                    key = k,
                    label = Text.key(era.Description),
                    articles = sl[k],
                }
            end
        end
        return sections
    end

    if cat == CAT.POLICIES then
        for branch in GameInfo.PolicyBranchTypes() do
            if sl[branch.ID] and #sl[branch.ID] > 0 then
                sections[#sections + 1] = {
                    key = branch.ID,
                    label = Text.key(branch.Description),
                    articles = sl[branch.ID],
                }
            end
        end
        return sections
    end

    if cat == CAT.CITY_STATES then
        for trait in GameInfo.MinorCivTraits() do
            if sl[trait.ID] and #sl[trait.ID] > 0 then
                sections[#sections + 1] = {
                    key = trait.ID,
                    label = Text.key(trait.Description),
                    articles = sl[trait.ID],
                }
            end
        end
        return sections
    end

    local prefix = SECTION_TEXT_KEY_PREFIX[cat]
    if prefix then
        -- Sequential 0..N; bounded at 99 as a sanity cap (largest observed
        -- is 25 for Game Concepts). Skip any gap in the sequence silently.
        for key = 0, 99 do
            if sl[key] and #sl[key] > 0 then
                sections[#sections + 1] = {
                    key = key,
                    label = Text.key(prefix .. tostring(key)),
                    articles = sl[key],
                }
            end
        end
        return sections
    end

    -- Fallback: iterate numeric keys in ascending order, no label.
    local keys = {}
    for k in pairs(sl) do
        if type(k) == "number" then
            keys[#keys + 1] = k
        end
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
        if sl[k] and #sl[k] > 0 then
            sections[#sections + 1] = { key = k, label = "", articles = sl[k] }
        end
    end
    return sections
end

-- Entry factory ---------------------------------------------------------

local function entryFromArticle(entryFactory, cat, article)
    local entryID = article.entryID
    return entryFactory({
        id = makeEntryID(cat, entryID),
        labelText = tostring(article.entryName or ""),
        buildReader = function(handler, id)
            return Civilopedia.buildReader(handler, cat, entryID)
        end,
    })
end

-- Intro Entry for a category: activation calls the category's DisplayHomePage
-- which populates the pedia's Controls with the category overview (e.g.
-- TXT_KEY_PEDIA_GAME_CONCEPT_HELP_TEXT for Game Concepts, the main pedia
-- welcome for Home Page, etc.). Every category defines a DisplayHomePage --
-- this is the article the user couldn't reach from our picker before.
--
-- `spec` overrides: `label` swaps the Intro label (used to hoist the Home
-- Page intro to the top level of the picker under its localized category
-- name, "Civilopedia Home Page", rather than a generic "Intro" inside an
-- otherwise-empty drill-in).
local function introEntry(entryFactory, cat, spec)
    spec = spec or {}
    local entrySpec = {
        id = tostring(cat) .. ":intro",
        buildReader = function(handler)
            local fn = CivilopediaCategory and CivilopediaCategory[cat] and CivilopediaCategory[cat].DisplayHomePage
            if type(fn) == "function" then
                local ok, err = pcall(fn)
                if not ok then
                    Log.warn("Civilopedia Intro DisplayHomePage(" .. tostring(cat) .. ") failed: " .. tostring(err))
                end
            end
            local leaves = {}
            Civilopedia._harvestInto(leaves, handler, cat)
            if #leaves == 0 then
                leaves[1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"),
                })
            end
            return { items = leaves, autoDrillToLevel = 1 }
        end,
    }
    if spec.textKey ~= nil then
        entrySpec.textKey = spec.textKey
    else
        entrySpec.labelText = spec.labelText or Text.key("TXT_KEY_CIVVACCESS_PEDIA_INTRO")
    end
    return entryFactory(entrySpec)
end

-- Build the children of a category Group:
--   [Intro] + section Groups (when there are multiple or labeled sections)
--   [Intro] + flat article Entries (when the category has a single unlabeled
--             section -- flattens the redundant drill layer)
--   [Intro] (when the category has no articles beyond the overview)
local function categoryChildren(entryFactory, cat)
    local children = { introEntry(entryFactory, cat) }
    local sections = getSections(cat)

    local soloUnlabeled = (#sections == 1 and (sections[1].label == nil or sections[1].label == ""))
    if soloUnlabeled then
        for _, article in ipairs(sections[1].articles) do
            children[#children + 1] = entryFromArticle(entryFactory, cat, article)
        end
        return children
    end

    for _, sec in ipairs(sections) do
        local articles = sec.articles
        children[#children + 1] = BaseMenuItems.Group({
            labelText = sec.label,
            cached = false,
            itemsFn = function()
                local entries = {}
                for i, article in ipairs(articles) do
                    entries[i] = entryFromArticle(entryFactory, cat, article)
                end
                return entries
            end,
        })
    end
    return children
end

local function categoryGroup(cat, entryFactory)
    local item = BaseMenuItems.Group({
        textKey = categoryLabelKey(cat),
        cached = false,
        itemsFn = function()
            return categoryChildren(entryFactory, cat)
        end,
    })
    -- Tag the top-level picker item with its category number so
    -- Civilopedia.openCategory / stageCategoryForShow can locate the
    -- matching heading from the iHomePage value that
    -- Events.GoToPediaHomePage fires.
    item.category = cat
    return item
end

local function hasTable(name)
    return GameInfo[name] ~= nil
end

-- Harvesters ------------------------------------------------------------

-- Title is deliberately skipped: the user already heard the article's
-- name when they activated its Entry in the picker; repeating it as the
-- first reader line is redundant. Stats keep their header prefix because
-- bare values ("40", "+2") are meaningless without the label.
local function harvestStats(leaves)
    for _, def in ipairs(STAT_FRAMES) do
        if not ctrlHidden(Controls[def.frame]) then
            addLeaf(leaves, headerFor(def), ctrlText(Controls[def.label]))
        end
    end
end

-- Text sections drop their header prefix: "Summary: ...", "Strategy: ...",
-- "Historical Info: ..." add nothing the body prose doesn't already convey
-- and just delay the content. Relationship links and stat frames keep
-- their headers (they label an otherwise-ambiguous value). FFText/BBText
-- keep per-instance headers because those vary per article and actually
-- name the block (civ unique-ability title, home-page how-to, etc.).
local function harvestTextSections(leaves)
    for _, def in ipairs(TEXT_FRAMES) do
        if not ctrlHidden(Controls[def.frame]) then
            addLeaf(leaves, "", ctrlText(Controls[def.label]))
        end
    end
end

-- Drop the header when it just repeats the article title (e.g. the
-- per-category DisplayHomePage writes "Technologies" into both ArticleID
-- and the BBText block's header, so without this guard every Intro speaks
-- its category name twice: once from the picker selection, once as the
-- first block header).
local function dropTitleEchoHeader(header, title)
    if header == nil or header == "" then
        return ""
    end
    if title ~= nil and title ~= "" and header == title then
        return ""
    end
    return header
end

-- FFTextStack: free-form per-instance {header, body} pairs used for
-- Civilizations (unique ability write-up) and richer profile pages. Each
-- instance has FFTextHeader + FFTextLabel. Skip when stack is hidden:
-- ClearArticle hides the stack but leaves stale allocated instances.
local function harvestFreeFormText(leaves)
    if ctrlHidden(Controls.FFTextStack) then
        return
    end
    local mgr = g_FreeFormTextManager
    if mgr == nil or mgr.m_AllocatedInstances == nil then
        return
    end
    local title = ctrlText(Controls.ArticleID)
    for _, instance in ipairs(mgr.m_AllocatedInstances) do
        local header = dropTitleEchoHeader(ctrlText(instance.FFTextHeader), title)
        local body = ctrlText(instance.FFTextLabel)
        addLeaf(leaves, header, body)
    end
end

-- BBTextStack: full-width intro blurbs used by home pages. Same shape as
-- FFText: per-instance header + body.
local function harvestBBText(leaves)
    if ctrlHidden(Controls.BBTextStack) then
        return
    end
    local mgr = g_BBTextManager
    if mgr == nil or mgr.m_AllocatedInstances == nil then
        return
    end
    local title = ctrlText(Controls.ArticleID)
    for _, instance in ipairs(mgr.m_AllocatedInstances) do
        local header = dropTitleEchoHeader(ctrlText(instance.BBTextHeader), title)
        local body = ctrlText(instance.BBTextLabel)
        addLeaf(leaves, header, body)
    end
end

-- Relationship frames. Each visible frame produces one leaf per button
-- instance. Navigable target categories emit an activatable Choice;
-- display-only entries (Traits, GreatWorks, context-unresolvable Replaces)
-- emit plain Text. Duplicate links within a single frame are coalesced by
-- (voidID, label) since stale instances can linger between articles.
local function harvestRelationships(leaves, handler, currentCat)
    for _, def in ipairs(RELATIONSHIP_DEFS) do
        if not ctrlHidden(Controls[def.frame]) then
            local mgr = def.manager
            if mgr ~= nil and mgr.m_AllocatedInstances ~= nil then
                local targetCat = resolveRelationshipCategory(def, currentCat)
                local header = headerFor(def)
                local seen = {}
                for _, instance in ipairs(mgr.m_AllocatedInstances) do
                    local btn = instance[def.button]
                    if btn ~= nil then
                        local label = btn:GetToolTipString()
                        -- GreatWorksButton is a <Container> in
                        -- CivilopediaScreen.xml, not a <Button>, and
                        -- Container userdata has no GetVoid1. Any future
                        -- non-Button instance "button" falls into the
                        -- same bucket. Treat missing as nil voidID,
                        -- which degrades the leaf to a plain Text entry
                        -- (no link-follow, but still readable).
                        local voidID = nil
                        if btn.GetVoid1 ~= nil then
                            local ok_v, v = pcall(btn.GetVoid1, btn)
                            if ok_v then
                                voidID = v
                            end
                        end
                        if label ~= nil and label ~= "" then
                            local dedup = tostring(voidID) .. "|" .. tostring(label)
                            if not seen[dedup] then
                                seen[dedup] = true
                                local text = header .. ": " .. tostring(label)
                                if voidID ~= nil and targetCat ~= nil then
                                    local capturedCat, capturedID = targetCat, voidID
                                    leaves[#leaves + 1] = BaseMenuItems.Choice({
                                        labelText = text,
                                        activate = function()
                                            followLink(handler, capturedCat, capturedID)
                                        end,
                                    })
                                else
                                    leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = text })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Combined harvester. Order matches the article's natural top-to-bottom
-- reading: title + stats, FFText (used by civs in place of the simple text
-- frames), BBText (home pages), text sections, relationships.
function Civilopedia._harvestInto(leaves, handler, currentCat)
    harvestStats(leaves)
    harvestFreeFormText(leaves)
    harvestBBText(leaves)
    harvestTextSections(leaves)
    harvestRelationships(leaves, handler, currentCat)
end

-- Harvest the currently-rendered article and populate the reader tab
-- with it. Callers must drive SelectArticle (via any path) before
-- calling this so the live Controls contain the target's text.
--
-- _harvestInto is pcalled so a broken individual harvester doesn't
-- abort the setItems call. The caller still needs setItems to run --
-- otherwise the reader tab keeps its placeholder, and in the
-- stage-for-show path setInitialTabIndex never lands us on the reader
-- tab at all (dumping the user on the picker instead of the article).
local function harvestIntoReader(handler, cat, entryID)
    if type(handler.setPickerReaderSelection) == "function" then
        handler.setPickerReaderSelection(makeEntryID(cat, entryID))
    end
    local leaves = {}
    local ok, err = pcall(Civilopedia._harvestInto, leaves, handler, cat)
    if not ok then
        Log.error(
            "Civilopedia harvest failed (cat=" .. tostring(cat) .. " id=" .. tostring(entryID) .. "): " .. tostring(err)
        )
    end
    if #leaves == 0 then
        leaves[1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"),
        })
    end
    handler.setItems(leaves, READER_TAB_IDX)
end

-- Shared tail of every in-reader navigation: harvest + setItems, then
-- programmatic switchToTab(force=true) to re-announce even though the
-- reader is already the active tab.
function Civilopedia.openArticle(handler, cat, entryID)
    harvestIntoReader(handler, cat, entryID)
    handler.switchToTab(READER_TAB_IDX)
end

-- Staging variant used when the pedia is hidden and is about to be
-- shown (e.g., by Events.SearchForPediaEntry's QueuePopup). Populates
-- the reader tab and sets the initial tab so openInitial lands on the
-- article with its text already in place, rather than going through
-- openArticle's switchToTab (which would announce into an empty UI
-- before ShowHide completes).
function Civilopedia.stageArticleForShow(handler, cat, entryID)
    harvestIntoReader(handler, cat, entryID)
    handler.setInitialTabIndex(READER_TAB_IDX)
end

-- Find the top-level picker index whose item represents the given
-- category. Returns nil if the category is not present in the current
-- picker tree (e.g., Beliefs in a base / G&K game -- unreachable for us
-- today, but the guard is free).
local function findCategoryPickerIdx(handler, cat)
    local pickerItems = handler.tabs[1]._items
    for i, item in ipairs(pickerItems) do
        if item.category == cat then
            return i
        end
    end
    return nil
end

-- Visible-pedia path for Events.GoToPediaHomePage: teleport the picker
-- cursor to the category's top-level heading and speak its label. The
-- user hits Enter to drill in (or, for Home Page, to read the welcome
-- page directly).
function Civilopedia.openCategory(handler, iHomePage)
    local idx = findCategoryPickerIdx(handler, iHomePage)
    if idx == nil then
        Log.warn("Civilopedia.openCategory: no picker idx for category " .. tostring(iHomePage))
        return
    end
    if handler._tabIndex ~= 1 then
        handler.switchToTab(1)
    end
    handler._level = 1
    handler._indices = { idx }
    local label = BaseMenuItems.labelOf(handler.tabs[1]._items[idx]) or ""
    if label ~= "" then
        SpeechPipeline.speakInterrupt(label)
    end
end

-- Staging variant: pedia is hidden; set the initial cursor / tab so
-- openInitial lands on the category heading without a mid-transition
-- announce.
function Civilopedia.stageCategoryForShow(handler, iHomePage)
    local idx = findCategoryPickerIdx(handler, iHomePage)
    if idx == nil then
        Log.warn("Civilopedia.stageCategoryForShow: no picker idx for category " .. tostring(iHomePage))
        return
    end
    handler.setInitialIndex(idx)
    handler.setInitialTabIndex(1)
end

-- Follow an embedded relationship link to another article. Activation
-- pushes the target onto the base pedia's history list (addToList=1) so
-- subsequent Alt+Left can step back to the article the link was on.
function followLink(handler, targetCat, targetID)
    if
        CivilopediaCategory ~= nil
        and CivilopediaCategory[targetCat] ~= nil
        and type(CivilopediaCategory[targetCat].SelectArticle) == "function"
    then
        local ok, err = pcall(CivilopediaCategory[targetCat].SelectArticle, targetID, 1)
        if not ok then
            Log.warn(
                "Civilopedia followLink SelectArticle("
                    .. tostring(targetCat)
                    .. ", "
                    .. tostring(targetID)
                    .. ") failed: "
                    .. tostring(err)
            )
        end
    end
    Civilopedia.openArticle(handler, targetCat, targetID)
end

-- History back/forward. The base pedia's Back / Forward buttons step a
-- (currentTopic, endTopic, listOfTopicsViewed) triple maintained by every
-- addToList=1 SelectArticle call, then re-SelectArticle the target with
-- addToList=0 (skip-add) to avoid polluting history with the navigation
-- itself. Our picker-driven buildReader and link-follow paths both pass
-- addToList=1, so history is populated automatically; these two functions
-- just walk the cursor and drive the re-harvest.
--
-- At the boundary (no-more-history either way) we speak a short "no
-- previous / no next" message rather than staying silent: the user has
-- no other channel to discover that their key did nothing.
function Civilopedia.goBack(handler)
    if currentTopic == nil or currentTopic <= 1 then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"))
        return
    end
    local targetTopic = currentTopic - 1
    local article = listOfTopicsViewed[targetTopic]
    if article == nil then
        Log.warn("Civilopedia.goBack: listOfTopicsViewed[" .. tostring(targetTopic) .. "] is nil")
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"))
        return
    end
    currentTopic = targetTopic
    local cat = article.entryCategory
    SetSelectedCategory(cat)
    if CivilopediaCategory[cat] ~= nil and type(CivilopediaCategory[cat].SelectArticle) == "function" then
        local ok, err = pcall(CivilopediaCategory[cat].SelectArticle, article.entryID, 0)
        if not ok then
            Log.warn(
                "Civilopedia.goBack SelectArticle("
                    .. tostring(cat)
                    .. ", "
                    .. tostring(article.entryID)
                    .. ") failed: "
                    .. tostring(err)
            )
        end
    end
    Civilopedia.openArticle(handler, cat, article.entryID)
end

function Civilopedia.goForward(handler)
    if currentTopic == nil or endTopic == nil or currentTopic >= endTopic then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"))
        return
    end
    local targetTopic = currentTopic + 1
    local article = listOfTopicsViewed[targetTopic]
    if article == nil then
        Log.warn("Civilopedia.goForward: listOfTopicsViewed[" .. tostring(targetTopic) .. "] is nil")
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"))
        return
    end
    currentTopic = targetTopic
    local cat = article.entryCategory
    SetSelectedCategory(cat)
    if CivilopediaCategory[cat] ~= nil and type(CivilopediaCategory[cat].SelectArticle) == "function" then
        local ok, err = pcall(CivilopediaCategory[cat].SelectArticle, article.entryID, 0)
        if not ok then
            Log.warn(
                "Civilopedia.goForward SelectArticle("
                    .. tostring(cat)
                    .. ", "
                    .. tostring(article.entryID)
                    .. ") failed: "
                    .. tostring(err)
            )
        end
    end
    Civilopedia.openArticle(handler, cat, article.entryID)
end

-- Flat search corpus -----------------------------------------------------
--
-- Without this, "camel archer" typed at the top of the picker matches
-- nothing: the 16 top-level items are category Groups, so article names
-- are unreachable by search until the user has drilled into the right
-- category. Blind users have no way to know an article even exists from
-- the top level. Flat search breaks that by making every Entry across
-- the whole tree type-ahead-reachable from anywhere in the picker.
--
-- Group 0 is the article layer; group 1 is the category/intro fallback
-- layer. When both would match, articles always win (the groupOf axis
-- in TypeAheadSearch dominates tier), so "tech" lands on a Technology
-- article instead of the Tech category, while still allowing the user
-- to reach the category when no article shares the prefix.
--
-- moveTo teleports the picker cursor by writing handler._level and
-- handler._indices to the target's path, then speaking the label.
-- Arrow nav then resumes from the landed position: Civ V's cached=false
-- section Groups lazily rebuild their children on the next
-- currentItems call (itemsAtLevel handles that for normal drill-in).

local function isIntroId(id)
    return type(id) == "string" and id:sub(-#":intro") == ":intro"
end

-- Depth-first walk of picker items. At every Group, call :children() to
-- materialize and recurse; at every Entry leaf, invoke visit with the
-- leaf + its full path.
local function walkWithPath(items, path, visit)
    for i, item in ipairs(items) do
        path[#path + 1] = i
        if item.kind == "entry" then
            visit(item, path)
        elseif item.kind == "group" then
            walkWithPath(item:children(), path, visit)
        end
        path[#path] = nil
    end
end

local function copyPath(path)
    local copy = {}
    for i, v in ipairs(path) do
        copy[i] = v
    end
    return copy
end

local function buildFlatCorpus(pickerItems)
    local flat = {}
    -- Track ids already added in the category-tier pass so the leaf walk
    -- can skip exactly those, rather than dropping anything that looks
    -- top-level-intro-shaped. Matters if a future top-level intro ever
    -- joins Home Page: the path-depth heuristic would silently drop it,
    -- but id-based dedup skips only what was actually added here.
    local seen = {}
    for i, item in ipairs(pickerItems) do
        if item.kind == "group" then
            flat[#flat + 1] = {
                label = BaseMenuItems.labelOf(item) or "",
                path = { i },
                group = 1,
            }
        elseif item.kind == "entry" and isIntroId(item.id) then
            flat[#flat + 1] = {
                label = BaseMenuItems.labelOf(item) or "",
                path = { i },
                group = 1,
            }
            seen[item.id] = true
        end
    end
    walkWithPath(pickerItems, {}, function(entry, path)
        if seen[entry.id] then
            return
        end
        local group = isIntroId(entry.id) and 1 or 0
        flat[#flat + 1] = {
            label = BaseMenuItems.labelOf(entry) or "",
            path = copyPath(path),
            group = group,
        }
    end)
    return flat
end

-- Teleport the handler cursor to `path` inside `rootItems` (sequence of
-- 1-based indices from the top of the picker tree). rootItems is the
-- picker tab's items captured at corpus-build time so the path always
-- resolves against the tree search was computed against, even if the
-- handler's active tab somehow changed between search and move.
-- Intermediate Groups are materialized during the walk so subsequent
-- arrow nav sees the same child set search resolved against.
local function teleportToPath(handler, rootItems, path, label)
    local cursor = rootItems
    for depth, idx in ipairs(path) do
        if depth == #path then
            break
        end
        local parent = cursor[idx]
        if parent == nil or type(parent.children) ~= "function" then
            Log.warn("Civilopedia flat search: path breaks at depth " .. tostring(depth) .. " index " .. tostring(idx))
            return
        end
        cursor = parent:children()
    end
    handler._level = #path
    handler._indices = copyPath(path)
    if label ~= nil and label ~= "" then
        SpeechPipeline.speakInterrupt(label)
    end
end

-- Build a searchable over the flat corpus. Re-walks the picker tree on
-- every invocation (every keystroke) — acceptable at pedia scale (a few
-- hundred articles) and ensures fresh labels if the tree ever changes.
function Civilopedia.buildFlatSearchable(handler)
    local pickerItems = handler.tabs[handler._tabIndex]._items
    local flat = buildFlatCorpus(pickerItems)
    return {
        itemCount = function()
            return #flat
        end,
        getLabel = function(i)
            local entry = flat[i]
            if entry == nil then
                return nil
            end
            return entry.label
        end,
        groupOf = function(i)
            local entry = flat[i]
            return entry and entry.group or 0
        end,
        moveTo = function(i)
            local entry = flat[i]
            if entry == nil then
                return
            end
            teleportToPath(handler, pickerItems, entry.path, entry.label)
        end,
    }
end

-- Public API ------------------------------------------------------------

function Civilopedia.buildPickerItems(entryFactory)
    if type(entryFactory) ~= "function" then
        error("Civilopedia.buildPickerItems requires an Entry factory", 2)
    end
    local CAT = Civilopedia.CATEGORY
    local items = {}

    -- Home Page lives at the top level as a direct Intro leaf -- the base
    -- pedia's "Home Page" category has no real sub-articles (the 16 entries
    -- it lists are just links to the other category home pages, which we
    -- already expose as L1 Groups). So there's nothing to drill into; Enter
    -- on this entry opens the Civilopedia welcome page directly.
    local home = introEntry(entryFactory, CAT.HOME_PAGE, {
        textKey = categoryLabelKey(CAT.HOME_PAGE),
    })
    home.category = CAT.HOME_PAGE
    items[#items + 1] = home
    items[#items + 1] = categoryGroup(CAT.GAME_CONCEPTS, entryFactory)
    items[#items + 1] = categoryGroup(CAT.TECH, entryFactory)
    items[#items + 1] = categoryGroup(CAT.UNITS, entryFactory)
    items[#items + 1] = categoryGroup(CAT.PROMOTIONS, entryFactory)
    items[#items + 1] = categoryGroup(CAT.BUILDINGS, entryFactory)
    items[#items + 1] = categoryGroup(CAT.WONDERS, entryFactory)
    items[#items + 1] = categoryGroup(CAT.POLICIES, entryFactory)
    items[#items + 1] = categoryGroup(CAT.PEOPLE, entryFactory)
    items[#items + 1] = categoryGroup(CAT.CIVILIZATIONS, entryFactory)
    items[#items + 1] = categoryGroup(CAT.CITY_STATES, entryFactory)
    items[#items + 1] = categoryGroup(CAT.TERRAIN, entryFactory)
    items[#items + 1] = categoryGroup(CAT.RESOURCES, entryFactory)
    items[#items + 1] = categoryGroup(CAT.IMPROVEMENTS, entryFactory)
    if hasTable("Beliefs") then
        items[#items + 1] = categoryGroup(CAT.BELIEFS, entryFactory)
    end
    if hasTable("Resolutions") then
        items[#items + 1] = categoryGroup(CAT.WORLD_CONGRESS, entryFactory)
    end
    return items
end

-- buildReader(handler, category, entryID) - activates the article via the
-- pedia's own SelectArticle, then harvests leaves from the rendered
-- controls. Flat list, autoDrillToLevel = 1.
function Civilopedia.buildReader(handler, category, entryID)
    if
        CivilopediaCategory ~= nil
        and CivilopediaCategory[category] ~= nil
        and type(CivilopediaCategory[category].SelectArticle) == "function"
    then
        local ok, err = pcall(CivilopediaCategory[category].SelectArticle, entryID, 1)
        if not ok then
            Log.warn(
                "Civilopedia SelectArticle("
                    .. tostring(category)
                    .. ", "
                    .. tostring(entryID)
                    .. ") failed: "
                    .. tostring(err)
            )
        end
    end

    local leaves = {}
    Civilopedia._harvestInto(leaves, handler, category)
    if #leaves == 0 then
        Log.warn(
            "Civilopedia buildReader: cat="
                .. tostring(category)
                .. " entryID="
                .. tostring(entryID)
                .. " no visible controls"
        )
        leaves[1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"),
        })
    end
    return { items = leaves, autoDrillToLevel = 1 }
end

return Civilopedia

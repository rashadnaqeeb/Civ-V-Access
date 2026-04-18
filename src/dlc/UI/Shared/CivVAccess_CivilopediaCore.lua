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
    HOME_PAGE      = 1,
    GAME_CONCEPTS  = 2,
    TECH           = 3,
    UNITS          = 4,
    PROMOTIONS     = 5,
    BUILDINGS      = 6,
    WONDERS        = 7,
    POLICIES       = 8,
    PEOPLE         = 9,
    CIVILIZATIONS  = 10,
    CITY_STATES    = 11,
    TERRAIN        = 12,
    RESOURCES      = 13,
    IMPROVEMENTS   = 14,
    BELIEFS        = 15,
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

-- Stat frames: single-Label frames with a fixed header. Order is the
-- reading order inside the narrow stack.
local STAT_FRAMES = {
    { frame = "CostFrame",              label = "CostLabel",              header = "Cost" },
    { frame = "MaintenanceFrame",       label = "MaintenanceLabel",       header = "Maintenance" },
    { frame = "HappinessFrame",         label = "HappinessLabel",         header = "Happiness" },
    { frame = "UnmoddedHappinessFrame", label = "UnmoddedHappinessLabel", header = "Happiness" },
    { frame = "CultureFrame",           label = "CultureLabel",           header = "Culture" },
    { frame = "FaithFrame",             label = "FaithLabel",             header = "Faith" },
    { frame = "DefenseFrame",           label = "DefenseLabel",           header = "Defense" },
    { frame = "FoodFrame",              label = "FoodLabel",              header = "Food" },
    { frame = "GoldChangeFrame",        label = "GoldChangeLabel",        header = "Gold" },
    { frame = "GoldFrame",              label = "GoldLabel",              header = "Gold" },
    { frame = "ScienceFrame",           label = "ScienceLabel",           header = "Science" },
    { frame = "ProductionFrame",        label = "ProductionLabel",        header = "Production" },
    { frame = "GreatPeopleFrame",       label = "GreatPeopleLabel",       header = "Great People" },
    { frame = "CombatFrame",            label = "CombatLabel",            header = "Combat Strength" },
    { frame = "RangedCombatFrame",      label = "RangedCombatLabel",      header = "Ranged Combat" },
    { frame = "RangedCombatRangeFrame", label = "RangedCombatRangeLabel", header = "Range" },
    { frame = "MovementFrame",          label = "MovementLabel",          header = "Movement" },
    { frame = "CombatTypeFrame",        label = "CombatTypeLabel",        header = "Combat Type" },
    { frame = "YieldFrame",             label = "YieldLabel",             header = "Yield" },
    { frame = "MountainYieldFrame",     label = "MountainYieldLabel",     header = "Mountain Yield" },
    { frame = "MovementCostFrame",      label = "MovementCostLabel",      header = "Movement Cost" },
    { frame = "CombatModFrame",         label = "CombatModLabel",         header = "Combat Modifier" },
    { frame = "LivedFrame",             label = "LivedLabel",             header = "Lived" },
    { frame = "TitlesFrame",            label = "TitlesLabel",            header = "Titles" },
    { frame = "PrereqEraFrame",         label = "PrereqEraLabel",         header = "Prerequisite Era" },
    { frame = "PolicyBranchFrame",      label = "PolicyBranchLabel",      header = "Policy Branch" },
    { frame = "TenetLevelFrame",        label = "TenetLevelLabel",        header = "Tenet Level" },
}

-- Text frames: single-Label frames holding prose. Empty header means the
-- body is spoken on its own (HomePageBlurb has no explicit header).
local TEXT_FRAMES = {
    { frame = "HomePageBlurbFrame", label = "HomePageBlurbLabel", header = "" },
    { frame = "GameInfoFrame",      label = "GameInfoLabel",      header = "Game Info" },
    { frame = "AbilitiesFrame",     label = "AbilitiesLabel",     header = "Special Abilities" },
    { frame = "SummaryFrame",       label = "SummaryLabel",       header = "Summary" },
    { frame = "ExtendedFrame",      label = "ExtendedLabel",      header = "Detailed Description" },
    { frame = "DNotesFrame",        label = "DNotesLabel",        header = "Designer Notes" },
    { frame = "StrategyFrame",      label = "StrategyLabel",      header = "Strategy" },
    { frame = "HistoryFrame",       label = "HistoryLabel",       header = "Historical Info" },
    { frame = "QuoteFrame",         label = "QuoteLabel",         header = "Quote" },
    { frame = "SilentQuoteFrame",   label = "SilentQuoteLabel",   header = "Quote" },
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
    { frame = "PrereqTechFrame",         manager = g_PrereqTechManager,         button = "PrereqTechButton",         category = Civilopedia.CATEGORY.TECH,          header = "Required Technologies" },
    { frame = "LeadsToTechFrame",        manager = g_LeadsToTechManager,        button = "LeadsToTechButton",        category = Civilopedia.CATEGORY.TECH,          header = "Leads To" },
    { frame = "ObsoleteTechFrame",       manager = g_ObsoleteTechManager,       button = "ObsoleteTechButton",       category = Civilopedia.CATEGORY.TECH,          header = "Obsoleted By" },
    { frame = "RevealTechsFrame",        manager = g_RevealTechsManager,        button = "RevealTechButton",         category = Civilopedia.CATEGORY.TECH,          header = "Revealed By" },
    { frame = "UnlockedUnitsFrame",      manager = g_UnlockedUnitsManager,      button = "UnlockedUnitButton",       category = Civilopedia.CATEGORY.UNITS,         header = "Unlocked Units" },
    { frame = "UnlockedBuildingsFrame",  manager = g_UnlockedBuildingsManager,  button = "UnlockedBuildingButton",   category = Civilopedia.CATEGORY.BUILDINGS,     header = "Unlocked Buildings" },
    { frame = "UnlockedProjectsFrame",   manager = g_UnlockedProjectsManager,   button = "UnlockedProjectButton",    category = Civilopedia.CATEGORY.WONDERS,       header = "Unlocked Projects" },
    { frame = "RevealedResourcesFrame",  manager = g_RevealedResourcesManager,  button = "RevealedResourceButton",   category = Civilopedia.CATEGORY.RESOURCES,     header = "Revealed Resources" },
    { frame = "RequiredResourcesFrame",  manager = g_RequiredResourcesManager,  button = "RequiredResourceButton",   category = Civilopedia.CATEGORY.RESOURCES,     header = "Required Resources" },
    { frame = "LocalResourcesFrame",     manager = g_LocalResourcesManager,     button = "LocalResourceButton",      category = Civilopedia.CATEGORY.RESOURCES,     header = "Local Resources" },
    { frame = "WorkerActionsFrame",      manager = g_WorkerActionsManager,      button = "WorkerActionButton",       category = Civilopedia.CATEGORY.IMPROVEMENTS,  header = "Worker Actions" },
    { frame = "FreePromotionsFrame",     manager = g_PromotionsManager,         button = "PromotionButton",          category = Civilopedia.CATEGORY.PROMOTIONS,    header = "Free Promotions" },
    { frame = "RequiredPromotionsFrame", manager = g_RequiredPromotionsManager, button = "RequiredPromotionButton",  category = Civilopedia.CATEGORY.PROMOTIONS,    header = "Required Promotions" },
    { frame = "RequiredBuildingsFrame",  manager = g_RequiredBuildingsManager,  button = "RequiredBuildingButton",   category = Civilopedia.CATEGORY.BUILDINGS,     header = "Required Buildings" },
    { frame = "RequiredPoliciesFrame",   manager = g_RequiredPoliciesManager,   button = "RequiredPolicyButton",     category = Civilopedia.CATEGORY.POLICIES,      header = "Required Policies" },
    { frame = "SpecialistsFrame",        manager = g_SpecialistsManager,        button = "SpecialistButton",         category = Civilopedia.CATEGORY.PEOPLE,        header = "Specialists" },
    { frame = "LeadersFrame",            manager = g_LeadersManager,            button = "LeaderButton",             category = Civilopedia.CATEGORY.CIVILIZATIONS, header = "Leaders" },
    { frame = "CivilizationsFrame",      manager = g_CivilizationsManager,      button = "CivilizationButton",       category = Civilopedia.CATEGORY.CIVILIZATIONS, header = "Civilizations" },
    { frame = "UniqueUnitsFrame",        manager = g_UniqueUnitsManager,        button = "UniqueUnitButton",         category = Civilopedia.CATEGORY.UNITS,         header = "Unique Units" },
    { frame = "UniqueBuildingsFrame",    manager = g_UniqueBuildingsManager,    button = "UniqueBuildingButton",     category = Civilopedia.CATEGORY.BUILDINGS,     header = "Unique Buildings" },
    { frame = "UniqueImprovementsFrame", manager = g_UniqueImprovementsManager, button = "UniqueImprovementButton",  category = Civilopedia.CATEGORY.IMPROVEMENTS,  header = "Unique Improvements" },
    { frame = "UpgradeFrame",            manager = g_UpgradeManager,            button = "UpgradeButton",            category = Civilopedia.CATEGORY.UNITS,         header = "Upgrades To" },
    { frame = "FeaturesFrame",           manager = g_FeaturesManager,           button = "FeatureButton",            category = Civilopedia.CATEGORY.TERRAIN,       header = "Features" },
    { frame = "TerrainsFrame",           manager = g_TerrainsManager,           button = "TerrainButton",            category = Civilopedia.CATEGORY.TERRAIN,       header = "Terrains" },
    { frame = "ImprovementsFrame",       manager = g_ImprovementsManager,       button = "ImprovementButton",        category = Civilopedia.CATEGORY.IMPROVEMENTS,  header = "Improvements" },
    -- Context-dependent target category; resolved at scrape time from the
    -- current article's category.
    { frame = "ReplacesFrame",           manager = g_ReplacesManager,           button = "ReplaceButton",            category = "ctx_replaces",                     header = "Replaces" },
    { frame = "ResourcesFoundFrame",     manager = g_ResourcesFoundManager,     button = "ResourceFoundButton",      category = "ctx_resources_found",              header = "Found On" },
    -- Display-only (no navigation): the relationship has no single link
    -- target that makes sense to navigate to.
    { frame = "TraitsFrame",             manager = g_TraitsManager,             button = "TraitButton",              category = nil,                                header = "Traits" },
    { frame = "GreatWorksFrame",         manager = g_GreatWorksManager,         button = "GreatWorksButton",         category = nil,                                header = "Great Works" },
}

-- Control-access helpers ------------------------------------------------

local function safeGetText(ctrl)
    if ctrl == nil then return "" end
    local ok, result = pcall(function() return ctrl:GetText() end)
    if ok and type(result) == "string" then return result end
    return ""
end

local function safeIsHidden(ctrl)
    if ctrl == nil then return true end
    local ok, result = pcall(function() return ctrl:IsHidden() end)
    if ok then return result end
    return true
end

local function addLeaf(leaves, header, body)
    if body == nil or body == "" then return end
    local text
    if header == nil or header == "" then
        text = body
    else
        text = header .. ": " .. body
    end
    leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = text })
end

-- Resolve a relationship's target category. Most defs have a fixed
-- category; the "ctx_*" sentinels defer to the current article's
-- category (ReplacesFrame → current cat; ResourcesFoundFrame flips
-- between Terrain and Resources).
local function resolveRelationshipCategory(def, currentCat)
    local c = def.category
    if c == nil then return nil end
    if type(c) == "number" then return c end
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
    [Civilopedia.CATEGORY.GAME_CONCEPTS]  = "TXT_KEY_GAME_CONCEPT_SECTION_",
    [Civilopedia.CATEGORY.PROMOTIONS]     = "TXT_KEY_PROMOTIONS_SECTION_",
    [Civilopedia.CATEGORY.WONDERS]        = "TXT_KEY_WONDER_SECTION_",
    [Civilopedia.CATEGORY.PEOPLE]         = "TXT_KEY_PEOPLE_SECTION_",
    [Civilopedia.CATEGORY.CIVILIZATIONS]  = "TXT_KEY_CIVILIZATIONS_SECTION_",
    [Civilopedia.CATEGORY.TERRAIN]        = "TXT_KEY_TERRAIN_SECTION_",
    [Civilopedia.CATEGORY.RESOURCES]      = "TXT_KEY_RESOURCES_SECTION_",
    [Civilopedia.CATEGORY.BELIEFS]        = "TXT_KEY_PEDIA_BELIEFS_CATEGORY_",
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
    if sl == nil then return sections end
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
                    label = Locale.ConvertTextKey(era.Description),
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
        local religionOn = (Game == nil)
            or (not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION))
        if religionOn and sl[0] and #sl[0] > 0 then
            sections[#sections + 1] = {
                key = 0,
                label = Locale.ConvertTextKey("TXT_KEY_PEDIA_RELIGIOUS"),
                articles = sl[0],
            }
            offset = 1
        end
        for era in GameInfo.Eras() do
            local k = era.ID + offset
            if sl[k] and #sl[k] > 0 then
                sections[#sections + 1] = {
                    key = k,
                    label = Locale.ConvertTextKey(era.Description),
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
                    label = Locale.ConvertTextKey(branch.Description),
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
                    label = Locale.ConvertTextKey(trait.Description),
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
                    label = Locale.ConvertTextKey(prefix .. tostring(key)),
                    articles = sl[key],
                }
            end
        end
        return sections
    end

    -- Fallback: iterate numeric keys in ascending order, no label.
    local keys = {}
    for k in pairs(sl) do
        if type(k) == "number" then keys[#keys + 1] = k end
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
    local idStr
    if type(entryID) == "table" then
        idStr = tostring(cat) .. ":" .. tostring(entryID[1]) .. ":" .. tostring(entryID[2])
    else
        idStr = tostring(cat) .. ":" .. tostring(entryID)
    end
    return entryFactory({
        id          = idStr,
        labelText   = tostring(article.entryName or ""),
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
            local fn = CivilopediaCategory
                and CivilopediaCategory[cat]
                and CivilopediaCategory[cat].DisplayHomePage
            if type(fn) == "function" then
                local ok, err = pcall(fn)
                if not ok then
                    Log.warn("Civilopedia Intro DisplayHomePage(" .. tostring(cat)
                        .. ") failed: " .. tostring(err))
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
            cached    = false,
            itemsFn   = function()
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
    return BaseMenuItems.Group({
        textKey = categoryLabelKey(cat),
        cached  = false,
        itemsFn = function()
            return categoryChildren(entryFactory, cat)
        end,
    })
end

local function hasTable(name) return GameInfo[name] ~= nil end

-- Harvesters ------------------------------------------------------------

-- Title is deliberately skipped: the user already heard the article's
-- name when they activated its Entry in the picker; repeating it as the
-- first reader line is redundant. Stats keep their header prefix because
-- bare values ("40", "+2") are meaningless without the label.
local function harvestStats(leaves)
    for _, def in ipairs(STAT_FRAMES) do
        if not safeIsHidden(Controls[def.frame]) then
            addLeaf(leaves, def.header, safeGetText(Controls[def.label]))
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
        if not safeIsHidden(Controls[def.frame]) then
            addLeaf(leaves, "", safeGetText(Controls[def.label]))
        end
    end
end

-- FFTextStack: free-form per-instance {header, body} pairs used for
-- Civilizations (unique ability write-up) and richer profile pages. Each
-- instance has FFTextHeader + FFTextLabel. Skip when stack is hidden:
-- ClearArticle hides the stack but leaves stale allocated instances.
local function harvestFreeFormText(leaves)
    if safeIsHidden(Controls.FFTextStack) then return end
    local mgr = g_FreeFormTextManager
    if mgr == nil or mgr.m_AllocatedInstances == nil then return end
    for _, instance in ipairs(mgr.m_AllocatedInstances) do
        local header = safeGetText(instance.FFTextHeader)
        local body   = safeGetText(instance.FFTextLabel)
        addLeaf(leaves, header, body)
    end
end

-- BBTextStack: full-width intro blurbs used by home pages. Same shape as
-- FFText: per-instance header + body.
local function harvestBBText(leaves)
    if safeIsHidden(Controls.BBTextStack) then return end
    local mgr = g_BBTextManager
    if mgr == nil or mgr.m_AllocatedInstances == nil then return end
    for _, instance in ipairs(mgr.m_AllocatedInstances) do
        local header = safeGetText(instance.BBTextHeader)
        local body   = safeGetText(instance.BBTextLabel)
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
        if not safeIsHidden(Controls[def.frame]) then
            local mgr = def.manager
            if mgr ~= nil and mgr.m_AllocatedInstances ~= nil then
                local targetCat = resolveRelationshipCategory(def, currentCat)
                local seen = {}
                for _, instance in ipairs(mgr.m_AllocatedInstances) do
                    local btn = instance[def.button]
                    if btn ~= nil then
                        local okLabel, label = pcall(function() return btn:GetToolTipString() end)
                        local okVoid,  voidID = pcall(function() return btn:GetVoid1() end)
                        if okLabel and label ~= nil and label ~= "" then
                            local dedup = tostring(voidID) .. "|" .. tostring(label)
                            if not seen[dedup] then
                                seen[dedup] = true
                                local text = def.header .. ": " .. tostring(label)
                                if okVoid and voidID ~= nil and targetCat ~= nil then
                                    local capturedCat, capturedID = targetCat, voidID
                                    leaves[#leaves + 1] = BaseMenuItems.Choice({
                                        labelText = text,
                                        activate  = function()
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

-- Rebuild the reader tab in place after a link is followed. Matches the
-- PickerReader Entry.activate path: SelectArticle -> setItems -> programmatic
-- switchToTab (force=true) so the reader re-announces even though it's
-- already the active tab. Also updates the PickerReader session's stored
-- selection id so Shift+Tab back to the picker lands on the article we
-- followed to, not the one the user originally opened from. The id format
-- mirrors entryFromArticle's non-tuple path ("cat:rowID"); link targets
-- in tuple-entryID categories (WorldCongress) would fall through and the
-- picker restore is a silent no-op, which is the right failure mode.
function followLink(handler, targetCat, targetID)
    if CivilopediaCategory ~= nil
            and CivilopediaCategory[targetCat] ~= nil
            and type(CivilopediaCategory[targetCat].SelectArticle) == "function" then
        pcall(CivilopediaCategory[targetCat].SelectArticle, targetID, 1)
    end
    if type(handler.setPickerReaderSelection) == "function" then
        handler.setPickerReaderSelection(
            tostring(targetCat) .. ":" .. tostring(targetID))
    end
    local leaves = {}
    Civilopedia._harvestInto(leaves, handler, targetCat)
    if #leaves == 0 then
        leaves[1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"),
        })
    end
    handler.setItems(leaves, READER_TAB_IDX)
    handler.switchToTab(READER_TAB_IDX)
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
    items[#items + 1] = introEntry(entryFactory, CAT.HOME_PAGE, {
        textKey = categoryLabelKey(CAT.HOME_PAGE),
    })
    items[#items + 1] = categoryGroup(CAT.GAME_CONCEPTS, entryFactory)
    items[#items + 1] = categoryGroup(CAT.TECH,          entryFactory)
    items[#items + 1] = categoryGroup(CAT.UNITS,         entryFactory)
    items[#items + 1] = categoryGroup(CAT.PROMOTIONS,    entryFactory)
    items[#items + 1] = categoryGroup(CAT.BUILDINGS,     entryFactory)
    items[#items + 1] = categoryGroup(CAT.WONDERS,       entryFactory)
    items[#items + 1] = categoryGroup(CAT.POLICIES,      entryFactory)
    items[#items + 1] = categoryGroup(CAT.PEOPLE,        entryFactory)
    items[#items + 1] = categoryGroup(CAT.CIVILIZATIONS, entryFactory)
    items[#items + 1] = categoryGroup(CAT.CITY_STATES,   entryFactory)
    items[#items + 1] = categoryGroup(CAT.TERRAIN,       entryFactory)
    items[#items + 1] = categoryGroup(CAT.RESOURCES,     entryFactory)
    items[#items + 1] = categoryGroup(CAT.IMPROVEMENTS,  entryFactory)
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
    if CivilopediaCategory ~= nil
            and CivilopediaCategory[category] ~= nil
            and type(CivilopediaCategory[category].SelectArticle) == "function" then
        local ok, err = pcall(CivilopediaCategory[category].SelectArticle, entryID, 1)
        if not ok then
            Log.warn("Civilopedia SelectArticle(" .. tostring(category)
                .. ", " .. tostring(entryID) .. ") failed: " .. tostring(err))
        end
    end

    local leaves = {}
    Civilopedia._harvestInto(leaves, handler, category)
    if #leaves == 0 then
        Log.warn("Civilopedia buildReader: cat=" .. tostring(category)
            .. " entryID=" .. tostring(entryID) .. " no visible controls")
        leaves[1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"),
        })
    end
    return { items = leaves, autoDrillToLevel = 1 }
end

return Civilopedia

-- Civilopedia flat-search corpus tests. Exercises the picker-tab
-- buildSearchable override from CivilopediaCore: walking a synthetic
-- picker tree into a flat list of { label, path, group } entries, then
-- teleporting the handler cursor through the returned searchable's
-- moveTo.
--
-- Uses real BaseMenuItems Group / Entry factories so cached=false Groups
-- behave the same as in the production picker. PickerReader.Entry is
-- simulated via BaseMenuItems.Choice-shaped entries with `kind = "entry"`
-- and an id — buildFlatCorpus only reads labelOf, kind, id, and
-- Group:children.

local T = require("support")
local M = {}

local speaks

local function setup()
    speaks = {}
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        speaks[#speaks + 1] = { text = text, interrupt = interrupt }
    end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    -- CivilopediaCore loads many RELATIONSHIP_DEFS that reference g_*Manager
    -- globals at evaluation time. They stay nil here; the flat search code
    -- never touches them, but the top-level evaluation must not error. The
    -- Civilopedia global gets (re)created by the load.
    dofile("src/dlc/UI/Shared/CivVAccess_CivilopediaCore.lua")

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "no article"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "start"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "end"
end

-- Minimal Entry factory matching the shape Civilopedia.buildFlatCorpus
-- reads from: kind, id, labelText (for labelOf). activate / announce /
-- isNavigable are unused by the flat search.
local function entry(id, labelText)
    return {
        kind = "entry",
        id = id,
        labelText = labelText,
    }
end

-- Picker-shaped tree mirroring the real pedia's layout:
--   index 1: Home Page intro Entry (top-level)
--   index 2: "Technologies" Group containing
--     - Tech intro Entry
--     - "Ancient" section Group containing Pottery, Agriculture
--   index 3: "Units" Group containing
--     - Units intro Entry
--     - "Medieval" section Group containing Camel Archer, Chariot Archer
local function pediaTree()
    return {
        entry("1:intro", "Civilopedia Home Page"),
        BaseMenuItems.Group({
            labelText = "Technologies",
            cached = false,
            itemsFn = function()
                return {
                    entry("3:intro", "Technologies intro"),
                    BaseMenuItems.Group({
                        labelText = "Ancient",
                        items = {
                            entry("3:0", "Pottery"),
                            entry("3:1", "Agriculture"),
                        },
                    }),
                }
            end,
        }),
        BaseMenuItems.Group({
            labelText = "Units",
            cached = false,
            itemsFn = function()
                return {
                    entry("4:intro", "Units intro"),
                    BaseMenuItems.Group({
                        labelText = "Medieval",
                        items = {
                            entry("4:10", "Camel Archer"),
                            entry("4:11", "Chariot Archer"),
                        },
                    }),
                }
            end,
        }),
    }
end

local function fakeHandler(items)
    return {
        _tabIndex = 1,
        _level = 1,
        _indices = { 1 },
        tabs = { { _items = items } },
    }
end

local function findByLabel(searchable, label)
    for i = 1, searchable.itemCount() do
        if searchable.getLabel(i) == label then
            return i
        end
    end
    return nil
end

function M.test_flat_corpus_includes_articles_intros_and_categories()
    setup()
    local items = pediaTree()
    local s = Civilopedia.buildFlatSearchable(fakeHandler(items))
    -- Articles: Pottery, Agriculture, Camel Archer, Chariot Archer
    -- Intros: Home Page (top-level), Technologies intro, Units intro
    -- Categories: Technologies Group, Units Group
    -- Total: 4 + 3 + 2 = 9
    T.eq(s.itemCount(), 9, "flat corpus has every article, intro, and category label")
end

function M.test_flat_corpus_articles_are_group_zero()
    setup()
    local items = pediaTree()
    local s = Civilopedia.buildFlatSearchable(fakeHandler(items))
    local i = findByLabel(s, "Camel Archer")
    T.truthy(i, "Camel Archer present in corpus")
    T.eq(s.groupOf(i), 0, "articles are group 0")
end

function M.test_flat_corpus_categories_are_group_one()
    setup()
    local items = pediaTree()
    local s = Civilopedia.buildFlatSearchable(fakeHandler(items))
    local i = findByLabel(s, "Technologies")
    T.truthy(i, "Technologies category present")
    T.eq(s.groupOf(i), 1, "top-level Groups are group 1")
end

function M.test_flat_corpus_intros_are_group_one()
    setup()
    local items = pediaTree()
    local s = Civilopedia.buildFlatSearchable(fakeHandler(items))
    local i = findByLabel(s, "Technologies intro")
    T.truthy(i, "Technologies intro present")
    T.eq(s.groupOf(i), 1, "intros (:intro id suffix) are group 1")
end

function M.test_flat_corpus_top_level_intro_not_duplicated()
    setup()
    -- Home Page intro lives at top-level index 1 as an Entry. The corpus
    -- adds top-level Groups and top-level Intros as category-tier items,
    -- and also walks the tree for leaf Entries. The id-based seen set in
    -- the walk prevents Home Page from appearing twice.
    local items = pediaTree()
    local s = Civilopedia.buildFlatSearchable(fakeHandler(items))
    local count = 0
    for i = 1, s.itemCount() do
        if s.getLabel(i) == "Civilopedia Home Page" then
            count = count + 1
        end
    end
    T.eq(count, 1, "top-level intro appears exactly once")
end

function M.test_flat_corpus_multiple_top_level_intros_not_dropped()
    setup()
    -- If a future revision adds a second top-level intro, it must still
    -- appear in the corpus (the prior path-depth heuristic would silently
    -- have dropped it as "looks top-level-intro-shaped"; id-based dedup
    -- skips only what was actually added in the category-tier pass).
    local items = {
        entry("1:intro", "Civilopedia Home Page"),
        entry("17:intro", "Future Category Home Page"),
        BaseMenuItems.Group({ labelText = "Units", items = { entry("4:10", "Camel Archer") } }),
    }
    local s = Civilopedia.buildFlatSearchable(fakeHandler(items))
    local firstCount, secondCount = 0, 0
    for i = 1, s.itemCount() do
        local label = s.getLabel(i)
        if label == "Civilopedia Home Page" then
            firstCount = firstCount + 1
        elseif label == "Future Category Home Page" then
            secondCount = secondCount + 1
        end
    end
    T.eq(firstCount, 1, "first top-level intro appears once")
    T.eq(secondCount, 1, "second top-level intro also appears once (not dropped)")
end

function M.test_flat_corpus_moveTo_teleports_to_article_path()
    setup()
    local items = pediaTree()
    local h = fakeHandler(items)
    local s = Civilopedia.buildFlatSearchable(h)
    local i = findByLabel(s, "Camel Archer")
    s.moveTo(i)
    -- Camel Archer lives at pickerItems[3] > "Medieval"[2] > items[1].
    T.eq(h._level, 3, "level set to article depth")
    T.eq(h._indices[1], 3, "top index points at Units Group")
    T.eq(h._indices[2], 2, "mid index points at Medieval section")
    T.eq(h._indices[3], 1, "leaf index points at Camel Archer")
end

function M.test_flat_corpus_moveTo_announces_label()
    setup()
    local items = pediaTree()
    local h = fakeHandler(items)
    local s = Civilopedia.buildFlatSearchable(h)
    local i = findByLabel(s, "Chariot Archer")
    s.moveTo(i)
    local heard = false
    for _, sp in ipairs(speaks) do
        if tostring(sp.text):find("Chariot Archer", 1, true) then
            heard = true
            break
        end
    end
    T.truthy(heard, "moveTo speaks the matched article label")
end

function M.test_flat_corpus_moveTo_teleports_to_top_level_category()
    setup()
    local items = pediaTree()
    local h = fakeHandler(items)
    local s = Civilopedia.buildFlatSearchable(h)
    local i = findByLabel(s, "Units")
    s.moveTo(i)
    T.eq(h._level, 1, "category target lands at level 1")
    T.eq(h._indices[1], 3, "cursor on Units Group")
end

return M

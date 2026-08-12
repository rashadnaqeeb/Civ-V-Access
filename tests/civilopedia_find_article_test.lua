-- Civilopedia.findArticle: resolving the string Events.SearchForPediaEntry
-- carries to an article. Covers the two indexes the base pedia builds
-- (TXT_KEY and lowercased display name) plus the qualifier-stripping
-- fallback that recovers Vox Populi's decorated names, where the displayed
-- (and indexed) name leads with a colored civilization / policy-branch tag
-- that no Ctrl+I caller knows to include.

local T = require("support")
local M = {}

local warns

local function setup()
    warns = {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_CivilopediaCore.lua")
    searchableList = {}
    searchableTextKeyList = {}
end

-- Index one article the way the pedia's PopulateList functions do: under
-- its TXT_KEY, and under the lowercased name it actually displays.
local function addArticle(textKey, displayName, cat, entryID)
    local article = {
        entryName = displayName,
        entryID = entryID,
        entryCategory = cat,
    }
    searchableTextKeyList[textKey] = article
    searchableList[Locale.ToLower(displayName)] = article
    return article
end

function M.test_text_key_resolves_as_rendered()
    setup()
    local warrior = addArticle("TXT_KEY_UNIT_WARRIOR", "Warrior", 4, 1)
    local article, rendered = Civilopedia.findArticle("TXT_KEY_UNIT_WARRIOR")
    T.eq(article, warrior, "TXT_KEY hits the text-key index")
    T.eq(rendered, true, "base's own lookup found it, so it is already drawn")
end

function M.test_plain_name_resolves_as_rendered()
    setup()
    local warrior = addArticle("TXT_KEY_UNIT_WARRIOR", "Warrior", 4, 1)
    local article, rendered = Civilopedia.findArticle("Warrior")
    T.eq(article, warrior, "localized name hits the name index")
    T.eq(rendered, true, "base's own lookup found it, so it is already drawn")
end

function M.test_name_lookup_is_case_insensitive()
    setup()
    local warrior = addArticle("TXT_KEY_UNIT_WARRIOR", "Warrior", 4, 1)
    T.eq(Civilopedia.findArticle("warrior"), warrior, "name index is keyed lowercased")
end

function M.test_qualified_name_resolves_from_plain_name()
    setup()
    local legion = addArticle("TXT_KEY_UNIT_ROMAN_LEGION", "[COLOR_POSITIVE_TEXT](Roman)[ENDCOLOR] Legion", 4, 12)
    local article, rendered = Civilopedia.findArticle("Legion")
    T.eq(article, legion, "civilization qualifier stripped off the indexed name")
    T.eq(rendered, false, "base's lookup missed, so the caller must draw it")
end

function M.test_stacked_qualifiers_are_all_stripped()
    setup()
    -- A policy-granted unique wonder carries a branch tag and a
    -- civilization tag, prepended one after the other.
    local wonder = addArticle(
        "TXT_KEY_BUILDING_X",
        "[COLOR_MAGENTA](Tradition)[ENDCOLOR] [COLOR_POSITIVE_TEXT](Egyptian)[ENDCOLOR] Great Library",
        7,
        30
    )
    T.eq(Civilopedia.findArticle("Great Library"), wonder, "every leading qualifier stripped")
end

function M.test_qualified_lookup_is_case_insensitive()
    setup()
    local legion = addArticle("TXT_KEY_UNIT_ROMAN_LEGION", "[COLOR_POSITIVE_TEXT](Roman)[ENDCOLOR] Legion", 4, 12)
    T.eq(Civilopedia.findArticle("legion"), legion, "stripped name compared lowercased")
end

function M.test_unknown_name_returns_nil()
    setup()
    addArticle("TXT_KEY_UNIT_ROMAN_LEGION", "[COLOR_POSITIVE_TEXT](Roman)[ENDCOLOR] Legion", 4, 12)
    T.eq(Civilopedia.findArticle("Battleship"), nil, "no article for a name nothing carries")
end

function M.test_partial_name_does_not_resolve()
    setup()
    -- The fallback matches whole bare names only: "Archer" must not drag
    -- in "Camel Archer", or Ctrl+I would open a neighbouring article and
    -- the player would have no way to notice.
    addArticle("TXT_KEY_UNIT_CAMEL_ARCHER", "[COLOR_POSITIVE_TEXT](Arabian)[ENDCOLOR] Camel Archer", 4, 20)
    T.eq(Civilopedia.findArticle("Archer"), nil, "qualifier stripping is not substring matching")
end

function M.test_qualifier_inside_a_name_is_not_stripped()
    setup()
    -- Only leading qualifiers are decoration; the pattern is anchored so a
    -- colored run anywhere else leaves the name alone.
    addArticle("TXT_KEY_UNIT_X", "Legion [COLOR_POSITIVE_TEXT](Roman)[ENDCOLOR]", 4, 12)
    T.eq(Civilopedia.findArticle("Legion"), nil, "only a leading qualifier counts as decoration")
end

function M.test_colliding_bare_names_pick_earlier_category_and_warn()
    setup()
    local unit = addArticle("TXT_KEY_UNIT_TWIN", "[COLOR_POSITIVE_TEXT](Roman)[ENDCOLOR] Twin", 4, 5)
    addArticle("TXT_KEY_BUILDING_TWIN", "[COLOR_POSITIVE_TEXT](Greek)[ENDCOLOR] Twin", 7, 9)
    T.eq(Civilopedia.findArticle("Twin"), unit, "collision resolves toward the earlier category")
    local warned = false
    for _, msg in ipairs(warns) do
        if tostring(msg):find("qualified articles", 1, true) then
            warned = true
        end
    end
    T.truthy(warned, "an ambiguous bare name is logged")
end

return M

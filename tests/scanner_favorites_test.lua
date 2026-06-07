-- ScannerFavorites model: the persistent custom-category selectors and
-- their flattening into customCategoryDefs. Covers the All-supersede
-- expand logic, delete renumbering, and the Prefs round-trip. The snapshot
-- half (how defs become categories) lives in scanner_custom_category_test.lua.

local T = require("support")
local M = {}

local prefsStore

local function setup()
    civvaccess_shared = {}
    prefsStore = {}
    Prefs = Prefs or {}
    Prefs.getBool = function(key, default)
        local v = prefsStore[key]
        if v == nil then
            return default
        end
        return v
    end
    Prefs.setBool = function(key, v)
        prefsStore[key] = v
    end
    Prefs.getInt = function(key, default)
        local v = prefsStore[key]
        if v == nil then
            return default
        end
        return v
    end
    Prefs.setInt = function(key, v)
        prefsStore[key] = v
    end
    Prefs.getString = function(key, default)
        local v = prefsStore[key]
        if v == nil then
            return default
        end
        return v
    end
    Prefs.setString = function(key, v)
        prefsStore[key] = v
    end
    -- addKeyword/rename trim via the real Text.trim; load the real module so
    -- that path isn't simulated, then override Text.format with an echo of
    -- key + position, which is enough to assert default-name numbering without
    -- a full Locale/Strings stack.
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    Text.format = function(key, pos)
        return key .. ":" .. tostring(pos)
    end

    ScannerCore = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerCore.lua")
    ScannerFavorites = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerFavorites.lua")

    Log.warn = function() end
    Log.error = function() end
end

function M.test_add_assigns_sequential_ids_and_persists()
    setup()
    local id1 = ScannerFavorites.add()
    local id2 = ScannerFavorites.add()
    T.eq(id1, 1, "first id is 1")
    T.eq(id2, 2, "ids increment")
    T.eq(prefsStore["ScnCustNextId"], 3, "nextId persists past the last assigned")
    T.eq(prefsStore["ScnCustActive:1"], true, "group 1 marked active")
    T.eq(prefsStore["ScnCustActive:2"], true, "group 2 marked active")
    T.eq(
        prefsStore["ScnCustName:1"],
        "TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL:1",
        "default name persists at creation position"
    )
    T.eq(prefsStore["ScnCustName:2"], "TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL:2")
end

function M.test_set_all_supersedes_named_subs()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.setAll(id, "units_my", true)
    T.truthy(ScannerFavorites.isAll(id, "units_my"), "All reads on")
    T.truthy(ScannerFavorites.isSub(id, "units_my", "melee"), "a named sub reads checked while All is on")
    T.eq(prefsStore["ScnCustSel:1:units_my:all"], true, "the all bit persists")
end

function M.test_unchecking_a_sub_while_all_on_expands_to_named_set()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.setAll(id, "units_my", true)
    ScannerFavorites.setSub(id, "units_my", "melee", false)
    T.falsy(ScannerFavorites.isAll(id, "units_my"), "All drops once a sub is unchecked")
    T.falsy(ScannerFavorites.isSub(id, "units_my", "melee"), "the unchecked sub is off")
    T.truthy(ScannerFavorites.isSub(id, "units_my", "ranged"), "the rest stay on")
    T.eq(prefsStore["ScnCustSel:1:units_my:all"], false, "the all bit is cleared on expand")
end

function M.test_clearing_last_named_sub_drops_the_category()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.setSub(id, "cities", "my", true)
    ScannerFavorites.setSub(id, "cities", "my", false)
    T.falsy(ScannerFavorites.isSub(id, "cities", "my"), "sub is off")
    T.falsy(ScannerFavorites.isAll(id, "cities"), "category carries nothing")
    -- An emptied category must contribute no selectors.
    local defs = ScannerFavorites.customCategoryDefs()
    T.eq(#defs[1].selectors, 0, "no selectors remain")
end

function M.test_delete_keeps_survivor_name_and_selectors()
    setup()
    local id1 = ScannerFavorites.add()
    local id2 = ScannerFavorites.add()
    ScannerFavorites.setSub(id2, "cities", "my", true)
    ScannerFavorites.delete(id1)
    local defs = ScannerFavorites.customCategoryDefs()
    T.eq(#defs, 1, "one group remains after delete")
    -- Names are stable, not positional: the survivor keeps its creation-time
    -- name rather than renumbering into the gap.
    T.eq(defs[1].labelText, "TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL:2", "survivor keeps its own name")
    T.eq(defs[1].selectors[1].cat, "cities", "survivor keeps its selector")
    T.eq(defs[1].selectors[1].sub, "my")
    T.eq(prefsStore["ScnCustActive:1"], false, "deleted group marked inactive in Prefs")
    T.eq(prefsStore["ScnCustName:1"], "", "deleted group's name row cleared")
end

function M.test_rename_persists_and_resorts_alphabetically()
    setup()
    local id1 = ScannerFavorites.add()
    local id2 = ScannerFavorites.add()
    ScannerFavorites.rename(id1, "Zulu raids")
    ScannerFavorites.rename(id2, "aztec sites")
    local defs = ScannerFavorites.customCategoryDefs()
    -- Case-insensitive sort: "aztec" precedes "Zulu".
    T.eq(defs[1].labelText, "aztec sites", "lowercase name still sorts ahead of a capitalized one")
    T.eq(defs[2].labelText, "Zulu raids")
    T.eq(prefsStore["ScnCustName:1"], "Zulu raids", "rename persists to Prefs")
    T.eq(prefsStore["ScnCustName:2"], "aztec sites")
end

function M.test_rename_rejects_empty()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.rename(id, "")
    local defs = ScannerFavorites.customCategoryDefs()
    T.eq(defs[1].labelText, "TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL:1", "empty rename keeps the default name")
end

function M.test_rename_rejects_whitespace_only()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.rename(id, "   ")
    local defs = ScannerFavorites.customCategoryDefs()
    -- A whitespace-only name would read as silence; the trim-then-blank guard
    -- must drop it and keep the default.
    T.eq(defs[1].labelText, "TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL:1", "whitespace-only rename is rejected")
end

function M.test_rename_trims_surrounding_whitespace()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.rename(id, "  Hunters  ")
    local defs = ScannerFavorites.customCategoryDefs()
    T.eq(defs[1].labelText, "Hunters", "leading/trailing whitespace is trimmed")
    T.eq(prefsStore["ScnCustName:1"], "Hunters", "the trimmed form persists")
end

function M.test_custom_defs_flatten_all_and_named_selectors()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.setAll(id, "units_my", true)
    ScannerFavorites.setSub(id, "cities", "my", true)
    ScannerFavorites.setSub(id, "cities", "enemy", true)
    local defs = ScannerFavorites.customCategoryDefs()
    local sels = defs[1].selectors
    -- Taxonomy order puts cities before units_my, and named subs emit in
    -- their declared order.
    T.eq(sels[1].cat, "cities")
    T.eq(sels[1].sub, "my")
    T.eq(sels[2].cat, "cities")
    T.eq(sels[2].sub, "enemy")
    T.eq(sels[3].cat, "units_my")
    T.eq(sels[3].sub, "all", "whole-category pick flattens to a single all-selector")
end

function M.test_add_keyword_persists_and_appears_in_defs()
    setup()
    local id = ScannerFavorites.add()
    T.truthy(ScannerFavorites.addKeyword(id, "warrior"), "a fresh keyword is added")
    T.eq(prefsStore["ScnCustKwCount:1"], 1, "keyword count persists")
    T.eq(prefsStore["ScnCustKw:1:1"], "warrior", "keyword text persists at its slot")
    local defs = ScannerFavorites.customCategoryDefs()
    T.eq(defs[1].keywords[1], "warrior", "customCategoryDefs carries the keyword")
end

function M.test_add_keyword_trims_and_rejects_blank()
    setup()
    local id = ScannerFavorites.add()
    T.truthy(ScannerFavorites.addKeyword(id, "  iron  "), "surrounding whitespace is trimmed, not rejected")
    T.eq(ScannerFavorites.getKeywords(id)[1], "iron", "stored trimmed")
    local ok, reason = ScannerFavorites.addKeyword(id, "   ")
    T.falsy(ok, "a whitespace-only keyword is rejected")
    T.eq(reason, "blank", "blank rejection is distinguishable from a duplicate")
    T.eq(#ScannerFavorites.getKeywords(id), 1, "the blank did not add a slot")
end

function M.test_add_keyword_rejects_case_insensitive_duplicate()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.addKeyword(id, "Iron")
    local ok, reason = ScannerFavorites.addKeyword(id, "iron")
    T.falsy(ok, "a case-variant duplicate is rejected")
    T.eq(reason, "duplicate", "and reports the duplicate reason for the spoken cue")
    T.eq(#ScannerFavorites.getKeywords(id), 1, "only the first spelling is kept")
end

function M.test_remove_keyword_compacts_and_clears_trailing_slot()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.addKeyword(id, "warrior")
    ScannerFavorites.addKeyword(id, "iron")
    T.truthy(ScannerFavorites.removeKeyword(id, "WARRIOR"), "removal matches case-insensitively")
    local kws = ScannerFavorites.getKeywords(id)
    T.eq(#kws, 1, "one keyword remains")
    T.eq(kws[1], "iron", "the list compacts onto the survivor")
    T.eq(prefsStore["ScnCustKwCount:1"], 1, "persisted count drops")
    T.eq(prefsStore["ScnCustKw:1:1"], "iron", "slot 1 now holds the survivor")
    T.eq(prefsStore["ScnCustKw:1:2"], "", "the vacated trailing slot is cleared")
end

function M.test_remove_keyword_reports_miss()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.addKeyword(id, "iron")
    T.falsy(ScannerFavorites.removeKeyword(id, "gold"), "removing an absent keyword reports no change")
end

function M.test_delete_clears_keyword_prefs()
    setup()
    local id = ScannerFavorites.add()
    ScannerFavorites.addKeyword(id, "warrior")
    ScannerFavorites.delete(id)
    T.eq(prefsStore["ScnCustKwCount:1"], 0, "keyword count zeroed on delete")
    T.eq(prefsStore["ScnCustKw:1:1"], "", "keyword slot cleared on delete")
end

function M.test_hydrate_restores_keywords()
    setup()
    prefsStore["ScnCustNextId"] = 2
    prefsStore["ScnCustActive:1"] = true
    prefsStore["ScnCustKwCount:1"] = 2
    prefsStore["ScnCustKw:1:1"] = "warrior"
    prefsStore["ScnCustKw:1:2"] = "iron"
    civvaccess_shared.scannerCustom = nil
    local kws = ScannerFavorites.getKeywords(1)
    T.eq(#kws, 2, "both saved keywords restored")
    T.eq(kws[1], "warrior")
    T.eq(kws[2], "iron")
end

function M.test_hydrate_reconstructs_from_prefs()
    setup()
    -- Pre-seed the store as if a prior session saved one group with a
    -- single named selector, then hydrate via the first API touch.
    prefsStore["ScnCustNextId"] = 2
    prefsStore["ScnCustActive:1"] = true
    prefsStore["ScnCustSel:1:cities:my"] = true
    civvaccess_shared.scannerCustom = nil
    local defs = ScannerFavorites.customCategoryDefs()
    T.eq(#defs, 1, "the saved group is restored")
    T.truthy(ScannerFavorites.isSub(1, "cities", "my"), "its selector is restored")
    T.falsy(ScannerFavorites.isAll(1, "cities"), "a named selector did not become an all-selector")
end

return M

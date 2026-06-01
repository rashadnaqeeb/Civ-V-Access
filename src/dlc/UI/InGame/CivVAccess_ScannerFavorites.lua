-- User-defined custom scanner categories ("Custom 1", "Custom 2", ...).
-- Each custom category clusters a handful of the taxonomy's category /
-- subcategory filters so a player who reaches for the same few scopes
-- every turn cycles to them in one place instead of hunting the full
-- 13-category list. Custom categories sort to the front of the category
-- cycle (Ctrl+PageUp/Down); an empty one is skipped by the same
-- categoryHasItems filter that hides any empty category.
--
-- Three layers live here:
--   1. The persistent model. A group is { id, sel } where sel maps a
--      taxonomy category key to either { all = true } (the whole category
--      as one scanner stop, including entries that match no named sub) or
--      { all = false, subs = { <subKey> = true, ... } } (specific named
--      subs as separate stops). `id` is stable across the session and
--      across deletes; the spoken "Custom N" label is the group's current
--      1-based POSITION, so deleting Custom 2 renumbers the rest with no
--      gap while leaving every surviving group's stored selectors intact.
--   2. customCategoryDefs(): the model flattened into the shape
--      ScannerSnap.build consumes to synthesize the custom categories.
--   3. The settings UI: settingsGroup() is the drillable spliced under the
--      F12 Scanner group, and openEditor(id) is the per-category editor it
--      pushes -- a checkbox per subcategory under a drillable per category,
--      with a Delete button at the bottom.
--
-- Persistence rides Prefs (Modding.OpenUserData), so picks survive across
-- sessions and games and never touch the savefile or the MP mod-hash.
-- The working copy lives on civvaccess_shared so it outlives the
-- load-from-game env wipe; hydrate() seeds it from Prefs exactly once.
-- Selectors are user configuration, not game state, so caching them is
-- correct -- the never-cache rule is about live game data, which the
-- snapshot still re-queries through the backends on every rebuild.

ScannerFavorites = {}

-- ===== Persistence keys =====
-- Stable id counter; the next id add() will hand out. ids are never
-- reused, so a stored selector can't bleed from a deleted group into a
-- later one that happens to take its position.
local PREF_NEXT_ID = "ScnCustNextId"

local function activeKey(id)
    return "ScnCustActive:" .. id
end

local function selKey(id, catKey, subKey)
    return "ScnCustSel:" .. id .. ":" .. catKey .. ":" .. subKey
end

-- ===== Model hydration =====
-- Populate civvaccess_shared.scannerCustom from Prefs on first touch.
-- Idempotent: a non-nil shared table (already hydrated this session, or
-- carried across a load-from-game) short-circuits. Reads the taxonomy to
-- know which selector keys to probe, so it must run with ScannerCore
-- loaded -- always true in-game, the only place the scanner exists.
local function hydrate()
    if civvaccess_shared.scannerCustom ~= nil then
        return
    end
    local nextId = Prefs.getInt(PREF_NEXT_ID, 1)
    local groups = {}
    for id = 1, nextId - 1 do
        if Prefs.getBool(activeKey(id), false) then
            local sel = {}
            for _, catDef in ipairs(ScannerCore.CATEGORIES) do
                if Prefs.getBool(selKey(id, catDef.key, "all"), false) then
                    sel[catDef.key] = { all = true, subs = {} }
                else
                    local subs = {}
                    for _, subDef in ipairs(catDef.subcategories) do
                        if Prefs.getBool(selKey(id, catDef.key, subDef.key), false) then
                            subs[subDef.key] = true
                        end
                    end
                    if next(subs) ~= nil then
                        sel[catDef.key] = { all = false, subs = subs }
                    end
                end
            end
            groups[#groups + 1] = { id = id, sel = sel }
        end
    end
    civvaccess_shared.scannerCustom = { nextId = nextId, groups = groups }
end

-- Locate a group and its current 1-based position by stable id.
local function findGroup(id)
    for pos, group in ipairs(civvaccess_shared.scannerCustom.groups) do
        if group.id == id then
            return group, pos
        end
    end
    return nil, nil
end

-- ===== Model mutation =====

function ScannerFavorites.add()
    hydrate()
    local state = civvaccess_shared.scannerCustom
    local id = state.nextId
    state.nextId = id + 1
    state.groups[#state.groups + 1] = { id = id, sel = {} }
    Prefs.setInt(PREF_NEXT_ID, state.nextId)
    Prefs.setBool(activeKey(id), true)
    return id
end

function ScannerFavorites.delete(id)
    hydrate()
    local state = civvaccess_shared.scannerCustom
    local removed = nil
    for i, group in ipairs(state.groups) do
        if group.id == id then
            removed = table.remove(state.groups, i)
            break
        end
    end
    if removed == nil then
        Log.warn("ScannerFavorites.delete: unknown id " .. tostring(id))
        return
    end
    Prefs.setBool(activeKey(id), false)
    -- Zero every selector row so a future id can never inherit a stale
    -- bool (ids don't reuse, but a wiped row keeps the user-data file from
    -- accumulating dead keys that a reader might misread).
    for _, catDef in ipairs(ScannerCore.CATEGORIES) do
        Prefs.setBool(selKey(id, catDef.key, "all"), false)
        for _, subDef in ipairs(catDef.subcategories) do
            Prefs.setBool(selKey(id, catDef.key, subDef.key), false)
        end
    end
end

-- ===== Selector queries =====

function ScannerFavorites.isAll(id, catKey)
    hydrate()
    local group = findGroup(id)
    if group == nil then
        return false
    end
    local catSel = group.sel[catKey]
    return catSel ~= nil and catSel.all == true
end

-- A named-sub checkbox reads checked when its own bit is set OR when the
-- category's All selector is on: All visually checks every sub while it
-- supersedes them. Toggling a sub off while All is on (setSub) expands
-- All into the explicit set first, so the visual stays truthful.
function ScannerFavorites.isSub(id, catKey, subKey)
    hydrate()
    local group = findGroup(id)
    if group == nil then
        return false
    end
    local catSel = group.sel[catKey]
    if catSel == nil then
        return false
    end
    if catSel.all then
        return true
    end
    return catSel.subs[subKey] == true
end

-- ===== Selector mutation =====

function ScannerFavorites.setAll(id, catKey, on)
    hydrate()
    local group = findGroup(id)
    if group == nil then
        Log.warn("ScannerFavorites.setAll: unknown id " .. tostring(id))
        return
    end
    local catDef = ScannerCore.CATEGORIES_BY_KEY[catKey]
    if on then
        group.sel[catKey] = { all = true, subs = {} }
        Prefs.setBool(selKey(id, catKey, "all"), true)
        -- Drop any named bits so the stored row matches the supersede
        -- semantics: All on means the whole category, not a named set.
        for _, subDef in ipairs(catDef.subcategories) do
            Prefs.setBool(selKey(id, catKey, subDef.key), false)
        end
    else
        group.sel[catKey] = nil
        Prefs.setBool(selKey(id, catKey, "all"), false)
    end
end

function ScannerFavorites.setSub(id, catKey, subKey, on)
    hydrate()
    local group = findGroup(id)
    if group == nil then
        Log.warn("ScannerFavorites.setSub: unknown id " .. tostring(id))
        return
    end
    local catDef = ScannerCore.CATEGORIES_BY_KEY[catKey]
    local catSel = group.sel[catKey]

    -- Toggling a sub while All is on converts the whole-category selector
    -- into the explicit named set (every sub on), then applies this one
    -- toggle. The user has dropped from "the whole category" to "these
    -- named subs", which is the honest result of unchecking one box.
    if catSel ~= nil and catSel.all then
        -- Every sub was implicitly on under All; the toggled one takes the
        -- new value and the rest stay on. One pass flushes each named bit and
        -- accumulates the surviving set.
        local subs = {}
        Prefs.setBool(selKey(id, catKey, "all"), false)
        for _, subDef in ipairs(catDef.subcategories) do
            local v
            if subDef.key == subKey then
                v = on == true
            else
                v = true
            end
            if v then
                subs[subDef.key] = true
            end
            Prefs.setBool(selKey(id, catKey, subDef.key), v)
        end
        if next(subs) == nil then
            group.sel[catKey] = nil
        else
            group.sel[catKey] = { all = false, subs = subs }
        end
        return
    end

    if catSel == nil then
        catSel = { all = false, subs = {} }
        group.sel[catKey] = catSel
    end
    if on then
        catSel.subs[subKey] = true
    else
        catSel.subs[subKey] = nil
    end
    Prefs.setBool(selKey(id, catKey, subKey), on == true)
    if next(catSel.subs) == nil then
        group.sel[catKey] = nil
    end
end

-- ===== Snapshot feed =====
-- Flatten the model into the def shape ScannerSnap.build consumes. One
-- def per group in display order; selectors in taxonomy order so the
-- subcategory cycle inside a custom category reads in the same order as
-- the source categories. labelText is pre-resolved ("Custom 3") because
-- the number is positional and has no TXT_KEY; ScannerSnap stamps it onto
-- the category and Nav speaks labelText in preference to a label key.
-- Empty groups still emit a def (so the snapshot's numbering matches the
-- settings list), but the snapshot drops any category with no items, so
-- an empty custom category never surfaces in the cycle.
function ScannerFavorites.customCategoryDefs()
    hydrate()
    local defs = {}
    for pos, group in ipairs(civvaccess_shared.scannerCustom.groups) do
        local selectors = {}
        for _, catDef in ipairs(ScannerCore.CATEGORIES) do
            local catSel = group.sel[catDef.key]
            if catSel ~= nil then
                if catSel.all then
                    selectors[#selectors + 1] = { cat = catDef.key, sub = "all", label = catDef.label }
                else
                    for _, subDef in ipairs(catDef.subcategories) do
                        if catSel.subs[subDef.key] then
                            selectors[#selectors + 1] = { cat = catDef.key, sub = subDef.key, label = subDef.label }
                        end
                    end
                end
            end
        end
        defs[#defs + 1] = {
            key = "custom:" .. group.id,
            labelText = Text.format("TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL", pos),
            selectors = selectors,
        }
    end
    return defs
end

-- ===== Settings UI =====
-- Drillable spliced under the F12 Scanner group. cached = false so add /
-- delete reflect on the next drill-in without rebuilding the whole
-- Settings menu: itemsFn re-reads the model each time the user enters.
function ScannerFavorites.settingsGroup()
    return BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_GROUP",
        cached = false,
        itemsFn = function()
            hydrate()
            local items = {
                BaseMenuItems.Text({
                    textKey = "TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_ADD",
                    onActivate = function()
                        local id = ScannerFavorites.add()
                        ScannerFavorites.openEditor(id)
                    end,
                }),
            }
            for pos, group in ipairs(civvaccess_shared.scannerCustom.groups) do
                local id = group.id
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.format("TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL", pos),
                    onActivate = function()
                        ScannerFavorites.openEditor(id)
                    end,
                })
            end
            return items
        end,
    })
end

-- One drillable per taxonomy category, each holding an All checkbox plus a
-- checkbox per named subcategory. Categories with no named subs surface
-- only the All box -- their whole-category selector is the single
-- meaningful pick. cached = false so reopening the editor reflects the
-- live model.
local function buildEditorItems(id)
    local items = {}
    for _, catDef in ipairs(ScannerCore.CATEGORIES) do
        local catKey = catDef.key
        items[#items + 1] = BaseMenuItems.Group({
            textKey = catDef.label,
            cached = false,
            itemsFn = function()
                local toggles = {
                    BaseMenuItems.VirtualToggle({
                        textKey = "TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL",
                        getValue = function()
                            return ScannerFavorites.isAll(id, catKey)
                        end,
                        setValue = function(v)
                            ScannerFavorites.setAll(id, catKey, v)
                        end,
                    }),
                }
                for _, subDef in ipairs(catDef.subcategories) do
                    local subKey = subDef.key
                    toggles[#toggles + 1] = BaseMenuItems.VirtualToggle({
                        textKey = subDef.label,
                        getValue = function()
                            return ScannerFavorites.isSub(id, catKey, subKey)
                        end,
                        setValue = function(v)
                            ScannerFavorites.setSub(id, catKey, subKey, v)
                        end,
                    })
                end
                return toggles
            end,
        })
    end
    items[#items + 1] = BaseMenuItems.Text({
        textKey = "TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_DELETE",
        onActivate = function()
            ScannerFavorites.delete(id)
            HandlerStack.removeByName("ScannerCustomEditor", true)
        end,
    })
    return items
end

function ScannerFavorites.openEditor(id)
    hydrate()
    local _, pos = findGroup(id)
    if pos == nil then
        Log.warn("ScannerFavorites.openEditor: unknown id " .. tostring(id))
        return
    end
    local handler = BaseMenu.create({
        name = "ScannerCustomEditor",
        displayName = Text.format("TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL", pos),
        items = buildEditorItems(id),
        capturesAllInput = true,
        escapePops = true,
    })
    HandlerStack.push(handler)
end

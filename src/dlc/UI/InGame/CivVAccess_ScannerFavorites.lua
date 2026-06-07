-- User-defined custom scanner categories. Each one clusters a handful of
-- the taxonomy's category / subcategory filters so a player who reaches for
-- the same few scopes every turn cycles to them in one place instead of
-- hunting the full 13-category list. Custom categories sort to the front of
-- the category cycle (Ctrl+PageUp/Down); an empty one is skipped by the same
-- categoryHasItems filter that hides any empty category.
--
-- Three layers live here:
--   1. The persistent model. A group is { id, name, sel, keywords } where
--      sel maps a taxonomy category key to either { all = true } (the whole
--      category as one scanner stop, including entries that match no named
--      sub) or { all = false, subs = { <subKey> = true, ... } } (specific
--      named subs as separate stops), and keywords is a list of free-text
--      strings, each of which becomes its own subcategory matching every
--      entry whose spoken name matches the keyword (TypeAheadSearch tiers,
--      same engine as Ctrl+F search). `id` is stable across the session and
--      across deletes. `name` is the user-facing label, spoken in the cycle
--      and the
--      settings list; it defaults to "Custom N" (N = the position at
--      creation) and is editable via the per-category rename field. Groups
--      are kept sorted by name (case-insensitively, id as tiebreak), so the
--      cycle and the settings list read in the same alphabetical order; the
--      stable id, not the position, anchors identity, so a resort never
--      strands the navigator (ScannerNav re-finds by the "custom:<id>" key).
--   2. customCategoryDefs(): the model flattened into the shape
--      ScannerSnap.build consumes to synthesize the custom categories.
--   3. The settings UI: settingsGroup() is the drillable spliced under the
--      F12 Scanner group, and openEditor(id) is the per-category editor it
--      pushes -- a rename field, a checkbox per subcategory under a drillable
--      per category, and a Delete button at the bottom.
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

local function nameKey(id)
    return "ScnCustName:" .. id
end

local function selKey(id, catKey, subKey)
    return "ScnCustSel:" .. id .. ":" .. catKey .. ":" .. subKey
end

-- Keyword list persistence: a count plus one indexed slot per keyword.
-- removeKeyword compacts the list, so persistKeywords rewrites every slot
-- and the count rather than poking a single key.
local function kwCountKey(id)
    return "ScnCustKwCount:" .. id
end

local function kwKey(id, n)
    return "ScnCustKw:" .. id .. ":" .. n
end

-- Default name for a group at the given 1-based position. Resolved through
-- Text.format so it localizes, and persisted at creation so it stays stable
-- across sessions rather than drifting with load order.
local function defaultName(pos)
    return Text.format("TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL", pos)
end

-- Keep the group list sorted by name (case-insensitive), id as tiebreak so
-- the order is deterministic when two share a name. Both the scanner cycle
-- and the settings list iterate this array, so sorting once on mutation
-- keeps them consistent without a per-read sort.
local function sortGroups()
    table.sort(civvaccess_shared.scannerCustom.groups, function(a, b)
        local an, bn = string.lower(a.name), string.lower(b.name)
        if an == bn then
            return a.id < b.id
        end
        return an < bn
    end)
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
            -- Name falls back to the creation-order default when a saved row
            -- predates the rename feature (no stored name yet).
            local name = Prefs.getString(nameKey(id), defaultName(#groups + 1))
            local keywords = {}
            local kwCount = Prefs.getInt(kwCountKey(id), 0)
            for n = 1, kwCount do
                local kw = Prefs.getString(kwKey(id, n), "")
                if kw ~= "" then
                    keywords[#keywords + 1] = kw
                end
            end
            groups[#groups + 1] = { id = id, name = name, sel = sel, keywords = keywords }
        end
    end
    civvaccess_shared.scannerCustom = { nextId = nextId, groups = groups }
    sortGroups()
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
    local name = defaultName(#state.groups + 1)
    state.groups[#state.groups + 1] = { id = id, name = name, sel = {}, keywords = {} }
    Prefs.setInt(PREF_NEXT_ID, state.nextId)
    Prefs.setBool(activeKey(id), true)
    Prefs.setString(nameKey(id), name)
    sortGroups()
    return id
end

-- Rename a group. Trims, then rejects a blank result: a whitespace-only name
-- would persist as something the screen reader speaks as silence with no cue
-- anything went wrong. A real rename persists and re-sorts so the new name
-- takes its alphabetical place immediately.
function ScannerFavorites.rename(id, name)
    hydrate()
    local trimmed = Text.trim(name)
    if trimmed == "" then
        return
    end
    local group = findGroup(id)
    if group == nil then
        Log.warn("ScannerFavorites.rename: unknown id " .. tostring(id))
        return
    end
    group.name = trimmed
    Prefs.setString(nameKey(id), trimmed)
    sortGroups()
    -- BaseMenu captures displayName by value at open, so the live editor's
    -- spoken title is the pre-rename name until close. Refresh it so an F1
    -- re-read speaks the new name. Guarded for the offline test harness,
    -- which drives rename without a HandlerStack.
    if HandlerStack ~= nil then
        for i = HandlerStack.count(), 1, -1 do
            local h = HandlerStack.at(i)
            if h.name == "ScannerCustomEditor" then
                h.displayName = trimmed
                break
            end
        end
    end
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
    Prefs.setString(nameKey(id), "")
    -- Zero every selector row so a future id can never inherit a stale
    -- bool (ids don't reuse, but a wiped row keeps the user-data file from
    -- accumulating dead keys that a reader might misread).
    for _, catDef in ipairs(ScannerCore.CATEGORIES) do
        Prefs.setBool(selKey(id, catDef.key, "all"), false)
        for _, subDef in ipairs(catDef.subcategories) do
            Prefs.setBool(selKey(id, catDef.key, subDef.key), false)
        end
    end
    -- Same hygiene for the keyword slots.
    local kwCount = Prefs.getInt(kwCountKey(id), 0)
    for n = 1, kwCount do
        Prefs.setString(kwKey(id, n), "")
    end
    Prefs.setInt(kwCountKey(id), 0)
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

-- ===== Keyword mutation =====
-- Rewrite the persisted keyword list from the live model: every indexed slot
-- plus the count. Called after any add/remove so a compacted list never
-- leaves a stale trailing slot for the next hydrate to read back.
local function persistKeywords(id, keywords)
    for n, kw in ipairs(keywords) do
        Prefs.setString(kwKey(id, n), kw)
    end
    Prefs.setInt(kwCountKey(id), #keywords)
end

-- Add a keyword. Trims, rejects a blank (a whitespace-only keyword matches
-- nothing and would read as a silent empty stop), and rejects a
-- case-insensitive duplicate so the same scope can't surface twice in the
-- cycle. Returns true on a real add; otherwise false plus a reason
-- ("duplicate" or "blank") so the caller can voice the duplicate case rather
-- than silently swallowing the keypress.
function ScannerFavorites.addKeyword(id, text)
    hydrate()
    local trimmed = Text.trim(text)
    if trimmed == "" then
        return false, "blank"
    end
    local group = findGroup(id)
    if group == nil then
        Log.warn("ScannerFavorites.addKeyword: unknown id " .. tostring(id))
        return false, "blank"
    end
    local lower = string.lower(trimmed)
    for _, kw in ipairs(group.keywords) do
        if string.lower(kw) == lower then
            return false, "duplicate"
        end
    end
    group.keywords[#group.keywords + 1] = trimmed
    persistKeywords(id, group.keywords)
    return true
end

-- Remove a keyword by case-insensitive match. Returns true when one went.
function ScannerFavorites.removeKeyword(id, text)
    hydrate()
    local group = findGroup(id)
    if group == nil then
        Log.warn("ScannerFavorites.removeKeyword: unknown id " .. tostring(id))
        return false
    end
    local lower = string.lower(text or "")
    for i, kw in ipairs(group.keywords) do
        if string.lower(kw) == lower then
            table.remove(group.keywords, i)
            -- Clear the now-vacant trailing slot before rewriting the rest,
            -- so the file never carries a dead key past the new count.
            Prefs.setString(kwKey(id, #group.keywords + 1), "")
            persistKeywords(id, group.keywords)
            return true
        end
    end
    return false
end

function ScannerFavorites.getKeywords(id)
    hydrate()
    local group = findGroup(id)
    if group == nil then
        return {}
    end
    return group.keywords
end

-- ===== Snapshot feed =====
-- Flatten the model into the def shape ScannerSnap.build consumes. One
-- def per group in name-sorted order; selectors in taxonomy order so the
-- subcategory cycle inside a custom category reads in the same order as
-- the source categories, followed by the group's keywords (insertion
-- order) which ScannerSnap turns into name-matched subcategories.
-- labelText carries the group's user-facing name
-- (free text, no TXT_KEY); ScannerSnap stamps it onto the category and Nav
-- speaks labelText in preference to a label key. Empty groups still emit a
-- def (so the snapshot's set matches the settings list), but the snapshot
-- drops any category with no items, so an empty custom category never
-- surfaces in the cycle.
function ScannerFavorites.customCategoryDefs()
    hydrate()
    local defs = {}
    for _, group in ipairs(civvaccess_shared.scannerCustom.groups) do
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
            labelText = group.name,
            selectors = selectors,
            keywords = group.keywords,
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
            for _, group in ipairs(civvaccess_shared.scannerCustom.groups) do
                local id = group.id
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = group.name,
                    onActivate = function()
                        ScannerFavorites.openEditor(id)
                    end,
                })
            end
            return items
        end,
    })
end

-- The keyword editor, spliced under the F12 custom-category editor: an entry
-- field that adds a keyword on Enter, then one activatable row per existing
-- keyword that removes it. cached = false so the row list re-reads
-- getKeywords on each drill-in. Add/remove speak a confirmation -- a silent
-- commit would leave the user no cue it took. The entry box is wiped after a
-- successful add so the next keyword starts from empty.
local function keywordSettingsGroup(id)
    return BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_SCANNER_KEYWORDS_GROUP",
        cached = false,
        itemsFn = function()
            local items = {
                BaseMenuItems.Textfield({
                    controlName = "CivVAccessScannerKeywordEntry",
                    textKey = "TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADD",
                    valueFn = function()
                        return ""
                    end,
                    priorCallback = function(text, _, bIsEnter)
                        if not bIsEnter then
                            return
                        end
                        local added, reason = ScannerFavorites.addKeyword(id, text)
                        local box = Controls.CivVAccessScannerKeywordEntry
                        if box ~= nil then
                            box:ClearString()
                            box:SetText("")
                        end
                        if added then
                            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADDED"))
                        elseif reason == "duplicate" then
                            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_DUPLICATE"))
                        end
                    end,
                }),
            }
            for _, kw in ipairs(ScannerFavorites.getKeywords(id)) do
                local keyword = kw
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = keyword,
                    onActivate = function()
                        if ScannerFavorites.removeKeyword(id, keyword) then
                            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_REMOVED"))
                        end
                    end,
                })
            end
            return items
        end,
    })
end

-- A rename field on top, then a keywords drillable, then one drillable per
-- taxonomy category, each holding an All checkbox plus a checkbox per named
-- subcategory. Categories
-- with no named subs surface only the All box -- their whole-category
-- selector is the single meaningful pick. cached = false so reopening the
-- editor reflects the live model.
--
-- The rename Textfield reads its value through valueFn (the live group name)
-- rather than the EditBox: Civ V's focused EditBox keeps a typing buffer that
-- TakeFocus and arrow-key navigation wipe to empty, so GetText is unreliable
-- for display. priorCallback commits on Enter, dropping empty text (edit mode
-- clears the box on entry, and a no-change Enter-through reads back "").
local function buildEditorItems(id)
    local items = {
        BaseMenuItems.Textfield({
            controlName = "CivVAccessScannerRenameEntry",
            textKey = "TXT_KEY_MODDING_HEADING_NAME",
            valueFn = function()
                local group = findGroup(id)
                return group and group.name or ""
            end,
            priorCallback = function(text, _, bIsEnter)
                if bIsEnter then
                    ScannerFavorites.rename(id, text)
                end
            end,
        }),
        keywordSettingsGroup(id),
    }
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
    local group = findGroup(id)
    if group == nil then
        Log.warn("ScannerFavorites.openEditor: unknown id " .. tostring(id))
        return
    end
    -- One EditBox is shared by every category's rename field, so a name typed
    -- for a prior category lingers in it. Wipe it on open (ClearString resets
    -- the typing buffer GetText reads from, SetText clears the display) so the
    -- Name field announces this group's name via valueFn, not stale text.
    local box = Controls.CivVAccessScannerRenameEntry
    if box ~= nil then
        box:ClearString()
        box:SetText("")
    end
    -- The keyword entry box shares the same stale-buffer hazard.
    local kwBox = Controls.CivVAccessScannerKeywordEntry
    if kwBox ~= nil then
        kwBox:ClearString()
        kwBox:SetText("")
    end
    local handler = BaseMenu.create({
        name = "ScannerCustomEditor",
        displayName = group.name,
        items = buildEditorItems(id),
        capturesAllInput = true,
        escapePops = true,
    })
    HandlerStack.push(handler)
end

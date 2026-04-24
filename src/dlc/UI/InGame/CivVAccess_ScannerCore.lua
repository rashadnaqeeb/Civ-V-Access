-- Scanner taxonomy, entry shape, and backend-registration registry.
-- No game calls -- this file defines only the static ordering tables and
-- the contract every backend implements.
--
-- Hierarchy (design section 1):
--   category -> subcategory -> item -> instance.
-- Every category has an implicit `all` subcategory at index 1 that
-- shares item references with its named siblings; removing an instance
-- from a named subcategory automatically drops it from `all` because
-- items are shared, not copied. Snapshot building (ScannerSnap) owns
-- the merge; this file just declares the named subcategories.
--
-- Categories with no meaningful split declare `subcategories = {}` and
-- backends emit entries with `subcategory = "all"` directly. Snap adds
-- them once into the implicit `all` sub without the named-sib share
-- step. Sub-cycle in Nav then degenerates to a no-op on those
-- categories (only one sub with items).
--
-- ScanEntry shape (emitted by every backend's Scan):
--   plotIndex   number      Map.GetPlotByIndex index.
--   backend     table       ScannerCore-registered backend; Snap uses
--                           this for ValidateEntry / FormatName dispatch.
--   data        opaque      Backend-specific handle (city ID, unit ID,
--                           plot coords, etc.) that ValidateEntry and
--                           FormatName read -- never game state cached
--                           off it, always re-queried at announce time.
--   category    string      Key from ScannerCore.CATEGORIES.
--   subcategory string      Key of a named subcategory beneath category.
--                           `all` is never emitted; Snap assembles it.
--   itemName    string      Already-localised label; the "collapse by
--                           name" key for grouping instances into items.
--   key         string      Stable identifier for the underlying entity
--                           (unit ID, city ID, plot + kind, ...) that
--                           survives rebuilds. Nav uses it to re-find
--                           the user's cursor across an identity-
--                           preserving rebuild so a resort doesn't move
--                           them off whatever they were on. Two entries
--                           produced by the same backend for the same
--                           entity must emit the same key; distinct
--                           entries (e.g. base terrain + feature on the
--                           same plot) must emit distinct keys.
--   sortKey     number      Optional secondary sort; falls through to
--                           PlotDistance on tie. Backends that don't
--                           need one can leave it 0.

ScannerCore = {}

-- Category ordering is also the announcement order on Ctrl+PageUp/Down.
-- Each category's `subcategories` array defines the order within the
-- category; `all` is implicit at index 1 and not listed here.
ScannerCore.CATEGORIES = {
    {
        key = "cities",
        label = "TXT_KEY_CITIES_HEADING1_TITLE",
        subcategories = {
            { key = "my", label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY" },
            { key = "neutral", label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL" },
            { key = "enemy", label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY" },
            { key = "barb", label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS" },
        },
    },
    {
        key = "units_my",
        label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY",
        subcategories = {
            { key = "melee", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE" },
            { key = "ranged", label = "TXT_KEY_ADVISOR_RANGED_UNIT_DISPLAY" },
            { key = "siege", label = "TXT_KEY_ADVISOR_SIEGE_UNIT_DISPLAY" },
            { key = "mounted", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED" },
            { key = "naval", label = "TXT_KEY_ADVISOR_COMBAT_NAVAL_UNIT_DISPLAY" },
            { key = "air", label = "TXT_KEY_UNITS_AIR_HEADING3_TITLE" },
            { key = "civilian", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN" },
            { key = "great_people", label = "TXT_KEY_ADVISOR_GREAT_PERSON_DISPLAY" },
        },
    },
    {
        key = "units_neutral",
        label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL",
        subcategories = {
            { key = "melee", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE" },
            { key = "ranged", label = "TXT_KEY_ADVISOR_RANGED_UNIT_DISPLAY" },
            { key = "siege", label = "TXT_KEY_ADVISOR_SIEGE_UNIT_DISPLAY" },
            { key = "mounted", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED" },
            { key = "naval", label = "TXT_KEY_ADVISOR_COMBAT_NAVAL_UNIT_DISPLAY" },
            { key = "air", label = "TXT_KEY_UNITS_AIR_HEADING3_TITLE" },
            { key = "civilian", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN" },
            { key = "great_people", label = "TXT_KEY_ADVISOR_GREAT_PERSON_DISPLAY" },
        },
    },
    {
        key = "units_enemy",
        label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY",
        subcategories = {
            { key = "melee", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE" },
            { key = "ranged", label = "TXT_KEY_ADVISOR_RANGED_UNIT_DISPLAY" },
            { key = "siege", label = "TXT_KEY_ADVISOR_SIEGE_UNIT_DISPLAY" },
            { key = "mounted", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED" },
            { key = "naval", label = "TXT_KEY_ADVISOR_COMBAT_NAVAL_UNIT_DISPLAY" },
            { key = "air", label = "TXT_KEY_UNITS_AIR_HEADING3_TITLE" },
            { key = "civilian", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN" },
            { key = "great_people", label = "TXT_KEY_ADVISOR_GREAT_PERSON_DISPLAY" },
            { key = "barbarians", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS" },
        },
    },
    {
        key = "resources",
        label = "TXT_KEY_MAP_OPTION_RESOURCES",
        subcategories = {
            { key = "strategic", label = "TXT_KEY_RESOURCES_STRATEGIC_HEADING2_TITLE" },
            { key = "luxury", label = "TXT_KEY_RESOURCES_LUXURY_HEADING2_TITLE" },
            { key = "bonus", label = "TXT_KEY_RESOURCES_BONUS_HEADING2_TITLE" },
        },
    },
    {
        key = "improvements",
        label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS",
        subcategories = {
            { key = "my", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_MY" },
            { key = "neutral", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL" },
            { key = "enemy", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY" },
        },
    },
    {
        key = "special",
        label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL",
        subcategories = {
            { key = "natural_wonders", label = "TXT_KEY_ADVISOR_DISCOVERED_NATURAL_WONDER_DISPLAY" },
            { key = "ancient_ruins", label = "TXT_KEY_IMPROVEMENT_GOODY_HUT" },
        },
    },
    {
        key = "terrain",
        label = "TXT_KEY_TERRAIN_HEADING1_TITLE",
        subcategories = {
            { key = "base", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE" },
            { key = "features", label = "TXT_KEY_TERRAIN_FEATURES_HEADING2_TITLE" },
            { key = "elevation", label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION" },
        },
    },
    {
        -- Settler and worker tile recommendations sourced from
        -- Player:GetRecommendedFoundCityPlots and GetRecommendedWorkerPlots.
        -- No named subs: settler and worker recs never coexist in one
        -- selection frame (the engine gates each kind on its matching
        -- UI.CanSelectionList* check), so a split would add a navigation
        -- step with no disambiguation payoff.
        key = "recommendations",
        label = "TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS",
        subcategories = {},
    },
}

-- Lookup table for O(1) category-by-key access. Built at load time from
-- the ordered list above.
ScannerCore.CATEGORIES_BY_KEY = {}
for _, cat in ipairs(ScannerCore.CATEGORIES) do
    ScannerCore.CATEGORIES_BY_KEY[cat.key] = cat
end

-- Backends self-register into this list in their own module. Nav iterates
-- the list in registration order to produce the flat entry list for a
-- snapshot rebuild.
ScannerCore.BACKENDS = {}

function ScannerCore.registerBackend(backend)
    if
        type(backend) ~= "table"
        or type(backend.Scan) ~= "function"
        or type(backend.ValidateEntry) ~= "function"
        or type(backend.FormatName) ~= "function"
    then
        Log.error("ScannerCore.registerBackend: bad backend shape " .. tostring(backend and backend.name))
        return
    end
    ScannerCore.BACKENDS[#ScannerCore.BACKENDS + 1] = backend
end

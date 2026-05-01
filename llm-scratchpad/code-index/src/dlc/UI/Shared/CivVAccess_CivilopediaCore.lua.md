# `src/dlc/UI/Shared/CivVAccess_CivilopediaCore.lua`

1250 lines · Civilopedia data module providing picker item construction and article reader harvesting by scraping rendered Controls after SelectArticle, plus flat cross-hierarchy search corpus.

## Header comment

```
-- Civilopedia data module. Two public fns:
--   Civilopedia.buildPickerItems(entryFactory) - top-level picker (one Group
--     per category; children built lazily from the pedia's own sortedList).
--   Civilopedia.buildReader(handler, category, entryID) - reader-tab content
--     for one article: a flat array of leaves (title, stats, text sections,
--     free-form text, BB text, relationship links), harvested from the
--     rendered Controls after CivilopediaCategory[cat].SelectArticle.
--
-- Why scrape Controls instead of querying GameInfo directly: per-category
-- schemas diverge in non-obvious ways [...]. SelectArticle is the game's own
-- per-category renderer -- it does all that work for us.
-- [... never-cache and link-follow design documented ...]
```

## Outline

- L30: `Civilopedia = {}`
- L32: `Civilopedia.CATEGORY = {...}`
- L55: `local READER_TAB_IDX = 2`
- L57: `local function categoryLabelKey(cat)`
- L65: `local STAT_FRAMES = {...}`
- L124: `local TEXT_FRAMES = {...}`
- L148: `local RELATIONSHIP_DEFS = {...}`
- L361: `local function ctrlText(ctrl)`
- L367: `local function ctrlHidden(ctrl)`
- L374: `local function makeEntryID(cat, entryID)`
- L382: `local function addLeaf(leaves, header, body)`
- L395: `local function headerFor(def)`
- L414: `local function resolveRelationshipCategory(def, currentCat)`
- L437: `local followLink`
- L445: `local SECTION_TEXT_KEY_PREFIX = {...}`
- L463: `local function getSections(cat)`
- L579: `local function entryFromArticle(entryFactory, cat, article)`
- L602: `local function introEntry(entryFactory, cat, spec)`
- L636: `local function categoryChildren(entryFactory, cat)`
- L666: `local function categoryGroup(cat, entryFactory)`
- L682: `local function hasTable(name)`
- L692: `local function harvestStats(leaves)`
- L706: `local function harvestTextSections(leaves)`
- L719: `local function dropTitleEchoHeader(header, title)`
- L733: `local function harvestFreeFormText(leaves)`
- L749: `local function harvestBBText(leaves)`
- L772: `local function harvestRelationships(leaves, handler, currentCat)`
- L826: `function Civilopedia._harvestInto(leaves, handler, currentCat)`
- L843: `local function harvestIntoReader(handler, cat, entryID)`
- L865: `function Civilopedia.openArticle(handler, cat, entryID)`
- L876: `function Civilopedia.stageArticleForShow(handler, cat, entryID)`
- L885: `local function findCategoryPickerIdx(handler, cat)`
- L899: `function Civilopedia.openCategory(handler, iHomePage)`
- L919: `function Civilopedia.stageCategoryForShow(handler, iHomePage)`
- L932: `function followLink(handler, targetCat, targetID)`
- L964: `function Civilopedia.goBack(handler)`
- L995: `function Civilopedia.goForward(handler)`
- L1047: `local function isIntroId(id)`
- L1054: `local function walkWithPath(items, path, visit)`
- L1066: `local function copyPath(path)`
- L1074: `local function buildFlatCorpus(pickerItems)`
- L1119: `local function teleportToPath(handler, rootItems, path, label)`
- L1142: `function Civilopedia.buildFlatSearchable(handler)`
- L1172: `function Civilopedia.buildPickerItems(entryFactory)`
- L1214: `function Civilopedia.buildReader(handler, category, entryID)`
- L1250: `return Civilopedia`

## Notes

- L437 `local followLink`: forward-declared so harvesters (which close over it) can reference it before the function definition at L932.
- L826 `Civilopedia._harvestInto`: underscore prefix indicates semi-internal; exposed for `introEntry`'s DisplayHomePage path which calls it directly after firing the category renderer.
- L1142 `Civilopedia.buildFlatSearchable`: rebuilds the flat corpus on every keystroke (every invocation); acceptable at pedia scale but not suitable for large dynamic lists.
- L876 `Civilopedia.stageArticleForShow`: populates the reader tab and sets initialTabIndex so the pedia opens directly to the article without a mid-transition announce; use when the screen is still hidden.

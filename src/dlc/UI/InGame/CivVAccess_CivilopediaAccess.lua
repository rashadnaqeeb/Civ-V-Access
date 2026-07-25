-- CivilopediaScreen accessibility wiring. Appended to the pedia.lua override.
--
-- The pedia's own code has finished running by the time this include fires,
-- so CivilopediaCategory / SetSelectedCategory / ShowHideHandler /
-- InputHandler are live globals. We chain priorShowHide so the engine's
-- history restoration on reopen still runs, and priorInput so the pedia's
-- own Esc-to-close path fires when the user Escs out at picker level 1.
--
-- Per-Context include chain: the pedia is its own LuaContext under InGame,
-- with its own Lua globals. The shared modules must load into this sandbox
-- before anything touches Text / BaseMenu / etc. These same include stems
-- are already loaded into other InGame Contexts; the engine's VFS indexes
-- by bare stem and re-runs the file per Context.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
include("CivVAccess_AudioCueMode")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_PluralRules")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_Verbosity")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_EditCapture")
include("CivVAccess_Help")
include("CivVAccess_VolumeControl")
include("CivVAccess_BeaconRange")
include("CivVAccess_BeaconVolume")
include("CivVAccess_Settings")
include("CivVAccess_PickerReader")
include("CivVAccess_CivilopediaCore")
-- Seated in this Context rather than reached through
-- civvaccess_shared.modules: the effects-text bodies call builder globals
-- (VP's InfoTooltipInclude / TechHelpInclude) that resolve in the pedia's env
-- and not in InGame's, and a function carries the env it was loaded under.
include("CivVAccess_EngineData")
include("CivVAccess_PediaSearchCore")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

local MOD_CTRL = 2

Log.info("CivilopediaAccess: wiring PickerReader over base pedia")

local session = PickerReader.create()
local pickerItems = Civilopedia.buildPickerItems(session.Entry)

Log.info("CivilopediaAccess: built " .. tostring(#pickerItems) .. " top-level categories")

-- Set by Events.SearchForPediaEntry / Events.GoToPediaHomePage when the
-- pedia is hidden at the moment the event fires. UIManager:QueuePopup
-- is async (ShowHide runs next tick), so we stage the target here and
-- consume it from onShow, which runs after priorShowHide but before
-- HandlerStack.push -- the window where setInitialTabIndex / setItems
-- land before openInitial reads them.
local pendingTarget = nil

-- True when the pedia was opened directly to a specific article (via
-- Ctrl+I, cursor pedia, hyperlink, etc.) and the user has not yet done
-- anything that suggests further exploration -- in which case Esc on
-- the reader tab closes the screen outright instead of bouncing back
-- to the category picker. Disarmed by any handler.switchToTab call,
-- which covers Tab/Shift+Tab cycling, follow-link, history nav,
-- adjacent-article nav, and picker-tab Entry activation -- every path
-- that takes the user somewhere other than the article they were
-- shown on entry.
local quickCloseArmed = false

-- Ctrl+F body-search filter over the picker tab. While active, the
-- picker holds the filtered category tree from
-- Civilopedia.buildFilteredPickerItems and savedLevel / savedIndices
-- remember the pre-search cursor in the full tree. Esc on the picker tab
-- (via the pickerEscape hook) clears the filter and restores both.
local pickerFilter = { active = false, savedLevel = nil, savedIndices = nil }

local function copyIndices(indices)
    local copy = {}
    for i, v in ipairs(indices) do
        copy[i] = v
    end
    return copy
end

local function clearSearchFilter(h, silent)
    if not pickerFilter.active then
        return
    end
    pickerFilter.active = false
    h.setItems(pickerItems, 1)
    if Controls.SearchEditBox ~= nil then
        Controls.SearchEditBox:SetText("")
    end
    -- Reseat the pre-search cursor. setItems reset the cursor to the
    -- top; the saved path came from this same full tree, so walking it
    -- back down resolves. Intermediate Groups are materialized on the
    -- way (cached=false children rebuild lazily) so subsequent arrow
    -- nav sees the same child set, mirroring the flat-search teleport.
    if pickerFilter.savedIndices ~= nil and h._tabIndex == 1 then
        local cursor = pickerItems
        local pathOk = true
        for depth = 1, #pickerFilter.savedIndices - 1 do
            local parent = cursor[pickerFilter.savedIndices[depth]]
            if parent == nil or type(parent.children) ~= "function" then
                pathOk = false
                break
            end
            cursor = parent:children()
        end
        if pathOk then
            h._level = pickerFilter.savedLevel
            h._indices = copyIndices(pickerFilter.savedIndices)
        end
    end
    pickerFilter.savedLevel = nil
    pickerFilter.savedIndices = nil
    if not silent then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
    end
end

-- Commit path for a typed query: match against the body corpus, swap
-- the picker to the filtered category tree, and speak only the result
-- count. The transient tab / item announcements switchToTab and
-- setItems produce are cut by the final speakInterrupt (the
-- openCategory pattern). A search while already filtered re-filters
-- from the full tree but keeps the original pre-search cursor for the
-- eventual restore.
local function applySearchQuery(h, query)
    local matchSet, matchCount = PediaSearch.match(query)
    Log.info("CivilopediaAccess: query '" .. tostring(query) .. "' matched " .. tostring(matchCount) .. " articles")
    if matchCount == 0 then
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_PEDIA_SEARCH_NO_MATCH", query))
        return
    end
    local filteredItems, shownCount = Civilopedia.buildFilteredPickerItems(session.Entry, matchSet)
    if shownCount == 0 then
        Log.warn(
            "CivilopediaAccess: query '"
                .. tostring(query)
                .. "' matched "
                .. tostring(matchCount)
                .. " articles but none placed in the picker tree"
        )
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_PEDIA_SEARCH_NO_MATCH", query))
        return
    end
    if not pickerFilter.active then
        pickerFilter.active = true
        if h._tabIndex == 1 then
            pickerFilter.savedLevel = h._level
            pickerFilter.savedIndices = copyIndices(h._indices)
        end
    end
    h.setItems(filteredItems, 1)
    if h._tabIndex ~= 1 then
        h.switchToTab(1)
    end
    h._level = 1
    h._indices = { 1 }
    SpeechPipeline.speakInterrupt(Text.formatPlural("TXT_KEY_CIVVACCESS_PEDIA_SEARCH_RESULTS", shownCount, shownCount))
end

local handler = session.install(ContextPtr, {
    name = "CivilopediaScreen",
    displayName = Text.key("TXT_KEY_CIVILOPEDIA"),
    pickerTabName = "TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB",
    readerTabName = "TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB",
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    pickerItems = pickerItems,
    pickerBuildSearchable = Civilopedia.buildFlatSearchable,
    readerOnAltLeft = Civilopedia.goBack,
    readerOnAltRight = Civilopedia.goForward,
    onShow = function(h)
        -- Clear the pedia-transit flag set by an underlying screen's
        -- BaseMenu / BaseTable Ctrl+I binding. The flag stays armed only
        -- through the engine's queue-popup cascade (other-screen-hide
        -- then pedia-show), and onShow is the natural lower bound on
        -- "pedia is up now."
        civvaccess_shared.pediaTransitArmed = nil
        -- A filter left up when the pedia was closed would silently
        -- reopen onto a pruned tree; every show starts unfiltered.
        clearSearchFilter(h, true)
        -- Default to disarmed. Article-target opens normally arrive
        -- through the SearchForPediaEntry listener's openArticle branch
        -- (because the base pedia's listener queues QueuePopup
        -- synchronously, leaving us already-visible by the time our
        -- listener runs). The pendingTarget path here covers an
        -- asynchronous-show fallback. Either path arms quickCloseArmed.
        quickCloseArmed = false
        if pendingTarget == nil then
            return
        end
        local target = pendingTarget
        pendingTarget = nil
        if target.kind == "article" then
            Civilopedia.stageArticleForShow(h, target.cat, target.entryID)
            quickCloseArmed = true
        elseif target.kind == "category" then
            Civilopedia.stageCategoryForShow(h, target.cat)
        end
    end,
    -- Reader-tab Esc closes the screen outright when quickCloseArmed
    -- is true (user opened to a specific article and has not moved
    -- since). Otherwise PickerReader bounces back to the picker.
    readerEscapeQuickClose = function()
        return quickCloseArmed
    end,
    -- Esc on the picker tab while a Ctrl+F filter is up clears the
    -- filter (restoring the full tree and pre-search cursor) instead of
    -- closing the pedia; unfiltered Esc falls through and closes as
    -- before.
    pickerEscape = function(h)
        if pickerFilter.active then
            clearSearchFilter(h, false)
            return true
        end
        return false
    end,
    -- Alt+Left/Right is reader-tab-scoped (see PickerReader install) but
    -- the help list is handler-level, so the entry surfaces in help from
    -- either tab. Description is worded as "article history" so the user
    -- can infer it doesn't apply while browsing categories.
    helpExtras = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_F",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_SEARCH",
        },
    },
})

-- Ctrl+F: open the body search. Clears the game's search box, pushes the
-- modal query capture above the menu, and speaks the prompt. The commit
-- callback owns everything after Enter.
handler.bindings[#handler.bindings + 1] = {
    key = Keys.F,
    mods = MOD_CTRL,
    description = "Search article text",
    fn = function()
        if Controls.SearchEditBox ~= nil then
            Controls.SearchEditBox:SetText("")
        end
        PediaSearch.openInput({
            control = Controls.CivVAccessPediaSearchEntry,
            echoControl = Controls.SearchEditBox,
            onCommit = function(query)
                applySearchQuery(handler, query)
            end,
        })
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_PEDIA_SEARCH_PROMPT"))
    end,
}

-- Wrap switchToTab so any tab change disarms quick-close. Covers Tab /
-- Shift+Tab cycling, Entry activation from the picker, follow-link from
-- the reader, history back/forward (Alt+Left/Right), and adjacent
-- article nav (Ctrl+Up/Down) -- every "the user moved" path funnels
-- through switchToTab. Bounce-back from onEscape also calls switchToTab
-- but only fires when quickCloseArmed is already false, so the disarm
-- is a no-op there.
local origSwitchToTab = handler.switchToTab
handler.switchToTab = function(idx)
    quickCloseArmed = false
    origSwitchToTab(idx)
end

-- External "open pedia on article X" requests. Fires from CityView
-- (Ctrl+I on a building tile), AdvisorInfoPopup's Civilopedia button,
-- TechPanel / ProductionPopup / UnitPanel hyperlinks, and our own
-- BaseMenu Ctrl+I binding. The base pedia's listener (registered
-- earlier via Events.SearchForPediaEntry.Add inside CivilopediaScreen
-- chunk) runs first and does SetSelectedCategory + SelectArticle, so
-- by the time our listener runs the article text is already rendered
-- in the sighted Controls -- we just need to harvest + land our UI on
-- the reader tab.
--
-- searchString == "OPEN_VIA_HOTKEY" is the bare-Ctrl+I toggle; base
-- handles the show/hide and there is no article to navigate to.
Log.installEvent(Events, "SearchForPediaEntry", function(searchString)
    if searchString == nil or searchString == "" or searchString == "OPEN_VIA_HOTKEY" then
        return
    end
    local article = searchableTextKeyList[searchString]
    if article == nil then
        article = searchableList[Locale.ToLower(searchString)]
    end
    if article == nil then
        Log.warn("CivilopediaAccess: no article for search string '" .. tostring(searchString) .. "'")
        return
    end
    if ContextPtr:IsHidden() then
        pendingTarget = { kind = "article", cat = article.entryCategory, entryID = article.entryID }
    else
        Civilopedia.openArticle(handler, article.entryCategory, article.entryID)
        -- Arm after openArticle: it calls switchToTab, which our wrapper
        -- uses to disarm, so the arm has to land after that call.
        -- This branch fires when the pedia is already visible at dispatch
        -- time -- either because the base pedia's listener ran QueuePopup
        -- synchronously before us (the popup-Ctrl+I path), or because the
        -- user followed a hyperlink while the pedia was already open.
        -- Both are "open me to a specific article" gestures and warrant
        -- quick-close.
        quickCloseArmed = true
    end
end, "CivilopediaAccess")

-- AdvisorInfoPopup's "View [concept] page" button fires this with the
-- concept's CivilopediaPage (a category number). Base selects the
-- category and QueuePopups; we park the picker cursor on that
-- category's heading so the user lands in the right spot.
Log.installEvent(Events, "GoToPediaHomePage", function(iHomePage)
    if iHomePage == nil then
        return
    end
    if ContextPtr:IsHidden() then
        pendingTarget = { kind = "category", cat = iHomePage }
    else
        -- The target category may be pruned from a filtered tree; drop
        -- the filter so the teleport always lands.
        clearSearchFilter(handler, true)
        Civilopedia.openCategory(handler, iHomePage)
    end
end, "CivilopediaAccess")

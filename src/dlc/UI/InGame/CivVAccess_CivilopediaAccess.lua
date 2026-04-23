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
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_PickerReader")
include("CivVAccess_CivilopediaCore")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

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
        if pendingTarget == nil then
            return
        end
        local target = pendingTarget
        pendingTarget = nil
        if target.kind == "article" then
            Civilopedia.stageArticleForShow(h, target.cat, target.entryID)
        elseif target.kind == "category" then
            Civilopedia.stageCategoryForShow(h, target.cat)
        end
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
    },
})

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
Events.SearchForPediaEntry.Add(function(searchString)
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
    end
end)

-- AdvisorInfoPopup's "View [concept] page" button fires this with the
-- concept's CivilopediaPage (a category number). Base selects the
-- category and QueuePopups; we park the picker cursor on that
-- category's heading so the user lands in the right spot.
Events.GoToPediaHomePage.Add(function(iHomePage)
    if iHomePage == nil then
        return
    end
    if ContextPtr:IsHidden() then
        pendingTarget = { kind = "category", cat = iHomePage }
    else
        Civilopedia.openCategory(handler, iHomePage)
    end
end)

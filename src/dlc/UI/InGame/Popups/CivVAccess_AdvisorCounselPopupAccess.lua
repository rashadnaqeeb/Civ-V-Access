-- AdvisorCounselPopup accessibility. BUTTONPOPUP_ADVISOR_COUNSEL shows all
-- four advisors' current counsel on one screen (2x2 grid); each advisor has
-- its own list of counsel pages paginated via per-advisor Prev/Next buttons.
-- Engine-reachable on the `V` hotkey (CONTROL_ADVISOR_COUNSEL); Baseline
-- swallows `V` so our own F10 binding (BaselineHandler) is the keyboard
-- entry point.
--
-- Tabbed BaseMenu, one tab per advisor in the visual reading order
-- (Economic, Military, Foreign, Science). Each tab's items are the counsel
-- pages for that advisor, one Text item per page. Page label is prefixed
-- with "i/N" when N > 1 so the user hears their position; single-page
-- advisors skip the prefix. Empty advisors render a single "no counsel"
-- placeholder so Tab does not land on nothing.
--
-- Visual sync: each page item's announce wrap calls ShowAdvisorText(advisor,
-- pageIndex) before returning the label. ShowAdvisorText is a global in the
-- base popup that rewrites the visible body label, per-advisor page counter,
-- and Prev/Next enable states -- so a sighted observer watching the screen
-- sees the same page the blind user is being read. On Tab into a new
-- advisor the first item's pageIndex is 0, so the visible panel resets to
-- page 1 for that advisor automatically.
--
-- Counsel data source: Game.GetAdvisorCounsel() in onShow. Base OnPopup has
-- already populated its own local AdvisorCounselTable via UpdateAdvisorSlots
-- by the time our ShowHide wrapper fires, so our independent call reads the
-- same state; we cannot reach the base's local directly. No caching across
-- opens -- onShow rebuilds for every popup appearance.

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

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local Advisors = {
    { type = AdvisorTypes.ADVISOR_ECONOMIC, nameKey = "TXT_KEY_ADVISOR_ECON_TITLE" },
    { type = AdvisorTypes.ADVISOR_MILITARY, nameKey = "TXT_KEY_ADVISOR_MILITARY_TITLE" },
    { type = AdvisorTypes.ADVISOR_FOREIGN,  nameKey = "TXT_KEY_ADVISOR_FOREIGN_TITLE" },
    { type = AdvisorTypes.ADVISOR_SCIENCE,  nameKey = "TXT_KEY_ADVISOR_SCIENCE_TITLE" },
}

local function emptyItem()
    return BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY") })
end

local function buildItemsForAdvisor(counselTable, advisorType)
    local list = counselTable and counselTable[advisorType]
    local total = list and table.count(list) or 0
    if total == 0 then
        return { emptyItem() }
    end
    local items = {}
    -- Base AdvisorCounselTable is 0-indexed (AdvisorCounselIndexTable starts
    -- at 0 and ShowAdvisorText reads list[index] directly). Iterate 0..N-1 so
    -- pageIndex matches what ShowAdvisorText expects.
    for pageIndex = 0, total - 1 do
        local pageText = list[pageIndex] or ""
        local label
        if total > 1 then
            -- Reuse the engine's page-display key (TXT_KEY_ADVISOR_COUNSEL_PAGE_DISPLAY = "{1_Num}/{2_Num}")
            -- for the fraction so blind and sighted players hear / see the same "i/N" label text.
            local fraction = Text.format("TXT_KEY_ADVISOR_COUNSEL_PAGE_DISPLAY", pageIndex + 1, total)
            label = fraction .. ", " .. pageText
        else
            label = pageText
        end
        local item = BaseMenuItems.Text({ labelText = label })
        local baseAnnounce = item.announce
        item.announce = function(self, menu)
            -- Sync visible panel so a sighted observer sees the page the
            -- blind user is hearing. ShowAdvisorText is a global defined in
            -- the base popup file above our include; it reads the base's
            -- own AdvisorCounselTable (populated by UpdateAdvisorSlots) and
            -- rewrites the body label + page counter + Prev/Next enables.
            local ok, err = pcall(ShowAdvisorText, advisorType, pageIndex)
            if not ok then
                Log.error("AdvisorCounselPopupAccess: ShowAdvisorText failed: " .. tostring(err))
            end
            return baseAnnounce(self, menu)
        end
        items[#items + 1] = item
    end
    return items
end

local function onShow(handler)
    local counselTable = Game.GetAdvisorCounsel()
    for tabIndex, advisor in ipairs(Advisors) do
        handler.setItems(buildItemsForAdvisor(counselTable, advisor.type), tabIndex)
    end
end

local tabs = {}
for i, advisor in ipairs(Advisors) do
    tabs[i] = {
        name  = advisor.nameKey,
        items = { emptyItem() },
    }
end

BaseMenu.install(ContextPtr, {
    name          = "AdvisorCounselPopup",
    displayName   = Text.key("TXT_KEY_ADVISOR_COUNSEL"),
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    onShow        = onShow,
    tabs          = tabs,
})

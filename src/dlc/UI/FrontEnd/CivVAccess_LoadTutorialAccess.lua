-- LoadTutorial accessibility wiring. Base declares ShowHideHandler and
-- InputHandler as globals so both priors forward normally. SetSelected
-- and OnStart / OnBack are globals too; the sentinel index -1 picks the
-- Intro, 1..5 pick tutorial slots. The base's Tutorials metadata table
-- is a file-local that our sandbox can't reach, so tutorial labels are
-- composed from the well-known TXT_KEY_TUTORIAL{N}_TITLE / _DESC keys
-- (stable since Civ V shipped; Intro uses TXT_KEY_TUTORIAL_INSTRUCT).
-- Completion state is surfaced by reading g_TutorialEntries[i].
-- CompletedIcon:IsHidden(), which the base's ShowHide refreshes from
-- modUserData on every open.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

local TUTORIAL_ROWS = {
    { slot = -1, nameKey = "TXT_KEY_TUTORIAL_INSTRUCT", descKey = "TXT_KEY_TUTORIAL0_DESC" },
    { slot =  1, nameKey = "TXT_KEY_TUTORIAL1_TITLE",   descKey = "TXT_KEY_TUTORIAL1_DESC" },
    { slot =  2, nameKey = "TXT_KEY_TUTORIAL2_TITLE",   descKey = "TXT_KEY_TUTORIAL2_DESC" },
    { slot =  3, nameKey = "TXT_KEY_TUTORIAL3_TITLE",   descKey = "TXT_KEY_TUTORIAL3_DESC" },
    { slot =  4, nameKey = "TXT_KEY_TUTORIAL4_TITLE",   descKey = "TXT_KEY_TUTORIAL4_DESC" },
    { slot =  5, nameKey = "TXT_KEY_TUTORIAL5_TITLE",   descKey = "TXT_KEY_TUTORIAL5_DESC" },
}

local function completionSuffix(slot)
    -- Intro has no completion tracking; base only populates icons for
    -- slots 1..5 via g_TutorialEntries (CompletedIcon hidden = not done).
    if slot < 1 then return nil end
    local entry = g_TutorialEntries and g_TutorialEntries[slot]
    if entry == nil or entry.CompletedIcon == nil then return nil end
    if entry.CompletedIcon:IsHidden() then return nil end
    return Text.key("TXT_KEY_CIVVACCESS_TUTORIAL_COMPLETED")
end

-- Base's g_iSelected is a file-local, unreachable from our sandbox. But
-- base drives a SelectHighlight widget per row (Controls.LearnSelectHighlight
-- for the intro, g_TutorialEntries[i].SelectHighlight for slots 1..5), so
-- we read selection state off those widgets. A highlight that is visible
-- (IsHidden false) is the currently-selected row.
local function isSelected(slot)
    if slot == -1 then
        local c = Controls.LearnSelectHighlight
        return c ~= nil and not c:IsHidden()
    end
    local entry = g_TutorialEntries and g_TutorialEntries[slot]
    if entry == nil or entry.SelectHighlight == nil then return false end
    return not entry.SelectHighlight:IsHidden()
end

local function buildItems()
    local items = {}
    for _, row in ipairs(TUTORIAL_ROWS) do
        local slot    = row.slot
        local label   = Text.key(row.nameKey)
        local suffix  = completionSuffix(slot)
        if suffix ~= nil then label = label .. ", " .. suffix end
        items[#items + 1] = BaseMenuItems.Choice({
            labelText   = label,
            tooltipText = Text.key(row.descKey),
            selectedFn  = function() return isSelected(slot) end,
            activate    = function() SetSelected(slot) end,
        })
    end
    items[#items + 1] = BaseMenuItems.Button({ controlName = "StartButton",
        textKey  = "TXT_KEY_START_TUTORIAL_BUTTON",
        activate = function() OnStart() end })
    items[#items + 1] = BaseMenuItems.Button({ controlName = "BackButton",
        textKey  = "TXT_KEY_BACK_BUTTON",
        activate = function() OnBack() end })
    return items
end

BaseMenu.install(ContextPtr, {
    name          = "LoadTutorial",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TUTORIAL"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    onShow        = function(h) h.setItems(buildItems()) end,
    items         = buildItems(),
})

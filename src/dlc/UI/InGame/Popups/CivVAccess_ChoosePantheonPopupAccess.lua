-- ChoosePantheonPopup accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_FOUND_PANTHEON.
-- Serves two related screens: the original pantheon founder (Data2 > 0)
-- and the Reformation bonus belief picker (Data2 == 0). Both walk a list
-- of beliefs sorted by short-description locale order.
--
-- Flow: pick a belief -> SelectPantheon(beliefID) shows the ChooseConfirm
-- overlay with the formatted "found {Belief}?" prompt -> we push
-- ChooseConfirmSub which navigates the overlay's Yes / No buttons.
-- Unusually, Pantheon's overlay buttons are named "Yes" / "No" rather
-- than "ConfirmYes" / "ConfirmNo" (the pattern the other Choose* popups
-- use), so we pass the control names through. On Yes, OnYes fires
-- Network.SendFoundPantheon and OnClose dismisses.
--
-- Conquest of the New World Deluxe runs this wrapper inside its own copy of
-- the screen, where the American civs found their religion. The Maya pick
-- two beliefs: the screen takes the first without its confirm overlay, lists
-- the other beliefs again, and shows lines naming the first belief and
-- asking for the second. So a pick that leaves the overlay hidden rebuilds
-- the list without that belief and reads those lines, instead of opening the
-- confirm menu, and the preamble reads them whenever they show.

include("CivVAccess_PopupBoot")
include("CivVAccess_ChooseConfirmSub")
include("CivVAccess_BeliefAdvisor")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- The scenario screen's lines about the Maya's two picks.
local PICK_LINES = { "Belief1Label", "ChooseBelief1", "ChooseBelief2" }

-- Beliefs the screen has taken in this popup without a confirm.
local _taken = {}

local function preambleText()
    local parts = { Text.controlText(Controls.PanelTitle, "ChoosePantheonPopup PanelTitle") }
    for _, name in ipairs(PICK_LINES) do
        local line = Controls[name]
        if line ~= nil and not line:IsHidden() then
            parts[#parts + 1] = Text.controlText(line, "ChoosePantheonPopup " .. name)
        end
    end
    return Text.joinNonEmpty(parts, ", ")
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChoosePantheonPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

local function buildItems(popupInfo)
    local bPantheons = popupInfo.Data2 and popupInfo.Data2 > 0
    local available = bPantheons and Game.GetAvailablePantheonBeliefs() or Game.GetAvailableReformationBeliefs()

    local rows = {}
    local offeredIDs = {}
    for _, beliefID in ipairs(available) do
        local belief = GameInfo.Beliefs[beliefID]
        if belief ~= nil and not _taken[beliefID] then
            rows[#rows + 1] = {
                ID = belief.ID,
                Name = Text.key(belief.ShortDescription),
                Description = Text.key(belief.Description),
            }
            offeredIDs[#offeredIDs + 1] = belief.ID
        end
    end
    table.sort(rows, function(a, b)
        return Locale.Compare(a.Name, b.Name) < 0
    end)

    -- Engine advisor ranking (empty map on vanilla).
    local advisor = BeliefAdvisor.labelSuffixes(offeredIDs)

    local items = {}
    for _, row in ipairs(rows) do
        local beliefID = row.ID
        local label = row.Name
        if advisor[beliefID] ~= nil then
            label = label .. ", " .. advisor[beliefID]
        end
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = label,
            tooltipText = row.Description,
            activate = function()
                SelectPantheon(beliefID)
                if Controls.ChooseConfirm:IsHidden() then
                    _taken[beliefID] = true
                    mainHandler.setItems(buildItems(popupInfo))
                    mainHandler.refresh()
                    return
                end
                ChooseConfirmSub.push({
                    yesControl = "Yes",
                    noControl = "No",
                    onYes = function()
                        OnYes()
                    end,
                })
            end,
        })
    end
    return items
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON then
        return
    end
    _taken = {}
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChoosePantheonPopupAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)

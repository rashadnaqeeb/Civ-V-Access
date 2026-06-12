-- Seated in each of the four EventOverview panel Contexts
-- (PlayerEventsInfo, CityEventsInfo, RecentEventsInfo,
-- CityRecentEventsInfo) via the include appended to the vendor file
-- (Vox Populi only; the Contexts are Community Patch UI addins and do
-- not exist on vanilla installs). Publishes the panel's SortByPullDown
-- to civvaccess_shared so CivVAccess_EventOverviewAccess (seated in the
-- parent EventOverview Context, a separate sandbox) can wrap it as a
-- BaseMenu Pulldown item, and makes sure the widget probes are patched
-- before the panel's Initialize() builds the sort entries on first show
-- (the panels wire per-entry button callbacks, so both the pulldown and
-- the button probe matter).
--
-- Panel identity comes from which per-panel stack control exists; the
-- four panel XMLs share every other relevant control name
-- (SortByPullDown, ItemStack, ItemScrollPanel).

include("CivVAccess_Log")
include("CivVAccess_PullDownProbe")

local PANEL_KEYS = {
    PlayerEventsStack = "playerChoices",
    CityEventsStack = "cityChoices",
    RecentEventsStack = "playerInstant",
    CityRecentEventsStack = "cityInstant",
}

local panelKey
for controlName, key in pairs(PANEL_KEYS) do
    if Controls[controlName] ~= nil then
        panelKey = key
        break
    end
end
if panelKey == nil then
    Log.error("EventPanelProbe: no panel stack control found; sort pulldown stays unwrapped")
    return
end

local pulldown = Controls.SortByPullDown
if pulldown == nil then
    Log.error("EventPanelProbe: panel '" .. panelKey .. "' has no SortByPullDown control")
    return
end

PullDownProbe.ensureInstalled(pulldown)
PullDownProbe.ensureButtonInstalled(pulldown:GetButton())

local published = civvaccess_shared.eventOverviewSortPulldowns
if published == nil then
    published = {}
    civvaccess_shared.eventOverviewSortPulldowns = published
end
published[panelKey] = pulldown

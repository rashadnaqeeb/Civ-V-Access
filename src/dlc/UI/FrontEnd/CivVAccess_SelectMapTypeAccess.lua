-- Select Map Type accessibility wiring.
-- The base screen is a folder tree: Refresh() builds a rootFolder with
-- nested sub-folders, View(folder) renders folder.Items. Our items are
-- kept in sync by wrapping the global View: after the base renders, we
-- translate folder.Items into Choice items. Sub-folder entries drill in
-- via their own Callback (= View(subfolder)); folder.ParentFolder handles
-- back navigation. Leaf entries call through to OnMapScriptSelected /
-- OnMultiSizeMapSelected (via v.Callback), which fires OnBack and pops
-- our handler through the Context's ShowHide.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler
local handler

-- Localized name of the currently selected map script, if PreGame's
-- current script resolves to a known row. Used to point the cursor at
-- the current selection when the screen opens.
local function currentSelectionName()
    if PreGame.IsRandomMapScript() then
        return Text.key("TXT_KEY_RANDOM_MAP_SCRIPT")
    end
    local file = PreGame.GetMapScript()
    for row in GameInfo.MapScripts{FileName = file} do
        return Text.key(row.Name)
    end
    for row in GameInfo.Map_Sizes{FileName = file} do
        local entry = GameInfo.Maps[row.MapType]
        if entry ~= nil then return Text.key(entry.Name) end
    end
end

-- Returns (items[], index-of-current-selection or nil).
local function buildItemsForFolder(folder)
    local items = {}
    local selectedIdx = nil
    local selectionName = currentSelectionName()
    if folder.ParentFolder ~= nil then
        local parent = folder.ParentFolder
        items[#items + 1] = BaseMenuItems.Choice({
            labelText  = Text.key("TXT_KEY_SELECT_MAP_TYPE_BACK"),
            tooltipKey = "TXT_KEY_SELECT_MAP_TYPE_BACK_HELP",
            activate   = function()
                View(parent)
                -- rootFolder has no Name; fall back to the screen display name.
                local label = parent.Name
                if label == nil or label == "" then
                    label = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAP_TYPE")
                end
                SpeechPipeline.speakInterrupt(label)
            end,
        })
    end
    for _, v in ipairs(folder.Items) do
        -- Mirror base: hide empty folders. Also skip unpickable leaves --
        -- the base renders these in red with no Callback (invalid WB maps
        -- or similar); sighted users see them but cannot click, and for
        -- speech surfacing a silent dead end is worse than omitting.
        local isSubFolder = (v.Items ~= nil)
        local isPickableLeaf = (not isSubFolder) and v.Callback ~= nil
        local isNonEmptyFolder = isSubFolder and #v.Items > 0
        if isPickableLeaf or isNonEmptyFolder then
            local callback = v.Callback
            local name = v.Name
            local desc = v.Description
            items[#items + 1] = BaseMenuItems.Choice({
                labelText   = name,
                tooltipText = desc,
                activate    = function()
                    if callback ~= nil then callback() end
                    -- Sub-folder drill-in: announce the folder so the user
                    -- knows they moved. Leaf selection closes the screen via
                    -- OnBack and the parent handler re-announces, so skip.
                    if isSubFolder then
                        SpeechPipeline.speakInterrupt(name)
                    end
                end,
            })
            if not isSubFolder and selectionName ~= nil and name == selectionName then
                selectedIdx = #items
            end
        end
    end
    return items, selectedIdx
end

local originalView = View
function View(folder)
    originalView(folder)
    if handler ~= nil then
        local items, selectedIdx = buildItemsForFolder(folder)
        handler.setItems(items)
        -- Takes effect on the next fresh open (install's ShowHide clears
        -- _initialized on hide). On drill-in the handler stays active, so
        -- the cursor just clamps via setItems.
        handler.setInitialIndex(selectedIdx)
    end
end

handler = BaseMenu.install(ContextPtr, {
    name          = "SelectMapType",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAP_TYPE"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items         = {},
})

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

local function buildItemsForFolder(folder)
    local items = {}
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
        -- Mirror base: hide empty folders.
        if v.Items == nil or #v.Items > 0 then
            local isSubFolder = (v.Items ~= nil)
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
        end
    end
    return items
end

local originalView = View
function View(folder)
    originalView(folder)
    if handler ~= nil then
        handler.setItems(buildItemsForFolder(folder))
    end
end

handler = BaseMenu.install(ContextPtr, {
    name          = "SelectMapType",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAP_TYPE"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items         = {},
})

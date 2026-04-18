-- CustomMod accessibility wiring. Base registers its InputHandler as an
-- anonymous callback (CustomMod.lua line 50) and has no ShowHideHandler
-- at all; the mod list is populated lazily via a ContextPtr:SetUpdate
-- (line 59) that BaseMenu's TickPump overwrites. priorInput is nil and
-- the list must be seeded from onShow. The StartButton callback is
-- anonymous too (line 27) so launch is replicated below.

include("CivVAccess_FrontendCommon")

-- Replicates the body of CustomMod.lua line 27's anonymous
-- StartButton.eLClick callback.
local function startCustomMod()
    if g_ModList == nil then return end
    local entry = g_ModList[g_iSelected]
    if entry == nil then return end
    PreGame.Reset()
    local customSetupFile = Modding.GetEvaluatedFilePath(
        entry.ModID, entry.Version, entry.File)
    local filePath = customSetupFile.EvaluatedPath
    local extension = Path.GetExtension(filePath)
    local path = string.sub(filePath, 1, #filePath - #extension)
    local newContext = ContextPtr:LoadNewContext(path)
    newContext:SetHide(true)
    table.insert(g_DynamicContexts, newContext)
    UIManager:QueuePopup(newContext, PopupPriority.CustomMod)
end

local function buildItems()
    local items = {}
    if g_ModList ~= nil then
        for i, entry in ipairs(g_ModList) do
            local index = i
            items[#items + 1] = BaseMenuItems.Choice({
                labelText   = Text.key(entry.Name),
                tooltipText = entry.Description and Text.key(entry.Description) or nil,
                selectedFn  = function() return g_iSelected == index end,
                activate    = function() SetSelected(index) end,
            })
        end
    end
    items[#items + 1] = BaseMenuItems.Button({ controlName = "StartButton",
        textKey  = "TXT_KEY_LOAD_MOD",
        activate = startCustomMod })
    items[#items + 1] = BaseMenuItems.Button({ controlName = "BackButton",
        textKey  = "TXT_KEY_BACK_BUTTON",
        activate = function() OnBack() end })
    return items
end

BaseMenu.install(ContextPtr, {
    name        = "CustomMod",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CUSTOM_MOD_GAME"),
    priorInput  = BaseMenu.escOnlyInput(OnBack),
    onShow      = function(h)
        -- Base's lazy-init Update is replaced by TickPump; seed the list
        -- ourselves. SetupFileButtonList is idempotent (it rebuilds from
        -- Modding.GetActivatedModEntryPoints on every call) so running
        -- it on every show keeps the list fresh across DLC toggles.
        SetupFileButtonList()
        h.setItems(buildItems())
    end,
    items       = buildItems(),
})

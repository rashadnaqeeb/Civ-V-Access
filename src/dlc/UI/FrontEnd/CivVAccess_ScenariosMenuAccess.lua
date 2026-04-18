-- ScenariosMenu accessibility wiring. Base registers both its ShowHide
-- and its InputHandler as anonymous callbacks (ScenariosMenu.lua lines
-- 58 and 67), so there are no priorShowHide / priorInput globals to
-- forward; the base's side effects (ActivateDLC, LoadPreGameSettings,
-- SetupFileButtonList, Esc -> OnBack) are replicated below. The
-- StartButton click callback is anonymous too (line 29) so we replicate
-- that body in startScenario.
--
-- Selection is two-step: activating a scenario entry calls SetSelected(i)
-- (which updates base's details pane, gates StartButton's disabled
-- state, and lights the SelectHighlight); the user then navigates to
-- Start to launch. Keeping Start as a separate item mirrors the sighted
-- flow of browse-then-commit.

include("CivVAccess_FrontendCommon")

-- Replicates the body of ScenariosMenu.lua line 29's anonymous
-- StartButton.eLClick callback. Any base-game update that changes the
-- launch path must be mirrored here.
local function startScenario()
    if g_ScenarioList == nil then return end
    local entry = g_ScenarioList[g_iSelected]
    if entry == nil then return end
    UIManager:SetUICursor(1)
    Modding.ActivateSpecificMod(entry.ModID, entry.Version)
    local customSetupFile = Modding.GetEvaluatedFilePath(
        entry.ModID, entry.Version, entry.File)
    local filePath = customSetupFile.EvaluatedPath
    local extension = Path.GetExtension(filePath)
    local path = string.sub(filePath, 1, #filePath - #extension)
    PreGame.SetPersistSettings(false)
    PreGame.Reset()
    Events.SystemUpdateUI(SystemUpdateUIType.RestoreUI, "ScenariosMenu", path)
    UIManager:SetUICursor(0)
end

-- Replicates the body of ScenariosMenu.lua line 67's anonymous ShowHide
-- (not-hiding branch), which BaseMenu.install's SetShowHideHandler
-- overwrites. Skipping IsHotLoad paths the same as base.
local function runPriorShow()
    if not ContextPtr:IsHotLoad() then
        UIManager:SetUICursor(1)
        Modding.ActivateDLC()
        PreGame.LoadPreGameSettings()
        UIManager:SetUICursor(0)
        Events.SystemUpdateUI(SystemUpdateUIType.RestoreUI, "ScenariosMenuReset")
    end
    SetupFileButtonList()
end

local function buildItems()
    local items = {}
    if g_ScenarioList ~= nil then
        for i, entry in ipairs(g_ScenarioList) do
            local index = i
            items[#items + 1] = BaseMenuItems.Choice({
                labelText   = entry.DisplayName,
                tooltipText = entry.DisplayDescription,
                selectedFn  = function() return g_iSelected == index end,
                activate    = function() SetSelected(index) end,
            })
        end
    end
    items[#items + 1] = BaseMenuItems.Button({ controlName = "StartButton",
        textKey  = "TXT_KEY_LOAD_SCENARIO",
        activate = startScenario })
    items[#items + 1] = BaseMenuItems.Button({ controlName = "BackButton",
        textKey  = "TXT_KEY_BACK_BUTTON",
        activate = function() OnBack() end })
    return items
end

BaseMenu.install(ContextPtr, {
    name        = "ScenariosMenu",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_SCENARIOS"),
    priorInput  = BaseMenu.escOnlyInput(OnBack),
    onShow      = function(h)
        runPriorShow()
        h.setItems(buildItems())
    end,
    items       = buildItems(),
})

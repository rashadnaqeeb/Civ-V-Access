-- GameSetup Screen accessibility wiring. Flat parent menu over the
-- property buttons, checkbox, and action row. Property buttons delegate
-- to the base-file OnXxx callbacks, which toggle their inline <LuaContext>
-- child panels; those children install their own BaseMenus on top of this
-- one via their own ShowHide. Current values come from the live label
-- controls (TypeName, SizeName, etc.) so the game's existing setter
-- functions (SetMapTypeForScript, etc.) remain the single source of truth.
-- The Scenario checkbox uses an explicit activateCallback: the base
-- registers OnSenarioCheck via Controls.ScenarioCheck:RegisterCallback
-- rather than RegisterCheckHandler, so PullDownProbe cannot capture it.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

local function labelFromControl(controlName)
    return function()
        return Text.controlText(Controls[controlName], "GameSetupScreen " .. controlName) or ""
    end
end

local function civilizationLabel()
    local title = Text.controlText(Controls.Title, "GameSetupScreen Title") or ""
    local bonus = Text.controlText(Controls.BonusDescription, "GameSetupScreen BonusDescription") or ""
    if bonus ~= "" then
        return title .. ", " .. bonus
    end
    return title
end

BaseMenu.install(ContextPtr, {
    name = "GameSetupScreen",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GAME_SETUP"),
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    items = {
        BaseMenuItems.Button({
            controlName = "CivilizationButton",
            labelFn = civilizationLabel,
            activate = function()
                OnCivilization()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "EditButton",
            textKey = "TXT_KEY_EDIT_BUTTON",
            tooltipKey = "TXT_KEY_NAME_CIV_TITLE",
            activate = function()
                OnSetCivNames()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "RemoveButton",
            textKey = "TXT_KEY_CANCEL_BUTTON",
            activate = function()
                OnCancel()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "MapTypeButton",
            labelFn = labelFromControl("TypeName"),
            tooltipFn = labelFromControl("TypeHelp"),
            activate = function()
                OnMapType()
            end,
        }),
        BaseMenuItems.Checkbox({
            controlName = "ScenarioCheck",
            visibilityControlName = "LoadScenarioBox",
            textKey = "TXT_KEY_LOAD_SCENARIO",
            activateCallback = function()
                OnSenarioCheck()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "MapSizeButton",
            labelFn = labelFromControl("SizeName"),
            tooltipFn = labelFromControl("SizeHelp"),
            activate = function()
                OnMapSize()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "DifficultyButton",
            labelFn = labelFromControl("DifficultyName"),
            tooltipFn = labelFromControl("DifficultyHelp"),
            activate = function()
                OnDifficulty()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "GameSpeedButton",
            labelFn = labelFromControl("SpeedName"),
            tooltipFn = labelFromControl("SpeedHelp"),
            activate = function()
                OnSpeed()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "RandomizeButton",
            textKey = "TXT_KEY_GAME_SETUP_RANDOMIZE",
            activate = function()
                OnRandomize()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "AdvancedButton",
            textKey = "TXT_KEY_GAME_ADVANCED_SETUP",
            activate = function()
                OnAdvanced()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "BackButton",
            textKey = "TXT_KEY_BACK_BUTTON",
            activate = function()
                OnBack()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "StartButton",
            labelFn = labelFromControl("StartButton"),
            activate = function()
                OnStart()
            end,
        }),
    },
})

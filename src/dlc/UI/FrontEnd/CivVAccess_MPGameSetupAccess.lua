-- MPGameSetupScreen (Multiplayer -> Host Game) accessibility wiring.
-- Single-tab form. Static widgets (map / size / speed / era / turn mode
-- pulldowns, max turns / turn timer / scenario) are declared up front;
-- InstanceManager-backed dynamic widgets are walked at each
-- UpdateGameOptionsDisplay call and merged via setItems.
--
-- Covered dynamic families (checkbox kind only):
--   * Victory Conditions (g_VictoryCondtionsManager)
--   * Game Options        (g_GameOptionsManager)
--   * DLC Allowed         (g_DLCAllowedManager)
-- The Map Script DropDown options (g_DropDownOptionsManager) use per-entry
-- mouse-click callbacks on sub-buttons rather than RegisterSelectionCallback,
-- so FormHandler's pulldown sub-handler path cannot reach them yet. They are
-- a follow-up; the pulldown probe needs a per-entry capture to match.

include("CivVAccess_FrontendCommon")
include("CivVAccess_FormHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

local function staticItems()
    return {
        { kind = "textfield", controlName = "NameBox",
          textKey = "TXT_KEY_MULTIPLAYER_GAME_NAME" },
        { kind = "checkbox", controlName = "PrivateGameCheckbox",
          textKey = "TXT_KEY_MULTIPLAYER_HOST_PRIVATE_GAME" },
        { kind = "slider",   controlName = "MinorCivsSlider",
          labelControlName = "MinorCivsLabel",
          textKey = "TXT_KEY_AD_SETUP_CITY_STATES" },
        { kind = "pulldown", controlName = "MapTypePullDown",
          textKey = "TXT_KEY_AD_SETUP_MAP_TYPE" },
        { kind = "pulldown", controlName = "MapSizePullDown",
          textKey = "TXT_KEY_AD_SETUP_MAP_SIZE" },
        { kind = "pulldown", controlName = "GameSpeedPullDown",
          textKey = "TXT_KEY_AD_SETUP_GAME_SPEED" },
        { kind = "pulldown", controlName = "EraPull",
          textKey = "TXT_KEY_AD_SETUP_GAME_ERA" },
        { kind = "pulldown", controlName = "TurnModePull",
          textKey = "TXT_KEY_AD_SETUP_GAME_TURN_MODE" },
        { kind = "checkbox", controlName = "MaxTurnsCheck",
          textKey    = "TXT_KEY_AD_SETUP_MAX_TURNS",
          tooltipKey = "TXT_KEY_AD_SETUP_MAX_TURNS_TT" },
        { kind = "textfield", controlName = "MaxTurnsEdit",
          visibilityControlName = "MaxTurnsEditbox",
          textKey       = "TXT_KEY_CIVVACCESS_FIELD_MAX_TURNS",
          priorCallback = OnMaxTurnsEditBoxChange },
        { kind = "checkbox", controlName = "TurnTimerCheck",
          textKey    = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED",
          tooltipKey = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED_HELP" },
        { kind = "textfield", controlName = "TurnTimerEdit",
          visibilityControlName = "TurnTimerEditbox",
          textKey       = "TXT_KEY_CIVVACCESS_FIELD_TURN_TIMER",
          priorCallback = OnTurnTimerEditBoxChange },
        { kind = "checkbox", controlName = "ScenarioCheck",
          textKey = "TXT_KEY_LOAD_SCENARIO" },
    }
end

local function actionItems()
    return {
        { kind = "button",   controlName = "LoadGameButton",
          textKey    = "TXT_KEY_LOAD_GAME",
          tooltipKey = "TXT_KEY_LOAD_GAME_TT",
          activate   = function() OnLoadGame() end },
        { kind = "button",   controlName = "DefaultButton",
          textKey    = "TXT_KEY_AD_SETUP_DEFAULT",
          tooltipKey = "TXT_KEY_AD_SETUP_ADD_DEFAULT_TT",
          activate   = function() OnDefaultButton() end },
        { kind = "button",   controlName = "BackButton",
          textKey = "TXT_KEY_BACK_BUTTON",
          activate = function() OnBack() end },
        { kind = "button",   controlName = "ExitButton",
          textKey = "TXT_KEY_EXIT_BUTTON",
          activate = function() OnExitGame() end },
        { kind = "button",   controlName = "LaunchButton",
          textKey = "TXT_KEY_HOST_GAME",
          activate = function() OnStart() end },
    }
end

-- Walk an InstanceManager's currently-allocated pool and push one
-- checkbox item per instance. Label is read live from the engine's
-- TextButton so whatever the Refresh path just set on each row is what
-- the user hears.
local function appendCheckboxInstances(items, manager, labelLookup)
    if manager == nil then return end
    local list = manager.m_AllocatedInstances
    if type(list) ~= "table" then return end
    for _, inst in ipairs(list) do
        local checkbox = inst.GameOptionRoot
        if checkbox ~= nil and not checkbox:IsHidden() then
            local label
            local ok, textBtn = pcall(function() return checkbox:GetTextButton() end)
            if ok and textBtn ~= nil then
                local ok2, t = pcall(function() return textBtn:GetText() end)
                if ok2 and t ~= nil and t ~= "" then label = t end
            end
            if label == nil then
                Log.warn("MPGameSetupAccess: missing label on " .. labelLookup .. " instance")
            else
                items[#items + 1] = {
                    kind      = "checkbox",
                    control   = checkbox,
                    labelText = label,
                }
            end
        end
    end
end

local function buildItems()
    local items = staticItems()
    appendCheckboxInstances(items, g_VictoryCondtionsManager, "VictoryConditions")
    appendCheckboxInstances(items, g_GameOptionsManager,      "GameOptions")
    appendCheckboxInstances(items, g_DLCAllowedManager,       "DLCAllowed")
    for _, item in ipairs(actionItems()) do items[#items + 1] = item end
    return items
end

local handler = FormHandler.install(ContextPtr, {
    name             = "MPGameSetupScreen",
    displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MP_GAME_SETUP"),
    priorShowHide    = priorShowHide,
    priorInput       = priorInput,
    focusParkControl = "BackButton",
    items            = buildItems(),
})

-- UpdateGameOptionsDisplay is the choke point through which every stack
-- rebuild (map-script change, scenario toggle, DLC toggle, host / guest
-- transitions) passes. Wrap it once so setItems fires after each refresh.
-- IsHidden guards against re-entry from the StagingRoom path: that screen
-- shares MPGameOptions.lua and also calls UpdateGameOptionsDisplay, but
-- from its own Context, so ContextPtr:IsHidden() is true here when the
-- call originated there.
local origUpdateGameOptionsDisplay = UpdateGameOptionsDisplay
function UpdateGameOptionsDisplay(bUpdateOnly)
    origUpdateGameOptionsDisplay(bUpdateOnly)
    if ContextPtr:IsHidden() then return end
    local ok, err = pcall(function() handler.setItems(buildItems()) end)
    if not ok then
        Log.error("MPGameSetupAccess setItems after UpdateGameOptionsDisplay: "
            .. tostring(err))
    end
end

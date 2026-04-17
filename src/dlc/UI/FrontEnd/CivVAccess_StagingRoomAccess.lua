-- StagingRoom (host + guest multiplayer pre-launch lobby) accessibility
-- wiring. Two tabs: Players and Options. Players-tab per-slot rows and
-- chat are deferred to the nested-handler pass. This file covers what
-- the two flat handlers can already express:
--   * Tab switching via the engine's OnPlayersPageTab / OnOptionsPageTab
--     globals, so the user can reach the Options tab at all.
--   * Options-tab static settings widgets (map / size / speed / era /
--     turn mode / max turns / turn timer / scenario).
--   * Options-tab dynamic checkbox families (Victory Conditions,
--     Game Options, DLC Allowed) rebuilt via setItems on every
--     UpdateGameOptionsDisplay. Map-script DropDown options are deferred
--     for the same reason as MPGameSetupScreen: per-entry mouse-click
--     callbacks need a pulldown-probe extension to activate from keyboard.
--   * Common action bar (Invite / Save / Back / Exit / Launch) appended
--     to every tab so those remain reachable regardless of the active
--     tab, matching OptionsMenu's bottom-bar pattern.
--
-- The screen defaults to m_bEditOptions=false (Players tab). Until the
-- nested-handler pass lands, the Players tab carries only the common
-- action buttons and the user must Tab once to hear game settings.

include("CivVAccess_FrontendCommon")
include("CivVAccess_FormHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

local function commonActionItems()
    return {
        { kind = "button",   controlName = "InviteButton",
          textKey = "TXT_KEY_MP_INVITE_BUTTON",
          activate = function() OnInviteButton() end },
        { kind = "button",   controlName = "SaveButton",
          textKey = "TXT_KEY_SAVE_GAME",
          activate = function() OnSaveButton() end },
        { kind = "button",   controlName = "BackButton",
          textKey = "TXT_KEY_BACK_BUTTON",
          activate = function() BackButtonClick() end },
        { kind = "button",   controlName = "ExitButton",
          textKey = "TXT_KEY_EXIT_BUTTON",
          activate = function() OnExitGame() end },
        { kind = "button",   controlName = "LaunchButton",
          textKey = "TXT_KEY_MP_LAUNCH_GAME",
          activate = function() LaunchGame() end },
    }
end

local function optionsStaticItems()
    return {
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

local function appendCheckboxInstances(items, manager, labelFor)
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
                Log.warn("StagingRoomAccess: missing label on " .. labelFor .. " instance")
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

local function optionsDynamicItems()
    local items = {}
    appendCheckboxInstances(items, g_VictoryCondtionsManager, "VictoryConditions")
    appendCheckboxInstances(items, g_GameOptionsManager,      "GameOptions")
    appendCheckboxInstances(items, g_DLCAllowedManager,       "DLCAllowed")
    return items
end

local function playersTabItems()
    -- Per-slot rows (Invite / Civ / Team / SlotType / Handicap pulldowns
    -- plus Kick / Lock / Edit) are deferred to the nested-handler pass.
    -- Until then, Players tab exposes only the always-visible action bar.
    local items = {}
    for _, item in ipairs(commonActionItems()) do items[#items + 1] = item end
    return items
end

local function optionsTabItems()
    local items = optionsStaticItems()
    for _, item in ipairs(optionsDynamicItems()) do items[#items + 1] = item end
    for _, item in ipairs(commonActionItems()) do items[#items + 1] = item end
    return items
end

local OPTIONS_TAB_INDEX = 2

local handler = FormHandler.install(ContextPtr, {
    name             = "StagingRoom",
    displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_STAGING_ROOM"),
    priorShowHide    = priorShowHide,
    priorInput       = priorInput,
    focusParkControl = "BackButton",
    tabs = {
        {
            name      = "TXT_KEY_MULTIPLAYER_STAGING_ROOM_HEADER_PLAYER",
            showPanel = function() OnPlayersPageTab() end,
            items     = playersTabItems(),
        },
        {
            name      = "TXT_KEY_AD_SETUP_GAME_OPTIONS",
            showPanel = function() OnOptionsPageTab() end,
            items     = optionsTabItems(),
        },
    },
})

-- UpdateGameOptionsDisplay is MPGameOptions.lua's choke point for every
-- options-stack rebuild (map-script change, scenario toggle, DLC toggle,
-- tab switch to Options). Wrap once so we re-emit the Options tab's item
-- list after each refresh. IsHidden guards against re-entry from
-- MPGameSetupScreen's own wrapper: that screen shares this global.
local origUpdateGameOptionsDisplay = UpdateGameOptionsDisplay
function UpdateGameOptionsDisplay(bUpdateOnly)
    origUpdateGameOptionsDisplay(bUpdateOnly)
    if ContextPtr:IsHidden() then return end
    local ok, err = pcall(function() handler.setItems(optionsTabItems(), OPTIONS_TAB_INDEX) end)
    if not ok then
        Log.error("StagingRoomAccess setItems after UpdateGameOptionsDisplay: "
            .. tostring(err))
    end
end

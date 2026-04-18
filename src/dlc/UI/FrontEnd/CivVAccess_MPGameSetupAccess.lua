-- MPGameSetupScreen (Multiplayer -> Host) accessibility wiring. Same nested
-- shape as AdvancedSetup: flat leaves at the top level for each global
-- setting, plus drill-in groups for Victory Conditions, Game Options, and
-- DLC Allowed (all dynamically built by InstanceManager into per-section
-- stacks). MP has no per-slot AI panel on this screen; player slot
-- selection happens in the Staging Room after Host.
--
-- Visibility proxies handle mode-dependent hiding: the game-name /
-- private-game pair is hidden in hotseat, TurnMode is hidden in hotseat,
-- the scenario checkbox and Mods button are only visible in
-- ModMultiplayer mode, ExitButton is dedicated-server-only. The item's
-- visibilityControl gates isNavigable, so our menu silently skips over
-- hidden controls without special-casing mode in this file.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

-- Dynamic children --------------------------------------------------------
--
-- Each section iterates GameInfo (with the same filters + sort base uses
-- in MPGameOptions) in parallel with the manager's allocated instances:
-- instance[i] corresponds to the i-th row in our own iteration. Labels
-- come from the row's TXT_KEY rather than from the widget's TextButton,
-- because GetTextButton:GetText() round-trips empty on CheckBox widgets
-- in this engine.

-- Game options are filtered to hide the three Types MP builds its own UI
-- for (turn-timer toggle + simultaneous-turn toggles), then split by the
-- hotseat / multiplayer support flag base toggles between.
local EXCLUDED_GAME_OPTION_TYPES = {
    GAMEOPTION_END_TURN_TIMER_ENABLED = true,
    GAMEOPTION_SIMULTANEOUS_TURNS     = true,
    GAMEOPTION_DYNAMIC_TURNS          = true,
}

-- MP sorts by SortPriority first, then raw string compare on Name (not
-- Locale.Compare, unlike AdvancedSetup). Mirror exactly so our indices
-- match the manager's allocated-instance order.
local function mpSortOptions(options)
    table.sort(options, function(a, b)
        if a.SortPriority == b.SortPriority then
            return a.Name < b.Name
        end
        return a.SortPriority < b.SortPriority
    end)
end

local function victoryChildren()
    local items = {}
    local instances = (g_VictoryCondtionsManager
        and g_VictoryCondtionsManager.m_AllocatedInstances) or {}
    local i = 1
    for row in GameInfo.Victories() do
        local inst = instances[i]
        if inst == nil then break end
        items[#items + 1] = BaseMenuItems.Checkbox({
            control = inst.GameOptionRoot,
            textKey = row.Description,
        })
        i = i + 1
    end
    return items
end

local function gameOptionDropdownRows()
    local rows = {}
    for option in DB.Query(
            [[select * from MapScriptOptions where exists (select 1 from
              MapScriptOptionPossibleValues where FileName = MapScriptOptions.FileName
              and OptionID = MapScriptOptions.OptionID) and Hidden = 0 and
              FileName = ?]], PreGame.GetMapScript()) do
        rows[#rows + 1] = {
            Name         = Locale.ConvertTextKey(option.Name),
            Help         = option.Description and Locale.ConvertTextKey(option.Description) or nil,
            SortPriority = option.SortPriority,
        }
    end
    return rows
end

local function gameOptionCheckboxRows()
    local rows = {}
    local hotseat = PreGame.IsHotSeatGame()
    for option in GameInfo.GameOptions{Visible = 1} do
        if not EXCLUDED_GAME_OPTION_TYPES[option.Type] then
            local supported = hotseat and option.SupportsSinglePlayer
                                       or option.SupportsMultiplayer
            if supported then
                rows[#rows + 1] = {
                    Name         = Locale.ConvertTextKey(option.Description),
                    Help         = option.Help and Locale.ConvertTextKey(option.Help) or nil,
                    SortPriority = 0,
                }
            end
        end
    end
    for option in DB.Query(
            [[select * from MapScriptOptions where not exists (select 1 from
              MapScriptOptionPossibleValues where FileName = MapScriptOptions.FileName
              and OptionID = MapScriptOptions.OptionID) and Hidden = 0 and
              FileName = ?]], PreGame.GetMapScript()) do
        rows[#rows + 1] = {
            Name         = Locale.ConvertTextKey(option.Name),
            Help         = option.Description and Locale.ConvertTextKey(option.Description) or nil,
            SortPriority = option.SortPriority,
        }
    end
    return rows
end

local function gameOptionsChildren()
    local items = {}
    if g_DropDownOptionsManager ~= nil then
        local instances = g_DropDownOptionsManager.m_AllocatedInstances
        local rows      = gameOptionDropdownRows()
        mpSortOptions(rows)
        for i, opt in ipairs(rows) do
            local inst = instances[i]
            if inst == nil then break end
            items[#items + 1] = BaseMenuItems.Pulldown({
                control     = inst.OptionDropDown,
                labelText   = opt.Name,
                tooltipText = opt.Help,
            })
        end
    end
    if g_GameOptionsManager ~= nil then
        local instances = g_GameOptionsManager.m_AllocatedInstances
        local rows      = gameOptionCheckboxRows()
        mpSortOptions(rows)
        for i, opt in ipairs(rows) do
            local inst = instances[i]
            if inst == nil then break end
            items[#items + 1] = BaseMenuItems.Checkbox({
                control     = inst.GameOptionRoot,
                labelText   = opt.Name,
                tooltipText = opt.Help,
            })
        end
    end
    return items
end

local function dlcChildren()
    local items = {}
    local instances = (g_DLCAllowedManager
        and g_DLCAllowedManager.m_AllocatedInstances) or {}
    -- Base iterates DownloadableContent in SQL order, skipping rows where
    -- IsBaseContentUpgrade == 1 (those are force-allowed, not user-editable);
    -- mirror that filter to keep our indices in sync.
    local i = 1
    for row in GameInfo.DownloadableContent() do
        if row.IsBaseContentUpgrade == 0 then
            local inst = instances[i]
            if inst == nil then break end
            items[#items + 1] = BaseMenuItems.Checkbox({
                control = inst.GameOptionRoot,
                textKey = row.FriendlyNameKey,
            })
            i = i + 1
        end
    end
    return items
end

-- Top-level items ---------------------------------------------------------

local function buildItems(handler)
    local items = {
        -- Game name + privacy (hidden wholesale in hotseat via GameNameBox).
        BaseMenuItems.Textfield({ controlName = "NameBox",
            visibilityControlName = "GameNameBox",
            textKey = "TXT_KEY_CIVVACCESS_FIELD_GAME_NAME" }),
        BaseMenuItems.Checkbox({ controlName = "PrivateGameCheckbox",
            textKey = "TXT_KEY_MULTIPLAYER_HOST_PRIVATE_GAME",
            activateCallback = function() OnPrivateGame() end }),
        -- Global settings.
        BaseMenuItems.Pulldown({ controlName = "MapTypePullDown",
            textKey = "TXT_KEY_AD_SETUP_MAP_TYPE" }),
        BaseMenuItems.Pulldown({ controlName = "MapSizePullDown",
            textKey = "TXT_KEY_AD_SETUP_MAP_SIZE" }),
        BaseMenuItems.Pulldown({ controlName = "GameSpeedPullDown",
            textKey = "TXT_KEY_AD_SETUP_GAME_SPEED" }),
        BaseMenuItems.Pulldown({ controlName = "EraPull",
            textKey = "TXT_KEY_AD_SETUP_GAME_ERA" }),
        -- TurnMode visibility lives on the wrapper container (hidden in
        -- hotseat). Our Pulldown item doesn't take a visibility control
        -- directly, so proxy via a Choice wrapper -- except the simplest
        -- thing is to rely on Controls.TurnModePull's own Hidden state.
        -- The base sets SetHide on TurnModeRoot, not TurnModePull, so we
        -- gate with a visibilityControlName. Uses the Pulldown control
        -- field directly because we need the visibility proxy.
        BaseMenuItems.Pulldown({ controlName = "TurnModePull",
            textKey = "TXT_KEY_AD_SETUP_GAME_TURN_MODE",
            visibilityControlName = "TurnModeRoot" }),
        BaseMenuItems.Slider({ controlName = "MinorCivsSlider",
            labelControlName = "MinorCivsLabel",
            textKey = "TXT_KEY_AD_SETUP_CITY_STATES" }),
        BaseMenuItems.Checkbox({ controlName = "MaxTurnsCheck",
            textKey    = "TXT_KEY_AD_SETUP_MAX_TURNS",
            tooltipKey = "TXT_KEY_AD_SETUP_MAX_TURNS_TT",
            activateCallback = function() OnMaxTurnsChecked() end }),
        BaseMenuItems.Textfield({ controlName = "MaxTurnsEdit",
            visibilityControlName = "MaxTurnsEditbox",
            textKey       = "TXT_KEY_CIVVACCESS_FIELD_MAX_TURNS",
            priorCallback = OnMaxTurnsEditBoxChange }),
        BaseMenuItems.Checkbox({ controlName = "TurnTimerCheck",
            textKey    = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED",
            tooltipKey = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED_HELP",
            activateCallback = function() OnTurnTimerChecked() end }),
        BaseMenuItems.Textfield({ controlName = "TurnTimerEdit",
            visibilityControlName = "TurnTimerEditbox",
            textKey       = "TXT_KEY_CIVVACCESS_FIELD_TURN_TIMER",
            priorCallback = OnTurnTimerEditBoxChange }),
        -- Scenario checkbox (ModMultiplayer mode only; ScenarioCheck's
        -- wrapper box hides when not in mods mode). ModsButton is rendered
        -- by the base but has no click handler, so it's informational
        -- only -- skipped from the item list.
        BaseMenuItems.Checkbox({ controlName = "ScenarioCheck",
            visibilityControlName = "LoadScenarioBox",
            textKey          = "TXT_KEY_LOAD_SCENARIO",
            activateCallback = function() OnSenarioCheck() end }),
    }
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_GROUP_VICTORY_CONDITIONS",
        itemsFn = victoryChildren,
        cached  = false,
    })
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_GROUP_GAME_OPTIONS",
        itemsFn = gameOptionsChildren,
        cached  = false,
    })
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_GROUP_DLC_ALLOWED",
        itemsFn = dlcChildren,
        cached  = false,
    })
    -- Action row.
    items[#items + 1] = BaseMenuItems.Button({ controlName = "BackButton",
        textKey  = "TXT_KEY_BACK_BUTTON",
        activate = function() OnBack() end })
    items[#items + 1] = BaseMenuItems.Button({ controlName = "ExitButton",
        textKey  = "TXT_KEY_EXIT_BUTTON",
        activate = function() OnExitGame() end })
    items[#items + 1] = BaseMenuItems.Button({ controlName = "LoadGameButton",
        textKey    = "TXT_KEY_LOAD_GAME",
        tooltipKey = "TXT_KEY_LOAD_GAME_TT",
        activate   = function() OnLoadGame() end })
    items[#items + 1] = BaseMenuItems.Button({ controlName = "DefaultButton",
        textKey    = "TXT_KEY_AD_SETUP_DEFAULT",
        tooltipKey = "TXT_KEY_AD_SETUP_ADD_DEFAULT_TT",
        activate   = function() OnDefaultButton() end })
    items[#items + 1] = BaseMenuItems.Button({ controlName = "LaunchButton",
        textKey  = "TXT_KEY_HOST_GAME",
        activate = function() OnStart() end })
    return items
end

BaseMenu.install(ContextPtr, {
    name          = "MPGameSetup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MP_GAME_SETUP"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    onShow        = function(h)
        h.setItems(buildItems(h))
    end,
    items         = {
        -- Placeholder; onShow rebuilds the real list before push + announce.
        BaseMenuItems.Button({ controlName = "LaunchButton",
            textKey  = "TXT_KEY_HOST_GAME",
            activate = function() end }),
    },
})

-- Launch bar (Shift+Tab on the map) over the GameScreens registry. Drives
-- the real LaunchBar menu, GameScreens entries, and Turn's blocker text
-- through BaseMenu and InputRouter; the engine side (game options, the
-- active player's end-turn blocker, the popup event) is stubbed.

local T = require("support")
local M = {}

local WM_KEYDOWN = 256
local MOD_SHIFT = 1

local speaks, popups, options, blocker, networkMP

-- English names for the game's own screen-name keys, which the offline
-- polyfill would otherwise return as the bare key.
local GAME_NAMES = {
    TXT_KEY_ADVISORINFOPOPUP_CIVILOPEDIA = "Civilopedia",
    TXT_KEY_ECONOMIC_OVERVIEW = "Economic Overview",
    TXT_KEY_MILITARY_OVERVIEW = "Military Overview",
    TXT_KEY_DIPLOMACY_OVERVIEW = "Diplomacy Overview",
    TXT_KEY_POLICYSCREEN_SOCIAL_POLICIES_TAB = "Social Policies",
    TXT_KEY_ADVISOR_SCREEN_TECH_TREE_DISPLAY = "Tech Tree",
    TXT_KEY_POP_NOTIFICATION_LOG = "Notification Log",
    TXT_KEY_VP_TT = "Victory Progress",
    TXT_KEY_DEMOGRAPHICS = "Demographics",
    TXT_KEY_ADVISOR_COUNSEL = "Advisor Counsel",
    TXT_KEY_CULTURE_OVERVIEW = "Culture Overview",
    TXT_KEY_TRADE_ROUTE_OVERVIEW = "Trade Route Overview",
    TXT_KEY_LEAGUE_OVERVIEW = "World Congress",
    TXT_KEY_RELIGION_OVERVIEW = "Religion Overview",
    TXT_KEY_EO_TITLE = "Espionage Overview",
    TXT_KEY_CHOOSE_RESEARCH = "Choose Research",
}

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end
    UI.ShiftKeyDown = function()
        return false
    end
    UI.CtrlKeyDown = function()
        return false
    end
    UI.AltKeyDown = function()
        return false
    end
    Events.AudioPlay2DSound = function() end

    speaks, popups, options = {}, {}, {}
    blocker = EndTurnBlockingTypes.NO_ENDTURN_BLOCKING_TYPE
    networkMP = false

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        speaks[#speaks + 1] = { text = text, interrupt = interrupt }
    end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_PullDownProbe.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuHelp.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuTabs.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_Turn.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_GameScreens.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_LaunchBar.lua")
    HandlerStack._reset()
    TickPump._reset()

    Locale.ConvertTextKey = function(key)
        return GAME_NAMES[key] or key
    end
    -- Other suites replace the collation; restore plain byte order.
    Locale.Compare = function(a, b)
        if a == b then
            return 0
        end
        return a < b and -1 or 1
    end

    ButtonPopupTypes = {
        BUTTONPOPUP_ECONOMIC_OVERVIEW = 1,
        BUTTONPOPUP_MILITARY_OVERVIEW = 2,
        BUTTONPOPUP_DIPLOMATIC_OVERVIEW = 3,
        BUTTONPOPUP_CHOOSEPOLICY = 4,
        BUTTONPOPUP_TECH_TREE = 5,
        BUTTONPOPUP_NOTIFICATION_LOG = 6,
        BUTTONPOPUP_VICTORY_INFO = 7,
        BUTTONPOPUP_DEMOGRAPHICS = 8,
        BUTTONPOPUP_ADVISOR_COUNSEL = 9,
        BUTTONPOPUP_CULTURE_OVERVIEW = 10,
        BUTTONPOPUP_TRADE_ROUTE_OVERVIEW = 11,
        BUTTONPOPUP_LEAGUE_OVERVIEW = 12,
        BUTTONPOPUP_RELIGION_OVERVIEW = 13,
        BUTTONPOPUP_ESPIONAGE_OVERVIEW = 14,
    }
    Events.SerialEventGameMessagePopup = function(info)
        popups[#popups + 1] = info
    end
    GameOptionTypes = GameOptionTypes or {}
    GameOptionTypes.GAMEOPTION_NO_RELIGION = "GAMEOPTION_NO_RELIGION"
    Game.IsOption = function(name)
        return options[name] == true
    end
    Game.IsNetworkMultiPlayer = function()
        return networkMP
    end
    Game.GetNumActiveLeagues = function()
        return 0
    end
    Game.IsCustomModOption = nil
    Game.GetActivePlayer = function()
        return 0
    end
    Players[0] = {
        GetEndTurnBlockingType = function()
            return blocker
        end,
    }
end

local function press(key, mods)
    InputRouter.dispatch(key, mods or 0, WM_KEYDOWN)
end

local function labels(items)
    local out = {}
    for i, item in ipairs(items) do
        out[i] = item:announce(HandlerStack.active())
    end
    return out
end

local function indexOf(list, text)
    for i, v in ipairs(list) do
        if v == text then
            return i
        end
    end
    return nil
end

function M.test_rows_are_alphabetical_with_their_keys()
    setup()
    local rows = labels(LaunchBar.buildItems())
    T.eq(rows[1], "Advisor Counsel, F10", "alphabetical first")
    T.eq(rows[2], "Civilopedia, F1")
    T.truthy(indexOf(rows, "Tech Tree, F6"), "F-row screen listed with its key")
    T.truthy(indexOf(rows, "World Congress, Control plus L"), "mod chord listed with its key")
    T.truthy(indexOf(rows, "Settings, F12"), "mod settings listed")
    T.truthy(indexOf(rows, "Culture Overview, Control plus C") < indexOf(rows, "Demographics, F9"))
end

function M.test_screen_holding_the_blocker_comes_first_with_its_text()
    setup()
    blocker = EndTurnBlockingTypes.ENDTURN_BLOCKING_RESEARCH
    local rows = labels(LaunchBar.buildItems())
    T.eq(rows[1], "Tech Tree, F6. Choose Research")
    T.eq(rows[2], "Advisor Counsel, F10", "the rest stay alphabetical")
end

function M.test_switched_off_screens_are_left_out()
    setup()
    options.GAMEOPTION_NO_RELIGION = true
    options.GAMEOPTION_NO_ESPIONAGE = true
    options.GAMEOPTION_NO_LEAGUES = true
    local rows = labels(LaunchBar.buildItems())
    T.falsy(indexOf(rows, "Religion Overview, Control plus R"), "religion off")
    T.falsy(indexOf(rows, "Espionage Overview, Control plus E"), "espionage off")
    T.falsy(indexOf(rows, "World Congress, Control plus L"), "leagues off")
    T.falsy(indexOf(rows, "Chat, Backslash"), "single player has no chat")
end

function M.test_chat_listed_in_network_multiplayer()
    setup()
    networkMP = true
    T.truthy(indexOf(labels(LaunchBar.buildItems()), "Chat, Backslash"))
end

function M.test_enter_closes_the_bar_and_opens_the_screen()
    setup()
    blocker = EndTurnBlockingTypes.ENDTURN_BLOCKING_RESEARCH
    LaunchBar.open()
    T.eq(HandlerStack.active().name, "LaunchBar", "bar is up")
    press(Keys.VK_RETURN)
    T.eq(HandlerStack.active(), nil, "bar closed")
    T.eq(#popups, 1, "one screen opened")
    T.eq(popups[1].Type, ButtonPopupTypes.BUTTONPOPUP_TECH_TREE)
    T.eq(popups[1].Data2, -1, "plain open, not a steal-tech target")
end

function M.test_shift_tab_closes_the_bar()
    setup()
    LaunchBar.open()
    press(Keys.VK_TAB, MOD_SHIFT)
    T.eq(HandlerStack.active(), nil, "bar closed")
    T.eq(#popups, 0, "nothing opened")
    T.eq(speaks[#speaks].text, "canceled")
end

function M.test_hotkey_for_a_switched_off_screen_speaks_instead_of_opening()
    setup()
    options.GAMEOPTION_NO_RELIGION = true
    GameScreens.openFromHotkey("religion")
    T.eq(#popups, 0, "no popup fired")
    T.eq(speaks[#speaks].text, Text.key("TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"))
end

return M

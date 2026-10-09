-- Registry of the screens the player can open by hotkey from the map, with
-- the call that opens each. Two consumers: BaselineHandler's screen chords
-- open an entry by id, and the Shift+Tab launch bar lists every entry this
-- game has. Keeping the open calls here means a chord and its launch-bar
-- row can't drift apart.
--
-- Entry fields:
--   id              stable identifier (GameScreens.open / openFromHotkey)
--   nameKey         TXT_KEY naming the screen; the game's own where one exists
--   keyLabel        help key-label TXT_KEY for the screen's hotkey (resolved
--                   through KeyLayout like the help list does)
--   open            fn() opening the screen
--   available       optional fn() -> bool; false when this game has the
--                   screen switched off (religion off, no espionage, single
--                   player for chat). The launch bar leaves such screens out.
--   unavailableKey  optional TXT_KEY the hotkey speaks instead of opening
--                   when available() is false. Without one the hotkey opens
--                   regardless and the screen shows its own empty state.
--   blockers        optional set of EndTurnBlockingTypes the screen resolves;
--                   the launch bar lists a screen holding the current blocker
--                   first, with the end-turn button's text after its name.
--
-- Screens that exist only under some rulesets (the Vox Populi overviews,
-- squads) are added by GameScreens.list() when present, the same gates
-- BaselineHandler uses to register their chords.

GameScreens = {}

-- Data1 = 1 is the engine's own F-key convention: queue at InGameUtmost
-- priority, or close the screen if it is already up.
local function popup(popupType, data1, data2)
    return function()
        Events.SerialEventGameMessagePopup({
            Type = popupType,
            Data1 = data1,
            Data2 = data2,
        })
    end
end

local function optionOff(name)
    return function()
        return not Game.IsOption(name)
    end
end

local function blockerSet(...)
    local set = {}
    for _, b in ipairs({ ... }) do
        set[b] = true
    end
    return set
end

-- League Overview reads Data1 as the league ID, not a toggle flag. -1 when
-- no league exists; the screen then shows its "not founded" panel and our
-- wrapper speaks the matching no-league state.
local function openLeague()
    local leagueId = -1
    if Game.GetNumActiveLeagues() > 0 then
        for i = 0, math.max(Game.GetNumLeaguesEverFounded() - 1, 0) do
            if Game.GetLeague(i) ~= nil then
                leagueId = i
                break
            end
        end
    end
    Events.SerialEventGameMessagePopup({
        Type = ButtonPopupTypes.BUTTONPOPUP_LEAGUE_OVERVIEW,
        Data1 = leagueId,
    })
end

local function eventsEnabled()
    return Game.IsOption("GAMEOPTION_GOOD_EVENTS")
        or Game.IsOption("GAMEOPTION_NEUTRAL_EVENTS")
        or Game.IsOption("GAMEOPTION_BAD_EVENTS")
        or Game.IsOption("GAMEOPTION_TRADE_EVENTS")
        or Game.IsOption("GAMEOPTION_CIV_SPECIFIC_EVENTS")
end

local function baseEntries()
    local B = EndTurnBlockingTypes
    return {
        {
            id = "civilopedia",
            nameKey = "TXT_KEY_ADVISORINFOPOPUP_CIVILOPEDIA",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1",
            -- An empty search string opens the pedia without toggling it
            -- (the TopPanel button's call); F1's "OPEN_VIA_HOTKEY" toggles.
            open = function()
                Events.SearchForPediaEntry("")
            end,
        },
        {
            id = "economic",
            nameKey = "TXT_KEY_ECONOMIC_OVERVIEW",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_ECONOMIC_OVERVIEW, 1),
        },
        {
            id = "military",
            nameKey = "TXT_KEY_MILITARY_OVERVIEW",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_MILITARY_OVERVIEW, 1),
        },
        {
            id = "diplomacy",
            nameKey = "TXT_KEY_DIPLOMACY_OVERVIEW",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_DIPLOMATIC_OVERVIEW, 1),
        },
        {
            id = "policies",
            nameKey = "TXT_KEY_POLICYSCREEN_SOCIAL_POLICIES_TAB",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY, 1),
            blockers = blockerSet(B.ENDTURN_BLOCKING_POLICY, B.ENDTURN_BLOCKING_FREE_POLICY),
        },
        {
            id = "techTree",
            nameKey = "TXT_KEY_ADVISOR_SCREEN_TECH_TREE_DISPLAY",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6",
            -- Data2 is read as the steal-tech target player; -1 is a plain
            -- open (the DiploCorner dropdown's call).
            open = popup(ButtonPopupTypes.BUTTONPOPUP_TECH_TREE, nil, -1),
            blockers = blockerSet(B.ENDTURN_BLOCKING_RESEARCH, B.ENDTURN_BLOCKING_FREE_TECH),
        },
        {
            id = "notificationLog",
            nameKey = "TXT_KEY_POP_NOTIFICATION_LOG",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_NOTIFICATION_LOG, 1),
        },
        {
            id = "victory",
            nameKey = "TXT_KEY_VP_TT",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_VICTORY_INFO, 1),
        },
        {
            id = "demographics",
            nameKey = "TXT_KEY_DEMOGRAPHICS",
            keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_DEMOGRAPHICS, 1),
        },
        {
            id = "advisorCounsel",
            nameKey = "TXT_KEY_ADVISOR_COUNSEL",
            keyLabel = "TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_ADVISOR_COUNSEL, 1),
        },
        {
            id = "culture",
            nameKey = "TXT_KEY_CULTURE_OVERVIEW",
            keyLabel = "TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_CULTURE_OVERVIEW, 1),
            available = optionOff("GAMEOPTION_NO_CULTURE_OVERVIEW_UI"),
            unavailableKey = "TXT_KEY_CIVVACCESS_CO_DISABLED",
        },
        {
            id = "tradeRoutes",
            nameKey = "TXT_KEY_TRADE_ROUTE_OVERVIEW",
            keyLabel = "TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY",
            -- Data2 selects the landing tab (1 = your trade routes).
            open = popup(ButtonPopupTypes.BUTTONPOPUP_TRADE_ROUTE_OVERVIEW, 1, 1),
        },
        {
            id = "league",
            nameKey = "TXT_KEY_LEAGUE_OVERVIEW",
            keyLabel = "TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY",
            open = openLeague,
            available = optionOff("GAMEOPTION_NO_LEAGUES"),
            blockers = blockerSet(
                B.ENDTURN_BLOCKING_LEAGUE_CALL_FOR_PROPOSALS,
                B.ENDTURN_BLOCKING_LEAGUE_CALL_FOR_VOTES
            ),
        },
        {
            id = "religion",
            nameKey = "TXT_KEY_RELIGION_OVERVIEW",
            keyLabel = "TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_RELIGION_OVERVIEW, 1),
            available = function()
                return not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)
            end,
            unavailableKey = "TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF",
        },
        {
            id = "espionage",
            nameKey = "TXT_KEY_EO_TITLE",
            keyLabel = "TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_ESPIONAGE_OVERVIEW, 1),
            available = optionOff("GAMEOPTION_NO_ESPIONAGE"),
            unavailableKey = "TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED",
        },
        {
            id = "chat",
            nameKey = "TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL",
            keyLabel = "TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY",
            -- ChatAccess is seated in DiploCorner's env; this LuaEvent is
            -- its cross-Context bridge. Hot-seat reports false too, which
            -- is right: hot-seat has no chat.
            open = function()
                LuaEvents.CivVAccessChatToggle()
            end,
            available = function()
                return Game:IsNetworkMultiPlayer()
            end,
            unavailableKey = "TXT_KEY_CIVVACCESS_CHAT_SP_NOOP",
        },
        {
            id = "mapSettings",
            nameKey = "TXT_KEY_CIVVACCESS_SCREEN_MAP_SETTINGS",
            keyLabel = "TXT_KEY_CIVVACCESS_MAP_SETTINGS_HOTKEY_HELP_KEY",
            -- MiniMapPanelAccess owns the menu (it needs the panel's own
            -- GetMapOptions / On*Checked handlers); this is its bridge.
            open = function()
                LuaEvents.CivVAccessMapSettingsToggle()
            end,
        },
        {
            id = "settings",
            nameKey = "TXT_KEY_CIVVACCESS_SCREEN_SETTINGS",
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F12",
            open = function()
                Settings.open()
            end,
        },
    }
end

-- Community Patch DLL screens. Events is a Community Patch addin; the
-- Vassal and Corporations overviews ship with Vox Populi only, so a
-- Community-Patch-only install has no screen to open for them.
local function communityPatchEntries(entries)
    if Game.IsCustomModOption == nil then
        return
    end
    entries[#entries + 1] = {
        id = "events",
        nameKey = "TXT_KEY_EVENT_OVERVIEW",
        keyLabel = "TXT_KEY_CIVVACCESS_EVENTS_HOTKEY_HELP_KEY",
        open = popup(ButtonPopupTypes.BUTTONPOPUP_MODDER_6, 1),
        available = eventsEnabled,
        unavailableKey = "TXT_KEY_CIVVACCESS_EVENTS_DISABLED",
    }
    if Game.IsCustomModOption("BALANCE_VP") then
        entries[#entries + 1] = {
            id = "vassals",
            nameKey = "TXT_KEY_VO",
            keyLabel = "TXT_KEY_CIVVACCESS_VASSALAGE_HOTKEY_HELP_KEY",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_MODDER_11, 1),
            available = function()
                return Game.IsOption("GAMEOPTION_ENABLE_VASSALAGE")
            end,
            unavailableKey = "TXT_KEY_CIVVACCESS_VASSALAGE_DISABLED",
        }
        entries[#entries + 1] = {
            id = "corporations",
            nameKey = "TXT_KEY_CPO",
            keyLabel = "TXT_KEY_CIVVACCESS_CORPORATIONS_HOTKEY_HELP_KEY",
            open = popup(ButtonPopupTypes.BUTTONPOPUP_MODDER_5, 1),
        }
    end
    if EngineData.squadsAvailable() then
        entries[#entries + 1] = {
            id = "squads",
            nameKey = "TXT_KEY_CIVVACCESS_SQUAD_MENU_NAME",
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MENU",
            open = function()
                SquadMapMode.openMenu()
            end,
        }
    end
end

-- Every screen this ruleset has, in no particular order. Built per call so
-- game options and the active ruleset are read live.
function GameScreens.list()
    local entries = baseEntries()
    communityPatchEntries(entries)
    return entries
end

local function find(id)
    for _, entry in ipairs(GameScreens.list()) do
        if entry.id == id then
            return entry
        end
    end
    Log.error("GameScreens: no screen '" .. tostring(id) .. "'")
    return nil
end

-- Hotkey path: speak the entry's unavailable line instead of opening a
-- screen this game has switched off, so the key never goes silent.
function GameScreens.openFromHotkey(id)
    local entry = find(id)
    if entry == nil then
        return
    end
    if entry.unavailableKey ~= nil and not entry.available() then
        SpeechPipeline.speakInterrupt(Text.key(entry.unavailableKey))
        return
    end
    entry.open()
end

-- Hotkey binding fn for BaselineHandler.
function GameScreens.opener(id)
    return function()
        GameScreens.openFromHotkey(id)
    end
end

return GameScreens

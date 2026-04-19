-- GameMenu (Esc pause menu) accessibility. Three-tab BaseMenu.
--
-- ExitConfirm yes/no is an overlay inside this Context, not a separate
-- LuaContext -- clicking Main Menu toggles Controls.ExitConfirm visible
-- rather than queuing a new popup. So we push a modal sub-handler with
-- capturesAllInput on the same Context, and its tick watches
-- ExitConfirm:IsHidden() to pop itself when any other path (debug
-- hot-reload, a future base-code edit we haven't traced) dismisses it.
--
-- Details labelFns re-query on every navigate so hotseat hand-offs show
-- the new active player's handicap without rebuilding the list. Victory
-- and game-option entries are session-fixed and use labelText.
--
-- showPanel drives MainContainer / DetailsPanel / ModsPanel to absolute
-- state (the base's OnGameDetails / OnGameMods are toggles rather than
-- setters) so the sighted view follows our tab.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

local priorShowHide = OnShowHide
local priorInput    = InputHandler

local DETAILS_TAB = 2
local MODS_TAB    = 3

-- Panel visibility ------------------------------------------------------

local function showPanel(active)
    Controls.MainContainer:SetHide(active ~= Controls.MainContainer)
    Controls.DetailsPanel :SetHide(active ~= Controls.DetailsPanel)
    Controls.ModsPanel    :SetHide(active ~= Controls.ModsPanel)
end

local function showMainContainer() showPanel(Controls.MainContainer) end
local function showDetailsPanel()  showPanel(Controls.DetailsPanel)  end
local function showModsPanel()     showPanel(Controls.ModsPanel)     end

-- ExitConfirm modal ----------------------------------------------------

local function makeExitConfirmHandler()
    local function closeSub(reactivate)
        HandlerStack.removeByName("GameMenuExitConfirm", reactivate ~= false)
    end
    local function pressYes()
        local ok, err = pcall(OnYes)
        if not ok then Log.error("GameMenuAccess: OnYes failed: " .. tostring(err)) end
        -- reactivate=false: OnYes fires Events.ExitToMainMenu which tears
        -- down the session; re-announcing the parent GameMenu handler's
        -- focused item mid-teardown is garbage speech.
        closeSub(false)
    end
    local function pressNo()
        local ok, err = pcall(OnNo)
        if not ok then Log.error("GameMenuAccess: OnNo failed: " .. tostring(err)) end
        closeSub()
    end
    return {
        name             = "GameMenuExitConfirm",
        capturesAllInput = true,
        bindings = {
            { key = Keys.Y,         mods = 0, description = "Confirm",
              fn  = pressYes },
            { key = Keys.VK_RETURN, mods = 0, description = "Confirm",
              fn  = pressYes },
            { key = Keys.N,         mods = 0, description = "Cancel",
              fn  = pressNo },
            { key = Keys.VK_ESCAPE, mods = 0, description = "Cancel",
              fn  = pressNo },
        },
        -- Empty by deliberate decision: Y/N/Enter/Esc on a yes/no prompt is
        -- the screen-reader-idiomatic chord set; listing it in the help
        -- overlay is noise.
        helpEntries = {},
        onActivate = function(self)
            local text
            if Controls.Message ~= nil then
                local ok, t = pcall(function() return Controls.Message:GetText() end)
                if ok and t ~= nil and t ~= "" then text = t end
            end
            if text == nil then
                text = Text.key("TXT_KEY_MENU_RETURN_MM_WARN")
            end
            SpeechPipeline.speakInterrupt(text)
        end,
        tick = function(self)
            if Controls.ExitConfirm:IsHidden() then closeSub() end
        end,
    }
end

-- Actions tab ----------------------------------------------------------

local function mainMenuActivate()
    local ok, err = pcall(OnMainMenu)
    if not ok then
        Log.error("GameMenuAccess: OnMainMenu failed: " .. tostring(err))
        return
    end
    HandlerStack.push(makeExitConfirmHandler())
end

local function buildActionsItems()
    return {
        BaseMenuItems.Button({ controlName = "ReturnButton",
            textKey = "TXT_KEY_MENU_RETURN_TO_GAME",      activate = OnReturn }),
        BaseMenuItems.Button({ controlName = "QuickSaveButton",
            textKey = "TXT_KEY_MENU_QUICK_SAVE_BUTTON",   activate = OnQuickSave }),
        BaseMenuItems.Button({ controlName = "SaveGameButton",
            textKey = "TXT_KEY_MENU_SAVE_BUTTON",         activate = OnSave }),
        BaseMenuItems.Button({ controlName = "LoadGameButton",
            textKey = "TXT_KEY_MENU_LOAD_GAME_BUTTON",    activate = OnLoad }),
        BaseMenuItems.Button({ controlName = "OptionsButton",
            textKey = "TXT_KEY_MENU_OPTIONS_BUTTON",      activate = OnOptions }),
        BaseMenuItems.Button({ controlName = "RestartGameButton",
            textKey = "TXT_KEY_MENU_RESTART_GAME_BUTTON", activate = OnRestartGame }),
        BaseMenuItems.Button({ controlName = "RetireButton",
            textKey = "TXT_KEY_RETIRE",                   activate = OnRetire }),
        BaseMenuItems.Button({ controlName = "MainMenuButton",
            textKey = "TXT_KEY_MENU_EXIT_TO_MAIN",        activate = mainMenuActivate }),
        BaseMenuItems.Button({ controlName = "ExitGameButton",
            textKey = "TXT_KEY_MENU_EXIT_TO_WINDOWS",     activate = OnExitGame }),
    }
end

-- Details tab ----------------------------------------------------------

-- Each label helper returns nil (or "") when the game state doesn't
-- resolve to a row -- scenarios and WB-loaded maps can leave
-- PreGame.GetMapScript with no GameInfo.MapScripts match, for instance.
-- buildDetailsItems skips nil/empty so those rows don't become silent
-- navigable Text entries (BaseMenuItems.Text is always navigable).

-- Mirrors PopulateGameData's three-branch precedence: nickname in
-- network MP, PreGame slot-0 custom leader name, GameInfo fallback.
local function leaderLabel()
    local pPlayer = Players[Game.GetActivePlayer()]
    local nick    = pPlayer:GetNickName()
    if Game:IsNetworkMultiPlayer() and nick ~= "" then return nick end
    if PreGame.GetLeaderName(0) ~= "" then return PreGame.GetLeaderName(0) end
    return Locale.ConvertTextKey(GameInfo.Leaders[pPlayer:GetLeaderType()].Description)
end

local function civLabel()
    if PreGame.GetCivilizationShortDescription(0) ~= "" then
        return PreGame.GetCivilizationShortDescription(0)
    end
    local t = Players[Game.GetActivePlayer()]:GetCivilizationType()
    return Locale.ConvertTextKey(GameInfo.Civilizations[t].ShortDescription)
end

local function eraLabel()
    local era = PreGame.GetEra()
    if era == nil then return nil end
    local row = GameInfo.Eras[era]
    if row == nil then return nil end
    return Locale.ConvertTextKey("TXT_KEY_START_ERA",
        Locale.ConvertTextKey(row.Description))
end

local function mapTypeLabel()
    local fileName = PreGame.GetMapScript()
    for row in GameInfo.MapScripts() do
        if row.FileName == fileName then
            return Locale.ConvertTextKey("TXT_KEY_AD_MAP_TYPE_SETTING",
                Locale.ConvertTextKey(row.Name))
        end
    end
    return nil
end

local function mapSizeLabel()
    local info = GameInfo.Worlds[PreGame.GetWorldSize()]
    if info == nil then return nil end
    return Locale.ConvertTextKey("TXT_KEY_AD_MAP_SIZE_SETTING",
        Locale.ConvertTextKey(info.Description))
end

local function handicapLabel()
    local info = GameInfo.HandicapInfos[PreGame.GetHandicap(Game.GetActivePlayer())]
    if info == nil then return nil end
    return Locale.ConvertTextKey("TXT_KEY_AD_HANDICAP_SETTING",
        Locale.ConvertTextKey(info.Description))
end

local function speedLabel()
    local info = GameInfo.GameSpeeds[PreGame.GetGameSpeed()]
    if info == nil then return nil end
    return Locale.ConvertTextKey("TXT_KEY_AD_GAME_SPEED_SETTING",
        Locale.ConvertTextKey(info.Description))
end

local function buildDetailsItems()
    local items = {}
    local function add(text)
        if text == nil or text == "" then return end
        items[#items + 1] = BaseMenuItems.Text({ labelText = text })
    end

    add(leaderLabel())
    add(civLabel())
    add(eraLabel())
    add(mapTypeLabel())
    add(mapSizeLabel())
    add(handicapLabel())
    add(speedLabel())

    add(Locale.ConvertTextKey("TXT_KEY_VICTORYS_FORMAT"))
    for row in GameInfo.Victories() do
        if PreGame.IsVictory(row.ID) then
            add(Locale.ConvertTextKey(row.Description))
        end
    end

    local conditions = { Visible = 1 }
    if Game:IsNetworkMultiPlayer() then
        conditions.SupportsMultiplayer = 1
    else
        conditions.SupportsSinglePlayer = 1
    end
    for option in GameInfo.GameOptions(conditions) do
        local saved = PreGame.GetGameOption(option.Type)
        if saved ~= nil and saved == 1 then
            add(Locale.ConvertTextKey(option.Description))
        end
    end

    return items
end

-- Mods tab -------------------------------------------------------------

local function buildModsItems()
    local active = Modding.GetActivatedMods()
    if active == nil or #active == 0 then
        return {
            BaseMenuItems.Text({
                textKey = "TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS",
            }),
        }
    end
    local sorted = {}
    for _, v in ipairs(active) do
        local title = Modding.GetModProperty(v.ID, v.Version, "Name") or ""
        sorted[#sorted + 1] = { title = title, version = v.Version }
    end
    table.sort(sorted,
        function(a, b) return Locale.Compare(a.title, b.title) == -1 end)

    local items = {}
    for _, m in ipairs(sorted) do
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY",
                m.title, m.version),
        })
    end
    return items
end

-- Install --------------------------------------------------------------

local function wrappedShowHide(bIsHide, bIsInit)
    local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
    if not ok then
        Log.error("GameMenuAccess: priorShowHide failed: " .. tostring(err))
    end
    if bIsHide then
        HandlerStack.removeByName("GameMenuExitConfirm", false)
    end
end

BaseMenu.install(ContextPtr, {
    name          = "GameMenu",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"),
    priorShowHide = wrappedShowHide,
    priorInput    = priorInput,
    tabs = {
        {
            name      = "TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB",
            showPanel = showMainContainer,
            items     = buildActionsItems(),
        },
        {
            name       = "TXT_KEY_POPUP_GAME_DETAILS",
            showPanel  = showDetailsPanel,
            items      = { BaseMenuItems.Text({ labelText = "" }) },
            onActivate = function(h) h.setItems(buildDetailsItems(), DETAILS_TAB) end,
        },
        {
            name       = "TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB",
            showPanel  = showModsPanel,
            items      = { BaseMenuItems.Text({ labelText = "" }) },
            onActivate = function(h) h.setItems(buildModsItems(), MODS_TAB) end,
        },
    },
})

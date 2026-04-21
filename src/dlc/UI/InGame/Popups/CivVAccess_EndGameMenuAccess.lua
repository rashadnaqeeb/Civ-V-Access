-- EndGameMenu accessibility. Victory / defeat screen with a top-row panel
-- switcher (GameOver / Demographics / Ranking / Replay) and a bottom-row
-- action stack (MainMenu exit, Back for extended play, Beyond Earth store).
-- Panel switchers toggle sub-LuaContext visibility; they're wired as flat
-- Buttons without announcement -- activating one just re-renders the sighted
-- UI beneath and the item itself drops out of navigation if hidden
-- (IsHidden guards on RankingButton / ReplayButton / DemographicsButton
-- during tutorial games and on BeyondButton outside a space victory).
--
-- EndGameText holds the victory flavor line set by OnDisplay; read via
-- preamble so the user hears why the game ended on first activation.
-- MainMenuButton's text flips to "Continue" in hotseat alt-player mode;
-- we label it with the common "Exit to Main Menu" since that's the path
-- that matters on a finished game.

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

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

BaseMenu.install(ContextPtr, {
    name          = "EndGameMenu",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_END_GAME"),
    preamble      = function() return Controls.EndGameText:GetText() end,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "MainMenuButton",
            textKey     = "TXT_KEY_MENU_EXIT_TO_MAIN",
            activate    = function() OnMainMenu() end,
        }),
        BaseMenuItems.Button({
            controlName = "BackButton",
            textKey     = "TXT_KEY_EXTENDED_GAME_YES",
            activate    = function() OnBack() end,
        }),
        BaseMenuItems.Button({
            controlName = "BeyondButton",
            textKey     = "TXT_KEY_GO_BEYOND_EARTH",
            activate    = function() ShowBeyondEarthStorePage() end,
        }),
        BaseMenuItems.Button({
            controlName = "GameOverButton",
            textKey     = "TXT_KEY_VICTORY_INFO",
            activate    = function() OnGameOver() end,
        }),
        BaseMenuItems.Button({
            controlName = "DemographicsButton",
            textKey     = "TXT_KEY_DEMOGRAPHICS_TITLE",
            activate    = function() OnDemographics() end,
        }),
        BaseMenuItems.Button({
            controlName = "RankingButton",
            textKey     = "TXT_KEY_RANKING_TITLE",
            activate    = function() OnRanking() end,
        }),
        BaseMenuItems.Button({
            controlName = "ReplayButton",
            textKey     = "TXT_KEY_REPLAY_TITLE",
            activate    = function() OnReplay() end,
        }),
    },
})

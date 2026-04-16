-- OtherMenu accessibility wiring. The game's LatestNews and Civilopedia
-- handlers are anonymous closures registered inline; we duplicate their
-- one-line bodies here rather than trying to reach into local scope.
-- If the base game changes those URLs / targets the duplicate needs a
-- matching update (re-diff OtherMenu.lua after any Civ V patch).

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

SimpleListHandler.install(ContextPtr, {
    name          = "OtherMenu",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_OTHER_MENU"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        { controlName = "LatestNewsButton",  textKey = "TXT_KEY_LATEST_NEWS",
          activate    = function()
            Steam.ActivateGameOverlayToWebPage("http://store.steampowered.com/news/?appids=8930")
          end },
        { controlName = "CivilopediaButton", textKey = "TXT_KEY_CIVILOPEDIA",
          activate    = function()
            UIManager:QueuePopup(Controls.Civilopedia, PopupPriority.HallOfFame)
          end },
        { controlName = "HallOfFameButton",  textKey = "TXT_KEY_HALL_OF_FAME",
          activate    = function() HallOfFameClick() end },
        { controlName = "ViewReplaysButton", textKey = "TXT_KEY_OTHER_MENU_VIEW_REPLAYS",
          activate    = function() ViewReplaysButtonClick() end },
        { controlName = "CreditsButton",     textKey = "TXT_KEY_CREDITS",
          activate    = function() CreditsClicked() end },
        { controlName = "LeaderboardButton", textKey = "TXT_KEY_LEADERBOARD",
          activate    = function() LeaderboardClick() end },
        { controlName = "BackButton",        textKey = "TXT_KEY_MODDING_MENU_BACK",
          activate    = function() BackButtonClick() end },
    },
})

-- OtherMenu accessibility wiring. The game's LatestNews and Civilopedia
-- handlers are anonymous closures registered inline; we duplicate their
-- one-line bodies here rather than trying to reach into local scope.
-- If the base game changes those URLs / targets the duplicate needs a
-- matching update (re-diff OtherMenu.lua after any Civ V patch).

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

Menu.install(ContextPtr, {
    name          = "OtherMenu",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_OTHER_MENU"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        MenuItems.Button({ controlName = "LatestNewsButton",
            textKey    = "TXT_KEY_LATEST_NEWS",
            tooltipKey = "TXT_KEY_LATEST_NEWS_TT",
            activate   = function()
                Steam.ActivateGameOverlayToWebPage("http://store.steampowered.com/news/?appids=8930")
            end }),
        MenuItems.Button({ controlName = "CivilopediaButton",
            textKey    = "TXT_KEY_CIVILOPEDIA",
            tooltipKey = "TXT_KEY_CIVILOPEDIA_TOOLTIP",
            activate   = function()
                UIManager:QueuePopup(Controls.Civilopedia, PopupPriority.HallOfFame)
            end }),
        MenuItems.Button({ controlName = "HallOfFameButton",
            textKey    = "TXT_KEY_HALL_OF_FAME",
            tooltipKey = "TXT_KEY_HALL_OF_FAME_TT",
            activate   = function() HallOfFameClick() end }),
        MenuItems.Button({ controlName = "ViewReplaysButton",
            textKey    = "TXT_KEY_OTHER_MENU_VIEW_REPLAYS",
            tooltipKey = "TXT_KEY_OTHER_MENU_VIEW_REPLAYS_TT",
            activate   = function() ViewReplaysButtonClick() end }),
        MenuItems.Button({ controlName = "CreditsButton",
            textKey    = "TXT_KEY_CREDITS",
            tooltipKey = "TXT_KEY_CREDITS_TT",
            activate   = function() CreditsClicked() end }),
        MenuItems.Button({ controlName = "LeaderboardButton",
            textKey    = "TXT_KEY_LEADERBOARD",
            tooltipKey = "TXT_KEY_LEADERBOARD_TT",
            activate   = function() LeaderboardClick() end }),
        MenuItems.Button({ controlName = "BackButton",
            textKey  = "TXT_KEY_MODDING_MENU_BACK",
            activate = function() BackButtonClick() end }),
    },
})

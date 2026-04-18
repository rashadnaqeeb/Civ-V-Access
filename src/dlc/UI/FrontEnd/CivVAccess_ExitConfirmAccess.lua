-- ExitConfirm accessibility wiring. The game file names its handler
-- OnShowHide (not ShowHideHandler), so we capture that symbol explicitly.
-- PushModal / PopModal still fire the ShowHide handler per the game source.
--
-- Preamble reads Controls.Message after the base OnShowHide has written it:
-- the base picks TXT_KEY_MENU_RETURN_EXIT_WARN in-game (warns that progress
-- won't be saved) vs TXT_KEY_MENU_EXIT_WARN out-of-game, via a LookUpControl
-- check. priorShowHide runs before our push, so GetText returns the
-- context-correct localized message by the time onActivate resolves.

include("CivVAccess_FrontendCommon")

local priorShowHide = OnShowHide
local priorInput    = InputHandler

BaseMenu.install(ContextPtr, {
    name          = "ExitConfirm",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_EXIT_CONFIRM"),
    preamble      = function()
        local c = Controls.Message
        if c == nil then return nil end
        local ok, t = pcall(function() return c:GetText() end)
        if not ok or t == nil or t == "" then return nil end
        return t
    end,
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        BaseMenuItems.Button({ controlName = "Yes", textKey = "TXT_KEY_YES_BUTTON",
            activate = function() OnYes() end }),
        BaseMenuItems.Button({ controlName = "No",  textKey = "TXT_KEY_NO_BUTTON",
            activate = function() OnNo() end }),
    },
})

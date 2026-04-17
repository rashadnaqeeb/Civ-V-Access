-- LegalScreen accessibility wiring. The game file registers an anonymous
-- callback on ContinueButton that dequeues the popup; we duplicate that
-- one-line body here rather than trying to reach into local scope.
-- Two static text bodies (EULA + ESRB) are joined into a single preamble
-- so the user hears both before the Continue button is announced.

include("CivVAccess_FrontendCommon")

BaseMenu.install(ContextPtr, {
    name        = "LegalScreen",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LEGAL"),
    preamble    = Text.key("TXT_KEY_LEGAL_BODY") .. " " .. Text.key("TXT_KEY_ESRB_BODY"),
    items = {
        BaseMenuItems.Button({ controlName = "ContinueButton",
            textKey  = "TXT_KEY_LEGAL_CONTINUE",
            activate = function() UIManager:DequeuePopup(ContextPtr) end }),
    },
})

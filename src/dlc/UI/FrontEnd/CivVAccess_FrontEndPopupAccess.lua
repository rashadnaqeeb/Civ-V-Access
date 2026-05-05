-- FrontEndPopup accessibility wiring. The game pushes the popup and then
-- sets Controls.PopupText via Events.FrontEndPopup; a Push-then-set race
-- means our onActivate may run before the text is updated, so we also
-- refresh() on subsequent FrontEndPopup events. The Context can be
-- re-instantiated by the engine, so we stash the latest handler in
-- civvaccess_shared and keep a single listener that resolves it at fire
-- time.

include("CivVAccess_FrontendCommon")

local priorInput = InputHandler

civvaccess_shared._frontEndPopupHandler = BaseMenu.install(ContextPtr, {
    name = "FrontEndPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_FRONT_END_POPUP"),
    preamble = function()
        return Text.controlText(Controls.PopupText, "FrontEndPopupAccess")
    end,
    priorInput = priorInput,
    items = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey = "TXT_KEY_CLOSE",
            activate = function()
                OnBack()
            end,
        }),
    },
})

-- Register fresh on every include. CLAUDE.md's "no install-once guards"
-- rule applies here too: the install-once flag persists on
-- civvaccess_shared but the listener it gated is stranded with a dead
-- env after a Context re-init. The handler-stash pattern (publishing
-- the latest handler on civvaccess_shared and having the listener
-- look it up at fire time) covers handler ref staleness, but the
-- listener body's own captured upvalues (Log, pcall, Events) belong
-- to the prior Context's env. Re-registering each include keeps the
-- newest listener live; the engine's per-listener catch limits the
-- accumulation cost.
Log.installEvent(
    Events,
    "FrontEndPopup",
    Log.safeListener("FrontEndPopupAccess.refresh", function()
        local h = civvaccess_shared._frontEndPopupHandler
        if h == nil then
            return
        end
        h.refresh()
    end),
    "FrontEndPopupAccess"
)

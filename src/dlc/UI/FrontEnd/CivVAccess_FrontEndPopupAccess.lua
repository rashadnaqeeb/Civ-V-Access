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

if not civvaccess_shared._frontEndPopupRefreshInstalled then
    civvaccess_shared._frontEndPopupRefreshInstalled = true
    Events.FrontEndPopup.Add(function()
        local h = civvaccess_shared._frontEndPopupHandler
        if h == nil then
            return
        end
        local ok, err = pcall(function()
            h.refresh()
        end)
        if not ok then
            Log.error("FrontEndPopupAccess refresh: " .. tostring(err))
        end
    end)
end

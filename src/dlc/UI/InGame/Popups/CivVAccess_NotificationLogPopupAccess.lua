-- NotificationLogPopup accessibility. BUTTONPOPUP_NOTIFICATION_LOG lists
-- every notification the active player has received this game, dismissed
-- or not. Two tabs:
--   Active    notifications whose dismissed flag is false (still on the
--             right-side stack for a sighted player).
--   Dismissed notifications whose dismissed flag is true (activated,
--             right-clicked, or auto-expired by the engine).
-- Enter on an active entry calls NotificationSelected(id), which is the
-- game's own OnClose + UI.ActivateNotification path. On a dismissed entry
-- activation is a no-op: the engine disables those buttons on sighted
-- UI, and calling ActivateNotification on a stale id has undefined
-- behavior.
--
-- After NotificationSelected fires, we ask CameraTracker to wait for the
-- engine's camera pan to settle and then jump the cursor onto the look-at
-- plot. This covers every notification whose Activate() in the engine ends
-- up calling lookAt(plot) -- ruins, barbarians, war declarations, enemy in
-- territory, etc -- because the engine emits no other Lua-observable
-- signal for those. Notifications that open a popup instead of panning
-- (production, tech, diplomacy) leave the camera still; CameraTracker's
-- timeout drops the cursor jump silently in that case.
--
-- Items rebuild from Players[active]:GetNumNotifications() on every open
-- via onShow. No caching. The game's OnPopup rebuilds its own visual row
-- stack in parallel; both read from the engine's authoritative list. The
-- menu's Tab key (BaseMenu default) switches between tabs; Esc falls
-- through priorInput to the popup's own handler which dismisses.

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
include("CivVAccess_CameraTracker")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function emptyItem()
    return BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY") })
end

-- Activate a notification: fire the engine's NotificationSelected (which
-- closes the popup and runs UI.ActivateNotification), then ride the camera
-- pan to drop the cursor on whatever plot the engine landed on.
local function activateAndFollow(notificationId)
    NotificationSelected(notificationId)
    CameraTracker.followAndJumpCursor()
end

local function buildItems()
    local active = {}
    local dismissed = {}
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        Log.warn("NotificationLogPopupAccess: active player is nil")
        return { emptyItem() }, { emptyItem() }
    end
    local num = player:GetNumNotifications()
    for i = num - 1, 0, -1 do
        local text = player:GetNotificationStr(i)
        local turn = player:GetNotificationTurn(i)
        local isDismissed = player:GetNotificationDismissed(i)
        local label = Text.format("TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM", text, turn)
        if isDismissed then
            dismissed[#dismissed + 1] = BaseMenuItems.Text({ labelText = label })
        else
            local notificationId = player:GetNotificationIndex(i)
            -- Choice (not Button): per-notification entries are built per
            -- onShow from engine data with no backing Controls.X, which is
            -- exactly the case Choice was written for. Button requires a
            -- controlName / control and would fail the spec check.
            active[#active + 1] = BaseMenuItems.Choice({
                labelText = label,
                activate = function() activateAndFollow(notificationId) end,
            })
        end
    end
    if #active == 0 then active[1] = emptyItem() end
    if #dismissed == 0 then dismissed[1] = emptyItem() end
    return active, dismissed
end

local function onShow(handler)
    local active, dismissed = buildItems()
    handler.setItems(active, 1)
    handler.setItems(dismissed, 2)
end

BaseMenu.install(ContextPtr, {
    name          = "NotificationLogPopup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"),
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    onShow        = onShow,
    tabs = {
        {
            name  = "TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE",
            items = { emptyItem() },
        },
        {
            name  = "TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED",
            items = { emptyItem() },
        },
    },
})

-- NotificationLogPopup accessibility. BUTTONPOPUP_NOTIFICATION_LOG lists
-- every notification the active player has received this game, dismissed
-- or not. Three tabs:
--   Active    notifications whose dismissed flag is false (still on the
--             right-side stack for a sighted player).
--   Turn Log  mod-authored cross-turn surfaces that don't live on the
--             engine's notification list: the ForeignUnitWatch four-line
--             delta (units entered / left view during the AI turn), the
--             ForeignClearWatch line (camps and ruins others claimed in
--             view), and the CombatLog group (one entry per combat
--             announced while the player was waiting). All clear at the
--             next TurnEnd.
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
include("CivVAccess_PluralRules")
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

-- Append each line in a watcher's delta (a flat array of strings on
-- civvaccess_shared, or nil when the watcher has nothing to report this
-- turn) as a plain Text item. Producers: ForeignUnitWatch (foreignUnit-
-- Delta), ForeignClearWatch (foreignClearDelta).
local function appendDeltaLines(turnLog, delta)
    if delta == nil then
        return
    end
    for _, line in ipairs(delta) do
        turnLog[#turnLog + 1] = BaseMenuItems.Text({ labelText = line })
    end
end

local function buildItems()
    local active = {}
    local dismissed = {}
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        Log.warn("NotificationLogPopupAccess: active player is nil")
        return { emptyItem() }, { emptyItem() }, { emptyItem() }
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

    -- Turn Log tab: ForeignUnitWatch's four-line entered / left summary
    -- followed by ForeignClearWatch's foreign-claimed-camps-and-ruins line
    -- (both flat arrays of non-empty strings parked on civvaccess_shared
    -- at TurnStart and cleared at TurnEnd), followed by the Combat Log
    -- group whose children are the per-combat lines CombatLog accumulated
    -- across the AI turn. Plain Text items for the watch lines because
    -- there's no plot or popup to activate; the Combat Log group drills
    -- into the per-combat entries.
    local turnLog = {}
    appendDeltaLines(turnLog, civvaccess_shared.foreignUnitDelta)
    appendDeltaLines(turnLog, civvaccess_shared.foreignClearDelta)
    local combatChildren = {}
    local combatLog = civvaccess_shared.combatLog
    if combatLog ~= nil then
        for _, line in ipairs(combatLog) do
            combatChildren[#combatChildren + 1] = BaseMenuItems.Text({ labelText = line })
        end
    end
    if #combatChildren == 0 then
        combatChildren[1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY") })
    end
    turnLog[#turnLog + 1] = BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"),
        items = combatChildren,
    })

    return active, turnLog, dismissed
end

local function onShow(handler)
    local active, turnLog, dismissed = buildItems()
    handler.setItems(active, 1)
    handler.setItems(turnLog, 2)
    handler.setItems(dismissed, 3)
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
            name  = "TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG",
            items = { emptyItem() },
        },
        {
            name  = "TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED",
            items = { emptyItem() },
        },
    },
})

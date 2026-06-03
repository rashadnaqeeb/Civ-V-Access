-- NotificationLogPopup accessibility. BUTTONPOPUP_NOTIFICATION_LOG lists
-- every notification the active player has received this game, dismissed
-- or not. Three tabs:
--   Active    notifications whose dismissed flag is false (still on the
--             right-side stack for a sighted player).
--   Turn Log  mod-authored cross-turn surfaces that don't live on the
--             engine's notification list: ForeignUnitWatch's entered units
--             (one jump group per hostile / neutral bucket, each child
--             jumping to that unit's tile), its left-view summary lines
--             (plain text), the ForeignClearWatch line (camps and ruins
--             others claimed in view), and the CombatLog group (one jump
--             entry per combat announced while the player was waiting). All
--             clear at the next TurnEnd.
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
-- The Turn Log jump entries (entered units, combats) instead carry a plot
-- directly, so they skip the camera-pan rider: activate closes the popup and
-- drops the cursor on the plot via Cursor.jumpTo (jumpToPlot below).
--
-- Items rebuild from Players[active]:GetNumNotifications() on every open
-- via onShow. No caching. The game's OnPopup rebuilds its own visual row
-- stack in parallel; both read from the engine's authoritative list. The
-- menu's Tab key (BaseMenu default) switches between tabs; Esc falls
-- through priorInput to the popup's own handler which dismisses.

include("CivVAccess_PopupBoot")
include("CivVAccess_CameraTracker")

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

-- Close the popup and drop the hex cursor on (x, y), speaking the destination
-- tile. Used by combat entries and entered foreign-unit entries, which carry
-- a plot directly rather than going through the engine's camera-pan path.
-- Cursor lives in the InGame Context; reach it via the shared modules table.
local function jumpToPlot(x, y)
    local Cursor = civvaccess_shared.modules and civvaccess_shared.modules.Cursor
    if Cursor == nil then
        Log.warn("NotificationLogPopupAccess: Cursor module not published; cannot jump")
        return
    end
    OnClose()
    local text = Cursor.jumpTo(x, y)
    if text ~= nil and text ~= "" then
        SpeechPipeline.speakInterrupt(text)
    end
end

-- Entered-unit buckets, in the same hostile-before-neutral order the turn-
-- start speech uses. Keys match the foreignUnitEntered table ForeignUnitWatch
-- parks on civvaccess_shared.
local FOREIGN_ENTERED_BUCKETS = {
    { key = "hostile", headerKey = "TXT_KEY_CIVVACCESS_FOREIGN_ENTERED_HOSTILE_GROUP" },
    { key = "neutral", headerKey = "TXT_KEY_CIVVACCESS_FOREIGN_ENTERED_NEUTRAL_GROUP" },
}

-- "<civ adjective> <unit name>" -- the per-unit base label before any
-- duplicate-disambiguation ordinal. Text.unitWithCiv handles noun-adjective
-- locale order and the adjective-already-in-name dedup.
local function unitBaseName(meta)
    return Text.unitWithCiv(meta.civAdjKey, meta.unitDescKey, nil)
end

-- Build the per-unit child items for one entered bucket. Each meta is
-- { ownerId, unitId, civAdjKey, unitDescKey }. We re-resolve every unit live
-- here at open: present-and-visible gives a Choice that jumps to its current
-- plot; killed-or-fogged-since-it-entered gives a Choice that speaks
-- "no longer in view". Same-name units in the bucket (including the gone
-- ones, since two identical labels are ambiguous regardless) get a trailing
-- ordinal so they're tellable apart. Returns nil for an empty bucket.
local function buildEnteredChildren(metas)
    if metas == nil or #metas == 0 then
        return nil
    end
    local activeTeam = Game.GetActiveTeam()
    local nameCounts = {}
    for _, meta in ipairs(metas) do
        local name = unitBaseName(meta)
        nameCounts[name] = (nameCounts[name] or 0) + 1
    end
    local ordinals = {}
    local children = {}
    for _, meta in ipairs(metas) do
        local name = unitBaseName(meta)
        local label = name
        if nameCounts[name] > 1 then
            local n = (ordinals[name] or 0) + 1
            ordinals[name] = n
            label = Text.format("TXT_KEY_CIVVACCESS_FOREIGN_ENTERED_NUMBERED", name, n)
        end
        -- Resolve live to decide jump vs gone. The popup is modal on the
        -- player's turn, so state can't change again before the user
        -- presses Enter; resolve once here and bake the result. The owner
        -- slot can be nil (civ eliminated since the unit entered view), same
        -- guard the turn-start re-resolve uses.
        local jumpX, jumpY
        local owner = Players[meta.ownerId]
        if owner ~= nil then
            local unit = owner:GetUnitByID(meta.unitId)
            if unit ~= nil and not unit:IsInvisible(activeTeam, false) then
                local plot = unit:GetPlot()
                if plot ~= nil and plot:IsVisible(activeTeam, false) then
                    jumpX, jumpY = plot:GetX(), plot:GetY()
                end
            end
        end
        local activate
        if jumpX ~= nil then
            activate = function()
                jumpToPlot(jumpX, jumpY)
            end
        else
            activate = function()
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_FOREIGN_UNIT_GONE"))
            end
        end
        children[#children + 1] = BaseMenuItems.Choice({ labelText = label, activate = activate })
    end
    return children
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
                activate = function()
                    activateAndFollow(notificationId)
                end,
            })
        end
    end
    if #active == 0 then
        active[1] = emptyItem()
    end
    if #dismissed == 0 then
        dismissed[1] = emptyItem()
    end

    -- Turn Log tab, in turn-start speech order: ForeignUnitWatch's entered
    -- units (one jump group per non-empty bucket, each child re-resolved to a
    -- live plot), then its left-view summary lines (plain text -- a departed
    -- unit's plot is in fog, nothing to jump to), then ForeignClearWatch's
    -- foreign-claimed-camps-and-ruins line, then the Combat Log group whose
    -- children jump to each combat's tile.
    local turnLog = {}
    local entered = civvaccess_shared.foreignUnitEntered
    if entered ~= nil then
        for _, bucket in ipairs(FOREIGN_ENTERED_BUCKETS) do
            local children = buildEnteredChildren(entered[bucket.key])
            if children ~= nil then
                turnLog[#turnLog + 1] = BaseMenuItems.Group({
                    labelText = Text.key(bucket.headerKey),
                    items = children,
                })
            end
        end
    end
    appendDeltaLines(turnLog, civvaccess_shared.foreignUnitDelta)
    appendDeltaLines(turnLog, civvaccess_shared.foreignClearDelta)
    local combatChildren = {}
    local combatLog = civvaccess_shared.combatLog
    if combatLog ~= nil then
        for _, entry in ipairs(combatLog) do
            if entry.x ~= nil and entry.y ~= nil then
                local x, y = entry.x, entry.y
                combatChildren[#combatChildren + 1] = BaseMenuItems.Choice({
                    labelText = entry.text,
                    activate = function()
                        jumpToPlot(x, y)
                    end,
                })
            else
                combatChildren[#combatChildren + 1] = BaseMenuItems.Text({ labelText = entry.text })
            end
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
    name = "NotificationLogPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = onShow,
    tabs = {
        {
            name = "TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE",
            items = { emptyItem() },
        },
        {
            name = "TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG",
            items = { emptyItem() },
        },
        {
            name = "TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED",
            items = { emptyItem() },
        },
    },
})

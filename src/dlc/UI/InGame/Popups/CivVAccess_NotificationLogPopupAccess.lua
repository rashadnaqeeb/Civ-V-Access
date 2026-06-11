-- NotificationLogPopup accessibility. BUTTONPOPUP_NOTIFICATION_LOG lists
-- every notification the active player has received this game, dismissed
-- or not. Three tabs everywhere, plus a fourth on Community Patch
-- engines (see the Options section below):
--   Active    notifications whose dismissed flag is false (still on the
--             right-side stack for a sighted player).
--   Turn Log  mod-authored cross-turn surfaces that don't live on the
--             engine's notification list: ForeignUnitWatch's entered units
--             (one jump group per hostile / neutral bucket, each child
--             jumping to that unit's tile), its left-view summary lines
--             (plain text), the ForeignClearWatch line (camps and ruins
--             others claimed in view), the CombatLog group (one jump
--             entry per combat announced while the player was waiting), and
--             the Unit Moves group (one jump entry per foreign / other-human
--             move, each re-resolved to the unit's live tile). All clear at
--             the next TurnEnd.
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

local mainHandler -- forward declared; assigned by install at the bottom

local function emptyItem()
    return BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY") })
end

-- Vanilla names these NotificationSelected / OnClose; Community Patch's
-- rewrite has GoToEvent / HidePopup (promoted to globals by our vp
-- vendor recipe).
local function selectNotification(notificationId)
    if NotificationSelected ~= nil then
        NotificationSelected(notificationId)
    else
        GoToEvent(notificationId)
    end
end

local function closePopup()
    if OnClose ~= nil then
        OnClose()
    else
        HidePopup()
    end
end

-- Activate a notification: fire the engine's selection path (which closes
-- the popup and runs UI.ActivateNotification), then ride the camera pan
-- to drop the cursor on whatever plot the engine landed on.
local function activateAndFollow(notificationId)
    selectNotification(notificationId)
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
    closePopup()
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

-- The unit's current plot coords if it's still alive on a tile the active
-- team can see, else nil, nil. Shared by the entered-units and unit-moves
-- builders, which re-resolve owner / unit id live at open and differ only in
-- their fallback when the unit is gone or fogged. The owner slot can be nil
-- (civ eliminated since the entry was logged).
local function liveUnitPlot(ownerId, unitId, activeTeam)
    local owner = Players[ownerId]
    if owner == nil then
        return nil, nil
    end
    local unit = owner:GetUnitByID(unitId)
    if unit == nil or unit:IsInvisible(activeTeam, false) then
        return nil, nil
    end
    local plot = unit:GetPlot()
    if plot == nil or not plot:IsVisible(activeTeam, false) then
        return nil, nil
    end
    return plot:GetX(), plot:GetY()
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
        -- player's turn, so state can't change again before the user presses
        -- Enter; resolve once here and bake the result.
        local jumpX, jumpY = liveUnitPlot(meta.ownerId, meta.unitId, activeTeam)
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

-- Build the Unit Moves group children. Each entry is a logged move string
-- with the moved unit's owner / id and the move's destination plot. Re-resolve
-- the unit live at open: if it's still alive on a visible plot, the jump
-- follows it there; otherwise fall back to the recorded destination, always a
-- tile the player could see since only visible moves are logged. Resolve once
-- and bake -- the popup is modal on the player's turn, so state can't change
-- before the user presses Enter.
local function buildUnitMoveChildren(entries)
    local children = {}
    local activeTeam = Game.GetActiveTeam()
    for _, entry in ipairs(entries) do
        -- Follow the unit to its live tile if still visible, else fall back to
        -- the recorded destination -- always a tile the player could see,
        -- since only visible moves are logged.
        local jx, jy = liveUnitPlot(entry.ownerId, entry.unitId, activeTeam)
        if jx == nil then
            jx, jy = entry.x, entry.y
        end
        children[#children + 1] = BaseMenuItems.Choice({
            labelText = entry.text,
            activate = function()
                jumpToPlot(jx, jy)
            end,
        })
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

    local moveChildren = {}
    local moveLog = civvaccess_shared.unitMoveLog
    if moveLog ~= nil then
        moveChildren = buildUnitMoveChildren(moveLog)
    end
    if #moveChildren == 0 then
        moveChildren[1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_UNIT_MOVES_EMPTY") })
    end
    turnLog[#turnLog + 1] = BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_UNIT_MOVES_GROUP"),
        items = moveChildren,
    })

    return active, turnLog, dismissed
end

-- ===== Options tab (Community Patch engines only) =====
--
-- VP's instant yields (one-off grants from dozens of gameplay triggers)
-- each post a regular notification; CP adds per-type opt-outs stored on
-- the player in the game core and saved with the game. Only the
-- notification is suppressed -- the yield always happens. The sighted
-- popup manages them in a second view: a category filter, one checkbox
-- row per type, and turn-on-all / turn-off-all buttons applying to the
-- filtered rows. Here that becomes a fourth tab: a synthetic filter
-- dropdown (the MiniMapPanel dropdownItem pattern), the two bulk
-- actions, then a VirtualToggle per type, checked meaning the
-- notification fires. Type names and category bucketing come from the
-- vendor file's own GetInstantYieldText / GetInstantYieldKind (promoted
-- by our vp recipe), so the rows can't drift from what the screen shows.
-- The tab only exists when the engine injects the InstantYieldType enum.

local HAS_OPTIONS = InstantYieldType ~= nil

-- CP's category ids (the vendor file's IYK_* constants) and the engine
-- label keys its own view uses. Kind 6 is the vendor's skip bucket,
-- excluded from its list and ours alike; 0 means no filter.
local FILTER_ALL = 0
local KIND_SKIP = 6
local KIND_KEYS = {
    [1] = "TXT_KEY_NOTIFICATION_SETTINGS_CITY_BUTTON",
    [2] = "TXT_KEY_NOTIFICATION_SETTINGS_MILITARY_BUTTON",
    [3] = "TXT_KEY_NOTIFICATION_SETTINGS_CIVILIAN_BUTTON",
    [4] = "TXT_KEY_NOTIFICATION_SETTINGS_SPIES_BUTTON",
    [5] = "TXT_KEY_NOTIFICATION_SETTINGS_MISC_BUTTON",
}

-- Session-local view state, the analog of the vendor's filter radios:
-- which category the rows are narrowed to. UI state, not game state.
local _optsFilter = FILTER_ALL

local buildOptionsItems -- forward declared: the filter sub rebuilds the tab

local function filterName()
    if _optsFilter == FILTER_ALL then
        return Text.key("TXT_KEY_CIVVACCESS_NOTIFICATION_FILTER_ALL")
    end
    return Text.key(KIND_KEYS[_optsFilter])
end

-- The currently filtered rows, in the vendor's own order (category, then
-- raw name compare -- it sorts the same way).
local function optionRows()
    local rows = {}
    for t = 0, InstantYieldType.NUM_INSTANT_YIELD_TYPES - 1 do
        local kind = GetInstantYieldKind(t)
        if kind ~= KIND_SKIP and (_optsFilter == FILTER_ALL or kind == _optsFilter) then
            rows[#rows + 1] = { type = t, kind = kind, name = GetInstantYieldText(t) }
        end
    end
    table.sort(rows, function(a, b)
        if a.kind ~= b.kind then
            return a.kind < b.kind
        end
        return a.name < b.name
    end)
    return rows
end

local function typeEnabled(t)
    return not Players[Game.GetActivePlayer()]:IsInstantYieldNotificationDisabled(t)
end

local function setTypeEnabled(t, enabled)
    Players[Game.GetActivePlayer()]:SetInstantYieldNotificationDisabled(t, not enabled)
end

local function filterDropdownItem()
    return BaseMenuItems.Choice({
        labelFn = function()
            return Text.format(
                "TXT_KEY_CIVVACCESS_LABEL_STATE",
                Text.key("TXT_KEY_CIVVACCESS_NOTIFICATION_FILTER"),
                filterName()
            )
        end,
        activate = function()
            local subName = "NotificationLogPopup/filter"
            local function filterChoice(kindId, label)
                return BaseMenuItems.Choice({
                    labelText = label,
                    selectedFn = function()
                        return _optsFilter == kindId
                    end,
                    activate = function()
                        _optsFilter = kindId
                        -- Rebuild before the sub pops so the parent
                        -- reactivates against the narrowed list (focus
                        -- lands back on this dropdown, first item).
                        mainHandler.setItems(buildOptionsItems(), 4)
                        HandlerStack.removeByName(subName, true)
                    end,
                })
            end
            local choices = {
                filterChoice(FILTER_ALL, Text.key("TXT_KEY_CIVVACCESS_NOTIFICATION_FILTER_ALL")),
            }
            for kindId = 1, 5 do
                choices[#choices + 1] = filterChoice(kindId, Text.key(KIND_KEYS[kindId]))
            end
            HandlerStack.push(BaseMenu.create({
                name = subName,
                displayName = Text.key("TXT_KEY_CIVVACCESS_NOTIFICATION_FILTER"),
                items = choices,
                escapePops = true,
            }))
        end,
    })
end

-- Bulk enable / disable over the filtered rows, same scope as the
-- vendor's buttons (its "all" also means "all currently shown").
local function bulkItem(textKey, enabled)
    return BaseMenuItems.Choice({
        textKey = textKey,
        activate = function()
            for _, row in ipairs(optionRows()) do
                setTypeEnabled(row.type, enabled)
            end
        end,
    })
end

buildOptionsItems = function()
    local items = {
        filterDropdownItem(),
        bulkItem("TXT_KEY_NOTIFICATION_SETTINGS_TURN_ON_ALL_BUTTON", true),
        bulkItem("TXT_KEY_NOTIFICATION_SETTINGS_TURN_OFF_ALL_BUTTON", false),
    }
    for _, row in ipairs(optionRows()) do
        local t = row.type
        local label = row.name
        -- The category clause repeats the filter verbatim when narrowed;
        -- speak it only on the unfiltered list.
        if _optsFilter == FILTER_ALL then
            label = label .. ", " .. Text.key(KIND_KEYS[row.kind])
        end
        items[#items + 1] = BaseMenuItems.VirtualToggle({
            labelText = label,
            getValue = function()
                return typeEnabled(t)
            end,
            setValue = function(v)
                setTypeEnabled(t, v)
            end,
        })
    end
    return items
end

-- ===== Install =====

local function onShow(handler)
    local active, turnLog, dismissed = buildItems()
    handler.setItems(active, 1)
    handler.setItems(turnLog, 2)
    handler.setItems(dismissed, 3)
    if HAS_OPTIONS then
        handler.setItems(buildOptionsItems(), 4)
    end
end

local tabs = {
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
}
if HAS_OPTIONS then
    tabs[#tabs + 1] = {
        name = "TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_OPTIONS",
        items = { emptyItem() },
    }
end

mainHandler = BaseMenu.install(ContextPtr, {
    name = "NotificationLogPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = onShow,
    tabs = tabs,
})

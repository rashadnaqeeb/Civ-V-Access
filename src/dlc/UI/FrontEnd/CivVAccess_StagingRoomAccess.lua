-- StagingRoom accessibility wiring. Two-tab BaseMenu.
--   Players tab: LocalReadyCheck (top-level for speed), your-seat Group
--     (wraps the fixed Host-grid Controls), then one Group per populated
--     non-local slot from civvaccess_shared._stagingSlotInstances, then
--     LaunchButton (rarely visible -- host + loading-save only) and Back.
--   Game Options tab: placeholder; next round copies the MPGameSetup shape.
--
-- Slot instance access: StagingRoom.lua's m_SlotInstances is a local table.
-- Our StagingRoom.lua override appends one line that stashes the table ref
-- on civvaccess_shared, so writes by CreateSlots / RefreshPlayerList reach
-- us without us reimplementing either function.
--
-- Remote-delta announcements: on every PreGameDirty we snapshot each major
-- civ slot's (nickname, civ, team, handicap, slot status, ready, connected)
-- and speak the deltas against the previous snapshot. Skip the local player
-- on civ / team / handicap changes (they just heard themselves do it). Chat
-- messages come through Events.GameMessageChat directly; the inline announce
-- fires regardless of which tab has focus (per user instruction: auto-speak
-- remote deltas, revisit if it turns out to be too chatty).
--
-- The F2 chat panel, full Game Options tab content, and countdown
-- announcements land in a follow-up pass.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
-- Base StagingRoom InputHandler grabs focus to Controls.ChatEntry on every
-- Tab / Enter KEY_UP (to make chat input the default typing target). That
-- steals keyboard focus from our menu the instant the user activates
-- anything, so arrow keys after the first Enter press go to the edit box
-- instead of our navigation. Filter those specific messages before forwarding
-- so the engine never sees them. Leave edit-mode handling to BaseMenuInstall
-- (it already claims Enter KEY_UP while a textfield is being edited).
local basePriorInput = InputHandler
local function priorInput(msg, wp, lp)
    if msg == 257 and (wp == Keys.VK_TAB or wp == Keys.VK_RETURN) then
        return true
    end
    if basePriorInput then return basePriorInput(msg, wp, lp) end
    return false
end

local MAX_SLOTS = GameDefines.MAX_MAJOR_CIVS

-- Helpers --------------------------------------------------------------

local function safeText(getter, context)
    local ok, t = pcall(getter)
    if not ok then
        Log.warn("StagingRoomAccess safeText"
            .. (context and (" [" .. context .. "]") or "")
            .. " failed: " .. tostring(t))
        return ""
    end
    if t == nil then return "" end
    return tostring(t)
end

-- Pulldown valueFn helper: read the sibling Label control whose GetText
-- holds the selected value for team / slot-type / handicap / civ pulldowns.
-- Returns nil for empty / error so Pulldown.announce drops the value part
-- rather than speaking "Team, " with a trailing comma.
local function labelText(labelControl)
    if labelControl == nil then return nil end
    local ok, t = pcall(function() return labelControl:GetText() end)
    if not ok or t == nil or t == "" then return nil end
    return tostring(t)
end

local function civText(playerID)
    local civType = PreGame.GetCivilization(playerID)
    if civType == nil or civType < 0 then return nil end
    local row = GameInfo.Civilizations[civType]
    if row == nil then return nil end
    return Locale.ConvertTextKey(row.ShortDescription)
end

local function teamText(playerID)
    local team = PreGame.GetTeam(playerID)
    if team == nil or team < 0 then return nil end
    return Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME",
        team + 1)
end

local function handicapText(playerID)
    local h = PreGame.GetHandicap(playerID)
    if h == nil or h < 0 then return nil end
    local row = GameInfo.HandicapInfos[h]
    if row == nil then return nil end
    return Locale.ConvertTextKey(row.Description)
end

local function nickName(playerID)
    local n = PreGame.GetNickName(playerID)
    if n == nil or n == "" then return nil end
    return n
end

local SLOT_STATUS_KEY = {
    [SlotStatus.SS_OPEN]     = "TXT_KEY_SLOTTYPE_OPEN",
    [SlotStatus.SS_COMPUTER] = "TXT_KEY_SLOTTYPE_AI",
    [SlotStatus.SS_CLOSED]   = "TXT_KEY_SLOTTYPE_CLOSED",
    [SlotStatus.SS_OBSERVER] = "TXT_KEY_SLOTTYPE_OBSERVER",
    [SlotStatus.SS_TAKEN]    = "TXT_KEY_PLAYER_TYPE_HUMAN",
}

local function slotStatusText(status)
    local key = SLOT_STATUS_KEY[status]
    if key == nil then return nil end
    return Locale.ConvertTextKey(key)
end

-- Compose a one-line summary of a slot's current state. Used as the Group
-- label; the individual pulldowns live inside as drill-in children. Empty
-- and closed slots get a short form because there is nothing else to say.
local function slotSummary(playerID)
    local status = PreGame.GetSlotStatus(playerID)
    if status == SlotStatus.SS_OPEN or status == SlotStatus.SS_CLOSED then
        return slotStatusText(status) or ""
    end

    local parts = {}
    local name  = nickName(playerID)
    if name ~= nil then
        parts[#parts + 1] = name
    else
        local fallback = slotStatusText(status)
        if fallback ~= nil then parts[#parts + 1] = fallback end
    end
    local civ = civText(playerID);     if civ  then parts[#parts + 1] = civ  end
    local tm  = teamText(playerID);    if tm   then parts[#parts + 1] = tm   end
    if status == SlotStatus.SS_COMPUTER then
        local hc = handicapText(playerID)
        if hc then parts[#parts + 1] = hc end
    end
    if PreGame.IsReady(playerID) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_STAGING_READY")
    end
    if playerID == Matchmaking.GetHostID() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_STAGING_HOST")
    end
    -- Safety net: the user reported a blank leading line. If every branch
    -- above declined to add a part (unmapped status, nil nickname, random
    -- civ, no team, not ready, not host), the Group would announce as the
    -- empty string. Log once and fall back to a generic identifier so the
    -- seat is at least reachable.
    if #parts == 0 then
        Log.warn("StagingRoomAccess: empty slotSummary for playerID="
            .. tostring(playerID) .. " status=" .. tostring(status)
            .. " civ=" .. tostring(PreGame.GetCivilization(playerID))
            .. " team=" .. tostring(PreGame.GetTeam(playerID))
            .. " nick='" .. tostring(PreGame.GetNickName(playerID)) .. "'")
        return Locale.ConvertTextKey("TXT_KEY_PLAYER_TYPE_HUMAN")
    end
    return table.concat(parts, ", ")
end

-- Group children ------------------------------------------------------

-- Per-slot drill-in children. For each editable field we include both the
-- Pulldown (when the row is editable) and the host's CheckBox / Button
-- controls. isNavigable skips widgets whose control is hidden, which is how
-- the engine signals "this field is read-only in this state" -- no mode
-- special-casing needed here.
local function slotChildren(instance)
    return {
        BaseMenuItems.Pulldown({ control = instance.CivPulldown,
            textKey = "TXT_KEY_CIVVACCESS_CIVILIZATION",
            valueFn = function() return labelText(instance.CivLabel) end }),
        BaseMenuItems.Pulldown({ control = instance.TeamPulldown,
            textKey = "TXT_KEY_CIVVACCESS_TEAM",
            valueFn = function() return labelText(instance.TeamLabel) end }),
        BaseMenuItems.Pulldown({ control = instance.SlotTypePulldown,
            textKey = "TXT_KEY_CIVVACCESS_SLOT_TYPE",
            valueFn = function() return labelText(instance.SlotTypeLabel) end }),
        BaseMenuItems.Pulldown({ control = instance.HandicapPulldown,
            textKey = "TXT_KEY_AD_SETUP_HANDICAP",
            valueFn = function() return labelText(instance.HandicapLabel) end }),
        BaseMenuItems.Checkbox({ control = instance.LockCheck,
            textKey = "TXT_KEY_MP_LOCK_SLOT" }),
        BaseMenuItems.Checkbox({ control = instance.EnableCheck,
            textKey = "TXT_KEY_MP_DISABLE_SLOT" }),
        BaseMenuItems.Button({ control = instance.KickButton,
            labelText = Text.key("TXT_KEY_MP_KICK_PLAYER"),
            activate = function()
                if type(OnKickPlayer) == "function" then
                    OnKickPlayer(Mouse.eLClick, instance.playerID)
                end
            end }),
        BaseMenuItems.Button({ control = instance.SwapButton,
            labelText = Text.key("TXT_KEY_MP_SWAP_BUTTON_TT"),
            activate = function()
                if type(OnSwapPlayer) == "function" then
                    OnSwapPlayer(Mouse.eLClick, instance.playerID)
                end
            end }),
        BaseMenuItems.Button({ control = instance.EditButton,
            textKey = "TXT_KEY_EDIT_BUTTON",
            activate = function()
                if type(OnEditPlayer) == "function" then
                    OnEditPlayer(Mouse.eLClick, instance.playerID)
                end
            end }),
    }
end

-- Local-seat drill-in children. Same shape, but widgets live on the Host
-- grid as fixed Controls.X, and the kick / swap / lock / enable quartet
-- doesn't apply to yourself (LocalEditButton is hotseat-only).
local function localSeatChildren()
    return {
        BaseMenuItems.Pulldown({ controlName = "CivPulldown",
            textKey = "TXT_KEY_CIVVACCESS_CIVILIZATION",
            valueFn = function() return labelText(Controls.CivLabel) end }),
        BaseMenuItems.Pulldown({ controlName = "TeamPulldown",
            textKey = "TXT_KEY_CIVVACCESS_TEAM",
            valueFn = function() return labelText(Controls.TeamLabel) end }),
        BaseMenuItems.Pulldown({ controlName = "SlotTypePulldown",
            textKey = "TXT_KEY_CIVVACCESS_SLOT_TYPE",
            valueFn = function() return labelText(Controls.SlotTypeLabel) end }),
        BaseMenuItems.Pulldown({ controlName = "HandicapPulldown",
            textKey = "TXT_KEY_AD_SETUP_HANDICAP",
            valueFn = function() return labelText(Controls.HandicapLabel) end }),
        BaseMenuItems.Button({ controlName = "LocalEditButton",
            textKey = "TXT_KEY_EDIT_BUTTON",
            activate = function()
                if type(OnEditHost) == "function" then OnEditHost() end
            end }),
    }
end

-- Top-level items -----------------------------------------------------

local function playersItems()
    local slots = civvaccess_shared._stagingSlotInstances or {}
    local items = {}

    items[#items + 1] = BaseMenuItems.Checkbox({
        controlName = "LocalReadyCheck",
        textKey     = "TXT_KEY_MP_READY_CHECK",
    })

    local localID = Matchmaking.GetLocalID()
    items[#items + 1] = BaseMenuItems.Group({
        visibilityControlName = "Host",
        labelFn  = function() return slotSummary(localID) end,
        itemsFn  = localSeatChildren,
        cached   = false,
    })

    for i = 1, MAX_SLOTS do
        local instance = slots[i]
        if instance ~= nil then
            items[#items + 1] = BaseMenuItems.Group({
                visibilityControl = instance.Root,
                labelFn  = function() return slotSummary(instance.playerID) end,
                itemsFn  = function() return slotChildren(instance) end,
                cached   = false,
            })
        end
    end

    items[#items + 1] = BaseMenuItems.Button({ controlName = "LaunchButton",
        textKey  = "TXT_KEY_MULTIPLAYER_LAUNCH_GAME",
        activate = function() if type(LaunchGame) == "function" then LaunchGame() end end })
    items[#items + 1] = BaseMenuItems.Button({ controlName = "BackButton",
        textKey  = "TXT_KEY_BACK_BUTTON",
        activate = function()
            if type(HandleExitRequest) == "function" then HandleExitRequest() end
        end })

    return items
end

local function optionsItems()
    -- Placeholder; next pass mirrors MPGameSetup's map/speed/era/victory/
    -- game-options/DLC tree. Leaving just Back so the tab is never empty.
    return {
        BaseMenuItems.Button({ controlName = "BackButton",
            textKey  = "TXT_KEY_BACK_BUTTON",
            activate = function()
                if type(HandleExitRequest) == "function" then HandleExitRequest() end
            end }),
    }
end

-- Delta tracking ------------------------------------------------------

-- Per-playerID snapshot. _snapshot is kept on civvaccess_shared so that a
-- Context re-instantiation during the session doesn't start speaking
-- "Alice: Egypt" for state that was already true.
local function snapshotFor(playerID)
    return {
        status    = PreGame.GetSlotStatus(playerID),
        civ       = PreGame.GetCivilization(playerID),
        team      = PreGame.GetTeam(playerID),
        handicap  = PreGame.GetHandicap(playerID),
        ready     = PreGame.IsReady(playerID),
        nick      = PreGame.GetNickName(playerID),
    }
end

local function takeSnapshot()
    local snap = {}
    for pid = 0, MAX_SLOTS - 1 do
        snap[pid] = snapshotFor(pid)
    end
    civvaccess_shared._stagingSnapshot = snap
end

local function displayName(playerID, snap)
    local n = snap.nick
    if n == nil or n == "" then
        if snap.status == SlotStatus.SS_COMPUTER then
            return Locale.ConvertTextKey("TXT_KEY_SLOTTYPE_AI")
        end
        return Locale.ConvertTextKey("TXT_KEY_PLAYER_TYPE_HUMAN")
    end
    return n
end

-- Spoken-friendly delta announcer. Compare new against old, emit one short
-- line per change. Skip the local player on civ / team / handicap / ready
-- changes (they already heard themselves toggle); do announce their
-- slot-status transitions because those can come from host action.
local function announceDeltas(newSnap, oldSnap)
    if oldSnap == nil then return end
    local localID = Matchmaking.GetLocalID()
    for pid = 0, MAX_SLOTS - 1 do
        local o = oldSnap[pid]
        local n = newSnap[pid]
        if o ~= nil and n ~= nil then
            local name = displayName(pid, n)

            if o.status ~= n.status then
                local ns = slotStatusText(n.status) or ""
                SpeechPipeline.speakQueued(
                    Text.format("TXT_KEY_CIVVACCESS_STAGING_DELTA_STATUS",
                        name, ns))
            end

            if pid ~= localID then
                if o.civ ~= n.civ then
                    local ct = civText(pid)
                    if ct ~= nil then
                        SpeechPipeline.speakQueued(
                            Text.format("TXT_KEY_CIVVACCESS_STAGING_DELTA_CIV",
                                name, ct))
                    end
                end
                if o.team ~= n.team then
                    local tt = teamText(pid)
                    if tt ~= nil then
                        SpeechPipeline.speakQueued(
                            Text.format("TXT_KEY_CIVVACCESS_STAGING_DELTA_TEAM",
                                name, tt))
                    end
                end
                if o.ready ~= n.ready then
                    local key = n.ready
                        and "TXT_KEY_CIVVACCESS_STAGING_DELTA_READY"
                        or  "TXT_KEY_CIVVACCESS_STAGING_DELTA_UNREADY"
                    SpeechPipeline.speakQueued(Text.format(key, name))
                end
                if o.handicap ~= n.handicap then
                    local hc = handicapText(pid)
                    if hc ~= nil then
                        SpeechPipeline.speakQueued(
                            Text.format("TXT_KEY_CIVVACCESS_STAGING_DELTA_HANDICAP",
                                name, hc))
                    end
                end
            end
        end
    end
end

-- Event listeners -----------------------------------------------------

local handler

local function refreshMenu()
    if handler == nil then return end
    if ContextPtr:IsHidden() then return end
    -- Regenerate the Players tab so the slot Group list reflects the latest
    -- occupied-slot set. Group labels are labelFn-based and re-resolve on
    -- every navigate, so options already visible also pick up changes.
    handler.setItems(playersItems(), 1)
end

local function onPreGameDirty()
    if ContextPtr:IsHidden() then return end
    Log.info("StagingRoomAccess: onPreGameDirty fired")
    local old = civvaccess_shared._stagingSnapshot
    local new = {}
    for pid = 0, MAX_SLOTS - 1 do new[pid] = snapshotFor(pid) end
    announceDeltas(new, old)
    civvaccess_shared._stagingSnapshot = new
    refreshMenu()
    Log.info("StagingRoomAccess: onPreGameDirty done")
end

local function onChat(fromPlayer, toPlayer, text, eTargetType)
    if ContextPtr:IsHidden() then return end
    if text == nil or text == "" then return end
    local n = PreGame.GetNickName(fromPlayer)
    if n == nil or n == "" then n = Locale.ConvertTextKey("TXT_KEY_PLAYER_TYPE_HUMAN") end
    SpeechPipeline.speakQueued(
        Text.format("TXT_KEY_CIVVACCESS_STAGING_CHAT_MSG", n, text))
end

local function onHostMigration()
    if ContextPtr:IsHidden() then return end
    local hostID = Matchmaking.GetHostID()
    local n = PreGame.GetNickName(hostID)
    if n == nil or n == "" then n = Locale.ConvertTextKey("TXT_KEY_PLAYER_TYPE_HUMAN") end
    SpeechPipeline.speakQueued(
        Text.format("TXT_KEY_CIVVACCESS_STAGING_HOST_MIGRATION", n))
end

local function onDisconnect(playerID)
    if ContextPtr:IsHidden() then return end
    if playerID == nil then return end
    local n = PreGame.GetNickName(playerID)
    if n == nil or n == "" then n = Locale.ConvertTextKey("TXT_KEY_PLAYER_TYPE_HUMAN") end
    SpeechPipeline.speakQueued(
        Text.format("TXT_KEY_CIVVACCESS_STAGING_DISCONNECT", n))
end

-- Listener installation is idempotent across Context resets via a shared
-- flag. Engine .Add() chains rather than replaces, so repeated includes
-- would stack listeners without this guard.
local function installListeners()
    if civvaccess_shared._stagingListenersInstalled then return end
    civvaccess_shared._stagingListenersInstalled = true
    Events.PreGameDirty.Add(onPreGameDirty)
    Events.GameMessageChat.Add(onChat)
    Events.MultiplayerGameHostMigration.Add(onHostMigration)
    Events.MultiplayerGamePlayerDisconnected.Add(onDisconnect)
end

-- Install -------------------------------------------------------------

local function wrappedShowHide(bIsHide, bIsInit)
    Log.info("StagingRoomAccess: wrappedShowHide hide=" .. tostring(bIsHide)
        .. " init=" .. tostring(bIsInit))
    local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
    if not ok then
        Log.error("StagingRoomAccess: priorShowHide failed: " .. tostring(err))
    end
    Log.info("StagingRoomAccess: priorShowHide returned")
    if bIsHide then return end
    installListeners()
    Log.info("StagingRoomAccess: installListeners returned")
    -- Base ShowHideHandler ran CreateSlots on first init and RefreshPlayerList
    -- every show, so the shared slot table is populated by the time we build
    -- items here.
    takeSnapshot()
    Log.info("StagingRoomAccess: takeSnapshot returned")
end

handler = BaseMenu.install(ContextPtr, {
    name          = "StagingRoom",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_STAGING_ROOM"),
    priorShowHide = wrappedShowHide,
    priorInput    = priorInput,
    onShow        = function(h)
        Log.info("StagingRoomAccess: onShow entered")
        local items = playersItems()
        Log.info("StagingRoomAccess: playersItems built " .. #items .. " entries")
        h.setItems(items, 1)
        Log.info("StagingRoomAccess: setItems returned")
    end,
    tabs = {
        {
            name  = "TXT_KEY_CIVVACCESS_STAGING_PLAYERS_TAB",
            items = {
                -- Placeholder; onShow replaces with the real list before
                -- the first announce.
                BaseMenuItems.Button({ controlName = "BackButton",
                    textKey  = "TXT_KEY_BACK_BUTTON",
                    activate = function() end }),
            },
        },
        {
            name  = "TXT_KEY_CIVVACCESS_STAGING_OPTIONS_TAB",
            items = optionsItems(),
        },
    },
})

-- StagingRoom accessibility wiring. Two-tab BaseMenu.
--   Players tab: LocalReadyCheck (top-level for speed), your-seat Group
--     (wraps the fixed Host-grid Controls), then one Group per populated
--     non-local slot from civvaccess_shared._stagingSlotInstances, then
--     LaunchButton (rarely visible -- host + loading-save only) and Back.
--   Game Options tab: map / size / speed / era / turn-mode pulldowns,
--     minor-civs slider, max-turns + turn-timer checkbox-edit pairs,
--     scenario check, and Groups for Victory Conditions / Game Options /
--     DLC Allowed built off the same InstanceManager m_AllocatedInstances
--     tables MPGameSetup uses (identical because both include MPGameOptions).
--
-- Tab showPanel calls base's OnPlayersPageTab / OnOptionsPageTab so the
-- visual panels flip with our tab. OnOptionsPageTab also triggers
-- UpdateGameOptionsDisplay which populates the manager instances; our tab
-- onActivate then rebuilds items so the Options list reflects the fresh
-- allocation. Before first Options flip the manager tables are empty, so
-- rebuild must be lazy.
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
-- is suppressed only while the F2 chat panel is the active handler (so the
-- user's focus there isn't stepped on).
--
-- Countdown: base's StartCountdown / StopCountdown are wrapped so the access
-- layer can announce "launching in ten" at start, a per-second count for the
-- last five seconds, and "countdown cancelled" on early stop. The threshold
-- and format match g_fCountdownTimer's base-game constants.
--
-- F2 chat panel: separate pushed BaseMenu with Messages (history) and
-- Compose (ChatEntry Textfield) tabs. History buffer lives on
-- civvaccess_shared so late-opened panels show messages received while
-- closed. Inline chat speech backs off when the panel is the active
-- handler so the user's context isn't stepped on.

include("CivVAccess_FrontendCommon")
include("CivVAccess_CivDetails")
include("CivVAccess_MPGameSetupShared")

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
    if basePriorInput then
        return basePriorInput(msg, wp, lp)
    end
    return false
end

local MAX_SLOTS = GameDefines.MAX_MAJOR_CIVS

-- Helpers --------------------------------------------------------------

-- Pulldown valueFn helper: read the sibling Label control whose GetText
-- holds the selected value for team / slot-type / handicap / civ pulldowns.
-- Returns nil for empty / error so Pulldown.announce drops the value part
-- rather than speaking "Team, " with a trailing comma.
local function labelText(labelControl)
    if labelControl == nil then
        return nil
    end
    local ok, t = pcall(function()
        return labelControl:GetText()
    end)
    if not ok or t == nil or t == "" then
        return nil
    end
    return tostring(t)
end

-- Rich civ labels for the civ pulldown's sub-menu entries, identifying each
-- entry by its civilization ID (SetVoids places civID at Void2; Random uses
-- civID == -1). Cached at first access because DB.Query results don't change
-- across a session (DLC / mods toggles rebuild the Context, which reloads
-- this chunk and clears the cache).
local _civRichByID
local function civRichLabelForID(civID)
    if civID == nil or civID == -1 then
        return Text.key("TXT_KEY_RANDOM_LEADER") .. ", " .. Text.key("TXT_KEY_RANDOM_CIV")
    end
    if _civRichByID == nil then
        _civRichByID = {}
        local sql = [[SELECT
            Civilizations.ID,
            Civilizations.Type,
            Civilizations.ShortDescription,
            Leaders.Type AS LeaderType,
            Leaders.Description AS LeaderDescription
            FROM Civilizations, Leaders, Civilization_Leaders WHERE
            Civilizations.Type = Civilization_Leaders.CivilizationType AND
            Leaders.Type = Civilization_Leaders.LeaderheadType AND
            Civilizations.Playable = 1]]
        for row in DB.Query(sql) do
            _civRichByID[row.ID] = CivDetails.richLabel(row)
        end
    end
    return _civRichByID[civID]
end

-- entryAnnounceFn contract: (inst, index) -> string. inst.Button carries
-- the civID as Void2 (set by PopulateCivPulldown in base), so the rich
-- label is keyed by that, not by pulldown position. Position differs
-- between AdvancedSetup and StagingRoom sort orders (Leader-only vs
-- Leader+Civ), so keying by civID keeps us aligned with the actual
-- selected civ regardless of sort.
local function civEntryAnnounce(inst)
    return civRichLabelForID(inst.Button:GetVoid2())
end

local function civText(playerID)
    local civType = PreGame.GetCivilization(playerID)
    if civType == nil or civType < 0 then
        return nil
    end
    local row = GameInfo.Civilizations[civType]
    if row == nil then
        return nil
    end
    return Text.key(row.ShortDescription)
end

local function teamText(playerID)
    local team = PreGame.GetTeam(playerID)
    if team == nil or team < 0 then
        return nil
    end
    return Text.format("TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME", team + 1)
end

local function handicapText(playerID)
    local h = PreGame.GetHandicap(playerID)
    if h == nil or h < 0 then
        return nil
    end
    local row = GameInfo.HandicapInfos[h]
    if row == nil then
        return nil
    end
    return Text.key(row.Description)
end

local function nickName(playerID)
    local n = PreGame.GetNickName(playerID)
    if n == nil or n == "" then
        return nil
    end
    return n
end

local SLOT_STATUS_KEY = {
    [SlotStatus.SS_OPEN] = "TXT_KEY_SLOTTYPE_OPEN",
    [SlotStatus.SS_COMPUTER] = "TXT_KEY_SLOTTYPE_AI",
    [SlotStatus.SS_CLOSED] = "TXT_KEY_SLOTTYPE_CLOSED",
    [SlotStatus.SS_OBSERVER] = "TXT_KEY_SLOTTYPE_OBSERVER",
    [SlotStatus.SS_TAKEN] = "TXT_KEY_PLAYER_TYPE_HUMAN",
}

local function slotStatusText(status)
    local key = SLOT_STATUS_KEY[status]
    if key == nil then
        return nil
    end
    return Text.key(key)
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
    local name = nickName(playerID)
    if name ~= nil then
        parts[#parts + 1] = name
    else
        local fallback = slotStatusText(status)
        if fallback ~= nil then
            parts[#parts + 1] = fallback
        end
    end
    local civ = civText(playerID)
    if civ then
        parts[#parts + 1] = civ
    end
    local tm = teamText(playerID)
    if tm then
        parts[#parts + 1] = tm
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
        Log.warn(
            "StagingRoomAccess: empty slotSummary for playerID="
                .. tostring(playerID)
                .. " status="
                .. tostring(status)
                .. " civ="
                .. tostring(PreGame.GetCivilization(playerID))
                .. " team="
                .. tostring(PreGame.GetTeam(playerID))
                .. " nick='"
                .. tostring(PreGame.GetNickName(playerID))
                .. "'"
        )
        return Text.key("TXT_KEY_PLAYER_TYPE_HUMAN")
    end
    return table.concat(parts, ", ")
end

-- Group children ------------------------------------------------------

-- Per-slot drill-in children. For each editable field we include both the
-- Pulldown (when the row is editable) and the host's CheckBox / Button
-- controls. isNavigable skips widgets whose control is hidden, which is how
-- the engine signals "this field is read-only in this state" -- no mode
-- special-casing needed here.
--
-- slotIndex is the 1-based m_SlotInstances key -- what base's OnKickPlayer /
-- OnSwapPlayer / OnEditPlayer expect as selectionIndex. They resolve it to
-- a playerID via GetPlayerIDBySelectionIndex; passing the playerID directly
-- would hit the 0 == local-player branch and misfire on the caller.
local function slotChildren(slotIndex, instance)
    return {
        BaseMenuItems.Pulldown({
            control = instance.CivPulldown,
            textKey = "TXT_KEY_CIVVACCESS_CIVILIZATION",
            valueFn = function()
                return labelText(instance.CivLabel)
            end,
            entryAnnounceFn = civEntryAnnounce,
        }),
        BaseMenuItems.Pulldown({
            control = instance.TeamPulldown,
            textKey = "TXT_KEY_CIVVACCESS_TEAM",
            valueFn = function()
                return labelText(instance.TeamLabel)
            end,
        }),
        BaseMenuItems.Pulldown({
            control = instance.SlotTypePulldown,
            textKey = "TXT_KEY_CIVVACCESS_SLOT_TYPE",
            valueFn = function()
                return labelText(instance.SlotTypeLabel)
            end,
        }),
        BaseMenuItems.Pulldown({
            control = instance.HandicapPulldown,
            textKey = "TXT_KEY_AD_SETUP_HANDICAP",
            valueFn = function()
                return labelText(instance.HandicapLabel)
            end,
        }),
        BaseMenuItems.Checkbox({ control = instance.LockCheck, textKey = "TXT_KEY_MP_LOCK_SLOT" }),
        BaseMenuItems.Checkbox({ control = instance.EnableCheck, textKey = "TXT_KEY_MP_DISABLE_SLOT" }),
        BaseMenuItems.Button({
            control = instance.KickButton,
            labelText = Text.key("TXT_KEY_MP_KICK_PLAYER"),
            activate = function()
                if type(OnKickPlayer) == "function" then
                    OnKickPlayer(slotIndex)
                end
            end,
        }),
        BaseMenuItems.Button({
            control = instance.SwapButton,
            labelText = Text.key("TXT_KEY_MP_SWAP_BUTTON_TT"),
            activate = function()
                if type(OnSwapPlayer) == "function" then
                    OnSwapPlayer(slotIndex)
                end
            end,
        }),
        BaseMenuItems.Button({
            control = instance.EditButton,
            textKey = "TXT_KEY_EDIT_BUTTON",
            activate = function()
                if type(OnEditPlayer) == "function" then
                    OnEditPlayer(slotIndex)
                end
            end,
        }),
    }
end

-- Local-seat drill-in children. Same shape, but widgets live on the Host
-- grid as fixed Controls.X, and the kick / swap / lock / enable quartet
-- doesn't apply to yourself (LocalEditButton is hotseat-only).
local function localSeatChildren()
    return {
        BaseMenuItems.Pulldown({
            controlName = "CivPulldown",
            textKey = "TXT_KEY_CIVVACCESS_CIVILIZATION",
            valueFn = function()
                return labelText(Controls.CivLabel)
            end,
            entryAnnounceFn = civEntryAnnounce,
        }),
        BaseMenuItems.Pulldown({
            controlName = "TeamPulldown",
            textKey = "TXT_KEY_CIVVACCESS_TEAM",
            valueFn = function()
                return labelText(Controls.TeamLabel)
            end,
        }),
        BaseMenuItems.Pulldown({
            controlName = "SlotTypePulldown",
            textKey = "TXT_KEY_CIVVACCESS_SLOT_TYPE",
            valueFn = function()
                return labelText(Controls.SlotTypeLabel)
            end,
        }),
        BaseMenuItems.Pulldown({
            controlName = "HandicapPulldown",
            textKey = "TXT_KEY_AD_SETUP_HANDICAP",
            valueFn = function()
                return labelText(Controls.HandicapLabel)
            end,
        }),
        BaseMenuItems.Button({
            controlName = "LocalEditButton",
            textKey = "TXT_KEY_EDIT_BUTTON",
            activate = function()
                if type(OnEditHost) == "function" then
                    OnEditHost()
                end
            end,
        }),
    }
end

local mapTypeEntryAnnounce = MPGameSetupShared.mapTypeEntryAnnounce
local victoryChildren = MPGameSetupShared.victoryChildren
local gameOptionsChildren = MPGameSetupShared.gameOptionsChildren
local dlcChildren = MPGameSetupShared.dlcChildren

-- Top-level items -----------------------------------------------------

local function playersItems()
    local slots = civvaccess_shared._stagingSlotInstances or {}
    local items = {}

    items[#items + 1] = BaseMenuItems.Checkbox({
        controlName = "LocalReadyCheck",
        textKey = "TXT_KEY_MP_READY_CHECK",
    })

    local localID = Matchmaking.GetLocalID()
    items[#items + 1] = BaseMenuItems.Group({
        visibilityControlName = "Host",
        labelFn = function()
            return slotSummary(localID)
        end,
        itemsFn = localSeatChildren,
        cached = false,
    })

    for i = 1, MAX_SLOTS do
        local slotIndex = i
        local instance = slots[slotIndex]
        if instance ~= nil then
            items[#items + 1] = BaseMenuItems.Group({
                visibilityControl = instance.Root,
                labelFn = function()
                    return slotSummary(instance.playerID)
                end,
                itemsFn = function()
                    return slotChildren(slotIndex, instance)
                end,
                cached = false,
            })
        end
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "LaunchButton",
        textKey = "TXT_KEY_MULTIPLAYER_LAUNCH_GAME",
        activate = function()
            if type(LaunchGame) == "function" then
                LaunchGame()
            end
        end,
    })
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "BackButton",
        textKey = "TXT_KEY_BACK_BUTTON",
        activate = function()
            if type(HandleExitRequest) == "function" then
                HandleExitRequest()
            end
        end,
    })

    return items
end

local function optionsItems()
    local items = {
        BaseMenuItems.Pulldown({
            controlName = "MapTypePullDown",
            textKey = "TXT_KEY_AD_SETUP_MAP_TYPE",
            entryAnnounceFn = mapTypeEntryAnnounce,
        }),
        BaseMenuItems.Pulldown({ controlName = "MapSizePullDown", textKey = "TXT_KEY_AD_SETUP_MAP_SIZE" }),
        BaseMenuItems.Pulldown({
            controlName = "GameSpeedPullDown",
            textKey = "TXT_KEY_AD_SETUP_GAME_SPEED",
        }),
        BaseMenuItems.Pulldown({ controlName = "EraPull", textKey = "TXT_KEY_AD_SETUP_GAME_ERA" }),
        -- TurnModeRoot hides the wrapper container in hotseat; the Pulldown
        -- item checks the wrapper via visibilityControlName so isNavigable
        -- skips it when appropriate.
        BaseMenuItems.Pulldown({
            controlName = "TurnModePull",
            textKey = "TXT_KEY_AD_SETUP_GAME_TURN_MODE",
            visibilityControlName = "TurnModeRoot",
        }),
        BaseMenuItems.Slider({
            controlName = "MinorCivsSlider",
            labelControlName = "MinorCivsLabel",
            textKey = "TXT_KEY_AD_SETUP_CITY_STATES",
        }),
        BaseMenuItems.Checkbox({
            controlName = "MaxTurnsCheck",
            textKey = "TXT_KEY_AD_SETUP_MAX_TURNS",
            tooltipKey = "TXT_KEY_AD_SETUP_MAX_TURNS_TT",
            activateCallback = function()
                OnMaxTurnsChecked()
            end,
        }),
        BaseMenuItems.Textfield({
            controlName = "MaxTurnsEdit",
            visibilityControlName = "MaxTurnsEditbox",
            textKey = "TXT_KEY_CIVVACCESS_FIELD_MAX_TURNS",
            priorCallback = OnMaxTurnsEditBoxChange,
        }),
        BaseMenuItems.Checkbox({
            controlName = "TurnTimerCheck",
            textKey = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED",
            tooltipKey = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED_HELP",
            activateCallback = function()
                OnTurnTimerChecked()
            end,
        }),
        BaseMenuItems.Textfield({
            controlName = "TurnTimerEdit",
            visibilityControlName = "TurnTimerEditbox",
            textKey = "TXT_KEY_CIVVACCESS_FIELD_TURN_TIMER",
            priorCallback = OnTurnTimerEditBoxChange,
        }),
        -- ModMultiplayerSelectScreen-only; LoadScenarioBox gates visibility.
        BaseMenuItems.Checkbox({
            controlName = "ScenarioCheck",
            visibilityControlName = "LoadScenarioBox",
            textKey = "TXT_KEY_LOAD_SCENARIO",
            activateCallback = function()
                OnSenarioCheck()
            end,
        }),
    }
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_GROUP_VICTORY_CONDITIONS",
        itemsFn = victoryChildren,
        cached = false,
    })
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_GROUP_GAME_OPTIONS",
        itemsFn = gameOptionsChildren,
        cached = false,
    })
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_GROUP_DLC_ALLOWED",
        itemsFn = dlcChildren,
        cached = false,
    })
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "BackButton",
        textKey = "TXT_KEY_BACK_BUTTON",
        activate = function()
            if type(HandleExitRequest) == "function" then
                HandleExitRequest()
            end
        end,
    })
    return items
end

-- Delta tracking ------------------------------------------------------

-- Per-playerID snapshot. _snapshot is kept on civvaccess_shared so that a
-- Context re-instantiation during the session doesn't start speaking
-- "Alice: Egypt" for state that was already true.
local function snapshotFor(playerID)
    return {
        status = PreGame.GetSlotStatus(playerID),
        civ = PreGame.GetCivilization(playerID),
        team = PreGame.GetTeam(playerID),
        handicap = PreGame.GetHandicap(playerID),
        ready = PreGame.IsReady(playerID),
        nick = PreGame.GetNickName(playerID),
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
            return Text.key("TXT_KEY_SLOTTYPE_AI")
        end
        return Text.key("TXT_KEY_PLAYER_TYPE_HUMAN")
    end
    return n
end

-- Spoken-friendly delta announcer. Compare new against old, emit one short
-- line per change. Skip the local player on civ / team / handicap / ready
-- changes (they already heard themselves toggle); do announce their
-- slot-status transitions because those can come from host action.
local function announceDeltas(newSnap, oldSnap)
    if oldSnap == nil then
        return
    end
    local localID = Matchmaking.GetLocalID()
    for pid = 0, MAX_SLOTS - 1 do
        local o = oldSnap[pid]
        local n = newSnap[pid]
        if o ~= nil and n ~= nil then
            local name = displayName(pid, n)

            if o.status ~= n.status then
                local ns = slotStatusText(n.status) or ""
                SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_STAGING_DELTA_STATUS", name, ns))
            end

            if pid ~= localID then
                if o.civ ~= n.civ then
                    local ct = civText(pid)
                    if ct ~= nil then
                        SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_STAGING_DELTA_CIV", name, ct))
                    end
                end
                if o.team ~= n.team then
                    local tt = teamText(pid)
                    if tt ~= nil then
                        SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_STAGING_DELTA_TEAM", name, tt))
                    end
                end
                if o.ready ~= n.ready then
                    local key = n.ready and "TXT_KEY_CIVVACCESS_STAGING_DELTA_READY"
                        or "TXT_KEY_CIVVACCESS_STAGING_DELTA_UNREADY"
                    SpeechPipeline.speakQueued(Text.format(key, name))
                end
                if o.handicap ~= n.handicap and n.status == SlotStatus.SS_TAKEN then
                    local hc = handicapText(pid)
                    if hc ~= nil then
                        SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_STAGING_DELTA_HANDICAP", name, hc))
                    end
                end
            end
        end
    end
end

-- Countdown announcements ---------------------------------------------
--
-- Base StartCountdown sets g_fCountdownTimer=10 and ContextPtr:SetUpdate(OnUpdate),
-- base OnUpdate ticks and calls StopCountdown at zero, base StopCountdown sets
-- timer=-1 and ClearUpdate. We wrap all three globals so the SetUpdate call
-- inside StartCountdown picks up our wrapped OnUpdate (SetUpdate reads the
-- OnUpdate global by name at call time).
--
-- Floor-based per-second speech: at each tick we floor g_fCountdownTimer and
-- speak once per new integer in [1..5]. `countdownExpired` distinguishes a
-- natural tick-to-zero stop (no cancel announce) from a mid-countdown
-- cancellation (speak "countdown cancelled"). Set pre-baseOnUpdate so the
-- flag is already true when baseOnUpdate's expiring branch calls StopCountdown.

local _lastSpokenCountdownInt
local _countdownExpired = false

local function wrapCountdown()
    if civvaccess_shared._stagingCountdownWrapped then
        return
    end
    civvaccess_shared._stagingCountdownWrapped = true

    local baseStartCountdown = StartCountdown
    local baseStopCountdown = StopCountdown
    local baseOnUpdate = OnUpdate

    if
        type(baseStartCountdown) ~= "function"
        or type(baseStopCountdown) ~= "function"
        or type(baseOnUpdate) ~= "function"
    then
        Log.warn("StagingRoomAccess: countdown globals missing; skipping wrap")
        civvaccess_shared._stagingCountdownWrapped = nil
        return
    end

    StartCountdown = function(...)
        _lastSpokenCountdownInt = nil
        _countdownExpired = false
        baseStartCountdown(...)
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_STAGING_COUNTDOWN_START"))
    end

    StopCountdown = function(...)
        local wasActive = (g_fCountdownTimer or -1) > 0
        baseStopCountdown(...)
        -- Base StopCountdown calls ContextPtr:ClearUpdate(), which removes our
        -- TickPump wiring. Re-arm so deferred callbacks fire after a countdown.
        TickPump.install(ContextPtr)
        if wasActive and not _countdownExpired then
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_STAGING_COUNTDOWN_CANCEL"))
        end
        _lastSpokenCountdownInt = nil
        _countdownExpired = false
    end

    OnUpdate = function(fDTime)
        local before = g_fCountdownTimer or -1
        if before > 0 and (before - fDTime) <= 0 then
            _countdownExpired = true
        end
        baseOnUpdate(fDTime)
        local after = g_fCountdownTimer or -1
        if after > 0 then
            local cur = math.floor(after)
            if cur >= 1 and cur <= 5 and cur ~= _lastSpokenCountdownInt then
                SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_STAGING_COUNTDOWN_TICK", cur))
                _lastSpokenCountdownInt = cur
            end
        end
    end
end

-- Chat panel ---------------------------------------------------------
--
-- Pushed (not installed) BaseMenu. Messages tab lists the cross-Context
-- history on civvaccess_shared._stagingChatLog in newest-first order so
-- the user lands on the latest line; Compose tab wraps Controls.ChatEntry
-- in a Textfield pointing at base's SendChat as the commit callback.
-- Esc and backslash both pop the panel.
--
-- History buffer is separate from base's g_ChatInstances because the base
-- drops old boxes from the Stack when it rotates them; we need a stable
-- record. Fed by onChat (below) regardless of whether the panel is open,
-- so opening the panel later shows messages received earlier in the
-- session. Capped at 100 to match the base's visual rotation.

local CHAT_LOG_CAP = 100
local CHAT_HANDLER = "StagingChat"

local function appendChatEntry(name, text)
    local log = civvaccess_shared._stagingChatLog or {}
    log[#log + 1] = { name = name, text = text }
    while #log > CHAT_LOG_CAP do
        table.remove(log, 1)
    end
    civvaccess_shared._stagingChatLog = log
end

-- True while the chat panel OR its edit-mode sub is the active handler, so
-- onChat's inline announce can back off while the user is focused there.
local function chatPanelActive()
    for i = HandlerStack.count(), 1, -1 do
        local h = HandlerStack.at(i)
        if h and h.name and string.sub(h.name, 1, #CHAT_HANDLER) == CHAT_HANDLER then
            return true
        end
    end
    return false
end

local function chatMessagesItems()
    local log = civvaccess_shared._stagingChatLog or {}
    if #log == 0 then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_CIVVACCESS_STAGING_CHAT_EMPTY"),
            }),
        }
    end
    local items = {}
    -- Reverse iterate so the newest entry is index 1 (cursor lands there
    -- on open). User can arrow down through older history.
    for i = #log, 1, -1 do
        local e = log[i]
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_CIVVACCESS_STAGING_CHAT_MSG", e.name, e.text),
        })
    end
    return items
end

local function chatComposeItems()
    return {
        BaseMenuItems.Textfield({
            controlName = "ChatEntry",
            textKey = "TXT_KEY_CIVVACCESS_STAGING_CHAT_COMPOSE",
            priorCallback = function(text, control, bIsEnter)
                if bIsEnter and type(SendChat) == "function" then
                    SendChat(text)
                end
            end,
        }),
    }
end

-- reactivate controls whether the handler underneath (StagingRoom) gets
-- onActivate after the pop; caller passes false when StagingRoom itself
-- is hiding, so we don't announce a screen that's about to disappear.
local function closeChatPanel(reactivate)
    return HandlerStack.drainAndRemove(CHAT_HANDLER, reactivate)
end

local function toggleChatPanel()
    if closeChatPanel() then
        return
    end
    local chatHandler = BaseMenu.create({
        name = CHAT_HANDLER,
        displayName = Text.key("TXT_KEY_CIVVACCESS_STAGING_CHAT_PANEL"),
        capturesAllInput = true,
        escapePops = true,
        tabs = {
            {
                name = "TXT_KEY_CIVVACCESS_STAGING_CHAT_MESSAGES_TAB",
                items = chatMessagesItems(),
                onActivate = function(self)
                    -- Rebuild on every tab activation so a just-arrived
                    -- message is visible when the user tabs back in.
                    self.setItems(chatMessagesItems(), self._tabIndex)
                end,
            },
            {
                name = "TXT_KEY_CIVVACCESS_STAGING_CHAT_COMPOSE_TAB",
                items = chatComposeItems(),
            },
        },
    })
    -- Backslash closes the panel (same key that opened it). VK_OEM_5 = 220
    -- per the Windows VK table; Keys.VK_OEM_5 is populated by the engine
    -- but falls back to the literal for the polyfilled test harness.
    chatHandler.bindings[#chatHandler.bindings + 1] = {
        key = Keys.VK_OEM_5 or 220,
        mods = 0,
        description = "Close chat",
        fn = closeChatPanel,
    }
    BaseMenuHelp.addScreenKey(chatHandler, {
        keyLabel = "TXT_KEY_CIVVACCESS_STAGING_CHAT_HELP_KEY_CLOSE",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE",
    })
    HandlerStack.push(chatHandler)
end

-- Event listeners -----------------------------------------------------

local handler

-- Don't rebuild items on PreGameDirty. setItems resets _level to 1 and
-- drops deeper indices, so any rebuild while the user was drilled into a
-- slot bounces the cursor back up to the Group header. Group labels are
-- labelFn-based and re-resolve on each navigate, and isNavigable reads
-- the slot Root's live IsHidden, so in-place state changes are already
-- reflected without a structural rebuild. Deltas still announce via
-- announceDeltas.
-- Name lookup for event-boundary speech. Prefer the live nickname, but fall
-- back to the last snapshot's name so Events.MultiplayerGamePlayerDisconnected
-- still speaks "<Alice> disconnected" after the engine has already cleared
-- that slot's nickname (the engine fires the event post-clear, and base's
-- chat UI uses its own pre-populated m_PlayerNames for the same reason).
local function resolveNick(playerID)
    local live = PreGame.GetNickName(playerID)
    if live ~= nil and live ~= "" then
        return live
    end
    local snap = civvaccess_shared._stagingSnapshot
    local cached = snap and snap[playerID] and snap[playerID].nick
    if cached ~= nil and cached ~= "" then
        return cached
    end
    return Text.key("TXT_KEY_PLAYER_TYPE_HUMAN")
end

local function onPreGameDirty()
    if ContextPtr:IsHidden() then
        return
    end
    local old = civvaccess_shared._stagingSnapshot
    local new = {}
    for pid = 0, MAX_SLOTS - 1 do
        new[pid] = snapshotFor(pid)
    end
    announceDeltas(new, old)
    civvaccess_shared._stagingSnapshot = new
end

local function onChat(fromPlayer, toPlayer, text, eTargetType)
    if ContextPtr:IsHidden() then
        return
    end
    if text == nil or text == "" then
        return
    end
    local n = resolveNick(fromPlayer)
    appendChatEntry(n, text)
    if chatPanelActive() then
        return
    end
    SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_STAGING_CHAT_MSG", n, text))
end

local function onHostMigration()
    if ContextPtr:IsHidden() then
        return
    end
    SpeechPipeline.speakQueued(
        Text.format("TXT_KEY_CIVVACCESS_STAGING_HOST_MIGRATION", resolveNick(Matchmaking.GetHostID()))
    )
end

local function onDisconnect(playerID)
    if ContextPtr:IsHidden() then
        return
    end
    if playerID == nil then
        return
    end
    SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_STAGING_DISCONNECT", resolveNick(playerID)))
end

-- Listener installation is idempotent within one Context lifetime via a
-- file-scope local. A flag on civvaccess_shared (the natural choice)
-- would persist across Context re-inits and lock the mod to a stranded
-- prior-Context listener -- CLAUDE.md's "no install-once guards"
-- rationale. The local resets to false when the file is re-evaluated
-- on Context re-include, so a fresh env gets a fresh listener set.
-- Each listener is pcall-wrapped via Log.safeListener because the
-- engine dispatches Events.X listeners from C and a raw Lua error
-- surfaces as a bare "Runtime Error: ..." line with no Context prefix
-- and no stack trace. The wrapper gives us a breadcrumb identifying
-- which listener threw so the error becomes traceable.
local listenersInstalled = false

local function installListeners()
    if listenersInstalled then
        return
    end
    listenersInstalled = true
    Log.installEvent(
        Events,
        "PreGameDirty",
        Log.safeListener("StagingRoomAccess.onPreGameDirty", onPreGameDirty),
        "StagingRoomAccess"
    )
    Log.installEvent(
        Events,
        "GameMessageChat",
        Log.safeListener("StagingRoomAccess.onChat", onChat),
        "StagingRoomAccess"
    )
    Log.installEvent(
        Events,
        "MultiplayerGameHostMigration",
        Log.safeListener("StagingRoomAccess.onHostMigration", onHostMigration),
        "StagingRoomAccess"
    )
    Log.installEvent(
        Events,
        "MultiplayerGamePlayerDisconnected",
        Log.safeListener("StagingRoomAccess.onDisconnect", onDisconnect),
        "StagingRoomAccess"
    )
end

-- Install -------------------------------------------------------------

local function wrappedShowHide(bIsHide, bIsInit)
    local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
    if not ok then
        Log.error("StagingRoomAccess: priorShowHide failed: " .. tostring(err))
    end
    if bIsHide then
        -- Auto-close the chat panel (+ any edit sub) so nothing orphans on
        -- the stack when the user leaves StagingRoom with the panel open.
        closeChatPanel(false)
        return
    end
    -- Base ShowHideHandler calls StopCountdown() on every show (to clear any
    -- leftover countdown), which calls ContextPtr:ClearUpdate() and wipes the
    -- TickPump wiring BaseMenu.install set at module load. Re-arm it here so
    -- deferred callbacks (BaseMenuEditMode TakeFocus, etc.) keep running.
    TickPump.install(ContextPtr)
    installListeners()
    wrapCountdown()
    -- Base ShowHideHandler ran CreateSlots on first init and RefreshPlayerList
    -- every show, so the shared slot table is populated by the time we build
    -- items here.
    takeSnapshot()
end

-- Placeholder items for each tab. tab.onActivate rebuilds the real list on
-- every open / switch: the Players list depends on live slot instances,
-- and the Options list depends on g_*Manager.m_AllocatedInstances which
-- only populates after OnOptionsPageTab runs UpdateGameOptionsDisplay.
local function tabPlaceholder()
    return {
        BaseMenuItems.Button({
            controlName = "BackButton",
            textKey = "TXT_KEY_BACK_BUTTON",
            activate = function() end,
        }),
    }
end

handler = BaseMenu.install(ContextPtr, {
    name = "StagingRoom",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_STAGING_ROOM"),
    priorShowHide = wrappedShowHide,
    priorInput = priorInput,
    tabs = {
        {
            name = "TXT_KEY_CIVVACCESS_STAGING_PLAYERS_TAB",
            showPanel = function()
                if type(OnPlayersPageTab) == "function" then
                    OnPlayersPageTab()
                end
            end,
            onActivate = function(self)
                self.setItems(playersItems(), self._tabIndex)
            end,
            items = tabPlaceholder(),
        },
        {
            name = "TXT_KEY_CIVVACCESS_STAGING_OPTIONS_TAB",
            showPanel = function()
                -- Force the base to populate the Options panel Controls
                -- (PopulateMapSizePulldown / RefreshMapScripts /
                -- UpdateGameOptionsDisplay) before we read their state.
                MPGameSetupShared.invalidateMapLabels()
                if type(OnOptionsPageTab) == "function" then
                    OnOptionsPageTab()
                end
            end,
            onActivate = function(self)
                self.setItems(optionsItems(), self._tabIndex)
            end,
            items = tabPlaceholder(),
        },
    },
})

-- Backslash opens the chat panel. Backslash is unbound by every Civ V XML
-- so the chord is free across base / G&K / BNW, mirroring the in-game chat
-- key handled by Baseline. Documented in docs/hotkey-reference.md under
-- CivVAccess additions.
handler.bindings[#handler.bindings + 1] = {
    key = Keys.VK_OEM_5 or 220,
    mods = 0,
    description = "Open chat",
    fn = toggleChatPanel,
}
BaseMenuHelp.addScreenKey(handler, {
    keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_BACKSLASH",
    description = "TXT_KEY_CIVVACCESS_STAGING_CHAT_HELP_OPEN",
})

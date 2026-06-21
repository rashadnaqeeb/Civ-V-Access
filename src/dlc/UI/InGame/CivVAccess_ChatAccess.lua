-- In-game multiplayer chat panel. Seated in DiploCorner's env via
-- DiploCorner.lua's appended include so Controls.ChatEntry, OnChatToggle
-- and SendChat (DiploCorner-locals) are reachable. Listens for
-- LuaEvents.CivVAccessChatToggle (fired by Baseline's `\` binding) and
-- pushes a BaseMenu over DiploCorner's existing chat UI.
--
-- Two-tab layout mirroring StagingRoomAccess's F2 panel: Messages (recent
-- history from civvaccess_shared._inGameChatLog, newest-first) and
-- Compose (Controls.ChatEntry wrapped as a Textfield, commit calls base's
-- SendChat which goes through Network.SendChat). DiploCorner's ChatPanel
-- is engine-managed and auto-shown in MP non-hotseat; we don't toggle its
-- visibility, just layer accessibility on top.
--
-- chatPanelActive is published on civvaccess_shared so ChatBuffer (in
-- WorldView's env) can suppress its inline speech announcement while the
-- user is focused in the panel -- otherwise a received message double-
-- announces (once via speakQueued from ChatBuffer, again via the Messages-
-- tab rebuild on the next activate).
--
-- Esc / `\` close the panel via the BaseMenu's escapePops Esc binding plus
-- an explicit `\` binding pasted onto chatHandler.bindings (same pattern
-- StagingRoomAccess uses to make F2 self-toggle).
--
-- Open-to-type and send-and-dismiss: `\` opens the panel straight into
-- BaseMenuEditMode on the Compose Textfield (one tick after the panel is
-- pushed, so the panel's first-open speech is already scheduled when our
-- "Editing message" interrupt fires), and Enter sends the line and closes
-- the panel. The close is deferred one tick so the edit-mode commit
-- announce -- which speaks the just-sent line -- plays out before the
-- panel pops, and uses reactivate=false so the underlying handler's
-- onActivate doesn't cut off that confirmation. Esc and `\` still close
-- without sending. The MP staging-room panel (StagingRoomAccess) keeps
-- its history-browser shape: separate file, separate handler, untouched.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
include("CivVAccess_AudioCueMode")
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
include("CivVAccess_Verbosity")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_VolumeControl")
include("CivVAccess_BeaconRange")
include("CivVAccess_BeaconVolume")
include("CivVAccess_Settings")

local CHAT_HANDLER = "InGameChat"
local VK_OEM_5 = 220 -- backslash

-- chatPanelActive is owned here: set true on toggle-open, false on close.
-- Initialize at module load so ChatBuffer's announce-suppression check is
-- well-defined before the user has touched the panel. Re-init on every
-- DiploCorner Context include is harmless -- a panel that was open in a
-- prior game is gone (its handler closure had a dead env, removed
-- naturally by the new game's HandlerStack reset in onInGameBoot).
civvaccess_shared.chatPanelActive = false

-- Reclaim Tab from LekMod's chat shortcut. LekMod binds CONTROL_TOGGLE_CHAT to
-- KB_TAB and adds an in-game hotkey manager in DiploCorner whose InputHandler
-- intercepts that hotkey and returns true -- consuming Tab before it reaches
-- WorldView/InGame, where our Baseline binding (the unit action menu) lives.
-- DiploCorner also seeds an always-present focusable "Dummy" EditBox
-- (DummyStack, FocusStop="2") so the engine's Tab focus-traversal toggles chat
-- as a second path. We expose chat on backslash and need Tab for the action
-- menu, matching vanilla/VP. So drop the dummy from the focus ring and
-- re-register the Context InputHandler to one that declines every key so Tab
-- falls through to our dispatch. Our append runs last in DiploCorner's env, so
-- this SetInputHandler wins over LekMod's. (LekMod's handler also ran a
-- GameInfoActions refresh tied to its runtime hotkey-remap manager, which we
-- do not use -- the engine refreshes actions on selection itself -- so dropping
-- it is safe.) Re-runs idempotently on every DiploCorner include (load-from-
-- game rebuilds both, this clears them again). Guarded on the dummy control's
-- presence, which marks LekMod's reworked DiploCorner; vanilla/VP DiploCorner
-- has neither and is untouched.
if Controls.DummyStack ~= nil then
    Controls.DummyStack:DestroyAllChildren()
    ContextPtr:SetInputHandler(function()
        return false
    end)
    Log.info("ChatAccess: neutralized LekMod DiploCorner Tab-to-chat so Tab reaches the unit action menu")
end

-- Forward decl: chatComposeItems' priorCallback closes the panel after
-- send (send-and-dismiss), and is defined before closeChatPanel below.
local closeChatPanel

local function chatMessagesItems()
    local log = civvaccess_shared._inGameChatLog or {}
    if #log == 0 then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"),
            }),
        }
    end
    local items = {}
    -- Newest-first so the cursor lands on the most recent line. User can
    -- arrow down through older history.
    for i = #log, 1, -1 do
        local e = log[i]
        items[#items + 1] = BaseMenuItems.Text({
            labelText = e.line,
        })
    end
    return items
end

local function chatComposeItems()
    return {
        BaseMenuItems.Textfield({
            controlName = "ChatEntry",
            textKey = "TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE",
            priorCallback = function(text, control, bIsEnter)
                if bIsEnter and type(SendChat) == "function" then
                    SendChat(text)
                    -- SendChat calls Controls.ChatEntry:ClearString() at the
                    -- end. BaseMenuEditMode then re-reads the EditBox to
                    -- speak commit confirmation, which would land on the
                    -- blank-sentinel instead of the line just sent. Put the
                    -- text back so the announce echoes what was sent. Gate
                    -- on the active panel so a sighted user typing into the
                    -- engine ChatPanel directly (which routes through the
                    -- same callback after BaseMenuEditMode restored it)
                    -- still sees the field clear visually after Enter. The
                    -- next BaseMenuEditMode push clears the box at entry,
                    -- so this restored value never bleeds into a fresh
                    -- compose.
                    if civvaccess_shared.chatPanelActive then
                        control:SetText(text)
                        -- Send-and-dismiss: `\` opens the panel straight
                        -- into edit mode, Enter is the single gesture for
                        -- "send this line and close." Defer one tick so
                        -- BaseMenuEditMode.exit can finish (sub pop +
                        -- commit announce of the just-sent line) before
                        -- we pop the panel. reactivate=false so the
                        -- underlying handler stays quiet and the commit
                        -- announce plays to completion. Sighted users
                        -- typing into Controls.ChatEntry directly hit
                        -- this callback too, but with chatPanelActive
                        -- false they skip both the SetText echo and the
                        -- close.
                        TickPump.runOnce(function()
                            closeChatPanel(false)
                        end)
                    end
                end
            end,
        }),
    }
end

-- chatPanelActive reset and engine-focus release live in the handler's
-- onDeactivate (set in toggleChatPanel), so every close path -- send-and-
-- dismiss, `\`-toggle, and the BaseMenu Esc binding (which pops via
-- removeByName, not through here) -- runs the same cleanup.
closeChatPanel = function(reactivate)
    return HandlerStack.drainAndRemove(CHAT_HANDLER, reactivate)
end

local function toggleChatPanel()
    -- LekMod wires its reworked DiploCorner chat even in single player
    -- (Controls.DummyStack marks that body), so the panel is usable there;
    -- vanilla / VP keep chat multiplayer-only and no-op in single player.
    if not Game:IsNetworkMultiPlayer() and Controls.DummyStack == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"))
        return
    end
    if closeChatPanel() then
        return
    end
    local composeItems = chatComposeItems()
    local textfieldItem = composeItems[1]
    local chatHandler = BaseMenu.create({
        name = CHAT_HANDLER,
        displayName = Text.key("TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"),
        capturesAllInput = true,
        escapePops = true,
        -- Land on Compose first: the user pressed `\` to send a message,
        -- not to review history. They can Tab to Messages if they want
        -- the recent log instead.
        initialTabIndex = 2,
        tabs = {
            {
                name = "TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB",
                items = chatMessagesItems(),
                onActivate = function(self)
                    -- Rebuild on every tab activation so a just-arrived
                    -- message is visible when the user tabs back in.
                    self.setItems(chatMessagesItems(), self._tabIndex)
                end,
            },
            {
                name = "TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB",
                items = composeItems,
            },
        },
    })
    -- Fires on every removal path (send-and-dismiss, `\` toggle, Esc). Resets
    -- the announce-suppression flag and hands engine keyboard focus back from
    -- Controls.ChatEntry. Civ V has no focus-release call; the engine drops
    -- focus only when the focused control is hidden. Unlike the popup EditBoxes
    -- other BaseMenuEditMode screens wrap (hidden with their Context on close),
    -- ChatEntry is a persistent always-visible engine EditBox -- without this
    -- it keeps focus after the panel pops, so every keystroke types into it and
    -- Enter re-fires its send callback. Hide to drop focus, reshow next tick so
    -- it stays visible. Guarded: ChatEntry only exists in DiploCorner's env.
    chatHandler.onDeactivate = function()
        civvaccess_shared.chatPanelActive = false
        if Controls.ChatEntry ~= nil then
            Controls.ChatEntry:SetHide(true)
            TickPump.runOnce(function()
                if Controls.ChatEntry ~= nil then
                    Controls.ChatEntry:SetHide(false)
                end
            end)
        end
    end
    -- `\` self-toggles like F2 does in StagingRoomAccess.
    chatHandler.bindings[#chatHandler.bindings + 1] = {
        key = VK_OEM_5,
        mods = 0,
        description = "Close chat",
        fn = closeChatPanel,
    }
    BaseMenuHelp.addScreenKey(chatHandler, {
        keyLabel = "TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE",
        description = "TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE",
    })
    civvaccess_shared.chatPanelActive = true
    HandlerStack.push(chatHandler)
    -- Auto-enter edit mode on the Compose Textfield so the user can start
    -- typing the moment `\` lands. Defer one tick: BaseMenuEditMode reads
    -- textfieldItem._control synchronously (already populated by Textfield
    -- at build time) but its TakeFocus has to run after the engine's
    -- KEYDOWN/KEYUP for `\` settles, otherwise the matching KEYUP revokes
    -- the just-taken focus. The HandlerStack.active() guard catches a
    -- racing close (Esc tapped before the tick fires).
    TickPump.runOnce(function()
        if HandlerStack.active() ~= chatHandler then
            return
        end
        BaseMenuEditMode.push(chatHandler, textfieldItem)
    end)
end

if
    Log.installEvent(
        LuaEvents,
        "CivVAccessChatToggle",
        Log.safeListener("ChatAccess.toggleChatPanel", toggleChatPanel),
        "ChatAccess",
        "\\ key will no-op"
    )
then
    Log.info("ChatAccess: registered LuaEvents.CivVAccessChatToggle listener")
end

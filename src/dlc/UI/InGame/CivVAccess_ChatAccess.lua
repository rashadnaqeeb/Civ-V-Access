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
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")

local CHAT_HANDLER = "InGameChat"
local VK_OEM_5 = 220 -- backslash

-- chatPanelActive is owned here: set true on toggle-open, false on close.
-- Initialize at module load so ChatBuffer's announce-suppression check is
-- well-defined before the user has touched the panel. Re-init on every
-- DiploCorner Context include is harmless -- a panel that was open in a
-- prior game is gone (its handler closure had a dead env, removed
-- naturally by the new game's HandlerStack reset in onInGameBoot).
civvaccess_shared.chatPanelActive = false

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
                    end
                end
            end,
        }),
    }
end

local function closeChatPanel(reactivate)
    if HandlerStack.drainAndRemove(CHAT_HANDLER, reactivate) then
        civvaccess_shared.chatPanelActive = false
        return true
    end
    return false
end

local function toggleChatPanel()
    if not Game:IsNetworkMultiPlayer() then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"))
        return
    end
    if closeChatPanel() then
        return
    end
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
                items = chatComposeItems(),
            },
        },
    })
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
end

if LuaEvents ~= nil and LuaEvents.CivVAccessChatToggle ~= nil then
    LuaEvents.CivVAccessChatToggle.Add(function()
        local ok, err = pcall(toggleChatPanel)
        if not ok then
            Log.error("ChatAccess: toggleChatPanel failed: " .. tostring(err))
        end
    end)
    Log.info("ChatAccess: registered LuaEvents.CivVAccessChatToggle listener")
else
    Log.warn("ChatAccess: LuaEvents.CivVAccessChatToggle missing; \\ key will no-op")
end

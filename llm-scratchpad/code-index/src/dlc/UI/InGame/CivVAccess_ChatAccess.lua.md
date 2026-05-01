# `src/dlc/UI/InGame/CivVAccess_ChatAccess.lua`

173 lines · In-game multiplayer chat panel seated in DiploCorner's Lua env, activated by the backslash key via LuaEvents.CivVAccessChatToggle, with a two-tab Messages/Compose BaseMenu layout.

## Header comment

```
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
```

## Outline

- L45: `local CHAT_HANDLER = "InGameChat"`
- L46: `local VK_OEM_5 = 220`
- L54: `civvaccess_shared.chatPanelActive = false`
- L56: `local function chatMessagesItems()`
- L77: `local function chatComposeItems()`
- L106: `local function closeChatPanel(reactivate)`
- L114: `local function toggleChatPanel()`
- L162: `LuaEvents.CivVAccessChatToggle.Add(...)`

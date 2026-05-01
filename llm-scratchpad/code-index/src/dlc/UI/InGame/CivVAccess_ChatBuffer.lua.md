# `src/dlc/UI/InGame/CivVAccess_ChatBuffer.lua`

97 lines · Ingests Events.GameMessageChat in WorldView's env, appends to the shared chat log, the MessageBuffer review surface, and speaks each received message queued (suppressed while the chat panel is active).

## Header comment

```
-- Multiplayer chat ingestion. Subscribes to Events.GameMessageChat from
-- the WorldView Context (Boot's env) so the listener survives load-game-
-- from-game without depending on DiploCorner's child-Context re-init
-- behavior. Three downstream effects per incoming message:
--   1) civvaccess_shared._inGameChatLog (capped) -- backing store for
--      ChatAccess's Messages tab.
--   2) MessageBuffer.append(formatted, "chat") -- the user's [ / ] review
--      surface, where chat shares the cycle with notifications / reveal /
--      combat.
--   3) SpeechPipeline.speakQueued -- in-the-moment announcement, queued
--      (not interrupting) so chat doesn't cut off other speech. Suppressed
--      while ChatAccess's Compose panel is up so the user isn't double-
--      announced what they're already focused on.
--
-- No install-once guard, mirroring the rest of the in-game listener
-- surface: Civ V kills WorldView's env on load-from-game and a flag-
-- gated registration would lock the mod to the dead listener forever.
-- Boot.lua re-includes this module on every onInGameBoot.
```

## Outline

- L20: `ChatBuffer = {}`
- L22: `local CHAT_LOG_CAP = 100`
- L24: `local function appendLog(entry)`
- L33: `local function chatPanelActive()`
- L42: `local function resolveNick(playerID)`
- L51: `local function formatLine(fromPlayer, toPlayer, text, eTargetType)`
- L68: `local function onChat(fromPlayer, toPlayer, text, eTargetType)`
- L87: `ChatBuffer._onChat = onChat`
- L89: `function ChatBuffer.installListeners()`

# `src/dlc/UI/FrontEnd/CivVAccess_StagingRoomAccess.lua`

991 lines · Accessibility wiring for the StagingRoom multiplayer lobby screen, covering a two-tab player/options menu, per-slot drill-in groups, remote-delta announcements, countdown speech, and an F2 chat panel.

## Header comment

```
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
```

## Outline

- L47: `local priorShowHide = ShowHideHandler`
- L55: `local basePriorInput = InputHandler`
- L56: `local function priorInput(msg, wp, lp)`
- L66: `local MAX_SLOTS = GameDefines.MAX_MAJOR_CIVS`
- L71: `local function labelText(labelControl)`
- L92: `local _civRichByID`
- L93: `local function civRichLabelForID(civID)`
- L122: `local function civEntryAnnounce(inst)`
- L126: `local function civText(playerID)`
- L136: `local function teamText(playerID)`
- L145: `local function handicapText(playerID)`
- L153: `local function nickName(playerID)`
- L166: `local SLOT_STATUS_KEY = { ... }`
- L174: `local function slotStatusText(status)`
- L183: `local function slotSummary(playerID)`
- L251: `local function slotChildren(slotIndex, instance)`
- L317: `local function localSeatChildren()`
- L360: `local mapTypeEntryAnnounce = MPGameSetupShared.mapTypeEntryAnnounce`
- L361: `local victoryChildren = MPGameSetupShared.victoryChildren`
- L362: `local gameOptionsChildren = MPGameSetupShared.gameOptionsChildren`
- L363: `local dlcChildren = MPGameSetupShared.dlcChildren`
- L367: `local function playersItems()`
- L425: `local function optionsItems()`
- L521: `local function snapshotFor(playerID)`
- L532: `local function takeSnapshot()`
- L540: `local function displayName(playerID, snap)`
- L555: `local function announceDeltas(newSnap, oldSnap)`
- L614: `local _lastSpokenCountdownInt`
- L615: `local _countdownExpired = false`
- L617: `local function wrapCountdown()`
- L688: `local CHAT_LOG_CAP = 100`
- L689: `local CHAT_HANDLER = "StagingChat"`
- L691: `local function appendChatEntry(name, text)`
- L700: `local function chatPanelActive()`
- L712: `local function chatMessagesItems()`
- L733: `local function chatComposeItems()`
- L750: `local function closeChatPanel(reactivate)`
- L754: `local function toggleChatPanel()`
- L797: `local handler`
- L811: `local function resolveNick(playerID)`
- L824: `local function onPreGameDirty()`
- L837: `local function onChat(fromPlayer, toPlayer, text, eTargetType)`
- L852: `local function onHostMigration()`
- L861: `local function onDisconnect(playerID)`
- L880: `local function safeListener(name, fn)`
- L889: `local function installListeners()`
- L902: `local function wrappedShowHide(bIsHide, bIsInit)`
- L930: `local function tabPlaceholder()`
- L940: `handler = BaseMenu.install(ContextPtr, { ... })`
- L981: `handler.bindings[#handler.bindings + 1] = { ... }`
- L987: `BaseMenuHelp.addScreenKey(handler, { ... })`

## Notes

- L56 `priorInput`: filters `KEY_UP` events for Tab and Return before forwarding to the base `InputHandler`, preventing the base from stealing keyboard focus to `ChatEntry` on every activation.
- L617 `wrapCountdown`: guarded by `civvaccess_shared._stagingCountdownWrapped` rather than a module-local flag so it is install-once across Context re-instantiations (the globals it wraps are shared, not per-env).
- L750 `closeChatPanel`: the `reactivate` parameter controls whether the handler underneath (StagingRoom) receives its `onActivate` after the pop, allowing callers to suppress the re-announce when StagingRoom itself is hiding.
- L889 `installListeners`: guarded by `civvaccess_shared._stagingListenersInstalled`; this is an intentional install-once guard for event listeners whose handlers must NOT accumulate (unlike the general pattern in the architecture notes, these listeners don't hold env references that die on load-from-game because StagingRoom is a front-end-only Context that doesn't survive into a loaded game).

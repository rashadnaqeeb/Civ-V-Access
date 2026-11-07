-- Reads text popups that the TextPopup hook cannot reach.
--
-- A mod that imports its own TextPopup.lua into the VFS shadows our override
-- of that screen, so its popups open with no accessibility hook. The Firaxis
-- scenarios that restyle the popup do exactly this (American Civil War and
-- Scramble for Africa): every scenario event message, and the briefing,
-- arrives that way. The box takes Enter and Esc itself to close, so without a
-- hook the player hears nothing, and their next Enter on the map goes to a box
-- they don't know is open.
--
-- So each such popup gets the dismiss menu the reward popups have (goody hut,
-- great person): the message as the preamble, then a lone Close button, with
-- Alt+Up/Down reviewing the message line by line. Enter and Esc still reach
-- the box first and close it; Close (Space) closes it through UIManager the way
-- the box's own button does. However the box closes, its hide reports the
-- popup processed, and that closes the menu.
--
-- The box queues itself behind any popup already up (a chooser at turn start),
-- so the menu waits until the box is actually on screen: opening on the
-- message alone would put a menu that captures all input over the chooser the
-- player is really looking at. The box announces its show with
-- SerialEventGameMessagePopupShown, but passes nil for the popup info (its
-- m_PopupInfo is never assigned), so the menu opens on any show that finds a
-- message pending and the box visible. The box may also show inside its own
-- popup listener, before ours runs, so the message listener checks too.
--
-- A more urgent popup (an AI leader's greeting) can hide the box while its menu
-- is open and show it again once that popup closes. The hide reports the box
-- processed just as a dismissal does, so the menu closes with it. The message
-- the menu opened on is kept, and a show that finds the box visible with no
-- message pending reopens the menu on it, without buffering it again. That
-- reopen waits a frame: the box can show its next message before our message
-- listener hears of it, and a frame later that listener has opened the menu
-- on the new message instead.
--
-- Such a popup can also take the screen in the frame the box shows (Who's
-- Winning at turn start), so the box reports itself processed before its show
-- reaches us, with its message unread. So a processed report never drops a
-- waiting message: the box either comes back with it, or a new message has
-- replaced it.
--
-- A scenario script can also raise its message between the player's turns:
-- Scramble for Africa announces each natural wonder any explorer finds, so
-- an AI's find lands while the AIs still move and their leaders may cut
-- in after a few words. So a message that arrives after ActivePlayerTurnEnd
-- is held until the game begins the player's next turn. The game raises its
-- own popups for the turn (a great person born) while it processes the turn,
-- which ends with PlayerDoTurn for that player, and ActivePlayerTurnStart
-- queues the turn line and the other turn-start announcements only after
-- that. So in the scenarios ScenarioRegistry supports, the games that replace
-- the box in practice, the hold ends on the active player's PlayerDoTurn, and
-- the held message opens alongside the game's own popups, ahead of those
-- announcements rather than cutting them off. Those scenarios listen to
-- PlayerDoTurn themselves, so ours rides along with calls into Lua the game
-- already makes; every other game, single player or multiplayer, runs
-- without it. PlayerDoTurn runs inside the simulation, on the game-core
-- thread (docs/llm-docs/mp-deadlock.md describes the two threads), not the UI
-- thread the screen belongs to, so the hook only ends the hold and the next
-- frame presents the message. ActivePlayerTurnStart ends the hold too: for a
-- turn that starts without that processing, and in any other game that
-- replaces the box. A message raised once the turn has begun replaces one
-- still held, since the box shows only its latest message.
--
-- A frame after a held message's box shows, the box is taken off the screen,
-- where no stray Enter or Esc can close it unheard, and put back at its own
-- priority when the hold ends; the menu opens on the message once it shows. A
-- held message whose box is gone when the hold ends anyway (the game closed
-- it, or a key landed in the frame before) is read and buffered all the same,
-- and the menu opens on it if the box comes back. Only a held message's box
-- comes off the screen: one from the player's own turn that shows only after
-- the turn ends (a multiplayer turn timer ran out) opens its menu as usual.
--
-- The message rides in on the same SerialEventGameMessagePopup the box itself
-- listens to, and the box shows popupInfo.Text through LocalizeAndSetText, so
-- the menu reads exactly what is on screen: Text.key resolves a TXT_KEY the
-- same way and passes already-localized text through. Nothing opens whenever
-- TextPopupAccess loaded this game: that wrapper publishes a liveness probe,
-- which reads false once its Context's env is wiped (game exit, load from
-- game) and is never refreshed when a shadowing mod keeps the wrapper from
-- loading at all. Each message is also buffered under notification, matching
-- NotificationAnnounce, so it stays reviewable after its box closes.

ShadowedTextPopupAnnounce = {}

local MENU_NAME = "ShadowedTextPopup"

-- The box's Context: InGame.xml declares TextPopup at the top level, and a
-- shadowing mod replaces only the file it loads.
local TEXT_POPUP_PATH = "/InGame/TextPopup"

local function hookAlive()
    local probe = civvaccess_shared.textPopupHookProbe
    if probe == nil then
        return false
    end
    local ok, alive = pcall(probe)
    if not ok then
        Log.error("ShadowedTextPopupAnnounce: TextPopup hook probe failed: " .. tostring(alive))
        return false
    end
    return alive == true
end

-- Text of the box's latest message, waiting for the box to show. Cleared when
-- the menu opens. Outlives the box's processed report, which a more urgent
-- popup taking the screen sets off just as a dismissal does.
local _pending = nil

-- Text of the message the menu last opened on. Outlives the box's processed
-- report, so the menu can reopen on it when the box comes back from behind a
-- more urgent popup. Replaced by the next message the menu opens on.
local _shownText = nil

-- True from the player's turn end to the start of their next turn.
local _betweenTurns = false

-- The latest message that arrived between turns, presented as the player's
-- turn begins.
-- Outlives the box's processed report: a leader can hide the box, or the
-- player close it, while the message waits.
local _held = nil

-- True while the held message's box is off the screen, to go back on when
-- the turn starts.
local _parked = false

local function lookUpBox()
    return ContextPtr:LookUpControl(TEXT_POPUP_PATH)
end

local function boxShowing()
    local box = lookUpBox()
    return box ~= nil and not box:IsHidden()
end

local function closeBox()
    local box = lookUpBox()
    if box == nil then
        Log.error("ShadowedTextPopupAnnounce: no " .. TEXT_POPUP_PATH .. " Context to close")
        HandlerStack.removeByName(MENU_NAME, true)
        return
    end
    if box:IsHidden() then
        -- Nothing on screen to close, so no processed event will come to
        -- close the menu: close it here.
        HandlerStack.removeByName(MENU_NAME, true)
        return
    end
    UIManager:DequeuePopup(box)
end

local function menuOpen()
    for i = 1, HandlerStack.count() do
        if HandlerStack.at(i).name == MENU_NAME then
            return true
        end
    end
    return false
end

local function openMenu(text)
    _shownText = text
    HandlerStack.removeByName(MENU_NAME, false)
    local handler = BaseMenu.create({
        name = MENU_NAME,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"),
        preamble = text,
        items = {
            -- A Choice, not a Button: the box's own button lives in another
            -- Context, so there is no control here to back a Button item.
            BaseMenuItems.Choice({
                labelText = Text.key("TXT_KEY_CLOSE"),
                verboseKindKey = "TXT_KEY_CIVVACCESS_KIND_BUTTON",
                activate = closeBox,
            }),
        },
        capturesAllInput = true,
        -- The showing box takes Esc before this menu sees it. Esc only gets
        -- here if the box is gone, and then nothing else will close the menu.
        escapePops = true,
    })
    RewardReview.install(handler, function()
        return { text }
    end)
    HandlerStack.push(handler)
end

local function openPending()
    local text = _pending
    _pending = nil
    MessageBuffer.append(text, "notification")
    openMenu(text)
end

-- A frame after a held message arrives or its box shows: takes the box off
-- the screen until the player's turn begins. A turn that began meanwhile
-- leaves the box be, for the message to be presented on it. Its hide reports
-- it processed, as a leader's greeting hiding it does.
local function parkBox()
    if not _betweenTurns or not boxShowing() then
        return
    end
    _parked = true
    Log.debug("ShadowedTextPopupAnnounce: took the held message's box off the screen until the turn starts")
    UIManager:DequeuePopup(lookUpBox())
end

-- A frame after the box showed with no message pending. A new message the box
-- showed from inside its own listener has opened the menu on itself by now, so
-- a box still showing without the menu is back with the message it showed.
local function reopenOnReturnedBox()
    if _pending == nil and boxShowing() and not menuOpen() then
        openMenu(_shownText)
    end
end

function ShadowedTextPopupAnnounce._onPopup(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TEXT or hookAlive() then
        return
    end
    local text = Text.key(popupInfo.Text)
    if _betweenTurns then
        _held = text
        Log.debug("ShadowedTextPopupAnnounce: holding a message that arrived between turns: " .. text:sub(1, 80))
        TickPump.runOnce(parkBox)
        return
    end
    -- The box shows only its latest message, so this one replaces any still
    -- held from the other civs' turns.
    _held = nil
    _pending = text
    if boxShowing() then
        openPending()
    end
end

function ShadowedTextPopupAnnounce._onPopupShown()
    if _held ~= nil then
        TickPump.runOnce(parkBox)
        return
    end
    if _pending ~= nil then
        if boxShowing() then
            openPending()
        end
    elseif _shownText ~= nil then
        TickPump.runOnce(reopenOnReturnedBox)
    end
end

function ShadowedTextPopupAnnounce._onPopupProcessed(popupType)
    if popupType ~= ButtonPopupTypes.BUTTONPOPUP_TEXT then
        return
    end
    HandlerStack.removeByName(MENU_NAME, true)
end

function ShadowedTextPopupAnnounce._onTurnEnd()
    _betweenTurns = true
end

local function releaseHold()
    local parked = _parked
    _parked = false
    local text = _held
    if text == nil then
        return
    end
    _held = nil
    if boxShowing() then
        _pending = text
        openPending()
        return
    end
    if parked then
        -- Put the box back. With nothing outranking it, the box shows inside
        -- this call, but its show reaches us a frame or more later, by when
        -- the turn-start announcements may have queued; so the menu opens on
        -- it at once. Behind another popup, the menu waits for the box to
        -- show.
        _pending = text
        Log.debug("ShadowedTextPopupAnnounce: put the held message's box back for the turn")
        UIManager:QueuePopup(lookUpBox(), PopupPriority.TextPopup)
        if boxShowing() then
            openPending()
        end
        return
    end
    -- No box on screen: the game closed it while it waited, a key landed
    -- before it came off the screen, or it waits behind another popup. Read
    -- it either way; if the box comes back, the menu reopens on it.
    Log.debug("ShadowedTextPopupAnnounce: no box on screen at turn start; reading the held message")
    MessageBuffer.append(text, "notification")
    _shownText = text
    SpeechPipeline.speakInterrupt(text)
end

-- Runs inside the game's turn processing, on the game-core thread rather than
-- the UI thread the screen belongs to: it only ends the hold, and the next
-- frame presents the message.
function ShadowedTextPopupAnnounce._onPlayerDoTurn(iPlayer)
    if iPlayer ~= Game.GetActivePlayer() then
        return
    end
    _betweenTurns = false
    TickPump.runOnce(releaseHold)
end

function ShadowedTextPopupAnnounce._onTurnStart()
    _betweenTurns = false
    releaseHold()
end

function ShadowedTextPopupAnnounce.install()
    _pending = nil
    _shownText = nil
    _betweenTurns = false
    _held = nil
    _parked = false
    Log.installEvent(
        Events,
        "SerialEventGameMessagePopup",
        Log.safeListener("ShadowedTextPopupAnnounce", ShadowedTextPopupAnnounce._onPopup),
        "ShadowedTextPopupAnnounce",
        "shadowed text popups will be silent"
    )
    Log.installEvent(
        Events,
        "SerialEventGameMessagePopupShown",
        Log.safeListener("ShadowedTextPopupAnnounce.shown", ShadowedTextPopupAnnounce._onPopupShown),
        "ShadowedTextPopupAnnounce",
        "a shadowed text popup that waited behind another popup will be silent"
    )
    Log.installEvent(
        Events,
        "SerialEventGameMessagePopupProcessed",
        Log.safeListener("ShadowedTextPopupAnnounce.processed", ShadowedTextPopupAnnounce._onPopupProcessed),
        "ShadowedTextPopupAnnounce",
        "a shadowed text popup's menu will stay open after its box closes"
    )
    Log.installEvent(
        Events,
        "ActivePlayerTurnEnd",
        Log.safeListener("ShadowedTextPopupAnnounce.turnEnd", ShadowedTextPopupAnnounce._onTurnEnd),
        "ShadowedTextPopupAnnounce",
        "a message between turns will be read at once"
    )
    -- Only the supported scenarios follow the game's turn processing; see the
    -- header for why.
    if ScenarioRegistry.active() ~= nil then
        Log.debug("ShadowedTextPopupAnnounce: following the turn processing in this scenario")
        Log.installEvent(
            GameEvents,
            "PlayerDoTurn",
            Log.safeListener("ShadowedTextPopupAnnounce.playerDoTurn", ShadowedTextPopupAnnounce._onPlayerDoTurn),
            "ShadowedTextPopupAnnounce",
            "a held message will wait for the turn start and may cut off its announcements"
        )
    end
    Log.installEvent(
        Events,
        "ActivePlayerTurnStart",
        Log.safeListener("ShadowedTextPopupAnnounce.turnStart", ShadowedTextPopupAnnounce._onTurnStart),
        "ShadowedTextPopupAnnounce",
        "a message held between turns may not be read"
    )
    Log.info("ShadowedTextPopupAnnounce: installed")
end

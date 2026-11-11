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
-- processed just as a dismissal does, so the menu closes with it. The messages
-- the menu opened on are kept, and a show that finds the box visible with
-- nothing unread reopens the menu on them, without buffering them again. That
-- reopen waits a frame: the box can show its next message before our message
-- listener hears of it, and a frame later that listener has opened the menu
-- on the new message instead.
--
-- Such a popup can also take the screen in the frame the box shows (Who's
-- Winning at turn start), so the box reports itself processed before its show
-- reaches us, with its message unread. So a processed report never drops a
-- waiting message: the box comes back with it, or with a newer message the
-- menu reads after it.
--
-- The box shows only its latest message, so a later one replaces any message
-- still held or waiting for the box. The menu reads every such message, oldest
-- first, ahead of the one the box shows, and Alt+Up/Down reviews them in that
-- order, so none goes unheard.
--
-- A scenario script can also raise its message once the player's turn is
-- over. Scramble for Africa announces each natural wonder any explorer finds,
-- so an AI's find lands while the AIs still move and their leaders may cut in
-- after a few words. The player's own units raise messages too after End Turn,
-- while the game runs their queued and automated moves: an explorer's dig
-- finishing in Scramble, a blockade runner reaching open water in the
-- American Civil War. The game takes back the End Turn for what it raises
-- itself then, a natural wonder or the dig's own prompt
-- (CancelActivePlayerEndTurn), but not for a script's message, so the turn
-- ends with the message unread. So a message that arrives once the turn is
-- over is held until the game begins the player's next turn. Such a message
-- reaches Lua before ActivePlayerTurnEnd does, so the hold also asks the game
-- whether the player's turn is still active. A menu that opened on one in the
-- frames before the game ended the turn is cut short when its box comes off
-- the screen, and its messages are read again ahead of the ones held after
-- it. So is a menu the player is reading when a multiplayer turn timer runs
-- out, and so are the messages of a box that comes back from behind a more
-- urgent popup once the turn is over. Hotseat holds nothing: the next turn
-- belongs to another human, and an AI's diplomacy waits for a human's turn
-- there.
--
-- The game raises its own popups for the turn (a great person born) while it
-- processes the turn, which ends with PlayerDoTurn for that player, and
-- ActivePlayerTurnStart queues the turn line and the other turn-start
-- announcements only after that. So in the scenarios ScenarioRegistry
-- supports, the games that replace the box in practice, the hold ends on the
-- active player's PlayerDoTurn, and the held messages open alongside the
-- game's own popups, ahead of those announcements rather than cutting them
-- off. Those scenarios listen to PlayerDoTurn themselves, so ours rides along
-- with calls into Lua the game already makes; every other game, single player
-- or multiplayer, runs without it. PlayerDoTurn runs inside the simulation, on
-- the game-core thread (docs/llm-docs/mp-deadlock.md describes the two
-- threads), not the UI thread the screen belongs to, so the hook only ends the
-- hold and the next frame presents the messages. ActivePlayerTurnStart ends
-- the hold too: for a turn that starts without that processing, and in any
-- other game that replaces the box. Only held messages are released, so a box
-- that already went back for the turn, or a message from the turn processing
-- still waiting behind the turn's own popups, waits for its box to show.
--
-- A frame after a held message's box shows, the box is taken off the screen,
-- where no stray Enter or Esc can close it unheard, and put back at its own
-- priority when the hold ends; the menu opens on the messages once it shows.
-- Held messages whose box is gone when the hold ends anyway (the game closed
-- it, or a key landed in the frame before) are read and buffered all the
-- same, and the menu opens on them if the box comes back.
--
-- The message rides in on the same SerialEventGameMessagePopup the box itself
-- listens to, and the box shows popupInfo.Text through LocalizeAndSetText, so
-- the menu reads the box's message exactly as it shows: Text.key resolves a
-- TXT_KEY the same way and passes already-localized text through. Nothing
-- opens whenever TextPopupAccess loaded this game: that wrapper publishes a
-- liveness probe, which reads false once its Context's env is wiped (game
-- exit, load from game) and is never refreshed when a shadowing mod keeps the
-- wrapper from loading at all. Each message is also buffered under
-- notification as it is presented, matching NotificationAnnounce, so it stays
-- reviewable after its box closes.

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

-- The messages not yet presented, oldest first, each { text = ..., buffered =
-- ... }. The box shows the newest; the menu reads them all when it opens on
-- the box, and buffers those not buffered yet. Outlives the box's processed
-- report, which a more urgent popup taking the screen sets off just as a
-- dismissal does, so a leader hiding the box, or the player closing it, loses
-- nothing while the messages wait.
local _unread = {}

-- Texts of the messages the menu last opened on. Outlives the box's processed
-- report, so the menu can reopen on them when the box comes back from behind a
-- more urgent popup. Replaced by the next messages the menu opens on.
local _shownTexts = nil

-- True from the player's turn end to the start of their next turn.
local _betweenTurns = false

-- True while the box of the held messages is off the screen, to go back on
-- when the turn starts.
local _parked = false

-- True while messages are held for the player's next turn. A message still
-- waiting for its box, or a box already put back for the turn, isn't held, so
-- a second release at the turn start leaves it to show.
local _holding = false

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

-- Whether the player's turn is over, so a message waits for their next one. A
-- message their own end-of-turn moves raise reaches Lua before
-- ActivePlayerTurnEnd, so the game's flag counts too: CvPlayer::setTurnActive
-- clears it before announcing the turn's end, and sets it before processing
-- the next turn. Hotseat holds nothing: the next turn belongs to another
-- human, and an AI's diplomacy waits for a human's turn there, so no leader
-- cuts in during the AI turns.
local function turnOver()
    if PreGame.IsHotSeatGame() then
        return false
    end
    return _betweenTurns or not Players[Game.GetActivePlayer()]:IsTurnActive()
end

local function openMenu(texts)
    _shownTexts = texts
    HandlerStack.removeByName(MENU_NAME, false)
    local handler = BaseMenu.create({
        name = MENU_NAME,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"),
        preamble = Text.joinNonEmpty(texts, " "),
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
        return texts
    end)
    HandlerStack.push(handler)
end

-- Takes the unread messages' texts, oldest first, buffering each one not
-- buffered yet.
local function takeUnread()
    local texts = {}
    for i, entry in ipairs(_unread) do
        if not entry.buffered then
            MessageBuffer.append(entry.text, "notification")
        end
        texts[i] = entry.text
    end
    _unread = {}
    _holding = false
    if #texts > 1 then
        Log.debug("ShadowedTextPopupAnnounce: reading " .. #texts .. " messages, oldest first")
    end
    return texts
end

local function present()
    openMenu(takeUnread())
end

-- Puts the messages the menu last opened on back to unread, already buffered,
-- ahead of any still waiting: the end of the turn cut them short, so they are
-- read again as the next turn begins.
local function cutShort()
    for i, text in ipairs(_shownTexts) do
        table.insert(_unread, i, { text = text, buffered = true })
    end
    Log.debug(
        "ShadowedTextPopupAnnounce: your turn ended before the menu was done; read again as your next turn starts"
    )
end

-- A frame after a held message arrives or its box shows, or as the turn ends
-- with the menu open: takes the box off the screen until the player's turn
-- begins, and holds its messages. A turn that began meanwhile leaves the box
-- be, for the messages to be presented on it. Its hide reports it processed,
-- as a leader's greeting hiding it does, which closes the menu.
--
-- The menu can be open on messages from the player's end-of-turn moves, which
-- it opened in the frames before the game ended the turn, or a multiplayer
-- turn timer can run out while the player reads one. Those are cut short.
local function parkBox()
    if not turnOver() or not boxShowing() then
        return
    end
    if menuOpen() then
        cutShort()
    end
    _parked = true
    _holding = true
    Log.debug("ShadowedTextPopupAnnounce: took the held message's box off the screen until the turn starts")
    UIManager:DequeuePopup(lookUpBox())
end

-- A frame after the box showed with nothing unread. A new message the box
-- showed from inside its own listener has opened the menu on itself by now, so
-- a box still showing without the menu is back with the messages it showed.
-- If the player's turn ended meanwhile, they wait for the next one instead.
local function reopenOnReturnedBox()
    if #_unread == 0 and boxShowing() and not menuOpen() then
        if turnOver() then
            cutShort()
            parkBox()
        else
            openMenu(_shownTexts)
        end
    end
end

function ShadowedTextPopupAnnounce._onPopup(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TEXT or hookAlive() then
        return
    end
    local text = Text.key(popupInfo.Text)
    -- The box shows only its latest message, so this one joins any still held
    -- or waiting for the box, to be read after them.
    _unread[#_unread + 1] = { text = text, buffered = false }
    if turnOver() then
        _holding = true
        local why = _betweenTurns and "" or " (the game had already ended your turn)"
        Log.debug(
            "ShadowedTextPopupAnnounce: holding a message that arrived between turns" .. why .. ": " .. text:sub(1, 80)
        )
        TickPump.runOnce(parkBox)
        return
    end
    if boxShowing() then
        present()
    end
end

function ShadowedTextPopupAnnounce._onPopupShown()
    if #_unread > 0 then
        if turnOver() then
            TickPump.runOnce(parkBox)
        elseif boxShowing() then
            present()
        end
    elseif _shownTexts ~= nil then
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
    if menuOpen() then
        parkBox()
    end
end

local function releaseHold()
    local parked = _parked
    _parked = false
    if not _holding then
        return
    end
    _holding = false
    if boxShowing() then
        present()
        return
    end
    if parked then
        -- Put the box back. With nothing outranking it, the box shows inside
        -- this call, but its show reaches us a frame or more later, by when
        -- the turn-start announcements may have queued; so the menu opens on
        -- it at once. Behind another popup, the menu waits for the box to
        -- show.
        Log.debug("ShadowedTextPopupAnnounce: put the held message's box back for the turn")
        UIManager:QueuePopup(lookUpBox(), PopupPriority.TextPopup)
        if boxShowing() then
            present()
        end
        return
    end
    -- No box on screen: the game closed it while it waited, a key landed
    -- before it came off the screen, or it waits behind another popup. Read
    -- the messages either way; if the box comes back, the menu reopens on
    -- them.
    Log.debug("ShadowedTextPopupAnnounce: no box on screen at turn start; reading the held message")
    local texts = takeUnread()
    _shownTexts = texts
    SpeechPipeline.speakInterrupt(Text.joinNonEmpty(texts, " "))
end

-- Runs inside the game's turn processing, on the game-core thread rather than
-- the UI thread the screen belongs to: it only ends the hold, and the next
-- frame presents the held messages.
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
    _unread = {}
    _shownTexts = nil
    _betweenTurns = false
    _parked = false
    _holding = false
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

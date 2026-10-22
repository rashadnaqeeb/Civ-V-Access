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
-- A scenario script can also raise its message between the player's turns:
-- Scramble for Africa announces each natural wonder any explorer finds, so
-- an AI's find lands while the AIs still move and their leaders may cut
-- in after a few words. The game's own popups for the player's turn show once
-- it starts, so a message that arrives between ActivePlayerTurnEnd and
-- ActivePlayerTurnStart is held and presented when the turn starts. It speaks
-- queued there, behind the turn line Turn.lua queues, rather than cutting it
-- off. The box is on screen but silent while held, so the player may close it
-- unaware: a held message whose box is gone at turn start is read and
-- buffered all the same, and the menu opens on it if the box comes back.
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
-- the menu opens and when the box reports itself processed.
local _pending = nil

-- Text of the message the menu last opened on. Outlives the box's processed
-- report, so the menu can reopen on it when the box comes back from behind a
-- more urgent popup. Replaced by the next message the menu opens on.
local _shownText = nil

-- True from the player's turn end to the start of their next turn.
local _betweenTurns = false

-- The latest message that arrived between turns, presented at turn start.
-- Outlives the box's processed report: a leader can hide the box, or the
-- player close it, while the message waits.
local _held = nil

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

-- queued: speak behind whatever is already speaking rather than cutting it
-- off, for a held message opening at turn start beside the turn line.
local function openMenu(text, queued)
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
        -- Skips the name line, the only part of the opening that interrupts;
        -- the message and Close then queue.
        silentDisplayName = queued == true,
    })
    RewardReview.install(handler, function()
        return { text }
    end)
    HandlerStack.push(handler)
end

local function openPending(queued)
    local text = _pending
    _pending = nil
    MessageBuffer.append(text, "notification")
    openMenu(text, queued)
end

-- A frame after the box showed with no message pending. A new message the box
-- showed from inside its own listener has opened the menu on itself by now, so
-- a box still showing without the menu is back with the message it showed.
local function reopenOnReturnedBox()
    if _pending == nil and _shownText ~= nil and boxShowing() and not menuOpen() then
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
        return
    end
    _pending = text
    if boxShowing() then
        openPending()
    end
end

function ShadowedTextPopupAnnounce._onPopupShown()
    if _betweenTurns then
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
    _pending = nil
    HandlerStack.removeByName(MENU_NAME, true)
end

function ShadowedTextPopupAnnounce._onTurnEnd()
    _betweenTurns = true
end

function ShadowedTextPopupAnnounce._onTurnStart()
    _betweenTurns = false
    local text = _held
    if text == nil then
        return
    end
    _held = nil
    if boxShowing() then
        _pending = text
        openPending(true)
        return
    end
    -- No box on screen: the player closed it while it waited, or it waits
    -- behind another popup. Read it either way; if the box comes back, the
    -- menu reopens on it.
    MessageBuffer.append(text, "notification")
    _shownText = text
    SpeechPipeline.speakQueued(text)
end

function ShadowedTextPopupAnnounce.install()
    _pending = nil
    _shownText = nil
    _betweenTurns = false
    _held = nil
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
    Log.installEvent(
        Events,
        "ActivePlayerTurnStart",
        Log.safeListener("ShadowedTextPopupAnnounce.turnStart", ShadowedTextPopupAnnounce._onTurnStart),
        "ShadowedTextPopupAnnounce",
        "a message held between turns will not be read"
    )
    Log.info("ShadowedTextPopupAnnounce: installed")
end

-- ShadowedTextPopupAnnounce tests. A mod that ships its own TextPopup.lua (the
-- restyled Firaxis scenarios do) shadows our hooked copy, so its text popups
-- open with no hook: the box takes Enter and Esc itself and nothing tells the
-- player it is up. Unless the hook's liveness probe says TextPopupAccess owns
-- the popup, the announcer buffers the message and opens the same dismiss menu
-- the reward popups get (the message, then a Close button), closes it when the
-- box reports itself processed, and reopens it if the box comes back on screen
-- with the same messages. Outside hotseat, a message that arrives once the
-- player's turn is over waits for the start of their next turn, and every
-- message the box replaced before it was read is read with the one that
-- replaced it, oldest first. Real modules dofiled over the shared menu
-- harness: SpeechPipeline (capturing through _speakAction), TextFilter, Text,
-- BaseMenu, HandlerStack, MessageBuffer, RewardReview, ScenarioRegistry,
-- ShadowedTextPopupAnnounce, and TextPopupAccess for the probe it publishes.
-- Seams: the popup and turn events and PlayerDoTurn (their listeners are
-- captured so tests fire them in the game's order), the active player and the
-- game's flag for whether their turn is active, whether the game is hotseat,
-- the game's activated mods (American Civil War unless a test says otherwise),
-- the box's Context lookup (a stub whose hidden flag stands in for the popup
-- queue), UIManager, and the game text.

local T = require("support")
local Setup = require("menu_test_setup")
local M = {}

local speaks = Setup.speaks

local WM_KEYDOWN = 256
local MOD_ALT = 4

local TEXT_POPUP = 0
local OTHER_POPUP = 46

local EVENT_TEXT = "PRO-UNION EVENT: Emancipation Proclamation[NEWLINE][NEWLINE]Freedom proclaimed."

local CIVIL_WAR = "55fd836a-72e5-4aba-bbcf-3395b05a0e70"

local popupListeners, shownListeners, processedListeners, turnEndListeners, turnStartListeners, dequeued, queued, box
local debugs
local doTurnListeners
-- The game's flag for whether the active player's turn is active. It turns off
-- before ActivePlayerTurnEnd reaches Lua and on before that player's
-- PlayerDoTurn, as CvPlayer::setTurnActive does.
local turnActive
-- Whether the game is hotseat, where each turn goes to the next human.
local hotSeat

local function setup(activatedMods)
    Setup.fresh()
    activatedMods = activatedMods or { { ID = CIVIL_WAR, Version = 1 } }
    Modding.GetActivatedMods = function()
        return activatedMods
    end
    debugs = {}
    Log.debug = function(m)
        debugs[#debugs + 1] = m
    end
    T.installLocaleStrings({
        TXT_KEY_TEST_BRIEFING = "Brother against brother.",
        TXT_KEY_CLOSE = "Close",
    })
    include = function() end
    ButtonPopupTypes = ButtonPopupTypes or {}
    ButtonPopupTypes.BUTTONPOPUP_TEXT = TEXT_POPUP
    popupListeners, shownListeners, processedListeners, dequeued = {}, {}, {}, {}
    Events.SerialEventGameMessagePopup = {
        Add = function(fn)
            popupListeners[#popupListeners + 1] = fn
        end,
    }
    Events.SerialEventGameMessagePopupShown = {
        Add = function(fn)
            shownListeners[#shownListeners + 1] = fn
        end,
    }
    Events.SerialEventGameMessagePopupProcessed = {
        Add = function(fn)
            processedListeners[#processedListeners + 1] = fn
        end,
    }
    turnEndListeners, turnStartListeners = {}, {}
    Events.ActivePlayerTurnEnd = {
        Add = function(fn)
            turnEndListeners[#turnEndListeners + 1] = fn
        end,
    }
    Events.ActivePlayerTurnStart = {
        Add = function(fn)
            turnStartListeners[#turnStartListeners + 1] = fn
        end,
    }
    doTurnListeners = {}
    GameEvents = GameEvents or {}
    GameEvents.PlayerDoTurn = {
        Add = function(fn)
            doTurnListeners[#doTurnListeners + 1] = fn
        end,
    }
    Game.GetActivePlayer = function()
        return 0
    end
    turnActive = true
    -- Only the active player's turn follows the flag; any other player's reads
    -- the opposite, so a read of the wrong player shows.
    Players = setmetatable({}, {
        __index = function(_, iPlayer)
            return {
                IsTurnActive = function()
                    if iPlayer == Game.GetActivePlayer() then
                        return turnActive
                    end
                    return not turnActive
                end,
            }
        end,
    })
    hotSeat = false
    PreGame = PreGame or {}
    PreGame.IsHotSeatGame = function()
        return hotSeat
    end
    UIManager = UIManager or {}
    -- Dequeuing hides a Context, as the engine does; queuing only records the
    -- call, and a test shows the box itself when the queue would.
    UIManager.DequeuePopup = function(_, ctx)
        dequeued[#dequeued + 1] = ctx
        ctx.hidden = true
    end
    queued = {}
    UIManager.QueuePopup = function(_, ctx, priority)
        queued[#queued + 1] = { ctx = ctx, priority = priority }
    end
    PopupPriority = PopupPriority or {}
    PopupPriority.TextPopup = PopupPriority.TextPopup or 4
    -- The box shows as soon as it queues unless a test holds it back.
    box = { hidden = false }
    function box:IsHidden()
        return self.hidden
    end
    ContextPtr = {
        LookUpControl = function(_, path)
            if path == "/InGame/TextPopup" then
                return box
            end
            return nil
        end,
    }
    civvaccess_shared.textPopupHookProbe = nil
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    MessageBuffer._reset()
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_RewardReview.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_ScenarioRegistry.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ShadowedTextPopupAnnounce.lua")
    ShadowedTextPopupAnnounce.install()
end

local function firePopup(popupInfo)
    for _, fn in ipairs(popupListeners) do
        fn(popupInfo)
    end
end

-- The box passes nil: its m_PopupInfo is never assigned.
local function fireShown()
    for _, fn in ipairs(shownListeners) do
        fn(nil)
    end
end

local function fireProcessed(popupType)
    for _, fn in ipairs(processedListeners) do
        fn(popupType, 0)
    end
end

-- The game ends the turn: its flag goes off, then ActivePlayerTurnEnd reaches
-- Lua.
local function fireTurnEnd()
    turnActive = false
    for _, fn in ipairs(turnEndListeners) do
        fn()
    end
end

local function fireTurnStart()
    turnActive = true
    for _, fn in ipairs(turnStartListeners) do
        fn()
    end
end

-- The game runs PlayerDoTurn as each player's turn begins; the active
-- player's comes before ActivePlayerTurnStart, with their turn already active.
local function firePlayerDoTurn(iPlayer)
    if iPlayer == Game.GetActivePlayer() then
        turnActive = true
    end
    for _, fn in ipairs(doTurnListeners) do
        fn(iPlayer)
    end
end

-- The game has run the units' queued moves after End Turn and ended the turn,
-- and ActivePlayerTurnEnd hasn't reached Lua yet.
local function gameEndsTurn()
    turnActive = false
end

-- The game has begun the turn and processes it, before ActivePlayerTurnStart.
local function gameBeginsTurn()
    turnActive = true
end

-- A game loaded mid-session starts in the player's turn and installs afresh.
local function loadGame()
    turnActive = true
    ShadowedTextPopupAnnounce.install()
end

local function buffered()
    local state = MessageBuffer._snapshot()
    return state and state.entries or {}
end

local function spoken()
    local out = {}
    for i, s in ipairs(speaks) do
        out[i] = s.text
    end
    return table.concat(out, " | ")
end

-- Whether a debug line containing `fragment` was logged: the hold's steps are
-- logged so a session's Lua.log shows which path a message took.
local function logged(fragment)
    for _, m in ipairs(debugs) do
        if m:find(fragment, 1, true) then
            return true
        end
    end
    return false
end

-- What was spoken after the first `count` utterances.
local function spokenSince(count)
    local out = {}
    for i = count + 1, #speaks do
        out[#out + 1] = speaks[i].text
    end
    return table.concat(out, " | ")
end

-- A stand-in for the map handler the box opens over.
local function pushMap()
    HandlerStack.push(BaseMenu.create({
        name = "Map",
        displayName = "Map",
        items = { BaseMenuItems.Text({ labelText = "map" }) },
    }))
end

function M.test_opens_a_close_menu_for_a_shadowed_text_popup()
    setup()
    firePopup({ Type = TEXT_POPUP, Data1 = 500, Data2 = 1, Text = EVENT_TEXT })
    local menu = HandlerStack.active()
    T.eq(menu.name, "ShadowedTextPopup")
    T.eq(menu.displayName, "Notification", "named like the hooked text popup")
    T.eq(#menu._items, 1, "one dismiss button")
    T.eq(menu._items[1].labelText, "Close")
    T.eq(menu._items[1].verboseKindKey, "TXT_KEY_CIVVACCESS_KIND_BUTTON", "announced as a button")
    local said = spoken()
    T.truthy(said:find("Emancipation Proclamation", 1, true), "speaks the popup's message")
    T.truthy(said:find("Freedom proclaimed.", 1, true))
    T.truthy(said:find("Close", 1, true), "lands on Close")
    T.eq(said:find("[NEWLINE]", 1, true), nil, "markup is stripped before speech")
    T.eq(#buffered(), 1)
    T.eq(buffered()[1].text, EVENT_TEXT)
    T.eq(buffered()[1].category, "notification")
end

function M.test_closing_the_box_returns_to_the_map()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
    fireProcessed(TEXT_POPUP)
    T.eq(HandlerStack.active().name, "Map", "Enter or Esc on the box closes the menu with it")
end

function M.test_another_popup_closing_leaves_the_menu_open()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireProcessed(OTHER_POPUP)
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
end

function M.test_close_closes_the_box_the_way_its_button_does()
    setup()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    local menu = HandlerStack.active()
    menu._items[1]:activate(menu)
    T.eq(#dequeued, 1)
    T.eq(dequeued[1], box)
end

-- The box queues behind a popup already up, such as a chooser at turn start.
-- The menu must not open over that popup and take its keys.
function M.test_waits_for_a_queued_box_to_show()
    setup()
    pushMap()
    box.hidden = true
    local before = #speaks
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active().name, "Map", "no menu while the box waits in the queue")
    T.eq(#speaks, before)
    T.eq(#buffered(), 0)
    fireShown()
    T.eq(HandlerStack.active().name, "Map", "another popup showing is not the box")
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "opens once the box is on screen")
    T.truthy(spoken():find("Emancipation Proclamation", 1, true))
    T.eq(#buffered(), 1)
    fireShown()
    T.eq(#buffered(), 1, "a later show does not reopen the menu")
end

-- A more urgent popup can take the screen in the frame the box shows, so the
-- box reports itself processed before its show reaches the announcer. That
-- report looks like a dismissal, but the box is only waiting, and it comes back
-- with its message unread.
function M.test_a_box_pushed_aside_as_it_shows_keeps_its_message()
    setup()
    pushMap()
    box.hidden = true
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireProcessed(TEXT_POPUP)
    fireShown()
    T.eq(HandlerStack.active().name, "Map", "no menu while the box is off the screen")
    T.eq(#buffered(), 0)
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "the menu opens when the box comes back")
    T.truthy(spoken():find("Emancipation Proclamation", 1, true))
    T.eq(#buffered(), 1)
end

-- The box shows only its latest message, so a new one replaces any still
-- waiting. The menu reads both, oldest first, Alt+Down reviews them in that
-- order, and each is buffered as the menu opens.
function M.test_a_message_still_waiting_for_its_box_is_read_with_the_next()
    setup()
    pushMap()
    box.hidden = true
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireProcessed(TEXT_POPUP)
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    box.hidden = false
    fireShown()
    local said = spoken()
    local older = said:find("Emancipation Proclamation", 1, true)
    local newer = said:find("Blockade runner arrives.", 1, true)
    T.truthy(older and newer and older < newer, "both are read, oldest first")
    local entries = buffered()
    T.eq(#entries, 2, "each is buffered once")
    T.eq(entries[1].text, EVENT_TEXT, "in the order they came")
    T.eq(entries[2].text, "Blockade runner arrives.")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "PRO-UNION EVENT: Emancipation Proclamation", "the review starts at the oldest")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "Blockade runner arrives.", "and goes on to the newest")
end

-- A more urgent popup (an AI leader's greeting) can hide the box while its
-- menu is open and show it again once that popup closes. The hide reports the
-- box processed just as a dismissal does, so the menu closes with it; it must
-- come back with the box, or the box sits on screen silent and takes the
-- player's next Enter.
function M.test_reopens_when_the_box_comes_back_after_a_more_urgent_popup()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    fireProcessed(TEXT_POPUP)
    T.eq(HandlerStack.active().name, "Map", "the menu closes while the box is hidden")
    box.hidden = false
    local before = #speaks
    fireShown()
    TickPump.tick()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "the menu comes back with the box")
    T.truthy(spokenSince(before):find("Emancipation Proclamation", 1, true), "the message is read again")
    T.eq(#buffered(), 1, "but buffered only once")
    local after = #speaks
    fireShown()
    TickPump.tick()
    T.eq(#speaks, after, "a later show while the menu is open does not read it again")
end

-- A more urgent popup can push the box aside just before the turn ends. When
-- the box comes back during the other civs' turns, the menu doesn't reopen
-- there: the box comes off the screen, and the message is read again as the
-- next turn begins, without being buffered twice.
function M.test_a_box_back_after_your_turn_ends_waits_for_the_next_turn()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    fireProcessed(TEXT_POPUP)
    fireTurnEnd()
    box.hidden = false
    fireShown()
    TickPump.tick()
    T.eq(HandlerStack.active().name, "Map", "no menu during the other civs' turns")
    T.eq(#dequeued, 1, "the box comes off the screen")
    local before = #speaks
    firePlayerDoTurn(0)
    TickPump.tick()
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
    T.truthy(spokenSince(before):find("Emancipation Proclamation", 1, true), "read again as the turn begins")
    T.eq(#buffered(), 1, "buffered once")
end

function M.test_a_dismissed_box_does_not_come_back()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    fireProcessed(TEXT_POPUP)
    fireShown()
    TickPump.tick()
    T.eq(HandlerStack.active().name, "Map", "another popup showing does not bring back a closed box's menu")
end

-- The box can show its next message from inside its own popup listener, before
-- the announcer hears of that message. The menu must read the new message,
-- never the one the box showed before.
function M.test_a_new_message_is_read_instead_of_the_previous_one()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    fireProcessed(TEXT_POPUP)
    box.hidden = false
    local before = #speaks
    fireShown()
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    TickPump.tick()
    T.eq(HandlerStack.active().preamble, "Blockade runner arrives.")
    T.falsy(spokenSince(before):find("Emancipation", 1, true), "the previous message is not read again")
    T.eq(#buffered(), 2)
end

-- The reopen waits a frame, and a message can land in that frame while its box
-- is still queued. The box that shows then holds the new message.
function M.test_a_waiting_message_stops_the_reopen_of_the_one_before()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    fireProcessed(TEXT_POPUP)
    fireShown()
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    box.hidden = false
    local before = #speaks
    TickPump.tick()
    T.eq(spokenSince(before), "", "the earlier message is not read again")
    fireShown()
    T.eq(HandlerStack.active().preamble, "Blockade runner arrives.")
end

-- A scenario script can raise its message between your turns: Scramble for
-- Africa announces each natural wonder any explorer finds, so an AI's find
-- lands while the AIs still move and their leaders may cut in after a few
-- words. The game's own popups for your turn show once it starts, so such a
-- message waits for the start of your turn. Its box is taken off the screen
-- meanwhile, where no stray Enter or Esc can close it, and put back when your
-- turn starts, where its menu opens like any popup's.
function M.test_holds_a_message_that_arrives_between_turns_until_your_turn()
    setup()
    pushMap()
    local before = #speaks
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireShown()
    T.eq(HandlerStack.active().name, "Map", "nothing opens while the other civs take their turns")
    T.eq(#speaks, before)
    T.eq(#buffered(), 0)
    T.truthy(logged("holding a message that arrived between turns"), "the hold is logged")
    TickPump.tick()
    T.eq(#dequeued, 1, "the box is taken off the screen a frame after it shows")
    T.eq(dequeued[1], box)
    T.truthy(logged("off the screen"), "the park is logged")
    fireProcessed(TEXT_POPUP)
    fireTurnStart()
    T.eq(#queued, 1, "and put back when your turn starts")
    T.eq(queued[1].ctx, box)
    T.eq(queued[1].priority, PopupPriority.TextPopup, "at its own priority")
    T.truthy(logged("put the held message's box back"), "the put-back is logged")
    T.eq(HandlerStack.active().name, "Map", "the menu waits for the box to show")
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "the menu opens with the box")
    T.truthy(spokenSince(before):find("Emancipation Proclamation", 1, true))
    T.eq(#buffered(), 1)
    T.truthy(speaks[before + 1].interrupt, "opens like any popup")
end

-- A message from the player's own turn can still be waiting for its box when
-- the game ends the turn: End Turn ran the units' queued moves, which raised
-- it, or a multiplayer turn timer ran out. ActivePlayerTurnEnd may not have
-- reached Lua yet, but the game's own flag says the turn is over, so the box
-- that shows then is held like one from the other civs' turns.
function M.test_a_box_that_shows_after_the_game_ends_your_turn_is_held()
    setup()
    pushMap()
    box.hidden = true
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    gameEndsTurn()
    box.hidden = false
    local before = #speaks
    fireShown()
    T.eq(HandlerStack.active().name, "Map", "not opened during the other civs' turns")
    T.eq(spokenSince(before), "")
    TickPump.tick()
    T.eq(#dequeued, 1, "taken off the screen")
end

-- The units' queued moves run once End Turn is pressed, and the game ends the
-- turn a few frames later. A message they raise, an explorer's dig in Scramble
-- for Africa, can reach the announcer before ActivePlayerTurnEnd does. The
-- game's own flag already says the turn is over, so it is held.
function M.test_a_message_after_the_game_ends_your_turn_is_held()
    setup()
    pushMap()
    gameEndsTurn()
    local before = #speaks
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active().name, "Map", "not opened during the other civs' turns")
    T.eq(spokenSince(before), "")
    T.truthy(logged("the game had already ended your turn"), "the hold says why")
    TickPump.tick()
    T.eq(#dequeued, 1, "its box comes off the screen")
end

-- The menu can open on a message from the units' queued moves in the frames
-- before the game ends the turn. When the turn ends, the box comes off the
-- screen, which closes the menu, and the message is read again as the next turn
-- begins, without being buffered twice.
function M.test_a_menu_open_as_your_turn_ends_is_read_again_at_your_turn()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
    fireTurnEnd()
    TickPump.tick()
    T.eq(#dequeued, 1, "the box comes off the screen")
    T.truthy(logged("read again as your next turn starts"), "the cut is logged")
    fireProcessed(TEXT_POPUP)
    T.eq(HandlerStack.active().name, "Map", "and the menu closes with it")
    local before = #speaks
    firePlayerDoTurn(0)
    TickPump.tick()
    T.eq(#queued, 1, "the box goes back as your turn begins")
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
    T.truthy(spokenSince(before):find("Emancipation Proclamation", 1, true), "the message is read again")
    T.eq(#buffered(), 1, "but buffered once")
end

-- Two messages from the units' queued moves: the menu opens on the first in
-- the frames before the game ends the turn, and the second arrives after.
-- Taking the box off the screen for the second cuts the first short, so both
-- are read as the next turn begins, the first one first.
function M.test_a_menu_cut_short_by_a_held_message_is_read_ahead_of_it()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    gameEndsTurn()
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    TickPump.tick()
    T.eq(#dequeued, 1, "the box comes off the screen")
    fireProcessed(TEXT_POPUP)
    fireTurnEnd()
    local before = #speaks
    firePlayerDoTurn(0)
    TickPump.tick()
    box.hidden = false
    fireShown()
    local said = spokenSince(before)
    local older = said:find("Emancipation Proclamation", 1, true)
    local newer = said:find("Blockade runner arrives.", 1, true)
    T.truthy(older and newer and older < newer, "both are read, the cut one first")
    T.eq(#buffered(), 2, "each is buffered once")
end

-- Only a box this hold took off the screen goes back on it.
function M.test_a_later_hold_does_not_inherit_an_earlier_park()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    TickPump.tick()
    fireProcessed(TEXT_POPUP)
    fireTurnStart()
    T.eq(#queued, 1)
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    fireTurnStart()
    T.eq(#queued, 1, "this hold's box never came off the screen")
    T.truthy(spoken():find("Blockade runner", 1, true), "read all the same")
end

-- Only the supported scenarios replace the box in practice, so only there does
-- the module follow the game's turn processing. Every other game, single
-- player or multiplayer, runs without the listener.
function M.test_an_ordinary_game_never_follows_the_turn_processing()
    setup({})
    fireTurnEnd()
    fireTurnStart()
    T.eq(#doTurnListeners, 0)
    T.eq(logged("following the turn processing"), false)
end

-- With no listener on the turn processing, the hold lasts until
-- ActivePlayerTurnStart, though the game has begun the turn by then.
function M.test_elsewhere_the_hold_lasts_until_the_turn_start()
    setup({})
    pushMap()
    fireTurnEnd()
    gameBeginsTurn()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active().name, "Map", "held while the game processes the turn")
    fireTurnStart()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "read as the turn starts")
end

function M.test_a_supported_scenario_follows_the_turn_processing()
    setup()
    T.eq(#doTurnListeners, 1)
    T.truthy(logged("following the turn processing"), "the listener is logged")
end

-- The game begins the player's turn with its turn processing, which raises the
-- game's own popups for the turn (a great person born) before
-- ActivePlayerTurnStart queues the turn-start announcements. A message raised
-- there is no longer between turns, so it shows at once, as those popups do.
-- The active player here is not player 0, so the release follows the active
-- player rather than the first civ.
function M.test_a_message_raised_as_your_turn_begins_is_not_held()
    setup()
    Game.GetActivePlayer = function()
        return 3
    end
    pushMap()
    fireTurnEnd()
    firePlayerDoTurn(3)
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    TickPump.tick()
    T.eq(#dequeued, 0, "not taken off the screen")
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "opens at once")
end

-- In hotseat the next turn belongs to another human, and an AI's diplomacy
-- waits for a human's turn, so no leader cuts in during the AI turns. Nothing
-- is held: a message opens at once, for the human whose turn just ended.
function M.test_hotseat_holds_nothing()
    setup()
    hotSeat = true
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    TickPump.tick()
    T.eq(#dequeued, 0, "not taken off the screen")
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "opens at once")
end

-- The turn's own popups (a great person born, a chooser) can stand in front of
-- the box when it goes back. ActivePlayerTurnStart then finds the hold already
-- over: the box waits behind them, nothing is read over them, and the menu
-- opens once the box shows.
function M.test_a_box_put_back_behind_another_popup_waits_through_the_turn_start()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireShown()
    TickPump.tick()
    fireProcessed(TEXT_POPUP)
    firePlayerDoTurn(0)
    TickPump.tick()
    T.eq(#queued, 1, "put back, behind the popup in front")
    local before = #speaks
    fireTurnStart()
    T.eq(spokenSince(before), "", "nothing is read over that popup")
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "the menu opens once the box shows")
    T.eq(#buffered(), 1, "buffered once")
end

-- A message from the turn processing can still be waiting for its box behind
-- the turn's own popups when ActivePlayerTurnStart comes. It was never held,
-- so the turn start leaves it be, and its menu opens once the box shows.
function M.test_a_message_from_the_turn_processing_waits_behind_another_popup()
    setup()
    pushMap()
    fireTurnEnd()
    firePlayerDoTurn(0)
    TickPump.tick()
    box.hidden = true
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    local before = #speaks
    fireTurnStart()
    T.eq(spokenSince(before), "", "nothing is read over the popup in front")
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "the menu opens once the box shows")
end

-- The box shows one message at a time, so a message raised as the turn begins
-- joins one still held from the other civs' turns. The menu reads both, oldest
-- first, and the release that follows finds nothing left to put back.
function M.test_a_message_raised_as_your_turn_begins_is_read_after_a_held_one()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireShown()
    TickPump.tick()
    fireProcessed(TEXT_POPUP)
    firePlayerDoTurn(0)
    box.hidden = false
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    TickPump.tick()
    T.eq(HandlerStack.active().preamble, EVENT_TEXT .. " Blockade runner arrives.", "both, oldest first")
    T.eq(#queued, 0, "the held message's box is not put back")
    T.eq(#buffered(), 2, "each is buffered once")
end

-- A box parked through the other civs' turns goes back the moment the player's
-- turn begins, beside the game's own popups for the turn, not after the
-- turn-start announcements.
function M.test_a_parked_box_goes_back_as_your_turn_begins()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireShown()
    TickPump.tick()
    fireProcessed(TEXT_POPUP)
    firePlayerDoTurn(1)
    TickPump.tick()
    T.eq(#queued, 0, "another civ's turn beginning changes nothing")
    firePlayerDoTurn(0)
    T.eq(#queued, 0, "nothing touches the screen from inside the game's turn processing")
    TickPump.tick()
    T.eq(#queued, 1, "put back before ActivePlayerTurnStart")
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
    fireTurnStart()
    T.eq(#queued, 1, "the turn start finds nothing left to put back")
    T.eq(#buffered(), 1)
end

-- With nothing outranking it, the box shows inside the call that puts it
-- back, and its show reaches us a frame or more later. The menu opens at once,
-- ahead of the turn-start announcements, instead of waiting for that show.
function M.test_a_box_put_back_that_shows_at_once_opens_the_menu_at_once()
    setup()
    pushMap()
    UIManager.QueuePopup = function(_, ctx, priority)
        queued[#queued + 1] = { ctx = ctx, priority = priority }
        ctx.hidden = false
    end
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireShown()
    TickPump.tick()
    fireProcessed(TEXT_POPUP)
    firePlayerDoTurn(0)
    TickPump.tick()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "opens without waiting for the show")
    fireShown()
    TickPump.tick()
    T.eq(#buffered(), 1, "the late show adds nothing")
end

-- The park waits a frame; a turn that begins in that frame keeps the box on
-- screen, and the menu opens on it at once.
function M.test_a_turn_beginning_before_the_park_keeps_the_box()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    local before = #speaks
    firePlayerDoTurn(0)
    TickPump.tick()
    T.eq(#dequeued, 0)
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
    T.truthy(#speaks > before, "the message is read")
    T.truthy(speaks[before + 1].interrupt, "opens like any popup, ahead of the turn-start announcements")
end

-- Two messages can arrive during the same AI turns, two explorers' finds in
-- Scramble for Africa, or an explorer's dig at the end of the player's turn
-- and an AI's find. The first box comes off the screen, which reports it
-- processed, so the game shows the second, and the box goes back for the turn
-- with only that one on it. The menu reads both, oldest first.
function M.test_every_message_held_through_the_ai_turns_is_read_oldest_first()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireShown()
    TickPump.tick()
    fireProcessed(TEXT_POPUP)
    box.hidden = false
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    fireShown()
    TickPump.tick()
    fireProcessed(TEXT_POPUP)
    local before = #speaks
    firePlayerDoTurn(0)
    TickPump.tick()
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
    local said = spokenSince(before)
    local older = said:find("Emancipation Proclamation", 1, true)
    local newer = said:find("Blockade runner arrives.", 1, true)
    T.truthy(older and newer and older < newer, "both are read, oldest first")
    T.truthy(logged("reading 2 messages, oldest first"), "the count is logged")
    local entries = buffered()
    T.eq(#entries, 2)
    T.eq(entries[1].text, EVENT_TEXT, "buffered in the order they came")
    T.eq(entries[1].category, "notification")
    T.eq(entries[2].text, "Blockade runner arrives.")
end

-- A message from the player's own turn can still be waiting for its box when
-- the turn ends, and a message from the AI turns then joins it. With no box on
-- screen as the turn begins, both are read, oldest first, and the menu opens
-- on both when the box shows. Each message is buffered once.
function M.test_held_messages_with_no_box_at_your_turn_are_all_read()
    setup()
    pushMap()
    box.hidden = true
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    TickPump.tick()
    local before = #speaks
    firePlayerDoTurn(0)
    TickPump.tick()
    local said = spokenSince(before)
    local older = said:find("Emancipation Proclamation", 1, true)
    local newer = said:find("Blockade runner arrives.", 1, true)
    T.truthy(older and newer and older < newer, "both are read, oldest first")
    box.hidden = false
    fireShown()
    TickPump.tick()
    T.eq(HandlerStack.active().preamble, EVENT_TEXT .. " Blockade runner arrives.", "the menu opens on both")
    local entries = buffered()
    T.eq(#entries, 2, "each message buffered once")
    T.eq(entries[1].text, EVENT_TEXT)
    T.eq(entries[2].text, "Blockade runner arrives.")
end

-- A popup of the player's turn (Who's Winning) can take the screen just as the
-- box goes back. The box shows and hides at once, and its show reaches the
-- announcer with the box already hidden. The held message is still unread when
-- the box comes back.
function M.test_a_held_message_outlasts_a_popup_that_takes_its_box_back()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireShown()
    TickPump.tick()
    fireProcessed(TEXT_POPUP)
    fireTurnStart()
    fireProcessed(TEXT_POPUP)
    fireShown()
    fireShown()
    T.eq(HandlerStack.active().name, "Map", "no menu over the popup that took the screen")
    T.eq(#buffered(), 0)
    local before = #speaks
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "the menu opens when the box comes back")
    T.truthy(spokenSince(before):find("Emancipation Proclamation", 1, true))
    T.eq(#buffered(), 1)
    T.truthy(speaks[before + 1].interrupt, "opens like any popup")
end

function M.test_does_not_reopen_an_earlier_message_while_a_new_one_waits()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    fireProcessed(TEXT_POPUP)
    fireTurnEnd()
    box.hidden = false
    local before = #speaks
    firePopup({ Type = TEXT_POPUP, Text = "The Ottomans now hold the longest railroad." })
    fireShown()
    TickPump.tick()
    T.eq(HandlerStack.active().name, "Map")
    T.eq(spokenSince(before), "", "neither the earlier message nor the new one is read yet")
    fireTurnStart()
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().preamble, "The Ottomans now hold the longest railroad.")
end

-- A held box can still go before it comes off the screen: the game closes it,
-- or a stray key lands in the frame before. The message is still the player's
-- to hear when their turn starts.
function M.test_a_held_message_whose_box_closed_is_still_read_at_your_turn()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    fireProcessed(TEXT_POPUP)
    local before = #speaks
    fireTurnStart()
    T.eq(HandlerStack.active().name, "Map", "no box on screen, so no menu")
    T.truthy(spokenSince(before):find("Emancipation Proclamation", 1, true), "read all the same")
    T.truthy(speaks[before + 1].interrupt, "read with an interrupt, as a popup's opening is")
    T.eq(#buffered(), 1)
    T.truthy(logged("no box on screen at turn start"), "the read without a box is logged")
    box.hidden = false
    fireShown()
    TickPump.tick()
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "a box that was only waiting gets its menu when it shows")
    T.eq(#buffered(), 1)
end

function M.test_a_new_game_does_not_inherit_the_hold()
    setup()
    pushMap()
    fireTurnEnd()
    loadGame()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "a game loaded after a turn ended starts unheld")
end

function M.test_a_new_game_does_not_inherit_a_held_message()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    loadGame()
    local before = #speaks
    fireTurnStart()
    T.eq(spokenSince(before), "")
    T.eq(#Setup.errors, 0, "and the turn start finds nothing held")
end

function M.test_a_new_game_does_not_inherit_a_parked_box()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    TickPump.tick()
    loadGame()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    fireTurnStart()
    T.eq(#queued, 0)
end

-- Neither a message waiting for its box nor the last one read carries over: a
-- box that shows in the new game holds nothing of the old one.
function M.test_a_new_game_does_not_inherit_a_message_for_its_box()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    fireProcessed(TEXT_POPUP)
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    loadGame()
    box.hidden = false
    fireShown()
    TickPump.tick()
    T.eq(HandlerStack.active().name, "Map")
    T.eq(#Setup.errors, 0, "and the show finds nothing to reopen")
end

function M.test_close_with_no_box_on_screen_closes_the_menu()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    box.hidden = true
    local menu = HandlerStack.active()
    menu._items[1]:activate(menu)
    T.eq(#dequeued, 0, "nothing to dequeue")
    T.eq(HandlerStack.active().name, "Map", "no processed event will come, so Close closes the menu")
end

function M.test_esc_that_reaches_the_menu_closes_it()
    setup()
    pushMap()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(HandlerStack.active().name, "Map", "the player is never stuck in the menu")
end

function M.test_stays_silent_while_the_hook_is_alive()
    setup()
    civvaccess_shared.textPopupHookProbe = function()
        return true
    end
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active(), nil, "TextPopupAccess opens its own menu instead")
    T.eq(#speaks, 0)
    T.eq(#buffered(), 0)
end

function M.test_opens_when_the_hooks_env_is_gone()
    setup()
    civvaccess_shared.textPopupHookProbe = function()
        return false
    end
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(
        HandlerStack.active().name,
        "ShadowedTextPopup",
        "a probe left over from an earlier game no longer vouches for the hook"
    )
end

function M.test_opens_when_the_hook_probe_throws()
    setup()
    civvaccess_shared.textPopupHookProbe = function()
        error("attempt to index a nil value")
    end
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active().name, "ShadowedTextPopup")
    T.eq(#Setup.errors, 1, "the probe failure is logged")
end

function M.test_ignores_other_popup_types()
    setup()
    firePopup({ Type = OTHER_POPUP, Data1 = 1, Data2 = -1, Text = EVENT_TEXT })
    T.eq(HandlerStack.active(), nil)
    T.eq(#speaks, 0)
    T.eq(#buffered(), 0)
end

function M.test_resolves_a_text_key_the_way_the_popup_does()
    setup()
    firePopup({ Type = TEXT_POPUP, Text = "TXT_KEY_TEST_BRIEFING" })
    T.eq(HandlerStack.active().preamble, "Brother against brother.")
    T.eq(buffered()[1].text, "Brother against brother.")
end

-- The probe TextPopupAccess publishes reads its own Context's env: alive while
-- that env stands, dead once the engine wipes it on game exit or load.
function M.test_text_popup_access_publishes_a_live_probe()
    setup()
    Controls = {
        DescriptionLabel = Polyfill.makeLabel("A message."),
        CloseButton = Polyfill.makeButton(),
    }
    InputHandler = function() end
    ShowHideHandler = function() end
    OnCloseButtonClicked = function() end
    local ctx = Setup.makeContextPtr()
    local realInstall = BaseMenu.install
    BaseMenu.install = function(_, spec)
        return realInstall(ctx, spec)
    end
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_TextPopupAccess.lua")
    BaseMenu.install = realInstall
    local probe = civvaccess_shared.textPopupHookProbe
    T.truthy(probe ~= nil and probe(), "alive while its env stands")
    local baseMenu = BaseMenu
    BaseMenu = nil
    local alive = probe()
    BaseMenu = baseMenu
    T.falsy(alive, "dead once the env's globals are gone")
end

return M

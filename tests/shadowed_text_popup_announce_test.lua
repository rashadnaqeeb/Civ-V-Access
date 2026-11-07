-- ShadowedTextPopupAnnounce tests. A mod that ships its own TextPopup.lua (the
-- restyled Firaxis scenarios do) shadows our hooked copy, so its text popups
-- open with no hook: the box takes Enter and Esc itself and nothing tells the
-- player it is up. Unless the hook's liveness probe says TextPopupAccess owns
-- the popup, the announcer buffers the message and opens the same dismiss menu
-- the reward popups get (the message, then a Close button), closes it when the
-- box reports itself processed, and reopens it if the box comes back on screen
-- with the same message. A message that arrives between the player's turns
-- waits for the start of their turn. Real modules dofiled over the shared menu
-- harness: SpeechPipeline (capturing through _speakAction), TextFilter, Text,
-- BaseMenu, HandlerStack, MessageBuffer, RewardReview, ScenarioRegistry,
-- ShadowedTextPopupAnnounce, and TextPopupAccess for the probe it publishes.
-- Seams: the popup and turn events and PlayerDoTurn (their listeners are
-- captured so tests fire them in the game's order), the active player, the
-- game's activated mods (American Civil War unless a test says otherwise), the
-- box's Context lookup (a stub whose hidden flag stands in for the popup
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

local function fireTurnEnd()
    for _, fn in ipairs(turnEndListeners) do
        fn()
    end
end

local function fireTurnStart()
    for _, fn in ipairs(turnStartListeners) do
        fn()
    end
end

-- The game runs PlayerDoTurn as each player's turn begins; the active
-- player's comes before ActivePlayerTurnStart.
local function firePlayerDoTurn(iPlayer)
    for _, fn in ipairs(doTurnListeners) do
        fn(iPlayer)
    end
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
-- waiting and the older one can't be read over it.
function M.test_a_new_message_replaces_one_still_waiting_for_its_box()
    setup()
    pushMap()
    box.hidden = true
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireProcessed(TEXT_POPUP)
    firePopup({ Type = TEXT_POPUP, Text = "Blockade runner arrives." })
    box.hidden = false
    fireShown()
    T.eq(HandlerStack.active().preamble, "Blockade runner arrives.")
    T.falsy(spoken():find("Emancipation", 1, true), "the replaced message is not read")
    T.eq(#buffered(), 1)
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

-- A box that waits behind a leader's greeting shows once the talk is over, and
-- comes off the screen then.
function M.test_parks_a_box_that_shows_later_between_turns()
    setup()
    pushMap()
    fireTurnEnd()
    box.hidden = true
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    TickPump.tick()
    T.eq(#dequeued, 0, "nothing on screen to take off yet")
    box.hidden = false
    fireShown()
    TickPump.tick()
    T.eq(#dequeued, 1, "taken off once it shows")
end

-- A message from the player's own turn whose box only shows once that turn
-- has ended (a multiplayer turn timer ran out while it waited behind another
-- popup) is not held, so its box stays up and the menu opens on it.
function M.test_a_box_from_your_turn_that_shows_after_it_ends_is_read()
    setup()
    pushMap()
    box.hidden = true
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    fireTurnEnd()
    box.hidden = false
    fireShown()
    TickPump.tick()
    T.eq(#dequeued, 0, "not taken off the screen")
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "read once it shows")
end

-- The box can show from inside its own popup listener, before the announcer
-- hears of the message, so the message starts the park too.
function M.test_parks_a_box_already_up_when_its_message_arrives()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    TickPump.tick()
    T.eq(#dequeued, 1)
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

function M.test_a_supported_scenario_follows_the_turn_processing()
    setup()
    T.eq(#doTurnListeners, 1)
    T.truthy(logged("following the turn processing"), "the listener is logged")
end

-- The game begins the player's turn with its turn processing, which raises the
-- game's own popups for the turn (a great person born) before
-- ActivePlayerTurnStart queues the turn-start announcements. A message raised
-- there is no longer between turns, so it shows at once, as those popups do.
-- The active player here is not player 0, as for the second human in hotseat.
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

-- The box shows one message at a time, so a message raised as the turn begins
-- replaces one still held from the other civs' turns.
function M.test_a_message_raised_as_your_turn_begins_replaces_a_held_one()
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
    T.eq(HandlerStack.active().preamble, "Blockade runner arrives.")
    T.eq(#queued, 0, "the replaced message's box is not put back")
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
    ShadowedTextPopupAnnounce.install()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    T.eq(HandlerStack.active().name, "ShadowedTextPopup", "a game loaded after a turn ended starts unheld")
end

function M.test_a_new_game_does_not_inherit_a_held_message()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    ShadowedTextPopupAnnounce.install()
    local before = #speaks
    fireTurnStart()
    T.eq(spokenSince(before), "")
end

function M.test_a_new_game_does_not_inherit_a_parked_box()
    setup()
    pushMap()
    fireTurnEnd()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    TickPump.tick()
    ShadowedTextPopupAnnounce.install()
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
    ShadowedTextPopupAnnounce.install()
    box.hidden = false
    fireShown()
    TickPump.tick()
    T.eq(HandlerStack.active().name, "Map")
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

function M.test_alt_down_reviews_the_message_line_by_line()
    setup()
    firePopup({ Type = TEXT_POPUP, Text = EVENT_TEXT })
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "PRO-UNION EVENT: Emancipation Proclamation")
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
    firePopup({ Type = OTHER_POPUP, Data1 = 1, Data2 = -1 })
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

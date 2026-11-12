-- ChoosePantheonPopup wrapper tests. The real wrapper loads with
-- BaseMenu.install captured and its popup listener fired. Pins that a pick
-- the screen confirms opens the confirm menu, as in the base game, and that a
-- pick the screen takes without a confirm (the first of the Maya's two
-- beliefs in Conquest of the New World Deluxe) lists the other beliefs again
-- and reads the screen's own lines for the next pick. The base game's screen,
-- which has none of those lines, reads its title alone.

local T = require("support")
local M = {}

local FOUND_PANTHEON = 77

local BELIEFS = {
    [10] = { ID = 10, ShortDescription = "Sun God", Description = "Sun" },
    [11] = { ID = 11, ShortDescription = "Rain God", Description = "Rain" },
    [12] = { ID = 12, ShortDescription = "Moon God", Description = "Moon" },
}

local spec
local handler
local listener
local pushes

-- A screen control whose text and visibility the screen's functions change.
local function control(text, hidden)
    local c = { _text = text or "", _hidden = hidden == true }
    function c:GetText()
        return self._text
    end
    function c:SetText(s)
        self._text = s
    end
    function c:IsHidden()
        return self._hidden
    end
    function c:SetHide(h)
        self._hidden = h
    end
    return c
end

-- The base game's screen: every pick shows the confirm overlay.
local function baseScreen()
    Controls = { PanelTitle = control("Found a Pantheon"), ChooseConfirm = control("", true) }
    SelectPantheon = function()
        Controls.ChooseConfirm:SetHide(false)
    end
end

-- Conquest of the New World Deluxe's screen as the Maya see it: the first
-- pick names the first belief and asks for a second; the second pick shows
-- the confirm overlay.
local function mayaScreen()
    Controls = {
        PanelTitle = control("Found a Religion"),
        ChooseConfirm = control("", true),
        Belief1Label = control("Belief 1 Name", true),
        ChooseBelief1 = control("Choose First Belief", false),
        ChooseBelief2 = control("Choose Second Belief", true),
    }
    local first
    SelectPantheon = function(beliefID)
        if first == nil then
            first = beliefID
            Controls.Belief1Label:SetText("First Belief -- " .. BELIEFS[beliefID].ShortDescription)
            Controls.Belief1Label:SetHide(false)
            Controls.ChooseBelief1:SetHide(true)
            Controls.ChooseBelief2:SetHide(false)
        else
            Controls.ChooseConfirm:SetHide(false)
        end
    end
end

local function load(screen)
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")

    include = function() end
    InputHandler = nil
    ShowHideHandler = nil
    screen()
    OnYes = function() end
    pushes = {}
    ChooseConfirmSub = {
        push = function(opts)
            pushes[#pushes + 1] = opts
        end,
    }
    BeliefAdvisor = {
        labelSuffixes = function()
            return {}
        end,
    }
    Game = Game or {}
    Game.GetAvailablePantheonBeliefs = function()
        return { 10, 11, 12 }
    end
    GameInfo = GameInfo or {}
    GameInfo.Beliefs = BELIEFS
    ButtonPopupTypes = ButtonPopupTypes or {}
    ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON = FOUND_PANTHEON
    Events = Events or {}
    Events.SerialEventGameMessagePopup = {
        Add = function(fn)
            listener = fn
        end,
    }

    spec = nil
    handler = { refreshes = 0 }
    function handler.setItems(items)
        handler.items = items
    end
    function handler.refresh()
        handler.refreshes = handler.refreshes + 1
    end
    BaseMenu = {
        install = function(_ctx, s)
            spec = s
            return handler
        end,
    }
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_ChoosePantheonPopupAccess.lua")
    listener({ Type = FOUND_PANTHEON, Data2 = 1 })
end

local function labels()
    local out = {}
    for i, item in ipairs(handler.items) do
        out[i] = item.labelText
    end
    return table.concat(out, " | ")
end

local function pick(name)
    for _, item in ipairs(handler.items) do
        if item.labelText == name then
            item:activate(handler)
            return
        end
    end
    error("no belief named " .. name)
end

function M.test_a_pick_the_screen_confirms_opens_the_confirm_menu()
    load(baseScreen)
    pick("Sun God")
    T.eq(#pushes, 1)
end

function M.test_a_pick_taken_without_a_confirm_lists_the_other_beliefs()
    load(mayaScreen)
    pick("Sun God")
    T.eq(#pushes, 0, "no confirm menu over a hidden overlay")
    T.eq(labels(), "Moon God | Rain God")
    T.eq(handler.refreshes, 1, "the screen's new lines are read")
end

-- The screen starts each popup afresh, so a belief taken in an earlier popup
-- is offered again.
function M.test_a_new_popup_lists_every_belief_again()
    load(mayaScreen)
    pick("Sun God")
    listener({ Type = FOUND_PANTHEON, Data2 = 1 })
    T.eq(labels(), "Moon God | Rain God | Sun God")
end

-- The base game's screen has none of the Maya's pick lines, so its title is
-- the whole preamble.
function M.test_the_preamble_on_the_base_screen_is_its_title()
    load(baseScreen)
    T.eq(spec.preamble(), "Found a Pantheon")
end

function M.test_the_preamble_reads_the_screens_lines_for_the_next_pick()
    load(mayaScreen)
    T.eq(spec.preamble(), "Found a Religion, Choose First Belief")
    pick("Sun God")
    T.eq(spec.preamble(), "Found a Religion, First Belief -- Sun God, Choose Second Belief")
end

return M

-- ReligionOverview wrapper tests for the shapes of screen the wrapper runs
-- in. The real wrapper loads with TabbedShell captured, and its onShow
-- builds every tab against a stubbed engine. Pins that the Your Religion tab
-- offers the automatic faith purchase menu where the screen has one, and
-- leaves it out, with no warning, where the screen has none, as in
-- Conquest of the New World Deluxe's own copy of the screen. The faith
-- readout, its sources and the Great People follow their controls the same
-- way, and that copy has none of them. It also counts a European side's
-- church as its religion, though only Spain and England found theirs, and
-- words the status line itself; the tab reads both from the screen. In that
-- scenario the tab also reads the scenario's note on how religion works
-- there, which no other supported scenario has.

local T = require("support")
local M = {}

local NEW_WORLD_DELUXE = "34fb6c19-10dd-4b65-b143-fd00b2c0826f"
local CIVIL_WAR = "55fd836a-72e5-4aba-bbcf-3395b05a0e70"
local RELIGION_NOTE = "TXT_KEY_NEWWORLD_SCENARIO_TP_RELIGION_TOOLTIP"

local tabs
local spec
local warnings

-- The functions a copy of the screen defines that the wrapper may call. The
-- stock copy has its own status line too.
local STOCK_SCREEN = {
    GetReligiousStatus = function()
        return "the stock screen's status line"
    end,
}

-- Load the wrapper over the given screen controls and copy of the screen, in
-- a game running the given mods (an ordinary game by default).
local function load(controls, screen, mods)
    screen = screen or STOCK_SCREEN
    warnings = {}
    Log.warn = function(msg)
        warnings[#warnings + 1] = msg
    end
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
    Modding = Modding or {}
    Modding.GetActivatedMods = function()
        return mods or {}
    end
    dofile("src/dlc/UI/Shared/CivVAccess_ScenarioRegistry.lua")

    include = function() end
    InputHandler = nil
    ShowHideHandler = nil
    GetMyReligion = screen.GetMyReligion
    GetReligiousStatus = screen.GetReligiousStatus
    Controls = controls
    ContextPtr = {
        SetShowHideHandler = function() end,
        IsHidden = function()
            return false
        end,
    }
    PullDownProbe = { installFromControls = function() end }
    tabs = {}
    spec = nil
    TabbedShell = {
        menuTab = function(tabSpec)
            local tab = { name = tabSpec.tabName }
            local menu = {
                setItems = function(items)
                    tab.items = items
                end,
            }
            tab.menu = function()
                return menu
            end
            tabs[#tabs + 1] = tab
            return tab
        end,
        install = function(_ctx, s)
            spec = s
        end,
    }
    Events = Events or {}
    Events.SerialEventCityInfoDirty = { Add = function() end }

    -- One civ, with no pantheon and no religion, and faith from its cities.
    GameDefines = GameDefines or {}
    GameDefines.MAX_CIV_PLAYERS = 1
    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    Game.IsCustomModOption = nil
    Players = {
        [0] = {
            GetID = function()
                return 0
            end,
            IsEverAlive = function()
                return true
            end,
            GetTeam = function()
                return 0
            end,
            HasCreatedPantheon = function()
                return false
            end,
            CanCreatePantheon = function()
                return false
            end,
            GetFaith = function()
                return 12
            end,
            GetMinimumFaithNextGreatProphet = function()
                return 1000000
            end,
            GetFaithPerTurnFromCities = function()
                return 3
            end,
            GetFaithPerTurnFromMinorCivs = function()
                return 0
            end,
            GetFaithPerTurnFromReligion = function()
                return 0
            end,
            GetCapitalCity = function()
                return nil
            end,
        },
    }
    Teams = { [0] = {} }
    EngineData = EngineData or {}
    EngineData.ownedReligion = function()
        return -1
    end

    dofile("src/dlc/UI/InGame/Popups/CivVAccess_ReligionOverviewAccess.lua")
    spec.onShow({ _initialized = false })
end

local function yourReligionHasPurchaseMenu()
    for _, item in ipairs(tabs[1].items) do
        if item.kind == "pulldown" then
            return true
        end
    end
    return false
end

function M.test_your_religion_offers_the_purchase_menu_the_screen_has()
    load({ AutomaticPurchasePD = Polyfill.makePullDown() })
    T.truthy(yourReligionHasPurchaseMenu())
end

function M.test_your_religion_leaves_out_the_purchase_menu_the_screen_lacks()
    load({})
    T.eq(yourReligionHasPurchaseMenu(), false)
    for _, msg in ipairs(warnings) do
        T.eq(msg:find("missing control", 1, true), nil, "no missing-control warning: " .. msg)
    end
end

-- What the Your Religion tab says, item by item.
local function yourReligionText()
    local out = {}
    for _, item in ipairs(tabs[1].items) do
        local label = item.labelText
        if label == nil and item.labelFn ~= nil then
            label = item.labelFn()
        end
        out[#out + 1] = tostring(label)
    end
    return table.concat(out, " | ")
end

-- The faith line, its sources and the Great People the screen lists.
local FAITH_ROWS = { "TXT_KEY_RO_FAITH", "TXT_KEY_TP_FAITH_FROM_CITIES", "TXT_KEY_RO_POSSIBLE_GP" }

function M.test_your_religion_reads_the_faith_and_great_people_the_screen_shows()
    load({
        CurrentFaith = Polyfill.makeLabel(""),
        FaithModifierStack = Polyfill.makeLabel(""),
        GreatPersonList = Polyfill.makeLabel(""),
    })
    local text = yourReligionText()
    for _, key in ipairs(FAITH_ROWS) do
        T.truthy(text:find(key, 1, true), key .. " read in: " .. text)
    end
end

-- Conquest of the New World Deluxe's copy shows none of them: Great Prophets
-- are off in that scenario.
function M.test_your_religion_leaves_out_the_faith_and_great_people_the_screen_lacks()
    load({})
    local text = yourReligionText()
    for _, key in ipairs(FAITH_ROWS) do
        T.eq(text:find(key, 1, true), nil, key .. " left out of: " .. text)
    end
end

-- Each of those rows follows its own control, in FAITH_ROWS order.
function M.test_each_faith_row_follows_its_own_control()
    for i, control in ipairs({ "CurrentFaith", "FaithModifierStack", "GreatPersonList" }) do
        load({ [control] = Polyfill.makeLabel("") })
        local text = yourReligionText()
        for j, key in ipairs(FAITH_ROWS) do
            T.eq(text:find(key, 1, true) ~= nil, i == j, key .. " with only " .. control .. ": " .. text)
        end
    end
end

-- Conquest of the New World Deluxe's copy, playing France: France founded
-- nothing, and the screen counts England's church as theirs.
local CHURCH = 5

local function loadNewWorldDeluxe()
    Game = Game or {}
    Game.GetBeliefsInReligion = function(eReligion)
        if eReligion == CHURCH then
            return { 20, 21 }
        end
        return {}
    end
    GameInfo = GameInfo or {}
    GameInfo.Beliefs = {
        [20] = { Founder = true, ShortDescription = "Tithe", Description = "Tithe description" },
        [21] = { Follower = true, ShortDescription = "Meeting Houses", Description = "Meeting Houses description" },
    }
    GameInfo.Religions = { [CHURCH] = { Description = "Protestantism" } }
    load({}, {
        GetMyReligion = function(iPlayer)
            return iPlayer == 0 and CHURCH or -1
        end,
        GetReligiousStatus = function()
            return "Founder of Protestantism"
        end,
    }, { { ID = NEW_WORLD_DELUXE } })
end

function M.test_your_religion_lists_the_beliefs_of_the_church_the_screen_counts_as_yours()
    loadNewWorldDeluxe()
    local listed = {}
    for _, item in ipairs(tabs[1].items) do
        if item.pediaName ~= nil then
            listed[item.pediaName] = true
        end
    end
    T.truthy(listed["Tithe"])
    T.truthy(listed["Meeting Houses"])
end

function M.test_your_religion_status_is_the_screens_own_line()
    loadNewWorldDeluxe()
    T.eq(tabs[1].items[1].labelText, "Founder of Protestantism")
end

function M.test_your_religion_status_keeps_its_own_wording_on_the_stock_screen()
    load({})
    T.eq(tabs[1].items[1].labelText, "TXT_KEY_RO_STATUS_TOO_LATE")
end

function M.test_your_religion_status_opens_the_church_in_the_pedia()
    loadNewWorldDeluxe()
    T.eq(tabs[1].items[1].pediaNameFn(), "Protestantism")
end

-- The scenario's top bar shows its note on how religion works there in the
-- faith tooltip, and its briefing points players to it; Your Religion reads
-- it after the church's beliefs.
function M.test_your_religion_reads_the_scenarios_religion_note()
    loadNewWorldDeluxe()
    local items = tabs[1].items
    T.eq(items[#items].labelText, RELIGION_NOTE)
end

-- A supported scenario without such a note reads as an ordinary game does.
function M.test_your_religion_reads_no_note_in_a_scenario_without_one()
    load({})
    local ordinary = yourReligionText()
    load({}, nil, { { ID = CIVIL_WAR } })
    T.eq(yourReligionText(), ordinary)
end

return M

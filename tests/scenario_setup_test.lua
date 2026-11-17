-- Scenario setup screen wrapper tests. The screen is the Custom entry point a
-- Firaxis BNW scenario launches into (American Civil War): pick a side, pick
-- a difficulty, Start. Loads the real wrapper over the real BaseMenu /
-- HandlerStack stack. The base screen's globals
-- (SetPlayerIndex, DifficultySelected, OnBack, ktScenarioCivilizations, the
-- difficulty entries the vendor override promotes) and the engine's DB /
-- GameInfo are stubbed as the external boundary they are, the same way engine
-- globals are. Pins what each chooser offers and marks selected, that a choice
-- commits through the screen's own functions, and that Start and Back reach
-- the screen's own handlers.

local T = require("support")
local Setup = require("menu_test_setup")
local M = {}

local WM_KEYDOWN = 256
local errors = Setup.errors

-- Setup menu rows, in the order the wrapper lists them.
local CIV, DIFFICULTY, INTRO, START, BACK = 1, 2, 3, 4, 5

local TEXT = {
    TXT_KEY_RANDOM_LEADER = "Random Leader",
    TXT_KEY_RANDOM_CIV = "Random Civilization",
    TXT_KEY_RANDOM_LEADER_HELP = "A random leader",
    TXT_KEY_LEADER_LINCOLN = "Abraham Lincoln",
    TXT_KEY_CIV_UNION = "Union",
    TXT_KEY_LEADER_DAVIS = "Jefferson Davis",
    TXT_KEY_CIV_CONFEDERACY = "Confederacy",
    TXT_KEY_HANDICAP_SETTLER = "Settler",
    TXT_KEY_HANDICAP_SETTLER_HELP = "Easiest",
    TXT_KEY_HANDICAP_PRINCE = "Prince",
    TXT_KEY_HANDICAP_PRINCE_HELP = "Balanced",
    TXT_KEY_HANDICAP_AI_DEFAULT = "AI Default",
    TXT_KEY_START_GAME = "Start Game",
    TXT_KEY_BACK_BUTTON = "Back",
}

-- Civ IDs deliberately differ from the scenario slots below, so a commit that
-- passes the civ ID instead of the slot is caught.
local CIV_ROWS = {
    CIVILIZATION_AMERICA = {
        ID = 4,
        Type = "CIVILIZATION_AMERICA",
        ShortDescription = "TXT_KEY_CIV_UNION",
        LeaderType = "LEADER_LINCOLN",
        LeaderDescription = "TXT_KEY_LEADER_LINCOLN",
    },
    CIVILIZATION_ENGLAND = {
        ID = 7,
        Type = "CIVILIZATION_ENGLAND",
        ShortDescription = "TXT_KEY_CIV_CONFEDERACY",
        LeaderType = "LEADER_DAVIS",
        LeaderDescription = "TXT_KEY_LEADER_DAVIS",
    },
}

local HANDICAPS = {
    {
        ID = 0,
        Type = "HANDICAP_SETTLER",
        Description = "TXT_KEY_HANDICAP_SETTLER",
        Help = "TXT_KEY_HANDICAP_SETTLER_HELP",
    },
    {
        ID = 3,
        Type = "HANDICAP_PRINCE",
        Description = "TXT_KEY_HANDICAP_PRINCE",
        Help = "TXT_KEY_HANDICAP_PRINCE_HELP",
    },
    {
        ID = 8,
        Type = "HANDICAP_AI_DEFAULT",
        Description = "TXT_KEY_HANDICAP_AI_DEFAULT",
        Help = "TXT_KEY_HANDICAP_AI_DEFAULT",
    },
}

local calls
local ctx

-- GameInfo tables are callable (row iterator) and indexable by ID.
local function gameInfoTable(rows)
    local byID = {}
    for _, row in ipairs(rows) do
        byID[row.ID] = row
    end
    return setmetatable(byID, {
        __call = function()
            local i = 0
            return function()
                i = i + 1
                return rows[i]
            end
        end,
    })
end

-- DB.CreateQuery stand-in: the side lookup returns the civ row for a type;
-- CivDetails' trait / unique queries come back empty.
local function installDB()
    DB = {
        CreateQuery = function(sql)
            if sql:find("FROM Civilizations, Leaders, Civilization_Leaders", 1, true) then
                return function(civType)
                    local done = false
                    return function()
                        if done then
                            return nil
                        end
                        done = true
                        return CIV_ROWS[civType]
                    end
                end
            end
            return function()
                return function()
                    return nil
                end
            end
        end,
    }
end

local function buttonMt()
    local proto = Polyfill.makeButton()
    return {
        __index = {
            SetText = proto.SetText,
            GetText = proto.GetText,
            IsHidden = proto.IsHidden,
            IsDisabled = proto.IsDisabled,
            SetHide = proto.SetHide,
            SetDisabled = proto.SetDisabled,
            RegisterCallback = proto.RegisterCallback,
        },
    }
end

local function setup()
    Setup.fresh()
    T.installLocaleStrings(TEXT)
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CIVILIZATION"] = "Civilization"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIFFICULTY"] = "Difficulty"
    include = function() end
    installDB()
    dofile("src/dlc/UI/Shared/CivVAccess_CivDetails.lua")

    calls = { sides = {}, difficulties = {}, back = 0, start = 0 }
    ktScenarioCivilizations = { [0] = "CIVILIZATION_ENGLAND", [1] = "CIVILIZATION_AMERICA" }
    ScenarioCivilizations = nil
    g_CurrentPlayerIndex = nil
    g_CurrentDifficulty = 3
    GameInfo.HandicapInfos = gameInfoTable(HANDICAPS)
    g_CivVAccessDifficultyButtons = { [0] = { name = "settler entry" }, [3] = { name = "prince entry" } }
    SetPlayerIndex = function(playerIndex)
        calls.sides[#calls.sides + 1] = playerIndex == nil and "random" or playerIndex
        g_CurrentPlayerIndex = playerIndex
    end
    DifficultySelected = function(entry, id)
        calls.difficulties[#calls.difficulties + 1] = { entry = entry, id = id }
        g_CurrentDifficulty = id
    end
    OnBack = function()
        calls.back = calls.back + 1
    end

    -- Start is metatable-backed so the real button probe captures the base
    -- screen's anonymous click handler, as it does in game.
    local start = Polyfill.makeButtonWithMetatable(buttonMt())
    PullDownProbe.ensureButtonInstalled(start)
    Controls = {
        ScreenTitle = Polyfill.makeLabel("Game Selection"),
        Title = Polyfill.makeLabel("Random Leader"),
        BonusDescription = Polyfill.makeLabel(""),
        Quote = Polyfill.makeLabel("A house divided."),
        CivilizationButton = Polyfill.makeButton(),
        StartButton = start,
        BackButton = Polyfill.makeButton(),
    }
    ctx = Setup.makeContextPtr()
end

-- Base registers Start's handler inside its own chunk, before the wrapper's
-- include runs.
local function registerBaseStart()
    Controls.StartButton:RegisterCallback(Mouse.eLClick, function()
        calls.start = calls.start + 1
    end)
end

-- Load the wrapper and show the screen. BaseMenu.install is routed to the
-- test's Context so the global ContextPtr stays nil for the other suites.
local function loadAndShow()
    local realInstall = BaseMenu.install
    BaseMenu.install = function(_, spec)
        return realInstall(ctx, spec)
    end
    dofile("src/dlc/UI/FrontEnd/CivVAccess_ScenarioSetupAccess.lua")
    BaseMenu.install = realInstall
    ctx._sh(false, false)
    return HandlerStack.active()
end

local function labels(menu)
    local out = {}
    for i, item in ipairs(menu._items) do
        out[i] = item.labelText
    end
    return table.concat(out, " | ")
end

local function openChooser(menu, row)
    menu._items[row]:activate(menu)
    return HandlerStack.active()
end

-- Side ------------------------------------------------------------------

function M.test_side_chooser_offers_random_then_sides_by_leader_name()
    setup()
    local chooser = openChooser(loadAndShow(), CIV)
    T.eq(chooser.name, "ScenarioSetup/Civilization")
    T.eq(labels(chooser), "Random Leader, Random Civilization | Abraham Lincoln, Union | Jefferson Davis, Confederacy")
    T.eq(chooser._indices[1], 1, "opens on the current pick")
end

-- Conquest of the New World Deluxe's screen names its side list
-- ScenarioCivilizations, without the kt prefix the other scenarios use.
function M.test_side_chooser_reads_a_side_list_without_the_kt_prefix()
    setup()
    ScenarioCivilizations, ktScenarioCivilizations = ktScenarioCivilizations, nil
    local chooser = openChooser(loadAndShow(), CIV)
    T.eq(labels(chooser), "Random Leader, Random Civilization | Abraham Lincoln, Union | Jefferson Davis, Confederacy")
end

-- Ctrl+I on a side opens that civilization's Civilopedia article, as on every
-- other civ list.
function M.test_sides_open_their_civilopedia_article()
    setup()
    local chooser = openChooser(loadAndShow(), CIV)
    T.eq(chooser._items[1].pediaName, nil, "Random has no article")
    T.eq(chooser._items[2].pediaName, "Union")
    T.eq(chooser._items[3].pediaName, "Confederacy")
end

function M.test_side_choice_commits_the_scenario_slot_and_closes()
    setup()
    local menu = loadAndShow()
    local chooser = openChooser(menu, CIV)
    chooser._items[2]:activate(chooser)
    T.eq(calls.sides[1], 1, "Abraham Lincoln is scenario slot 1, not civ ID 4")
    T.eq(HandlerStack.active(), menu, "the chooser closes back to the setup menu")
    chooser = openChooser(menu, CIV)
    T.eq(chooser._indices[1], 2, "reopens on the committed side")
    chooser._items[1]:activate(chooser)
    T.eq(calls.sides[2], "random", "Random commits no slot")
end

function M.test_civilization_row_reads_title_and_bonus()
    setup()
    local menu = loadAndShow()
    T.eq(menu._items[CIV]:announce(menu), "Random Leader")
    Controls.Title:SetText("Abraham Lincoln (Union)")
    Controls.BonusDescription:SetText("Emancipation")
    T.eq(menu._items[CIV]:announce(menu), "Abraham Lincoln (Union), Emancipation")
end

-- Difficulty --------------------------------------------------------------

function M.test_difficulty_chooser_lists_handicaps_except_ai_default()
    setup()
    local chooser = openChooser(loadAndShow(), DIFFICULTY)
    T.eq(chooser.name, "ScenarioSetup/Difficulty")
    T.eq(labels(chooser), "Settler | Prince")
    T.eq(chooser._indices[1], 2, "opens on the current difficulty")
end

function M.test_difficulty_choice_moves_the_screens_highlight()
    setup()
    local menu = loadAndShow()
    local chooser = openChooser(menu, DIFFICULTY)
    chooser._items[1]:activate(chooser)
    T.eq(calls.difficulties[1].id, 0)
    T.eq(calls.difficulties[1].entry, g_CivVAccessDifficultyButtons[0], "passes the on-screen entry")
    T.eq(HandlerStack.active(), menu, "the chooser closes back to the setup menu")
end

function M.test_difficulty_without_promoted_entry_logs_and_commits_nothing()
    setup()
    g_CivVAccessDifficultyButtons[0] = nil
    local chooser = openChooser(loadAndShow(), DIFFICULTY)
    chooser._items[1]:activate(chooser)
    T.eq(#calls.difficulties, 0, "no partial commit")
    T.eq(g_CurrentDifficulty, 3)
    T.truthy(#errors > 0, "the missing entry is logged")
end

function M.test_difficulty_row_names_the_current_difficulty()
    setup()
    local menu = loadAndShow()
    T.truthy(menu._items[DIFFICULTY]:announce(menu):find("Prince", 1, true))
    g_CurrentDifficulty = 0
    T.truthy(menu._items[DIFFICULTY]:announce(menu):find("Settler", 1, true), "read live at speech time")
end

-- Introduction, Start, Back -------------------------------------------------

function M.test_intro_row_reads_the_screens_quote()
    setup()
    local menu = loadAndShow()
    T.eq(menu._items[INTRO]:announce(menu), "A house divided.")
    Controls.Quote:SetText("Liberty and union.")
    T.eq(menu._items[INTRO]:announce(menu), "Liberty and union.", "read live at speech time")
end

function M.test_start_runs_the_screens_own_handler()
    setup()
    registerBaseStart()
    local menu = loadAndShow()
    menu._items[START]:activate(menu)
    T.eq(calls.start, 1)
end

function M.test_start_without_a_captured_handler_logs()
    setup()
    local menu = loadAndShow()
    menu._items[START]:activate(menu)
    T.eq(calls.start, 0)
    T.truthy(#errors > 0, "an uncaptured Start is logged, not silent")
end

function M.test_escape_and_back_leave_through_on_back()
    setup()
    local menu = loadAndShow()
    T.truthy(ctx._in(WM_KEYDOWN, Keys.VK_ESCAPE, 0), "Esc stays with the modal screen")
    T.eq(calls.back, 1, "Esc backs out through the screen's OnBack")
    menu._items[BACK]:activate(menu)
    T.eq(calls.back, 2, "Back backs out through the screen's OnBack")
end

return M

-- Civilopedia history back / forward landing on the reader line the user
-- left each article at. Drives the real PickerReader install with the real
-- Civilopedia reader, history-step, and link-follow paths; the base pedia's
-- SelectArticle (history bookkeeping plus rendering into Controls) is the
-- engine side and is stood in for here.

local T = require("support")
local M = {}

local WM_KEYDOWN = 256
local MOD_ALT = 4
local UNITS = 4

local speaks

local ARTICLES = {
    [1] = { entryID = 1, entryCategory = UNITS, entryName = "Alpha" },
    [2] = { entryID = 2, entryCategory = UNITS, entryName = "Bravo" },
}

local TEXT_FRAMES = { "Summary", "Extended", "Strategy", "History" }

local function frame()
    return {
        _hidden = true,
        IsHidden = function(self)
            return self._hidden
        end,
    }
end

local function label()
    return {
        _text = "",
        GetText = function(self)
            return self._text
        end,
    }
end

-- Alpha renders four text lines plus a unique-unit link to Bravo (the
-- civ-article-to-unique-unit case); Bravo renders four text lines.
local function render(id)
    local name = ARTICLES[id].entryName
    for _, f in ipairs(TEXT_FRAMES) do
        Controls[f .. "Frame"]._hidden = false
        Controls[f .. "Label"]._text = name .. " " .. f
    end
    if id == 1 then
        Controls.UniqueUnitsFrame._hidden = false
        g_UniqueUnitsManager.m_AllocatedInstances = {
            {
                UniqueUnitButton = {
                    GetToolTipString = function()
                        return "Bravo"
                    end,
                    GetVoid1 = function()
                        return 2
                    end,
                },
            },
        }
    else
        Controls.UniqueUnitsFrame._hidden = true
        g_UniqueUnitsManager.m_AllocatedInstances = {}
    end
end

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end
    UI.ShiftKeyDown = function()
        return false
    end
    UI.CtrlKeyDown = function()
        return false
    end
    UI.AltKeyDown = function()
        return false
    end
    Events.AudioPlay2DSound = function() end

    speaks = {}
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        speaks[#speaks + 1] = { text = text, interrupt = interrupt }
    end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_PullDownProbe.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuHelp.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuTabs.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuInstall.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuEditMode.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_PickerReader.lua")
    -- The relationship table captures its InstanceManager refs at load.
    g_UniqueUnitsManager = { m_AllocatedInstances = {} }
    dofile("src/dlc/UI/Shared/CivVAccess_CivilopediaCore.lua")

    HandlerStack._reset()
    TickPump._reset()

    Controls = { UniqueUnitsFrame = frame() }
    for _, f in ipairs(TEXT_FRAMES) do
        Controls[f .. "Frame"] = frame()
        Controls[f .. "Label"] = label()
    end

    currentTopic = 0
    endTopic = 0
    listOfTopicsViewed = {}
    SetSelectedCategory = function() end
    CivilopediaCategory = {
        [UNITS] = {
            SelectArticle = function(id, addToList)
                if addToList == 1 then
                    currentTopic = currentTopic + 1
                    listOfTopicsViewed[currentTopic] = ARTICLES[id]
                    for i = currentTopic + 1, endTopic do
                        listOfTopicsViewed[i] = nil
                    end
                    endTopic = currentTopic
                end
                render(id)
            end,
        },
    }

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_PEDIA_UNIQUEUNIT_LABEL"] = "Unique unit:"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] = "no selection"
    CivVAccess_Strings["TXT_KEY_HISTORY_TEST_PICKER_TAB"] = "Categories"
    CivVAccess_Strings["TXT_KEY_HISTORY_TEST_READER_TAB"] = "Content"
end

local function install()
    local session = PickerReader.create()
    local function entry(id)
        return session.Entry({
            id = tostring(UNITS) .. ":" .. tostring(id),
            labelText = ARTICLES[id].entryName,
            buildReader = function(handler)
                return Civilopedia.buildReader(handler, UNITS, id)
            end,
        })
    end
    local ctx = {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        IsHidden = function()
            return false
        end,
        SetUpdate = function() end,
    }
    local handler = session.install(ctx, {
        name = "HistoryPedia",
        displayName = "Civilopedia",
        pickerTabName = "TXT_KEY_HISTORY_TEST_PICKER_TAB",
        readerTabName = "TXT_KEY_HISTORY_TEST_READER_TAB",
        pickerItems = { entry(1), entry(2) },
        readerOnAltLeft = Civilopedia.goBack,
        readerOnAltRight = Civilopedia.goForward,
        readerOnActivate = Civilopedia.onReaderActivate,
        -- Same reset the pedia's onShow performs.
        onShow = function()
            Civilopedia.forgetReaderPositions()
        end,
    })
    ctx._sh(false, false)
    return handler, ctx
end

local function press(key, mods)
    InputRouter.dispatch(key, mods or 0, WM_KEYDOWN)
end

local function down(n)
    for _ = 1, n do
        press(Keys.VK_DOWN)
    end
end

local function lastSpoken()
    return speaks[#speaks] and speaks[#speaks].text or ""
end

-- Open Alpha from the picker and walk down to its unique-unit link.
local function openAlphaOnLink()
    press(Keys.VK_RETURN)
    down(4)
end

function M.test_back_after_following_link_lands_on_the_link()
    setup()
    local handler = install()
    openAlphaOnLink()
    press(Keys.VK_RETURN)
    T.eq(lastSpoken(), "Bravo Summary", "link opened Bravo at its first line")
    down(1)
    press(Keys.VK_LEFT, MOD_ALT)
    T.eq(handler._indices[1], 5, "back on Alpha's link line")
    T.truthy(lastSpoken():find(": Bravo$"), "landing speaks the link line the user left")
end

function M.test_forward_lands_where_the_user_left_the_next_article()
    setup()
    local handler = install()
    openAlphaOnLink()
    press(Keys.VK_RETURN)
    down(2)
    press(Keys.VK_LEFT, MOD_ALT)
    press(Keys.VK_RIGHT, MOD_ALT)
    T.eq(handler._indices[1], 3, "forward onto Bravo's third line")
    T.eq(lastSpoken(), "Bravo Strategy")
end

function M.test_leaving_through_the_categories_saves_nothing()
    setup()
    local handler, ctx = install()
    press(Keys.VK_RETURN)
    down(2)
    -- Esc bounces to the picker (on Alpha); pick Bravo from there.
    ctx._in(WM_KEYDOWN, Keys.VK_ESCAPE, 0)
    T.eq(handler._tabIndex, 1, "back on the picker")
    down(1)
    press(Keys.VK_RETURN)
    press(Keys.VK_LEFT, MOD_ALT)
    T.eq(handler._indices[1], 1, "Alpha opens at its first line")
    T.eq(lastSpoken(), "Alpha Summary")
end

function M.test_leaving_with_ctrl_down_saves_nothing()
    setup()
    local handler = install()
    press(Keys.VK_RETURN)
    down(3)
    press(Keys.VK_DOWN, 2) -- Ctrl+Down: next article in picker order
    T.eq(lastSpoken(), "Bravo Summary", "Ctrl+Down opened Bravo at its first line")
    press(Keys.VK_LEFT, MOD_ALT)
    T.eq(handler._indices[1], 1, "Alpha opens at its first line")
    T.eq(lastSpoken(), "Alpha Summary")
end

function M.test_reopening_the_pedia_forgets_positions()
    setup()
    local handler, ctx = install()
    openAlphaOnLink()
    press(Keys.VK_RETURN)
    ctx._sh(true, false)
    ctx._sh(false, false)
    -- Reopen lands on the picker at Alpha; open it, then step back twice
    -- through Bravo to the Alpha visited before the close.
    press(Keys.VK_RETURN)
    press(Keys.VK_LEFT, MOD_ALT)
    press(Keys.VK_LEFT, MOD_ALT)
    T.eq(handler._indices[1], 1, "pre-close position was dropped")
    T.eq(lastSpoken(), "Alpha Summary")
end

return M

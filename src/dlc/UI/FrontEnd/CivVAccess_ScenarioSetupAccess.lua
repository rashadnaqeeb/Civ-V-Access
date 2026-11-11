-- Scenario setup screen accessibility wiring for Firaxis BNW scenarios whose
-- Custom entry point uses the side / difficulty / Start template; American
-- Civil War's and Scramble for Africa's include it. ScenariosMenu loads the
-- screen by full path from the scenario's mod folder; the engine still runs
-- our stem override of its Lua, so this wrapper sits in the screen's own
-- Context like any other Access wrapper.
--
-- The base screen picks a side from a mouse-only list that
-- CivilizationButton toggles and a difficulty from an inline list, and its
-- InputHandler maps both Enter and Esc to OnBack while swallowing every other
-- key. Here each pick is a select-and-close chooser off the setup menu, the
-- shape of every pulldown sub-menu. A side commits through the base
-- SetPlayerIndex global with the ktScenarioCivilizations slot it plays. A
-- difficulty commits through DifficultySelected with the on-screen entry the
-- vendor override promotes onto g_CivVAccessDifficultyButtons, so the
-- highlight moves with the choice. Start is an anonymous base callback,
-- captured by the ProbeBoot the vendor override runs ahead of the base file.

include("CivVAccess_FrontendCommon")
include("CivVAccess_CivDetails")
include("CivVAccess_PullDownProbe")

local SIDE_CHOOSER = "ScenarioSetup/Civilization"
local DIFFICULTY_CHOOSER = "ScenarioSetup/Difficulty"

local function civilizationLabel()
    return CivDetails.setupButtonLabel("ScenarioSetup")
end

local function chooseSide(slot)
    SetPlayerIndex(slot)
    HandlerStack.removeByName(SIDE_CHOOSER, true)
end

local function openSideChooser()
    local items = {
        BaseMenuItems.Choice({
            labelText = Text.key("TXT_KEY_RANDOM_LEADER") .. ", " .. Text.key("TXT_KEY_RANDOM_CIV"),
            tooltipText = Text.key("TXT_KEY_RANDOM_LEADER_HELP"),
            selectedFn = function()
                return g_CurrentPlayerIndex == nil
            end,
            activate = function()
                chooseSide(nil)
            end,
        }),
    }
    local initialIndex = 1
    local sides = {}
    for slot, civType in pairs(ktScenarioCivilizations) do
        local row = CivDetails.rowForType(civType)
        if row ~= nil then
            sides[#sides + 1] = { name = Text.key(row.LeaderDescription), row = row, slot = slot }
        end
    end
    table.sort(sides, function(a, b)
        return Locale.Compare(a.name, b.name) == -1
    end)
    for _, side in ipairs(sides) do
        local slot = side.slot
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = CivDetails.richLabel(side.row),
            pediaName = CivDetails.pediaName(side.row),
            selectedFn = function()
                return g_CurrentPlayerIndex == slot
            end,
            activate = function()
                chooseSide(slot)
            end,
        })
        if g_CurrentPlayerIndex == slot then
            initialIndex = #items
        end
    end
    HandlerStack.push(BaseMenu.create({
        name = SIDE_CHOOSER,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CIVILIZATION"),
        items = items,
        initialIndex = initialIndex,
        escapePops = true,
    }))
end

local function currentDifficulty()
    return GameInfo.HandicapInfos[g_CurrentDifficulty]
end

-- Checked before DifficultySelected runs: it sets g_CurrentDifficulty and
-- hides the old highlight before touching the new entry, so a missing entry
-- would otherwise leave the choice half made.
local function chooseDifficulty(id)
    local entry = g_CivVAccessDifficultyButtons[id]
    Log.check(entry ~= nil, "ScenarioSetupAccess: no on-screen difficulty entry for handicap " .. tostring(id))
    DifficultySelected(entry, id)
    HandlerStack.removeByName(DIFFICULTY_CHOOSER, true)
end

local function openDifficultyChooser()
    local items = {}
    local initialIndex
    for info in GameInfo.HandicapInfos() do
        if info.Type ~= "HANDICAP_AI_DEFAULT" then
            local id = info.ID
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = Text.key(info.Description),
                tooltipText = Text.key(info.Help),
                selectedFn = function()
                    return g_CurrentDifficulty == id
                end,
                activate = function()
                    chooseDifficulty(id)
                end,
            })
            if g_CurrentDifficulty == id then
                initialIndex = #items
            end
        end
    end
    HandlerStack.push(BaseMenu.create({
        name = DIFFICULTY_CHOOSER,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_DIFFICULTY"),
        items = items,
        initialIndex = initialIndex,
        escapePops = true,
    }))
end

local function startGame()
    local handler = PullDownProbe.buttonCallbackFor(Controls.StartButton, Mouse.eLClick)
    Log.check(handler ~= nil, "ScenarioSetupAccess: StartButton click handler was not captured")
    handler()
end

BaseMenu.install(ContextPtr, {
    name = "ScenarioSetup",
    displayName = Text.controlText(Controls.ScreenTitle, "ScenarioSetup ScreenTitle"),
    priorInput = BaseMenu.escOnlyInput(OnBack),
    items = {
        BaseMenuItems.Button({
            controlName = "CivilizationButton",
            labelFn = civilizationLabel,
            activate = openSideChooser,
        }),
        BaseMenuItems.Choice({
            labelFn = function()
                return Text.key(currentDifficulty().Description)
            end,
            tooltipFn = function()
                return Text.key(currentDifficulty().Help)
            end,
            activate = openDifficultyChooser,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.controlText(Controls.Quote, "ScenarioSetup Quote") or ""
            end,
        }),
        BaseMenuItems.Button({
            controlName = "StartButton",
            textKey = "TXT_KEY_START_GAME",
            activate = startGame,
        }),
        BaseMenuItems.Button({
            controlName = "BackButton",
            textKey = "TXT_KEY_BACK_BUTTON",
            activate = function()
                OnBack()
            end,
        }),
    },
})

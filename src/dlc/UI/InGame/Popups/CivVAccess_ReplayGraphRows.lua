-- Replay graph-data row builder, shared between the front-end ReplayViewer
-- (Load Replay -> Graphs panel) and the Graphs tab of EndGameMenu's
-- end-of-game screen. Both surface the numbers behind the line graph a
-- sighted player reads off the chart: one drillable per civ, one per turn
-- inside it, and a leaf per dataset that recorded a value on that turn
-- ("Score 58", "Techs Known 14").
--
-- Vanilla plots one dataset at a time for every civ at once, so the chart
-- axes are turn against value with the dataset chosen from a pulldown.
-- The tree inverts that -- civ, then turn, then every dataset -- because a
-- keyboard walk down one civ's timeline is the shape that reads, where a
-- flat per-dataset list would need the user to hold the turn axis in their
-- head across civs. Datasets are ordered the way vanilla's own pulldown
-- orders them (localized description, sorted), so the leaves under any
-- turn arrive in the same order every time.
--
-- Both callers pass an array of { name, scoresFn } and the module never
-- looks at a player handle itself. scoresFn returns table[turn][dataSet],
-- and is called lazily on drill rather than up front: the engine records
-- every dataset for every living civ on every turn, so a full game is on
-- the order of 24 datasets x 500 turns x 40-odd ever-alive civs. Building
-- all of that on tab open would hitch the screen for a user who wanted one
-- civ. Group's itemsFn defers each civ's turn list until the cursor
-- reaches it and caches the result for the life of the item list, which the
-- callers rebuild on every visit.
--
-- Pure functions, no captured state, no install side effects -- safe to
-- include() in any Context that already loads BaseMenuItems and Text.

ReplayGraphRows = {}

-- Every GameInfo.ReplayDataSets row, sorted by localized description.
-- Mirrors vanilla RefreshGraphDataSets so mod-added datasets (the Community
-- Patch adds tourism and golden age points) come along on their own.
local function dataSets()
    local sets = {}
    for row in GameInfo.ReplayDataSets() do
        sets[#sets + 1] = { type = row.Type, name = Text.key(row.Description) }
    end
    table.sort(sets, function(a, b)
        return Locale.Compare(a.name, b.name) == -1
    end)
    return sets
end

-- The datasets that recorded a value on one turn, in dataset order. A civ
-- that was dead on the turn in question records nothing, so the leaves under
-- a turn are only the datasets actually present in the table.
local function valueItems(turnData, sets)
    local items = {}
    for _, ds in ipairs(sets) do
        local value = turnData[ds.type]
        if value ~= nil then
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format("TXT_KEY_CIVVACCESS_LABEL_VALUE", ds.name, value),
            })
        end
    end
    return items
end

-- One drillable per turn that holds any recorded value, ascending. The
-- group label carries the turn so the leaves under it speak only the
-- dataset and its number.
local function turnItems(scores, sets)
    local turns = {}
    for turn in pairs(scores) do
        turns[#turns + 1] = turn
    end
    table.sort(turns)
    local items = {}
    for _, turn in ipairs(turns) do
        local turnData = scores[turn]
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.format("TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP", turn),
            itemsFn = function()
                return valueItems(turnData, sets)
            end,
        })
    end
    return items
end

-- Top-level items for the graph tree. `players` is an array of
-- { name = <civ name>, scoresFn = fn() -> table[turn][dataSet] }, in the
-- order the civs should be announced. A civ whose scoresFn yields no turns
-- produces an empty group, which BaseMenu skips as non-navigable.
function ReplayGraphRows.buildItems(players)
    if #players == 0 then
        return {
            BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_REPLAY_NOGRAPHDATA") }),
        }
    end
    local sets = dataSets()
    local items = {}
    for _, player in ipairs(players) do
        items[#items + 1] = BaseMenuItems.Group({
            labelText = player.name,
            itemsFn = function()
                return turnItems(player.scoresFn(), sets)
            end,
        })
    end
    return items
end

-- End-game path: the live game. Mirrors vanilla
-- GenerateReplayInfoFromCurrentGame's player loop (every ever-alive slot up
-- to MAX_CIV_PLAYERS, city-states included the way the graph legend
-- includes them) and its transposition of Player:GetReplayData, which hands
-- back table[dataSet][turn]. The transpose runs inside scoresFn so a civ the
-- user never drills into costs nothing.
function ReplayGraphRows.playersFromGame()
    local players = {}
    for playerNum = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local player = Players[playerNum]
        if player ~= nil and player:IsEverAlive() then
            players[#players + 1] = {
                name = Text.key(player:GetCivilizationShortDescription()),
                scoresFn = function()
                    local scores = {}
                    for dataSet, byTurn in pairs(player:GetReplayData()) do
                        for turn, value in pairs(byTurn) do
                            local turnData = scores[turn]
                            if turnData == nil then
                                turnData = {}
                                scores[turn] = turnData
                            end
                            turnData[dataSet] = value
                        end
                    end
                    return scores
                end,
            }
        end
    end
    if #players == 0 then
        Log.warn("ReplayGraphRows: no ever-alive civs in the current game")
    end
    return players
end

-- Front-end path: a replay file the engine already parsed into g_ReplayInfo.
-- PlayerInfo entries arrive with Scores in table[turn][dataSet] shape, so
-- scoresFn is a straight handback. Civs with no recorded turns are dropped
-- here (the table is already in memory, so the check is free) which lets an
-- unreadable replay fall through to the no-data notice instead of a silent
-- list of empty drillables.
function ReplayGraphRows.playersFromReplayInfo(replayInfo)
    local players = {}
    if replayInfo == nil or replayInfo.PlayerInfo == nil then
        Log.warn("ReplayGraphRows: replay info has no PlayerInfo")
        return players
    end
    for _, info in ipairs(replayInfo.PlayerInfo) do
        local name = info.CivShortDescription
        if name == nil then
            name = GameInfo.Civilizations[info.Civilization].ShortDescription
        end
        local scores = info.Scores
        if scores == nil then
            Log.warn("ReplayGraphRows: replay civ '" .. tostring(name) .. "' carries no Scores table")
        elseif next(scores) ~= nil then
            players[#players + 1] = {
                name = Text.key(name),
                scoresFn = function()
                    return scores
                end,
            }
        end
    end
    return players
end

return ReplayGraphRows

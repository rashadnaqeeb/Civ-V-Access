-- Shared row-cell formatters for game-result archives (Hall of Fame +
-- Leaderboard). Both screens flatten a saved-game header into a single
-- announce string per row in visual order: rank/score, leader+civ,
-- victory/defeat, winner, victory type, map and setup, era+turn, end time.
--
-- The two callers' header schemas overlap on most fields (PlayerTeamWon,
-- WinningTeamLeaderCivilizationType, VictoryType, MapName, StartEraType,
-- WinningTurn, Score, WorldSize, PlayerHandicapType, GameEndTime) but
-- diverge on:
--   - civ key field           HoF: PlayerCivilizationType (per-row caller)
--                              Leaderboard: Civ
--   - leader/civ name override HoF: LeaderName / CivilizationName fields
--                              from custom-named games override the GameInfo
--                              lookup. Leaderboard rows have no overrides.
--   - "you" winner flavor      HoF speaks "you" when the player won;
--                              Leaderboard always speaks the winning civ.
--   - game-speed field         HoF: GameSpeedType. Leaderboard: GameSpeed.
--
-- This module exposes the always-shared formatters and parameterizes the
-- diverging ones (winnerText takes a flag, leaderCivFromCivType takes the
-- already-resolved civ key). Callers wrap the diverging cases with their
-- per-row schema knowledge.

GameResultRow = {}

-- Resolve a row's localized Description, falling back to "" when the row
-- or its Description is missing. Used for map size / handicap / game speed.
function GameResultRow.lookupDescription(tbl, key)
    if key == nil then
        return ""
    end
    local row = tbl[key]
    if row == nil or row.Description == nil then
        return ""
    end
    return Text.key(row.Description)
end

-- Resolve "Leader, Civ" from a Civilizations-table key (PlayerCivilizationType
-- in HoF, Civ in Leaderboard). Returns TXT_KEY_MISC_UNKNOWN if the key is
-- unknown, or the civ short description alone if no leader link exists.
-- Callers with player-supplied LeaderName / CivilizationName overrides
-- (HoF) wrap this with their own override branch.
function GameResultRow.leaderCivFromCivType(civType)
    local civ = GameInfo.Civilizations[civType]
    if civ == nil then
        return Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    local civName = Text.key(civ.ShortDescription)
    local linkRow = GameInfo.Civilization_Leaders("CivilizationType = '" .. civ.Type .. "'")()
    if linkRow == nil then
        return civName
    end
    local leader = GameInfo.Leaders[linkRow.LeaderheadType]
    if leader == nil then
        return civName
    end
    return Text.joinNonEmpty({ Text.key(leader.Description), civName })
end

-- Winner cell. honorPlayerWon=true speaks "you" when the player's team won
-- (HoF flavor). false always speaks the winning civ short description, with
-- "nobody" when no winner was recorded (timed games / unfinished sessions).
function GameResultRow.winnerText(v, honorPlayerWon)
    if honorPlayerWon and v.PlayerTeamWon then
        return Text.key("TXT_KEY_POP_VOTE_RESULTS_YOU")
    end
    if v.WinningTeamLeaderCivilizationType ~= nil then
        local winCiv = GameInfo.Civilizations[v.WinningTeamLeaderCivilizationType]
        if winCiv ~= nil then
            return Text.key(winCiv.ShortDescription)
        end
    end
    return Text.key("TXT_KEY_CITY_STATE_NOBODY")
end

function GameResultRow.victoryTypeText(v)
    if v.VictoryType == nil then
        return ""
    end
    local row = GameInfo.Victories[v.VictoryType]
    if row == nil or row.VictoryStatement == nil then
        return ""
    end
    return Text.key(row.VictoryStatement)
end

function GameResultRow.mapTypeText(v)
    if v.MapName == nil or v.MapName == "" then
        return ""
    end
    local info = MapUtilities.GetBasicInfo(v.MapName)
    if info == nil or info.Name == nil then
        return ""
    end
    return Text.key(info.Name)
end

function GameResultRow.eraTurnText(v)
    local eraName = GameResultRow.lookupDescription(GameInfo.Eras, v.StartEraType)
    if eraName == "" then
        eraName = Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    return Text.format("TXT_KEY_ERA_TURNS_FORMAT", eraName, v.WinningTurn or 0)
end

function GameResultRow.statusText(v)
    if v.PlayerTeamWon then
        return Text.key("TXT_KEY_VICTORY_BANG")
    end
    return Text.key("TXT_KEY_DEFEAT_BANG")
end

function GameResultRow.scoreText(v)
    return Text.format("TXT_KEY_CIVVACCESS_LABEL_VALUE", Text.key("TXT_KEY_POP_SCORE"), v.Score or 0)
end

return GameResultRow

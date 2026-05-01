-- HallOfFame accessibility. Local game-result archive loaded synchronously
-- via UI.GetHallofFameData() in the vanilla ShowHide. Each row is flattened
-- to a single Text entry whose announce string carries the full XML row in
-- visual order: score, leader and civ, victory/defeat, winner + victory
-- type, map and setup icons, start era + winning turn, end time. When the
-- player won, the "winner" cell speaks "you" rather than naming the civ
-- (vanilla's flavor — keeps "I won this one" obvious while skimming).
--
-- Empty list reads as a single Text item built from
-- TXT_KEY_HALL_OF_FAME_EMPTY so arrow-key nav lands on the empty notice
-- rather than silence.
--
-- Loaded as a child LuaContext of the front-end OtherMenu (no in-game
-- entry point), which is why our DLC manifest extends <Skin> with
-- UI/InGame/Popups so this override is visible at front-end resolution
-- time. We pull the front-end include chain (locale strings live there)
-- rather than the in-game CivVAccess_InGameStrings_en_US which isn't
-- routed through the front-end Skin.

include("CivVAccess_FrontendCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Resolve "Leader, Civ" for a row. Honors player-supplied custom names
-- (LeaderName / CivilizationName fields are pre-filled by the engine when
-- the user picked custom names at game start) and falls back to the
-- canonical leader Description + civ ShortDescription.
local function leaderCivText(v)
    if v.LeaderName ~= nil and v.LeaderName ~= "" then
        return Text.joinNonEmpty({
            Text.key(v.LeaderName),
            Text.key(v.CivilizationName or ""),
        })
    end
    local civ = GameInfo.Civilizations[v.PlayerCivilizationType]
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

-- Winner cell. Speaks "you" when the player's team won (matching the
-- vanilla "TXT_KEY_POP_VOTE_RESULTS_YOU" label); otherwise the winning
-- civ short description, falling back to "nobody" when no winner was
-- recorded (timed games, unfinished sessions persisted to HoF).
local function winnerText(v)
    if v.PlayerTeamWon then
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

local function victoryTypeText(v)
    if v.VictoryType == nil then
        return ""
    end
    local row = GameInfo.Victories[v.VictoryType]
    if row == nil or row.VictoryStatement == nil then
        return ""
    end
    return Text.key(row.VictoryStatement)
end

local function lookupDescription(tbl, key)
    if key == nil then
        return ""
    end
    local row = tbl[key]
    if row == nil or row.Description == nil then
        return ""
    end
    return Text.key(row.Description)
end

local function mapTypeText(v)
    if v.MapName == nil or v.MapName == "" then
        return ""
    end
    local info = MapUtilities.GetBasicInfo(v.MapName)
    if info == nil or info.Name == nil then
        return ""
    end
    return Text.key(info.Name)
end

local function eraTurnText(v)
    local eraName = lookupDescription(GameInfo.Eras, v.StartEraType)
    if eraName == "" then
        eraName = Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    return Text.format("TXT_KEY_ERA_TURNS_FORMAT", eraName, v.WinningTurn or 0)
end

local function statusText(v)
    if v.PlayerTeamWon then
        return Text.key("TXT_KEY_VICTORY_BANG")
    end
    return Text.key("TXT_KEY_DEFEAT_BANG")
end

local function scoreText(v)
    return Text.format("TXT_KEY_CIVVACCESS_LABEL_VALUE", Text.key("TXT_KEY_POP_SCORE"), v.Score or 0)
end

local function rowLabel(v)
    return Text.joinNonEmpty({
        scoreText(v),
        leaderCivText(v),
        statusText(v),
        winnerText(v),
        victoryTypeText(v),
        mapTypeText(v),
        lookupDescription(GameInfo.Worlds, v.WorldSize),
        lookupDescription(GameInfo.HandicapInfos, v.PlayerHandicapType),
        lookupDescription(GameInfo.GameSpeeds, v.GameSpeedType),
        eraTurnText(v),
        v.GameEndTime or "",
    })
end

local function buildItems()
    local games = UI.GetHallofFameData()
    if games == nil or next(games) == nil then
        return {
            BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_HALL_OF_FAME_EMPTY"),
            }),
        }
    end
    local items = {}
    -- Vanilla iterates with pairs; match that to avoid the Civ V ipairs
    -- (0,t[0]) quirk if the engine ever returns a 0-indexed table.
    -- We don't filter rows on civ / leader nil (the way vanilla's
    -- PopulateGameResults does for layout reasons) — leaderCivText falls
    -- back to TXT_KEY_MISC_UNKNOWN, which is preferable to silently
    -- dropping a row from speech with no other surface to communicate it.
    for _, v in pairs(games) do
        items[#items + 1] = BaseMenuItems.Text({
            labelText = rowLabel(v),
        })
    end
    return items
end

BaseMenu.install(ContextPtr, {
    name = "HallOfFame",
    displayName = Text.key("TXT_KEY_HALL_OF_FAME"),
    items = buildItems(),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = function(h)
        h.setItems(buildItems())
    end,
})

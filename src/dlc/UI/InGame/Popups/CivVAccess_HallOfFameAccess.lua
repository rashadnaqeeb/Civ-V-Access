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
include("CivVAccess_GameResultRow")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Resolve "Leader, Civ" for a row. HoF rows can carry player-supplied
-- LeaderName / CivilizationName overrides (the engine pre-fills them when
-- the user picked custom names at game start); otherwise fall back to the
-- shared canonical leader+civ resolver.
local function leaderCivText(v)
    if v.LeaderName ~= nil and v.LeaderName ~= "" then
        return Text.joinNonEmpty({
            Text.key(v.LeaderName),
            Text.key(v.CivilizationName or ""),
        })
    end
    return GameResultRow.leaderCivFromCivType(v.PlayerCivilizationType)
end

local function rowLabel(v)
    return Text.joinNonEmpty({
        GameResultRow.scoreText(v),
        leaderCivText(v),
        GameResultRow.statusText(v),
        GameResultRow.winnerText(v, true),
        GameResultRow.victoryTypeText(v),
        GameResultRow.mapTypeText(v),
        GameResultRow.lookupDescription(GameInfo.Worlds, v.WorldSize),
        GameResultRow.lookupDescription(GameInfo.HandicapInfos, v.PlayerHandicapType),
        GameResultRow.lookupDescription(GameInfo.GameSpeeds, v.GameSpeedType),
        GameResultRow.eraTurnText(v),
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

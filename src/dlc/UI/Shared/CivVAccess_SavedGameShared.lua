-- Shared helpers for saved-game / replay header presentation. Consumed by
-- LoadMenuCore, SaveMenuCore, and LoadReplayMenuCore. These all render a
-- picker of save files and a reader of header fields; the helpers track
-- the game's header schema (PlayerCivilization, LeaderName, CurrentEra,
-- WorldSize, Difficulty, GameSpeed, GameType) and its GameInfo lookup
-- conventions.
--
-- Extracted rather than duplicated so a schema or localization change lands
-- in one place. Dependencies: BaseMenuItems.Text (for addField) and Text.key
-- (for label resolution) -- consumers must include those first.
--
-- Consumers typically alias the exported functions to local names to keep
-- call sites terse: `local resolveLeaderCiv = SavedGameShared.resolveLeaderCiv`.

SavedGameShared = {}

-- Detail field header labels. Engine TXT_KEYs keep speech aligned with the
-- sighted-user labels (tooltip strings on the *Menu.xml file's icon row)
-- and pick up localization.
SavedGameShared.HEADER_KEYS = {
    mapType    = "TXT_KEY_AD_SETUP_MAP_TYPE",
    mapSize    = "TXT_KEY_AD_SETUP_MAP_SIZE",
    difficulty = "TXT_KEY_AD_SETUP_HANDICAP",
    gameSpeed  = "TXT_KEY_GAME_SPEED",
}

function SavedGameShared.stripPath(filename)
    if filename == nil or filename == "" then return "" end
    return Path.GetFileNameWithoutExtension(filename)
end

-- Decode an entry id from buildPickerItems back into (kind, numeric index).
-- Returns nil on malformed ids so the caller can log through its own path.
function SavedGameShared.parseId(id)
    local kind, idxStr = string.match(id or "", "^(%a+):(%d+)$")
    if kind == nil then return nil end
    return kind, tonumber(idxStr)
end

-- Resolve leader / civ display text from a save header, falling back to
-- GameInfo.Civilizations / Civilization_Leaders when the header doesn't
-- carry a per-save override (LeaderName / CivilizationName). Mirrors the
-- SetSelected body in the base LoadMenu / SaveMenu.
function SavedGameShared.resolveLeaderCiv(header)
    local civName        = Text.key("TXT_KEY_MISC_UNKNOWN")
    local leaderDescText = Text.key("TXT_KEY_MISC_UNKNOWN")
    local civ = GameInfo.Civilizations[header.PlayerCivilization]
    if civ ~= nil then
        civName = Text.key(civ.Description)
        local row = GameInfo.Civilization_Leaders(
            "CivilizationType = '" .. civ.Type .. "'")()
        if row ~= nil then
            local leader = GameInfo.Leaders[row.LeaderheadType]
            if leader ~= nil then
                leaderDescText = Text.key(leader.Description)
            end
        end
    end
    if header.LeaderName ~= nil and header.LeaderName ~= "" then
        leaderDescText = header.LeaderName
    end
    if header.CivilizationName ~= nil and header.CivilizationName ~= "" then
        civName = header.CivilizationName
    end
    return leaderDescText, civName
end

function SavedGameShared.gameTypeLabel(header)
    if header.GameType == GameTypes.GAME_HOTSEAT_MULTIPLAYER then
        return Text.key("TXT_KEY_MULTIPLAYER_HOTSEAT_GAME")
    elseif header.GameType == GameTypes.GAME_NETWORK_MULTIPLAYER then
        return Text.key("TXT_KEY_MULTIPLAYER_STRING")
    elseif header.GameType == GameTypes.GAME_SINGLE_PLAYER then
        return Text.key("TXT_KEY_SINGLE_PLAYER")
    end
    return nil
end

-- Resolve a GameInfo row's localized Description, falling back to a
-- TXT_KEY_MISC_UNKNOWN when the row or its Description is missing. Used for
-- map size / difficulty / game speed (all follow the same schema).
function SavedGameShared.descOf(row)
    if row == nil or row.Description == nil then
        return Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    return Text.key(row.Description)
end

-- Append a "Label: value" Text leaf to `leaves` when value is non-empty.
-- headerKey is a TXT_KEY for the label prefix; leave nil/empty to emit the
-- value alone. Value must be a pre-resolved string (not a TXT_KEY).
function SavedGameShared.addField(leaves, headerKey, value)
    if value == nil or value == "" then return end
    local prefix = ""
    if headerKey ~= nil and headerKey ~= "" then
        prefix = Text.key(headerKey) .. ": "
    end
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = prefix .. value,
    })
end

return SavedGameShared

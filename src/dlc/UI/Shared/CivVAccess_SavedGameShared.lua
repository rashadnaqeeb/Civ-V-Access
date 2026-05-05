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
    mapType = "TXT_KEY_AD_SETUP_MAP_TYPE",
    mapSize = "TXT_KEY_AD_SETUP_MAP_SIZE",
    difficulty = "TXT_KEY_AD_SETUP_HANDICAP",
    gameSpeed = "TXT_KEY_GAME_SPEED",
}

function SavedGameShared.stripPath(filename)
    if filename == nil or filename == "" then
        return ""
    end
    return Path.GetFileNameWithoutExtension(filename)
end

-- Decode an entry id from buildPickerItems back into (kind, numeric index).
-- Returns nil on malformed ids so the caller can log through its own path.
function SavedGameShared.parseId(id)
    local kind, idxStr = string.match(id or "", "^(%a+):(%d+)$")
    if kind == nil then
        return nil
    end
    return kind, tonumber(idxStr)
end

-- Resolve leader / civ display text from a save header, falling back to
-- GameInfo.Civilizations / Civilization_Leaders when the header doesn't
-- carry a per-save override (LeaderName / CivilizationName). Mirrors the
-- SetSelected body in the base LoadMenu / SaveMenu.
function SavedGameShared.resolveLeaderCiv(header)
    local civName = Text.key("TXT_KEY_MISC_UNKNOWN")
    local leaderDescText = Text.key("TXT_KEY_MISC_UNKNOWN")
    local civ = GameInfo.Civilizations[header.PlayerCivilization]
    if civ ~= nil then
        civName = Text.key(civ.Description)
        local row = GameInfo.Civilization_Leaders("CivilizationType = '" .. civ.Type .. "'")()
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
    if value == nil or value == "" then
        return
    end
    local prefix = ""
    if headerKey ~= nil and headerKey ~= "" then
        prefix = Text.key(headerKey) .. ": "
    end
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = prefix .. value,
    })
end

-- Append the standard reader-tab header leaves: leader+civ, optional date,
-- era/turn, optional start era, optional game type, map / size / difficulty /
-- speed. Used by LoadMenu / SaveMenu / LoadReplayMenu, which carry the same
-- header schema with a few flag-shaped differences.
--
-- opts:
--   date              pre-resolved date string (caller resolves via
--                     UI.GetSavedGameModificationTime / UI.GetReplayModificationTime).
--                     Pass nil/empty to skip the date leaf (e.g., cloud saves).
--   alwaysEmitEra     bool. Replays always emit the era/turn leaf with a
--                     TXT_KEY_MISC_UNKNOWN era when the header lacks one.
--                     Save / load only emit when CurrentEra is non-empty.
--   startEraFormatKey TXT_KEY for the start-era line (default "TXT_KEY_START_ERA";
--                     replay overrides to "TXT_KEY_START_ERA_FORMAT").
--   skipGameType      bool. Replay headers don't emit game type.
function SavedGameShared.appendStandardHeaderLeaves(leaves, header, opts)
    opts = opts or {}

    local leaderDescText, civName = SavedGameShared.resolveLeaderCiv(header)
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = Text.format("TXT_KEY_RANDOM_LEADER_CIV", leaderDescText, civName),
    })

    if opts.date ~= nil and opts.date ~= "" then
        leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = opts.date })
    end

    local hasEra = header.CurrentEra ~= nil and header.CurrentEra ~= ""
    if opts.alwaysEmitEra or hasEra then
        local eraDesc
        if hasEra then
            local era = GameInfo.Eras[header.CurrentEra]
            eraDesc = Text.key((era ~= nil and era.Description) or "TXT_KEY_MISC_UNKNOWN")
        else
            eraDesc = Text.key("TXT_KEY_MISC_UNKNOWN")
        end
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_CUR_ERA_TURNS_FORMAT", eraDesc, header.TurnNumber),
        })
    end

    if header.StartEra ~= nil and header.StartEra ~= "" then
        local startEra = GameInfo.Eras[header.StartEra]
        local startEraDesc = Text.key((startEra ~= nil and startEra.Description) or "TXT_KEY_MISC_UNKNOWN")
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.format(opts.startEraFormatKey or "TXT_KEY_START_ERA", startEraDesc),
        })
    end

    if not opts.skipGameType then
        local gameType = SavedGameShared.gameTypeLabel(header)
        if gameType ~= nil then
            leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = gameType })
        end
    end

    local mapInfo = MapUtilities.GetBasicInfo(header.MapScript)
    if mapInfo ~= nil and mapInfo.Name ~= nil then
        SavedGameShared.addField(leaves, SavedGameShared.HEADER_KEYS.mapType, Text.key(mapInfo.Name))
    end
    SavedGameShared.addField(
        leaves,
        SavedGameShared.HEADER_KEYS.mapSize,
        SavedGameShared.descOf(GameInfo.Worlds[header.WorldSize])
    )
    SavedGameShared.addField(
        leaves,
        SavedGameShared.HEADER_KEYS.difficulty,
        SavedGameShared.descOf(GameInfo.HandicapInfos[header.Difficulty])
    )
    SavedGameShared.addField(
        leaves,
        SavedGameShared.HEADER_KEYS.gameSpeed,
        SavedGameShared.descOf(GameInfo.GameSpeeds[header.GameSpeed])
    )
end

-- Push a sub-menu listing referenced DLC / Mods names. Mirrors the base
-- ShowModsButton / ShowDLCButton popups (LoadMenu.lua lines 145-203,
-- LoadReplayMenu.lua lines 68-126) but strips "[ICON_BULLET]" prefixes
-- since the bullet carries no information in speech (the icon filter would
-- drop it anyway).
--
-- kind     "dlc" or "mods".
-- dlcList  the engine's g_SavedGameDLCRequired / g_ReplayDLCRequired.
-- modsList the engine's g_SavedGameModsRequired / g_ReplayModsRequired.
-- Pass both regardless of kind; the helper picks the one matching kind.
function SavedGameShared.pushRequirementsSub(mainHandler, kind, dlcList, modsList)
    local list, displayKey
    if kind == "mods" then
        list, displayKey = modsList, "TXT_KEY_LOAD_MENU_REQUIRED_MODS"
    else
        list, displayKey = dlcList, "TXT_KEY_LOAD_MENU_REQUIRED_DLC"
    end
    if list == nil or #list == 0 then
        return
    end
    local items = {}
    for _, v in ipairs(list) do
        local name
        if kind == "dlc" and v.DescriptionKey ~= nil and Locale.HasTextKey(v.DescriptionKey) then
            name = Text.key(v.DescriptionKey)
        else
            name = v.Title or ""
            if Locale.HasTextKey(name) then
                name = Text.key(name)
            end
        end
        if kind == "mods" and v.Version ~= nil then
            name = Text.format("TXT_KEY_CIVVACCESS_LOAD_MOD_VERSION", name, v.Version)
        end
        items[#items + 1] = BaseMenuItems.Text({ labelText = name })
    end
    HandlerStack.push(BaseMenu.create({
        name = mainHandler.name .. "/Requirements",
        displayName = Text.key(displayKey),
        items = items,
        escapePops = true,
    }))
end

-- Push a Yes/No delete-confirm sub. Bypasses the visual DeleteConfirm popup
-- (no speech affordance). On Yes calls deleteFn(filename) + SetupFileButtonList,
-- and replaces the reader tab with a one-item placeholder so stale details
-- can't be read back. Esc on the sub pops without committing (escapePops).
--
-- "No" is first so arrow-down to Yes is an explicit affirmative step;
-- accidental Enter on the default cancels rather than deletes.
--
-- opts:
--   deleteFn         function(filename) - the engine delete call
--                    (UI.DeleteSavedGame / UI.DeleteReplayFile)
--   deletedTextKey   TXT_KEY for the post-delete reader placeholder
--   readerTabIdx     reader tab index (default 2, matching PickerReader)
function SavedGameShared.pushDeleteConfirmSub(mainHandler, filename, opts)
    if filename == nil or filename == "" then
        return
    end
    local displayName = SavedGameShared.stripPath(filename)
    local confirmLabel = Text.format("TXT_KEY_CIVVACCESS_LOAD_DELETE_CONFIRM", displayName)
    local subName = mainHandler.name .. "/DeleteConfirm"
    local readerTabIdx = opts.readerTabIdx or 2
    HandlerStack.push(BaseMenu.create({
        name = subName,
        displayName = confirmLabel,
        items = {
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    HandlerStack.removeByName(subName, true)
                end,
            }),
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    opts.deleteFn(filename)
                    SetupFileButtonList()
                    mainHandler.setItems({
                        BaseMenuItems.Text({ textKey = opts.deletedTextKey }),
                    }, readerTabIdx)
                    HandlerStack.removeByName(subName, true)
                end,
            }),
        },
        escapePops = true,
    }))
end

-- Order fileList's indices to match the currently-selected engine sort
-- (g_CurrentSort, one of SortByLastModified / SortByName). Our picker is a
-- separate list from the engine's visual Stack, so we replicate the sort
-- here. Returns a flat array of fileList indices; Entry ids remain
-- "<kind>:<original-index>" so PickerReader cursor restoration works.
--
-- opts:
--   mtimeRawFn          function(filename) -> high, low (engine's raw
--                       UI.GetSavedGameModificationTimeRaw or
--                       UI.GetReplayModificationTimeRaw).
--   reverseAlphaSortFn  optional function() -> bool. When true, name-sort
--                       runs reverse-alphabetical (LoadMenu's autosave mode
--                       inverts the order; LoadReplay never does).
function SavedGameShared.sortedFileIndices(fileList, opts)
    local records = {}
    for i, filename in ipairs(fileList) do
        records[#records + 1] = { idx = i, filename = filename }
    end
    if g_CurrentSort == SortByLastModified then
        -- Read mtimes once up front; table.sort's comparator can fire
        -- N log N times and per-compare filesystem reads would be expensive.
        for _, r in ipairs(records) do
            r.high, r.low = opts.mtimeRawFn(r.filename)
        end
        table.sort(records, function(a, b)
            return UI.CompareFileTime(a.high, a.low, b.high, b.low) == 1
        end)
    elseif g_CurrentSort == SortByName then
        for _, r in ipairs(records) do
            r.name = SavedGameShared.stripPath(r.filename)
        end
        local reverse = opts.reverseAlphaSortFn and opts.reverseAlphaSortFn()
        if reverse then
            table.sort(records, function(a, b)
                return Locale.Compare(b.name, a.name) == -1
            end)
        else
            table.sort(records, function(a, b)
                return Locale.Compare(a.name, b.name) == -1
            end)
        end
    end
    local indices = {}
    for i, r in ipairs(records) do
        indices[i] = r.idx
    end
    return indices
end

-- Build the picker-tab Sort-by Group with its Last Modified / Name choices.
-- Each choice flips g_CurrentSort, updates the engine pulldown's button text
-- and the visual Stack's order (sighted parity), and rebuilds the picker via
-- buildPickerItems(entryFactory, handlerRef). Visibility is gated on the
-- engine pulldown's hidden state: cloud mode hides Controls.SortByPullDown
-- and our Group follows suit.
function SavedGameShared.makeSortByGroup(entryFactory, handlerRef, buildPickerItems)
    local function applySort(sortFn, labelKey)
        g_CurrentSort = sortFn
        Controls.SortByPullDown:GetButton():LocalizeAndSetText(labelKey)
        Controls.LoadFileButtonStack:SortChildren(sortFn)
        local newItems = buildPickerItems(entryFactory, handlerRef)
        handlerRef().setItems(newItems, 1)
    end
    return BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_LOAD_SORT_BY",
        visibilityControlName = "SortByPullDown",
        items = {
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_SORTBY_LASTMODIFIED",
                selectedFn = function()
                    return g_CurrentSort == SortByLastModified
                end,
                activate = function()
                    applySort(SortByLastModified, "TXT_KEY_SORTBY_LASTMODIFIED")
                end,
            }),
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_SORTBY_NAME",
                selectedFn = function()
                    return g_CurrentSort == SortByName
                end,
                activate = function()
                    applySort(SortByName, "TXT_KEY_SORTBY_NAME")
                end,
            }),
        },
    })
end

return SavedGameShared

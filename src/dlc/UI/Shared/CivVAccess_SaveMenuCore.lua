-- SaveMenu data module. Two public fns:
--   SaveMenu.buildPickerItems(entryFactory, handlerRef) - picker-tab items.
--     Local mode: Textfield for NameBox (gated on NameBoxFrame visibility),
--     Save action, Steam Cloud checkbox, and one Entry per existing save in
--     g_SavedGames. Cloud mode: Steam Cloud checkbox and one Entry per slot
--     (1..s_maxCloudSaves), populated or empty.
--   SaveMenu.buildReader(handlerRef, id) - reader-tab leaves for the save
--     or cloud slot identified by id: the save's header fields plus an
--     Overwrite (or Save-to-slot for empty cloud slots) action, and Delete
--     for disk saves.
--
-- Why bypass the base OnSave / OnDelete wiring: OnSave's collision branch
-- pops Controls.DeleteConfirm (a sighted-only overlay); OnDelete pops the
-- same overlay with a different message. Rather than intercept the overlay,
-- we replicate the branching in Lua and push pure-speech Yes/No subs for
-- both confirmation cases. The underlying save / delete calls (UI.SaveGame,
-- UI.DeleteSavedGame, Steam.SaveGameToCloud, etc.) are the same as base;
-- we just gate them behind our own confirm flow.
--
-- Never cache header data: every buildReader call re-reads from PreGame
-- (or g_SavedGames[i].SaveData for cloud, which SetupFileButtonList
-- populated from the fresh Steam.GetCloudSaves call).
--
-- Entry ids encode the source and slot: "save:N" indexes g_SavedGames in
-- local mode; "cloud:N" indexes the same table in cloud mode (where i also
-- happens to be the Steam cloud slot number). The two modes are mutually
-- exclusive so a picker only ever contains one id scheme at a time.
--
-- Reader tab is always index 2 per PickerReader's install; hardcoded here
-- because the session internals aren't exposed.

SaveMenu = {}

local READER_TAB_IDX = 2

local HEADER_KEYS = {
    mapType    = "TXT_KEY_AD_SETUP_MAP_TYPE",
    mapSize    = "TXT_KEY_AD_SETUP_MAP_SIZE",
    difficulty = "TXT_KEY_AD_SETUP_HANDICAP",
    gameSpeed  = "TXT_KEY_GAME_SPEED",
}

-- --------------------------------------------------------------------------
-- Helpers

local function isMultiplayerStarted()
    return PreGame.IsMultiplayerGame() and PreGame.GameStarted()
end

local function parseId(id)
    local kind, idxStr = string.match(id or "", "^(%a+):(%d+)$")
    if kind == nil then return nil end
    return kind, tonumber(idxStr)
end

local function resolveLeaderCiv(header)
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

local function gameTypeLabel(header)
    if header.GameType == GameTypes.GAME_HOTSEAT_MULTIPLAYER then
        return Text.key("TXT_KEY_MULTIPLAYER_HOTSEAT_GAME")
    elseif header.GameType == GameTypes.GAME_NETWORK_MULTIPLAYER then
        return Text.key("TXT_KEY_MULTIPLAYER_STRING")
    elseif header.GameType == GameTypes.GAME_SINGLE_PLAYER then
        return Text.key("TXT_KEY_SINGLE_PLAYER")
    end
    return nil
end

local function descOf(row)
    if row == nil or row.Description == nil then
        return Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    return Text.key(row.Description)
end

local function addField(leaves, headerKey, value)
    if value == nil or value == "" then return end
    local prefix = ""
    if headerKey ~= nil and headerKey ~= "" then
        prefix = Text.key(headerKey) .. ": "
    end
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = prefix .. value,
    })
end

-- --------------------------------------------------------------------------
-- Save / delete actions
--
-- These replicate the base OnSave / OnYes / OnDelete branching (SaveMenu.lua
-- lines 21-80 and 136-159) without invoking Controls.DeleteConfirm. The
-- confirm flow is instead driven by our pushed Yes/No sub-handlers below.

local function performSaveDisk(text)
    if isMultiplayerStarted() then
        UI.CopyLastAutoSave(text)
    else
        UI.SaveGame(text)
    end
    Controls.NameBox:ClearString()
    SetupFileButtonList()
    OnBack()
end

local function performSaveCloud(slotIndex)
    if isMultiplayerStarted() then
        Steam.CopyLastAutoSaveToSteamCloud(slotIndex)
    else
        Steam.SaveGameToCloud(slotIndex)
    end
    Controls.NameBox:ClearString()
    SetupFileButtonList()
    OnBack()
end

local function performDelete(filename)
    UI.DeleteSavedGame(filename)
    SetupFileButtonList()
end

-- Overwrite / save-to-slot confirm sub. "No" is first so that an accidental
-- Enter on the default cancels rather than commits the overwrite, matching
-- our delete-confirm pattern.
local function pushConfirmSub(mainHandler, subSuffix, promptLabel, onYes)
    local subName = mainHandler.name .. "/" .. subSuffix
    local sub = BaseMenu.create({
        name        = subName,
        displayName = promptLabel,
        items = {
            BaseMenuItems.Choice({
                textKey  = "TXT_KEY_NO_BUTTON",
                activate = function()
                    HandlerStack.removeByName(subName, true)
                end,
            }),
            BaseMenuItems.Choice({
                textKey  = "TXT_KEY_YES_BUTTON",
                activate = function()
                    HandlerStack.removeByName(subName, true)
                    onYes()
                end,
            }),
        },
        escapePops = true,
    })
    HandlerStack.push(sub)
end

-- saveText is the name to pass to UI.SaveGame on Yes. When the overwrite
-- is reached from the top-level Save leaf, it's the user's typed NameBox
-- value (matches base OnYes which passes Controls.NameBox:GetText()
-- verbatim). When reached from the reader's Overwrite leaf, it's the
-- selected save's DisplayName (which SetSelected just wrote into NameBox,
-- so the two paths end up equivalent).
local function pushOverwriteDiskConfirm(mainHandler, entry, saveText)
    local label = Text.format(
        "TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM", entry.DisplayName)
    pushConfirmSub(mainHandler, "OverwriteConfirm", label, function()
        performSaveDisk(saveText)
    end)
end

local function pushOverwriteCloudConfirm(mainHandler, slotIndex)
    local label = Text.format(
        "TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM", slotIndex)
    pushConfirmSub(mainHandler, "OverwriteCloudConfirm", label, function()
        performSaveCloud(slotIndex)
    end)
end

local function pushDeleteConfirm(mainHandler, entry)
    local label = Text.format(
        "TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM", entry.DisplayName)
    local subName = mainHandler.name .. "/DeleteConfirm"
    local sub = BaseMenu.create({
        name        = subName,
        displayName = label,
        items = {
            BaseMenuItems.Choice({
                textKey  = "TXT_KEY_NO_BUTTON",
                activate = function()
                    HandlerStack.removeByName(subName, true)
                end,
            }),
            BaseMenuItems.Choice({
                textKey  = "TXT_KEY_YES_BUTTON",
                activate = function()
                    performDelete(entry.FileName)
                    mainHandler.setItems({
                        BaseMenuItems.Text({
                            textKey = "TXT_KEY_CIVVACCESS_SAVE_DELETED" }),
                    }, READER_TAB_IDX)
                    HandlerStack.removeByName(subName, true)
                end,
            }),
        },
        escapePops = true,
    })
    HandlerStack.push(sub)
end

-- Top-level Save action on the picker tab. Reads the current NameBox text,
-- scans g_SavedGames for a DisplayName collision (case-insensitive, matching
-- base OnSave's scan), and either saves directly or pushes the overwrite
-- confirm. Cloud mode doesn't expose the NameBox, so this fn is never
-- reached there (the Save item is gated on NameBoxFrame visibility).
local function onSaveActivate(mainHandler)
    local text = Controls.NameBox:GetText()
    if text == nil or not ValidateText(text) then
        SpeechPipeline.speakInterrupt(
            Text.key("TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"))
        return
    end
    for _, v in ipairs(g_SavedGames) do
        if v.DisplayName ~= nil and Locale.Length(v.DisplayName) > 0 then
            if Locale.ToUpper(text) == Locale.ToUpper(v.DisplayName) then
                pushOverwriteDiskConfirm(mainHandler, v, text)
                return
            end
        end
    end
    performSaveDisk(text)
end

-- --------------------------------------------------------------------------
-- Reader builder

function SaveMenu.buildReader(mainHandler, id)
    local kind, idx = parseId(id)
    if kind == nil then
        Log.error("SaveMenu: unparseable entry id '" .. tostring(id) .. "'")
        return { items = {} }
    end

    local entry = g_SavedGames[idx]
    if entry == nil then
        Log.warn("SaveMenu: no entry for id '" .. id .. "'")
        return { items = {} }
    end

    -- Sync engine selection. SetSelected populates the detail-panel Controls,
    -- sets NameBox to the entry's DisplayName (local mode), and toggles the
    -- Delete / Save button enabled states. buildReader consumers don't rely
    -- on Controls side-effects, but staying in sync with engine state makes
    -- the sighted panel match what we're announcing.
    SetSelected(entry)

    local leaves = {}
    local isCloud = (kind == "cloud")
    local header = entry.SaveData

    if isCloud and header == nil then
        -- Empty cloud slot: the only leaf is the Save-to-slot action.
        leaves[#leaves + 1] = BaseMenuItems.Text({
            textKey = "TXT_KEY_STEAM_EMPTY_SAVE",
        })
        leaves[#leaves + 1] = BaseMenuItems.Button({
            controlName = "SaveButton",
            textKey     = "TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION",
            activate    = function()
                performSaveCloud(idx)
            end,
        })
        return { items = leaves }
    end

    if header == nil then
        Log.warn("SaveMenu: no header for id '" .. id .. "'")
        return { items = {} }
    end

    -- Leader + civ line (engine's TXT_KEY_RANDOM_LEADER_CIV renders as
    -- "<leader> - <civ>", already localized). Mirrors SaveMenu.xml's Title.
    local leaderDescText, civName = resolveLeaderCiv(header)
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = Text.format(
            "TXT_KEY_RANDOM_LEADER_CIV", leaderDescText, civName),
    })

    -- Saved-on date (disk only; cloud slot headers don't carry an mtime).
    if not isCloud and entry.FileName ~= nil then
        local date = UI.GetSavedGameModificationTime(entry.FileName)
        if date ~= nil and date ~= "" then
            leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = date })
        end
    end

    -- Era / turn. Only emitted when the header carries a current era;
    -- setup-only saves don't.
    if header.CurrentEra ~= nil and header.CurrentEra ~= "" then
        local era = GameInfo.Eras[header.CurrentEra]
        local eraDesc = (era ~= nil and era.Description)
            or "TXT_KEY_MISC_UNKNOWN"
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.format(
                "TXT_KEY_CUR_ERA_TURNS_FORMAT", eraDesc, header.TurnNumber),
        })
    end

    if header.StartEra ~= nil and header.StartEra ~= "" then
        local startEra = GameInfo.Eras[header.StartEra]
        local startEraDesc = (startEra ~= nil and startEra.Description)
            or "TXT_KEY_MISC_UNKNOWN"
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_START_ERA", startEraDesc),
        })
    end

    local gameType = gameTypeLabel(header)
    if gameType ~= nil then
        leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = gameType })
    end

    local mapInfo = MapUtilities.GetBasicInfo(header.MapScript)
    if mapInfo ~= nil and mapInfo.Name ~= nil then
        addField(leaves, HEADER_KEYS.mapType, Locale.Lookup(mapInfo.Name))
    end
    addField(leaves, HEADER_KEYS.mapSize,
        descOf(GameInfo.Worlds[header.WorldSize]))
    addField(leaves, HEADER_KEYS.difficulty,
        descOf(GameInfo.HandicapInfos[header.Difficulty]))
    addField(leaves, HEADER_KEYS.gameSpeed,
        descOf(GameInfo.GameSpeeds[header.GameSpeed]))

    -- Overwrite action: fires pushed confirm sub. Disk-save overwrites go
    -- through UI.SaveGame (which overwrites an existing file of the same
    -- name); cloud slot overwrites through Steam.SaveGameToCloud(i).
    leaves[#leaves + 1] = BaseMenuItems.Button({
        controlName = "SaveButton",
        textKey     = "TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION",
        activate    = function()
            if isCloud then
                pushOverwriteCloudConfirm(mainHandler, idx)
            else
                pushOverwriteDiskConfirm(mainHandler, entry, entry.DisplayName)
            end
        end,
    })

    -- Delete is disk-only; the engine hides Controls.Delete in cloud mode
    -- (SetupFileButtonList line 591), and cloud slots aren't deletable
    -- through this screen (a cloud-slot "delete" would require a separate
    -- Steam API call the base doesn't use).
    if not isCloud then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_DELETE_BUTTON",
            activate = function()
                pushDeleteConfirm(mainHandler, entry)
            end,
        })
    end

    return { items = leaves }
end

-- --------------------------------------------------------------------------
-- Picker builder

local function stripPath(filename)
    if filename == nil or filename == "" then return "" end
    return Path.GetFileNameWithoutExtension(filename)
end

-- Build picker-tab items from current engine state. In local mode the
-- Textfield + Save action + Cloud checkbox sit at the top; saves follow.
-- In cloud mode the Textfield / Save action are omitted (NameBoxFrame is
-- hidden and the save flow is per-slot via the reader tab); only the Cloud
-- checkbox and the slot entries show.
function SaveMenu.buildPickerItems(entryFactory, mainHandlerRef)
    local items = {}
    local inCloudMode = Controls.CloudCheck:IsChecked()

    if not inCloudMode then
        -- Textfield wraps NameBox. priorCallback routes every keystroke
        -- through the game's OnEditBoxChange, which validates filename
        -- chars and enables / disables the engine SaveButton. Enter-commit
        -- from edit mode calls priorCallback(text, control, bIsEnter=true),
        -- which the game routes to OnSave. We don't want that (it triggers
        -- the game's OnSave which would pop the visual overlay on a
        -- collision). So wrap priorCallback to drop bIsEnter so commit is
        -- just a value update, and let our Save leaf handle the save action.
        items[#items + 1] = BaseMenuItems.Textfield({
            controlName           = "NameBox",
            textKey               = "TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL",
            visibilityControlName = "NameBoxFrame",
            priorCallback         = function(text, control, _)
                OnEditBoxChange(text, control, false)
            end,
        })
        items[#items + 1] = BaseMenuItems.Button({
            controlName = "SaveButton",
            textKey     = "TXT_KEY_MENU_SAVE",
            activate    = function()
                onSaveActivate(mainHandlerRef())
            end,
        })
    end

    items[#items + 1] = BaseMenuItems.Checkbox({
        controlName = "CloudCheck",
        textKey     = "TXT_KEY_STEAMCLOUD",
    })

    -- Save entries. g_SavedGames is populated by SetupFileButtonList in
    -- whichever mode is active: local mode iterates g_SavedGames as a dense
    -- array of existing saves; cloud mode iterates 1..s_maxCloudSaves with
    -- every slot present (SaveData may be nil for empty slots).
    if inCloudMode then
        for i, v in ipairs(g_SavedGames) do
            local label
            if v.SaveData ~= nil then
                local leaderDescText, civName = resolveLeaderCiv(v.SaveData)
                local name = Text.format(
                    "TXT_KEY_RANDOM_LEADER_CIV", leaderDescText, civName)
                label = Text.format("TXT_KEY_STEAMCLOUD_SAVE", i, name)
            else
                label = Text.format(
                    "TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY", i)
            end
            items[#items + 1] = entryFactory({
                id          = "cloud:" .. tostring(i),
                labelText   = label,
                buildReader = function(_, id)
                    return SaveMenu.buildReader(mainHandlerRef(), id)
                end,
            })
        end
    else
        for i, v in ipairs(g_SavedGames) do
            items[#items + 1] = entryFactory({
                id          = "save:" .. tostring(i),
                labelText   = v.DisplayName or stripPath(v.FileName),
                buildReader = function(_, id)
                    return SaveMenu.buildReader(mainHandlerRef(), id)
                end,
            })
        end
    end

    -- Empty-list placeholder so the picker never ships zero items
    -- (PickerReader rejects an empty pickerItems on install). Only reachable
    -- when inCloudMode is true and g_SavedGames is somehow empty (shouldn't
    -- happen since cloud mode always builds s_maxCloudSaves slots), or in
    -- local mode when no saves exist AND our top three fixed items somehow
    -- didn't make it in (also shouldn't happen). Defensive.
    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            textKey = "TXT_KEY_CIVVACCESS_SAVE_NO_SAVES",
        })
    end

    return items
end

return SaveMenu

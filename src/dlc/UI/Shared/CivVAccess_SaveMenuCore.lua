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

local stripPath = SavedGameShared.stripPath
local parseId = SavedGameShared.parseId
local resolveLeaderCiv = SavedGameShared.resolveLeaderCiv

local function isMultiplayerStarted()
    return PreGame.IsMultiplayerGame() and PreGame.GameStarted()
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
        name = subName,
        displayName = promptLabel,
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
    local label = Text.format("TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM", entry.DisplayName)
    pushConfirmSub(mainHandler, "OverwriteConfirm", label, function()
        performSaveDisk(saveText)
    end)
end

local function pushOverwriteCloudConfirm(mainHandler, slotIndex)
    local label = Text.format("TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM", slotIndex)
    pushConfirmSub(mainHandler, "OverwriteCloudConfirm", label, function()
        performSaveCloud(slotIndex)
    end)
end

local function pushDeleteConfirm(mainHandler, entry)
    local label = Text.format("TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM", entry.DisplayName)
    pushConfirmSub(mainHandler, "DeleteConfirm", label, function()
        performDelete(entry.FileName)
        mainHandler.setItems({
            BaseMenuItems.Text({ textKey = "TXT_KEY_CIVVACCESS_SAVE_DELETED" }),
        }, READER_TAB_IDX)
    end)
end

-- Top-level Save action on the picker tab. Reads the current NameBox text,
-- scans g_SavedGames for a DisplayName collision (case-insensitive, matching
-- base OnSave's scan), and either saves directly or pushes the overwrite
-- confirm. Cloud mode doesn't expose the NameBox, so this fn is never
-- reached there (the Save item is gated on NameBoxFrame visibility).
local function onSaveActivate(mainHandler)
    local text = Controls.NameBox:GetText()
    if text == nil or not ValidateText(text) then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"))
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
            textKey = "TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION",
            activate = function()
                performSaveCloud(idx)
            end,
        })
        return { items = leaves }
    end

    if header == nil then
        Log.warn("SaveMenu: no header for id '" .. id .. "'")
        return { items = {} }
    end

    -- Saved-on date (disk only; cloud slot headers don't carry an mtime).
    -- Pre-resolve so the shared header builder gets a plain string.
    local date
    if not isCloud and entry.FileName ~= nil then
        date = UI.GetSavedGameModificationTime(entry.FileName)
    end
    SavedGameShared.appendStandardHeaderLeaves(leaves, header, { date = date })

    -- Overwrite action: fires pushed confirm sub. Disk-save overwrites go
    -- through UI.SaveGame (which overwrites an existing file of the same
    -- name); cloud slot overwrites through Steam.SaveGameToCloud(i).
    leaves[#leaves + 1] = BaseMenuItems.Button({
        controlName = "SaveButton",
        textKey = "TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION",
        activate = function()
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
            textKey = "TXT_KEY_DELETE_BUTTON",
            activate = function()
                pushDeleteConfirm(mainHandler, entry)
            end,
        })
    end

    return { items = leaves }
end

-- --------------------------------------------------------------------------
-- Picker builder

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
            controlName = "NameBox",
            textKey = "TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL",
            visibilityControlName = "NameBoxFrame",
            priorCallback = function(text, control, _)
                OnEditBoxChange(text, control, false)
            end,
        })
        items[#items + 1] = BaseMenuItems.Button({
            controlName = "SaveButton",
            textKey = "TXT_KEY_MENU_SAVE",
            activate = function()
                onSaveActivate(mainHandlerRef())
            end,
        })
    end

    items[#items + 1] = BaseMenuItems.Checkbox({
        controlName = "CloudCheck",
        textKey = "TXT_KEY_STEAMCLOUD",
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
                local name = Text.format("TXT_KEY_RANDOM_LEADER_CIV", leaderDescText, civName)
                label = Text.format("TXT_KEY_STEAMCLOUD_SAVE", i, name)
            else
                label = Text.format("TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY", i)
            end
            items[#items + 1] = entryFactory({
                id = "cloud:" .. tostring(i),
                labelText = label,
                buildReader = function(_, id)
                    return SaveMenu.buildReader(mainHandlerRef(), id)
                end,
            })
        end
    else
        for i, v in ipairs(g_SavedGames) do
            items[#items + 1] = entryFactory({
                id = "save:" .. tostring(i),
                labelText = v.DisplayName or stripPath(v.FileName),
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
    -- didn't make it in (also shouldn't happen).
    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            textKey = "TXT_KEY_CIVVACCESS_SAVE_NO_SAVES",
        })
    end

    return items
end

return SaveMenu

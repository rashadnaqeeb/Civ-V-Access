-- LoadMenu data module. Two public fns:
--   LoadMenu.buildPickerItems(entryFactory, handlerRef) - picker-tab items
--     for the current g_FileList (regular / autosave mode) or g_CloudSaves
--     (Steam Cloud mode), followed by the Autosaves / Steam Cloud filter
--     checkboxes. One Entry per save (or populated cloud slot); label is the
--     bare filename with path and extension stripped (matches engine UI).
--   LoadMenu.buildReader(handlerRef, id) - reader-tab leaves for the save
--     identified by id: the save's header fields plus Load / Delete /
--     Show-DLC / Show-Mods action leaves.
--
-- Why not query PreGame.GetFileHeader during picker build: headers are a
-- per-save filesystem read. Engine UI reads them lazily on row selection;
-- we match that and only read inside buildReader. Picker stays responsive
-- with hundreds of saves.
--
-- Never cache header data: every buildReader call re-reads from PreGame.
-- g_iSelected is engine-owned state that Load / Delete callbacks read, so
-- buildReader calls SetSelected(index) first to sync it before reading.
-- That also populates g_SavedGameModsRequired / g_SavedGameDLCRequired which
-- the mods / DLC conditional leaves consult.
--
-- Entry ids encode the source and slot: "save:N" indexes g_FileList;
-- "cloud:N" indexes g_CloudSaves (== Steam cloud slot number). The two
-- modes are mutually exclusive (g_ShowAutoSaves / g_ShowCloudSaves) so a
-- picker only ever contains one id scheme at a time.
--
-- Reader tab is always index 2 per PickerReader's install; hardcoded here
-- because the session internals aren't exposed.

LoadMenu = {}

local READER_TAB_IDX = 2

-- Detail field header labels. Engine TXT_KEYs keep speech aligned with the
-- sighted-user labels (LoadMenu.xml tooltip strings) and pick up localization.
local HEADER_KEYS = {
    mapType    = "TXT_KEY_AD_SETUP_MAP_TYPE",
    mapSize    = "TXT_KEY_AD_SETUP_MAP_SIZE",
    difficulty = "TXT_KEY_AD_SETUP_HANDICAP",
    gameSpeed  = "TXT_KEY_GAME_SPEED",
}

-- --------------------------------------------------------------------------
-- Helpers

local function stripPath(filename)
    if filename == nil or filename == "" then return "" end
    return Path.GetFileNameWithoutExtension(filename)
end

-- Order g_FileList's original indices to match the currently-selected engine
-- sort (g_CurrentSort is one of the SortByLastModified / SortByName globals
-- defined in LoadMenu.lua). Our picker is a separate list from the engine's
-- visual Stack, so we replicate the sort here rather than try to read order
-- out of the Stack. Returns a flat array of g_FileList indices; entry ids
-- remain "save:<original-index>" so the picker's Entry identities stay stable
-- across re-sorts and PickerReader cursor restoration works.
local function sortedFileIndices()
    local records = {}
    for i, filename in ipairs(g_FileList) do
        records[#records + 1] = { idx = i, filename = filename }
    end
    if g_CurrentSort == SortByLastModified then
        -- Read mtimes once up front; table.sort's comparator can fire
        -- N log N times and filesystem reads per compare would get
        -- expensive on large save directories.
        for _, r in ipairs(records) do
            r.high, r.low = UI.GetSavedGameModificationTimeRaw(r.filename)
        end
        table.sort(records, function(a, b)
            return UI.CompareFileTime(a.high, a.low, b.high, b.low) == 1
        end)
    elseif g_CurrentSort == SortByName then
        -- SortByName inverts to reverse-alphabetical in autosave mode; match.
        for _, r in ipairs(records) do r.name = stripPath(r.filename) end
        if g_ShowAutoSaves then
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
    for i, r in ipairs(records) do indices[i] = r.idx end
    return indices
end

-- Apply a sort choice. Mirrors the base per-entry button callback from
-- LoadMenu.lua lines 716-721 plus a picker rebuild. Done in Lua (not by
-- wrapping the engine's entry callback) because our Sort-by Group drives
-- its own Choice items rather than going through the base pulldown's
-- sub-menu. Visual state is kept in sync for sighted observers: the
-- pulldown's button text changes and SortChildren reorders the hidden
-- Stack, same as a mouse-driven sort pick.
local function applySort(mainHandler, entryFactory, handlerRefThunk,
                        sortFn, labelKey)
    g_CurrentSort = sortFn
    Controls.SortByPullDown:GetButton():LocalizeAndSetText(
        Locale.ConvertTextKey(labelKey))
    Controls.LoadFileButtonStack:SortChildren(sortFn)
    local newItems = LoadMenu.buildPickerItems(entryFactory, handlerRefThunk)
    mainHandler.setItems(newItems, 1)
end

-- Decode an entry id from buildPickerItems back into (kind, numeric index).
-- Returns nil on malformed ids so the caller can log through its own path.
local function parseId(id)
    local kind, idxStr = string.match(id or "", "^(%a+):(%d+)$")
    if kind == nil then return nil end
    return kind, tonumber(idxStr)
end

-- Resolve leader / civ display text from a header, falling back to
-- GameInfo.Civilizations[...] / Civilization_Leaders when the header doesn't
-- carry an override. Mirrors LoadMenu.SetSelected lines 292-331.
local function resolveLeaderCiv(header)
    local civName        = Locale.ConvertTextKey("TXT_KEY_MISC_UNKNOWN")
    local leaderDescText = Locale.ConvertTextKey("TXT_KEY_MISC_UNKNOWN")
    local civ = GameInfo.Civilizations[header.PlayerCivilization]
    if civ ~= nil then
        civName = Locale.ConvertTextKey(civ.Description)
        local row = GameInfo.Civilization_Leaders(
            "CivilizationType = '" .. civ.Type .. "'")()
        if row ~= nil then
            local leader = GameInfo.Leaders[row.LeaderheadType]
            if leader ~= nil then
                leaderDescText = Locale.ConvertTextKey(leader.Description)
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
        return Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_HOTSEAT_GAME")
    elseif header.GameType == GameTypes.GAME_NETWORK_MULTIPLAYER then
        return Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_STRING")
    elseif header.GameType == GameTypes.GAME_SINGLE_PLAYER then
        return Locale.ConvertTextKey("TXT_KEY_SINGLE_PLAYER")
    end
    return nil
end

-- Resolve a GameInfo row's localized Description, falling back to a
-- TXT_KEY_MISC_UNKNOWN when the row or its Description is missing. Used for
-- map size / difficulty / game speed (all follow the same schema).
local function descOf(row)
    if row == nil or row.Description == nil then
        return Locale.ConvertTextKey("TXT_KEY_MISC_UNKNOWN")
    end
    return Locale.ConvertTextKey(row.Description)
end

local function addField(leaves, headerKey, value)
    if value == nil or value == "" then return end
    local prefix = ""
    if headerKey ~= nil and headerKey ~= "" then
        prefix = Locale.ConvertTextKey(headerKey) .. ": "
    end
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = prefix .. value,
    })
end

-- Push an additional sub-menu listing referenced DLC / Mods names. Opened
-- from the Show-DLC / Show-Mods action leaves. List text mirrors LoadMenu.lua
-- lines 145-203 but strips the "[ICON_BULLET]" prefix (the icon filter would
-- drop it anyway and the bullet carries no information in speech).
local function pushRequirementsSub(mainHandler, kind)
    local list
    local displayKey
    if kind == "mods" then
        list = g_SavedGameModsRequired
        displayKey = "TXT_KEY_LOAD_MENU_REQUIRED_MODS"
    else
        list = g_SavedGameDLCRequired
        displayKey = "TXT_KEY_LOAD_MENU_REQUIRED_DLC"
    end
    if list == nil or #list == 0 then return end
    local items = {}
    for _, v in ipairs(list) do
        local name
        if kind == "dlc" and v.DescriptionKey ~= nil
                and Locale.HasTextKey(v.DescriptionKey) then
            name = Locale.ConvertTextKey(v.DescriptionKey)
        else
            name = v.Title or ""
            if Locale.HasTextKey(name) then
                name = Locale.ConvertTextKey(name)
            end
        end
        if kind == "mods" and v.Version ~= nil then
            name = name .. " version " .. tostring(v.Version)
        end
        items[#items + 1] = BaseMenuItems.Text({ labelText = name })
    end
    local sub = BaseMenu.create({
        name        = mainHandler.name .. "/Requirements",
        displayName = Locale.ConvertTextKey(displayKey),
        items       = items,
        escapePops  = true,
    })
    HandlerStack.push(sub)
end

-- Delete confirmation: we bypass the visual DeleteConfirm popup (it carries
-- no speech affordance and a blind user has no reason to see it) and push a
-- pure-speech Yes/No sub. On Yes the delete + SetupFileButtonList fires;
-- our monkey-patched SetupFileButtonList rebuilds the picker, and the reader
-- tab gets a one-item "deleted" placeholder so the stale save details can't
-- be read back. Esc on the sub pops without committing (escapePops).
local function pushDeleteConfirmSub(mainHandler, filename)
    if filename == nil or filename == "" then return end
    local displayName = stripPath(filename)
    local confirmLabel = Text.format(
        "TXT_KEY_CIVVACCESS_LOAD_DELETE_CONFIRM", displayName)
    local subName = mainHandler.name .. "/DeleteConfirm"
    local sub = BaseMenu.create({
        name        = subName,
        displayName = confirmLabel,
        -- No first so that arrow-down to Yes is an explicit affirmative step;
        -- accidental Enter on the default cancels rather than deletes.
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
                    UI.DeleteSavedGame(filename)
                    SetupFileButtonList()
                    mainHandler.setItems({
                        BaseMenuItems.Text({
                            textKey = "TXT_KEY_CIVVACCESS_LOAD_DELETED" }),
                    }, READER_TAB_IDX)
                    HandlerStack.removeByName(subName, true)
                end,
            }),
        },
        escapePops = true,
    })
    HandlerStack.push(sub)
end

-- --------------------------------------------------------------------------
-- Reader builder

-- Build reader leaves for the save identified by id. Called by PickerReader
-- on every Entry activation; never caches. id parse failure or a nil header
-- returns an empty list so PickerReader falls through to the empty-reader
-- placeholder. Logs the failure so silent nothing doesn't reach the user
-- without an explanation in Lua.log.
function LoadMenu.buildReader(mainHandler, id)
    local kind, idx = parseId(id)
    if kind == nil then
        Log.error("LoadMenu: unparseable entry id '" .. tostring(id) .. "'")
        return { items = {} }
    end

    -- Sync engine selection. SetSelected populates g_iSelected, the detail-
    -- panel Controls, and g_SavedGameModsRequired / g_SavedGameDLCRequired.
    -- Our Load / Delete / Show-{DLC,Mods} leaves read those.
    SetSelected(idx)

    local header
    local filename
    local isCloud = (kind == "cloud")
    if isCloud then
        header = g_CloudSaves[idx]
    else
        filename = g_FileList[idx]
        if filename ~= nil then
            header = PreGame.GetFileHeader(filename)
        end
    end
    if header == nil then
        Log.warn("LoadMenu: no header for id '" .. id .. "'")
        return { items = {} }
    end

    local leaves = {}

    -- Leader + civ line. Engine's TXT_KEY_RANDOM_LEADER_CIV renders
    -- "<leader> - <civ>" (already localized). Used as the reader header
    -- equivalent to LoadMenu.xml's Title label.
    local leaderDescText, civName = resolveLeaderCiv(header)
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = Locale.ConvertTextKey(
            "TXT_KEY_RANDOM_LEADER_CIV", leaderDescText, civName),
    })

    -- Saved-on date (regular / autosave only; cloud saves lack a filesystem
    -- mtime from our side).
    if not isCloud and filename ~= nil then
        local date = UI.GetSavedGameModificationTime(filename)
        if date ~= nil and date ~= "" then
            leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = date })
        end
    end

    -- Era / turn (TXT_KEY_CUR_ERA_TURNS_FORMAT = "<era>: <N> Turns"). Only
    -- emitted when the header carries a current era; setup-only saves don't.
    if header.CurrentEra ~= nil and header.CurrentEra ~= "" then
        local era = GameInfo.Eras[header.CurrentEra]
        local eraDesc = (era ~= nil and era.Description)
            or "TXT_KEY_MISC_UNKNOWN"
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Locale.ConvertTextKey(
                "TXT_KEY_CUR_ERA_TURNS_FORMAT", eraDesc, header.TurnNumber),
        })
    end

    -- Start era ("<era> Start").
    if header.StartEra ~= nil and header.StartEra ~= "" then
        local startEra = GameInfo.Eras[header.StartEra]
        local startEraDesc = (startEra ~= nil and startEra.Description)
            or "TXT_KEY_MISC_UNKNOWN"
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Locale.ConvertTextKey(
                "TXT_KEY_START_ERA", startEraDesc),
        })
    end

    -- Game type (single / hotseat / network).
    local gameType = gameTypeLabel(header)
    if gameType ~= nil then
        leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = gameType })
    end

    -- Map, size, difficulty, speed.
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

    -- Action leaves. Load first (the primary action), Delete second, then
    -- conditional Show-DLC / Show-Mods when the save has unmet requirements.

    -- Load uses the engine's StartButton for the disabled / enabled gate:
    -- SetSelected just populated its tooltip with the reason (missing DLC,
    -- incompatible mods, wrong game type) and toggled its SetDisabled state.
    -- BaseMenuItems.Button.isActivatable reads IsDisabled and announces
    -- "disabled" with the tooltip reason appended.
    leaves[#leaves + 1] = BaseMenuItems.Button({
        controlName = "StartButton",
        textKey     = "TXT_KEY_LOAD_GAME",
        tooltipFn   = function(control)
            local ok, tip = pcall(function()
                return control:GetToolTipString()
            end)
            if ok and tip ~= nil and tip ~= "" then return tip end
            return nil
        end,
        activate = function() OnStartButton() end,
    })

    -- Delete: not available in cloud mode (engine hides Controls.Delete via
    -- UpdateControlStates). We match by not emitting the leaf.
    if not isCloud then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_DELETE_BUTTON",
            activate = function()
                pushDeleteConfirmSub(mainHandler, filename)
            end,
        })
    end

    -- Show-DLC / Show-Mods: engine populates g_SavedGameDLCRequired /
    -- g_SavedGameModsRequired during SetSelected only when the save carries
    -- non-default DLC / mod requirements. Empty list means the save runs on
    -- the base content set; skip the leaf.
    if g_SavedGameDLCRequired ~= nil and #g_SavedGameDLCRequired > 0 then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_LOAD_MENU_DLC",
            activate = function()
                pushRequirementsSub(mainHandler, "dlc")
            end,
        })
    end
    if g_SavedGameModsRequired ~= nil and #g_SavedGameModsRequired > 0 then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_LOAD_MENU_MODS",
            activate = function()
                pushRequirementsSub(mainHandler, "mods")
            end,
        })
    end

    return { items = leaves }
end

-- --------------------------------------------------------------------------
-- Picker builder

-- Build picker-tab items from current engine state. Saves come first so the
-- cursor lands on one on open (first navigable); the Autosaves / Cloud
-- filter checkboxes sit at the tail. An empty list keeps a single "no saves"
-- Text leaf before the filters so PickerReader's pickerItems > 0 invariant
-- holds and the list stays announceable.
--
-- Regular and autosave modes iterate g_FileList; the two are distinguished
-- only by what UI.SaveFileList populated (the engine's AutoCheck handler
-- toggled g_ShowAutoSaves and re-ran SaveFileList before we got here).
-- Cloud mode iterates g_CloudSaves and skips empty slots since an empty
-- cloud slot isn't a loadable save.
function LoadMenu.buildPickerItems(entryFactory, mainHandlerRef)
    local items = {}

    if g_ShowCloudSaves then
        for i = 1, Steam.GetMaxCloudSaves(), 1 do
            local slotHeader = g_CloudSaves[i]
            if slotHeader ~= nil then
                -- Engine renders cloud rows as "Steam Cloud save <N>: <name>".
                -- Speak the same string so the user hears what the sighted
                -- UI shows; TXT_KEY_STEAMCLOUD_SAVE is the engine's format
                -- key for that.
                local leaderDescText, civName = resolveLeaderCiv(slotHeader)
                local name = Locale.ConvertTextKey(
                    "TXT_KEY_RANDOM_LEADER_CIV", leaderDescText, civName)
                local label = Locale.ConvertTextKey(
                    "TXT_KEY_STEAMCLOUD_SAVE", i, name)
                items[#items + 1] = entryFactory({
                    id          = "cloud:" .. tostring(i),
                    labelText   = label,
                    buildReader = function(handler, id)
                        return LoadMenu.buildReader(mainHandlerRef(), id)
                    end,
                })
            end
        end
    else
        for _, i in ipairs(sortedFileIndices()) do
            local filename = g_FileList[i]
            items[#items + 1] = entryFactory({
                id          = "save:" .. tostring(i),
                labelText   = stripPath(filename),
                buildReader = function(handler, id)
                    return LoadMenu.buildReader(mainHandlerRef(), id)
                end,
            })
        end
    end

    -- Empty-list placeholder before the filter checkboxes so the picker
    -- never ships zero items (PickerReader rejects an empty pickerItems).
    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            textKey = "TXT_KEY_CIVVACCESS_LOAD_NO_SAVES",
        })
    end

    -- Sort-by Group. Exposes Last Modified / Name as Choice children with
    -- selectedFn flagging the current sort. Visibility-gated on the engine
    -- pulldown's hidden state: in cloud mode the base UI hides
    -- Controls.SortByPullDown (LoadMenu.lua line 106) and we follow suit.
    -- Each Choice calls applySort which also touches the base pulldown's
    -- button text and the visual Stack's SortChildren for sighted parity.
    items[#items + 1] = BaseMenuItems.Group({
        textKey               = "TXT_KEY_CIVVACCESS_LOAD_SORT_BY",
        visibilityControlName = "SortByPullDown",
        items = {
            BaseMenuItems.Choice({
                textKey    = "TXT_KEY_SORTBY_LASTMODIFIED",
                selectedFn = function()
                    return g_CurrentSort == SortByLastModified
                end,
                activate = function()
                    applySort(mainHandlerRef(), entryFactory, mainHandlerRef,
                        SortByLastModified, "TXT_KEY_SORTBY_LASTMODIFIED")
                end,
            }),
            BaseMenuItems.Choice({
                textKey    = "TXT_KEY_SORTBY_NAME",
                selectedFn = function()
                    return g_CurrentSort == SortByName
                end,
                activate = function()
                    applySort(mainHandlerRef(), entryFactory, mainHandlerRef,
                        SortByName, "TXT_KEY_SORTBY_NAME")
                end,
            }),
        },
    })

    -- Filter toggles. Backed by the engine Controls.AutoCheck /
    -- Controls.CloudCheck, whose CheckHandlers the pulldown probe captured
    -- at LoadMenu.lua lines 91 and 102. Activating the checkbox calls
    -- that handler, which flips g_ShowAutoSaves / g_ShowCloudSaves and
    -- calls SetupFileButtonList; our monkey-patched wrapper catches the
    -- rebuild and refreshes the picker.
    items[#items + 1] = BaseMenuItems.Checkbox({
        controlName = "AutoCheck",
        textKey     = "TXT_KEY_AUTOSAVES",
    })
    items[#items + 1] = BaseMenuItems.Checkbox({
        controlName = "CloudCheck",
        textKey     = "TXT_KEY_STEAMCLOUD",
    })

    return items
end

return LoadMenu

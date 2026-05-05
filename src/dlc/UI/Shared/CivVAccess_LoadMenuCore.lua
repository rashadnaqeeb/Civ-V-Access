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

local stripPath = SavedGameShared.stripPath
local parseId = SavedGameShared.parseId
local resolveLeaderCiv = SavedGameShared.resolveLeaderCiv

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
        header = PreGame.GetFileHeader(filename)
    end
    if header == nil then
        Log.warn("LoadMenu: no header for id '" .. id .. "'")
        return { items = {} }
    end

    local leaves = {}

    -- Saved-on date (regular / autosave only; cloud saves lack a filesystem
    -- mtime from our side). Resolved upfront so the shared header builder
    -- gets a plain string.
    local date
    if not isCloud and filename ~= nil then
        date = UI.GetSavedGameModificationTime(filename)
    end
    SavedGameShared.appendStandardHeaderLeaves(leaves, header, { date = date })

    -- Action leaves. Load first (the primary action), Delete second, then
    -- conditional Show-DLC / Show-Mods when the save has unmet requirements.

    -- Load uses the engine's StartButton for the disabled / enabled gate:
    -- SetSelected just populated its tooltip with the reason (missing DLC,
    -- incompatible mods, wrong game type) and toggled its SetDisabled state.
    -- BaseMenuItems.Button.isActivatable reads IsDisabled and announces
    -- "disabled" with the tooltip reason appended.
    leaves[#leaves + 1] = BaseMenuItems.Button({
        controlName = "StartButton",
        textKey = "TXT_KEY_LOAD_GAME",
        tooltipFn = function(control)
            local ok, tip = pcall(function()
                return control:GetToolTipString()
            end)
            if not ok then
                Log.warn("LoadMenu: StartButton GetToolTipString failed: " .. tostring(tip))
                return nil
            end
            if tip ~= nil and tip ~= "" then
                return tip
            end
            return nil
        end,
        activate = function()
            OnStartButton()
        end,
    })

    -- Delete: not available in cloud mode (engine hides Controls.Delete via
    -- UpdateControlStates). We match by not emitting the leaf.
    if not isCloud then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey = "TXT_KEY_DELETE_BUTTON",
            activate = function()
                SavedGameShared.pushDeleteConfirmSub(mainHandler, filename, {
                    deleteFn = UI.DeleteSavedGame,
                    deletedTextKey = "TXT_KEY_CIVVACCESS_LOAD_DELETED",
                })
            end,
        })
    end

    -- Show-DLC / Show-Mods: engine populates g_SavedGameDLCRequired /
    -- g_SavedGameModsRequired during SetSelected only when the save carries
    -- non-default DLC / mod requirements. Empty list means the save runs on
    -- the base content set; skip the leaf.
    if g_SavedGameDLCRequired ~= nil and #g_SavedGameDLCRequired > 0 then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey = "TXT_KEY_LOAD_MENU_DLC",
            activate = function()
                SavedGameShared.pushRequirementsSub(mainHandler, "dlc", g_SavedGameDLCRequired, g_SavedGameModsRequired)
            end,
        })
    end
    if g_SavedGameModsRequired ~= nil and #g_SavedGameModsRequired > 0 then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey = "TXT_KEY_LOAD_MENU_MODS",
            activate = function()
                SavedGameShared.pushRequirementsSub(
                    mainHandler,
                    "mods",
                    g_SavedGameDLCRequired,
                    g_SavedGameModsRequired
                )
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
                local name = Text.format("TXT_KEY_RANDOM_LEADER_CIV", leaderDescText, civName)
                local label = Text.format("TXT_KEY_STEAMCLOUD_SAVE", i, name)
                items[#items + 1] = entryFactory({
                    id = "cloud:" .. tostring(i),
                    labelText = label,
                    buildReader = function(handler, id)
                        return LoadMenu.buildReader(mainHandlerRef(), id)
                    end,
                })
            end
        end
    else
        local indices = SavedGameShared.sortedFileIndices(g_FileList, {
            mtimeRawFn = UI.GetSavedGameModificationTimeRaw,
            -- SortByName inverts to reverse-alphabetical in autosave mode.
            reverseAlphaSortFn = function()
                return g_ShowAutoSaves
            end,
        })
        for _, i in ipairs(indices) do
            local filename = g_FileList[i]
            items[#items + 1] = entryFactory({
                id = "save:" .. tostring(i),
                labelText = stripPath(filename),
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

    -- Sort-by Group. Visibility-gated on the engine pulldown's hidden state:
    -- in cloud mode the base UI hides Controls.SortByPullDown (LoadMenu.lua
    -- line 106) and the Group follows suit.
    items[#items + 1] = SavedGameShared.makeSortByGroup(entryFactory, mainHandlerRef, LoadMenu.buildPickerItems)

    -- Filter toggles. Backed by the engine Controls.AutoCheck /
    -- Controls.CloudCheck, whose CheckHandlers the pulldown probe captured
    -- at LoadMenu.lua lines 91 and 102. Activating the checkbox calls
    -- that handler, which flips g_ShowAutoSaves / g_ShowCloudSaves and
    -- calls SetupFileButtonList; our monkey-patched wrapper catches the
    -- rebuild and refreshes the picker.
    items[#items + 1] = BaseMenuItems.Checkbox({
        controlName = "AutoCheck",
        textKey = "TXT_KEY_AUTOSAVES",
    })
    items[#items + 1] = BaseMenuItems.Checkbox({
        controlName = "CloudCheck",
        textKey = "TXT_KEY_STEAMCLOUD",
    })

    return items
end

return LoadMenu

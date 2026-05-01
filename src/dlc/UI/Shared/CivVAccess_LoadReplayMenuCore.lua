-- LoadReplayMenu data module. Two public fns:
--   LoadReplayMenu.buildPickerItems(entryFactory, handlerRef) - picker-tab
--     items for the current g_FileList, followed by a Sort-by Group.
--     One Entry per replay; label is the bare filename (path / extension
--     stripped, same as engine).
--   LoadReplayMenu.buildReader(handlerRef, id) - reader-tab leaves for the
--     replay identified by id: header fields plus Select / Delete /
--     Show-DLC / Show-Mods action leaves.
--
-- Why not query UI.GetReplayFileHeader during picker build: headers are a
-- per-file filesystem read. Engine UI reads them lazily on row selection;
-- we match that and only read inside buildReader.
--
-- Never cache header data: every buildReader call re-reads. g_iSelected is
-- engine-owned state the Select / Delete callbacks read, so buildReader
-- calls SetSelected(index) first to sync it. That also populates
-- g_ReplayModsRequired / g_ReplayDLCRequired which the mods / DLC
-- conditional leaves consult, and sets the SelectReplayButton's disabled
-- state + tooltip from Modding.CanLoadReplay.
--
-- Entry ids are "replay:N" where N indexes g_FileList.
--
-- Reader tab is always index 2 per PickerReader's install; hardcoded here
-- because the session internals aren't exposed.

LoadReplayMenu = {}

local stripPath = SavedGameShared.stripPath
local parseId = SavedGameShared.parseId

-- --------------------------------------------------------------------------
-- Reader builder

function LoadReplayMenu.buildReader(mainHandler, id)
    local kind, idx = parseId(id)
    if kind == nil then
        Log.error("LoadReplayMenu: unparseable entry id '" .. tostring(id) .. "'")
        return { items = {} }
    end

    -- Sync engine selection. SetSelected populates g_iSelected, the detail-
    -- panel Controls, g_ReplayModsRequired / g_ReplayDLCRequired, and the
    -- SelectReplayButton's disabled state / tooltip.
    SetSelected(idx)

    local filename = g_FileList[idx]
    local header = UI.GetReplayFileHeader(filename)
    if header == nil then
        Log.warn("LoadReplayMenu: no header for id '" .. id .. "'")
        return {
            items = {
                BaseMenuItems.Text({
                    textKey = "TXT_KEY_LOAD_REPLAY_MENU_INVALID_REPLAY_FILE",
                }),
            },
        }
    end

    local leaves = {}
    -- Replays always emit the era/turn leaf (alwaysEmitEra). CurrentEra may
    -- be empty on replays of scenarios that never set one; appendStandard
    -- substitutes TXT_KEY_MISC_UNKNOWN. StartEra uses TXT_KEY_START_ERA_FORMAT
    -- here vs TXT_KEY_START_ERA in LoadMenu / SaveMenu (replay-specific key).
    -- Game type is omitted for replays.
    SavedGameShared.appendStandardHeaderLeaves(leaves, header, {
        date = UI.GetReplayModificationTime(filename),
        alwaysEmitEra = true,
        startEraFormatKey = "TXT_KEY_START_ERA_FORMAT",
        skipGameType = true,
    })

    -- Select Replay: the primary action. SetSelected just populated the
    -- button's tooltip (missing DLC / incompatible mods reason) and toggled
    -- IsDisabled. BaseMenuItems.Button reads IsDisabled and announces
    -- "disabled" with the tooltip reason appended.
    leaves[#leaves + 1] = BaseMenuItems.Button({
        controlName = "SelectReplayButton",
        textKey = "TXT_KEY_LOAD_REPLAY_MENU_SELECT_REPLAY",
        tooltipFn = function(control)
            local ok, tip = pcall(function()
                return control:GetToolTipString()
            end)
            if not ok then
                Log.warn("LoadReplayMenu: SelectReplayButton GetToolTipString failed: " .. tostring(tip))
                return nil
            end
            if tip ~= nil and tip ~= "" then
                return tip
            end
            return nil
        end,
        activate = function()
            OnSelectReplay()
        end,
    })

    leaves[#leaves + 1] = BaseMenuItems.Choice({
        textKey = "TXT_KEY_DELETE_BUTTON",
        activate = function()
            SavedGameShared.pushDeleteConfirmSub(mainHandler, filename, {
                deleteFn = UI.DeleteReplayFile,
                deletedTextKey = "TXT_KEY_CIVVACCESS_REPLAY_DELETED",
            })
        end,
    })

    -- Show-DLC / Show-Mods: emitted only when the replay carries unmet
    -- requirements (SetSelected fills these; empty means base content set).
    if g_ReplayDLCRequired ~= nil and #g_ReplayDLCRequired > 0 then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey = "TXT_KEY_LOAD_MENU_DLC",
            activate = function()
                SavedGameShared.pushRequirementsSub(mainHandler, "dlc",
                    g_ReplayDLCRequired, g_ReplayModsRequired)
            end,
        })
    end
    if g_ReplayModsRequired ~= nil and #g_ReplayModsRequired > 0 then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey = "TXT_KEY_LOAD_MENU_MODS",
            activate = function()
                SavedGameShared.pushRequirementsSub(mainHandler, "mods",
                    g_ReplayDLCRequired, g_ReplayModsRequired)
            end,
        })
    end

    return { items = leaves }
end

-- --------------------------------------------------------------------------
-- Picker builder

function LoadReplayMenu.buildPickerItems(entryFactory, mainHandlerRef)
    local items = {}

    local indices = SavedGameShared.sortedFileIndices(g_FileList, {
        mtimeRawFn = UI.GetReplayModificationTimeRaw,
    })
    for _, i in ipairs(indices) do
        local filename = g_FileList[i]
        items[#items + 1] = entryFactory({
            id = "replay:" .. tostring(i),
            labelText = stripPath(filename),
            buildReader = function(handler, id)
                return LoadReplayMenu.buildReader(mainHandlerRef(), id)
            end,
        })
    end

    -- Empty-list placeholder before the Sort-by Group so the picker never
    -- ships zero items (PickerReader rejects an empty pickerItems).
    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            textKey = "TXT_KEY_NO_REPLAYS",
        })
    end

    items[#items + 1] = SavedGameShared.makeSortByGroup(entryFactory, mainHandlerRef, LoadReplayMenu.buildPickerItems)

    return items
end

return LoadReplayMenu

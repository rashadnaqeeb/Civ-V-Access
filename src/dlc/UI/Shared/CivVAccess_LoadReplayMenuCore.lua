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

local READER_TAB_IDX = 2

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

-- Order g_FileList's indices to match the currently-selected engine sort
-- (g_CurrentSort is one of SortByLastModified / SortByName from
-- LoadReplayMenu.lua). Our picker is a separate list from the engine's
-- visual Stack, so we replicate the sort here. Entry ids remain
-- "replay:<original-index>" so PickerReader cursor restoration works.
local function sortedFileIndices()
    local records = {}
    for i, filename in ipairs(g_FileList) do
        records[#records + 1] = { idx = i, filename = filename }
    end
    if g_CurrentSort == SortByLastModified then
        -- Read mtimes up front; table.sort can fire the comparator N log N
        -- times and per-compare filesystem reads would hurt on large dirs.
        for _, r in ipairs(records) do
            r.high, r.low = UI.GetReplayModificationTimeRaw(r.filename)
        end
        table.sort(records, function(a, b)
            return UI.CompareFileTime(a.high, a.low, b.high, b.low) == 1
        end)
    elseif g_CurrentSort == SortByName then
        for _, r in ipairs(records) do r.name = stripPath(r.filename) end
        table.sort(records, function(a, b)
            return Locale.Compare(a.name, b.name) == -1
        end)
    end
    local indices = {}
    for i, r in ipairs(records) do indices[i] = r.idx end
    return indices
end

-- Apply a sort choice. Mirrors the base per-entry pulldown callback
-- (LoadReplayMenu.lua lines 464-469) plus a picker rebuild. Visual state
-- is kept in sync for sighted observers: the pulldown's button text
-- changes and SortChildren reorders the hidden Stack.
local function applySort(entryFactory, handlerRefThunk, sortFn, labelKey)
    g_CurrentSort = sortFn
    Controls.SortByPullDown:GetButton():LocalizeAndSetText(labelKey)
    Controls.LoadFileButtonStack:SortChildren(sortFn)
    local newItems = LoadReplayMenu.buildPickerItems(entryFactory, handlerRefThunk)
    handlerRefThunk().setItems(newItems, 1)
end

local function parseId(id)
    local kind, idxStr = string.match(id or "", "^(%a+):(%d+)$")
    if kind == nil then return nil end
    return kind, tonumber(idxStr)
end

-- Resolve leader / civ text from a replay header. Mirrors SetSelected
-- lines 191-219.
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

-- Push a sub-menu listing referenced DLC / Mods names. Mirrors the base
-- ShowModsButton / ShowDLCButton popup at LoadReplayMenu.lua lines 68-126
-- but strips "[ICON_BULLET]" since the bullet carries no information in
-- speech (the icon filter would drop it anyway).
local function pushRequirementsSub(mainHandler, kind)
    local list
    local displayKey
    if kind == "mods" then
        list = g_ReplayModsRequired
        displayKey = "TXT_KEY_LOAD_MENU_REQUIRED_MODS"
    else
        list = g_ReplayDLCRequired
        displayKey = "TXT_KEY_LOAD_MENU_REQUIRED_DLC"
    end
    if list == nil or #list == 0 then return end
    local items = {}
    for _, v in ipairs(list) do
        local name
        if kind == "dlc" and v.DescriptionKey ~= nil
                and Locale.HasTextKey(v.DescriptionKey) then
            name = Text.key(v.DescriptionKey)
        else
            name = v.Title or ""
            if Locale.HasTextKey(name) then
                name = Text.key(name)
            end
        end
        if kind == "mods" and v.Version ~= nil then
            name = Text.format("TXT_KEY_CIVVACCESS_LOAD_MOD_VERSION",
                name, v.Version)
        end
        items[#items + 1] = BaseMenuItems.Text({ labelText = name })
    end
    local sub = BaseMenu.create({
        name        = mainHandler.name .. "/Requirements",
        displayName = Text.key(displayKey),
        items       = items,
        escapePops  = true,
    })
    HandlerStack.push(sub)
end

-- Delete confirmation: bypass the visual DeleteConfirm popup (no speech
-- affordance) and push a pure-speech Yes/No sub. On Yes the delete +
-- SetupFileButtonList fires; the monkey-patched SetupFileButtonList
-- rebuilds the picker, and the reader tab gets a placeholder so stale
-- replay details can't be read back. Esc on the sub pops without
-- committing.
local function pushDeleteConfirmSub(mainHandler, filename)
    if filename == nil or filename == "" then return end
    local displayName = stripPath(filename)
    local confirmLabel = Text.format(
        "TXT_KEY_CIVVACCESS_LOAD_DELETE_CONFIRM", displayName)
    local subName = mainHandler.name .. "/DeleteConfirm"
    local sub = BaseMenu.create({
        name        = subName,
        displayName = confirmLabel,
        -- No first so arrow-down to Yes is an explicit affirmative step;
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
                    UI.DeleteReplayFile(filename)
                    SetupFileButtonList()
                    mainHandler.setItems({
                        BaseMenuItems.Text({
                            textKey = "TXT_KEY_CIVVACCESS_REPLAY_DELETED" }),
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
                    textKey = "TXT_KEY_LOAD_REPLAY_MENU_INVALID_REPLAY_FILE" }),
            },
        }
    end

    local leaves = {}

    local leaderDescText, civName = resolveLeaderCiv(header)
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = Text.format(
            "TXT_KEY_RANDOM_LEADER_CIV", leaderDescText, civName),
    })

    local date = UI.GetReplayModificationTime(filename)
    if date ~= nil and date ~= "" then
        leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = date })
    end

    -- Era / turn. Replays always carry a turn count; CurrentEra may be
    -- empty on replays of scenarios that never set one.
    local eraDesc
    if header.CurrentEra ~= nil and header.CurrentEra ~= "" then
        local era = GameInfo.Eras[header.CurrentEra]
        eraDesc = (era ~= nil and era.Description) or "TXT_KEY_MISC_UNKNOWN"
    else
        eraDesc = "TXT_KEY_MISC_UNKNOWN"
    end
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = Text.format(
            "TXT_KEY_CUR_ERA_TURNS_FORMAT", eraDesc, header.TurnNumber),
    })

    if header.StartEra ~= nil and header.StartEra ~= "" then
        local startEra = GameInfo.Eras[header.StartEra]
        local startEraDesc = (startEra ~= nil and startEra.Description)
            or "TXT_KEY_MISC_UNKNOWN"
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_START_ERA_FORMAT", startEraDesc),
        })
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

    -- Select Replay: the primary action. SetSelected just populated the
    -- button's tooltip (missing DLC / incompatible mods reason) and toggled
    -- IsDisabled. BaseMenuItems.Button reads IsDisabled and announces
    -- "disabled" with the tooltip reason appended.
    leaves[#leaves + 1] = BaseMenuItems.Button({
        controlName = "SelectReplayButton",
        textKey     = "TXT_KEY_LOAD_REPLAY_MENU_SELECT_REPLAY",
        tooltipFn   = function(control)
            local ok, tip = pcall(function()
                return control:GetToolTipString()
            end)
            if not ok then
                Log.warn("LoadReplayMenu: SelectReplayButton GetToolTipString failed: "
                    .. tostring(tip))
                return nil
            end
            if tip ~= nil and tip ~= "" then return tip end
            return nil
        end,
        activate = function() OnSelectReplay() end,
    })

    leaves[#leaves + 1] = BaseMenuItems.Choice({
        textKey  = "TXT_KEY_DELETE_BUTTON",
        activate = function()
            pushDeleteConfirmSub(mainHandler, filename)
        end,
    })

    -- Show-DLC / Show-Mods: emitted only when the replay carries unmet
    -- requirements (SetSelected fills these; empty means base content set).
    if g_ReplayDLCRequired ~= nil and #g_ReplayDLCRequired > 0 then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_LOAD_MENU_DLC",
            activate = function()
                pushRequirementsSub(mainHandler, "dlc")
            end,
        })
    end
    if g_ReplayModsRequired ~= nil and #g_ReplayModsRequired > 0 then
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

function LoadReplayMenu.buildPickerItems(entryFactory, mainHandlerRef)
    local items = {}

    for _, i in ipairs(sortedFileIndices()) do
        local filename = g_FileList[i]
        items[#items + 1] = entryFactory({
            id          = "replay:" .. tostring(i),
            labelText   = stripPath(filename),
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
                    applySort(entryFactory, mainHandlerRef,
                        SortByLastModified, "TXT_KEY_SORTBY_LASTMODIFIED")
                end,
            }),
            BaseMenuItems.Choice({
                textKey    = "TXT_KEY_SORTBY_NAME",
                selectedFn = function()
                    return g_CurrentSort == SortByName
                end,
                activate = function()
                    applySort(entryFactory, mainHandlerRef,
                        SortByName, "TXT_KEY_SORTBY_NAME")
                end,
            }),
        },
    })

    return items
end

return LoadReplayMenu

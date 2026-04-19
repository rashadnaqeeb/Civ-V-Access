-- Shared helpers for screens that surface MPGameOptions. Consumed by
-- MPGameSetupAccess (the Host screen) and StagingRoomAccess (the lobby).
-- Both screens include MPGameOptions.lua, so they draw from the same
-- GameInfo.MapScripts/Maps iteration, the same Victory / GameOptions /
-- DLC managers, and the same sort order (raw string compare, no Random
-- seed, no t[0]). Pulldown index i lines up one-to-one with ipairs i.
--
-- Dependencies: BaseMenuItems.Checkbox / Pulldown, Text.key / Text.format,
-- Log.warn. Consumers must include CivVAccess_FrontendCommon first.
--
-- Cache lifetime: the map-size labels cache is session-sticky across a
-- screen show/hide but must be invalidated when the underlying pulldown is
-- repopulated. Consumers call MPGameSetupShared.invalidateMapLabels() in
-- their showPanel / onShow path.

MPGameSetupShared = {}

-- Helpers --------------------------------------------------------------

local function safeText(getter, context)
    local ok, t = pcall(getter)
    if not ok then
        Log.warn("MPGameSetupShared safeText"
            .. (context and (" [" .. context .. "]") or "")
            .. " failed: " .. tostring(t))
        return ""
    end
    if t == nil then return "" end
    return tostring(t)
end

local function worldNameById(worldID)
    local w = GameInfo.Worlds[worldID]
    if w == nil then return nil end
    return Text.key(w.Description)
end

local function worldNameByType(typeKey)
    local w = GameInfo.Worlds[typeKey]
    if w == nil then return nil end
    return Text.key(w.Description)
end

-- Map-type entries: supported-size suffix -------------------------------
--
-- Three shapes built in MPGameOptions.RefreshMapScripts:
--   * MapScripts filtered by SupportsMultiplayer = 1 (size-agnostic).
--   * GameInfo.Maps() rows (size-constrained via Map_Sizes).
--   * Loose WB maps not referenced by Map_Sizes (pinned to wb.MapSize).
-- Sort: raw a.Name < b.Name (not Locale.Compare), no Random entry, no
-- t[0] seed, so pulldown index i == our ipairs i.

local _mpMapSizeLabelsCache

function MPGameSetupShared.invalidateMapLabels()
    _mpMapSizeLabelsCache = nil
end

local function mpMapTypeSizeLabels()
    if _mpMapSizeLabelsCache ~= nil then return _mpMapSizeLabelsCache end

    local mapScripts = {}
    for row in GameInfo.MapScripts{SupportsMultiplayer = 1} do
        mapScripts[#mapScripts + 1] = {
            name     = Locale.ConvertTextKey(row.Name),
            allSizes = true,
        }
    end
    for row in GameInfo.Maps() do
        local sizes = {}
        for srow in GameInfo.Map_Sizes{MapType = row.Type} do
            local s = worldNameByType(srow.WorldSizeType)
            if s ~= nil then sizes[#sizes + 1] = s end
        end
        mapScripts[#mapScripts + 1] = {
            name  = Locale.Lookup(row.Name),
            sizes = sizes,
        }
    end
    local filter = {}
    for row in GameInfo.Map_Sizes() do filter[row.FileName] = true end
    for _, map in ipairs(Modding.GetMapFiles()) do
        if not filter[map.File] then
            local wb = UI.GetMapPreview(map.File)
            local name
            if map.Name and not Locale.IsNilOrWhitespace(map.Name) then
                name = map.Name
            elseif wb ~= nil and not Locale.IsNilOrWhitespace(wb.Name) then
                name = Locale.Lookup(wb.Name)
            else
                name = Path.GetFileNameWithoutExtension(map.File)
            end
            local sizes = {}
            if wb ~= nil and wb.MapSize ~= nil then
                local s = worldNameById(wb.MapSize)
                if s ~= nil then sizes[#sizes + 1] = s end
            end
            mapScripts[#mapScripts + 1] = { name = name, sizes = sizes }
        end
    end

    table.sort(mapScripts, function(a, b) return a.name < b.name end)

    local total
    do
        local n = 0
        for _ in GameInfo.Worlds("ID >= 0") do n = n + 1 end
        total = n
    end

    local labels = {}
    for i, s in ipairs(mapScripts) do
        if s.allSizes or s.sizes == nil or #s.sizes == 0 then
            labels[i] = nil
        elseif #s.sizes == total then
            labels[i] = nil
        elseif #s.sizes == 1 then
            labels[i] = Text.format("TXT_KEY_CIVVACCESS_MAP_SIZE_ONLY",
                s.sizes[1])
        else
            labels[i] = Text.format("TXT_KEY_CIVVACCESS_MAP_SIZE_LIMITED",
                table.concat(s.sizes, ", "))
        end
    end
    _mpMapSizeLabelsCache = labels
    return labels
end

function MPGameSetupShared.mapTypeEntryAnnounce(inst, index)
    local text = safeText(function() return inst.Button:GetText() end,
        "MapType entry GetText")
    local sizeInfo = mpMapTypeSizeLabels()[index]
    local parts = { text }
    if sizeInfo ~= nil and sizeInfo ~= "" then
        parts[#parts + 1] = sizeInfo
    end
    local combined = table.concat(parts, ", ")
    local tip = safeText(function() return inst.Button:GetToolTipString() end,
        "MapType entry GetToolTipString")
    if tip ~= "" then
        return BaseMenuItems.appendTooltip(combined, tip)
    end
    return combined
end

-- Dynamic children ------------------------------------------------------
--
-- Each section iterates GameInfo (with the same filters + sort base uses
-- in MPGameOptions) in parallel with the manager's allocated instances:
-- instance[i] corresponds to the i-th row in our own iteration. Labels
-- come from the row's TXT_KEY rather than from the widget's TextButton,
-- because GetTextButton:GetText() round-trips empty on CheckBox widgets
-- in this engine.

-- Filtered: MP builds its own UI for the turn-timer toggle and the
-- simultaneous / dynamic turn-mode toggles, so they'd duplicate.
local EXCLUDED_GAME_OPTION_TYPES = {
    GAMEOPTION_END_TURN_TIMER_ENABLED = true,
    GAMEOPTION_SIMULTANEOUS_TURNS     = true,
    GAMEOPTION_DYNAMIC_TURNS          = true,
}

-- MP sorts by SortPriority first, then raw string compare on Name (not
-- Locale.Compare, unlike AdvancedSetup). Mirror exactly so our indices
-- match the manager's allocated-instance order.
local function mpSortOptions(options)
    table.sort(options, function(a, b)
        if a.SortPriority == b.SortPriority then
            return a.Name < b.Name
        end
        return a.SortPriority < b.SortPriority
    end)
end

function MPGameSetupShared.victoryChildren()
    local items = {}
    local instances = (g_VictoryCondtionsManager
        and g_VictoryCondtionsManager.m_AllocatedInstances) or {}
    local i = 1
    for row in GameInfo.Victories() do
        local inst = instances[i]
        if inst == nil then break end
        items[#items + 1] = BaseMenuItems.Checkbox({
            control = inst.GameOptionRoot,
            textKey = row.Description,
        })
        i = i + 1
    end
    return items
end

local function gameOptionDropdownRows()
    local rows = {}
    for option in DB.Query(
            [[select * from MapScriptOptions where exists (select 1 from
              MapScriptOptionPossibleValues where FileName = MapScriptOptions.FileName
              and OptionID = MapScriptOptions.OptionID) and Hidden = 0 and
              FileName = ?]], PreGame.GetMapScript()) do
        rows[#rows + 1] = {
            Name         = Locale.ConvertTextKey(option.Name),
            Help         = option.Description and Locale.ConvertTextKey(option.Description) or nil,
            SortPriority = option.SortPriority,
        }
    end
    return rows
end

local function gameOptionCheckboxRows()
    local rows = {}
    local hotseat = PreGame.IsHotSeatGame()
    for option in GameInfo.GameOptions{Visible = 1} do
        if not EXCLUDED_GAME_OPTION_TYPES[option.Type] then
            local supported = hotseat and option.SupportsSinglePlayer
                                       or option.SupportsMultiplayer
            if supported then
                rows[#rows + 1] = {
                    Name         = Locale.ConvertTextKey(option.Description),
                    Help         = option.Help and Locale.ConvertTextKey(option.Help) or nil,
                    SortPriority = 0,
                }
            end
        end
    end
    for option in DB.Query(
            [[select * from MapScriptOptions where not exists (select 1 from
              MapScriptOptionPossibleValues where FileName = MapScriptOptions.FileName
              and OptionID = MapScriptOptions.OptionID) and Hidden = 0 and
              FileName = ?]], PreGame.GetMapScript()) do
        rows[#rows + 1] = {
            Name         = Locale.ConvertTextKey(option.Name),
            Help         = option.Description and Locale.ConvertTextKey(option.Description) or nil,
            SortPriority = option.SortPriority,
        }
    end
    return rows
end

function MPGameSetupShared.gameOptionsChildren()
    local items = {}
    if g_DropDownOptionsManager ~= nil then
        local instances = g_DropDownOptionsManager.m_AllocatedInstances
        local rows      = gameOptionDropdownRows()
        mpSortOptions(rows)
        for i, opt in ipairs(rows) do
            local inst = instances[i]
            if inst == nil then break end
            items[#items + 1] = BaseMenuItems.Pulldown({
                control     = inst.OptionDropDown,
                labelText   = opt.Name,
                tooltipText = opt.Help,
            })
        end
    end
    if g_GameOptionsManager ~= nil then
        local instances = g_GameOptionsManager.m_AllocatedInstances
        local rows      = gameOptionCheckboxRows()
        mpSortOptions(rows)
        for i, opt in ipairs(rows) do
            local inst = instances[i]
            if inst == nil then break end
            items[#items + 1] = BaseMenuItems.Checkbox({
                control     = inst.GameOptionRoot,
                labelText   = opt.Name,
                tooltipText = opt.Help,
            })
        end
    end
    return items
end

function MPGameSetupShared.dlcChildren()
    local items = {}
    local instances = (g_DLCAllowedManager
        and g_DLCAllowedManager.m_AllocatedInstances) or {}
    -- Base skips IsBaseContentUpgrade == 1 rows (force-allowed, not
    -- user-editable); mirror that filter so indices line up.
    local i = 1
    for row in GameInfo.DownloadableContent() do
        if row.IsBaseContentUpgrade == 0 then
            local inst = instances[i]
            if inst == nil then break end
            items[#items + 1] = BaseMenuItems.Checkbox({
                control = inst.GameOptionRoot,
                textKey = row.FriendlyNameKey,
            })
            i = i + 1
        end
    end
    return items
end

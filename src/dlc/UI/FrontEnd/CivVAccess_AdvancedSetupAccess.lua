-- AdvancedSetup (Single Player -> Set Up Game -> Advanced) accessibility
-- wiring. Nested menu layout:
--
--   Level 1  global settings (Map Type / Size / Handicap / Game Speed /
--            Era / Minor Civs / Max Turns), Players group, Victory
--            Conditions group, Game Options group, Defaults, Back, Start.
--   Level 2  inside Players: the human slot + each active AI slot (both
--            as groups), plus Add AI.
--   Level 3  inside a player slot: Civ, Team, and (for AI slots that allow
--            it) a Remove button; for the human slot, also Edit / cancel
--            custom-name.
--
-- The base file's dynamic data (player rows, victory / game-option
-- checkboxes, map-script dropdowns) is built through InstanceManager so
-- the widgets themselves have no stable Controls.X names. For per-player
-- widgets we read each slot's g_SlotInstances[i] entry. For victory and
-- game-option rows we iterate GameInfo (with the same sort base uses) in
-- parallel with each manager's allocated instances so the row's TXT_KEY
-- furnishes the label, avoiding GetTextButton:GetText() round-tripping
-- (which empirically returns an empty string on CheckBox widgets in this
-- engine).
--
-- Dynamic groups pass cached=false so the children rebuild on every drill;
-- PartialSync from pulldown selections can reshape the game-option set
-- without notice and slot presence can flip when Add AI / Remove fires.

include("CivVAccess_FrontendCommon")
include("CivVAccess_CivDetails")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

-- Forward decls so activate closures reference handler before it's set.
local handler
local buildItems

-- Rich labels for the civ pulldown's sub-menu entries: leader + civ +
-- unique ability / unit / building / improvement, in the same leader-
-- alphabetical order the base file uses for playableCivs. Cached only
-- across drills within a single screen show; onShow invalidates because
-- DLC / mod toggles between shows can reshape the playable-civ list.
local _civLabelsCache
local function civPulldownLabels()
    if _civLabelsCache == nil then
        _civLabelsCache = CivDetails.pulldownLabels()
    end
    return _civLabelsCache
end
local function civEntryAnnounce(inst, index)
    local labels = civPulldownLabels()
    return labels[index]
end

-- Map-type entries: supported-size suffix --------------------------------
--
-- Three shapes contribute entries to the Map Type pulldown:
--   * Pure map scripts (Lua generators) -- work at every world size; the
--     size is an input to the generator rather than a constraint.
--   * Maps() rows -- may be constrained to a subset of world sizes by the
--     Map_Sizes rows keyed to the row's MapType.
--   * Loose WB map files not referenced by any Map_Sizes row -- pinned to
--     the single world size embedded in their map preview (wb.MapSize).
--
-- We replicate base's MapTypes.FullSync build order (scripts + Maps rows +
-- loose WB files, sorted by name) to pair each entry with a size summary
-- by sorted index. The summary is "<size> only" for single-size, a comma
-- list for few-size sets, and nil for all-sizes (skipped so the common
-- case stays concise).

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

local _mapSizeLabelsCache
local function mapTypeSizeLabels()
    if _mapSizeLabelsCache ~= nil then return _mapSizeLabelsCache end

    -- Build mapScripts mirroring base AdvancedSetup MapTypes.FullSync.
    local mapScripts = {
        [0] = { name = Locale.ConvertTextKey("TXT_KEY_RANDOM_MAP_SCRIPT"),
                allSizes = true },
    }
    for row in GameInfo.MapScripts{SupportsSinglePlayer = 1, Hidden = 0} do
        mapScripts[#mapScripts + 1] = {
            name     = Locale.ConvertTextKey(row.Name),
            allSizes = true,  -- pure script: size is input, not constraint
        }
    end
    for row in GameInfo.Maps() do
        local sizes = {}
        for srow in GameInfo.Map_Sizes{MapType = row.Type} do
            sizes[#sizes + 1] = worldNameByType(srow.WorldSizeType)
        end
        mapScripts[#mapScripts + 1] = {
            name  = Locale.Lookup(row.Name),
            sizes = sizes,
        }
    end
    -- Loose WB files (not in Map_Sizes): pinned to wb.MapSize.
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

    table.sort(mapScripts,
        function(a, b) return Locale.Compare(a.name, b.name) == -1 end)

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
            -- Constrained set covers every size the game ships; no signal.
            labels[i] = nil
        elseif #s.sizes == 1 then
            labels[i] = Text.format("TXT_KEY_CIVVACCESS_MAP_SIZE_ONLY",
                s.sizes[1])
        else
            labels[i] = Text.format("TXT_KEY_CIVVACCESS_MAP_SIZE_LIMITED",
                table.concat(s.sizes, ", "))
        end
    end
    _mapSizeLabelsCache = labels
    return labels
end

local function mapTypeEntryAnnounce(inst, index)
    local text  = safeText(function() return inst.Button:GetText() end,
        "MapType entry GetText")
    local parts = { text }
    local sizeInfo = mapTypeSizeLabels()[index]
    if sizeInfo ~= nil and sizeInfo ~= "" then
        parts[#parts + 1] = sizeInfo
    end
    local combined = table.concat(parts, ", ")
    local tip      = safeText(function() return inst.Button:GetToolTipString() end,
        "MapType entry GetToolTipString")
    if tip ~= "" then
        return BaseMenuItems.appendTooltip(combined, tip)
    end
    return combined
end

-- Helpers -----------------------------------------------------------------

-- Read a widget string (label / tooltip / button text) and surface any
-- pcall failure through Log.warn so a silently empty label points at the
-- actual error rather than looking like "the widget has no text".
-- pcall returning (true, nil) is not a failure -- a widget can legitimately
-- have no text yet -- so only the error path logs.
local function safeText(getter, context)
    local ok, t = pcall(getter)
    if not ok then
        Log.warn("AdvancedSetupAccess safeText"
            .. (context and (" [" .. context .. "]") or "")
            .. " failed: " .. tostring(t))
        return ""
    end
    if t == nil then return "" end
    return tostring(t)
end

local function pulldownButtonText(control)
    if control == nil then return "" end
    return safeText(function() return control:GetButton():GetText() end)
end

-- Base-game's MaxTurnsCheck click callback is anonymous (AdvancedSetup.lua
-- line 1055) so the checkbox probe can't capture it; replicate the same
-- side effects explicitly here.
local function onMaxTurnsChecked()
    if Controls.MaxTurnsCheck:IsChecked() then
        Controls.MaxTurnsEditbox:SetHide(false)
    else
        Controls.MaxTurnsEditbox:SetHide(true)
        PreGame.SetMaxTurns(0)
    end
    PerformPartialSync()
end

-- MaxTurns edit callback: base is an inline per-character anonymous fn
-- (CallOnChar=1). Replicate the setter.
local function maxTurnsEditCallback()
    PreGame.SetMaxTurns(Controls.MaxTurnsEdit:GetText())
end

-- Human slot ---------------------------------------------------------------

local function humanCivText()
    -- When the user has set a custom leader name, CivPulldown hides and
    -- CivName takes its place. Prefer CivName when visible.
    local nameCtrl = Controls.CivName
    if nameCtrl ~= nil and not nameCtrl:IsHidden() then
        local t = safeText(function() return nameCtrl:GetText() end)
        if t ~= "" then return t end
    end
    return pulldownButtonText(Controls.CivPulldown)
end

local function humanTeamText()
    return safeText(function() return Controls.TeamLabel:GetText() end)
end

local function humanSlotLabel()
    return Text.format("TXT_KEY_CIVVACCESS_HUMAN_SLOT",
        humanCivText(), humanTeamText())
end

local function humanSlotChildren()
    return {
        -- Civ pulldown. labelFn returns the current civ button text so the
        -- announcement is "Napoleon of France" rather than a generic
        -- "Random Leader" label plus a different current value. No static
        -- tooltipKey: "The game will randomly pick..." is stale once the
        -- user picks a specific civ. entryAnnounceFn replaces each sub-
        -- menu entry's default announce with the same rich text the
        -- SelectCivilization picker produces (leader / civ / uniques).
        BaseMenuItems.Pulldown({ controlName = "CivPulldown",
            labelFn         = function() return pulldownButtonText(Controls.CivPulldown) end,
            entryAnnounceFn = civEntryAnnounce }),
        -- When CivName is visible (custom name set), announce the custom
        -- text; Enter reopens the name editor.
        BaseMenuItems.Choice({
            visibilityControlName = "CivName",
            labelFn  = function() return safeText(function() return Controls.CivName:GetText() end) end,
            activate = function() UIManager:PushModal(Controls.SetCivNames) end }),
        BaseMenuItems.Pulldown({ controlName = "TeamPullDown",
            labelFn = function() return humanTeamText() end }),
        BaseMenuItems.Button({ controlName = "EditButton",
            textKey    = "TXT_KEY_EDIT_BUTTON",
            tooltipKey = "TXT_KEY_NAME_CIV_TITLE",
            activate   = function() UIManager:PushModal(Controls.SetCivNames) end }),
        BaseMenuItems.Button({ controlName = "RemoveButton",
            textKey  = "TXT_KEY_CANCEL_BUTTON",
            activate = function() OnCancelEditPlayerDetails() end }),
    }
end

-- AI slots -----------------------------------------------------------------

local function slotLabel(slotIndex)
    return function()
        local slot = g_SlotInstances and g_SlotInstances[slotIndex]
        if slot == nil then return "" end
        return Text.format("TXT_KEY_CIVVACCESS_AI_SLOT",
            slotIndex + 1,
            pulldownButtonText(slot.CivPulldown),
            safeText(function() return slot.TeamLabel:GetText() end))
    end
end

local function slotChildren(slotIndex)
    return function()
        local slot = g_SlotInstances and g_SlotInstances[slotIndex]
        if slot == nil then return {} end
        local items = {
            BaseMenuItems.Pulldown({ control = slot.CivPulldown,
                labelFn         = function() return pulldownButtonText(slot.CivPulldown) end,
                entryAnnounceFn = civEntryAnnounce }),
            BaseMenuItems.Pulldown({ control = slot.TeamPullDown,
                labelFn = function() return safeText(function() return slot.TeamLabel:GetText() end) end }),
        }
        -- Base forbids removing slot 1 (games require >= 2 players).
        if slotIndex ~= 1 then
            items[#items + 1] = BaseMenuItems.Button({
                control  = slot.RemoveButton,
                textKey  = "TXT_KEY_MODDING_DELETEMOD",
                activate = function()
                    if PreGame.GetSlotStatus(slotIndex) == SlotStatus.SS_COMPUTER then
                        PreGame.SetSlotStatus(slotIndex, SlotStatus.SS_CLOSED)
                    end
                    PerformPartialSync()
                    if handler ~= nil then handler._goBackLevel() end
                end,
            })
        end
        return items
    end
end

-- Players group -----------------------------------------------------------

local function playersChildren()
    local items = {}
    -- Human first.
    items[#items + 1] = BaseMenuItems.Group({
        labelFn = humanSlotLabel,
        items   = humanSlotChildren(),
    })
    -- Active AI slots; each gated on its Root visibility so random-world-
    -- size (all slots hidden via UnknownPlayers) and non-SS_COMPUTER slots
    -- drop from navigation naturally.
    if g_SlotInstances ~= nil then
        for i = 1, GameDefines.MAX_MAJOR_CIVS - 1 do
            local slot = g_SlotInstances[i]
            if slot ~= nil and slot.Root ~= nil then
                items[#items + 1] = BaseMenuItems.Group({
                    labelFn           = slotLabel(i),
                    itemsFn           = slotChildren(i),
                    cached            = false,
                    visibilityControl = slot.Root,
                })
            end
        end
    end
    -- Add AI lives inside Players rather than the top-level action row;
    -- the action conceptually modifies the player list it sits next to.
    items[#items + 1] = BaseMenuItems.Button({ controlName = "AddAIButton",
        textKey    = "TXT_KEY_AD_SETUP_ADD_AI_PLAYER",
        tooltipKey = "TXT_KEY_AD_SETUP_ADD_AI_PLAYER_TT",
        activate   = function() OnAdAIClicked() end })
    return items
end

-- Victory / game-options children -----------------------------------------
--
-- Parallel iteration over GameInfo with the same sort base uses. The
-- manager's m_AllocatedInstances is populated in that order, so index i in
-- GameInfo matches instances[i]. Using row.Description as a TXT_KEY gives
-- a reliable label source even when GetTextButton:GetText() round-trips
-- empty.

local function victoryChildren()
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

local function sortedOptions(rows, defaultSortPriority)
    local options = {}
    for _, row in ipairs(rows) do
        options[#options + 1] = {
            Name         = row.Name,
            Help         = row.Help,
            SortPriority = row.SortPriority or defaultSortPriority or 0,
        }
    end
    table.sort(options, function(a, b)
        if a.SortPriority == b.SortPriority then
            return Locale.Compare(a.Name, b.Name) == -1
        end
        return a.SortPriority < b.SortPriority
    end)
    return options
end

local function mapScriptDropdownRows()
    local rows = {}
    local currentMapScript = PreGame.GetMapScript()
    if PreGame.IsRandomMapScript() then currentMapScript = nil end
    for option in DB.Query(
            [[select * from MapScriptOptions where exists (select 1 from
              MapScriptOptionPossibleValues where FileName = MapScriptOptions.FileName
              and OptionID = MapScriptOptions.OptionID) and Hidden = 0 and
              FileName = ?]], currentMapScript) do
        rows[#rows + 1] = {
            Name         = Locale.ConvertTextKey(option.Name),
            Help         = option.Description and Locale.ConvertTextKey(option.Description) or nil,
            SortPriority = option.SortPriority,
        }
    end
    return rows
end

local function mapScriptCheckboxRows()
    local rows = {}
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

local function gameOptionCheckboxRows()
    local rows = {}
    for option in GameInfo.GameOptions{Visible = 1} do
        if option.SupportsSinglePlayer then
            rows[#rows + 1] = {
                Name         = Locale.ConvertTextKey(option.Description),
                Help         = option.Help and Locale.ConvertTextKey(option.Help) or nil,
                SortPriority = 0,
            }
        end
    end
    return rows
end

local function gameOptionsChildren()
    local items = {}
    -- Dropdown map-script options first (same order base inserts them).
    if g_DropDownOptionsManager ~= nil then
        local instances = g_DropDownOptionsManager.m_AllocatedInstances
        local options = sortedOptions(mapScriptDropdownRows())
        for i, opt in ipairs(options) do
            local inst = instances[i]
            if inst == nil then break end
            items[#items + 1] = BaseMenuItems.Pulldown({
                control     = inst.OptionDropDown,
                labelText   = opt.Name,
                tooltipText = opt.Help,
            })
        end
    end
    -- Checkbox game options: GameOptions{Visible=1,SupportsSinglePlayer}
    -- merged with MapScriptOptions lacking possible values, sorted by
    -- (SortPriority, Locale.Compare(Name)).
    if g_GameOptionsManager ~= nil then
        local instances = g_GameOptionsManager.m_AllocatedInstances
        local rows = gameOptionCheckboxRows()
        for _, r in ipairs(mapScriptCheckboxRows()) do
            rows[#rows + 1] = r
        end
        local options = sortedOptions(rows)
        for i, opt in ipairs(options) do
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

-- Top-level ---------------------------------------------------------------

buildItems = function()
    return {
        -- Global settings.
        BaseMenuItems.Pulldown({ controlName = "MapTypePullDown",
            textKey         = "TXT_KEY_AD_SETUP_MAP_TYPE",
            entryAnnounceFn = mapTypeEntryAnnounce }),
        BaseMenuItems.Pulldown({ controlName = "MapSizePullDown",
            textKey = "TXT_KEY_AD_SETUP_MAP_SIZE" }),
        BaseMenuItems.Pulldown({ controlName = "HandicapPullDown",
            textKey = "TXT_KEY_AD_SETUP_HANDICAP" }),
        BaseMenuItems.Pulldown({ controlName = "GameSpeedPullDown",
            textKey = "TXT_KEY_AD_SETUP_GAME_SPEED" }),
        BaseMenuItems.Pulldown({ controlName = "EraPullDown",
            textKey = "TXT_KEY_AD_SETUP_GAME_ERA" }),
        BaseMenuItems.Slider({ controlName = "MinorCivsSlider",
            labelControlName = "MinorCivsLabel",
            textKey = "TXT_KEY_AD_SETUP_CITY_STATES" }),
        BaseMenuItems.Checkbox({ controlName = "MaxTurnsCheck",
            textKey          = "TXT_KEY_AD_SETUP_MAX_TURNS",
            tooltipKey       = "TXT_KEY_AD_SETUP_MAX_TURNS_TT",
            activateCallback = onMaxTurnsChecked }),
        BaseMenuItems.Textfield({ controlName = "MaxTurnsEdit",
            visibilityControlName = "MaxTurnsEditbox",
            textKey       = "TXT_KEY_CIVVACCESS_FIELD_MAX_TURNS",
            priorCallback = maxTurnsEditCallback }),
        -- Players group: human + active AI slots + Add AI.
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CIVVACCESS_GROUP_PLAYERS",
            itemsFn = playersChildren,
            cached  = false,
        }),
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CIVVACCESS_GROUP_VICTORY_CONDITIONS",
            itemsFn = victoryChildren,
            cached  = false,
        }),
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CIVVACCESS_GROUP_GAME_OPTIONS",
            itemsFn = gameOptionsChildren,
            cached  = false,
        }),
        BaseMenuItems.Button({ controlName = "DefaultButton",
            textKey    = "TXT_KEY_AD_SETUP_DEFAULT",
            tooltipKey = "TXT_KEY_AD_SETUP_ADD_DEFAULT_TT",
            activate   = function() OnDefaultsClicked() end }),
        BaseMenuItems.Button({ controlName = "BackButton",
            textKey    = "TXT_KEY_BACK_BUTTON",
            tooltipKey = "TXT_KEY_REFRESH_GAME_LIST_TT",
            activate   = function() OnBackClicked() end }),
        BaseMenuItems.Button({ controlName = "StartButton",
            textKey  = "TXT_KEY_START_GAME",
            activate = function() OnStartClicked() end }),
    }
end

handler = BaseMenu.install(ContextPtr, {
    name          = "AdvancedSetup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_ADVANCED_SETUP"),
    preamble      = function()
        if PreGame.IsRandomWorldSize() then
            return Text.key("TXT_KEY_CIVVACCESS_UNKNOWN_PLAYERS_STATUS")
        end
        return nil
    end,
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    -- onShow invalidates the two label caches so DLC / mod toggles that
    -- happened since the prior show don't leave stale civ-detail or
    -- map-size-constraint announcements. Dynamic groups are already
    -- cached=false so they pick up widget-state changes on every drill.
    onShow        = function()
        _civLabelsCache     = nil
        _mapSizeLabelsCache = nil
    end,
    items         = buildItems(),
})

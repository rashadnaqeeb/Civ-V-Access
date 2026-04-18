-- Two-tab picker + reader pattern on top of BaseMenu. A picker tab hosts a
-- nested list of selectable Entries; Enter on an Entry rebuilds the reader
-- tab's items from the Entry's buildReader callback and switches tabs.
-- Shift+Tab (or Esc at reader level 1) returns to the picker, landing the
-- cursor on the just-opened Entry.
--
-- Modeled on ONI Access's CodexScreenHandler split (CategoriesTab + ContentTab),
-- but collapsed into one BaseMenu since our nested navigation natively handles
-- drill levels. Reusable across any "pick from a list, read details in another
-- panel" flow -- Civilopedia is the first consumer; the save-file LoadMenu is
-- a candidate second.
--
-- Usage:
--   local pr = PickerReader.create()
--   local pickerItems = buildMyPickerItems(pr.Entry)  -- pr.Entry is a factory
--   pr.install(ContextPtr, {
--       name = "MyScreen",
--       displayName = "...",
--       pickerTabName = "TXT_KEY_...",
--       readerTabName = "TXT_KEY_...",
--       emptyReaderText = "...",
--       pickerItems = pickerItems,
--       priorShowHide = ..., priorInput = ..., focusParkControl = "...",
--   })
--
-- Entry spec (PickerReader.Entry factory returned from create()):
--   id                opaque string identifier; used to restore the picker
--                     cursor on return from the reader tab, and passed to
--                     buildReader so it can source fresh data every call.
--   textKey / labelText / labelFn   label source (one required)
--   tooltipKey / tooltipText / tooltipFn   optional tooltip
--   visibilityControl / visibilityControlName   optional gate
--   buildReader       fn(handler, id) -> { items = {...}, autoDrillToLevel = N }
--                     Called on every activation; must not cache. Returning nil
--                     or an empty items list shows the emptyReaderText.

PickerReader = {}

local function check(cond, msg)
    if not cond then
        Log.error(msg)
        error(msg, 2)
    end
end

-- Walk picker items (which may include nested Groups) and invoke visit
-- at every Entry leaf, passing the 1-based path of indices from the top
-- level down to the leaf. Returns immediately if visit returns true.
local function forEachEntry(items, path, visit)
    for i, item in ipairs(items) do
        path[#path + 1] = i
        if item.kind == "entry" then
            if visit(item, path) then
                path[#path] = nil
                return true
            end
        elseif item.kind == "group" then
            local children = item:children()
            if forEachEntry(children, path, visit) then
                path[#path] = nil
                return true
            end
        end
        path[#path] = nil
    end
    return false
end

-- Restore picker cursor to the Entry whose id matches state.selectedId.
-- Called from the picker tab's onActivate when returning from the reader.
-- Silent on miss (Entry may have become hidden; the tab's default first-
-- valid cursor stays). Walks via forEachEntry so nested categories work.
local function restorePickerCursor(handler, state, pickerTabIdx)
    if state.selectedId == nil then return end
    local tab = handler.tabs[pickerTabIdx]
    if tab == nil or tab._items == nil then return end
    local found = false
    local foundPath
    forEachEntry(tab._items, {}, function(entry, path)
        if entry.id == state.selectedId then
            foundPath = { }
            for k, v in ipairs(path) do foundPath[k] = v end
            found = true
            return true
        end
        return false
    end)
    if not found then return end
    handler._level = #foundPath
    handler._indices = {}
    for l, idx in ipairs(foundPath) do
        handler._indices[l] = idx
    end
end

-- Shared navigability / activability for Entry leaves. Mirrors BaseMenuItems'
-- Choice behavior: no _control, so navigability is gated only by an optional
-- visibility control. Activatable implies navigable.
local function entryIsNavigable(self)
    if self._visibilityControl ~= nil and self._visibilityControl:IsHidden() then
        return false
    end
    return true
end

local function entryIsActivatable(self) return self:isNavigable() end

-- Create a PickerReader session. Returns a table with two fields:
--   Entry(spec) - factory for leaf items that drive cross-tab moves
--   install(ContextPtr, config) - wraps BaseMenu.install with a two-tab spec
-- Call Entry() to build picker items; then hand the items to install via
-- config.pickerItems. The session closes over its own state (selectedId,
-- tab indices) so Entry closures written before install know which session
-- they belong to.
function PickerReader.create()
    local state = {
        selectedId = nil,
        pickerTabIdx = 1,
        readerTabIdx = 2,
        -- Wired by install() so Entry:activate can call handler methods.
        handler = nil,
    }
    local session = {}

    -- Shared entry-activation path. Enter on a picker Entry and Ctrl+Up/Down
    -- on the reader tab both go through here. They differ only in whether an
    -- activation sound plays: Enter is a deliberate pick, Ctrl+arrows are
    -- navigation within an open article. On success, switchToTab(force=true)
    -- re-enters the reader tab, firing the reader tab's nameFn (article
    -- title) + first-item announcement.
    local function activateEntry(entry, menu, playSound)
        if playSound then
            Events.AudioPlay2DSound("AS2D_IF_SELECT")
        end
        state.selectedId = entry.id
        local ok, result = pcall(entry._buildReader, menu, entry.id)
        if not ok then
            Log.error("PickerReader '" .. tostring(menu.name)
                .. "' buildReader for id '" .. tostring(entry.id)
                .. "' failed: " .. tostring(result))
            return false
        end
        local readerItems = result and result.items
        local drillLevel  = result and result.autoDrillToLevel
        if type(readerItems) ~= "table" or #readerItems == 0 then
            SpeechPipeline.speakInterrupt(
                Text.key("TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"))
            return false
        end
        menu.setItems(readerItems, state.readerTabIdx)
        menu.tabs[state.readerTabIdx].autoDrillToLevel = drillLevel or 1
        menu.switchToTab(state.readerTabIdx)
        return true
    end

    -- Walk the picker tree into a flat list of Entry refs in display order.
    -- Used by reader-tab Ctrl+Up/Down to find the adjacent article. Built on
    -- demand (not cached) because category Groups carry cached=false and may
    -- rebuild child entries between invocations — the ids stay stable but
    -- the table refs don't, so a cached flat list would go stale.
    local function flattenEntries(pickerItems)
        local flat = {}
        forEachEntry(pickerItems, {}, function(entry)
            flat[#flat + 1] = entry
            return false
        end)
        return flat
    end

    -- Resolve the label for a given selectedId by walking the picker. Used
    -- by the reader tab's nameFn to announce the article title in place of
    -- the static "Content" tab name. Returns empty string on miss so switchTab
    -- speaks nothing for the tab name.
    local function labelForId(id)
        if id == nil then return "" end
        local handler = state.handler
        if handler == nil or handler.tabs == nil then return "" end
        local pickerTab = handler.tabs[state.pickerTabIdx]
        if pickerTab == nil or pickerTab._items == nil then return "" end
        local found = ""
        forEachEntry(pickerTab._items, {}, function(entry)
            if entry.id == id then
                found = BaseMenuItems.labelOf(entry) or ""
                return true
            end
            return false
        end)
        return found
    end

    -- Navigate to the Entry adjacent to the currently-selected article in
    -- the picker's flat display order. Step is -1 (prev) or +1 (next). At
    -- boundaries silently no-ops (no wrap, per spec). If no article is
    -- currently selected this is also a no-op.
    local function navigateAdjacent(menu, step)
        local handler = state.handler
        if handler == nil or handler.tabs == nil then return end
        local pickerTab = handler.tabs[state.pickerTabIdx]
        if pickerTab == nil or pickerTab._items == nil then return end
        local flat = flattenEntries(pickerTab._items)
        local currentIdx
        for i, entry in ipairs(flat) do
            if entry.id == state.selectedId then currentIdx = i; break end
        end
        if currentIdx == nil then return end
        local targetIdx = currentIdx + step
        if targetIdx < 1 or targetIdx > #flat then return end
        activateEntry(flat[targetIdx], menu, false)
    end

    function session.Entry(spec)
        check(type(spec) == "table", "PickerReader.Entry requires a spec table")
        check(type(spec.id) == "string" and spec.id ~= "",
            "PickerReader.Entry.id required (non-empty string)")
        check(type(spec.textKey) == "string"
            or type(spec.labelText) == "string"
            or type(spec.labelFn) == "function",
            "PickerReader.Entry needs textKey, labelText, or labelFn")
        check(spec.tooltipFn == nil or type(spec.tooltipFn) == "function",
            "PickerReader.Entry.tooltipFn must be a function if provided")
        check(type(spec.buildReader) == "function",
            "PickerReader.Entry.buildReader required (fn(handler, id))")
        local item = {
            kind         = "entry",
            id           = spec.id,
            textKey      = spec.textKey,
            labelText    = spec.labelText,
            labelFn      = spec.labelFn,
            tooltipKey   = spec.tooltipKey,
            tooltipText  = spec.tooltipText,
            tooltipFn    = spec.tooltipFn,
            _buildReader = spec.buildReader,
        }
        if spec.visibilityControl ~= nil then
            item._visibilityControl = spec.visibilityControl
        elseif spec.visibilityControlName ~= nil then
            item.visibilityControlName = spec.visibilityControlName
            item._visibilityControl    = Controls[spec.visibilityControlName]
            if item._visibilityControl == nil then
                Log.warn("PickerReader.Entry: missing visibility control '"
                    .. spec.visibilityControlName .. "'")
            end
        end
        item.isNavigable   = entryIsNavigable
        item.isActivatable = entryIsActivatable
        function item:announce(menu)
            return BaseMenuItems.appendTooltip(
                BaseMenuItems.labelOf(self),
                BaseMenuItems.tooltipOf(self))
        end
        function item:activate(menu)
            activateEntry(self, menu, true)
        end
        function item:adjust(menu, dir, big) end
        return item
    end

    function session.install(ContextPtr, config)
        check(type(config) == "table",
            "PickerReader.install requires a config table")
        check(type(config.name) == "string" and config.name ~= "",
            "config.name required")
        check(type(config.displayName) == "string" and config.displayName ~= "",
            "config.displayName required")
        check(type(config.pickerTabName) == "string",
            "config.pickerTabName (TXT_KEY) required")
        check(type(config.readerTabName) == "string",
            "config.readerTabName (TXT_KEY) required")
        check(type(config.pickerItems) == "table" and #config.pickerItems > 0,
            "config.pickerItems required (non-empty array)")

        local emptyReaderText = config.emptyReaderText
            or Text.key("TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION")

        -- Reader tab opens with a single informational Text item so first
        -- Tab-over before any selection reads something sensible rather
        -- than speaking into an empty list.
        local readerPlaceholder = {
            BaseMenuItems.Text({ labelText = emptyReaderText }),
        }

        local bmSpec = {
            name             = config.name,
            displayName      = config.displayName,
            preamble         = config.preamble,
            priorShowHide    = config.priorShowHide,
            priorInput       = config.priorInput,
            focusParkControl = config.focusParkControl,
            deferActivate    = config.deferActivate,
            shouldActivate   = config.shouldActivate,
            onShow           = config.onShow,
            tabs = {
                {
                    name  = config.pickerTabName,
                    items = config.pickerItems,
                    onActivate = function(handler)
                        restorePickerCursor(handler, state, state.pickerTabIdx)
                    end,
                },
                {
                    name  = config.readerTabName,
                    items = readerPlaceholder,
                    -- Replace the static "Content" tab-name announcement
                    -- with the currently-selected article's label. Empty
                    -- on initial state so switchTab speaks only the
                    -- placeholder item and not a redundant tab name.
                    nameFn = function() return labelForId(state.selectedId) end,
                    -- Ctrl+Up / Ctrl+Down on the reader: move to the
                    -- prev/next Entry in the picker's flat display order
                    -- (no wrap). The shared activateEntry path re-enters
                    -- the reader tab and announces the new article title
                    -- (via nameFn) + first content element.
                    onCtrlUp   = function(h) navigateAdjacent(h, -1) end,
                    onCtrlDown = function(h) navigateAdjacent(h,  1) end,
                },
            },
            escAtLevelOne = function(handler)
                -- Esc on reader tab -> back to picker (landing on the
                -- selected entry). Esc on picker tab -> fall through, the
                -- screen closes.
                if handler._tabIndex == state.readerTabIdx then
                    handler.switchToTab(state.pickerTabIdx)
                    return true
                end
                return false
            end,
        }

        local handler = BaseMenu.install(ContextPtr, bmSpec)
        state.handler = handler

        -- Exposed so in-reader navigations (Civilopedia's follow-link path)
        -- can update the stored selection without touching internal state.
        -- Shift+Tab back to the picker then lands on the just-navigated-to
        -- Entry rather than the one the user originally opened from.
        function handler.setPickerReaderSelection(id)
            if type(id) ~= "string" or id == "" then return end
            state.selectedId = id
        end

        return handler
    end

    return session
end

return PickerReader

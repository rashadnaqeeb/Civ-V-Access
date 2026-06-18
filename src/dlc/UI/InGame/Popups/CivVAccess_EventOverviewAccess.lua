-- Events Overview accessibility (Vox Populi only; Ctrl+Shift+E or the
-- Additional Information dropdown). Wraps the Community Patch
-- EventOverview popup (BUTTONPOPUP_MODDER_6) as a four-tab TabbedShell
-- mirroring the vendor's tabs:
--
--   Player Choices -- active effects from player events the user picked
--                     a choice on. Row: event title, the "Your Choice:"
--                     line, duration ("N Turns Remaining" / "Permanent
--                     Effect"); the scaled "Result:" effect text rides
--                     the tooltip.
--   City Choices   -- the same for city events; the city name leads the
--                     row and Enter drops the hex cursor on the city.
--   Player Events  -- active effects from instant (single-choice) player
--                     events. The choice description doubles as the
--                     title; the duration slot reads turns remaining for
--                     timed effects or "Instant Event" for one-shots.
--   City Events    -- instant city events, including espionage actions
--                     resolved against the player's cities (the vendor's
--                     spy tag with its "Enemy Benefit:" phrasing). The
--                     vendor never shows remaining turns on this tab
--                     (its duration line is unconditionally overwritten
--                     by the espionage / instant tag) and we mirror
--                     that, a design decision of record. Enter drops the
--                     hex cursor on the city.
--
-- Rows rebuild from the DLL bindings (GetActivePlayerEventChoices /
-- GetActiveCityEventChoices / GetRecentPlayerEventChoices /
-- GetRecentCityEventChoices) rather than scraping the vendor's instanced
-- widgets; spoken text reuses the vendor card's TXT keys in the vendor
-- card's order. "Active" is the operative word across all four tabs:
-- expired effects vanish from the bindings, so nothing here is
-- historical despite the vendor's "Recent" internal naming.
--
-- Each tab carries the vendor panel's "Sort by" pulldown as a trailing
-- Pulldown item (after the rows, like the popups' trailing Close
-- buttons, so tab landings announce content first). The entries are the
-- vendor's own, captured via PullDownProbe from the panel Context (see
-- CivVAccess_EventPanelProbe); selecting one fires the vendor's
-- per-entry callback so the visual panel re-sorts, and the shell's
-- re-activation rebuild re-derives our row order from the pulldown's
-- button text, so the two cannot drift.
--
-- Tab switches drive the vendor's own panel buttons so the visual screen
-- follows for a sighted spectator and the panel's Initialize() has built
-- the sort entries before our Pulldown item can open. Esc falls through
-- to the vendor InputHandler (close); the vendor's Enter-closes binding
-- stays beneath our consumed Enter.

include("CivVAccess_PopupBoot")
include("CivVAccess_TabbedShell")
include("CivVAccess_PullDownProbe")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

-- ===== Row models (vendor RefreshData mirrors) ==========================

-- Resolve the city a city-event record points at, the way the vendor
-- does (plot coordinates ride the binding record; the city is re-queried
-- live). A vanished city crashes the build like it crashes the vendor;
-- the pcall in buildTabItems' caller logs it.
local function cityAt(x, y)
    return Map.GetPlot(x, y):GetPlotCity()
end

local function buildPlayerChoiceRows()
    local p = activePlayer()
    local rows = {}
    for _, v in ipairs(p:GetActivePlayerEventChoices()) do
        local info = GameInfo.EventChoices[v.EventChoice]
        rows[#rows + 1] = {
            title = Text.key(GameInfo.Events[v.ParentEvent].Description),
            choice = Text.key(info.Description),
            duration = v.Duration,
            -- Composite localization payload, not a bare key; Text.key
            -- still converts it and only warns when conversion fails.
            effects = Text.key(p:GetScaledEventChoiceValue(info.ID)),
        }
    end
    return rows
end

local function buildCityChoiceRows()
    local p = activePlayer()
    local rows = {}
    for _, v in ipairs(p:GetActiveCityEventChoices()) do
        local info = GameInfo.CityEventChoices[v.EventChoice]
        local city = cityAt(v.CityX, v.CityY)
        rows[#rows + 1] = {
            title = Text.key(GameInfo.CityEvents[v.ParentEvent].Description),
            choice = Text.key(info.Description),
            duration = v.Duration,
            effects = Text.key(city:GetScaledEventChoiceValue(info.ID)),
            city = city:GetName(),
            cityX = v.CityX,
            cityY = v.CityY,
        }
    end
    return rows
end

-- Instant rows: the binding reports ParentEvent = -1 for every entry
-- (single-choice events), so the choice description doubles as the
-- title, matching the vendor's else-branch rendering.
local function buildPlayerInstantRows()
    local p = activePlayer()
    local rows = {}
    for _, v in ipairs(p:GetRecentPlayerEventChoices()) do
        local info = GameInfo.EventChoices[v.EventChoice]
        rows[#rows + 1] = {
            title = Text.key(info.Description),
            duration = v.Duration,
            effects = Text.key(p:GetScaledEventChoiceValue(info.ID)),
        }
    end
    return rows
end

local function buildCityInstantRows()
    local p = activePlayer()
    local rows = {}
    for _, v in ipairs(p:GetRecentCityEventChoices()) do
        local info = GameInfo.CityEventChoices[v.EventChoice]
        local city = cityAt(v.CityX, v.CityY)
        rows[#rows + 1] = {
            title = Text.key(info.Description),
            duration = v.Duration,
            espionage = v.Espionage == true,
            effects = Text.key(city:GetScaledEventChoiceValue(info.ID)),
            city = city:GetName(),
            cityX = v.CityX,
            cityY = v.CityY,
        }
    end
    return rows
end

-- ===== Row speech (vendor card order, vendor keys) ======================

local function choiceDurationText(duration)
    if duration > 0 then
        return Text.format("TXT_KEY_TP_TURNS_REMAINING", duration)
    end
    return Text.key("TXT_KEY_TP_PERMANENT")
end

local function instantDurationText(duration)
    if duration > 0 then
        return Text.format("TXT_KEY_TP_TURNS_REMAINING", duration)
    end
    return Text.key("TXT_KEY_TP_BONUS")
end

-- City Events duration slot: the espionage or instant tag only, never a
-- turn count -- the sighted card overwrites its turns-remaining line
-- with this tag unconditionally and we mirror it (decision of record).
local function cityInstantTagText(row)
    if row.espionage then
        return Text.key("TXT_KEY_TP_ESPIONAGE_EVENT")
    end
    return Text.key("TXT_KEY_TP_BONUS")
end

local function resultTooltip(row)
    return Text.key("TXT_KEY_EVENT_CHOICE_RESULT_UI") .. " " .. row.effects
end

-- Enter on a city row: vendor camera pan (spectator parity) plus the hex
-- cursor drop with the landing spoken, the Find On Map precedent from
-- the city-event popup. The screen stays open; Esc closes it.
local function jumpToCity(x, y)
    UI.LookAt(Map.GetPlot(x, y), 0)
    local Cursor = civvaccess_shared.modules and civvaccess_shared.modules.Cursor
    if Cursor == nil then
        Log.warn("EventOverview go-to-city: Cursor module not published")
        return
    end
    local text = Cursor.jumpTo(x, y)
    if text ~= nil and text ~= "" then
        SpeechPipeline.speakQueued(text)
    end
end

-- "Your Choice: <choice>" as one fragment so the choice never splits from
-- its prefix.
local function choiceFragment(row)
    return Text.key("TXT_KEY_EVENT_CHOICE_UI") .. " " .. row.choice
end

-- Each row's label joins its fragments with ", " into one [NEWLINE]-free
-- blob, so the section reviewer would receive the whole row as a single
-- section. sectionsFn hands it the same discrete fragments (the title /
-- choice / duration pieces); the scaled "Result:" effect rides the tooltip
-- and the reviewer auto-splits it onto its own sections.
local function playerChoiceItem(row)
    local parts = { row.title, choiceFragment(row), choiceDurationText(row.duration) }
    return BaseMenuItems.Text({
        labelText = table.concat(parts, ", "),
        sectionsFn = function()
            return parts
        end,
        tooltipText = resultTooltip(row),
    })
end

local function cityChoiceItem(row)
    local parts = { row.city, row.title, choiceFragment(row), choiceDurationText(row.duration) }
    return BaseMenuItems.Text({
        labelText = table.concat(parts, ", "),
        sectionsFn = function()
            return parts
        end,
        tooltipText = resultTooltip(row),
        onActivate = function()
            jumpToCity(row.cityX, row.cityY)
        end,
    })
end

local function playerInstantItem(row)
    local parts = { row.title, instantDurationText(row.duration) }
    return BaseMenuItems.Text({
        labelText = table.concat(parts, ", "),
        sectionsFn = function()
            return parts
        end,
        tooltipText = resultTooltip(row),
    })
end

local function cityInstantItem(row)
    local parts = { row.city, row.title, cityInstantTagText(row) }
    return BaseMenuItems.Text({
        labelText = table.concat(parts, ", "),
        sectionsFn = function()
            return parts
        end,
        tooltipText = resultTooltip(row),
        onActivate = function()
            jumpToCity(row.cityX, row.cityY)
        end,
    })
end

-- ===== Sort (vendor pulldown wrap) ======================================

local SORT_COMPARATORS = {
    TXT_KEY_EVENT_CHOICE_SORT_NAME = function(a, b)
        return Locale.Compare(a.title, b.title) == -1
    end,
    TXT_KEY_EVENT_CHOICE_SORT_DURATION = function(a, b)
        return a.duration < b.duration
    end,
    TXT_KEY_EVENT_CHOICE_SORT_CITY_NAME = function(a, b)
        return Locale.Compare(a.city, b.city) == -1
    end,
}

-- The current order is whatever the vendor pulldown's button text says
-- (its callback rewrites the text on every pick), re-derived at build
-- time rather than tracked, so a pick made through the visual pulldown
-- by a sighted co-driver reorders our rows too. Falls back to the tab's
-- vendor default before the panel's first show.
local function currentComparator(def)
    local published = civvaccess_shared.eventOverviewSortPulldowns
    local pulldown = published and published[def.key]
    if pulldown ~= nil then
        local ok, text = pcall(function()
            return pulldown:GetButton():GetText()
        end)
        if ok and text ~= nil and text ~= "" then
            for _, sortKey in ipairs(def.sortOptions) do
                if tostring(text) == Text.key(sortKey) then
                    return SORT_COMPARATORS[sortKey]
                end
            end
        end
    end
    return SORT_COMPARATORS[def.sortOptions[def.defaultSort]]
end

-- Trailing "Sort by" item wrapping the vendor panel's own pulldown. No
-- onSelected rebuild: the selection sub pops back to the shell, whose
-- re-activation path re-runs the tab's setItems with the new order (and
-- lands the user back on this item, which now speaks the new sort).
local function buildSortItem(def)
    local published = civvaccess_shared.eventOverviewSortPulldowns
    local pulldown = published and published[def.key]
    if pulldown == nil then
        Log.warn("EventOverview: sort pulldown for '" .. def.key .. "' not published; tab keeps default order")
        return nil
    end
    return BaseMenuItems.Pulldown({
        control = pulldown,
        labelFn = function(control)
            return tostring(control:GetButton():GetText())
        end,
    })
end

-- ===== Tabs =============================================================

local TAB_DEFS = {
    {
        key = "playerChoices",
        tabName = "TXT_KEY_PLAYER_EVENT_INFORMATION",
        buildRows = buildPlayerChoiceRows,
        buildRowItem = playerChoiceItem,
        emptyKey = "TXT_KEY_NO_PLAYER_EVENTS",
        sortOptions = { "TXT_KEY_EVENT_CHOICE_SORT_NAME", "TXT_KEY_EVENT_CHOICE_SORT_DURATION" },
        defaultSort = 2,
    },
    {
        key = "cityChoices",
        tabName = "TXT_KEY_CITY_EVENT_INFORMATION",
        buildRows = buildCityChoiceRows,
        buildRowItem = cityChoiceItem,
        emptyKey = "TXT_KEY_NO_CITY_EVENTS",
        sortOptions = { "TXT_KEY_EVENT_CHOICE_SORT_NAME", "TXT_KEY_EVENT_CHOICE_SORT_CITY_NAME" },
        defaultSort = 2,
    },
    {
        key = "playerInstant",
        tabName = "TXT_KEY_RECENT_EVENT_INFORMATION",
        buildRows = buildPlayerInstantRows,
        buildRowItem = playerInstantItem,
        emptyKey = "TXT_KEY_NO_RECENT_EVENTS",
        sortOptions = { "TXT_KEY_EVENT_CHOICE_SORT_NAME", "TXT_KEY_EVENT_CHOICE_SORT_DURATION" },
        defaultSort = 2,
    },
    {
        key = "cityInstant",
        tabName = "TXT_KEY_CITY_RECENT_EVENT_INFORMATION",
        buildRows = buildCityInstantRows,
        buildRowItem = cityInstantItem,
        emptyKey = "TXT_KEY_NO_RECENT_CITY_EVENTS",
        sortOptions = {
            "TXT_KEY_EVENT_CHOICE_SORT_NAME",
            "TXT_KEY_EVENT_CHOICE_SORT_DURATION",
            "TXT_KEY_EVENT_CHOICE_SORT_CITY_NAME",
        },
        defaultSort = 2,
    },
}

local function buildTabItems(def)
    local rows = def.buildRows()
    table.sort(rows, currentComparator(def))
    local items = {}
    for _, row in ipairs(rows) do
        items[#items + 1] = def.buildRowItem(row)
    end
    if #rows == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key(def.emptyKey) })
    end
    local sortItem = buildSortItem(def)
    if sortItem ~= nil then
        items[#items + 1] = sortItem
    end
    return items
end

-- ===== Install ==========================================================

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    -- Vendor tab handlers, captured by key. The vendor file's globals are
    -- live in this env because our include is appended to its tail.
    local VENDOR_PANEL_SWITCH = {
        playerChoices = OnPlayerEventsInfoButton,
        cityChoices = OnCityEventsInfoButton,
        playerInstant = OnRecentEventsInfoButton,
        cityInstant = OnCityRecentEventsInfoButton,
    }

    local tabs = {}
    for _, def in ipairs(TAB_DEFS) do
        local tab = TabbedShell.menuTab({
            tabName = def.tabName,
            menuSpec = {
                displayName = Text.key("TXT_KEY_EVENT_OVERVIEW"),
                items = {},
            },
        })
        -- Decorate the activation: drive the vendor panel first (visual
        -- sync, and the panel's show-handler builds the sort pulldown's
        -- entries), then rebuild rows in the current sort order, then run
        -- menuTab's own lifecycle speech.
        local baseActivated = tab.onTabActivated
        tab.onTabActivated = function(self, announce)
            Log.tryCall("EventOverview panel switch '" .. def.key .. "'", VENDOR_PANEL_SWITCH[def.key])
            local ok, items = pcall(buildTabItems, def)
            if ok then
                tab.menu().setItems(items)
            else
                Log.error("EventOverview buildTabItems '" .. def.key .. "' failed: " .. tostring(items))
            end
            baseActivated(self, announce)
        end
        tabs[#tabs + 1] = tab
    end

    TabbedShell.install(ContextPtr, {
        name = "EventOverview",
        displayName = Text.key("TXT_KEY_EVENT_OVERVIEW"),
        tabs = tabs,
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
    })
end

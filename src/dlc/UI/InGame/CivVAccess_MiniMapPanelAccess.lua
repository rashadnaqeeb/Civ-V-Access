-- Accessible Map Options menu (Ctrl+M). Seated in MiniMapPanel's env via
-- MiniMapPanel.lua's appended include so the panel-local GetMapOptions and
-- the On*Checked handlers, plus the EXE-side strategic-view setters
-- (StrategicViewShowFeatures, OnOverlaySelected, ...), are all in reach --
-- none of which are exposed anywhere else. Baseline's Ctrl+M fires
-- LuaEvents.CivVAccessMapSettingsToggle; this listener builds and pushes a
-- BaseMenu over the panel's own controls. Mirrors the ChatAccess pattern
-- (cross-Context toggle bridged from Baseline into a vendor screen's env).
--
-- Why a menu and not the hotkeys: the engine's map-overlay hotkeys (G grid,
-- Y yields, Ctrl+R resources, F10 strategic view) drive engine view toggles
-- that are noise under Baseline's key capture, so they're blocked. This menu
-- is the accessible replacement, and it also surfaces the flyout-only
-- toggles (trade routes, tile recommendations) and the strategic-view
-- sub-settings that never had hotkeys at all.
--
-- Each item reads live state (OptionsManager.Get*On / InStrategicView /
-- GetMapOptions) and writes by calling the panel's own check / selection
-- handler, then SetChecks the matching visible checkbox so a partially
-- sighted player sees the flyout stay in agreement with the speech menu.
-- SetCheck does not fire the handler, so there's no double-apply.
--
-- Overlay mode and icon mode are multi-value, so they're dropdowns, not
-- drillables: the list entry announces "label, current value" and Enter
-- pushes a sub-handler of the choices (current one marked, pick-and-close),
-- the same shape BaseMenuItems.Pulldown produces. They're built from the
-- engine's own label lists and setters rather than wrapped via
-- BaseMenuItems.Pulldown: that path reads a control's entries / selection
-- callback through PullDownProbe, which only captures via a metatable patch
-- installed before the control is populated. Nothing installs the probe for
-- this panel, and the panel populates these PullDowns during its own load
-- regardless, so probing here would be unreliable. Driving the panel's
-- selection handlers directly sidesteps the probe dependency entirely.
--
-- The strategic-view sub-settings (features, fog, overlay, icon) only apply
-- while strategic view is on, matching the panel hiding its StrategicStack
-- otherwise, so they're in the list only when InStrategicView(). Toggling
-- strategic view re-flows the open menu live via the StrategicViewStateChanged
-- listener (robust whether the engine flips the view synchronously or not).

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
include("CivVAccess_AudioCueMode")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_PluralRules")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_Verbosity")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_Help")

local MAP_HANDLER = "MapSettings"
local MOD_CTRL = 2

-- The currently open Map settings handler, or nil. Used by the
-- StrategicViewStateChanged listener to re-flow the list when the view
-- changes while the menu is up. Singleton: only one Map settings menu is
-- open at a time.
local currentHandler = nil

-- Live per-player option table the panel maintains; holds the strategic-view
-- sub-settings (SVShowFeatures / SVShowFOW / SVIconMode / SVOverlayMode)
-- that have no OptionsManager getter.
local function mapOptions()
    return GetMapOptions(Game.GetActivePlayer())
end

-- VirtualToggle whose write calls the panel's own handler and then mirrors
-- the visible checkbox. controlName is the panel Control to SetCheck for the
-- sighted-sync; nil skips the mirror (strategic view has no flyout checkbox,
-- its button texture syncs via the engine's StrategicViewStateChanged event).
local function panelToggle(textKey, getValue, handler, controlName)
    return BaseMenuItems.VirtualToggle({
        textKey = textKey,
        getValue = getValue,
        setValue = function(b)
            handler(b)
            if controlName ~= nil and Controls[controlName] ~= nil then
                Controls[controlName]:SetCheck(b)
            end
        end,
    })
end

-- Dropdown over a multi-value engine setting. The list entry announces
-- "label, current value"; Enter pushes a sub-handler listing the choices
-- (current one marked) that select and close. Built from the engine's label
-- table (index -> TXT_KEY), a current-index reader, and the panel's
-- selection handler, all of which we have directly -- no control probe.
-- With literal=true, labels hold already-localized strings instead of
-- TXT_KEYs (Community Patch overlay add-ins supply either form).
local function dropdownItem(labelKey, labels, currentFn, selectHandler, literal)
    local function valueText(value)
        if value == nil then
            return nil
        end
        if literal then
            return value
        end
        return Text.key(value)
    end
    return BaseMenuItems.Choice({
        labelFn = function()
            local value = valueText(labels[currentFn()])
            if value ~= nil then
                return Text.format("TXT_KEY_CIVVACCESS_LABEL_STATE", Text.key(labelKey), value)
            end
            return Text.key(labelKey)
        end,
        activate = function()
            local subName = MAP_HANDLER .. "/" .. labelKey
            local items = {}
            for index, value in pairs(labels) do
                items[#items + 1] = BaseMenuItems.Choice({
                    labelText = valueText(value),
                    selectedFn = function()
                        return currentFn() == index
                    end,
                    activate = function()
                        selectHandler(index)
                        HandlerStack.removeByName(subName, true)
                    end,
                })
            end
            HandlerStack.push(BaseMenu.create({
                name = subName,
                displayName = Text.key(labelKey),
                items = items,
                escapePops = true,
            }))
        end,
    })
end

-- Strategic view on/off. OnStrategicView is the panel button's handler (it
-- also covers the observer view-cycle); call it only when the current state
-- differs from the requested one so the toggle is idempotent. The list
-- re-flow happens in the StrategicViewStateChanged listener, not here.
local function strategicViewToggle()
    return BaseMenuItems.VirtualToggle({
        textKey = "TXT_KEY_POP_STRATEGIC_VIEW",
        getValue = function()
            return InStrategicView()
        end,
        setValue = function(b)
            if InStrategicView() ~= b then
                OnStrategicView()
            end
        end,
    })
end

-- Built fresh on every open and on every strategic-view change. Resource
-- icons stay in the list in strategic view (the panel only disables their
-- checkbox there); setting the option still applies when world view returns,
-- and keeping the entry fixed keeps the cursor stable across a re-flow. The
-- strategic-view sub-settings append at the end so the always-present items
-- hold stable indices.
local function buildItems()
    local items = {
        panelToggle("TXT_KEY_MAP_OPTIONS_HEX_GRID", function()
            return OptionsManager.GetGridOn()
        end, OnShowGridChecked, "ShowGrid"),
        panelToggle("TXT_KEY_MAP_OPTIONS_YIELD_ICONS", function()
            return OptionsManager.GetYieldOn()
        end, OnYieldChecked, "ShowYield"),
        panelToggle("TXT_KEY_MAP_OPTIONS_RESOURCE_ICONS", function()
            return OptionsManager.GetResourceOn()
        end, OnResourcesChecked, "ShowResources"),
        panelToggle("TXT_KEY_MAP_OPTIONS_TRADE_ROUTES", function()
            return OptionsManager.GetShowTradeOn()
        end, OnShowTradeChecked, "ShowTrade"),
        panelToggle("TXT_KEY_MAP_OPTIONS_RECOMMENDATIONS", function()
            return OptionsManager.IsNoTileRecommendations()
        end, OnRecommendationChecked, "HideRecommendation"),
        strategicViewToggle(),
    }
    if InStrategicView() then
        items[#items + 1] = panelToggle("TXT_KEY_STRAT_FEATURES", function()
            return mapOptions().SVShowFeatures
        end, OnShowFeaturesChecked, "ShowFeatures")
        items[#items + 1] = panelToggle("TXT_KEY_STRAT_FOW", function()
            return mapOptions().SVShowFOW
        end, OnShowFOWChecked, "ShowFogOfWar")
        if OnModularOverlay ~= nil and g_OverlayCallbacks ~= nil and #g_OverlayCallbacks > 0 then
            -- Community Patch's modular overlay system replaces the engine
            -- list: entries (including mod add-ins) live in the flattened
            -- g_OverlayCallbacks table the vendoring recipe promotes,
            -- selection goes through OnModularOverlay, and g_OverlayActive
            -- holds the current pick (-1 before any, meaning entry 1,
            -- None). Add-in texts may be TXT_KEYs or already-localized.
            local labels = {}
            for i, tab in ipairs(g_OverlayCallbacks) do
                local s = tostring(tab.text)
                if s:find("^TXT_KEY_") ~= nil then
                    s = Text.key(s)
                end
                labels[i] = s
            end
            items[#items + 1] = dropdownItem("TXT_KEY_STRAT_OVERLAY", labels, function()
                if g_OverlayActive ~= nil and g_OverlayActive ~= -1 then
                    return g_OverlayActive
                end
                return 1
            end, OnModularOverlay, true)
        else
            items[#items + 1] = dropdownItem("TXT_KEY_STRAT_OVERLAY", GetStrategicViewOverlays(), function()
                return mapOptions().SVOverlayMode
            end, OnOverlaySelected)
        end
        items[#items + 1] = dropdownItem("TXT_KEY_STRAT_ICON_MODE", GetStrategicViewIconSettings(), function()
            return mapOptions().SVIconMode
        end, OnIconModeSelected)
    end
    return items
end

local function closeMenu()
    if HandlerStack.removeByName(MAP_HANDLER, true) then
        currentHandler = nil
        return true
    end
    return false
end

local function toggleMenu()
    if closeMenu() then
        return
    end
    local handler = BaseMenu.create({
        name = MAP_HANDLER,
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAP_SETTINGS"),
        items = buildItems(),
        capturesAllInput = true,
        escapePops = true,
    })
    -- Ctrl+M self-toggles closed, mirroring how Settings closes on F12 and
    -- chat closes on backslash.
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.M,
        mods = MOD_CTRL,
        description = "Close map settings",
        fn = closeMenu,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_MAP_SETTINGS_HOTKEY_HELP_KEY",
        description = "TXT_KEY_CIVVACCESS_MAP_SETTINGS_HELP_DESC_CLOSE",
    })
    currentHandler = handler
    HandlerStack.push(handler)
end

-- Re-flow the open menu when strategic view changes from any source, so the
-- sub-settings appear or disappear without the user reopening. Only when the
-- map menu itself is on top (skip while the user is inside an overlay/icon
-- sub-handler). setItems clamps the cursor to the first navigable item at or
-- after its current slot; strategic view sits at a fixed index, so the
-- cursor stays put. Silent -- the toggle's own activate already announced
-- the new state.
local function onStrategicViewChanged()
    if currentHandler ~= nil and HandlerStack.active() == currentHandler then
        currentHandler.setItems(buildItems())
    end
end

-- Register fresh on every MiniMapPanel include (no install-once guard): the
-- listener closures capture this Context's env, which load-game-from-game
-- wipes, so a stale registration would throw. Re-registering each include
-- keeps the most recent live closure on each event.
if
    Log.installEvent(
        LuaEvents,
        "CivVAccessMapSettingsToggle",
        Log.safeListener("MiniMapPanelAccess.toggleMenu", toggleMenu),
        "MiniMapPanelAccess",
        "Ctrl+M will no-op"
    )
then
    Log.info("MiniMapPanelAccess: registered LuaEvents.CivVAccessMapSettingsToggle listener")
end

Log.installEvent(
    Events,
    "StrategicViewStateChanged",
    Log.safeListener("MiniMapPanelAccess.onStrategicViewChanged", onStrategicViewChanged),
    "MiniMapPanelAccess",
    "map settings list will not re-flow on strategic-view change"
)

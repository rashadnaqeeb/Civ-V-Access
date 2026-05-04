-- Tab action menu for the selected unit. Enumerates GameInfoActions,
-- keeps the ones the engine will accept, splits them into "commit at the
-- unit's plot" vs "pick a target", and routes each commit through the
-- right path (immediate Game.HandleAction for self-plot, HandleAction
-- + UnitTargetMode.enter for targeted).
--
-- The action set is pulled live from GameInfoActions on every open so a
-- newly-available build / promotion shows up without a stale cache.
-- Promotions and worker builds nest into a sub-Group so the top level
-- stays short (a freshly-promoted veteran with 30 qualifying promotions
-- would otherwise bury the action list).
--
-- Availability pattern mirrors base UnitPanel.lua:230-302:
--   Game.CanHandleAction(iAction, 0, 1) -> "could, if active unit"
--   Game.CanHandleAction(iAction)       -> "can, right now"
-- We show the action only when both return true. Partially-available
-- actions (visible-but-disabled in the engine UI) are omitted from
-- speech because activating one would silently no-op.

UnitActionMenu = {}

-- Action.Type / Action.SubType -> symbolic token for UnitSpeech.selfPlotConfirm.
-- Everything not in either map falls through to speaking the action's
-- localized TextKey as the confirm, so new engine actions at least say
-- something meaningful without needing a mapping update.
local SELF_PLOT_TOKENS_BY_TYPE = {
    MISSION_FORTIFY = "FORTIFY",
    MISSION_SLEEP = "SLEEP",
    MISSION_ALERT = "ALERT",
    MISSION_WAKE = "WAKE",
    COMMAND_WAKE = "WAKE",
    MISSION_AUTOMATE = "AUTOMATE",
    COMMAND_AUTOMATE_BUILD = "AUTOMATE",
    COMMAND_AUTOMATE_EXPLORE = "AUTOMATE",
    COMMAND_DELETE = "DISBAND",
    MISSION_DISBAND = "DISBAND",
    MISSION_HEAL = "HEAL",
    MISSION_PILLAGE = "PILLAGE",
    MISSION_SKIP = "SKIP",
    COMMAND_UPGRADE = "UPGRADE",
    COMMAND_CANCEL = "CANCEL",
    COMMAND_STOP_AUTOMATION = "CANCEL",
}

local function isTargetedAction(actionType)
    return type(actionType) == "string" and actionType:sub(1, 14) == "INTERFACEMODE_"
end

-- Rebase destination enumeration. Cursor-driven target mode is unusable on
-- keyboard for rebase / airlift -- the player can't see which plots are
-- valid -- so the action menu replaces the engine's INTERFACEMODE_REBASE
-- target picker with a list of valid destinations sorted by hex distance
-- from the unit. Each entry commits MISSION_REBASE directly against its
-- plot via the same PUSH_MISSION net message base UI's mouse-click path
-- uses, bypassing INTERFACEMODE_REBASE entirely (the engine processes the
-- mission regardless of UI mode; interface mode only drives the range
-- overlay and cursor, neither of which matters to a blind player).
--
-- Candidates: the active player's own cities (canRebaseAt requires strict
-- owner match for cities -- teammate cities are rejected by the engine
-- absent a CanRebaseInCity script hook, so iterating own cities matches
-- the engine's reachable set) plus the active player's own air-cargo
-- units (carriers). Each candidate is tested with canRebaseAt against its
-- plot; the engine's check covers range, capacity, canLoad, and same-plot
-- exclusion in one call. Dedupe by plot index in case a carrier sits on
-- a city tile.
local function rebaseDestinations(unit)
    local startPlot = unit:GetPlot()
    local ux, uy = unit:GetX(), unit:GetY()
    local actorID = unit:GetID()
    local player = Players[Game.GetActivePlayer()]
    local seen = {}
    local out = {}

    local function add(plot, label, pediaName)
        if plot == nil then
            return
        end
        local idx = plot:GetPlotIndex()
        if seen[idx] then
            return
        end
        local x, y = plot:GetX(), plot:GetY()
        if not unit:CanRebaseAt(startPlot, x, y) then
            return
        end
        seen[idx] = true
        out[#out + 1] = {
            x = x,
            y = y,
            dist = Map.PlotDistance(ux, uy, x, y),
            label = label,
            pediaName = pediaName,
        }
    end

    for city in player:Cities() do
        local cityName = Text.key(city:GetNameKey())
        add(city:Plot(), cityName, cityName)
    end

    for u in player:Units() do
        if u:GetID() ~= actorID and u:CargoSpace() > 0 then
            local typeRow = GameInfo.Units[u:GetUnitType()]
            local typeName = typeRow ~= nil and Text.key(typeRow.Description) or u:GetName()
            add(u:GetPlot(), u:GetName(), typeName)
        end
    end

    table.sort(out, function(a, b)
        if a.dist ~= b.dist then
            return a.dist < b.dist
        end
        return a.label < b.label
    end)
    return out
end

local function buildRebaseDestinationItems(unit)
    local items = {}
    for _, d in ipairs(rebaseDestinations(unit)) do
        local x, y, dist, destLabel = d.x, d.y, d.dist, d.label
        local labelText = Text.formatPlural("TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST", dist, destLabel, dist)
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = labelText,
            pediaName = d.pediaName,
            activate = function()
                UnitControl.registerPending(unit, x, y, { kind = "rebase", destLabel = destLabel })
                Game.SelectionListGameNetMessage(
                    GameMessageTypes.GAMEMESSAGE_PUSH_MISSION,
                    GameInfoTypes.MISSION_REBASE,
                    x,
                    y,
                    0,
                    false,
                    false
                )
                HandlerStack.removeByName("UnitActionMenu", false)
            end,
        })
    end
    if #items == 0 then
        -- Game.CanHandleAction(REBASE) is per-unit (canRebase: air, immobile,
        -- has moves), not per-destination. An air unit with no friendly
        -- cities or carriers in rebase range satisfies the unit gate but
        -- has nowhere to go. Without an entry the menu would silently drop
        -- Rebase, leaving the user wondering. Surface a single info Choice
        -- that speaks the empty-list reason on activate; no engine call.
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.key("TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"),
            activate = function()
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"))
            end,
        })
    end
    return items
end

-- Targeted actions whose action-menu entry expands into a destination list
-- instead of entering the engine's cursor-driven target mode. Keyed on
-- action.Type. Each builder returns the list of Choice items to nest under
-- a drill-in Group; the builder is responsible for surfacing a "no
-- destinations" info Choice when the candidate set is empty, so the entry
-- always stays present and answers the user (the engine's CanHandleAction
-- gate is per-unit, not per-destination, so we can't rely on the outer
-- gate to filter out the no-destinations case).
local DESTINATION_LIST_BUILDERS = {
    INTERFACEMODE_REBASE = buildRebaseDestinationItems,
}

-- Airlift destination enumeration. Different shape from rebase: airlift
-- lands within one tile of a friendly airlift-capable city (the city plot
-- itself or any of the six neighbors), so the picker is two-stage --
-- pick a city, then pick the exact landing hex. The sub-menu lists
-- candidate cities; each Choice's activate pops back to selection mode,
-- jumps the cursor to the city, and enters the engine's
-- INTERFACEMODE_AIRLIFT target picker. From there the user navigates
-- with QAZEDC and commits with Enter against any of the seven candidate
-- hexes (engine's canAirliftAt filters per-hex).
--
-- Candidates: every alive same-team player's cities (the engine's
-- canAirliftAt resolves the destination via GetAdjacentFriendlyCity which
-- is team-keyed, so teammate cities are valid airlift targets unlike
-- rebase's strict-owner gate). Filter to cities where at least one of
-- the seven candidate hexes (city + 6 neighbors) passes canAirliftAt --
-- otherwise the user picks a city, jumps there, and hears "cannot
-- airlift here" on every cursor position. The "city has airport"
-- requirement is enforced inside canAirliftAt's pTargetCity->CanAirlift()
-- check; we don't pre-filter here because CanAirlift isn't bound on
-- CvLuaCity (the engine binding only exposes the unit-side method).
local function airliftCityHasValidHex(unit, startPlot, city)
    local cx, cy = city:GetX(), city:GetY()
    if unit:CanAirliftAt(startPlot, cx, cy) then
        return true
    end
    for dir = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1 do
        local p = Map.PlotDirection(cx, cy, dir)
        if p ~= nil and unit:CanAirliftAt(startPlot, p:GetX(), p:GetY()) then
            return true
        end
    end
    return false
end

-- Major-civ slot count. Matches CivVAccess_ScannerBackendCities's pattern.
-- Iterating only major slots is correct here: the team-match filter below
-- excludes city-states and barbs (they don't share a team with the active
-- player), and they don't have CanAirlift() cities anyway. The 64 fallback
-- exists for the offline test harness where GameDefines isn't injected.
local MAX_MAJOR_PLAYERS = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 64

local function airliftDestinationCities(unit)
    local startPlot = unit:GetPlot()
    local ux, uy = unit:GetX(), unit:GetY()
    local activeTeam = Game.GetActiveTeam()
    local out = {}
    for playerId = 0, MAX_MAJOR_PLAYERS - 1 do
        local player = Players[playerId]
        if player ~= nil and player:IsAlive() and player:GetTeam() == activeTeam then
            for city in player:Cities() do
                -- No CanAirlift() prefilter on the city itself: the engine
                -- method exists in C++ but isn't bound on CvLuaCity. The
                -- seven-hex sweep below tests canAirliftAt per hex, which
                -- internally checks pTargetCity->CanAirlift() -- a city
                -- without an airport fails every hex and gets dropped here
                -- for free.
                if airliftCityHasValidHex(unit, startPlot, city) then
                    local cx, cy = city:GetX(), city:GetY()
                    local cityName = Text.key(city:GetNameKey())
                    out[#out + 1] = {
                        x = cx,
                        y = cy,
                        dist = Map.PlotDistance(ux, uy, cx, cy),
                        label = cityName,
                    }
                end
            end
        end
    end
    table.sort(out, function(a, b)
        if a.dist ~= b.dist then
            return a.dist < b.dist
        end
        return a.label < b.label
    end)
    return out
end

-- Pop both menus (sub on top, action menu underneath), jump the cursor to
-- the picked city, then enter target mode against INTERFACEMODE_AIRLIFT
-- the same way commitTargeted does for the non-airlift flow. The
-- per-hex legality check inside target mode (canAirliftAt against every
-- cursor position) handles the seven-fan validation; the existing
-- legality preview speaks "cannot airlift here" / the destination tile
-- glance per hex on Space.
--
-- ScannerNav.jumpCursorTo (not bare Cursor.jumpTo) is the shared cursor-
-- jump primitive every "send the cursor to a remembered cell" path uses
-- (scanner Home, Bookmarks Shift+digit, Bookmarks Ctrl+S). It handles
-- the markPreJump bookkeeping so Backspace restores the pre-jump cursor
-- position -- the user picked Berlin from the menu and changed their
-- mind, Backspace returns them to where they were navigating before.
-- Return value (tile glance string) is dropped: target mode's onActivate
-- speakInterrupts "target mode" right after, which would clobber any
-- glance we tried to speak first; user inspects the destination by
-- pressing Space inside target mode like every other targeted action.
local function commitAirliftCityPick(unit, action, iAction, cx, cy)
    HandlerStack.removeByName("UnitAirliftMenu", false)
    HandlerStack.removeByName("UnitActionMenu", false)
    ScannerNav.jumpCursorTo(cx, cy)
    Game.HandleAction(iAction)
    UnitTargetMode.enter(unit, iAction, UI.GetInterfaceMode())
end

local function openAirliftSubMenu(unit, action, iAction, displayName)
    local cities = airliftDestinationCities(unit)
    local items = {}
    for _, c in ipairs(cities) do
        local cx, cy, dist, label = c.x, c.y, c.dist, c.label
        local labelText = Text.formatPlural("TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST", dist, label, dist)
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = labelText,
            pediaName = label,
            activate = function()
                commitAirliftCityPick(unit, action, iAction, cx, cy)
            end,
        })
    end
    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.key("TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"),
            activate = function()
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"))
            end,
        })
    end
    local menu = BaseMenu.create({
        name = "UnitAirliftMenu",
        displayName = displayName,
        preamble = Text.key("TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(menu)
end

-- Targeted actions whose action-menu entry pushes a sub-menu (rather than
-- nesting items as a drill-in Group). Used when the picker needs a
-- preamble, or when the entries don't commit directly but instead set up
-- a follow-on interaction (airlift's two-stage pick-city-then-pick-hex).
local SUBMENU_OPENERS = {
    INTERFACEMODE_AIRLIFT = openAirliftSubMenu,
}

local function isPromotionAction(action)
    local subTypes = ActionSubTypes
    return subTypes ~= nil and action.SubType == subTypes.ACTIONSUBTYPE_PROMOTION
end

local function isBuildAction(action)
    local subTypes = ActionSubTypes
    return subTypes ~= nil and action.SubType == subTypes.ACTIONSUBTYPE_BUILD
end

local function actionLabel(action)
    local key = action.TextKey
    if key == nil or key == "" then
        key = action.Type
    end
    if type(key) ~= "string" or key == "" then
        return ""
    end
    return Text.key(key)
end

-- Static Help text from the action's underlying table (Builds.Help,
-- UnitPromotions.Help, Missions.Help, etc.). Engine defaults are "" for
-- rows that don't author one, so treat empty / nil the same.
local function staticHelpText(action)
    if type(action.Help) ~= "string" or action.Help == "" then
        return nil
    end
    return Text.key(action.Help)
end

-- Pedia search string for a Build action: the resulting Improvement's
-- description (Farm, Trading Post, ...) when one exists, else the Route's
-- description (Road, Railroad). Pure feature-clearing / repair builds
-- have neither and return nil, leaving Ctrl+I a silent no-op there.
local function buildPediaName(action)
    local pBuild = GameInfo.Builds[action.MissionData]
    if pBuild == nil then
        return nil
    end
    if pBuild.ImprovementType ~= nil and pBuild.ImprovementType ~= "NONE" then
        local pImprovement = GameInfo.Improvements[pBuild.ImprovementType]
        if pImprovement ~= nil then
            return Text.key(pImprovement.Description)
        end
    end
    if pBuild.RouteType ~= nil and pBuild.RouteType ~= "NONE" then
        local pRoute = GameInfo.Routes[pBuild.RouteType]
        if pRoute ~= nil then
            return Text.key(pRoute.Description)
        end
    end
    return nil
end

-- Yield TXT_KEY per YieldTypes.YIELD_* id, for build-tooltip delta strings.
-- Keys mirror UnitPanel.lua TipHandler's yield branch (line ~1586).
local BUILD_YIELD_KEYS = {
    [YieldTypes.YIELD_FOOD] = "TXT_KEY_BUILD_FOOD_STRING",
    [YieldTypes.YIELD_PRODUCTION] = "TXT_KEY_BUILD_PRODUCTION_STRING",
    [YieldTypes.YIELD_GOLD] = "TXT_KEY_BUILD_GOLD_STRING",
    [YieldTypes.YIELD_SCIENCE] = "TXT_KEY_BUILD_SCIENCE_STRING",
    [YieldTypes.YIELD_CULTURE] = "TXT_KEY_BUILD_CULTURE_STRING",
    [YieldTypes.YIELD_FAITH] = "TXT_KEY_BUILD_FAITH_STRING",
}

-- Rich build tooltip mirroring UnitPanel.lua TipHandler (line ~1540-1658):
-- static Help, turn count for this plot, per-yield delta vs current,
-- resource connection, feature clearing. All pieces joined with ". " so
-- appendTooltip's sentence-level dedup can drop duplicates against the
-- label. Re-queried at announce time per the "never cache game state" rule.
local function buildActionTooltip(unit, action)
    local parts = {}
    local help = staticHelpText(action)
    if help ~= nil then
        parts[#parts + 1] = help
    end

    local iBuildID = action.MissionData
    local pBuild = GameInfo.Builds[iBuildID]
    if pBuild == nil then
        return table.concat(parts, ". ")
    end

    local plot = unit:GetPlot()
    local iActivePlayer = Game.GetActivePlayer()
    local iActiveTeam = Game.GetActiveTeam()

    local iExtraBuildRate = 0
    local iCurrentBuildID = unit:GetBuildType()
    if iCurrentBuildID == -1 or iBuildID ~= iCurrentBuildID then
        iExtraBuildRate = unit:WorkRate(true, iBuildID)
    end
    local iBuildTurns = plot:GetBuildTurnsLeft(iBuildID, iActivePlayer, iExtraBuildRate, iExtraBuildRate)
    if iBuildTurns > 1 then
        parts[#parts + 1] = Text.format("TXT_KEY_BUILD_NUM_TURNS", iBuildTurns)
    end

    local yieldParts = {}
    for iYield = 0, YieldTypes.NUM_YIELD_TYPES - 1 do
        local delta = plot:GetYieldWithBuild(iBuildID, iYield, false, iActivePlayer) - plot:CalculateYield(iYield)
        if delta ~= 0 then
            local key = BUILD_YIELD_KEYS[iYield]
            if key ~= nil then
                yieldParts[#yieldParts + 1] = Text.format(key, delta)
            end
        end
    end
    if #yieldParts > 0 then
        parts[#parts + 1] = table.concat(yieldParts, ", ")
    end

    local pImprovement
    if pBuild.ImprovementType ~= nil and pBuild.ImprovementType ~= "NONE" then
        pImprovement = GameInfo.Improvements[pBuild.ImprovementType]
    end
    if pImprovement ~= nil then
        local iResource = plot:GetResourceType(iActiveTeam)
        if iResource ~= -1 and plot:IsResourceConnectedByImprovement(pImprovement.ID) then
            if Game.GetResourceUsageType(iResource) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS then
                local pResource = GameInfo.Resources[iResource]
                if pResource ~= nil then
                    parts[#parts + 1] =
                        Text.format("TXT_KEY_BUILD_CONNECTS_RESOURCE", pResource.IconString, pResource.Description)
                end
            end
        end
    end

    local iFeature = plot:GetFeatureType()
    if iFeature ~= -1 then
        local pFeature = GameInfo.Features[iFeature]
        if pFeature ~= nil and plot:IsBuildRemovesFeature(iBuildID) then
            parts[#parts + 1] = Text.format("TXT_KEY_BUILD_FEATURE_CLEARED", pFeature.Description)
            local iFeatureProd = plot:GetFeatureProduction(iBuildID, iActiveTeam)
            if iFeatureProd > 0 then
                parts[#parts + 1] = Text.format("TXT_KEY_BUILD_FEATURE_PRODUCTION", iFeatureProd)
            end
        end
    end

    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ". ")
end

-- Collapses both CanHandleAction gates into a single yes / no read,
-- then applies the base-UI's out-of-moves filter.
--
-- Civ V's action table uses 0-based indexing into GameInfoActions, and
-- the iterator emits entries in Action-definition order.
--
-- The zero-moves branch mirrors base UnitPanel.lua:223 with one
-- exception. CanHandleAction returns true for mission actions even at
-- 0 moves because the per-mission canFoo helpers only check plot
-- legality; the real moves gate is downstream in
-- CvUnitMission::ContinueMission's `if (canMove())` block. So
-- MISSION_FOUND / MISSION_BUILD / etc. would silently no-op if we
-- passed them through. Base UI hides everything at 0 moves except
-- cancel, stop-automation, and promotions.
--
-- The exception is path-bearing missions (MOVE_TO and friends): a
-- 0-MP unit pressing Shift+Enter on a target plot must reach the
-- target picker so the mission can be queued for next turn. The
-- engine accepts a queued PUSH_MISSION at 0 MP -- StartMission sets
-- ACTIVITY_HOLD instead of ACTIVITY_MISSION (CvUnitMission.cpp line
-- 1269), the entry stays in the queue, next turn's UpdateMission
-- picks it up. Vanilla mouse path covers this case via map-click
-- (no MP gate on the SELECTION-mode click handler); blind players
-- have no map-click affordance, so without keeping the menu entry
-- there is no keyboard route to queue ahead. Plain Enter at 0 MP on
-- a path-bearing mission still falls through to commitAtCursor's
-- CanDoInterfaceMode rejection and speaks "action failed."
-- GameInfoActions Types for path-bearing interface modes. Move To and
-- Route To back the MISSION_MOVE_TO / MISSION_ROUTE_TO missions
-- (CIV5InterfaceModes.xml Mission field) -- the engine accepts a
-- queued PUSH_MISSION on those at 0 MP. MOVE_TO_TYPE / MOVE_TO_ALL
-- are the shift-modifier-on-click variants for moving same-type or
-- all selected units; same MISSION_MOVE_TO backing, same queue
-- semantics. ATTACK / AIRSTRIKE also back MISSION_MOVE_TO but are
-- combat-class (the action verb is attack-into-tile); those stay
-- hidden at 0 MP because there's no queueable-attack semantics.
local QUEUEABLE_AT_ZERO_MP = {
    INTERFACEMODE_MOVE_TO = true,
    INTERFACEMODE_MOVE_TO_TYPE = true,
    INTERFACEMODE_MOVE_TO_ALL = true,
    INTERFACEMODE_ROUTE_TO = true,
}

-- Embark and Disembark are filtered out of the menu. MISSION_MOVE_TO
-- already handles cross-domain transitions inside CvUnit::move()
-- (CvUnit.cpp ~line 2910): a Move To target on water auto-embarks at
-- the coast step, a target on land auto-disembarks at the shore step.
-- The dedicated INTERFACEMODE_EMBARK / INTERFACEMODE_DISEMBARK only
-- differ in restricting the click target to a single adjacent boundary
-- tile, which is a mouse-UX affordance with no benefit on keyboard.
local HIDDEN_ACTION_TYPES = {
    INTERFACEMODE_EMBARK = true,
    INTERFACEMODE_DISEMBARK = true,
}

local function isAvailable(unit, iAction, action)
    if HIDDEN_ACTION_TYPES[action.Type] then
        return false
    end
    if not action.Visible then
        return false
    end
    if not Game.CanHandleAction(iAction, 0, 1) then
        return false
    end
    if not Game.CanHandleAction(iAction) then
        return false
    end
    if
        unit:MovesLeft() == 0
        and action.Type ~= "COMMAND_CANCEL"
        and action.Type ~= "COMMAND_STOP_AUTOMATION"
        and not isPromotionAction(action)
        and not QUEUEABLE_AT_ZERO_MP[action.Type]
    then
        return false
    end
    return true
end

local function commitSelfPlot(action, payload)
    Game.HandleAction(payload.iAction)
    local token = SELF_PLOT_TOKENS_BY_TYPE[action.Type]
    if isPromotionAction(action) then
        token = "PROMOTION"
    elseif isBuildAction(action) then
        token = "BUILD_START"
    end
    local confirm
    if token ~= nil then
        confirm = UnitSpeech.selfPlotConfirm(token, payload)
    end
    if confirm == nil or confirm == "" then
        confirm = actionLabel(action)
    end
    if confirm ~= "" then
        SpeechPipeline.speakInterrupt(confirm)
    end
end

local function commitTargeted(unit, action, iAction)
    Game.HandleAction(iAction)
    UnitTargetMode.enter(unit, iAction, UI.GetInterfaceMode())
end

local function buildPromotionItems(unit, rows)
    local items = {}
    for _, row in ipairs(rows) do
        local iAction = row.iAction
        local action = row.action
        local label = actionLabel(action)
        local promotionName = label
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = label,
            pediaName = label,
            tooltipFn = function()
                return staticHelpText(action)
            end,
            activate = function()
                commitSelfPlot(action, { iAction = iAction, promotionName = promotionName })
                HandlerStack.removeByName("UnitActionMenu", false)
            end,
        })
    end
    return items
end

local function buildBuildItems(unit, rows)
    local items = {}
    for _, row in ipairs(rows) do
        local iAction = row.iAction
        local action = row.action
        local label = actionLabel(action)
        local buildName = label
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = label,
            pediaName = buildPediaName(action),
            tooltipFn = function()
                return buildActionTooltip(unit, action)
            end,
            activate = function()
                commitSelfPlot(action, { iAction = iAction, buildName = buildName })
                HandlerStack.removeByName("UnitActionMenu", false)
            end,
        })
    end
    return items
end

local function buildTopLevelItems(unit, buckets)
    local items = {}
    for _, row in ipairs(buckets.plain) do
        local iAction = row.iAction
        local action = row.action
        local label = actionLabel(action)
        local destBuilder = DESTINATION_LIST_BUILDERS[action.Type]
        local submenuOpener = SUBMENU_OPENERS[action.Type]
        if label == "" then
            Log.warn("UnitActionMenu: action iAction=" .. tostring(iAction) .. " has no label; omitting")
        elseif submenuOpener ~= nil then
            -- Pushes a separate BaseMenu (with its own preamble) on top of
            -- the action menu rather than nesting items as a Group. Used
            -- when the picker needs an introductory help string or a
            -- two-stage flow where activating an entry doesn't commit
            -- but kicks off a follow-on interaction (airlift jumps the
            -- cursor and enters target mode). Action menu stays on the
            -- stack underneath so Esc on the sub returns to it.
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
                tooltipFn = function()
                    return staticHelpText(action)
                end,
                activate = function()
                    submenuOpener(unit, action, iAction, label)
                end,
            })
        elseif destBuilder ~= nil then
            -- Drill-in Group of valid destinations. cached=false rebuilds
            -- on every drill so the list reflects the current game state
            -- (mission queue changes, MP, capacity) without a stale cache.
            -- The builder is responsible for surfacing an empty-list info
            -- entry when no destinations qualify (the engine's
            -- CanHandleAction gate is per-unit, not per-destination, so an
            -- air unit with no valid targets in range still passes the
            -- outer gate and the user expects a non-silent answer here).
            items[#items + 1] = BaseMenuItems.Group({
                labelText = label,
                tooltipFn = function()
                    return staticHelpText(action)
                end,
                cached = false,
                itemsFn = function()
                    return destBuilder(unit)
                end,
            })
        elseif isTargetedAction(action.Type) then
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
                tooltipFn = function()
                    return staticHelpText(action)
                end,
                activate = function()
                    HandlerStack.removeByName("UnitActionMenu", false)
                    commitTargeted(unit, action, iAction)
                end,
            })
        else
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
                tooltipFn = function()
                    return staticHelpText(action)
                end,
                activate = function()
                    commitSelfPlot(action, { iAction = iAction })
                    HandlerStack.removeByName("UnitActionMenu", false)
                end,
            })
        end
    end
    if #buckets.promotions > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"),
            items = buildPromotionItems(unit, buckets.promotions),
        })
    end
    if #buckets.builds > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"),
            items = buildBuildItems(unit, buckets.builds),
        })
    end
    return items
end

local function collectActions(unit)
    local buckets = { plain = {}, promotions = {}, builds = {} }
    if GameInfoActions == nil then
        Log.error("UnitActionMenu: GameInfoActions missing; no actions to list")
        return buckets
    end
    for iAction = 0, #GameInfoActions do
        local action = GameInfoActions[iAction]
        if action ~= nil and isAvailable(unit, iAction, action) then
            if isPromotionAction(action) then
                buckets.promotions[#buckets.promotions + 1] = { iAction = iAction, action = action }
            elseif isBuildAction(action) then
                buckets.builds[#buckets.builds + 1] = { iAction = iAction, action = action }
            else
                buckets.plain[#buckets.plain + 1] = { iAction = iAction, action = action }
            end
        end
    end
    return buckets
end

-- Public action lookups for the Alt-letter quick-action hotkeys in
-- UnitControl. Same isAvailable / commitSelfPlot / commitTargeted gates
-- the Tab menu uses, so a hotkey commit and a menu commit run identical
-- code (including the speech confirm path through selfPlotConfirm).

-- Find the first GameInfoActions row whose Type is in `types`, regardless
-- of whether it's currently available. Caller uses this to fetch a label
-- for the "{action} not available" failure speech. Iterates types in
-- caller order so the first listed type wins on ties.
function UnitActionMenu.findActionRow(types)
    if GameInfoActions == nil then
        return nil, nil
    end
    for _, wantType in ipairs(types) do
        for iAction = 0, #GameInfoActions do
            local action = GameInfoActions[iAction]
            if action ~= nil and action.Type == wantType then
                return iAction, action
            end
        end
    end
    return nil, nil
end

-- Localized label for an action row's TextKey, with the same fallback
-- ladder as the menu's actionLabel. Public so UnitControl can speak the
-- failure case without duplicating the lookup.
function UnitActionMenu.actionLabel(action)
    return actionLabel(action)
end

-- Find and commit the first available action whose Type is in `types`.
-- Returns true on commit, false if no listed type is currently available
-- for `unit`. Self-plot vs targeted dispatch matches the Tab menu exactly:
-- INTERFACEMODE_* enters target mode through commitTargeted, everything
-- else commits at the unit's plot through commitSelfPlot.
function UnitActionMenu.commitByType(unit, types)
    if unit == nil or GameInfoActions == nil then
        return false
    end
    for _, wantType in ipairs(types) do
        for iAction = 0, #GameInfoActions do
            local action = GameInfoActions[iAction]
            if action ~= nil and action.Type == wantType and isAvailable(unit, iAction, action) then
                if isTargetedAction(action.Type) then
                    commitTargeted(unit, action, iAction)
                else
                    commitSelfPlot(action, { iAction = iAction })
                end
                return true
            end
        end
    end
    return false
end

-- Opens the action menu for `unit`. No-op with no unit. Speaks the
-- "no actions" token and stays closed when every action is filtered.
-- Idempotent: an existing UnitActionMenu handler on the stack is
-- removed before the new push so Tab-during-menu reopens cleanly.
function UnitActionMenu.open(unit)
    if unit == nil then
        return
    end
    local buckets = collectActions(unit)
    local items = buildTopLevelItems(unit, buckets)
    if #items == 0 then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"))
        return
    end
    HandlerStack.removeByName("UnitActionMenu", false)
    local handler = BaseMenu.create({
        name = "UnitActionMenu",
        displayName = Text.key("TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(handler)
end

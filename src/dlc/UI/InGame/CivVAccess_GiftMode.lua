-- Gift-unit / gift-tile-improvement target picker. Pushed above Baseline
-- after the city-state diplo popup commits to OnGiftUnit / OnGiftTile-
-- Improvement (which dequeues the popup and sets INTERFACEMODE_GIFT_UNIT
-- or INTERFACEMODE_GIFT_TILE_IMPROVEMENT). Structurally a sibling to
-- CityRangeStrikeMode: free Q/E/A/D/Z/C cursor movement via Baseline,
-- Space speaks a kind-specific legality preview ("can gift" via the plot's
-- glance, or "cannot gift here"), Enter commits, Esc cancels. Alt+QAZEDC
-- and the Alt-letter quick actions are swallowed to block Baseline's
-- direct-move and quick-action handlers from firing against an unrelated
-- unit while the engine holds a gift interface mode.
--
-- The two kinds share this handler because they're shaped the same -- pick
-- a target plot, fire an engine commit -- and differ only in the per-plot
-- legality predicate and the commit call. Splitting them into two files
-- would duplicate the binding surface and the cancel / cleanup plumbing.
--
-- Commit mirrors the engine's hex-click handlers (InGame.lua GiftUnit /
-- GiftTileImprovement). Gift-unit queues BUTTONPOPUP_GIFT_CONFIRM with
-- the same Data1/2/3 the engine uses; that popup surfaces through
-- GenericPopupAccess as a Yes/No, so we don't need a separate confirm
-- step here. Gift-tile-improvement calls Game.DoMinorGiftTileImprovement
-- directly (no engine confirm popup) and speaks a short "improvement
-- given" so the user knows the command landed.
--
-- Exit (commit OR cancel OR external pop) restores INTERFACEMODE_SELECTION
-- via onDeactivate so the engine's gift mode is unwound regardless of the
-- exit path. Mirrors CityRangeStrikeMode.onDeactivate's belt-and-braces.

GiftMode = {}

local MOD_NONE = 0

local KIND_UNIT = "unit"
local KIND_IMPROVEMENT = "improvement"

local bind = HandlerStack.bind

local speakInterrupt = SpeechPipeline.speakInterrupt

local function cursorPlot()
    local cx, cy = Cursor.position()
    if cx == nil then
        return nil
    end
    return Map.GetPlot(cx, cy), cx, cy
end

-- Find the active player's first unit on `plot`. Mirrors InGame.lua
-- GiftUnit's loop (it overwrites on each match, so the last own-unit on
-- the plot wins -- matching the engine's pick).
local function firstOwnUnit(plot)
    if plot == nil then
        return nil
    end
    local activePlayer = Game.GetActivePlayer()
    local pUnit = nil
    for i = 0, plot:GetNumUnits() - 1 do
        local pFoundUnit = plot:GetUnit(i)
        if pFoundUnit ~= nil and pFoundUnit:GetOwner() == activePlayer then
            pUnit = pFoundUnit
        end
    end
    return pUnit
end

local function canGiftUnitFromPlot(plot, toPlayerID)
    local unit = firstOwnUnit(plot)
    if unit == nil then
        return false
    end
    return unit:CanDistanceGift(toPlayerID)
end

local function canGiftImprovementAtPlot(x, y, toPlayerID)
    local pToPlayer = Players[toPlayerID]
    if pToPlayer == nil then
        return false
    end
    return pToPlayer:CanMajorGiftTileImprovementAtPlot(Game.GetActivePlayer(), x, y)
end

-- Initial landing target. Convenience-only -- nil result is fine; cursor
-- stays where the user was and they roam manually. For unit, walks the
-- player's unit list to find the first one CanDistanceGift accepts. For
-- improvement, expands rings out from the city-state's capital up to
-- MINOR_CIV_RESOURCE_SEARCH_RADIUS, the same box HighlightImprovableCity-
-- StatePlots scans (InGame.lua:709), so the first hit is spatially close
-- to the city.
local function findFirstUnitTarget(toPlayerID)
    local activePlayer = Players[Game.GetActivePlayer()]
    if activePlayer == nil then
        return nil, nil
    end
    for unit in activePlayer:Units() do
        if unit:CanDistanceGift(toPlayerID) then
            return unit:GetX(), unit:GetY()
        end
    end
    return nil, nil
end

local function findFirstImprovementTarget(toPlayerID)
    local pToPlayer = Players[toPlayerID]
    if pToPlayer == nil then
        return nil, nil
    end
    local capital = pToPlayer:GetCapitalCity()
    if capital == nil then
        return nil, nil
    end
    local cx, cy = capital:GetX(), capital:GetY()
    local iFromPlayer = Game.GetActivePlayer()
    local iRange = GameDefines["MINOR_CIV_RESOURCE_SEARCH_RADIUS"] or 5
    for r = 1, iRange do
        for dx = -r, r do
            for dy = -r, r do
                local plot = Map.PlotXYWithRangeCheck(cx, cy, dx, dy, r)
                if plot ~= nil then
                    local px, py = plot:GetX(), plot:GetY()
                    if pToPlayer:CanMajorGiftTileImprovementAtPlot(iFromPlayer, px, py) then
                        return px, py
                    end
                end
            end
        end
    end
    return nil, nil
end

-- Per-plot Space preview. PlotComposers.legalityPreview returns the plot
-- glance on legal targets and the "cannot X here" key on illegal -- the
-- glance covers unit identity on the gift-unit path (a plot with my Warrior
-- reads "Warrior"), so the absence of the "cannot" prefix already tells
-- the user the cursor's unit is the one they'd commit.
local legalityPreview = PlotComposers.legalityPreview

local function commitUnit(toPlayerID)
    local plot, _x, _y = cursorPlot()
    if plot == nil then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"))
        return false
    end
    local unit = firstOwnUnit(plot)
    if unit == nil or not unit:CanDistanceGift(toPlayerID) then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"))
        return false
    end
    -- Mirror InGame.lua:215-221. The engine's BUTTONPOPUP_GIFT_CONFIRM
    -- handler is C++-side and surfaces through PopupLayouts.ConfirmGift
    -- (covered by GenericPopupAccess), so the Yes/No follow-up reads
    -- without further wiring.
    Events.SerialEventGameMessagePopup({
        Type = ButtonPopupTypes.BUTTONPOPUP_GIFT_CONFIRM,
        Data1 = Game.GetActivePlayer(),
        Data2 = toPlayerID,
        Data3 = unit:GetID(),
    })
    return true
end

local function commitImprovement(toPlayerID)
    local _plot, cx, cy = cursorPlot()
    if cx == nil then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"))
        return false
    end
    if not canGiftImprovementAtPlot(cx, cy, toPlayerID) then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"))
        return false
    end
    -- Mirror InGame.lua:290-291. No engine confirm popup on this path,
    -- so speak a short confirmation locally.
    Game.DoMinorGiftTileImprovement(Game.GetActivePlayer(), toPlayerID, cx, cy)
    speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"))
    return true
end

-- Abandon-entry path. Caller has already put the engine into one of the
-- gift modes; bail unwinds it so the user isn't stranded with no binding.
local function abandonEntry()
    UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)
end

function GiftMode.enter(toPlayerID, kind)
    if toPlayerID == nil or toPlayerID < 0 then
        Log.warn("GiftMode.enter: invalid toPlayerID " .. tostring(toPlayerID) .. "; aborting")
        abandonEntry()
        return
    end
    if kind ~= KIND_UNIT and kind ~= KIND_IMPROVEMENT then
        Log.warn("GiftMode.enter: unknown kind " .. tostring(kind) .. "; aborting")
        abandonEntry()
        return
    end

    local self = {
        name = "GiftMode",
        capturesAllInput = false,
    }

    local function popHandler()
        HandlerStack.removeByName("GiftMode", false)
    end

    local previewFn
    local commitFn
    local modeWordKey
    local jumpFn
    if kind == KIND_UNIT then
        previewFn = function()
            local plot = cursorPlot()
            if plot == nil then
                return ""
            end
            return legalityPreview(
                canGiftUnitFromPlot(plot, toPlayerID),
                "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL",
                plot
            )
        end
        commitFn = function()
            if commitUnit(toPlayerID) then
                popHandler()
            end
        end
        modeWordKey = "TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"
        jumpFn = function()
            return findFirstUnitTarget(toPlayerID)
        end
    else
        previewFn = function()
            local plot, cx, cy = cursorPlot()
            if plot == nil then
                return ""
            end
            return legalityPreview(
                canGiftImprovementAtPlot(cx, cy, toPlayerID),
                "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL",
                plot
            )
        end
        commitFn = function()
            if commitImprovement(toPlayerID) then
                popHandler()
            end
        end
        modeWordKey = "TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"
        jumpFn = function()
            return findFirstImprovementTarget(toPlayerID)
        end
    end

    self.bindings = {
        bind(Keys.VK_SPACE, MOD_NONE, function()
            speakInterrupt(previewFn())
        end, "Target preview"),
        bind(Keys.VK_RETURN, MOD_NONE, commitFn, "Commit gift"),
        bind(Keys.VK_ESCAPE, MOD_NONE, function()
            popHandler()
            speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CANCELED"))
        end, "Cancel"),
    }
    -- Block Baseline's Alt+QAZEDC direct-move and Alt+letter quick-actions
    -- (fortify / heal / pillage / wake / etc.) while the engine holds the
    -- gift interface mode; without the blocks a stray Alt+key commits
    -- against whatever unit is selected and fights the picker.
    HandlerStack.appendAltBlocks(self.bindings, { directMove = true, quickActions = true })
    self.helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_PREVIEW",
            description = "TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_PREVIEW",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_COMMIT",
            description = "TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_COMMIT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_CANCEL",
            description = "TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_CANCEL",
        },
    }
    self.onActivate = function()
        speakInterrupt(Text.key(modeWordKey))
        local jx, jy = jumpFn()
        if jx ~= nil then
            local tileSpeech = Cursor.jumpTo(jx, jy)
            if tileSpeech ~= nil and tileSpeech ~= "" then
                SpeechPipeline.speakQueued(tileSpeech)
            end
        end
    end
    self.onDeactivate = function()
        UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)
    end

    if not HandlerStack.push(self) then
        abandonEntry()
    end
end

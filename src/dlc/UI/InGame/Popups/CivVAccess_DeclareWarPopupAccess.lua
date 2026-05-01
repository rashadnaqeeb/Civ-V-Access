-- DeclareWarPopup (BNW) accessibility. Yes / No confirmation for declaring
-- war by moving onto rival territory, range-striking a rival, or plundering
-- a trade route.
--
-- Structure mirrors GenericPopup (AddButton / ClearButtons / HideWindow /
-- SetPopupText, Button1..N + per-slot callbacks), but DeclareWarPopup lives
-- in its own Context with a local PopupLayouts table -- GenericPopup's
-- dispatch never reaches it. Same monkey-patch trick captures per-slot
-- callbacks so each BaseMenuItems.Button slot can invoke the recorded click
-- and then dismiss via HideWindow. The XML only defines Button1 / Button2;
-- extra slots would be ignored (resolveControl nil-guards isNavigable).
--
-- PopupText holds the reason line set by each PopupLayouts entry
-- ("Are you sure you wish to declare war on X?" plus open-borders /
-- city-state / plunder variants); surfaced as the preamble.
--
-- DECLAREWARMOVE-only coordination with UnitControl's pending-move
-- tracker: the popup intercepts a move that already registered pending,
-- so the engine's two-tick expiry would falsely speak "action failed"
-- under the popup. UnitControl freezes pending into a deferred slot on
-- popup show; we re-arm it on Yes (slot 1) so the engine's re-issued
-- Game.SelectionListMove gets announced normally, or drop it on No /
-- Esc (the popup itself was the user's resolution). Other DeclareWar
-- popup variants (range-strike, plunder) don't touch the deferred slot
-- because their commit paths skip pending registration.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- AddButton / ClearButtons / HideWindow monkey-patches ---------------------

local baseAddButton    = AddButton
local baseClearButtons = ClearButtons
local baseHideWindow   = HideWindow

local buttonCallbacks    = {}
local buttonPreventClose = {}
local nextButtonIdx      = 1

-- Tracks whether the current popup-open ended via a button click vs an
-- Esc / mouse-out dismissal; HideWindow uses it to decide whether to
-- notify UnitControl that the deferred move was canceled.
local _clicked = false

AddButton = function(buttonText, buttonClickFunc, strToolTip, bPreventClose)
    baseAddButton(buttonText, buttonClickFunc, strToolTip, bPreventClose)
    if nextButtonIdx <= 4 then
        buttonCallbacks[nextButtonIdx]    = buttonClickFunc
        buttonPreventClose[nextButtonIdx] = bPreventClose == true
        nextButtonIdx = nextButtonIdx + 1
    end
end

ClearButtons = function()
    baseClearButtons()
    buttonCallbacks    = {}
    buttonPreventClose = {}
    nextButtonIdx      = 1
end

HideWindow = function()
    if not _clicked
        and g_PopupInfo ~= nil
        and g_PopupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_DECLAREWARMOVE then
        local UC = civvaccess_shared.modules and civvaccess_shared.modules.UnitControl
        if UC ~= nil and UC.notifyCommitCanceled ~= nil then
            UC.notifyCommitCanceled()
        end
    end
    _clicked = false
    return baseHideWindow()
end

-- Items ---------------------------------------------------------------------

local function invokeSlot(idx)
    _clicked = true
    -- DECLAREWARMOVE-only: forward Yes (slot 1) / No (slot 2) to UnitControl
    -- BEFORE the engine's OnYesClicked runs so re-arming pending captures
    -- the unit's start hex before Game.SelectionListMove fires.
    if g_PopupInfo ~= nil
        and g_PopupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_DECLAREWARMOVE then
        local UC = civvaccess_shared.modules and civvaccess_shared.modules.UnitControl
        if UC ~= nil then
            if idx == 1 and UC.notifyDeferredCommit ~= nil then
                UC.notifyDeferredCommit()
            elseif idx ~= 1 and UC.notifyCommitCanceled ~= nil then
                UC.notifyCommitCanceled()
            end
        end
    end
    local fn = buttonCallbacks[idx]
    if fn ~= nil then
        local ok, err = pcall(fn)
        if not ok then
            Log.error("DeclareWarPopupAccess: button " .. idx
                .. " callback failed: " .. tostring(err))
        end
    end
    if not buttonPreventClose[idx] then
        HideWindow()
    end
end

local function labelForSlot(idx)
    return Controls["Button" .. idx .. "Text"]:GetText() or ""
end

BaseMenu.install(ContextPtr, {
    name          = "DeclareWarPopup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"),
    preamble      = function() return Controls.PopupText:GetText() end,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "Button1",
            labelFn     = function() return labelForSlot(1) end,
            activate    = function() invokeSlot(1) end,
        }),
        BaseMenuItems.Button({
            controlName = "Button2",
            labelFn     = function() return labelForSlot(2) end,
            activate    = function() invokeSlot(2) end,
        }),
    },
})

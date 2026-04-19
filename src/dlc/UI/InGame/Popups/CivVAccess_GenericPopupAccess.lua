-- GenericPopup accessibility. One BaseMenu handler covers all 16 popups
-- dispatched through PopupLayouts (AnnexCity, PuppetCity, LiberateMinor,
-- ReturnCivilian, ConfirmCommand, ConfirmCityTask, ConfirmGift,
-- ConfirmImprovementRebuild, ConfirmPolicyBranch, DeclareWarMove,
-- DeclareWarRangeStrike, BarbarianRansom, MinorCivEnterTerritory,
-- MinorCivGold, NetworkKicked, CityPlotManagement).
--
-- Buttons: the XML declares Button1..Button4 + CloseButton; each layout
-- unhides and labels a subset via AddButton. We monkey-patch AddButton /
-- ClearButtons to record the per-slot click callback and preventClose flag,
-- then expose each slot as a BaseMenuItems.Button. Slot visibility falls
-- out of _control:IsHidden, so items for unused slots drop out of
-- navigation automatically; the CloseButton item behaves the same way
-- (layouts that want it call Controls.CloseButton:SetHide(false)).
--
-- Timing: OnDisplay runs ClearButtons -> layout (SetPopupText + AddButton
-- calls) -> ShowWindow. ShowWindow's QueuePopup triggers our ShowHide,
-- which pushes the handler; by that point PopupText and the visible
-- buttons are already set, so onActivate reads fresh state. No refresh
-- listener needed.
--
-- Escape: priorInput chains to the base InputHandler, which dispatches to
-- PopupInputHandlers[type]. Popups with a handler dismiss on Esc/Return.
-- Popups without one consume keys without acting (matches base; sighted
-- users in that path also have to click a button). Enter on the focused
-- menu item activates it, giving blind users a reliable keyboard path for
-- every popup regardless of whether a PopupInputHandler is registered.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

Log.info("GenericPopupAccess: wiring BaseMenu over PopupLayouts dispatch")

local priorInput = InputHandler

-- AddButton / ClearButtons monkey-patches -----------------------------------

local baseAddButton    = AddButton
local baseClearButtons = ClearButtons

local buttonCallbacks    = {}
local buttonPreventClose = {}
local nextButtonIdx      = 1

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

-- Items ---------------------------------------------------------------------

local function invokeSlot(idx)
    local fn = buttonCallbacks[idx]
    if fn ~= nil then
        local ok, err = pcall(fn)
        if not ok then
            Log.error("GenericPopupAccess: button " .. idx
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

local items = {
    BaseMenuItems.Button({ controlName = "Button1",
        labelFn = function() return labelForSlot(1) end,
        activate = function() invokeSlot(1) end }),
    BaseMenuItems.Button({ controlName = "Button2",
        labelFn = function() return labelForSlot(2) end,
        activate = function() invokeSlot(2) end }),
    BaseMenuItems.Button({ controlName = "Button3",
        labelFn = function() return labelForSlot(3) end,
        activate = function() invokeSlot(3) end }),
    BaseMenuItems.Button({ controlName = "Button4",
        labelFn = function() return labelForSlot(4) end,
        activate = function() invokeSlot(4) end }),
    BaseMenuItems.Button({ controlName = "CloseButton",
        textKey  = "TXT_KEY_CLOSE",
        activate = function() HideWindow() end }),
}

BaseMenu.install(ContextPtr, {
    name        = "GenericPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"),
    preamble    = function() return Controls.PopupText:GetText() end,
    priorInput  = priorInput,
    items       = items,
})

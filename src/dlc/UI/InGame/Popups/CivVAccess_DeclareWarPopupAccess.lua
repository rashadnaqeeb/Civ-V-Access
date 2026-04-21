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

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

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

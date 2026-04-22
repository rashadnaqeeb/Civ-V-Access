-- Advisors (tutorial banner) accessibility. Fired by Events.AdvisorDisplayShow
-- from TutorialEngine.ProcessActiveTutorialQueue with eventInfo =
-- {IDName, Advisor, TitleText, BodyText, ActivateButtonText, Concept1/2/3,
-- Modal}. Body is short tutorial advice (e.g. "This looks like a good place
-- to start a city..."). Up to three Question buttons drill into a Concept
-- (each opens BUTTONPOPUP_ADVISOR_INFO, a separate Context not yet wired);
-- an optional Activate button fires a generic help popup; a Don't-show-
-- again checkbox and Thank-you dismiss complete the layout. Question4String
-- exists in the XML but the base lua never wires it, so we omit it too.
--
-- DontShowAgainCheckbox has no click callback wired in base code: base
-- AdvisorClose() reads its state synchronously at dismiss time and calls
-- UI.SetAdvisorMessageHasBeenSeen(g_TutorialQueue[1].IDName, true). Our
-- Checkbox item uses a no-op activateCallback so PullDownProbe's "callback
-- not captured" warning stays quiet; toggling only flips the control state,
-- which is all base code reads anyway.
--
-- Re-show while visible: when a tutorial queues behind one already on
-- screen, base OnAdvisorDisplayShow overwrites the Controls text in place
-- and calls AdvisorOpen(), whose SetHide(false) on an already-visible
-- Context does not fire ShowHide. The AdvisorDisplayShow listener below
-- detects this case via a freshShow flag that onShow sets: if the flag is
-- false when the listener runs, the Context was already visible, so force
-- a full re-announce by clearing _initialized and re-running onActivate.
-- The flag also guards against double-announcing in the normal fresh-show
-- path (where ShowHide + onShow + push already announced before our
-- listener runs).

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

local function controlText(control)
    if control == nil then
        return ""
    end
    local ok, text = pcall(function()
        return control:GetText()
    end)
    if not ok or text == nil then
        return ""
    end
    return tostring(text)
end

-- Preamble order: advisor title ("Science Advisor" etc., set live by base
-- SetAdvisorDisplay), then tutorial header ("Found Your First City"), then
-- body ("This looks like a good place..."). AdvisorTitleText lives inside
-- a hidden grid so it does not render, but GetText returns the populated
-- value and the user hears which advisor is speaking.
local function buildPreamble()
    local parts = {}
    local advisor = controlText(Controls.AdvisorTitleText)
    if advisor ~= "" then
        parts[#parts + 1] = advisor
    end
    local header = controlText(Controls.AdvisorHeaderText)
    if header ~= "" then
        parts[#parts + 1] = header
    end
    local body = controlText(Controls.AdvisorBodyText)
    if body ~= "" then
        parts[#parts + 1] = body
    end
    return table.concat(parts, ". ")
end

local freshShow = false

local handler = BaseMenu.install(ContextPtr, {
    name = "Advisors",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"),
    preamble = buildPreamble,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = function(h)
        -- Force onActivate's fresh-show path on every show, so SetHide(false)
        -- on an already-visible Context (should the engine ever fire ShowHide
        -- for the re-show case) still resets level / cursor / search.
        h._initialized = false
        freshShow = true
    end,
    items = {
        BaseMenuItems.Button({
            controlName = "Question1String",
            labelFn = function(c)
                return controlText(c)
            end,
            activate = function()
                OnQuestion1Clicked()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "Question2String",
            labelFn = function(c)
                return controlText(c)
            end,
            activate = function()
                OnQuestion2Clicked()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "Question3String",
            labelFn = function(c)
                return controlText(c)
            end,
            activate = function()
                OnQuestion3Clicked()
            end,
        }),
        -- Labelled from the inner ActivateButtonText label (the GridButton
        -- itself has no text); activate fires base OnAdvisorHelpClicked
        -- which opens popup Type=99997.
        BaseMenuItems.Button({
            controlName = "ActivateButton",
            labelFn = function()
                return controlText(Controls.ActivateButtonText)
            end,
            activate = function()
                OnAdvisorHelpClicked()
            end,
        }),
        BaseMenuItems.Checkbox({
            controlName = "DontShowAgainCheckbox",
            textKey = "TXT_KEY_ADVISOR_MODAL_DONT_SHOW_ME_AGAIN",
            activateCallback = function() end,
        }),
        BaseMenuItems.Button({
            controlName = "AdvisorDismissButton",
            textKey = "TXT_KEY_ADVISOR_THANK_YOU",
            activate = function()
                OnAdvisorDismissClicked()
            end,
        }),
    },
})

Events.AdvisorDisplayShow.Add(function()
    -- Context hidden when the listener runs means base OnAdvisorDisplayShow
    -- has not yet reached its AdvisorOpen() call, or AdvisorOpen's
    -- SetHide(false) has not transitioned yet. Either way, the install
    -- ShowHide wrapper will fire and announce on the transition; nothing
    -- for us to do here.
    if ContextPtr:IsHidden() then
        return
    end
    if freshShow then
        freshShow = false
        return
    end
    -- Context was already visible: base overwrote the tutorial text in
    -- place without a SetHide transition. Re-announce the new preamble and
    -- reset the cursor to the first navigable item.
    handler._initialized = false
    local ok, err = pcall(handler.onActivate)
    if not ok then
        Log.error("Advisors re-show onActivate failed: " .. tostring(err))
    end
end)

-- Advisors (tutorial banner) accessibility. Fired by Events.AdvisorDisplayShow
-- from TutorialEngine.ProcessActiveTutorialQueue with eventInfo =
-- {IDName, Advisor, TitleText, BodyText, ActivateButtonText, Concept1/2/3,
-- Modal}. Body is short tutorial advice ("This is a good place to start a
-- city..."). Up to three Question buttons drill into a Concept (each opens
-- BUTTONPOPUP_ADVISOR_INFO, a separate Context not yet wired); an optional
-- Activate button fires a generic help popup; a Don't-show-again checkbox
-- and Thank-you dismiss complete the layout. Question4String exists in the
-- XML but base lua never wires it, so we omit it too.
--
-- Speech overlap: the engine plays a pre-recorded advisor voice clip for
-- every tutorial listed in Sounds/XML/AdvisorSoundConnections.xml (covers
-- essentially every base-game tutorial). That clip narrates the same text
-- our preamble would speak, so reading the preamble on push produces a
-- double-narration. AdvisorSoundConnections is not exposed through
-- GameInfo, so we can't reliably detect "voice will play" per-tutorial.
-- Resolution: silentFirstOpen = true. On fresh show BaseMenu speaks only
-- the dynamic displayName (the live advisor title) and nothing else. The
-- body text stays reachable through F1 (readHeader) so the user can opt
-- in. Tradeoff: a tutorial added without voice (mod content, unusual
-- base case) will be silent until the user presses F1 -- matches the
-- stated preference for silence-plus-F1 over spam.
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
--
-- Escape routing: vanilla InputHandler calls AdvisorClose() directly, which
-- pops Advisors.lua's g_TutorialQueue and hides the Context but never fires
-- Events.AdvisorDisplayHide. TutorialEngine's HandleAdvisorUIHide listens
-- on that event and is the only thing that pops g_ActiveTutorialQueue and
-- calls ProcessActiveTutorialQueue(), so vanilla Escape leaves the engine
-- stuck on the same tutorial -- the banner closes but the next queued
-- tutorial never shows. onEscape below routes Escape through
-- OnAdvisorDismissClicked (the Thank-You button's handler) which fires the
-- event, matching the advance-to-next behavior the mouse path has.

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
include("CivVAccess_CameraTracker")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function controlText(control)
    if control == nil then
        return ""
    end
    local ok, text = pcall(function()
        return control:GetText()
    end)
    if not ok then
        Log.warn("AdvisorsAccess: GetText failed: " .. tostring(text))
        return ""
    end
    if text == nil then
        return ""
    end
    return tostring(text)
end

-- The screen name tracks whoever is currently speaking. base SetAdvisorDisplay
-- writes the per-advisor title ("Military Advisor", "Economic Advisor", etc.)
-- into AdvisorTitleText on every OnAdvisorDisplayShow, so reading it live
-- gives the right value for the tutorial currently on screen. Falls back to
-- the static "Tutorial Advisor" string when the label is blank, which keeps
-- the spec's non-empty-string requirement satisfied at install time before
-- any tutorial has fired.
local function readAdvisorTitle()
    local live = controlText(Controls.AdvisorTitleText)
    if live ~= "" then
        return live
    end
    return Text.key("TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL")
end

local function buildPreamble()
    local parts = {}
    local header = controlText(Controls.AdvisorHeaderText)
    if header ~= "" then
        parts[#parts + 1] = header
    end
    local body = controlText(Controls.AdvisorBodyText)
    if body ~= "" then
        parts[#parts + 1] = body
    end
    if #parts == 0 then
        return nil
    end
    return TextFilter.filter(table.concat(parts, ". "))
end

local freshShow = false

local handler = BaseMenu.install(ContextPtr, {
    name = "Advisors",
    -- Install-time placeholder; onShow writes the live advisor title into
    -- handler.displayName before each push so the user hears "Economic
    -- Advisor" / "Military Advisor" / etc.
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"),
    preamble = buildPreamble,
    silentFirstOpen = true,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onEscape = function()
        OnAdvisorDismissClicked()
        return true
    end,
    onShow = function(h)
        -- Update the live title and force onActivate's fresh-show path on
        -- every show (so SetHide(false) on an already-visible Context --
        -- should the engine ever fire ShowHide for the re-show case --
        -- still resets cursor / search / initialized).
        h.displayName = readAdvisorTitle()
        h._initialized = false
        freshShow = true
    end,
    items = {
        BaseMenuItems.Button({
            controlName = "Question1String",
            labelFn = controlText,
            activate = function()
                OnQuestion1Clicked()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "Question2String",
            labelFn = controlText,
            activate = function()
                OnQuestion2Clicked()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "Question3String",
            labelFn = controlText,
            activate = function()
                OnQuestion3Clicked()
            end,
        }),
        -- Labelled from the inner ActivateButtonText label (the GridButton
        -- itself has no text); activate fires base OnAdvisorHelpClicked
        -- which opens popup Type=99997. The TutorialEngine's handler for
        -- that type (Tutorial/lua/TutorialEngine.lua:450-493) dispatches
        -- to UI.SelectUnit + UI.LookAt, UI.LookAt directly, or another
        -- popup depending on the tutorial -- the camera-panning variants
        -- get the cursor follow via CameraTracker; the popup-opening
        -- variant times out silently with the cursor unchanged.
        BaseMenuItems.Button({
            controlName = "ActivateButton",
            labelFn = function()
                return controlText(Controls.ActivateButtonText)
            end,
            activate = function()
                OnAdvisorHelpClicked()
                CameraTracker.followAndJumpCursor()
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
    -- place without a SetHide transition. Re-announce under the new
    -- advisor by mirroring onShow's state reset and re-running onActivate.
    handler.displayName = readAdvisorTitle()
    handler._initialized = false
    local ok, err = pcall(handler.onActivate)
    if not ok then
        Log.error("Advisors re-show onActivate failed: " .. tostring(err))
    end
end)

-- AdvisorModal accessibility. Combat-interrupt popup fired by the engine
-- (BUTTONPOPUP_ADVISOR_MODAL) when the active player queues a move the AI
-- judges as a bad attack or an attack against a city. Binary choice:
-- Confirm proceeds with the queued move (Game.SetCombatWarned +
-- Game.SelectionListMove against the referenced plot), Cancel abandons.
-- A DontShowAgainCheckbox suppresses future warnings of the same flavour
-- (city-attack vs bad-attack, keyed off g_bAttackingCity in the base file);
-- the base Close() reads the checkbox synchronously and calls the matching
-- Game.SetAdvisor*Interrupt(false), so our items just delegate to the base
-- callbacks and the checkbox toggle only flips the control state.
--
-- TitleLabel / DescriptionLabel are populated by the base OnPopup with
-- the scenario-specific banner (e.g. "This Attack May Not End Well") and
-- body text; we surface both as the preamble so the user hears why the
-- warning fired before the first item. DisplayName is the static
-- "Combat Information" header.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function buildPreamble()
    local body = Text.joinNonEmpty({
        Controls.TitleLabel:GetText(),
        Controls.DescriptionLabel:GetText(),
    }, ". ")
    if body == "" then
        return nil
    end
    return body
end

BaseMenu.install(ContextPtr, {
    name          = "AdvisorModal",
    displayName   = Text.key("TXT_KEY_ADVISOR_MODAL_TITLE"),
    preamble      = buildPreamble,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "ConfirmButton",
            textKey     = "TXT_KEY_ADVISOR_MODAL_CONFIRM",
            activate    = function() OnConfirmButtonClicked() end,
        }),
        BaseMenuItems.Button({
            controlName = "CancelButton",
            textKey     = "TXT_KEY_ADVISOR_MODAL_CANCEL",
            activate    = function() OnCancelButtonClicked() end,
        }),
        BaseMenuItems.Checkbox({
            controlName      = "DontShowAgainCheckbox",
            textKey          = "TXT_KEY_ADVISOR_MODAL_DONT_SHOW_ME_AGAIN",
            -- No engine-side callback exists: the base's Close() reads
            -- DontShowAgainCheckbox at dismiss time and calls
            -- Game.SetAdvisor*Interrupt(false) there. The toggle on our
            -- side just flips the control state. A no-op activateCallback
            -- suppresses the "callback not captured" warning the
            -- PullDownProbe fallback would log.
            activateCallback = function() end,
        }),
    },
})

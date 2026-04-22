-- AdvisorInfoPopup accessibility wiring. Fired by
-- Events.SerialEventGameMessagePopup with Type=BUTTONPOPUP_ADVISOR_INFO and
-- Text=<concept key>. Base OnPopup populates the screen via ShowConcept(key)
-- and pushes itself onto the popup stack; the user can drill into any
-- related concept (same screen redraws in place), navigate Back/Forward
-- through an in-popup history, jump to the matching Civilopedia page, or
-- search the Civilopedia by description.
--
-- Speech model: displayName is the live concept title (Controls.TitleLabel)
-- and changes on every navigation; the preamble joins AdvisorLabel (which
-- advisor category this concept belongs to) with DescriptionLabel (the body
-- text). Items are rebuilt per-concept and contain the related-concept
-- choices followed by the two Civilopedia hand-offs and Close.
--
-- In-place nav: ShowConcept writes Controls directly with no ShowHide
-- transition, so wrapping it is the only way to notice the concept changed.
-- The wrap captures the key, rebuilds items, and re-runs onActivate when the
-- Context is already visible (post-first-open). On the initial popup show
-- ShowConcept fires first (still hidden) and the subsequent ShowHide handles
-- the announce naturally; we guard the re-announce path with IsHidden().
--
-- Related-concept buttons are InstanceManager-created and have no stable
-- Controls.X entry, so we use BaseMenuItems.Choice (control-less). Activation
-- calls AddToHistory + ShowConcept directly rather than base ConceptSelected:
-- ConceptSelected indexes into base's local g_strConceptList (which our
-- iteration order has to match exactly) whereas going through the history
-- helpers is ordering-independent.

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

-- Module-local mirror of the current concept key. Base's g_strConcept is a
-- chunk-local that our include cannot see, so we track our own copy updated
-- by the ShowConcept wrap below.
local currentConceptKey = nil

local function readTitle()
    local ok, text = pcall(function()
        return Controls.TitleLabel:GetText()
    end)
    if not ok then
        Log.warn("AdvisorInfoPopupAccess: TitleLabel GetText failed: " .. tostring(text))
        return Text.key("TXT_KEY_ADVISOR_INFORMATION")
    end
    if text == nil or text == "" then
        return Text.key("TXT_KEY_ADVISOR_INFORMATION")
    end
    return tostring(text)
end

local function controlText(control)
    if control == nil then
        return ""
    end
    local ok, text = pcall(function()
        return control:GetText()
    end)
    if not ok then
        Log.warn("AdvisorInfoPopupAccess: GetText failed: " .. tostring(text))
        return ""
    end
    if text == nil then
        return ""
    end
    return tostring(text)
end

local function buildPreamble()
    local parts = {}
    local advisor = controlText(Controls.AdvisorLabel)
    if advisor ~= "" then
        parts[#parts + 1] = advisor
    end
    local body = controlText(Controls.DescriptionLabel)
    if body ~= "" then
        parts[#parts + 1] = body
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ". ")
end

local function buildItems()
    local items = {}
    if currentConceptKey == nil then
        return items
    end
    -- Related concepts. Iteration order depends on the engine's row ordering
    -- under this filter; we do not rely on it matching base's g_strConceptList
    -- because our activate calls AddToHistory + ShowConcept directly rather
    -- than indexing through ConceptSelected.
    for row in GameInfo.Concepts_RelatedConcept({ ConceptType = currentConceptKey }) do
        local relatedKey = row.RelatedConcept
        local related = GameInfo.Concepts[relatedKey]
        if related ~= nil then
            local descKey = related.Description
            items[#items + 1] = BaseMenuItems.Choice({
                textKey = descKey,
                activate = function()
                    AddToHistory(relatedKey)
                    ShowConcept(relatedKey)
                end,
            })
        end
    end
    -- "View Civilopedia page". Base ShowConcept toggles Civilopedia_List's
    -- hidden state by whether the concept has a CivilopediaPage; the Button's
    -- own isNavigable already reads IsHidden, so the extra concept-side check
    -- here is just to source the dynamic page-name label without hitting
    -- nil on concepts that have no page.
    local concept = GameInfo.Concepts[currentConceptKey]
    if concept ~= nil and concept.CivilopediaPage then
        items[#items + 1] = BaseMenuItems.Button({
            controlName = "Civilopedia_List",
            textKey = concept.CivilopediaPageText,
            activate = function()
                OnCivilopediaListClicked()
            end,
        })
    end
    -- Always: search Civilopedia (fires Events.SearchForPediaEntry).
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "Civilopedia",
        textKey = "TXT_KEY_ADVISORINFOPOPUP_CIVILOPEDIA",
        activate = function()
            OnCivilopediaClicked()
        end,
    })
    -- Always: close.
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "CloseButton",
        textKey = "TXT_KEY_CLOSE",
        activate = function()
            Close()
        end,
    })
    return items
end

local handler = BaseMenu.install(ContextPtr, {
    name = "AdvisorInfoPopup",
    -- Install-time placeholder overwritten per-concept by onConceptChanged
    -- before the first announce; the static string satisfies the spec's
    -- non-empty-string requirement at create time.
    displayName = Text.key("TXT_KEY_ADVISOR_INFORMATION"),
    preamble = buildPreamble,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    focusParkControl = "CloseButton",
    -- Empty at install; onConceptChanged fires before the first ShowHide
    -- announce (OnPopup invokes ShowConcept prior to QueuePopup), so the
    -- final item list is in place before the user hears anything.
    items = {},
    onAltLeft = function()
        if CanGoBackInHistory() then
            BackInHistory()
        else
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_ADVISOR_INFO_NO_PREV_HISTORY"))
        end
    end,
    onAltRight = function()
        -- Guard on CanGoForwardInHistory() ourselves. Base's ForwardInHistory
        -- has a defect: `if (CanGoForwardInHistory)` tests the function
        -- reference (always truthy) rather than invoking it, so an unguarded
        -- call past the end would advance g_intHistoryLoc past the list and
        -- pass nil to ShowConcept.
        if CanGoForwardInHistory() then
            ForwardInHistory()
        else
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_ADVISOR_INFO_NO_NEXT_HISTORY"))
        end
    end,
    helpExtras = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY",
        },
    },
})

local function onConceptChanged()
    handler.displayName = readTitle()
    handler.setItems(buildItems())
    if ContextPtr:IsHidden() then
        -- Pre-show: OnPopup calls ShowConcept before UIManager:QueuePopup.
        -- The subsequent ShowHide transition fresh-show-announces on its own.
        return
    end
    -- In-place concept navigation (related-concept pick, Back/Forward): no
    -- ShowHide fires, so force fresh-show announce by clearing _initialized
    -- and re-running onActivate.
    handler._initialized = false
    local ok, err = pcall(handler.onActivate)
    if not ok then
        Log.error("AdvisorInfoPopup re-announce onActivate failed: " .. tostring(err))
    end
end

-- Wrap base ShowConcept. Base defines it as a global (line 72 of
-- AdvisorInfoPopup.lua, no `local` prefix), so reassigning the global catches
-- every caller path: OnPopup initial display, ConceptSelected (related-
-- concept click), BackInHistory, ForwardInHistory.
local basePriorShowConcept = ShowConcept
function ShowConcept(strConceptKey)
    currentConceptKey = strConceptKey
    basePriorShowConcept(strConceptKey)
    onConceptChanged()
end

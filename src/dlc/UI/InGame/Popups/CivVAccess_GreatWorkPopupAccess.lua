-- GreatWorkPopup accessibility. Title holds either the great work's artist
-- (from Game.GetGreatWorkArtist) or TXT_KEY_GREAT_WORK_POPUP_WRITTEN_ARTIFACT
-- for archaeology-only works; LowerCaption holds the work's Description;
-- Quote holds the flavor quote and is hidden when the work has no quote.
-- Single Close button dismisses via OnClose.
--
-- Speech model: silentFirstOpen is conditional on whether the engine will
-- narrate the popup. Writings come with a Quote and the engine plays a
-- recorded voice clip of that quote when the popup is shown — Tolk stays
-- silent on first open so the two don't compete. Art and music popups carry
-- no Quote (only literature rows have one in CIV5GreatWorks_Expansion2.xml),
-- so first-open speaks the preamble normally. The work's name (LowerCaption)
-- is rolled into displayName via onShow so the silent-first-open path still
-- tells the user which work was completed; F1 reads artist + quote on
-- demand.
--
-- The narration check reads Controls.Quote:IsHidden() live. Base
-- ShowHideHandler calls Controls.Quote:SetHide(...) before returning, so by
-- the time silentFirstOpen evaluates inside HandlerStack.push (after our
-- wrapper's priorShowHide call), the visibility reflects the popup actually
-- being shown. An earlier version captured GreatWorkType from a listener on
-- Events.SerialEventGameMessagePopupShown; that event is fire-only (zero
-- shipped subscribers, base fires with the async bare-call form rather than
-- .CallImmediate), so the listener never reached the gate in time and the
-- preamble always spoke even with Read Subtitles off. Reading live UI state
-- is synchronous and also sidesteps the multi-great-works-same-turn race
-- since each ShowHide rewrites Controls.Quote for that specific popup.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function labelOf(name)
    local c = Controls[name]
    if c == nil or c:IsHidden() then
        return ""
    end
    local ok, text = pcall(function()
        return c:GetText()
    end)
    if not ok or text == nil then
        return ""
    end
    return tostring(text)
end

local function hasNarratedQuote()
    local c = Controls.Quote
    return c ~= nil and not c:IsHidden()
end

-- LowerCaption (work name) is in displayName, so omit it here to avoid F1
-- reading it twice.
local function preamble()
    return Text.joinNonEmpty({ labelOf("Title"), labelOf("Quote") })
end

BaseMenu.install(ContextPtr, {
    name = "GreatWorkPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"),
    preamble = preamble,
    silentFirstOpen = hasNarratedQuote,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    items = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey = "TXT_KEY_CLOSE",
            activate = function()
                OnClose()
            end,
        }),
    },
    onShow = function(h)
        local title = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP")
        local name = labelOf("LowerCaption")
        if name ~= "" then
            h.displayName = title .. ", " .. name
        else
            h.displayName = title
        end
    end,
})

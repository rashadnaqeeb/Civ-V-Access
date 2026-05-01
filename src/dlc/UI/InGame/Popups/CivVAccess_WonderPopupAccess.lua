-- WonderPopup accessibility. Title holds the wonder name, Quote the
-- flavor quote, Stats the help/bonus text (all populated by OnPopup from
-- the selected Building row). Single Close button dismisses via OnClose.
--
-- Speech model: silentFirstOpen so the engine's narrated wonder quote (a
-- voice clip the game plays as the popup appears) is not stepped on by
-- Tolk. The wonder name is rolled into displayName via onShow so the
-- first-open announce still tells the user which wonder was built. Quote
-- and stats stay in the preamble and are reachable on demand via F1.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function labelOf(name)
    local c = Controls[name]
    if c == nil or c:IsHidden() then return "" end
    local ok, text = pcall(function() return c:GetText() end)
    if not ok or text == nil then return "" end
    return tostring(text)
end

-- Title is in displayName, so omit it here to avoid F1 reading it twice.
local function preamble()
    return Text.joinNonEmpty({ labelOf("Quote"), labelOf("Stats") })
end

BaseMenu.install(ContextPtr, {
    name            = "WonderPopup",
    displayName     = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"),
    preamble        = preamble,
    silentFirstOpen = true,
    priorInput      = priorInput,
    priorShowHide   = priorShowHide,
    items           = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey     = "TXT_KEY_CLOSE",
            activate    = function() OnClose() end,
        }),
    },
    onShow          = function(h)
        local title = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP")
        local name = labelOf("Title")
        if name ~= "" then
            h.displayName = title .. ", " .. name
        else
            h.displayName = title
        end
    end,
})

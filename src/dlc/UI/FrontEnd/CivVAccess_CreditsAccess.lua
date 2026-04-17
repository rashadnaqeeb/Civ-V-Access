-- Credits accessibility wiring. Scrolling-text splash with one BackButton.
-- The visual list scrolls at a fixed rate that speech can't keep pace with,
-- so the preamble reads the credits content at announce time (parsing the
-- same \r\n-delimited blob UI.GetCredits returns, skipping spacer lines and
-- joining title / entry content with periods). Esc routes through priorInput
-- to the base OnBack; Enter is consumed by the handler's VK_RETURN binding.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

-- Line layout per base ReadCredits: position 2 is the header code
-- (N spacer, 1/2 titles, 3 heading, 4 entry), positions 1/3 are separators,
-- position 4+ is the localized content.
local function buildCreditsText()
    local raw = UI.GetCredits()
    if raw == nil or raw == "" then return nil end
    local parts = {}
    local prev  = 1
    local i     = string.find(raw, "\r\n", 1, true)
    while i ~= nil do
        local line   = string.sub(raw, prev, i - 1)
        local header = string.sub(line, 2, 2)
        if header == "1" or header == "2" or header == "3" or header == "4" then
            local content = string.sub(line, 4)
            if content ~= "" then parts[#parts + 1] = content end
        end
        prev = i + 2
        i    = string.find(raw, "\r\n", prev, true)
    end
    if #parts == 0 then return nil end
    return table.concat(parts, ". ")
end

SimpleListHandler.install(ContextPtr, {
    name          = "Credits",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CREDITS"),
    preamble      = buildCreditsText,
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items         = {},
})

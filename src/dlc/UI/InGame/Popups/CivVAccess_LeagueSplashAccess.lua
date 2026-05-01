-- LeagueSplash accessibility (World Congress founding / session splash).
-- TitleLabel is dynamic (pLeague:GetLeagueSplashTitle), DescriptionLabel
-- holds the narrative, ThisEraLabel / NextEraLabel hold era bullet lists.
-- Single Close button dismisses via OnClose.

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

local function preamble()
    return Text.joinNonEmpty({
        labelOf("TitleLabel"),
        labelOf("DescriptionLabel"),
        labelOf("ThisEraLabel"),
        labelOf("NextEraLabel"),
    })
end

BaseMenu.install(ContextPtr, {
    name          = "LeagueSplash",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"),
    preamble      = preamble,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey     = "TXT_KEY_CLOSE",
            activate    = function() OnClose() end,
        }),
    },
})

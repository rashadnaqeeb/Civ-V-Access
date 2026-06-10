-- LeagueSplash accessibility (World Congress founding / session splash).
-- TitleLabel is dynamic (pLeague:GetLeagueSplashTitle), DescriptionLabel
-- holds the narrative, ThisEraLabel / NextEraLabel hold era bullet lists.
-- Single Close button dismisses via OnClose. F2 reads a prose description
-- of the session's splash painting (see CivVAccess_CongressDescription).
-- The wonder strings are included because the United Nations session
-- resolves to the UN wonder's description string.

include("CivVAccess_PopupBoot")
include("CivVAccess_WonderDescStrings_en_US")
include("CivVAccess_CongressDescStrings_en_US")
include("CivVAccess_CongressDescription")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- The vendor file resolves the governing special session from popupInfo
-- (Data3 is the LeagueSpecialSessions row ID), but that state is
-- file-local and invisible to this wrapper. Capture the same field off
-- the same event the vendor's OnPopup subscribes to, with the same Type
-- filter. The ID is a stable handle; F2 re-queries GameInfo through it
-- at keypress time.
local capturedSessionID = nil
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_LEAGUE_SPLASH then
        return
    end
    capturedSessionID = popupInfo.Data3
end)

-- Returns LeagueSpecialSessions.Type of the session whose splash is
-- showing, else nil (nothing captured yet).
local function sessionType()
    if capturedSessionID == nil then
        return nil
    end
    local row = GameInfo.LeagueSpecialSessions[capturedSessionID]
    if row == nil then
        return nil
    end
    return row.Type
end

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

local function preamble()
    return Text.joinNonEmpty({
        labelOf("TitleLabel"),
        labelOf("DescriptionLabel"),
        labelOf("ThisEraLabel"),
        labelOf("NextEraLabel"),
    })
end

local handler = BaseMenu.install(ContextPtr, {
    name = "LeagueSplash",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"),
    preamble = preamble,
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
})

CongressDescription.bindF2(handler, sessionType)

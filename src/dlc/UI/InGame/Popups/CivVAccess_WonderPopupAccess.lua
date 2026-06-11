-- WonderPopup accessibility. Title holds the wonder name, Quote the
-- flavor quote, Stats the help/bonus text (all populated by OnPopup from
-- the selected Building row). Single Close button dismisses via OnClose.
-- F2 reads a prose description of the wonder's splash painting (see
-- CivVAccess_WonderDescription).
--
-- Speech model: silentFirstOpen so the engine's narrated wonder quote (a
-- voice clip the game plays as the popup appears) is not stepped on by
-- Tolk. The wonder name is rolled into displayName via onShow so the
-- first-open announce still tells the user which wonder was built. Quote
-- and stats stay in the preamble and are reachable on demand via F1.

include("CivVAccess_PopupBoot")
include("CivVAccess_WonderDescStrings_en_US")
include("CivVAccess_WonderDescription")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- The vendor file resolves the completed wonder from popupInfo (Data1 is
-- the Buildings row ID), but that state is file-local and invisible to
-- this wrapper. Capture the same field off the same event the vendor's
-- OnPopup subscribes to, with the same Type filter. The ID is a stable
-- handle; F2 re-queries GameInfo through it at keypress time.
local capturedBuildingID = nil
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_WONDER_COMPLETED_ACTIVE_PLAYER then
        return
    end
    capturedBuildingID = popupInfo.Data1
end)

-- Returns Buildings.Type of the completed wonder, else nil (nothing
-- captured yet).
local function wonderBuildingType()
    if capturedBuildingID == nil then
        return nil
    end
    local row = GameInfo.Buildings[capturedBuildingID]
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

-- Community Patch wraps the Stats label in a StatsScroll panel and gates
-- visibility there, leaving the label itself shown with its previous text;
-- treat Stats as empty whenever its container is hidden. Vanilla has no
-- StatsScroll control.
local function statsText()
    if Controls.StatsScroll ~= nil and Controls.StatsScroll:IsHidden() then
        return ""
    end
    return labelOf("Stats")
end

-- Title is in displayName, so omit it here to avoid F1 reading it twice.
local function preamble()
    return Text.joinNonEmpty({ labelOf("Quote"), statsText() })
end

local handler = BaseMenu.install(ContextPtr, {
    name = "WonderPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"),
    preamble = preamble,
    silentFirstOpen = true,
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
        local title = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP")
        local name = labelOf("Title")
        if name ~= "" then
            h.displayName = title .. ", " .. name
        else
            h.displayName = title
        end
    end,
})

WonderDescription.bindF2(handler, wonderBuildingType)

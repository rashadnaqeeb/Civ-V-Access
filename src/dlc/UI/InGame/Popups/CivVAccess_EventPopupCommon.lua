-- Shared scaffold for the Community Patch event popups: the player /
-- city / espionage choice pickers and the informational event popups.
-- Vox Populi only -- the Contexts are CP UI addins; nothing includes
-- this file on a vanilla install.
--
-- All the vendors share one shape: a SerialEventGameMessagePopup
-- listener gated on the Context being hidden, a TitleLabel +
-- DescriptionLabel header, and (for the choice pickers) a global
-- DisplayPopup that the vendor listener calls only when it accepts the
-- popup. Per-popup data plumbing (event tables, validity and commit
-- signatures, extra buttons) stays in each caller's buildItems.
--
-- Stem note: sibling event wrapper stems all diverge from this one
-- before either string ends (Common vs Access suffixes), so the VFS
-- stem index keeps every file; none is a strict prefix of another.

EventPopupCommon = {}

function EventPopupCommon.controlText(control)
    if control == nil then
        return nil
    end
    local ok, text = pcall(function()
        return control:GetText()
    end)
    if not ok or text == nil then
        return nil
    end
    return tostring(text)
end

-- opts:
--   contextPtr        ContextPtr of the popup's Context.
--   priorInput        vendor InputHandler captured before the install.
--   priorShowHide     vendor ShowHideHandler captured before the install.
--   handlerName       BaseMenu handler name (also the error-log prefix).
--   popupType         ButtonPopupTypes.* this listener fires on.
--   buildItems(popupInfo) -> array of menu items; pcalled by the
--                     listener and forwarded via setItems.
--   gateOnDisplayPopup  when true, wrap the vendor's global DisplayPopup
--                     as the accept signal. The vendor OnPopup calls it
--                     only when the Context was hidden; our listener
--                     runs after the vendor's in the same dispatch and
--                     cannot see that local gate directly. Without the
--                     signal, a popup arriving while the screen is open
--                     would rebuild items for an event the vendor is
--                     not showing.
--
-- The handler announces the live event title (TitleLabel, with any
-- modmod override the vendor applied) as its display name on every
-- show; DescriptionLabel is the preamble. Returns the mainHandler.
function EventPopupCommon.install(opts)
    local mainHandler = BaseMenu.install(opts.contextPtr, {
        name = opts.handlerName,
        -- Install-time placeholder; onShow writes the live title.
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_EVENT"),
        preamble = function()
            return EventPopupCommon.controlText(Controls.DescriptionLabel)
        end,
        priorInput = opts.priorInput,
        priorShowHide = opts.priorShowHide,
        deferActivate = true,
        onShow = function(h)
            local title = EventPopupCommon.controlText(Controls.TitleLabel)
            if title ~= nil and title ~= "" then
                h.displayName = title
            end
        end,
        items = {},
    })

    local vendorAccepted = not opts.gateOnDisplayPopup
    if opts.gateOnDisplayPopup then
        local priorDisplayPopup = DisplayPopup
        DisplayPopup = function(...)
            vendorAccepted = true
            return priorDisplayPopup(...)
        end
    end

    Events.SerialEventGameMessagePopup.Add(function(popupInfo)
        if popupInfo.Type ~= opts.popupType then
            return
        end
        if not vendorAccepted then
            return
        end
        if opts.gateOnDisplayPopup then
            vendorAccepted = false
        end
        local ok, items = pcall(opts.buildItems, popupInfo)
        if not ok then
            Log.error(opts.handlerName .. " buildItems failed: " .. tostring(items))
            return
        end
        mainHandler.setItems(items)
    end)
    return mainHandler
end

return EventPopupCommon

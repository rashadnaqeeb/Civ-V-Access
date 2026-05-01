-- Shared scaffold for the four "Choose<X>" popups (FreeItem, GoodyHutReward,
-- FaithGreatPerson, MayaBonus). All four mirror base PopulateItems /
-- CommitItems / SelectedItems flows: build a row per eligible option with a
-- selectedFn / activate that updates SelectedItems, plus a trailing Confirm
-- Button. Differences are popup-shaped (eligibility predicate, source
-- table, key type, commit key, close mechanism) and stay in each caller's
-- buildItems. This module factors the parts that are identical:
--
--   - selectionStub           SelectedItems[1][2] needs a SelectionAnim
--                             stub so a stray mouse click on a row while our
--                             sub-handler is active doesn't throw.
--   - preambleText            Read-only TitleLabel + DescriptionLabel join.
--   - install                 BaseMenu.install spec + the
--                             SerialEventGameMessagePopup listener that
--                             dispatches by popupType, pcalls buildItems,
--                             and forwards items to mainHandler.setItems.
--
-- Each Choose* wrapper passes its popupType / handlerName / displayKey /
-- buildItems and gets back the mainHandler. Per-popup specifics
-- (CommitItems[...], close via OnClose vs SetHide, eligibility) live in
-- the wrapper's buildItems closure.

ChoosePopupCommon = {}

-- SelectedItems entries have shape {key, controlTable}. Base's click
-- handler indexes v[2].SelectionAnim on re-selection, so this stub keeps
-- the mirror robust against a stray click while we're in our sub-handler.
function ChoosePopupCommon.selectionStub()
    return { SelectionAnim = { SetHide = function() end } }
end

-- Read TitleLabel + DescriptionLabel via the live engine controls, joined
-- with ", ". Returns "" when both are empty so callers can announce the
-- popup body even before our buildItems has run.
function ChoosePopupCommon.preambleText()
    local parts = {}
    local t = Controls.TitleLabel and Controls.TitleLabel:GetText() or ""
    if t ~= "" then
        parts[#parts + 1] = t
    end
    local d = Controls.DescriptionLabel and Controls.DescriptionLabel:GetText() or ""
    if d ~= "" then
        parts[#parts + 1] = d
    end
    return table.concat(parts, ", ")
end

-- opts:
--   contextPtr      ContextPtr of the popup's Context.
--   priorInput      base file's InputHandler captured before the install.
--   priorShowHide   base file's ShowHideHandler captured before the install.
--   handlerName     name for the BaseMenu handler (also used in error logs).
--   displayKey      TXT_KEY for the handler's display name.
--   popupType       ButtonPopupTypes.* this listener should fire on.
--   buildItems(popupInfo) -> array of menu items. Caller's per-popup logic;
--                   the listener pcalls it and forwards via setItems.
--
-- Returns the mainHandler (so callers can keep a reference if they need
-- one beyond the listener flow).
function ChoosePopupCommon.install(opts)
    local mainHandler = BaseMenu.install(opts.contextPtr, {
        name = opts.handlerName,
        displayName = Text.key(opts.displayKey),
        preamble = ChoosePopupCommon.preambleText,
        priorInput = opts.priorInput,
        priorShowHide = opts.priorShowHide,
        deferActivate = true,
        items = {},
    })
    Events.SerialEventGameMessagePopup.Add(function(popupInfo)
        if popupInfo.Type ~= opts.popupType then
            return
        end
        local ok, items = pcall(opts.buildItems, popupInfo)
        if not ok then
            Log.error(opts.handlerName .. "Access buildItems failed: " .. tostring(items))
            return
        end
        mainHandler.setItems(items)
    end)
    return mainHandler
end

return ChoosePopupCommon

-- DiploCurrentDeals accessibility. The Deals tab of DiploOverview; lists
-- active and historical deals the player is party to. Each deal
-- renders as a single Text leaf whose label inlines the full contents
-- (other civ, what we give, what they give) with per-item duration where
-- the item carries one. There's no drill past the deal, no Your / Their
-- offer drawer, and no scratch-deal mutation outside build time -- review
-- is read-only and the trade-screen drawer pattern only earns its keep
-- when the user is composing or modifying an offer.
--
-- The picker list is stable while the popup is open, so one build at
-- onShow is enough; building loads each deal into the engine's scratch
-- slot to read its items and clears the slot afterwards so it doesn't
-- leak loaded state into other consumers.

include("CivVAccess_PopupBoot")
include("CivVAccess_DiploCommon")
-- Read-only per-deal label rendering, shared with the Espionage diplomat
-- trade-deals view.
include("CivVAccess_DealLabelShared")

-- Tab / Shift+Tab both cycle to the Relations Context, which now hosts
-- a TabbedShell with Majors and Minors sub-tabs. Forward Tab lands on
-- Majors (the conceptual "next" after Deals); Shift+Tab lands on Minors
-- (the conceptual "previous"). The bridge stages the landing index on
-- civvaccess_shared.DiploOverview.relationsLanding and the shell's
-- onShow consumes it. See CivVAccess_DiploOverviewBridge for the
-- cross-Context mechanism; the sibling panel's visibility flip fires
-- ShowHide on both panels, which pops our BaseMenu and pushes the
-- sibling's.
local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local RELATIONS_TAB_MAJORS = 1
local RELATIONS_TAB_MINORS = 2

local function buildDealItems(iPlayer, isCurrent, count)
    local items = {}
    for i = 0, count - 1 do
        if isCurrent then
            UI.LoadCurrentDeal(iPlayer, i)
        else
            UI.LoadHistoricDeal(iPlayer, i)
        end
        -- Snapshot the deal's clauses now, while the scratch slot holds this
        -- deal: the loop reloads the slot each iteration, so a deferred read
        -- would see the wrong deal. The list is stable while the popup is
        -- open (see file header), so a build-time snapshot is current.
        local parts, pediaName = DealLabel.buildDealParts(iPlayer, UI.GetScratchDeal(), not isCurrent)
        items[#items + 1] = BaseMenuItems.Text({
            labelText = table.concat(parts, ". "),
            sectionsFn = function()
                return parts
            end,
            pediaName = pediaName,
        })
    end
    return items
end

local function buildItems()
    local iPlayer = Game.GetActivePlayer()
    local items = {}

    local nCurrent = UI.GetNumCurrentDeals(iPlayer) or 0
    if nCurrent > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_DO_CURRENT_DEALS"),
            items = buildDealItems(iPlayer, true, nCurrent),
        })
    end

    local nHistoric = UI.GetNumHistoricDeals(iPlayer) or 0
    if nHistoric > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"),
            items = buildDealItems(iPlayer, false, nHistoric),
        })
    end

    if nCurrent == 0 and nHistoric == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"),
        })
    end

    -- buildDealItems left the scratch deal holding the last iterated deal.
    -- Clear so it doesn't leak loaded state into other consumers reading
    -- UI.GetScratchDeal later.
    UI.GetScratchDeal():ClearItems()

    return items
end

BaseMenu.install(ContextPtr, {
    name = "DiploCurrentDeals",
    displayName = Text.key("TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    shouldActivate = DiploCommon.shouldActivate,
    onShow = function(h)
        h.setItems(buildItems())
    end,
    items = {},
    onTab = function()
        civvaccess_shared.DiploOverview.showRelations(RELATIONS_TAB_MAJORS)
    end,
    onShiftTab = function()
        civvaccess_shared.DiploOverview.showRelations(RELATIONS_TAB_MINORS)
    end,
    onEscape = function()
        civvaccess_shared.DiploOverview.close()
        return true
    end,
    suppressReactivateOnHide = function()
        return civvaccess_shared.DiploOverview._switching == true
    end,
})

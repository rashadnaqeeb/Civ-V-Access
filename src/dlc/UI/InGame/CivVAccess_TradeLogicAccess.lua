-- Diplomacy trade screen accessibility orchestrator. Loaded via include
-- from three Context wrappers (AI DiploTrade, PvP SimpleDiploTrade,
-- review DiploCurrentDeals); each Context calls TradeLogicAccess.install
-- with a descriptor naming the kind, preamble, and any Context-specific
-- top-items override.
--
-- The screen has a flat top-level BaseMenu with up to six items
-- (Your Offer, Their Offer, an AI query slot, Propose, Cancel, Modify).
-- Activating Your / Their Offer pushes a drawer -- a tabbed BaseMenu with
-- Offering (items currently on the table) and Available (items that
-- could be placed). Read-only states (AI demand / request / offer, or
-- g_bTradeReview) push a flat Offering-only drawer instead.
--
-- The Offering and Available item builders live in two sibling files:
--   CivVAccess_TradeLogicOffering.lua  -> TradeLogicOffering.buildOfferingItems
--   CivVAccess_TradeLogicAvailable.lua -> TradeLogicAvailable.buildAvailableItems
-- Both are included from this orchestrator so that whichever Context
-- pulls in CivVAccess_TradeLogicAccess gets the full split transparently.
-- The shared per-side helpers (prefix, sidePlayer, sideIsUs, turnsSuffix,
-- pocketTooltipFn, dealDuration, peaceDuration, afterLocalDealChange,
-- emptyPlaceholder, clearEngineTable) are exposed on the TradeLogicAccess
-- table so the sub-modules can call them at item-build time.
--
-- Reads of TradeLogic state rely on eight g_* names we promoted to globals
-- in our shipped TradeLogic.lua override (g_Deal, g_iUs, g_iThem,
-- g_iDiploUIState, g_bTradeReview, g_LeagueVoteList, g_UsTableResources,
-- g_ThemTableResources). The base file declares them `local` at chunk
-- scope, which Lua 5.1 hides from the next included chunk -- so without
-- the promotion, every read here would see nil and every build* function
-- would return its empty-placeholder path.
--
-- Rebuild triggers: any state change that could flip an item's visibility
-- or label (AI responded, remote PvP peer proposed/withdrew, active player
-- changed, deal wiped). Listeners register fresh on every Context include
-- per CLAUDE.md's no-install-once-guards rule -- dead listeners from a
-- prior game throw harmlessly on first global access under the engine's
-- per-listener pcall.

include("CivVAccess_TradeLogicOffering")
include("CivVAccess_TradeLogicAvailable")

TradeLogicAccess = {}

local DRAWER_NAME = "DiploTrade/Drawer"

-- Single upvalue per Context for the top handler and the open drawer, if
-- any. _handler is set in onShow and nilled in onDeactivate; _drawerHandler
-- is set when the drawer is pushed and nilled in its onDeactivate. The
-- rebuild closure is a module-scope fn; its closures over these upvalues
-- re-resolve on each rebuild call.
local _handler = nil
local _drawerHandler = nil
local _descriptor = nil

-- Shared helpers ----------------------------------------------------------

-- TradeLogic's g_iDealDuration / g_iPeaceDuration are file-locals, not
-- globals; we can't reach them from our own file. Re-query the engine each
-- time the values are needed.
local function dealDuration()
    return (Game and Game.GetDealDuration and Game.GetDealDuration()) or 30
end

local function peaceDuration()
    return (GameDefines and GameDefines.PEACE_TREATY_LENGTH)
        or (Game and Game.GetPeaceDuration and Game.GetPeaceDuration())
        or 10
end

-- Per-item duration suffix for labels. Returns "" when the item has no
-- meaningful duration (lump gold, cities, third-party, vote, instant)
-- so the caller can append unconditionally. Game speed sets the value
-- once per session; we re-query each call rather than caching so a
-- mid-session save-load with a different speed (engine prevents this in
-- practice, but cheap insurance) doesn't read a stale number.
local function turnsSuffix(duration)
    if duration == nil or duration <= 0 then
        return ""
    end
    return ", " .. Text.format("TXT_KEY_DIPLO_TURNS", duration)
end

-- State classification ----------------------------------------------------

-- Read-only: the user can browse but not place / remove. AI is demanding
-- or proposing, or we're reviewing a historical deal. Checked live on each
-- rebuild -- DIPLO_UI_STATE can flip as AILeaderMessage fires.
local function isReadOnly()
    if g_bTradeReview then
        return true
    end
    if g_iDiploUIState == nil or DiploUIStateTypes == nil then
        return false
    end
    local s = g_iDiploUIState
    return s == DiploUIStateTypes.DIPLO_UI_STATE_TRADE_AI_MAKES_DEMAND
        or s == DiploUIStateTypes.DIPLO_UI_STATE_TRADE_AI_MAKES_REQUEST
        or s == DiploUIStateTypes.DIPLO_UI_STATE_TRADE_AI_MAKES_OFFER
end

-- HUMAN_DEMAND: human demanding from AI. Engine hides UsPanel / UsGlass;
-- we mirror by omitting "Your Offer" from the flat list.
local function isHumanDemand()
    if g_iDiploUIState == nil or DiploUIStateTypes == nil then
        return false
    end
    return g_iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_HUMAN_DEMAND
end

local function sidePlayer(side)
    if side == "us" then
        return g_iUs
    end
    return g_iThem
end

local function sideIsUs(side)
    return side == "us"
end

-- Control-name helpers. Pocket / Table / Panel controls are prefixed "Us"
-- or "Them" uniformly, so a sided caller passes "us" / "them" and we
-- interpolate. Luxury / Strategic / Vote resource instance tables share the
-- same convention (g_UsTableResources vs g_ThemTableResources).
local function prefix(side)
    return sideIsUs(side) and "Us" or "Them"
end

-- Closure over a base-game control name that returns its current
-- SetToolTipString live. Used as `tooltipFn` on items whose engine
-- counterpart owns a contextual tooltip the user should hear (disabled
-- reason, descriptive copy, cost / duration text). Returns nil when the
-- control or its tooltip is missing so appendTooltip skips silently.
local function pocketTooltipFn(controlName)
    return function()
        local c = Controls[controlName]
        if c == nil then
            return nil
        end
        return c:GetToolTipString()
    end
end

-- DoClearTable mirrors the engine's own post-remove repaint; called after
-- every mutation that removes a placed item so the engine's InstanceManager
-- rows drop their contents before DisplayDeal rebuilds them.
local function clearEngineTable()
    if type(DoClearTable) ~= "function" then
        return
    end
    local ok, err = pcall(DoClearTable)
    if not ok then
        Log.error("TradeLogicAccess DoClearTable failed: " .. tostring(err))
    end
end

-- Placeholder Text item appended when a drawer tab would otherwise be
-- empty. Without it, BaseMenu's tab-switch / first-open announce skips
-- silently on zero items, leaving the user unsure whether the tab is
-- empty or the handler is broken.
local function emptyPlaceholder(textKey)
    return BaseMenuItems.Text({ labelText = Text.key(textKey) })
end

-- Drawer rebuild trigger. Called from onCommit / onRemove after a
-- g_Deal:Add* or Remove* mutation completes, and from the module's top-
-- level rebuild() on external events. Idempotent: no-op if the drawer is
-- not currently pushed.
local function rebuildDrawer()
    if _drawerHandler == nil then
        return
    end
    local found = false
    for i = 1, HandlerStack.count() do
        if HandlerStack.at(i) == _drawerHandler then
            found = true
            break
        end
    end
    if not found then
        _drawerHandler = nil
        return
    end
    local side = _drawerHandler._civvaccess_side
    if side == nil then
        return
    end
    local readOnly = isReadOnly()
    if _drawerHandler.tabs ~= nil then
        -- Editable: two tabs. Rebuild both so the user's cursor position is
        -- preserved on the active tab and the inactive tab is fresh on
        -- next visit.
        _drawerHandler.setItems(TradeLogicOffering.buildOfferingItems(side, false), 1)
        _drawerHandler.setItems(TradeLogicAvailable.buildAvailableItems(side), 2)
    else
        _drawerHandler.setItems(TradeLogicOffering.buildOfferingItems(side, readOnly))
    end
end

-- Fire after a local-side placement / removal. DoUIDealChangedByHuman
-- updates engine button labels; DisplayDeal repaints the game's own table
-- rows. Both run the same work the mouse-click handlers do.
local function afterLocalDealChange()
    if type(DisplayDeal) == "function" then
        local ok, err = pcall(DisplayDeal)
        if not ok then
            Log.error("TradeLogicAccess DisplayDeal failed: " .. tostring(err))
        end
    end
    if type(DoUIDealChangedByHuman) == "function" then
        local ok, err = pcall(DoUIDealChangedByHuman)
        if not ok then
            Log.error("TradeLogicAccess DoUIDealChangedByHuman failed: " .. tostring(err))
        end
    end
    TradeLogicAccess.rebuild()
end

-- Expose shared helpers so the sub-modules (TradeLogicOffering /
-- TradeLogicAvailable) can call them at item-build time. These were
-- file-locals in the pre-split file; promoting them to TradeLogicAccess
-- members is the smallest change that lets the split work without
-- duplicating the helper bodies into each sub-module.
TradeLogicAccess.dealDuration = dealDuration
TradeLogicAccess.peaceDuration = peaceDuration
TradeLogicAccess.turnsSuffix = turnsSuffix
TradeLogicAccess.isReadOnly = isReadOnly
TradeLogicAccess.isHumanDemand = isHumanDemand
TradeLogicAccess.sidePlayer = sidePlayer
TradeLogicAccess.sideIsUs = sideIsUs
TradeLogicAccess.prefix = prefix
TradeLogicAccess.pocketTooltipFn = pocketTooltipFn
TradeLogicAccess.clearEngineTable = clearEngineTable
TradeLogicAccess.emptyPlaceholder = emptyPlaceholder
TradeLogicAccess.afterLocalDealChange = afterLocalDealChange

-- Re-exports so any caller that previously reached for
-- TradeLogicAccess.buildOfferingItems / buildAvailableItems still works.
TradeLogicAccess.buildOfferingItems = TradeLogicOffering.buildOfferingItems
TradeLogicAccess.buildAvailableItems = TradeLogicAvailable.buildAvailableItems

-- Drawer push -------------------------------------------------------------

local function pushDrawer(side)
    local readOnly = isReadOnly()
    local label = sideIsUs(side) and Text.key("TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER")
        or Text.key("TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER")
    local spec
    if readOnly then
        spec = {
            name = DRAWER_NAME,
            displayName = label,
            escapePops = true,
            items = TradeLogicOffering.buildOfferingItems(side, true),
        }
    else
        spec = {
            name = DRAWER_NAME,
            displayName = label,
            escapePops = true,
            tabs = {
                {
                    name = "TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING",
                    items = TradeLogicOffering.buildOfferingItems(side, false),
                },
                {
                    name = "TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE",
                    items = TradeLogicAvailable.buildAvailableItems(side),
                },
            },
        }
    end
    local drawer = BaseMenu.create(spec)
    drawer._civvaccess_side = side
    local priorDeactivate = drawer.onDeactivate
    drawer.onDeactivate = function()
        if type(priorDeactivate) == "function" then
            pcall(priorDeactivate)
        end
        _drawerHandler = nil
    end
    _drawerHandler = drawer
    HandlerStack.push(drawer)
end

-- Top-level items ---------------------------------------------------------

-- Your / Their Offer items, exported so Contexts whose top-level list is
-- not "pocket + action buttons" (DiploCurrentDeals: deal picker + drawer
-- entries) can compose them into their own topItemsFn. useVisibilityControl
-- gates the item on Us/ThemPanel -- DiploTrade and SimpleDiploTrade have
-- those controls, DiploCurrentDeals does not.
function TradeLogicAccess.buildYourOfferItem(useVisibilityControl)
    local spec = {
        labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"),
        activate = function()
            pushDrawer("us")
        end,
    }
    if useVisibilityControl then
        spec.visibilityControlName = "UsPanel"
    end
    return BaseMenuItems.Choice(spec)
end

function TradeLogicAccess.buildTheirOfferItem(useVisibilityControl)
    local spec = {
        labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"),
        activate = function()
            pushDrawer("them")
        end,
    }
    if useVisibilityControl then
        spec.visibilityControlName = "ThemPanel"
    end
    return BaseMenuItems.Choice(spec)
end

-- Action-button leaf for the trade screen's bottom row (Propose / Cancel /
-- Modify / What*-query). Surfaces hidden or disabled buttons as "<label>,
-- disabled" Text leaves rather than dropping them from navigation, so the
-- user can find the buttons even when the engine has greyed them out --
-- a hidden button is functionally a disabled one for our purposes. The
-- disabled leaf carries the engine's live tooltip via tooltipFn so the
-- reason auto-announces alongside the label. fallbackLabel fills in
-- when the engine never set the button's text (e.g. a query button
-- that's never been shown this session).
local function actionButtonLeaf(controlName, activate, fallbackLabel)
    local control = Controls[controlName]
    if control == nil then
        return nil
    end
    local hidOk, hidden = pcall(function()
        return control:IsHidden()
    end)
    local disOk, disabled = pcall(function()
        return control:IsDisabled()
    end)
    local inactive = (hidOk and hidden) or (disOk and disabled)
    if inactive then
        local label = ""
        local okT, t = pcall(function()
            return control:GetText()
        end)
        if okT and t ~= nil then
            label = tostring(t)
        end
        if label == "" then
            label = fallbackLabel or controlName
        end
        return BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_CIVVACCESS_LABEL_DISABLED", label),
            tooltipFn = pocketTooltipFn(controlName),
        })
    end
    return BaseMenuItems.Button({
        controlName = controlName,
        labelFn = function(c)
            return c:GetText()
        end,
        tooltipFn = function(c)
            return c:GetToolTipString()
        end,
        activate = activate,
    })
end

local function buildTopItems(descriptor)
    local items = {}

    -- Gate "Your Offer" / "Their Offer" on Us/ThemPanel visibility only when
    -- the screen is editable. In AI_MAKES_DEMAND / AI_MAKES_REQUEST the
    -- engine's DoDemandState(true) hides UsPanel, UsGlass, ThemPanel, and
    -- ThemGlass and overlays TableCover -- the layout becomes a
    -- non-interactive readout for sighted users. The deal still lives in
    -- g_Deal, though, and a screen-reader user has no other way to hear
    -- what's being asked. Skip the gate in any read-only AI state so the
    -- drawers stay reachable; pushDrawer's read-only branch builds the
    -- Offering-only flat list (no Available tab), which is the right
    -- surface for inspect-but-don't-modify. AI_MAKES_OFFER doesn't hide
    -- the panels (bDemandOn is false there), so the gate would be a no-op
    -- regardless -- folding it in keeps the rule "editable: gate, read-
    -- only: ungate" simple. Editable-Human-Demand still drops Your Offer
    -- via the explicit isHumanDemand() check below.
    local gateOnPanel = not isReadOnly()

    if not isHumanDemand() then
        items[#items + 1] = TradeLogicAccess.buildYourOfferItem(gateOnPanel)
    end

    items[#items + 1] = TradeLogicAccess.buildTheirOfferItem(gateOnPanel)

    -- AI query buttons: in AI Context only. Engine hides 4 of 5 at any
    -- given time and the absent ones aren't useful in their inactive state
    -- (WhatWillEndThisWar at peace, WhatConcessions when not requesting,
    -- etc.), so we use plain Button items whose isNavigable hides them
    -- when the engine does -- only the relevant query for the current
    -- state shows up.
    if descriptor.kind == "AI" then
        local queries = {
            { name = "WhatDoYouWantButton", activate = OnWhatDoesAIWant },
            { name = "WhatWillYouGiveMeButton", activate = OnWhatWillAIGive },
            { name = "WhatWillMakeThisWorkButton", activate = OnEqualizeDeal },
            { name = "WhatWillEndThisWarButton", activate = OnEqualizeDeal },
            { name = "WhatConcessionsButton", activate = OnEqualizeDeal },
        }
        for _, q in ipairs(queries) do
            if Controls[q.name] ~= nil and type(q.activate) == "function" then
                items[#items + 1] = BaseMenuItems.Button({
                    controlName = q.name,
                    labelFn = function(c)
                        return c:GetText()
                    end,
                    tooltipFn = function(c)
                        return c:GetToolTipString()
                    end,
                    activate = q.activate,
                })
            end
        end
    end

    -- Propose. Base TradeLogic registers OnPropose on ProposeButton and
    -- relies on Void1 (PROPOSE_TYPE / WITHDRAW_TYPE / ACCEPT_TYPE) to pick
    -- the path; DoUpdateButtons sets the right Void1 per state. Read it
    -- live so a "Propose" press in TRADE, "Demand" in HUMAN_DEMAND, and
    -- "Accept" in TRADE_AI_MAKES_OFFER all dispatch correctly through the
    -- engine's own callback.
    if Controls.ProposeButton ~= nil and type(OnPropose) == "function" then
        local item = actionButtonLeaf("ProposeButton", function()
            local okV, void1 = pcall(function()
                return Controls.ProposeButton:GetVoid1()
            end)
            OnPropose((okV and void1) or 0)
        end, Text.key("TXT_KEY_DIPLO_PROPOSE"))
        if item ~= nil then
            items[#items + 1] = item
        end
    end

    -- Cancel / Refuse. Same Void1 pattern (CANCEL_TYPE vs REFUSE_TYPE).
    if Controls.CancelButton ~= nil and type(OnBack) == "function" then
        local item = actionButtonLeaf("CancelButton", function()
            local okV, void1 = pcall(function()
                return Controls.CancelButton:GetVoid1()
            end)
            OnBack((okV and void1) or 0)
        end, Text.key("TXT_KEY_DIPLO_CANCEL"))
        if item ~= nil then
            items[#items + 1] = item
        end
    end

    -- Modify (PvP only; control is nil in AI / Review so factory returns nil).
    if Controls.ModifyButton ~= nil and type(OnModify) == "function" then
        local item = actionButtonLeaf("ModifyButton", OnModify, Text.key("TXT_KEY_DIPLO_MODIFY"))
        if item ~= nil then
            items[#items + 1] = item
        end
    end

    return items
end

-- Rebuild + install -------------------------------------------------------

-- Resolve the top-items builder for a descriptor. Contexts whose top level
-- is not the standard pocket+action list (DiploCurrentDeals: deal picker +
-- drawer entries) supply descriptor.topItemsFn to replace the default.
local function effectiveTopItems(descriptor)
    if type(descriptor.topItemsFn) == "function" then
        local ok, result = pcall(descriptor.topItemsFn, descriptor)
        if not ok then
            Log.error("TradeLogicAccess topItemsFn failed: " .. tostring(result))
            return {}
        end
        return result or {}
    end
    return buildTopItems(descriptor)
end

function TradeLogicAccess.rebuild()
    if _handler == nil or _descriptor == nil then
        return
    end
    _handler.setItems(effectiveTopItems(_descriptor))
    rebuildDrawer()
    _handler.refresh()
end

function TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, descriptor)
    _descriptor = descriptor

    local handler = BaseMenu.install(ContextPtr, {
        name = descriptor.name,
        displayName = descriptor.fallbackDisplayName or Text.key("TXT_KEY_CIVVACCESS_SCREEN_TRADE"),
        preamble = descriptor.preambleFn,
        silentFirstOpen = descriptor.silentFirstOpen,
        deferActivate = descriptor.deferActivate,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onTab = descriptor.onTab,
        onShiftTab = descriptor.onShiftTab,
        onEscape = descriptor.onEscape,
        suppressReactivateOnHide = descriptor.suppressReactivateOnHide,
        onShow = function(h)
            _handler = h
            _drawerHandler = nil
            if type(descriptor.displayNameFn) == "function" then
                local ok, name = pcall(descriptor.displayNameFn)
                if ok and name ~= nil and name ~= "" then
                    h.displayName = tostring(name)
                end
            end
            h.setItems(effectiveTopItems(descriptor))
        end,
        items = {},
    })

    -- Wrap onDeactivate to clear the module upvalues when the Context
    -- hides. BaseMenu.install's ShowHide handler fires onDeactivate via
    -- removeByName before it un-sets _initialized.
    local priorDeactivate = handler.onDeactivate
    handler.onDeactivate = function()
        if type(priorDeactivate) == "function" then
            pcall(priorDeactivate)
        end
        _handler = nil
        _drawerHandler = nil
    end

    -- Register rebuild listeners. Fresh on every Context include per
    -- CLAUDE.md's no-install-once rule. Dead listeners from a prior game
    -- throw on first access under the engine's per-listener pcall; the
    -- newest live listener still fires.
    --
    -- Skipped for DiploCurrentDeals (descriptor.skipStandardListeners):
    -- none of these events apply to a deal-review session. Rebuild there
    -- fires only from the deal-picker's own onActivate.
    if not descriptor.skipStandardListeners then
        local function rebuildIfLive()
            TradeLogicAccess.rebuild()
        end
        if descriptor.kind == "AI" and Events.AILeaderMessage ~= nil then
            Events.AILeaderMessage.Add(rebuildIfLive)
        end
        if LuaEvents.OpenAILeaderDiploTrade ~= nil then
            LuaEvents.OpenAILeaderDiploTrade.Add(rebuildIfLive)
        end
        if LuaEvents.OpenSimpleDiploTrade ~= nil then
            LuaEvents.OpenSimpleDiploTrade.Add(rebuildIfLive)
        end
        if Events.ClearDiplomacyTradeTable ~= nil then
            Events.ClearDiplomacyTradeTable.Add(rebuildIfLive)
        end
        if Events.OpenPlayerDealScreenEvent ~= nil then
            Events.OpenPlayerDealScreenEvent.Add(rebuildIfLive)
        end
        if Events.GameplaySetActivePlayer ~= nil then
            Events.GameplaySetActivePlayer.Add(rebuildIfLive)
        end
    end

    return handler
end

return TradeLogicAccess

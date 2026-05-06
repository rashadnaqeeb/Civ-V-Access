-- ReplayViewer accessibility, front-end Load Replay path.
--
-- Same Lua file backs two Contexts: this one (a popup queued from
-- LoadReplayMenu after the user picks a replay file) and the EndGameReplay
-- LuaContext nested inside EndGameMenu. Vanilla's `if not g_bIsEndGame`
-- guards make this Context the popup root with its own InputHandler;
-- the end-game one stays input-less and the parent EndGameMenu owns
-- input. We mirror that split: install BaseMenu only at the front-end,
-- and let EndGameMenuAccess's Replay tab cover the end-game path
-- separately (different env, different items source -- it pulls from
-- Game.GetReplayMessages() rather than g_ReplayInfo).
--
-- Layout: a panel pulldown wrapping vanilla's ReplayInfoPulldown
-- (Messages / Graphs / Map), per-turn drillable groups of messages when
-- the pulldown is on Messages, then the Back button. Each group's label
-- is "Turn N" and its children are the non-empty Text entries that
-- emitted on that turn, with the turn prefix dropped since the group
-- label provides it. Mirrors EndGameMenu's Replay tab. Graphs and Map
-- render blank for now; the visual graph and animated culture map don't
-- reduce to readable text in any obvious way and are deferred. The
-- pulldown itself stays so the user sees the same panel-selection
-- affordance sighted players have, and so the structure is in place
-- when Graphs gets a summarizer.
--
-- Items rebuild from g_ReplayInfo.Messages, populated by vanilla's
-- LuaEvents.ReplayViewer_LoadReplay listener. We register an additional
-- listener after that one (Civ V LuaEvents .Add chains, vanilla's runs
-- first in registration order) so by the time our rebuild fires, the
-- engine has loaded the file and refreshed g_ReplayInfo. setItems +
-- refresh announces the first message to confirm load completed.
--
-- Esc / Enter on unbound keys fall through priorInput to vanilla's
-- InputHandler -> OnBack(), which dequeues the popup. BaseMenu has no
-- escapePops binding so the chain works.

if g_bIsEndGame then
    return
end

include("CivVAccess_FrontendCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local m_handler = nil

local function buildItems()
    local items = {
        BaseMenuItems.Pulldown({
            controlName = "ReplayInfoPulldown",
            textKey = "TXT_KEY_CIVVACCESS_REPLAY_PANEL_LABEL",
            onSelected = function()
                -- Vanilla's per-entry button callback ran SetCurrentPanel
                -- before us; CurrentPanelIndex is now set.
                if m_handler ~= nil then
                    m_handler.setItems(buildItems())
                    m_handler.refresh()
                end
            end,
        }),
    }
    -- CurrentPanelIndex: 1 = Messages, 2 = Graphs, 3 = Map (the order
    -- vanilla iterates Panels[]). Only Messages gets a populated body;
    -- Graphs and Map are intentionally blank. Messages are grouped by
    -- turn into drillables; engine emission order is chronological so a
    -- single forward pass with flush-on-turn-change builds the groups.
    if CurrentPanelIndex == 1 and g_ReplayInfo ~= nil and g_ReplayInfo.Messages ~= nil then
        local currentTurn = nil
        local currentTexts = nil
        local function flush()
            if currentTexts == nil or #currentTexts == 0 then
                return
            end
            local subItems = {}
            for _, t in ipairs(currentTexts) do
                subItems[#subItems + 1] = BaseMenuItems.Text({ labelText = t })
            end
            items[#items + 1] = BaseMenuItems.Group({
                labelText = Text.format("TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP", currentTurn),
                items = subItems,
            })
        end
        for _, m in ipairs(g_ReplayInfo.Messages) do
            if m.Text ~= nil and m.Text ~= "" then
                if m.Turn ~= currentTurn then
                    flush()
                    currentTurn = m.Turn
                    currentTexts = {}
                end
                currentTexts[#currentTexts + 1] = m.Text
            end
        end
        flush()
    end
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "BackButton",
        textKey = "TXT_KEY_BACK_BUTTON",
        activate = function()
            OnBack()
        end,
    })
    return items
end

LuaEvents.ReplayViewer_LoadReplay.Add(function()
    if m_handler == nil then
        return
    end
    m_handler.setItems(buildItems())
    if not ContextPtr:IsHidden() then
        m_handler.refresh()
    end
end)

m_handler = BaseMenu.install(ContextPtr, {
    name = "ReplayViewer",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_REPLAY_VIEWER"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    items = buildItems(),
})

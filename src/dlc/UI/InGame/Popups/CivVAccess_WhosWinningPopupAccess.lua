-- WhosWinningPopup accessibility. BUTTONPOPUP_WHOS_WINNING fires on the
-- engine's own schedule (no hotkey, no menu entry) with one randomly-chosen
-- ranking metric. Distinct from the F8 VictoryProgress screen, which is
-- the persistent victory-conditions advisor.
--
-- Header speech is the engine's three live labels in order: the framing
-- "<random historian> presents the list of:" line, the metric name, and
-- the metric's tooltip definition. All three change per-popup, so the
-- preamble is a function so F1 / refresh re-reads the latest. Tooltip is
-- read back via :GetToolTipString() rather than reaching into the base
-- file's locals (g_iListMode / g_tListModeText are local to that chunk
-- and unreachable from this include).
--
-- Capture strategy: monkey-patch base AddPlayerEntry / AddCityEntry so we
-- ride the same sorted iteration the base does (table.sort by score
-- descending). iRank == 1 marks the start of a fresh popup so we reset
-- captured state and remember which mode (player vs city) populated it.
-- Tourism mode populates city entries (owner identification added because
-- sighted users see the leader portrait next to the city name); every
-- other mode populates player entries. Pedia hookup (Ctrl+I) routes to
-- the entry's leader article; unmet-civ rows skip the hookup since the
-- placeholder name has no pedia target.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local capturedEntries = {}
local capturedKind = nil

local baseAddPlayerEntry = AddPlayerEntry
AddPlayerEntry = function(iPlayerID, iScore, iRank)
    baseAddPlayerEntry(iPlayerID, iScore, iRank)
    if iRank == 1 then
        capturedEntries = {}
        capturedKind = "player"
    end
    capturedEntries[#capturedEntries + 1] = {
        iPlayerID = iPlayerID,
        iScore    = iScore,
        iRank     = iRank,
    }
end

local baseAddCityEntry = AddCityEntry
AddCityEntry = function(iPlayerID, iCityID, iScore, iRank)
    baseAddCityEntry(iPlayerID, iCityID, iScore, iRank)
    if iRank == 1 then
        capturedEntries = {}
        capturedKind = "city"
    end
    capturedEntries[#capturedEntries + 1] = {
        iPlayerID = iPlayerID,
        iCityID   = iCityID,
        iScore    = iScore,
        iRank     = iRank,
    }
end

local function isMet(iPlayerID)
    return Teams[Players[iPlayerID]:GetTeam()]:IsHasMet(Game.GetActiveTeam())
end

local function leaderName(iPlayerID)
    return Text.key(GameInfo.Leaders[Players[iPlayerID]:GetLeaderType()].Description)
end

local function nameForPlayer(iPlayerID)
    if iPlayerID == Game.GetActivePlayer() then
        return Text.key("TXT_KEY_POP_VOTE_RESULTS_YOU")
    end
    if not isMet(iPlayerID) then
        return Text.key("TXT_KEY_POP_VOTE_RESULTS_UNMET_PLAYER")
    end
    return Text.key(Players[iPlayerID]:GetNameKey())
end

local function pediaForPlayer(iPlayerID)
    if iPlayerID == Game.GetActivePlayer() then
        return nil
    end
    if not isMet(iPlayerID) then
        return nil
    end
    return leaderName(iPlayerID)
end

local function buildPreamble()
    local parts = {}
    if Controls.PresentsLabel ~= nil then
        local presents = Controls.PresentsLabel:GetText() or ""
        if presents ~= "" then
            parts[#parts + 1] = presents
        end
    end
    if Controls.ListNameLabel ~= nil then
        local listName = Controls.ListNameLabel:GetText() or ""
        if listName ~= "" then
            parts[#parts + 1] = listName
        end
        local tooltip = Controls.ListNameLabel:GetToolTipString() or ""
        if tooltip ~= "" then
            parts[#parts + 1] = tooltip
        end
    end
    return table.concat(parts, ". ")
end

local function buildItems()
    local items = {}
    for _, e in ipairs(capturedEntries) do
        local label
        if capturedKind == "city" then
            local score = Locale.ConvertTextKey("TXT_KEY_FORMAT_NUMBER", e.iScore)
            if not isMet(e.iPlayerID) then
                label = Text.format("TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY",
                    e.iRank,
                    Text.key("TXT_KEY_POP_VOTE_RESULTS_UNMET_PLAYER"),
                    score)
            else
                local pCity = Players[e.iPlayerID]:GetCityByID(e.iCityID)
                label = Text.format("TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY",
                    e.iRank,
                    Text.key(pCity:GetNameKey()),
                    leaderName(e.iPlayerID),
                    score)
            end
        else
            local score = Locale.ConvertTextKey("TXT_KEY_FORMAT_NUMBER", e.iScore)
            label = Text.format("TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY",
                e.iRank,
                nameForPlayer(e.iPlayerID),
                score)
        end
        items[#items + 1] = BaseMenuItems.Text({
            labelText = label,
            pediaName = pediaForPlayer(e.iPlayerID),
        })
    end
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "CloseButton",
        textKey     = "TXT_KEY_CLOSE",
        activate    = function() OnClose() end,
    })
    return items
end

BaseMenu.install(ContextPtr, {
    name          = "WhosWinningPopup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"),
    preamble      = buildPreamble,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    onShow        = function(handler)
        handler.setItems(buildItems())
    end,
    items         = {},
})

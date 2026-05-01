-- LeagueProjectPopup accessibility. BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED pops
-- when a World Congress project (World's Fair, International Games, ISS)
-- finishes. The screen shows project description + a per-major-civ ranking
-- (rank, leader name, contribution points, reward tier earned).
--
-- The contributor list can run all 22 majors in a full game, so each entry
-- is exposed as its own navigable Text item rather than concatenated into
-- one preamble. Preamble is the project header + description; items are the
-- contributor entries followed by Close.
--
-- Capture strategy: monkey-patch the base AddPlayerEntry global, which base
-- UpdateAll calls per major in sorted order. We piggyback on that call so
-- our list is already in the same rank order base displays without re-doing
-- the contribution-tier sort. base UpdateAll runs synchronously inside the
-- SerialEventGameMessagePopup dispatch, so by the time ShowHide(false)
-- fires the captured list is complete.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local capturedEntries = {}
local capturedLeague = nil
local capturedProject = nil

-- Capture the league/project IDs from the popup info; base keeps these as
-- file-locals so we re-listen to the engine event ourselves.
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED then
        capturedLeague = popupInfo.Data1
        capturedProject = popupInfo.Data2
    end
end)

local baseAddPlayerEntry = AddPlayerEntry
AddPlayerEntry = function(iPlayerID, iScore, iTier, iRank)
    baseAddPlayerEntry(iPlayerID, iScore, iTier, iRank)
    -- Reset on rank 1 so a re-fire of the popup (engine can dispatch the
    -- same project completion twice during boot recovery) replaces the list
    -- rather than appending to a stale one.
    if iRank == 1 then
        capturedEntries = {}
    end
    capturedEntries[#capturedEntries + 1] = {
        iPlayerID = iPlayerID,
        iScore    = iScore,
        iTier     = iTier,
        iRank     = iRank,
    }
end

local function playerNameFor(iPlayerID)
    local pPlayer = Players[iPlayerID]
    local pTeam = Teams[pPlayer:GetTeam()]
    if pPlayer:GetID() == Game.GetActivePlayer() then
        return Text.key("TXT_KEY_POP_VOTE_RESULTS_YOU")
    end
    if not pTeam:IsHasMet(Game.GetActiveTeam()) then
        return Text.key("TXT_KEY_POP_VOTE_RESULTS_UNMET_PLAYER")
    end
    return Text.key(pPlayer:GetNameKey())
end

local function tierLabel(iTier)
    if iTier >= 3 then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD")
    end
    if iTier == 2 then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER")
    end
    if iTier == 1 then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE")
    end
    return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE")
end

local function buildPreamble()
    local parts = {}
    for _, name in ipairs({ "PresentsLabel", "ListNameLabel", "ProjectInfoLabel" }) do
        local c = Controls[name]
        if c ~= nil then
            local ok, t = pcall(function() return c:GetText() end)
            if ok and t ~= nil and t ~= "" then
                parts[#parts + 1] = tostring(t)
            end
        end
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ". ")
end

local function rewardTooltipFor(iTier)
    if iTier <= 0 then return nil end
    if capturedLeague == nil or capturedProject == nil then return nil end
    local pLeague = Game.GetLeague(capturedLeague)
    if pLeague == nil then return nil end
    -- Cumulative: a silver-tier earner also got bronze, gold also got silver+bronze.
    -- Order highest-to-lowest to match base's tooltip ordering.
    local parts = {}
    for i = iTier, 1, -1 do
        parts[#parts + 1] = pLeague:GetProjectRewardTierDetails(i, capturedProject)
    end
    return table.concat(parts, ". ")
end

local function buildItems()
    local items = {}
    for _, e in ipairs(capturedEntries) do
        local label = Text.format("TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY",
            e.iRank,
            playerNameFor(e.iPlayerID),
            e.iScore,
            tierLabel(e.iTier))
        items[#items + 1] = BaseMenuItems.Text({
            labelText   = label,
            tooltipText = rewardTooltipFor(e.iTier),
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
    name          = "LeagueProjectPopup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"),
    preamble      = buildPreamble,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    onShow        = function(handler)
        handler.setItems(buildItems())
    end,
    items         = {},
})

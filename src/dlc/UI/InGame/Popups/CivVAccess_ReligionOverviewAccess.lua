-- Accessibility wrapper for the engine's ReligionOverview popup
-- (BUTTONPOPUP_RELIGION_OVERVIEW). Three-tab TabbedShell over the engine's
-- own three-tab screen: tab 1 Your Religion (status, beliefs, faith
-- readout, possible great people, automatic-purchase pulldown), tab 2
-- World Religions (one row per founded religion plus an OVERALL STATUS
-- footer), tab 3 Beliefs (one Group per religion / pantheon, drilling
-- into each religion's beliefs).
--
-- The screen is opened by the engine's existing entry points (Faith string
-- in the top panel, additional-info dropdown, engine Ctrl+P) and by our
-- Ctrl+R binding on BaselineHandler. Engine OnPopup gates on
-- GAMEOPTION_NO_RELIGION, so a religion-off game never queues the popup
-- and our wrapper never installs items against an empty tab.
--
-- Engine integration: ships an override of ReligionOverview.{lua,xml}
-- (verbatim BNW copies plus an include for this module). The engine's
-- OnPopup, InputHandler, ShowHideHandler, RefreshYourReligion /
-- RefreshWorldReligions / RefreshBeliefs, sort wiring, and the
-- AutomaticPurchasePD RegisterSelectionCallback all stay intact;
-- TabbedShell.install layers our handler on top via priorInput /
-- priorShowHide chains.
--
-- Refresh on Events.SerialEventCityInfoDirty rebuilds all three tabs.
-- Faith totals tick on this event each turn-end while the popup stays
-- open; the other tabs are static within a turn but cheap to rebuild
-- alongside, so a single rebuilder covers both.

include("CivVAccess_PopupBoot")
include("CivVAccess_TabbedShell")
include("CivVAccess_PullDownProbe")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local m_yourTab
local m_worldTab
local m_beliefsTab

-- Resolve Cursor module published on civvaccess_shared by the WorldView
-- boot. The popup only opens in-game so the registry is populated by the
-- time activate fires; the nil branch is purely defensive.
local function cursorModule()
    return civvaccess_shared.modules and civvaccess_shared.modules.Cursor
end

-- Civilopedia lookup target for a religion line. Use the underlying
-- religion's Description text key (canonical "Christianity") rather than
-- the custom name the founder picks ("Cult of the Wolf"), so Ctrl+I lands
-- on the religion's pedia entry instead of falling through to GameConcepts.
local function religionPediaName(eReligion)
    local info = GameInfo.Religions[eReligion]
    if info == nil then
        return nil
    end
    return Text.key(info.Description)
end

-- Beliefs are a single pedia category indexed by ShortDescription
-- (CivilopediaScreen Beliefs section uses Locale.ConvertTextKey on it).
local function beliefPediaName(belief)
    return Text.key(belief.ShortDescription)
end

local function beliefTypeWord(belief)
    if belief.Pantheon then
        return Text.key("TXT_KEY_RO_BELIEF_TYPE_PANTHEON")
    elseif belief.Founder then
        return Text.key("TXT_KEY_RO_BELIEF_TYPE_FOUNDER")
    elseif belief.Follower then
        return Text.key("TXT_KEY_RO_BELIEF_TYPE_FOLLOWER")
    elseif belief.Enhancer then
        return Text.key("TXT_KEY_RO_BELIEF_TYPE_ENHANCER")
    elseif belief.Reformation then
        return Text.key("TXT_KEY_RO_BELIEF_TYPE_REFORMATION")
    end
    return ""
end

-- "{TYPE} belief" -- the engine type word ("Founder") on its own reads as
-- a noun about the player; the suffix disambiguates that this row is a
-- belief slot of that type rather than a status line.
local function beliefTypeText(belief)
    local word = beliefTypeWord(belief)
    if word == "" then
        return ""
    end
    return Text.format("TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE", word)
end

local function religiousStatusText(player)
    if player:HasCreatedReligion() then
        return Text.format(
            "TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER",
            Text.key(Game.GetReligionName(player:GetReligionCreatedByPlayer()))
        )
    elseif player:HasCreatedPantheon() then
        return Text.key("TXT_KEY_RO_STATUS_CREATED_PANTHEON")
    elseif player:CanCreatePantheon(true) then
        return Text.key("TXT_KEY_RO_STATUS_CAN_CREATE_PANTHEON")
    elseif player:CanCreatePantheon(false) then
        local needed = Game.GetMinimumFaithNextPantheon() - player:GetFaith()
        return Text.format("TXT_KEY_RO_STATUS_NEED_FAITH", needed)
    end
    return Text.key("TXT_KEY_RO_STATUS_TOO_LATE")
end

-- Belief row used as a Group child (Tab 1's "Your Religion" status block,
-- Tab 3's per-religion group). The parent carries religion context, so
-- the row only needs type / name / description. Ctrl+I jumps to the
-- belief's pedia entry.
local function buildBeliefRow(belief)
    return BaseMenuItems.Text({
        labelText = TextFilter.filter(
            beliefTypeText(belief) .. ", " .. Text.key(belief.ShortDescription) .. ", " .. Text.key(belief.Description)
        ),
        pediaName = beliefPediaName(belief),
    })
end

-- Tab 1: Your Religion ----------------------------------------------------

local function buildYourReligionItems()
    local player = Players[Game.GetActivePlayer()]
    local items = {}

    -- Status row carries Ctrl+I to the founded religion's pedia entry when
    -- the player has founded one; pre-pantheon and post-deadline forms
    -- have no pediable target. pediaNameFn re-resolves at keypress time
    -- so a pantheon-then-religion progression doesn't need the row rebuilt.
    items[#items + 1] = BaseMenuItems.Text({
        labelText = religiousStatusText(player),
        pediaNameFn = function()
            local p = Players[Game.GetActivePlayer()]
            if p:HasCreatedReligion() then
                return religionPediaName(p:GetReligionCreatedByPlayer())
            end
            return nil
        end,
    })

    if player:HasCreatedReligion() then
        for _, v in ipairs(Game.GetBeliefsInReligion(player:GetReligionCreatedByPlayer())) do
            local belief = GameInfo.Beliefs[v]
            if belief ~= nil then
                items[#items + 1] = buildBeliefRow(belief)
            end
        end
    elseif player:HasCreatedPantheon() then
        local belief = GameInfo.Beliefs[player:GetBeliefInPantheon()]
        if belief ~= nil then
            items[#items + 1] = buildBeliefRow(belief)
        end
    end

    -- Faith readout. The bare engine row "Faith 47 of 200" is ambiguous
    -- without the visual context sighted players get, so the engine's
    -- hover-tooltip explanation ("Need minimum of N Faith for next Great
    -- Prophet") is appended inline.
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local p = Players[Game.GetActivePlayer()]
            local minFaith = p:GetMinimumFaithNextGreatProphet()
            return TextFilter.filter(
                Text.format("TXT_KEY_RO_FAITH", p:GetFaith(), minFaith)
                    .. ", "
                    .. Text.format("TXT_KEY_RO_FAITH_TOOLTIP", minFaith)
            )
        end,
    })
    -- Each source suppressed when zero so the pre-Industrial / no-religion
    -- state doesn't speak three "+0" lines.
    local fromCities = player:GetFaithPerTurnFromCities()
    if fromCities ~= 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = TextFilter.filter(Text.format("TXT_KEY_TP_FAITH_FROM_CITIES", fromCities)),
        })
    end
    local fromMinors = player:GetFaithPerTurnFromMinorCivs()
    if fromMinors ~= 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = TextFilter.filter(Text.format("TXT_KEY_TP_FAITH_FROM_MINORS", fromMinors)),
        })
    end
    local fromReligion = player:GetFaithPerTurnFromReligion()
    if fromReligion ~= 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = TextFilter.filter(Text.format("TXT_KEY_TP_FAITH_FROM_RELIGION", fromReligion)),
        })
    end

    -- Possible Great People -- units the player can buy with faith right
    -- now in any city. Mirrors engine RefreshYourReligion's filter chain
    -- (capital cost > 0, IsCanPurchaseAnyCity, DoesUnitPassFaithPurchaseCheck).
    local greatPeople = {}
    local capital = player:GetCapitalCity()
    if capital ~= nil then
        for info in GameInfo.Units({ Special = "SPECIALUNIT_PEOPLE" }) do
            local infoID = info.ID
            local cost = capital:GetUnitFaithPurchaseCost(infoID, true)
            if
                cost > 0
                and player:IsCanPurchaseAnyCity(false, true, infoID, -1, YieldTypes.YIELD_FAITH)
                and player:DoesUnitPassFaithPurchaseCheck(infoID)
            then
                greatPeople[#greatPeople + 1] = Text.key(info.Description)
            end
        end
    end
    table.sort(greatPeople, function(a, b)
        return Locale.Compare(a, b) == -1
    end)
    local gpLabel = Text.key("TXT_KEY_RO_POSSIBLE_GP")
    if #greatPeople > 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.format("TXT_KEY_CIVVACCESS_LABELED_LIST", gpLabel, table.concat(greatPeople, ", ")),
        })
    else
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.format(
                "TXT_KEY_CIVVACCESS_LABELED_LIST",
                gpLabel,
                Text.key("TXT_KEY_RO_YR_NO_GREAT_PEOPLE")
            ),
        })
    end

    -- The engine builds entry text and the current-selection text with a
    -- literal `[ICON_PEACE]` token (e.g. "Purchase Missionary (200 [ICON_PEACE])").
    -- valueFn / entryAnnounceFn route both through TextFilter so the icon
    -- token resolves to "Faith" instead of reaching Tolk raw.
    items[#items + 1] = BaseMenuItems.Pulldown({
        controlName = "AutomaticPurchasePD",
        labelText = Text.key("TXT_KEY_RO_AUTO_FAITH_PURCHASE"),
        valueFn = function(control)
            local ok, btn = pcall(function()
                return control:GetButton()
            end)
            if not ok or btn == nil then
                return nil
            end
            local ok2, text = pcall(function()
                return btn:GetText()
            end)
            if not ok2 or text == nil or text == "" then
                return nil
            end
            return TextFilter.filter(text)
        end,
        entryAnnounceFn = function(inst)
            local ok, text = pcall(function()
                return inst.Button:GetText()
            end)
            if not ok or text == nil then
                return ""
            end
            return TextFilter.filter(text)
        end,
    })

    return items
end

-- Tab 2: World Religions --------------------------------------------------

-- Cities following a religion across every met civ. Filters by
-- Teams:IsHasMet so unmet civs' cities don't leak through; further
-- gates each city by plot:IsRevealed because that's the strictest
-- "can the user navigate there" filter (jumping the cursor onto an
-- unrevealed plot is meaningless). Returns city handles, not snapshots,
-- so onActivate reads live coordinates.
local function citiesFollowingReligion(eReligion, activePlayerId, activeTeamId)
    local activeTeam = Teams[activeTeamId]
    local out = {}
    for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local p = Players[iPlayer]
        if p ~= nil and p:IsAlive() and not p:IsBarbarian() then
            local met = (iPlayer == activePlayerId) or activeTeam:IsHasMet(p:GetTeam())
            if met then
                for city in p:Cities() do
                    if city:GetReligiousMajority() == eReligion then
                        local plot = city:Plot()
                        if plot ~= nil and plot:IsRevealed(activeTeamId) then
                            out[#out + 1] = city
                        end
                    end
                end
            end
        end
    end
    table.sort(out, function(a, b)
        return Locale.Compare(a:GetName(), b:GetName()) == -1
    end)
    return out
end

-- One row per city following a religion. Enter dismisses the popup and
-- jumps the hex cursor onto the city plot so the user can keep navigating
-- from there. OnClose is the engine ReligionOverview global (same Context
-- as the wrapper); calling it before the cursor jump matches MilitaryOverview's
-- pattern -- close the modal first so the world hex announcement isn't
-- talking under it.
local function buildCityRow(city)
    local cityX, cityY = city:GetX(), city:GetY()
    local cityName = city:GetName()
    return BaseMenuItems.Text({
        labelText = cityName,
        onActivate = function()
            OnClose()
            local Cursor = cursorModule()
            if Cursor ~= nil then
                Cursor.jumpTo(cityX, cityY)
            end
        end,
    })
end

local function buildWorldReligionGroup(eReligion, founderPlayer, activePlayerId, activeTeamId)
    local activeTeam = Teams[activeTeamId]
    local holyCity = Game.GetHolyCityForReligion(eReligion, founderPlayer:GetID())
    local holyCityName, founderName
    if activeTeam:IsHasMet(founderPlayer:GetTeam()) then
        holyCityName = holyCity:GetName()
        founderName = founderPlayer:GetCivilizationDescription()
    else
        holyCityName = "TXT_KEY_RO_WR_UNKNOWN_HOLY_CITY"
        founderName = "TXT_KEY_RO_WR_UNKNOWN_CIV"
    end
    -- Count is the global Game.GetNumCitiesFollowing -- a religion-level
    -- statistic the user wants for comparison ("Christianity: 12 cities,
    -- Islam: 4 cities") rather than a "how many entries in this drilldown"
    -- count. The drilled-in list filters by met civ + revealed plot, so
    -- the navigable subset can be smaller than the global total; that's
    -- fine -- the count is what a sighted player would see in the engine's
    -- own row, and the drilldown is the navigable subset.
    local numCities = Game.GetNumCitiesFollowing(eReligion)
    local label = TextFilter.filter(
        Text.formatPlural(
            "TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW",
            numCities,
            Text.key(Game.GetReligionName(eReligion)),
            Text.key(holyCityName),
            Text.key(founderName),
            numCities
        )
    )
    local cities = citiesFollowingReligion(eReligion, activePlayerId, activeTeamId)
    local children = {}
    for _, city in ipairs(cities) do
        children[#children + 1] = buildCityRow(city)
    end
    -- A Group with no navigable children would be skipped by the parent's
    -- nav, hiding extinct religions (no follower cities). Fall back to a
    -- flat Text row in that edge case so the religion still shows up.
    if #children == 0 then
        return BaseMenuItems.Text({
            labelText = label,
            pediaName = religionPediaName(eReligion),
        })
    end
    return BaseMenuItems.Group({
        labelText = label,
        items = children,
        pediaName = religionPediaName(eReligion),
    })
end

local function buildWorldReligionsItems()
    local items = {}
    local activePlayerId = Game.GetActivePlayer()
    local activePlayer = Players[activePlayerId]
    local activeTeamId = activePlayer:GetTeam()

    local found = 0
    for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local p = Players[iPlayer]
        if p:IsEverAlive() and p:HasCreatedReligion() then
            found = found + 1
            items[#items + 1] = buildWorldReligionGroup(p:GetReligionCreatedByPlayer(), p, activePlayerId, activeTeamId)
        end
    end

    if found == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_RO_NO_WORLD_RELIGIONS") })
    end

    return items
end

-- Tab 3: Beliefs ----------------------------------------------------------

local function buildReligionBeliefGroup(eReligion)
    local children = {}
    for _, v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
        local belief = GameInfo.Beliefs[v]
        if belief ~= nil then
            children[#children + 1] = buildBeliefRow(belief)
        end
    end
    return BaseMenuItems.Group({
        labelText = Text.key(Game.GetReligionName(eReligion)),
        items = children,
        pediaName = religionPediaName(eReligion),
    })
end

-- Pantheon-only civs carry a single belief, so a drillable Group is just
-- one click of friction. Front-load it as a flat Text row that announces
-- the civ-adjective header and the belief inline. Ctrl+I jumps to the
-- belief's pedia entry (the pantheon religion type itself isn't a useful
-- pedia destination -- one entry covers all pantheon beliefs).
local function buildPantheonBeliefRow(player, activeTeam)
    local belief = GameInfo.Beliefs[player:GetBeliefInPantheon()]
    if belief == nil then
        return nil
    end
    local header
    if activeTeam:IsHasMet(player:GetTeam()) then
        header = Text.format("TXT_KEY_RO_BELIEF_PANTHEON", player:GetCivilizationAdjectiveKey())
    else
        header = Text.key("TXT_KEY_RO_BELIEF_UNKNOWN_PANTHEON")
    end
    return BaseMenuItems.Text({
        labelText = TextFilter.filter(
            header
                .. ", "
                .. beliefTypeText(belief)
                .. ", "
                .. Text.key(belief.ShortDescription)
                .. ", "
                .. Text.key(belief.Description)
        ),
        pediaName = beliefPediaName(belief),
    })
end

local function buildBeliefsItems()
    local items = {}
    local activePlayer = Players[Game.GetActivePlayer()]
    local activeTeam = Teams[activePlayer:GetTeam()]

    for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local p = Players[iPlayer]
        if p:IsEverAlive() then
            if p:HasCreatedReligion() then
                items[#items + 1] = buildReligionBeliefGroup(p:GetReligionCreatedByPlayer())
            elseif p:HasCreatedPantheon() then
                local row = buildPantheonBeliefRow(p, activeTeam)
                if row ~= nil then
                    items[#items + 1] = row
                end
            end
        end
    end

    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_RO_B_NO_BELIEFS") })
    end

    return items
end

-- Install -----------------------------------------------------------------

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    -- Patch the engine PullDown metatable so AutomaticPurchasePD's
    -- ClearEntries / BuildEntry / RegisterSelectionCallback are captured.
    -- Engine RefreshYourReligion re-runs on every popup show (priorShowHide
    -- chains the engine ShowHide which calls TabSelect("YourReligion")), so
    -- a probe installed at access-file load time is in place by the time
    -- show-time entries are built. Idempotent across the lua_State.
    PullDownProbe.installFromControls({ "AutomaticPurchasePD" }, {}, {}, {})

    local function makeTab(tabName)
        return TabbedShell.menuTab({
            tabName = tabName,
            menuSpec = {
                displayName = Text.key("TXT_KEY_RELIGION_OVERVIEW"),
                items = {},
            },
        })
    end
    m_yourTab = makeTab("TXT_KEY_RO_TAB_YOUR_RELIGION")
    m_worldTab = makeTab("TXT_KEY_RO_TAB_WORLD_RELIGIONS")
    m_beliefsTab = makeTab("TXT_KEY_RO_TAB_BELIEFS")

    local function rebuildAllTabs()
        m_yourTab.menu().setItems(buildYourReligionItems())
        m_worldTab.menu().setItems(buildWorldReligionsItems())
        m_beliefsTab.menu().setItems(buildBeliefsItems())
    end

    TabbedShell.install(ContextPtr, {
        name = "ReligionOverview",
        displayName = Text.key("TXT_KEY_RELIGION_OVERVIEW"),
        tabs = { m_yourTab, m_worldTab, m_beliefsTab },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(_handler)
            rebuildAllTabs()
        end,
    })

    -- Faith totals tick on city-info dirty (engine recomputes per-turn
    -- yields here). Other tabs only change on rare engine events
    -- (religion founded, belief enhanced) and are cheap to refresh
    -- alongside, so a single rebuilder covers both. Registered on every
    -- Context include rather than gated by an install-once flag because
    -- load-from-game wipes this Context's env and re-registers a fresh
    -- listener (Architecture Gotchas in CLAUDE.md).
    Events.SerialEventCityInfoDirty.Add(function()
        if ContextPtr:IsHidden() then
            return
        end
        local ok, err = pcall(rebuildAllTabs)
        if not ok then
            Log.error("ReligionOverview dirty refresh failed: " .. tostring(err))
        end
    end)
end

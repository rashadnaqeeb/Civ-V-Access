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

local function beliefTypeText(belief)
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

local function religiousStatusText(player)
    if player:HasCreatedReligion() then
        return Text.format(
            "TXT_KEY_RO_STATUS_FOUNDER",
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
-- Tab 3's per-religion / per-pantheon group). The parent carries religion
-- context, so the row only needs type / name / description.
local function buildBeliefRow(belief)
    return BaseMenuItems.Text({
        labelText = TextFilter.filter(
            beliefTypeText(belief) .. ", " .. Text.key(belief.ShortDescription) .. ", " .. Text.key(belief.Description)
        ),
    })
end

-- Tab 1: Your Religion ----------------------------------------------------

local function buildYourReligionItems()
    local player = Players[Game.GetActivePlayer()]
    local items = {}

    items[#items + 1] = BaseMenuItems.Text({ labelText = religiousStatusText(player) })

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
            labelText = Text.format("TXT_KEY_CIVVACCESS_LABELED_LIST", gpLabel, Text.key("TXT_KEY_RO_YR_NO_GREAT_PEOPLE")),
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

local function buildWorldReligionsItems()
    local items = {}
    local activePlayer = Players[Game.GetActivePlayer()]
    local activeTeam = Teams[activePlayer:GetTeam()]

    local found = 0
    for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local p = Players[iPlayer]
        if p:IsEverAlive() and p:HasCreatedReligion() then
            found = found + 1
            local eReligion = p:GetReligionCreatedByPlayer()
            local holyCity = Game.GetHolyCityForReligion(eReligion, iPlayer)
            local holyCityName, founderName
            if activeTeam:IsHasMet(p:GetTeam()) then
                holyCityName = holyCity:GetName()
                founderName = p:GetCivilizationDescription()
            else
                holyCityName = "TXT_KEY_RO_WR_UNKNOWN_HOLY_CITY"
                founderName = "TXT_KEY_RO_WR_UNKNOWN_CIV"
            end
            items[#items + 1] = BaseMenuItems.Text({
                labelText = TextFilter.filter(
                    Text.formatPlural(
                        "TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW",
                        Game.GetNumCitiesFollowing(eReligion),
                        Text.key(Game.GetReligionName(eReligion)),
                        Text.key(holyCityName),
                        Text.key(founderName),
                        Game.GetNumCitiesFollowing(eReligion)
                    )
                ),
            })
        end
    end

    if found == 0 then
        items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_RO_NO_WORLD_RELIGIONS") })
    end

    -- OVERALL STATUS footer at the bottom (matches engine layout).
    local left = math.max(Game.GetNumReligionsStillToFound(), 0)
    items[#items + 1] = BaseMenuItems.Text({
        labelText = TextFilter.filter(Text.format("TXT_KEY_TP_FAITH_RELIGIONS_LEFT", left)),
    })
    items[#items + 1] = BaseMenuItems.Text({ labelText = religiousStatusText(activePlayer) })

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
    })
end

local function buildPantheonBeliefGroup(player, activeTeam)
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
    return BaseMenuItems.Group({
        labelText = TextFilter.filter(header),
        items = { buildBeliefRow(belief) },
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
                local group = buildPantheonBeliefGroup(p, activeTeam)
                if group ~= nil then
                    items[#items + 1] = group
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

-- Corporations Overview accessibility (Vox Populi only; Ctrl+Shift+C or
-- the Additional Information dropdown / DiploCorner button). Wraps the
-- Vox Populi CorporationsOverview popup (BUTTONPOPUP_MODDER_5) as a
-- five-tab TabbedShell, flattening the vendor's three tabs plus their
-- two embedded view pulldowns into one tab per view:
--
--   Monopolies        -- BaseTable, one row per monopoly-flagged resource
--                        with copies on the map. Columns: Controlled (the
--                        selected civ's share with the monopoly state in
--                        words and the owned-of-total count; the engine's
--                        local / import / city-state breakdown rides the
--                        tooltip), Monopoly Owner (vendor rule mirrored:
--                        the leader is named only once they hold a global
--                        monopoly, otherwise "No Civilization"), and
--                        Monopoly Bonus (the resource's Help text). The
--                        vendor's civ-perspective pulldown becomes a
--                        Select Player control above the column headers
--                        (Up from the header row); activating it opens a
--                        picker of met civs that commits through the
--                        vendor's own pulldown callback so the visual
--                        panel tracks the pick. The vendor's type filter
--                        (All / Global / Strategic / Potential) is
--                        dropped: the sortable Controlled column covers
--                        the same triage.
--   Your Corporation  -- BaseMenu. Pre-tech: the vendor's not-ready line.
--                        Tech but unfounded: the availability status line
--                        (founding rules on the tooltip) and one drillable
--                        group per corporation -- label carries name plus
--                        founded-by / unavailable state, children are the
--                        "Monopoly Required (Any)" lead, one row per
--                        qualifying resource with your live share inline,
--                        then the corporation's Help text split per line.
--                        Founded: name, headquarters (Enter drops the hex
--                        cursor), founding date, offices N of M,
--                        franchises N of max (DLL breakdown tooltip), the
--                        live office benefit (DLL-composed, already
--                        scaled by franchise count), and a Bonuses group
--                        with the three benefit help rows.
--   Offices and Franchises -- BaseMenu, two drillable groups: your office
--                        cities (foreign trade-route count per city, the
--                        vendor's route-by-route franchised/not list on
--                        the tooltip) and your franchises (host city plus
--                        host civ). Enter on any city drops the hex
--                        cursor. A no-corporation line replaces the
--                        groups until a corporation exists.
--   World Corporations -- BaseTable, one row per founded corporation:
--                        civilization, headquarters city (Enter drops the
--                        hex cursor), date founded, office and franchise
--                        counts. Rows order by corporation name.
--   World Franchises  -- BaseTable, one row per franchise on the map:
--                        host city is the row label; columns are the
--                        owning civ, the corporation, and the host civ.
--                        Enter on any column drops the hex cursor on the
--                        city. The vendor scans without fog-of-war
--                        filtering and we mirror; unmet civs still read
--                        as unknown through the shared civ-label helper.
--
-- Tab switches drive the vendor's own tab buttons and view pulldown
-- callbacks (TabSelect / OnYourCorporationPulldown /
-- OnWorldCorporationsPulldown) so the visual screen follows for a
-- sighted spectator. The screen is purely informational -- founding
-- happens in city production, franchises spread via trade routes -- so
-- there are no commit flows and no mid-screen refresh events; the
-- tables re-query on every keystroke and the menu tabs rebuild on each
-- activation. Esc falls through to the vendor InputHandler (close); the
-- vendor's Enter-closes binding stays beneath our consumed Enter.

include("CivVAccess_PopupBoot")
include("CivVAccess_TabbedShell")
include("CivVAccess_BaseTableCore")
include("CivVAccess_OverviewCivLabels")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local activePlayer = OverviewCivLabels.activePlayer
local activePlayerID = OverviewCivLabels.activePlayerId
local civDisplayName = OverviewCivLabels.civDisplayName

-- ===== Shared helpers ===================================================

-- Enter on a city row: vendor camera pan (spectator parity) plus the hex
-- cursor drop with the landing spoken (the EventOverview go-to-city
-- precedent). The screen stays open; Esc closes it.
local function jumpToCity(city)
    local plot = city:Plot()
    UI.LookAt(plot, 0)
    local Cursor = civvaccess_shared.modules and civvaccess_shared.modules.Cursor
    if Cursor == nil then
        Log.warn("CorporationsOverview go-to-city: Cursor module not published")
        return
    end
    local text = Cursor.jumpTo(plot:GetX(), plot:GetY())
    if text ~= nil and text ~= "" then
        SpeechPipeline.speakQueued(text)
    end
end

-- ===== Monopolies tab ===================================================

-- Perspective is the vendor's own g_MonopolyResourcePlayer global, read
-- live so a pick made through the visual pulldown by a sighted co-driver
-- moves our table too. The vendor seeds it to the active player at
-- Context load.
local function selectedMonopolyPlayer()
    local id = g_MonopolyResourcePlayer
    if id == nil or Players[id] == nil then
        return activePlayer()
    end
    return Players[id]
end

local function rebuildMonopolyRows()
    local rows = {}
    for resource in GameInfo.Resources() do
        if resource.IsMonopoly and Map.GetNumResources(resource.ID) > 0 then
            rows[#rows + 1] = resource
        end
    end
    return rows
end

-- Owned / import / city-state decomposition, mirroring the vendor's
-- HookupResourceInstance math (imports and minor-civ copies only count
-- when the show-imports player option is on, same as the engine's
-- monopoly accounting).
local function ownedBreakdown(resourceID)
    local p = selectedMonopolyPlayer()
    local base = p:GetNumResourceTotal(resourceID, false, false) + p:GetResourceExport(resourceID)
    local imports, minors = 0, 0
    if p:IsShowImports() then
        minors = p:GetResourceFromMinors(resourceID)
        imports = p:GetResourceImport(resourceID) - minors
    end
    return base, imports, minors
end

local function shareCellText(r)
    local p = selectedMonopolyPlayer()
    local pct = p:GetMonopolyPercent(r.ID)
    local base, imports, minors = ownedBreakdown(r.ID)
    local owned = base + imports + minors
    local onMap = Map.GetNumResources(r.ID)
    local stateKey
    if p:HasGlobalMonopoly(r.ID) then
        stateKey = "TXT_KEY_CIVVACCESS_CORP_STATE_GLOBAL"
    elseif p:HasStrategicMonopoly(r.ID) then
        stateKey = "TXT_KEY_CIVVACCESS_CORP_STATE_STRATEGIC"
    end
    if stateKey ~= nil then
        return Text.format("TXT_KEY_CIVVACCESS_CORP_SHARE_STATE", pct, Text.key(stateKey), owned, onMap)
    end
    return Text.format("TXT_KEY_CIVVACCESS_CORP_SHARE", pct, owned, onMap)
end

local function shareTooltip(r)
    local base, imports, minors = ownedBreakdown(r.ID)
    if selectedMonopolyPlayer():IsShowImports() then
        return Text.format("TXT_KEY_RESOURCE_BREAKDOWN_IMPORTS", base, imports, minors)
    end
    return Text.format("TXT_KEY_RESOURCE_BREAKDOWN", base)
end

-- Vendor rule mirrored (ChooseMonopolyPlayer): the leading civ is named
-- only once it holds a global monopoly; below that threshold the cell
-- reads "No Civilization" even when someone clearly leads.
local function monopolyOwnerCell(r)
    local eGreatest = Game.GetGreatestPlayerResourceMonopoly(r.ID)
    if eGreatest <= -1 or not Players[eGreatest]:HasGlobalMonopoly(r.ID) then
        return Text.key("TXT_KEY_CPO_MP_NO_CIVILIZATION")
    end
    local pOwner = Players[eGreatest]
    return Text.format("TXT_KEY_CPO_MONOPOLY_OWNER_INFO", civDisplayName(pOwner), pOwner:GetMonopolyPercent(r.ID))
end

local function monopolyOwnerSortKey(r)
    local eGreatest = Game.GetGreatestPlayerResourceMonopoly(r.ID)
    if eGreatest <= -1 or not Players[eGreatest]:HasGlobalMonopoly(r.ID) then
        return ""
    end
    return civDisplayName(Players[eGreatest])
end

local function resourcePedia(r)
    return Text.key(r.Description)
end

-- The Select Player control above the column headers. Activation pushes a
-- picker of met civs; a pick commits through the vendor's own pulldown
-- callback (OnMonopolyCivPulldown) so the visual pulldown label and panel
-- refresh stay in sync, then pops back to the table, whose re-activation
-- re-reads the control with the new civ.
local PERSPECTIVE_SUB = "CorporationsOverview/Perspective"

local function perspectiveLabel()
    return Text.key("TXT_KEY_CPO_MP_DROPDOWN_LABEL_SELECT_PLAYER") .. ", " .. civDisplayName(selectedMonopolyPlayer())
end

local function openPerspectivePicker()
    local items = {}
    local initialIndex
    local current = selectedMonopolyPlayer():GetID()
    local team = OverviewCivLabels.activeTeam()
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local p = Players[i]
        if p ~= nil and p:IsAlive() and team:IsHasMet(p:GetTeam()) then
            local id = i
            local name = civDisplayName(p)
            local label = name
            if id == current then
                label = Text.format("TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED", name)
                initialIndex = #items + 1
            end
            items[#items + 1] = BaseMenuItems.Text({
                labelText = label,
                onActivate = function()
                    Log.tryCall("CorporationsOverview perspective pick", OnMonopolyCivPulldown, id)
                    HandlerStack.removeByName(PERSPECTIVE_SUB, true)
                end,
            })
        end
    end
    HandlerStack.push(BaseMenu.create({
        name = PERSPECTIVE_SUB,
        displayName = Text.key("TXT_KEY_CPO_MP_DROPDOWN_LABEL_SELECT_PLAYER"),
        items = items,
        initialIndex = initialIndex,
        escapePops = true,
    }))
end

local function buildMonopoliesTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CPO_TAB_MONOPOLIES",
        topItem = {
            labelFn = perspectiveLabel,
            onActivate = openPerspectivePicker,
            helpEntry = {
                keyLabel = "TXT_KEY_CIVVACCESS_CORP_PERSPECTIVE_HELP_KEY",
                description = "TXT_KEY_CIVVACCESS_CORP_PERSPECTIVE_HELP_DESC",
            },
        },
        columns = {
            {
                name = "TXT_KEY_CPO_MP_OWNED",
                getCell = shareCellText,
                sortKey = function(r)
                    return selectedMonopolyPlayer():GetMonopolyPercent(r.ID)
                end,
                getTooltip = shareTooltip,
                pediaName = resourcePedia,
            },
            {
                name = "TXT_KEY_CPO_MP_CIVILIZATION",
                getCell = monopolyOwnerCell,
                sortKey = monopolyOwnerSortKey,
                pediaName = resourcePedia,
            },
            {
                name = "TXT_KEY_CPO_MP_MONOPOLY_BONUS",
                getCell = function(r)
                    if r.Help == nil then
                        return ""
                    end
                    return Text.key(r.Help)
                end,
                pediaName = resourcePedia,
            },
        },
        rebuildRows = rebuildMonopolyRows,
        rowLabel = function(r)
            return Text.key(r.Description)
        end,
        defaultSort = { column = 1, ascending = false },
    })
end

-- ===== Your Corporation tab =============================================

-- A corporation whose headquarters resolves to another civ's unique
-- building (or to no building at all) can never be founded by the active
-- player. Mirrors the vendor's override-then-default resolution in
-- UpdateAvailableCorporations.
local function isCivLocked(row)
    local hqClass = GameInfo.BuildingClasses[row.HeadquartersBuildingClass]
    if hqClass == nil then
        return false
    end
    local civType = GameInfo.Civilizations[activePlayer():GetCivilizationType()].Type
    local hq
    local override = GameInfo.Civilization_BuildingClassOverrides({
        BuildingClassType = row.HeadquartersBuildingClass,
        CivilizationType = civType,
    })()
    if override ~= nil then
        if override.BuildingType then
            hq = GameInfo.Buildings[override.BuildingType]
        end
    elseif hqClass.DefaultBuilding then
        hq = GameInfo.Buildings[hqClass.DefaultBuilding]
    end
    return hq == nil or (hq.CivilizationRequired ~= nil and hq.CivilizationRequired ~= civType)
end

local function corporationStatusClause(row)
    local founder = Game.GetCorporationFounder(row.ID)
    if founder ~= -1 then
        return Text.format("TXT_KEY_CIVVACCESS_CORP_FOUNDED_BY", civDisplayName(Players[founder]))
    end
    if isCivLocked(row) then
        return Text.key("TXT_KEY_CIVVACCESS_CORP_CIV_LOCKED")
    end
    return nil
end

local function corpResourceShareItem(resource)
    local resName = Text.key(resource.Description)
    return BaseMenuItems.Text({
        labelFn = function()
            return Text.format(
                "TXT_KEY_CIVVACCESS_CORP_RESOURCE_SHARE",
                resName,
                activePlayer():GetMonopolyPercent(resource.ID)
            )
        end,
        tooltipFn = function()
            if resource.Help == nil then
                return nil
            end
            return Text.key(resource.Help)
        end,
        pediaName = resName,
    })
end

local function corpBrowserGroup(row)
    local corpName = Text.key(row.Description)
    return BaseMenuItems.Group({
        labelFn = function()
            local clause = corporationStatusClause(row)
            if clause ~= nil then
                return corpName .. ", " .. clause
            end
            return corpName
        end,
        pediaName = corpName,
        cached = false,
        itemsFn = function()
            local items = {}
            items[#items + 1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CPO_MONOPOLY_REQUIRED") })
            for req in GameInfo.Corporation_ResourceMonopolyOrs("CorporationType = '" .. row.Type .. "'") do
                local resource = GameInfo.Resources[req.ResourceType]
                if resource ~= nil then
                    items[#items + 1] = corpResourceShareItem(resource)
                end
            end
            if row.Help ~= nil then
                for _, line in ipairs(TextFilter.splitLines(Text.key(row.Help))) do
                    items[#items + 1] = BaseMenuItems.Text({ labelText = line })
                end
            end
            return items
        end,
    })
end

local function buildFoundedItems(eCorp)
    local pCorp = GameInfo.Corporations[eCorp]
    local corpName = Text.key(pCorp.Description)
    local items = {}
    items[#items + 1] = BaseMenuItems.Text({
        labelText = corpName,
        tooltipFn = function()
            if pCorp.Help == nil then
                return nil
            end
            return Text.key(pCorp.Help)
        end,
        pediaName = corpName,
    })
    if Game.GetCorporationHeadquarters(eCorp) ~= nil then
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                local city = Game.GetCorporationHeadquarters(eCorp)
                return Text.format("TXT_KEY_CPO_YOUR_CORPORATION_HQ", city ~= nil and city:GetName() or "")
            end,
            onActivate = function()
                local city = Game.GetCorporationHeadquarters(eCorp)
                if city ~= nil then
                    jumpToCity(city)
                end
            end,
        })
    end
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local turn = activePlayer():GetCorporationFoundedTurn()
            return Text.format("TXT_KEY_CPO_YOUR_CORPORATION_ESTABLISHED", Game.GetDateString(turn), turn)
        end,
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local p = activePlayer()
            return Text.format("TXT_KEY_CPO_NUM_OFFICES", p:GetNumberofOffices(), p:GetNumCities())
        end,
        tooltipKey = "TXT_KEY_NUM_OFFICES_TT",
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local p = activePlayer()
            return Text.format("TXT_KEY_CPO_NUM_FRANCHISES", p:GetNumberofGlobalFranchises(), p:GetMaxFranchises())
        end,
        tooltipFn = function()
            return activePlayer():GetNumFranchisesTooltip()
        end,
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            return activePlayer():GetCurrentOfficeBenefit()
        end,
        tooltipKey = "TXT_KEY_CPO_BUILD_FRANCHISES_HELP",
    })
    local benefitDefs = {
        { lead = "TXT_KEY_CPO_RESOURCE_BONUS", help = pCorp.ResourceBonusHelp },
        { lead = "TXT_KEY_CPO_OFFICE_BONUS", help = pCorp.OfficeBonusHelp },
        { lead = "TXT_KEY_CPO_TRADE_ROUTE_BONUS", help = pCorp.TradeRouteBonusHelp },
    }
    local benefitRows = {}
    for _, b in ipairs(benefitDefs) do
        if b.help ~= nil then
            benefitRows[#benefitRows + 1] = BaseMenuItems.Text({
                labelText = Text.key(b.lead) .. ", " .. Text.key(b.help),
            })
        end
    end
    if #benefitRows > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CPO_CORPORATION_BONUSES"),
            items = benefitRows,
        })
    end
    return items
end

local function buildYourCorpItems()
    local p = activePlayer()
    if not Teams[p:GetTeam()]:IsCorporationsEnabled() then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CPO_CORPORATIONS_NOT_READY") }) }
    end
    local eCorp = p:GetCorporation()
    if eCorp ~= -1 then
        return buildFoundedItems(eCorp)
    end
    local items = {}
    local anyAvailable = false
    for row in GameInfo.Corporations() do
        if Game.GetCorporationFounder(row.ID) == -1 and not isCivLocked(row) then
            anyAvailable = true
            break
        end
    end
    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.key(
            anyAvailable and "TXT_KEY_CPO_FOUND_CORPORATION_AVAILABLE" or "TXT_KEY_CPO_FOUND_CORPORATION_UNAVAILABLE"
        ),
        tooltipKey = "TXT_KEY_CPO_FOUND_CORPORATION_HELP",
    })
    for row in GameInfo.Corporations() do
        items[#items + 1] = corpBrowserGroup(row)
    end
    return items
end

-- ===== Offices and Franchises tab =======================================

-- Foreign trade routes leaving this office city, with the vendor's
-- per-route tooltip ("from to to, franchised / no franchise").
local function officeTradeRouteData(city)
    local p = activePlayer()
    local count = 0
    local lines = {}
    for _, v in ipairs(p:GetTradeRoutes()) do
        if v.FromCity == city and v.ToCity:GetCivilizationType() ~= p:GetCivilizationType() then
            count = count + 1
            local franchised
            if v.ToCity:IsFranchised(activePlayerID()) then
                franchised = Text.key("TXT_KEY_CPO_FRANCHISED")
            else
                franchised = Text.key("TXT_KEY_CPO_NO_FRANCHISE")
            end
            lines[#lines + 1] = Text.format(
                "TXT_KEY_CPO_OFFICE_TRADE_ROUTES_INSTANCE_TT",
                v.FromCity:GetName(),
                v.ToCity:GetName(),
                franchised
            )
        end
    end
    if count == 0 then
        return 0, nil
    end
    return count, Text.key("TXT_KEY_CPO_OFFICE_TRADE_ROUTES_TT") .. "[NEWLINE]" .. table.concat(lines, "[NEWLINE]")
end

local function officeCityItem(city)
    return BaseMenuItems.Text({
        labelFn = function()
            local count = officeTradeRouteData(city)
            local name = city:GetName()
            if activePlayer():GetCapitalCity() == city then
                name = Text.format(
                    "TXT_KEY_CIVVACCESS_EO_CITY_LABEL",
                    name,
                    Text.key("TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL")
                )
            end
            return Text.formatPlural("TXT_KEY_CIVVACCESS_CORP_OFFICE_ROW", count, name, count)
        end,
        tooltipFn = function()
            local _, tooltip = officeTradeRouteData(city)
            return tooltip
        end,
        onActivate = function()
            jumpToCity(city)
        end,
    })
end

local function franchiseCityItem(city, ownerID)
    return BaseMenuItems.Text({
        labelFn = function()
            return Text.format(
                "TXT_KEY_CIVVACCESS_CORP_FRANCHISE_ROW",
                city:GetName(),
                civDisplayName(Players[ownerID])
            )
        end,
        onActivate = function()
            jumpToCity(city)
        end,
    })
end

local function buildOfficesItems()
    local p = activePlayer()
    if not Teams[p:GetTeam()]:IsCorporationsEnabled() or p:GetCorporation() == -1 then
        return { BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_CORP_NONE") }) }
    end
    return {
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CPO_YOUR_OFFICES"),
            cached = false,
            itemsFn = function()
                local items = {}
                for city in activePlayer():Cities() do
                    if city:HasOffice() then
                        items[#items + 1] = officeCityItem(city)
                    end
                end
                if #items == 0 then
                    items[1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY") })
                end
                return items
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CPO_YOUR_FRANCHISES"),
            cached = false,
            itemsFn = function()
                local items = {}
                local me = activePlayerID()
                for i = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
                    local other = Players[i]
                    if other ~= nil and other:IsEverAlive() then
                        for city in other:Cities() do
                            if city:IsFranchised(me) then
                                items[#items + 1] = franchiseCityItem(city, i)
                            end
                        end
                    end
                end
                if #items == 0 then
                    items[1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY") })
                end
                return items
            end,
        }),
    }
end

-- ===== World Corporations tab ===========================================

local function rebuildWorldCorpRows()
    local rows = {}
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local p = Players[i]
        if p ~= nil and p:IsAlive() then
            local eCorp = p:GetCorporation()
            if eCorp ~= -1 and GameInfo.Corporations[eCorp] ~= nil then
                rows[#rows + 1] = { player = i, corp = eCorp }
            end
        end
    end
    table.sort(rows, function(a, b)
        local an = Text.key(GameInfo.Corporations[a.corp].Description)
        local bn = Text.key(GameInfo.Corporations[b.corp].Description)
        return Locale.Compare(an, bn) == -1
    end)
    return rows
end

local function worldCorpLabel(row)
    return Text.key(GameInfo.Corporations[row.corp].Description)
end

local function buildWorldCorpsTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CPO_TAB_WORLD_CORPORATIONS",
        columns = {
            {
                name = "TXT_KEY_CPO_WC_CIVILIZATION",
                getCell = function(r)
                    return civDisplayName(Players[r.player])
                end,
                sortKey = function(r)
                    return civDisplayName(Players[r.player])
                end,
                pediaName = worldCorpLabel,
            },
            {
                name = "TXT_KEY_CPO_WC_HEADQUARTERS",
                getCell = function(r)
                    local city = Game.GetCorporationHeadquarters(r.corp)
                    return city ~= nil and city:GetName() or ""
                end,
                sortKey = function(r)
                    local city = Game.GetCorporationHeadquarters(r.corp)
                    return city ~= nil and city:GetName() or ""
                end,
                enterAction = function(r)
                    local city = Game.GetCorporationHeadquarters(r.corp)
                    if city ~= nil then
                        jumpToCity(city)
                    end
                end,
                pediaName = worldCorpLabel,
            },
            {
                name = "TXT_KEY_CPO_WC_DATE_FOUNDED",
                getCell = function(r)
                    return Game.GetDateString(Players[r.player]:GetCorporationFoundedTurn())
                end,
                sortKey = function(r)
                    return Players[r.player]:GetCorporationFoundedTurn()
                end,
                pediaName = worldCorpLabel,
            },
            {
                name = "TXT_KEY_CPO_WC_NUM_OFFICES",
                getCell = function(r)
                    return tostring(Players[r.player]:GetNumberofOffices())
                end,
                sortKey = function(r)
                    return Players[r.player]:GetNumberofOffices()
                end,
                pediaName = worldCorpLabel,
            },
            {
                name = "TXT_KEY_CPO_WC_NUM_FRANCHISES",
                getCell = function(r)
                    return tostring(Players[r.player]:GetNumberofGlobalFranchises())
                end,
                sortKey = function(r)
                    return Players[r.player]:GetNumberofGlobalFranchises()
                end,
                pediaName = worldCorpLabel,
            },
        },
        rebuildRows = rebuildWorldCorpRows,
        rowLabel = worldCorpLabel,
    })
end

-- ===== World Franchises tab =============================================

local function rebuildWorldFranchiseRows()
    local rows = {}
    for i = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local host = Players[i]
        if host ~= nil and host:IsEverAlive() and host:IsAlive() then
            for city in host:Cities() do
                for from = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
                    if city:IsFranchised(from) then
                        rows[#rows + 1] = { city = city, host = i, from = from }
                    end
                end
            end
        end
    end
    table.sort(rows, function(a, b)
        return Locale.Compare(civDisplayName(Players[a.from]), civDisplayName(Players[b.from])) == -1
    end)
    return rows
end

local function franchiseCorpName(r)
    local eCorp = Players[r.from]:GetCorporation()
    if eCorp == -1 then
        return ""
    end
    local info = GameInfo.Corporations[eCorp]
    if info == nil then
        return ""
    end
    return Text.key(info.Description)
end

local function jumpRowCity(r)
    jumpToCity(r.city)
end

local function buildWorldFranchisesTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CIVVACCESS_CORP_TAB_WORLD_FRANCHISES",
        columns = {
            {
                name = "TXT_KEY_CPO_WF_CIVILIZATION",
                getCell = function(r)
                    return civDisplayName(Players[r.from])
                end,
                sortKey = function(r)
                    return civDisplayName(Players[r.from])
                end,
                enterAction = jumpRowCity,
            },
            {
                name = "TXT_KEY_CPO_WF_CORPNAME",
                getCell = franchiseCorpName,
                sortKey = franchiseCorpName,
                enterAction = jumpRowCity,
                pediaName = function(r)
                    local name = franchiseCorpName(r)
                    if name == "" then
                        return nil
                    end
                    return name
                end,
            },
            {
                name = "TXT_KEY_CPO_WF_CIVILIZATION_TO",
                getCell = function(r)
                    return civDisplayName(Players[r.host])
                end,
                sortKey = function(r)
                    return civDisplayName(Players[r.host])
                end,
                enterAction = jumpRowCity,
            },
        },
        rebuildRows = rebuildWorldFranchiseRows,
        rowLabel = function(r)
            return r.city:GetName()
        end,
    })
end

-- ===== Install ==========================================================

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    local monopoliesTab = buildMonopoliesTab()
    local yourCorpTab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CPO_TAB_CORPORATIONS",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CPO"),
            items = {},
        },
    })
    local officesTab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CPO_YC_PULLDOWN_TYPE_OFFICES",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CPO"),
            items = {},
        },
    })
    local worldCorpsTab = buildWorldCorpsTab()
    local worldFranchisesTab = buildWorldFranchisesTab()

    -- Decorate each tab's activation: drive the vendor's tab button and
    -- view pulldown first (visual sync for a sighted spectator), rebuild
    -- the menu tabs' items, then run the tab's own lifecycle speech.
    local function decorate(tab, syncFn, rebuildFn)
        local baseActivated = tab.onTabActivated
        tab.onTabActivated = function(self, announce)
            Log.tryCall("CorporationsOverview panel sync '" .. tostring(tab.tabName) .. "'", syncFn)
            if rebuildFn ~= nil then
                local ok, items = pcall(rebuildFn)
                if ok then
                    tab.menu().setItems(items)
                else
                    Log.error("CorporationsOverview tab rebuild failed: " .. tostring(items))
                end
            end
            baseActivated(self, announce)
        end
    end

    decorate(monopoliesTab, function()
        TabSelect("Monopolies")
    end, nil)
    decorate(yourCorpTab, function()
        TabSelect("Corporations")
        OnYourCorporationPulldown(1)
    end, buildYourCorpItems)
    decorate(officesTab, function()
        TabSelect("Corporations")
        OnYourCorporationPulldown(2)
    end, buildOfficesItems)
    decorate(worldCorpsTab, function()
        TabSelect("WorldCorporations")
        OnWorldCorporationsPulldown(1)
    end, nil)
    decorate(worldFranchisesTab, function()
        TabSelect("WorldCorporations")
        OnWorldCorporationsPulldown(2)
    end, nil)

    TabbedShell.install(ContextPtr, {
        name = "CorporationsOverview",
        displayName = Text.key("TXT_KEY_CPO"),
        tabs = { monopoliesTab, yourCorpTab, officesTab, worldCorpsTab, worldFranchisesTab },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
    })
end

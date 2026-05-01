-- Economic Overview accessibility (F2 / Domestic Advisor). Wraps the engine
-- popup as a four-tab TabbedShell:
--
--   Cities    -- BaseTable, one row per owned city, columns for population,
--                 name, defensive strength, food, science, gold, culture,
--                 faith, production. Sortable on every column. Enter on the
--                 Production cell opens the city's Choose Production popup;
--                 Enter on the Name cell focuses the city on the map.
--   Gold      -- BaseMenu list, treasury / income / expense breakdown with
--                 expandable per-city sub-lists for cities, trade routes,
--                 and building maintenance.
--   Happiness -- BaseMenu list, combined happiness and unhappiness sources
--                 (engine pairs them in one column already), per-city
--                 expansions for resources, buildings, trade routes, local
--                 cities, and per-city unhappiness with occupation flag.
--   Resources -- BaseMenu list, four collapsible sections: Available,
--                 Imported, Exported, Local. Lists each resource and its
--                 net count. Bonus resources excluded.
--
-- Initial tab is Cities (the densest user-facing data; matches the engine's
-- default landing tab "General Information" of which the city table is the
-- right pane).
--
-- Engine integration: the base game ships
-- Assets/UI/InGame/Popups/EconomicOverview.lua which we override with a
-- verbatim copy plus an include line for this module. The override-as-extend
-- pattern keeps the engine's button registration, popup queueing, and
-- GameplaySetActivePlayer wiring intact, and our include() at the tail wires
-- the TabbedShell on top.

include("CivVAccess_PopupBoot")
include("CivVAccess_TabbedShell")
include("CivVAccess_BaseTableCore")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Module table for testability. Exposes the pure helpers and column-spec
-- builder so tests can dofile this module and exercise them without going
-- through TabbedShell.install (which needs a real ContextPtr). Not a
-- standalone "logic module" -- just a thin export from the wrapper file
-- so the column shape can be inspected and the formatters covered.
EconomicOverviewAccess = EconomicOverviewAccess or {}

-- Active player accessor with no-cache rule: every announce site re-queries
-- so the values track the engine even though F2 freezes the simulation while
-- open (a load-from-game would still wipe upvalue closures).
local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

-- Format a signed yield as "+N" / "0" / "-N". Speech reads "+5" as "plus 5"
-- which is desirable for net food / science / etc.; tostring drops the sign
-- of positives.
local function formatSigned(n)
    if n == nil then
        return "0"
    end
    if n > 0 then
        return "+" .. tostring(n)
    end
    return tostring(n)
end

-- Format a "times100" gold value into a human number. Engine returns most
-- gold values multiplied by 100 to preserve fractions; we divide and pass
-- through Locale.ToNumber for the player's locale formatting.
local function formatGoldT100(t100)
    return Locale.ToNumber((t100 or 0) / 100, "#.##")
end

local function formatNumber(n)
    return Locale.ToNumber(n or 0, "#.##")
end

-- ===== Cities tab ======================================================

-- Annotation suffix appended to a city's name to surface Capital / Puppet /
-- Occupied state. Returns nil when the city is unannotated so the row
-- label is just the bare name.
local function cityAnnotation(city)
    if city:IsCapital() then
        return Text.key("TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL")
    end
    if city:IsPuppet() then
        return Text.key("TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET")
    end
    if city:IsOccupied() and not city:IsNoOccupiedUnhappiness() then
        return Text.key("TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED")
    end
    return nil
end

local function cityRowLabel(city)
    local name = city:GetName()
    local annot = cityAnnotation(city)
    if annot ~= nil then
        return Text.format("TXT_KEY_CIVVACCESS_EO_CITY_LABEL", name, annot)
    end
    return name
end

local function rebuildCityRows()
    local p = activePlayer()
    if p == nil then
        return {}
    end
    local rows = {}
    for c in p:Cities() do
        rows[#rows + 1] = c
    end
    return rows
end

-- Production yield includes the city's percent modifier (matches engine
-- EconomicGeneralInfo.lua's totalProductionPerTurn computation).
local function cityProductionPerTurn(city)
    local base = city:GetYieldRate(YieldTypes.YIELD_PRODUCTION)
    return math.floor(base + (base * (city:GetProductionModifier() / 100)))
end

-- Cell text for the production column: "<turns> turns: <name>" when a build
-- is queued, "<name>" if a process is in production (no turns), or "no
-- production" when the queue is empty.
local function productionCellText(city)
    local nameKey = city:GetProductionNameKey()
    local nameText
    if nameKey == nil or nameKey == "" then
        nameText = Text.key("TXT_KEY_CIVVACCESS_EO_PROD_NONE")
    else
        nameText = Text.key(nameKey)
    end
    if city:IsProduction() and not city:IsProductionProcess()
        and city:GetCurrentProductionDifferenceTimes100(false, false) > 0 then
        local turns = city:GetProductionTurnsLeft()
        if turns ~= nil and turns > 0 then
            return Text.formatPlural("TXT_KEY_CIVVACCESS_EO_PROD_CELL", turns, turns, nameText)
        end
    end
    return nameText
end

-- Cell text combining the production-per-turn yield with the queued-item
-- description, so a single column conveys both rate and target. Sort by
-- the rate so columnar comparison is meaningful.
local function productionColumnCell(city)
    return Text.format(
        "TXT_KEY_CIVVACCESS_EO_PROD_FULL",
        cityProductionPerTurn(city),
        productionCellText(city)
    )
end

local function focusCity(city)
    UI.LookAt(city:Plot(), 0)
    UI.SelectCity(city)
end

local function openChooseProduction(city)
    local popup = {
        Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION,
        Data1 = city:GetID(),
        Data2 = -1,
        Data3 = -1,
        Option1 = false,
        Option2 = false,
    }
    Events.SerialEventGameMessagePopup(popup)
end

-- Per-stat Civilopedia anchor. Each stat column gets a constant pediaName
-- routing Ctrl+I to the matching concept article. The strings are the raw
-- TXT_KEY of each concept's Description, which CivilopediaScreen indexes
-- in searchableTextKeyList.
local function constPedia(textKey)
    return function(_) return textKey end
end

local function buildCityColumns()
    local cols = {
        {
            name = "TXT_KEY_CIVVACCESS_EO_COL_POPULATION",
            getCell = function(c) return tostring(c:GetPopulation()) end,
            sortKey = function(c) return c:GetPopulation() end,
            pediaName = constPedia("TXT_KEY_FOOD_CITYGROWTH_HEADING2_TITLE"),
        },
        {
            name = "TXT_KEY_PRODPANEL_CITY_NAME",
            getCell = function(c) return c:GetName() end,
            sortKey = function(c) return c:GetName() end,
            enterAction = focusCity,
        },
        {
            name = "TXT_KEY_CIVVACCESS_EO_COL_STRENGTH",
            getCell = function(c) return tostring(math.floor(c:GetStrengthValue() / 100)) end,
            sortKey = function(c) return c:GetStrengthValue() end,
            pediaName = constPedia("TXT_KEY_COMBAT_COMBATSTRENGTH_HEADING3_TITLE"),
        },
        {
            name = "TXT_KEY_CIVVACCESS_EO_COL_FOOD",
            getCell = function(c) return formatSigned(c:FoodDifference()) end,
            sortKey = function(c) return c:FoodDifference() end,
            pediaName = constPedia("TXT_KEY_FOOD_HEADING1_TITLE"),
        },
    }
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
        cols[#cols + 1] = {
            name = "TXT_KEY_CIVVACCESS_EO_COL_SCIENCE",
            getCell = function(c) return formatSigned(c:GetYieldRate(YieldTypes.YIELD_SCIENCE)) end,
            sortKey = function(c) return c:GetYieldRate(YieldTypes.YIELD_SCIENCE) end,
            pediaName = constPedia("TXT_KEY_TECH_HEADING1_TITLE"),
        }
    end
    cols[#cols + 1] = {
        name = "TXT_KEY_CIVVACCESS_EO_COL_GOLD",
        getCell = function(c) return formatSigned(c:GetYieldRate(YieldTypes.YIELD_GOLD)) end,
        sortKey = function(c) return c:GetYieldRate(YieldTypes.YIELD_GOLD) end,
        pediaName = constPedia("TXT_KEY_GOLD_HEADING1_TITLE"),
    }
    cols[#cols + 1] = {
        name = "TXT_KEY_CIVVACCESS_EO_COL_CULTURE",
        getCell = function(c) return formatSigned(c:GetJONSCulturePerTurn()) end,
        sortKey = function(c) return c:GetJONSCulturePerTurn() end,
        pediaName = constPedia("TXT_KEY_CULTURE_HEADING1_TITLE"),
    }
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
        cols[#cols + 1] = {
            name = "TXT_KEY_CIVVACCESS_EO_COL_FAITH",
            getCell = function(c) return formatSigned(c:GetFaithPerTurn()) end,
            sortKey = function(c) return c:GetFaithPerTurn() end,
            pediaName = constPedia("TXT_KEY_CONCEPT_RELIGION_FAITH_EARNING_DESCRIPTION"),
        }
    end
    cols[#cols + 1] = {
        name = "TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION",
        getCell = productionColumnCell,
        sortKey = cityProductionPerTurn,
        enterAction = openChooseProduction,
        -- Ctrl+I jumps to the queued building / unit / process article. The
        -- production name key is what GetProductionNameKey returns directly;
        -- localize for the lowercase pedia search index.
        pediaName = function(c)
            local key = c:GetProductionNameKey()
            if key == nil or key == "" then
                return nil
            end
            return Text.key(key)
        end,
    }
    return cols
end

local function buildCitiesTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CIVVACCESS_EO_TAB_CITIES",
        columns = buildCityColumns(),
        rebuildRows = rebuildCityRows,
        rowLabel = cityRowLabel,
    })
end

-- ===== Gold tab =======================================================

local function goldTextItem(labelKey, valueFn)
    return BaseMenuItems.Text({
        labelFn = function()
            return Text.format(labelKey, valueFn())
        end,
    })
end

-- Per-city sub-list builder: each city contributing a non-zero amount becomes
-- a Text row labeled "<city>: <amount>". cached=false on the parent group so
-- each drill-in re-queries (turns can elapse off-screen via end-turn from a
-- nested popup, even though F2 itself is read-only).
local function perCityGoldEntries(amountFn, includePred)
    local p = activePlayer()
    if p == nil then
        return {}
    end
    local items = {}
    for city in p:Cities() do
        if includePred == nil or includePred(p, city) then
            local amount = amountFn(p, city)
            if amount and amount ~= 0 then
                local row = {
                    name = city:GetName(),
                    amount = amount,
                }
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.format("TXT_KEY_CIVVACCESS_EO_CITY_LINE", row.name, formatNumber(row.amount)),
                })
            end
        end
    end
    if #items == 0 then
        items[1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY") })
    end
    return items
end

local function buildGoldItems()
    local items = {
        goldTextItem("TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL", function()
            return formatNumber(activePlayer():GetGold())
        end),
        goldTextItem("TXT_KEY_CIVVACCESS_EO_GOLD_NET", function()
            return formatGoldT100(activePlayer():CalculateGoldRateTimes100())
        end),
        goldTextItem("TXT_KEY_CIVVACCESS_EO_GOLD_PENALTY", function()
            local p = activePlayer()
            local net = p:CalculateGoldRateTimes100() / 100
            if net >= 0 then
                return Text.key("TXT_KEY_CIVVACCESS_EO_NONE")
            end
            return formatGoldT100(p:GetScienceFromBudgetDeficitTimes100())
        end),
        goldTextItem("TXT_KEY_CIVVACCESS_EO_GOLD_GROSS", function()
            return formatGoldT100(activePlayer():CalculateGrossGoldTimes100())
        end),
        goldTextItem("TXT_KEY_CIVVACCESS_EO_GOLD_EXPENSES", function()
            return formatNumber(activePlayer():CalculateInflatedCosts())
        end),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_INCOME"),
            cached = false,
            itemsFn = function()
                return {
                    BaseMenuItems.Group({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_INCOME_CITIES",
                                formatGoldT100(activePlayer():GetGoldFromCitiesTimes100())
                            )
                        end,
                        cached = false,
                        itemsFn = function()
                            return perCityGoldEntries(function(_, c)
                                return c:GetYieldRateTimes100(YieldTypes.YIELD_GOLD) / 100
                            end)
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            local v = activePlayer():GetGoldPerTurnFromDiplomacy()
                            if v < 0 then v = 0 end
                            return Text.format("TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO", formatNumber(v))
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            local v = activePlayer():GetGoldPerTurnFromReligion()
                            if v < 0 then v = 0 end
                            return Text.format("TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION", formatNumber(v))
                        end,
                    }),
                    BaseMenuItems.Group({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_INCOME_TRADE",
                                formatGoldT100(activePlayer():GetCityConnectionGoldTimes100())
                            )
                        end,
                        cached = false,
                        itemsFn = function()
                            return perCityGoldEntries(
                                function(p, c)
                                    return p:GetCityConnectionRouteGoldTimes100(c) / 100
                                end,
                                function(p, c)
                                    return p:IsCapitalConnectedToCity(c)
                                end
                            )
                        end,
                    }),
                }
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_EXPENSES"),
            cached = false,
            itemsFn = function()
                return {
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS",
                                formatNumber(activePlayer():CalculateUnitCost())
                            )
                        end,
                    }),
                    BaseMenuItems.Group({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS",
                                formatNumber(activePlayer():GetBuildingGoldMaintenance())
                            )
                        end,
                        cached = false,
                        itemsFn = function()
                            return perCityGoldEntries(function(_, c)
                                return c:GetTotalBaseBuildingMaintenance()
                            end)
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS",
                                formatNumber(activePlayer():GetImprovementGoldMaintenance())
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            local v = activePlayer():GetGoldPerTurnFromDiplomacy()
                            if v > 0 then v = 0 else v = -v end
                            return Text.format("TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO", formatNumber(v))
                        end,
                    }),
                }
            end,
        }),
    }
    return items
end

local function buildGoldTab()
    return TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_EO_TAB_GOLD",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CIVVACCESS_EO_TAB_GOLD"),
            items = buildGoldItems(),
        },
    })
end

-- ===== Happiness tab ===================================================

-- Per-city happiness sub-list. amountFn returns the per-city amount;
-- annotateFn (optional) returns a string suffix appended to the row, used
-- by the unhappiness breakdown to flag occupied cities.
local function perCityHappinessEntries(amountFn, includePred, annotateFn)
    local p = activePlayer()
    if p == nil then
        return {}
    end
    local items = {}
    for city in p:Cities() do
        if includePred == nil or includePred(p, city) then
            local amount = amountFn(p, city)
            local label
            local annot = annotateFn and annotateFn(p, city) or nil
            if annot ~= nil and annot ~= "" then
                label = Text.format(
                    "TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT",
                    city:GetName(),
                    formatNumber(amount or 0),
                    annot
                )
            else
                label = Text.format(
                    "TXT_KEY_CIVVACCESS_EO_CITY_LINE",
                    city:GetName(),
                    formatNumber(amount or 0)
                )
            end
            items[#items + 1] = BaseMenuItems.Text({ labelText = label })
        end
    end
    if #items == 0 then
        items[1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY") })
    end
    return items
end

local function perLuxuryHappinessEntries()
    local p = activePlayer()
    if p == nil then
        return {}
    end
    local items = {}
    for resource in GameInfo.Resources() do
        local h = p:GetHappinessFromLuxury(resource.ID)
        if h and h > 0 then
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format(
                    "TXT_KEY_CIVVACCESS_EO_CITY_LINE",
                    Text.key(resource.Description),
                    formatNumber(h)
                ),
                pediaName = Text.key(resource.Description),
            })
        end
    end
    if #items == 0 then
        items[1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY") })
    end
    return items
end

local function buildHappinessItems()
    return {
        BaseMenuItems.Text({
            labelFn = function()
                return Text.format(
                    "TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL",
                    activePlayer():GetHappiness()
                )
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"),
            cached = false,
            itemsFn = function()
                local p = activePlayer()
                return {
                    BaseMenuItems.Group({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES",
                                activePlayer():GetHappinessFromResources()
                            )
                        end,
                        cached = false,
                        itemsFn = perLuxuryHappinessEntries,
                    }),
                    BaseMenuItems.Group({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS",
                                activePlayer():GetHappinessFromBuildings()
                            )
                        end,
                        cached = false,
                        itemsFn = function()
                            return perCityHappinessEntries(function(_, c)
                                return c:GetHappiness()
                            end)
                        end,
                    }),
                    BaseMenuItems.Group({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES",
                                activePlayer():GetHappinessFromTradeRoutes()
                            )
                        end,
                        cached = false,
                        itemsFn = function()
                            return perCityHappinessEntries(
                                function(player)
                                    return player:GetHappinessPerTradeRoute() / 100
                                end,
                                function(player, c)
                                    return not c:IsCapital() and player:IsCapitalConnectedToCity(c)
                                end
                            )
                        end,
                    }),
                    BaseMenuItems.Group({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_LOCAL_CITIES",
                                activePlayer():GetHappinessFromCities()
                            )
                        end,
                        cached = false,
                        itemsFn = function()
                            return perCityHappinessEntries(function(_, c)
                                return c:GetLocalHappiness()
                            end)
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES",
                                activePlayer():GetHappinessFromMinorCivs()
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES",
                                activePlayer():GetHappinessFromPolicies()
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION",
                                activePlayer():GetHappinessFromReligion()
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS",
                                activePlayer():GetHappinessFromNaturalWonders()
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            local pl = activePlayer()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_FREE_PER_CITY",
                                pl:GetExtraHappinessPerCity() * pl:GetNumCities()
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_HAPPY_LEAGUES",
                                activePlayer():GetHappinessFromLeagues()
                            )
                        end,
                    }),
                }
            end,
        }),
        BaseMenuItems.Text({
            labelFn = function()
                return Text.format(
                    "TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL",
                    activePlayer():GetUnhappiness()
                )
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"),
            cached = false,
            itemsFn = function()
                return {
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES",
                                formatGoldT100(activePlayer():GetUnhappinessFromCityCount())
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES",
                                formatGoldT100(activePlayer():GetUnhappinessFromCapturedCityCount())
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION",
                                formatGoldT100(activePlayer():GetUnhappinessFromCityPopulation())
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP",
                                formatGoldT100(activePlayer():GetUnhappinessFromOccupiedCities())
                            )
                        end,
                    }),
                    BaseMenuItems.Text({
                        labelFn = function()
                            return Text.format(
                                "TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION",
                                activePlayer():GetUnhappinessFromPublicOpinion()
                            )
                        end,
                    }),
                    BaseMenuItems.Group({
                        labelText = Text.key("TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"),
                        cached = false,
                        itemsFn = function()
                            return perCityHappinessEntries(
                                function(p, c)
                                    return p:GetUnhappinessFromCityForUI(c) / 100
                                end,
                                nil,
                                function(_, c)
                                    if c:IsOccupied() and not c:IsNoOccupiedUnhappiness() then
                                        return Text.key("TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG")
                                    end
                                    return nil
                                end
                            )
                        end,
                    }),
                }
            end,
        }),
    }
end

local function buildHappinessTab()
    return TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"),
            items = buildHappinessItems(),
        },
    })
end

-- ===== Resources tab ===================================================

-- Skip ResourceUsageTypes.RESOURCEUSAGE_BONUS so the lists stay focused on
-- luxuries and strategics (matches engine HappinessInfo's resource panels).
local function isLuxOrStrategic(resourceID)
    return Game.GetResourceUsageType(resourceID) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS
end

local function resourceEntries(amountFn)
    local p = activePlayer()
    if p == nil then
        return {}
    end
    local items = {}
    for resource in GameInfo.Resources() do
        if isLuxOrStrategic(resource.ID) then
            local amount = amountFn(p, resource.ID)
            if amount and amount > 0 then
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.format(
                        "TXT_KEY_CIVVACCESS_EO_CITY_LINE",
                        Text.key(resource.Description),
                        amount
                    ),
                    pediaName = Text.key(resource.Description),
                })
            end
        end
    end
    if #items == 0 then
        items[1] = BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY") })
    end
    return items
end

local function buildResourcesItems()
    return {
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"),
            cached = false,
            itemsFn = function()
                return resourceEntries(function(p, id)
                    return p:GetNumResourceTotal(id, true)
                end)
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"),
            cached = false,
            itemsFn = function()
                return resourceEntries(function(p, id)
                    return p:GetResourceImport(id)
                end)
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"),
            cached = false,
            itemsFn = function()
                return resourceEntries(function(p, id)
                    return p:GetResourceExport(id)
                end)
            end,
        }),
        BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_EO_RES_LOCAL"),
            cached = false,
            itemsFn = function()
                return resourceEntries(function(p, id)
                    return p:GetNumResourceTotal(id, false) + p:GetResourceExport(id)
                end)
            end,
        }),
    }
end

local function buildResourcesTab()
    return TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"),
            items = buildResourcesItems(),
        },
    })
end

-- ===== Module exports for tests ========================================

EconomicOverviewAccess.formatSigned = formatSigned
EconomicOverviewAccess.formatGoldT100 = formatGoldT100
EconomicOverviewAccess.formatNumber = formatNumber
EconomicOverviewAccess.cityAnnotation = cityAnnotation
EconomicOverviewAccess.cityRowLabel = cityRowLabel
EconomicOverviewAccess.cityProductionPerTurn = cityProductionPerTurn
EconomicOverviewAccess.productionColumnCell = productionColumnCell
EconomicOverviewAccess.buildCityColumns = buildCityColumns
EconomicOverviewAccess.rebuildCityRows = rebuildCityRows

-- ===== Install =========================================================

-- Guarded so tests can dofile the wrapper to inspect helpers and column
-- specs without satisfying the full Context fixture. In-game ContextPtr is
-- a real userdata with these methods; the offline harness leaves it absent.
if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    TabbedShell.install(ContextPtr, {
        name = "EconomicOverview",
        displayName = Text.key("TXT_KEY_ECONOMIC_OVERVIEW"),
        tabs = {
            buildCitiesTab(),
            buildGoldTab(),
            buildHappinessTab(),
            buildResourcesTab(),
        },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
    })
end

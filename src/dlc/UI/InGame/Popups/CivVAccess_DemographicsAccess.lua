-- Demographics accessibility (F9). Wraps the engine Demographics popup as
-- a flat BaseMenu list: one row per metric (Population, Crop Yield, GNP,
-- etc.), each speaking the active player's value, rank, and the rival
-- best / average / worst figures in vanilla column order. The screen has
-- no useful secondary axis -- rows are heterogeneous metrics, not sortable
-- like F2's city table -- so a flat list is the natural shape; vanilla's
-- table is visual scaffolding, not strategic structure.
--
-- Per-metric formulas mirror Demographics.lua's GetXValue functions
-- verbatim so the numbers a sighted onlooker sees in the column match
-- what we speak. Locale.ToNumber with vanilla's format strings keeps
-- comma grouping locale-correct.
--
-- All values are recomputed on every show via onShow -> setItems so the
-- ranking tracks the engine across turn ends. No upvalue caching.
--
-- Engine integration: ships an override of Demographics.lua (verbatim
-- base copy + an include for this module). The engine's OnPopup, OnBack,
-- ShowHideHandler, InputHandler, and GameplaySetActivePlayer wiring stay
-- intact; BaseMenu.install layers our handler on top via priorInput /
-- priorShowHide chains.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
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
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

DemographicsAccess = DemographicsAccess or {}

-- ===== Player / team helpers ==========================================

local function activePlayerId()
    return Game.GetActivePlayer()
end

local function activeTeamId()
    return Game.GetActiveTeam()
end

local function isMP()
    return Game:IsNetworkMultiPlayer()
end

local function playerHasMet(pPlayer)
    return Teams[pPlayer:GetTeam()]:IsHasMet(activeTeamId()) or isMP()
end

-- Met / unmet / active-player / nickname branches mirror vanilla SetCivName.
-- Unmet civs read as "Unknown Civilization" so a sighted player's "?" icon
-- maps to a speakable noun phrase. Same shape as VictoryProgressAccess's
-- helper -- duplicated rather than imported because Popup Contexts each
-- run their own include chain and a cross-Context module reference would
-- break under load-from-game's env wipe.
local function civDisplayName(pPlayer)
    if not playerHasMet(pPlayer) then
        return Locale.ConvertTextKey("TXT_KEY_MISC_UNKNOWN")
    end
    local civInfo = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
    local strPlayer
    local nick = pPlayer:GetNickName()
    if nick ~= "" and isMP() then
        strPlayer = nick
    elseif pPlayer:GetID() == activePlayerId() then
        strPlayer = "TXT_KEY_POP_VOTE_RESULTS_YOU"
    else
        strPlayer = pPlayer:GetNameKey()
    end
    return Locale.ConvertTextKey("TXT_KEY_RANDOM_LEADER_CIV", strPlayer, civInfo.ShortDescription)
end

-- Major civs that are currently alive. Vanilla's GetBest / GetWorst /
-- GetAverage / GetRank iterate Players[0..MAX_MAJOR_CIVS] filtering by
-- IsAlive + not IsMinorCiv. Match that filter exactly so our ranks line
-- up with vanilla's column. (City-states never appear on Demographics.)
local function eachMajorAlive()
    local i = -1
    return function()
        while true do
            i = i + 1
            if i > GameDefines.MAX_MAJOR_CIVS then
                return nil
            end
            local p = Players[i]
            if p ~= nil and p:IsAlive() and not p:IsMinorCiv() then
                return i, p
            end
        end
    end
end

-- ===== Number formatters ==============================================

-- Match vanilla Demographics format strings ("#,###,###,###" for the six
-- raw-number metrics, "#'%'" for the two percentage metrics) so a sighted
-- onlooker hears the same number they see in the column.
local function formatBig(n)
    return Locale.ToNumber(n, "#,###,###,###")
end

local function formatPct(n)
    return Locale.ToNumber(n, "#'%'")
end

-- ===== Per-metric value queries =======================================
--
-- Each function returns the player's raw value for the metric. Formulas
-- mirror Demographics.lua's GetXValue functions verbatim. Re-queried on
-- every announce; never cached.

local function valuePopulation(pPlayer)
    return pPlayer:GetRealPopulation()
end

local function valueFood(pPlayer)
    return pPlayer:CalculateTotalYield(YieldTypes.YIELD_FOOD)
end

local function valueProduction(pPlayer)
    return pPlayer:CalculateTotalYield(YieldTypes.YIELD_PRODUCTION)
end

local function valueGold(pPlayer)
    return pPlayer:CalculateGrossGold()
end

local function valueLand(pPlayer)
    return pPlayer:GetNumPlots() * 10000
end

local function valueArmy(pPlayer)
    return math.sqrt(pPlayer:GetMilitaryMight()) * 2000
end

-- 60 baseline (zero excess happiness) plus 3 points per surplus, clamped
-- to 0..100. Matches Demographics.lua's GetApprovalValue.
local function valueApproval(pPlayer)
    local v = 60 + (pPlayer:GetExcessHappiness() * 3)
    if v < 0 then return 0 end
    if v > 100 then return 100 end
    return v
end

-- Percentage of techs researched. Returns 0 until Writing -- vanilla's
-- explicit gate, since pre-Writing civs lack the institutional capacity
-- to be measured on the demographic.
local function valueLiteracy(pPlayer)
    local pTeamTechs = Teams[pPlayer:GetTeam()]:GetTeamTechs()
    local iWriting = GameInfoTypes["TECH_WRITING"]
    if iWriting ~= nil and not pTeamTechs:HasTech(iWriting) then
        return 0
    end
    local iCount = 0
    for row in GameInfo.Technologies() do
        if pTeamTechs:HasTech(row.ID) then
            iCount = iCount + 1
        end
    end
    return 100 * iCount / #GameInfo.Technologies
end

-- ===== Aggregations ===================================================

-- Best / worst pick the leading and trailing major civ across all majors
-- alive. Returns (value, pPlayer); both nil if no civs are alive (the
-- game shouldn't reach Demographics in that state, but the row builder
-- treats nil holders as the active player so the row still speaks).
local function bestOf(valueFn)
    local highest, holder
    for _, p in eachMajorAlive() do
        local v = valueFn(p)
        if highest == nil or v > highest then
            highest = v
            holder = p
        end
    end
    return highest, holder
end

local function worstOf(valueFn)
    local lowest, holder
    for _, p in eachMajorAlive() do
        local v = valueFn(p)
        if lowest == nil or v <= lowest then
            lowest = v
            holder = p
        end
    end
    return lowest, holder
end

local function averageOf(valueFn)
    local accum, count = 0, 0
    for _, p in eachMajorAlive() do
        accum = accum + valueFn(p)
        count = count + 1
    end
    if count == 0 then return 0 end
    return accum / count
end

-- 1-based rank: count of major-civs whose value strictly exceeds ours,
-- plus one. Ties share a rank (matches vanilla GetRank).
local function rankOf(valueFn, pSelf)
    local selfVal = valueFn(pSelf)
    local rank = 1
    for _, p in eachMajorAlive() do
        if valueFn(p) > selfVal then
            rank = rank + 1
        end
    end
    return rank
end

-- ===== Row composition ================================================

-- One Text item per metric. labelFn re-evaluates on every announce so
-- arrow / re-show navigation always reflects current game state. Format
-- mirrors vanilla's left-to-right column order: name, rank, value, best
-- (with civ), average, worst (with civ).
--
-- measureKey is the engine's per-metric unit string (vanilla shows it as
-- the value-cell tooltip: "Million Bushels", "Million Tons", "Square KM",
-- etc.). The raw-number metrics are flavor-scaled by the engine -- GNP
-- "50" is really 50 GPT, Crop Yield "200" is really 200 food per turn --
-- so speaking the unit on the active player's value lets the listener
-- recognize the scaling. Skipped where the unit is already implied:
-- Soldiers (metric name and unit are both "Soldiers" in vanilla),
-- Approval, and Literacy (the "%" suffix in formatPct already encodes
-- the unit on every value).
--
-- magSuffix is a short magnitude marker tacked onto the comparison
-- numbers (best / average / worst) for metrics whose unit prefix is
-- "Million" -- without it, the listener hears "200 Million Bushels,
-- best Persia 350" and can't tell whether 350 means 350 bushels or
-- 350 million bushels. Population and Land sidestep this because their
-- digit-grouped numbers (12,345,678 / 1,000,000) read with magnitude
-- already in the digit count.
local function metricRow(labelKey, valueFn, formatFn, measureKey, magSuffix)
    return BaseMenuItems.Text({
        labelFn = function()
            local pSelf = Players[activePlayerId()]
            local rank = rankOf(valueFn, pSelf)
            local selfVal = formatFn(valueFn(pSelf))
            if measureKey ~= nil then
                selfVal = selfVal .. " " .. Text.key(measureKey)
            end
            local function shortVal(rawVal)
                local s = formatFn(rawVal)
                if magSuffix ~= nil then
                    s = s .. magSuffix
                end
                return s
            end
            local bestRaw, bestP = bestOf(valueFn)
            local worstRaw, worstP = worstOf(valueFn)
            local avgRaw = averageOf(valueFn)
            return Text.format(
                "TXT_KEY_CIVVACCESS_DEMO_ROW",
                Text.key(labelKey),
                rank,
                selfVal,
                civDisplayName(bestP or pSelf),
                shortVal(bestRaw or 0),
                shortVal(avgRaw),
                civDisplayName(worstP or pSelf),
                shortVal(worstRaw or 0)
            )
        end,
    })
end

local function buildItems()
    return {
        metricRow("TXT_KEY_DEMOGRAPHICS_POPULATION", valuePopulation, formatBig, "TXT_KEY_DEMOGRAPHICS_POPULATION_MEASURE", nil),
        metricRow("TXT_KEY_DEMOGRAPHICS_FOOD",       valueFood,       formatBig, "TXT_KEY_DEMOGRAPHICS_FOOD_MEASURE",       "m"),
        metricRow("TXT_KEY_DEMOGRAPHICS_PRODUCTION", valueProduction, formatBig, "TXT_KEY_DEMOGRAPHICS_PRODUCTION_MEASURE", "m"),
        -- Spell out vanilla's "GNP" acronym for speech; the underlying value
        -- and unit ("Million Gold") stay engine-sourced.
        metricRow("TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD", valueGold,       formatBig, "TXT_KEY_DEMOGRAPHICS_GOLD_MEASURE",       "m"),
        metricRow("TXT_KEY_DEMOGRAPHICS_LAND",       valueLand,       formatBig, "TXT_KEY_DEMOGRAPHICS_LAND_MEASURE",       nil),
        metricRow("TXT_KEY_DEMOGRAPHICS_ARMY",       valueArmy,       formatBig, nil,                                       nil),
        metricRow("TXT_KEY_DEMOGRAPHICS_APPROVAL",   valueApproval,   formatPct, nil,                                       nil),
        metricRow("TXT_KEY_DEMOGRAPHICS_LITERACY",   valueLiteracy,   formatPct, nil,                                       nil),
    }
end

-- ===== Module exports for tests =======================================

DemographicsAccess.civDisplayName = civDisplayName
DemographicsAccess.valuePopulation = valuePopulation
DemographicsAccess.valueFood = valueFood
DemographicsAccess.valueProduction = valueProduction
DemographicsAccess.valueGold = valueGold
DemographicsAccess.valueLand = valueLand
DemographicsAccess.valueArmy = valueArmy
DemographicsAccess.valueApproval = valueApproval
DemographicsAccess.valueLiteracy = valueLiteracy
DemographicsAccess.bestOf = bestOf
DemographicsAccess.worstOf = worstOf
DemographicsAccess.averageOf = averageOf
DemographicsAccess.rankOf = rankOf
DemographicsAccess.buildItems = buildItems

-- ===== Install ========================================================

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    local handler = BaseMenu.install(ContextPtr, {
        name = "Demographics",
        displayName = Text.key("TXT_KEY_DEMOGRAPHICS_TITLE"),
        items = buildItems(),
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(h)
            h.setItems(buildItems())
        end,
    })

    -- F9 re-press toggles the popup shut, mirroring F8's pattern. The
    -- engine's own toggle (Data1==1 path in OnPopup) is bypassed because
    -- our handler captures input modally while the popup is up.
    if handler ~= nil and type(handler.bindings) == "table" then
        handler.bindings[#handler.bindings + 1] = {
            key = Keys.VK_F9,
            mods = 0,
            description = "Close Demographics",
            fn = function()
                UIManager:DequeuePopup(ContextPtr)
            end,
        }
    end
end

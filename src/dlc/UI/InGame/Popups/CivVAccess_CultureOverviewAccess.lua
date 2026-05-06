-- Culture Overview accessibility (Ctrl+C). Wraps the engine popup as a four-tab
-- TabbedShell. Tabs 1 and 2 are flat BaseMenu lists where the per-row data is
-- rich enough that drill-in is the natural shape; tabs 3 and 4 are BaseTables
-- because the engine renders both as multi-column sortable tables and parity
-- is best preserved by mirroring that shape.
--
--   Your Culture     -- per-city Group: name, culture/turn, tourism/turn, GW
--                       filled/total, damage. Drills into the city's GW-
--                       housing buildings (heritage row + any wonders the
--                       city owns), each of which drills into its slots.
--                       Slot Enter runs the move state machine; great-work
--                       details are surfaced via the slot's tooltip.
--                       The global antiquity-site count (visible + hidden)
--                       follows the city list as a one-line footer.
--   Swap Great Works -- three top-level rows. (1) Your offerings: drills
--                       into three Pulldowns wrapping the engine's per-type
--                       designation widgets; tooltip on each carries the
--                       engine's "other civs may swap for this without
--                       your permission" warning so the trade-asymmetry is
--                       visible to us as it is to sighted players. (2)
--                       Available from other civilizations: drills into
--                       civs with at least one designation, then into each
--                       civ's non-empty slots; activating a leaf queues
--                       that work as the swap target. (3) Trade item:
--                       state-aware label (nothing picked / picked but no
--                       matching designation on your side / ready) that
--                       fires Network.SendSwapGreatWorks on activate when
--                       ready and stays on the tab.
--                       Great-work reading on this tab matches Tab 1: the
--                       work name carries the label (with a type prefix on
--                       foreign leaves to disambiguate within a civ, like
--                       Tab 1's slot index inside a multi-slot building),
--                       and gwTooltip supplies the rich class/artist/
--                       origin/era/yields detail. Pulldown entries fold
--                       both into one announcement because pulldown
--                       entries have no separate tooltip-on-demand path.
--   Culture Victory  -- BaseTable, one row per met major civ alive. Civ
--                       short name is the row label; columns are
--                       Influencing count, Tourism per turn, Ideology,
--                       Public Opinion, Public Opinion Unhappiness, and
--                       Excess Happiness. Public Opinion Unhappiness
--                       appends the engine's breakdown tooltip; the
--                       other cells are bare values.
--   Player Influence -- BaseTable, one row per met major civ alive
--                       (excluding the current perspective). The
--                       perspective picker and the perspective's overall
--                       tourism header collapse into column 1 ("Change
--                       perspective"): each cell carries that civ's
--                       overall tourism rate plus a "press enter to
--                       switch" hint, and Enter mutates g_iSelectedPlayerID
--                       and speaks "now viewing from <civ>". Other columns:
--                       Influence Level (with bonuses-at-level tooltip),
--                       Influence Percent (with the absolute your-tourism
--                       vs their-lifetime-culture decomposition on
--                       tooltip), Tourism Modifier (with the engine
--                       breakdown on tooltip), Tourism Rate on Them
--                       (the per-target influence-per-turn), and Trend
--                       (with estimated turns to Influential on tooltip
--                       when applicable). The default perspective on
--                       first open is the active player; the engine
--                       does not reset g_iSelectedPlayerID on popup
--                       close, so a sighted player's perspective pick
--                       persists across reopen and we mirror that.
--
-- Initial tab is Your Culture (matches the engine's landing tab).
--
-- Engine integration: ships an override of CultureOverview.lua (verbatim BNW
-- copy + an include for this module). The engine's OnPopupMessage, OnClose,
-- ShowHideHandler, InputHandler, RegisterSortOptions, TabSelect("YourCulture"),
-- and SerialEvent*Dirty wiring stay intact; TabbedShell.install layers our
-- handler on top via priorInput / priorShowHide chains. SerialEventCityInfo-
-- Dirty refreshes Tab 1 (post GW-move slot states); SerialEventGreatWorks-
-- ScreenDirty refreshes Tab 2 (post designate / post swap, including swaps
-- another player initiated against our designations). onShow also calls the
-- engine's RefreshSwappingItems directly so the YourWriting/Art/Artifact
-- pulldowns are populated regardless of which engine tab landed.

include("CivVAccess_PopupBoot")
include("CivVAccess_OverviewCivLabels")
include("CivVAccess_TabbedShell")
include("CivVAccess_BaseTableCore")
include("CivVAccess_PullDownProbe")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

CultureOverviewAccess = CultureOverviewAccess or {}

-- ===== Module state ====================================================

-- Tab 1: GW move source. Mirror of the engine's g_CurrentGreatWorkSlot
-- but in our own state so the click-to-move flow is independent of the
-- engine widget callbacks (we don't reach across to the engine's
-- selection because that'd require driving SortAndDisplayYourCulture each
-- round-trip; cheaper to track our own and call Network.SendMoveGreatWorks
-- when the user lands a target).
local m_gwMoveSource = nil

-- Tab 2: queued swap target. The work the user picked from another civ's
-- offerings, plus that civ's player ID. The matching-type designation on
-- our side is derived live from the engine accessors at trade time so a
-- designation change between picking and trading can't leave a stale
-- pairing. Reset on every popup open and after a trade fires.
local m_swapTheirItem = -1
local m_swapTradingPartner = -1

-- Tab handles, set during install. onShow rebuilds each tab's items via
-- the menu accessor. Module-level so the SerialEvent*Dirty hooks can
-- refresh tabs mid-screen.
local m_yourCultureTab
local m_swapTab
local m_victoryTab
local m_influenceTab

-- Forward declaration. Tab 2's pulldown onSelected and foreign-offering
-- activate both rebuild the tab to refresh the trade item's state-aware
-- label.
local buildSwapItems

-- ===== Helpers =========================================================

local activePlayer = OverviewCivLabels.activePlayer
local activePlayerID = OverviewCivLabels.activePlayerId
local activeTeam = OverviewCivLabels.activeTeam
local isMP = OverviewCivLabels.isMP

local function formatSigned(n)
    if n == nil then
        return "0"
    end
    if n > 0 then
        return "+" .. tostring(n)
    end
    return tostring(n)
end

local function formatNumber(n)
    return Locale.ToNumber(n or 0, "#,###,###")
end

local civDisplayName = OverviewCivLabels.civDisplayName

-- Resolve a great work's creator to a speakable civ name. The engine can
-- return -1 here: the ARCHAEOLOGY_ARTIFACT_PLAYER2 path passes
-- ArchaeologicalRecord.m_ePlayer2 through to CreateGreatWork, and that
-- field is NO_PLAYER for ancient-ruin-derived artifacts (see
-- CvCultureClasses.cpp:6166). A nil pPlayer would crash civDisplayName
-- on its first method call.
local function gwCreatorName(gwIndex)
    local pCreator = Players[Game.GetGreatWorkCreator(gwIndex)]
    if pCreator == nil then
        return Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    return civDisplayName(pCreator)
end

-- Iterator over met major civs that are alive. CO's per-civ tabs filter on
-- alive + non-minor + has-met from the active team. MP exposes everyone.
local function eachMetMajorAlive()
    local i = -1
    return function()
        while true do
            i = i + 1
            if i >= GameDefines.MAX_CIV_PLAYERS then
                return nil
            end
            local p = Players[i]
            if p ~= nil and p:IsAlive() and not p:IsMinorCiv() and (activeTeam():IsHasMet(p:GetTeam()) or isMP()) then
                return i, p
            end
        end
    end
end

-- ===== Slot / class label maps =========================================

-- GreatWorkSlotType -> user-facing slot-type phrase. Surfaced once on the
-- building row so the user knows the kind of work that fits before drilling.
local SLOT_TYPE_KEY = {
    GREAT_WORK_SLOT_LITERATURE = "TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING",
    GREAT_WORK_SLOT_ART_ARTIFACT = "TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT",
    GREAT_WORK_SLOT_MUSIC = "TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC",
}

local function slotTypeLabel(slotType)
    local key = SLOT_TYPE_KEY[slotType]
    if key == nil then
        Log.error("CultureOverview: unknown GreatWorkSlotType '" .. tostring(slotType) .. "'")
        return Text.key("TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING")
    end
    return Text.key(key)
end

-- GreatWorkClassType -> user-facing class word. Used inside the slot
-- tooltip as the leading distinguisher ("art by ...", "writing by ...").
local WORK_CLASS_KEY = {
    GREAT_WORK_LITERATURE = "TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING",
    GREAT_WORK_ART = "TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART",
    GREAT_WORK_ARTIFACT = "TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT",
    GREAT_WORK_MUSIC = "TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC",
}

local function workClassLabel(classType)
    local key = WORK_CLASS_KEY[classType]
    if key == nil then
        Log.error("CultureOverview: unknown GreatWorkClassType '" .. tostring(classType) .. "'")
        return Text.key("TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART")
    end
    return Text.key(key)
end

-- Strip the trailing "(Great Artist)" / "(Great Writer)" / "(Great Musician)"
-- parenthetical the engine appends to GetGreatWorkArtist. The class word
-- already conveys the unit type, so the parenthetical would just repeat it.
-- Locale-agnostic: matches any trailing parenthesised group with optional
-- surrounding whitespace.
local function stripArtistTitle(s)
    return (s:gsub("%s*%(.-%)%s*$", ""))
end

-- Custom tooltip for a great work, built from Lua primitives. Replaces
-- engine's GetGreatWorkTooltip which packed fields together with no
-- labels and lost the yield icons through markup stripping. Yields are
-- the BNW base (GameDefines.BASE_*_PER_GREAT_WORK = 2/2); city-level
-- theming and policy modifiers surface separately on the building / city
-- rows.
--
-- Class-word inclusion depends on whether the slot type can hold more
-- than one work class. ART_ARTIFACT slots (Museum, Cathedral, Palace,
-- etc.) hold either art or artifact, so the class word distinguishes
-- the two. LITERATURE and MUSIC slots only ever hold their one class,
-- so the parent row's slot-type phrase already conveys it and we drop
-- the leading class word from the tooltip. Artifacts skip the artist
-- field entirely (no human author for dug-up works).
local function gwTooltip(gwIndex)
    if gwIndex < 0 then
        return nil
    end
    local workType = Game.GetGreatWorkType(gwIndex)
    local classType = GameInfo.GreatWorks[workType].GreatWorkClassType
    local creator = gwCreatorName(gwIndex)
    local era = Text.key(Game.GetGreatWorkEraShort(gwIndex))
    local culture = GameDefines.BASE_CULTURE_PER_GREAT_WORK
    local tourism = GameDefines.BASE_TOURISM_PER_GREAT_WORK
    if classType == "GREAT_WORK_ARTIFACT" then
        return Text.format(
            "TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT",
            workClassLabel(classType),
            creator,
            era,
            culture,
            tourism
        )
    end
    local artist = stripArtistTitle(Text.key(Game.GetGreatWorkArtist(gwIndex)))
    if classType == "GREAT_WORK_ART" then
        return Text.format(
            "TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED",
            workClassLabel(classType),
            artist,
            creator,
            era,
            culture,
            tourism
        )
    end
    return Text.format("TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS", artist, creator, era, culture, tourism)
end

-- ===== Building / great-work data ======================================

-- Heritage building list in fixed engine order. Each entry is either a
-- BuildingClass (resolved per-player to honour civ UB overrides like
-- Polynesia's Moai for Amphitheater) or a direct BuildingType (Babylon's
-- Royal Library is the engine's only by-type entry, kept at the tail).
local HERITAGE_ENTRIES = {
    { class = "BUILDINGCLASS_AMPHITHEATER" },
    { class = "BUILDINGCLASS_OPERA_HOUSE" },
    { class = "BUILDINGCLASS_MUSEUM" },
    { class = "BUILDINGCLASS_BROADCAST_TOWER" },
    { class = "BUILDINGCLASS_CATHEDRAL" },
    { class = "BUILDINGCLASS_PALACE" },
    { class = "BUILDINGCLASS_NATIONAL_EPIC" },
    { class = "BUILDINGCLASS_HEROIC_EPIC" },
    { type = "BUILDING_ROYAL_LIBRARY" },
}

-- Resolve a HERITAGE_ENTRIES row to (building, buildingClass) for the
-- active player, honouring civ-specific BuildingClassOverrides.
local function resolveHeritageEntry(entry)
    if entry.type ~= nil then
        local building = GameInfo.Buildings[entry.type]
        if building == nil then
            return nil
        end
        return building, GameInfo.BuildingClasses[building.BuildingClass]
    end
    local civType = GameInfo.Civilizations[activePlayer():GetCivilizationType()].Type
    local override = GameInfo.Civilization_BuildingClassOverrides({
        BuildingClassType = entry.class,
        CivilizationType = civType,
    })()
    local buildingClass = GameInfo.BuildingClasses[entry.class]
    local building
    if override ~= nil then
        building = GameInfo.Buildings[override.BuildingType]
    else
        building = GameInfo.Buildings[buildingClass.DefaultBuilding]
    end
    return building, buildingClass
end

-- World-wonder GW buildings: any building with GreatWorkCount > 0 whose
-- BuildingClass has MaxGlobalInstances > 0, plus Hermitage and Oxford
-- (national wonders that the engine groups into the wonder display).
-- Iteration order matches the engine's WorldWonders construction so the
-- per-city wonder list reads in the same sequence.
local function gwWonderBuildings()
    local out = {}
    for building in GameInfo.Buildings() do
        local bc = GameInfo.BuildingClasses[building.BuildingClass]
        if
            bc ~= nil
            and (
                (bc.MaxGlobalInstances > 0 and (building.GreatWorkCount or 0) > 0)
                or building.Type == "BUILDING_HERMITAGE"
                or building.Type == "BUILDING_OXFORD_UNIVERSITY"
            )
        then
            out[#out + 1] = { building = building, buildingClass = bc }
        end
    end
    return out
end

-- Every GW-housing building present in `city`, in engine display order:
-- heritage entries first (skipping any the city doesn't own), then any
-- GW-housing wonders the city has built. Each row is { building,
-- buildingClass } pairs ready for buildBuildingGroup.
local function cityGwBuildings(city)
    local out = {}
    for _, entry in ipairs(HERITAGE_ENTRIES) do
        local b, bc = resolveHeritageEntry(entry)
        if b ~= nil and city:IsHasBuilding(b.ID) then
            out[#out + 1] = { building = b, buildingClass = bc }
        end
    end
    for _, w in ipairs(gwWonderBuildings()) do
        if city:IsHasBuilding(w.building.ID) then
            out[#out + 1] = w
        end
    end
    return out
end

-- Run the move state machine for a slot. Shared by the multi-slot drill-in
-- leaves (buildSlotItem) and the single-slot building rows that collapse
-- to a slot (buildBuildingRow). Re-queries the slot's current GW index
-- so a mid-screen move can't leave us acting on stale state.
local function activateSlotMove(city, buildingClassID, slotIndex, slotType)
    local cityID = city:GetID()
    local gw = city:GetBuildingGreatWork(buildingClassID, slotIndex)
    if m_gwMoveSource == nil then
        -- Marking an empty slot as the source would let
        -- Network.SendMoveGreatWorks fire with no work attached; the
        -- engine silently no-ops and the user would hear "moved" with
        -- nothing actually changing.
        if gw < 0 then
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"))
            return
        end
        m_gwMoveSource = {
            cityID = cityID,
            buildingClassID = buildingClassID,
            slotIndex = slotIndex,
            slotType = slotType,
        }
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"))
        return
    end
    -- Same slot pressed again: clear source.
    if
        m_gwMoveSource.cityID == cityID
        and m_gwMoveSource.buildingClassID == buildingClassID
        and m_gwMoveSource.slotIndex == slotIndex
    then
        m_gwMoveSource = nil
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"))
        return
    end
    -- Different slot, different type: engine doesn't allow the swap.
    -- Speak feedback so the user understands why nothing happened.
    if m_gwMoveSource.slotType ~= slotType then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"))
        return
    end
    -- Different slot, same type: send the move. SerialEventCityInfoDirty
    -- will refresh Tab 1's items.
    Network.SendMoveGreatWorks(
        activePlayerID(),
        m_gwMoveSource.cityID,
        m_gwMoveSource.buildingClassID,
        m_gwMoveSource.slotIndex,
        cityID,
        buildingClassID,
        slotIndex
    )
    m_gwMoveSource = nil
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"))
end

-- Per-slot leaf inside a multi-slot building. Speaks the index plus the
-- work name (or "empty"); the slot-type phrase lives one level up on the
-- building row, so the leaf doesn't repeat it. Tooltip is gwTooltip,
-- built from Lua primitives.
--
-- The `city` handle is captured directly (live userdata, per project
-- rules); the slot's GW index is re-queried inside every closure so a
-- mid-screen move or swap can't leave us speaking the pre-move work name
-- after SerialEventCityInfoDirty has updated the underlying state but
-- before the items list has been rebuilt.
local function buildSlotItem(city, buildingClassID, slotIndex, slotType)
    local idxLabel = tostring(slotIndex + 1)
    return BaseMenuItems.Text({
        labelFn = function()
            local gw = city:GetBuildingGreatWork(buildingClassID, slotIndex)
            if gw >= 0 then
                local name = Text.key(Game.GetGreatWorkName(gw))
                return Text.format("TXT_KEY_CIVVACCESS_CO_SLOT_FILLED", idxLabel, name)
            end
            return Text.format("TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY", idxLabel)
        end,
        tooltipFn = function()
            return gwTooltip(city:GetBuildingGreatWork(buildingClassID, slotIndex))
        end,
        onActivate = function()
            activateSlotMove(city, buildingClassID, slotIndex, slotType)
        end,
    })
end

-- Single-slot buildings collapse to one row that *is* the slot. Drilling
-- into a Group of one entry would just echo the parent label one level
-- deeper, so the building row carries the work info and Enter runs the
-- move state machine directly. All heritage buildings except Museum and
-- Royal Library land here, plus most GW-housing wonders.
local function buildSingleSlotRow(city, building, buildingClass)
    local buildingClassID = buildingClass.ID
    local slotType = building.GreatWorkSlotType
    local buildingDescription = Text.key(building.Description)
    local slotTypeText = slotTypeLabel(slotType)
    return BaseMenuItems.Text({
        labelFn = function()
            local gw = city:GetBuildingGreatWork(buildingClassID, 0)
            if gw >= 0 then
                local name = Text.key(Game.GetGreatWorkName(gw))
                return Text.format(
                    "TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED",
                    buildingDescription,
                    slotTypeText,
                    name
                )
            end
            return Text.format("TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY", buildingDescription, slotTypeText)
        end,
        tooltipFn = function()
            return gwTooltip(city:GetBuildingGreatWork(buildingClassID, 0))
        end,
        pediaName = buildingDescription,
        onActivate = function()
            activateSlotMove(city, buildingClassID, 0, slotType)
        end,
    })
end

-- Multi-slot building Group: lists every slot in the building. Label
-- combines localized building name + slot type + filled/total + active
-- theming bonus when one applies. cached=false so the slot list rebuilds
-- on each drill (post-move state is reflected when the user drills back).
local function buildMultiSlotGroup(city, building, buildingClass)
    local buildingClassID = buildingClass.ID
    local slotType = building.GreatWorkSlotType
    local slotCount = building.GreatWorkCount or 0
    local buildingDescription = Text.key(building.Description)
    local slotTypeText = slotTypeLabel(slotType)
    return BaseMenuItems.Group({
        labelFn = function()
            local filled = 0
            for s = 0, slotCount - 1 do
                if city:GetBuildingGreatWork(buildingClassID, s) >= 0 then
                    filled = filled + 1
                end
            end
            if city:IsThemingBonusPossible(buildingClassID) then
                local themeBonus = city:GetThemingBonus(buildingClassID)
                if themeBonus and themeBonus > 0 then
                    return Text.format(
                        "TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED",
                        buildingDescription,
                        slotTypeText,
                        filled,
                        slotCount,
                        themeBonus
                    )
                end
            end
            return Text.format(
                "TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL",
                buildingDescription,
                slotTypeText,
                filled,
                slotCount
            )
        end,
        tooltipFn = function()
            if city:IsThemingBonusPossible(buildingClassID) then
                return city:GetThemingTooltip(buildingClassID)
            end
            return nil
        end,
        pediaName = buildingDescription,
        cached = false,
        itemsFn = function()
            local items = {}
            for s = 0, slotCount - 1 do
                items[#items + 1] = buildSlotItem(city, buildingClassID, s, slotType)
            end
            return items
        end,
    })
end

-- Dispatch by slot count. Single-slot collapses to a Text row; multi-slot
-- keeps the drill-in.
local function buildBuildingGroup(city, building, buildingClass)
    if (building.GreatWorkCount or 0) <= 1 then
        return buildSingleSlotRow(city, building, buildingClass)
    end
    return buildMultiSlotGroup(city, building, buildingClass)
end

-- City Group: every GW-housing building present in the city, in fixed
-- engine order (heritage classes, Royal Library, then any GW-housing
-- wonders the city owns). Label combines name + culture/turn + tourism/
-- turn + GW filled-of-total + damaged annotation when health < 100%.
local function cityAnnotationPrefix(city)
    if city:IsCapital() then
        return Text.key("TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL")
    end
    if city:IsPuppet() then
        return Text.key("TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET")
    end
    if city:IsOccupied() and not city:IsNoOccupiedUnhappiness() then
        return Text.key("TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED")
    end
    return nil
end

local function buildCityGroup(city)
    return BaseMenuItems.Group({
        labelFn = function()
            local prefix = cityAnnotationPrefix(city)
            local namePart
            if prefix ~= nil then
                namePart = prefix .. " " .. city:GetName()
            else
                namePart = city:GetName()
            end
            local filled = city:GetNumGreatWorks()
            local total = 0
            for _, b in ipairs(cityGwBuildings(city)) do
                total = total + (b.building.GreatWorkCount or 0)
            end
            local cul = city:GetJONSCulturePerTurn()
            local tou = city:GetBaseTourism()
            local damagePct = math.floor((city:GetDamage() / city:GetMaxHitPoints()) * 100 + 0.5)
            if damagePct > 0 then
                return Text.formatPlural(
                    "TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED",
                    total,
                    namePart,
                    cul,
                    tou,
                    filled,
                    total,
                    damagePct
                )
            end
            return Text.formatPlural(
                "TXT_KEY_CIVVACCESS_CO_CITY_LABEL",
                total,
                namePart,
                cul,
                tou,
                filled,
                total
            )
        end,
        cached = false,
        itemsFn = function()
            local items = {}
            for _, b in ipairs(cityGwBuildings(city)) do
                items[#items + 1] = buildBuildingGroup(city, b.building, b.buildingClass)
            end
            if #items == 0 then
                items[1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"),
                })
            end
            return items
        end,
    })
end

-- ===== Tab 1 (Your Culture) ============================================

local function buildYourCultureItems()
    local items = {}
    local p = activePlayer()
    local hadCity = false
    for c in p:Cities() do
        items[#items + 1] = buildCityGroup(c)
        hadCity = true
    end
    if not hadCity then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_CO_NO_CITIES"),
        })
    end
    -- Global archaeology pool footer. -1 means no civ has unlocked
    -- Archaeology yet, so the count would be meaningless; suppress the
    -- whole row in that state.
    if Game.GetNumArchaeologySites() ~= -1 then
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return Text.format(
                    "TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES",
                    Game.GetNumArchaeologySites(),
                    Game.GetNumHiddenArchaeologySites()
                )
            end,
        })
    end
    return items
end

-- ===== Tab 2 (Swap Great Works) ========================================

-- Engine workType IDs for Network.SendSetSwappableGreatWork: 1=Art,
-- 2=Artifact, 3=Writing, 4=Music. Music is commented out engine-side; we
-- follow.
local SWAP_TYPE_WRITING = 3
local SWAP_TYPE_ART = 1
local SWAP_TYPE_ARTIFACT = 2

-- Per-type metadata. Display order (Writing, Art, Artifact) matches the
-- engine's RefreshSwappingItems sequence so anything the user reads in a
-- sighted-player walkthrough lines up with the order they hear here. The
-- slotTooltipKey is the engine TXT_KEY whose body ends with the
-- "other civilizations may swap for it on their turn without your
-- permission!" advisory; reusing it verbatim means the trade-asymmetry
-- warning is one tooltip request away from each pulldown.
local SWAP_TYPES = {
    {
        id = SWAP_TYPE_WRITING,
        controlName = "YourWritingPullDown",
        nameKey = "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING",
        slotTooltipKey = "TXT_KEY_WRITING_SLOT_TT",
        accessor = function(p)
            return p:GetSwappableGreatWriting()
        end,
    },
    {
        id = SWAP_TYPE_ART,
        controlName = "YourArtPullDown",
        nameKey = "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART",
        slotTooltipKey = "TXT_KEY_ART_SLOT_TT",
        accessor = function(p)
            return p:GetSwappableGreatArt()
        end,
    },
    {
        id = SWAP_TYPE_ARTIFACT,
        controlName = "YourArtifactPullDown",
        nameKey = "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT",
        slotTooltipKey = "TXT_KEY_ARTIFACT_SLOT_TT",
        accessor = function(p)
            return p:GetSwappableGreatArtifact()
        end,
    },
}

local function typeMetaFor(typeId)
    for _, t in ipairs(SWAP_TYPES) do
        if t.id == typeId then
            return t
        end
    end
    return nil
end

local function swappableForTypeId(typeId)
    local meta = typeMetaFor(typeId)
    if meta == nil then
        return -1
    end
    return meta.accessor(activePlayer())
end

-- Closed-state value for a per-type designation pulldown: the work name
-- when designated, "none designated" otherwise. Era / creator / yields are
-- carried by the per-entry announcement and the foreign-offering tooltips
-- (both routed through gwTooltip), which keeps Tab 2's work reading
-- aligned with Tab 1's slot-leaf "name in label, rich detail in tooltip"
-- pattern.
local function gwInlineName(idx)
    if idx < 0 then
        return Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_NONE")
    end
    return Text.key(Game.GetGreatWorkName(idx))
end

-- The trade-state sentence describing what would happen if the user
-- pressed the trade item right now. Three states:
--   1. m_swapTheirItem < 0                       not picked
--   2. picked but no matching designation        need to designate
--   3. both ready                                consummate
-- Used both as the trade item's labelFn and as spoken feedback after the
-- user picks a foreign offering, so the post-pick speech matches what the
-- trade item itself would say if reached.
local function tradeStateLabel()
    if m_swapTheirItem < 0 then
        return Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED")
    end
    local theirIdx = m_swapTheirItem
    local typeId = Game.GetGreatWorkClass(theirIdx)
    local meta = typeMetaFor(typeId)
    local typeName = meta and Text.key(meta.nameKey) or ""
    local theirName = Text.key(Game.GetGreatWorkName(theirIdx))
    local theirCiv = civDisplayName(Players[m_swapTradingPartner])
    local yourIdx = swappableForTypeId(typeId)
    if yourIdx < 0 then
        return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE", typeName, theirName, theirCiv)
    end
    local yourName = Text.key(Game.GetGreatWorkName(yourIdx))
    return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY", yourName, theirName, theirCiv)
end

-- Per-type Pulldown wrapping the engine's per-type designation widget.
-- The engine already wires RegisterSelectionCallback to fire
-- Network.SendSetSwappableGreatWork, so the Pulldown's activate path
-- mutates engine state through the captured callback. onSelected rebuilds
-- the tab so the trade item's state-aware label reflects whatever
-- matching-type designation now exists.
local function buildOfferingPulldown(typeMeta)
    return BaseMenuItems.Pulldown({
        controlName = typeMeta.controlName,
        labelFn = function()
            return Text.format(
                "TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE",
                Text.key(typeMeta.nameKey),
                gwInlineName(swappableForTypeId(typeMeta.id))
            )
        end,
        tooltipKey = typeMeta.slotTooltipKey,
        entryAnnounceFn = function(inst)
            -- Engine sets entry voids to (workType, workIndex). Index < 0
            -- is the "Empty This Spot" / clear entry.
            local idx = inst.Button:GetVoid2()
            if idx < 0 then
                return Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY")
            end
            -- Match Tab 1's slot-leaf reading: name as label, gwTooltip
            -- supplying class/artist/origin/era/yields. Pulldown entries
            -- have no separate tooltip-on-demand path (entryAnnounceFn
            -- short-circuits the per-entry tooltip append), so the two
            -- are folded into one announcement here.
            local name = Text.key(Game.GetGreatWorkName(idx))
            return name .. ". " .. gwTooltip(idx)
        end,
        onSelected = function()
            m_swapTab.menu().setItems(buildSwapItems())
        end,
    })
end

local function buildYourOfferingsGroup()
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"),
        cached = false,
        itemsFn = function()
            local items = {}
            for _, t in ipairs(SWAP_TYPES) do
                items[#items + 1] = buildOfferingPulldown(t)
            end
            return items
        end,
    })
end

-- Foreign offering leaf. Activating queues this work as the swap target.
-- We don't store a "your item" alongside; the matching designation is
-- derived live by tradeStateLabel and at trade-fire time so changing your
-- designation between picking and trading can't strand a stale pairing.
-- Speaks the resolved trade-state label after queuing so the user hears
-- what would happen at the trade item without backing out to it.
--
-- Reading mirrors Tab 1's slot-leaf pattern: type prefix + work name in
-- the label (the type prefix is the within-civ disambiguator, like the
-- slot index inside a multi-slot building); gwTooltip supplies the rich
-- class/artist/origin/era/yields detail and gets auto-appended on
-- navigation by Text.announce.
local function buildForeignOfferingLeaf(gwIndex, ownerID)
    return BaseMenuItems.Text({
        labelFn = function()
            local typeId = Game.GetGreatWorkClass(gwIndex)
            local meta = typeMetaFor(typeId)
            local typeName = meta and Text.key(meta.nameKey) or ""
            local name = Text.key(Game.GetGreatWorkName(gwIndex))
            return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED", typeName, name)
        end,
        tooltipFn = function()
            return gwTooltip(gwIndex)
        end,
        onActivate = function()
            m_swapTheirItem = gwIndex
            m_swapTradingPartner = ownerID
            m_swapTab.menu().setItems(buildSwapItems())
            SpeechPipeline.speakInterrupt(tradeStateLabel())
        end,
    })
end

-- Civ-level Group inside the foreign-offerings drill. Slot indices are
-- re-derived from a fresh GetOthersGreatWorks() query on every drill-in
-- (cached = false) so a designation change between the parent build and
-- the user reaching this Group can't surface a stale index. Only iPlayer
-- is captured, since player IDs are stable for the session.
local function buildForeignCivGroup(iPlayer)
    local civPlayer = Players[iPlayer]
    local civLabel = civDisplayName(civPlayer)
    return BaseMenuItems.Group({
        labelText = civLabel,
        cached = false,
        itemsFn = function()
            local items = {}
            local others = activePlayer():GetOthersGreatWorks() or {}
            for _, rec in ipairs(others) do
                if rec.iPlayer == iPlayer then
                    if rec.WritingIndex >= 0 then
                        items[#items + 1] = buildForeignOfferingLeaf(rec.WritingIndex, iPlayer)
                    end
                    if rec.ArtIndex >= 0 then
                        items[#items + 1] = buildForeignOfferingLeaf(rec.ArtIndex, iPlayer)
                    end
                    if rec.ArtifactIndex >= 0 then
                        items[#items + 1] = buildForeignOfferingLeaf(rec.ArtifactIndex, iPlayer)
                    end
                    break
                end
            end
            if #items == 0 then
                items[1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"),
                })
            end
            return items
        end,
    })
end

local function buildForeignOfferingsGroup()
    local function civsWithOfferings()
        local out = {}
        local others = activePlayer():GetOthersGreatWorks() or {}
        for _, v in ipairs(others) do
            if v.WritingIndex >= 0 or v.ArtIndex >= 0 or v.ArtifactIndex >= 0 then
                out[#out + 1] = v
            end
        end
        return out
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"),
        cached = false,
        itemsFn = function()
            local items = {}
            for _, rec in ipairs(civsWithOfferings()) do
                items[#items + 1] = buildForeignCivGroup(rec.iPlayer)
            end
            if #items == 0 then
                items[1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"),
                })
            end
            return items
        end,
    })
end

-- Trade item. Label mirrors tradeStateLabel; activate consummates the
-- trade in the ready state and re-speaks the not-ready label otherwise so
-- the user gets explicit feedback rather than silence. After the trade
-- fires we don't pre-emptively setItems because SerialEventGreatWorks-
-- ScreenDirty will rebuild the tab before the user can navigate.
local function buildTradeItem()
    return BaseMenuItems.Text({
        labelFn = tradeStateLabel,
        onActivate = function()
            local theirIdx = m_swapTheirItem
            if theirIdx < 0 then
                SpeechPipeline.speakInterrupt(tradeStateLabel())
                return
            end
            local yourIdx = swappableForTypeId(Game.GetGreatWorkClass(theirIdx))
            if yourIdx < 0 then
                SpeechPipeline.speakInterrupt(tradeStateLabel())
                return
            end
            Network.SendSwapGreatWorks(activePlayerID(), yourIdx, m_swapTradingPartner, theirIdx)
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_SENT"))
            m_swapTheirItem = -1
            m_swapTradingPartner = -1
        end,
    })
end

buildSwapItems = function()
    return {
        buildYourOfferingsGroup(),
        buildForeignOfferingsGroup(),
        buildTradeItem(),
    }
end

-- ===== Tab 3 (Culture Victory) =========================================

local function publicOpinionText(opinionType)
    if opinionType == PublicOpinionTypes.PUBLIC_OPINION_CONTENT then
        return Text.key("TXT_KEY_CO_PUBLIC_OPINION_CONTENT")
    end
    if opinionType == PublicOpinionTypes.PUBLIC_OPINION_DISSIDENTS then
        return Text.key("TXT_KEY_CO_PUBLIC_OPINION_DISSIDENTS")
    end
    if opinionType == PublicOpinionTypes.PUBLIC_OPINION_CIVIL_RESISTANCE then
        return Text.key("TXT_KEY_CO_PUBLIC_OPINION_CIVIL_RESISTANCE")
    end
    if opinionType == PublicOpinionTypes.PUBLIC_OPINION_REVOLUTIONARY_WAVE then
        return Text.key("TXT_KEY_CO_PUBLIC_OPINION_REVOLUTIONARY_WAVE")
    end
    return Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA")
end

local function rebuildVictoryRows()
    local rows = {}
    for _, p in eachMetMajorAlive() do
        rows[#rows + 1] = p
    end
    return rows
end

local function victoryRowLabel(pPlayer)
    return civDisplayName(pPlayer)
end

local function influencingCellText(pPlayer)
    return Text.format(
        "TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF",
        pPlayer:GetNumCivsInfluentialOn(),
        pPlayer:GetNumCivsToBeInfluentialOn()
    )
end

-- Sort by the count/total ratio so a 1-of-1 civ outranks 5-of-7 the way
-- the engine's InfluencePct does. Zero-total civs (everyone else dead)
-- sort to the bottom in desc; substituting -1 instead of 0 keeps them
-- below content civs at 0%.
local function influencingSortKey(pPlayer)
    local total = pPlayer:GetNumCivsToBeInfluentialOn()
    if total == 0 then
        return -1
    end
    return pPlayer:GetNumCivsInfluentialOn() / total
end

local function ideologyCellText(pPlayer)
    local branch = pPlayer:GetLateGamePolicyTree()
    if branch == PolicyBranchTypes.NO_POLICY_BRANCH_TYPE then
        return Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY")
    end
    return Text.key(GameInfo.PolicyBranchTypes[branch].Description)
end

local function opinionCellText(pPlayer)
    local branch = pPlayer:GetLateGamePolicyTree()
    if branch == PolicyBranchTypes.NO_POLICY_BRANCH_TYPE then
        return Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA")
    end
    return publicOpinionText(pPlayer:GetPublicOpinionType())
end

-- Public-opinion unhappiness is signed-negative on this screen (the engine
-- multiplies by -1 before rendering: a content civ reads "0", a civ pushed
-- by ideology pressure reads "-3"). Match that sign convention. Civs with
-- no ideology have no public-opinion unhappiness at all -> "0".
local function unhappyCellText(pPlayer)
    if pPlayer:GetLateGamePolicyTree() == PolicyBranchTypes.NO_POLICY_BRANCH_TYPE then
        return "0"
    end
    return formatSigned(-1 * pPlayer:GetPublicOpinionUnhappiness())
end

local function unhappySortKey(pPlayer)
    if pPlayer:GetLateGamePolicyTree() == PolicyBranchTypes.NO_POLICY_BRANCH_TYPE then
        return 0
    end
    return -1 * pPlayer:GetPublicOpinionUnhappiness()
end

local function unhappyTooltip(pPlayer)
    if pPlayer:GetLateGamePolicyTree() == PolicyBranchTypes.NO_POLICY_BRANCH_TYPE then
        return nil
    end
    if pPlayer:GetPublicOpinionUnhappiness() == 0 then
        return nil
    end
    return pPlayer:GetPublicOpinionUnhappinessTooltip()
end

-- Excess happiness is a player-wide buffer that's live regardless of
-- ideology (city happiness summed minus unhappiness from all sources).
-- Show in both branches, signed.
local function happyCellText(pPlayer)
    return formatSigned(pPlayer:GetExcessHappiness())
end

local function buildVictoryColumns()
    return {
        {
            name = "TXT_KEY_CIVVACCESS_CO_VICTORY_COL_INFLUENCING",
            getCell = influencingCellText,
            sortKey = influencingSortKey,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_VICTORY_COL_TOURISM",
            getCell = function(p)
                return tostring(p:GetTourism())
            end,
            sortKey = function(p)
                return p:GetTourism()
            end,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_VICTORY_COL_IDEOLOGY",
            getCell = ideologyCellText,
            -- Numeric branch ID groups civs by ideology; NO_POLICY_BRANCH_TYPE
            -- (-1) is the same sentinel pattern Opinion uses, so no-ideology
            -- civs land at the bottom in descending sort -- consistent across
            -- all three ideology-gated columns.
            sortKey = function(p)
                return p:GetLateGamePolicyTree()
            end,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_VICTORY_COL_OPINION",
            getCell = opinionCellText,
            -- No-ideology civs sort below all opinion enums (-1 < CONTENT).
            sortKey = function(p)
                if p:GetLateGamePolicyTree() == PolicyBranchTypes.NO_POLICY_BRANCH_TYPE then
                    return -1
                end
                return p:GetPublicOpinionType()
            end,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_VICTORY_COL_UNHAPPY",
            getCell = unhappyCellText,
            sortKey = unhappySortKey,
            getTooltip = unhappyTooltip,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_VICTORY_COL_HAPPY",
            getCell = happyCellText,
            sortKey = function(p)
                return p:GetExcessHappiness()
            end,
        },
    }
end

local function buildVictoryTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CIVVACCESS_CO_TAB_VICTORY",
        columns = buildVictoryColumns(),
        rebuildRows = rebuildVictoryRows,
        rowLabel = victoryRowLabel,
    })
end

-- ===== Tab 4 (Player Influence) ========================================

local INFLUENCE_LEVEL_KEYS = {
    [InfluenceLevelTypes.INFLUENCE_LEVEL_UNKNOWN] = "TXT_KEY_CO_UNKNOWN",
    [InfluenceLevelTypes.INFLUENCE_LEVEL_EXOTIC] = "TXT_KEY_CO_EXOTIC",
    [InfluenceLevelTypes.INFLUENCE_LEVEL_FAMILIAR] = "TXT_KEY_CO_FAMILIAR",
    [InfluenceLevelTypes.INFLUENCE_LEVEL_POPULAR] = "TXT_KEY_CO_POPULAR",
    [InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL] = "TXT_KEY_CO_INFLUENTIAL",
    [InfluenceLevelTypes.INFLUENCE_LEVEL_DOMINANT] = "TXT_KEY_CO_DOMINANT",
}

local function influenceLevelText(level)
    local key = INFLUENCE_LEVEL_KEYS[level]
    if key == nil then
        return Text.key("TXT_KEY_CO_UNKNOWN")
    end
    return Text.key(key)
end

-- Bonuses-at-level callout. Engine concatenates this onto the level
-- tooltip and uses the same off-by-one indirection: at level Popular the
-- callout describes Familiar's bonuses (what you've already unlocked).
-- We surface it as the level cell's tooltip so the engine's "press
-- tooltip-key to read what this tier gave you" pattern still works.
local function levelBonusKey(level)
    if level == InfluenceLevelTypes.INFLUENCE_LEVEL_POPULAR then
        return "TXT_KEY_CO_INFLUENCE_BONUSES_FAMILIAR"
    end
    if level == InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL then
        return "TXT_KEY_CO_INFLUENCE_BONUSES_POPULAR"
    end
    if level == InfluenceLevelTypes.INFLUENCE_LEVEL_DOMINANT then
        return "TXT_KEY_CO_INFLUENCE_BONUSES_INFLUENTIAL"
    end
    return nil
end

-- Trend enum -> mod-authored TXT_KEY. The "rising slowly" branch is
-- engine-derived (rising trend with turns-to-influential = 999, the
-- engine's "unreachable" sentinel) and computed in trendCellText below;
-- it's not a separate enum value.
local TREND_TEXT_KEYS = {
    [InfluenceLevelTrend.INFLUENCE_TREND_FALLING] = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_FALLING",
    [InfluenceLevelTrend.INFLUENCE_TREND_STATIC] = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC",
    [InfluenceLevelTrend.INFLUENCE_TREND_RISING] = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING",
}

local function rebuildInfluenceRows()
    local rows = {}
    for i = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local p = Players[i]
        -- All met (or universally-known in MP) major civs other than the
        -- current perspective. Engine's row set additionally filters on
        -- "perspective has non-zero influence on them"; we drop that
        -- filter so column 1 doubles as the perspective switcher --
        -- every met civ is reachable as a perspective target, even if
        -- the current perspective hasn't generated tourism on them yet.
        if
            p ~= nil
            and p:IsAlive()
            and not p:IsMinorCiv()
            and i ~= g_iSelectedPlayerID
            and (activeTeam():IsHasMet(p:GetTeam()) or isMP())
        then
            rows[#rows + 1] = i
        end
    end
    return rows
end

local function influenceRowLabel(targetID)
    return civDisplayName(Players[targetID])
end

-- Column 1 cell: the row civ's overall tourism generation rate (their
-- GetTourism, the same number the engine surfaces in the perspective
-- header) plus the "press enter to switch" discoverability hint. The
-- combined string is one TXT_KEY for translatability.
local function perspectiveCellText(targetID)
    return Text.format(
        "TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE_CELL",
        Players[targetID]:GetTourism()
    )
end

-- Enter on column 1 mutates g_iSelectedPlayerID directly (engine pattern;
-- the engine's pulldown callback at CultureOverview.lua:2103 does the
-- same). No engine RefreshContent call needed: BaseTable rebuilds rows
-- on the next nav and our cell accessors all read g_iSelectedPlayerID
-- live. Speak "now viewing from <civ>" once on switch as the user's
-- confirmation; cursor preservation is intentional, the user can press
-- Home to re-orient if they want a fresh start in the new row order.
local function switchPerspectiveTo(targetID)
    g_iSelectedPlayerID = targetID
    SpeechPipeline.speakInterrupt(
        Text.format("TXT_KEY_CIVVACCESS_CO_INFLUENCE_NOW_VIEWING", civDisplayName(Players[targetID]))
    )
end

local function influenceLevelCell(targetID)
    return influenceLevelText(Players[g_iSelectedPlayerID]:GetInfluenceLevel(targetID))
end

local function influenceLevelTooltip(targetID)
    local level = Players[g_iSelectedPlayerID]:GetInfluenceLevel(targetID)
    local key = levelBonusKey(level)
    if key == nil then
        return nil
    end
    return Text.key(key)
end

local function influencePercent(targetID)
    local pSel = Players[g_iSelectedPlayerID]
    local pTgt = Players[targetID]
    local culture = pTgt:GetJONSCultureEverGenerated()
    if culture == 0 then
        return 0
    end
    return pSel:GetInfluenceOn(targetID) / culture
end

local function influencePercentCell(targetID)
    local pct = math.floor(influencePercent(targetID) * 100 + 0.5)
    return Text.format("TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_CELL", pct)
end

local function influencePercentTooltip(targetID)
    local pSel = Players[g_iSelectedPlayerID]
    local pTgt = Players[targetID]
    return Text.format(
        "TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_TOOLTIP",
        formatNumber(pSel:GetInfluenceOn(targetID)),
        formatNumber(pTgt:GetJONSCultureEverGenerated())
    )
end

local function modifierCell(targetID)
    return Text.format(
        "TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIER_CELL",
        formatSigned(Players[g_iSelectedPlayerID]:GetTourismModifierWith(targetID))
    )
end

local function modifierTooltip(targetID)
    local tt = Players[g_iSelectedPlayerID]:GetTourismModifierWithTooltip(targetID)
    if tt == nil or tt == "" then
        return nil
    end
    return tt
end

local function tourismRateCell(targetID)
    return formatSigned(math.floor(Players[g_iSelectedPlayerID]:GetInfluencePerTurn(targetID)))
end

local function tourismRateSortKey(targetID)
    return math.floor(Players[g_iSelectedPlayerID]:GetInfluencePerTurn(targetID))
end

-- Trend cell. The engine special-cases rising-but-unreachable (turns to
-- influential == 999) as "rising slowly", and treats rising-at-Dominant
-- as static (a Dominant civ can't gain a level, so the rising trend is
-- not actionable). We mirror both gates from CultureOverview.lua:2046-2049.
local function trendCell(targetID)
    local pSel = Players[g_iSelectedPlayerID]
    local trend = pSel:GetInfluenceTrend(targetID)
    if trend == InfluenceLevelTrend.INFLUENCE_TREND_RISING then
        if pSel:GetTurnsToInfluential(targetID) == 999 then
            return Text.key("TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING_SLOWLY")
        end
        if pSel:GetInfluenceLevel(targetID) >= InfluenceLevelTypes.INFLUENCE_LEVEL_DOMINANT then
            return Text.key("TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC")
        end
        return Text.key("TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING")
    end
    local key = TREND_TEXT_KEYS[trend]
    if key == nil then
        return Text.key("TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC")
    end
    return Text.key(key)
end

-- Sort rank: falling -1, static 0, rising-slowly 1, rising 2. Matches the
-- engine's TrendRate convention from CultureOverview.lua:2040+. Rising
-- at Dominant collapses to 0 (the engine treats it as no movement; see
-- the level cap in the engine's sort-rank assignment at line 2049).
local function trendSortKey(targetID)
    local pSel = Players[g_iSelectedPlayerID]
    local trend = pSel:GetInfluenceTrend(targetID)
    if trend == InfluenceLevelTrend.INFLUENCE_TREND_FALLING then
        return -1
    end
    if trend == InfluenceLevelTrend.INFLUENCE_TREND_RISING then
        if pSel:GetTurnsToInfluential(targetID) == 999 then
            return 1
        end
        if pSel:GetInfluenceLevel(targetID) >= InfluenceLevelTypes.INFLUENCE_LEVEL_DOMINANT then
            return 0
        end
        return 2
    end
    return 0
end

-- Trend tooltip: estimated turns to Influential, gated on the same
-- conditions the engine uses (rising trend, sub-Influential, reachable).
local function trendTooltip(targetID)
    local pSel = Players[g_iSelectedPlayerID]
    local trend = pSel:GetInfluenceTrend(targetID)
    local turns = pSel:GetTurnsToInfluential(targetID)
    if
        trend == InfluenceLevelTrend.INFLUENCE_TREND_RISING
        and turns ~= 999
        and pSel:GetInfluenceLevel(targetID) < InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    then
        return Text.formatPlural("TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO", turns, turns)
    end
    return nil
end

local function buildInfluenceColumns()
    return {
        {
            name = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERSPECTIVE",
            getCell = perspectiveCellText,
            -- Sort by the row civ's overall tourism so the perspective
            -- column is also a tourism-output ranking.
            sortKey = function(targetID)
                return Players[targetID]:GetTourism()
            end,
            enterAction = switchPerspectiveTo,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_LEVEL",
            getCell = influenceLevelCell,
            sortKey = function(targetID)
                return Players[g_iSelectedPlayerID]:GetInfluenceLevel(targetID)
            end,
            getTooltip = influenceLevelTooltip,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERCENT",
            getCell = influencePercentCell,
            sortKey = influencePercent,
            getTooltip = influencePercentTooltip,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_MODIFIER",
            getCell = modifierCell,
            sortKey = function(targetID)
                return Players[g_iSelectedPlayerID]:GetTourismModifierWith(targetID)
            end,
            getTooltip = modifierTooltip,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_RATE",
            getCell = tourismRateCell,
            sortKey = tourismRateSortKey,
        },
        {
            name = "TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_TREND",
            getCell = trendCell,
            sortKey = trendSortKey,
            getTooltip = trendTooltip,
        },
    }
end

local function buildInfluenceTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE",
        columns = buildInfluenceColumns(),
        rebuildRows = rebuildInfluenceRows,
        rowLabel = influenceRowLabel,
    })
end

-- ===== Install =========================================================

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    -- Patch the engine PullDown metatable so RegisterSelectionCallback /
    -- BuildEntry / ClearEntries are captured for Tab 2's per-type swap
    -- pulldowns. Idempotent across the lua_State; a no-op if FrontEnd
    -- ProbeBoot already ran. Sample picker uses the swap pulldowns
    -- (Tab 4 no longer wraps PlayerPD -- the perspective picker has
    -- collapsed into Tab 4's Change Perspective column).
    PullDownProbe.installFromControls({
        "YourWritingPullDown",
        "YourArtPullDown",
        "YourArtifactPullDown",
    }, {}, {}, {})
    local function makeTab(tabName)
        return TabbedShell.menuTab({
            tabName = tabName,
            menuSpec = {
                displayName = Text.key("TXT_KEY_CULTURE_OVERVIEW"),
                items = {},
            },
        })
    end
    m_yourCultureTab = makeTab("TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE")
    m_swapTab = makeTab("TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS")
    m_victoryTab = buildVictoryTab()
    m_influenceTab = buildInfluenceTab()
    TabbedShell.install(ContextPtr, {
        name = "CultureOverview",
        displayName = Text.key("TXT_KEY_CULTURE_OVERVIEW"),
        tabs = { m_yourCultureTab, m_swapTab, m_victoryTab, m_influenceTab },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(_handler)
            -- Reset transient mod-side state on every open so a previous
            -- session's in-flight selection (move source, swap target)
            -- doesn't bleed into the new view. Tab 4's perspective is the
            -- engine's g_iSelectedPlayerID; the engine itself does not
            -- reset it on popup close, so a sighted player's perspective
            -- pick persists across reopen — we mirror that.
            m_gwMoveSource = nil
            m_swapTheirItem = -1
            m_swapTradingPartner = -1
            -- Force the engine's per-type swap pulldowns
            -- (YourWriting/Art/Artifact) to populate even when the user
            -- doesn't visually land on the SwapGreatWorks panel. priorShowHide
            -- above ran the engine's TabSelect(g_CurrentTab), which only
            -- rebuilds one panel and only that panel's pulldowns get
            -- BuildEntry / RegisterSelectionCallback called. RefreshSwapping-
            -- Items is the function inside DisplaySwapGreatWorks that calls
            -- PopulatePullDown for each, capturing entries via PullDownProbe;
            -- cheap and idempotent. Skipping the rest of DisplaySwapGreat-
            -- Works (CheckSwappedItems / DisplayOthersWorks) because we use
            -- our own swap state and our own foreign offerings list.
            if type(RefreshSwappingItems) == "function" then
                local ok, err = pcall(RefreshSwappingItems)
                if not ok then
                    Log.error("CultureOverview: swap pulldown prefetch failed: " .. tostring(err))
                end
            end
            m_yourCultureTab.menu().setItems(buildYourCultureItems())
            m_swapTab.menu().setItems(buildSwapItems())
            -- Tabs 3 and 4 are BaseTables; rebuildRows reruns on every nav,
            -- so onShow doesn't need to push rows. resetForNextOpen on hide
            -- is wired by TabbedShell so the next open lands at the header.
        end,
    })

    -- Tab 1 refresh: SerialEventCityInfoDirty fires after Network.Send-
    -- MoveGreatWorks completes. cached=false on every Group inside Tab 1
    -- makes drill-ins re-query, but the top-level rebuild covers removal
    -- of cities (capture / liberation between turns is theoretical but
    -- cheap to handle). Guard on IsHidden so we don't waste work when the
    -- popup isn't open.
    Events.SerialEventCityInfoDirty.Add(function()
        if ContextPtr:IsHidden() then
            return
        end
        m_yourCultureTab.menu().setItems(buildYourCultureItems())
    end)

    -- Tab 2 refresh: SerialEventGreatWorksScreenDirty is the engine's
    -- authoritative event for swap state changes. Fires after a
    -- designation (Network.SendSetSwappableGreatWork), after a swap (our
    -- side or theirs — when another player swaps for one of our
    -- designations the event fires here too so the user sees the updated
    -- "your offerings" count). Guard on IsHidden.
    Events.SerialEventGreatWorksScreenDirty.Add(function()
        if ContextPtr:IsHidden() then
            return
        end
        m_swapTab.menu().setItems(buildSwapItems())
    end)
end

-- ===== Module exports for tests ========================================

CultureOverviewAccess.formatSigned = formatSigned
CultureOverviewAccess.formatNumber = formatNumber
CultureOverviewAccess.civDisplayName = civDisplayName

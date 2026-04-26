-- Culture Overview accessibility (Ctrl+C). Wraps the engine popup as a four-tab
-- TabbedShell, every tab a flat BaseMenu list. The screen is small (few cities,
-- few met civs) and the per-row data is rich enough that drill-in is the
-- natural shape; no tab earns a BaseTable. Same reasoning Demographics uses.
--
--   Your Culture     -- per-city Group: name, culture/turn, tourism/turn, GW
--                       filled/total, damage. Drills into the city's GW-
--                       housing buildings (heritage row + any wonders the
--                       city owns), each of which drills into its slots.
--                       Slot Enter runs the move state machine; great-work
--                       details are surfaced via the slot's tooltip.
--                       Antiquity site counts precede the city list.
--   Swap Great Works -- designate-your-swappable section (three drill-ins,
--                       one per type), the in-flight swap workspace (your
--                       offer / their offer / Send / Clear), and the foreign-
--                       offerings list (one Group per offering civ, three
--                       slot leaves each).
--   Culture Victory  -- one Group per met major civ alive, sorted by tourism
--                       descending. Label combines influences/tourism/
--                       ideology/public opinion/excess happiness; drill-in
--                       surfaces the public-opinion and unhappiness tooltips.
--   Player Influence -- perspective picker (defaults to active player) +
--                       tourism-per-turn header + one Group per civ the
--                       perspective player has any influence level on.
--                       Drill-in surfaces influence percent, level tooltip
--                       (with bonuses-at-level callout), modifier breakdown,
--                       trend tooltip, and the bar tooltips (your influence
--                       vs their lifetime culture).
--
-- Initial tab is Your Culture (matches the engine's landing tab).
--
-- Engine integration: ships an override of CultureOverview.lua (verbatim BNW
-- copy + an include for this module). The engine's OnPopupMessage, OnClose,
-- ShowHideHandler, InputHandler, RegisterSortOptions, TabSelect("YourCulture"),
-- and SerialEventCityInfoDirty wiring stay intact; TabbedShell.install layers
-- our handler on top via priorInput / priorShowHide chains. SerialEventCityInfoDirty
-- triggers a Tab 1 setItems refresh while the popup is open so post-move state
-- is reflected without requiring the user to close and reopen.

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
include("CivVAccess_TabbedShell")
include("CivVAccess_Help")
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

-- Tab 2: in-flight swap state. Mirrors engine's g_iTheirItem, g_iYourItem,
-- g_iTradingPartner. Reset on every popup open.
local m_swapTheirItem = -1
local m_swapYourItem = -1
local m_swapTradingPartner = -1

-- Tab handles, set during install. onShow rebuilds each tab's items via
-- the menu accessor. Module-level so the SerialEventCityInfoDirty hook
-- can refresh Tab 1 mid-screen.
local m_yourCultureTab
local m_swapTab
local m_victoryTab
local m_influenceTab

-- Forward declaration. The Tab 4 perspective Pulldown's onSelected hook
-- needs to call buildInfluenceItems to rebuild the row list against the
-- new perspective; buildInfluenceItems is the function that creates the
-- Pulldown in the first place, so the dependency is self-referential.
local buildInfluenceItems

-- ===== Helpers =========================================================

local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

local function activePlayerID()
    return Game.GetActivePlayer()
end

local function activeTeam()
    return Teams[Game.GetActiveTeam()]
end

local function isMP()
    return Game:IsNetworkMultiPlayer()
end

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

-- "You of Rome" / "Augustus of Rome" / "Unknown Civilization". Same met /
-- nickname / active-player branches VictoryProgressAccess uses; duplicated
-- here because Popup Contexts each run their own include chain and a
-- cross-Context reference would break under load-from-game's env wipe.
local function civDisplayName(pPlayer)
    if not Teams[pPlayer:GetTeam()]:IsHasMet(Game.GetActiveTeam()) and not isMP() then
        return Locale.ConvertTextKey("TXT_KEY_MISC_UNKNOWN")
    end
    local civInfo = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
    local strPlayer
    local nick = pPlayer:GetNickName()
    if nick ~= "" and isMP() then
        strPlayer = nick
    elseif pPlayer:GetID() == activePlayerID() then
        strPlayer = "TXT_KEY_POP_VOTE_RESULTS_YOU"
    else
        strPlayer = pPlayer:GetNameKey()
    end
    return Locale.ConvertTextKey("TXT_KEY_RANDOM_LEADER_CIV", strPlayer, civInfo.ShortDescription)
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
    local creator = civDisplayName(Players[Game.GetGreatWorkCreator(gwIndex)])
    local era = Locale.ConvertTextKey(Game.GetGreatWorkEraShort(gwIndex))
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
    local artist = stripArtistTitle(Locale.ConvertTextKey(Game.GetGreatWorkArtist(gwIndex)))
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
                local name = Locale.ConvertTextKey(Game.GetGreatWorkName(gw))
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
    local buildingDescription = Locale.ConvertTextKey(building.Description)
    local slotTypeText = slotTypeLabel(slotType)
    return BaseMenuItems.Text({
        labelFn = function()
            local gw = city:GetBuildingGreatWork(buildingClassID, 0)
            if gw >= 0 then
                local name = Locale.ConvertTextKey(Game.GetGreatWorkName(gw))
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
    local buildingDescription = Locale.ConvertTextKey(building.Description)
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
                return Text.format(
                    "TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED",
                    namePart,
                    cul,
                    tou,
                    filled,
                    total,
                    damagePct
                )
            end
            return Text.format("TXT_KEY_CIVVACCESS_CO_CITY_LABEL", namePart, cul, tou, filled, total)
        end,
        tooltipFn = function()
            return city:GetTourismTooltip()
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
    if Game.GetNumArchaeologySites() ~= -1 then
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return Text.format("TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES", Game.GetNumArchaeologySites())
            end,
        })
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return Text.format("TXT_KEY_CIVVACCESS_CO_HIDDEN_SITES", Game.GetNumHiddenArchaeologySites())
            end,
        })
    end
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
    return items
end

-- ===== Tab 2 (Swap Great Works) ========================================

-- Class IDs for Network.SendSetSwappableGreatWork: 1=Art, 2=Artifact,
-- 3=Writing, 4=Music. Music is commented out in the engine; we omit it
-- here too. The accessor pair matches engine SelectYourWork class branches.
local function swappableForType(typeID)
    local p = activePlayer()
    if typeID == 1 then
        return p:GetSwappableGreatArt()
    end
    if typeID == 2 then
        return p:GetSwappableGreatArtifact()
    end
    if typeID == 3 then
        return p:GetSwappableGreatWriting()
    end
    return -1
end

-- Speak a great work as "<name>, <era>, <creator>" or, when ownerID is
-- supplied, with an "owned by <owner>" suffix. The owner-bearing form is
-- used by the in-flight swap workspace where the user needs to know whose
-- inventory the offered work is coming from; the bare form is used inside
-- the active player's own designate-swappable list where the owner is
-- always us.
local function gwShortDesc(idx, ownerID)
    if idx < 0 then
        return Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_NONE")
    end
    local name = Locale.ConvertTextKey(Game.GetGreatWorkName(idx))
    local era = Locale.ConvertTextKey(Game.GetGreatWorkEraShort(idx))
    local creator = civDisplayName(Players[Game.GetGreatWorkCreator(idx)])
    if ownerID == nil then
        return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_OFFER_DETAIL", name, era, creator)
    end
    local owner = civDisplayName(Players[ownerID])
    return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_OFFER_DETAIL_OWNED", name, era, creator, owner)
end

-- Drill-in Group for "designate your swappable Writing/Art/Artifact."
-- Children are a Clear entry plus every great work the active player owns
-- of that type. Activating a child fires Network.SendSetSwappableGreatWork.
local function buildDesignateGroup(typeID, typeNameKey)
    return BaseMenuItems.Group({
        labelFn = function()
            local cur = swappableForType(typeID)
            local detail
            if cur < 0 then
                detail = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_NONE")
            else
                detail = gwShortDesc(cur)
            end
            return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE", Text.key(typeNameKey), detail)
        end,
        cached = false,
        itemsFn = function()
            local items = {}
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"),
                onActivate = function()
                    Network.SendSetSwappableGreatWork(activePlayerID(), typeID, -1)
                end,
            })
            local works = activePlayer():GetGreatWorks(typeID) or {}
            for _, w in ipairs(works) do
                local idx = w.Index
                local name = Locale.ConvertTextKey(Game.GetGreatWorkName(idx))
                local era = Locale.ConvertTextKey(Game.GetGreatWorkEraShort(idx))
                local creator = civDisplayName(Players[w.Creator])
                items[#items + 1] = BaseMenuItems.Text({
                    labelFn = function()
                        local theming = Game.GetGreatWorkCurrentThemingBonus(idx)
                        return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_WORK_ENTRY", name, era, creator, theming or 0)
                    end,
                    tooltipFn = function()
                        return Game.GetGreatWorkTooltip(idx, activePlayerID())
                    end,
                    onActivate = function()
                        Network.SendSetSwappableGreatWork(activePlayerID(), typeID, idx)
                    end,
                })
            end
            return items
        end,
    })
end

-- Foreign-civ slot leaf. Activating sets m_swapTheirItem and auto-pairs
-- m_swapYourItem with the matching-type swappable (mirror of engine
-- CheckAvailableSwap branch).
local function buildForeignSlotItem(typeID, typeNameKey, gwIndex, ownerID)
    return BaseMenuItems.Text({
        labelFn = function()
            if gwIndex < 0 then
                return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_EMPTY", Text.key(typeNameKey))
            end
            local name = Locale.ConvertTextKey(Game.GetGreatWorkName(gwIndex))
            local era = Locale.ConvertTextKey(Game.GetGreatWorkEraShort(gwIndex))
            local creatorID = Game.GetGreatWorkCreator(gwIndex)
            local creator = civDisplayName(Players[creatorID])
            return Text.format(
                "TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED",
                Text.key(typeNameKey),
                name,
                era,
                creator
            )
        end,
        tooltipFn = function()
            if gwIndex >= 0 then
                return Game.GetGreatWorkTooltip(gwIndex, ownerID)
            end
            return nil
        end,
        onActivate = function()
            if gwIndex < 0 then
                return
            end
            m_swapTheirItem = gwIndex
            m_swapTradingPartner = ownerID
            -- Auto-pair our matching-type swappable, mirroring engine
            -- CheckAvailableSwap. typeID for SelectYourWork is the engine
            -- enum; map our Writing(3)/Art(1)/Artifact(2) tags to the
            -- swappable accessors via swappableForType.
            m_swapYourItem = swappableForType(typeID)
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_PAIRED"))
        end,
    })
end

local function buildForeignOfferingsGroup()
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_OFFERINGS"),
        cached = false,
        itemsFn = function()
            local items = {}
            local others = activePlayer():GetOthersGreatWorks() or {}
            for _, v in ipairs(others) do
                local civPlayer = Players[v.iPlayer]
                local civLabel = civDisplayName(civPlayer)
                items[#items + 1] = BaseMenuItems.Group({
                    labelText = civLabel,
                    cached = false,
                    itemsFn = function()
                        return {
                            buildForeignSlotItem(
                                3,
                                "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING",
                                v.WritingIndex,
                                v.iPlayer
                            ),
                            buildForeignSlotItem(1, "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART", v.ArtIndex, v.iPlayer),
                            buildForeignSlotItem(
                                2,
                                "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT",
                                v.ArtifactIndex,
                                v.iPlayer
                            ),
                        }
                    end,
                })
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

local function buildSwapItems()
    local items = {}
    items[#items + 1] = BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE"),
        cached = false,
        itemsFn = function()
            return {
                buildDesignateGroup(3, "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"),
                buildDesignateGroup(1, "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"),
                buildDesignateGroup(2, "TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"),
            }
        end,
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local detail
            if m_swapYourItem < 0 then
                detail = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_OFFER_NONE")
            else
                detail = gwShortDesc(m_swapYourItem)
            end
            return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFER", detail)
        end,
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local detail
            if m_swapTheirItem < 0 then
                detail = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_OFFER_NONE")
            else
                detail = gwShortDesc(m_swapTheirItem, m_swapTradingPartner)
            end
            return Text.format("TXT_KEY_CIVVACCESS_CO_SWAP_THEIR_OFFER", detail)
        end,
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_BUTTON"),
        onActivate = function()
            if m_swapTheirItem >= 0 and m_swapYourItem >= 0 and m_swapTradingPartner >= 0 then
                Network.SendSwapGreatWorks(activePlayerID(), m_swapYourItem, m_swapTradingPartner, m_swapTheirItem)
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_SENT"))
                m_swapTheirItem = -1
                m_swapYourItem = -1
                m_swapTradingPartner = -1
            else
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_NOT_READY"))
            end
        end,
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_BUTTON"),
        onActivate = function()
            m_swapTheirItem = -1
            m_swapYourItem = -1
            m_swapTradingPartner = -1
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CO_SWAP_CLEARED"))
        end,
    })
    items[#items + 1] = buildForeignOfferingsGroup()
    return items
end

-- ===== Tab 3 (Culture Victory) =========================================

local function publicOpinionText(opinionType)
    if opinionType == PublicOpinionTypes.PUBLIC_OPINION_CONTENT then
        return Locale.ConvertTextKey("TXT_KEY_CO_PUBLIC_OPINION_CONTENT")
    end
    if opinionType == PublicOpinionTypes.PUBLIC_OPINION_DISSIDENTS then
        return Locale.ConvertTextKey("TXT_KEY_CO_PUBLIC_OPINION_DISSIDENTS")
    end
    if opinionType == PublicOpinionTypes.PUBLIC_OPINION_CIVIL_RESISTANCE then
        return Locale.ConvertTextKey("TXT_KEY_CO_PUBLIC_OPINION_CIVIL_RESISTANCE")
    end
    if opinionType == PublicOpinionTypes.PUBLIC_OPINION_REVOLUTIONARY_WAVE then
        return Locale.ConvertTextKey("TXT_KEY_CO_PUBLIC_OPINION_REVOLUTIONARY_WAVE")
    end
    return Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA")
end

local function buildVictoryRowGroup(pPlayer)
    local id = pPlayer:GetID()
    return BaseMenuItems.Group({
        labelFn = function()
            local p = Players[id]
            local civ = civDisplayName(p)
            local infCount = p:GetNumCivsInfluentialOn()
            local infTotal = p:GetNumCivsToBeInfluentialOn()
            local infText = Text.format("TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF", infCount, infTotal)
            local tourism = p:GetTourism()
            local ideologyText
            local opinionText
            local unhappyText
            local happyText
            local ideoBranch = p:GetLateGamePolicyTree()
            if ideoBranch ~= PolicyBranchTypes.NO_POLICY_BRANCH_TYPE then
                ideologyText = Locale.ConvertTextKey(GameInfo.PolicyBranchTypes[ideoBranch].Description)
                opinionText = publicOpinionText(p:GetPublicOpinionType())
                local unhappiness = -1 * p:GetPublicOpinionUnhappiness()
                unhappyText = Locale.ConvertTextKey("TXT_KEY_CO_PUBLIC_OPINION_UNHAPPINESS", unhappiness)
            else
                ideologyText = Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY")
                opinionText = Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA")
                unhappyText = "0"
            end
            -- Excess happiness is the player's overall happiness buffer; it
            -- exists regardless of ideology (city happiness summed minus
            -- unhappiness from all sources). Public-opinion unhappiness only
            -- meaningfully kicks in once an ideology is chosen, but the
            -- buffer itself is always live, so query GetExcessHappiness in
            -- both branches.
            happyText = formatSigned(p:GetExcessHappiness())
            return Text.format(
                "TXT_KEY_CIVVACCESS_CO_VICTORY_ROW",
                civ,
                infText,
                tourism,
                ideologyText,
                opinionText,
                unhappyText,
                happyText
            )
        end,
        cached = false,
        itemsFn = function()
            local p = Players[id]
            local items = {}
            local ideoBranch = p:GetLateGamePolicyTree()
            if ideoBranch ~= PolicyBranchTypes.NO_POLICY_BRANCH_TYPE then
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_DETAIL"),
                    tooltipText = p:GetPublicOpinionTooltip(),
                })
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_UNHAPPY_DETAIL"),
                    tooltipText = p:GetPublicOpinionUnhappinessTooltip(),
                })
            else
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY_DETAIL"),
                })
            end
            return items
        end,
    })
end

local function buildVictoryItems()
    local items = {}
    local players = {}
    for _, p in eachMetMajorAlive() do
        players[#players + 1] = p
    end
    table.sort(players, function(a, b)
        return a:GetTourism() > b:GetTourism()
    end)
    for _, p in ipairs(players) do
        items[#items + 1] = buildVictoryRowGroup(p)
    end
    if #items == 0 then
        items[1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_CO_VICTORY_NO_CIVS"),
        })
    end
    return items
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
        return Locale.ConvertTextKey("TXT_KEY_CO_UNKNOWN")
    end
    return Locale.ConvertTextKey(key)
end

-- Bonuses-at-level callout. Engine concatenates this onto the level
-- tooltip; we surface it as a separate drill-in line so the user can read
-- the level-tier description without scrolling the tooltip mid-paragraph.
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

local function buildInfluenceRowGroup(targetID)
    return BaseMenuItems.Group({
        labelFn = function()
            local pSel = Players[g_iSelectedPlayerID]
            local pTgt = Players[targetID]
            local civ = civDisplayName(pTgt)
            local levelText = influenceLevelText(pSel:GetInfluenceLevel(targetID))
            local influence = pSel:GetInfluenceOn(targetID)
            local culture = pTgt:GetJONSCultureEverGenerated()
            local pct = 0
            if culture > 0 then
                pct = math.floor((influence / culture) * 100 + 0.5)
            end
            local perTurn = math.floor(pSel:GetInfluencePerTurn(targetID))
            -- Modifier and trend live on drill-in items rather than the row:
            -- modifier becomes "Tourism modifier N percent" with the engine's
            -- itemized breakdown on tooltip (so the bare number isn't
            -- contextless); trend is implied by the per-turn sign and the
            -- estimated-turns-to-influential line below.
            return Text.format("TXT_KEY_CIVVACCESS_CO_INFLUENCE_ROW", civ, levelText, pct, formatSigned(perTurn))
        end,
        cached = false,
        itemsFn = function()
            local pSel = Players[g_iSelectedPlayerID]
            local pTgt = Players[targetID]
            local items = {}
            -- Bonuses-at-level callout.
            local level = pSel:GetInfluenceLevel(targetID)
            local bonusKey = levelBonusKey(level)
            if bonusKey ~= nil then
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Locale.ConvertTextKey(bonusKey),
                })
            end
            -- Modifier breakdown. The label carries the live modifier value
            -- (e.g. "Tourism modifier +50 percent") so a bare drill-in line
            -- isn't contextless; the tooltip is the engine's itemized list
            -- of which boosts and penalties contributed. Show only when
            -- the engine has a non-empty breakdown to drill into.
            local modTooltipNow = pSel:GetTourismModifierWithTooltip(targetID)
            if modTooltipNow ~= nil and modTooltipNow ~= "" then
                items[#items + 1] = BaseMenuItems.Text({
                    labelFn = function()
                        return Text.format(
                            "TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIERS_LABEL",
                            formatSigned(Players[g_iSelectedPlayerID]:GetTourismModifierWith(targetID))
                        )
                    end,
                    tooltipFn = function()
                        return Players[g_iSelectedPlayerID]:GetTourismModifierWithTooltip(targetID)
                    end,
                })
            end
            -- Estimated turns-to-Influential, surfaced when the engine
            -- would have shown the trend tooltip (Rising and below
            -- Influential).
            local trend = pSel:GetInfluenceTrend(targetID)
            local turnsTo = pSel:GetTurnsToInfluential(targetID)
            if
                trend == InfluenceLevelTrend.INFLUENCE_TREND_RISING
                and turnsTo ~= 999
                and level < InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
            then
                items[#items + 1] = BaseMenuItems.Text({
                    labelText = Text.format("TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO", turnsTo),
                })
            end
            -- Bar tooltips: your tourism on them vs their lifetime
            -- culture. Sighted players read these as comparative bar
            -- lengths; we speak the absolute numbers.
            local influence = pSel:GetInfluenceOn(targetID)
            local culture = pTgt:GetJONSCultureEverGenerated()
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format("TXT_KEY_CIVVACCESS_CO_INFLUENCE_BAR_YOURS", formatNumber(influence)),
            })
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format("TXT_KEY_CIVVACCESS_CO_INFLUENCE_BAR_THEIRS", formatNumber(culture)),
            })
            return items
        end,
    })
end

-- Perspective picker. Wraps the engine's PlayerPD pulldown via
-- BaseMenuItems.Pulldown so the engine's RegisterSelectionCallback
-- (sets g_iSelectedPlayerID, rebuilds the visual influence stack) does
-- the per-perspective state mutation; our onSelected hook then rebuilds
-- the per-civ row list against the new perspective. The Pulldown's label
-- and current value both come from civDisplayName so the announce form
-- matches the rest of the wrapper (engine's pulldown uses the short
-- "Roman Empire" form; we want "Augustus of Roman Empire" for parity
-- with row labels). entryAnnounceFn replaces each sub-menu entry's
-- engine-text default with the same rich form so browsing the picker
-- reads the leader/civ pair, not just the civ short description.
local function buildPerspectivePulldown()
    local function perspectiveText()
        return Text.format("TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE", civDisplayName(Players[g_iSelectedPlayerID]))
    end
    return BaseMenuItems.Pulldown({
        controlName = "PlayerPD",
        labelFn = perspectiveText,
        valueFn = perspectiveText,
        entryAnnounceFn = function(inst)
            local pid = inst.Button:GetVoid1()
            return civDisplayName(Players[pid])
        end,
        onSelected = function()
            m_influenceTab.menu().setItems(buildInfluenceItems())
        end,
    })
end

buildInfluenceItems = function()
    local items = {}
    items[#items + 1] = buildPerspectivePulldown()
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            return Text.format("TXT_KEY_CIVVACCESS_CO_INFLUENCE_TOURISM", Players[g_iSelectedPlayerID]:GetTourism())
        end,
    })
    -- Every alive non-minor civ that isn't the selected player and that
    -- the selected player has any influence level on. Mirrors engine's
    -- iteration filter exactly so the row set matches.
    local pSel = Players[g_iSelectedPlayerID]
    for i = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local p = Players[i]
        if p ~= nil and p:IsAlive() and not p:IsMinorCiv() and i ~= g_iSelectedPlayerID then
            local level = pSel:GetInfluenceLevel(i)
            if level ~= InfluenceLevelTypes.NO_INFLUENCE_LEVEL then
                items[#items + 1] = buildInfluenceRowGroup(i)
            end
        end
    end
    if #items <= 2 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_CO_INFLUENCE_NO_TARGETS"),
        })
    end
    return items
end

-- ===== Install =========================================================

if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then
    -- Patch the engine PullDown metatable so RegisterSelectionCallback /
    -- BuildEntry / ClearEntries are captured before the engine's
    -- SortAndDisplayPlayerInfluence first runs (popup-show flow). Without
    -- the probe in place, BaseMenuItems.Pulldown over PlayerPD has no
    -- engine callback to invoke from keyboard activation. Idempotent
    -- across the lua_State; a no-op if FrontEnd ProbeBoot already ran.
    PullDownProbe.installFromControls({ "PlayerPD" }, {}, {}, {})
    m_yourCultureTab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CULTURE_OVERVIEW"),
            items = {},
        },
    })
    m_swapTab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CULTURE_OVERVIEW"),
            items = {},
        },
    })
    m_victoryTab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_CO_TAB_VICTORY",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CULTURE_OVERVIEW"),
            items = {},
        },
    })
    m_influenceTab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CULTURE_OVERVIEW"),
            items = {},
        },
    })
    TabbedShell.install(ContextPtr, {
        name = "CultureOverview",
        displayName = Text.key("TXT_KEY_CULTURE_OVERVIEW"),
        tabs = { m_yourCultureTab, m_swapTab, m_victoryTab, m_influenceTab },
        initialTabIndex = 1,
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(_handler)
            -- Reset transient mod-side state on every open so a previous
            -- session's in-flight selection (move source, swap pairing)
            -- doesn't bleed into the new view. Tab 4's perspective is the
            -- engine's g_iSelectedPlayerID; the engine itself does not
            -- reset it on popup close, so a sighted player's perspective
            -- pick persists across reopen — we mirror that.
            m_gwMoveSource = nil
            m_swapTheirItem = -1
            m_swapYourItem = -1
            m_swapTradingPartner = -1
            -- Force the engine's PlayerInfluence refresh whenever it isn't
            -- the visually current tab. priorShowHide above ran the engine's
            -- TabSelect(g_CurrentTab), which only rebuilds one panel — and
            -- only that panel's pulldowns get BuildEntry / RegisterSelection-
            -- Callback called. Our Tab 4 perspective wraps Controls.PlayerPD
            -- via PullDownProbe, so without this refresh the pulldown opens
            -- empty (no captured entries, no captured callback) and Enter
            -- on it just re-speaks the current value. RefreshContent is
            -- the engine's own combined refresh hook; cheap and idempotent
            -- (panel stays hidden, just rebuilds the data and entries).
            if
                g_CurrentTab ~= "PlayerInfluence"
                and type(g_Tabs) == "table"
                and g_Tabs["PlayerInfluence"] ~= nil
                and type(g_Tabs["PlayerInfluence"].RefreshContent) == "function"
            then
                local ok, err = pcall(g_Tabs["PlayerInfluence"].RefreshContent)
                if not ok then
                    Log.error("CultureOverview: PlayerInfluence prefetch failed: " .. tostring(err))
                end
            end
            m_yourCultureTab.menu().setItems(buildYourCultureItems())
            m_swapTab.menu().setItems(buildSwapItems())
            m_victoryTab.menu().setItems(buildVictoryItems())
            m_influenceTab.menu().setItems(buildInfluenceItems())
        end,
    })

    -- Engine fires SerialEventCityInfoDirty after a Network.SendMoveGreatWorks
    -- and a Network.SendSwapGreatWorks completes. Refresh Tab 1 so post-move
    -- slot states reflect on next drill-in. Tab 2 also depends on swap
    -- state, so refresh it too. cached=false on every Group inside Tabs 1
    -- and 2 makes drill-ins re-query, but the top-level rebuild covers
    -- removal of cities (capture / liberation between turns is theoretical
    -- but cheap to handle). Guard on IsHidden so we don't waste work when
    -- the popup isn't open.
    Events.SerialEventCityInfoDirty.Add(function()
        if ContextPtr:IsHidden() then
            return
        end
        if m_yourCultureTab ~= nil then
            m_yourCultureTab.menu().setItems(buildYourCultureItems())
        end
        if m_swapTab ~= nil then
            m_swapTab.menu().setItems(buildSwapItems())
        end
    end)
end

-- ===== Module exports for tests ========================================

CultureOverviewAccess.formatSigned = formatSigned
CultureOverviewAccess.formatNumber = formatNumber
CultureOverviewAccess.civDisplayName = civDisplayName

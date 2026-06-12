-- Shared rich civ-label builder. Used by SelectCivilization's picker and
-- AdvancedSetup's civ pulldown so both screens produce the same detail:
-- leader, civ short name, unique ability (name + description), unique
-- unit, unique building, unique improvement. Keeps the two screens from
-- drifting.
--
-- The queries are DB.CreateQuery'd at module load so they're prepared
-- once per Context sandbox and reused for each civ-row lookup.

CivDetails = {}

-- LEFT JOIN onto the overridden class's default unit/building so each row
-- carries what the unique stands in for. Rows where the class has no
-- default (or where the unique IS the default) come back with a nil
-- ReplacesDesc and render without the "replaces X" suffix.
local uniqueUnitsQuery = DB.CreateQuery([[SELECT
        UniqueUnit.Description AS UniqueDesc,
        DefaultUnit.Description AS ReplacesDesc
    FROM Civilization_UnitClassOverrides
        INNER JOIN Units AS UniqueUnit
            ON UniqueUnit.Type = Civilization_UnitClassOverrides.UnitType
        INNER JOIN UnitClasses
            ON UnitClasses.Type = Civilization_UnitClassOverrides.UnitClassType
        LEFT JOIN Units AS DefaultUnit
            ON DefaultUnit.Type = UnitClasses.DefaultUnit
    WHERE Civilization_UnitClassOverrides.CivilizationType = ?
        AND Civilization_UnitClassOverrides.UnitType IS NOT NULL]])

local uniqueBuildingsQuery = DB.CreateQuery([[SELECT
        UniqueBuilding.Description AS UniqueDesc,
        DefaultBuilding.Description AS ReplacesDesc
    FROM Civilization_BuildingClassOverrides
        INNER JOIN Buildings AS UniqueBuilding
            ON UniqueBuilding.Type = Civilization_BuildingClassOverrides.BuildingType
        INNER JOIN BuildingClasses
            ON BuildingClasses.Type = Civilization_BuildingClassOverrides.BuildingClassType
        LEFT JOIN Buildings AS DefaultBuilding
            ON DefaultBuilding.Type = BuildingClasses.DefaultBuilding
    WHERE Civilization_BuildingClassOverrides.CivilizationType = ?
        AND Civilization_BuildingClassOverrides.BuildingType IS NOT NULL]])

-- Improvements are additive (Moai, Polder, Feitoria add a new buildable
-- rather than replacing a default), so no Replaces clause here.
local uniqueImprovementsQuery = DB.CreateQuery([[SELECT Description FROM Improvements WHERE CivilizationType = ?]])

local traitsQuery = DB.CreateQuery([[SELECT Description, ShortDescription FROM Traits
    INNER JOIN Leader_Traits ON Traits.Type = Leader_Traits.TraitType
    WHERE Leader_Traits.LeaderType = ? LIMIT 1]])

local function appendLabeled(parts, labelKey, value)
    if value == nil or value == "" then
        return
    end
    parts[#parts + 1] = Text.key(labelKey) .. ": " .. value
end

local function appendUnique(parts, labelKey, uniqueDesc, replacesDesc)
    local name = Text.key(uniqueDesc)
    if name == nil or name == "" then
        return
    end
    local value = name
    -- replacesDesc is nil when the unique's class has no default to stand
    -- in for (the LEFT JOIN miss documented above; several VP uniques are
    -- additions rather than replacements).
    if replacesDesc ~= nil then
        local replaces = Text.key(replacesDesc)
        if replaces ~= nil and replaces ~= "" and replaces ~= name then
            value = value .. ", " .. Text.format("TXT_KEY_CIVVACCESS_REPLACES", replaces)
        end
    end
    parts[#parts + 1] = Text.key(labelKey) .. ": " .. value
end

-- `row` must carry LeaderDescription, ShortDescription, Type, LeaderType.
-- Returns a ", "-joined string with each piece prefix-labeled where the
-- prefix helps distinguish the value (Unique ability: X, ...). Civ /
-- leader names don't get prefixes because the surrounding context makes
-- them obvious.
function CivDetails.richLabel(row)
    local parts = {
        Text.key(row.LeaderDescription),
        Text.key(row.ShortDescription),
    }
    for t in traitsQuery(row.LeaderType) do
        local name = Text.key(t.ShortDescription)
        local desc = Text.key(t.Description)
        if name ~= nil and name ~= "" then
            local value = name
            if desc ~= nil and desc ~= "" then
                value = value .. ", " .. desc
            end
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIQUE_ABILITY") .. ": " .. value
        end
    end
    for urow in uniqueUnitsQuery(row.Type) do
        appendUnique(parts, "TXT_KEY_CIVVACCESS_UNIQUE_UNIT", urow.UniqueDesc, urow.ReplacesDesc)
    end
    for urow in uniqueBuildingsQuery(row.Type) do
        appendUnique(parts, "TXT_KEY_CIVVACCESS_UNIQUE_BUILDING", urow.UniqueDesc, urow.ReplacesDesc)
    end
    for urow in uniqueImprovementsQuery(row.Type) do
        appendLabeled(parts, "TXT_KEY_CIVVACCESS_UNIQUE_IMPROVEMENT", Text.key(urow.Description))
    end
    return table.concat(parts, ", ")
end

-- Returns the pulldown-ordered label list used by AdvancedSetup's civ
-- pulldown (both the human's and each per-slot one). Index 1 is the
-- "random" entry base builds first; indices 2..N+1 are the playable
-- civilizations sorted by leader description, matching the order base's
-- Civs.FullSync feeds BuildEntry.
function CivDetails.pulldownLabels()
    local labels = {
        Text.key("TXT_KEY_RANDOM_LEADER") .. ", " .. Text.key("TXT_KEY_RANDOM_CIV"),
    }
    local sql = [[SELECT
        Civilizations.ID,
        Civilizations.Type,
        Civilizations.ShortDescription,
        Leaders.Type AS LeaderType,
        Leaders.Description AS LeaderDescription
        FROM Civilizations, Leaders, Civilization_Leaders WHERE
        Civilizations.Type = Civilization_Leaders.CivilizationType AND
        Leaders.Type = Civilization_Leaders.LeaderheadType AND
        Civilizations.Playable = 1]]
    local entries = {}
    for row in DB.Query(sql) do
        entries[#entries + 1] = { Text.key(row.LeaderDescription), row }
    end
    table.sort(entries, function(a, b)
        return Locale.Compare(a[1], b[1]) == -1
    end)
    for _, entry in ipairs(entries) do
        labels[#labels + 1] = CivDetails.richLabel(entry[2])
    end
    return labels
end

return CivDetails

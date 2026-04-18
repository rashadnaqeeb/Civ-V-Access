-- Select Civilization accessibility wiring.
-- Modal popup, opened via UIManager:QueuePopup from the parent screen.
-- Items rebuild on every show because DLC activation and scenario toggle
-- both reshape the playable-civ set; the base file gates its InstanceManager
-- rebuild on g_bRefreshCivs / WB map, but rebuilding our items every show
-- is cheap and removes the dependency on those flags.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler
local handler

local function buildRegularItems(traitsQuery)
    local items = {
        BaseMenuItems.Choice({
            labelText   = Text.key("TXT_KEY_RANDOM_LEADER") .. ", "
                        .. Text.key("TXT_KEY_RANDOM_CIV"),
            tooltipText = Text.key("TXT_KEY_RANDOM_LEADER_HELP"),
            activate    = function() CivilizationSelected(-1) end,
        }),
    }
    local entries = {}
    local sql = [[SELECT
        Civilizations.ID,
        Civilizations.Description,
        Civilizations.ShortDescription,
        Leaders.Type AS LeaderType,
        Leaders.Description AS LeaderDescription
        FROM Civilizations, Leaders, Civilization_Leaders WHERE
        Civilizations.Type = Civilization_Leaders.CivilizationType AND
        Leaders.Type = Civilization_Leaders.LeaderheadType AND
        Civilizations.Playable = 1]]
    for row in DB.Query(sql) do
        entries[#entries + 1] = { Text.key(row.LeaderDescription), row }
    end
    table.sort(entries, function(a, b) return Locale.Compare(a[1], b[1]) == -1 end)
    for _, entry in ipairs(entries) do
        local row = entry[2]
        local civID = row.ID
        local traitShort, traitLong
        for t in traitsQuery(row.LeaderType) do
            traitShort = Text.key(t.ShortDescription)
            traitLong  = Text.key(t.Description)
        end
        local parts = {
            Text.key(row.LeaderDescription),
            Text.key(row.ShortDescription),
        }
        if traitShort ~= nil and traitShort ~= "" then
            parts[#parts + 1] = traitShort
        end
        items[#items + 1] = BaseMenuItems.Choice({
            labelText   = table.concat(parts, ", "),
            tooltipText = traitLong,
            activate    = function() CivilizationSelected(civID) end,
        })
    end
    return items
end

local function buildScenarioItems(traitsQuery)
    local items = {}
    local civList = UI.GetMapPlayers(PreGame.GetMapScript())
    if civList == nil then return items end
    local query = DB.CreateQuery([[SELECT
        Civilizations.ID,
        Civilizations.ShortDescription,
        Leaders.Type AS LeaderType,
        Leaders.Description AS LeaderDescription
        FROM Civilizations, Leaders, Civilization_Leaders WHERE
        Civilizations.ID = ? AND
        Civilizations.Type = Civilization_Leaders.CivilizationType AND
        Leaders.Type = Civilization_Leaders.LeaderheadType LIMIT 1]])
    local entries = {}
    for i, v in pairs(civList) do
        if v.Playable then
            for row in query(v.CivType) do
                entries[#entries + 1] = {
                    Text.key(row.LeaderDescription), row, i - 1,
                }
            end
        end
    end
    table.sort(entries, function(a, b) return Locale.Compare(a[1], b[1]) == -1 end)
    for _, entry in ipairs(entries) do
        local row = entry[2]
        local scenarioCivID = entry[3]
        local civID = row.ID
        local traitShort, traitLong
        for t in traitsQuery(row.LeaderType) do
            traitShort = Text.key(t.ShortDescription)
            traitLong  = Text.key(t.Description)
        end
        local parts = {
            Text.key(row.LeaderDescription),
            Text.key(row.ShortDescription),
        }
        if traitShort ~= nil and traitShort ~= "" then
            parts[#parts + 1] = traitShort
        end
        items[#items + 1] = BaseMenuItems.Choice({
            labelText   = table.concat(parts, ", "),
            tooltipText = traitLong,
            activate    = function()
                CivilizationSelected(civID, scenarioCivID)
            end,
        })
    end
    return items
end

local function rebuildItems()
    local traitsQuery = DB.CreateQuery([[SELECT Description, ShortDescription FROM Traits
        INNER JOIN Leader_Traits ON Traits.Type = Leader_Traits.TraitType
        WHERE Leader_Traits.LeaderType = ? LIMIT 1]])
    local items
    if PreGame.GetLoadWBScenario() and IsWBMap(PreGame.GetMapScript()) then
        items = buildScenarioItems(traitsQuery)
    else
        items = buildRegularItems(traitsQuery)
    end
    if handler ~= nil then handler.setItems(items) end
    return items
end

handler = BaseMenu.install(ContextPtr, {
    name          = "SelectCivilization",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CIVILIZATION"),
    priorShowHide = function(bIsHide, bIsInit)
        if priorShowHide ~= nil then priorShowHide(bIsHide, bIsInit) end
        if not bIsHide then rebuildItems() end
    end,
    priorInput    = priorInput,
    items         = rebuildItems(),
})

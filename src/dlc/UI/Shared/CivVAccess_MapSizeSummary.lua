-- Shared helper that produces a supported-size suffix per Map Type
-- pulldown entry. AdvancedSetup (SP) and MPGameSetup call this to attach
-- a concise size-constraint announcement to each sub-menu entry at the
-- Map Type decision point, so the user learns that e.g. a scenario is
-- pinned to a single world size before committing to it.
--
-- Three shapes contribute entries to a Map Type pulldown:
--   * Pure map scripts -- Lua generators that take world size as input;
--     no constraint.
--   * Maps() table rows -- constrained to the subset of world sizes that
--     have a Map_Sizes row keyed to the row's MapType. If the subset
--     covers every world size we suppress the suffix (common case:
--     Earth ships with all six).
--   * Loose WB map files not referenced by Map_Sizes -- pinned to the
--     single world size embedded in the map preview's MapSize field.
--
-- Both screens' base code iterates these three sources in this order and
-- sorts the combined list. Iteration is identical; only the MapScripts
-- filter (SupportsSinglePlayer vs SupportsMultiplayer) and the sort
-- comparator (Locale.Compare vs raw string <) differ. The helper takes
-- both as parameters and returns a table keyed by 1-based sorted index
-- matching the pulldown entries each base file will BuildEntry.

MapSizeSummary = {}

local function worldNameById(worldID)
    local w = GameInfo.Worlds[worldID]
    if w == nil then return nil end
    return Text.key(w.Description)
end

local function worldNameByType(typeKey)
    local w = GameInfo.Worlds[typeKey]
    if w == nil then return nil end
    return Text.key(w.Description)
end

-- scriptFilter: table passed to GameInfo.MapScripts (e.g.
--   { SupportsSinglePlayer = 1, Hidden = 0 } or { SupportsMultiplayer = 1 }).
-- sortCmp: fn(a, b) -> bool for table.sort. Receives rows with `name`
--   (pre-localized) and size metadata; compare on `a.name` and `b.name`.
-- Returns labels indexed 1..N. Nil entries mean "no suffix"; strings are
-- formatted via TXT_KEY_CIVVACCESS_MAP_SIZE_ONLY (single size) or
-- TXT_KEY_CIVVACCESS_MAP_SIZE_LIMITED (partial set).
function MapSizeSummary.labelsFor(scriptFilter, sortCmp)
    local rows = {}
    for row in GameInfo.MapScripts(scriptFilter) do
        rows[#rows + 1] = {
            name     = Locale.ConvertTextKey(row.Name),
            allSizes = true,
        }
    end
    for row in GameInfo.Maps() do
        local sizes = {}
        for srow in GameInfo.Map_Sizes{MapType = row.Type} do
            sizes[#sizes + 1] = worldNameByType(srow.WorldSizeType)
        end
        rows[#rows + 1] = {
            name  = Locale.Lookup(row.Name),
            sizes = sizes,
        }
    end
    -- Loose WB files not referenced by Map_Sizes are pinned to wb.MapSize.
    local filter = {}
    for row in GameInfo.Map_Sizes() do filter[row.FileName] = true end
    for _, map in ipairs(Modding.GetMapFiles()) do
        if not filter[map.File] then
            local wb = UI.GetMapPreview(map.File)
            local name
            if map.Name and not Locale.IsNilOrWhitespace(map.Name) then
                name = map.Name
            elseif wb ~= nil and not Locale.IsNilOrWhitespace(wb.Name) then
                name = Locale.Lookup(wb.Name)
            else
                name = Path.GetFileNameWithoutExtension(map.File)
            end
            local sizes = {}
            if wb ~= nil and wb.MapSize ~= nil then
                local s = worldNameById(wb.MapSize)
                if s ~= nil then sizes[#sizes + 1] = s end
            end
            rows[#rows + 1] = { name = name, sizes = sizes }
        end
    end

    table.sort(rows, sortCmp)

    local total = 0
    for _ in GameInfo.Worlds("ID >= 0") do total = total + 1 end

    local labels = {}
    for i, s in ipairs(rows) do
        if s.allSizes or s.sizes == nil or #s.sizes == 0 then
            labels[i] = nil
        elseif #s.sizes == total then
            -- Constrained set covers every size the game ships; no signal.
            labels[i] = nil
        elseif #s.sizes == 1 then
            labels[i] = Text.format("TXT_KEY_CIVVACCESS_MAP_SIZE_ONLY",
                s.sizes[1])
        else
            labels[i] = Text.format("TXT_KEY_CIVVACCESS_MAP_SIZE_LIMITED",
                table.concat(s.sizes, ", "))
        end
    end
    return labels
end

return MapSizeSummary

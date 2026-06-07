-- Scanner backend: queued-move waypoints. Source of truth is
-- WaypointsCore (cached by selection / queue signature); this file is
-- just the scanner shape.
--
-- Two modes, gated by the "show only selected unit waypoints in scanner"
-- setting (on by default, read live from civvaccess_shared):
--   * On: one entry per plot the selected unit will step onto across its
--     mission queue, each its own item named "waypoint i of N".
--   * Off: every owned unit with a queued path becomes one item named for
--     the unit, and that unit's stop plots are its instances. Items group
--     by unit ID (itemKey), not name, so two same-named units stay
--     separate -- the player hears "Warrior" twice but the snapshot keeps
--     them apart. Per-unit numbering comes free from the instance count.
--
-- Multiple waypoints can land on the same plot (a queue with reversal
-- legs walks the same plot twice). Each gets its own scanner entry with
-- a unique key so identity-preserving rebuild doesn't collapse them.

ScannerBackendWaypoints = {
    name = "waypoints",
}

local function selectedOnly()
    return civvaccess_shared.scannerSelectedWaypointsOnly ~= false
end

local function scanSelected()
    local out = {}
    local list = Waypoints.list()
    for i, wp in ipairs(list) do
        local plot = Map.GetPlot(wp.x, wp.y)
        if plot ~= nil then
            local plotIdx = plot:GetPlotIndex()
            out[#out + 1] = {
                plotIndex = plotIdx,
                backend = ScannerBackendWaypoints,
                data = { index = i },
                category = "waypoints",
                subcategory = "all",
                itemName = Text.format("TXT_KEY_CIVVACCESS_PLOT_WAYPOINT", i, #list),
                key = "waypoints:" .. plotIdx .. ":" .. i,
                sortKey = i,
            }
        end
    end
    return out
end

local function scanAllUnits()
    local out = {}
    for _, group in ipairs(Waypoints.allUnitsList()) do
        for i, wp in ipairs(group.waypoints) do
            local plot = Map.GetPlot(wp.x, wp.y)
            if plot ~= nil then
                local plotIdx = plot:GetPlotIndex()
                out[#out + 1] = {
                    plotIndex = plotIdx,
                    backend = ScannerBackendWaypoints,
                    data = { unitID = group.unitID, index = i },
                    category = "waypoints",
                    subcategory = "all",
                    -- Live name (resolved per scan, and again in FormatName)
                    -- so a rename takes effect; never read from the cache.
                    itemName = Waypoints.unitName(group.unitID),
                    -- Group items by unit, not name, so two "Warrior"
                    -- items don't collapse. Instances number per unit.
                    itemKey = "unit:" .. group.unitID,
                    key = "waypoints:" .. group.unitID .. ":" .. plotIdx .. ":" .. i,
                    sortKey = i,
                }
            end
        end
    end
    return out
end

function ScannerBackendWaypoints.Scan(_activePlayer, _activeTeam)
    if selectedOnly() then
        return scanSelected()
    end
    return scanAllUnits()
end

-- Re-resolve against a fresh waypoint list. Membership rather than just
-- index-position because shift+queueing or a unit completing its current
-- leg changes the numbering, and an entry whose stored index falls out
-- of the live list (or whose plot no longer matches that index) must drop
-- rather than mis-announce a stale waypoint. All-units entries carry a
-- unitID and re-resolve against that unit's group; selected-only entries
-- have no unitID and re-resolve against the selected unit's list.
function ScannerBackendWaypoints.ValidateEntry(entry, _cursorPlotIndex)
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    local wp
    if entry.data.unitID ~= nil then
        for _, group in ipairs(Waypoints.allUnitsList()) do
            if group.unitID == entry.data.unitID then
                wp = group.waypoints[entry.data.index]
                break
            end
        end
    else
        wp = Waypoints.list()[entry.data.index]
    end
    if wp == nil then
        return false
    end
    return wp.x == plot:GetX() and wp.y == plot:GetY()
end

-- FormatName is the scanner's live-query seam (called at announce time).
-- All-units items re-resolve the unit's name from its id so a rename
-- spoken on the next cycle is current even without a rebuild; selected-
-- only items keep their numbered "waypoint i of N" label.
function ScannerBackendWaypoints.FormatName(entry)
    if entry.data.unitID ~= nil then
        return Waypoints.unitName(entry.data.unitID)
    end
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendWaypoints)

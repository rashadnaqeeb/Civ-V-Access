-- River edges section. Civ V's plot stores river presence for three of the
-- six hex edges as flags whose names look like edge labels but are actually
-- positional: IsNEOfRiver means "this plot is NE of a river," i.e. the
-- river runs along the plot's SW edge. By the same inversion IsWOfRiver
-- maps to the E edge and IsNWOfRiver to the SE edge. The other three edges
-- (NE, W, NW) live on the same flag of the neighbor in that direction --
-- e.g. the NE neighbor's IsNEOfRiver puts a river on its SW edge, which is
-- our NE edge. Authoritative source: CvPlot::updateRiverCrossing in the
-- SDK (CvGameCoreDLL_Expansion2/CvPlot.cpp).
--
-- We assemble all six edges and announce them in a fixed clockwise order
-- starting from NE so the same river always reads the same way regardless
-- of cursor approach. Six-of-six collapses to a single "river all sides"
-- token so the user doesn't sit through six direction tokens for what is
-- effectively "you are on a river island."

local SELF_EDGES = {
    { dir = "TXT_KEY_CIVVACCESS_DIR_SW", method = "IsNEOfRiver" },
    { dir = "TXT_KEY_CIVVACCESS_DIR_E", method = "IsWOfRiver" },
    { dir = "TXT_KEY_CIVVACCESS_DIR_SE", method = "IsNWOfRiver" },
}

-- The neighbor in direction D, checked with the same flag, owns our D edge:
-- "neighbor is D of a river" means the river is on the side of the neighbor
-- facing us.
local NEIGHBOR_EDGES = {
    { dir = "TXT_KEY_CIVVACCESS_DIR_NE", neighborDir = "DIRECTION_NORTHEAST", method = "IsNEOfRiver" },
    { dir = "TXT_KEY_CIVVACCESS_DIR_W", neighborDir = "DIRECTION_WEST", method = "IsWOfRiver" },
    { dir = "TXT_KEY_CIVVACCESS_DIR_NW", neighborDir = "DIRECTION_NORTHWEST", method = "IsNWOfRiver" },
}

-- Spoken order (clockwise from NE), independent of how we collected the
-- edges above. Keep this list as the single source of truth for output
-- ordering -- the river-all-sides collapse depends on the count matching
-- this list's length.
local SPOKEN_ORDER = {
    "TXT_KEY_CIVVACCESS_DIR_NE",
    "TXT_KEY_CIVVACCESS_DIR_E",
    "TXT_KEY_CIVVACCESS_DIR_SE",
    "TXT_KEY_CIVVACCESS_DIR_SW",
    "TXT_KEY_CIVVACCESS_DIR_W",
    "TXT_KEY_CIVVACCESS_DIR_NW",
}

PlotSectionRiver = {
    Read = function(plot)
        local edges = {}
        for _, e in ipairs(SELF_EDGES) do
            if plot[e.method](plot) then
                edges[e.dir] = true
            end
        end
        for _, e in ipairs(NEIGHBOR_EDGES) do
            local n = Map.PlotDirection(plot:GetX(), plot:GetY(), DirectionTypes[e.neighborDir])
            if n ~= nil and n[e.method](n) then
                edges[e.dir] = true
            end
        end

        local present = {}
        for _, dir in ipairs(SPOKEN_ORDER) do
            if edges[dir] then
                present[#present + 1] = Text.key(dir)
            end
        end

        if #present == 0 then
            return {}
        end
        if #present == #SPOKEN_ORDER then
            return { Text.key("TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES") }
        end
        return { Text.format("TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS", table.concat(present, " ")) }
    end,
}

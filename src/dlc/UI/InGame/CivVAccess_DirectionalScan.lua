-- Directional scan: read a straight line of tiles outward from the cursor in
-- one of the six hex directions, or a north / south composite of two
-- diagonals, without moving the cursor. Entered as a dedicated modal handler
-- so the cursor's own movement cluster (Q/E/A/D/Z/C) is repurposed to mean
-- "scan that way" while the mode is active; Escape leaves the mode and
-- restores normal cursor control. The scan never mutates game state -- every
-- key reads the map live and speaks, so repeated scans always reflect the
-- current fog / ownership picture.

DirectionalScan = {}

local bind = HandlerStack.bind
local MOD_NONE = 0

-- Radius bounds and default for the directional scan, independent of the
-- circular surveyor's radius (civvaccess_shared.surveyorRadius, max 5).
local DEFAULT_DIRSCAN_RADIUS = 3
local MIN_DIRSCAN_RADIUS = 1
local MAX_DIRSCAN_RADIUS = 10

local MODE_NAME = "DirectionalScanMode"

-- Spoken full-word heading labels, keyed by engine DirectionTypes. Distinct
-- from the cursor's terse "nw / ne" tokens (TXT_KEY_CIVVACCESS_DIR_*) because
-- a scan reads its heading in a banner where the full word is clearer, not in
-- the tight per-move glue the cursor uses.
local DIR_LABEL_KEY = {
    [DirectionTypes.DIRECTION_NORTHWEST] = "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_NW",
    [DirectionTypes.DIRECTION_NORTHEAST] = "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_NE",
    [DirectionTypes.DIRECTION_WEST] = "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_W",
    [DirectionTypes.DIRECTION_EAST] = "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_E",
    [DirectionTypes.DIRECTION_SOUTHWEST] = "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_SW",
    [DirectionTypes.DIRECTION_SOUTHEAST] = "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_SE",
}

local function dirLabel(direction)
    return Text.key(DIR_LABEL_KEY[direction])
end

-- Clamp r to the valid dirScanRadius range; substitute the default when r is
-- not a number. Used both on read (getRadius) and on explicit resolve, so
-- a value stored directly in civvaccess_shared can never propagate as-is.
local function normalizeRadius(r)
    if type(r) ~= "number" then
        return DEFAULT_DIRSCAN_RADIUS
    end
    if r < MIN_DIRSCAN_RADIUS then
        return MIN_DIRSCAN_RADIUS
    end
    if r > MAX_DIRSCAN_RADIUS then
        return MAX_DIRSCAN_RADIUS
    end
    return r
end

local function getRadius()
    local r = civvaccess_shared and civvaccess_shared.dirScanRadius
    local norm = normalizeRadius(r)
    -- Rewrite shared only when the stored value needed correction so the
    -- next read does not repeat the clamp.
    if norm ~= r and civvaccess_shared then
        civvaccess_shared.dirScanRadius = norm
    end
    return norm
end

local function setRadius(r)
    local norm = normalizeRadius(r)
    if civvaccess_shared then
        civvaccess_shared.dirScanRadius = norm
    end
    return norm
end

local function speakRadius(r)
    if r <= MIN_DIRSCAN_RADIUS then
        return Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_RADIUS_MIN", r)
    end
    if r >= MAX_DIRSCAN_RADIUS then
        return Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_RADIUS_MAX", r)
    end
    return Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_RADIUS", r)
end

local function resolveRadius(radius)
    if radius ~= nil then
        return normalizeRadius(radius)
    end
    return getRadius()
end

-- Describe one revealed tile for the scan list and return the spoken info plus
-- the owner-identity token so the caller can detect a border crossing between
-- consecutive steps. The revealed / fog gate lives in stepRay, which stops the
-- ray at the first unexplored tile before this is ever reached.
local function describeStep(plot, prevToken)
    local info = PlotComposers.glance(plot, {})
    -- An empty glance means the composer found nothing nameable (open ocean,
    -- featureless land). Substitute a stable token so the step still reads.
    if info == nil or info == "" then
        info = Text.key("TXT_KEY_CIVVACCESS_DIRSCAN_OPEN")
    end
    local ownerSpoken, ownerToken = PlotSections.ownerIdentity(plot)
    -- Announce the owning civ only when the border actually changes between
    -- steps, and never for unowned tiles (the absence of a border is not
    -- itself news). prevToken is nil on the first step, so it never fires
    -- there.
    if prevToken ~= nil and ownerToken ~= prevToken and ownerToken ~= "unclaimed" then
        info = Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_OWNER_PREFIX", ownerSpoken, info)
    end
    return info, ownerToken
end

-- Walk one ray one step. Returns the advanced coordinates, the step line, the
-- next owner token, and a status: "ok" landed on a revealed tile and the ray
-- continues; "fog" landed on an unexplored tile, so the ray stops (fog is the
-- visibility boundary); "edge" the next plot is off the map, so the ray stops
-- with the coordinates unchanged. Shared by the single-direction and composite
-- scans so both handle the two boundaries identically.
local function stepRay(x, y, direction, label, stepIndex, prevToken)
    local ok, plot = pcall(Map.PlotDirection, x, y, direction)
    if not ok then
        plot = nil
    end
    if plot == nil then
        return x, y, Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_STEP_EDGE", label, stepIndex), prevToken, "edge"
    end
    if not plot:IsRevealed(Game.GetActiveTeam(), Game.IsDebugMode()) then
        local unexplored = Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
        local line = Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_STEP", label, stepIndex, unexplored)
        return plot:GetX(), plot:GetY(), line, prevToken, "fog"
    end
    local info, token = describeStep(plot, prevToken)
    local line = Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_STEP", label, stepIndex, info)
    return plot:GetX(), plot:GetY(), line, token, "ok"
end

-- Build the spoken line list for a single-direction scan. Pure: reads the map
-- but mutates nothing and does not speak -- the caller voices the lines. Stops
-- at the map edge or the first unexplored tile and reports how far it reached.
-- startToken seeds the owner comparison with the tile under the cursor so a
-- scan that immediately crosses into another civ's land announces that civ on
-- the first step; nil suppresses the first-step owner prefix.
function DirectionalScan.scanOne(startX, startY, direction, radius, startToken)
    radius = resolveRadius(radius)
    local label = dirLabel(direction)
    local lines = {}
    local x, y = startX, startY
    local prevToken = startToken
    local reached = 0
    for step = 1, radius do
        local line, status
        x, y, line, prevToken, status = stepRay(x, y, direction, label, step, prevToken)
        lines[#lines + 1] = line
        if status == "edge" then
            lines[#lines + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_DIRSCAN_TRUNCATED", reached, reached, radius)
            return lines
        elseif status == "fog" then
            lines[#lines + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_DIRSCAN_FOGGED", reached, reached, radius)
            return lines
        end
        reached = reached + 1
    end
    lines[#lines + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_DIRSCAN_COMPLETE", reached, reached, label)
    return lines
end

-- Build the spoken line list for a composite scan: interleave two diagonal
-- rays (NW + NE for north, SW + SE for south) step by step so the user hears
-- the line grow outward symmetrically. Each ray tracks its own owner token and
-- stops independently at its own map edge or first unexplored tile. startToken
-- seeds both rays' owner comparison with the tile under the cursor, as in
-- scanOne.
function DirectionalScan.scanComposite(startX, startY, dirA, dirB, radius, compositeKey, startToken)
    radius = resolveRadius(radius)
    local labelA, labelB = dirLabel(dirA), dirLabel(dirB)
    local composite = Text.key(compositeKey)
    local lines = {}
    lines[#lines + 1] = Text.format("TXT_KEY_CIVVACCESS_DIRSCAN_BANNER", composite, labelA, labelB)
    local ax, ay = startX, startY
    local bx, by = startX, startY
    local aPrev, bPrev = startToken, startToken
    local aDone, bDone = false, false
    local reached = 0
    for step = 1, radius do
        if not aDone then
            local line, status
            ax, ay, line, aPrev, status = stepRay(ax, ay, dirA, labelA, step, aPrev)
            lines[#lines + 1] = line
            if status == "ok" then
                reached = reached + 1
            else
                aDone = true
            end
        end
        if not bDone then
            local line, status
            bx, by, line, bPrev, status = stepRay(bx, by, dirB, labelB, step, bPrev)
            lines[#lines + 1] = line
            if status == "ok" then
                reached = reached + 1
            else
                bDone = true
            end
        end
        if aDone and bDone then
            break
        end
    end
    lines[#lines + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_DIRSCAN_COMPLETE", reached, reached, composite)
    return lines
end

-- Voice a scan: the banner / first line interrupts any in-flight speech, the
-- rest queue behind it so the whole line reads as one stream the user can
-- listen through or cut off with the next key.
local function speakLines(lines)
    if not lines or #lines == 0 then
        return
    end
    SpeechPipeline.speakInterrupt(lines[1])
    for i = 2, #lines do
        SpeechPipeline.speakQueued(lines[i])
    end
end

-- Owner token of the tile the cursor sits on, so a scan that immediately
-- crosses into another civ's land announces that civ on the first step. nil
-- when the plot is unavailable, which suppresses the first-step owner prefix
-- exactly as an unseeded scan would.
local function cursorOwnerToken(x, y)
    local plot = Map.GetPlot(x, y)
    if plot == nil then
        return nil
    end
    local _, token = PlotSections.ownerIdentity(plot)
    return token
end

local function scanFrom(direction)
    local x, y = Cursor.position()
    speakLines(DirectionalScan.scanOne(x, y, direction, nil, cursorOwnerToken(x, y)))
end

local function compositeFrom(dirA, dirB, compositeKey)
    local x, y = Cursor.position()
    speakLines(DirectionalScan.scanComposite(x, y, dirA, dirB, nil, compositeKey, cursorOwnerToken(x, y)))
end

local function exitMode()
    HandlerStack.removeByName(MODE_NAME, true)
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_DIRSCAN_EXIT"))
end

-- Enter the dedicated scan mode. Pushed above Baseline with capturesAllInput
-- so the cursor's movement cluster is free to drive scanning while active;
-- beaconsTransparent keeps the audio beacons audible underneath. Escape pops
-- the mode and reactivates Baseline.
function DirectionalScan.enterMode()
    local handler = {
        name = MODE_NAME,
        capturesAllInput = true,
        beaconsTransparent = true,
        bindings = {
            bind(Keys.Q, MOD_NONE, function()
                scanFrom(DirectionTypes.DIRECTION_NORTHWEST)
            end, "Scan northwest"),
            bind(Keys.E, MOD_NONE, function()
                scanFrom(DirectionTypes.DIRECTION_NORTHEAST)
            end, "Scan northeast"),
            bind(Keys.A, MOD_NONE, function()
                scanFrom(DirectionTypes.DIRECTION_WEST)
            end, "Scan west"),
            bind(Keys.D, MOD_NONE, function()
                scanFrom(DirectionTypes.DIRECTION_EAST)
            end, "Scan east"),
            bind(Keys.Z, MOD_NONE, function()
                scanFrom(DirectionTypes.DIRECTION_SOUTHWEST)
            end, "Scan southwest"),
            bind(Keys.C, MOD_NONE, function()
                scanFrom(DirectionTypes.DIRECTION_SOUTHEAST)
            end, "Scan southeast"),
            bind(Keys.W, MOD_NONE, function()
                compositeFrom(
                    DirectionTypes.DIRECTION_NORTHWEST,
                    DirectionTypes.DIRECTION_NORTHEAST,
                    "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_N"
                )
            end, "Scan north"),
            bind(Keys.X, MOD_NONE, function()
                compositeFrom(
                    DirectionTypes.DIRECTION_SOUTHWEST,
                    DirectionTypes.DIRECTION_SOUTHEAST,
                    "TXT_KEY_CIVVACCESS_DIRSCAN_DIR_S"
                )
            end, "Scan south"),
            bind(Keys.VK_ESCAPE, MOD_NONE, exitMode, "Exit directional scan"),
            bind(Keys.VK_ADD, MOD_NONE, function()
                SpeechPipeline.speakInterrupt(speakRadius(setRadius(getRadius() + 1)))
            end, "Increase directional scan radius"),
            bind(Keys.VK_SUBTRACT, MOD_NONE, function()
                SpeechPipeline.speakInterrupt(speakRadius(setRadius(getRadius() - 1)))
            end, "Decrease directional scan radius"),
        },
        -- Empty by design: the mode is transient and its keys are announced on
        -- entry, so it opts out of the persistent map-mode help list rather
        -- than crowding it with keys only reachable inside the mode.
        helpEntries = {},
    }
    HandlerStack.push(handler)
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_DIRSCAN_ENTER"))
end

-- Baseline bindings: plain L and Numpad * both enter the scan mode. Exposed
-- via getBindings so BaselineHandler folds them into the map-mode handler the
-- same way as every other sibling feature.
function DirectionalScan.getBindings()
    return {
        bindings = {
            bind(Keys.L, MOD_NONE, DirectionalScan.enterMode, "Directional scan"),
            bind(Keys.VK_MULTIPLY, MOD_NONE, DirectionalScan.enterMode, "Directional scan (numpad)"),
        },
        helpEntries = {
            {
                keyLabel = "TXT_KEY_CIVVACCESS_DIRSCAN_HELP_KEY",
                description = "TXT_KEY_CIVVACCESS_DIRSCAN_HELP_DESC",
            },
            {
                keyLabel = "TXT_KEY_CIVVACCESS_DIRSCAN_HELP_KEY_RADIUS",
                description = "TXT_KEY_CIVVACCESS_DIRSCAN_HELP_DESC_RADIUS",
            },
        },
    }
end

Log.info("DirectionalScan module loaded")

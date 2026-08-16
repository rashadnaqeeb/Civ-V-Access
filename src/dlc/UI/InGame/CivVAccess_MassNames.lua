-- Player-given names for landmasses and bodies of water. Ctrl+N names the
-- mass under the hex cursor; the cursor speaks the name once when it
-- crosses into a differently-named mass (CivVAccess_CursorCore's diff),
-- and the scanner's geography category prefers the name over the
-- "Landmass N" ordinal (CivVAccess_ScannerBackendGeography).
--
-- Membership map. A union-find over revealed plot indices, clustered on
-- 6-neighbor hex adjacency and split by domain exactly like the geography
-- backend (land in one pool, non-lake water in the other, lakes in
-- neither). Unlike the backend's per-Scan clustering this one is
-- persistent: rebuilt from the revealed map on every in-game boot and
-- grown per-tile by the fork's GameEvents.CivVAccessPlotRevealed (fires
-- synchronously on first reveal of a plot for a team, from CvPlot::
-- setRevealed -- see CivVAccess_RevealAnnounce for the event's contract).
-- Reveal is monotonic within a session and land / water never changes, so
-- the map only ever grows or merges; every load boundary breaks that
-- monotonicity (an earlier save has fewer tiles revealed, a different
-- game a different map), which is why installListeners rebuilds from
-- scratch instead of trusting anything that survived on the shared state.
-- If a lookup ever hits a revealed, clusterable plot the map doesn't
-- know, the event path has failed; resolve() logs and self-heals with a
-- full rebuild rather than silently mis-answering.
--
-- Names. A record is { kind, anchor, seq, name }: the plot the cursor was
-- on when the name was given (anchor), a creation counter (seq), and the
-- text. A cluster's spoken name is the OLDEST record whose anchor lies
-- inside it. Merges never delete a record: when a revealed connector
-- joins two named clusters the newer name is merely shadowed by the
-- older, so loading an earlier save -- where the two masses are separate
-- again -- brings both names back on their own masses. A live merge of
-- two differently-named masses is announced once (queued, mirrored to the
-- message buffer); rebuild-time merges are not news and stay silent.
--
-- Persistence rides the same ModUserData store as Bookmarks, keyed by
-- (map seed, active player): outside the savefile, outside the MP
-- mod-hash, per player at the keyboard in hotseat. A name whose anchor
-- is not revealed in the loaded save is dormant -- attached to no
-- cluster, spoken nowhere -- and wakes when the anchor is revealed again.

MassNames = {}

-- Same store as Bookmarks (src/dlc/CivVAccess_2.Civ5Pkg GUID); distinct
-- subkey namespace. Version stays at 1 unless we deliberately migrate.
local STORE_ID = "40a9df7b-ae9f-48db-abb5-44afe0420524"
local STORE_VERSION = 1

local HEX_NEIGHBOR_DIRS = {
    DirectionTypes.DIRECTION_NORTHEAST,
    DirectionTypes.DIRECTION_EAST,
    DirectionTypes.DIRECTION_SOUTHEAST,
    DirectionTypes.DIRECTION_SOUTHWEST,
    DirectionTypes.DIRECTION_WEST,
    DirectionTypes.DIRECTION_NORTHWEST,
}

-- Module-local state, re-established by installListeners on every boot
-- (the RevealAnnounce pattern): load-from-game wipes this env, and the
-- rebuild-on-boot contract above makes carrying any of it over wrong.
local _parent = {}
local _rank = {}
-- root plotIndex -> array of name records anchored in that cluster.
local _rootNames = {}
-- All hydrated records for the current (seed, player) scope.
local _names = {}
local _nextSeq = 1
-- Records whose anchor is not yet revealed, keyed by anchor plotIndex;
-- onPlotRevealed wakes them.
local _dormantByAnchor = {}
-- Merge announcements fire only for live unions; the boot / self-heal
-- rebuild sets this false while it replays history.
local _live = false

-- Which mass domain a plot belongs to: "landmass" for land, "ocean" for
-- non-lake water, nil for lakes (a lake reads as lake terrain on the land
-- around it and never forms a body of water -- same split as the
-- geography backend).
local function poolKindOf(plot)
    if plot:IsWater() then
        if plot:IsLake() then
            return nil
        end
        return "ocean"
    end
    return "landmass"
end

-- ===== Union-find =====

local function ufFind(i)
    while _parent[i] ~= i do
        _parent[i] = _parent[_parent[i]]
        i = _parent[i]
    end
    return i
end

local function ufAdd(i)
    if _parent[i] == nil then
        _parent[i] = i
        _rank[i] = 0
    end
end

local function oldestOf(list)
    local best = list[1]
    for i = 2, #list do
        if list[i].seq < best.seq then
            best = list[i]
        end
    end
    return best
end

local function announceMerge(retiredName, keptName)
    local line = Text.format("TXT_KEY_CIVVACCESS_MASS_MERGED", retiredName, keptName)
    SpeechPipeline.speakQueued(line)
    MessageBuffer.append(line, "reveal")
end

-- Combine the name lists of two clusters that just became one. When both
-- sides were named, the older spoken name wins and the newer is shadowed;
-- a live merge of two different spoken names is announced once. Returns
-- the merged list (or nil when neither side was named).
local function mergeNameLists(listA, listB)
    if listA == nil then
        return listB
    end
    if listB == nil then
        return listA
    end
    local oldA, oldB = oldestOf(listA), oldestOf(listB)
    for i = 1, #listB do
        listA[#listA + 1] = listB[i]
    end
    if _live then
        local kept, retired
        if oldA.seq <= oldB.seq then
            kept, retired = oldA, oldB
        else
            kept, retired = oldB, oldA
        end
        if kept.name ~= retired.name then
            announceMerge(retired.name, kept.name)
        end
    end
    return listA
end

local function ufUnion(a, b)
    local ra, rb = ufFind(a), ufFind(b)
    if ra == rb then
        return
    end
    local merged = mergeNameLists(_rootNames[ra], _rootNames[rb])
    _rootNames[ra], _rootNames[rb] = nil, nil
    if _rank[ra] < _rank[rb] then
        _parent[ra] = rb
    elseif _rank[ra] > _rank[rb] then
        _parent[rb] = ra
    else
        _parent[rb] = ra
        _rank[ra] = _rank[ra] + 1
    end
    if merged ~= nil then
        _rootNames[ufFind(ra)] = merged
    end
end

-- Attach a hydrated / newly-created record to the cluster holding its
-- anchor, or park it dormant when the anchor is not revealed yet.
local function attachRec(rec)
    if _parent[rec.anchor] == nil then
        _dormantByAnchor[rec.anchor] = _dormantByAnchor[rec.anchor] or {}
        local bucket = _dormantByAnchor[rec.anchor]
        bucket[#bucket + 1] = rec
        return
    end
    local root = ufFind(rec.anchor)
    _rootNames[root] = mergeNameLists(_rootNames[root], { rec })
end

-- ===== Membership maintenance =====

-- Add one revealed plot and union it with revealed same-pool neighbors.
-- Order-independent within a reveal burst: a neighbor whose own event
-- has not arrived yet is added here, and its event later finds it
-- already present.
local function addRevealedPlot(plot, pool)
    local i = plot:GetPlotIndex()
    ufAdd(i)
    local px, py = plot:GetX(), plot:GetY()
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    for _, dir in ipairs(HEX_NEIGHBOR_DIRS) do
        local n = Map.PlotDirection(px, py, dir)
        if n ~= nil and n:IsRevealed(team, debug) and poolKindOf(n) == pool then
            ufAdd(n:GetPlotIndex())
            ufUnion(i, n:GetPlotIndex())
        end
    end
    local waking = _dormantByAnchor[i]
    if waking ~= nil then
        _dormantByAnchor[i] = nil
        for _, rec in ipairs(waking) do
            attachRec(rec)
        end
    end
end

-- Full rebuild from the revealed map: fresh union-find, then re-attach
-- every hydrated record. Costs one geography-Scan-equivalent walk; runs
-- at boot, on hotseat player switch, and from the self-heal path.
local function rebuild()
    _parent, _rank, _rootNames, _dormantByAnchor = {}, {}, {}, {}
    _live = false
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil and plot:IsRevealed(team, debug) then
            local pool = poolKindOf(plot)
            if pool ~= nil then
                addRevealedPlot(plot, pool)
            end
        end
    end
    for _, rec in ipairs(_names) do
        attachRec(rec)
    end
    _live = true
end

-- ===== Persistence =====

-- Same wrappers as Bookmarks: pcall + nil-handle, errors logged so a
-- failed persist traces to a MassNames-scoped Lua.log line.
local function openStore()
    if Modding == nil or Modding.OpenUserData == nil then
        Log.warn("MassNames: Modding.OpenUserData unavailable; persistence disabled this session")
        return nil
    end
    local ok, h = pcall(Modding.OpenUserData, STORE_ID, STORE_VERSION)
    if not ok then
        Log.error("MassNames: OpenUserData threw: " .. tostring(h))
        return nil
    end
    if h == nil then
        Log.warn("MassNames: OpenUserData returned nil")
        return nil
    end
    return h
end

local function storageKey()
    return tostring(Network.GetMapRandSeed()) .. ":" .. tostring(Game.GetActivePlayer()) .. ":massnames"
end

-- Wire format "kind,anchor,seq,name;...". Names are sanitized at commit
-- time (no comma / semicolon can survive setName), so the separators are
-- unambiguous.
local function serialize()
    local parts = {}
    for _, rec in ipairs(_names) do
        parts[#parts + 1] = rec.kind .. "," .. rec.anchor .. "," .. rec.seq .. "," .. rec.name
    end
    return table.concat(parts, ";")
end

local function deserialize(s)
    local result = {}
    if s == nil or s == "" then
        return result
    end
    for entry in string.gmatch(s, "[^;]+") do
        local kind, anchor, seq, name = string.match(entry, "([^,]+),([^,]+),([^,]+),(.+)")
        local nAnchor, nSeq = tonumber(anchor), tonumber(seq)
        if (kind == "landmass" or kind == "ocean") and nAnchor ~= nil and nSeq ~= nil and name ~= nil then
            result[#result + 1] = { kind = kind, anchor = nAnchor, seq = nSeq, name = name }
        else
            Log.warn("MassNames: skipped malformed entry: " .. tostring(entry))
        end
    end
    return result
end

local function persist()
    local store = openStore()
    if store == nil then
        return
    end
    local ok, err = pcall(function()
        store.SetValue(storageKey(), serialize())
    end)
    if not ok then
        Log.error("MassNames: SetValue threw: " .. tostring(err))
    end
end

local function hydrate()
    _names = {}
    _nextSeq = 1
    local store = openStore()
    if store == nil then
        return
    end
    local ok, raw = pcall(function()
        return store.GetValue(storageKey())
    end)
    if not ok then
        Log.error("MassNames: GetValue threw: " .. tostring(raw))
        return
    end
    _names = deserialize(raw)
    for _, rec in ipairs(_names) do
        if rec.seq >= _nextSeq then
            _nextSeq = rec.seq + 1
        end
    end
end

-- ===== Queries =====

-- The winning (oldest-attached) name record for the mass holding this
-- plot, or nil for an unnamed mass, a lake, or an unrevealed plot. The
-- self-heal rebuild covers a revealed clusterable plot the event path
-- missed -- that is a broken listener, not a normal state, so it warns.
function MassNames.resolve(plotIndex)
    if _parent[plotIndex] == nil then
        local plot = Map.GetPlotByIndex(plotIndex)
        if plot == nil or not plot:IsRevealed(Game.GetActiveTeam(), Game.IsDebugMode()) then
            return nil
        end
        if poolKindOf(plot) == nil then
            return nil
        end
        Log.warn("MassNames: revealed plot " .. plotIndex .. " missing from membership map; rebuilding")
        rebuild()
        if _parent[plotIndex] == nil then
            return nil
        end
    end
    local list = _rootNames[ufFind(plotIndex)]
    if list == nil then
        return nil
    end
    return oldestOf(list)
end

-- ===== Naming =====

-- Strip the wire-format separators as well as trimming: the input
-- handler's charset can't produce them, but the store must stay parseable
-- even if a caller ever feeds richer text.
local function sanitize(text)
    return Text.trim(string.gsub(text or "", "[,;]", ""))
end

-- Name (or rename) the mass holding plotIndex. A rename updates the
-- winning record in place, so a merged mass renames as one thing. Returns
-- the spoken confirmation, or nil for an empty commit (treated as
-- cancel). Caller guarantees the plot is revealed and clusterable --
-- openRename gates on both before pushing the input handler.
function MassNames.setName(plotIndex, rawText)
    local text = sanitize(rawText)
    if text == "" then
        return nil
    end
    local rec = MassNames.resolve(plotIndex)
    if rec ~= nil then
        rec.name = text
    else
        local plot = Map.GetPlotByIndex(plotIndex)
        rec = { kind = poolKindOf(plot), anchor = plotIndex, seq = _nextSeq, name = text }
        _nextSeq = _nextSeq + 1
        _names[#_names + 1] = rec
        attachRec(rec)
    end
    persist()
    return Text.format("TXT_KEY_CIVVACCESS_MASS_NAMED", text)
end

-- ===== Ctrl+N text entry =====
-- EditCapture over the dedicated off-screen WorldView EditBox
-- (CivVAccessMassNameEntry), so typed names follow the player's keyboard
-- layout. The screen reader provides typing echo; Enter commits, Escape
-- cancels, and an empty commit cancels like Escape (setName returns nil
-- on blank text, so nothing is spoken or saved).

-- Ctrl+N entry point. Speaks the reason when the cursor tile has no
-- nameable mass (unexplored, or a lake); otherwise pushes the input
-- handler and returns the prompt naming what is being (re)named.
function MassNames.openRename()
    local cx, cy = Cursor.position()
    if cx == nil then
        Log.warn("MassNames.openRename: cursor not initialised")
        return ""
    end
    local plot = Map.GetPlot(cx, cy)
    if not plot:IsRevealed(Game.GetActiveTeam(), Game.IsDebugMode()) then
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
    end
    local kind = poolKindOf(plot)
    if kind == nil then
        return Text.key("TXT_KEY_CIVVACCESS_MASS_NONE")
    end
    local idx = plot:GetPlotIndex()
    local rec = MassNames.resolve(idx)
    EditCapture.open({
        name = "MassNameInput",
        control = Controls.CivVAccessMassNameEntry,
        onCommit = function(text)
            return MassNames.setName(idx, text)
        end,
    })
    if rec ~= nil then
        return Text.format("TXT_KEY_CIVVACCESS_MASS_RENAME_PROMPT", rec.name)
    end
    if kind == "landmass" then
        return Text.key("TXT_KEY_CIVVACCESS_MASS_NAME_PROMPT_LAND")
    end
    return Text.key("TXT_KEY_CIVVACCESS_MASS_NAME_PROMPT_OCEAN")
end

-- ===== Listeners =====

-- First reveal of a plot for a team, fired synchronously from the fork's
-- CvPlot::setRevealed hook. Filtered to the active team -- the
-- membership map models what the player at the keyboard has revealed.
function MassNames._onPlotRevealed(eTeam, iX, iY)
    if eTeam ~= Game.GetActiveTeam() then
        return
    end
    local plot = Map.GetPlot(iX, iY)
    if plot == nil then
        return
    end
    local pool = poolKindOf(plot)
    if pool == nil then
        return
    end
    addRevealedPlot(plot, pool)
end

-- Hotseat seat change: both the revealed set (per team) and the name
-- scope (per player) belong to the new seat. Same guards as Bookmarks:
-- the engine fires iActive < 0 during teardown / non-player transitions.
function MassNames._onActivePlayerChanged(iActive, _iPrev)
    if iActive == nil or iActive < 0 then
        return
    end
    if not Game.IsHotSeat() then
        return
    end
    hydrate()
    rebuild()
end

-- Fresh listeners on every call -- see CivVAccess_Boot.lua's
-- LoadScreenClose registration for the load-from-game rationale.
function MassNames.installListeners()
    hydrate()
    rebuild()
    EngineEvents.on(
        "CivVAccessPlotRevealed",
        Log.safeListener("MassNames.onPlotRevealed", MassNames._onPlotRevealed),
        "MassNames",
        "mass membership updates degraded to self-heal rebuilds (engine fork not deployed?)"
    )
    if Game.IsHotSeat() then
        Log.installEvent(
            Events,
            "GameplaySetActivePlayer",
            Log.safeListener("MassNames.onActivePlayerChanged", MassNames._onActivePlayerChanged),
            "MassNames",
            "hotseat per-player mass names disabled"
        )
    end
end

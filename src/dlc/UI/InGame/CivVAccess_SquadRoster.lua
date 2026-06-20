-- Owner-local roster of squads: which squad numbers exist, their names,
-- the escort-civilians flag, and the intended end-of-move wake mode. The
-- engine holds the load-bearing squad state (membership, destination, the
-- per-unit end-mode) and syncs it across clients, but it cannot represent
-- an empty squad or a named one, so the roster is the source of truth for
-- "this squad exists / is called X / escorts civilians / wakes like Y."
-- Membership itself is never stored here; it is read live from the engine
-- every time (a blind player trusts speech absolutely, so a cached member
-- list that drifted from the engine would be a silent lie).
--
-- Persistence mirrors Bookmarks exactly: Modding.OpenUserData scoped by
-- map seed plus active player, the same per-(mod GUID, version) SQLite
-- store, under a ":squads" sub-key so it shares the scope with the
-- bookmark blobs without colliding. The store is outside the .Civ5Save and
-- outside the engine's m_syncArchive, so MP clients keep their own rosters
-- and asymmetric mod loading cannot desync; hotseat re-hydrates per active
-- player. See CivVAccess_Bookmarks.lua for the rationale on every line of
-- the OpenUserData wrapper, which this file follows.
--
-- Storage shape: civvaccess_shared.squadRoster[number] = { name, escort,
-- wakeMode }. `number` is the engine squad number (a positive integer;
-- AssignToSquad does no clamping). `name` is nil for the default "Squad N"
-- and a user string otherwise. `escort` is the escort-civilians flag read
-- at move time. `wakeMode` is the end-of-move behavior (0 sentry on
-- arrival, 1 wake on arrival, 2 wake when all arrive), engine default 0.
-- Serialized "number,escort,wakeMode,encodedName;..." per (seed, player)
-- key; the name is percent-encoded so an arbitrary user name carrying a
-- comma or semicolon cannot break the row / field split.
--
-- No renumbering: deleting a squad drops its entry and leaves a gap in the
-- number sequence. Navigation is by the named, sorted list, so gaps are
-- invisible to the player and renumbering would silently move a squad the
-- player had memorized as "Squad 3" to a different number.

SquadRoster = {}

local WAKE_SENTRY = 0
local WAKE_EACH = 1
local WAKE_ALL = 2

-- Exposed so the menu's wake-mode cycler and the engine push share one
-- vocabulary for the three modes and their bounds.
SquadRoster.WAKE_SENTRY = WAKE_SENTRY
SquadRoster.WAKE_EACH = WAKE_EACH
SquadRoster.WAKE_ALL = WAKE_ALL

-- Same store identity as Bookmarks: one ModUserData/<guid>-1.db file holds
-- both the bookmark blobs and the squad roster, keyed apart by sub-key. The
-- GUID matches src/dlc/CivVAccess_2.Civ5Pkg; version stays 1 unless a
-- deliberate migration is needed (bumping it orphans the prior file).
local STORE_ID = "40a9df7b-ae9f-48db-abb5-44afe0420524"
local STORE_VERSION = 1

-- "<seed>:<player>:squads". GetMapRandSeed is fixed at map gen and round-
-- trips a load; GetActivePlayer is the local seat (and rotates in hotseat),
-- so the roster is scoped to this game and this player at the keyboard.
local function storageKey()
    return tostring(Network.GetMapRandSeed()) .. ":" .. tostring(Game.GetActivePlayer()) .. ":squads"
end

-- Percent-encode the row/field delimiters (and the escape char itself) so a
-- user name with a comma or semicolon survives the round trip. Newline is
-- encoded too in case an EditBox ever yields one.
local function encodeName(s)
    return (s:gsub("[%%,;\n]", function(c)
        return string.format("%%%02X", string.byte(c))
    end))
end

local function decodeName(s)
    return (s:gsub("%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end))
end

local function serialize(roster)
    -- Emit in ascending number order so the blob is stable across saves
    -- (deterministic diffs, and a human reading the .db sees them in order).
    local nums = {}
    for num in pairs(roster) do
        nums[#nums + 1] = num
    end
    table.sort(nums)
    local parts = {}
    for _, num in ipairs(nums) do
        local e = roster[num]
        local escort = e.escort and 1 or 0
        parts[#parts + 1] = tostring(num)
            .. ","
            .. tostring(escort)
            .. ","
            .. tostring(e.wakeMode)
            .. ","
            .. encodeName(e.name or "")
    end
    return table.concat(parts, ";")
end

-- tonumber on a malformed field returns nil. A row with a nil number / flag
-- would look populated to the menu and crash downstream (the engine seam
-- indexes by number, the wake push passes wakeMode straight to the DLL);
-- skip and warn instead so a corrupt store row can't masquerade as a squad.
local function deserialize(s)
    local result = {}
    if s == nil or s == "" then
        return result
    end
    for entry in string.gmatch(s, "[^;]+") do
        local num, escort, wake, name = string.match(entry, "([^,]+),([^,]+),([^,]+),(.*)")
        if num == nil then
            -- The row didn't even split into four fields (an empty field, e.g.
            -- "1,,0,Name" from a truncated write, fails the one-or-more capture).
            -- Warn rather than drop it silently -- a lost squad must leave a
            -- Lua.log trace.
            Log.warn("SquadRoster: skipped unparseable entry: " .. tostring(entry))
        else
            local nNum, nEscort, nWake = tonumber(num), tonumber(escort), tonumber(wake)
            if nNum ~= nil and nEscort ~= nil and nWake ~= nil then
                local decoded = decodeName(name or "")
                result[nNum] = {
                    name = decoded ~= "" and decoded or nil,
                    escort = nEscort ~= 0,
                    wakeMode = nWake,
                }
            else
                Log.warn("SquadRoster: skipped malformed entry: " .. tostring(entry))
            end
        end
    end
    return result
end

-- Wraps OpenUserData in the same pcall + nil-handle pattern Bookmarks /
-- UserPrefs use. Returns nil on any failure, logged so a roster that fails
-- to persist or hydrate traces back to a SquadRoster Lua.log line rather
-- than getting swallowed.
local function openStore()
    if Modding == nil or Modding.OpenUserData == nil then
        Log.warn("SquadRoster: Modding.OpenUserData unavailable; persistence disabled this session")
        return nil
    end
    local ok, h = pcall(Modding.OpenUserData, STORE_ID, STORE_VERSION)
    if not ok then
        Log.error("SquadRoster: OpenUserData threw: " .. tostring(h))
        return nil
    end
    if h == nil then
        Log.warn("SquadRoster: OpenUserData returned nil")
        return nil
    end
    return h
end

local function persist()
    local store = openStore()
    if store == nil then
        return
    end
    local ok, err = pcall(function()
        store.SetValue(storageKey(), serialize(civvaccess_shared.squadRoster))
    end)
    if not ok then
        Log.error("SquadRoster: SetValue threw: " .. tostring(err))
    end
end

function SquadRoster.hydrateForCurrentGame()
    -- Always assign a fresh empty table first so a failed store open or a
    -- thrown GetValue still leaves the roster as a valid (empty) table the
    -- menu / focus code can index without nil guarding.
    civvaccess_shared.squadRoster = {}
    local store = openStore()
    if store == nil then
        return
    end
    local ok, raw = pcall(function()
        return store.GetValue(storageKey())
    end)
    if not ok then
        Log.error("SquadRoster: GetValue threw: " .. tostring(raw))
        return
    end
    civvaccess_shared.squadRoster = deserialize(raw)
end

local function roster()
    return civvaccess_shared.squadRoster
end

-- Lowest free positive squad number. Gaps left by deletes are reused (a
-- gap is just a free number), but an existing number is never reassigned.
function SquadRoster.allocate()
    local r = roster()
    local num = 1
    while r[num] ~= nil do
        num = num + 1
    end
    r[num] = { name = nil, escort = false, wakeMode = WAKE_SENTRY }
    persist()
    return num
end

-- Make sure a roster entry exists for a squad number the engine already
-- knows about (a save whose membership survived but whose OpenUserData
-- store was lost, or any squad created outside allocate). Defaults match a
-- fresh allocation. Returns true when it created an entry so the caller can
-- decide whether to persist (reconcile batches the persist).
function SquadRoster.ensure(num)
    local r = roster()
    if r[num] ~= nil then
        return false
    end
    r[num] = { name = nil, escort = false, wakeMode = WAKE_SENTRY }
    return true
end

-- Reconcile the roster against the live engine squad numbers (passed in by
-- Boot, which reads them off the active player's units). Ensures an entry
-- for every number the engine has, then persists once if anything changed.
-- Kept pure (numbers supplied by the caller) so the roster stays offline-
-- testable; Boot owns the engine iteration.
function SquadRoster.reconcile(numbers)
    local changed = false
    for _, num in ipairs(numbers) do
        if SquadRoster.ensure(num) then
            changed = true
        end
    end
    if changed then
        persist()
    end
end

function SquadRoster.exists(num)
    return roster()[num] ~= nil
end

-- Ascending list of existing squad numbers. The menu and the Up/Down focus
-- cycler both navigate this, so gaps from deletes stay invisible.
function SquadRoster.getList()
    local nums = {}
    for num in pairs(roster()) do
        nums[#nums + 1] = num
    end
    table.sort(nums)
    return nums
end

-- Display name: the user's custom name, or the default "Squad N". Always
-- resolves to a spoken string so the menu / focus readouts never go blank.
function SquadRoster.getName(num)
    local e = roster()[num]
    if e ~= nil and e.name ~= nil then
        return e.name
    end
    return Text.format("TXT_KEY_CIVVACCESS_SQUAD_DEFAULT_NAME", num)
end

-- Trim, then a blank result resets to the default name rather than storing
-- an empty string (which would read as a nameless squad). Unknown number is
-- a no-op with a warning -- a rename for a deleted squad shouldn't resurrect
-- it.
function SquadRoster.rename(num, name)
    local e = roster()[num]
    if e == nil then
        Log.warn("SquadRoster.rename: unknown squad " .. tostring(num))
        return
    end
    local trimmed = (name or ""):match("^%s*(.-)%s*$")
    e.name = trimmed ~= "" and trimmed or nil
    persist()
end

function SquadRoster.getEscort(num)
    local e = roster()[num]
    return e ~= nil and e.escort or false
end

function SquadRoster.setEscort(num, value)
    local e = roster()[num]
    if e == nil then
        Log.warn("SquadRoster.setEscort: unknown squad " .. tostring(num))
        return
    end
    e.escort = value and true or false
    persist()
end

function SquadRoster.getWakeMode(num)
    local e = roster()[num]
    return e ~= nil and e.wakeMode or WAKE_SENTRY
end

function SquadRoster.setWakeMode(num, mode)
    local e = roster()[num]
    if e == nil then
        Log.warn("SquadRoster.setWakeMode: unknown squad " .. tostring(num))
        return
    end
    e.wakeMode = mode
    persist()
end

-- Drop a squad from the roster. Clearing the engine-side membership is the
-- caller's job (the roster never touches live game state); this only forgets
-- the name / escort / wake-mode and the squad's existence. No renumbering.
function SquadRoster.delete(num)
    local r = roster()
    if r[num] == nil then
        Log.warn("SquadRoster.delete: unknown squad " .. tostring(num))
        return
    end
    r[num] = nil
    persist()
end

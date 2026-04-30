-- TechTreeLogic tests. Exercises graph construction from a stubbed
-- Technology_PrereqTechs table, status-token determination across the
-- five game states, queue-row composition, preamble mode switches,
-- commit eligibility rejections per mode, and the initial-cursor
-- fallback chain.

local T = require("support")
local M = {}

-- Minimal tech records. Type is the key GameInfo.Technologies[Type] and
-- Technology_PrereqTechs references resolve against. GridY / ID drive
-- sort order in the graph adjacency and initial-cursor fallback.
local function tech(id, typeName, gridY, description)
    return { ID = id, Type = typeName, Description = description or typeName, GridY = gridY }
end

local function installTechDB(techs, prereqs)
    GameInfo = GameInfo or {}
    -- GameInfo.Technologies must be both a callable iterator AND an indexable
    -- map by ID or Type string. Matches the shape base-game code relies on
    -- (e.g. TechTree.lua's InitialSetup iterates, TechSelected indexes by ID).
    local techMap = {}
    for _, t in ipairs(techs) do
        techMap[t.ID] = t
        techMap[t.Type] = t
    end
    setmetatable(techMap, {
        __call = function()
            local i = 0
            return function()
                i = i + 1
                return techs[i]
            end
        end,
    })
    GameInfo.Technologies = techMap

    -- Technology_PrereqTechs is a callable iterator only.
    GameInfo.Technology_PrereqTechs = function()
        local i = 0
        return function()
            i = i + 1
            return prereqs[i]
        end
    end

    GameInfo.Civilizations = GameInfo.Civilizations or { [0] = { ShortDescription = "TXT_KEY_CIV_ROME_SHORT" } }
end

local function fakePlayer(opts)
    opts = opts or {}
    local p = {
        _team = opts.team or 0,
        _current = opts.current == nil and -1 or opts.current,
        _science = opts.science or 0,
        _numFree = opts.numFreeTechs or 0,
        _civType = opts.civType or 0,
        _queue = opts.queue or {}, -- techID -> position
        _canResearch = opts.canResearch or {},
        _canEverResearch = opts.canEverResearch or {},
        _canResearchForFree = opts.canResearchForFree or {},
        _turnsLeft = opts.turnsLeft or {},
        _name = opts.name or "Player",
    }
    function p:GetTeam()
        return self._team
    end
    function p:GetCurrentResearch()
        return self._current
    end
    function p:GetScience()
        return self._science
    end
    function p:GetNumFreeTechs()
        return self._numFree
    end
    function p:GetCivilizationType()
        return self._civType
    end
    function p:GetName()
        return self._name
    end
    function p:GetQueuePosition(id)
        return self._queue[id] or -1
    end
    function p:CanResearch(id)
        return self._canResearch[id] or false
    end
    function p:CanEverResearch(id)
        if self._canEverResearch[id] ~= nil then
            return self._canEverResearch[id]
        end
        return true
    end
    function p:CanResearchForFree(id)
        return self._canResearchForFree[id] or false
    end
    function p:GetResearchTurnsLeft(id, _includeThisTurn)
        return self._turnsLeft[id] or 0
    end
    return p
end

local function fakeTeam(opts)
    opts = opts or {}
    local t = {
        _researched = opts.researched or {},
    }
    function t:GetTeamTechs()
        return self
    end
    function t:HasTech(id)
        return self._researched[id] or false
    end
    function t:IsHasTech(id)
        return self._researched[id] or false
    end
    return t
end

local function setup()
    Log = Log
        or {
            debug = function() end,
            info = function() end,
            warn = function() end,
            error = function() end,
        }
    Locale = Locale or {}
    Locale.ConvertTextKey = function(k, ...)
        local args = { ... }
        if #args == 0 then
            return k
        end
        return (
            k:gsub("{(%d+)_[^}]*}", function(n)
                local v = args[tonumber(n)]
                return v == nil and "" or tostring(v)
            end)
        )
    end
    Game = Game or {}
    Game.IsTechRecommended = function()
        return false
    end
    Game.SetAdvisorRecommenderTech = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "researched"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "available"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "prerequisites not met"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "locked"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "current"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "currently researching"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "queued slot {1_Slot}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = "{1_Num} turns"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "free tech, {1_N} remaining"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "stealing from {1_Civ}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "{1_N} science per turn"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "already researched"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "not available for free tech"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "cannot steal this"

    GetHelpTextForTech = function()
        return ""
    end

    dofile("src/dlc/UI/InGame/Popups/CivVAccess_ChooseTechLogic.lua")
    dofile("src/dlc/UI/TechTree/CivVAccess_TechTreeLogic.lua")
end

local function techs3()
    -- Agriculture (root) -> Pottery -> Mining (leaf). GridY ascending by ID
    -- so sort order is the same as declaration order.
    return {
        tech(0, "TECH_AGRICULTURE", 1, "TXT_KEY_TECH_AGRICULTURE"),
        tech(1, "TECH_POTTERY", 2, "TXT_KEY_TECH_POTTERY"),
        tech(2, "TECH_MINING", 3, "TXT_KEY_TECH_MINING"),
    }, {
        { TechType = "TECH_POTTERY", PrereqTech = "TECH_AGRICULTURE" },
        { TechType = "TECH_MINING", PrereqTech = "TECH_POTTERY" },
    }
end

-- ===== buildGraph =====

function M.test_buildGraph_roots_exclude_techs_with_prereqs()
    setup()
    installTechDB(techs3())
    local g = TechTreeLogic.buildGraph()
    local roots = g.getRoots()
    T.eq(#roots, 1)
    T.eq(roots[1].Type, "TECH_AGRICULTURE")
end

function M.test_buildGraph_children_and_parents_resolve()
    setup()
    installTechDB(techs3())
    local g = TechTreeLogic.buildGraph()
    local pottery = GameInfo.Technologies["TECH_POTTERY"]
    T.eq(g.getParents(pottery)[1].Type, "TECH_AGRICULTURE")
    T.eq(g.getChildren(pottery)[1].Type, "TECH_MINING")
end

function M.test_buildGraph_sorts_children_by_gridY_then_ID()
    setup()
    local techs = {
        tech(0, "TECH_BASE", 0),
        tech(1, "TECH_CHILD_A", 3),
        tech(2, "TECH_CHILD_B", 1),
        tech(3, "TECH_CHILD_C", 2),
    }
    local prereqs = {
        { TechType = "TECH_CHILD_A", PrereqTech = "TECH_BASE" },
        { TechType = "TECH_CHILD_B", PrereqTech = "TECH_BASE" },
        { TechType = "TECH_CHILD_C", PrereqTech = "TECH_BASE" },
    }
    installTechDB(techs, prereqs)
    local g = TechTreeLogic.buildGraph()
    local base = GameInfo.Technologies["TECH_BASE"]
    local children = g.getChildren(base)
    T.eq(children[1].Type, "TECH_CHILD_B", "GridY=1 first")
    T.eq(children[2].Type, "TECH_CHILD_C", "GridY=2 second")
    T.eq(children[3].Type, "TECH_CHILD_A", "GridY=3 last")
end

-- ===== statusKey =====

function M.test_statusKey_researched_wins()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({ current = 1 }),
    }
    Teams = { [0] = fakeTeam({ researched = { [1] = true } }) }
    T.eq(TechTreeLogic.statusKey(Players[0], 1), "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED")
end

function M.test_statusKey_current_precedes_available()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({ current = 1, canResearch = { [1] = true } }),
    }
    Teams = { [0] = fakeTeam() }
    T.eq(TechTreeLogic.statusKey(Players[0], 1), "TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT")
end

function M.test_statusKey_available_when_canResearch()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer({ canResearch = { [1] = true } }) }
    Teams = { [0] = fakeTeam() }
    T.eq(TechTreeLogic.statusKey(Players[0], 1), "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE")
end

function M.test_statusKey_unavailable_when_only_canEver()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer({ canResearch = {}, canEverResearch = { [1] = true } }) }
    Teams = { [0] = fakeTeam() }
    T.eq(TechTreeLogic.statusKey(Players[0], 1), "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE")
end

function M.test_statusKey_locked_when_not_canEver()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({ canResearch = {}, canEverResearch = { [1] = false } }),
    }
    Teams = { [0] = fakeTeam() }
    T.eq(TechTreeLogic.statusKey(Players[0], 1), "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED")
end

-- ===== buildLandingSpeech =====

function M.test_landing_current_shows_turns_without_queue_slot()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({
            current = 1,
            science = 3,
            queue = { [1] = 1 },
            turnsLeft = { [1] = 4 },
        }),
    }
    Teams = { [0] = fakeTeam() }
    local text = TechTreeLogic.buildLandingSpeech(1, Players[0])
    -- Name, status, turns — no "queued slot" clause for the current research.
    T.truthy(text:find("TXT_KEY_TECH_POTTERY"), "leads with tech name key")
    T.truthy(text:find("currently researching"))
    T.truthy(text:find("4 turns"))
    T.falsy(text:find("queued slot"), "current tech does not add queued slot")
end

function M.test_landing_queued_shows_slot_number()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({
            current = 0,
            canResearch = { [0] = true, [1] = true },
            science = 3,
            queue = { [0] = 1, [1] = 2, [2] = 3 },
            turnsLeft = { [1] = 4 },
        }),
    }
    Teams = { [0] = fakeTeam() }
    local text = TechTreeLogic.buildLandingSpeech(1, Players[0])
    T.truthy(text:find("queued slot 1"), "position 2 displays as slot 1")
end

function M.test_landing_researched_suppresses_turns()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer({ science = 3, turnsLeft = { [1] = 4 } }) }
    Teams = { [0] = fakeTeam({ researched = { [1] = true } }) }
    local text = TechTreeLogic.buildLandingSpeech(1, Players[0])
    T.truthy(text:find("researched"))
    T.falsy(text:find("4 turns"), "researched techs never narrate turns")
end

function M.test_landing_zero_science_suppresses_turns()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({ canResearch = { [1] = true }, science = 0, turnsLeft = { [1] = 4 } }),
    }
    Teams = { [0] = fakeTeam() }
    local text = TechTreeLogic.buildLandingSpeech(1, Players[0])
    T.falsy(text:find("4 turns"), "zero science suppresses turns clause")
end

-- ===== buildQueueRows =====

function M.test_queue_rows_sorted_by_position()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({
            queue = { [0] = 2, [1] = 1, [2] = 3 },
        }),
    }
    Teams = { [0] = fakeTeam() }
    local rows = TechTreeLogic.buildQueueRows(Players[0])
    T.eq(#rows, 3)
    T.eq(rows[1].techID, 1, "position 1 row is the currently-researching tech")
    T.eq(rows[2].techID, 0)
    T.eq(rows[3].techID, 2)
end

function M.test_queue_rows_empty_when_nothing_queued()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer() }
    Teams = { [0] = fakeTeam() }
    T.eq(#TechTreeLogic.buildQueueRows(Players[0]), 0)
end

function M.test_queue_row_speech_current_vs_queued()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer({ science = 3, turnsLeft = { [1] = 4, [2] = 8 } }) }
    Teams = { [0] = fakeTeam() }
    local currentRow = { techID = 1, info = GameInfo.Technologies[1], position = 1 }
    local queuedRow = { techID = 2, info = GameInfo.Technologies[2], position = 2 }
    local currentText = TechTreeLogic.buildQueueRowSpeech(currentRow, Players[0])
    local queuedText = TechTreeLogic.buildQueueRowSpeech(queuedRow, Players[0])
    T.truthy(currentText:find(", current,"), "position 1 uses the 'current' token")
    T.truthy(queuedText:find("queued slot 1"), "position 2 renders as slot 1")
    T.truthy(currentText:find("4 turns"))
    T.truthy(queuedText:find("8 turns"))
end

-- Preamble coverage lives in tests/choose_tech_test.lua since the
-- function moved to ChooseTechLogic once TechTree joined the popup in
-- needing it; same API, one source of truth.

-- ===== currentMode =====

function M.test_currentMode_stealing_beats_free()
    setup()
    installTechDB(techs3())
    local p = fakePlayer({ numFreeTechs = 1 })
    T.eq(TechTreeLogic.currentMode(p, 2), "stealing")
end

function M.test_currentMode_free_beats_normal()
    setup()
    installTechDB(techs3())
    local p = fakePlayer({ numFreeTechs = 1 })
    T.eq(TechTreeLogic.currentMode(p, -1), "free")
end

function M.test_currentMode_normal_by_default()
    setup()
    installTechDB(techs3())
    local p = fakePlayer({})
    T.eq(TechTreeLogic.currentMode(p, -1), "normal")
end

-- ===== commitEligibility =====

function M.test_commit_rejects_researched_tech()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer() }
    Teams = { [0] = fakeTeam({ researched = { [1] = true } }) }
    local ok, key = TechTreeLogic.commitEligibility(Players[0], 1, "normal", -1)
    T.falsy(ok)
    T.eq(key, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED")
end

function M.test_commit_rejects_locked_tech()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({ canEverResearch = { [1] = false } }),
    }
    Teams = { [0] = fakeTeam() }
    local ok, key = TechTreeLogic.commitEligibility(Players[0], 1, "normal", -1)
    T.falsy(ok)
    T.eq(key, "TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED")
end

function M.test_commit_allows_prereq_gap_in_normal_mode()
    -- SendResearch auto-queues unmet prereqs ahead of the requested
    -- tech, so the commit gate must not block on CanResearch in normal
    -- mode — only HasTech and !CanEverResearch are hard rejects.
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({ canResearch = {}, canEverResearch = { [1] = true } }),
    }
    Teams = { [0] = fakeTeam() }
    local ok, key = TechTreeLogic.commitEligibility(Players[0], 1, "normal", -1)
    T.truthy(ok, "normal mode allows queueing techs with unmet prereqs")
    T.eq(key, nil)
end

function M.test_commit_accepts_available_tech_in_normal()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer({ canResearch = { [1] = true } }) }
    Teams = { [0] = fakeTeam() }
    local ok, key = TechTreeLogic.commitEligibility(Players[0], 1, "normal", -1)
    T.truthy(ok)
    T.eq(key, nil)
end

function M.test_commit_free_requires_canResearchForFree()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({
            canResearch = { [1] = true },
            canResearchForFree = { [1] = false },
        }),
    }
    Teams = { [0] = fakeTeam() }
    local ok, key = TechTreeLogic.commitEligibility(Players[0], 1, "free", -1)
    T.falsy(ok)
    T.eq(key, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE")
end

function M.test_commit_stealing_requires_opponent_has_tech()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({ canResearch = { [1] = true } }),
        [2] = fakePlayer({ team = 2 }),
    }
    Teams = { [0] = fakeTeam(), [2] = fakeTeam() }
    local ok, key = TechTreeLogic.commitEligibility(Players[0], 1, "stealing", 2)
    T.falsy(ok)
    T.eq(key, "TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE")
end

function M.test_commit_stealing_accepts_when_opponent_has_tech()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({ canResearch = { [1] = true } }),
        [2] = fakePlayer({ team = 2 }),
    }
    Teams = { [0] = fakeTeam(), [2] = fakeTeam({ researched = { [1] = true } }) }
    local ok = TechTreeLogic.commitEligibility(Players[0], 1, "stealing", 2)
    T.truthy(ok)
end

-- ===== pickInitialCursor =====

function M.test_initialCursor_prefers_current_research()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer({ current = 2 }) }
    Teams = { [0] = fakeTeam() }
    local graph = TechTreeLogic.buildGraph()
    local pick = TechTreeLogic.pickInitialCursor(Players[0], graph)
    T.eq(pick.Type, "TECH_MINING")
end

function M.test_initialCursor_falls_back_to_first_canResearch()
    setup()
    installTechDB(techs3())
    Players = {
        [0] = fakePlayer({
            canResearch = { [1] = true, [2] = true },
        }),
    }
    Teams = { [0] = fakeTeam() }
    local graph = TechTreeLogic.buildGraph()
    local pick = TechTreeLogic.pickInitialCursor(Players[0], graph)
    -- Lowest GridY among canResearch is TECH_POTTERY (GridY=2).
    T.eq(pick.Type, "TECH_POTTERY")
end

function M.test_initialCursor_falls_back_to_first_root_when_nothing_canResearch()
    setup()
    installTechDB(techs3())
    Players = { [0] = fakePlayer({ canResearch = {} }) }
    Teams = { [0] = fakeTeam() }
    local graph = TechTreeLogic.buildGraph()
    local pick = TechTreeLogic.pickInitialCursor(Players[0], graph)
    T.eq(pick.Type, "TECH_AGRICULTURE", "lands on the only root")
end

-- ===== buildSearchCorpus =====

function M.test_searchCorpus_one_entry_per_tech()
    setup()
    installTechDB(techs3())
    local corpus = TechTreeLogic.buildSearchCorpus()
    T.eq(#corpus, 3)
    T.eq(corpus[1].tech.Type, "TECH_AGRICULTURE")
    T.eq(corpus[2].tech.Type, "TECH_POTTERY")
    T.eq(corpus[3].tech.Type, "TECH_MINING")
end

function M.test_searchCorpus_label_is_name_only_when_prose_empty()
    -- Default setup stub returns "" from GetHelpTextForTech; with no prose,
    -- the label collapses to just the tech name so TypeAheadSearch never
    -- appends a stray comma or empty segment.
    setup()
    installTechDB(techs3())
    local corpus = TechTreeLogic.buildSearchCorpus()
    T.eq(corpus[2].label, "TXT_KEY_TECH_POTTERY")
end

function M.test_searchCorpus_label_joins_name_and_unlocks_prose()
    -- Non-empty prose is appended after ", " so TypeAheadSearch's
    -- pre-comma/post-comma axis ranks name matches above prose matches
    -- (typing "knight" finds Chivalry via "Unlocks Knight" prose but ranks
    -- it below a hypothetical tech literally named Knight).
    setup()
    local techs = {
        tech(0, "TECH_CHIVALRY", 1, "chivalry"),
    }
    installTechDB(techs, {})
    GetHelpTextForTech = function(id)
        if id == 0 then
            return "CHIVALRY[NEWLINE]Unlocks Knight"
        end
        return ""
    end
    local corpus = TechTreeLogic.buildSearchCorpus()
    T.eq(corpus[1].label, "chivalry, Unlocks Knight")
end

-- ===== seedCursorSiblings =====

local function loadNavigableGraph()
    NavigableGraph = nil
    dofile("src/dlc/UI/Shared/CivVAccess_NavigableGraph.lua")
end

function M.test_seedCursorSiblings_uses_roots_when_landing_is_a_root()
    setup()
    loadNavigableGraph()
    installTechDB(techs3())
    local graph = TechTreeLogic.buildGraph()
    local cursor = NavigableGraph.new({
        getParents = graph.getParents,
        getChildren = graph.getChildren,
        getRoots = graph.getRoots,
    })
    local agriculture = GameInfo.Technologies["TECH_AGRICULTURE"]
    TechTreeLogic.seedCursorSiblings(cursor, agriculture, graph)
    T.eq(cursor.current().Type, "TECH_AGRICULTURE")
    -- Roots list has exactly Agriculture, so hasSiblings is false but
    -- the seeded list is the root set -- confirmed by cycleSibling being a
    -- wrap no-op returning nil rather than cycling into a parent list.
    local n = cursor.cycleSibling(1)
    T.eq(n, nil, "single-root case yields no cycle target")
end

-- ===== buildGrid / gridNeighbor =====

-- Tech with GridX, GridY, and Era populated. Era stays nil unless passed.
local function gridTech(id, typeName, gridX, gridY, era)
    return {
        ID = id,
        Type = typeName,
        Description = typeName,
        GridX = gridX,
        GridY = gridY,
        Era = era,
    }
end

local function installGridTechs(techs)
    installTechDB(techs, {})
end

function M.test_buildGrid_byColumn_sorted_by_gridY()
    setup()
    installGridTechs({
        gridTech(0, "T_BOT", 3, 7),
        gridTech(1, "T_TOP", 3, 1),
        gridTech(2, "T_MID", 3, 4),
    })
    local grid = TechTreeLogic.buildGrid()
    local col3 = grid.byColumn[3]
    T.eq(#col3, 3)
    T.eq(col3[1].Type, "T_TOP", "lowest GridY first")
    T.eq(col3[3].Type, "T_BOT")
end

function M.test_gridNeighbor_row_right_steps_exactly_one_column()
    -- Right moves to GridX+1, never skipping ahead to a more-distant column
    -- even when the adjacent column has no tech at the cursor's row.
    setup()
    installGridTechs({
        gridTech(0, "T_A", 1, 1),
        gridTech(1, "T_NEXT", 2, 4),
        gridTech(2, "T_FAR", 3, 1),
    })
    local grid = TechTreeLogic.buildGrid()
    local a = GameInfo.Technologies["T_A"]
    local n = TechTreeLogic.gridNeighbor(grid, a, "row", 1)
    T.eq(n.Type, "T_NEXT", "lands in adjacent column despite row mismatch instead of jumping to T_FAR")
end

function M.test_gridNeighbor_row_left_steps_exactly_one_column()
    setup()
    installGridTechs({
        gridTech(0, "T_FAR", 1, 1),
        gridTech(1, "T_PREV", 4, 6),
        gridTech(2, "T_B", 5, 1),
    })
    local grid = TechTreeLogic.buildGrid()
    local b = GameInfo.Technologies["T_B"]
    local n = TechTreeLogic.gridNeighbor(grid, b, "row", -1)
    T.eq(n.Type, "T_PREV", "left lands one column over, not at the next populated row 1 cell")
end

function M.test_gridNeighbor_row_snaps_to_nearest_gridY()
    -- Adjacent column has multiple techs; cursor lands on whichever sits
    -- closest to intendedGridY in absolute distance.
    setup()
    installGridTechs({
        gridTech(0, "T_CUR", 1, 5),
        gridTech(1, "T_NEAR", 2, 4),
        gridTech(2, "T_FAR", 2, 9),
    })
    local grid = TechTreeLogic.buildGrid()
    local cur = GameInfo.Technologies["T_CUR"]
    local n = TechTreeLogic.gridNeighbor(grid, cur, "row", 1, 5)
    T.eq(n.Type, "T_NEAR", "GridY=4 is closer to intended 5 than GridY=9")
end

function M.test_gridNeighbor_row_intended_gridY_overrides_current_row()
    -- The cursor's GridY may have drifted from a prior snap; the next move
    -- snaps relative to intendedGridY (the row the user actually picked
    -- with their last vertical move), not the cursor's current GridY.
    setup()
    installGridTechs({
        gridTech(0, "T_DRIFTED", 1, 2),
        gridTech(1, "T_AT_INTENDED", 2, 5),
        gridTech(2, "T_AT_DRIFT", 2, 1),
    })
    local grid = TechTreeLogic.buildGrid()
    local cur = GameInfo.Technologies["T_DRIFTED"]
    local n = TechTreeLogic.gridNeighbor(grid, cur, "row", 1, 5)
    T.eq(
        n.Type,
        "T_AT_INTENDED",
        "snap target is intendedGridY=5, not the cursor's GridY=2"
    )
end

function M.test_gridNeighbor_row_falls_back_to_cursor_gridY_when_intended_nil()
    -- intendedGridY nil at the very start of an open or a search landing
    -- before any vertical move — fall back to the cursor's GridY so the
    -- behavior is sensible without the caller having to pre-seed.
    setup()
    installGridTechs({
        gridTech(0, "T_CUR", 1, 3),
        gridTech(1, "T_HIGH", 2, 1),
        gridTech(2, "T_NEAR", 2, 4),
    })
    local grid = TechTreeLogic.buildGrid()
    local cur = GameInfo.Technologies["T_CUR"]
    local n = TechTreeLogic.gridNeighbor(grid, cur, "row", 1, nil)
    T.eq(n.Type, "T_NEAR", "snap target falls back to cursor.GridY=3, nearest is GridY=4")
end

function M.test_gridNeighbor_row_ties_prefer_smaller_gridY()
    -- Two equidistant snap candidates: smaller GridY (visually higher) wins.
    setup()
    installGridTechs({
        gridTech(0, "T_CUR", 1, 5),
        gridTech(1, "T_HIGH", 2, 3),
        gridTech(2, "T_LOW", 2, 7),
    })
    local grid = TechTreeLogic.buildGrid()
    local cur = GameInfo.Technologies["T_CUR"]
    local n = TechTreeLogic.gridNeighbor(grid, cur, "row", 1, 5)
    T.eq(n.Type, "T_HIGH", "tie at distance 2 prefers GridY=3 over GridY=7")
end

function M.test_gridNeighbor_row_silent_when_adjacent_column_empty()
    -- No tech at GridX+1 at all — return nil rather than skipping ahead.
    setup()
    installGridTechs({
        gridTech(0, "T_CUR", 1, 5),
        gridTech(1, "T_TWO_OVER", 3, 5),
    })
    local grid = TechTreeLogic.buildGrid()
    local cur = GameInfo.Technologies["T_CUR"]
    T.eq(TechTreeLogic.gridNeighbor(grid, cur, "row", 1, 5), nil)
end

function M.test_gridNeighbor_column_down_finds_next_tech_at_same_gridX()
    setup()
    installGridTechs({
        gridTech(0, "T_TOP", 3, 1),
        gridTech(1, "T_OTHER", 4, 2),
        gridTech(2, "T_BOT", 3, 5),
    })
    local grid = TechTreeLogic.buildGrid()
    local top = GameInfo.Technologies["T_TOP"]
    local n = TechTreeLogic.gridNeighbor(grid, top, "column", 1)
    T.eq(n.Type, "T_BOT", "skips intermediate GridY positions with no tech at GridX=3")
end

function M.test_gridNeighbor_column_up_finds_prior_tech()
    setup()
    installGridTechs({
        gridTech(0, "T_TOP", 3, 1),
        gridTech(1, "T_BOT", 3, 5),
    })
    local grid = TechTreeLogic.buildGrid()
    local bot = GameInfo.Technologies["T_BOT"]
    local n = TechTreeLogic.gridNeighbor(grid, bot, "column", -1)
    T.eq(n.Type, "T_TOP")
end

function M.test_gridNeighbor_returns_nil_at_row_edge()
    setup()
    installGridTechs({
        gridTech(0, "T_A", 1, 1),
        gridTech(1, "T_B", 3, 1),
    })
    local grid = TechTreeLogic.buildGrid()
    -- Right of the rightmost populated column has no GridX+1 to step into.
    local b = GameInfo.Technologies["T_B"]
    T.eq(TechTreeLogic.gridNeighbor(grid, b, "row", 1), nil)
    -- Left of the leftmost populated column likewise.
    local a = GameInfo.Technologies["T_A"]
    T.eq(TechTreeLogic.gridNeighbor(grid, a, "row", -1), nil)
end

function M.test_gridNeighbor_returns_nil_at_column_edge()
    setup()
    installGridTechs({
        gridTech(0, "T_TOP", 3, 1),
        gridTech(1, "T_BOT", 3, 4),
    })
    local grid = TechTreeLogic.buildGrid()
    local bot = GameInfo.Technologies["T_BOT"]
    T.eq(TechTreeLogic.gridNeighbor(grid, bot, "column", 1), nil)
    local top = GameInfo.Technologies["T_TOP"]
    T.eq(TechTreeLogic.gridNeighbor(grid, top, "column", -1), nil)
end

function M.test_gridNeighbor_returns_nil_when_column_unpopulated()
    setup()
    installGridTechs({
        gridTech(0, "T_LONE", 5, 5),
    })
    local grid = TechTreeLogic.buildGrid()
    -- A made-up tech at a column with nothing in it (and nothing in the
    -- adjacent column either) returns nil in every direction.
    local stranded = { ID = 99, Type = "T_GHOST", GridX = 9, GridY = 9 }
    T.eq(TechTreeLogic.gridNeighbor(grid, stranded, "row", 1), nil)
    T.eq(TechTreeLogic.gridNeighbor(grid, stranded, "column", 1), nil)
end

-- ===== eraID / eraName / eraPrefix =====

local function installEras()
    GameInfo.Eras = {
        ERA_ANCIENT = { ID = 0, Type = "ERA_ANCIENT", Description = "TXT_KEY_ERA_ANCIENT" },
        ERA_CLASSICAL = { ID = 1, Type = "ERA_CLASSICAL", Description = "TXT_KEY_ERA_CLASSICAL" },
    }
    -- Era display strings live under vanilla TXT_KEY_ERA_* keys, not the
    -- CIVVACCESS namespace, so Text.key falls through to Locale. Stub
    -- those mappings here.
    local prior = Locale.ConvertTextKey
    local map = {
        TXT_KEY_ERA_ANCIENT = "Ancient Era",
        TXT_KEY_ERA_CLASSICAL = "Classical Era",
    }
    Locale.ConvertTextKey = function(k, ...)
        if map[k] ~= nil and select("#", ...) == 0 then
            return map[k]
        end
        return prior(k, ...)
    end
end

function M.test_eraID_returns_techs_era_key()
    setup()
    installGridTechs({ gridTech(0, "T_X", 1, 1, "ERA_CLASSICAL") })
    installEras()
    T.eq(TechTreeLogic.eraID(0), "ERA_CLASSICAL")
end

function M.test_eraID_returns_nil_for_missing_tech()
    setup()
    installGridTechs({ gridTech(0, "T_X", 1, 1, "ERA_CLASSICAL") })
    T.eq(TechTreeLogic.eraID(999), nil)
end

function M.test_eraName_returns_localized_era_description()
    setup()
    installGridTechs({ gridTech(0, "T_X", 1, 1, "ERA_CLASSICAL") })
    installEras()
    T.eq(TechTreeLogic.eraName(0), "Classical Era")
end

function M.test_eraPrefix_announces_when_era_changes()
    setup()
    installGridTechs({ gridTech(0, "T_X", 1, 1, "ERA_CLASSICAL") })
    installEras()
    local prefix, newEra = TechTreeLogic.eraPrefix("ERA_ANCIENT", 0)
    T.eq(prefix, "Classical Era. ", "prefix uses period+space so era boundary is its own clause")
    T.eq(newEra, "ERA_CLASSICAL")
end

function M.test_eraPrefix_silent_when_era_unchanged()
    setup()
    installGridTechs({ gridTech(0, "T_X", 1, 1, "ERA_CLASSICAL") })
    installEras()
    local prefix, newEra = TechTreeLogic.eraPrefix("ERA_CLASSICAL", 0)
    T.eq(prefix, "")
    T.eq(newEra, "ERA_CLASSICAL")
end

function M.test_eraPrefix_announces_on_first_landing_with_nil_prev()
    setup()
    installGridTechs({ gridTech(0, "T_X", 1, 1, "ERA_ANCIENT") })
    installEras()
    local prefix, newEra = TechTreeLogic.eraPrefix(nil, 0)
    T.eq(prefix, "Ancient Era. ", "nil prev counts as a boundary so first landing announces era")
    T.eq(newEra, "ERA_ANCIENT")
end

function M.test_eraPrefix_silent_when_tech_has_no_era()
    setup()
    installGridTechs({ gridTech(0, "T_X", 1, 1, nil) })
    installEras()
    local prefix, newEra = TechTreeLogic.eraPrefix("ERA_ANCIENT", 0)
    T.eq(prefix, "")
    T.eq(newEra, "ERA_ANCIENT", "prev era preserved when the new tech has none to compare")
end

function M.test_eraPrefix_advances_prev_when_era_known_but_name_missing()
    -- Era exists in GameInfo.Eras but its Description key is unmapped.
    -- The prefix is empty (nothing to speak), but prev advances to the
    -- new era so a subsequent move into a third era doesn't compare
    -- against the one before this gap and announce a stale boundary.
    setup()
    installGridTechs({ gridTech(0, "T_X", 1, 1, "ERA_INDUSTRIAL") })
    installEras()
    GameInfo.Eras.ERA_INDUSTRIAL = { ID = 5, Type = "ERA_INDUSTRIAL", Description = nil }
    local prefix, newEra = TechTreeLogic.eraPrefix("ERA_ANCIENT", 0)
    T.eq(prefix, "")
    T.eq(newEra, "ERA_INDUSTRIAL", "prev advances to the new era despite missing display name")
end

function M.test_seedCursorSiblings_uses_first_parents_children_for_non_root()
    setup()
    loadNavigableGraph()
    local techs = {
        tech(0, "TECH_BASE", 0, "base"),
        tech(1, "TECH_CHILD_A", 1, "child a"),
        tech(2, "TECH_CHILD_B", 2, "child b"),
    }
    local prereqs = {
        { TechType = "TECH_CHILD_A", PrereqTech = "TECH_BASE" },
        { TechType = "TECH_CHILD_B", PrereqTech = "TECH_BASE" },
    }
    installTechDB(techs, prereqs)
    local graph = TechTreeLogic.buildGraph()
    local cursor = NavigableGraph.new({
        getParents = graph.getParents,
        getChildren = graph.getChildren,
        getRoots = graph.getRoots,
    })
    local childA = GameInfo.Technologies["TECH_CHILD_A"]
    TechTreeLogic.seedCursorSiblings(cursor, childA, graph)
    T.eq(cursor.current().Type, "TECH_CHILD_A")
    -- Siblings should be BASE's children: [CHILD_A, CHILD_B]. Cycling
    -- right from CHILD_A lands on CHILD_B without any prior vertical nav.
    local n = cursor.cycleSibling(1)
    T.truthy(n, "sibling cycle is live immediately after seedCursorSiblings")
    T.eq(n.Type, "TECH_CHILD_B")
end

return M

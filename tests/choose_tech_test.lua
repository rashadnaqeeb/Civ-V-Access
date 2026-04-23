-- ChooseTechLogic tests. Exercises mode filtering, advisor compositing,
-- label composition, and help-text cleanup against stubbed Players / GameInfo
-- / Game tables so we don't have to dofile the install-side access module
-- (which touches ContextPtr / Events at load).

local T = require("support")
local M = {}

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    AdvisorTypes = AdvisorTypes
        or {
            ADVISOR_ECONOMIC = 0,
            ADVISOR_MILITARY = 1,
            ADVISOR_SCIENCE = 2,
            ADVISOR_FOREIGN = 3,
        }

    Locale = Locale or {}
    Locale.ConvertTextKey = Locale.ConvertTextKey or function(k, ...)
        return k
    end

    Game = Game or {}
    Game.IsTechRecommended = function()
        return false
    end
    Game.SetAdvisorRecommenderTech = function() end
    GameInfo = {}
    Players = {}
    Teams = {}

    -- Logic's buildLabel pulls the engine help text via this global (defined
    -- in-game by TechHelpInclude, which the base TechPopup.lua has already
    -- loaded by the time our same-Context include runs). Default is empty so
    -- label tests that don't care about help prose stay short; tests that
    -- exercise help-text composition override this per-case.
    GetHelpTextForTech = function() return "" end

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "free"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "currently researching"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "queued slot {1_Slot}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = "{1_Num} turns"

    dofile("src/dlc/UI/InGame/Popups/CivVAccess_ChooseTechLogic.lua")
end

-- Sets Locale so advisor-key lookups return a distinct string per advisor so
-- concatenation order is observable in tests. Also maps a handful of
-- tech-description keys to friendly names so label assertions can search for
-- human-readable strings instead of raw TXT_KEY prefixes.
local function installAdvisorLocale()
    Locale.ConvertTextKey = function(k, ...)
        if k == "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_ECONOMIC" then
            return "economic"
        elseif k == "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_MILITARY" then
            return "military"
        elseif k == "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_SCIENCE" then
            return "science"
        elseif k == "TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_FOREIGN" then
            return "foreign"
        elseif k == "TXT_KEY_TECH_POTTERY" or k == "Pottery" then
            return "Pottery"
        end
        return k
    end
end

local function mkTech(id, typeName, description)
    return { ID = id, Type = typeName, Description = description or ("TXT_KEY_TECH_" .. typeName) }
end

local function installTechs(techs)
    GameInfo.Technologies = setmetatable({}, {
        __index = function(_, k)
            if type(k) == "number" then
                for _, t in ipairs(techs) do
                    if t.ID == k then
                        return t
                    end
                end
            end
            return nil
        end,
        __call = function()
            local i = 0
            return function()
                i = i + 1
                return techs[i]
            end
        end,
    })
end

local function mkPlayer(opts)
    opts = opts or {}
    return {
        _canResearch = opts.canResearch or {},
        _canResearchForFree = opts.canResearchForFree or {},
        _currentResearch = opts.currentResearch or -1,
        _queuePositions = opts.queuePositions or {},
        _team = opts.team or 0,
        _numFreeTechs = opts.numFreeTechs or 0,
        _science = opts.science or 0,
        _researchTurnsLeft = opts.researchTurnsLeft or {},
        CanResearch = function(self, id) return self._canResearch[id] == true end,
        CanResearchForFree = function(self, id) return self._canResearchForFree[id] == true end,
        GetCurrentResearch = function(self) return self._currentResearch end,
        GetQueuePosition = function(self, id) return self._queuePositions[id] or -1 end,
        GetTeam = function(self) return self._team end,
        GetNumFreeTechs = function(self) return self._numFreeTechs end,
        GetScience = function(self) return self._science end,
        GetResearchTurnsLeft = function(self, id, _overflow) return self._researchTurnsLeft[id] or 0 end,
    }
end

local function mkTeam(techs)
    return {
        _techs = techs or {},
        IsHasTech = function(self, id) return self._techs[id] == true end,
    }
end

-- ===== advisorSuffix =====

function M.test_advisorSuffix_empty_when_no_recommend()
    setup()
    installAdvisorLocale()
    Game.IsTechRecommended = function() return false end
    T.eq(ChooseTechLogic.advisorSuffix(1), "")
end

function M.test_advisorSuffix_single_advisor()
    setup()
    installAdvisorLocale()
    Game.IsTechRecommended = function(id, adv) return adv == AdvisorTypes.ADVISOR_SCIENCE end
    T.eq(ChooseTechLogic.advisorSuffix(1), "science")
end

function M.test_advisorSuffix_order_economic_military_science_foreign()
    setup()
    installAdvisorLocale()
    Game.IsTechRecommended = function(id, adv) return true end -- all four
    T.eq(ChooseTechLogic.advisorSuffix(1), "economic military science foreign")
end

-- ===== buildEntries =====

function M.test_buildEntries_normal_filters_canResearch()
    setup()
    installTechs({ mkTech(1, "AGRICULTURE"), mkTech(2, "POTTERY"), mkTech(3, "SAILING") })
    Players[0] = mkPlayer({
        canResearch = { [1] = true, [3] = true },
        currentResearch = -1,
    })
    local entries, current = ChooseTechLogic.buildEntries(0, "normal", -1)
    T.eq(#entries, 2, "two researchable")
    T.eq(entries[1].techID, 1)
    T.eq(entries[2].techID, 3)
    T.eq(current, nil, "no current pin in normal mode")
end

function M.test_buildEntries_free_filters_canResearchForFree()
    setup()
    installTechs({ mkTech(1, "AGRICULTURE"), mkTech(2, "POTTERY") })
    Players[0] = mkPlayer({
        canResearchForFree = { [2] = true },
        canResearch = { [1] = true, [2] = true },
        currentResearch = -1,
        numFreeTechs = 1,
    })
    local entries, current = ChooseTechLogic.buildEntries(0, "free", -1)
    T.eq(#entries, 1)
    T.eq(entries[1].techID, 2)
    T.eq(current, nil)
end

-- Free mode requires CanResearch as an outer gate (base TechPopup.lua wraps the
-- free check inside CanResearch). Without it, we'd surface techs the engine
-- rejects at commit - a silent no-op with the user hearing "gained X" while
-- nothing actually researches.
function M.test_buildEntries_free_requires_canResearch()
    setup()
    installTechs({ mkTech(1, "AGRICULTURE") })
    Players[0] = mkPlayer({
        canResearchForFree = { [1] = true },
        canResearch = {}, -- prereqs not met
        currentResearch = -1,
        numFreeTechs = 1,
    })
    local entries, _ = ChooseTechLogic.buildEntries(0, "free", -1)
    T.eq(#entries, 0, "CanResearchForFree alone must not admit a tech")
end

function M.test_buildEntries_stealing_intersects_target_techs()
    setup()
    installTechs({ mkTech(1, "AGRICULTURE"), mkTech(2, "POTTERY"), mkTech(3, "SAILING") })
    Players[0] = mkPlayer({
        canResearch = { [1] = true, [2] = true, [3] = true },
    })
    Players[1] = mkPlayer({ team = 1 })
    Teams[1] = mkTeam({ [2] = true, [3] = true }) -- target has 2 and 3; we can research all 3
    local entries, current = ChooseTechLogic.buildEntries(0, "stealing", 1)
    T.eq(#entries, 2, "intersect of canResearch and target-has-tech")
    T.eq(entries[1].techID, 2)
    T.eq(entries[2].techID, 3)
end

function M.test_buildEntries_free_mode_pins_current_research()
    setup()
    installTechs({ mkTech(1, "AGRICULTURE"), mkTech(2, "POTTERY") })
    Players[0] = mkPlayer({
        canResearchForFree = { [1] = true, [2] = true },
        canResearch = { [1] = true, [2] = true },
        currentResearch = 1, -- currently researching Agriculture
        numFreeTechs = 1,
    })
    local entries, current = ChooseTechLogic.buildEntries(0, "free", -1)
    T.truthy(current, "current should be pinned in free mode")
    T.eq(current.techID, 1)
    T.eq(#entries, 1, "current removed from Choice list")
    T.eq(entries[1].techID, 2)
end

function M.test_buildEntries_normal_mode_keeps_current_in_list()
    setup()
    -- Normal-mode popup only opens when current research == -1, but verify
    -- the Logic's contract: if called with a current-research in normal mode,
    -- don't extract the pin. The access layer gates the call.
    installTechs({ mkTech(1, "AGRICULTURE") })
    Players[0] = mkPlayer({
        canResearch = { [1] = true },
        currentResearch = 1,
    })
    local entries, current = ChooseTechLogic.buildEntries(0, "normal", -1)
    T.eq(current, nil)
    T.eq(#entries, 1)
    T.eq(entries[1].isCurrent, true, "isCurrent flag still set for label composition")
end

function M.test_buildEntries_records_queue_position()
    setup()
    installTechs({ mkTech(1, "AGRICULTURE"), mkTech(2, "POTTERY") })
    Players[0] = mkPlayer({
        canResearch = { [1] = true, [2] = true },
        queuePositions = { [2] = 3 },
    })
    local entries, _ = ChooseTechLogic.buildEntries(0, "normal", -1)
    T.eq(entries[1].queuePosition, nil, "unqueued has nil position")
    T.eq(entries[2].queuePosition, 3)
end

-- ===== buildLabel =====

local function mkLabelPlayer(science, turnsByTech)
    return mkPlayer({ science = science, researchTurnsLeft = turnsByTech or {} })
end

function M.test_buildLabel_name_leads()
    setup()
    installAdvisorLocale()
    CivVAccess_Strings["TXT_KEY_TECH_POTTERY"] = "Pottery"
    local entry = {
        techID = 1,
        info = { Description = "TXT_KEY_TECH_POTTERY" },
        mode = "normal",
    }
    local label = ChooseTechLogic.buildLabel(entry, mkLabelPlayer(5, { [1] = 10 }))
    T.truthy(label:sub(1, 7) == "Pottery", "tech name first: " .. label)
end

function M.test_buildLabel_includes_turns_when_science_positive()
    setup()
    installAdvisorLocale()
    local entry = { techID = 1, info = { Description = "Pottery" }, mode = "normal" }
    local label = ChooseTechLogic.buildLabel(entry, mkLabelPlayer(5, { [1] = 10 }))
    T.truthy(label:find("10 turns"), "turns present: " .. label)
end

function M.test_buildLabel_omits_turns_when_science_zero()
    setup()
    installAdvisorLocale()
    local entry = { techID = 1, info = { Description = "Pottery" }, mode = "normal" }
    local label = ChooseTechLogic.buildLabel(entry, mkLabelPlayer(0, { [1] = 10 }))
    T.eq(label:find("turns"), nil, "no turns at zero science: " .. label)
end

function M.test_buildLabel_omits_turns_in_stealing_mode()
    setup()
    installAdvisorLocale()
    local entry = { techID = 1, info = { Description = "Pottery" }, mode = "stealing" }
    local label = ChooseTechLogic.buildLabel(entry, mkLabelPlayer(5, { [1] = 10 }))
    T.eq(label:find("turns"), nil, "no turns when stealing: " .. label)
end

function M.test_buildLabel_free_status_shows()
    setup()
    installAdvisorLocale()
    local entry = { techID = 1, info = { Description = "Pottery" }, mode = "free" }
    local label = ChooseTechLogic.buildLabel(entry, mkLabelPlayer(5, { [1] = 10 }))
    T.truthy(label:find("free"), "status 'free' shown: " .. label)
end

function M.test_buildLabel_queued_status_shows_slot()
    setup()
    installAdvisorLocale()
    local entry = {
        techID = 1,
        info = { Description = "Pottery" },
        mode = "normal",
        queuePosition = 2,
    }
    local label = ChooseTechLogic.buildLabel(entry, mkLabelPlayer(5, { [1] = 10 }))
    T.truthy(label:find("queued slot 2"), "queue slot shown: " .. label)
end

function M.test_buildLabel_advisor_suffix_appended()
    setup()
    installAdvisorLocale()
    Game.IsTechRecommended = function(id, adv) return adv == AdvisorTypes.ADVISOR_MILITARY end
    local entry = { techID = 1, info = { Description = "Pottery" }, mode = "normal" }
    local label = ChooseTechLogic.buildLabel(entry, mkLabelPlayer(5, { [1] = 10 }))
    T.truthy(label:find("military"), "advisor suffix appended: " .. label)
end

function M.test_buildLabel_filtered_help_trails()
    setup()
    installAdvisorLocale()
    GetHelpTextForTech = function()
        return "POTTERY[NEWLINE]Cost: 60[NEWLINE]Leads to: Animal Husbandry[NEWLINE]Allows construction of Granary"
    end
    local entry = { techID = 1, info = { Description = "Pottery" }, mode = "normal" }
    local label = ChooseTechLogic.buildLabel(entry, mkLabelPlayer(5, { [1] = 10 }))
    T.truthy(label:find("Animal Husbandry"), "help text appended: " .. label)
    T.truthy(label:find("Granary"), "unlocks included: " .. label)
    local _, count = label:gsub("Pottery", "x")
    T.eq(count, 1, "tech name not duplicated after strip: " .. label)
end

-- ===== cleanHelpText =====

function M.test_cleanHelpText_strips_leading_name()
    setup()
    local out = ChooseTechLogic.cleanHelpText("POTTERY Cost: 60", "Pottery")
    T.eq(out, "Cost: 60")
end

function M.test_cleanHelpText_collapses_dash_runs()
    setup()
    local out = ChooseTechLogic.cleanHelpText("Cost: 60 ------------------------- Leads to: X", "")
    T.eq(out:find("%-%-%-"), nil, "long dash runs collapsed: " .. out)
    T.truthy(out:find("Cost: 60, Leads to: X") or out:find("Cost: 60 , Leads to: X"), "comma-separated: " .. out)
end

function M.test_cleanHelpText_empty_input()
    setup()
    T.eq(ChooseTechLogic.cleanHelpText(nil, "Pottery"), "")
    T.eq(ChooseTechLogic.cleanHelpText("", "Pottery"), "")
end

return M

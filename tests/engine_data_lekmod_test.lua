-- LekMod EngineData port tests. Two jobs:
--   * Parity: the vanilla and LekMod CivVAccess_EngineData.lua must define the
--     identical function set, so a seam added to one and forgotten in the
--     other fails here instead of failing at speech time on the other engine
--     (the same guard engine_data_vp_test enforces for VP).
--   * LekMod bodies match vanilla on the high-divergence reads. LekMod does
--     not diverge from vanilla on any drift read (verified: vanilla signed-
--     surplus happiness, display-scale getters, a purely additive binding
--     surface), so its bodies ARE the vanilla calls. These tests pin exactly
--     the points where VP diverges hardest -- the happiness model, tourism
--     scale, the bestDefender signature -- so a future edit that accidentally
--     gives the LekMod seam VP semantics (a silent-value failure, nothing
--     crashes) is caught here.
--
-- Each test loads the file under test into a fresh environment (setfenv)
-- whose reads fall through to _G, matching engine_data_vp_test.

local T = require("support")
local M = {}

local VANILLA_PATH = "src/dlc/UI/InGame/CivVAccess_EngineData.lua"
local LEKMOD_PATH = "src/lekmod/CivVAccess_EngineData.lua"

local function loadSeam(path)
    local env = setmetatable({}, { __index = _G })
    local chunk = assert(loadfile(path))
    setfenv(chunk, env)
    chunk()
    return env.EngineData, env
end

function M.test_lekmod_and_vanilla_define_identical_function_sets()
    local vanilla = loadSeam(VANILLA_PATH)
    local lekmod = loadSeam(LEKMOD_PATH)
    local missing, extra = {}, {}
    for name, value in pairs(vanilla) do
        if type(value) == "function" and type(lekmod[name]) ~= "function" then
            missing[#missing + 1] = name
        end
    end
    for name, value in pairs(lekmod) do
        if type(value) == "function" and type(vanilla[name]) ~= "function" then
            extra[#extra + 1] = name
        end
    end
    table.sort(missing)
    table.sort(extra)
    T.eq(table.concat(missing, ","), "", "seam functions missing from the LekMod implementation")
    T.eq(table.concat(extra, ","), "", "seam functions only in the LekMod implementation")
end

-- LekMod's fork canaries are the same Game bindings as vanilla (we ported the
-- same additions under their vanilla names), so forkPresent must key off them.
function M.test_lekmod_fork_present_checks_the_same_game_canaries()
    local lekmod, env = loadSeam(LEKMOD_PATH)
    env.Game = {
        GetBuildRoutePath = function() end,
        GetCycleUnits = function() end,
        GetClosestSearchedPlot = function() end,
    }
    T.truthy(lekmod.forkPresent(), "all three fork Game bindings present -> fork present")
    env.Game.GetClosestSearchedPlot = nil
    T.falsy(lekmod.forkPresent(), "a missing fork binding -> fork absent (degrade, do not throw)")
end

-- Happiness on LekMod is the vanilla signed surplus, NOT VP's 0-100 approval
-- percent. A consumer formatting an approval percent as a surplus (or vice
-- versa) is the canonical silent-value failure the happinessSummary model
-- exists to prevent.
function M.test_lekmod_happiness_summary_is_surplus_model()
    local lekmod = loadSeam(LEKMOD_PATH)
    local player = {
        GetExcessHappiness = function()
            return -7
        end,
        IsEmpireUnhappy = function()
            return true
        end,
        IsEmpireVeryUnhappy = function()
            return false
        end,
    }
    local s = lekmod.happinessSummary(player)
    T.eq(s.mode, "surplus", "LekMod happiness must report the signed-surplus model")
    T.eq(s.value, -7, "value is the raw signed surplus")
    T.eq(s.state, "unhappy")
    T.eq(s.happyCitizens, nil, "citizen counts are a VP approval-model field, absent on LekMod")
end

-- Vanilla-model happiness breakdown getters pass straight through on LekMod
-- (VP hardcodes these to 0 / errors under its citizen-needs model).
function M.test_lekmod_happiness_breakdown_passes_through()
    local lekmod = loadSeam(LEKMOD_PATH)
    T.eq(
        lekmod.unhappinessFromCityCount({
            GetUnhappinessFromCityCount = function()
                return 350
            end,
        }),
        350
    )
end

-- LekMod's bare getters return display scale, so tourism passes through
-- unscaled. VP divides a times-100 getter by 100; that body here would read
-- 100x low.
function M.test_lekmod_tourism_passes_through_unscaled()
    local lekmod = loadSeam(LEKMOD_PATH)
    T.eq(
        lekmod.tourism({
            GetTourism = function()
                return 1234
            end,
        }),
        1234,
        "LekMod tourism is already a plain rate, no times-100 division"
    )
    T.eq(
        lekmod.baseTourism({
            GetBaseTourism = function()
                return 12
            end,
        }),
        12,
        "base tourism is already a plain rate too"
    )
end

-- bestDefender keeps the vanilla positional signature on LekMod (purely
-- additive binding surface). VP inserts a pIgnoreUnit arg and repurposes the
-- potential-enemy slot as bIgnoreVisibility; that arg order here would pick
-- the wrong defender.
function M.test_lekmod_best_defender_uses_vanilla_positional_signature()
    local lekmod = loadSeam(LEKMOD_PATH)
    local seen
    local plot = {
        GetBestDefender = function(_, owner, attackingPlayer, attacker, atWar, potentialEnemy, canMove, noncombat)
            seen = {
                owner = owner,
                attackingPlayer = attackingPlayer,
                attacker = attacker,
                atWar = atWar,
                potentialEnemy = potentialEnemy,
                canMove = canMove,
                noncombat = noncombat,
            }
            return "defender"
        end,
    }
    local got = lekmod.bestDefender(plot, 3, "actor", { testAtWar = true, noncombatAllowed = true })
    T.eq(got, "defender")
    T.eq(seen.owner, -1, "owner filter off")
    T.eq(seen.attackingPlayer, 3)
    T.eq(seen.attacker, "actor")
    T.eq(seen.atWar, 1)
    T.eq(seen.potentialEnemy, 0, "vanilla potential-enemy slot at arg 5, off")
    T.eq(seen.canMove, 0, "bTestCanMove off at arg 6")
    T.eq(seen.noncombat, 1, "fork noncombat extension at arg 7")
end

-- VP-only features stay inert on LekMod, exactly as on vanilla: vassalage,
-- war score, embassies, historic events, building investments have no LekMod
-- equivalent, so their bodies must return the no-support answer.
function M.test_lekmod_vp_only_features_are_inert()
    local lekmod = loadSeam(LEKMOD_PATH)
    T.eq(lekmod.warScore({}, 3), nil, "no war-score concept")
    T.eq(lekmod.embassyOwner({}), nil, "no embassies")
    T.eq(lekmod.supportsHistoricEvents(), false)
    T.eq(lekmod.buildingInvestmentsEnabled(), false)
    local v = lekmod.vassalInfo({})
    T.falsy(v.isVassal, "no vassalage system")
    T.eq(#v.vassals, 0)
end

return M

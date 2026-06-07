-- UnitControlCombat speech / buffer gating. Drives the engine-fork
-- CivVAccessCombatResolved hook through onCombatResolved + the deferred
-- flushPendingHooks and asserts the three-way contract the bracket buffer
-- depends on: the F7 CombatLog records every resolved combat regardless of
-- the speech toggle, while speech AND the message buffer fire only when the
-- combat is spoken (active-player-involved always, AI-vs-AI only when
-- aiCombatAnnounce is on). UnitSpeech text formatting is stubbed to a marker
-- so the assertions isolate the gate, not the readout wording (that has its
-- own suite).

local T = require("support")
local M = {}

local spoken
local combatListener
local capturedFlush

-- A full CivVAccessCombatResolved payload for a one-on-one unit melee. Opts
-- override only the bits the gate keys on: who attacks (active vs AI) and the
-- defender identity (so multi-hook tests can target distinct defenders).
local function resolveCombat(opts)
    opts = opts or {}
    local attackerPlayer = opts.attackerPlayer or 0
    local defenderPlayer = opts.defenderPlayer or 1
    local defenderUnit = opts.defenderUnit or 9
    combatListener(
        attackerPlayer, -- attackerPlayer
        5, -- attackerUnit
        10, -- attackerDamage
        10, -- attackerFinalDamage
        100, -- attackerMaxHP
        defenderPlayer, -- defenderPlayer
        defenderUnit, -- defenderUnit
        -1, -- defenderCity
        30, -- defenderDamage
        30, -- defenderFinalDamage
        100, -- defenderMaxHP
        -1, -- interceptorPlayer
        -1, -- interceptorUnit
        0, -- interceptorDamage
        0, -- combatKind (normal melee)
        1, -- plotVisibleToActiveTeam
        1, -- attackerKnown
        1, -- defenderKnown
        -1, -- attackerCity
        0, -- defenderCityCaptured
        3, -- plotX
        4 -- plotY
    )
end

local function flush()
    capturedFlush()
end

local function setup()
    -- SpeechPipeline must load before UnitControlCombat: the latter captures
    -- speakQueued as an upvalue at load time. captureSpeech patches the
    -- _speakAction seam below it, so the captured upvalue still records.
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitSpeech.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_CombatLog.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitControlCombat.lua")

    SpeechPipeline._reset()
    spoken = T.captureSpeech()

    -- Isolate the gate from readout wording: a fixed marker per defender so
    -- distinct defenders produce distinguishable text, and non-empty
    -- combatant names so onCombatResolved doesn't early-return on an empty
    -- name.
    UnitSpeech.combatResult = function(args)
        return "hit " .. args.defenderName
    end
    UnitSpeech.combatantName = function(_player, unitId)
        return "Unit" .. tostring(unitId)
    end
    UnitSpeech.cityCombatantName = function(_player, cityId)
        return "City" .. tostring(cityId)
    end

    civvaccess_shared = {}

    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    Game.IsHotSeat = function()
        return false
    end

    -- Capture the combat listener and the deferred flush instead of running
    -- on a real tick. Other listeners installListeners registers (capture,
    -- nuke, air-sweep) land on these same capturing dispatchers harmlessly.
    combatListener = nil
    capturedFlush = nil
    -- No-op dispatcher for the hooks these tests don't fire (capture, nuke,
    -- air-sweep). Only CivVAccessCombatResolved captures its listener.
    local function dispatcher()
        return { Add = function(_fn) end }
    end
    GameEvents = {
        CivVAccessCombatResolved = {
            Add = function(fn)
                combatListener = fn
            end,
        },
        CivVAccessAirSweepNoTarget = dispatcher(),
        CivVAccessNukeStart = dispatcher(),
        CivVAccessNukeUnitAffected = dispatcher(),
        CivVAccessNukeCityAffected = dispatcher(),
        CivVAccessNukeEnd = dispatcher(),
    }
    Events = {
        SerialEventCityCaptured = dispatcher(),
    }
    TickPump = {
        runOnce = function(fn)
            capturedFlush = fn
        end,
    }

    UnitControlCombat.installListeners()
end

-- The corrected invariant: an AI-vs-AI combat with announce off records to the
-- F7 log but stays out of speech and the bracket buffer (the buffer mirrors
-- what was spoken).
function M.test_ai_combat_muted_records_f7_only()
    setup()
    civvaccess_shared.aiCombatAnnounce = false
    resolveCombat({ attackerPlayer = 1, defenderPlayer = 2 })
    flush()
    T.eq(#spoken, 0, "muted AI combat is not spoken")
    T.eq(MessageBuffer._snapshot(), nil, "muted AI combat stays out of the buffer")
    T.eq(#civvaccess_shared.combatLog, 1, "F7 records it regardless")
end

-- AI-vs-AI with announce on: spoken and buffered under the combat category.
function M.test_ai_combat_announced_buffers()
    setup()
    civvaccess_shared.aiCombatAnnounce = true
    resolveCombat({ attackerPlayer = 1, defenderPlayer = 2 })
    flush()
    T.eq(#spoken, 1, "announced AI combat is spoken")
    local s = MessageBuffer._snapshot()
    T.truthy(s, "announced AI combat buffered")
    T.eq(#s.entries, 1)
    T.eq(s.entries[1].category, "combat")
    T.eq(#civvaccess_shared.combatLog, 1, "F7 records it too")
end

-- Active-player-involved combat speaks and buffers even with announce off:
-- the toggle only gates AI-vs-AI, never combat the player is in.
function M.test_player_combat_buffers_with_announce_off()
    setup()
    civvaccess_shared.aiCombatAnnounce = false
    resolveCombat({ attackerPlayer = 0, defenderPlayer = 1 })
    flush()
    T.eq(#spoken, 1, "player combat is spoken regardless of the AI toggle")
    local s = MessageBuffer._snapshot()
    T.truthy(s, "player combat buffered")
    T.eq(#s.entries, 1)
    T.eq(s.entries[1].text, "hit Unit9")
    T.eq(s.entries[1].category, "combat")
end

return M

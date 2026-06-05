-- The EngineData port: the single place the mod reads engine-sensitive
-- values and calls engine-extension (fork-added) bindings. The rest of the
-- mod reads the game directly; only the handful of points that actually
-- differ between engines route through here. This file is the VANILLA
-- (Brave New World) implementation -- every body is the call the mod made
-- inline before the port existed, so routing a call site through it changes
-- nothing on vanilla. A future engine adapter (e.g. Vox Populi) ships its
-- own CivVAccess_EngineData.lua in this file's place, with bodies that read
-- that engine's getters; the rest of the mod is unaffected because it only
-- ever sees these function names.
--
-- Two categories live here, added as call sites migrate onto the port:
--   * Drift reads -- getters whose VALUE or signature differs across
--     engines (combat damage, happiness, tourism, the trade resource
--     count). Plain passthroughs on vanilla.
--   * Extension bindings -- Lua methods the stock engine does not expose
--     and our C++ fork adds (mission queue, pathfinder, line of sight,
--     build-route finder). Gated on forkPresent() so a build without the
--     fork DLL degrades to a safe value and logs, instead of throwing a
--     method-not-found error that the engine swallows per listener and
--     silently kills the whole read.
--
-- No state is held here -- every function re-reads its handles, per the
-- never-cache rule. Published as civvaccess_shared.modules.EngineData so
-- Contexts other than InGame (Popups, CityView, WorldView) reach the same
-- implementation.

EngineData = {}

-- Is the engine fork DLL deployed? The fork registers several Game-level
-- bindings; if those resolve, the Unit / Plot fork bindings resolve too,
-- so the Game methods are the canary. A vanilla-DLL deploy (deploy.ps1
-- -SkipEngine, or a machine never deployed against) makes every extension
-- binding degrade rather than throw. This is the capability source the
-- Boot probe logs from and the binding wrappers gate on.
function EngineData.forkPresent()
    return Game ~= nil
        and Game.GetBuildRoutePath ~= nil
        and Game.GetCycleUnits ~= nil
        and Game.GetClosestSearchedPlot ~= nil
end

-- Extension binding: Unit:GetMissionQueue (the unit's queued missions).
-- Absent on a non-fork DLL, where a bare call throws a method-not-found
-- error the engine swallows per listener -- which is what silenced the
-- whole tile read on a stock engine. Degrades to an empty queue so callers
-- measuring #queue see "no queued missions" and keep going.
function EngineData.missionQueue(unit)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.missionQueue: engine fork absent, returning empty queue")
        return {}
    end
    return unit:GetMissionQueue()
end

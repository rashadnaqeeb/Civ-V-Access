# The multiplayer freeze: a game-core / UI thread deadlock

Hand-authored. Diagnosed August 2026 from paired process dumps of a hung
five-player LekMod multiplayer session (one dump from the blind player's client,
one from a sighted player's). Read this before adding any hook that calls Lua
from inside the engine, and before adding per-frame Lua that reads engine state.

## The symptom

Intermittent, roughly one session in thirty. The modded player's game stops
responding completely: Windows paints the "not responding" overlay, the window
never repaints, and nothing recovers it. Every other player in the game freezes
too, but only in the sense that the turn never advances; their clients are
healthy and still pumping input. Killing the modded client releases everyone
else immediately. On rejoin the same state often deadlocks again within a turn.

Reported in both the vanilla and LekMod install states, markedly more often in
LekMod.

## The mechanism

Civ V runs the simulation on a game-core thread and the UI, including all UI
Lua, on the main thread. Two locks are involved:

- a **mutex** guarding the game core, which every Lua binding takes before it
  reads or writes simulation state
- a **critical section** inside the host executable guarding the script system

The two directions of traffic take them in opposite orders.

- **UI thread**: Lua is running, so the script lock is already held. A binding
  like `Game.GetGameTurn()` or `Players[i]:IsHuman()` then takes the game-core
  mutex. Order: script lock, then game-core mutex.
- **Game-core thread**: the simulation holds the game-core mutex for the whole
  of `CvGame::doTurn`. When engine code calls out to Lua from in there
  (`LuaSupport::CallHook` / `LuaSupport::CallAccumulator`) it needs the script
  lock. Order: game-core mutex, then script lock.

That is a lock-order inversion. If the UI thread is inside any engine binding at
the moment the game core makes a Lua callout, both threads block forever.

## The evidence

From the blind player's dump:

```
thread 0 (UI, tid 18016)          thread 93 (game core, tid 21632)
ZwWaitForSingleObject             ZwWaitForAlertByThreadId
KERNELBASE!WaitForSingleObject    ntdll!RtlEnterCriticalSection
CivilizationV.exe+0x42386B        CivilizationV.exe+0x41CE47
lua51_original.dll  (x9)          CvGameCore!LuaSupport::CallAccumulator
CivilizationV.exe+0x4F7BD5          [CvLuaSupport.cpp:130]
                                  CvGameCore!CvGameReligions::
                                    GetFounderBenefitsReligion
                                    [CvReligionClasses.cpp:1878]
                                  CvGameCore!CvGame::doTurn
                                    [CvGame.cpp:8367]
```

Thread 0 is waiting on a `Mutant` (handle `0xDB0`). Thread 93 is waiting on a
critical section whose header, read out of the dump, closes the cycle:

```
CS at 0x06457E24   LockCount=-6   RecursionCount=2   OwningThread=18016
```

`OwningThread` is thread 0. Recursion count 2 matches the two nested Lua-into-
engine entries visible on its stack. So thread 0 holds the script lock and wants
the game-core mutex; thread 93 holds the game-core mutex and wants the script
lock.

The sighted player's dump shows the contrast: no `Mutant` wait anywhere in the
process, and its main thread sitting in `NtUserPeekMessage`, pumping normally.
It is a bystander waiting on a peer that will never finish its turn.

Both clients were running the identical fork DLL (same `SizeOfImage`, same
`TimeDateStamp`), so this is not a DLL-divergence problem. The only difference
was the accessibility runtime on the blind player's side.

## Why the mod made a rare base-game race common

The callout in the captured stack is stock Firaxis code. `CvReligionClasses.cpp`
is not in our fork's diff at all, and the base game has several more like it
(`GetReligionToFound`, `GetReligionToSpread`, the scenario diplomacy modifiers).
The race predates us. It is rare in an unmodded game because stock UI Lua only
touches the engine in response to user input, so the UI thread is almost never
inside a binding.

The mod widened both sides:

- **UI side.** Per-frame Lua that reads engine state. The MP end-turn reminder
  was the worst case: a TickPump subscriber that ran every frame, in networked
  multiplayer only, taking the game-core mutex several times per frame.
- **Game-core side.** The fork's own hooks. `CivVAccessUnitMoved` fires from
  `CvUnit::setXY`, once per hex per unit, and `CivVAccessPlotRevealed` fires
  from `CvPlot::setRevealed`. Both sit in the innermost loops of the simulation
  and used to make a synchronous Lua callout, thousands of times per turn.

That combination explains every part of the report: only the modded client
hangs, more often in LekMod (more players and units means more callouts per
turn and longer poll loops), and reproducibly on rejoin because the same
`doTurn` runs again over the same state.

## What was done about it

Two changes, in `Poll the MCP mailbox off the game thread`'s follow-up work:

1. **`CivVAccess_MPEndTurnReminder.lua` samples once per wall-clock second**
   instead of once per frame. The engine reads all sit behind that gate. The
   transition it watches for (the engine pulling a submitted turn back) persists
   until the player re-submits, so a slower sample cannot miss it.

2. **The two hot hooks no longer call Lua from the game-core thread.**
   `CivVAccessEventQueue` (see its header for the full contract) takes a few
   ints under its own critical section and returns; the UI thread drains the
   queue every tick through `Game.CivVAccessDrainEvents()` and dispatches to the
   same handlers. `CivVAccess_EngineEvents.lua` is the Lua half. Consumers
   register through `EngineEvents.on` instead of `Log.installEvent(GameEvents,
   ...)` and are otherwise unchanged.

## What is deliberately still synchronous

The rare hooks: the nuke family, goody huts, barbarian camps, city-state
greetings, combat resolution, mission dispatch. Their handlers read engine
objects that are destroyed moments after the hook fires — a nuked city is killed
on the next line — so deferring them would hand Lua dead handles. They fire
orders of magnitude less often than the two deferred hooks, so their
contribution to the race is small.

## Residual risk

This does not prove the deadlock away, and should not be described as if it
does. The stock religion and diplomacy callouts still run from `doTurn`, and the
UI thread still calls engine bindings. What changed is the size of the window on
both sides, by roughly two orders of magnitude. If a hang is reported again,
capture dumps the same way and check whether thread 0 is on a `Mutant` and some
other thread is in `RtlEnterCriticalSection` under a `LuaSupport::Call*` frame.

## Still to do

The Community Patch / Vox Populi fork (`dist/engine-vp`) has not been given the
queue yet. Its seam reports the drain binding absent, so `EngineEvents` falls
back to registering on `GameEvents` and VP behaves exactly as it did before —
correct, but still carrying the old exposure. Porting the queue there is the
same change: copy `CivVAccessEventQueue.{h,cpp}`, convert the two hook sites,
and add the `CivVAccessDrainEvents` binding.

## Reproducing the analysis

The dumps are 64-bit captures of a 32-bit (WOW64) process, so Task Manager's
"Create dump file" records x64 contexts and every thread appears parked in
`wow64cpu`. The real x86 context hangs off the TEB:
`TEB64.TlsSlots[WOW64_TLS_CPURESERVED=1]` points at a block whose x86 `CONTEXT`
starts 4 bytes in; validate it by checking `SegCs == 0x23` and `SegSs == 0x2B`.
From there, walk the EBP chain rather than scanning the stack — a raw scan picks
up dead slots and will invent call chains that were never there.

`dist/engine-lekmod/CvGameCore_Expansion2.pdb` matches the shipped fork exactly,
so engine frames symbolise to function and source line via dbghelp.

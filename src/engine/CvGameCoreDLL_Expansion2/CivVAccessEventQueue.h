/*	-------------------------------------------------------------------------------------------------------
	Civ V Access overlay. Deferred hand-off for the mod's high-frequency engine hooks.

	WHY THIS EXISTS

	Civ V runs the simulation on the game-core thread and the UI (and all UI Lua)
	on the main thread. The engine guards the game core with a mutex, and the
	host's script system guards Lua with a critical section. A Lua binding called
	from the UI thread takes them in the order script-lock then game-core-mutex.
	A Lua callout made from inside the simulation -- LuaSupport::CallHook /
	CallAccumulator reached from CvGame::doTurn -- takes them in the opposite
	order. That is a lock-order inversion, and when both happen at once the two
	threads deadlock permanently: the UI thread stops pumping messages, Windows
	marks the process "not responding", and in multiplayer every other player
	stalls behind the wedged client until it is killed.

	The base game already has this race (its own religion and diplomacy hooks
	call out to Lua from doTurn), but it is rare because stock UI Lua touches
	the engine only on user input. This mod's hooks made it common: the reveal
	and unit-move hooks fired a synchronous Lua callout from the innermost loops
	of the simulation, thousands of times per turn, each one an opportunity to
	collide with the mod's own per-frame UI Lua. Confirmed from paired process
	dumps of a hung multiplayer session -- see docs/llm-docs/mp-deadlock.md.

	WHAT THIS DOES

	The hot hooks no longer call Lua from the game-core thread at all. They copy
	a few ints into this queue and return. The UI thread drains the queue every
	tick through Game.CivVAccessDrainEvents() and dispatches to the same Lua
	handlers, on the thread that is allowed to be in Lua. The game core never
	waits on the script lock, so it cannot be one half of the cycle.

	Push is safe to call from any thread and never blocks on anything except
	this queue's own critical section, which is held only for a fixed-size copy
	-- no allocation, no Lua, no engine calls. The lock is always taken last, so
	it cannot participate in a cycle of its own.

	WHAT IS NOT DEFERRED

	Only the hooks that fire from the simulation's inner loops go through here.
	The rare ones (nuke resolution, goody huts, city-state greetings, combat
	resolution, mission dispatch) still call Lua synchronously: their handlers
	read engine objects that are destroyed moments later -- a nuked city is
	killed immediately after its hook -- so deferring them would hand Lua dead
	handles. They fire orders of magnitude less often than the two deferred
	hooks and their contribution to the race is correspondingly small.

	COST OF DEFERRAL

	Handlers see events up to one UI frame late. The mod's consumers already
	buffer these two hooks across a tick before speaking, so the ordering they
	rely on is preserved -- the queue is FIFO. A unit that dies in the same
	frame it moved can no longer be resolved by the time the move is dispatched,
	and that move is dropped; combat readouts speak the kill separately.
	------------------------------------------------------------------------------------------------------- */
#pragma once

#ifndef CIVVACCESS_EVENT_QUEUE_H
#define CIVVACCESS_EVENT_QUEUE_H

namespace CivVAccessEventQueue
{
// Widest deferred hook payload (unit moved: owner, unit, fromX, fromY, toX, toY).
const int MAX_ARGS = 6;

struct Event
{
	const char* szName;	// static string literal from the call site; never freed
	int iArgc;
	int aiArgs[MAX_ARGS];
};

// Queue one event. Call from any thread. szName must be a string literal.
// Silently drops the event when the queue is full and latches the overflow
// flag for the next drain.
void Push(const char* szName, int iArgc, const int* paiArgs);

// Move up to iMax queued events into paEvents, oldest first. Returns how many
// were written. Call from the UI thread only.
int Drain(Event* paEvents, int iMax);

// True once if events were dropped since the last call, then clears. The Lua
// side logs it; the membership maps it feeds already self-heal on a miss.
bool TakeOverflowed();
}

#endif // CIVVACCESS_EVENT_QUEUE_H

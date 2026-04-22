-- WorldView-Context input hook. Runs in WorldView.lua's sandbox (appended
-- at the bottom of our WorldView.lua override). The base WorldView
-- registers its own InputHandler via ContextPtr:SetInputHandler; we
-- re-register a wrapper that dispatches through our HandlerStack first
-- and, on a miss, falls through to the base handler so camera pan /
-- zoom / strategic-view toggle continue to work for sighted testers.
--
-- Why here in addition to InGame: WorldView is a child LuaContext under
-- InGame and sits earlier in the input dispatch chain. Its
-- DefaultMessageHandler returns true for VK_PRIOR / VK_NEXT (plus arrows
-- and OEM_PLUS/MINUS), so without this hook the scanner's PageUp/PageDown
-- cycle bindings with any modifier layer are swallowed before InGame's
-- InputHandler ever runs. Cursor keys (Q/A/D/Z/C) are not bound in
-- WorldView and bubble to InGame today -- those still work fine; this
-- hook is specifically for the keys WorldView would otherwise eat.
--
-- On dispatch hit, we return true and InGame never runs, so bindings
-- fire exactly once. On miss, we return false and InGame's own
-- InputRouter wrapper walks the same stack a second time; that is a
-- deterministic no-op (same bindings, same event) and costs one extra
-- small-loop pass per unbound keypress.
--
-- Dependencies are re-included in this sandbox because Civ V Contexts
-- are fenv-sandboxed (per-Context globals); HandlerStack state is still
-- shared via civvaccess_shared.stack, so both Contexts read and write
-- the same LIFO of handlers.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")

local WM_KEYDOWN = 256
local WM_SYSKEYDOWN = 260
local basePriorInput = InputHandler

ContextPtr:SetInputHandler(function(msg, wp, lp)
    if msg == WM_KEYDOWN or msg == WM_SYSKEYDOWN then
        local mods = InputRouter.currentModifierMask()
        if InputRouter.dispatch(wp, mods, msg) then
            return true
        end
    end
    return basePriorInput(msg, wp, lp)
end)

-- WorldView is always visible during gameplay, so its SetUpdate fires
-- reliably. TaskList (where Boot's TickPump.install also runs) appears to
-- skip the engine's update rotation when no in-game tasks are active,
-- which silently breaks any runOnce callback scheduled from TaskList's
-- sandbox. Installing from WorldView too guarantees the shared queue
-- drains regardless of TaskList's hide state.
TickPump.install(ContextPtr)

Log.info("CivVAccess_WorldViewKeys: installed InputHandler over base WorldView")

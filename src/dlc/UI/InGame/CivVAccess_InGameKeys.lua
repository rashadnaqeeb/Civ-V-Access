-- InGame-Context input hook. Runs in InGame.lua's sandbox (appended at
-- the bottom of our InGame.lua override). The base InGame.lua registers
-- its own InputHandler via ContextPtr:SetInputHandler; we re-register a
-- wrapper that dispatches through our HandlerStack first and, on a miss,
-- falls through to the base handler so engine behaviors (Esc opens the
-- game menu, interface-mode handlers, etc.) continue to work.
--
-- Why here and not on WorldView's ContextPtr alone: WorldView sits earlier
-- in the dispatch chain and catches keys the engine's own WorldView
-- DefaultMessageHandler would otherwise swallow (PageUp/PageDown, arrows,
-- OEM +/-), but it's not the root input seat. InGame is the root in-game
-- Context and its InputHandler receives every global key (that's how base
-- Esc opens the game menu). Suppression via "return true" is only
-- reachable from a Context that sits on that chain, so keys that reach
-- InGame need their own hook here.
--
-- Dependencies are re-included in this sandbox because Civ V Contexts
-- are fenv-sandboxed (per-Context globals); modules defined in WorldView's
-- Boot sandbox are not directly visible here. The HandlerStack state is
-- still shared via civvaccess_shared.stack, so both Contexts read and
-- write the same LIFO of handlers.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")

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

Log.info("CivVAccess_InGameKeys: installed InputHandler over base InGame")

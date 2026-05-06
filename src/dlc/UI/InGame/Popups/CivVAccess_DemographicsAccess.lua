-- Demographics accessibility (F9, standalone). Wraps the engine
-- Demographics popup as a flat BaseMenu list: one row per metric
-- (Population, Crop Yield, GNP, etc.), each speaking the active player's
-- value, rank, and the rival best / average / worst figures in vanilla
-- column order. The screen has no useful secondary axis -- rows are
-- heterogeneous metrics, not sortable like F2's city table -- so a flat
-- list is the natural shape; vanilla's table is visual scaffolding, not
-- strategic structure.
--
-- Row construction lives in CivVAccess_DemographicsRows so the same
-- metric speech can be reused by EndGameMenu's Demographics tab. This
-- file owns only the BaseMenu install and the F9 toggle binding.
--
-- All values are recomputed on every show via onShow -> setItems so the
-- ranking tracks the engine across turn ends. No upvalue caching.
--
-- Engine integration: ships an override of Demographics.lua (verbatim
-- base copy + an include for this module). The engine's OnPopup, OnBack,
-- ShowHideHandler, InputHandler, and GameplaySetActivePlayer wiring stay
-- intact; BaseMenu.install layers our handler on top via priorInput /
-- priorShowHide chains.
--
-- The same Demographics.lua file is also loaded as a child LuaContext
-- inside EndGameMenu (XML id "EndGameDemographics"), and runs there with
-- the engine's own InputHandler intentionally unregistered. We mirror
-- that: when ContextPtr is the EndGameDemographics child, skip our
-- install -- EndGameMenu's BaseMenu handler stays on top, its tabs own
-- the panel switch, and DemographicsRows.buildItems runs from inside the
-- end-game tab's onActivate. Without the gate our install would push a
-- Demographics handler whose Esc tries to dequeue a child Context (a
-- no-op) and traps the user on the demographics panel.

include("CivVAccess_PopupBoot")
include("CivVAccess_DemographicsRows")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

if type(ContextPtr) == "table"
    and type(ContextPtr.SetShowHideHandler) == "function"
    and ContextPtr:GetID() ~= "EndGameDemographics"
then
    local handler = BaseMenu.install(ContextPtr, {
        name = "Demographics",
        displayName = Text.key("TXT_KEY_DEMOGRAPHICS_TITLE"),
        items = DemographicsRows.buildItems(),
        priorInput = priorInput,
        priorShowHide = priorShowHide,
        onShow = function(h)
            h.setItems(DemographicsRows.buildItems())
        end,
    })

    -- F9 re-press toggles the popup shut, mirroring F8's pattern. The
    -- engine's own toggle (Data1==1 path in OnPopup) is bypassed because
    -- our handler captures input modally while the popup is up.
    if handler ~= nil and type(handler.bindings) == "table" then
        handler.bindings[#handler.bindings + 1] = {
            key = Keys.VK_F9,
            mods = 0,
            description = "Close Demographics",
            fn = function()
                UIManager:DequeuePopup(ContextPtr)
            end,
        }
    end
end

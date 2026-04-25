-- ContextPtr wiring for BaseMenu handlers. Wraps a screen's existing
-- ShowHide / Input handlers so the menu pushes/pops on show/hide, the type-
-- ahead and Esc-back semantics fire, and any prior wiring keeps working.
--
-- Distinct from BaseMenu.create (which produces just the handler object).
-- Help, Pulldown sub-menus, and Options popups push handlers directly onto
-- HandlerStack without an installed Context, so they need create() but not
-- install().
--
-- Spec fields specific to install (the rest are documented in BaseMenuCore):
--   priorShowHide,    chained beneath our wrapper so the engine's wiring
--   priorInput        keeps working underneath.
--   shouldActivate    fn() -> bool; if false on a non-hide ShowHide, skip
--                     the push without blocking the prior ShowHide.
--   onShow            fn(handler); runs after priorShowHide and before the
--                     push so setInitialIndex / setItems land before
--                     onActivate reads them.
--   deferActivate     when true, push fires next tick through TickPump so a
--                     same-frame hide can cancel before speech.
--   tickOwner         default true; install wires ContextPtr's SetUpdate to
--                     TickPump for runOnce callbacks (edit-mode TakeFocus,
--                     deferred pushes).
--   onEscape          fn(handler) -> bool; consulted before priorInput when
--                     Esc fires (at any drill level). Return true to consume.
--                     Esc never drills out one level at a time — use Left for
--                     that — so the hook sees Esc regardless of _level.
--   suppressReactivateOnHide
--                     fn() -> bool; consulted on hide. When true, the hide-
--                     time removeByName passes reactivate=false so the
--                     handler underneath does not announce. Used by tab-swap
--                     panels (DiploOverview) where a sibling Context is
--                     about to push within the same engine event chain and
--                     the intermediate exposure of Scanner / parent menu
--                     would speak a transient mode label.

function BaseMenu.install(ContextPtr, spec)
    local handler = BaseMenu.create(spec)
    local priorShowHide = spec.priorShowHide
    local priorInput = spec.priorInput
    local deferActivate = spec.deferActivate == true
    local shouldActivate = spec.shouldActivate
    local onShow = spec.onShow
    local tickOwner = spec.tickOwner ~= false
    local onEscape = spec.onEscape
    local suppressReactivateOnHide = spec.suppressReactivateOnHide
    local pendingPush = false

    if tickOwner then
        TickPump.install(ContextPtr)
    end

    local function runDeferredPush()
        if not pendingPush then
            return
        end
        pendingPush = false
        if ContextPtr:IsHidden() then
            return
        end
        HandlerStack.push(handler)
    end

    ContextPtr:SetShowHideHandler(function(bIsHide, bIsInit)
        if priorShowHide then
            local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
            if not ok then
                Log.error("BaseMenu '" .. handler.name .. "' prior ShowHide: " .. tostring(err))
            end
        end
        -- bIsInit=true fires once per Context at boot so the engine can
        -- prime it; the screen isn't actually open to the user. Pushing
        -- here would land our handler on top of whatever is genuinely
        -- visible (LoadScreen at game start) with capturesAllInput=true,
        -- trapping input until the real screen finally closes.
        if bIsInit then
            return
        end
        -- On show (bIsHide=false): reactivate=false so the handler we're
        -- about to re-push doesn't spuriously announce whatever is beneath
        -- it mid-transition. On hide: reactivate=true so the newly-exposed
        -- handler (Scanner when a popup closes, parent menu when a nested
        -- popup closes) announces itself and the user hears which mode
        -- they landed back in. suppressReactivateOnHide opts out for the
        -- tab-swap case where a sibling Context will push within the same
        -- engine event chain.
        local reactivate = bIsHide
        if bIsHide and suppressReactivateOnHide ~= nil then
            local ok, suppress = pcall(suppressReactivateOnHide)
            if not ok then
                Log.error("BaseMenu '" .. handler.name .. "' suppressReactivateOnHide: " .. tostring(suppress))
            elseif suppress then
                reactivate = false
            end
        end
        HandlerStack.removeByName(handler.name, reactivate)
        if bIsHide then
            handler._initialized = false
            pendingPush = false
            return
        end
        if shouldActivate ~= nil then
            local ok, should = pcall(shouldActivate)
            if not ok then
                Log.error("BaseMenu '" .. handler.name .. "' shouldActivate: " .. tostring(should))
                return
            end
            if not should then
                return
            end
        end
        -- onShow runs after priorShowHide (so the base screen's setters
        -- have finalized) and before the push (so setInitialIndex /
        -- setItems calls land before onActivate reads them). Receives the
        -- handler so callers don't need a forward-declared upvalue.
        if onShow ~= nil then
            local ok, err = pcall(onShow, handler)
            if not ok then
                Log.error("BaseMenu '" .. handler.name .. "' onShow: " .. tostring(err))
            end
        end
        if deferActivate then
            pendingPush = true
            if not tickOwner then
                TickPump.install(ContextPtr)
            end
            TickPump.runOnce(runDeferredPush)
        else
            HandlerStack.push(handler)
        end
    end)

    ContextPtr:SetInputHandler(function(msg, wp, lp)
        local top = HandlerStack.active()
        -- During edit mode, claim the Enter KEYUP so the engine's default
        -- Enter-release doesn't revoke focus from the EditBox we just took
        -- focus on. Without this, typed characters end up nowhere.
        if top ~= nil and top._editMode and msg == 257 and wp == Keys.VK_RETURN then
            return true
        end
        if (msg == 256 or msg == 260) and wp == Keys.VK_ESCAPE then
            -- Esc on the menu itself: if a type-ahead search is live, clear
            -- it and stay put. Otherwise bypass to the screen's own Back /
            -- OnNo at any drill level — Esc does not drill out one level at
            -- a time (users shouldn't need 5 presses to close a menu they
            -- drilled 5 levels into; Left is how you walk back up). Esc on
            -- a sub (pulldown / edit mode) runs the sub's binding.
            if top == handler then
                if handler._search:isSearchActive() or handler._search:hasBuffer() then
                    handler._search:clear()
                    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
                    return true
                end
                if onEscape ~= nil then
                    -- Esc hook. Consumed (return true) means the screen
                    -- stays open; unconsumed falls through to the screen's
                    -- own priorInput (closes the pedia, ExitConfirm, etc.).
                    -- PickerReader uses this to bounce the reader tab back
                    -- to the picker tab rather than closing the screen.
                    local ok, consumed = pcall(onEscape, handler)
                    if not ok then
                        Log.error("BaseMenu '" .. handler.name .. "' onEscape: " .. tostring(consumed))
                    elseif consumed then
                        return true
                    end
                end
                if priorInput then
                    return priorInput(msg, wp, lp)
                end
                return false
            end
            local mods = InputRouter.currentModifierMask()
            if InputRouter.dispatch(wp, mods, msg) then
                return true
            end
            if priorInput then
                return priorInput(msg, wp, lp)
            end
            return false
        end
        local mods = InputRouter.currentModifierMask()
        if InputRouter.dispatch(wp, mods, msg) then
            return true
        end
        if priorInput then
            return priorInput(msg, wp, lp)
        end
        return false
    end)

    return handler
end

-- Minimal InputHandler that routes Esc to backFn and consumes everything
-- else (returns true). Convenience for screens whose only non-menu input
-- contract is "Esc = go back".
function BaseMenu.escOnlyInput(backFn)
    return function(uiMsg, wParam)
        if (uiMsg == 256 or uiMsg == 260) and wParam == Keys.VK_ESCAPE then
            backFn()
        end
        return true
    end
end

return BaseMenu

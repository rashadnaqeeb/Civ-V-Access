-- Dispatches keyboard events down the HandlerStack, top-first. Stateless.
-- Called from each screen's SetInputHandler (via BaseMenu.install for
-- front-end screens, directly from in-game handlers).
--
-- Pre-walk hooks (run before the binding walk):
--   1. Shift+? opens the Help overlay built from HandlerStack.collectHelpEntries.
--      Gated so pressing ? while Help is on top doesn't re-enter.
--   2. Type-ahead search: if the top handler exposes handleSearchInput, route
--      printable / Backspace / Space through it so every BaseMenu-backed
--      handler (installed or pushed directly) gets search without needing 40+
--      per-letter bindings.

InputRouter = {}

local WM_KEYDOWN = 256
local WM_SYSKEYDOWN = 260

local MOD_SHIFT = 1
local MOD_CTRL = 2
local MOD_ALT = 4

-- Windows VK for the US '/?' key. Shift+OEM_2 is what the user types to
-- mean '?'. Non-US layouts produce '?' via a different VK; revisit if we
-- localize the help hotkey.
local VK_OEM_2 = 191

function InputRouter.currentModifierMask()
    local mask = 0
    if UI.ShiftKeyDown() then
        mask = mask + MOD_SHIFT
    end
    if UI.CtrlKeyDown() then
        mask = mask + MOD_CTRL
    end
    if UI.AltKeyDown() then
        mask = mask + MOD_ALT
    end
    return mask
end

-- Invariant: a binding's fn may push or pop handlers, but this loop bails
-- (`return true`) the moment any binding fires, so the walk never sees a
-- mutated stack under its own feet. Bindings that intend to keep the walk
-- going after mutating the stack are not supported; add a new primitive
-- before trying.
function InputRouter.dispatch(keyCode, modMask, msg)
    if msg ~= WM_KEYDOWN and msg ~= WM_SYSKEYDOWN then
        return false
    end

    -- Help overlay hotkey. Fires before the binding walk so every screen
    -- that routes through InputRouter gets ? help uniformly, without each
    -- handler having to bind it. Skips when Help is already on top.
    if keyCode == VK_OEM_2 and modMask == MOD_SHIFT then
        local top = HandlerStack.active()
        if top == nil or top.name ~= "Help" then
            if Help ~= nil and type(Help.open) == "function" then
                local ok, err = pcall(Help.open)
                if not ok then
                    Log.error("InputRouter: Help.open failed: " .. tostring(err))
                end
            else
                Log.warn("InputRouter: Shift+? pressed but Help module not loaded")
            end
            return true
        end
    end

    -- Type-ahead search. Handler-exposed hook so any handler with a search
    -- instance participates (BaseMenu-created handlers, including HelpHandler).
    -- Only keydowns route through search; WM_SYSKEYDOWN carries Alt-chorded
    -- keys that don't feed type-ahead.
    if msg == WM_KEYDOWN then
        local top = HandlerStack.active()
        if top ~= nil and type(top.handleSearchInput) == "function" then
            local ok, consumed = pcall(top.handleSearchInput, top, keyCode, modMask)
            if not ok then
                Log.error("InputRouter search hook in '" .. tostring(top.name) .. "' failed: " .. tostring(consumed))
            elseif consumed then
                return true
            end
        end
    end

    for i = HandlerStack.count(), 1, -1 do
        local h = HandlerStack.at(i)
        local bindings = h.bindings
        if type(bindings) == "table" then
            for _, b in ipairs(bindings) do
                if b.key == keyCode and (b.mods or 0) == modMask then
                    local ok, err = pcall(b.fn)
                    if not ok then
                        Log.error(
                            "InputRouter binding '"
                                .. tostring(b.description)
                                .. "' in '"
                                .. tostring(h.name)
                                .. "' failed: "
                                .. tostring(err)
                        )
                    end
                    return true
                end
            end
        end
        if h.capturesAllInput then
            -- Barrier handlers may name specific keys that should fall
            -- through to the engine despite the swallow (e.g. Baseline
            -- passes F-row and Escape so advisor screens and the pause
            -- menu remain reachable on the map). Matches on keycode only;
            -- modifier chords (Ctrl+F10, Ctrl+F11) pass through alongside
            -- plain F10 / F11.
            if h.passthroughKeys ~= nil and h.passthroughKeys[keyCode] then
                return false
            end
            return true
        end
    end
    return false
end

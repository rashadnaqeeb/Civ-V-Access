-- Dispatches keyboard events down the HandlerStack, top-first. Stateless.
-- Called from each screen's SetInputHandler (via BaseMenu.install for
-- front-end screens, directly from in-game handlers).
--
-- Pre-walk hooks (run before the binding walk):
--   1. Ctrl+Shift+F12 toggles the hotseat hard-mute. Runs first so the
--      toggle works in both states; on enter-mute it cuts in-flight speech
--      and short-circuits all subsequent dispatch (no Help, no Settings,
--      no search, no bindings) so the sighted player's keys reach the
--      engine. HandlerStack push/pop continue normally so the stack stays
--      consistent for unmute.
--   2. Shift+? opens the Help overlay built from HandlerStack.collectHelpEntries.
--      Gated so pressing ? while Help is on top doesn't re-enter.
--   3. F12 opens the Settings overlay. Gated so the in-menu close binding
--      can fire when Settings is already on top.
--   4. Type-ahead search: if the top handler exposes handleSearchInput, route
--      printable / Backspace / Space through it so every BaseMenu-backed
--      handler (installed or pushed directly) gets search without needing 40+
--      per-letter bindings.

InputRouter = {}

civvaccess_shared = civvaccess_shared or {}

-- Test seam for the debounce clock. Production reads os.clock; tests
-- swap this to a controllable source so they can drive key-repeat scenarios
-- without sleeping.
InputRouter._timeSource = os.clock

local _lastMuteToggleTime = -math.huge
-- Windows default key-repeat rate is ~30/s (33ms). 0.2s blocks a held
-- chord from flipping mute back and forth (the failure mode is silent --
-- a stuck-muted mod has no way to announce that it's stuck) while still
-- accepting an intentional re-press.
local MUTE_TOGGLE_DEBOUNCE_SECONDS = 0.2

local WM_KEYDOWN = 256
local WM_SYSKEYDOWN = 260

local MOD_SHIFT = 1
local MOD_CTRL = 2
local MOD_ALT = 4

-- Windows VK for the US '/?' key. Shift+OEM_2 is what the user types to
-- mean '?'. Non-US layouts produce '?' via a different VK; revisit if we
-- localize the help hotkey.
local VK_OEM_2 = 191
local VK_F12 = 123

-- Numpad-to-letter mirror for the Q/W/E/A/S/D/Z/X/C cluster. With NumLock
-- on, every cluster key has a numpad twin in the same physical 3x3 layout
-- (S=5 anchors the center, the rest fall out around it). Dispatch retries
-- the binding walk with the mapped letter when a numpad keycode produced
-- no match, so every existing letter binding -- plain, Shift, Ctrl, Alt
-- -- gets the numpad alias for free without each handler having to enumerate
-- both keys. NumberEntry binds VK_NUMPAD0..9 directly and wins on the first
-- pass, so the mirror never shadows digit entry.
local NUMPAD_MIRROR = {
    [Keys.VK_NUMPAD7] = Keys.Q,
    [Keys.VK_NUMPAD8] = Keys.W,
    [Keys.VK_NUMPAD9] = Keys.E,
    [Keys.VK_NUMPAD4] = Keys.A,
    [Keys.VK_NUMPAD5] = Keys.S,
    [Keys.VK_NUMPAD6] = Keys.D,
    [Keys.VK_NUMPAD1] = Keys.Z,
    [Keys.VK_NUMPAD2] = Keys.X,
    [Keys.VK_NUMPAD3] = Keys.C,
}

-- Windows substitutes a numpad keypress with its navigation VK when Shift
-- is held with NumLock on, OR when NumLock is off and no modifier toggles
-- it back. Either way, the engine sees the nav VK (VK_END for Numpad1,
-- VK_CLEAR for Numpad5, etc.) and NUMPAD_MIRROR never gets a chance --
-- the user's Shift+Numpad press lands on a key the binding walk doesn't
-- recognize. Rewrite the nav VK back to its numpad twin so NUMPAD_MIRROR
-- can carry it, gated by the extended-key bit (see isNumpadOrigin below)
-- so dedicated Home / End / PgUp / PgDn / arrows / Insert / Delete on
-- the nav cluster are untouched.
--
-- Hardcoded numeric VKs because Civ V's Keys table doesn't reliably expose
-- VK_CLEAR (12) or VK_INSERT (45) -- base UI never references them, so a
-- table literal keyed on Keys.VK_CLEAR would NaN at load time on engines
-- where the field is absent. Numeric form sidesteps that and matches the
-- form used elsewhere when a Keys.* alias would be brittle.
local NAV_TO_NUMPAD = {
    [45] = Keys.VK_NUMPAD0, -- VK_INSERT  -> Numpad0
    [35] = Keys.VK_NUMPAD1, -- VK_END     -> Numpad1
    [40] = Keys.VK_NUMPAD2, -- VK_DOWN    -> Numpad2
    [34] = Keys.VK_NUMPAD3, -- VK_NEXT    -> Numpad3 (PgDn)
    [37] = Keys.VK_NUMPAD4, -- VK_LEFT    -> Numpad4
    [12] = Keys.VK_NUMPAD5, -- VK_CLEAR   -> Numpad5
    [39] = Keys.VK_NUMPAD6, -- VK_RIGHT   -> Numpad6
    [36] = Keys.VK_NUMPAD7, -- VK_HOME    -> Numpad7
    [38] = Keys.VK_NUMPAD8, -- VK_UP      -> Numpad8
    [33] = Keys.VK_NUMPAD9, -- VK_PRIOR   -> Numpad9 (PgUp)
}

-- bit 24 of WM_KEYDOWN's lParam is the extended-key flag. Win32 sets it
-- for the dedicated nav cluster (Home / End / PgUp / PgDn / arrows /
-- Insert / Delete on the cluster between the main block and numpad) and
-- clears it for the numpad-origin substitutions. Modulo math handles
-- signed-32-bit lp arriving with bit 31 set (negative in Lua) by
-- normalizing to the unsigned representation before the comparison.
local LPARAM_EXTENDED_KEY_BIT = 0x01000000

local function isNumpadOrigin(lp)
    if lp == nil then
        return false
    end
    return (lp % 0x02000000) < LPARAM_EXTENDED_KEY_BIT
end

-- Modifier state for the current dispatch. Reads through civvaccess_keys
-- (proxy-exposed GetAsyncKeyState wrappers) when present so the Shift bit
-- survives Windows' synthesized Shift-release around Shift+Numpad presses
-- with NumLock on -- UI.ShiftKeyDown wraps the engine's WM-stream tracker,
-- which sees the synthesized release and reports Shift = false during the
-- numpad keydown even though the player is still holding it. Falls back to
-- UI.*KeyDown so a Lua-only update against an old proxy still limps.
function InputRouter.currentModifierMask()
    local mask = 0
    local keys = civvaccess_keys
    if keys ~= nil then
        if keys.isShiftDown() then
            mask = mask + MOD_SHIFT
        end
        if keys.isCtrlDown() then
            mask = mask + MOD_CTRL
        end
        if keys.isAltDown() then
            mask = mask + MOD_ALT
        end
        return mask
    end
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

-- Walk the HandlerStack top-to-bottom looking for a binding that matches
-- (keyCode, modMask). Returns (fired, consumed):
--   fired=true,  consumed=true   a binding ran.
--   fired=false, consumed=true   a capturesAllInput barrier ate the key
--                                without a binding match (no passthrough).
--   fired=false, consumed=false  the key passed through (barrier passthrough,
--                                or no barrier on the stack).
-- Factored so dispatch can run a second pass with a numpad-mirrored keycode
-- without duplicating the loop. passthroughKeys is checked against the
-- ORIGINAL keycode at the call site -- a numpad mirror should not change
-- whether the engine sees the press.
local function walkBindings(keyCode, modMask)
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
                    return true, true
                end
            end
        end
        if h.capturesAllInput then
            if h.passthroughKeys ~= nil and h.passthroughKeys[keyCode] then
                return false, false
            end
            return false, true
        end
    end
    return false, false
end

-- Invariant: a binding's fn may push or pop handlers, but walkBindings bails
-- the moment any binding fires, so the walk never sees a mutated stack
-- under its own feet. Bindings that intend to keep the walk going after
-- mutating the stack are not supported; add a new primitive before trying.
function InputRouter.dispatch(keyCode, modMask, msg, lp)
    if msg ~= WM_KEYDOWN and msg ~= WM_SYSKEYDOWN then
        return false
    end

    -- Rewrite Windows-substituted nav VKs back to their numpad twin so
    -- NUMPAD_MIRROR carries the press. See NAV_TO_NUMPAD / isNumpadOrigin
    -- for the discriminator that keeps dedicated nav-cluster presses
    -- untouched. Done before the early hotkey checks below because none
    -- of them (Ctrl+Shift+F12, Shift+?, F12, type-ahead) bind a key in
    -- NAV_TO_NUMPAD, so the rewrite can't shadow them.
    local origKeyCode = keyCode
    local navMapped = NAV_TO_NUMPAD[keyCode]
    local navRewrote = false
    if navMapped ~= nil and isNumpadOrigin(lp) then
        keyCode = navMapped
        navRewrote = true
    end

    -- TEMP diagnosis for Shift+Numpad (Windows substitutes the nav VK
    -- when Shift is held with NumLock on, and we rewrite it above).
    -- Logs the raw keycode, the post-rewrite keycode, modifier mask,
    -- the raw lParam, and whether the nav-to-numpad rewrite fired so
    -- the player log shows the dispatch chain end-to-end. Remove after
    -- a tester confirms the fix.
    Log.info(
        "InputRouter.dispatch origKc="
            .. tostring(origKeyCode)
            .. " kc="
            .. tostring(keyCode)
            .. " modMask="
            .. tostring(modMask)
            .. " msg="
            .. tostring(msg)
            .. " lp="
            .. tostring(lp)
            .. " navRewrote="
            .. tostring(navRewrote)
    )

    -- Drop any handlers whose owning Context env got wiped (front-end
    -- skin unload during pre-game-to-in-game, in-game env wipe on load-
    -- game-from-game). Boot.onInGameBoot purges these at LoadScreenClose
    -- too, but the engine's exact wipe timing relative to LoadScreenClose
    -- isn't guaranteed -- if the wipe lands later, a stranded handler with
    -- capturesAllInput=true sits on top of Baseline / Scanner and consumes
    -- every key into a failing pcall, no-op'ing the whole map.
    HandlerStack.purgeDeadEnv()

    -- Order matters in both directions: the pause announcement speaks
    -- BEFORE the flag flips (otherwise SpeechPipeline's gate swallows it
    -- and there's no audible confirmation the toggle worked); the resume
    -- announcement speaks AFTER the flag clears (same reason). Tolk takes
    -- the text synchronously and plays it asynchronously, so the pause
    -- announcement reaches the screen reader before mute takes effect.
    if keyCode == VK_F12 and modMask == (MOD_CTRL + MOD_SHIFT) then
        local now = InputRouter._timeSource()
        if (now - _lastMuteToggleTime) < MUTE_TOGGLE_DEBOUNCE_SECONDS then
            return true
        end
        _lastMuteToggleTime = now
        if civvaccess_shared.muted then
            civvaccess_shared.muted = false
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_MUTE_RESUMED"))
        else
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_MUTE_PAUSED"))
            civvaccess_shared.muted = true
        end
        return true
    end

    if civvaccess_shared.muted then
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

    -- Settings overlay hotkey. Same shape as the Help hook above. Skips
    -- when Settings is already on top so the menu's own F12-close binding
    -- can fire and toggle the overlay off.
    if keyCode == VK_F12 and modMask == 0 then
        local top = HandlerStack.active()
        if top == nil or top.name ~= "Settings" then
            if Settings ~= nil and type(Settings.open) == "function" then
                local ok, err = pcall(Settings.open)
                if not ok then
                    Log.error("InputRouter: Settings.open failed: " .. tostring(err))
                end
            else
                Log.warn("InputRouter: F12 pressed but Settings module not loaded")
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

    -- First pass: original keycode. Barrier passthroughKeys are checked
    -- here against the literal keycode the user pressed. Comment on
    -- passthrough behavior: matches on keycode only -- modifier chords
    -- (Ctrl+F10, Ctrl+F11) pass through alongside plain F10 / F11 without
    -- a per-chord entry.
    local fired, consumed = walkBindings(keyCode, modMask)
    if fired then
        return true
    end

    -- Second pass: numpad-mirrored letter. Only when the first pass found
    -- nothing -- so a handler that explicitly binds VK_NUMPAD0..9 (NumberEntry)
    -- still wins. Dispatches with the mapped keycode so every modifier-
    -- specific binding (plain, Shift, Ctrl, Alt) on Q/W/E/A/S/D/Z/X/C
    -- picks up its numpad twin without each handler having to enumerate
    -- the pair.
    local mapped = NUMPAD_MIRROR[keyCode]
    if mapped ~= nil then
        local fired2 = walkBindings(mapped, modMask)
        if fired2 then
            return true
        end
    end

    return consumed
end

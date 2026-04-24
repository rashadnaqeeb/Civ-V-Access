-- Routes the in-game cursor keys (Q/A/Z/E/D/C movement, S orient, W
-- economy, X combat) to the Cursor module, plus the Shift-letter
-- surveyor cluster to SurveyorCore. Sits at the bottom of the
-- HandlerStack so any popup / overlay above it that sets capturesAllInput
-- will pre-empt both clusters without us having to coordinate.
--
-- capturesAllInput = true: Baseline eats every unbound key on the map.
-- The mod reimplements every map-mode action we expose to the user, so
-- letting the engine's huge mission / build / automate key set fire under
-- us would be noise (keys that pick up different meanings depending on
-- the selected unit are impossible to speak consistently). passthroughKeys
-- carves out the minimum set we explicitly want the engine to still
-- handle: F1-F12 (advisor screens, strategic view, quick save/load,
-- Ctrl+F10 select capital, Ctrl+F11 quick load all hang off F-row
-- keycodes) and Escape (opens the pause menu, which our GameMenuAccess
-- then layers over). Popups above Baseline set their own capturesAllInput
-- without a passthrough list, so F-keys and Escape are correctly
-- swallowed while any dialog or menu is up.
--
-- F10 is both passed through AND bound: the plain-F10 binding wins at the
-- bindings-loop stage (InputRouter matches key + mods) and fires the
-- advisor counsel popup, overriding the engine's strategic-view toggle
-- which is useless to blind players. Ctrl+F10 has no mods=2 binding here
-- so it falls through the bindings loop, hits the passthrough check on
-- keycode alone, and reaches the engine's select-capital binding intact.
-- Rebinding F10 is the accessibility path because the engine's native
-- hotkey for advisor counsel is KB_V, which Baseline swallows as an
-- unbound letter.

BaselineHandler = {}

local MOD_NONE = 0
local MOD_SHIFT = 1
local MOD_CTRL = 2

local function speak(s)
    if s == nil or s == "" then
        return
    end
    SpeechPipeline.speakInterrupt(s)
end

local bind = HandlerStack.bind

-- Each cursor binding wraps the cursor call so the HandlerStack table only
-- ever sees a no-arg function. Direction is hard-coded per binding because
-- there are six -- a single dispatch table would cost more than the six
-- explicit closures and lose grep-ability.
local function moveDir(dir)
    return function()
        speak(Cursor.move(dir))
    end
end

function BaselineHandler.create()
    local bindings = {
        -- In Civ V's Keys enum, printable ASCII keys (letters and top-row
        -- digits) are registered under their literal character. Letters are
        -- valid Lua identifiers so `Keys.Q` works; digits aren't, so the
        -- top-row number keys require bracket form: `Keys["1"]`. Only the
        -- non-printable / special keys use the VK_ prefix (VK_ESCAPE, VK_LEFT,
        -- VK_NUMPAD1, etc.).
        bind(Keys.Q, MOD_NONE, moveDir(DirectionTypes.DIRECTION_NORTHWEST), "Move cursor NW"),
        bind(Keys.E, MOD_NONE, moveDir(DirectionTypes.DIRECTION_NORTHEAST), "Move cursor NE"),
        bind(Keys.A, MOD_NONE, moveDir(DirectionTypes.DIRECTION_WEST), "Move cursor W"),
        bind(Keys.D, MOD_NONE, moveDir(DirectionTypes.DIRECTION_EAST), "Move cursor E"),
        bind(Keys.Z, MOD_NONE, moveDir(DirectionTypes.DIRECTION_SOUTHWEST), "Move cursor SW"),
        bind(Keys.C, MOD_NONE, moveDir(DirectionTypes.DIRECTION_SOUTHEAST), "Move cursor SE"),
        bind(Keys.S, MOD_NONE, function()
            speak(Cursor.unitAtTile())
        end, "Read unit on tile"),
        bind(Keys.S, MOD_SHIFT, function()
            speak(Cursor.orient())
        end, "Orient from capital"),
        bind(Keys.W, MOD_NONE, function()
            speak(Cursor.economy())
        end, "Economy details"),
        bind(Keys.X, MOD_NONE, function()
            speak(Cursor.combat())
        end, "Combat details"),
        bind(Keys["1"], MOD_NONE, function()
            speak(Cursor.cityIdentity())
        end, "City identity and combat"),
        bind(Keys["2"], MOD_NONE, function()
            speak(Cursor.cityDevelopment())
        end, "City production and growth"),
        bind(Keys["3"], MOD_NONE, function()
            speak(Cursor.cityPolitics())
        end, "City diplomacy"),
        bind(Keys.VK_RETURN, MOD_NONE, function()
            Cursor.activate()
        end, "Activate tile"),
        bind(Keys.VK_F10, MOD_NONE, function()
            -- Engine's native hotkey for this popup is KB_V, which Baseline
            -- swallows as an unbound letter; F10 (strategic view) is
            -- repurposed since blind players have no use for the visual
            -- toggle. Data1 = 1 asks the popup to queue at InGameUtmost
            -- priority and toggle-close if already visible.
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_ADVISOR_COUNSEL,
                Data1 = 1,
            })
        end, "Open advisor counsel"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ORIENT",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ORIENT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_POL",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_POL",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY",
            description = "TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC",
        },
    }
    local surveyor = SurveyorCore.getBindings()
    for _, b in ipairs(surveyor.bindings) do
        bindings[#bindings + 1] = b
    end
    for _, h in ipairs(surveyor.helpEntries) do
        helpEntries[#helpEntries + 1] = h
    end
    local unitControl = UnitControl.getBindings()
    for _, b in ipairs(unitControl.bindings) do
        bindings[#bindings + 1] = b
    end
    for _, h in ipairs(unitControl.helpEntries) do
        helpEntries[#helpEntries + 1] = h
    end
    local turn = Turn.getBindings()
    for _, b in ipairs(turn.bindings) do
        bindings[#bindings + 1] = b
    end
    for _, h in ipairs(turn.helpEntries) do
        helpEntries[#helpEntries + 1] = h
    end
    local passthroughKeys = {
        [Keys.VK_F1] = true,
        [Keys.VK_F2] = true,
        [Keys.VK_F3] = true,
        [Keys.VK_F4] = true,
        [Keys.VK_F5] = true,
        [Keys.VK_F6] = true,
        [Keys.VK_F7] = true,
        [Keys.VK_F8] = true,
        [Keys.VK_F9] = true,
        [Keys.VK_F10] = true,
        [Keys.VK_F11] = true,
        [Keys.VK_F12] = true,
        [Keys.VK_ESCAPE] = true,
    }
    return {
        name = "Baseline",
        capturesAllInput = true,
        passthroughKeys = passthroughKeys,
        bindings = bindings,
        helpEntries = helpEntries,
    }
end

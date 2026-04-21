-- Routes the in-game cursor keys (Q/A/Z/E/D/C movement, S orient, W
-- economy, X combat) to the Cursor module, plus the Shift-letter
-- surveyor cluster to SurveyorCore. Sits at the bottom of the
-- HandlerStack so any popup / overlay above it that sets capturesAllInput
-- will pre-empt both clusters without us having to coordinate.

BaselineHandler = {}

local MOD_NONE = 0

local function speak(s)
    if s == nil or s == "" then
        return
    end
    SpeechPipeline.speakInterrupt(s)
end

local function bind(key, mods, action, description)
    return { key = key, mods = mods, fn = action, description = description }
end

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
        -- Letter keys in Civ V's Keys enum are `Keys.<letter>` (no VK_
        -- prefix); only special keys use VK_ (VK_LEFT, VK_ESCAPE, etc.).
        bind(Keys.Q, MOD_NONE, moveDir(DirectionTypes.DIRECTION_NORTHWEST), "Move cursor NW"),
        bind(Keys.E, MOD_NONE, moveDir(DirectionTypes.DIRECTION_NORTHEAST), "Move cursor NE"),
        bind(Keys.A, MOD_NONE, moveDir(DirectionTypes.DIRECTION_WEST), "Move cursor W"),
        bind(Keys.D, MOD_NONE, moveDir(DirectionTypes.DIRECTION_EAST), "Move cursor E"),
        bind(Keys.Z, MOD_NONE, moveDir(DirectionTypes.DIRECTION_SOUTHWEST), "Move cursor SW"),
        bind(Keys.C, MOD_NONE, moveDir(DirectionTypes.DIRECTION_SOUTHEAST), "Move cursor SE"),
        bind(Keys.S, MOD_NONE, function()
            speak(Cursor.orient())
        end, "Orient from capital"),
        bind(Keys.W, MOD_NONE, function()
            speak(Cursor.economy())
        end, "Economy details"),
        bind(Keys.X, MOD_NONE, function()
            speak(Cursor.combat())
        end, "Combat details"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE",
            description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE",
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
    return {
        name = "Baseline",
        capturesAllInput = false,
        bindings = bindings,
        helpEntries = helpEntries,
    }
end

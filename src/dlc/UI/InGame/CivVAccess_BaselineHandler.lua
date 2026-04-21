-- Routes the in-game cursor keys (Q/A/Z/E/D/C movement, S orient, W
-- economy, X combat) to the Cursor module, plus the Shift-letter
-- surveyor cluster to SurveyorCore. Sits at the bottom of the
-- HandlerStack so any popup / overlay above it that sets capturesAllInput
-- will pre-empt both clusters without us having to coordinate.

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
        -- Letter keys in Civ V's Keys enum are `Keys.<letter>` (no VK_
        -- prefix); only special keys use VK_ (VK_LEFT, VK_ESCAPE, etc.).
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
        bind(Keys.VK_1, MOD_NONE, function()
            speak(Cursor.cityIdentity())
        end, "City identity and combat"),
        bind(Keys.VK_2, MOD_NONE, function()
            speak(Cursor.cityDevelopment())
        end, "City production and growth"),
        bind(Keys.VK_3, MOD_NONE, function()
            speak(Cursor.cityPolitics())
        end, "City diplomacy"),
        bind(Keys.N, MOD_CTRL, function()
            -- Data1 = 1 asks the popup to queue at InGameUtmost priority and
            -- toggle-close if already visible; any other value falls back to
            -- its lower NotificationLog priority and loses the toggle path.
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_NOTIFICATION_LOG,
                Data1 = 1,
            })
        end, "Open notification log"),
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
            keyLabel = "TXT_KEY_CIVVACCESS_NOTIFICATION_HELP_KEY_OPEN",
            description = "TXT_KEY_CIVVACCESS_NOTIFICATION_HELP_DESC_OPEN",
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

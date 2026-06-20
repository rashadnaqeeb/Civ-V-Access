-- Move sub-mode for a focused squad. Entered from the map layer's Alt+Up.
-- Shaped like UnitTargetMode but lighter: capturesAllInput = false so the
-- cursor still roams the map (Q/A/Z/E/D/C and the info queries fall through
-- to Baseline), and the only job is picking a destination plot for the whole
-- squad. Space previews the turns to the cursor plot, Enter commits the
-- squad move with the squad's escort setting, Esc cancels.
--
-- The squad is addressed through any one of its live members (the engine
-- command channel rides on a unit). Membership is re-read on every Space /
-- Enter rather than captured at entry, so a member dying mid-pick doesn't
-- strand a dead handle; an emptied squad reads as having no units.

SquadMoveMode = {}

local MOD_NONE = 0

local speak = SpeechPipeline.speakInterrupt
local bind = HandlerStack.bind

local function cursorPlot()
    local cx, cy = Cursor.position()
    if cx == nil then
        return nil
    end
    return Map.GetPlot(cx, cy)
end

-- A live member to use as the squad's command handle, or nil when the squad
-- is empty.
local function repMember(num)
    local m = EngineData.squadMembers(Players[Game.GetActivePlayer()], num)
    return m[1]
end

local function pop()
    HandlerStack.removeByName("SquadMoveMode", false)
end

function SquadMoveMode.enter(num)
    if num == nil then
        return
    end
    local self = {
        name = "SquadMoveMode",
        capturesAllInput = false,
        -- Cursor stays live on the world map during the pick; keep beacons
        -- playing under us the way the unit target pickers do.
        beaconsTransparent = true,
        _squadNum = num,
    }
    self.bindings = {
        bind(Keys.VK_SPACE, MOD_NONE, function()
            local plot = cursorPlot()
            if plot == nil then
                return
            end
            local rep = repMember(num)
            if rep == nil then
                speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"))
                return
            end
            speak(SquadSpeech.movePreview(rep, plot))
        end, "Preview squad move"),
        bind(Keys.VK_RETURN, MOD_NONE, function()
            local plot = cursorPlot()
            if plot == nil then
                speak(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
                return
            end
            local rep = repMember(num)
            if rep == nil then
                speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"))
                return
            end
            EngineData.moveSquad(rep, plot, SquadRoster.getEscort(num))
            pop()
            speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_MOVE_ORDERED", SquadRoster.getName(num)))
        end, "Commit squad move"),
        bind(Keys.VK_ESCAPE, MOD_NONE, function()
            pop()
            speak(Text.key("TXT_KEY_CIVVACCESS_CANCELED"))
        end, "Cancel squad move"),
    }
    self.helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_PREVIEW",
            description = "TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_PREVIEW",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_COMMIT",
            description = "TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_COMMIT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_CANCEL",
            description = "TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_CANCEL",
        },
    }
    -- Speak the squad name on entry: the action keys carry the confirmation
    -- that the silent Up/Down scan omits, so entering move mode is where the
    -- player hears which squad they are commanding.
    self.onActivate = function()
        speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_MOVE_MODE", SquadRoster.getName(num)))
    end
    HandlerStack.push(self)
end

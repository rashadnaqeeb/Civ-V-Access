-- Text-capture handler pushed on top of ScannerHandler when the user
-- presses Ctrl+F. Every printable keystroke appends to an internal
-- buffer and speaks it so the user hears what they've typed; Enter
-- commits the query, Escape cancels.
--
-- Driven by InputRouter's handleSearchInput hook -- the same pre-walk
-- path BaseMenu's type-ahead uses -- so no per-letter bindings table is
-- needed. capturesAllInput=true stops any key we don't consume from
-- falling through into ScannerHandler's cycle bindings during a typed
-- query.

ScannerInput = {}

local WM_SHIFT_MASK = 1

local function charForLetter(vk)
    if vk >= 0x41 and vk <= 0x5A then return string.char(vk + 32) end
    return nil
end

local function charForDigit(vk)
    if vk >= 0x30 and vk <= 0x39 then return string.char(vk) end
    return nil
end

function ScannerInput.create()
    local self = {
        name             = "ScannerInput",
        capturesAllInput = true,
        -- No bindings table: every key goes through handleSearchInput
        -- so the modal capture is all in one place.
        bindings         = {},
        helpEntries      = {},
        _buffer          = "",
    }

    local function speak(s)
        if s == nil or s == "" then return end
        SpeechPipeline.speakInterrupt(s)
    end

    local function pop()
        HandlerStack.removeByName("ScannerInput")
    end

    function self:handleSearchInput(vk, mods)
        -- Commit query.
        if vk == Keys.VK_RETURN then
            local query = self._buffer
            pop()
            speak(ScannerNav.applySearch(query))
            return true
        end
        if vk == Keys.VK_ESCAPE then
            pop()
            return true
        end
        if vk == Keys.VK_BACK then
            if #self._buffer == 0 then return true end
            self._buffer = string.sub(self._buffer, 1, -2)
            if #self._buffer == 0 then
                speak(Text.key("TXT_KEY_CIVVACCESS_SCANNER_SEARCH_CLEARED"))
            else
                speak(self._buffer)
            end
            return true
        end
        if vk == Keys.VK_SPACE then
            if #self._buffer == 0 then return true end
            self._buffer = self._buffer .. " "
            speak(self._buffer)
            return true
        end
        -- Letters: case-insensitive match; lowercase in buffer for
        -- consistent TypeAheadSearch behaviour at commit time.
        local ch = charForLetter(vk) or charForDigit(vk)
        if ch ~= nil then
            self._buffer = self._buffer .. ch
            speak(self._buffer)
            return true
        end
        return false
    end

    return self
end

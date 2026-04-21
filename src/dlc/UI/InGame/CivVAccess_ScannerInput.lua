-- Text-capture handler pushed on top of ScannerHandler when the user
-- presses Ctrl+F. Printable keystrokes append to an internal buffer
-- silently; the user's screen reader provides typing echo. Enter
-- commits the query and speaks the result, Escape cancels.
--
-- Driven by InputRouter's handleSearchInput hook -- the same pre-walk
-- path BaseMenu's type-ahead uses -- so no per-letter bindings table is
-- needed. capturesAllInput=true stops any key we don't consume from
-- falling through into ScannerHandler's cycle bindings during a typed
-- query.

ScannerInput = {}

local function charForLetter(vk)
    if vk >= 0x41 and vk <= 0x5A then
        return string.char(vk + 32)
    end
    return nil
end

local function charForDigit(vk)
    if vk >= 0x30 and vk <= 0x39 then
        return string.char(vk)
    end
    return nil
end

function ScannerInput.create()
    local self = {
        name = "ScannerInput",
        capturesAllInput = true,
        -- No bindings table: every key goes through handleSearchInput
        -- so the modal capture is all in one place.
        bindings = {},
        helpEntries = {},
        _buffer = "",
    }

    local function speak(s)
        if s == nil or s == "" then
            return
        end
        SpeechPipeline.speakInterrupt(s)
    end

    local function pop()
        HandlerStack.removeByName("ScannerInput")
    end

    function self.handleSearchInput(me, vk, mods)
        -- Commit query.
        if vk == Keys.VK_RETURN then
            local query = me._buffer
            pop()
            speak(ScannerNav.applySearch(query))
            return true
        end
        if vk == Keys.VK_ESCAPE then
            pop()
            return true
        end
        if vk == Keys.VK_BACK then
            if #me._buffer == 0 then
                return true
            end
            me._buffer = string.sub(me._buffer, 1, -2)
            return true
        end
        if vk == Keys.VK_SPACE then
            if #me._buffer == 0 then
                return true
            end
            me._buffer = me._buffer .. " "
            return true
        end
        -- Letters: case-insensitive match; lowercase in buffer for
        -- consistent TypeAheadSearch behaviour at commit time.
        local ch = charForLetter(vk) or charForDigit(vk)
        if ch ~= nil then
            me._buffer = me._buffer .. ch
            return true
        end
        return false
    end

    return self
end

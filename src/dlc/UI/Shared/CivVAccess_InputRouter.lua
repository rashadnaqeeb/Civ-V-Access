-- Dispatches keyboard events down the HandlerStack, top-first. Stateless.
-- Called from each screen's SetInputHandler (via BaseMenu.install for
-- front-end screens, directly from in-game handlers).

InputRouter = {}

local WM_KEYDOWN    = 256
local WM_SYSKEYDOWN = 260

local MOD_SHIFT = 1
local MOD_CTRL  = 2
local MOD_ALT   = 4

function InputRouter.currentModifierMask()
    local mask = 0
    if UI.ShiftKeyDown() then mask = mask + MOD_SHIFT end
    if UI.CtrlKeyDown()  then mask = mask + MOD_CTRL  end
    if UI.AltKeyDown()   then mask = mask + MOD_ALT   end
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
    for i = HandlerStack.count(), 1, -1 do
        local h = HandlerStack.at(i)
        local bindings = h.bindings
        if type(bindings) == "table" then
            for _, b in ipairs(bindings) do
                if b.key == keyCode and (b.mods or 0) == modMask then
                    local ok, err = pcall(b.fn)
                    if not ok then
                        Log.error("InputRouter binding '" .. tostring(b.description)
                            .. "' in '" .. tostring(h.name) .. "' failed: " .. tostring(err))
                    end
                    return true
                end
            end
        end
        if h.capturesAllInput then
            return true
        end
    end
    return false
end

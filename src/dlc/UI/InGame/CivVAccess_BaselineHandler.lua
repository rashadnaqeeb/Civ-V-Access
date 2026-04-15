-- No-op handler pushed at boot so HandlerStack.active() is never nil.
-- Real world-view functionality (plot cursor, next turn, read tile) lands
-- in the followup plan.

BaselineHandler = {}

function BaselineHandler.create()
    return {
        name = "Baseline",
        capturesAllInput = false,
        bindings = {},
    }
end

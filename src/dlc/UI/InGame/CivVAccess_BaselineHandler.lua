-- No-op handler pushed at boot so HandlerStack.active() is never nil.
-- Real world-view functionality (plot cursor, next turn, read tile) lands
-- in the followup plan.

BaselineHandler = {}

function BaselineHandler.create()
    return {
        name = "Baseline",
        capturesAllInput = false,
        bindings = {},
        -- Explicit empty: Baseline has no user-visible bindings, but the
        -- push-time help audit expects every handler to declare a list.
        helpEntries = {},
    }
end

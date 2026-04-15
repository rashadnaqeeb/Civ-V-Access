-- BaselineHandler is a tiny constructor; one test covers the shape.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/InGame/CivVAccess_BaselineHandler.lua")
end

function M.test_create_returns_noop_shape()
    setup()
    local h = BaselineHandler.create()
    T.eq(h.name, "Baseline")
    T.eq(h.capturesAllInput, false)
    T.eq(type(h.bindings), "table")
    T.eq(#h.bindings, 0)
    T.eq(h.onActivate, nil)
    T.eq(h.onDeactivate, nil)
end

return M

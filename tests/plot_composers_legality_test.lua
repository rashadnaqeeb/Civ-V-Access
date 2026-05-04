-- Tests for PlotComposers.legalityPreview, the per-target Space readout
-- shared by every targeted-action picker (airlift, paradrop, nuke, gift
-- unit, gift improvement, embark, disembark, rebase). The function
-- branches three ways: illegal -> illegalKey text, legal with legalText
-- -> legalText verbatim, legal without legalText -> fall through to the
-- plot's glance. Glance fallback is the legacy embark/disembark/rebase
-- contract; the legalText path was added so action-affirming previews
-- ("airlift here", "gift Warrior to Vilnius") could replace the cursor
-- glance the user already heard during navigation.
--
-- The function is small and pure modulo the glance call, so this suite
-- monkey-patches PlotComposers.glance per case rather than dragging in
-- the full section chain. That lets each branch be exercised in
-- isolation without any plot fixture beyond a sentinel value to thread
-- through to the glance stub.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotComposers.lua")
end

function M.test_illegal_returns_illegalKey_text()
    setup()
    -- Stub glance so a regression that reaches it (instead of the early
    -- illegal return) shows up as a wrong-string assertion below.
    PlotComposers.glance = function()
        return "GLANCE_STUB"
    end
    local out = PlotComposers.legalityPreview(false, "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL", {}, "ignored")
    T.eq(out, "cannot airlift here")
end

function M.test_legal_with_legalText_returns_legalText_verbatim()
    setup()
    PlotComposers.glance = function()
        error("glance must not be called when legalText is supplied")
    end
    local out = PlotComposers.legalityPreview(true, "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL", {}, "airlift here")
    T.eq(out, "airlift here")
end

function M.test_legal_without_legalText_falls_through_to_glance()
    setup()
    local capturedPlot
    PlotComposers.glance = function(plot)
        capturedPlot = plot
        return "Berlin, capital, plains"
    end
    local sentinelPlot = { _id = "sentinel" }
    local out =
        PlotComposers.legalityPreview(true, "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL", sentinelPlot, nil)
    T.eq(out, "Berlin, capital, plains")
    T.eq(capturedPlot, sentinelPlot, "glance must receive the plot the caller passed")
end

function M.test_legal_glance_empty_returns_EMPTY_key()
    setup()
    PlotComposers.glance = function()
        return ""
    end
    local out = PlotComposers.legalityPreview(true, "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL", {}, nil)
    T.eq(out, "no target here")
end

function M.test_legal_glance_nil_returns_EMPTY_key()
    setup()
    PlotComposers.glance = function()
        return nil
    end
    local out = PlotComposers.legalityPreview(true, "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL", {}, nil)
    T.eq(out, "no target here")
end

return M

-- ForeignClearWatch: counter-driven flush at turn boundaries. Tests
-- exercise visibility and teammate filters, the singular / plural / both
-- string shapes, the F7 delta + speech-gate split, and the bracket-buffer
-- push category.

local T = require("support")
local M = {}

-- ===== Fixture builders =====

local function visiblePlot(x, y)
    return T.fakePlot({ x = x, y = y, visible = true })
end

local function fogPlot(x, y)
    return T.fakePlot({ x = x, y = y, visible = false })
end

-- Install a plot at (x, y) so Map.GetPlot(x, y) returns it.
local function installPlots(plots)
    Map.GetPlot = function(x, y)
        for _, p in ipairs(plots) do
            if p:GetX() == x and p:GetY() == y then
                return p
            end
        end
        return nil
    end
end

-- ===== Test setup =====

local spoken

local function setup()
    -- Active player slot 0 on team 0. Foreign players sit at 1+ on
    -- distinct teams unless a test overrides.
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Players = {}
    Players[0] = T.fakePlayer({ team = 0 })

    civvaccess_shared = {
        foreignClearWatchAnnounce = true,
    }

    Events = {
        ActivePlayerTurnEnd = { Add = function(_) end },
        ActivePlayerTurnStart = { Add = function(_) end },
    }
    GameEvents = {
        CivVAccessForeignBarbCampCleared = { Add = function(_) end },
        CivVAccessForeignGoodyCleared = { Add = function(_) end },
    }

    -- Load the real SpeechPipeline + TextFilter and patch the lower
    -- _speakAction seam so assertions go through the production filter +
    -- gating path. spoken is repopulated on every setup() call.
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()

    -- Real Text + MessageBuffer + ForeignClearWatch. Text.formatPlural
    -- runs against the en_US bundle loaded by run.lua, so plural form
    -- selection is exercised end-to-end.
    PluralRules._setLocale("en_US")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    -- Reset module before reload so installListeners runs fresh.
    ForeignClearWatch = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ForeignClearWatch.lua")
end

local function installForeign(slot, opts)
    opts = opts or {}
    Players[slot] = T.fakePlayer({ team = opts.team or slot })
end

-- ===== Tests =====

function M.test_no_clears_no_announce()
    setup()
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onTurnStart()
    T.eq(#spoken, 0, "no speech when no clears happened")
    T.eq(civvaccess_shared.foreignClearDelta, nil, "delta cleared when no clears")
end

function M.test_visible_camp_cleared_by_foreign_counts()
    setup()
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(#spoken, 1)
    T.eq(spoken[1].interrupt, false, "all clears queue")
    T.eq(spoken[1].text, "Someone else has claimed 1 visible barbarian camp.")
end

function M.test_visible_ruin_cleared_by_foreign_counts()
    setup()
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignGoodyCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(spoken[1].text, "Someone else has claimed 1 visible ancient ruin.")
end

function M.test_fogged_plot_skipped()
    setup()
    installForeign(1, { team = 1 })
    local plot = fogPlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(#spoken, 0, "fogged-plot clears do not announce")
    T.eq(civvaccess_shared.foreignClearDelta, nil)
end

function M.test_teammate_clears_skipped()
    setup()
    -- Foreign player on the active team (team 0) -- shared vision, not foreign.
    installForeign(1, { team = 0 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onForeignGoodyCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(#spoken, 0, "teammate clears do not announce")
end

function M.test_unknown_actor_skipped()
    -- Defensive: an actor ID that doesn't resolve to a Players[] entry
    -- shouldn't crash or leak a count. Could happen if the engine fires
    -- the hook for a player slot the Lua layer hasn't seen yet.
    setup()
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(99, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(#spoken, 0, "unknown actor doesn't count")
end

function M.test_plural_form_for_multiple_camps()
    setup()
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(spoken[1].text, "Someone else has claimed 3 visible barbarian camps.")
end

function M.test_camps_and_ruins_joined_with_and()
    setup()
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onForeignGoodyCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(spoken[1].text, "Someone else has claimed 2 visible barbarian camps and 1 visible ancient ruin.")
end

function M.test_delta_stored_for_f7()
    setup()
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.truthy(civvaccess_shared.foreignClearDelta, "delta stored")
    T.eq(#civvaccess_shared.foreignClearDelta, 1, "single-element flat array")
    T.eq(civvaccess_shared.foreignClearDelta[1], "Someone else has claimed 1 visible barbarian camp.")
end

function M.test_announce_off_silent_but_delta_still_set()
    setup()
    civvaccess_shared.foreignClearWatchAnnounce = false
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(#spoken, 0, "no speech when announce setting is off")
    T.truthy(civvaccess_shared.foreignClearDelta, "delta still written so F7 turn log shows the line")
end

function M.test_message_buffer_push_uses_reveal_category()
    setup()
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    local snapshot = MessageBuffer._snapshot()
    T.truthy(snapshot, "message buffer state created")
    T.eq(#snapshot.entries, 1, "one buffer entry pushed")
    T.eq(snapshot.entries[1].category, "reveal", "reveal category matches ForeignUnitWatch's convention")
    T.eq(snapshot.entries[1].text, "Someone else has claimed 1 visible barbarian camp.")
end

function M.test_delta_cleared_on_turn_end()
    setup()
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.truthy(civvaccess_shared.foreignClearDelta, "delta set after turn start")
    ForeignClearWatch._onTurnEnd()
    T.eq(civvaccess_shared.foreignClearDelta, nil, "delta cleared on next turn end")
end

function M.test_counters_reset_between_ai_turns()
    -- Two consecutive AI turns. Each ticks one camp; the second turn's
    -- announcement should say 1, not 2 -- proves counters zero at
    -- TurnEnd.
    setup()
    installForeign(1, { team = 1 })
    local plot = visiblePlot(3, 4)
    installPlots({ plot })
    ForeignClearWatch.installListeners()

    -- Turn 1.
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(spoken[1].text, "Someone else has claimed 1 visible barbarian camp.")

    -- Turn 2.
    ForeignClearWatch._onTurnEnd()
    ForeignClearWatch._onForeignBarbCampCleared(1, 3, 4)
    ForeignClearWatch._onTurnStart()
    T.eq(#spoken, 2, "second turn produced its own announcement")
    T.eq(spoken[2].text, "Someone else has claimed 1 visible barbarian camp.")
end

return M

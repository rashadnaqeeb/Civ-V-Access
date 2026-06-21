-- RewardReview: the Alt+Up/Down section review wired onto dismiss-only
-- reward popups (tech / wonder researched, golden age, ...), whose content
-- lives in the preamble rather than a navigable item. Covers the real input
-- path: the binding swap, walking content fragments split on [NEWLINE], the
-- live re-read, and the content-signature reset that restarts the cursor when
-- a different reward opens. Shared setup lives in tests/menu_test_setup.lua.
local T = require("support")
local Setup = require("menu_test_setup")
local M = {}

local speaks = Setup.speaks
local setCtrls = Setup.setCtrls
local clearArr = Setup.clearArr

local WM_KEYDOWN = 256
local MOD_ALT = 4

local function setup()
    Setup.fresh()
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_RewardReview.lua")
    civvaccess_shared.verbosity = false
end

local function lastSpeak()
    return speaks[#speaks].text
end

-- A dismiss-only reward popup: one Close button (no content of its own),
-- with the reward content supplied through fragmentsFn the way the popups do.
local function pushReward(fragmentsFn)
    setCtrls({ "Close" })
    local h = BaseMenu.create({
        name = "Reward",
        displayName = "Reward",
        items = {
            BaseMenuItems.Button({
                controlName = "Close",
                labelText = "Close",
                activate = function() end,
            }),
        },
    })
    RewardReview.install(h, fragmentsFn)
    HandlerStack.push(h)
    return h
end

function M.test_alt_down_reviews_content_not_the_button()
    setup()
    pushReward(function()
        return { "A golden age dawns" }
    end)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "A golden age dawns", "Alt+Down reviews the reward content, not the Close label")
end

function M.test_fragments_split_on_newline()
    setup()
    pushReward(function()
        return { "Quote line", "Effect one[NEWLINE]Effect two" }
    end)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Quote line")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Effect one", "each [NEWLINE] line within a fragment is its own section")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Effect two")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Effect two", "Alt+Down past the end re-speaks the last section")
end

function M.test_empty_fragment_never_a_silent_section()
    setup()
    pushReward(function()
        return { "", "Real content", "" }
    end)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Real content", "blank fragments are dropped, not spoken as silence")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Real content", "the only section clamps on repeat")
end

function M.test_alt_up_from_fresh_enters_at_first_section()
    setup()
    pushReward(function()
        return { "Section one", "Section two" }
    end)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_UP, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Section one", "Alt+Up from fresh enters at section one, not silence")
end

function M.test_new_reward_restarts_cursor()
    setup()
    -- Mutable content: the first reward's fragments, then a different reward's.
    local reward = { "First quote", "First effect" }
    pushReward(function()
        return reward
    end)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN) -- section 1
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN) -- section 2
    -- A new reward opens (same Context, fresh content); no onShow coordination.
    reward = { "Second quote", "Second effect", "Second bonus" }
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Second quote", "changed content restarts the cursor at the new first section")
end

function M.test_live_reread_reflects_current_content()
    setup()
    local reward = { "Stale" }
    pushReward(function()
        return reward
    end)
    -- No press yet; content updates before the first review.
    reward = { "Fresh" }
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, MOD_ALT, WM_KEYDOWN)
    T.eq(lastSpeak(), "Fresh", "fragments are read live at press time, never snapshotted early")
end

return M

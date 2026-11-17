-- SocialPolicyPopup wrapper tests for the shapes of screen the wrapper runs
-- in. The real wrapper loads with BaseMenu.install captured, and its onShow
-- runs against a recording handler. Pins that a screen without the policies
-- part, its policy confirm, as in Conquest of the New World Deluxe, gets the
-- Ideology tab alone, while any screen with it keeps a Policies tab that is
-- filled on show and rebuilt on a policies change, and opens on the Ideology
-- tab when the popup asks for it. Also pins that the Ideology tab leaves out
-- the public opinion and switch-ideology rows when the screen has no such
-- controls. Where the switch row is offered, it follows the screen's
-- button: left out of Vox Populi's read-only spy view, said to be
-- unavailable while the button is disabled, and starting a switch only
-- while it isn't.

local T = require("support")
local M = {}

-- A classical branch and an ideology, as in the base game.
local BASE_BRANCHES = {
    [0] = { ID = 0, Type = "POLICY_BRANCH_TRADITION", Description = "Tradition" },
    [1] = { ID = 1, Type = "POLICY_BRANCH_FREEDOM", Description = "Freedom", PurchaseByLevel = true },
}

-- Conquest of the New World Deluxe replaces every branch with two
-- ideology-style ones.
local NEW_WORLD_DELUXE_BRANCHES = {
    [0] = { ID = 0, Type = "POLICY_BRANCH_AMERICAN", Description = "American", PurchaseByLevel = true },
    [1] = { ID = 1, Type = "POLICY_BRANCH_EUROPEAN", Description = "European", PurchaseByLevel = true },
}

local spec
local shown
local dirtyListener
local rebuilt

local function baseControls()
    return {
        CloseButton = Polyfill.makeButton(),
        PolicyConfirm = Polyfill.makeLabel(""),
        PublicOpinion = Polyfill.makeLabel(""),
        SwitchIdeologyButton = Polyfill.makeButton(),
        ChangeIdeologyConfirmYes = Polyfill.makeButton(),
        ChangeIdeologyConfirmNo = Polyfill.makeButton(),
    }
end

local function newWorldDeluxeControls()
    return { CloseButton = Polyfill.makeButton() }
end

local CHOOSEPOLICY = 17

-- Load the wrapper over the given branches and screen controls, then show
-- the screen, opened by popupInfo when given. The active player has embraced
-- the second branch.
local function load(branches, controls, popupInfo)
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_SocialPolicyLogic.lua")

    include = function() end
    InputHandler = nil
    ShowHideHandler = nil
    Controls = controls
    GameInfo = GameInfo or {}
    GameInfo.PolicyBranchTypes = branches
    GameOptionTypes = { GAMEOPTION_NO_POLICIES = 1 }
    Game = Game or {}
    Game.IsOption = function()
        return false
    end
    Game.GetActivePlayer = function()
        return 0
    end
    Players = {
        [0] = {
            GetLateGamePolicyTree = function()
                return 1
            end,
        },
        -- The rival a Vox Populi spy views, on the same ideology.
        [1] = {
            GetLateGamePolicyTree = function()
                return 1
            end,
            GetCivilizationShortDescription = function()
                return "Rome"
            end,
        },
    }
    ButtonPopupTypes = ButtonPopupTypes or {}
    ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY = CHOOSEPOLICY
    local popupListener
    Events = Events or {}
    Events.SerialEventGameMessagePopup = {
        Add = function(fn)
            popupListener = fn
        end,
    }
    Events.EventPoliciesDirty = {
        Add = function(fn)
            dirtyListener = fn
        end,
    }
    ContextPtr = {
        IsHidden = function()
            return false
        end,
    }

    -- The installed menu records each tab a policies change rebuilds.
    spec = nil
    rebuilt = {}
    BaseMenu = {
        install = function(_ctx, s)
            spec = s
            return {
                setItems = function(items, tab)
                    rebuilt[#rebuilt + 1] = { tab = tab, items = items }
                end,
                refresh = function() end,
            }
        end,
    }
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_SocialPolicyPopupAccess.lua")
    if popupInfo ~= nil then
        popupListener(popupInfo)
    end

    shown = { items = {} }
    spec.onShow({
        setInitialTabIndex = function(i)
            shown.initialTab = i
        end,
        setItems = function(items, tab)
            shown.items[tab] = items
        end,
    })
end

function M.test_base_game_screen_opens_on_policies_then_ideology()
    load(BASE_BRANCHES, baseControls())
    T.eq(#spec.tabs, 2)
    T.eq(spec.tabs[1].name, "TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES")
    T.eq(spec.tabs[2].name, "TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY")
    T.eq(shown.initialTab, 1)
    -- Tradition's branch and Close fill the Policies tab.
    T.eq(#shown.items[1], 2)
end

-- A popup can ask for the ideologies (Data2 = 2), and the screen then opens
-- on them, as the stock screen does.
function M.test_a_popup_asking_for_the_ideologies_opens_on_the_ideology_tab()
    load(BASE_BRANCHES, baseControls(), { Type = CHOOSEPOLICY, Data2 = 2 })
    T.eq(#spec.tabs, 2)
    T.eq(shown.initialTab, 2)
end

-- The American Civil War re-adds its one branch past ID 0, so no classical
-- branch shows there, but its screen has the policies part, so the Policies
-- tab stays first, as on that screen.
function M.test_a_screen_with_the_policies_part_keeps_its_policies_tab_without_a_branch_at_id_0()
    load({ [12] = { ID = 12, Type = "POLICY_BRANCH_LIBERTY", Description = "Liberty" } }, baseControls())
    T.eq(#spec.tabs, 2)
    T.eq(spec.tabs[1].name, "TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES")
    T.eq(shown.initialTab, 1)
end

-- Scramble for Africa's copy has the policy confirm but neither the public
-- opinion nor the switch-ideology control, and keeps its Policies tab.
function M.test_a_screen_with_only_the_policy_confirm_keeps_its_policies_tab()
    load(BASE_BRANCHES, { CloseButton = Polyfill.makeButton(), PolicyConfirm = Polyfill.makeLabel("") })
    T.eq(#spec.tabs, 2)
end

function M.test_a_screen_without_the_policies_part_leaves_out_the_policies_tab()
    load(NEW_WORLD_DELUXE_BRANCHES, newWorldDeluxeControls())
    T.eq(#spec.tabs, 1)
    T.eq(spec.tabs[1].name, "TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY")
    T.eq(shown.initialTab, 1)
    T.truthy(shown.items[1] ~= nil, "the ideology rows fill the only tab")
end

function M.test_ideology_tab_keeps_public_opinion_and_switch_rows_the_screen_has()
    load(BASE_BRANCHES, baseControls())
    -- Three tenet levels, public opinion, switch ideology, Close.
    T.eq(#shown.items[2], 6)
end

-- Vox Populi's espionage view of a rival's screen is read-only, so it offers
-- no switch row even though the screen has the button.
function M.test_the_spy_view_leaves_out_the_switch_row()
    load(BASE_BRANCHES, baseControls(), { Type = CHOOSEPOLICY, Data3 = 1, Data4 = 1 })
    -- Three tenet levels, public opinion and Close.
    T.eq(#shown.items[2], 5)
end

-- The switch row says whether the screen's button can be used right now.
function M.test_the_switch_row_follows_its_buttons_state()
    local controls = baseControls()
    load(BASE_BRANCHES, controls)
    local switch = shown.items[2][5]
    T.eq(switch.labelFn(), Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"))
    controls.SwitchIdeologyButton:SetDisabled(true)
    T.eq(switch.labelFn(), Text.key("TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"))
end

-- Enter on the switch row starts a switch only while the screen's button
-- allows one: the screen's own ChooseChangeIdeology, then its confirm.
function M.test_the_switch_row_switches_only_while_its_button_allows_it()
    local controls = baseControls()
    controls.SwitchIdeologyButton:SetDisabled(true)
    load(BASE_BRANCHES, controls)
    local asked = 0
    ChooseChangeIdeology = function()
        asked = asked + 1
    end
    BaseMenu.create = function(s)
        return { name = s.name }
    end
    local pushed = {}
    HandlerStack.push = function(h)
        pushed[#pushed + 1] = h.name
    end
    local switch = shown.items[2][5]
    switch:activate()
    T.eq(asked, 0, "no switch while the button is disabled")
    controls.SwitchIdeologyButton:SetDisabled(false)
    switch:activate()
    T.eq(asked, 1)
    T.eq(#pushed, 1, "the confirm menu opens")
end

function M.test_ideology_tab_leaves_out_rows_for_controls_the_screen_lacks()
    load(NEW_WORLD_DELUXE_BRANCHES, newWorldDeluxeControls())
    -- Three tenet levels and Close.
    T.eq(#shown.items[1], 4)
end

-- Adopting a policy fires EventPoliciesDirty, which rebuilds both tabs on a
-- screen with the Policies tab.
function M.test_a_policies_change_rebuilds_both_tabs_on_a_screen_with_a_policies_tab()
    load(BASE_BRANCHES, baseControls())
    dirtyListener()
    T.eq(#rebuilt, 2)
    T.eq(rebuilt[1].tab, 1)
    T.eq(rebuilt[2].tab, 2)
end

-- Adopting a tenet fires EventPoliciesDirty; with no Policies tab, only the
-- Ideology tab is rebuilt, so its rows aren't replaced by the empty policy list.
function M.test_a_policies_change_rebuilds_only_the_ideology_tab_without_a_policies_tab()
    load(NEW_WORLD_DELUXE_BRANCHES, newWorldDeluxeControls())
    dirtyListener()
    T.eq(#rebuilt, 1)
    T.eq(rebuilt[1].tab, 1)
    T.eq(#rebuilt[1].items, 4)
end

return M

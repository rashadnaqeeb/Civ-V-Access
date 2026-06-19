-- ProposalChartPopup wrapper tests (LekMod voting system). The wrapper is a
-- LekMod-only popup whose announce logic (proposal headline, secret-ballot
-- tally gating, per-voter status, Yes/No vote dispatch) is exercised only in a
-- live MP session otherwise. We load the real wrapper, capture the spec it
-- hands BaseMenu.install, and drive its real preamble / item builders against a
-- stubbed Game voting surface -- so the headline-type mapping, the tally
-- secret-ballot gate, and the -5 / -6 vote codes are pinned offline.
--
-- The proposal id arrives on a SerialEventGameMessagePopup the wrapper listens
-- for; we capture that listener and fire it to set the captured id / status,
-- exactly as LekMod's BUTTONPOPUP_MODDER_0 does in game.

local T = require("support")
local M = {}

-- LekMod's own proposal-screen text keys (resolved via Locale; the CIVVACCESS_
-- keys resolve from the CivVAccess_Strings table run.lua loads).
local LEK_TEXT = {
    ["TXT_KEY_MP_PROPOSAL_SCREEN_SUMMARY_CC"] = "Condemn {1_Subject}",
    ["TXT_KEY_MP_PROPOSAL_SCREEN_SUMMARY_IRR"] = "Increase Research Rate",
    ["TXT_KEY_MP_PROPOSAL_SCREEN_SUMMARY_SCRAP"] = "Scrap the game",
    ["TXT_KEY_MP_PROPOSAL_SCREEN_SUMMARY_REMAP"] = "Remap",
    ["TXT_KEY_MP_PROPOSAL_SCREEN_STARTED_BY"] = "started by {1_Name}",
    ["TXT_KEY_MP_PROPOSAL_SCREEN_PROPOSAL_PASSED"] = "Passed",
    ["TXT_KEY_MP_PROPOSAL_SCREEN_PROPOSAL_FAILED"] = "Failed",
    ["TXT_KEY_LEKMOD_MP_PENDING_VOTES"] = "{1_Num} pending",
    ["TXT_KEY_LEKMOD_MP_PENDING_VOTES_NONE"] = "everyone has voted",
    ["TXT_KEY_POSITIVE_VOTE_CHART_STATUS"] = "voted yes",
    ["TXT_KEY_NEGATIVE_VOTE_CHART_STATUS"] = "voted no",
    ["TXT_KEY_CLOSE"] = "Close",
}

-- Mutable voting state the Game stubs read. Tests set fields before loading.
local G
local capturedSpec
local popupListener
local giftCalls

local function stubPlayer(name, opts)
    opts = opts or {}
    return {
        _name = name,
        GetName = function(self)
            return self._name
        end,
        GetNickName = function()
            return opts.nick or ""
        end,
        IsAlive = function()
            return opts.alive ~= false
        end,
        IsHuman = function()
            return opts.human ~= false
        end,
        IsObserver = function()
            return opts.observer == true
        end,
    }
end

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    T.installLocaleStrings(LEK_TEXT)

    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")

    include = function() end
    InputHandler = nil
    ShowHideHandler = nil
    Controls = {}

    -- Capture the install spec instead of wiring a real Context.
    capturedSpec = nil
    BaseMenu = {
        install = function(_ctx, spec)
            capturedSpec = spec
        end,
    }

    popupListener = nil
    Events = Events or {}
    Events.SerialEventGameMessagePopup = {
        Add = function(fn)
            popupListener = fn
        end,
    }
    ButtonPopupTypes = ButtonPopupTypes or {}
    ButtonPopupTypes.BUTTONPOPUP_MODDER_0 = 137

    giftCalls = {}
    Network = Network or {}
    Network.SendGiftUnit = function(id, code)
        giftCalls[#giftCalls + 1] = { id = id, code = code }
    end
    OnClose = function() end

    GameDefines = GameDefines or {}
    GameDefines.MAX_MAJOR_CIVS = 3

    G = {
        ptype = 0,
        subject = -1,
        owner = -1,
        status = 0,
        maxVotes = 7,
        yes = 0,
        no = 0,
        expire = 3,
        elapsed = 10,
        me = 0,
        voters = {}, -- [i] = { eligible=, voted=, vote= }
    }

    Players = {
        [0] = stubPlayer("You"),
        [1] = stubPlayer("Rome"),
        [2] = stubPlayer("Greece"),
    }

    local function voter(i)
        return G.voters[i] or {}
    end

    Game = Game or {}
    Game.GetActivePlayer = function()
        return G.me
    end
    Game.GetProposalType = function()
        return G.ptype
    end
    Game.GetProposalSubject = function()
        return G.subject
    end
    Game.GetProposalOwner = function()
        return G.owner
    end
    Game.GetProposalStatus = function()
        return G.status
    end
    Game.GetMaxVotes = function()
        return G.maxVotes
    end
    Game.GetYesVotes = function()
        return G.yes
    end
    Game.GetNoVotes = function()
        return G.no
    end
    Game.GetElapsedGameTurns = function()
        return G.elapsed
    end
    Game.GetProposalExpirationCounter = function()
        return G.expire
    end
    Game.GetProposalVoterEligibility = function(_id, i)
        return voter(i).eligible == true
    end
    Game.GetProposalVoterHasVoted = function(_id, i)
        return voter(i).voted == true
    end
    Game.GetProposalVoterVote = function(_id, i)
        return voter(i).vote == true
    end
end

-- Load the wrapper fresh (resets capturedId to -1 + re-registers listener),
-- then fire the popup event so the captured id / status are set, mirroring
-- LekMod's BUTTONPOPUP_MODDER_0.
local function loadWith(id)
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_ProposalChartPopupAccess.lua")
    popupListener({ Type = ButtonPopupTypes.BUTTONPOPUP_MODDER_0, Data1 = id, Data2 = G.status })
    return capturedSpec
end

local function items()
    local collected
    capturedSpec.onShow({
        setItems = function(list)
            collected = list
        end,
    })
    return collected
end

local function findLabel(list, label)
    for _, it in ipairs(list) do
        if it.labelText == label then
            return it
        end
    end
end

-- Headline -------------------------------------------------------------

function M.test_headline_condemn_names_subject()
    setup()
    G.ptype = 1
    G.subject = 1
    local spec = loadWith(5)
    T.truthy(spec.preamble():find("Condemn Rome", 1, true), "CC headline names the subject")
end

function M.test_headline_types_are_distinct()
    setup()
    G.ptype = 0
    loadWith(5)
    T.truthy(capturedSpec.preamble():find("Increase Research Rate", 1, true), "IRR headline")
    setup()
    G.ptype = 3
    loadWith(5)
    T.truthy(capturedSpec.preamble():find("Remap", 1, true), "remap headline")
end

-- Secret-ballot tally gate --------------------------------------------

function M.test_tally_shown_for_non_remap()
    setup()
    G.ptype = 0
    G.maxVotes = 7
    G.yes = 2
    G.no = 1
    local spec = loadWith(5)
    -- TXT_KEY_CIVVACCESS_PROPOSAL_TALLY: "{1} of {2} votes in, {3} missing"
    T.truthy(spec.preamble():find("3 of 7 votes in, 4 missing", 1, true), "running tally for non-remap")
end

function M.test_tally_hidden_for_remap_open_vote()
    setup()
    G.ptype = 3 -- open remap vote: per-player votes, no running tally
    G.maxVotes = 7
    G.yes = 2
    G.no = 1
    local spec = loadWith(5)
    T.eq(spec.preamble():find("votes in", 1, true), nil, "no running tally on the open remap vote")
end

-- Vote dispatch --------------------------------------------------------

function M.test_vote_options_present_and_use_codes_minus5_minus6()
    setup()
    G.status = 0 -- voting open
    G.me = 0
    G.voters[0] = { eligible = true, voted = false }
    loadWith(5)
    local list = items()
    local yes = findLabel(list, "Vote yes")
    local no = findLabel(list, "Vote no")
    T.truthy(yes, "Vote yes offered while voting open")
    T.truthy(no, "Vote no offered while voting open")
    yes:activate({})
    no:activate({})
    T.eq(giftCalls[1].id, 5)
    T.eq(giftCalls[1].code, -5, "yes casts via SendGiftUnit(id, -5)")
    T.eq(giftCalls[2].code, -6, "no casts via SendGiftUnit(id, -6)")
end

function M.test_vote_options_absent_when_already_voted()
    setup()
    G.status = 0
    G.me = 0
    G.voters[0] = { eligible = true, voted = true }
    loadWith(5)
    local list = items()
    T.eq(findLabel(list, "Vote yes"), nil, "no vote option once the player has voted")
    T.eq(findLabel(list, "Vote no"), nil)
end

function M.test_vote_options_absent_when_resolved()
    setup()
    G.status = 1 -- passed
    G.me = 0
    G.voters[0] = { eligible = true, voted = false }
    local spec = loadWith(5)
    local list = items()
    T.eq(findLabel(list, "Vote yes"), nil, "no vote option after the proposal resolved")
    T.truthy(spec.preamble():find("Passed", 1, true), "resolved status announced")
end

-- Per-voter status secrecy --------------------------------------------

function M.test_voter_vote_hidden_until_remap_or_resolved()
    -- A cast vote stays "voted" on a secret-ballot proposal; only the open
    -- remap vote (or a resolved proposal) reveals yes / no. Same own row (the
    -- active player), differing only by proposal type, isolates the type-3 gate.
    setup()
    G.ptype = 0 -- secret ballot
    G.status = 0
    G.me = 0
    G.voters[0] = { eligible = true, voted = true, vote = true }
    loadWith(5)
    local secret = findLabel(items(), "You, voted")
    T.truthy(secret, "secret ballot shows 'voted', not the choice")

    setup()
    G.ptype = 3 -- open remap vote reveals the choice
    G.status = 0
    G.me = 0
    G.voters[0] = { eligible = true, voted = true, vote = true }
    loadWith(5)
    local revealed = findLabel(items(), "You, voted yes")
    T.truthy(revealed, "open remap vote reveals the per-voter choice")
end

return M

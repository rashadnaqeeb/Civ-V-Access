-- LekModDraft: the reads and announcements behind LekMod's staging-room civ
-- draft. The item builders need the menu framework and a live lobby, so what
-- is covered here is everything that decides WHAT those items say and when
-- the draft speaks:
--   * inUse, which keeps a lobby that ignores the draft from hearing about it
--   * slotStatus, the ban-phase tail on a seat summary
--   * the ban and draft summaries a player polls
--   * applyBan's rejection notice, the one place LekMod fails silently
--   * the protocol announcements, which are the only signal a remote change
--     gives at all
--
-- LekMod's own Draft_* entry points are stubbed as the external boundary they
-- are, the same way engine globals are; everything under test is ours. The
-- protocol stub applies the same state changes LekMod's does, because our
-- announcements are diffs taken across that call.

local T = require("support")
local M = {}

local spoken
local applied
local pools
local aiSlots

local CIVS = {
    [1] = { ShortDescription = "Rome" },
    [2] = { ShortDescription = "Korea" },
    [3] = { ShortDescription = "Zulu" },
}

-- A lobby with the local player at 0 and two other humans. Nothing banned,
-- nobody ready, no draft dealt: the state a lobby opens in.
local function setup()
    spoken = {}
    applied = {}
    pools = {}
    aiSlots = {}
    civvaccess_shared = {}

    Text = Text or {}
    Text.key = function(k)
        return k
    end
    Text.format = function(k, a, b)
        return k .. "|" .. tostring(a) .. (b ~= nil and ("|" .. tostring(b)) or "")
    end

    SpeechPipeline = {
        speakQueued = function(t)
            spoken[#spoken + 1] = t
        end,
        speakInterrupt = function(t)
            spoken[#spoken + 1] = t
        end,
    }

    GameInfo = GameInfo or {}
    GameInfo.Civilizations = CIVS

    Matchmaking = {
        GetLocalID = function()
            return 0
        end,
        IsHost = function()
            return true
        end,
    }

    PreGame = PreGame or {}
    PreGame.GetNickName = function(playerID)
        return ({ [0] = "You", [1] = "Alice", [2] = "Bob" })[playerID]
    end
    PreGame.GetCivilization = function()
        return -1
    end
    PreGame.IsHotSeatGame = function()
        return false
    end

    -- LekMod state, as Lekmod_staging_draft.lua leaves it on a fresh lobby.
    g_DraftRules = { bansPerPlayer = 2, picksPerPlayer = 3 }
    g_DraftBans = {}
    g_DraftBanReady = {}
    g_DraftBanHostControl = {}
    g_DraftSwapDesire = {}
    g_DraftLocked = false
    g_PendingBan = nil
    g_PreviousDraftSnapshot = nil

    Draft_GetPoolForPlayer = function(playerID)
        return pools[playerID]
    end

    -- Stands in for LekMod's commit: records the call and writes the ban,
    -- which is what our code reads back to detect a rejected pick.
    Draft_ApplyBanSelection = function(civID)
        local pending = g_PendingBan
        g_PendingBan = nil
        applied[#applied + 1] = { playerID = pending.playerID, slotIndex = pending.slotIndex, civID = civID }
        g_DraftBans[pending.playerID] = g_DraftBans[pending.playerID] or {}
        g_DraftBans[pending.playerID][pending.slotIndex] = civID
    end

    -- The packets our announcements diff across, applied as LekMod applies
    -- them. Only the three ops the layer reacts to are modelled.
    Draft_HandleProtocol = function(_fromPlayer, text)
        local op, rest = string.match(text, "^#LDRAFT#([^|]+)|(.*)$")
        if op == "BANREADY" then
            local pid, flag = string.match(rest, "^(%d+)|(%d+)$")
            g_DraftBanReady[tonumber(pid)] = tonumber(flag) == 1
        elseif op == "SWAPREQ" then
            local from, to = string.match(rest, "^(%-?%d+)|(%-?%d+)$")
            from, to = tonumber(from), tonumber(to)
            g_DraftSwapDesire[from] = (to >= 0) and to or nil
        elseif op == "SWAP" then
            local a, b = string.match(rest, "^(%d+)|(%d+)|")
            g_DraftSwapDesire[tonumber(a)] = nil
            g_DraftSwapDesire[tonumber(b)] = nil
        end
    end

    Draft_UpdatePageTabView = function() end
    Draft_IsHistoryOnly = function()
        return false
    end

    civvaccess_shared._lekmodDraft = {
        canEditBans = function(playerID)
            return not g_DraftLocked and g_DraftBanReady[playerID] ~= true
        end,
        lockedByGameReady = function()
            return false
        end,
        isParticipant = function()
            return true
        end,
        isAI = function(playerID)
            return aiSlots[playerID] == true
        end,
        isHumanRequired = function()
            return false
        end,
        humanOrder = function()
            return { 0, 1, 2 }
        end,
        draftOrder = function()
            return { 0, 1, 2 }
        end,
        canSelectDraftCiv = function(playerID)
            return g_DraftLocked and playerID == 0
        end,
    }

    dofile("src/dlc/UI/FrontEnd/CivVAccess_LekModDraft.lua")
end

-- Clear every LekMod global so present() sees what vanilla and VP see.
local function setupWithoutLekMod()
    setup()
    Draft_ApplyBanSelection = nil
    Draft_UpdatePageTabView = nil
    g_DraftRules = nil
end

-- Present / inert ------------------------------------------------------

function M.test_absent_without_lekmod()
    setupWithoutLekMod()
    T.eq(LekModDraft.present(), false)
    T.eq(#LekModDraft.localItems(), 0, "no own-bans group off LekMod")
    T.eq(#LekModDraft.slotChildren(1), 0, "no per-seat draft rows off LekMod")
    T.eq(#LekModDraft.tabItems(), 0, "no draft tab content off LekMod")
    T.eq(LekModDraft.slotStatus(1), nil)
    T.eq(LekModDraft.inUse(), false)
end

-- In use ---------------------------------------------------------------

-- LekMod's draft page exists in every lobby, so an untouched draft must read
-- as not happening: otherwise every seat in an ordinary game reports a ban
-- state nobody set.
function M.test_untouched_draft_is_not_in_use()
    setup()
    T.eq(LekModDraft.inUse(), false)
end

function M.test_a_single_ban_puts_the_draft_in_use()
    setup()
    g_DraftBans[1] = { 2, -1 }
    T.eq(LekModDraft.inUse(), true)
end

-- Empty ban slots are stored as -1, which must not count as a ban.
function M.test_empty_ban_slots_do_not_put_the_draft_in_use()
    setup()
    g_DraftBans[1] = { -1, -1 }
    T.eq(LekModDraft.inUse(), false)
end

function M.test_a_readied_player_puts_the_draft_in_use()
    setup()
    g_DraftBanReady[2] = true
    T.eq(LekModDraft.inUse(), true)
end

function M.test_a_dealt_draft_is_in_use()
    setup()
    g_DraftLocked = true
    T.eq(LekModDraft.inUse(), true)
end

-- Seat summary tail ----------------------------------------------------

function M.test_no_seat_status_before_the_draft_is_used()
    setup()
    T.eq(LekModDraft.slotStatus(1), nil)
end

function M.test_seat_status_reports_the_ban_phase()
    setup()
    g_DraftBanReady[2] = true
    T.eq(LekModDraft.slotStatus(1), "TXT_KEY_CIVVACCESS_DRAFT_STATUS_CHOOSING")
    T.eq(LekModDraft.slotStatus(2), "TXT_KEY_CIVVACCESS_DRAFT_STATUS_READY")
end

function M.test_seat_status_reports_ceded_ban_control()
    setup()
    g_DraftBanReady[2] = true
    g_DraftBanHostControl[1] = true
    T.eq(LekModDraft.slotStatus(1), "TXT_KEY_CIVVACCESS_DRAFT_STATUS_HOST_CONTROLS")
end

-- An AI never holds the ban phase up, so saying anything about its readiness
-- on every landing would be noise.
function M.test_no_seat_status_for_an_ai()
    setup()
    g_DraftBanReady[2] = true
    aiSlots[1] = true
    T.eq(LekModDraft.slotStatus(1), nil)
end

-- Once the hands are dealt the phase is lobby-wide; repeating it on every
-- seat says nothing the Draft tab does not.
function M.test_no_seat_status_once_dealt()
    setup()
    g_DraftBanReady[2] = true
    g_DraftLocked = true
    T.eq(LekModDraft.slotStatus(2), nil)
end

-- Summaries ------------------------------------------------------------

function M.test_ban_summary_names_the_banned_civs()
    setup()
    g_DraftBans[1] = { 1, 3 }
    T.eq(LekModDraft._banSummary(1), "Rome, Zulu")
end

-- A half-filled set reads as what was actually banned; the empty slot is a
-- thing to do, not a thing to say.
function M.test_ban_summary_skips_empty_slots()
    setup()
    g_DraftBans[1] = { -1, 2 }
    T.eq(LekModDraft._banSummary(1), "Korea")
end

function M.test_ban_summary_is_nil_with_nothing_banned()
    setup()
    T.eq(LekModDraft._banSummary(1), nil)
end

-- The rules can raise bans-per-player before every player's array has caught
-- up, so a short array must read as empty slots rather than throw.
function M.test_ban_summary_survives_a_short_array()
    setup()
    g_DraftRules.bansPerPlayer = 4
    g_DraftBans[1] = { 1 }
    T.eq(LekModDraft._banSummary(1), "Rome")
end

function M.test_hand_summary_is_nil_until_a_draft_is_dealt()
    setup()
    pools[0] = { 1, 2, 3 }
    T.eq(LekModDraft._handSummary(0), nil, "a pool is not a hand until the draft locks")
    g_DraftLocked = true
    T.eq(LekModDraft._handSummary(0), "Rome, Korea, Zulu")
end

-- Applying a ban -------------------------------------------------------

-- LekMod names the slot from g_PendingBan, the slot its own picker was opened
-- for, so our commit has to set it the way a click would.
function M.test_apply_ban_names_the_slot_it_commits()
    setup()
    LekModDraft._applyBan(0, 2, 3)
    T.eq(#applied, 1)
    T.eq(applied[1].playerID, 0)
    T.eq(applied[1].slotIndex, 2)
    T.eq(applied[1].civID, 3)
    T.eq(g_PendingBan, nil, "pending slot cleared after the commit")
end

function M.test_apply_ban_is_quiet_when_it_takes()
    setup()
    LekModDraft._applyBan(0, 1, 1)
    T.eq(#spoken, 0)
end

-- When another player claimed the civ first, LekMod empties the slot instead
-- of setting it and says nothing at all -- the player would be left with a
-- ban that silently went missing.
function M.test_apply_ban_reports_a_civ_someone_else_banned()
    setup()
    Draft_ApplyBanSelection = function(civID)
        local pending = g_PendingBan
        g_PendingBan = nil
        g_DraftBans[pending.playerID] = g_DraftBans[pending.playerID] or {}
        g_DraftBans[pending.playerID][pending.slotIndex] = -1
        applied[#applied + 1] = { civID = civID }
    end
    LekModDraft._applyBan(0, 1, 1)
    T.eq(#spoken, 1)
    T.eq(spoken[1], "TXT_KEY_CIVVACCESS_DRAFT_BAN_TAKEN|Rome")
end

-- Clearing a slot is a commit of -1, and lands the slot empty on purpose.
function M.test_clearing_a_ban_is_not_reported_as_taken()
    setup()
    g_DraftBans[0] = { 1, -1 }
    LekModDraft._applyBan(0, 1, -1)
    T.eq(#spoken, 0)
end

function M.test_apply_ban_refuses_a_locked_slot()
    setup()
    g_DraftBanReady[0] = true
    LekModDraft._applyBan(0, 1, 1)
    T.eq(#applied, 0, "no commit while your bans are readied")
end

-- Remote changes -------------------------------------------------------

-- Readiness is the ban phase's progress signal and LekMod broadcasts it with
-- no announcement of its own.
function M.test_a_player_readying_speaks()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#BANREADY|1|1")
    T.eq(spoken[1], "TXT_KEY_CIVVACCESS_DRAFT_READY_ANNOUNCE|Alice")
end

function M.test_a_player_unreadying_stays_quiet()
    setup()
    g_DraftBanReady[1] = true
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#BANREADY|1|0")
    T.eq(#spoken, 0)
end

-- The host replays every ready flag it holds whenever the lobby refreshes;
-- a flag that was already set is not news.
function M.test_a_replayed_ready_flag_does_not_re_announce()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#BANREADY|1|1")
    Draft_HandleProtocol(1, "#LDRAFT#BANREADY|1|1")
    T.eq(#spoken, 1)
end

-- Your own readiness is something you just did; you do not need telling.
function M.test_your_own_readying_is_not_announced()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(0, "#LDRAFT#BANREADY|0|1")
    T.eq(#spoken, 0)
end

-- A swap request aimed at you asks you to act and shows up only as a glow.
function M.test_a_swap_request_aimed_at_you_speaks()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#SWAPREQ|1|0")
    T.eq(spoken[1], "TXT_KEY_CIVVACCESS_DRAFT_SWAP_WANTED|Alice")
end

function M.test_a_swap_request_between_others_stays_quiet()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#SWAPREQ|1|2")
    T.eq(#spoken, 0)
end

-- A request already standing must not re-announce on the next packet.
function M.test_a_standing_swap_request_announces_once()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#SWAPREQ|1|0")
    Draft_HandleProtocol(2, "#LDRAFT#BANREADY|2|0")
    T.eq(#spoken, 1)
end

-- A completed swap trades two hands with no announcement from LekMod at all.
function M.test_a_completed_swap_involving_you_speaks()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#SWAP|0|1|1,2|3")
    T.eq(spoken[1], "TXT_KEY_CIVVACCESS_DRAFT_SWAP_DONE|Alice")
end

function M.test_a_completed_swap_between_others_stays_quiet()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#SWAP|1|2|1,2|3")
    T.eq(#spoken, 0)
end

-- Wrapping twice would announce twice; the guard has to survive a second
-- install without stacking.
function M.test_installing_twice_does_not_double_announce()
    setup()
    LekModDraft.installAnnounce()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#SWAPREQ|1|0")
    T.eq(#spoken, 1)
end

-- The Context re-initialises on a lobby refresh and redefines the handler from
-- a fresh chunk. Keying the guard on a flag would leave that fresh copy
-- unwrapped and the draft silent for the rest of the session.
function M.test_a_redefined_handler_is_wrapped_again()
    setup()
    LekModDraft.installAnnounce()
    Draft_HandleProtocol = function()
        g_DraftSwapDesire[1] = 0
    end
    LekModDraft.installAnnounce()
    Draft_HandleProtocol(1, "#LDRAFT#SWAPREQ|1|0")
    T.eq(spoken[1], "TXT_KEY_CIVVACCESS_DRAFT_SWAP_WANTED|Alice")
end

return M

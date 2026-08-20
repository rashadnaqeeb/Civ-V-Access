-- LekMod staging-room civ draft and ban system.
--
-- LekMod v35 added a draft to the multiplayer lobby: the host sets rules (bans
-- and picks per player, guaranteed coastal and inland counts, vanilla-only,
-- seasonal exclusions), every player bans civilizations out of the shared
-- pool and readies, the host deals each participant a hand, and players pick
-- their civ from that hand or swap whole hands with each other. On screen it
-- is nothing but ban boxes, civ icons, and colour highlights.
--
-- This module turns that into menu items. It reads LekMod's own state
-- (g_DraftRules / g_DraftBans / g_DraftPools and friends are globals in the
-- StagingRoom Context) and drives LekMod's own Draft_* entry points, so every
-- action takes the path a mouse click would: network broadcast, visual
-- refresh, and persistence all happen as LekMod intends, and a sighted
-- partner watching the same lobby sees the screen update.
--
-- The predicates that decide whether a ban may still be edited are file-local
-- to Lekmod_staging_draft.lua; our vendor override promotes them onto
-- civvaccess_shared._lekmodDraft rather than have us re-derive rules that can
-- change under us. See docs/llm-docs/lekmod-support.md.
--
-- Inert everywhere else: present() is false whenever the LekMod draft did not
-- load, and every entry point returns an empty list.
--
-- Layout. The draft is per-player state, so it lives with the players:
--   * Your own bans and, once dealt, your hand sit at the top of the Players
--     tab, one keypress deep, mirroring LekMod pinning its own ban box above
--     the roster and matching how the local ready checkbox is already hoisted.
--   * Every other seat carries the same information inside its existing slot
--     group, plus the swap action, so one place answers everything about that
--     player.
--   * The Draft tab holds what is lobby-wide rather than per-player: the
--     phase, who the draft is waiting on, the rules, and the host's controls.
-- Ban readiness is appended to a seat's summary only once the draft is
-- actually in use, so a lobby that ignores the draft never hears about it.

include("CivVAccess_CivDetails")

LekModDraft = {}

-- Promoted LekMod file-locals. A missing key means an upstream rename; log it
-- once (loud enough to find, quiet enough not to spam a per-navigate call) and
-- let the caller fall back.
local INTERNAL_KEYS = {
    "canEditBans",
    "lockedByGameReady",
    "isParticipant",
    "isAI",
    "isHumanRequired",
    "humanOrder",
    "draftOrder",
    "canSelectDraftCiv",
}

-- One check per table, not per call: these are read on every navigation step.
local _checkedTable = nil

local function internals()
    local t = civvaccess_shared._lekmodDraft
    if t == nil then
        if _checkedTable ~= false then
            _checkedTable = false
            Log.error(
                "LekModDraft: civvaccess_shared._lekmodDraft missing; the vendored "
                    .. "Lekmod_staging_draft.lua override did not load. Ban editability "
                    .. "falls back to a coarse check."
            )
        end
        return {}
    end
    if _checkedTable ~= t then
        _checkedTable = t
        for _, key in ipairs(INTERNAL_KEYS) do
            if type(t[key]) ~= "function" then
                Log.error("LekModDraft: promoted LekMod local '" .. key .. "' is missing; re-derive it on re-pin")
            end
        end
    end
    return t
end

-- Call a promoted predicate, falling back to `default` when it is missing or
-- throws. A throw is a real bug (these are pure reads), so it is logged.
local function ask(name, default, ...)
    local fn = internals()[name]
    if type(fn) ~= "function" then
        return default
    end
    local ok, result = pcall(fn, ...)
    if not ok then
        Log.error("LekModDraft: promoted '" .. name .. "' failed: " .. tostring(result))
        return default
    end
    return result
end

-- Wrap a LekMod entry point so a thrown error names the call that threw
-- instead of dying inside a menu activate.
local function drive(name, fn, ...)
    if type(fn) ~= "function" then
        Log.error("LekModDraft: LekMod entry point '" .. name .. "' is missing")
        return
    end
    local ok, err = pcall(fn, ...)
    if not ok then
        Log.error("LekModDraft: " .. name .. " failed: " .. tostring(err))
    end
end

-- State reads ---------------------------------------------------------

function LekModDraft.present()
    return type(Draft_ApplyBanSelection) == "function"
        and type(Draft_UpdatePageTabView) == "function"
        and type(g_DraftRules) == "table"
end

local function isLocked()
    return g_DraftLocked == true
end

local function isHistoryOnly()
    if type(Draft_IsHistoryOnly) ~= "function" then
        return false
    end
    local ok, result = pcall(Draft_IsHistoryOnly)
    if not ok then
        Log.error("LekModDraft: Draft_IsHistoryOnly failed: " .. tostring(result))
        return false
    end
    return result == true
end

local function localID()
    return Matchmaking.GetLocalID()
end

local function playerName(playerID)
    local name = PreGame.GetNickName(playerID)
    if name == nil or name == "" then
        return Text.key("TXT_KEY_PLAYER_TYPE_HUMAN")
    end
    return name
end

local function bansPerPlayer()
    local n = tonumber(g_DraftRules and g_DraftRules.bansPerPlayer)
    if n == nil or n < 0 then
        return 0
    end
    return n
end

-- The civ banned in one of a player's ban slots, or nil for an empty slot.
-- Slots past the end of the player's array read as empty: LekMod resizes those
-- arrays lazily when the rules change, so a new count can be live in
-- g_DraftRules before every player's array has caught up.
local function banAt(playerID, slotIndex)
    local list = g_DraftBans and g_DraftBans[playerID]
    local civID = list and list[slotIndex]
    if civID == nil or civID < 0 then
        return nil
    end
    return civID
end

local function poolFor(playerID)
    if not isLocked() or type(Draft_GetPoolForPlayer) ~= "function" then
        return nil
    end
    local ok, pool = pcall(Draft_GetPoolForPlayer, playerID)
    if not ok then
        Log.error("LekModDraft: Draft_GetPoolForPlayer failed: " .. tostring(pool))
        return nil
    end
    if pool == nil or #pool == 0 then
        return nil
    end
    return pool
end

local function canEditBans(playerID)
    -- The fallback is coarse on purpose: it covers the states where editing is
    -- definitely closed, so a broken promotion leaves the slot reachable
    -- rather than vanishing, and LekMod's own guard still rejects the write.
    return ask("canEditBans", not (isLocked() or isHistoryOnly()), playerID) == true
end

local function isParticipant(playerID)
    return ask("isParticipant", true, playerID) == true
end

local function gameReadyLock()
    return ask("lockedByGameReady", false) == true
end

-- Whether the draft is being used in this lobby. LekMod's draft page is always
-- present, so without this every seat in a lobby that ignores the draft would
-- report a ban state nobody set. The moment anyone bans, readies, or a draft
-- is dealt, it is in play for everyone.
function LekModDraft.inUse()
    if not LekModDraft.present() then
        return false
    end
    if isLocked() then
        return true
    end
    if type(g_DraftBanReady) == "table" then
        for _, ready in pairs(g_DraftBanReady) do
            if ready == true then
                return true
            end
        end
    end
    if type(g_DraftBans) == "table" then
        for _, list in pairs(g_DraftBans) do
            for _, civID in ipairs(list) do
                if civID ~= nil and civID >= 0 then
                    return true
                end
            end
        end
    end
    return false
end

-- Labels --------------------------------------------------------------

-- Leader, civ, unique ability, unique unit and building: the same detail the
-- civ pulldown gives, for the places where the player is choosing.
local function civDetailLabel(civID)
    local label = CivDetails.richLabelForID(civID)
    if label ~= nil and label ~= "" then
        return label
    end
    -- A civ in a ban or a hand that the database no longer offers: name it
    -- from its own row rather than drop the entry silently.
    local row = civID ~= nil and civID >= 0 and GameInfo.Civilizations[civID] or nil
    if row ~= nil then
        return Text.key(row.ShortDescription)
    end
    return nil
end

-- Just the name, for summary lines where the full detail would bury it.
local function civShortLabel(civID)
    local row = civID ~= nil and civID >= 0 and GameInfo.Civilizations[civID] or nil
    if row == nil then
        return nil
    end
    return Text.key(row.ShortDescription)
end

-- The civs a player has banned, named. Nil when they have banned nothing.
local function banSummary(playerID)
    local parts = {}
    for i = 1, bansPerPlayer() do
        local civID = banAt(playerID, i)
        if civID ~= nil then
            parts[#parts + 1] = civShortLabel(civID) or tostring(civID)
        end
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ", ")
end

local function handSummary(playerID)
    local pool = poolFor(playerID)
    if pool == nil then
        return nil
    end
    local parts = {}
    for _, civID in ipairs(pool) do
        parts[#parts + 1] = civShortLabel(civID) or tostring(civID)
    end
    return table.concat(parts, ", ")
end

-- Ban-phase state for one player, as a tail on their seat summary. Nil once a
-- draft is dealt (the phase is lobby-wide by then and belongs on the Draft
-- tab rather than repeated on every seat) and for the seats that never hold
-- the draft up.
function LekModDraft.slotStatus(playerID)
    if not LekModDraft.present() or not LekModDraft.inUse() then
        return nil
    end
    if isLocked() or isHistoryOnly() then
        return nil
    end
    if not isParticipant(playerID) then
        return nil
    end
    if ask("isAI", false, playerID) == true or ask("isHumanRequired", false, playerID) == true then
        return nil
    end
    if g_DraftBanHostControl ~= nil and g_DraftBanHostControl[playerID] == true then
        return Text.key("TXT_KEY_CIVVACCESS_DRAFT_STATUS_HOST_CONTROLS")
    end
    if g_DraftBanReady ~= nil and g_DraftBanReady[playerID] == true then
        return Text.key("TXT_KEY_CIVVACCESS_DRAFT_STATUS_READY")
    end
    return Text.key("TXT_KEY_CIVVACCESS_DRAFT_STATUS_CHOOSING")
end

-- Ban editing ---------------------------------------------------------

-- The civs still available for one ban slot: everything playable except what
-- some player has already banned, minus this slot's own current pick, which
-- stays listed so it can be re-confirmed exactly as in LekMod's own picker.
local function availableBanChoices(playerID, slotIndex)
    local taken = {}
    if type(Draft_GetTakenBans) == "function" then
        local ok, result = pcall(Draft_GetTakenBans, nil, { playerID = playerID, slotIndex = slotIndex })
        if ok and result ~= nil then
            taken = result
        else
            Log.error("LekModDraft: Draft_GetTakenBans failed: " .. tostring(result))
        end
    end
    local rows = {}
    for _, row in ipairs(CivDetails.playableRows()) do
        if taken[row.ID] == nil then
            rows[#rows + 1] = row
        end
    end
    return rows
end

-- Commit one ban. LekMod applies it against g_PendingBan, the slot its own
-- picker was opened for, so the slot is named the same way a click would name
-- it. When another player claimed the civ while we were choosing, LekMod
-- clears the slot instead of setting it, and says nothing -- compare the slot
-- before and after so the player is told rather than left with a ban that
-- quietly went missing.
local function applyBan(playerID, slotIndex, civID)
    if not canEditBans(playerID) then
        return
    end
    g_PendingBan = { playerID = playerID, slotIndex = slotIndex }
    local ok, err = pcall(Draft_ApplyBanSelection, civID)
    if not ok then
        g_PendingBan = nil
        Log.error("LekModDraft: Draft_ApplyBanSelection failed: " .. tostring(err))
        return
    end
    if civID ~= nil and civID >= 0 and banAt(playerID, slotIndex) ~= civID then
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_DRAFT_BAN_TAKEN", civShortLabel(civID) or ""))
    end
end

-- Children of one ban slot: clear (when the slot holds a civ) then every
-- available civ. Rebuilt on each drill, so a civ another player banned in the
-- meantime is already gone from the list.
local function banChoiceItems(playerID, slotIndex)
    local items = {}
    if banAt(playerID, slotIndex) ~= nil then
        items[#items + 1] = BaseMenuItems.Choice({
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_BAN_CLEAR",
            activate = function()
                applyBan(playerID, slotIndex, -1)
            end,
        })
    end
    for _, row in ipairs(availableBanChoices(playerID, slotIndex)) do
        local civID = row.ID
        items[#items + 1] = BaseMenuItems.Choice({
            -- By ID rather than from the row: the list is rebuilt every time
            -- the slot is opened, and the by-ID labels are built once for the
            -- whole Context instead of re-querying four tables per civ.
            labelText = civDetailLabel(civID) or tostring(civID),
            selectedFn = function()
                return banAt(playerID, slotIndex) == civID
            end,
            activate = function()
                applyBan(playerID, slotIndex, civID)
            end,
        })
    end
    return items
end

-- One item per ban slot while the slots are yours to set: each drills into the
-- civ list, and an empty one says so rather than carrying a slot number
-- nobody needs (bans are a set; which box holds which civ means nothing).
-- Read-only, the empty slots are dropped entirely and each ban that was made
-- becomes a line carrying the full civ detail.
local function banSlotItems(playerID)
    local items = {}
    local editable = canEditBans(playerID)
    for i = 1, bansPerPlayer() do
        local slotIndex = i
        if editable then
            items[#items + 1] = BaseMenuItems.Group({
                labelFn = function()
                    local civID = banAt(playerID, slotIndex)
                    if civID == nil then
                        return Text.key("TXT_KEY_CIVVACCESS_DRAFT_BAN_CHOOSE")
                    end
                    return civShortLabel(civID) or tostring(civID)
                end,
                itemsFn = function()
                    return banChoiceItems(playerID, slotIndex)
                end,
                cached = false,
            })
        else
            local civID = banAt(playerID, slotIndex)
            if civID ~= nil then
                items[#items + 1] = BaseMenuItems.Text({ labelText = civDetailLabel(civID) or tostring(civID) })
            end
        end
    end
    return items
end

-- Hand ----------------------------------------------------------------

-- One item per civ in a player's dealt hand. Activating picks that civ, the
-- call LekMod's own hand icons make. Where you cannot pick, the entries stay
-- listed and read-only: every hand in the lobby is public, and the detail is
-- what a sighted player gets from hovering the icon.
local function handItems(playerID)
    local pool = poolFor(playerID)
    if pool == nil then
        return {}
    end
    local canPick = ask("canSelectDraftCiv", false, playerID) == true
    local items = {}
    for _, id in ipairs(pool) do
        local civID = id
        local label = civDetailLabel(civID) or tostring(civID)
        if canPick then
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
                selectedFn = function()
                    return PreGame.GetCivilization(playerID) == civID
                end,
                activate = function()
                    drive("Draft_OnDraftCivIconClicked", Draft_OnDraftCivIconClicked, playerID, civID)
                end,
            })
        else
            items[#items + 1] = BaseMenuItems.Text({ labelText = label })
        end
    end
    return items
end

-- Swap ----------------------------------------------------------------

-- Draft-pool swaps are mutual: you request one against another player and it
-- completes when they request you back. Against an AI or an unclaimed
-- Human Required seat there is nobody to answer, so LekMod swaps immediately.
-- The label carries which way a pending request points, since that is the
-- whole state of the flow and the screen shows it only as a pulsing glow.
local function swapItem(playerID)
    local function pending()
        if type(g_DraftSwapDesire) ~= "table" then
            return nil
        end
        if g_DraftSwapDesire[playerID] == localID() then
            return "incoming"
        end
        if g_DraftSwapDesire[localID()] == playerID then
            return "outgoing"
        end
        return nil
    end
    return BaseMenuItems.Choice({
        labelFn = function()
            local state = pending()
            if state == "incoming" then
                return Text.key("TXT_KEY_CIVVACCESS_DRAFT_SWAP_ACCEPT")
            elseif state == "outgoing" then
                return Text.key("TXT_KEY_CIVVACCESS_DRAFT_SWAP_CANCEL")
            end
            return Text.key("TXT_KEY_CIVVACCESS_DRAFT_SWAP_REQUEST")
        end,
        disabledFn = function()
            return isHistoryOnly() or PreGame.IsHotSeatGame() or gameReadyLock() or not isParticipant(playerID)
        end,
        activate = function()
            drive("Draft_OnBanSwapClick", Draft_OnBanSwapClick, playerID)
        end,
    })
end

-- Item builders -------------------------------------------------------

-- Your own bans and hand, hoisted to the top of the Players tab. The hand
-- group drops out on its own until a draft is dealt.
function LekModDraft.localItems()
    if not LekModDraft.present() then
        return {}
    end
    local pid = localID()
    local items = {}

    items[#items + 1] = BaseMenuItems.Group({
        labelFn = function()
            local summary = banSummary(pid)
            if summary == nil then
                return Text.key("TXT_KEY_CIVVACCESS_DRAFT_YOUR_BANS")
            end
            return Text.format("TXT_KEY_CIVVACCESS_DRAFT_YOUR_BANS_VALUE", summary)
        end,
        itemsFn = function()
            local children = banSlotItems(pid)
            -- Both widgets are LekMod's own, so they carry their own enabled
            -- and hidden state: the ready box locks while a draft is dealt,
            -- and handing bans to the host is a non-host action that
            -- disappears for the host and once the draft is made.
            children[#children + 1] = BaseMenuItems.Checkbox({
                controlName = "BanHostReadyCheck",
                textKey = "TXT_KEY_CIVVACCESS_DRAFT_BANS_READY",
            })
            children[#children + 1] = BaseMenuItems.Button({
                controlName = "BanHostDelegateButton",
                labelFn = function()
                    if g_DraftBanHostControl ~= nil and g_DraftBanHostControl[pid] == true then
                        return Text.key("TXT_KEY_CIVVACCESS_DRAFT_RECLAIM_BANS")
                    end
                    return Text.key("TXT_KEY_CIVVACCESS_DRAFT_DELEGATE_BANS")
                end,
                activate = function()
                    drive("Draft_OnDelegateBanControl", Draft_OnDelegateBanControl)
                end,
            })
            return children
        end,
        cached = false,
    })

    items[#items + 1] = BaseMenuItems.Group({
        labelFn = function()
            local summary = handSummary(pid)
            if summary == nil then
                return Text.key("TXT_KEY_CIVVACCESS_DRAFT_YOUR_HAND")
            end
            return Text.format("TXT_KEY_CIVVACCESS_DRAFT_YOUR_HAND_VALUE", summary)
        end,
        itemsFn = function()
            return handItems(pid)
        end,
        cached = false,
    })

    return items
end

-- Draft state for one other seat, appended to that seat's existing group.
function LekModDraft.slotChildren(playerID)
    if not LekModDraft.present() or playerID == nil or playerID < 0 then
        return {}
    end
    if playerID == localID() or not isParticipant(playerID) then
        return {}
    end
    local items = {}

    items[#items + 1] = BaseMenuItems.Group({
        labelFn = function()
            local summary = banSummary(playerID)
            if summary == nil then
                return Text.key("TXT_KEY_CIVVACCESS_DRAFT_BANS")
            end
            return Text.format("TXT_KEY_CIVVACCESS_DRAFT_BANS_VALUE", summary)
        end,
        itemsFn = function()
            return banSlotItems(playerID)
        end,
        cached = false,
    })

    items[#items + 1] = BaseMenuItems.Group({
        labelFn = function()
            local summary = handSummary(playerID)
            if summary == nil then
                return Text.key("TXT_KEY_CIVVACCESS_DRAFT_HAND")
            end
            return Text.format("TXT_KEY_CIVVACCESS_DRAFT_HAND_VALUE", summary)
        end,
        itemsFn = function()
            return handItems(playerID)
        end,
        cached = false,
    })

    if isLocked() then
        items[#items + 1] = swapItem(playerID)
    end

    return items
end

-- Draft tab -----------------------------------------------------------

-- Where the draft has got to, in the words a player would use to ask.
local function phaseText()
    if isHistoryOnly() then
        return Text.key("TXT_KEY_CIVVACCESS_DRAFT_PHASE_HISTORY")
    end
    if gameReadyLock() then
        return Text.key("TXT_KEY_CIVVACCESS_DRAFT_PHASE_GAME_READY")
    end
    if isLocked() then
        return Text.key("TXT_KEY_CIVVACCESS_DRAFT_PHASE_DEALT")
    end
    return Text.key("TXT_KEY_CIVVACCESS_DRAFT_PHASE_BANNING")
end

-- Ban readiness for every human seat, so "who are we waiting for" is one place
-- rather than a walk through the roster. AI and unclaimed seats are absent:
-- they never hold the draft up.
local function readinessItems()
    local order = ask("humanOrder", nil)
    if type(order) ~= "table" then
        return {}
    end
    local items = {}
    for _, pid in ipairs(order) do
        local playerID = pid
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                local ready = g_DraftBanReady ~= nil and g_DraftBanReady[playerID] == true
                return Text.format(
                    "TXT_KEY_CIVVACCESS_DRAFT_READINESS_ROW",
                    playerName(playerID),
                    Text.key(
                        ready and "TXT_KEY_CIVVACCESS_DRAFT_STATUS_READY" or "TXT_KEY_CIVVACCESS_DRAFT_STATUS_CHOOSING"
                    )
                )
            end,
        })
    end
    return items
end

-- Host actions. LekMod hides these buttons off its own players page, so they
-- are driven as plain choices rather than bound to controls that would be
-- invisible (and so unreachable) from our Draft tab; each entry point
-- re-checks its own preconditions anyway. A non-host gets no entries at all
-- rather than a row of permanently disabled ones.
local function hostActionItems()
    if not Matchmaking.IsHost() or isHistoryOnly() then
        return {}
    end
    local items = {}
    items[#items + 1] = BaseMenuItems.Choice({
        textKey = "TXT_KEY_CIVVACCESS_DRAFT_CREATE",
        tooltipKey = "TXT_KEY_CIVVACCESS_DRAFT_CREATE_TT",
        disabledFn = function()
            if isLocked() or gameReadyLock() then
                return true
            end
            return type(Draft_AllHumansBanReady) ~= "function" or Draft_AllHumansBanReady() ~= true
        end,
        activate = function()
            drive("Draft_OnCreateDraft", Draft_OnCreateDraft)
        end,
    })
    items[#items + 1] = BaseMenuItems.Choice({
        textKey = "TXT_KEY_CIVVACCESS_DRAFT_RESET",
        tooltipKey = "TXT_KEY_CIVVACCESS_DRAFT_RESET_TT",
        disabledFn = gameReadyLock,
        activate = function()
            drive("Draft_OnResetDraft", Draft_OnResetDraft)
        end,
    })
    -- Restore is offered only once a draft has been made and cleared; before
    -- that there is nothing to restore and LekMod hides the button too.
    local snapshot = g_PreviousDraftSnapshot
    if snapshot ~= nil and snapshot.pools ~= nil then
        items[#items + 1] = BaseMenuItems.Choice({
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_RESTORE",
            tooltipKey = "TXT_KEY_CIVVACCESS_DRAFT_RESTORE_TT",
            disabledFn = function()
                if gameReadyLock() then
                    return true
                end
                -- A draft cannot be restored onto more seats than it was dealt
                -- for; LekMod says so through a tooltip on a disabled button.
                local order = ask("draftOrder", nil)
                local count = type(order) == "table" and #order or 0
                return count > (tonumber(snapshot.participantCount) or 0)
            end,
            activate = function()
                drive("Draft_OnRestorePreviousDraft", Draft_OnRestorePreviousDraft)
            end,
        })
    end
    return items
end

-- The Draft tab: the phase, who it waits on, the rules, and the host's
-- controls. The rules widgets are LekMod's own, so a non-host reaches them
-- read-only (the engine disables them) and still hears every setting. Each
-- numeric rule is a slider over LekMod's pulldown: every one of them is a
-- short run of numbers the host nudges, and the values stay LekMod's, so a
-- range it changes upstream needs nothing here.
function LekModDraft.tabItems()
    if not LekModDraft.present() then
        return {}
    end
    local items = {
        BaseMenuItems.Text({ labelFn = phaseText }),
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_READINESS",
            itemsFn = readinessItems,
            cached = false,
        }),
        BaseMenuItems.PulldownSlider({
            controlName = "DraftBansPull",
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_BANS",
        }),
        BaseMenuItems.PulldownSlider({
            controlName = "DraftPicksPull",
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_PICKS",
        }),
        BaseMenuItems.PulldownSlider({
            controlName = "DraftCoastalsPull",
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_COASTALS",
            tooltipKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_COASTALS_TT",
        }),
        BaseMenuItems.PulldownSlider({
            controlName = "DraftInlandsPull",
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_INLANDS",
            tooltipKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_INLANDS_TT",
        }),
        BaseMenuItems.Checkbox({
            controlName = "DraftVanillaCheck",
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_VANILLA",
        }),
        BaseMenuItems.Checkbox({
            controlName = "DraftSeasonalCheck",
            textKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_SEASONAL",
            tooltipKey = "TXT_KEY_CIVVACCESS_DRAFT_RULE_SEASONAL_TT",
        }),
    }
    for _, item in ipairs(hostActionItems()) do
        items[#items + 1] = item
    end
    return items
end

-- Remote changes ------------------------------------------------------

-- LekMod syncs the draft as chat packets, applied in Draft_HandleProtocol and
-- shown only as redrawn icons and colour changes. Wrapping it is what turns a
-- remote change into speech; the state is already applied by the time we run,
-- so the announcement reads the new value rather than guessing from the
-- packet.
--
-- Ban edits are deliberately silent: every player broadcasts on every change
-- to every ban, and reading those out would bury the lobby. So are the draft
-- being created, reset and restored -- the host broadcasts a chat
-- announcement for each of those, which the chat listener already speaks, and
-- saying it twice is worse than saying it once in LekMod's own words. What is
-- left is what LekMod says nothing about: readiness, a swap aimed at you, and
-- a swap going through.

-- A ban readied is the ban phase's only real progress signal. The diff covers
-- the host replaying other players' readiness to a client that just joined,
-- which is the one burst worth hearing: it says who the lobby is waiting for.
local function announceReadyDeltas(priorReady)
    if type(g_DraftBanReady) ~= "table" then
        return
    end
    local me = localID()
    for pid, ready in pairs(g_DraftBanReady) do
        if ready == true and priorReady[pid] ~= true and pid ~= me then
            SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_DRAFT_READY_ANNOUNCE", playerName(pid)))
        end
    end
end

-- A swap request aimed at you is the one packet that asks the player to act,
-- and the screen carries it only as a pulsing highlight. A request pointed
-- somewhere else, or one being withdrawn, stays quiet.
local function announceSwapDeltas(priorDesire)
    if type(g_DraftSwapDesire) ~= "table" then
        return
    end
    local me = localID()
    for pid, target in pairs(g_DraftSwapDesire) do
        if target == me and priorDesire[pid] ~= me then
            SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_DRAFT_SWAP_WANTED", playerName(pid)))
        end
    end
end

local function snapshotFlags(source)
    local out = {}
    if type(source) == "table" then
        for k, v in pairs(source) do
            out[k] = v
        end
    end
    return out
end

-- A completed swap is the one draft change LekMod broadcasts without saying
-- anything: two hands trade places and the only sign is a different row of
-- icons. The packet names both players, so the one who is not you is who you
-- traded with. Two other players swapping stays quiet.
local function announceSwapCompleted(text)
    local a, b = string.match(text, "^#LDRAFT#SWAP|(%d+)|(%d+)|")
    a, b = tonumber(a), tonumber(b)
    if a == nil or b == nil then
        return
    end
    local me = localID()
    local other
    if a == me then
        other = b
    elseif b == me then
        other = a
    else
        return
    end
    SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_DRAFT_SWAP_DONE", playerName(other)))
end

-- Speak what the packet just changed. Called after LekMod applied it.
function LekModDraft._announceProtocol(before, text)
    announceReadyDeltas(before.ready)
    announceSwapDeltas(before.desire)
    if type(text) == "string" then
        announceSwapCompleted(text)
    end
end

-- Re-wrapping is keyed on the live function, not a flag: a Context re-init
-- redefines Draft_HandleProtocol from a fresh chunk, and a flag would leave
-- that fresh copy unwrapped and the draft silent for the rest of the session.
function LekModDraft.installAnnounce()
    if not LekModDraft.present() or type(Draft_HandleProtocol) ~= "function" then
        return
    end
    if Draft_HandleProtocol == civvaccess_shared._lekmodDraftProtocolWrapper then
        return
    end
    local prior = Draft_HandleProtocol
    local wrapped = function(fromPlayer, text)
        local before = {
            ready = snapshotFlags(g_DraftBanReady),
            desire = snapshotFlags(g_DraftSwapDesire),
        }
        local result = prior(fromPlayer, text)
        local ok, err = pcall(LekModDraft._announceProtocol, before, text)
        if not ok then
            Log.error("LekModDraft: draft announcement failed: " .. tostring(err))
        end
        return result
    end
    civvaccess_shared._lekmodDraftProtocolWrapper = wrapped
    Draft_HandleProtocol = wrapped
end

-- Test seams.
LekModDraft._banSummary = banSummary
LekModDraft._handSummary = handSummary
LekModDraft._applyBan = applyBan
LekModDraft._banSlotItems = banSlotItems

-- JoiningRoom accessibility wiring. Status splash during multiplayer
-- handshake; no buttons, but Controls.JoiningLabel changes as each phase
-- completes (room join -> host connect -> net registered). Dynamic
-- preamble reads the live label; refresh() runs on the three progress
-- events.
--
-- Ordering matters: the game's own OnJoinRoomComplete / OnHostConnect /
-- OnNetRegistered handlers are the ones that actually update the label,
-- and they're installed inside the game's ShowHideHandler on first show.
-- We wrap priorShowHide so our Events.X.Add calls happen AFTER the game
-- registers its handlers; .Add chains, so our listener then fires after
-- the game's and reads the updated label.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

-- File-scope local guard rather than civvaccess_shared. A flag on
-- civvaccess_shared persists across Context re-inits and would lock the
-- mod to a stranded prior-Context listener (CLAUDE.md "no install-once
-- guards" rationale); this local lives only in the current Context's
-- env, so a re-include rebuilds it as false and re-installs fresh
-- listeners. Each show within one Context lifetime still installs only
-- once (the listeners persist on Events.X for the life of this env).
local listenersInstalled = false

local function wrappedPriorShowHide(bIsHide, bIsInit)
    priorShowHide(bIsHide, bIsInit)
    if bIsHide then
        return
    end
    if listenersInstalled then
        return
    end
    listenersInstalled = true
    local doRefresh = Log.safeListener("JoiningRoomAccess.refresh", function()
        local h = civvaccess_shared._joiningRoomHandler
        if h == nil then
            return
        end
        h.refresh()
    end)
    Log.installEvent(Events, "MultiplayerJoinRoomComplete", doRefresh, "JoiningRoomAccess")
    Log.installEvent(Events, "ConnectedToNetworkHost", doRefresh, "JoiningRoomAccess")
    Log.installEvent(Events, "MultiplayerNetRegistered", doRefresh, "JoiningRoomAccess")
end

civvaccess_shared._joiningRoomHandler = BaseMenu.install(ContextPtr, {
    name = "JoiningRoom",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_JOINING_ROOM"),
    preamble = function()
        return Text.controlText(Controls.JoiningLabel, "JoiningRoomAccess")
    end,
    priorShowHide = wrappedPriorShowHide,
    priorInput = priorInput,
    items = {},
})

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

local function wrappedPriorShowHide(bIsHide, bIsInit)
    priorShowHide(bIsHide, bIsInit)
    if bIsHide then
        return
    end
    if civvaccess_shared._joiningRoomListenersInstalled then
        return
    end
    civvaccess_shared._joiningRoomListenersInstalled = true
    local function doRefresh()
        local h = civvaccess_shared._joiningRoomHandler
        if h == nil then
            return
        end
        local ok, err = pcall(function()
            h.refresh()
        end)
        if not ok then
            Log.error("JoiningRoomAccess refresh: " .. tostring(err))
        end
    end
    Events.MultiplayerJoinRoomComplete.Add(doRefresh)
    Events.ConnectedToNetworkHost.Add(doRefresh)
    Events.MultiplayerNetRegistered.Add(doRefresh)
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

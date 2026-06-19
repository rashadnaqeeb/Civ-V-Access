-- CCVotePopup accessibility (LekMod only). LekMod's MP voting system opens
-- this target picker via LuaEvents.MPProposeCCButtonPress when the local
-- player proposes a "condemn" vote: a scrollable list of the other human
-- major players, click one to cast the proposal at them
-- (Network.SendGiftUnit(target, -3)). The Context is a LekMod UI addin; this
-- file never loads on a vanilla / VP install.
--
-- We expose the same target list as selectable items. The list is context-
-- free (it enumerates eligible players, not popup data), so onShow rebuilds
-- it from live state every time the picker opens. The base OnClose global
-- dequeues the popup.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Mirrors the base enumeration: other human, alive, major players (the base
-- excludes the local player's own team), most-recent label rules collapsed to
-- the nickname (network MP) or the leader name.
local function buildItems()
    local items = {}
    local pActive = Players[Game.GetActivePlayer()]
    local activeTeam = pActive:GetTeam()
    for iTeam = 0, GameDefines.MAX_CIV_TEAMS - 1 do
        local pTeam = Teams[iTeam]
        if pTeam ~= nil and iTeam ~= activeTeam then
            local iPlayer = pTeam:GetLeaderID()
            local pPlayer = Players[iPlayer]
            if pPlayer ~= nil and pPlayer:IsAlive() and pPlayer:IsHuman() and not pPlayer:IsMinorCiv() then
                local label
                if pPlayer:GetNickName() ~= "" and Game:IsNetworkMultiPlayer() then
                    label = pPlayer:GetNickName()
                else
                    label = Text.key(GameInfo.Leaders[pPlayer:GetLeaderType()].Description)
                end
                items[#items + 1] = BaseMenuItems.Choice({
                    labelText = label,
                    activate = function()
                        Network.SendGiftUnit(iPlayer, -3)
                        OnClose()
                    end,
                })
            end
        end
    end
    return items
end

BaseMenu.install(ContextPtr, {
    name = "CCVotePopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CC_VOTE"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = function(handler)
        handler.setItems(buildItems())
    end,
    items = {},
})

-- Shared player / team / civ-name helpers for the cross-civ overview popups
-- (Demographics, VictoryProgress, CultureOverview). All three present civ
-- rows whose label honors the same vanilla SetCivName branches: unmet civs
-- read as "Unknown Civilization" (so the sighted "?" icon maps to a
-- speakable noun phrase), nicknamed humans read by nickname in MP, the
-- active player reads as "you", and other met civs read by leader name +
-- civ short description.
--
-- Pure functions, no captured state. Safe across load-from-game env wipe:
-- Popup Contexts each re-run their include chain when the engine
-- re-initializes them, and these functions resolve their own globals at
-- call time within whichever Context's env is active.

OverviewCivLabels = {}

function OverviewCivLabels.activePlayerId()
    return Game.GetActivePlayer()
end

function OverviewCivLabels.activePlayer()
    return Players[Game.GetActivePlayer()]
end

function OverviewCivLabels.activeTeamId()
    return Game.GetActiveTeam()
end

function OverviewCivLabels.activeTeam()
    return Teams[Game.GetActiveTeam()]
end

function OverviewCivLabels.isMP()
    return Game:IsNetworkMultiPlayer()
end

-- Vanilla treats network-multiplayer as universally-met for naming purposes
-- (no fog-of-war on player identity in MP). Single-player respects the
-- team's IsHasMet flag.
function OverviewCivLabels.playerHasMet(pPlayer)
    return Teams[pPlayer:GetTeam()]:IsHasMet(Game.GetActiveTeam())
        or OverviewCivLabels.isMP()
end

-- "Augustus of Rome" / "You of Rome" / "Unknown Civilization". Mirrors the
-- met / unmet / nickname / active-player branches of vanilla SetCivName.
function OverviewCivLabels.civDisplayName(pPlayer)
    if not OverviewCivLabels.playerHasMet(pPlayer) then
        return Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    local civInfo = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
    local strPlayer
    local nick = pPlayer:GetNickName()
    if nick ~= "" and OverviewCivLabels.isMP() then
        strPlayer = nick
    elseif pPlayer:GetID() == OverviewCivLabels.activePlayerId() then
        strPlayer = Text.key("TXT_KEY_POP_VOTE_RESULTS_YOU")
    else
        strPlayer = pPlayer:GetNameKey()
    end
    return Text.format("TXT_KEY_RANDOM_LEADER_CIV", strPlayer, civInfo.ShortDescription)
end

return OverviewCivLabels

-- Spoken leader descriptions. Civ V's diplo screens (LeaderHeadRoot,
-- DiscussionDialog, DiploTrade) show the AI leader in their animated
-- form; sighted players see the setting, dress, and symbolism; blind
-- players have no visual fallback. F2 on those screens calls
-- LeaderDescription.speakFor(iPlayer) to read a prose description of
-- the leader's portrait, keyed off Leaders.Type (Leaders table in
-- GameInfo). String entries live in CivVAccess_InGameStrings_en_US
-- under TXT_KEY_CIVVACCESS_LEADER_DESC_<LEADER_TYPE>.

LeaderDescription = {}

local function typeForPlayer(iPlayer)
    local player = Players[iPlayer]
    if player == nil then
        return nil
    end
    local leaderTypeId = player:GetLeaderType()
    local row = GameInfo.Leaders[leaderTypeId]
    if row == nil then
        return nil
    end
    return row.Type
end

-- Speak the leader description for iPlayer via interrupt. Missing
-- entries (new-leader mods, malformed player id) log a warning and
-- speak a generic fallback so the user always gets feedback on F2.
function LeaderDescription.speakFor(iPlayer)
    if iPlayer == nil or iPlayer < 0 then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"))
        return
    end
    local leaderType = typeForPlayer(iPlayer)
    if leaderType == nil then
        Log.warn("LeaderDescription: no Leaders row for player " .. tostring(iPlayer))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"))
        return
    end
    local key = "TXT_KEY_CIVVACCESS_LEADER_DESC_" .. leaderType
    local desc = Text.keyOrNil(key)
    if desc == nil then
        Log.warn("LeaderDescription: no description for " .. tostring(leaderType))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"))
        return
    end
    SpeechPipeline.speakInterrupt(desc)
end

-- Append an F2 binding + matching help entry to a BaseMenu handler.
-- getPlayerIdFn is called at keypress time so it resolves live state
-- (per CLAUDE.md "Never cache game state"). A screen that captures
-- the iPlayer off Events.AILeaderMessage returns the captured id;
-- DiploTrade returns g_iThem directly.
function LeaderDescription.bindF2(handler, getPlayerIdFn)
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F2 or 113,
        mods = 0,
        description = "Read leader description",
        fn = function()
            local ok, iPlayer = pcall(getPlayerIdFn)
            if not ok then
                Log.error("LeaderDescription: resolver failed: " .. tostring(iPlayer))
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"))
                return
            end
            LeaderDescription.speakFor(iPlayer)
        end,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F2",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC",
    })
end

return LeaderDescription

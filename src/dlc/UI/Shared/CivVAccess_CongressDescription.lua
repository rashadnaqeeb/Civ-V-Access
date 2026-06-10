-- Spoken splash descriptions for the World Congress. LeagueSplash shows a
-- full-screen painting when a special session convenes; LeagueProjectPopup
-- shows one when an international project completes. Sighted players see
-- the scene, blind players have no visual fallback. F2 on those popups
-- calls CongressDescription.speakForType(leagueType) with the
-- LeagueSpecialSessions.Type or LeagueProjects.Type string. String entries
-- live in CivVAccess_CongressDescStrings_en_US under
-- TXT_KEY_CIVVACCESS_CONGRESSDESC_<TYPE>, except where the alias table
-- below routes several types to one shared string. Types without an entry
-- (modded resolutions) speak the fallback so F2 always answers.

CongressDescription = {}

-- Types whose splash art is not their own: the three pre-UN special
-- sessions share one painting (WorldCongress.dds) and resolve to the
-- founding session's key, while the United Nations session and the
-- International Space Station project show the same art as the matching
-- world wonder's splash and resolve to that wonder's description key so
-- the text is written and translated once. The wonder keys require
-- CivVAccess_WonderDescStrings to be included alongside this module.
local keyAliases = {
    LEAGUE_SPECIAL_SESSION_WELCOME_CITY_STATES = "TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_SPECIAL_SESSION_START_WORLD_CONGRESS",
    LEAGUE_SPECIAL_SESSION_LEADERSHIP_COUNCIL = "TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_SPECIAL_SESSION_START_WORLD_CONGRESS",
    LEAGUE_SPECIAL_SESSION_START_UNITED_NATIONS = "TXT_KEY_CIVVACCESS_WONDERDESC_BUILDING_UNITED_NATIONS",
    LEAGUE_PROJECT_INTERNATIONAL_SPACE_STATION = "TXT_KEY_CIVVACCESS_WONDERDESC_BUILDING_INTERNATIONAL_SPACE_STATION",
}

-- Speak the splash description for the session or project whose Type is
-- leagueType. nil means the resolver had no popup state; a missing entry
-- for a real type logs and speaks the fallback.
function CongressDescription.speakForType(leagueType)
    if leagueType == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CONGRESSDESC_MISSING"))
        return
    end
    local key = keyAliases[leagueType] or ("TXT_KEY_CIVVACCESS_CONGRESSDESC_" .. leagueType)
    local desc = Text.keyOrNil(key)
    if desc == nil then
        Log.warn("CongressDescription: no description for " .. tostring(leagueType))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CONGRESSDESC_MISSING"))
        return
    end
    SpeechPipeline.speakInterrupt(desc)
end

-- Append an F2 binding + matching help entry to a BaseMenu handler.
-- getTypeFn is called at keypress time so it resolves live state (per
-- CLAUDE.md "Never cache game state"); it returns the session's or
-- project's Type string, else nil.
function CongressDescription.bindF2(handler, getTypeFn)
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F2 or 113,
        mods = 0,
        description = "Describe congress splash",
        fn = function()
            local ok, leagueType = pcall(getTypeFn)
            if not ok then
                Log.error("CongressDescription: resolver failed: " .. tostring(leagueType))
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CONGRESSDESC_MISSING"))
                return
            end
            CongressDescription.speakForType(leagueType)
        end,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F2",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_IMAGE_DESC",
    })
end

return CongressDescription

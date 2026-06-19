-- Spoken background descriptions for the end-of-game screen. EndGameMenu
-- fills the screen with one of six full-frame paintings (one per victory
-- type, plus defeat); sighted players see the scene, blind players have
-- no visual fallback. F2 on that screen calls
-- VictoryDescription.speakForKey(artKey) to read a short prose
-- description of the painting. String entries live in
-- CivVAccess_VictoryDescStrings_en_US under
-- TXT_KEY_CIVVACCESS_VICTORYDESC_<KEY>, keyed by the Victories table
-- Type plus DEFEAT for the loss art (which has no Victories row).

VictoryDescription = {}

-- Some victory backgrounds reuse an existing wonder splash rather than a
-- bespoke painting (LekMod's scrap victory shows the Cristo Redentor art), so
-- describe them with that wonder's own image description instead of
-- duplicating the prose. Maps a Victories Type to a WONDERDESC string key.
local REUSED_WONDER_ART = {
    VICTORY_SCRAP = "TXT_KEY_CIVVACCESS_WONDERDESC_BUILDING_CRISTO_REDENTOR",
}

-- Speak the background description for artKey (a Victories Type or
-- "DEFEAT"). nil means the resolver had no display state; a missing
-- entry for a real key is a data bug and logs.
function VictoryDescription.speakForKey(artKey)
    if artKey == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_VICTORYDESC_MISSING"))
        return
    end
    local desc = Text.keyOrNil("TXT_KEY_CIVVACCESS_VICTORYDESC_" .. artKey)
    if desc == nil and REUSED_WONDER_ART[artKey] ~= nil then
        desc = Text.keyOrNil(REUSED_WONDER_ART[artKey])
    end
    if desc == nil then
        Log.warn("VictoryDescription: no description for " .. tostring(artKey))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_VICTORYDESC_MISSING"))
        return
    end
    SpeechPipeline.speakInterrupt(desc)
end

-- Append an F2 binding + matching help entry to a BaseMenu handler.
-- getKeyFn is called at keypress time so it resolves live state (per
-- CLAUDE.md "Never cache game state"); it returns the art key of the
-- displayed background, else nil.
function VictoryDescription.bindF2(handler, getKeyFn)
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F2 or 113,
        mods = 0,
        description = "Describe victory screen art",
        fn = function()
            local ok, artKey = pcall(getKeyFn)
            if not ok then
                Log.error("VictoryDescription: resolver failed: " .. tostring(artKey))
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_VICTORYDESC_MISSING"))
                return
            end
            VictoryDescription.speakForKey(artKey)
        end,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F2",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_IMAGE_DESC",
    })
end

return VictoryDescription

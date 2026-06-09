-- Spoken portrait descriptions for natural wonders. The NaturalWonderPopup
-- shows the wonder's portrait art; sighted players see the scene, blind
-- players have no visual fallback. F2 on that popup calls
-- NaturalWonderDescription.speakForType(featureType) to read a short prose
-- description of the portrait, keyed off Features.Type. String entries
-- live in CivVAccess_NaturalWonderDescStrings_en_US under
-- TXT_KEY_CIVVACCESS_NWDESC_<FEATURE_TYPE>. Wonders without an entry
-- (new-wonder mods) speak the fallback so F2 always answers.

NaturalWonderDescription = {}

-- Speak the portrait description for the Features row whose Type is
-- featureType. nil means the resolver had no popup state; a missing entry
-- for a real wonder logs and speaks the fallback.
function NaturalWonderDescription.speakForType(featureType)
    if featureType == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_NWDESC_MISSING"))
        return
    end
    local desc = Text.keyOrNil("TXT_KEY_CIVVACCESS_NWDESC_" .. featureType)
    if desc == nil then
        Log.warn("NaturalWonderDescription: no description for " .. tostring(featureType))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_NWDESC_MISSING"))
        return
    end
    SpeechPipeline.speakInterrupt(desc)
end

-- Append an F2 binding + matching help entry to a BaseMenu handler.
-- getTypeFn is called at keypress time so it resolves live state (per
-- CLAUDE.md "Never cache game state"); it returns the Features.Type
-- string of the displayed wonder, else nil.
function NaturalWonderDescription.bindF2(handler, getTypeFn)
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F2 or 113,
        mods = 0,
        description = "Describe wonder portrait",
        fn = function()
            local ok, featureType = pcall(getTypeFn)
            if not ok then
                Log.error("NaturalWonderDescription: resolver failed: " .. tostring(featureType))
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_NWDESC_MISSING"))
                return
            end
            NaturalWonderDescription.speakForType(featureType)
        end,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F2",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_IMAGE_DESC",
    })
end

return NaturalWonderDescription

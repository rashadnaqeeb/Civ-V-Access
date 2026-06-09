-- Spoken painting descriptions for great works of art. The GreatWorkPopup
-- shows the artwork itself; sighted players see the painting, blind
-- players have no visual fallback. F2 on that popup calls
-- GreatWorkDescription.speakForType(gwType) to read a short prose
-- description of the painting, keyed off GreatWorks.Type. String entries
-- live in CivVAccess_GreatWorkDescStrings_en_US under
-- TXT_KEY_CIVVACCESS_GWDESC_<GREAT_WORK_TYPE>. Only GREAT_WORK_ART class
-- works have descriptions; writing, music, and artifacts speak the
-- fallback so F2 always answers.

GreatWorkDescription = {}

-- Speak the painting description for the GreatWorks row whose Type is
-- gwType. nil means the displayed work is not a great work of art (or the
-- resolver had no popup state); a missing entry for a real art type is a
-- data bug and logs.
function GreatWorkDescription.speakForType(gwType)
    if gwType == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_GWDESC_MISSING"))
        return
    end
    local desc = Text.keyOrNil("TXT_KEY_CIVVACCESS_GWDESC_" .. gwType)
    if desc == nil then
        Log.warn("GreatWorkDescription: no description for " .. tostring(gwType))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_GWDESC_MISSING"))
        return
    end
    SpeechPipeline.speakInterrupt(desc)
end

-- Append an F2 binding + matching help entry to a BaseMenu handler.
-- getTypeFn is called at keypress time so it resolves live state (per
-- CLAUDE.md "Never cache game state"); it returns the GreatWorks.Type
-- string when the displayed work is a great work of art, else nil.
function GreatWorkDescription.bindF2(handler, getTypeFn)
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F2 or 113,
        mods = 0,
        description = "Describe painting",
        fn = function()
            local ok, gwType = pcall(getTypeFn)
            if not ok then
                Log.error("GreatWorkDescription: resolver failed: " .. tostring(gwType))
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_GWDESC_MISSING"))
                return
            end
            GreatWorkDescription.speakForType(gwType)
        end,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F2",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_IMAGE_DESC",
    })
end

return GreatWorkDescription

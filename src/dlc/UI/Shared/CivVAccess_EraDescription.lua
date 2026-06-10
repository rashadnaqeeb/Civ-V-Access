-- Spoken splash descriptions for era changes. NewEraPopup shows a wide
-- banner painting when a new era begins; sighted players see the scene,
-- blind players have no visual fallback. F2 on that popup calls
-- EraDescription.speakForType(eraType) to read a short prose description
-- of the painting, keyed off Eras.Type. String entries live in
-- CivVAccess_EraDescStrings_en_US under
-- TXT_KEY_CIVVACCESS_ERADESC_<ERA_TYPE>. Eras without an entry (modded
-- eras; the popup never fires for ERA_ANCIENT) speak the fallback so F2
-- always answers.

EraDescription = {}

-- Speak the splash description for the Eras row whose Type is eraType.
-- nil means the resolver had no popup state; a missing entry for a real
-- era logs and speaks the fallback.
function EraDescription.speakForType(eraType)
    if eraType == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_ERADESC_MISSING"))
        return
    end
    local desc = Text.keyOrNil("TXT_KEY_CIVVACCESS_ERADESC_" .. eraType)
    if desc == nil then
        Log.warn("EraDescription: no description for " .. tostring(eraType))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_ERADESC_MISSING"))
        return
    end
    SpeechPipeline.speakInterrupt(desc)
end

-- Append an F2 binding + matching help entry to a BaseMenu handler.
-- getTypeFn is called at keypress time so it resolves live state (per
-- CLAUDE.md "Never cache game state"); it returns the Eras.Type string of
-- the era just entered, else nil.
function EraDescription.bindF2(handler, getTypeFn)
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F2 or 113,
        mods = 0,
        description = "Describe era splash",
        fn = function()
            local ok, eraType = pcall(getTypeFn)
            if not ok then
                Log.error("EraDescription: resolver failed: " .. tostring(eraType))
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_ERADESC_MISSING"))
                return
            end
            EraDescription.speakForType(eraType)
        end,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F2",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_IMAGE_DESC",
    })
end

return EraDescription

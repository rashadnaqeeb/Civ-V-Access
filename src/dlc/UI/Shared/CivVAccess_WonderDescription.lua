-- Spoken splash descriptions for world wonders. The WonderPopup shows the
-- wonder's full-scene splash painting on completion; sighted players see
-- the scene, blind players have no visual fallback. F2 on that popup calls
-- WonderDescription.speakForType(buildingType) to read a short prose
-- description of the painting, keyed off Buildings.Type. String entries
-- live in CivVAccess_WonderDescStrings_en_US under
-- TXT_KEY_CIVVACCESS_WONDERDESC_<BUILDING_TYPE>. Wonders without an entry
-- (new-wonder mods) speak the fallback so F2 always answers.

WonderDescription = {}

-- Speak the splash description for the Buildings row whose Type is
-- buildingType. nil means the resolver had no popup state; a missing entry
-- for a real wonder logs and speaks the fallback.
function WonderDescription.speakForType(buildingType)
    if buildingType == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_WONDERDESC_MISSING"))
        return
    end
    local desc = Text.keyOrNil("TXT_KEY_CIVVACCESS_WONDERDESC_" .. buildingType)
    if desc == nil then
        Log.warn("WonderDescription: no description for " .. tostring(buildingType))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_WONDERDESC_MISSING"))
        return
    end
    SpeechPipeline.speakInterrupt(desc)
end

-- Append an F2 binding + matching help entry to a BaseMenu handler.
-- getTypeFn is called at keypress time so it resolves live state (per
-- CLAUDE.md "Never cache game state"); it returns the Buildings.Type
-- string of the completed wonder, else nil.
function WonderDescription.bindF2(handler, getTypeFn)
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F2 or 113,
        mods = 0,
        description = "Describe wonder splash",
        fn = function()
            local ok, buildingType = pcall(getTypeFn)
            if not ok then
                Log.error("WonderDescription: resolver failed: " .. tostring(buildingType))
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_WONDERDESC_MISSING"))
                return
            end
            WonderDescription.speakForType(buildingType)
        end,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F2",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_IMAGE_DESC",
    })
end

return WonderDescription

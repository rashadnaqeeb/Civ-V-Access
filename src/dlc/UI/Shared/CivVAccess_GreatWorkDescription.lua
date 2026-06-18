-- Spoken artwork descriptions for great works. The GreatWorkPopup shows the
-- artwork itself; sighted players see it, blind players have no visual
-- fallback. F2 on that popup calls GreatWorkDescription.speakForType(token)
-- to read a short prose description, where token is GreatWorks.Type for a
-- great work of art (one description per painting) or the class type for
-- writing and music (one shared background image per class). String entries
-- live in CivVAccess_GreatWorkDescStrings_en_US under
-- TXT_KEY_CIVVACCESS_GWDESC_<token>. Art works plus the GREAT_WORK_LITERATURE
-- and GREAT_WORK_MUSIC class backgrounds have descriptions; archaeological
-- artifacts speak the fallback so F2 always answers.

GreatWorkDescription = {}

-- Speak the artwork description for the description token (GreatWorks.Type
-- for art, class type for writing and music). nil means the displayed work
-- has no dedicated image (an artifact) or the resolver had no popup state;
-- a missing entry for a real token is a data bug and logs.
function GreatWorkDescription.speakForType(token)
    if token == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_GWDESC_MISSING"))
        return
    end
    local desc = Text.keyOrNil("TXT_KEY_CIVVACCESS_GWDESC_" .. token)
    if desc == nil then
        Log.warn("GreatWorkDescription: no description for " .. tostring(token))
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_GWDESC_MISSING"))
        return
    end
    SpeechPipeline.speakInterrupt(desc)
end

-- Append an F2 binding + matching help entry to a BaseMenu handler.
-- getTokenFn is called at keypress time so it resolves live state (per
-- CLAUDE.md "Never cache game state"); it returns the description token
-- (GreatWorks.Type for art, class type for writing and music) or nil.
function GreatWorkDescription.bindF2(handler, getTokenFn)
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F2 or 113,
        mods = 0,
        description = "Describe image",
        fn = function()
            local ok, token = pcall(getTokenFn)
            if not ok then
                Log.error("GreatWorkDescription: resolver failed: " .. tostring(token))
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_GWDESC_MISSING"))
                return
            end
            GreatWorkDescription.speakForType(token)
        end,
    }
    BaseMenuHelp.addScreenKey(handler, {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F2",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_IMAGE_DESC",
    })
end

return GreatWorkDescription

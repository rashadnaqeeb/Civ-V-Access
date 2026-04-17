-- Mod-authored localized strings, in-game Context.
-- Looked up by Text.key / Text.format in CivVAccess_Text.lua. Sets a global
-- (rather than returning) so the offline test harness can dofile() it without
-- relying on Civ V's include() semantics.
CivVAccess_Strings = CivVAccess_Strings or {}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"]     = "Civilization V accessibility loaded in-game."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"

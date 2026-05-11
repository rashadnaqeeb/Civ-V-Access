-- Include-chain that every front-end Lua Context needs before it touches
-- Text / Log / SpeechPipeline / HandlerStack / InputRouter. Globals live
-- in per-Context sandboxes (only civvaccess_shared crosses Contexts), so
-- each overridden screen must run this chain in its own Context rather
-- than relying on FrontendBoot's ToolTips-Context setup.
-- include() resolves stems via a lua_State-wide index but executes the
-- file per Context, so the same stems load the same module code into
-- each sandbox.

include("CivVAccess_Log")
-- CivVAccess_Version.lua is generated at deploy / package time from
-- versions.json into UI/InGame/, which the front-end <Skin> directive in
-- CivVAccess_2.Civ5Pkg also includes -- so the stem resolves from front-end
-- Contexts too. Sets civvaccess_shared.version, read by FrontendBoot's
-- TXT_KEY_CIVVACCESS_BOOT_FRONTEND format call. Tests rely on the polyfill's
-- sentinel "test" instead since neither real Context runs in the harness.
include("CivVAccess_Version")
include("CivVAccess_UserPrefs")
include("CivVAccess_AudioCueMode")
include("CivVAccess_Verbosity")
include("CivVAccess_TextFilter")
-- StringsLoader before the en_US strings so loadOverlay is callable as
-- soon as the baseline finishes populating CivVAccess_Strings.
include("CivVAccess_StringsLoader")
include("CivVAccess_FrontEndStrings_en_US")
StringsLoader.loadOverlay("CivVAccess_FrontEndStrings")
include("CivVAccess_PluralRules")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
-- The BaseMenu container file is named with a "Core" suffix to avoid a
-- stem-prefix collision with BaseMenuItems: Civ V's include index drops
-- the shorter of two stems when one is a prefix of the other, leaving the
-- BaseMenu stem unreachable in every Context. "BaseMenuCore" is just a
-- unique stem; the global it defines is still `BaseMenu`. BaseMenuTabs
-- loads first because Core's create() / onActivate call into it; Install
-- loads after because it builds on Core's BaseMenu.create.
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_VolumeControl")
-- BeaconRange / BeaconVolume are in-game-only at the consumer level
-- (Beacons), but the Settings overlay is reachable from front-end via
-- F12, so both modules need to load here for the sliders' get/set/
-- labelFn closures to resolve. Pre-game tweaks persist via Prefs and
-- apply on the first in-game beacon parameter update.
include("CivVAccess_BeaconRange")
include("CivVAccess_BeaconVolume")
include("CivVAccess_Settings")

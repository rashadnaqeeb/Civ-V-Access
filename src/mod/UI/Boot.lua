include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")

Log.info("in-game boot")
SpeechPipeline.speakInterrupt(Locale.ConvertTextKey("TXT_KEY_CIVVACCESS_BOOT_INGAME"))

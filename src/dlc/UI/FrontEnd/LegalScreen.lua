-- Civ V Access: base-game override.
-- Target: Assets/UI/FrontEnd/LegalScreen.{lua,xml}. Contents above the
-- bootstrap marker are a verbatim copy of the base-game file. Re-diff
-- against the base after any Civ V patch. Expansion1/2 ship a cosmetic
-- XML variant (different textures/offsets); the functional controls
-- (ContinueButton, EULAText, text keys) match ours.
-------------------------------------------------
-------------------------------------------------
Controls.ContinueButton:RegisterCallback(Mouse.eLClick, function()
	UIManager:DequeuePopup(ContextPtr);
end);

-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_LegalScreenAccess")

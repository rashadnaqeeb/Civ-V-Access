-- Civ V Access: base-game override.
-- Target: Assets/UI/FrontEnd/LegalScreen.{lua,xml}. Contents above the
-- bootstrap marker are a verbatim copy of the base-game file. BNW does
-- not override this file; our base copy is what loads under the
-- Expansion2 UISkin.
-------------------------------------------------
-------------------------------------------------
Controls.ContinueButton:RegisterCallback(Mouse.eLClick, function()
	UIManager:DequeuePopup(ContextPtr);
end);

-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_LegalScreenAccess")

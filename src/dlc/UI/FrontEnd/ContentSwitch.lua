-- Civ V Access: base-game override.
-- Target: Assets/UI/FrontEnd/ContentSwitch.{lua,xml}. Contents above the
-- bootstrap marker are a verbatim copy of the base-game file. Re-diff
-- against the base after any Civ V patch.
-------------------------------------------------
-- ContentSwitch
-------------------------------------------------

----------------------------------------------------------------
----------------------------------------------------------------
function OnShowHide( isHide, isInit )

	if(not isHide) then

	end
end
ContextPtr:SetShowHideHandler( OnShowHide );


-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_ContentSwitchAccess")

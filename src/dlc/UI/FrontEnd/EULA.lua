-- Civ V Access: base-game override.
-- Target: Assets/UI/FrontEnd/Modding/EULA.{lua,xml}.
-- Flattened to UI/FrontEnd/ because include() resolves by bare filename
-- stem. Contents above the bootstrap marker are a verbatim copy of the
-- base-game file. Re-diff against the base after any Civ V patch.
-------------------------------------------------
-- EULA Screen
-------------------------------------------------
g_HasAcceptedEULA = false;


function OnAccept()
	g_HasAcceptedEULA = true;
	NavigateForward();
end

--------------------------------------------------
-- Navigation Routines
--------------------------------------------------
function NavigateBack()
	UIManager:DequeuePopup( ContextPtr );
end

function NavigateForward()
	UIManager:DequeuePopup(	ContextPtr );
	UIManager:QueuePopup( Controls.ModsBrowser, PopupPriority.ModsBrowserScreen );
end

--------------------------------------------------
-- Explicit Event Handlers
--------------------------------------------------
ContextPtr:SetInputHandler(function(uiMsg, wParam, lParam)

	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_ESCAPE then
			NavigateBack();
		end
	end

	return true;
end);

ContextPtr:SetShowHideHandler(function(isHide)
    --UNCOMMENT THIS BLOCK IF YOU WISH TO ONLY
    --SHOW THE EULA ONCE PER APPLICATION RUN
    --if not isHide and g_HasAcceptedEULA then
	--	NavigateForward();
	--end

	--if(not isHide and g_QueueEulaToHide) then
	--	NavigateBack();
	--end
end);

-- For now, we don't need to track any sort of acknowledgement of the policy.
Controls.AcceptButton:RegisterCallback( Mouse.eLClick, OnAccept);
Controls.DeclineButton:RegisterCallback( Mouse.eLClick, NavigateBack);


-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_EULAAccess")

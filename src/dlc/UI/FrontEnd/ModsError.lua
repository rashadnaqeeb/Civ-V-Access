-- Civ V Access: base-game override.
-- Target: Assets/UI/FrontEnd/Modding/ModsError.{lua,xml}.
-- Flattened to UI/FrontEnd/ because include() resolves by bare filename
-- stem. Contents above the bootstrap marker are a verbatim copy of the
-- base-game file. Re-diff against the base after any Civ V patch.
-------------------------------------------------
-- Mods Error Popup
-------------------------------------------------
include("IconSupport");
include("InstanceManager");

local g_BackButton = {};

-------------------------------------------------
-------------------------------------------------
function OnOK()
    UIManager:PopModal( ContextPtr );
    ContextPtr:CallParentShowHideHandler( true );
    ContextPtr:SetHide( true );
end
Controls.OKButton:RegisterCallback( Mouse.eLClick, OnOK );

----------------------------------------------------------------
-- Input processing
----------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE then
            OnBack();
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );

----------------------------------------------------------------
-- ShowHideHandler
----------------------------------------------------------------
function ShowHideHandler( bIsHide )

end
ContextPtr:SetShowHideHandler( ShowHideHandler );


-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_ModsErrorAccess")

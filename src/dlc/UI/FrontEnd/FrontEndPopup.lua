-- Civ V Access: base-game override.
-- Target: Assets/UI/FrontEnd/FrontEndPopup.{lua,xml}. Contents above the
-- bootstrap marker are a verbatim copy of the base-game file. Re-diff
-- against the base after any Civ V patch.


-------------------------------------------------
-------------------------------------------------
function OnFrontEndPopup( string )
    UIManager:PushModal( ContextPtr );

    Controls.PopupText:SetText( Locale.ConvertTextKey( string ) );
end
Events.FrontEndPopup.Add( OnFrontEndPopup )


-------------------------------------------------
-------------------------------------------------
function OnBack()
    UIManager:PopModal( ContextPtr );
end
--Controls.BackButton:RegisterCallback( Mouse.eLClick, OnBack );
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnBack );


----------------------------------------------------------------
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


-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_FrontEndPopupAccess")

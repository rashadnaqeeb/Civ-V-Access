-- Civ V Access: base-game override.
-- Target: Assets/UI/FrontEnd/WaitingForPlayers.{lua,xml}. Contents above
-- the bootstrap marker are a verbatim copy of the base-game file.


function ShowHide( isHide )
    if( isHide == true ) then
        -- SetUICursor( 0 );
    else
        -- SetUICursor( 1 );
    end
end
ContextPtr:SetShowHideHandler( ShowHide );


-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_WaitingForPlayersAccess")

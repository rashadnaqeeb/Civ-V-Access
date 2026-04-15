-- Civ V Access: base-game override.
-- Target: Assets/UI/FrontEnd/ToolTips.{lua,xml} (base game; not overridden by
-- Expansion/Expansion2). Contents above the bootstrap marker are a verbatim
-- copy of the base-game file. Re-diff against the base file after any Civ V
-- patch. Rationale for this target: 15 lines, leaf, always loaded at
-- front-end init (before MainMenu), and very unlikely to be patched.
-------------------------------------------------
-------------------------------------------------


--------------------------------------------------------------------------------------
-- this function call registers the components in ToolTips.xml for use as the simple
-- tool tip frame.
--
-- RegisterBasicControls( Root, Container, Label, Grid );
-- Root      - the tool tip itself is anchored to the mouse by this and BranchResetAnimation begins here
-- Container - this is where dynamically created tool tip definitions will be added
-- Label     - this is the TextControl used for the simple string-only tool tips
-- Grid      - this is the GridControl used for backing of the Label and to check the
--             overall tip against the screen bounds
--------------------------------------------------------------------------------------
TTManager:RegisterBasicControls( Controls.ToolTipRoot, Controls.ToolTipStore, Controls.ToolTipText, Controls.ToolTipGrid );

-- Civ V Access accessibility mod bootstrap.
include("CivVAccess_FrontendBoot")

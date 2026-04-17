-- Prepended to each overridden form screen (OptionsMenu, AdvancedSetup,
-- MPGameSetupScreen, StagingRoom) so PullDownProbe is in place BEFORE the
-- screen's own top-level code registers selection callbacks or builds
-- entries. Patching the metatable after those calls would miss the
-- one-time RegisterSelectionCallback, leaving FormHandler with no way to
-- invoke the engine's callback from keyboard Enter.
--
-- include() is idempotent (engine caches by bare stem); multiple screens
-- chaining through here cost nothing on the second Context. The probe's
-- install itself is guarded by civvaccess_shared.pullDownProbeInstalled.
--
-- Sample control list is per-screen-superset: the first control that
-- resolves is enough since the PullDown metatable is shared across every
-- PullDown in the lua_State.

include("CivVAccess_Log")
include("CivVAccess_PullDownProbe")

if not civvaccess_shared.pullDownProbeInstalled then
    PullDownProbe.installFromControls({
        -- OptionsMenu
        "TutorialPull", "BindMousePull", "LeaderPull", "MSAAPull",
        "FSResolutionPull", "WResolutionPull",
        -- AdvancedSetup
        "MapTypePullDown", "MapSizePullDown", "HandicapPullDown",
        "GameSpeedPullDown", "EraPullDown", "CivPulldown", "TeamPullDown",
        -- MPGameSetupScreen / StagingRoom reuse the same stems above,
        -- plus these:
        "TurnModePullDown", "TurnTimerPullDown", "MaxTurnsPullDown",
    })
end

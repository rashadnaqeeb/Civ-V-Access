-- Prepended to each overridden form screen (OptionsMenu, AdvancedSetup,
-- MPGameSetupScreen, StagingRoom) so the widget probes are in place BEFORE
-- the screen's own top-level code registers callbacks or builds entries.
-- Patching the metatable after those calls would miss the one-time
-- Register*Callback, leaving BaseMenu with no way to invoke the
-- engine's callback from keyboard activation.
--
-- include() is idempotent (engine caches by bare stem); multiple screens
-- chaining through here cost nothing on the second Context. The probe's
-- install itself is guarded by civvaccess_shared.{pullDownProbeInstalled,
-- sliderProbeInstalled}.
--
-- Sample control lists are per-widget-kind supersets: the first control
-- that resolves is enough since each widget-kind metatable is shared by
-- every instance of that kind in the lua_State.

include("CivVAccess_Log")
include("CivVAccess_PullDownProbe")

PullDownProbe.installFromControls(
    {
        -- OptionsMenu
        "TutorialPull", "BindMousePull", "LeaderPull", "MSAAPull",
        "FSResolutionPull", "WResolutionPull",
        -- AdvancedSetup
        "MapTypePullDown", "MapSizePullDown", "HandicapPullDown",
        "GameSpeedPullDown", "EraPullDown", "CivPulldown", "TeamPullDown",
        -- MPGameSetupScreen / StagingRoom
        "TurnModePull", "TurnTimerPullDown", "MaxTurnsPullDown",
        -- LoadMenu
        "SortByPullDown",
    },
    {
        -- OptionsMenu
        "MusicVolumeSlider", "EffectsVolumeSlider",
        "AmbienceVolumeSlider", "SpeechVolumeSlider",
        "Tooltip1TimerSlider", "DragSpeedSlider", "PinchSpeedSlider",
        -- AdvancedSetup / MPGameSetupScreen / StagingRoom
        "MinorCivsSlider",
    },
    {
        -- OptionsMenu: any checkbox is enough; metatable is shared.
        "SinglePlayerAutoEndTurnCheckBox", "ZoomCheck", "VSyncCheck",
        "AutoWorkersDontReplaceCB", "FullscreenCheck",
        -- MPGameSetupScreen / StagingRoom / AdvancedSetup
        "MaxTurnsCheck", "TurnTimerCheck", "ScenarioCheck",
        "PrivateGameCheckbox",
        -- LoadMenu
        "AutoCheck", "CloudCheck",
    },
    {
        -- Buttons: shared metatable across GridButton / TextButton usages.
        -- First resolvable wins; all screens that use ProbeBoot have at
        -- least a BackButton or DefaultButton at top-level Controls.
        "BackButton", "DefaultButton", "StartButton", "LaunchButton",
        "LoadGameButton", "ExitButton", "AddAIButton", "EditButton",
    }
)

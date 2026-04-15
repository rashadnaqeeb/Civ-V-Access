# Civilization V: Comprehensive Accessibility Audit

## Every User-Facing Mechanic and Interface Element

*Ordered by Encounter Sequence*

> **Note:** This document catalogues every interface, screen, panel, overlay, menu, popup, and interactive element a player encounters in Sid Meier's Civilization V (base game, Gods and Kings expansion, and Brave New World expansion). It is organized by feature in the order a player first encounters each surface, progressing from application launch through setup, early in-game, mid-game systems, and endgame. Related screens are grouped under the feature they belong to rather than listed individually. The goal is to identify every component that must be made accessible for a blind player using a screen reader.

> **Scope:** Covers base game plus both expansions (G&K, BNW). DLC-specific elements are tagged inline. Debug screens are excluded. The advisor system is treated as a single entry rather than enumerating every advisor prompt. This document describes what exists in the UI, not how to make it accessible.

> **Status key:** DONE = fully accessible via this mod, PARTIAL = accessible with minor gaps, NOT STARTED = no coverage, N/A = not applicable (non-interactive, or feature does not exist as a distinct surface in shipped Civ V).

> **Source authority:** Entries are compiled from the screen inventory at `docs/llm-docs/screen-inventory.md`, the UI text-key index at `docs/llm-docs/txt-keys/ui-text-keys.md`, and the events catalog at `docs/llm-docs/events-catalog.md`. Widget-level details rely on the screen inventory's top-level-control enumeration; deeper XML structure should be verified against `Sid Meier's Civilization V\Assets\UI\` during implementation.

---

# Phase 1: Application Launch and Main Menus

## 1.1 Legal, Logo, and Title Splash - N/A

Civ V opens with publisher and engine logo movies, followed by the `LegalScreen` legalese page and then the animated `FrontEnd` title background. The LegalScreen requires a single click through; everything else is passive animation.

- 2K / Firaxis / Aspyr logo movies (non-interactive, auto-advance)
- `LegalScreen` with a Continue button past the EULA / legal copy
- `FrontEnd` title animation (background for the Main Menu; rotating leader vignettes, no controls)

## 1.2 Main Menu - NOT STARTED

`FrontEnd/MainMenu.{lua,xml}` (G&K and BNW XML-only overrides that change branding; Lua shared). The primary navigation hub, rendered over the `FrontEnd` title animation. Buttons stack vertically inside `MainStack`, each a `GridButton` with `Style="ZoomButton"` sized 320x45. Every button has an ID and a `TXT_KEY_*` string:

- `SinglePlayerButton` (`TXT_KEY_MODDING_SINGLE_PLAYER`) opens the SinglePlayer submenu (`LuaContext` child).
- `MultiplayerButton` (`TXT_KEY_MULTIPLAYER`) opens MultiplayerSelect.
- `ModsButton` (`TXT_KEY_MODS`) transitions to the Modding UI context.
- `OptionsButton` (`TXT_KEY_OPTIONS`) opens the OptionsMenu child context.
- `OtherButton` (`TXT_KEY_OTHER`) opens the Other submenu.
- `ExpansionRulesSwitch` (`TXT_KEY_LOAD_MENU_DLC`) toggles between Vanilla, G&K, and BNW rule sets; only visible when at least one expansion is owned.
- `ExitButton` (`TXT_KEY_EXIT_BUTTON`) triggers `ExitConfirm` modal.
- `TouchHelpButton` (tooltip `TXT_KEY_TOUCH_HELP`) — tablet-only help glyph.

Label-only elements: `VersionNumber` (build string, bottom-center). Promo tiles (`MapPack2PromoButton`, `MapPack3PromoButton`, `AcePatrolPromoButton`) occupy the bottom area and open Steam storefront links; labels composed from `TXT_KEY_DLC_*_AVAILABLE` and `TXT_KEY_DLC_AVAILABLE`.

Child contexts registered via `LuaContext` and toggled via `Hidden`: `OptionsMenu_FrontEnd`, `SinglePlayerScreen`, `MultiplayerSelectScreen`, `ModsEULAScreen`, `Other`, `JoinScreen`, `StagingRoomScreen`, `PremiumContentScreen`, `DedicatedServerScreen`, `TouchControlsMenu`. All start `Hidden="1"`; the MainMenu Lua drives visibility swaps on button click.

## 1.3 Single Player Submenu - NOT STARTED

`FrontEnd/SinglePlayer.{lua,xml}`. Identical layout to the Main Menu — vertical `MainStack` of `GridButton Style="ZoomButton"` 320x45 entries. G&K and BNW XML overrides change branding only.

- `StartGameButton` (`TXT_KEY_PLAY_NOW`, tooltip `TXT_KEY_PLAY_NOW_TT`) — resumes the most recent single-player session if one exists, otherwise launches a default setup.
- `GameSetupButton` (`TXT_KEY_SETUP_GAME`) — opens `GameSetupScreen` child (see Phase 2).
- `LoadGameButton` (`{TXT_KEY_LOAD_GAME:upper}`) — opens `LoadMenu` child.
- `ScenariosButton` (`TXT_KEY_SCENARIOS`) — opens `ScenariosMenu`.
- `LoadTutorialButton` (`TXT_KEY_TUTORIAL`) — opens `LoadTutorial` tutorial picker.
- `BackButton` (`TXT_KEY_MODDING_MENU_BACK`) — returns to Main Menu.

Child contexts registered here: `LoadGameScreen`, `LoadTutorial`, `GameSetupScreen`, `ScenariosScreen`. All start hidden and swap via button callback.

## 1.4 Other Submenu - NOT STARTED

`FrontEnd/OtherMenu.{lua,xml}`. Same `MainStack` + `ZoomButton 320x45` pattern. Buttons:

- `LatestNewsButton` (`TXT_KEY_LATEST_NEWS`, tooltip `TXT_KEY_LATEST_NEWS_TT`) — opens `LatestNews` context (news ticker feed, DeferLoad).
- `CivilopediaButton` (`TXT_KEY_CIVILOPEDIA`, tooltip `TXT_KEY_CIVILOPEDIA_TOOLTIP`) — opens `Civilopedia` (full reference screen, see §12.1 / §12.2).
- `HallOfFameButton` (`TXT_KEY_HALL_OF_FAME`, tooltip `TXT_KEY_HALL_OF_FAME_TT`) — opens `HallOfFame` (see §12.9, §14.12).
- `ViewReplaysButton` (`TXT_KEY_OTHER_MENU_VIEW_REPLAYS`, tooltip `TXT_KEY_OTHER_MENU_VIEW_REPLAYS_TT`) — opens `LoadReplayMenu`.
- `CreditsButton` (`TXT_KEY_CREDITS`, tooltip `TXT_KEY_CREDITS_TT`) — opens `Credits` (see §1.12, N/A).
- `LeaderboardButton` (`TXT_KEY_LEADERBOARD`, tooltip `TXT_KEY_LEADERBOARD_TT`) — opens `Leaderboard` online rankings.
- `BackButton` (`TXT_KEY_MODDING_MENU_BACK`) — returns to Main Menu.

All children use `DeferLoad="1"` — Lua loads lazily on first open.

## 1.5 Tutorial Launcher - NOT STARTED

Reached from Single Player, Load Tutorial. Small menu with a list of scripted tutorial scenarios (Your First 60 Turns, Combat, Economy, City Growth, etc.).

- Tutorial list entries (one button per scenario)
- Start (launches the selected tutorial)
- Learn (opens the related Civilopedia entry for the tutorial topic)
- Back

## 1.6 Options Menu - NOT STARTED

`UI/Options/OptionsMenu.{lua,xml}` (433-line XML; loaded as `LuaContext` from both MainMenu and the in-game pause menu with shared Lua). Tabbed shell: five `Button` tab headers at the top (each with a `*Highlight` frame visible when active), five `Container` panels below sharing the same Offset/Size, `Hidden` toggled by tab click. `TitleLabel` uses style `MenuTitleCaption`.

**Tab headers**:
- `GameButton` (`TXT_KEY_GAME_OPTIONS`), `GameHighlight`
- `IFaceButton` (`TXT_KEY_INTERFACE_OPTIONS`), `IFaceHighlight`
- `VideoButton` (`TXT_KEY_VIDEO_OPTIONS`), `VideoHighlight`
- `AudioButton` (`TXT_KEY_AUDIO_OPTIONS`), `AudioHighlight`
- `MultiplayerButton` (`TXT_KEY_MULTIPLAYER_OPTIONS`), `MultiplayerHighlight`

**Game tab (`GamePanel`)**:
- `Tooltip1TimerSlider` with `Tooltip1TimerLength` label (tooltip `TXT_KEY_OPSCREEN_TOOLTIP_1_TIMER_LENGTH_TT`) — tooltip fade-in delay.
- `TutorialPull` pulldown (`TXT_KEY_OPSCREEN_TUTORIAL_LEVEL`, tooltip `TXT_KEY_OPSCREEN_TUTORIAL_LEVEL_TT`).
- `ResetTutorialButton` (`TXT_KEY_OPSCREEN_RESET_TUTORIAL`).
- Checkboxes: `SinglePlayerAutoEndTurnCheckBox`, `MultiplayerAutoEndTurnCheckbox`, `SPQuickCombatCheckBox`, `SPQuickMovementCheckBox`, `MPQuickCombatCheckbox`, `MPQuickMovementCheckbox`, `AutoWorkersDontReplaceCB`, `AutoWorkersDontRemoveFeaturesCB`, `NoRewardPopupsCheckbox`, `NoTileRecommendationsCheckbox`, `CivilianYieldsCheckbox`, `NoBasicHelpCheckbox`, `QuickSelectionAdvCheckbox`. Each has a `TXT_KEY_OPSCREEN_*` label and matching `_TT` tooltip.

**Interface tab (`IFacePanel`)**:
- `AutosaveTurnsEdit` (number input), `AutosaveMaxEdit` (`TXT_KEY_OPSCREEN_TURNS_FOR_AUTOSAVES` / `_MAX_AUTOSAVES_KEPT`).
- `BindMousePull` pulldown (`TXT_KEY_BIND_MOUSE`).
- Checkboxes: `ZoomCheck` (dynamic camera zoom), `PolicyInfo` (show all policy info), `AutoUnitCycleCheck`, `ScoreListCheck`, `MPScoreListCheck`, `EnableMapInertiaCheck`, `SkipIntroVideoCheck`, `AutoUIAssetsCheck`, `SmallUIAssetsCheck` (disabled).
- `LanguagePull`, `SpokenLanguagePull` (locale).
- Tablet-only: `DragSpeedSlider` / `DragSpeedValue` / `PinchSpeedSlider` / `PinchSpeedValue` inside `TabletInterfaceOptions`.

**Video tab (`VideoPanel`)**:
- Pulldowns: `FSResolutionPull`, `WResolutionPull`, `MSAAPull` (AA), `LeaderPull`, `OverlayPull`, `ShadowPull`, `FOWPull` (fog-of-war), `TerrainDetailPull`, `TerrainTessPull`, `TerrainShadowPull`, `WaterPull`, `TextureQualityPull`. Each label is a `TXT_KEY_OPSCREEN_<topic>` string.
- Checkboxes: `FullscreenCheck`, `VSyncCheck`, `HDStratCheck` (high-detail strategic view), `GPUDecodeCheck` (tooltip `TXT_KEY_OPSCREEN_GPU_TEXTURE_DECODE_TT`), `MinimizeGrayTilesCheck`, `FadeShadowsCheck`.
- `ApplyResButton` (`TXT_KEY_OPSCREEN_APPLY_RESOLUTION`).
- `VideoPanelBlock` overlay shown when video options are disabled (`TXT_KEY_OPSCREEN_VDOP_DISABLED`).

**Audio tab (`AudioPanel`)**:
- Sliders with live-value labels: `MusicVolumeSlider` / `MusicVolumeSliderValue`, `EffectsVolumeSlider` / `EffectsVolumeSliderValue`, `AmbienceVolumeSlider` / `AmbienceVolumeSliderValue`, `SpeechVolumeSlider` / `SpeechVolumeSliderValue`. No master slider — the sum of the four is the master.

**Multiplayer tab (`MultiplayerPanel`)**:
- Turn notification controls: `TurnNotifySteamInviteCheckbox`, `TurnNotifyEmailCheckbox`, `TurnNotifyEmailAddressEdit` (player's own email).
- SMTP host config: `TurnNotifySmtpEmailEdit`, `TurnNotifySmtpHostEdit`, `TurnNotifySmtpPortEdit`, `TurnNotifySmtpTLS` (checkbox), `TurnNotifySmtpUserEdit`, `TurnNotifySmtpPassEdit` / `TurnNotifySmtpPassRetypeEdit` (obscured), `StmpPasswordMatchLabel` (live validation).
- LAN: `LANNickNameEdit` (`TXT_KEY_MP_NICK_NAME`).

**Footer controls (shared)**:
- `CancelButton` (`TXT_KEY_OPSCREEN_CANCEL_BUTTON`).
- `DefaultButton` (`TXT_KEY_OPSCREEN_DEFAULTS_BUTTON`, tooltip `TXT_KEY_OPSCREEN_DEFAULTS_BUTTON_TT`).
- `AcceptButton` (`TXT_KEY_OPSCREEN_SAVE_BUTTON`, tooltip `TXT_KEY_OPSCREEN_SAVE_BUTTON_TT`).

**Modal overlays**:
- `GraphicsChangedPopup` with `GraphicsChangedMessage` (`TXT_KEY_OPSCREEN_VDOP_RESTART`) and `GraphicsChangedOK` — shown when video settings require restart.
- `Countdown` with `CountdownMessage`, `CountdownTimer`, `CountYes`, `CountNo` — shown for resolution change keep-or-revert countdown.

Civ V has no dedicated key-rebinding UI in this Options menu or anywhere else at runtime. Action hotkeys are authored in DLC data XML (`ActionInfos.xml`) and are not exposed. For a mod accessibility pass this means two things: (a) hotkey changes require editing game data or the mod's own input handler, (b) the Options menu itself has no hotkey tab to speak through.

## 1.7 Mods Menu - NOT STARTED

Reached from Main Menu, Mods. A multi-screen flow rather than a single panel. Selecting Mods switches the game into a mod-only UI context where `ModsSinglePlayer` and `ModsMultiplayer` mirror the main SinglePlayer / Multiplayer menus but operate on enabled mods only.

### 1.7.1 Mods Root (`ModsMenu`)
- Single Player (opens the mods single-player flow)
- Multiplayer (opens the mods multiplayer flow)
- Back

### 1.7.2 Installed Mods Panel (`InstalledPanel`)
Scrollable list of locally installed mods. Each row shows the mod name, author, version, enabled / disabled state, and an expand arrow for description.

- Per-row Enable / Disable buttons
- Per-row Update button (Workshop mods with available updates)
- Per-row Options button (mods that ship their own options screen)
- Sort by Name toggle
- Sort by Enabled toggle
- Delete User Data button (clears per-mod save data)
- Show DLC as Mods toggle
- Options OK (closes the per-mod options subpopup)

### 1.7.3 Workshop Browser (`ModsBrowser`)
Embedded Steam Workshop view: title, thumbnail, author, rating, subscribe button per mod entry.

- Small navigation buttons (1 and 2; category / page navigation)
- Large subscribe / install button on the currently focused entry
- Back

### 1.7.4 Mods Error (`ModsError`)
- Error message text
- OK

### 1.7.5 Custom Mod Launch (`CustomMod`)
- Start
- Back

### 1.7.6 EULA Acceptance (`EULA`)
Shown the first time the user enables a user-generated mod.
- Decline
- Accept

## 1.8 Load Game - NOT STARTED

`FrontEnd/LoadMenu.{lua,xml}` (203-line XML; G&K and BNW XML overrides; shared Lua). Two-pane layout: left is the save list, right is the per-save detail panel.

Left pane:
- `SortByPullDown` — Name, Date Modified, Civ, Map, Turn.
- `AutoCheck` (`TXT_KEY_AUTOSAVES`) — show autosaves.
- `CloudCheck` (`TXT_KEY_STEAMCLOUD`) — show cloud saves.
- `NoGames` label (`{TXT_KEY_NO_SAVED_GAMES:upper}`) — shown only when list is empty.
- `ScrollPanel` containing `LoadFileButtonStack`. Each row is an `InstanceRoot` instance: a `Button` with `SelectHighlight` frame and a `ButtonText` label showing the save name. Selecting populates the right pane.

Right pane (`DetailsBox`, visible only when a save is selected):
- `LargeMapImage` — map thumbnail.
- `Portrait` — leader portrait.
- `SaveFileName` label (save's user-supplied name).
- `Title` (leader and civ, e.g. "Washington - America").
- `TimeSaved` (wall-clock date, e.g. "October 24, 1972 10:32 A.M.").
- `EraTurn` (current era plus turn count).
- `StartEra` (era the game was started in).
- `GameType` label (Single / Multi / Hot Seat / Pitboss).
- `ShowDLCButton` (`TXT_KEY_LOAD_MENU_DLC`) and `ShowModsButton` (`TXT_KEY_LOAD_MENU_MODS`) — open `ReferencedPackagesWindow` showing which DLC and mods the save depends on.
- Metadata icons: `CivIcon` (civ), `MapType`, `MapSize`, `Handicap` (difficulty), `SpeedIcon` (game speed).

Footer:
- `Delete` (`TXT_KEY_DELETE_BUTTON`) — triggers `DeleteConfirm` modal (`Yes` / `No`).
- `BackButton` (`TXT_KEY_MODDING_MENU_BACK`).
- `StartButton` (`TXT_KEY_LOAD_GAME`) — loads the selected save.

Modals:
- `DeleteConfirm` — confirm save deletion. `ButtonStack` with `Yes` / `No`.
- `ReferencedPackagesWindow` — lists DLC/mods the save needs; `ReferencedPackagesPrompt` and `ReferencedPackagesScrollPanel` / `ReferencedPackagesStack`.

## 1.9 Replay Viewer - NOT STARTED

Reached from Other, View Replays. Selecting a replay opens `ReplayViewer`, an animated world map that plays back turn-by-turn history with a turn slider.

- Replay list (`LoadReplayMenu`, Select Replay button per row)
- Show / Hide toggle (toggles UI chrome while replaying)
- Replay Info pulldown (selects which statistical overlay to show; score, population, land area, etc.)
- Graph Data Set pulldown (switches the graph series shown on the side panel)
- Turn slider (scrubs through turns)
- Play / Pause button

## 1.10 Hall of Fame - NOT STARTED

Reached from Other, Hall of Fame. A scrollable table of local past games with columns for player name, civilization, score, victory type, date, difficulty, game speed, map size.

- Past-game list (display-only rows)
- Back

## 1.11 Leaderboards - NOT STARTED

Reached from Other, Leaderboard. Online rankings pulled from Steam.

- Friends / Personal / Global scope toggle
- Leaderboard pulldown (selects which category to display; overall score, fastest science victory, highest turn count, etc.)
- Ranked list (rows with rank, player name, score)
- Refresh
- Back

## 1.12 Credits - N/A

Reached from Other, Credits. Auto-scrolling text of the development team.

- Back button (interrupts the scroll and returns)

## 1.13 Multiplayer Type Selector - NOT STARTED

Reached from Main Menu, Multiplayer (`MultiplayerSelect`). Picks which multiplayer mode to enter.

- Internet (public matchmaking; opens the internet `Lobby`)
- Local Network / LAN (opens the LAN `Lobby`)
- Hot Seat (same-machine play; opens the hot-seat `StagingRoom`)
- Pitboss (long-running dedicated-server play; opens the pitboss `Lobby`)
- Reconnect To Last Game (rejoins the most recent session)
- Back

## 1.14 Multiplayer Lobby (Internet / LAN / Pitboss) - NOT STARTED

Reached from the type selector. Server browser. `Lobby` is shared across all three list types with the list-type pulldown switching context.

- Games list: each row shows server name, host name, map, civs in play, turn, game speed, pings, version flag, DLC flag, mods flag, password flag
- Host Game (opens `MPGameSetupScreen` to configure a new game)
- Host Private Game (host with password; opens the same setup with password preset)
- Join Game (enters the selected row staging room)
- Refresh / Stop Refresh
- Sort-by header buttons for each column
- Connect To IP edit box (pitboss only; public IP entry to join a server not in the list)
- List Type pulldown (filters the browser: standard, private, mods, DLC)
- Search / filter field
- Back

## 1.15 Joining Room - N/A

`JoiningRoom` is a transient Retrieving Host Information / Connecting to players splash with status text only. No controls beyond the engine implicit cancel.

## 1.16 Multiplayer Staging Room - NOT STARTED

`FrontEnd/Multiplayer/StagingRoom.{lua,xml}` (557-line XML — the largest frontend screen). Two tabs: Players (default) and Game Options. Shared for Internet, LAN, Hot Seat, and Pitboss modes with mode-specific variants on a handful of controls.

`TitleLabel` uses `{TXT_KEY_MULTIPLAYER_STAGING_ROOM:upper}`.

**Top tabs**:
- `PlayersPageTab` (`{TXT_KEY_MULTIPLAYER_STAGING_ROOM_HEADER_PLAYER:upper}`, tooltip `TXT_KEY_MULTIPLAYER_STAGING_ROOM_HEADER_PLAYER_TT`) with `PlayersPageTabHighlight`.
- `OptionsPageTab` (`{TXT_KEY_AD_SETUP_GAME_OPTIONS:upper}`, tooltip `TXT_KEY_MULTIPLAYER_STAGING_ROOM_GAME_OPTIONS_TT`) with `OptionsPageTabHighlight`.
- `GameOptionsSummaryTitle` header label on right side of Players tab shows a compact readout of current game options.

**Player rows** (one `PlayerListingInstance` per slot, 575x107 each):
- `Portrait` (leader portrait), `CivIconBox` with `Icon` (civ symbol) and `ActiveTurnAnim`.
- `WaitOnPlayer` icon — shown while waiting on that player.
- `PlayerNameBox` with `PlayerNameLabel`. Host has `HostBox` with `HostIcon` (`[ICON_CAPITAL]`, tooltip `TXT_KEY_HOST`). Connection state via `ConnectedBox` / `ConnectionStatus` (tooltip `TXT_KEY_MP_PLAYER_CONNECTED`).
- `InvitePulldown` — Steam friends to invite (host only, open slots only).
- `CivPulldown` / `CivLabel` (civ selection; pulldown for host and own slot, static label otherwise).
- `TeamPulldown` / `TeamLabel`.
- `SlotTypePulldown` / `SlotTypeLabel` — Open / AI / Human / Closed / Observer (host only).
- `HandicapPulldown` / `HandicapLabel` — per-slot handicap (host only).
- `KickButton` (tooltip `TXT_KEY_MP_KICK_PLAYER`) — host only.
- `SwapButton` (`[ICON_SWAP]`, tooltip `TXT_KEY_MP_SWAP_BUTTON_TT`) — swap two slots.
- `LockCheck` (tooltip `TXT_KEY_MP_LOCK_SLOT`) — prevents slot from being taken.
- `EnableCheck` (tooltip `TXT_KEY_MP_DISABLE_SLOT`).
- `ReadyHighlight` — green frame when the slot is marked ready.
- `PingTimeLabel` — network ping for remote humans.
- `DisableBlock` — overlay that dims the row when the slot is disabled.

**Host row** gets a distinct `Host` container (separate from list) so the local player's row stays pinned visually.

**Game Options tab** (`OptionsPageTab` active): reuses `GameOptionRoot` and `DropDownOptionRoot` templates identical to AdvancedSetup (§2.7), dynamically populated with victory conditions, rule toggles, turn mode, turn timer, max turns. Host has full edit control; non-host players see read-only mirrors.

**Chat area** (always visible): chat history scroll panel, chat entry edit box, chat target pulldown (All / team / specific player).

**Footer**: `Ready` toggle (non-host), `LaunchButton` (host-only; enabled when all slots are ready), `BackButton`.

Hot Seat shares this screen — `ChangePassword` and `PlayerChange` (§1.17) are transient popups that appear between turns rather than modifications to StagingRoom itself.

## 1.17 Hot Seat Password and Player Change - NOT STARTED

During a hot-seat game, control passes between players on the same machine. Two small modal screens manage the handoff.

- `ChangePassword`: edit box for new password, Save, Main Menu
- `PlayerChange`: Your turn announcement for the next player, password edit box, Continue, Main Menu

## 1.18 Dedicated Server (Pitboss Host) - NOT STARTED

`DedicatedServer` is the pitboss host control panel. Mostly status output with limited input.

- Server status readouts (uptime, players connected, current turn, next autosave)
- Start / Stop server toggle
- Kick controls per connected player
- Save Now button
- Return to main menu

## 1.19 Content and Expansion Switching - NOT STARTED

Two small supporting screens handle rule-set and DLC toggling between games.

- `ContentSwitch`: confirmation prompt when enabling or disabling mods or DLC that requires a game restart. Continue, Back.
- `PremiumContentMenu`: grid of owned expansions and DLC, each with an enable / disable toggle. Launch button (starts the game with the selected content set), Back.

## 1.20 Generic Front-End Popup and Exit Confirm - NOT STARTED

Small modal dialogs layered over any front-end screen.

- `FrontEndPopup`: single Close button; used for informational messages (connection lost, invalid save, etc.)
- `ExitConfirm`: Yes / No dialog when quitting to desktop
- `GenericPopup` (in front-end use): up to four labeled buttons plus Close; used for confirm-action prompts (overwrite save, decline mod, etc.)

---

# Phase 2: New Game Setup

## 2.1 Quick Game Setup Screen - NOT STARTED

`FrontEnd/GameSetup/GameSetupScreen.{lua,xml}` (236-line XML; G&K and BNW XML overrides). The new-game entry point. Layout: a `MainSelection` container with `ScreenTitle` (`TXT_KEY_GAME_SELECTION_SCREEN`), five large 922x100 choice buttons stacked vertically, a small control row at the top, and `StartButton` / `BackButton` at the bottom corners. Each choice button displays its current value as a title/description pair with an icon, and opens a dedicated picker child context when clicked.

Top controls:
- `RandomizeButton` (`TXT_KEY_GAME_SETUP_RANDOMIZE`) — shuffles all five choices to random valid values.
- `AdvancedButton` (`TXT_KEY_GAME_ADVANCED_SETUP`) — opens `AdvancedSetup` child (see §2.7).

Five choice buttons (each with `Title`, `BonusDescription` or equivalent description label, and an icon):
- `CivilizationButton` — shows `Title` (leader plus civ), `BonusDescription` (first bonus bullet), a `Portrait` leader image, and icon slots `BF1` / `B1` / `BF2` / `B2` plus `IconShadow` showing unique units/buildings. Has a nested `EditButton` (`TXT_KEY_EDIT_BUTTON`, tooltip `TXT_KEY_NAME_CIV_TITLE`) opening `SetCivNames` rename popup, and a `RemoveButton` (`TXT_KEY_CANCEL_BUTTON`). Opens `SelectCivilization` on main click.
- `MapTypeButton` — shows `TypeName` + `TypeHelp` + `TypeIcon`. Has a nested `LoadScenarioBox` with `ScenarioCheck` (`TXT_KEY_LOAD_SCENARIO`). Opens `SelectMapType`.
- `MapSizeButton` — `SizeName` + `SizeHelp` + `SizeIcon`. Opens `SelectMapSize`.
- `DifficultyButton` — `DifficultyName` + `DifficultyHelp` + `DifficultyIcon`. Opens `SelectDifficulty`.
- `GameSpeedButton` — `SpeedName` + `SpeedHelp` + `SpeedIcon`. Opens `SelectGameSpeed`.

Right panel: `LargeMapImage` (preview of the selected map script's thumbnail).

Footer:
- `BackButton` (`TXT_KEY_BACK_BUTTON`).
- `StartButton` (`TXT_KEY_START_GAME`, 260x45, base button style).

Child contexts registered on this screen: `SelectCivilization`, `SelectGameSpeed`, `SelectDifficulty`, `SelectMapType`, `SelectMapSize`, `AdvancedSetup` (DeferLoad), `SetCivNames`. All `Hidden="1"` at start.

## 2.2 Civilization and Leader Picker - NOT STARTED

`SelectCivilization`. A scrollable list of civilizations, each with leader portrait, leader name, civ name, and a highlighted selection. Selecting one populates side panels describing the civ uniques via the `UniqueBonuses` helper.

- Civilization list (one button per civ / leader; base game 18, G&K adds 9, BNW adds 9, plus per-civ DLC packs)
- Random entry at the top of the list
- Unique Units panel (lists the civ unique units with description)
- Unique Buildings / Improvements panel
- Leader Trait panel (name and description of the civ special ability)
- Civilopedia shortcut (opens the civ pedia entry)
- Confirm / Back

## 2.3 Map Type Picker - NOT STARTED

`SelectMapType`. A scrollable list of map scripts. Each entry is a name, thumbnail, and description. Base game ships scripts including Pangaea, Continents, Archipelago, Small Continents, Large Island, Earth, Lakes, Highlands, Fractal, Great Plains, Inland Sea, Oval, Shuffle, Tilted Axis, Terra, Boreal, Frontier, Ice Age, and Skirmish. G&K and BNW add further scripts and scenario-specific maps.

- Map list (one selectable row per map script; includes Random)
- Description panel
- Confirm / Back

## 2.4 Map Size Picker - NOT STARTED

`SelectMapSize` (also launched via `WorldPicker` for some scripts). Six named world sizes with tile count, recommended civ count, and recommended city-state count for each.

- Duel (2 civs, 4 city-states, smallest map)
- Tiny (4 civs, 8 city-states)
- Small (6 civs, 12 city-states)
- Standard (8 civs, 16 city-states)
- Large (10 civs, 20 city-states)
- Huge (12 civs, 24 city-states, largest map)
- Confirm / Back

## 2.5 Difficulty Picker - NOT STARTED

`SelectDifficulty`. Eight difficulty levels with a description panel summarizing the AI and player bonuses at the selected level.

- Settler (lowest)
- Chieftain
- Warlord
- Prince (default, neutral)
- King
- Emperor
- Immortal
- Deity (highest)
- Description panel (per-level summary of production, gold, happiness bonuses and AI behavior)
- Confirm / Back

## 2.6 Game Speed Picker - NOT STARTED

`SelectGameSpeed`. Four pace options changing turn counts for research, production, construction, and growth.

- Quick (fastest, roughly 330 turns)
- Standard (default, 500 turns)
- Epic (roughly 750 turns)
- Marathon (roughly 1500 turns)
- Description panel (per-speed summary)
- Confirm / Back

## 2.7 Advanced Setup - NOT STARTED

`AdvancedSetup`. The full customization panel reached from `GameSetupScreen`, Advanced. Left column hosts map and rule settings; the right column is the player-slot list with Add AI Player, Remove AI, civ pulldown, team pulldown, handicap pulldown per row. G&K overrides the layout; BNW further overrides it to add ideology-era and trade-related options.

Global settings:
- Map Type pulldown
- Map Size pulldown
- Difficulty / Handicap pulldown (baseline; per-player overrides below)
- Game Pace pulldown
- Starting Era pulldown (Ancient, Classical, Medieval, Renaissance, Industrial, Modern, Atomic, Information)
- Game Era pulldown (G&K and BNW expanded era list)
- Turn Mode pulldown (Simultaneous, Sequential, Alternate)
- Max Turns checkbox with turn-count edit box
- Time Victory toggle
- Science Victory toggle
- Domination Victory toggle
- Cultural Victory toggle
- Diplomatic Victory toggle (G&K and BNW)
- Always War toggle
- Always Peace toggle
- Lock Mods toggle
- No Barbarians toggle
- Raging Barbarians toggle
- No Ancient Ruins toggle
- No City Razing toggle
- No Espionage toggle (G&K and BNW)
- Policy Saving toggle
- Promotion Saving toggle
- One-City Challenge toggle
- No Religion toggle (G&K and BNW)
- No Science toggle
- Disable Start Bias toggle
- Complete Kills toggle
- New Random Seed toggle
- AI Nuclear First Strike toggle
- Minor Civs / City-States slider (0 to map maximum)
- Map-script-specific option pulldowns (resources abundance, climate, sea level, age, world wrap, world age, temperature, rainfall; set varies by map script)

Concrete control IDs from `AdvancedSetup.xml`:
- `MapTypePullDown`, `MapSizePullDown`, `HandicapPullDown`, `GameSpeedPullDown`, `EraPullDown` — each a `PullDown` with a `Label String="TXT_KEY_AD_SETUP_<topic>"`.
- `CityStateStack` with `MinorCivsLabel` and `MinorCivsSlider` — city-state count.
- `VictoryConditionsStack` and `GameOptionsStack` — dynamically populated from game rule data using the `GameOptionRoot` `CheckBox` instance and `DropDownOptionRoot` container template.
- `MaxTurnsCheck` with `MaxTurnsEdit` (number input, max 3 digits) inside `MaxTurnsEditbox`.
- `ScenariosPullDown` and related when Scenario mode is active (not always shown).
- `TitleLabel` uses `TXT_KEY_AD_SETUP_ADVANCED_OPTIONS`.

Player slots list (inside `OptionsScrollPanel` and `SlotStack`):
- Each slot is an instance of an `AIPlayerSlot` or `HumanGrid` template (depending on slot type). Per-row controls: `Portrait` (leader), `CivPulldown` with child `CivNumberIndex` (`"1."`, `"2."`, etc.), `TeamPullDown` with `TeamLabel`, nested `EditButton` (`TXT_KEY_EDIT_BUTTON`), `RemoveButton` (`TXT_KEY_MODDING_DELETEMOD`), `CivName` label, `Icon` (civ symbol).
- `AddAIButton` (`TXT_KEY_AD_SETUP_ADD_AI_PLAYER`, tooltip `TXT_KEY_AD_SETUP_ADD_AI_PLAYER_TT`).
- `DefaultButton` (`TXT_KEY_AD_SETUP_DEFAULT`, tooltip `TXT_KEY_AD_SETUP_ADD_DEFAULT_TT`) — restores default player list.

Civ dropdown is truncated to 60px display width but has `ScrollThreshold="110"` and `SpaceForScroll="1"`, so the full civ list scrolls inside the dropdown.

Footer:
- `BackButton` (`TXT_KEY_BACK_BUTTON`).
- `StartButton` (`TXT_KEY_START_GAME`).

## 2.8 Set Civilization Names - NOT STARTED

`SetCivNames`. Reached before starting a game if the user wants to customize. Edit boxes for every player slot.

- Civilization name edit box (per slot)
- Leader name edit box (per slot)
- Civilization adjective edit box (per slot)
- City list prefix / suffix edit boxes (per slot)
- Player password edit box (per slot; multiplayer and hot seat)
- Accept
- Back

## 2.9 Scenarios Menu - NOT STARTED

`ScenariosMenu`. Reached from Single Player, Scenarios. Lists shipped scenarios. Selecting one launches either a direct-play configuration or jumps to a scenario-specific setup panel. G&K and BNW each add scenarios; the available set depends on owned content.

Shipped scenarios:
- Paradise Found (base)
- Into the Renaissance (base)
- Conquest of the New World (base)
- New World (base)
- Ancient Empires (base)
- Fall of Rome (G&K)
- 1066: Year of Viking Destiny (G&K)
- Empires of the Smoky Skies (G&K and BNW)
- American Civil War (BNW)
- Scramble for Africa (BNW)
- Samurai Invasion of Korea (BNW)

Controls:
- Scenario list (one row per scenario with thumbnail and summary)
- Play / Start button
- Description panel (synopsis, victory conditions, playable civs)
- Difficulty pulldown (per scenario)
- Game Speed pulldown (per scenario; some scenarios lock this)
- Civilization picker (per scenario; filtered to scenario-eligible civs)
- Back

## 2.10 Multiplayer Game Setup - NOT STARTED

`MPGameSetupScreen`. The multiplayer variant of Advanced Setup, reached from the Staging Room Game Options button (host only). Mirrors `AdvancedSetup` with three additional multiplayer-specific controls.

- All controls from `AdvancedSetup` (map, size, difficulty, pace, victory toggles, rule toggles, city-state slider)
- Turn Mode pulldown (Simultaneous, Sequential, Hybrid)
- Turn Timer checkbox with seconds edit box
- Max Turns checkbox with turn-count edit box
- Back (returns to Staging Room without applying)
- Accept / OK (applies to the staging room pending game)
# Phase 3: Core In-Game HUD

Once a game loads, the player is presented with the main gameplay interface. Civ V uses a 3D hex map viewport with UI chrome docked at the screen edges. The HUD is persistent: it remains visible during play (though individual panels hide contextually) and is the primary readout for empire-wide state. Almost every readout doubles as a button that opens a deeper screen, so a full pass for accessibility has to cover both the spoken-value side (what the readout says right now) and the activation side (what opening it does).

Base-game, Gods and Kings (GK), and Brave New World (BNW) each ship their own override of most HUD panels. Where a readout is DLC-specific (Faith in GK+, Tourism and Trade Routes in BNW), it is tagged inline.

## 3.1 Top Panel - NOT STARTED

A horizontal status bar pinned to the top of the screen. Each entry is a TextButton: it displays a number and a trend indicator and opens a relevant overview when clicked. Hover tooltips explain the breakdown. Every value changes on turn transitions and also reactively (trade deals, pillaging, policy adoption), so a mod reading these must refresh on event, not on a timer. Lives in UI/InGame/TopPanel.xml, with GK and BNW overrides.

Readouts, left to right in the BNW layout:

- Science per turn (beakers per turn). Click opens the Tech Tree.
- Gold stockpile and gold per turn (net). Click opens the Economic Overview. Negative GPT is critical - units disband when treasury hits zero.
- International Trade Routes (BNW only). Current active trade routes, max allowed. Click opens the Trade Route Overview.
- Happiness string. Numeric happiness surplus or unhappiness deficit, with status (Happy, Unhappy, Very Unhappy, We Love The King Day eligible). Click opens the Demographics or empire overview.
- Golden Age string. Either turns remaining in current Golden Age, or Golden Age points accumulated toward next (X of Y). Click opens the overview.
- Culture per turn, plus progress toward next policy (current over required). Click opens the Social Policies screen.
- Tourism per turn (BNW only). Click opens the Culture Overview. Tourism is only meaningful against other civs culture totals; the top-panel value alone is not actionable.
- Faith stockpile and faith per turn (GK and BNW). Click opens religion overview or Choose Belief flows depending on state.
- Resource string. Summary of surplus strategic resources (Horses, Iron, Coal, Oil, Aluminum, Uranium). Click opens the Resources list.
- Unit Supply string. Units used of units supported. Over-supply triggers production penalties.
- Turn counter and current era. The turn number ticks every End Turn. Era advances on researching an era-gating tech.
- Date or year string. Translated from turn number using the game speed year table.
- Menu button (opens GameMenu pause screen).
- Civilopedia button.

Tooltips on each readout give a per-source breakdown (for example Science: base plus buildings plus trade routes plus population plus Great Scientist; Happiness: luxuries plus wonders plus policies minus city count minus population). The breakdown is the actionable part of the panel; the bare number is rarely enough to act on.

## 3.2 Minimap Panel - NOT STARTED

Bottom-right corner. A rendered mini-image of the world plus overlay toggles. Lives in UI/InGame/MiniMapPanel.xml (BNW has a full override). The minimap image itself is useless to a blind player; the value is in the overlay toggles and the strategic-view switch.

- Overlay dropdown. Selects a world-layer visualization: owner, religion, trade routes, tourism, ideology influence, and others depending on DLC.
- Icon dropdown. Selects which world-icon layer is drawn (resources, improvements, yields, etc.).
- Show Features checkbox. Toggles forest, jungle, marsh rendering.
- Show Fog of War checkbox.
- Hide Recommendations checkbox. Toggles the advisor city-site and tile-improvement hint icons.
- Show Resources checkbox.
- Show Yield checkbox. Renders yield icons on every visible plot.
- Show Grid checkbox. Hex grid lines.
- Show Trade checkbox (BNW). Renders trade route lines on the world.
- Strategic View button (F10). Toggles between 3D world and a flat symbolic view. Strategic View is already closer to what a blind player needs - flat, symbolic, high-contrast - but the underlying plot state is the same; neither view is spoken.
- Map Options button. Opens a secondary options flyout.

## 3.3 Notification Panel - NOT STARTED

A vertical stack of typed notification icons, right side of the screen, below the top panel. Lives in UI/InGame/NotificationPanel.xml, with GK and BNW overrides. Each notification is added via the NotificationAdded event and removed either on click, on dismiss, or when the underlying condition clears (for example a choose-production notification removes itself when production is set).

Notification types include: city production complete, city needs production, tech researched, choose research, choose free tech, policy available, choose ideology, pantheon available, found religion, enhance religion, reformation belief, enough faith for Great Person, barbarian camp near city, barbarians attacking, enemy in territory, met new civ, met city-state, city-state quest, city-state gift, war declared, peace offered, deal expired, trade route plundered, spy rank-up, spy stole tech, golden age started, great person born, unit promotion available, wonder completed (own or rival), archaeology site found (BNW), World Congress session, World Leader vote, tourism milestones, ideology pressure, and about fifty others. The full typed-button list is in NotificationPanel.xml.

Each notification has:

- An icon and a short summary line (TXT_KEY_NOTIFICATION_SUMMARY_*).
- A longer tooltip (TXT_KEY_NOTIFICATION_*_TT).
- A left-click action: typically zoom camera to the relevant plot or open the relevant chooser popup.
- A right-click action: dismiss without acting.

Notifications stack indefinitely until actioned. Blocking notifications (choose production, choose research, choose policy, choose belief) prevent End Turn from completing. Non-blocking ones do not.

The NotificationLogPopup screen shows a scrollable log of past notifications, including dismissed ones.

## 3.4 End Turn Button and Flow - NOT STARTED

Bottom-right, just above the minimap. Lives in UI/InGame/WorldView/ActionInfoPanel.xml. The button is a single GridButton whose label, icon, and behavior change based on the current EndTurnBlockingType. The EndTurnBlockingChanged and SerialEventEndTurnDirty events drive all state transitions.

Possible button states, in priority order:

- Choose Production - a city has no production set.
- Choose Research - no current research.
- Choose Free Tech - a Great Scientist or policy granted one.
- Choose Policy - a social policy is available.
- Choose Pantheon, Found Religion, Enhance Religion, Reformation Belief, Add Reformation Belief.
- Choose Ideology (BNW).
- Choose Archaeology (BNW).
- Stacking-unit-needs-orders - there are units that have not moved or been given a skip, sleep, or fortify order. These block by default in single-player; Shift+Return forces past them.
- Unit Needs Attention - a flashing unit glyph. Clicking cycles to the unit.
- Next Turn - no blockers; pressing ends the turn.
- Waiting For Other Players (multiplayer).
- Turn Timer (multiplayer) - countdown rendered in MPTurnPanel.

Hotkeys: Return and Numpad Enter end turn; Ctrl+Space is an alternate; Shift+Return force-ends past unit-action blockers. Between turns the game shows NewTurn and TurnProcessing overlays briefly (no interactive controls, but the brief period where input is swallowed is itself a state the mod may want to announce).

## 3.5 Tech Panel - NOT STARTED

A compact current-research readout, usually below or beside the top panel depending on resolution. Lives in UI/InGame/TechPanel.xml, with GK and BNW overrides.

- Current tech name and icon.
- Turns remaining to complete (beakers accumulated over total required, at current science per turn).
- TechButton - clicking opens the full Tech Tree.
- BigTechButton variant used when no research is set (glows and prompts choose).
- B1 through B5 - up to five free-tech slots, populated when a Great Scientist, Liberty finisher, or similar grants a free tech waiting to be claimed.

When no research is set, the panel doubles as a blocking notification - the same condition also appears in the End Turn button.

## 3.6 Social Policies and Culture Progress Indicator - NOT STARTED

Culture progress is surfaced in two places: the Top Panel Culture readout (see 3.1), and as a blocking notification when a policy becomes available. There is no dedicated persistent policy-bar panel like the Tech Panel; the top-panel CultureString is the readout. Clicking it opens SocialPolicyPopup (the full chooser). Coverage of that screen belongs in the management-screens phase; what is visible on the HUD is only the per-turn culture and the X-of-Y culture toward next policy text.

Ideology adoption (BNW, Industrial era) also routes through this readout; when ideology becomes available, a Choose Ideology notification fires and the End Turn button blocks until picked.

## 3.7 Unit Panel (Bottom-Left Selected-Unit Panel) - NOT STARTED

When a unit is selected, the bottom-left panel populates with that unit controls and stats. Lives in UI/InGame/WorldView/UnitPanel.xml, with GK and BNW overrides and a _small resolution variant. The UnitSelectionChanged event drives population; UnitActionChanged and UnitMoveQueueChanged drive in-place updates while a unit is selected.

- Unit portrait and name. UnitNameButton is a TextButton; clicking opens the rename prompt (SetUnitName). EditButton beside the name does the same.
- Unit type (for example Warrior, Settler, Great General, Caravan).
- Stats row: Movement (current over max, with fractional moves shown as fractions), Strength (combat), Ranged Attack (if the unit has one), Range in tiles (if ranged).
- Health (HP current over 100). Hidden when unit is at full HP in some layouts.
- Experience and promotion level. PromotionButton appears when a promotion is available.
- Charges readout for charge-using units: Worker build charges left, Great Engineer hurry-production charges, Great Scientist tech-bulb charges.
- Status flags: Fortified, Sleeping, Sentry, Alert, Embarked, Garrisoned, In Foreign Territory, Damage-healing rate.
- Cycle Left and Cycle Right buttons. Cycle through units needing orders. Also hotkeyed to period and comma and Numpad 5.
- Unit Action Buttons. A row of context-dependent action icons; see 3.8.
- Recommended Action Button. The advisor suggested action, highlighted.

The panel is hidden entirely when nothing is selected; selecting a foreign unit opens the EnemyUnitPanel variant instead (see 4.4).

## 3.8 Unit Action Panel - NOT STARTED

The lower row of the UnitPanel lists every legal action for the current unit on its current plot. Actions are populated from GameInfoActions, filtered by unit type and plot state. Each action button shows an icon, a name, a hotkey hint, and a tooltip with the full effect and any requirements or costs. Disabled actions show a reason string in the tooltip.

Common actions (the full list varies per unit):

- Move To (M). Enters movement targeting mode - see 4.3.
- Attack (engages targeting; see 4.4).
- Ranged Attack (R). Targeting mode for ranged units.
- Fortify (F). Fortify in place; plus 25 percent defense, stacks per turn up to plus 50 percent.
- Fortify Until Healed (H). Like Fortify but auto-wakes at full HP.
- Sleep (Z). Skip turns until disturbed.
- Alert (A). Skip turns until an enemy enters vision.
- Sentry. Similar to Alert with different wake conditions.
- Skip Turn (Space or Numpad 5). End this unit turn without moving.
- Wake (W). Cancel Fortify, Sleep, or Alert.
- Disband (Delete). Destroy the unit, optional refund.
- Upgrade (U). Spend gold to upgrade to the next tier unit type.
- Found City (B, Settlers only).
- Build improvements (Workers, see 4.8).
- Automate Worker (A, Workers) - the unit chooses build orders itself.
- Automate Explore (E, most land and naval units) - the unit wanders the map auto-exploring.
- Embark and Disembark - automatic on first move into water once Sailing or Optics is researched.
- Trade Route (T, BNW Caravans and Cargo Ships) - opens trade route picker.
- Great Person actions: Start Golden Age (Great Artist base, Great Writer BNW), Construct Academy, Manufactory, Customs House, Citadel, Landmark, Holy Site, Hurry Production, Discover Technology, Found or Enhance Religion, Conduct Trade Mission, Great Work creation (BNW).
- Religious actions (GK+): Spread Religion, Remove Heresy, found Holy City.
- Air unit actions: Rebase (R), Air Sweep (Alt+S), Intercept.
- Nuke (N) - targeting for nuclear weapons.

Cost annotations appear inline: move cost for moves, gold cost for upgrades, faith cost for religious actions, charges remaining for workers and Great People.

## 3.9 Diplomacy Corner - NOT STARTED

Bottom-left of the screen (distinct from UnitPanel, which occupies the same region when a unit is selected - DiploCorner sits above). Lives in UI/InGame/WorldView/DiploCorner.xml, with GK and BNW overrides. The persistent entry points to empire-management screens.

- Diplomacy Button - opens the known-civs list (DiploList).
- Culture Overview Button (BNW) - opens CultureOverview (tourism, great works, themed museums).
- Social Policies Button - opens SocialPolicyPopup.
- Espionage Button (GK+) - opens the espionage overview.
- Chat Pull, Chat Entry, Chat Toggle (multiplayer) - text chat.
- Multiplayer Pull, MP Invite (multiplayer).
- End Game Button - retire or concede.

## 3.10 Info Corner and Sidebar Lists - NOT STARTED

Left edge, collapsible. InfoCorner hosts a LeftPull toggle and a Panel Display (PDButton) that opens one of several sidebar lists. Each list is a separate screen reparented into the corner:

- City List. All owned cities. Sort by population, name, strength, or production. Each entry shows name, population, current production and turns remaining, garrisoned unit, and a range-strike icon if the city can shoot. Clicking an entry centers the map on the city; double-clicking opens the City Screen. (UI/InGame/CityList.xml.)
- Unit List (BNW Lua override). All owned units. Sort by name, status, or movement. Each entry shows unit type, location (plot coordinates or city name), HP, moves remaining, and status flags.
- Great People List. Progress toward each Great Person type (Artist, Engineer, Merchant, Musician, Scientist, Writer, and expansion-added Prophet). Shows current over required points and source city. (UI/InGame/GPList.xml.)
- Resource List. Strategic, luxury, bonus resources with counts and trade status. Sort by name or trade info.
- DiploList - known civs. Score, filter major or minor, buttons for per-civ diplomacy, global politics, League overview (BNW), per-civ leader view, declare war, plus war and peace yes or no confirmations. (UI/InGame/DiploList.xml.)

The sidebar is one-at-a-time; opening another list closes the previous one. Each list has its own Close button that returns to collapsed state.

## 3.11 Tooltip Layer - NOT STARTED

Civ V renders several tooltip surfaces layered above the rest of the HUD. All fire on pointer dwell and clear on pointer move; there is no keyboard equivalent, which is structurally hostile to screen-reader play. Tooltip content must be surfaced through a parallel inspect-on-hotkey / speak-on-focus pipeline.

- `PlotHelpManager.lua` (353 lines, base; G&K and BNW overrides) registers a single `ToolTipType Name="HexDetails"` defined in `PlotHelpManager.xml` — a `Grid` with one `Label ID="Text"` and `WrapWidth=500`. Driven by `Events.SerialEventMouseOverHex(x, y)`. The label text is assembled each call by walking the plot: owner line, working-city line, terrain/feature via `PlotMouseoverInclude.GetNatureString`, resource name via `ResourceTooltipGenerator`, improvement (including pillaged state), per-yield totals, movement cost, defensive bonus (`TXT_KEY_PLOT_HELP_DEFENSE_BONUS` with signed percent), river-crossing penalty, roads/railroads, any goody-hut marker, and `GetCivStateQuestString` for city-state `MINOR_CIV_QUEST_KILL_CAMP` target tiles. When a unit occupies the plot, adds `TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV` (civ adjective plus unit name) and the unit's HP, moves, XP.
- `PlotHelpText.lua` (80 lines, under `WorldView/`) is the positioning/animation layer on top of the HexDetails control — handles fade-in delay per `Option: Tooltip 1` / `Tooltip 2` slider in the Options menu.
- `InfoTooltipInclude.lua` (G&K and BNW overrides) is an include-file of tooltip builders used across screens: `GetHelpTextForUnit`, `GetHelpTextForBuilding`, `GetHelpTextForWonder`, `GetHelpTextForTech`, `GetHelpTextForPolicy`, `GetHelpTextForBelief`, `GetHelpTextForImprovement`, `GetHelpTextForProject`, `GetHelpTextForPromotion`, `GetHelpTextForUnitCombat`. Each returns a composed multi-line string using `TXT_KEY_*_HELP` entries plus inlined costs, prereqs, yield modifiers, and flavor quote. These are reused by TechTree, CityView production chooser, social policy screen, civilopedia, etc., so implementing an accessible speech form of these composers once covers many screens.
- `ResourceTooltipGenerator.lua` composes per-resource tooltips: name, type (strategic / luxury / bonus), yields, required tech to exploit, improvement that harvests it, current owned / in-use / available counts from the active player.
- `PathHelpManager` (see 4.10) — movement-path tooltip. Separate from hex tooltip but triggered during the same hover action.
- Tooltip fade timing is user-configurable (two sliders in Options: Tooltip 1 Delay and Tooltip 2 Delay). A zero delay is functionally an instant tooltip; the mod should mimic whatever delay the user has set for speech consistency.

## 3.12 Advisor System - NOT STARTED

Civ V ships four themed advisors (Economic, Foreign, Military, Science) that surface through three distinct screens plus inline recommendations. Each advisor has three portrait variants (e.g. `EconomicAdvisorPortrait1..3`) that rotate based on mood. The advisor can be disabled in `OptionsMenu` (Game tab, `NoBasicHelp` and `NoTileRecommendations` toggles), and most popups include a `DontShowAgainCheckbox` suppressing that category.

- `WorldView/Advisors.xml` (`Advisors.lua`) — floating in-world prompt. Layout: `AdvisorDisplayFront` box with `AdvisorHeaderText`, `AdvisorBodyText` (310 px wrap), one of four portrait boxes (`EconomicAdvisor`, `ForeignAdvisor`, `MilitaryAdvisor`, `ScienceAdvisor` — only one shown at a time), an `AdvisorTitleText` banner, four `Question1String`..`Question4String` response buttons, `DontShowAgainCheckbox`, `AdvisorDismissButton` (labeled `TXT_KEY_ADVISOR_THANK_YOU`, tooltip `TXT_KEY_ADVISOR_TY_TT`), and `ActivateButton` (takes the advised action). Each advisor label uses `TXT_KEY_ADVISOR_ECON_TITLE`, `_FOREIGN_TITLE`, `_MILITARY_TITLE`, `_SCIENCE_TITLE`.
- `Popups/AdvisorInfoPopup.{lua,xml}` — brief overview popup shown the first time each advisor type speaks; pre-game accessible via Civilopedia as well.
- `Popups/AdvisorCounselPopup.{lua,xml}` — the full-screen multi-advisor counsel. Grid of four quadrants, one per advisor (Economic top-left, Military top-right, Foreign bottom-left, Science bottom-right). Each quadrant has a portrait, an advisor label, a `<Prefix>PrevButton` / `<Prefix>NextButton` pair (e.g. `EconomicPrevButton` / `EconomicNextButton` labeled `TXT_KEY_ADVISOR_COUNSEL_<TYPE>_PREV` / `_NEXT`), a `<Prefix>PagesLabel` ("2 / 5") counter, and a scrollable `<Prefix>CounselText` label (e.g. `EACounselText`, `MACounselText`, `FACounselText`, `SACounselText`) with per-quadrant scrollbar. `PlayerTitleLabel` reads `TXT_KEY_ADVISOR_COUNSEL`; `ScreenTitle` reads `TXT_KEY_ADVISOR_COUNSEL_TITLE`. `CloseButton` dismisses. Each advisor walks its own page list independently.
- `Popups/AdvisorModal.{lua,xml}` — blocking Yes/No modal for dangerous actions ("Are you sure?" confirms). Dismiss, Activate, and `TXT_KEY_ADVISOR_MODAL_DONT_SHOW_ME_AGAIN` checkbox.
- Recommendation markers on the map — city-site flags rendered by Settler advisor (toggled off by minimap `Hide Recommendations`), tile-improvement hints for selected Workers, combat-strength preview chrome for selected military. Visual-only; no speech surface.
- `RecommendedActionButton` on `UnitPanel` (see 3.7) — highlights the advisor's suggested action for the selected unit within the normal action grid.
- Construction Advisor Recommendation in the production chooser — one or more `TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_*` flags (e.g. `_TRAIN_WORKER`, `_BUILD_WONDER`) appended to matching item rows. These are the closest thing to a turn-by-turn "what should I do next" hint and are load-bearing for blind play when combined with the ability to list them on demand.

The advisor is cosmetic in that ignoring it is always legal, but `AdvisorModal` confirms and construction recommendation tags are the only proactive warnings for costly misclicks (attacking into bad odds, razing a wonder city, overbuilding military at the expense of science). A speech pass that covers at minimum `AdvisorModal` (it is blocking) and `CONSTRUCTION_ADVISOR_RECOMMENDATION_*` tags on production rows is a high-leverage win.

## 3.13 Tutorial and Task List - NOT STARTED

Two thin contexts that surface scripted guidance text.

- `Tutorial.xml` is a minimal overlay: a single `Container` anchored top-left at offset `0,50` holding a `Box ID="TutorialTextBox"` with one `Label ID="TutorialText"` (Font `TwCenMT14`, cream-on-black). No buttons; text is set imperatively from whichever tutorial include is active. `Tutorial.lua` branches on `GameDefines.TUTORIAL` and pulls in one of six scripts: `Tutorial_MainGame` (the default, default new-game tutorial), `Tutorial_1_MovementAndExploration`, `Tutorial_2_FoundCities`, `Tutorial_3_ImprovingCities`, `Tutorial_4_CombatAndConquest`, `Tutorial_5_Diplomacy`. Each is a standalone scripted-event system. `TutorialEngine` is included last and drives advancement. `Game.SetStaticTutorialActive(true)` is set when the main-game tutorial runs, which also activates engine-side pulsing arrows and target-UI highlights (glow/pulse on whatever control is the current focus — purely visual, no textual marker that the player has to do something specific).
- `TaskList.xml` renders the objective list. A `Grid ID="TaskListGrid"` (400x270, title `TXT_KEY_TASK_LIST`, font `TwCenMT20`) contains a `Stack ID="TaskStack"` populated with `TaskEntryInstance` clones — each instance is a `Label ID="TaskLabel"` with an `Image ID="TaskEntryImage"` bullet pip (`MarcPips.dds`, 32x32). Display-only; clicking does nothing. Scenarios populate the stack with victory conditions, interim goals, and per-turn objectives; the default single-player game does not use it.

For blind play, the tutorial overlay directs attention visually (pulse, arrow, target-UI highlight) with no textual equivalent of "look at this control". Two reasonable strategies: (a) unconditionally disable the tutorial via `GameDefines.TUTORIAL = -1` at load and point the player at external documentation, or (b) hook `Controls.TutorialText` via a set-text trampoline and speak on change, accepting that the arrow target is still invisible. TaskList is simpler — speaking the stack contents on open and on change (a Lua-level wrapper around `TaskStack:AddChildAt` or equivalent) delivers the information faithfully.

---

# Phase 4: World Interaction

The world viewport is the center of the screen: a 3D hex map rendered with WorldView logic. Every tile is a Plot with an owner, terrain, feature, resource, improvement, and any units or city occupying it. Interaction is pointer-driven in the base game - the primary skills are inspect a plot, select a unit, issue an order. None of these have a native keyboard-only workflow, so every entry below is a surface the mod must either replicate or replace.

Camera controls: arrow keys or WASD pan; mouse wheel zooms; Home centers on capital; clicking a minimap position jumps the camera. Camera position is not gameplay state - speech output should key off selection and plot focus, not camera viewport.

## 4.1 Plot Inspection - NOT STARTED

Hovering a hex fires SerialEventMouseOverHex and surfaces the plot tooltip (see 3.11). A left-click on an empty plot does not open a persistent panel; selection is transient and the tooltip is the primary surface. Plot state that the player needs spoken:

- Terrain: Grass, Plains, Desert, Tundra, Snow, Coast, Ocean, Lake.
- Elevation: Flat, Hill, Mountain. Mountains are impassable to most units.
- Feature: Forest, Jungle, Marsh, Floodplains, Oasis, Ice, Atoll (GK+), natural wonders.
- Rivers: on which hex edges. Rivers grant plus 1 gold on adjacent worked tiles and impose a combat penalty for attackers crossing them.
- Resource: strategic (Horses, Iron, Coal, Oil, Aluminum, Uranium), luxury (Wine, Silk, Gems, and many more), bonus (Wheat, Cattle, Fish, and many more). Resource is hidden until the required tech is researched.
- Improvement: Farm, Mine, Trading Post, Camp, Pasture, Plantation, Quarry, Lumbermill, Fishing Boats, Oil Well, Offshore Platform, Well, Academy, Manufactory, Customs House, Citadel, Landmark, Holy Site, Moai, Terrace Farm, Polder, Brazilwood Camp, Chateau, Feitoria (BNW uniques), Fort, Archaeological Dig (BNW), Great Work sites, roads and railroads.
- Improvement pillaged status.
- Owner: unowned, your civ, another civ (by name), city-state.
- Working city: which of your cities is currently working this plot, if any.
- Yield: food, production, gold, science, culture, faith (GK+), tourism (BNW) - totals after all modifiers.
- Movement cost to enter.
- Defensive bonus for a unit standing there.
- Visibility: visible, fog of war (previously seen, current state unknown), unexplored.
- Units on plot: own units, enemy units, civilian units; stack count and topmost unit shown by the unit flag.
- City on plot, if any (see 4.5).

Plot coordinates (X, Y) are internal but useful as a spoken fallback when no landmark identifies the plot.

## 4.2 Unit Selection - NOT STARTED

Left-click a unit to select it. UnitSelectionChanged fires with old and new unit IDs. Selection:

- Populates the UnitPanel (see 3.7).
- Paints a movement-range overlay on reachable plots.
- Paints attack-range overlays for ranged units.
- Begins pulsing the unit flag on the map.

Stacked units on a plot are cycled with left-click on the plot repeatedly, or via Alt+C (select all units of same type) and Alt+Numpad 5 variants. There is no dedicated stack-cycle hotkey - the selection rotates through the plot unit list on repeated clicks. The UnitFlagManager paints the top-of-stack unit flag; deeper units are not surfaced until the player cycles.

Deselection: right-click, Escape, or selecting another unit or plot.

Cycle-to-next-unit-needing-orders: period or Numpad 5 (forward), comma (back), forward-slash to cycle workers specifically. End Turn also auto-cycles through units needing orders unless Shift+Return is used.

## 4.3 Unit Movement Targeting - NOT STARTED

After selecting a unit, clicking any reachable plot orders a move. Intermediate state:

- Movement-range overlay: every plot the unit can reach this turn is highlighted. Plots reachable in subsequent turns are highlighted in a second color, up to the pathfinding limit.
- Path preview: on hover, the game draws a route line showing the actual path taken and turn markers (1, 2, 3) at each turn endpoint. PathHelpManager renders the tooltip with total turns, per-turn breakdown, and any hazards along the way (enemy territory, rough terrain, river crossings).
- Hostile-territory warning: moving into an open-bordered civ territory is fine; moving where borders are closed is not allowed unless war is declared. Crossing a border that would declare war triggers DeclareWarMovePopup.
- Multi-turn move: a click on a plot outside this turn range issues a queued move. The unit moves as far as possible this turn, continues next turn. UnitMoveQueueChanged fires on every queue change.
- Cancel: right-click during targeting, or select a different unit.

Explicit Move-To mode (M): the same as clicking, but requires a confirmation click rather than selecting-and-clicking. Route-To mode (Ctrl+Shift+R, Workers): queues a road or railroad along the path.

## 4.4 Attack and Ranged Targeting - NOT STARTED

Attacking a melee unit: select the attacker, click an adjacent enemy unit or city. The game renders a combat preview tooltip (attacker strength, defender strength, terrain modifiers, expected damage each way, probability of unit death). Confirm with a second click; cancel with right-click. EnemyUnitPanel shows the defender stats during hover.

Ranged attack (R): enters a targeting mode. Plots within the unit range are highlighted. Hovering an enemy unit or city shows the same combat preview, minus counter-attack damage (ranged attackers do not take return fire from the target). Confirming commits the shot.

City range strike: cities can fire on adjacent enemies once per turn starting in the Ancient era. Select the city (CityBanner click, or the city-list entry), then Range Strike button on the banner, then target. The CityRangeStrikeButton on the banner fires this.

Nuclear attack (N, Atomic Bomb or Nuclear Missile selected): similar targeting mode, but the confirmation popup is elevated - nukes trigger a global denunciation and environmental fallout.

Combat resolution plays a small battle animation on the world (Bombardment.lua for artillery and ranged feedback). Damage dealt, unit death, and plot capture all fire individual events that notifications also surface.

## 4.5 City Banners - NOT STARTED

Every city on the map wears a banner rendered by CityBannerManager. The banner is a world-anchored UI element, updated live as the city state changes. For the player own cities, the banner includes:

- City name (localized).
- Population count (citizens).
- Current production item and turns remaining (or Great Work slot, settler, or unit in queue).
- Garrison icon if a unit is stationed.
- Range Strike button (if adjacent enemy in range).
- HP bar if the city has been damaged.
- Capital star (on the capital).
- Religion icon (GK+) - the majority religion, if any.
- Eject Garrison button (hidden unless relevant).

For other civs and city-states cities, the banner shows name, owner, population, HP, and a clickable entry that opens the DiploList or city-state relations popup.

Clicking a city banner on one of your own cities opens the City Screen (Phase 5). Clicking an enemy city selects it for ranged targeting or diplomacy depending on context.

## 4.6 Stacked-Unit Cycling and Unit Flags - NOT STARTED

`UnitFlagManager.{lua,xml}` (base; G&K and BNW full Lua overrides) paints a flag on every visible unit and a banner on every city. Three `InstanceManager` pools drive the flag system: `g_MilitaryManager` (military units, parent `Controls.MilitaryFlags`), `g_CivilianManager` (workers, settlers, civilians, parent `Controls.CivilianFlags`), and `g_AirCraftManager` (air units, parent `Controls.AirCraftFlags`). `NewUnitFlag` is the per-unit instance template. Additional containers: `Controls.GarrisonFlags` (cities with a garrison get a garrison-indicator flag) and `Controls.CityContainer` (city banners).

Each `NewUnitFlag` instance exposes multiple button variants:

- `NormalButton` — the undamaged unit flag. Registers `Mouse.eLClick` → `UnitFlagClicked`, `eMouseEnter` → `UnitFlagEnter`, `eMouseExit` → `UnitFlagExit`.
- `HealthBarButton` — replaces NormalButton when the unit has taken damage. Same three callbacks; adds a visible HP bar (`HealthBar` and `HealthBarBG`).
- `NormalSelect` / `HealthBarSelect` — selection-highlight overlays, shown only when the unit is currently selected.
- `UnitIcon` — the unit type icon inside the flag.
- `PullDown` (for cities and aircraft carriers) — opens a stack-cycle dropdown listing every unit on the plot or cargo aircraft loaded, using `UnitInstance` template buttons (size 150x26, truncate at 200) with the unit name and a `Count` label. Multi-unit stacks expose their members through this pulldown, not through repeated clicks.

Tooltip strings use `TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV` (civ adjective plus unit name) for single-player, `TXT_KEY_MULTIPLAYER_UNIT_TT` (player nickname plus civ plus unit name) for multiplayer. Each appends `TXT_KEY_UPANEL_CLICK_TO_SELECT` when clickable.

Stack cycling: plot with multiple units shows the top-of-stack unit flag plus a `Count` badge. Clicking the flag opens the `PullDown` with all plot units; clicking a pulldown entry (`UnitInstance` button) selects that unit. There is no keyboard shortcut; the game expects pointer interaction with the stack pulldown. `Alt+C` selects all units of the same type on a plot (a different behavior), but there is no cycle-within-stack hotkey. The mod must supply one — iterate the plot's unit list via `plot:GetUnit(i)` from `i = 0` to `plot:GetNumUnits() - 1` and speak each unit's type, HP, moves, and status on each keypress. Strategic View shows flags conditionally on `bShowInStrategicView`; the flag visibility logic in `UnitFlagManager.lua` toggles `self.m_Instance.Anchor:SetHide()` accordingly. City flags use `MajorButton` (civ-color framed) versus `NormalButton` (barbarian / unclaimed); unit flags use color and corner-style to distinguish own / ally / neutral / enemy — none of that is reachable via speech without explicit lookup.

## 4.7 Workable-Tile Overlay - NOT STARTED

When a city is selected (city screen or banner focus), the game highlights the city workable tiles: a three-ring radius (21 plots) around the city center. Each plot shows its yield icons (food, production, gold, science, culture, faith, tourism). Plots being worked by citizens have a filled-citizen marker; plots available but idle are dim. Locked plots (player-locked to force a specific citizen assignment) show a lock icon. Plots worked by another city are marked as such.

This overlay is also toggled globally by the minimap Show Yield checkbox (see 3.2). Outside the city view, yield icons render on all visible plots.

## 4.8 Worker Build Menu - NOT STARTED

With a Worker (or Work Boat, or Great Person performing improvement builds) selected, the UnitPanel action row populates with build options filtered by the current plot state. Each build option is an action button with an icon, hotkey, and tooltip showing the improvement yields, turn cost, and prerequisites.

Base game builds: Road (R), Farm (F), Mine, Trading Post (T), Lumbermill (L), Camp (H), Pasture, Plantation (Alt+P), Quarry (Q), Fishing Boats, Oil Well (O), Offshore Platform, Well, Academy, Manufactory, Customs House, Holy Site, Landmark, Citadel (Ctrl+C), Fort, Remove Jungle or Forest or Marsh (Alt+C, all three share the key), Repair (Ctrl+P), Railroad (Alt+R), Remove Route (Ctrl+Alt+R).

GK adds no new workers but adjusts some yields. BNW adds civ-unique improvements as builds that appear only for the matching civ Worker: Moai, Terrace Farm, Polder, Brazilwood Camp, Chateau, Feitoria, Kasbah, Mekewap, and others. BNW also adds Archaeological Dig for Archaeologists (a distinct unit type with its own action panel).

Disabled builds show a tooltip explaining the block: wrong terrain, missing tech, hostile territory, plot already improved.

## 4.9 Auto-Explore and Auto-Worker Toggles - NOT STARTED

Automation actions come from `GameInfo.Automates`, not `GameInfo.Actions`, and are rendered into the `UnitPanel` action grid alongside missions. `UnitPanel.lua` line 103 fetches the `info = GameInfo.Automates[action.Type]` when building the button for each automation. Two automations ship:

- `AUTOMATE_BUILD` (Automate Worker). Available on Workers and Work Boats. The unit selects improvement builds based on nearest-city priority and the current citizen-focus settings. Respects pre-queued manual routes. Status label: `TXT_KEY_ACTION_AUTOMATE_BUILD`.
- `AUTOMATE_EXPLORE` (Automate Explore). Available on most land and naval military units and civilian scouts. Unit wanders visible and fog-of-war areas, revealing tiles and avoiding combat; breaks on enemy contact or when exploration is complete (no unexplored reachable tile). Status label: `TXT_KEY_ACTION_AUTOMATE_EXPLORE`.

Both appear as `UnitActionButton` entries in the bottom-left unit-action grid while the eligible unit is selected. Clicking commits immediately; no confirmation popup. `W` (Wake) and any manual order cancel the automation. The `UnitPanel` status line reads the automate label while automation is active, so a selection-change announcement that includes the status line already surfaces automation state.

Worker auto is the higher-traffic of the two since workers act every turn; for blind play, explicitly announcing "automated" on the worker's status line on every selection cycle and on any auto-deactivation (unit stopped because no valid build) is the critical hook.

## 4.10 Route and Path Preview - NOT STARTED

Three distinct path preview surfaces.

- Unit movement path overlay (see 4.3). Driven by `Events.UIPathFinderUpdate(data)`, consumed by `PathHelpManager.lua` (57 lines, under `WorldView/`). `OnPath(data)` walks the path node list and, at every turn-boundary node, spawns a `TurnIndicator` instance (from `InstanceManager`) with a `TurnLabel` showing the turn number. Each indicator is anchored to the plot via `SetWorldPositionVal(x, y, z+3)` for revealed tiles or `z=15` for fog-of-war tiles. `Events.DisplayMovementIndicator(bShow)` toggles `Controls.Container:SetHide`. The indicator is purely visual — numbers floating over hexes — so blind play requires a list-form path read-out triggered off the same event or the `SerialEventUnitInfoDirty` / `UnitMoveQueueChanged` signals. The tooltip form that PlotHelpManager emits on path hover gives turns-to-reach, hazards, and borders-crossed in text.
- Worker Route-To mode (`INTERFACEMODE_ROUTE_TO`, hotkey `Ctrl+Shift+R`). Referenced at `UnitPanel.lua:233` as a distinct `action.Type`. Enters a targeting cursor; the Worker will lay Road or Railroad tile-by-tile toward the clicked target plot, multi-turn, persisting through End Turn. Preview shows turn count on the destination reticle. No modal confirm; click-to-commit.
- Trade route preview (BNW). Not a map overlay — a list-form destination picker opened from `Trade Route` unit action on Caravan or Cargo Ship. Each row shows destination city, distance in hexes, per-turn gold and science yields (including religion/culture spread contribution), religion pressure direction, and turns until the 30-turn route expires. Covered in detail in §8.7.

Additionally, `INTERFACEMODE_PARADROP` (atomic-era Paratroopers) enters a drop-range reticle mode; tooltip `TXT_KEY_INTERFACEMODE_PARADROP_HELP_WITH_RANGE` substitutes the unit's drop range. Same class of event (interface-mode cursor with hex highlights) as ranged attack and nuke targeting.

## 4.11 Other World Interaction Modes - NOT STARTED

A cluster of cursor modes defined in `CIV5InterfaceModes.xml` and dispatched by `WorldView.lua`. Each is entered from a unit action button and puts the map in a reticle-targeted state until a plot is clicked or the mode is cancelled.

- `INTERFACEMODE_ATTACK` / `INTERFACEMODE_RANGE_ATTACK` — covered in §4.4.
- `INTERFACEMODE_CITY_RANGE_ATTACK` — entered from the `CityRangeStrikeButton` on a city banner (§4.5). Hovered enemy tiles show combat preview; clicking fires.
- `INTERFACEMODE_NUKE` — see §11.9. Reticle over valid hexes within nuke range; blast radius renders on the hovered hex.
- `INTERFACEMODE_AIRSTRIKE`, `INTERFACEMODE_AIR_SWEEP`, `INTERFACEMODE_REBASE`, `INTERFACEMODE_AIRLIFT` — air-unit modes (§11.10). Each highlights valid targets per mission type and range.
- `INTERFACEMODE_PARADROP` — drop-range reticle for Paratroopers, tooltip `TXT_KEY_INTERFACEMODE_PARADROP_HELP_WITH_RANGE` with unit's drop range.
- `INTERFACEMODE_ROUTE_TO` — Worker road-laying mode (§4.10).
- `INTERFACEMODE_GIFT_TILE_IMPROVEMENT` — city-state gifting mode (§7.7 gift submenu); cursor highlights CS-adjacent plots where a Worker-built improvement can be gifted as part of a UA.
- `INTERFACEMODE_ESPIONAGE_MOVE` (G&K+) — used when relocating a spy via EspionageOverview; picks a destination city, not a plot.
- `INTERFACEMODE_GREAT_PERSON_ACTION` — selecting a Great Person tile improvement action (Academy, Customs House, Citadel, etc.) enters a per-plot valid-hex reticle.

Non-map cursor modes (these enter specific screens, not interface-mode states):
- Spy placement (G&K+) — opens the EspionageOverview city-picker popup (§10.2), not a map mode.
- Great Work swap (BNW) — initiated from CultureOverview (§5.8 reference); the swap source and destination lists span every player's building-slot. The map is not involved.
- Archaeologist dig (BNW) — Archaeologist walks to an antiquity-site plot via normal movement, then `Excavate` in the action panel opens `ChooseArchaeologyPopup` (§13.2) for Landmark / Artifact / Hidden Artifact selection.

All interface modes cancel via Esc, right-click, or selecting a different unit. None surfaces range or valid-hex set to speech; the mod must either (a) pre-compute the valid set when entering the mode and expose a keyboard-iterable list, or (b) hook the hover event to speak the current hex's eligibility. The former is more useful since blind users do not scan with a mouse.

---
# Phase 5: City Management

The city screen is where most per-turn decisions actually happen. Every city is a standalone complex of readouts, choosers, and drill-downs, and the full CityView panel (UI/InGame/CityView/CityView.lua, with G&K and BNW overrides) is the largest single Lua file in the UI layer at roughly 2400 lines. Opening a city fires `SerialEventEnterCityScreen` and pauses normal input; closing fires `SerialEventExitCityScreen`. While inside, most HUD panels are hidden or dimmed and interaction is scoped to the city, its worked hexes, and the production and purchase choosers that overlay it. For a sighted player the screen is a dense dashboard of icons and bars; for a blind player each readout below is a separate question the mod must answer on demand, and almost every one of them changes turn over turn.

Cities come in three dispositions - owned and annexed (full control), puppet (no production or purchase choice, AI-run), and occupied not-yet-decided (razing menu pending from capture). The CityView screen morphs for each. Foreign cities opened via Espionage use a read-only variant keyed off `TXT_KEY_CITYVIEW_RETURN_TO_ESPIONAGE`; the same panel handles both. All of this must be surfaced.

## 5.1 City View Entry and Exit - NOT STARTED

Opening a city happens from many paths: clicking a CityBanner on the map, double-clicking a city in CityList, accepting a Choose Production notification, pressing the production button on a banner, pressing View City on a capture popup, or via the spy View City button in Espionage. All of them end in `SerialEventEnterCityScreen(iPlayer, iCityID)` and `UI.DoSelectCityAtPlot` or `Events.SerialEventEnterCityScreen`. Exit is either the Return button (top of the city panel, labeled via TXT_KEY_CITYVIEW_RETURN_TO_MAP or TXT_KEY_CITYVIEW_RETURN_TO_ESPIONAGE depending on entry context), the Esc key, or the Next City / Previous City arrows which cycle without leaving the screen.

- Return button (top of panel). Closes CityView and returns to the prior context.
- Next City button (right arrow icon). Cycles to the next owned city by internal order.
- Previous City button (left arrow icon). Cycles to the previous owned city.
- Esc keybind (closes the screen).
- The city being viewed is identified by city name plus owner; the name also doubles as the Rename edit field (NameField EditBox in CityView.xml).
- WhileInside flag blocks most Events; gameplay pauses during the screen.

The distinguishing fact a blind player needs on entry is the city's name, whether it is the capital, its population, its current production item with turns remaining, and whether anything is pending a choice (no production set, border growth available to buy, great work slot empty and swappable, resource demanded, WLTKD active, occupied and pending annex or raze). A good open-city announcement is the difference between one keystroke and ten.

## 5.2 City Header Readouts - NOT STARTED

The city header occupies the top of the CityView panel. It holds the city name, population, turns until next citizen, capital indicator, connection indicator, and various status icons. The Lua driving this lives in CityView.lua around the UpdateCityInfo function (line references in the base file are approximate and differ between DLC overrides).

- City name (EditBox, doubles as Rename field). Capital city has an ICON_CAPITAL prefix in the rendered string; the mod must check `city:IsCapital()` rather than parse the string.
- Population count with ICON_CITIZEN marker (TXT_KEY_CITYVIEW_CITIZENS_TEXT, pluralized).
- Turns until next citizen (TXT_KEY_CITYVIEW_TURNS_TILL_CITIZEN_TEXT). Replaced by STAGNATION (TXT_KEY_CITYVIEW_STAGNATION_TEXT) or STARVATION (TXT_KEY_CITYVIEW_STARVATION_TEXT) when food growth is zero or negative.
- Food stored and food storage cap (progress toward next citizen). Not a single TXT_KEY but assembled from `city:GetFood()` and `city:GrowthThreshold()`.
- Net food per turn (TXT_KEY_CITYVIEW_FOOD_IN_TURNS format).
- Capital indicator. Visually an ICON_CAPITAL glyph on the name; gameplay-load-bearing because a lost capital is a near-loss.
- Occupied indicator (for cities recently captured and not yet decided). Cities in occupation show the Raze and Annex buttons instead of normal controls.
- Puppet indicator. Puppeted cities show a dimmed interior; production and purchase are AI-controlled.
- Razing indicator with turns remaining. During razing, the header shows the countdown; the Stop Razing button (TXT_KEY_CITYVIEW_UNRAZE_BUTTON_TEXT) appears.
- Resistance indicator. Newly captured cities are in resistance for N turns during which nothing works; announce the remaining turns.
- We Love The King Day counter (TXT_KEY_CITYVIEW_WLTKD_COUNTER). When active, food growth is boosted.
- City damage and HP. Cities have hitpoints and can be damaged by bombardment; the header shows damage as a red bar.

## 5.3 Yields Panel - NOT STARTED

The left rail of CityView lists the city's per-turn yields. Each is a TextButton that opens a detailed tooltip breakdown (base plus buildings plus specialists plus policies plus religion plus trade routes plus WLTKD plus wonders, minus maintenance). The raw number alone is rarely enough; the breakdown is the actionable part, same pattern as the top panel.

- Food (TXT_KEY_CITYVIEW_FOOD_TEXT). Per-turn gross, minus citizens eaten, equals net.
- Production (TXT_KEY_CITYVIEW_PROD_TEXT).
- Gold (TXT_KEY_CITYVIEW_GOLD_TEXT).
- Science (TXT_KEY_CITYVIEW_RESEARCH_TEXT).
- Culture (TXT_KEY_CITYVIEW_CULTURE_TEXT).
- Faith (TXT_KEY_CITYVIEW_FAITH_TEXT, G&K and BNW).
- Tourism (TXT_KEY_CITYVIEW_TOURISM_TEXT, BNW only). Per-city tourism from great works and wonders.
- Great People progress (TXT_KEY_CITYVIEW_GP_PROGRGRESS). Shows which great person type is accumulating and per-turn rate.
- Great General progress (TXT_KEY_CITYVIEW_GG_PROGRGRESS). Military-unit-driven, per-city contribution.
- Maintenance (TXT_KEY_CITYVIEW_MAINTENANCE). Gold drain from buildings in this city.
- City Combat Strength and Ranged Strength (TXT_KEY_CITYVIEW_CITY_COMB_STRENGTH_TT). Defensive stat for the city as a unit.

Each yield's tooltip is a multi-line breakdown assembled from `city:GetBaseYieldRate`, `city:GetYieldRateModifier`, and similar game API per source. The breakdown text is not in a single TXT_KEY; it is composed at runtime. The mod needs to reimplement the breakdown walk or speak the aggregated sources on a drill-down key.

## 5.4 Citizen Focus and Workforce Management - NOT STARTED

The city's workforce allocation panel lets the player steer which yield the governor prioritizes. It is a row of toggles under the yields list, plus a reset button and a manual-specialists toggle. Default behavior: the AI governor auto-allocates; toggling a focus skews allocation toward that yield; manually clicking a worked tile locks it (governor respects locks).

- Default Focus (TXT_KEY_CITYVIEW_FOCUS_BALANCED_TEXT).
- Food Focus (TXT_KEY_CITYVIEW_FOCUS_FOOD_TEXT).
- Production Focus (TXT_KEY_CITYVIEW_FOCUS_PROD_TEXT).
- Gold Focus (TXT_KEY_CITYVIEW_FOCUS_GOLD_TEXT).
- Science Focus (TXT_KEY_CITYVIEW_FOCUS_RESEARCH_TEXT).
- Culture Focus (TXT_KEY_CITYVIEW_FOCUS_CULTURE_TEXT).
- Faith Focus (TXT_KEY_CITYVIEW_FOCUS_FAITH_TEXT, G&K and BNW).
- Great Person Focus (TXT_KEY_CITYVIEW_FOCUS_GREAT_PERSON_TEXT).
- Avoid Growth (TXT_KEY_CITYVIEW_FOCUS_AVOID_GROWTH_TEXT). Halts population growth without starving.
- Reset Tiles (TXT_KEY_CITYVIEW_FOCUS_RESET_TEXT). Clears all user-locked tiles so the governor can reallocate freely.
- Manual Specialist Control (TXT_KEY_CITYVIEW_MANUAL_SPEC_CONTROL). Toggles AI-vs-manual specialist assignment.

Only one focus is active at a time (radio behavior); Avoid Growth is an independent checkbox layered on top of any focus. Clicking a focus that is already active turns it off. Changes take effect immediately; the governor reallocates tiles and specialists on the same frame.

## 5.5 Worked Tiles Ring - NOT STARTED

The city and its workable hex ring (three rings, up to 37 plots including center) are rendered in the world view while CityView is open. Tile highlight colors indicate: city center (automatic), worked, unworked but in range, owned but blockaded, enemy-occupied, buyable, and outside range. Tiles inside the workable ring are clickable: click a worked tile to lock it (governor will respect the lock), click an unworked tile to force it to be worked (bumping a lower-priority tile), and, if the tile is a buyable adjacent plot, click to purchase.

- Worked tile marker (governor-selected, TXT_KEY_CITYVIEW_GUVNA_WORK_TILE).
- Forced-work tile marker (TXT_KEY_CITYVIEW_FORCED_WORK_TILE).
- Blockaded tile marker (TXT_KEY_CITYVIEW_BLOCKADED_CITY_TILE). Enemy adjacency or naval blockade; tile cannot be worked.
- Enemy unit on tile (TXT_KEY_CITYVIEW_ENEMY_UNIT_CITY_TILE).
- City center (TXT_KEY_CITYVIEW_CITY_CENTER). Always worked, provides a minimum yield.
- Per-tile yield readout (food, production, gold, science, culture, faith) with specific modifiers from improvement, resource, feature, and adjacent buildings.
- Per-tile citizen icon overlay. Indicates worked status and lock state.

Tile interaction is pure pointer currently: there is no keyboard cursor that cycles through the city's workable ring. A keyboard-driven inspect-and-toggle flow for this ring is one of the core accessibility requirements for the city screen. The data needed per tile is already exposed via the Plot API (`plot:GetYield`, `plot:IsCityRadius`, `city:IsWorkingPlot`, `city:GetNumForcedWorkingPlots`).

## 5.6 Unemployed Citizens and Specialist Allocation - NOT STARTED

Below the focus row, CityView lists unemployed citizens (specialists not assigned to any slot; they default to giving small production) and the full Specialist Buildings section (each building with specialist slots shows slot icons). Clicking an empty slot assigns an unemployed citizen; clicking a filled slot removes the specialist, returning the citizen to the unemployed pool (or to a worked tile if any are free).

- Unemployed citizens count (TXT_KEY_CITYVIEW_UNEMPLOYED_TEXT, tooltip TXT_KEY_CITYVIEW_UNEMPLOYED_TOOLTIP).
- Specialist Buildings header (TXT_KEY_CITYVIEW_SPECIAL_TEXT).
- Per-building specialist slot grid. Each slot is either empty (TXT_KEY_CITYVIEW_EMPTY_SLOT) or filled with a specialist of that building's type (Scientist, Merchant, Artist, Engineer, plus BNW Musician and Writer in the Great Works buildings).
- Per-slot yield (TXT_KEY_CITYVIEW_BUILDING_SPECIALIST_YIELD, for example "2 Scientists ... +3 Science each"). The specialist also contributes fractional Great Person points of the matching type.
- Great Person progress badge on the specialist building. Shows which GP is accumulating and at what rate.
- Citizen Management header (TXT_KEY_CITYVIEW_CITIZEN_ALLOCATION).
- Manual Specialist Control toggle (TXT_KEY_CITYVIEW_SPECIALISTCONTROL_TT). If off, the governor moves specialists per focus; if on, the player's assignments stick.

Specialists are distinct from worked tiles: specialists produce yields with no geographic basis (they are just people in the building). A city can run out of food by over-specializing; the unemployed-citizen pool is the overflow.

## 5.7 Buildings List - NOT STARTED

The Building List panel (TXT_KEY_CITYVIEW_BUILDING_LIST) is a scrollable list of every building currently constructed in the city, grouped by section. Each entry shows the building name, its yields or effects, and a sell button (the remove control) if the building is sellable. Only one building per turn can be sold, and wonders and certain key buildings cannot be sold.

- Regular Buildings section (TXT_KEY_CITYVIEW_REGULARBUILDING_TEXT). Granary, Library, Market, and so on.
- Specialist Buildings section (TXT_KEY_CITYVIEW_SPECIAL_TEXT). Buildings with specialist slots.
- Great Work Buildings section (TXT_KEY_CITYVIEW_GREAT_WORK_BUILDINGS_TEXT, BNW). Amphitheater, Opera House, Museum, Broadcast Tower, Palace, and wonders with slots.
- Wonders section (TXT_KEY_CITYVIEW_WONDERS_TEXT). National and World wonders. Not sellable.
- Per-building sell button (b#remove in CityView.xml; b is the building internal index). Disabled on wonders and on buildings already sold this turn.
- Per-building yield readout. Summarizes what the building contributes to this city; long tooltip expands to include prereq, flavor, and policy modifiers.
- Per-building queue-position markers (up and down arrows in CityView.xml, b#up and b#down). These move the building's display position in the list, not the production queue.

The event `CityBuildingsIsBuildingSellable(iPlayer, iCity, iBuildingType)` gates the sell button; mods can add rules. Selling refunds roughly a quarter of the build cost in gold. Selling the wrong building because of a mispress is recoverable only by rebuilding at full cost.

## 5.8 Great Works Slots and Themes (BNW) - NOT STARTED

In Brave New World, every great-work-capable building has one to three slots for great works of a given type (Writing, Art, Artifact, Music). The CityView Great Work Buildings section and the CultureOverview screen both display these; CultureOverview is the authoritative swap interface (see Phase 6), but inline slot readouts and the swap-enter control live in CityView.

- Per-slot great work readout. When filled: work name, author, era, and origin civ. When empty: TXT_KEY_CITYVIEW_EMPTY_SLOT of that type.
- Per-slot theming state. A fully themed building (all slots filled with works matching a theming rule, typically same civ or same era) grants a large bonus (extra culture, tourism, happiness depending on building).
- Theming bonus tooltip. Spells out which rule applies, for example all works from different civs of the same era.
- Per-slot tourism output (BNW). Each filled great work generates tourism; themed buildings double it.
- Great Work swap entry point. Click a slot to open CultureOverview in swap mode, or right-click to get the swap context menu.
- Archaeology dig-site mark (BNW). Cities near a completed dig site show an archaeology progress indicator on the Artifact-slot building.

Great works are unique global objects: only one copy of each exists, and swapping moves works between buildings and between players (via trade). The per-slot data is gameplay-critical for tourism-victory play and for theming-bonus chasing; for a blind player, each slot needs a discoverable announce-what-is-here action.

## 5.9 Production Chooser - NOT STARTED

The Production Chooser (UI/InGame/Popups/ProductionPopup.lua, with G&K and BNW overrides) is the modal that opens on Change Production, Choose Production, or the Choose Production notification. It is an overlay over CityView and has its own buttons plus keyboard category tabs.

- Change Production button (TXT_KEY_CITYVIEW_CHANGE_PROD, tooltip TXT_KEY_CITYVIEW_CHANGE_PROD_TT). When production is already set.
- Choose Production button (TXT_KEY_CITYVIEW_CHOOSE_PROD, tooltip TXT_KEY_CITYVIEW_CHOOSE_PROD_TT). When no production is set.
- Produce Button (TXT_KEY_CITYVIEW_PRODUCE_BUTTON). Confirms selection.
- Category tabs: Units (UnitButton), Buildings (BuildingsButton), Wonders (WondersButton), Other (OtherButton, TXT_KEY_CITYVIEW_OTHER).
- Produce Research shortcut (ProduceResearchButton, TXT_KEY_CITYVIEW_PRODUCE_RESEARCH). Convert production to science per turn (base only, removed in later versions for non-scenario play; still present in some DLC).
- Produce Gold shortcut (ProduceGoldButton, TXT_KEY_CITYVIEW_PRODUCE_WEALTH). Convert production to gold per turn.
- Produce League Project shortcut (BNW, ProduceLeagueProject). Active only when a World Congress project is in session.
- Items list. Each row is: item name, icon, per-turn cost, total cost, turns remaining at current production rate, and unlocking-prereq text if the item is not yet producible.
- Per-item tooltip. Long form with prereq (tech, building, resource, policy), yield, unit stats, and flavor. Includes Advisor Recommendation when applicable (TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_*).
- Hide Unbuildable toggle (implicit). Most versions hide items with missing prereqs; some show them greyed.
- `CityCanConstruct(iPlayer, iCity, iBuildingType)` and `CityCanTrain(iPlayer, iCity, iUnitType)` events gate buildable status; mods can extend.

The per-turn and turns-remaining figures are the most load-bearing data on this screen: a building that takes 60 turns in a tiny new city is a different decision from the same building in a capital at 8 turns. Those must be announced on row focus.

## 5.10 Production Queue - NOT STARTED

The queue is an optional extension of the chooser: instead of replacing current production, append items (up to six deep). The queue is shown in-line when the Show Queue button is toggled on.

- Show Queue button (TXT_KEY_CITYVIEW_QUEUE_O, tooltip TXT_KEY_CITYVIEW_QUEUE_O_TT).
- Hide Queue button (TXT_KEY_CITYVIEW_QUEUE_C, tooltip TXT_KEY_CITYVIEW_QUEUE_C_TT).
- Add to Queue button (TXT_KEY_CITYVIEW_QUEUE_PROD, tooltip TXT_KEY_CITYVIEW_QUEUE_PROD_TT). Replaces Produce when queue mode is on.
- Per-queue-slot move up arrow (TXT_KEY_CITYVIEW_Q_UP_TEXT).
- Per-queue-slot move down arrow (TXT_KEY_CITYVIEW_Q_DOWN_TEXT).
- Per-queue-slot remove x (TXT_KEY_CITYVIEW_Q_X_TEXT).
- Queue Selection indicator (TXT_KEY_CITYVIEW_QUEUE_SELECTION). Which slot in the queue is currently being edited.

Queue items carry through turn transitions: when the head item completes, the next item starts the same turn. Overflow production from a completed item carries to the next.

## 5.11 Purchase With Gold Panel - NOT STARTED

The Purchase side of the Production chooser (TXT_KEY_CITYVIEW_PURCHASE_BUTTON, tooltip TXT_KEY_CITYVIEW_PURCHASE_TT) lets the player complete a unit or building immediately for gold. It shares the chooser's category tabs but filters to currently-purchasable items and shows a gold cost rather than a production cost. Faith purchase is a separate tab (see 5.12).

- Purchase tab toggle. Flips the chooser between Production and Gold Purchase modes.
- Items list, gold-mode. Each row: item name, gold cost, and enabled state (enabled only if treasury has enough gold and the prereqs are met). Tooltip identical to production chooser.
- Unit hurry cost scales with how many of that unit you already have and with game speed. Cost appears per-row; no separate current-treasury readout on the row but the top panel gold figure is still visible behind the overlay.
- Confirm dialog. Purchases are irreversible; the game shows a confirm popup (TextPopup variant) before debiting gold.
- Disabled state reasons. A greyed row has a tooltip stating why (not enough gold, tech not researched, resource missing, unit cap reached, already have the building).

Hurrying production of a building under construction is not supported in base Civ V. You can purchase a building that hasn't been started, but you cannot pay down an in-progress wonder. Certain items are purchase-locked regardless of gold (wonders cannot be gold-purchased; some G&K and BNW buildings are faith-only; some units are faith-only after Industrial era).

## 5.12 Purchase With Faith Panel (G&K+) - NOT STARTED

Faith purchase (G&K onward) is a third chooser mode alongside Production and Gold. Religious units (Missionary, Inquisitor, Great Prophet) are always faith-bought; certain buildings become faith-buyable once the player founds a religion with a relevant Follower Belief; post-Industrial, faith can buy Great People of any type (one of each, once per game).

- Faith tab toggle. Only visible if the player has accumulated faith or founded a religion.
- Religious unit rows. Missionary (spreads religion), Inquisitor (removes foreign religion), Great Prophet (found or enhance religion; also used to build Holy Site improvements).
- Religion-specific building rows. Mosque, Pagoda, Cathedral, Synagogue, Stupa, and so on, depending on the player's religion beliefs. Each row shows faith cost and the belief that unlocked it.
- Great Person rows (Industrial era and later). Faith can buy a Great Scientist, Engineer, Merchant, Artist, Musician, Writer, or General; cost escalates dramatically per purchase across the empire.
- Automatic Faith Purchase setting (ReligionOverview has the global toggle; the city inherits it). Notification TXT_KEY_NOTIFICATION_AUTOMATIC_FAITH_PURCHASE fires when the autopurchase system spends faith.
- Disabled state reasons per row. No religion founded, belief not taken, era not reached, already purchased this Great Person type.

Faith is typically scarcer than gold; the faith-purchase panel is the single highest-leverage point of the religion system, so for a blind player, row-level cost-vs-benefit announce is critical.

## 5.13 Buy Tile Panel - NOT STARTED

Adjacent-plot purchase is a CityView-specific interaction (TXT_KEY_CITYVIEW_BUY_TILE, tooltip TXT_KEY_CITYVIEW_BUY_TILE_TT). The Buy Plot button toggles a mode in which clicking a highlighted adjacent tile (plots next to already-owned ones, within the city's maximum working range of 3 hexes) purchases it for gold.

- Buy Plot button (TXT_KEY_CITYVIEW_BUYPLOT_TT).
- Buyable-tile highlight. Tiles eligible for purchase light up; clicking prompts a confirm.
- Per-tile buy cost (TXT_KEY_CITYVIEW_CLAIM_NEW_LAND, parameterized with the gold cost). Cost grows with the number of tiles already bought in the empire and with game era.
- Not-enough-gold tooltip (TXT_KEY_CITYVIEW_NEED_MONEY_BUY_TILE).
- Turns until next free border growth (TXT_KEY_CITYVIEW_TURNS_TILL_TILE_TEXT). Border growth is automatic over time from accumulated culture; buying just accelerates it.
- Enough-gold-to-buy notification (TXT_KEY_NOTIFICATION_SUMMARY_ENOUGH_GOLD_TO_BUY_PLOT). Fires empire-wide when any city can afford a plot.

For accessibility, the buyable-tile highlight needs a keyboard-cycled list: tile to the northeast, grassland with wheat, 75 gold, rather than a pointer-hover scan.

## 5.14 City Connection, Resource Demand, and WLTKD - NOT STARTED

Several status readouts appear inline in CityView when certain conditions are met. None has a dedicated button; each is a label that appears or disappears turn to turn.

- Connected-to-capital indicator. Shown when a trade route (road, railroad, harbor, or, in BNW, internal trade route) links this city to the capital. Connection generates gold and enables trade routes for this city. The absence is load-bearing: a newly founded or newly captured city often is not yet connected and drips gold.
- Resource Demanded string (TXT_KEY_CITYVIEW_RESOURCE_DEMANDED). Each city periodically requests a specific luxury; fulfilling the demand (having the resource tradeable or owned) triggers WLTKD.
- WLTKD active banner (TXT_KEY_CITYVIEW_WLTKD_COUNTER). Counts down turns; boosts food growth by 25 percent (base) or applies BNW-specific effects (extra great person generation under some policies).
- WLTKD fulfilled tooltip (TXT_KEY_CITYVIEW_RESOURCE_FULFILLED_TT).
- Resource Demand notification (TXT_KEY_NOTIFICATION_SUMMARY_CITY_RESOURCE_DEMAND). Empire-wide hint that a new demand has appeared.
- Religion pressure and majority religion. The city has a majority religion (if any religion has more than half the followers) and accumulating pressure from adjacent cities; the icons for followers per religion and the pressure-per-turn figures appear in the religion subpanel of CityView. The Religion overview (Phase 7) has the full per-city drill-down.
- City-State influence readout (capitals only, under Religion or in a dedicated row depending on DLC version). Not present in all cities.
- Growing Borders notification (TXT_KEY_NOTIFICATION_SUMMARY_CITY_CULTURE_ACQUIRED_NEW_PLOT). Fires on free border growth.
- City Growth notification (TXT_KEY_NOTIFICATION_SUMMARY_CITY_GROWTH). Fires when a citizen is born.

These status lines are the kind of thing a sighted player reads at a glance and a blind player must actively request. An open-city status summary readout that folds all of these into a single speech is a strong candidate for the mod's default city announce.

## 5.15 Capture Decision Popup - NOT STARTED

When a city is captured, the Popup TXT_KEY_POPUP_CITY_CAPTURE_INFO fires with "What would you like to do with this City?" and up to four buttons depending on context. This popup pauses the turn; it must be resolved before End Turn completes.

- Annex the City (TXT_KEY_POPUP_ANNEX_CITY). Full control, adds unhappiness immediately, costs no gold, but the city enters a resistance period. Can later build a Courthouse to remove occupied penalty.
- Puppet the City (TXT_KEY_POPUP_PUPPET_CAPTURED_CITY, TXT_KEY_POPUP_DONT_ANNEX_CITY). AI-run city; reduced yields; no production or tile-buy choice; half unhappiness compared to annexed.
- Raze the City (TXT_KEY_POPUP_RAZE_CAPTURED_CITY). Burn over N turns (TXT_KEY_CITYVIEW_RAZE_BUTTON_TEXT applies post-capture too). Cannot raze a city that was ever a capital (TXT_KEY_CITYVIEW_RAZE_BUTTON_DISABLED_BECAUSE_CAPITAL_TT). Cannot raze if the game option No City Razing (TXT_KEY_GAME_OPTION_NO_CITY_RAZING) is on.
- Liberate the City (TXT_KEY_POPUP_LIBERATE_CITY). Returns the city to its original owner (a civ you had previously beaten, or a city-state you took from someone else). Massive diplomatic boost with that player; zero cost otherwise. Only shown if a prior owner exists and is still alive (or is a city-state that can be reinstated).
- Pillage gold readout (TXT_KEY_POPUP_GOLD_CITY_CAPTURE, TXT_KEY_POPUP_GOLD_AND_CULTURE_CITY_CAPTURE for BNW with Honor). Shown as flavor before the decision.
- Capture-without-gold variant (TXT_KEY_POPUP_NO_GOLD_CITY_CAPTURE). Just the acknowledgment line.
- View City shortcut (TXT_KEY_POPUP_VIEW_CITY, tooltip TXT_KEY_POPUP_VIEW_CITY_DETAILS). Opens CityView in read-only mode to inspect buildings before deciding.
- Are-you-sure-raze confirm (TXT_KEY_POPUP_ARE_YOU_SURE_RAZE). Razing is reversible during the burn via the Stop Razing button but not after.

This popup is the single most consequential decision in the game for conquest play; the relative yield, happiness cost, and diplo implication of each option are load-bearing. The buttons alone are not enough; the mod should offer a spoken tradeoff summary.

## 5.16 Razing, Annex, and Puppet State Transitions - NOT STARTED

After the initial capture decision, each disposition has its own follow-up UI:

- Razing: CityView shows the UnRaze button (TXT_KEY_CITYVIEW_UNRAZE_BUTTON_TEXT, tooltip TXT_KEY_CITYVIEW_UNRAZE_BUTTON_TT) plus turns-until-destroyed. Razing removes one population per turn; at population 1, the city burns next turn. UnRazing mid-burn is allowed; the city becomes puppet.
- Puppet: CityView is mostly read-only. Production is AI-driven; the Production chooser button is disabled; focus controls are disabled. The Annex button (a gold-cost action to convert the puppet to a full city) appears; clicking it prompts a confirm and debits gold equal to the current Annex cost. Annex cost scales with empire size and era.
- Annexed: If annexed during resistance, the city cannot produce or work tiles for N turns. Post-resistance, a Courthouse building (produced or gold-purchased) removes the occupied happiness penalty.
- Occupied (not yet decided): rare transient state when the capture popup is dismissed before resolution; Next Turn is blocked until it is reopened and resolved.

Each of these states changes which subpanels of CityView are active. The mod must expose the current state unambiguously on open-city and announce state transitions (resistance ended, razing complete, annex cost reached affordable) because several of them are notification-only in vanilla.

## 5.17 City Banner and City List Quick Access - NOT STARTED

Outside CityView, two surfaces control or surface city state. The CityBanner (UI/InGame/CityBannerManager.lua) is the on-world label above each city; the CityList (UI/InGame/CityList.lua) is the collapsible sidebar.

- CityBanner BannerButton. Click opens CityView for that city.
- CityBanner production icon (CityBannerProductionButton). Shows current item with turns-remaining; click opens Production chooser directly.
- CityBanner EjectGarrison button. Removes the stationed unit.
- CityBanner CityRangeStrikeButton. Enters the city ranged-attack interface mode (see Phase 4 combat interaction). Bound to the InitCityRangeStrike event; cities can fire once per turn at units in range.
- CityBanner damage bar. Visual-only HP indicator.
- CityList rows (one per owned city). Shows name, population, current production, strength, and a production-shortcut button (ProdButton) per row.
- CityList sort controls: SortPopulation, SortCityName, SortStrength, SortProduction.
- CityList OpenEconButton. Jumps to the Economic Overview filtered on this city.
- CityList per-row CityRangeStrikeAnim. Flags cities that can fire this turn.
- CityList Close.

For a blind player the CityList is the natural keyboard entry point to the city system - one list, all cities, sortable. The map-based CityBanner is pointer-driven and much less accessible. A CityList-first navigation model is likely the right default.

## 5.18 Rename and Self-Raze Controls - NOT STARTED

Inside CityView, two actions let the player alter the city without going through chooser popups:

- Rename NameField. The city name EditBox in the header is editable; typing replaces the name on Enter. Names persist through save and load and appear in notifications and diplomacy screens.
- Raze City button (TXT_KEY_CITYVIEW_RAZE_BUTTON_TEXT, tooltip TXT_KEY_CITYVIEW_RAZE_BUTTON_TT). Voluntary self-raze: destroy your own city. Disabled for ex-capital (TXT_KEY_CITYVIEW_RAZE_BUTTON_DISABLED_BECAUSE_CAPITAL_TT) and for the current capital. Also disabled by No City Razing game option.

Rename is especially load-bearing for blind play because similarly-named cities (auto-generated) are hard to disambiguate in notifications.

## 5.19 Foreign City View (Espionage Scouting) - NOT STARTED

Opening a foreign city through Espionage (spy stationed in an enemy or neutral city) uses the same CityView panel in read-only mode. The Return button is labeled TXT_KEY_CITYVIEW_RETURN_TO_ESPIONAGE; production cannot be changed, tiles cannot be bought, buildings cannot be sold. The view exists solely to let the player scout the city buildings, great works, garrison, and yield output before planning a stealing mission or conquest.

- All readouts present in owned-city view are present in read-only form.
- No action buttons other than Return and the Next and Previous City cycle (which cycles among other foreign cities the player has spy access to).
- Foreign great work slots are visible (BNW), which is how you identify what to steal with a Great Writer or Musician.
- The disabled-because-no-spy tooltip (TXT_KEY_EO_CITY_VIEW_DISABLED_NO_CITY_TT) appears if the spy is not yet assigned.

This mode shares the same Lua and XML; the mod's speech logic should fork on the Return-button text to decide whether write-actions are available.
# Phase 6: Research and Progression

## 6.1 Tech Chooser Popup - NOT STARTED

When a research project completes (or when the game starts with no tech selected), the engine fires `SerialEventGameMessagePopup` with `ButtonPopupTypes.BUTTONPOPUP_CHOOSETECH` and `TechPopup` opens as a modal chooser. It is a vertically scrolling list of every tech the player can start researching now, rendered from the `TechButtonInstance` template in `UI/InGame/TechPopup.xml`. Each row is a clickable button that selects that tech; selection closes the popup and begins research.

Each tech row carries: tech name, icon, base research cost in science, estimated turns to completion at the current science-per-turn rate, and a body of "what you unlock" bullets generated by `TechButtonInclude` (units, buildings, wonders, resource reveals, improvements, abilities, other techs it leads to, and free-promotion or free-tile-improvement effects). G&K adds religion-related unlocks (founding and enhancing religion prerequisites); BNW adds archaeology, tourism, and ideology era-gating. The popup also contains an `OpenTTButton` to swap to the full tech tree without picking, and a close affordance. If the player has banked free techs from Great Scientists, Oxford University, or a ruin, slots B1 through B5 display those separately and route through `TechAwardPopup` once chosen.

- Tech list rendered into `ButtonStack`, one entry per available tech.
- Per-entry data: name, icon, base cost in science, turns at current output, unlocks list.
- `OpenTTButton` switches to the full tech tree without committing a choice.
- No explicit cancel. Choosing is mandatory; the popup blocks end-of-turn until resolved.

## 6.2 Tech Tree (Full Screen) - NOT STARTED

Opened from the TopPanel science readout, from within the chooser popup, or from the research overview. `TechTree.xml` lays out a horizontally panning two-dimensional grid of all tech nodes, grouped into era columns (Ancient, Classical, Medieval, Renaissance, Industrial, Modern, Atomic, Information). BNW retunes Atomic and Information pacing and ships its Lua under `DLC/Expansion2/UI/TechTree/`. Prerequisite lines are drawn between nodes. The legend in the bottom-left explains node color states: `TXT_KEY_TECH_NOT_YET_AVAILABLE`, `TXT_KEY_TECH_AVAILABLE`, `TXT_KEY_TECH_CURRENT_RESEARCH`, `TXT_KEY_TECH_RESEARCHED`.

Each tech node is a clickable button showing tech name, icon, science cost, era tag, and the same unlocks list as the chooser popup in its tooltip. Clicking an unresearched reachable node starts or queues it. Clicking a researched node shows its Civilopedia entry. The tree also exposes the B1 through B5 free-tech slots at the top and a close button. BNW adds ideology-unlock era markers rendered as era banners in the `EraStack`.

- Scroll panel with horizontal-only scrolling over `EraStack`.
- Per-node: name, era, cost, status (locked, available, current, done), prerequisite lines, full unlocks tooltip.
- Free-tech indicators B1..B5 at the header when the player has banked selections.
- `CloseButton` returns to world view.
- Research queue: shift-click chains tech selections; queue order and per-tech turn estimates are visual only, with no audible readout.

## 6.3 Research Overview (TechPanel) - NOT STARTED

The permanent compact research readout lives on the main HUD. `TechPanel.xml` shows the currently researching tech icon, name, a fill bar for progress, turns remaining, and the B1..B5 free-tech slots. `BigTechButton` is the large icon that opens the full tech tree; `TechButton` swaps to the chooser popup when no research is set. G&K and BNW override this file to accommodate faith and tourism-driven modifiers in the tooltip. The same information is duplicated in the TopPanel `SciencePerTurn` readout, which also opens the tree when clicked.

- Current tech name, icon, percent complete, turns remaining.
- `BigTechButton` opens full tree; `TechButton` opens chooser when idle.
- B1..B5 free-tech indicators when applicable.
- Idle-research state is silent in the base game; the engine nags once per turn via a notification.

## 6.4 Tech Award Popup - NOT STARTED

Fires when a tech completes (`BUTTONPOPUP_TECH_AWARD`) unless the player has disabled the popup in options. `TechAwardPopup.xml` shows the tech name, icon, flavor quote (from `pTechInfo.Quote`), and the full `TXT_KEY_<TECH>_HELP` unlocks body. A `ContinueButton` dismisses and, if chained free techs exist, queues the next award or chooser.

- Tech name, icon, quote, help body listing unlocks.
- `ContinueButton` and `CloseButton` both dismiss.
- Fires in sequence when multiple techs complete in one turn (chained via the popup queue).

## 6.5 Free Tech Popup (ChooseFreeItem) - NOT STARTED

Great Scientist bulb, Oxford University completion, research agreements, certain ruins, and the Liberty finisher trigger a free-tech grant routed through `ChooseFreeItem` (G&K and BNW Lua-override it). The popup is a list of every tech currently grantable to the player. Each entry uses the same `TechButtonInstance` as the chooser, so the displayed information matches section 6.1. A `ConfirmButton` commits the selection and a `Close` dismisses with no pick made (the grant is deferred until the player returns).

- Same per-tech information shape as the chooser popup.
- `ConfirmButton` applies the grant; `Close` cancels without consuming the charge.
- Also used for free-policy grants (Piety finisher, some wonders) with the same Lua and a different item type.

## 6.6 Social Policy Screen - NOT STARTED

Opened from the DiploCorner `SocialPoliciesButton`, the TopPanel culture readout, or the `BUTTONPOPUP_CONFIRM_POLICY` notification. `SocialPolicyPopup.xml` is the combined policy and ideology chooser; BNW override adds the ideology tab and tenet picker. The screen has a header strip with the civilization icon, next policy cost (`TXT_KEY_NEXT_POLICY_COST_LABEL`), current culture stockpile (`TXT_KEY_CURRENT_CULTURE_LABEL`), culture per turn (`TXT_KEY_CULTURE_PER_TURN_LABEL`), turns until next policy (`TXT_KEY_NEXT_POLICY_TURN_LABEL`), and a free-policies counter (`TXT_KEY_FREE_POLICIES_LABEL`) when Liberty finisher or a wonder has granted free picks.

Policy tree branches are laid out as named panels: `TraditionPanel`, `LibertyPanel`, `HonorPanel`, `PietyPanel`, `AestheticsPanel` (BNW), `PatronagePanel`, `CommercePanel`, `ExplorationPanel` (BNW), `RationalismPanel`, plus the ideology panel in BNW. Each branch is a miniature tree of policy icons (`PolicyButton` template instanced into the panel) with connector pipes (`ConnectorPipe` template) drawn between prerequisites. Branch headers (`BranchButton0` through `BranchButton8`) unlock the whole branch when clicked, consuming one policy point; they show adoption text via `TXT_KEY_POP_ADOPT_BUTTON` and tooltips for blocked states: `TXT_KEY_POLICY_BRANCH_CANNOT_UNLOCK_RELIGION` (Piety and Rationalism mutual exclusion), `TXT_KEY_POLICY_BRANCH_CANNOT_UNLOCK_ERA` (requires era), `TXT_KEY_POLICY_BRANCH_CANNOT_UNLOCK_CULTURE` (need more culture), `TXT_KEY_POLICY_BRANCH_BLOCKED` (locked by opposing branch), `TXT_KEY_POLICY_BRANCH_UNLOCK_SPEND`.

Each individual policy icon shows the policy name, its branch, its prerequisite arrows, effect text, and an adopted, available, or locked state. Clicking an available policy opens a `PolicyConfirm` sub-dialog with Yes and No buttons. `PolicyInfo` is a toggle for compact versus verbose effect descriptions. The `CloseButton` exits. `LabelPoliciesDisabled` appears when the player has entered an ideology that blocks further social-policy adoption in Industrial or later.

- Header: civ icon, next policy cost, culture stockpile, culture per turn, turns to next policy, free policies remaining.
- Nine branches (ten with ideology tab in BNW), each with opener button and child policy grid.
- Per-policy: name, branch, effect text, prerequisite lines, state.
- Blocked-branch tooltips carry the reason in localized form.
- `PolicyConfirm` Yes/No subdialog for each adoption.
- `SwitchIdeologyButton` (BNW only) appears once an ideology is adopted, with tooltip `TXT_KEY_POLICYSCREEN_CHANGE_IDEOLOGY_TT` or disabled variant.

### 6.6.1 Policy Branch Confirm (ConfirmPolicyBranchPopup) - NOT STARTED

Popping a new branch opens a Yes/No confirmation with branch description and cost. Reuses `GenericPopup.xml`. Uses `TXT_KEY_POLICYSCREEN_CONFIRM_TENET` and branch-specific adoption strings.

## 6.7 Ideology Selection (BNW) - NOT STARTED

When a player enters the Industrial era (earlier with certain wonders) and has no ideology, `ChooseIdeologyPopup.xml` opens. It presents the three ideology branches (Freedom, Order, Autocracy) as three large buttons in `ItemStack`. Each button shows branch name, an icon, a summary of the Level 1, Level 2, and Level 3 tenet counts, and the free-policy bonus for being first or second to adopt (`TXT_KEY_CHOOSE_IDEOLOGY_NUM_FREE_POLICIES`). A `ViewTenetsPopup` subpanel opens a scrollable popup listing every Level 1, Level 2, and Level 3 tenet under the selected ideology with full effect text; its headers come from `TXT_KEY_POLICYSCREEN_L1_TENET`, `_L2_TENET`, `_L3_TENET`. `ConfirmYes` and `ConfirmNo` commit the choice and it is permanent barring a revolution from public opinion.

- Three ideology cards (Freedom, Order, Autocracy) each with name, icon, tenet-count summary, adoption-order bonus text.
- `ViewTenetsPopup` subpanel: scrollable list of all tenets by level with effect text.
- `ConfirmYes` and `ConfirmNo` on choice.
- `ChooseConfirm` subdialog uses `TXT_KEY_CHOOSE_IDEOLOGY_CONFIRM`.

### 6.7.1 Tenet Selection - NOT STARTED

After the ideology is chosen, subsequent policy points spend on tenets. `SocialPolicyPopup` switches to its ideology tab (`TabButtonIdeologies`), where `TenetStack` renders `TenetChoice` instances for each currently pickable tenet grouped by level. A `ChooseTenet` modal appears when the player has a policy point to spend; each tenet row shows name, effect text, and level badge. `TenetConfirm` Yes/No subdialog confirms. `TXT_KEY_POLICYSCREEN_ADD_TENET` labels unpicked slots; `TXT_KEY_POLICYSCREEN_NEED_L1_TENETS_TOOLTIP` and `_NEED_L2_TENETS_TOOLTIP` explain gating (must buy two of level N before level N plus 1).

- Level 1, Level 2, Level 3 tenet rows rendered when unlocked.
- Each tenet: name, level, effect text, tooltip with prerequisites.
- `TenetConfirmYes` and `TenetConfirmNo` subdialog per choice.
- Public opinion readout (`PublicOpinion`, `PublicOpinionUnhappiness`): current state (Content, Dissidents, Civil Resistance, Revolutionary Wave) and unhappiness amount with tooltip breakdown. `SwitchIdeologyButton` becomes active when a revolution forces change.

## 6.8 Great Person Selection Popups - NOT STARTED

When a Great Person is earned through accumulated points, the engine fires `BUTTONPOPUP_GREAT_PEOPLE_CHOICE` or displays `GreatPersonRewardPopup.xml` directly. The reward popup shows a portrait, the Great Person name, their civilization-born-in label via `TXT_KEY_GREAT_PERSON_REWARD` (substituted with the GP type description and the city name), and a `CloseButton`. There is no branching choice here; the GP simply spawns.

For faith-bought Great People, `ChooseFaithGreatPerson` opens as a selectable list of GP types the player can buy at current faith (Prophet, General, Admiral, plus Artist, Musician, Writer, Scientist, Engineer, Merchant after Industrial era), each with cost in faith and a `ConfirmButton`. The layout reuses a list template instanced off the generic popup frame.

For the Liberty finisher free Great Person, `ChooseFreeItem` is reused to pick from any of the six civilian GPs (Great Artist, Engineer, Merchant, Prophet in G&K, Scientist, Musician or Writer in BNW).

- `GreatPersonRewardPopup`: portrait, name, born-in-city text, dismiss.
- `ChooseFaithGreatPerson`: list of faith-purchasable GP types with costs, `ConfirmButton`.
- Liberty free GP routed through `ChooseFreeItem` with GP entries.
- `ChooseAdmiralNewPort` (BNW) opens when a Great Admiral needs a home port chosen: `GoToCity` previews, `ConfirmYes` and `ConfirmNo` commits.

## 6.9 Wonder Race Notifications - NOT STARTED

Wonder availability and construction events are pure notifications on the `NotificationPanel`, not modal popups, except the completion splash. When someone starts a wonder the player has access to, a `GenericButton` notification fires. When a wonder is built, `WonderPopup.xml` opens with the wonder splash image, name, flavor quote, effect text, and a `Close` button; the same popup also fires for other civs wonders as a built-in-a-distant-land variant. `BUTTONPOPUP_CULTURE_CHOOSE_WONDER` (BNW) covers Hermitage, Uffizi, and Louvre slot assignments and routes through an internal chooser.

- Start-of-wonder notification: `NotificationPanel` entry with tooltip listing civs racing the same wonder.
- Completion: `WonderPopup` with name, quote, effects, close.
- Player-missed-wonder: identical splash with a different body string.
- BNW `CULTURE_CHOOSE_WONDER` routes great-work placement into the CultureOverview flow.

---
# Phase 7: Diplomacy

Diplomacy is the most dialog-heavy subsystem in Civ V. It spans leader-to-leader conversations, structured trade deals, city-state relations, and (in BNW) a full legislative body with proposals and votes. Every diplomatic interaction is driven by engine-side ButtonPopupTypes messages that spawn a specific popup context, with the AI response text composed server-side and handed to Lua as a finished string. Almost nothing here is selectable with standard keyboard navigation; most screens are mouse-driven button grids with no focus indicator, tooltips gated behind hover, and state that changes silently as deals are constructed. The leader-head screen in particular overlays a 3D character animation on top of the dialog and buttons, with no textual equivalent for the leader mood shown on their face.

This phase covers the leader-head root, trade UI, diplomacy overview, city-state popup, declare-war and peace confirmation flows, the World Congress and its pre-BNW United Nations predecessor, and the league and vote splash popups. Spy-related diplomacy is covered here only where it surfaces as a diplo dialog option; the Espionage Overview itself is Phase 10.

## 7.1 Leader Head Root (LeaderHeadRoot) - NOT STARTED

The full-screen diplomacy root that opens any time the player initiates contact with an AI civ or the AI initiates contact with the player. base / G&K / BNW. Driven by LeaderHeadRoot.lua under UI/InGame/Diplomacy/ in base and under each expansion UI/InGame/LeaderHead/ directory. The screen is triggered by the LeaderMessageHandler callback on Events.AILeaderMessage, which receives the AI player id, a DiploUIStateTypes constant, a pre-localized leader message, an animation action, and a data payload. The DiploUIState determines which action buttons are enabled and which child panel is active.

Layout is a 3D leader model on the left (a full-screen character rig with idle, speaking, angry, and pleased animations), a speech bubble frame showing the AI current line, a mood indicator near the top showing the AI approach toward the player, and an action button row along the bottom.

- Title text: the leader localized title, for example Gandhi of India, built from GameplayUtilities.GetLocalizedLeaderTitle(player)
- Mood text: one of TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR, _DENOUNCING, _LIBERATED, _HOSTILE, _GUARDED, _AFRAID, _FRIENDLY, _NEUTRAL, or TXT_KEY_WAR_CAPS / TXT_KEY_EMOTIONLESS as fallback. Computed from pActivePlayer:GetApproachTowardsUsGuess(iAIPlayer)
- Mood tooltip: a multi-line breakdown of why the AI feels this way (shared opinion modifiers, you denounced us, we share a friend, and so on), only available on hover
- Leader speech text: the line szLeaderMessage passed in from the engine. This is the single most important piece of text on the screen and it updates each time the AI responds
- Action buttons: DiscussButton (opens DiscussionDialog), DemandButton, TradeButton (opens DiploTrade), WarButton, BackButton
- Available actions change per DiploUIState. At war, only peace-negotiation paths are reachable; at peace with a friend, Demand is hidden
- The 3D leader head plays animations synced to the voice-over speech file. No textual cue marks which animation is playing

## 7.2 Discuss Leader Menu (DiscussLeader) - NOT STARTED

A submenu of the leader-head screen reached by clicking Discuss. base only; G&K and BNW fold these options into DiscussionDialog. The options are a flat list of conversation openers that each trigger a new DiploUIState round-trip and a new leader response.

- Opinion: ask what the AI thinks of you. Returns a mood breakdown in speech
- Like: express that you like them (improves relations slightly)
- Dislike: the inverse
- Attack: declare intent to attack (triggers a response without actually declaring war)
- Back

## 7.3 Discussion Dialog (DiscussionDialog) - NOT STARTED

The omnibus multi-choice dialog used for AI-initiated conversations and player-initiated discussions. base / G&K / BNW (expanded substantially in G&K and again in BNW). Reuses the same 3D leader head root and presents up to eight contextual buttons labeled by the active DiploUIState.

Known buttons Button1 through Button8 plus CloseLeaderPanel, DenounceConfirmYes, DenounceConfirmNo. The content of each button depends entirely on the state. Common states and their buttons include:

- AI requests help against a third party: accept / decline
- AI offers declaration of friendship: accept / decline / not now
- Player opens Discuss from root: Denounce, Declaration of Friendship, Request (gifts or aid), Cooperation (joint war or embargo), Open Borders Offer, and others
- Denounce confirm: Yes / No secondary popup layered on top of the speech frame
- AI warns you for settling near their borders, spying, building wonders they wanted, and so on: acknowledge / apologize / refuse
- AI demands tribute (for weaker AIs demanding from stronger, or vice versa): give gold / give city / refuse
- AI requests a specific luxury or strategic resource: accept / counter-offer / refuse

Each dialog consumes the prior leader speech, replaces it with a new line, and either closes out (returning to root) or presents a follow-up set of buttons. The denunciation confirm overlay is a modal inside the modal with yes/no. None of this flow is keyboard-navigable beyond ESC to close.

## 7.4 Diplomacy Trade Screen (DiploTrade) - NOT STARTED

The structured trade interface. base / G&K / BNW. Triggered from TradeButton on LeaderHeadRoot or when the AI proposes a deal. Driven by TradeLogic.lua (an include file; the XML is DiploTrade.xml and its Lua is DiploTrade.lua). The screen is a two-column exchange: the player offer pocket on the left, the AI offer pocket on the right, with a what-is-on-the-table summary across the bottom and commit buttons.

Each side has a Pocket panel listing what can be added to the deal, and a Table panel showing what is currently being offered. Clicking a pocket item moves it to the table. The item types, with their buttons on both UsPocket / ThemPocket and UsTable / ThemTable, are:

- Gold lump sum. Amount typed into an AmountEdit text field (TXT_KEY_DIPLO_GOLD)
- Gold per turn for 30 turns (TXT_KEY_DIPLO_GOLD_PER_TURN)
- Luxury resources: a submenu listing each tradeable luxury with quantity (TXT_KEY_DIPLO_LUXURY_RESOURCES)
- Strategic resources: a submenu per resource with quantity (TXT_KEY_DIPLO_STRATEGIC_RESOURCES)
- Votes in the UN or World Congress (TXT_KEY_TRADE_ITEM_VOTES), BNW and late-game base
- Allow Embassy (G&K+, TXT_KEY_DIPLO_ALLOW_EMBASSY). One-way permission to establish a permanent embassy
- Open Borders (TXT_KEY_DIPLO_OPEN_BORDERS). 30-turn agreement
- Defensive Pact (TXT_KEY_DIPLO_DEF_PACT). 30-turn mutual defense
- Research Agreement (TXT_KEY_DIPLO_RESCH_AGREEMENT). Costs gold from both, grants a free tech after 30 turns
- Trade Agreement (TXT_KEY_DIPLO_TRADE_AGREEMENT). Hidden in base game, not implemented
- Cities (TXT_KEY_DIPLO_CITIES). Submenu listing each side cities; city transfer
- Other Players: submenu for declaring war on or making peace with a third party (TXT_KEY_DIPLO_MAKE_PEACE_WITH, TXT_KEY_DIPLO_DECLARE_WAR_ON). Each lists every met civ
- Peace Treaty (context-sensitive, only when at war)
- Tech (base game only, removed in BNW). Submenu of each side tradeable techs
- Declaration of Friendship (G&K+). A free-to-both-sides item; appears on both Table panels when proposed
- Maps (base only, removed in G&K)

Commit row:

- WhatDoYouWantButton (TXT_KEY_DIPLO_WHAT_WANT_FOR_THIS): ask AI what they want for what is on their side
- WhatWillYouGiveMeButton (TXT_KEY_DIPLO_WHAT_GIVE_FOR_THIS): ask AI what they will give for what is on your side
- WhatWillMakeThisWorkButton (TXT_KEY_DIPLO_MAKE_DEAL_WORK): ask AI to balance the current offer
- WhatWillEndThisWarButton (TXT_KEY_DIPLO_END_CONFLICT): ask AI for peace terms
- WhatConcessionsButton (TXT_KEY_DIPLO_WHAT_WANT): general what do you want
- Proposed Trade Value label: the AI internal valuation delta, shown as a tooltip on hover only
- Make Deal / Cancel / Equalize / Clear table buttons

The screen has a second variant, SimpleDiploTrade (base / G&K / BNW, SimpleDiploTrade.xml under WorldView/), used when the AI initiates a short one-item deal like please declare war on X for me or will you accept our declaration of friendship. It shares the pocket and table structure but pre-populates the table and usually allows only accept or decline.

Tooltips on every pocket item describe why it is disabled if it is (no embassy yet, already have an agreement, not enough gold on hand, and so on). These never appear in speech.

## 7.5 Diplomacy Overview (DiploOverview) - NOT STARTED

A tabbed window opened from the DiploButton in the persistent DiploCorner. base / G&K / BNW. Three tabs: RelationsButton, DealsButton, GlobalPoliticsButton, plus Close.

- Relations tab (DiploRelationships): one row per known civ with leader portrait, civ name, relationship status word, and a LeaderButton to open LeaderHeadRoot for that civ. base / G&K / BNW
- Deals tab (DiploCurrentDeals): current active deals and historic deals. Two sub-tabs CurrentDealsButton and HistoricDealsButton. Each entry is a deal record: parties, turn signed, turns remaining, and the same pocket-category breakdown as DiploTrade showing what each side gave
- Global Politics tab (DiploGlobalRelationships): a matrix of every known civ relation to every other known civ. BNW adds denunciations, declarations of friendship, defensive pacts, and ideology alignment indicators to each cell. Only shown for relationships the player has intel on (embassy or visibility via spy). The layout is a grid of leader portrait columns and rows with icon glyphs in each cell (friend, enemy, denounced, DoF, allied, at-war)

## 7.6 City-State Greeting Popup (CityStateGreetingPopup) - NOT STARTED

Fires once the first time the player unit enters a city-state territory, triggered by BUTTONPOPUP_CITY_STATE_GREETING. base / G&K / BNW. Announces the city-state name, type, and initial disposition, and offers a first-meet bonus choice or a flat reward depending on traits the player has unlocked.

- Welcome text (leader-style speech, but no 3D model; static illustration instead)
- City-state name and type label (Militaristic, Cultural, Maritime, Mercantile, Religious - Religious added in G&K)
- Initial trait description
- Close button and FindOnMapButton (zooms camera to the CS capital)
- ScreenButton: routes to the full CityStateDiploPopup

An alternate XML layout CityStateGreetingPopupOpenCenter.xml exists for some triggers (probably the first-unit-enters variant versus a special-unit-gift variant); same Lua.

## 7.7 City-State Diplomacy Popup (CityStateDiploPopup) - NOT STARTED

The interaction hub for a single city-state, reached by clicking the city-state banner or notification. base / G&K / BNW, with G&K adding religion-trait handling and BNW adding pledge-to-protect, buyout, and the expanded quest list. Triggered by BUTTONPOPUP_CITY_STATE_DIPLO or BUTTONPOPUP_CITY_STATE_MESSAGE.

Top of the popup shows status information:

- StatusLabel (TXT_KEY_POP_CSTATE_STATUS): current relationship (Allied, Friend, Neutral, Afraid, Angry, War)
- QuestLabel (TXT_KEY_POP_CSTATE_QUESTS): count and list of active quests
- AllyLabel (TXT_KEY_POP_CSTATE_ALLIED_WITH): current ally civ if any
- TraitLabel (TXT_KEY_POP_CSTATE_TRAIT): the CS personality archetype (Friendly, Neutral, Hostile, Irrational)
- PersonalityLabel (TXT_KEY_POP_CSTATE_PERSONALITY): flavor text
- ResourcesLabel (TXT_KEY_POP_CSTATE_RESOURCES): luxuries and strategics they will share if allied
- Influence bar showing current Influence value, resting point, and decay rate. The numeric value and change-per-turn appear in a tooltip only

The main action column is a vertical stack of buttons whose visibility depends on state:

- PeaceButton (TXT_KEY_POP_CSTATE_MAKE_PEACE): only shown when at war with this CS
- GiveButton (TXT_KEY_POP_CSTATE_GIFT_GOLD): opens the gift submenu
- PledgeButton (TXT_KEY_POP_CSTATE_PLEDGE_TO_PROTECT): G&K+ pledge
- RevokePledgeButton (TXT_KEY_POP_CSTATE_REVOKE_PROTECTION): G&K+ revoke
- TakeButton (TXT_KEY_POP_CSTATE_BULLY): demand tribute. Opens Bully submenu
- WarButton (TXT_KEY_POP_CSTATE_DECLARE_WAR)
- NoUnitSpawningButton (TXT_KEY_POP_CSTATE_STOP_UNIT_SPAWNING): Militaristic CS-specific, stops them gifting units
- BuyoutButton (TXT_KEY_POP_CSTATE_BUYOUT): Austria UA only, or late-game for anyone in BNW

Gift submenu (Give):

- SmallGiftButton, MediumGiftButton, LargeGiftButton (three gold tiers, amount varies by era)
- UnitGiftButton: gift a military unit you own. Opens a unit picker
- TileImprovementGiftButton: gift a Worker-built improvement near their border (specific scenario or UA)
- ExitGiveButton / back

Bully submenu (Take):

- GoldTributeButton: demand a lump sum
- UnitTributeButton: demand a Worker unit
- ExitTakeButton / back
- BullyConfirm sub-popup: yes/no on the actual bully action, since a failed bully tanks influence

Bottom row:

- CloseButton
- FindOnMapButton (TXT_KEY_POP_CSTATE_FIND_ON_MAP)

### 7.7.1 City-State Quest Display - NOT STARTED

Quests are listed inside the same popup QuestInfo section. Each active quest shows its localized name and reward (Influence amount, plus sometimes gold or a Great Person point). Quest types include:

- Connect a luxury resource we need
- Build a specific wonder
- Bully a rival city-state
- Kill a specific barbarian encampment (coordinates shown as a map pin, not spoken)
- Give us gold
- Destroy a rival city-state (G&K+)
- Pledge to protect us (G&K+)
- Trade route to us (BNW)
- Invest (BNW: give gold, longer-term quest with bigger Influence reward)
- Influence a civilization via tourism (BNW, Ideology era)
- Global quest: win a contest across all players (tech race, wonder race, tourism race) (BNW)
- Culture from Great Works or Artifacts (BNW)

Quest turns-remaining and the specific target (which wonder, which barbarian camp location, which civ) appear in tooltip only on most variants.

### 7.7.2 City-State Types and Bonuses - NOT STARTED

The five CS types each grant different rewards per relationship tier (Friend vs Ally):

- Militaristic: periodic gifted military units, tier-scaled (warriors, then swordsmen, then units two eras ahead)
- Cultural: flat culture per turn, scaled by tier
- Maritime: food to capital and all other cities, scaled
- Mercantile: happiness plus unique luxuries (Jewelry, Porcelain) when allied
- Religious (G&K+): faith per turn

These are expressed on the CS popup as a tooltip on the type label; the actual numerical bonuses are not shown in plain text.

## 7.8 Declare War Popup (DeclareWarPopup) - NOT STARTED

A confirmation popup summarizing everything that will break if the player declares war. BNW only; earlier editions use a simpler GenericPopup with Yes/No. Triggered as part of the declare-war flow before the action is committed.

- PopupText: the main question, including who the war is with
- DiplomacyHeader: list of civs who will be upset with you for declaring
- UnderProtectionOfHeader: civs who have pledged to protect the target (they will denounce you if you proceed)
- AlliedCityStatesHeader: CS who are allied with the target and will declare war on you
- ActiveDealsHeader: list of active deals with the target that will be canceled (embassy, OB, DP, RA, GPT, luxury trades)
- TradeRoutesHeader: list of trade routes with the target that will be plundered or lost
- Button1 (Declare War) / Button2 (Cancel)

The pre-BNW variants are subclasses triggered from specific contexts:

- DeclareWarMovePopup (G&K and BNW Lua overrides): moving this unit into their territory will declare war, continue yes or no
- DeclareWarRangeStrikePopup (BNW): firing a ranged attack at this target will declare war
- DeclareWarPlunderTradeRoutePopup (BNW only): plundering this trade route will declare war on its owner

Each presents Yes/No and the cost summary.

## 7.9 Denunciation Flow - NOT STARTED

Public denunciation is routed through DiscussionDialog (Denounce button) with a DenounceConfirmYes / DenounceConfirmNo sub-overlay on top of the speech frame. G&K / BNW. Once confirmed, the target civ relation becomes Denouncing, every met civ gets a notification, and the target opinion of the player drops sharply. The AI reaction speech is delivered immediately on the same screen.

- Denounce button text
- Confirm yes / no
- Target immediate response speech (replaces the dialog speech bubble)
- Side-effect feedback: none on-screen beyond the notification icons appearing later

## 7.10 Peace Negotiation Flow - NOT STARTED

Peace is a trade-screen flow, entered from DiscussionDialog make-peace button or the AI peace offer. Uses DiploTrade with the WhatWillEndThisWarButton as the main action. Peace treaties are 10 turns minimum; the treaty line appears on both Table panels as a locked item once accepted. base / G&K / BNW.

After peace is made, LeaderMessageHandler is called with DIPLO_UI_STATE_PEACE_MADE_BY_HUMAN, which keeps the leader head visible for a closing line before dropping back to the world.

## 7.11 Embassy Exchange - NOT STARTED

G&K / BNW only. Embassies are a one-way trade item (TXT_KEY_DIPLO_ALLOW_EMBASSY) offered through DiploTrade. Granting an embassy gives the other civ visibility into your capital, your current tech, your approximate military strength, and enables them to see your deals with third parties. Revocation is not a UI action; embassies persist until the player-target relationship breaks down (war, denouncement).

The act of trading an embassy is identical to any other trade item: click the pocket item on your side, click Make Deal. No dedicated screen; confirmation is implicit in the trade acceptance.

## 7.12 World Congress Overview (LeagueOverview) - NOT STARTED

BNW only. The World Congress is founded when two civs have met every other civ, or immediately on reaching a specific tech (Printing Press). It transitions into the United Nations late game. Opened from the LeagueOverviewButton on DiploList or from a notification. Driven by LeagueOverview.lua and triggered by BUTTONPOPUP_LEAGUE_OVERVIEW.

The screen has one tab per active league session state. Controls and content:

- MainFrame title: league name (renameable via RenameButton if you are host). Default TXT_KEY_LEAGUE_WORLD_CONGRESS or TXT_KEY_LEAGUE_UNITED_NATIONS
- Host indicator: leader portrait of the current host civ (the host proposes extra resolutions and gets a vote bonus)
- TurnsUntilVoteFrame: countdown to next vote or next proposal phase
- Session phase: Proposal Phase, Voting Phase, or Recess. Each phase has different actions available
- Member list: every civ in the league with their current delegate count. MemberButton1 through 4+ per seat. Delegate counts come from host status, city-state allies, Forbidden Palace, Globalization tech, and various resolutions
- Active Resolutions stack (ActiveResolutionStack): resolutions currently in force, each with a ResolutionButton that opens a details tooltip
- Proposed Resolutions stack (ProposalStack2): resolutions up for vote this session, each with a VoteUpButton, VoteDownButton, and for choice-based resolutions a ResolutionChoiceButton grid of targets
- Inactive and Disabled Resolutions: repealed or locked-out resolutions, shown for reference
- Active Effects (ActiveEffectsStack): the aggregate gameplay effects of all currently-in-force resolutions, in plain-text form. Example: Natural Wonders provide +2 Science, Scholars in Residence active
- ProposeButton (TXT_KEY_LEAGUE_OVERVIEW_PROPOSE_BUTTON): during the proposal phase, lets the player propose one enact or one repeal. Opens a scrollable list of valid resolutions
- Enact prefix (TXT_KEY_LEAGUE_OVERVIEW_PREFIX_ENACT) vs Repeal prefix (TXT_KEY_LEAGUE_OVERVIEW_PREFIX_REPEAL) on each proposal

Resolution types (BNW):

- Standing resolutions: International Games, International Space Station, World Fair (these are League Projects, see 7.13)
- Target-a-civ resolutions: World Religion, World Ideology, Embargo City-States, Embargo (specific civ), Scholars in Residence (target civ tech), Casus Belli on a target
- Target-a-resource: Ban Luxury Happiness (loses +4 happy bonus worldwide for that luxury)
- Flat effect: Arts Funding (culture and tourism), Sciences Funding (science), World Fair bonuses, Historical Landmarks (tourism from wonders)
- Host-power-only: Nuclear Non-Proliferation, Global Peace Accord
- Repeal: removes an active resolution

Each resolution vote outcome is yes votes, no votes, abstain. Outcome shown live as votes come in from the AI. The player own delegates are spent via +1 / -1 steppers (VoteUpButton / VoteDownButton) up to their cap.

Host election is its own resolution voted on every 30 turns; whoever wins hosts the next session plus gets +1 bonus delegate per session.

## 7.13 League Project Popup (LeagueProjectPopup) - NOT STARTED

BNW only. When a League Project resolution (World Fair, International Games, International Space Station) is passed, this popup opens to describe the project, its production cost per civ, and the tier rewards.

- Project name and description
- Per-civ production contribution threshold for Bronze, Silver, Gold tiers
- Global production progress bar
- Reward summary: what the top contributor, second-tier, and third-tier get
- Close button only (no direct interaction; contributions come from ProductionPopup ProduceLeagueProject buttons in city production queues)

## 7.14 League Splash (LeagueSplash) - NOT STARTED

BNW only. A celebratory full-screen popup shown when the league is founded, when it upgrades from World Congress to United Nations, and when a session begins. Close-only, auto-dismissable.

- Title: which league event (The World Congress is Founded, United Nations Established)
- Flavor text describing the transition
- Close

## 7.15 Vote Results Popup (VoteResultsPopup) - NOT STARTED

Fires at the end of each voting session. base (for UN), G&K (UN), BNW (World Congress and UN). Announces the outcome of each resolution voted on this session and the host-election outcome.

- Per-resolution result row: resolution name, enacted or failed, yes/no tallies
- Diplomatic Victory outcome row: if a UN vote for world leader was held, which civ won or how far short the leader fell (one of the base-game three victory conditions pre-BNW)
- Close

## 7.16 Diplo Vote Popup (DiploVotePopup) - NOT STARTED

The pre-BNW United Nations vote UI, also used by the BNW Diplomatic Victory vote. base / G&K / BNW. Triggered by BUTTONPOPUP_DIPLO_VOTE. Presents a scrollable list of every civ (plus abstain) as a vote target.

- ButtonStack: one DiploVoteButton per eligible target, each showing the civ leader portrait, civ name, and a known-modifier tooltip
- Vote is committed via Network.SendDiploVote(iVotePlayer) and the popup closes
- Close

In BNW this is used for the Host election round and the final Diplomatic Victory round; the general-purpose World Congress votes use LeagueOverview inline voting instead.

## 7.17 Whos Winning Popup (WhosWinningPopup) - NOT STARTED

A pre-vote preview of the upcoming Diplomatic Victory round. G&K XML-only / BNW full Lua. Shows every civ anticipated vote count heading into the UN or World Congress diplo-win vote. Close-only.

## 7.18 Global Relations (DiploGlobalRelationships) - NOT STARTED

Covered as a tab of 7.5 above, but worth calling out separately. The Global Politics tab is the only consolidated view of the international landscape the player has. For a blind player this is critical. The tab is where you learn that civ A denounced civ B, that civs C and D are in a defensive pact, that civ E is hostile to everyone. The visual layout is an NxN grid of icon glyphs with tooltip text per cell. No textual summary of the map exists.

## 7.19 Gift Unit and Liberate City Options - NOT STARTED

Gifting a unit to a city-state is handled inside CityStateDiploPopup UnitGiftButton, which opens a unit-picker listing every eligible military or great-person unit the player owns, with the CS reaction preview. Gifting a unit to a major civ is a one-off trade item that surfaces in DiploTrade only in scenarios.

Liberating a captured city back to its original owner is handled by LiberateMinorPopup (for city-states) and as an option in AnnexCityPopup / PuppetCityPopup when the captured city prior owner is still alive. The liberation option shows the would-be-liberated civ name and the expected relations boost. base / G&K / BNW (LiberateMinorPopup in base; AnnexCityPopup Liberate option in G&K+). Yes/No confirmation.

## 7.20 Tribute Demands Between Major Civs - NOT STARTED

Distinct from city-state bullying. Triggered via DiscussionDialog when an AI demands tribute from a weaker player, or when a strong player initiates a demand via the Demand action on LeaderHeadRoot. Presents:

- Demand speech: what the AI wants (gold sum, specific resource, specific city)
- Options: Give / Refuse / Counter-offer
- Refusing costs relations and can trigger war declaration from the AI on their next turn

No dedicated screen; reuses the DiscussionDialog button row.

## 7.21 Minor Civ Territory Entry (MinorCivEnterTerritoryPopup) - NOT STARTED

base / G&K / BNW. Fires when the player non-scout unit enters a minor civ territory without permission. Yes/No: leave or stay (staying costs Influence). Relevant because this is a common first-contact failure mode and the popup can easily be dismissed accidentally.

## 7.22 Minor Civ Gold Popup (MinorCivGoldPopup) - NOT STARTED

base / G&K / BNW. Fires when a gifted Great Person event gives the player a choice to accept a one-time gold gift from a minor civ instead. Accept / Decline.

## 7.23 Return Civilian Popup (ReturnCivilianPopup) - NOT STARTED

base / G&K / BNW. Fires when the player captures a civilian unit (Worker, Settler) from another civ. Options: return for relations boost, keep for economic gain. Yes/No style.

## 7.24 Barbarian Ransom Popup (BarbarianRansomPopup) - NOT STARTED

base / G&K / BNW. Fires when a barbarian encampment holds a captured civilian (usually a city-state Worker). Rescuing the civilian grants Influence with the CS that lost it. Close-only acknowledgement after the rescue; the actual rescue happens by combat, not in the popup.

## 7.25 Trade Route Diplomatic Implications - NOT STARTED

BNW only. Trade routes between civs surface diplomatically in three places: the trade-route selection dialog (ChooseInternationalTradeRoutePopup, Phase 6 territory), the plunder-warning DeclareWarPlunderTradeRoutePopup (7.8 above), and as a relations modifier shown in the Opinion tooltip on LeaderHeadRoot mood indicator. A civ with an active profitable trade route to the player has a positive opinion modifier; plundering someone trade route puts a permanent negative modifier on them toward you. None of this is spoken; it all lives in tooltip text.

## 7.26 Espionage-Diplomacy Intersection - NOT STARTED

G&K / BNW. Three surfaces where espionage triggers a diplomacy popup:

- Spy caught performing an action: a LeaderMessageHandler dispatch with the caught-spy DiploUIState, showing the AI angry reaction and giving the player a choice to apologize, deny, or refuse to apologize
- Shared intrigue: when a player spy uncovers a plot (another civ is plotting war against a third party), the player can share this intel via a DiscussionDialog option, boosting relations with the warned civ
- Rigging an election in a CS: no diplomacy popup directly, but if detected, the owner of the rival spy gets a notification and the two civs Opinion modifier updates

Full espionage coverage is Phase 10.

## 7.27 Leader Voice-Over - N/A

Each AI leader has recorded voice-over for every major diplomatic event (first meeting, declaration of war, peace, denunciation, demand, friendly greeting, agreement, rejection). The audio plays automatically when the leader head opens, overlapping any screen-reader speech. There is no in-engine toggle to disable leader VO specifically; the overall Voice volume slider in Options affects it along with advisors and combat taunts. For a screen-reader user, leader VO is either a useful cue or an unwanted collision with Tolk output. A mod-side ducking or mute of the diplomacy VO channel during Tolk speech is worth considering, but the audio itself is content, not UI, and is out of scope for this audit.
# Phase 8: Economy and Logistics

Civ V's economic surface is scattered across a handful of full-screen overviews reached from the top bar and diplomatic corner, plus several transient popups driven by production events. Every number a sighted player glances at on the top bar has a deeper breakdown screen behind it, and every one of those breakdowns is keyboard-reachable only through mouse-style click targets. All of the screens in this phase are NOT STARTED.

## 8.1 Economic Overview Shell - NOT STARTED

`EconomicOverview.{lua,xml}` (G&K and BNW overrides) is a tabbed shell that embeds two child contexts via `LuaContext`. The shell itself is thin: a `Grid` (1000x658) with title `TXT_KEY_ECONOMIC_OVERVIEW`, a civ icon at the top, a two-tab row (`GeneralInfoButton` with label `TXT_KEY_GENERAL_INFORMATION`, `HappinessButton` with label `TXT_KEY_HAPPINESS_AND_RESOURCES`), each tab showing a `*SelectHighlight` frame when active, and a `CloseButton` labeled `TXT_KEY_CLOSE`. The two child contexts are `EconomicGeneralInfo` (§8.2, always visible) and `HappinessInfo` (§8.3, hidden until tab switch).

Reached from the top panel gold readout, or from the `DiploCorner` economic button in BNW. Tab switching swaps `Hidden` on the two `LuaContext` children. Both children share the same outer frame so the close button is shared.

- Two-tab shell: General Information, Happiness and Resources.
- Civ icon header (`CivIcon`, `CivIconBG`, `CivIconShadow`) reflects active player.
- `CloseButton` (`TXT_KEY_CLOSE`) dismisses.

## 8.2 Economic General Info Tab - NOT STARTED

`EconomicGeneralInfo.{lua,xml}` (291 lines of XML; G&K and BNW overrides). The default tab. Two-column layout: left column is a 210-wide `GoldScroll` aggregating empire-wide gold totals and breakdown; right column is a 718-wide `MainScroll` listing every owned city (`CityInstance` template) sorted by a clickable column header.

Left column (`GoldStack` inside `GoldScroll`), labeled sections and each value a named `Label`:

- `TotalGold` (`TXT_KEY_EO_TOTAL_GOLD` / `TotalGoldValue`) — current treasury.
- `NetGold` (`TXT_KEY_EO_NET_PER_TURN` / `NetGoldValue`) — net income per turn.
- `ScienceLost` (`TXT_KEY_EO_PENALTY` / `ScienceLostValue`, tooltip `TXT_KEY_EO_PENALTY_TT`) — science penalty when in deficit.
- `GrossGold` (`TXT_KEY_EO_GROSS` / `GrossGoldValue`).
- `TotalExpense` (`TXT_KEY_EO_TOTAL_EXPENSE` / `TotalExpenseValue`).
- `TXT_KEY_EO_INCOME` section header, then: `CityToggle` (`TXT_KEY_EO_INCOME_CITIES`, expands `CityStack` with per-city income rows), `DiploIncome` (`TXT_KEY_EO_DIPLOMACY`, tooltip `TXT_KEY_EO_INCOME_DIPLOMACY`), `TradeToggle` (`TXT_KEY_EO_INCOME_TRADE_DETAILS`, expands `TradeStack` with `TradeEntry` instances showing city name plus gold/turn).
- `TXT_KEY_EO_EXPENSES` section header, then: `UnitExpense` (`TXT_KEY_EO_UNITS`), `BuildingsToggle` (`TXT_KEY_EO_BUILDINGS`, tooltip `TXT_KEY_EO_EX_BUILDINGS`, expands `BuildingsStack` with per-city maintenance rows), `TileExpense` (`TXT_KEY_EO_IMPROVEMENTS`), `DiploExpense` (`TXT_KEY_EO_DIPLOMACY`, tooltip `TXT_KEY_EO_EX_DIPLOMACY`).

This `GoldStack` is the authoritative gold breakdown referenced in §8.11; its structure is expand-in-place toggles rather than a separate screen.

Right column (`MainStack` inside `MainScroll`), one `CityInstance` per owned city, sorted by the active column header. Columns and their sort headers:

- `SortCityName` (`TXT_KEY_PRODPANEL_CITY_NAME`, tooltip `TXT_KEY_EO_SORT_NAME`) — city name (with `IconCapital` prefix for capital), shown in `CityName` label; row is wide (240 px).
- `SortPopulation` (tooltip `TXT_KEY_EO_SORT_POPULATION`, icon `[ICON_CITIZEN]`) — `Population` label plus `GrowthBar` / `GrowthBox` mini-meter with `CityGrowth` turns-to-next-pop.
- `SortStrength` (tooltip `TXT_KEY_EO_SORT_STRENGTH`, `[ICON_STRENGTH]`) — `Defense` label plus `HealthBar` under city name.
- `SortFood` (tooltip `TXT_KEY_EO_SORT_FOOD`, `[ICON_FOOD]`) — `Food` label, yellow food-tinted number.
- `SortResearch` (tooltip `TXT_KEY_EO_SORT_RESEARCH`, `[ICON_RESEARCH]`) — `Science` label, tinted.
- `SortGold` (tooltip `TXT_KEY_EO_SORT_GOLD`, `[ICON_GOLD]`) — `Gold` net per-city (includes building maintenance).
- `SortCulture` (tooltip `TXT_KEY_EO_SORT_CULTURE`, `[ICON_CULTURE]`) — `Culture` label.
- `SortProduction` (tooltip `TXT_KEY_EO_SORT_PRODUCTION`, `[ICON_PRODUCTION]`) — `Production` label, plus a `ProdButton` with `ProdImage` of the current build and a `ProductionBar` with `BuildGrowth` turns remaining (clicking the image opens the production chooser).
- G&K and BNW add a Faith column with `[ICON_PEACE]` icon; BNW also adds Tourism in some layouts.

Puppet cities appear in the list with yields intact but the `ProdButton` is disabled (production is AI-controlled); annex cost surfaces only on the AnnexCityPopup (§8.9).

## 8.3 Happiness Info Tab - NOT STARTED

`HappinessInfo.{lua,xml}` (271 lines of XML; G&K and BNW overrides). Three-column layout under a horizontal stack: Happiness column (header `TXT_KEY_GAME_CONCEPT_SECTION_10`), Unhappiness column (header `TXT_KEY_UNHAPPINESS`), Resources column (header `TXT_KEY_SV_OVERLAY_RESOURCES`). Each column is a 260x395 scroll pane with its own named stack.

**Happiness column (`HappinessStack`)**:
- `TotalHappiness` (`TXT_KEY_TOTAL` / `TotalHappinessValue`) — header total.
- `LuxuryHappinessToggle` (`TXT_KEY_EO_LUXURY_HAPPINESS` / `LuxuryHappinessValue`) — expands `LuxuryHappinessStack` with per-luxury contribution rows.
- `LuxuryVariety` (`TXT_KEY_LUXURY_VARIETY` / `LuxuryVarietyValue`) — plus-one-per-distinct-luxury bonus.
- `LuxuryBonus` (`TXT_KEY_LUXURY_BONUS` / `LuxuryBonusValue`), `LuxuryMisc` (`TXT_KEY_LUXURY_MISC` / `LuxuryMiscValue`).
- `CityBuildingToggle` (`TXT_KEY_EO_CITY_BUILDINGS` / `CityBuildingValue`) — expands `CityBuildingStack` with per-building rows (Temple, Circus, Colosseum, Theatre, Stadium, policy-boosted variants).
- `TradeRouteToggle` (`TXT_KEY_EO_TRADE_ROUTES` / `TradeRouteValue`) — BNW trade-route happiness from international routes.
- `GarrisonToggle` (`TXT_KEY_EO_GARRISON` / `GarrisonValue`) — happiness from garrisoned cities under certain policies.
- `PoliciesHappiness` (`TXT_KEY_TOPIC_SOCIALPOLICY` / `PoliciesHappinessValue`).
- `NaturalWonders` (`TXT_KEY_ADVISOR_DISCOVERED_NATURAL_WONDER_DISPLAY` / `NaturalWondersValue`).
- `FreeCityHappiness` (`TXT_KEY_FREE_HAPP_PER_CITY` / `FreeCityHappinessValue`).
- `HandicapHappiness` (`TXT_KEY_AD_SETUP_HANDICAP` / `HandicapHappinessValue`) — difficulty-level baseline.

**Unhappiness column (`UnhappinessStack`)**:
- `TotalUnhappiness` (`TXT_KEY_TOTAL` / `TotalUnhappinessValue`).
- `CityCountUnhappiness`, `OCityCountUnhappiness` (occupied cities), `PopulationUnhappiness`, `OPopulationUnhappiness` (occupied-city population) — each with a dynamic title `*Title` composed at runtime (per-city count, per-pop count).
- `CityUnhappinessToggle` (`TXT_KEY_EO_CITY_UNHAPPINESS` / `CityUnhappinessValue`) — expands `CityUnhappinessStack` with per-city unhappiness detail.

**Resources column (`ResourcesStack`)**:
- `ResourcesAvailableToggle` (dynamic title, `ResourcesAvailableStack` of `ResourceEntry`) — luxury resources you could trade.
- `ResourcesImportedToggle` — resources incoming from active trade deals.
- `ResourcesExportedToggle` — resources outgoing via trade deals.
- `ResourcesLocalToggle` — resources in your territory.

Each `ResourceEntry` is a 150x24 row with `ResourceName` and `ResourceValue` labels. This is the canonical "what can I trade away" surface.

The only happiness/unhappiness signals not present on this screen are golden age threshold (implicit — top-panel Golden Age readout handles it) and we-love-the-king-day demand (per-city on CityView, §5.14). Everything else that moves the happiness needle lives in one of the eleven toggles above.

## 8.4 Military Overview - NOT STARTED

Duplicate of §11.13 from a different entry point — `MilitaryOverview.{lua,xml}` (272 lines of XML; G&K and BNW overrides). Reached from the InfoCorner military icon (and also referenced as the "military overview" per top-panel Unit Supply click-through). Placed in Phase 8 because it is a global non-combat roster panel, but the full widget inventory is in §11.13 — this section is the economic-context reference.

Key points (full detail in §11.13):
- Title `TXT_KEY_MILITARY_OVERVIEW`.
- Two sortable tables: `MilitaryStack` (combat units) and `CivilianStack` (workers, settlers, great people, missionaries, diplomats in BNW). `CivilianSeperator` divides the two.
- Column sort headers: `SortName` (`TXT_KEY_NAME`, tooltip `TXT_KEY_MO_SORT_NAME`), `SortStatus` (`TXT_KEY_STATUS`, `TXT_KEY_MO_SORT_STATUS`), `SortMovement` (`TXT_KEY_MO_SORT_MOVEMENT`), `SortMoves` (`TXT_KEY_MO_SORT_MAX_MOVES`, icon `[ICON_MOVES]`), `SortStrength` (`TXT_KEY_MO_SORT_STRENGTH`, `[ICON_STRENGTH]`), `SortRanged` (`TXT_KEY_MO_SORT_RANGED`, `[ICON_RANGE_STRENGTH]`).
- `SupplyStack` header: `HandicapSupply`, `CitiesSupply`, `PopulationSupply`, `SupplyCap`, `SupplyUse`, `SupplyRemaining` (or `SupplyDeficit` plus `SupplyDeficitPenalty` when over cap). Each has a `*Value` label and `*Title` label plus tooltips `TXT_KEY_HANDICAP_SUPPLY_TT`, `TXT_KEY_CITIES_SUPPLY_TT`, `TXT_KEY_POPULATION_SUPPLY_TT`, and so on.
- G&K adds `GPMeter` / `GPBox` with `TXT_KEY_MO_GENERAL_TT` for Great General progress; BNW adds `GAMeter` / `GABox` with `TXT_KEY_MO_ADMIRAL_TT` for Great Admiral.
- Row click jumps the camera to the unit and selects it.
- `CloseButton` (`TXT_KEY_CLOSE`).

The supply breakdown is the economic-decision part of the screen (are you bleeding production from excess units?); the per-unit table is the operational part. Speech coverage should expose both.
- Sort by any column header
- Great General or Great Admiral influence icons appear inline on applicable units

## 8.5 Demographics Screen - NOT STARTED

Screen stem `Demographics`, G&K and BNW XML-only override. Lists the player's rank among all known civilizations for each of several categories: Population, GNP, Mfg. Goods, Crop Yield, Land Area, Approval Rating, Literacy, Soldiers. For each category the player sees their value, the world average, the best civ (by value, name hidden until met), and the worst civ. Only a `BackButton`.

Placement is economic-adjacent but mostly informational; it is included here because it is the primary measure a player uses to judge relative economic health against rivals.

Tags: base, G&K, BNW.

- Per-category row: own value, average, best, worst, rank
- No drill-down; display-only

## 8.6 Trade Route Overview (BNW) - NOT STARTED

Screen stem `TradeRouteOverview`, BNW only. Reached from the top-bar `InternationalTradeRoutes` button. Tabs: `TabButtonYourTR` (your active trade routes), `TabButtonAvailableTR` (available routes from your idle caravans and cargo ships), `TabButtonTRWithYou` (routes foreign civs have with you). A Domain filter narrows to land or sea. Sort headers: `FromOwner`, `FromCity`, `ToOwner`, `ToCity`, `FromGPT`, `ToGPT`, `FromScience`, `ToScience`.

Per route the screen shows origin civ and city, destination civ and city, gold per turn to each side, science per turn to each side (when tech differential applies), religion pressure direction, turns remaining, and whether the route is internal (same civ, yields food or production to destination) or international (yields gold and science). Internal routes show food or production on the to-column instead of gold. Plundering risk and war status are reflected in the "with you" tab so the player can assess vulnerability.

Tags: BNW.

- Three tabs: your routes, available, with you
- Land or sea domain filter
- Per-route yields to both sides: gold, science, food (internal), production (internal), religion spread
- Turn counter shows expiry; a route must be re-initiated when it expires, there is no auto-renew
- Sort by origin, destination, or any yield column

## 8.7 Trade Route Chooser Popup (BNW) - NOT STARTED

Screen stem `ChooseInternationalTradeRoutePopup`, BNW only. Driven by `BUTTONPOPUP_CHOOSE_INTERNATIONAL_TRADE_ROUTE`; appears when a caravan or cargo ship finishes construction or when the player manually re-tasks one. Buttons: `GoToCity` (center camera on origin), `TradeOverviewButton` (jump to 8.6), `SortByPullDown`, section headers `YourCitiesHeader`, `MajorCivsHeader`, `CityStatesHeader`, `ConfirmYes`, `ConfirmNo`.

The list shows every reachable destination grouped by type: own cities (internal routes), other civs' cities (international), city-states (international). Each entry shows the destination name, what the route will pay both sides (gold, science, food, production), turn length, and religion spread direction. Distance and intervening-territory hazards are baked into the row but not broken out.

The chooser also appears when a caravan or cargo ship's current route expires and the unit becomes idle again. Missing this popup means the unit sits idle, producing nothing, until the player finds it.

Tags: BNW.

- Destination list grouped by own cities, major civs, city-states
- Per-entry: yields to both sides, turn length, religion pressure direction, distance
- Sort by yield, distance, or destination name
- Confirm Yes or No; closing without confirming leaves unit idle

## 8.8 Rebase Trade Unit Popup (BNW) - NOT STARTED

Screen stem `ChooseTradeUnitNewHome`, BNW only. Allows moving a caravan or cargo ship to a different home city before dispatching. `GoToCity`, `TradeOverviewButton`, `ConfirmYes`, `ConfirmNo`.

Tags: BNW.

## 8.9 Annex and Puppet City Popups - NOT STARTED

`PopupsGeneric/AnnexCityPopup.lua` (Lua-only; reuses the generic popup shell). Registered on `ButtonPopupTypes.BUTTONPOPUP_ANNEX_CITY` via `PopupLayouts`. Fires when the player clicks on a puppeted city deciding to annex. Text body composed from `TXT_KEY_POPUP_ANNEX_PUPPET` with the city's `GetNameKey()` substituted. Three buttons added via `AddButton`:

- `TXT_KEY_POPUP_ANNEX_CITY` — commits via `Network.SendDoTask(cityID, TaskTypes.TASK_ANNEX_PUPPET, ...)`. Annex imposes full unhappiness immediately and a resistance period.
- `TXT_KEY_POPUP_DONT_ANNEX_CITY` — dismisses without action, leaves city as puppet (no callback bound).
- `TXT_KEY_POPUP_VIEW_CITY` (tooltip `TXT_KEY_POPUP_VIEW_CITY_DETAILS`) — calls `UI.SetCityScreenViewingMode(true)` and `UI.DoSelectCityAtPlot` to inspect first.

`Controls.CloseButton` is shown (the shared generic popup close). Input handler: Esc and Enter both dismiss (`HideWindow`). `Events.GameplaySetActivePlayer.Add(HideWindow)` ensures hand-off in hotseat hides the popup.

The sibling `PuppetCityPopup.lua` registers on `BUTTONPOPUP_PUPPET_CITY` and mirrors the structure — it appears after city capture giving the initial puppet-vs-annex decision (parallel to §11.6 capture popup's path when Puppet is selected first). Raze option is not in these popups; razing is chosen at capture time (§5.15 / §11.6) and then managed via CityView's UnRaze button (§5.16).

Puppet constraints surface indirectly in the economic listings (§8.2): puppets appear in the city row table with their yields intact, but `ProdButton` is disabled and `CityCommerceStrategy` is AI-controlled. Annexation gold cost is not shown on this popup either — Civ V does not impose a gold cost to annex (unhappiness is the cost); cost-to-annex language applies only to certain mods. The surface for reading current annex/puppet status is the per-city CityView header (§5.2).

- Annex: imposes full unhappiness, triggers resistance period.
- Puppet: retains reduced unhappiness contribution, no player production control.
- Raze: chosen only at capture; CityView UnRaze reverts to puppet state.
- Popup is modal but non-blocking across turns (it will re-present each time the player clicks the puppet).

## 8.10 Resource Tracking - NOT STARTED

Two surfaces: the top panel `ResourceString` readout (§3.1 reference) is the live summary; `ResourceList.{lua,xml}` (110 lines of XML; G&K and BNW have additional text keys but the layout is base-owned) is the authoritative drill-down.

`ResourceList` structure: a 390x400 grid at the top-left sidebar position, containing:
- Two sort headers: `SortName` (label `TXT_KEY_NAME`, tooltip `TXT_KEY_SORT_NAME`) and `SortTradeInfo` (label `TXT_KEY_TRADE_INFO`, tooltip `TXT_KEY_SORT_TRADE`). Click toggles sort direction.
- `MainStack` in a vertical `ScrollPanel`, split into three collapsible sections:
  - `LuxuryHeader` with `LuxuryToggle` (label `TXT_KEY_RESOURCE_LUXURY_DETAILS_COLLAPSE` / `_EXPAND`) and `LuxuryStack` of `ResourceInstance` rows. Each row shows `ResourceQty` (count owned), `ResourceName`, and `TradeInfo` (trade status: "available", "imported from civ X", "exported to civ Y", "in a deal with Z until turn N").
  - `StrategicHeader` with `StrategicToggle` (label `TXT_KEY_RESOURCE_STRATEGIC_DETAILS_COLLAPSE`) and `StrategicStack`. Strategic resources (Horses, Iron, Coal, Oil, Aluminum, Uranium) show signed availability: positive is surplus, negative is deficit (allocation-breaking).
  - `BonusHeader` with `BonusToggle` (label `TXT_KEY_RESOURCE_BONUS_DETAILS_COLLAPSE`) and `BonusStack`. Bonus resources (Wheat, Cattle, Fish, Deer, Sheep, Stone, Bananas, etc.) show count only; they have no trade or supply role.
- `CloseButton` (label `TXT_KEY_CLOSE`) at the bottom.

Per-`ResourceInstance`: three inline labels — `ResourceQty` (22 px wide, right-aligned number), `ResourceName` (103 px, resource label), `TradeInfo` (210 px). The `TradeInfo` string encodes the in-use/available/traded state that the HappinessInfo tab (§8.3) splits across four stacks but here is condensed to one line per resource.

Strategic deficit is the most actionable state — a negative number means units will start disbanding on next turn if a resource is lost (trade expires, source pillaged). The mod must flag deficit on strategic rows unambiguously.

- Strategic: signed count (surplus or deficit), trade status.
- Luxury: count, and tradeable-duplicate status on `TradeInfo`.
- Bonus: count only.
- Sort by Name or Trade Info.

## 8.11 Gold Income Breakdown - NOT STARTED

Two surfaces cover this. The top-panel `GoldPerTurn` hover tooltip (assembled in `TopPanel.lua`) gives a compact aggregate: income from cities summed, trade routes, per-civ resource trade deals, research agreements, minus unit maintenance, building maintenance, route maintenance, and a final net. The tooltip fires only on pointer hover and has no clickable open-in-panel action.

The drill-down form is the `GoldScroll` left column of `EconomicGeneralInfo` (§8.2), which exposes the same data as expandable toggles (`CityToggle`, `TradeToggle`, `BuildingsToggle`) with per-row stacks (`CityStack`, `TradeStack`, `BuildingsStack`) and discrete labeled totals (`TotalGoldValue`, `NetGoldValue`, `ScienceLostValue`, `GrossGoldValue`, `TotalExpenseValue`, `CityIncomeValue`, `DiploIncomeValue`, `TradeIncomeValue`, `UnitExpenseValue`, `BuildingExpenseValue`, `TileExpenseValue`, `DiploExpenseValue`).

For blind play, the EconomicGeneralInfo surface is preferred because every line has a stable ID and can be spoken on demand. The top-panel tooltip is the fast-access summary when the player does not want to open a full screen; the mod should replicate both paths — a one-line net-income readout on top-panel focus plus a full breakdown on drill-in hotkey. The ScienceLost line (tooltip `TXT_KEY_EO_PENALTY_TT`) is the critical warning flag: negative treasury triggers a science-rate penalty that is not otherwise surfaced.

- Top-panel tooltip: aggregate one-shot, hover-only.
- `EconomicGeneralInfo` `GoldStack`: labeled per-source rows with expand-in-place detail, accessible by keyboard focus per label.
- Science-lost penalty line flags the deficit state load-bearingly.

---

# Phase 9: Religion

Religion was added in G&K and extended in BNW with the Reformation step. Every screen in this phase is tagged G&K except where marked BNW. Religion is an optional game system but, once a civ crosses the faith thresholds, these popups interrupt the turn flow and must be resolved before the game will proceed. Every screen in this phase is NOT STARTED.

## 9.1 Pantheon Selection Popup (G&K+) - NOT STARTED

Screen stem `ChoosePantheonPopup`, G&K and BNW overrides. Driven by `BUTTONPOPUP_FOUND_PANTHEON`; appears the first time the civ accumulates enough faith (starts at 10, rises as more civs found pantheons). A modal scrolling list of every pantheon belief not yet claimed by another civ. `CloseButton` (defers, does not cancel; the popup returns next turn), `Yes` and `No` confirm.

Each pantheon belief has a short name (for example, Goddess of the Hunt) and a one-line effect (plus one food from camps). Some pantheons are keyed to terrain or resources the civ has; the popup does not filter by relevance, so the player must read all of them and pick. Once selected, the pantheon stays with the civ until it founds a full religion, at which point the pantheon belief carries into the religion as one of its beliefs.

Tags: G&K, BNW.

- Full list of unclaimed pantheon beliefs with name and effect
- Pick one, confirm; no preview of interaction with future religion
- Deferring: popup will re-fire next turn until resolved

## 9.2 Found Religion Popup (G&K+) - NOT STARTED

Screen stem `ChooseReligionPopup`, G&K and BNW overrides. Driven by `BUTTONPOPUP_FOUND_RELIGION`. Appears when the civ produces its first Great Prophet (faith cost scales; not every civ gets one). Controls: `LabelReligionName` (shows the default religion name, click to rename), `NewName` EditBox (rename to any legal string; keyed `TXT_KEY_CHOOSE_RELIGION_NAME_LABEL`), `PantheonBelief` button (display-only, shows the already-chosen pantheon as the first belief), `FounderBelief` and `FollowerBelief` buttons (pick one each from scrollable lists of unclaimed beliefs), `FoundReligion` confirm, `Close`.

A founded religion carries three beliefs: the civ pantheon (carried over), one founder belief (benefits to the civ that founded the religion), and one follower belief (benefits every city that follows the religion regardless of owner). Each belief has a short name and an effect line; belief lists are long, and reading through all of them is the bulk of the interaction time. The confirm button is disabled until one of each type is chosen.

The popup title switches between `TXT_KEY_CHOOSE_RELIGION_TITLE` ("Found a Religion") and the enhance variant (9.3) based on state; same XML is reused.

Tags: G&K, BNW.

- Default religion name shown, custom name optional
- Pantheon belief already filled, display-only
- Choose one founder belief (civ-wide) and one follower belief (per-city where religion is majority)
- Each belief: short name plus effect text
- Confirm disabled until both picks made

## 9.3 Enhance Religion Popup (G&K+) - NOT STARTED

Same screen stem (`ChooseReligionPopup`) reused with different titles and active buttons. Driven by `BUTTONPOPUP_ENHANCE_RELIGION`. Triggered by producing a second Great Prophet after founding. Adds one more follower belief (`FollowerBelief2`) and one enhancer belief (`EnhancerBelief`, which typically affects religion spread, missionary strength, or faith generation). Founder and existing follower belief rows are display-only reminders of what the religion already has.

Tags: G&K, BNW.

- Existing beliefs shown read-only
- Pick one additional follower belief and one enhancer belief
- Confirm locks in; religion is now fully enhanced

## 9.4 Reformation Popup (BNW) - NOT STARTED

Same screen stem (`ChooseReligionPopup`) with the Reformation path active. Driven by `BUTTONPOPUP_REFORMATION`. BNW only. Requires the player to have adopted the Piety social policy tree Reformation tenet or equivalent unlocking condition, then to produce a third Great Prophet. Adds the `BonusBelief` slot: a pick from the reformation belief pool, which are significantly stronger than standard beliefs (for example, plus four happiness from all temples).

Tags: BNW.

- Pick one reformation belief from a smaller pool
- Adds permanently to the religion; religion is now reformed
- One per religion per game

## 9.5 Religion Overview Panel (G&K+) - NOT STARTED

Screen stem `ReligionOverview`, G&K and BNW overrides. Reached from the faith string on the top bar when a religion exists, or directly via the religion overview shortcut. Three tabs: `TabButtonYourReligion`, `TabButtonWorldReligions`, `TabButtonBeliefs`. `AutomaticPurchasePD` is a pulldown controlling whether surplus faith auto-purchases great prophets or great people (keys `TXT_KEY_RO_AUTO_FAITH_PURCHASE`, `TXT_KEY_RO_AUTO_FAITH_PURCHASE_PROPHET`, `TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON`). Sort headers on the world-religions and beliefs tabs.

Your Religion tab: religion name, holy city, all beliefs currently attached, list of every city that follows the religion and from which civ, pressure applied by each foreign religion on your cities, faith per turn total.

World Religions tab: one row per founded religion across all known civs. Per-row: religion name and icon, founder civ, holy city, number of cities following as majority religion, total followers worldwide, enhanced and reformed status. Sort by any column.

Beliefs tab: list of every belief chosen by any founded religion, grouped by type (pantheon, founder, follower, enhancer, reformation). Useful to see which beliefs are still available before founding or enhancing.

Tags: G&K (tabs 1 and 2, basic beliefs); BNW adds reformation belief listing and the auto-purchase pulldown.

- Your Religion: name, holy city, beliefs, follower cities list with civ ownership, foreign pressure, faith per turn
- World Religions: all founded religions with founder, holy city, spread stats
- Beliefs: catalog of taken versus available beliefs by type
- Auto-purchase pulldown controls passive faith spending

## 9.6 Religion Display in City View (G&K+) - NOT STARTED

Religion surfaces in two places inside the G&K and BNW `CityView.{lua,xml}` overrides. First, buildings in the Buildings List that are faith-unique per-religion (Mosque, Pagoda, Cathedral, Synagogue, Stupa) are labeled using `TXT_KEY_RELIGIOUS_BUILDING` (a format key substituting the building's description with the player's `GetStateReligionKey()` — so a Mosque reads "Mosque of the Religion Name" rather than a bare name). `CityView.lua:323` (G&K) and `:329` (BNW) are the substitution sites. This is also where the mod must reach to avoid announcing the generic building name and losing the player's religion context.

Second, the city religion panel proper (a mid-page section added to the G&K CityView layout) shows majority religion, per-religion follower counts, and net pressure direction. Follower counts come from the live `city:GetNumFollowers(eReligion)` walk over every founded religion; pressure comes from `city:GetPressurePerTurn(eReligion)` minus outgoing decay. Tooltip composition uses the religion tooltip line family (notably `TXT_KEY_RELIGION_TOOLTIP_LINE` and BNW's trade-route-extended variant that adds pressure-from-trade-routes lines), assembled at render time rather than stored as a fixed key. The panel's majority-religion state is load-bearing: if the city's majority religion matches the player's founded religion, follower beliefs apply to this city; if it is foreign, foreign follower beliefs apply instead and the city becomes a pressure leak.

- Religious buildings relabel via `TXT_KEY_RELIGIOUS_BUILDING` (CityView.lua:323 G&K, :329 BNW). The mod must honor the substitution or it will speak "Mosque" instead of "Mosque of Islam".
- Majority religion: one per city, may be none. Queried via `city:GetReligiousMajority()`.
- Per-religion follower count: `city:GetNumFollowers(eReligion)` for each founded religion.
- Pressure direction: sign of `city:GetPressurePerTurn(eReligion)` with source breakdown in BNW (adjacent cities, trade routes, Missionary/Great Prophet actions).
- Inquisitor stationed in a city adds a passive block-spread indicator that should announce alongside follower counts.

A good open-city summary for a blind player includes "majority religion of City: Name (own|foreign), N followers, strongest incoming pressure from: X religion".

## 9.7 Missionary Unit Actions (G&K+) - NOT STARTED

Missionary units plug into the shared `UnitPanel` action grid (`WorldView/UnitPanel.xml`, G&K Lua override). Action buttons are `UnitAction` template instances placed into `Controls.PrimaryStack`. The mission is `MISSION_SPREAD_RELIGION`, which `UnitPanel.lua:1100-1116` (G&K) handles with a special tooltip composer:

- Header: `TXT_KEY_MISSION_SPREAD_RELIGION_HELP` — base help text.
- Result line: `TXT_KEY_MISSION_SPREAD_RELIGION_RESULT` substituted with `religionName` and `iNumFollowers` from `unit:GetNumFollowersAfterSpread()`. This gives the predicted after-spread follower count for the missionary's religion.
- Majority-after line: a separate TXT_KEY based on `unit:GetMajorityReligionAfterSpread()`. If the post-spread majority is still Pantheon-or-lower (foreign majority persists), `TXT_KEY_MISSION_MAJORITY_RELIGION_NONE`; otherwise `TXT_KEY_MISSION_MAJORITY_RELIGION` with the winning religion's localized name.

This post-action preview is the critical decision signal — it tells the player whether spreading will tip the city's majority. The mod must expose it on action-button focus, not only on click.

- Mission ID `MISSION_SPREAD_RELIGION`; unit panel action button with per-click charge consumption.
- Missionary has two charges, tracked via `unit:GetSpreadsLeft()`.
- Religious strength is a unit stat (`unit:GetReligiousStrength`) shown in the unit info block; affects conversion amount.
- Tooltip preview of followers-after and majority-after is computed per target city on hover.
- Passive charge drain in hostile territory without open borders (one charge per turn of unauthorized presence), surfaced as a status-line decrement.
- Missionaries are faith-purchased only; see §5.12 for the purchase panel. Missionary unit is destroyed after last charge is spent.

## 9.8 Inquisitor Unit Actions (G&K+) - NOT STARTED

Inquisitor units also use the shared `UnitPanel`. Two distinct behaviors:

- **Remove Heresy action** (mission-type gated). `UnitPanel.lua:672` branches on `GameInfo.Units[unit:GetUnitType()].RemoveHeresy == true` — the unit-type flag marks the Inquisitor class. The action is available only inside one of the player's own cities and only when a foreign religion has followers there. Clicking converts all non-player-religion followers to the player's religion, consuming the Inquisitor (single-use). Tooltip composes from `TXT_KEY_MISSION_INQUISITOR_*` family. No preview of exact follower delta; conversion is total.
- **Passive garrison**. When stationed in a city (not consumed, just present), the Inquisitor blocks foreign Missionaries from spreading religion into that city. Persists until moved or killed. The block state is implicit — no status flag on the unit panel beyond the general in-city indicator — so the mod must expose it via a secondary readout ("Inquisitor garrisoned, blocking spread to City X") when scanning own-unit list or the religion panel.

- Unit trait flag `RemoveHeresy` on the unit-type row.
- Remove Heresy: single-click action, consumes the Inquisitor, purges foreign followers in the current own-city.
- Passive block-spread: unobtrusive in vanilla UI; worth surfacing explicitly for blind play.
- Inquisitors are faith-purchased; same purchase panel as §5.12.
- Enhancer belief Religious Texts and Inquisitor-specific faith cost reductions apply if the player's religion has the right beliefs.

## 9.9 Great Prophet Unit Actions (G&K+) - NOT STARTED

Great Prophets appear in the UnitPanel action grid with up to four state-conditioned actions plus the shared Great Person actions.

- **Found Religion** — available only if the civ has claimed a pantheon (§9.1) but no full religion. Triggers `BUTTONPOPUP_FOUND_RELIGION` → `ChooseReligionPopup.xml` (§9.2). Consumes the prophet.
- **Enhance Religion** — available only if the civ has founded a religion (§9.2) and has not yet enhanced it. Triggers `BUTTONPOPUP_ENHANCE_RELIGION` → same `ChooseReligionPopup.xml` with enhance-mode active (§9.3). Consumes the prophet.
- **Reformation (BNW)** — available only if the civ has enhanced its religion AND has unlocked a Reformation slot (via the Piety policy tree's Reformation tenet, the Sacred Sites Reformation belief, or the Cristo Redentor wonder). Triggers `BUTTONPOPUP_REFORMATION` → same XML with reformation-mode active (§9.4). Consumes the prophet.
- **Build Holy Site** — places a Holy Site improvement on the prophet's tile yielding faith each turn. Consumes the prophet. Improvement is destroyed if the tile is pillaged.
- **Spread Religion** — same `MISSION_SPREAD_RELIGION` as missionaries (§9.7 composer applies), but Great Prophets have four charges (versus two for missionaries) and a higher religious strength, giving a much larger conversion amount per spread. The followers-after and majority-after preview composes identically.

The first three are mutually exclusive: the available one depends on civ state (has-pantheon-not-religion, has-religion-not-enhanced, has-enhanced-not-reformed). Only one of them will render on any given Prophet. The unit panel shows the appropriate action button plus Spread Religion plus Build Holy Site as separate buttons; a freshly spawned Great Prophet immediately after research of Theology or equivalent has Found Religion available, while a late-game Prophet after reformation will only have Spread Religion plus Build Holy Site.

- Four state-driven actions; only one of Found/Enhance/Reformation is ever visible per prophet.
- All three popup triggers reuse `ChooseReligionPopup.xml` with different active modes (§9.2/9.3/9.4).
- Build Holy Site is an alternative to any of the popups — consumes the prophet for a tile improvement.
- Spread Religion composer identical to §9.7; higher strength, four charges.
- Great Prophets can be faith-purchased or earned through great-person points from religious buildings.

## 9.10 Faith Purchase Panel - NOT STARTED

Covered in Phase 5 (production and construction). The faith purchase tab in `CityView` lets a player spend accumulated faith on religious units (missionaries, inquisitors, great prophets) and, with certain beliefs, on buildings, great people, and military units. See Phase 5 for the panel structure; religion-specific context here is that the list of purchasable items depends on which follower beliefs are active in the city majority religion (not the player founded religion) and on whether industrial-era reformation beliefs unlock great people purchases.

Tags: G&K (religious units); BNW (reformation-unlocked purchases, great people via belief).

## 9.11 Religion in Diplomacy Display (G&K+) - NOT STARTED

Religion shows up in the diplomacy surface in two forms. On the `DiploList` civ entries, the civ founded religion is labeled with its religion icon. In the leader discussion (`DiscussionDialog`), when the other civ has a different founded religion, dialog options include asking them to stop spreading their religion to your cities (a diplomatic modifier, not a hard stop). The Religion Overview (9.5) World Religions tab is the authoritative cross-civ view; the diplomacy surface only flags the religion, it does not quantify pressure.

Tags: G&K, BNW.

- Religion icon per civ in the known-civs list
- Discussion option to request no more religious spread
- No numeric pressure or conversion data in the diplomacy panel itself
# Phase 10: Espionage (G&K, BNW)

The entire espionage system is added by the Gods and Kings expansion and extended in Brave New World. A base-game player never sees any of this. Spies unlock at the Renaissance era (first spy at Printing Press tech in G&K; earlier if a rival researches it first), with additional spies awarded at later tech thresholds. The primary entry point is the Espionage button on the DiploCorner (G&K override of `DiploCorner.lua`); notifications also open the overview screen directly. Screen file: `DLC/Expansion/UI/InGame/Popups/EspionageOverview.{lua,xml}`, fully re-overridden by BNW at `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.{lua,xml}`.

## 10.1 Espionage Overview Screen - NOT STARTED

The main spy management screen. Opens as a modal popup over the HUD. Has two tabs: Overview (default) and Intrigue. The Overview tab is a table of all your spies with one row per spy. The Intrigue tab is a chronological log of intelligence your spies have gathered about rival civilizations.

Overview tab per-spy row (BNW - G&K is the same minus the diplomat column):

- Spy rank icon and name. Ranks are Recruit, Agent, Special Agent, rendered as `TXT_KEY_SPY_RANK_*`. The spy's personal name is a random string drawn from a per-civ name pool. Tooltip `TXT_KEY_EO_SPY_LOCATION_TT` ("{SpyRank} {SpyName} is currently in {CityName}") or `TXT_KEY_EO_SPY_TRAVELLING_TT` for in-transit spies.
- Location cell. Name of the city where the spy is stationed, or "Unassigned" if idle, or the destination city with a travelling indicator if the spy is relocating (spies take several turns to travel between cities).
- Activity cell. Current mission with a progress indicator. Missions include Gathering Intelligence (counts turns until next intrigue roll), Stealing Technology (turns until next steal attempt), Rigging Election (showing current influence level), Counter-Espionage (running in own cities), Establishing Surveillance (initial orientation period before coup becomes available), and Making Introductions (BNW diplomat mode).
- Action buttons per row: View City (jumps the world view to the spy's host city, disabled with `TXT_KEY_EO_CITY_VIEW_DISABLED_NO_CITY_TT` if unassigned), Relocate (opens the city selection popup, tooltip `TXT_KEY_EO_RELOCATE_TOOLTIP`), Stage Coup (only visible for spies in city-states who are not your ally and whose patron is; disabled variants include `TXT_KEY_EO_SPY_COUP_DISABLED_NO_ALLY_TT`, `TXT_KEY_EO_SPY_COUP_DISABLED_WAIT_TT` for surveillance not complete, and `TXT_KEY_EO_SPY_COUP_DISABLED_YOU_ALLY_TT` when you are the current ally), Unassign (pulls the spy back to your capital hideout), and (BNW only) Switch to Diplomat / Switch to Spy toggle available when the spy is stationed in a rival major civ capital.
- Dead spies remain listed with `TXT_KEY_EO_SPY_BUTTON_DISABLED_SPY_DEAD_TT` and all actions disabled; a new spy replaces them after a cooldown.

Column header sort buttons: Name/Rank, Location, Activity. XML defines them as `SortByName`, `SortByLocation`, `SortByActivity`. The `TabButtonOverview` and `TabButtonIntrigue` switch between tabs.

Intrigue tab content. A scrolling list of intelligence entries, each with a turn number, the civilization the intelligence concerns, and the intrigue text. Intelligence levels escalate: a target civ is plotting war, a target civ is plotting war against a specific victim, a specific plot has been uncovered with operational details. Text is assembled from `TXT_KEY_INTRIGUE_*` templates. Older entries scroll off-screen but remain in the log.

Counter-espionage display. Spies assigned to your own cities show a counter-espionage activity with a kill-chance percentage. Tooltip breakdown via `TXT_KEY_EO_SPY_COUNTER_INTEL_SPY_RANK_TT` (contribution from the spy's rank), `TXT_KEY_EO_SPY_COUNTER_INTEL_POLICY_TT` (Police State social policy bonus), and `TXT_KEY_EO_SPY_COUNTER_INTEL_SUM_TT` (total chance to kill enemy spy).

All spy names, rank names, city names, and civ names must come from the live Player / Spy / City objects at speech time. Never cache - spies can die, get promoted, or relocate between turns. Use `pPlayer:GetEspionageSpies()` (see `lua-api/Player.md` for the actual iterator shape) and query each spy's `GetSpyName`, `GetSpyRank`, `GetCityName`, and activity state on demand.

## 10.2 Spy Assignment / Relocation Popup - NOT STARTED

Reached by clicking Relocate on a spy row, or by clicking an unassigned spy. Lists every valid destination city grouped into three categories: your own cities (for counter-espionage), rival major civ cities (for tech stealing and, in BNW, diplomat conversion when the city is the rival's capital), and city-states (for election rigging and coups). Each destination row shows the city name, owner civ (or city-state trait adjective for CS - `TXT_KEY_EO_CITY_CIV_CITY_STATE_TT` and `TXT_KEY_EO_CITY_CIV_TT`), city population (`TXT_KEY_EO_CITY_POPULATION_TT`), and a potential yield or mission indicator. For rival civs, a tech-steal potential modifier list is shown in the tooltip breaking down `TXT_KEY_EO_POTENTIAL_BUILDING_MOD_TITLE`, `TXT_KEY_EO_POTENTIAL_POLICY_MOD_TITLE`, and `TXT_KEY_EO_POTENTIAL_WONDER_MOD_TITLE` entries. `CitySelectButton` per-row; Cancel button to abort.

## 10.3 Intrigue Discovered Notification - NOT STARTED

No dedicated popup XML; the entire intrigue flow runs through `NotificationPanel.lua` (G&K override under `DLC/Expansion/UI/InGame/WorldView/`). The `g_NameTable` registers an extensive intrigue family — eighteen distinct notification types, each routed to the icon name "Spy":

- `NOTIFICATION_INTRIGUE_DECEPTION` — a general discovery that an AI is being deceitful about their plans.
- `NOTIFICATION_INTRIGUE_BUILDING_SNEAK_ATTACK_ARMY` / `_AMPHIBIOUS` — AI is massing forces for a land or amphibious surprise attack; no target named yet.
- `NOTIFICATION_INTRIGUE_SNEAK_ATTACK_ARMY_AGAINST_KNOWN_CITY_UNKNOWN` / `_KNOWN`, `_AGAINST_YOU_CITY_UNKNOWN` / `_KNOWN`, `_AGAINST_UNKNOWN` — army sneak attacks with varying precision (target civ / city known or not; "you" variants are highest severity).
- `NOTIFICATION_INTRIGUE_SNEAK_ATTACK_AMPHIB_AGAINST_KNOWN_CITY_UNKNOWN` / `_KNOWN`, `_AGAINST_YOU_CITY_UNKNOWN` / `_KNOWN`, `_AGAINST_UNKNOWN` — amphibious variants of the same matrix.
- `NOTIFICATION_INTRIGUE_CONSTRUCTING_WONDER` — spy has identified a rival racing a specific wonder.

Each notification's body text is assembled from `TXT_KEY_NOTIFICATION_INTRIGUE_*` templates substituting source spy, source city, target civ, target city (if known), and forecast turn. Clicking a notification opens `EspionageOverview` on the `TabButtonIntrigue` tab; right-click dismisses without opening. The notification persists in `NotificationLogPopup` after dismissal.

- 18 distinct intrigue notification types covering deception, army/amphibious sneak attacks with four precision levels each, and wonder-construction intelligence.
- All route through `NotificationPanel` (no dedicated popup), icon "Spy".
- Clicking opens `EspionageOverview` on the Intrigue tab.
- Severity is encoded in the type suffix: `_AGAINST_YOU_*` types are the ones the player must react to most urgently.

## 10.4 Tech Stolen Popup / Chooser - NOT STARTED

Not a dedicated XML. The tech-steal chooser reuses the base-game `TechPopup.xml` with a different mode: the engine dispatches `SerialEventGameMessagePopup` with `popupInfo.Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSE_TECH_TO_STEAL`, and `TechPopup.lua:64` (G&K override) branches on this to filter the tech list to techs known by the victim but not by the active player. Same `TechButtonInstance` template, same `ButtonStack` layout, same tooltip composer as the normal Choose Research popup (§6.1) — the difference is only in which techs appear.

The precursor notification (fires when steal progress completes in the rival city) is `NOTIFICATION_SPY_STOLE_TECH` with icon name "StealTech", text `TXT_KEY_NOTIFICATION_SPY_STEAL_BLOCKING_TT` ("Your spy has gathered enough intelligence to steal a technology from an opponent. Choose which technology to steal."). Clicking the notification fires the popup. This is a blocking popup — End Turn is gated until the player selects a tech.

- Reuses `TechPopup.xml` with `BUTTONPOPUP_CHOOSE_TECH_TO_STEAL` mode (see `TechPopup.lua:64, :90` G&K).
- Filtered tech list: techs the rival knows that the player does not.
- Each row same shape as Choose Research: name, icon, base cost, turns at current output, unlocks list.
- Selection completes instantly (no ConfirmButton) — clicking a row commits the steal. Applies a full tech or large science toward it depending on spy rank.
- `TechPanel.lua:201` (G&K) also observes the mode to sync the tech panel display state while the chooser is open.
- Blocking: End Turn will not complete until resolved.
- `NOTIFICATION_SPY_CANT_STEAL_TECH` (icon "SpyCannotSteal") fires when no valid targets exist (either victim has nothing new, or all rivals are out of range).

## 10.5 Rigging Elections Result Popup - NOT STARTED

Also notification-only. `NotificationPanel.lua` registers three election types:

- `NOTIFICATION_SPY_RIG_ELECTION_ALERT` (icon "Spy") — fires one or more turns before the election to warn the player that an election is coming. Body text names the city-state and turns-until-election. Non-blocking.
- `NOTIFICATION_SPY_RIG_ELECTION_SUCCESS` — your spy won the election for that city-state. Body names the CS, the influence gained, and any new ally status if you crossed the ally threshold.
- `NOTIFICATION_SPY_RIG_ELECTION_FAILURE` — your spy lost (either another civ's spy won or no-winner split). Body names the CS and the amount of influence the winner gained.

Elections run every fifteen turns on standard game speed, simultaneously across all CS with at least one spy present. No modal popup accompanies the result — the outcomes surface through the notification stack. All text comes from `TXT_KEY_NOTIFICATION_SPY_RIG_ELECTION_*` family (success, failure, alert variants).

For the mod, the alert is the most actionable — it gives the player a few turns to reposition spies or make diplomatic moves. Announcing alerts with CS name, influence status, and competing-spy count is a high-leverage speech hook.

- Three distinct notification types (alert, success, failure), all icon "Spy".
- No blocking popup; outcomes are passive notifications.
- Alert fires pre-election; success/failure after the fifteen-turn tick resolves.
- Influence deltas are composed per-player at resolution time from spy rank, influence accrued since last election, and counter-spy presence.

## 10.6 Coup Attempt Popup - NOT STARTED

Triggered by the `Stage Coup` button on a spy row in EspionageOverview (§10.1), available only when the spy is in a city-state and the current ally is someone else. The confirmation step is a small generic popup (no dedicated XML; reuses `GenericPopup.xml`) showing the coup odds (percent chance of success) and the two consequences; commit fires `Network.SendStageCoup(spy, city)`.

Result notifications via `NotificationPanel.lua`, four variants:

- `NOTIFICATION_SPY_YOU_STAGE_COUP_SUCCESS` (icon "Spy") — your coup succeeded. Removes the prior ally, installs you as ally with a large flat influence gain. Body includes CS name, displaced civ name, and new influence.
- `NOTIFICATION_SPY_YOU_STAGE_COUP_FAILURE` (icon "SpyWasKilled") — your coup failed. Spy is killed and the prior ally civ gets a diplomatic modifier against you. Body includes CS name and displaced-ally context.
- `NOTIFICATION_SPY_STAGE_COUP_SUCCESS` — another civ's coup succeeded in a CS you knew about (possibly one where you were the ally).
- `NOTIFICATION_SPY_STAGE_COUP_FAILURE` — another civ's coup failed in a CS you had intel on.

Coup odds depend on spy rank, the ally's current influence surplus over the second-place civ, and whether the coup-staging civ has recently rigged elections there (which builds up staging progress). Audio cues `CoupSuccess.wav` and `CoupFail.wav` fire from `DLC/Expansion{,2}/Sounds/Interface/`; blind play must surface the result in speech regardless.

- Pre-commit confirm via generic popup with odds percent and consequence summary.
- Four result notification types (you-success, you-failure, other-success, other-failure).
- `NOTIFICATION_SPY_YOU_STAGE_COUP_FAILURE` reuses the "SpyWasKilled" icon to signal spy loss.
- Coup removes only the current ally (not all friends); you must pay influence to hold the alliance.

## 10.7 Spy Killed and Spy Promoted Notifications - NOT STARTED

Three related notification types, all in `NotificationPanel.lua` G&K override:

- `NOTIFICATION_SPY_WAS_KILLED` (icon "SpyWasKilled") — your spy died. Body names the dead spy (via `spy:GetSpyName()`), the host city, the killer civ if known (high-rank counterspy kills reveal identity; low-rank stay anonymous), and the mission the spy was on (stealing, rigging, or counter-spying).
- `NOTIFICATION_SPY_REPLACEMENT` (icon "Spy") — a replacement spy arrives in your capital hideout after a cooldown (typically a few turns). Body introduces the new spy by name.
- `NOTIFICATION_SPY_PROMOTION` (icon "Spy") — a spy's successful actions have accrued enough XP for a rank promotion. Body names the spy, the old rank, the new rank (`TXT_KEY_SPY_RANK_*`), and typically the mission that triggered the promotion.

Related: `NOTIFICATION_SPY_CREATED_ACTIVE_PLAYER` (icon "NewSpy") fires when a new spy is granted (tech threshold crossed, Constabulary built), and `NOTIFICATION_SPY_EVICTED` (icon "Spy") fires when a spy is expelled from a city by diplomatic action (for example another civ closes borders with you while your spy is there).

All are non-blocking notifications; the player can safely ignore them but the spy will not resume work until a mission is set. Clicking a promotion notification opens EspionageOverview on the Overview tab so the player can see the new rank in context.

- Five total spy-lifecycle notifications: killed, replacement, promotion, created, evicted.
- Each names the specific spy (spies have persistent names); the mod must track names for continuity across turns.
- "SpyWasKilled" versus "Spy" icons differentiate lethal versus non-lethal events at the icon level only; body text carries the gameplay implication.

## 10.8 Diplomat Conversion (BNW only) - NOT STARTED

BNW adds a diplomat mode that reuses the spy unit. The `EspionageOverview.lua` BNW override (`DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua`) adds a per-row toggle to convert a spy stationed in a rival major civ's capital into a Diplomat; the action is immediate and does not consume the spy. Underlying API is `spy:IsDiplomat()` / `player:ConvertSpyToDiplomat(iSpyIndex)` (names approximate — see the BNW EspionageOverview.lua for exact signatures).

Diplomat effects:

- Unlocks trade-route information about that civ (routes they run, partners, destinations, expiration turns) — surfaces in the trade route overview (§8.6).
- Provides a continuous influence trickle on World Congress votes (see §7.12) — the diplomat's parent civ can now propose extra voting options and has visibility into the target civ's voting record.
- Lets the player see voting commitments in the `LeagueOverview` — which resolutions the target civ intends to support before the session resolves.
- Gathers general intelligence at a slower rate than a spy (reduced tech-steal buildup), in exchange for the trade/congress visibility.

Conversion consequences:

- Spy loses any in-progress tech steal (the bar resets).
- Activity cell changes through two states: "Making Introductions" (several-turn establishment period) then "Diplomat" once active.
- Converting back to Spy mode is legal via the same toggle; diplomat visibility resets and tech-steal progress starts from zero.

The toggle is a `Switch to Diplomat` / `Switch to Spy` button rendered on the spy's row in EspionageOverview. Tooltips describe the trade-off. No confirmation popup — conversion is instant on click.

- Per-row toggle in BNW EspionageOverview; not visible in G&K.
- Conversion is instant but wipes tech-steal progress.
- Two activity states (Making Introductions then Diplomat) tracked in the Activity cell.
- Unlocks trade-route visibility and World Congress voting intel on the target civ.

## 10.9 Counterspy Results - NOT STARTED

Counterspy outcomes surface through two notification types in `NotificationPanel.lua`:

- `NOTIFICATION_SPY_KILLED_A_SPY` (icon "SpyKilledASpy") — your counterspy killed an enemy spy attempting to infiltrate or steal from one of your cities. Body names your counterspy, the dead enemy spy (if rank permits identification), the target city, and the enemy civ. Your counterspy typically gains XP/rank from the kill.
- Enemy-spy-escaped outcomes generate a lighter variant (attempt detected, no kill) — surfaced through the generic `NOTIFICATION_SPY_EVICTED` family or a lower-severity intrigue notification depending on context.

The continuous counterspy readout is on the EspionageOverview row for the spy assigned to counter-espionage duty in one of your cities: the Activity cell shows "Counter-Espionage" and a kill-chance percent, composed via three tooltip keys:

- `TXT_KEY_EO_SPY_COUNTER_INTEL_SPY_RANK_TT` — contribution from the counterspy's rank (higher rank = higher base kill chance).
- `TXT_KEY_EO_SPY_COUNTER_INTEL_POLICY_TT` — Police State (Autocracy BNW) social policy bonus if active.
- `TXT_KEY_EO_SPY_COUNTER_INTEL_SUM_TT` — aggregate kill chance per enemy-spy encounter.

Tech-steal prevented is a subset of the same flow: if the enemy spy is killed before they complete their steal progress, the kill notification fires and the tech-steal notification does not. If the enemy spy evades, the steal completes and the enemy civ gets the tech.

- Two primary notification types: spy-killed-a-spy (icon "SpyKilledASpy"), spy-was-killed (icon "SpyWasKilled", §10.7) from the opposite side.
- Continuous kill-chance readout on EspionageOverview counterspy rows, composed from three named tooltip keys.
- Policy modifier (Police State / Autocracy policies) surfaces in the tooltip breakdown.
- Counterspy XP accrues from successful kills and from simply being stationed; promotion uses the same `NOTIFICATION_SPY_PROMOTION` flow as offensive spies.

## 10.10 Active Mission Status on Spy Rows - PARTIAL

Covered as part of 10.1's Activity cell. The distinction worth naming for implementation: the Activity cell aggregates mission type and progress ("Stealing Technology, 8 turns remaining"; "Rigging Election, 2 of 4 influence"; "Establishing Surveillance, 3 turns remaining"). These values come from live spy-object queries each turn - there is no Activity that is safe to cache, because coup odds and steal timers change with rival tech and building state.

---

# Phase 12: Civilopedia and Reference Screens

The Civilopedia is the game's built-in reference for every unit, building, wonder, improvement, technology, civic, resource, terrain feature, religion, belief, social policy, promotion, and gameplay concept. It is available from both the FrontEnd (via OtherMenu) and in-game (via the Civilopedia button on TopPanel). Demographics, Info Addict-style graphs, Top Cities, Victory Progress, and Replay are the other reference screens - each is a separate popup reached from the pause menu, the end-game screen, or (for Victory Progress) a dedicated button.

Civilopedia paths: base `UI/Civilopedia/CivilopediaScreen.{lua,xml}`, with full overrides in `DLC/Expansion/UI/Civilopedia/` (G&K) and `DLC/Expansion2/UI/Civilopedia/` (BNW). Each DLC adds its own categories (religion and espionage for G&K; ideology, great works, archaeology, trade for BNW) and data entries.

## 12.1 Civilopedia Screen - NOT STARTED

Full-screen reference. Three-pane layout conceptually, though rendered as a single panel with a category bar at the top, a category/article list on the left, and the article body on the right.

Category bar. Horizontal row of clickable category icons at the top of the screen. Categories in BNW order: Game Concepts, Civilizations and Leaders, Units, Buildings, Wonders, Policies, Religion and Beliefs (G&K+), Ideologies (BNW only), Technologies, Terrain and Environment, Resources, Improvements, Great People and Specialists, Eras, Worlds (map scripts). Each category opens to its Home Page (`TXT_KEY_PEDIA_UNITS_PAGE_LABEL`, `TXT_KEY_PEDIA_BUILDINGS_PAGE_LABEL`, `TXT_KEY_PEDIA_WONDERS_PAGE_LABEL`, `TXT_KEY_PEDIA_RESOURCES_PAGE_LABEL`, `TXT_KEY_PEDIA_TERRAIN_PAGE_LABEL`, `TXT_KEY_PEDIA_TECH_PAGE_LABEL`, `TXT_KEY_PEDIA_CIVILIZATIONS_PAGE_LABEL`, `TXT_KEY_PEDIA_POLICIES_PAGE_LABEL`, `TXT_KEY_PEDIA_BELIEFS_PAGE_LABEL`).

List pane. Shows either the current category's Home Page content (grouped headings and links) or an article list grouped by subcategory. `ListHeadingButton` elements are the group headings; `ListItemButton` elements are individual articles. Each item has a name and when clicked loads the corresponding article. Headings and items are built dynamically from `GameInfo.*` tables at open time.

Article body pane. The main content area. Structure varies by category but common elements include title, flavor quote (if present), an info block with mechanical stats, one or more narrative sections with `_HEADING_N` text keys (for example leader articles always include History, Early Life, Rise to Power, Reign, and Judgment of History sub-sections, plus per-leader Fact quotes as tooltips or sidebars), and cross-reference links. Designer's notes block labeled with `TXT_KEY_PEDIA_DNOTES_LABEL` when present.

Cross-reference links in article bodies. Units link to their prerequisite tech, required resource, obsolete tech, upgrade unit, and unlocked buildings. Buildings link to required tech, required buildings, produced units, unlocked resources. Technologies link to prerequisite techs (`PrereqTechButton`), lead-to techs (`LeadsToTechButton`), obsoleted by (`ObsoleteTechButton`), unlocked units (`UnlockedUnitButton`) and unlocked buildings (`UnlockedBuildingButton`), revealed resources (`RevealedResourceButton`), and upgrades (`UpgradeButton`). Resources link to the terrains they appear on (`TXT_KEY_PEDIA_TERRAINS_LABEL`, `TXT_KEY_PEDIA_RESOURCESFOUND_LABEL`) and improvements that harvest them. Each link is a clickable button that navigates to the referenced article.

Navigation controls. Back button walks the history stack. Close button dismisses the screen. A search box exists in the XML but is not exposed on all layouts - confirm in the live XML; most navigation is done by category then list click. No keyboard search-as-you-type in the base implementation.

The Civilopedia is the single largest source of explanatory text in the game. Every entry's text is already localized via `TXT_KEY_*`. Accessibility priorities for this screen: category navigation, list navigation with current-article indicator, article body reading with heading structure preserved, link traversal with target article preview, and history/back support. Given the article volume, a reader-mode that speaks the current section and lets the user move heading-by-heading is the right shape.

## 12.2 Civilopedia from FrontEnd (OtherMenu) - NOT STARTED

Same screen, launched from `OtherMenu.xml` via the `Civilopedia` button before any game has started. Functionally identical to the in-game version; the screen's lua tolerates both contexts. Back button returns to OtherMenu instead of the HUD.

## 12.3 Demographics Screen - NOT STARTED

Opens from the pause menu's info section or from the EndGameMenu after a game via `DemographicsButton`. Title `TXT_KEY_DEMOGRAPHICS_TITLE`. BackButton only. Content is a tabular-style display - the accessibility layer should read it as a list of rows rather than a grid - showing the player's empire rank for each of ten demographics plus the best, worst, and average values across all known civilizations:

- GNP (`TXT_KEY_DEMOGRAPHICS_GOLD`), measured in Million Gold (`TXT_KEY_DEMOGRAPHICS_GOLD_MEASURE`)
- Manufactured Goods (`TXT_KEY_DEMOGRAPHICS_PRODUCTION`), in Million Tons
- Crop Yield (`TXT_KEY_DEMOGRAPHICS_FOOD`), in Million Bushels
- Population (`TXT_KEY_DEMOGRAPHICS_POPULATION`), in People
- Land (`TXT_KEY_DEMOGRAPHICS_LAND`), in Square KM
- Soldiers / Army (`TXT_KEY_DEMOGRAPHICS_ARMY`)
- Approval (`TXT_KEY_DEMOGRAPHICS_APPROVAL`)
- Literacy (`TXT_KEY_DEMOGRAPHICS_LITERACY`)
- Life Expectancy
- Military Might (separate from soldier count, weighted by unit strength and tech)

Each row shows the demographic name (`TXT_KEY_DEMOGRAPHICS_TYPE`), your Value (`TXT_KEY_DEMOGRAPHICS_VALUE`), your Rank (`TXT_KEY_DEMOGRAPHICS_RANK`), Average across civs (`TXT_KEY_DEMOGRAPHICS_RIVAL_AVERAGE`), Best (`TXT_KEY_DEMOGRAPHICS_RIVAL_BEST`), Worst (`TXT_KEY_DEMOGRAPHICS_RIVAL_WORST`). Rival values are shown as unmet-style placeholders until you have met those civs.

All values are live queries against player-level statistics. Never cache.

## 12.4 Ranking / Info Addict Graphs - NOT STARTED

The base-game screen `UI/InGame/Popups/Ranking.{lua,xml}` shows historical score ranking. Title `TXT_KEY_RANKING_TITLE`. This is a line-graph display, one line per known civilization, with the y-axis being score and the x-axis being turn number. Since the graph is purely visual, accessibility means reading out the data series.

The fuller graph experience is `ReplayViewer.{lua,xml}` reused from end-game, which offers a Graphs tab (`TXT_KEY_REPLAY_VIEWER_GRAPHS_TITLE`, tooltip `TXT_KEY_REPLAY_VIEWER_GRAPHS_TT` "View various graphs of data collected for each player"). The `GraphDataSetPulldown` control selects which metric to plot. Available metric series:

- Score (`TXT_KEY_REPLAY_VIEWER_GRAPHBY_SCORE`)
- Population (`TXT_KEY_REPLAY_DATA_TOTALPOPULATION`)
- Total Culture, Total Gold, Total Land (`TXT_KEY_REPLAY_DATA_TOTALCULTURE`, `_TOTALGOLD`, `_TOTALLAND`)
- Number of Cities, Policies, Workers, Known Techs (`TXT_KEY_REPLAY_DATA_CITYCOUNT`, `_NUMBEROFPOLICIES`, `_NUMBEROFWORKERS`, `_TECHSKNOWN`)
- Military Might (`TXT_KEY_REPLAY_DATA_MILITARYMIGHT`)
- Happiness, Unhappiness, Excess Happiness (`TXT_KEY_REPLAY_DATA_HAPPINESS`, `_UNHAPPINESS`, `_EXCESSHAPPINESS`)
- Food, Production, Gold, Science, Culture per Turn (`TXT_KEY_REPLAY_DATA_FOODPERTURN`, `_PRODUCTIONPERTURN`, `_GOLDPERTURN`, `_SCIENCEPERTURN`, `_CULTUREPERTURN`)
- Golden Age Turns (`TXT_KEY_REPLAY_DATA_GOLDAGETURNS`)
- Improved Tiles, Worked Tiles (`TXT_KEY_REPLAY_DATA_IMPROVEDTILES`, `_WORKEDTILES`)
- GPT breakdown: City Connections, Deals, Building Maintenance, Unit Maintenance, Improvement Maintenance (`TXT_KEY_REPLAY_DATA_GPTCITYCONNECTIONS`, `_GPTDEALS`, `_BUILDINGMAINTENANCE`, `_UNITMAINTENANCE`, `_IMPROVEMENTMAINTENANCE`)

TurnSlider scrubs through history. If no data is available, the screen shows `TXT_KEY_REPLAY_NOGRAPHDATA`. The PlayPauseButton (`TXT_KEY_REPLAY_PLAYPAUSE`) animates the slider. Faith per turn, Tourism per turn, and Great People accumulation are not in the base replay series but appear in the G&K / BNW overrides.

For each metric, the accessibility layer needs a way to pick the metric, pick a civilization, pick a turn (or range), and speak the value. A summary mode ("your score at turn 100 was X, rank Y of Z") is more useful than reading every turn.

## 12.5 Victory Progress Screen - NOT STARTED

`UI/InGame/Popups/VictoryProgress.{lua,xml}` (G&K and BNW overrides). Title `TXT_KEY_VP_TITLE` "VICTORY PROGRESS", tooltip `TXT_KEY_VP_TT`. Tabbed popup with one tab per active victory condition plus a summary tab. Controls: `ScoreDetails`, `SpaceRaceDetails`, `DiploClose`, `ScoreClose`, `SpaceRaceClose`, `Back`. Tabs:

- Score. Shows each known civ's current score and the Score Details breakdown (population, technologies, policies, wonders, future tech count). `TXT_KEY_VP_DIPLO_CIV_RANK` "Civilization Rank" header.
- Time / Score victory at turn limit. Shows `TXT_KEY_VP_TURNS_TT` "Turns Before the Game Ends".
- Domination. Shows original capitals status per civilization with tooltips `TXT_KEY_VP_DIPLO_TT_YOU_CONTROL_YOUR_CAPITAL`, `TXT_KEY_VP_DIPLO_TT_SOMEONE_CONTROLS_THEIR_CAPITAL`, `TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_OTHER_PLAYER_CAPITAL`, and variants for unmet civs and for civs with no capital yet (`TXT_KEY_VP_DIPLO_TT_YOU_NO_CAPITAL`, `TXT_KEY_VP_DIPLO_TT_KNOWN_NO_CAPITAL`, `TXT_KEY_VP_DIPLO_TT_UNKNOWN_NO_CAPITAL`). When all original capitals belong to one player, that player wins. `TXT_KEY_VP_DIPLO_NEW_CAPITALS_REMAINING` is shown when none have been captured yet.
- Science / Space Race. Shows each spaceship part's build status per civ (Apollo Program prerequisite, then the six parts - Booster x3, Cockpit, Stasis Chamber, Engine). `TXT_KEY_VP_DIPLO_PROJECT_PLAYERS_COMPLETE` lists who has built the prerequisite Apollo.
- Cultural. Shows Social Policy branches completed (`TXT_KEY_VP_DIPLO_SOCIAL_POLICIES`) in base/G&K. BNW changes this entirely: cultural victory is Tourism-vs-Culture dominance - this screen shows how many civs you are "Influential" with toward all others. The `CultureOverview` (BNW) has the detailed tourism numbers; VictoryProgress shows the aggregate.
- Diplomatic. BNW World Congress / G&K United Nations. Shows total available votes (`TXT_KEY_VP_DIPLO_VOTES`), votes needed to win (`TXT_KEY_VP_DIPLO_VOTES_NEEDED`), turns until the next session (`TXT_KEY_VP_DIPLO_TURNS_UNTIL_SESSION`), delegates you control (`TXT_KEY_VP_DIPLO_DELEGATES_CONTROLLED`), total delegates in world (`TXT_KEY_VP_DIPLO_DELEGATES_IN_WORLD`), and delegates needed for the World Leader proposal (`TXT_KEY_VP_DIPLO_DELEGATES_NEEDED`). Projected votes per civ shown via `TXT_KEY_VP_DIPLO_MY_VOTES_TT_SUMMARY_ALT` "{CivName} has a projected {Num} votes". `TXT_KEY_VP_DIPLO_UN_INACTIVE` / `TXT_KEY_VP_DIPLO_UN_ACTIVE` headline. If the diplomatic victory is disabled by game setup, `TXT_KEY_VP_DIPLO_VICTORY_DISABLED`. When someone wins, `TXT_KEY_VP_DIPLO_SOMEONE_WON` "{CivName} has been elected World Leader".

`WhosWinningPopup` (G&K XML-only, BNW full override) is a sibling summary popup that fires at key thresholds warning the player that another civ is close to winning.

## 12.6 Top 5 Cities - N/A

The base game does not ship a dedicated Top 5 Cities screen - this was a Civ IV feature that did not carry over. The closest equivalents in Civ V are the Economic General Info tab of the Economic Overview (sort by Population to see your own cities ranked, but rival cities are not included) and the end-game Hall of Fame which records your largest cities. If we want a true Top-5-across-all-civs panel, it would have to be synthesized from `Game` / `Player:GetCityList` queries; mark as NOT STARTED in that case.

## 12.7 Replay Screen (Post-Game) - NOT STARTED

`UI/InGame/Popups/ReplayViewer.{lua,xml}`, plus `EndGameReplay.{lua,xml}` (base only) as the launcher wrapper. Title `TXT_KEY_REPLAY_TITLE` "REPLAY". The same viewer is reachable from the FrontEnd OtherMenu's `ViewReplays` option (via `LoadReplayMenu` as selector) and from `EndGameMenu` via `ReplayButton`. Three tabs:

- Map tab (`TXT_KEY_REPLAY_VIEWER_MAP_TITLE`, tooltip `TXT_KEY_REPLAY_VIEWER_MAP_TT` "View the world map and the growth of territories over time"). A turn-by-turn animated map showing each civilization's territory expansion. Purely visual. Accessibility substitute: per-civ city founding timeline and territorial size at each turn.
- Graphs tab (see 12.4).
- Messages tab (`TXT_KEY_REPLAY_VIEWER_MESSAGES_TITLE`, tooltip `TXT_KEY_REPLAY_VIEWER_MESSAGES_TT` "View all important messages which occurred during the game"). Every significant historical event from the game: city founded, city captured, wonder built, tech researched by someone, religion founded, war declared, leader defeated, and so on. This is the most valuable tab for a blind user since it is already text.

Shared controls: `ShowHide` toggle, `ReplayInfoPulldown` (pick the civilization to focus), `GraphDataSetPulldown` (see 12.4), `TurnSlider` (scrubs through history), `PlayPauseButton` (auto-advances turn slider for the Map tab).

## 12.8 Previous Turn Replay - N/A

Civ V does not have an in-game "previous turn replay" feature. The notification log (`NotificationLogPopup`) is a weak version - it lists notifications from the current and past turns that the player has received, but only notifications, not a full turn replay. The Messages tab of ReplayViewer is the closest equivalent and is only available after the game ends. If we want mid-game turn review, the accessibility layer would need to supply its own turn-event log by subscribing to the relevant `Events.*` (DoTurn, CityCaptured, UnitKilledInCombat, TechResearched, ReligionFounded, etc.) and replaying entries on demand. Mark as NOT STARTED if we choose to synthesize.

## 12.9 Hall of Fame - NOT STARTED

`UI/InGame/Popups/HallOfFame.{lua,xml}` in-game, also reachable from FrontEnd OtherMenu. Lists the player's past completed games with leader, civilization, victory type, score, date, difficulty, map, and duration. BackButton only. No drill-down beyond the list row; launching a replay from here goes through `LoadReplayMenu`.

## 12.10 End Game Menu - NOT STARTED

`EndGameMenu.{lua,xml}` with G&K and BNW XML-only overrides. The screen shown when the game ends (victory or defeat). Buttons: GameOverButton (the headline summary - who won, how, and when), DemographicsButton (opens 12.3), RankingButton (opens 12.4 base-game ranking), ReplayButton (opens 12.7), MainMenuButton (return to FrontEnd), BackButton (dismiss), BeyondButton ("One More Turn" - continue playing after victory or defeat). The headline summary includes the flavor text for the specific victory type (for example `TXT_KEY_VICTORY_SPACESHIP_HEADING4_TITLE`, `TXT_KEY_VICTORY_CULTURAL_HEADING3_TITLE`, `TXT_KEY_VICTORY_DOMINATION_HEADING3_TITLE`, `TXT_KEY_VICTORY_DIPLOMATIC_HEADING3_TITLE`, or the time-out variant `TXT_KEY_VICTORY_2050ARRIVES_HEADING3_TITLE`). For losses, `TXT_KEY_VICTORY_ANOTHERCIVWINS_HEADING3_TITLE` or `TXT_KEY_VICTORY_LOSINGCITY_HEADING3_TITLE`.
# Phase 11: Combat and Military

## 11.1 Unit Panel Selected-Unit Display - NOT STARTED

`UI/InGame/WorldView/UnitPanel.xml` (G&K and BNW overrides) is the persistent selected-unit panel in the bottom-left. It shows unit name (`UnitNameButton`, editable via `EditButton`), unit icon, movement remaining (`Movement` text button), melee strength (`Strength`), ranged strength (`RangedAttack`) when applicable, hit-points bar, experience toward next promotion, and the civ flag. `CycleLeft` and `CycleRight` step through owned units. `PromotionButton` toggles the promotion flyout. `UnitActionButton` grid hosts the context-sensitive orders (Move, Attack, Fortify, Sentry, Sleep, Alert, Hold, Pillage, Embark, Build Road, Build Farm, Build Mine, and so on for workers, Citadel or Academy for Great People, Airlift, Air Sweep, Rebase, Intercept). `RecommendedActionButton` prompts the advisor-suggested order.

Earned promotions are listed as icons in `EarnedPromotionStack`. Promotion tooltips come from `TXT_KEY_PROMOTION_*_HELP`. The unit status (fortified, embarked, sleeping, alert, automated) is displayed as a label using keys `TXT_KEY_UNIT_STATUS_FORTIFIED`, `_EMBARKED`, `TXT_KEY_MISSION_SLEEP`, `_HEAL`, `_ALERT`, `TXT_KEY_ACTION_AUTOMATE_BUILD`, `_AUTOMATE_EXPLORE`, `TXT_KEY_MISSION_GARRISON`.

- Unit name (editable), icon, civ flag.
- Movement remaining and max, melee strength, ranged strength when applicable.
- HP current and max (100 max for most units; displayed as bar).
- XP current and to-next-promotion threshold.
- Earned promotions list with tooltips.
- Status label.
- Action button grid with mission-specific icons and hotkey hints.
- Cycle left and right between owned units.
- `PromotionText` and `PromotionAnimation` pulse when a promotion is available to spend.

## 11.2 Promotion Chooser (Inline Flyout) - NOT STARTED

Civ V does not ship a standalone promotion popup. When a unit earns enough XP, `PromotionButton` on the UnitPanel begins flashing and `PromotionText` appears. Clicking the button reveals `PromotionStack`, a flyout listing every currently-eligible promotion as a `UnitAction`-template button. Each promotion button shows icon, name, and a tooltip with the full effect text. Clicking commits the promotion immediately and closes the flyout; no confirmation dialog. Multiple banked promotions cycle through the flyout until spent or the user defers.

- Flashing `PromotionButton` indicates at least one promotion available.
- `PromotionStack` flyout lists eligible promotions (varies by unit combat class, terrain, current promotions).
- Per-promotion: icon, localized name, effect tooltip (movement, combat bonuses, healing rate, sight range, and so on).
- Click to commit, no Yes/No confirmation.
- Banked promotions persist across turns; heal-and-promote interaction decides which to prefer.

## 11.3 Combat Preview (EnemyUnitPanel) - NOT STARTED

`UI/InGame/WorldView/EnemyUnitPanel.xml` mirrors the UnitPanel on the right-hand side when the cursor hovers a foreign unit or a tile targetable by the selected unit attack. Its Lua runs `UpdateCombatOddsUnitVsUnit` or `UpdateCombatOddsUnitVsCity` and populates a modifier list plus predicted damage numbers.

The panel shows: defender name, icon, HP current and max, defender strength (with terrain-adjusted value), attacker predicted damage dealt, attacker predicted damage taken, and a stack of every modifier feeding the prediction. Modifier rows use keys such as `TXT_KEY_EUPANEL_ATTACK_OVER_RIVER`, `_AMPHIBIOUS_ATTACK`, `_RANGED_ATTACK_MODIFIER`, `_GG_NEAR` (Great General adjacency), `_REVERSE_GG_NEAR` (enemy GG adjacency), `_IMPROVEMENT_NEAR` (fort or citadel), `_EMPIRE_UNHAPPY_PENALTY`, `_STRATEGIC_RESOURCE` (resource deficit), `_POLICY_ATTACK_BONUS`, `_BONUS_GOLDEN_AGE`, `_BONUS_CITY_STATE` (CS ally bonus), `_FLANKING_BONUS`, `_EXTRA_PERCENT` (promotions), `_FIGHT_AT_HOME_BONUS`, `_ATTACK_IN_FRIEND_LANDS`, `_OUTSIDE_HOME_BONUS`, `_ADJACENT_FRIEND_UNIT_BONUS`, `_ATTACK_MOD_BONUS`, `_BONUS_VS_CLASS` (plus N percent versus mounted, armored, and so on), `_SUPPORT_DMG` (siege support), `_ATTACK_CITIES` and `_ATTACK_CITIES_PENALTY` (melee versus city).

For air versus air: `_AIR_INTERCEPT_WARNING1`, `_AIR_INTERCEPT_WARNING2`, and `_VISIBLE_AA_UNITS` count the interceptors in range before committing an air strike.

- Defender name, icon, HP, terrain, strength after all modifiers.
- Predicted damage dealt and received (integer HP points out of 100 typical).
- Modifier stack with per-source sign and magnitude.
- Air-strike preview adds visible-interceptors count and intercept-probability warnings.
- City-attack preview shows city strength, garrison strength, HP, and defender wall or citadel bonuses.

## 11.4 Combat Resolution Display - NOT STARTED

Civ V has no explicit results dialog after a battle. The combat animation plays on the world view, both units HP bars update in place, and the outcome is announced only via `NotificationPanel` entries (unit killed, city damaged, barbarian defeated) plus log entries. Floating combat text over the hex shows damage numbers. If the attacker dies and was the selected unit, the UnitPanel empties; if the defender dies, the tile becomes occupyable. Promotions earned from the combat trigger the `PromotionButton` pulse on the next selection cycle.

- No modal after combat resolves.
- Floating damage numbers over attacker and defender tiles.
- HP bars on `UnitFlagManager` flags update.
- Kill and win notifications feed `NotificationPanel`.
- XP gain is silent apart from the promotion availability flash.

## 11.5 Pillage Confirmation - NOT STARTED

`ConfirmCommandPopup` (`PopupsGeneric/`, reuses `GenericPopup.xml`) handles destructive unit commands including pillage. It shows a Yes/No prompt with the improvement or route being destroyed, the heal amount the pillaging unit will gain (25 HP typical, 50 for Huns and Berber Cavalry unique units), and gold stolen if applicable. Yes commits and consumes the unit movement; No cancels.

- Prompt body identifies what is being pillaged (improvement, trade route, or city tile).
- HP-gain and gold-gain numbers if applicable.
- Yes and No buttons.
- Same popup pattern used for disband unit and rebase confirmation.

## 11.6 City Capture Popups - NOT STARTED

On taking a city, the engine dispatches `BUTTONPOPUP_CITY_CAPTURED` which opens two sequential generic popups.

First, a capture-gold announcement: `TXT_KEY_POPUP_GOLD_CITY_CAPTURE` reports captured gold and city name, or `TXT_KEY_POPUP_NO_GOLD_CITY_CAPTURE` if empty. Below, `TXT_KEY_POPUP_CITY_CAPTURE_INFO` explains that a choice is pending.

Then the choice popup (`AnnexCityPopup.lua` and `PuppetCityPopup.lua`, Lua-only, reusing `GenericPopup.xml`) presents up to four buttons:

- `TXT_KEY_POPUP_LIBERATE_CITY` (Yes, or Resurrect if the original owner was eliminated). Tooltips `TXT_KEY_POPUP_CITY_CAPTURE_INFO_LIBERATE` or `_LIBERATE_RESURRECT`.
- `TXT_KEY_POPUP_ANNEX_CITY` with unhappiness penalty in `TXT_KEY_POPUP_CITY_CAPTURE_INFO_ANNEX`.
- `TXT_KEY_POPUP_PUPPET_CAPTURED_CITY` with lesser penalty in `TXT_KEY_POPUP_CITY_CAPTURE_INFO_PUPPET`.
- `TXT_KEY_POPUP_RAZE_CAPTURED_CITY` (offered only if not an original capital) with `_RAZE`.
- `TXT_KEY_POPUP_VIEW_CITY` to jump to the CityView without deciding yet.

Tooltips on each option give the exact happiness cost at the current empire size. The choice is mandatory before the next turn ends.

- First popup: gold captured, city name, you-must-choose preamble.
- Second popup: Liberate, Annex, Puppet, Raze, or View City, each with unhappiness and resistance tooltips.
- Decision persists the city in that state; annex can happen later from CityView, raze can be toggled from the puppet menu.

## 11.7 Found, Raze, and Adjacent City Prompts - NOT STARTED

Founding a city uses the Settler Found City action button with no popup; the city is created and CityView opens after the first city. Subsequent foundings just place the city. Razing a non-capital city is decided at capture time or toggled in CityView Annex or Raze menu. `ConfirmCityTaskPopup` confirms certain city-scoped tasks (buy tile, buy building via gold, purchase with faith) with a Yes/No and cost readout.

## 11.8 Barbarian Encounter Popups - NOT STARTED

Two barbarian-specific popups exist. `BarbarianCampPopup.xml` fires when a player clears a camp and earns gold; it shows `TXT_KEY_BARB_CAMP_CLEARED` with the gold amount and a single `CloseButton`. `BarbarianRansomPopup` (`PopupsGeneric/`, reuses GenericPopup) fires when barbarians capture a worker or settler and demand ransom: `TXT_KEY_RANSOM_POPUP_INFO` with the gold demanded, a `TXT_KEY_RANSOM_POPUP_PAY` button, and a `TXT_KEY_RANSOM_POPUP_ABANDON` button.

- Camp cleared: gold amount, close.
- Ransom: gold demanded, pay (recover civilian, lose gold) or abandon (lose civilian).
- Barbarian presence otherwise surfaces only through `NotificationPanel` `EnemyInTerritoryButton` entries.

## 11.9 Nuke Targeting Mode - NOT STARTED

Attacking with a nuclear-capable unit (Atomic Bomb on a carrier or city, Nuclear Missile from a silo) enters an interface mode driven by `WorldView.lua` and flagged by `CIV5InterfaceModes.xml`. No modal popup; instead the cursor becomes a target reticle over every hex within the nuke range, invalid hexes are dimmed, and hovering shows a blast-radius preview on the world. Clicking a target fires `DeclareWarPopup` (BNW) or `DeclareWarRangeStrikePopup` first if targeting a civ at peace; otherwise launches immediately with no confirmation. Post-launch, a `GenericWorldAnchor` animation plays and fallout and damage are announced via notifications. There is no strike-confirmation modal for hostile targets.

- Enters interface-mode cursor; range and blast radius are purely visual.
- War-declaration confirmation fires only if target is currently at peace.
- No pre-launch Yes/No for hostile targets.
- Outcome reported through notifications: cities damaged, units destroyed, fallout tiles, diplomatic reputation hit.

## 11.10 Air Mission Interface - NOT STARTED

Air units (Fighter, Bomber, Jet Fighter, Stealth Bomber, Triplane, Great War Bomber, Guided Missile, and BNW additions) use interface-mode actions launched from the UnitPanel action grid. Each action enters a targeting cursor similar to nuke mode.

- Air Strike: cursor over valid ground or naval targets within range. Hovering a target shows the same combat-preview stack as `EnemyUnitPanel`, with the `_AIR_INTERCEPT_WARNING1`, `_AIR_INTERCEPT_WARNING2`, and `_VISIBLE_AA_UNITS` rows added. Damage is dealt on click with no modal.
- Air Sweep (G&K and BNW): targets a hex; fighters in range engage any interceptors there to clear them for subsequent bombers. Same targeting pattern.
- Intercept: toggle on the unit, no targeting mode. Unit will auto-engage enemy air in range during enemy turns.
- Rebase: cursor over friendly cities and carriers within rebase range (double the air unit range typically). Click commits. Confirmation via `ConfirmCommandPopup` if the move is to a carrier.

BNW does not restructure the air mission chooser. The same action buttons are present but BNW adjusts tech gating and the Atomic era unit mix; air-unit management flow is unchanged from G&K.

- Action buttons on UnitPanel: Air Strike, Air Sweep, Intercept toggle, Rebase.
- Targeting cursor with valid-hex highlighting and combat preview for attacks.
- Rebase confirmation via `ConfirmCommandPopup`.
- Interceptor warnings surface only through `EnemyUnitPanel` before committing.

## 11.11 Embarkation Prompts - NOT STARTED

Embarking a land unit onto water (after Optics) uses `ConfirmCommandPopup` the first time per turn to warn about movement-point cost and vulnerability. The unit flag switches to embarked state; the UnitPanel status label becomes `TXT_KEY_UNIT_STATUS_EMBARKED`. Disembarking back onto land also costs movement; no confirmation. Great Admiral and Great General embarks behave the same. Crossing ocean (after Astronomy) is silent. Embarked units have 1 strength and die outright to naval attacks, which the combat preview correctly reflects.

- Initial embark: Yes/No confirmation with move-cost warning.
- Embarked unit flag style changes (small boat icon); UnitPanel status reads `EMBARKED`.
- No prompt on disembark or on ocean-tile crossing.

## 11.12 Naval Unit Special Cases - NOT STARTED

Naval units share the UnitPanel layout but add some domain-specific actions. Melee naval can capture civilian units and enemy embarked units on water (no prompt). Ranged naval (Galleass, Frigate, Battleship, Missile Cruiser) use the same range-attack targeting cursor as land ranged units. Submarines have a stealth indicator on the flag (visible only to adjacent enemies or with specific promotions). Carriers show cargo load as a number on the flag; clicking the carrier opens the UnitPanel with a cargo list and rebase-carrier-cargo buttons.

- Capture of civilians at sea: silent; the unit is added to the naval unit tile.
- Range attack: same targeting and preview as land ranged.
- Carrier cargo: shown on UnitPanel with per-aircraft slots; aircraft can be launched from the carrier, rebased off, or used as normal.
- BNW adds Cargo Ship and Caravan, but these are civilian trade units with their own flow (covered in the trade phase), not combat.

## 11.13 Military Overview - NOT STARTED

`MilitaryOverview.xml` (G&K and BNW overrides) opens from the InfoCorner military icon. It is a two-column sortable table of every owned unit split into `MilitaryStack` (combat) and `CivilianStack` (workers, settlers, Great People, missionaries, diplomats-as-spies in BNW). Columns: Name, Status, Movement (remaining and max), Moves (distance), Strength, Ranged Strength. Each column is a click-to-sort header (`SortName`, `SortStatus`, `SortMovement`, `SortMoves`, `SortStrength`, `SortRanged`). Row clicks jump the camera to the unit and select it. `CivilianSeperator` divides the two sections.

The header also shows unit supply: `HandicapSupplyValue` (base from difficulty), `CitiesSupplyValue` (per-city bonus), `PopulationSupplyValue` (per-pop bonus), `SupplyCapValue` (total), `SupplyUseValue` (currently used), `SupplyRemainingValue` (room before deficit) or `SupplyDeficitValue` plus `SupplyDeficitPenaltyValue` (production penalty percent) when over cap. G&K adds a Great General progress meter (`GPMeter`, `GPBox` with `TXT_KEY_MO_GENERAL_TT`); BNW adds a Great Admiral progress meter (`GAMeter`, `GABox` with `TXT_KEY_MO_ADMIRAL_TT`).

Status column values come from `TXT_KEY_UNIT_STATUS_EMBARKED`, `TXT_KEY_MISSION_GARRISON`, `TXT_KEY_ACTION_AUTOMATE_BUILD`, `TXT_KEY_ACTION_AUTOMATE_EXPLORE`, `TXT_KEY_MISSION_HEAL`, `TXT_KEY_MISSION_ALERT`, `TXT_KEY_UNIT_STATUS_FORTIFIED`, and `TXT_KEY_MISSION_SLEEP`.

- Two sortable tables (military, civilian) with name, status, movement, moves, strength, ranged.
- Unit supply breakdown and deficit penalty.
- Great General and Great Admiral progress bars (G&K and BNW respectively).
- Row click jumps to the unit and selects it.
- `CloseButton` returns to world view.

---
# Phase 13: Interrupt Popups

The `SerialEventGameMessagePopup` event is Civ V's central modal dispatcher. Its `popupInfo.Type` field carries one of 69 values from the `ButtonPopupTypes` enumeration. Each value corresponds to a distinct XML/Lua pair under `Assets/UI/InGame/Popups/` (with Expansion and Expansion2 overrides for G&K and BNW additions). These popups pause turn flow, demand acknowledgment, or solicit a choice; several of them are the only way a given mechanic surfaces to the player. Because they steal focus from whatever the player was doing, each one must announce itself, read its content, expose its inputs, and confirm dismissal.

None of these are covered by the mod yet. Every subsection below is NOT STARTED.

## 13.1 Discovery and Exploration Popups - NOT STARTED

These fire when the player's units encounter something new on the map. They are purely informational in base Civ V, except for BNW's ancient ruins rework which makes the reward a choice.

- `BUTTONPOPUP_TEXT` in goody-hut form (`GoodyHutPopup`) - announces what an ancient ruin yielded: gold, culture, map reveal, population, worker, upgraded unit, tech, or faith. Pure acknowledge. base.
- `ChooseGoodyHutReward` - BNW reworks some ruins into a choice between two or three rewards. Each option has a localized title and description. Requires selection. BNW.
- `NaturalWonderPopup` - fires when any civ discovers a natural wonder for the first time, or when the player does. Shows the wonder name, its yields, happiness and tourism modifiers, a flavor paragraph, and a zoom-to action. base / G&K / BNW.
- `BarbarianCampPopup` - fires after clearing a barbarian encampment, announcing the gold reward and any city-state relation bump. base / G&K / BNW.
- `CityStateGreetingPopup` - fires on first contact with a city-state, showing its type (Cultured, Maritime, Militaristic, Mercantile, Religious in G&K+), its personality, the gift offered for meeting, and the initial influence granted. base / G&K / BNW.
- First-contact with a major civ is routed through `BUTTONPOPUP_DIPLOMACY` and covered in 13.4.

## 13.2 Production, Growth, and Wonder Popups - NOT STARTED

These fire when a city completes something or when a wonder changes hands globally. Most are acknowledge-only, but the production-finished one can offer a choice of next production.

- `BUTTONPOPUP_CITY_PRODUCTION_FINISHED` (`ProductionPopup` in finished mode) - a city has completed its current build. Shows the finished item and presents the full production menu to pick the next queue entry: units, buildings, wonders, national wonders, projects, processes like research or gold conversion, and purchase-with-faith items in G&K and BNW. Requires choice. base / G&K / BNW.
- `BUTTONPOPUP_CHOOSEPRODUCTION` - dispatched when a new city needs its first production choice, same UI as above. base / G&K / BNW.
- `BUTTONPOPUP_CULTURE_CHOOSE_WONDER` - wonder-selection popup surfaced by a policy or event that grants a free wonder. Lists wonders currently buildable by the player. base / G&K / BNW.
- `WonderPopup` (`BUTTONPOPUP_TEXT` in wonder-completed form) - a wonder has just been built, either by the player or by another civ. Shows a cinematic (skippable), the wonder's name, a quotation, and its effects. When another civ built it, adds who and where. base / G&K / BNW.
- `GreatPersonRewardPopup` (`BUTTONPOPUP_GREAT_PERSON_REWARD`) - a city with the right buildings has birthed a great person. Names the person, the type, and offers a go-to-unit action. base / G&K / BNW.
- `BUTTONPOPUP_GREAT_PEOPLE_CHOICE` - fires where the player must pick which great person type to receive (Liberty finisher, certain policy finishers). Lists available types with the effect of each. base / G&K / BNW.
- `BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER` and `GreatWorkPopup` - a Great Writer, Artist, or Musician has produced a great work and the player must select which theming slot to place it in, or which rival to target with a Great Musician concert tour. BNW.
- `BUTTONPOPUP_GREAT_WORK` - general dispatcher for great-work placement prompts. BNW.
- `BUTTONPOPUP_ARCHAEOLOGY_CHOICE` (`ChooseArchaeologyPopup`) - an Archaeologist has finished digging a site. Player picks between a landmark tile improvement (permanent tile bonus) or an artifact great work (slottable in buildings). BNW.
- `BUTTONPOPUP_CITY_NAME_CHANGE` (`SetCityName`) - fires on founding and on manual rename. Text input field. base / G&K / BNW.
- City growth and starvation do not get dedicated popup types; they surface through the notification system.

## 13.3 Choice Popups (Tech, Policy, Religion, Ideology) - NOT STARTED

The densest and most information-heavy group. Each is a modal that cannot be dismissed without making a choice, and each exposes mechanics unique to its system.

- `BUTTONPOPUP_CHOOSETECH` and `BUTTONPOPUP_TECH_TREE` (`TechPopup` / tech tree screen) - the player finished a tech and must queue the next, or is browsing the tree. The popup form lists immediately-researchable techs with cost and effects; the tree form is the full navigable tech tree with prerequisites. base / G&K / BNW.
- `BUTTONPOPUP_TECH_AWARD` (`TechAwardPopup`) - first civ to research a given tech gets an award announcement (free great person from philosophy, for instance). base / G&K / BNW.
- `BUTTONPOPUP_CONFIRM_POLICY` and `BUTTONPOPUP_POLICY_TREE` (`SocialPolicyPopup`) - culture has accumulated to the point of a new policy. Shows policy trees unlocked by era; lists each policy's prerequisites, effects, and cost in current culture; confirms the spend. In BNW, also surfaces ideologies once Industrial era hits. base / G&K / BNW.
- `BUTTONPOPUP_CONFIRM_IDEOLOGY_CHOICE` (`ChooseIdeologyPopup`) - the player's civ has entered the Industrial era and must pick Freedom, Order, or Autocracy. Each option shows its tenets, defector pressure, and tourism implications. BNW.
- `ChoosePantheonPopup` - faith threshold reached for a pantheon. Lists every pantheon belief still available with its effect text. G&K / BNW.
- `ChooseReligionPopup` - a Great Prophet is founding a religion. Player names the religion (or picks from a rotating list), selects the icon, picks one founder belief and one follower belief. G&K / BNW.
- `BUTTONPOPUP_FOUND_RELIGION` - engine dispatcher for the religion-founding flow. G&K / BNW.
- `BUTTONPOPUP_ENHANCE_RELIGION` - a Great Prophet is enhancing an existing religion. Player picks one additional follower belief and one enhancer belief. G&K / BNW.
- `BUTTONPOPUP_REFORMATION_BELIEF` - a Reformation wonder or policy has unlocked a reformation belief slot. Player picks one reformation belief from those still available. BNW.
- `ChooseFaithGreatPerson` - a player with enough faith after Industrial era (G&K) or after unlocking the right belief (BNW) can purchase a great person with faith. Lists available great person types with faith cost and effect. G&K / BNW.
- `ChooseMayaBonus` - Maya civ specific. End of each baktun period, the player picks one great person to spawn from a list that narrows each period. G&K / BNW.
- `ChooseFreeItem` - dispatcher for various pick-one-from-a-list grants: free tech from Great Library, free unit from certain ruins, free building from a wonder. base / G&K / BNW.
- `SetUnitName` (`BUTTONPOPUP_TEXT` variant) - a Great General or Great Admiral has been earned and the player names it, or renames any unit. base / G&K / BNW.
- `BUTTONPOPUP_RELIGION_ESTABLISHED` - notification-style popup announcing that a religion has been founded somewhere in the world, with name, founder, and holy city. G&K / BNW.

## 13.4 Diplomacy Popups (Outside the Leader Screen) - NOT STARTED

The leader screen itself is covered by Phase 7. These popups wrap or supplement it: alerts, vote prompts, and lightweight diplomatic notifications that do not need a full 3D leader.

- `BUTTONPOPUP_DIPLOMACY` - the top-level dispatcher to open the leader head screen. Also fires the first-contact sequence with a major civ. base / G&K / BNW.
- `BUTTONPOPUP_DECLAREWARMOVE` (`DeclareWarPopup`) - player is about to move a unit in a way that would cross a border without open borders, triggering war declaration. Confirms the war. base / G&K / BNW.
- `BUTTONPOPUP_WAR_STATE_CHANGE` - fires on declaration of war by or against the player, on peace treaty, and on ceasefire. Names the parties and the state change. base / G&K / BNW.
- `BUTTONPOPUP_DIPLO_OPINION_CHANGE` - a major civ's opinion of the player has shifted enough to warrant a callout (denunciation, friendship accepted, friendship expired, backstab). base / G&K / BNW.
- `BUTTONPOPUP_TRADE_REPUDIATED` and `BUTTONPOPUP_DEAL_CANCELED` - a standing deal has been broken by the other party, whether through war, repudiation of a peace treaty, or research-agreement cancellation. Names the deal and the reason. base / G&K / BNW.
- `BUTTONPOPUP_PLAYER_DEALT_WITH` - the other-civ-side confirmation that a deal was accepted or refused. base / G&K / BNW.
- `BUTTONPOPUP_GOSSIP` - BNW gossip system. Reports what another civ has been up to (built a wonder, adopted an ideology, denounced someone, received a delegation). Informational only. BNW.
- `BUTTONPOPUP_YOU_ARE_UNDER_ATTACK` - your city or unit has been attacked and you may not have been looking. Pause and acknowledge. base / G&K / BNW.
- `CityStateDiploPopup` / `BUTTONPOPUP_MINOR_CIV_DIPLOMACY` - full city-state interaction screen: gift gold, gift units, demand tribute, buyout (BNW after Patronage finisher), view current quests. base / G&K / BNW.
- `BUTTONPOPUP_MINOR_CIV_QUEST` - a city-state has issued a new quest or completed one. Announces quest text, reward, and deadline. base / G&K / BNW.
- `BUTTONPOPUP_MINOR_CIV_INVESTMENT` - mercantile or gold-focused action with a city-state. base / G&K / BNW.
- `BUTTONPOPUP_MINOR_CIV_GIFT_TILE` - the city-state has gifted the player a tile. Names the tile and its yields. G&K / BNW.
- `BUTTONPOPUP_CSD_DIPLO_DEAL` - city-state diplomacy modifier dispatcher. base / G&K / BNW.
- World Congress flow is BNW-only:
  - `BUTTONPOPUP_LEAGUE_SPLASH` (`LeagueSplash`) - session is starting or has just concluded; shows league name, host, session number.
  - `BUTTONPOPUP_LEAGUE_OVERVIEW` - full congress overview, member list, current proposals, votes cast.
  - `BUTTONPOPUP_LEAGUE_PROPOSE` - the player is proposer this session and picks one proposal plus one repeal from the available set.
  - `BUTTONPOPUP_LEAGUE_VOTE_ENACT` - voting on proposed resolutions with delegates.
  - `BUTTONPOPUP_LEAGUE_VOTE_REPEAL` - voting on repeal of enacted resolutions.
  - `BUTTONPOPUP_DIPLOMATIC_VOTE`, `BUTTONPOPUP_DIPLO_VOTE_CHOICE`, `BUTTONPOPUP_DIPLOMATIC_VOTE_RESULT`, `BUTTONPOPUP_DIPLO_VOTE_RESULTS` - vote-cast and vote-result flows for both congress resolutions and the final Diplomatic Victory vote.
  - `VoteResultsPopup` - results display for any league vote.

## 13.5 Crisis and Combat Popups - NOT STARTED

- `BUTTONPOPUP_CITY_CAPTURED` - a city has changed hands. Names the city, former owner, new owner, and in player-as-conqueror form presents a choice: annex (unhappiness, courthouse path), puppet (no control, reduced penalties), raze (countdown to destruction; only for non-original-capital cities), or liberate (return to original owner for diplomatic bonus). base / G&K / BNW.
- `BUTTONPOPUP_RESISTANCE_ENDED` - a captured city has finished its resistance period and is now productive. base / G&K / BNW.
- `BUTTONPOPUP_BARBARIAN_RANSOM` - a barbarian has captured one of your units or workers and demands a ransom. Pay or refuse. base / G&K / BNW.
- `BUTTONPOPUP_CONFIRM_COMMAND` - command-level confirmations: disband unit, raze city manually, sell building, gift unit to city-state. base / G&K / BNW.
- `BUTTONPOPUP_CHOOSE_DISBAND_UNIT` - the player is over the unit supply limit or needs to disband to build a replacement; lists candidates. base / G&K / BNW.
- `BUTTONPOPUP_UNIT_UPGRADE` - a unit has become upgradable. Shows current type, target type, gold cost, and stat deltas. base / G&K / BNW.
- `BUTTONPOPUP_LOADUNIT` / `BUTTONPOPUP_LEADUNIT` - boarding and disembark confirmations for transport units (Triremes, Caravels, Galleasses, Transports). base / G&K / BNW.
- `BUTTONPOPUP_BUYTILE` - tile-purchase confirmation from the city screen buy-tile mode. base / G&K / BNW.
- `BUTTONPOPUP_CHOOSE_CITY_PLOT` - settler is placing a city and the engine wants explicit plot confirmation in some flows. base / G&K / BNW.
- `BUTTONPOPUP_ESPIONAGE_SPY_CHOICE` - a spy has completed a mission or been reassigned, and the player picks its next posting: own city (counterspy), major civ city (steal tech, fabricate incident), city-state (rig election, coup). BNW.
- `BUTTONPOPUP_COUP_RESULT` - coup attempt against a city-state has resolved. Names the spy, the city-state, and success or failure. BNW.
- `BUTTONPOPUP_RIG_ELECTION_RESULT` - city-state election resolved with influence changes for all participating civs. BNW.
- Nuke detonation does not have its own ButtonPopupType; it surfaces through `BUTTONPOPUP_YOU_ARE_UNDER_ATTACK` and through notification and cinematic events. base / G&K / BNW.

## 13.6 Informational and Milestone Popups - NOT STARTED

Acknowledge-only popups that mark turn-level transitions or give the player a standing readout. Most are low-priority but still need to be spoken.

- `BUTTONPOPUP_NEW_ERA` (`NewEraPopup`) - the player has entered a new era. Shows era name, a flavor quote, and unlocks summary. base / G&K / BNW.
- `BUTTONPOPUP_TEXT` (`TextPopup` and `GenericPopup`) - the generic fallback for any one-off text message the engine wants to interrupt with: ideology defection warnings, treaty expiration reminders, turn-timer warnings, and modder-inserted messages. base / G&K / BNW.
- `BUTTONPOPUP_NOTIFICATION_LOG` (`NotificationLogPopup`) - scrollable log of all notifications this turn and recent turns. base / G&K / BNW.
- `BUTTONPOPUP_ALARM` - an engine alarm fires, typically for turn-timer expiry in multiplayer or for certain scenario triggers. base / G&K / BNW.
- `BUTTONPOPUP_CONFIRM_END_TURN` - end-of-turn prompt when unmoved units, unresearched tech, or other pending actions would be wasted. Lists the pending items. base / G&K / BNW.
- `BUTTONPOPUP_REPUBLIC_GOVERNMENT` - scenario-specific government change confirmation used by a few official scenarios. base / G&K / BNW.
- `BUTTONPOPUP_ADVANCED_START` - advanced-start mode at game launch lets the player spend points on starting units, techs, gold, buildings, and tiles. Each purchase shows cost and remaining budget. base / G&K / BNW.
- `BUTTONPOPUP_CIVILOPEDIA` and `BUTTONPOPUP_PEDIA_SEARCH` - open the in-game encyclopedia (covered by Phase 11) via popup dispatch. base / G&K / BNW.
- `BUTTONPOPUP_MAP` - full-screen minimap or strategic view popup. base / G&K / BNW.
- `BUTTONPOPUP_MAIN_MENU` and `BUTTONPOPUP_MAIN_MENU_OPTIONS` - in-game pause / retire / load / options menu, dispatched through the same popup system. base / G&K / BNW.
- `LeagueProjectPopup` - a World Congress project (World Fair, International Games, International Space Station) has completed and the popup names the top three contributor civs and the rewards each gets. BNW.
- `AdvisorCounselPopup`, `AdvisorInfoPopup`, `AdvisorModal` - the advisor nag popups (Military, Foreign, Economic, Science) that fire when the advisor level is set above "No Advisors". Each shows an advisor portrait and a text tip. base / G&K / BNW.
- `EmptyPopup` - a shell used by mods and by the engine as a placeholder; typically not shown but may flash briefly. base / G&K / BNW.

## 13.7 End-Game Trigger Popups - NOT STARTED

Full end-game screens (Hall of Fame, replay viewer, final leaderboard) are covered in Phase 14. The popups listed here are the ones that announce the transition: the you-won or you-lost moment and the keep-playing prompt.

- `BUTTONPOPUP_ENDGAME` (`EndGameMenu`) - a victory condition has been reached by some civ. Names the winner, the victory type (Domination, Science, Cultural, Diplomatic in G&K+, Cultural in the BNW tourism sense), and offers keep-playing, view-replay, main-menu, or one-more-turn. base / G&K / BNW.
- `BUTTONPOPUP_CIV5_DEFEATED` - the player's civ has been eliminated (capital captured in base, or last city lost). Shows who defeated them and offers spectate, replay, or main menu. base / G&K / BNW.
- `BUTTONPOPUP_EXTENDED_GAME` - fires after the player chose one-more-turn from the victory screen and wants to return to that prompt or see the final score at the calendar end. base / G&K / BNW.
- `BUTTONPOPUP_WHOSWINNING` (`WhosWinningPopup`) - not strictly end-game, but surfaces current victory progress for every civ across every victory type. Useful as a late-game status check. base / G&K / BNW.

## 13.8 Cross-Cutting Concerns - NOT STARTED

A few behaviors apply to every popup regardless of type and deserve accessibility treatment at the dispatcher level rather than per popup.

- Popup queueing. The engine serializes popups: if three fire on the same turn rollover (era change, production finished, tech finished), they play in order. The mod needs to announce the queue depth or at minimum name each popup as it becomes active so the player knows the context has changed.
- Focus handoff. When a popup opens, keyboard focus moves to its default button. When it closes, focus returns to wherever it was before (usually the unit panel or the map). Both transitions must be spoken.
- Text content. Most popups render their body text through Locale.ConvertTextKey on a TXT_KEY_* that may contain [NEWLINE], [ICON_*], color codes, and bullet-like glyphs. The central announcement pipeline must strip markup before speech but must not drop gameplay-relevant numbers.
- Choice enumeration. Choice popups (tech, policy, belief, production, archaeology, ideology, goody-hut reward) expose their options as a scrollable or paged list of buttons. The mod needs a uniform read-current / move-next / move-previous / confirm interaction that works across all of them without reimplementing per popup.
- Modal dismissal. Some popups have a confirm button, some have confirm plus cancel, some are acknowledge-only with a single close, and a few (end-turn confirm, war declaration) default to the destructive action. The default action and the set of actions must be announced when the popup opens.
# Phase 14: Endgame

The endgame sits behind the `EndGameMenu` screen (base / G&K / BNW XML overrides, base Lua shared), which is driven by the `Events.EndGameShow(type, team)` event. The `type` is an `EndGameTypes` enum with entries for each victory condition plus `Loss` and five `TutorialN` variants. The active player's team is compared against `Game:GetWinner()` to decide whether this is a win or a loss. Below that root the menu embeds three sub-screens as `LuaContext` children: `Ranking` (final scoreboard), `ReplayViewer` (map-history playback and per-civ graphs), and `Demographics` (final demographics table). BNW also exposes a `BeyondButton` on Science victories that opens the Steam store page for Beyond Earth; it is not a gameplay continuation.

## 14.1 Spaceship Build Screen - N/A

Civ V has no dedicated spaceship assembly panel. The Space Race proceeds entirely through normal city production: once a team researches the Apollo Program tech and builds the Apollo Program wonder, each of the seven SS Cockpit / SS Stasis Chamber / SS Engine / SS Booster parts becomes a production option in city production menus. They appear like any other wonder in the `ProductionPopup` chooser and in city production readouts, then auto-assemble when completed. Progress is visible from two existing screens:

- `VictoryProgress` (base / G&K / BNW overrides) - the SpaceRaceDetails sub-view lists every spaceship part and which civ has built it. Button IDs: `SpaceRaceDetails` (open), `SpaceRaceClose` (close), returning to the `YourDetails` pane.
- `TechTree` / `CityView` production panels show the parts as buildable items like any other.

Coverage therefore falls out of production-menu and victory-progress accessibility (Phases 6 and 8 in this audit). No bespoke assembly UI exists to announce.

## 14.2 Victory Progress Panel - NOT STARTED

base / G&K / BNW. `VictoryProgress` is the in-game "how close is everyone to each victory" screen, reachable from the `DiploCorner` `VictoryProgressButton` and from various notifications. It is not strictly an endgame screen but it is where the player monitors the race. Tabs along the top break down per victory type:

- Domination tab (`DominationStack`) - lists every original capital and which team currently holds it, with a leading highlight when one team holds enough capitals.
- Tech / Space Race tab (`TechStack`, `SpaceRaceDetails` button) - Apollo prereq progress and spaceship part-by-part status per civ.
- Cultural tab (`CultureStack`) - BNW shows tourism influence levels versus each other civ; base / G&K shows policy-tree progress instead.
- Diplo tab (`DiploStack`) - World Congress / UN vote tallies and delegate counts (BNW) or city-state ally counts (G&K UN path).
- Score tab (`ScoreDetails` / `ScoreClose`) - the current per-civ score and, via `PopulateScoreBreakdown`, the local player's score split across Cities, Population, Land, Wonders, Tech, Future Tech, Policies, Great Works (BNW), Religion (G&K+), and up to four scenario categories.

Close via `BackButton`. No coverage.

## 14.3 Who Is Winning Popup - NOT STARTED

base / G&K / BNW. `WhosWinningPopup` auto-fires every so often through the `BUTTONPOPUP_WHOS_WINNING` message. The Lua picks a random presenter name from `TXT_KEY_DUDE_1` through `TXT_KEY_DUDE_7` (for example "Abraham Lincoln presents...") and a random category from ten list modes: Food, Production, Gold, Science, Culture (policies), Happiness, Wonders, Power (military might), Cultural Influence (civs you are Influential over), and Tourist Cities (top tourism-producing cities worldwide). Modes guard themselves against gating conditions: Culture, Food, and Production stop showing past the Industrial Era, Cultural Influence only appears once someone has influence, Tourism only once someone generates it, Wonders only once two exist, and Happiness and Science hide if those systems are disabled. Each entry shows rank, leader name (or "Unmet player"), civ icon, and the score for the chosen metric. Close via `CloseButton` / Esc / Enter.

This is the game's closest thing to a "who is threatening to win" readout and is a prime candidate for a full speech pass. No coverage.

## 14.4 Tourism Threshold Popup (Influential / Dominant) - NOT STARTED

BNW only. Crossing a tourism threshold against another civ - Unknown, Exotic, Familiar, Popular, Influential, Dominant - fires the generic notification system; Influential on every remaining civ triggers the Cultural Victory win path. There is no dedicated popup screen: the event surfaces as a `NotificationPanel` entry (for example, "Your civilization has become Influential with the French") with its own `TXT_KEY_*` notification text, plus a global text announcement. The actual tourism status table (every civ's level against every other civ) lives in `CultureOverview` under its influence tab, and the BNW cultural tab of `VictoryProgress` summarizes it.

Coverage has to hook the notification stream (see Phase 7 NotificationPanel audit) and additionally differentiate these level transitions, since the step from Popular to Influential is the win trigger. No coverage.

## 14.5 World Congress and UN Vote Flow - NOT STARTED

G&K uses the UN wonder and runs the classic Diplomatic vote; BNW replaces this with the World Congress and its World Leader election resolution.

- `DiploVotePopup` (base / G&K / BNW) - the ballot. Lists every met major civ as a clickable button; selecting one calls `Network.SendDiploVote(iVotePlayer)`. BNW shows team labels in team games and leader names otherwise. Controls: `ButtonStack` of dynamic `Button` instances, `CloseButton` / Esc. At the cusp of diplomatic victory the ballot is the World Leader resolution.
- `VoteResultsPopup` (base / G&K / BNW) - the tally. `PlayerListStack` lists every team, their rank, how many votes they received, and who they voted for. Highlights the local player's team and flags minors that abstained. `CloseButton`.
- `LeagueOverview` (BNW only) - World Congress main screen between sessions. Lists active resolutions, pending proposals, turns until next vote, each civ's delegate count, and the current host. Controls: `ResolutionButton`, `VoteUpButton` / `VoteDownButton`, `ResolutionChoiceButton`, `RenameButton`, `TurnsUntilVoteFrame`, per-seat `MemberButton1..N`.
- `LeagueSplash` (BNW) - league founded / session opening splash. `CloseButton` only.

The vote-for-World-Leader ballot looks identical in control structure to the regular `DiploVotePopup`; the distinguishing information (that this vote decides the game) is buried in the ballot header text and the accompanying `SerialEventGameMessagePopup` info text. No coverage.

## 14.6 Victory Screen - NOT STARTED

base / G&K / BNW. `EndGameMenu` is the root for all victory and defeat flows. On show, `Controls.EndGameText` is filled from the matching text key and a full-screen `BackgroundImage` is loaded from `GameInfo.Victories[victoryType].VictoryBackground`. Victory audio (`GameInfo.Victories.Audio`) plays 2 seconds into the animation via `Events.AudioPlay2DSound`. The ContextPtr `OnUpdate` runs a `ZoomOutEffect` on the background for three seconds. Victory flavor text by type:

- Domination - `TXT_KEY_VICTORY_FLAVOR_DOMINATION`, `VICTORY_DOMINATION` audio and background. Triggers when your team holds every original capital.
- Science (Space Race) - `TXT_KEY_VICTORY_FLAVOR_TECHNOLOGY`, `VICTORY_SPACE_RACE`. Uses a 7 second deferred display (the spaceship-launch movie is supposed to play first). Also un-hides the BNW `BeyondButton`.
- Cultural - `TXT_KEY_VICTORY_FLAVOR_CULTURE`, `VICTORY_CULTURAL`. Base and G&K win by filling five policy trees and completing the Utopia Project; BNW wins by being Influential with every other civ via tourism.
- Diplomatic - `TXT_KEY_VICTORY_FLAVOR_DIPLOMACY`, `VICTORY_DIPLOMATIC`. G&K is the UN vote; BNW is the World Leader resolution in the World Congress.
- Time - `TXT_KEY_VICTORY_FLAVOR_TIME`, `VICTORY_TIME`. Awarded to the highest-scoring civ when the turn limit is reached; also the fallback screen if no victory type matches.

All five share the same button layout in `ButtonStack`: `MainMenuButton`, `BackButton` (the one-more-turn continue, labeled `TXT_KEY_EXTENDED_GAME_YES`), and on Science victories only `BeyondButton` (`TXT_KEY_GO_BEYOND_EARTH`) which opens the Steam overlay to the Beyond Earth store page.

The screen has four top tabs that swap the visible sub-context: `GameOverButton` (the flavor-text victory splash itself), `DemographicsButton`, `RankingButton`, and `ReplayButton`. Three of these are auto-hidden in tutorial games. No coverage.

## 14.7 Defeat Screen - NOT STARTED

base / G&K / BNW. Same `EndGameMenu` screen, selected when the event fires with a `team` that does not match the active team. The text is always `TXT_KEY_VICTORY_FLAVOR_LOSS`, the background switches to `Victory_Defeat.dds`, and the defeat audio (`AS2D_VICTORY_SPEECH_LOSS`) plays. The `BackButton` (one-more-turn) is disabled by default on defeat, but re-enabled if the player is still alive, the game is single-player, and extended play is not disabled via `GAMEOPTION_NO_EXTENDED_PLAY`, so a diplomatic or cultural loss where your civ still has cities lets you keep playing. If the active civ has been destroyed outright the button stays disabled and Main Menu is the only exit.

Hotseat has a special path: if any other human is still alive, `MainMenuButton` relabels to `TXT_KEY_MP_PLAYER_CHANGE_CONTINUE` and hands control to the next living human rather than exiting. No coverage.

## 14.8 Final Scoreboard (Ranking) - NOT STARTED

`Ranking` screen, embedded in `EndGameMenu` as the `RankingButton` tab. It slots the local player's final score into the list of historical civ-leader scores defined in the `HistoricRankings` data table. Each row shows rank number (`TXT_KEY_NUMBERING_FORMAT`), a historical leader name (`HistoricLeader`), their reference score, and on the player's inserted row a `LeaderQuote` and a highlighted `SelectHighlight` box. The title becomes `TXT_KEY_RANKING_STATEMENT` filled with the nearest-rank historical leader name ("You are comparable to..."). The screen is scrollable via `MainScroll`. No per-civ scoreboard of the current game's opponents lives here; for that, the `Demographics` tab shows final demographic rankings (population, GNP, land area, etc.) and the `VictoryProgress` Score tab shows the raw final scores. Together these three form the end-of-game scoreboard. No coverage.

## 14.9 Replay / Map-History Playback - NOT STARTED

base / G&K / BNW. `ReplayViewer` is embedded in `EndGameMenu` as the `ReplayButton` tab (also reachable standalone from `OtherMenu` via `ViewReplays` and `LoadReplayMenu`). Two panels swap via `ReplayInfoPulldown`:

- Messages panel - scrollable log of every recorded replay event (city founded, wonder built, war declared, tech completed, etc.) with turn numbers. Populated from `ReplayMessageStack` instances.
- Graphs panel - per-civ line graphs of a selectable dataset. `GraphDataSetPulldown` picks the metric (Score, Gold, Culture, Food, Production, Land, Population, Tech, etc.); each civ gets a `GraphLegend` row with civ icon, civ name, colored legend line, and a `ShowHide` checkbox. Below that, `TurnSlider` and `PlayPauseButton` step through the map visible state turn by turn, redrawing borders and cities as they were at that turn.

The entire panel is visual by construction. The metric graphs have discrete datapoints per civ per turn that could be sonified or read as lists; the map playback is a pan-able world view. No coverage.

## 14.10 One More Turn - NOT STARTED

Implemented as the `BackButton` on `EndGameMenu`, labeled `TXT_KEY_EXTENDED_GAME_YES`. Clicking it calls `Network.SendExtendedGame()` and dequeues the popup, dropping the player back into the running game with all victory conditions still achievable by others. The button is disabled when `GAMEOPTION_NO_EXTENDED_PLAY` is set, in multiplayer, or on a defeat where the active civ is dead. Esc and Enter both fire the same handler via `InputHandler`, so keyboard dismissal doubles as continue playing. No coverage to surface the current state of that button (enabled vs disabled) or distinguish it from the Main Menu exit.

## 14.11 Post-Game Stats and Demographics - NOT STARTED

base / G&K / BNW. `Demographics` is embedded in `EndGameMenu` as the `DemographicsButton` tab, and the same screen is also reachable mid-game from the `EconomicOverview`. It shows the final per-civ ranking across population, gross national product, soldiers, approval rating (happiness), life expectancy, family size, literacy, land area, and agriculture, with the local player row highlighted. `BackButton` only, no sorting or interactivity beyond the tab swap. No coverage.

The community Info Addict mod is the standard sighted-player solution for richer endgame graphs but is out of scope for this mod.

## 14.12 Hall of Fame Entry - NOT STARTED

base / G&K / BNW (XML overrides only, Lua shared). `HallOfFame` is a main-menu screen reached from `OtherMenu` via `HallOfFame`, not a post-game popup. Civ V does not pop a new-record splash at game end; the finished game is silently appended to the Hall of Fame data on exit (read back via `UI.GetHallofFameData()`), and the player has to open the screen from the main menu to see the entry. Each row shows:

- Win or loss banner (`TXT_KEY_VICTORY_BANG` or `TXT_KEY_DEFEAT_BANG`)
- Leader portrait and civ icon, with leader name and civ short description (using custom names if the player set them)
- Difficulty icon (tooltipped with the handicap description)
- Final score
- Winning civ of that game (or "You" if it was this player's win, or `TXT_KEY_CITY_STATE_NOBODY` for no-winner games)
- Game length and date metadata

No victory-type filter, no speed or difficulty filter, no new-record highlight. `BackButton` only. No coverage; because there is no end-of-game popup, the accessibility work is confined to reading the screen when the user opens it from the main menu.

## 14.13 End-of-Game Event Surface Summary

Observable on the engine side:

- `Events.EndGameShow(type, team)` - the authoritative signal for victory and defeat. Both arguments need inspection: `type` gives victory flavor, `team` compared against `Game.GetActiveTeam()` gives win vs loss.
- `SerialEventGameMessagePopup` `BUTTONPOPUP_WHOS_WINNING` - the periodic progress popup.
- `SerialEventGameMessagePopup` `BUTTONPOPUP_DIPLO_VOTE` and `BUTTONPOPUP_DIPLO_VOTE_RESULTS` - UN and World Leader ballot and tally.
- `Game:GetWinner()` and `Game:GetVictory()` - post-fact winning-team and winning-victory-type queries.
- `Player:GetScore()` and the per-category `GetScoreFrom*` family - live score breakdown at any point.
- Tourism level transitions surface through the notification stream (see Phase 7); no dedicated event fires specifically for crossing the Influential or Dominant boundary.

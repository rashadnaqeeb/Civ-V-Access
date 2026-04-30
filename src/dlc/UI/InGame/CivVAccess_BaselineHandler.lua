-- Routes the in-game cursor keys (Q/A/Z/E/D/C movement, S unit-at-tile,
-- W economy, X combat, Shift+S coordinates) to the Cursor module, plus
-- the Shift-letter surveyor cluster to SurveyorCore. Sits at the bottom
-- of the
-- HandlerStack so any popup / overlay above it that sets capturesAllInput
-- will pre-empt both clusters without us having to coordinate.
--
-- capturesAllInput = true: Baseline eats every unbound key on the map.
-- The mod reimplements every map-mode action we expose to the user, so
-- letting the engine's huge mission / build / automate key set fire under
-- us would be noise (keys that pick up different meanings depending on
-- the selected unit are impossible to speak consistently). passthroughKeys
-- carves out the minimum set we explicitly want the engine to still
-- handle: F1-F12 (advisor screens, strategic view, quick save/load,
-- Ctrl+F10 select capital, Ctrl+F11 quick load all hang off F-row
-- keycodes) and Escape (opens the pause menu, which our GameMenuAccess
-- then layers over). Popups above Baseline set their own capturesAllInput
-- without a passthrough list, so F-keys and Escape are correctly
-- swallowed while any dialog or menu is up.
--
-- F10 is both passed through AND bound: the plain-F10 binding wins at the
-- bindings-loop stage (InputRouter matches key + mods) and fires the
-- advisor counsel popup, overriding the engine's strategic-view toggle
-- which is useless to blind players. Ctrl+F10 has no mods=2 binding here
-- so it falls through the bindings loop, hits the passthrough check on
-- keycode alone, and reaches the engine's select-capital binding intact.
-- Rebinding F10 is the accessibility path because the engine's native
-- hotkey for advisor counsel is KB_V, which Baseline swallows as an
-- unbound letter.
--
-- Help entries are composed as one unified map-mode list in eight sections:
-- tile info (cursor cluster), game info (T/R/G/H/F/P/I empire-status keys),
-- unit control, turn lifecycle, surveyor, scanner (pulled from
-- ScannerHandler.HELP_ENTRIES), bookmarks (Ctrl/Shift/Alt + digit), and
-- function-row keys that open engine screens (F1-F9, plus our F10 rebind).
-- Scanner is always on the stack alongside Baseline in-game, so its entries
-- belong inside this ordered list rather than at the top (which is what a
-- top-down HandlerStack.collectHelpEntries walk would produce if Scanner
-- authored its own helpEntries). The F1-F9 entries describe engine behavior
-- reached via passthroughKeys; they have no Baseline binding.

BaselineHandler = {}

local MOD_NONE = 0
local MOD_SHIFT = 1
local MOD_CTRL = 2

local VK_OEM_5 = 220 -- backslash

local function speak(s)
    if s == nil or s == "" then
        return
    end
    SpeechPipeline.speakInterrupt(s)
end

local bind = HandlerStack.bind

-- Each cursor binding wraps the cursor call so the HandlerStack table only
-- ever sees a no-arg function. Direction is hard-coded per binding because
-- there are six -- a single dispatch table would cost more than the six
-- explicit closures and lose grep-ability.
local function moveDir(dir)
    return function()
        speak(Cursor.move(dir))
    end
end

local MOVEMENT_AND_INFO_HELP_ENTRIES = {
    -- Cursor cluster: unmodified keys first (move, S/W/X tile queries,
    -- 1/2/3 city queries, Enter activate), then the Shift-S coordinates
    -- and Ctrl-I pedia modifier variants.
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_POL",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_POL",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA",
        description = "TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA",
    },
}

local FUNCTION_KEY_HELP_ENTRIES = {
    -- Engine F1-F9 passthroughs. These aren't Baseline bindings -- the
    -- passthroughKeys table lets the keycode reach the engine's own
    -- advisor-screen / civilopedia / tech-tree / victory / info-screen
    -- actions. Authored here so the map-mode help list documents what a
    -- user gets "for free" from the engine.
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1" },
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2" },
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3" },
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4" },
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5" },
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6" },
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7" },
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8" },
    { keyLabel = "TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9", description = "TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9" },
    -- F10 is our rebind (see BaselineHandler binding further down); the
    -- engine's strategic-view toggle is suppressed. Grouped with the F-row
    -- passthroughs so the user sees the full function-row vocabulary in
    -- one place.
    {
        keyLabel = "TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY",
        description = "TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC",
    },
    -- Mod-bound chord; Culture Overview has no engine hotkey, so the
    -- binding sits adjacent to F10 here even though it isn't function-row.
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY",
        description = "TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC",
    },
    -- Trade Route Overview is reachable in vanilla only via the trade-unit
    -- panel button and DiploCorner; no engine hotkey. Same rationale as
    -- Culture Overview's chord above.
    {
        keyLabel = "TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY",
        description = "TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC",
    },
    -- League Overview. Engine's Ctrl+L is "Load game in-game" which is
    -- still reachable via the Esc menu; Baseline already swallowed it.
    {
        keyLabel = "TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY",
        description = "TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC",
    },
    -- Religion Overview. Engine's Ctrl+R toggles the resource icon overlay
    -- (visual-only); same overlay-toggle category as Ctrl+L and safe to
    -- replace.
    {
        keyLabel = "TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY",
        description = "TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC",
    },
    -- Espionage Overview (BNW only). Re-fires the engine's native Ctrl+E
    -- which Baseline's capture would otherwise swallow.
    {
        keyLabel = "TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY",
        description = "TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC",
    },
    -- Multiplayer chat. Mod-bound; backslash is unbound by every Civ V XML
    -- so the chord is free. SP no-ops with a spoken marker.
    {
        keyLabel = "TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY",
        description = "TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC",
    },
}

local function appendAll(dst, src)
    if type(src) ~= "table" then
        return
    end
    for _, e in ipairs(src) do
        dst[#dst + 1] = e
    end
end

function BaselineHandler.create()
    local bindings = {
        -- In Civ V's Keys enum, printable ASCII keys (letters and top-row
        -- digits) are registered under their literal character. Letters are
        -- valid Lua identifiers so `Keys.Q` works; digits aren't, so the
        -- top-row number keys require bracket form: `Keys["1"]`. Only the
        -- non-printable / special keys use the VK_ prefix (VK_ESCAPE, VK_LEFT,
        -- VK_NUMPAD1, etc.).
        bind(Keys.Q, MOD_NONE, moveDir(DirectionTypes.DIRECTION_NORTHWEST), "Move cursor NW"),
        bind(Keys.E, MOD_NONE, moveDir(DirectionTypes.DIRECTION_NORTHEAST), "Move cursor NE"),
        bind(Keys.A, MOD_NONE, moveDir(DirectionTypes.DIRECTION_WEST), "Move cursor W"),
        bind(Keys.D, MOD_NONE, moveDir(DirectionTypes.DIRECTION_EAST), "Move cursor E"),
        bind(Keys.Z, MOD_NONE, moveDir(DirectionTypes.DIRECTION_SOUTHWEST), "Move cursor SW"),
        bind(Keys.C, MOD_NONE, moveDir(DirectionTypes.DIRECTION_SOUTHEAST), "Move cursor SE"),
        bind(Keys.S, MOD_NONE, function()
            speak(Cursor.unitAtTile())
        end, "Read unit on tile"),
        bind(Keys.S, MOD_SHIFT, function()
            speak(Cursor.coordinates())
        end, "Coordinates from capital"),
        -- Ctrl+S (jump cursor to capital) is bound from Bookmarks.getBindings
        -- so it shares ScannerNav.jumpCursorTo with the digit-slot jumps;
        -- the help entry stays here in MOVEMENT_AND_INFO_HELP_ENTRIES so it
        -- sits next to Shift+S in the help list rather than in the
        -- bookmarks section.
        bind(Keys.W, MOD_NONE, function()
            speak(Cursor.economy())
        end, "Economy details"),
        bind(Keys.X, MOD_NONE, function()
            speak(Cursor.combat())
        end, "Combat details"),
        bind(Keys["1"], MOD_NONE, function()
            speak(Cursor.cityIdentity())
        end, "City identity and combat"),
        bind(Keys["2"], MOD_NONE, function()
            speak(Cursor.cityDevelopment())
        end, "City production and growth"),
        bind(Keys["3"], MOD_NONE, function()
            speak(Cursor.cityPolitics())
        end, "City diplomacy"),
        bind(Keys.VK_RETURN, MOD_NONE, function()
            Cursor.activate()
        end, "Activate tile"),
        bind(Keys.I, MOD_CTRL, function()
            Cursor.pedia()
        end, "Civilopedia for tile contents"),
        bind(Keys.VK_F10, MOD_NONE, function()
            -- Engine's native hotkey for this popup is KB_V, which Baseline
            -- swallows as an unbound letter; F10 (strategic view) is
            -- repurposed since blind players have no use for the visual
            -- toggle. Data1 = 1 asks the popup to queue at InGameUtmost
            -- priority and toggle-close if already visible.
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_ADVISOR_COUNSEL,
                Data1 = 1,
            })
        end, "Open advisor counsel"),
        -- Culture Overview has no engine hotkey at all (the screen opens
        -- only via the top-bar tourism icon and DiploCorner button), so
        -- without a chord, blind players cannot reach it. C alone is the
        -- cursor SE binding; Ctrl+C is distinct under (key, mods)
        -- dispatch. Engine's native Ctrl+C (CONTROL_SELECT_OF_TYPE,
        -- "select units of same type on plot") and Ctrl+C as Citadel
        -- build for Great Generals are both already swallowed by
        -- Baseline's letter capture, so the chord is free for us. Gated
        -- on GAMEOPTION_NO_CULTURE_OVERVIEW_UI so the binding speaks a
        -- disabled state rather than silently no-opping.
        bind(Keys.C, MOD_CTRL, function()
            if Game.IsOption("GAMEOPTION_NO_CULTURE_OVERVIEW_UI") then
                speak(Text.key("TXT_KEY_CIVVACCESS_CO_DISABLED"))
                return
            end
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_CULTURE_OVERVIEW,
                Data1 = 1,
            })
        end, "Open Culture Overview"),
        -- Trade Route Overview. No engine hotkey at all (sighted players
        -- reach it via the trade-unit panel and DiploCorner). Plain T is
        -- empire-status turn / date / supply readout; Ctrl+T is distinct
        -- under (key, mods) dispatch and unbound by every CIV5 XML
        -- (Controls / Commands / Missions / Automates / Builds / Interface-
        -- Modes), so the chord is free. Data1=1 toggles the popup closed
        -- when already visible (matches the Culture Overview pattern); Data2
        -- selects the landing tab (1=Your TR).
        bind(Keys.T, MOD_CTRL, function()
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_TRADE_ROUTE_OVERVIEW,
                Data1 = 1,
                Data2 = 1,
            })
        end, "Open Trade Route Overview"),
        -- League Overview (World Congress / United Nations). Engine reads
        -- popupInfo.Data1 as the league ID (not a toggle flag like TRO/CO),
        -- so we look up the active league's ID and pass it directly. -1
        -- when no league exists -- engine then shows the "not founded"
        -- panel and our wrapper speaks the matching no-league state.
        -- Engine's native Ctrl+L is "Load game in-game"; Baseline's
        -- capturesAllInput barrier already swallowed it. In-game load
        -- remains reachable via Esc menu.
        bind(Keys.L, MOD_CTRL, function()
            local leagueId = -1
            if Game.GetNumActiveLeagues() > 0 then
                for i = 0, math.max(Game.GetNumLeaguesEverFounded() - 1, 0) do
                    if Game.GetLeague(i) ~= nil then
                        leagueId = i
                        break
                    end
                end
            end
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_LEAGUE_OVERVIEW,
                Data1 = leagueId,
            })
        end, "Open World Congress overview"),
        -- Religion Overview. Engine's Ctrl+R toggles the resource-icon
        -- overlay (visual-only, no value to a blind player). Engine has a
        -- native Ctrl+P binding for the same screen, but Ctrl+P collides
        -- with worker BUILD_REPAIR (the engine disambiguates by context);
        -- Ctrl+R is mnemonic and conflict-free across CIV5Controls /
        -- Builds / Missions / Interface-Modes (bare R is BUILD_ROAD,
        -- Alt+R is RAILROAD/REBASE, Ctrl+Alt+R is REMOVE_ROUTE,
        -- Ctrl+Shift+R is ROUTE_TO -- none of which dispatch on Ctrl+R
        -- alone). Data1=1 toggles the popup closed when already visible
        -- (matches the Culture / Trade Route Overview pattern). Gated on
        -- GAMEOPTION_NO_RELIGION so the binding speaks a disabled state
        -- rather than silently no-opping when religion is off.
        bind(Keys.R, MOD_CTRL, function()
            if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
                speak(Text.key("TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"))
                return
            end
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_RELIGION_OVERVIEW,
                Data1 = 1,
            })
        end, "Open Religion Overview"),
        -- Espionage Overview (BNW only). Engine's native Ctrl+E was added in
        -- G&K and kept in BNW for this same popup; Baseline's
        -- capturesAllInput barrier already swallows it, so we re-fire the
        -- engine event here. Data1=1 toggles closed if already visible
        -- (matches the Culture / Trade Route / Religion Overview pattern).
        -- Gated on GAMEOPTION_NO_ESPIONAGE so the binding speaks a disabled
        -- state rather than silently no-opping when the host disabled
        -- espionage.
        bind(Keys.E, MOD_CTRL, function()
            if Game.IsOption("GAMEOPTION_NO_ESPIONAGE") then
                speak(Text.key("TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"))
                return
            end
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_ESPIONAGE_OVERVIEW,
                Data1 = 1,
            })
        end, "Open Espionage Overview"),
        -- Multiplayer chat. Backslash is unbound in every Civ V XML so the
        -- chord is free across base / G&K / BNW. SP no-ops with a spoken
        -- marker; MP fires the cross-Context bridge LuaEvents.CivVAccess-
        -- ChatToggle that ChatAccess (seated in DiploCorner's env via our
        -- DiploCorner.lua override) listens for. Game:IsNetworkMultiPlayer
        -- returns false in hot-seat too, which is correct -- hot-seat has
        -- no networking and no chat.
        bind(VK_OEM_5, MOD_NONE, function()
            if not Game:IsNetworkMultiPlayer() then
                speak(Text.key("TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"))
                return
            end
            LuaEvents.CivVAccessChatToggle()
        end, "Toggle multiplayer chat"),
    }

    -- Pull sibling modules' bindings into Baseline's list, and their help
    -- entries into the correct section of the composed map-mode help.
    local surveyor = SurveyorCore.getBindings()
    local unitControl = UnitControl.getBindings()
    local turn = Turn.getBindings()
    local empireStatus = EmpireStatus.getBindings()
    local taskList = TaskList.getBindings()
    local bookmarks = Bookmarks.getBindings()
    local messageBuffer = MessageBuffer.getBindings()
    appendAll(bindings, surveyor.bindings)
    appendAll(bindings, unitControl.bindings)
    appendAll(bindings, turn.bindings)
    appendAll(bindings, empireStatus.bindings)
    appendAll(bindings, taskList.bindings)
    appendAll(bindings, bookmarks.bindings)
    appendAll(bindings, messageBuffer.bindings)

    -- Help list, one unified map-mode list. Sections, in order:
    -- 1) tile info (cursor cluster, S/W/X tile queries, 1/2/3 city queries,
    --    Enter, Shift+S coordinates, Ctrl+I pedia),
    -- 2) game info (T/R/G/H/F/P/I empire-status readouts plus Shift+T
    --    task list) -- grouped right after tile info because both clusters
    --    answer "tell me about X" in one keystroke; tile info reads the
    --    cursor's hex, game info reads the empire,
    -- 3) unit control (Tab plus Alt-cluster quick actions),
    -- 4) turn lifecycle,
    -- 5) surveyor radius queries,
    -- 6) scanner (from ScannerHandler.HELP_ENTRIES because its own
    --    handler.helpEntries is intentionally empty; see ScannerHandler),
    -- 7) bookmarks (digit-keyed cursor positions; sit after scanner
    --    because they share the "go somewhere fast" purpose),
    -- 8) function-row keys (engine passthroughs plus our F10 rebind).
    local helpEntries = {}
    appendAll(helpEntries, MOVEMENT_AND_INFO_HELP_ENTRIES)
    appendAll(helpEntries, empireStatus.helpEntries)
    appendAll(helpEntries, taskList.helpEntries)
    appendAll(helpEntries, unitControl.helpEntries)
    appendAll(helpEntries, turn.helpEntries)
    appendAll(helpEntries, surveyor.helpEntries)
    appendAll(helpEntries, ScannerHandler.HELP_ENTRIES)
    appendAll(helpEntries, bookmarks.helpEntries)
    appendAll(helpEntries, messageBuffer.helpEntries)
    appendAll(helpEntries, FUNCTION_KEY_HELP_ENTRIES)

    -- F12 is intentionally absent: InputRouter's pre-walk hook claims it
    -- for the mod-wide Settings overlay. Letting it fall through here would
    -- be dead weight (the engine has no F12 binding) and would falsely
    -- advertise the chord as engine-handled.
    local passthroughKeys = {
        [Keys.VK_F1] = true,
        [Keys.VK_F2] = true,
        [Keys.VK_F3] = true,
        [Keys.VK_F4] = true,
        [Keys.VK_F5] = true,
        [Keys.VK_F6] = true,
        [Keys.VK_F7] = true,
        [Keys.VK_F8] = true,
        [Keys.VK_F9] = true,
        [Keys.VK_F10] = true,
        [Keys.VK_F11] = true,
        [Keys.VK_ESCAPE] = true,
    }
    return {
        name = "Baseline",
        capturesAllInput = true,
        passthroughKeys = passthroughKeys,
        bindings = bindings,
        helpEntries = helpEntries,
    }
end

-- Scanner handler. Sits directly above Baseline on the HandlerStack;
-- capturesAllInput=false so unbound keys (Q/A/S/W/X/... cursor cluster)
-- fall through to Baseline unchanged. Every binding here is an engine-
-- overriding choice documented in docs/hotkey-reference.md and listed
-- in the design doc section 6 rationale column.
--
-- Axis cycles are authored outer-to-inner in the four-level hierarchy:
-- Ctrl (category) above Shift (subcategory) above unmodified (item) above
-- Alt (instance). The binding list, the HELP_ENTRIES list, and the order
-- BaselineHandler surfaces them in all follow the same progression so the
-- user learns one modifier ladder.
--
-- Help entries live on the module (HELP_ENTRIES) rather than the returned
-- handler because BaselineHandler composes the full map-mode help list in
-- the order {movement/info, surveyor, scanner, function keys}. Scanner is
-- always stacked above Baseline in-game (Boot.lua pushes both at
-- LoadScreenClose), so surfacing scanner keys from Baseline lets the user
-- see them in the middle of Baseline's list rather than at the top (which
-- is what a top-down HandlerStack.collectHelpEntries walk would otherwise
-- produce). The returned handler.helpEntries is set to {} to opt in
-- explicitly and silence the "bindings without helpEntries" push warning.

ScannerHandler = {}

local MOD_NONE = 0
local MOD_SHIFT = 1
local MOD_CTRL = 2
local MOD_ALT = 4

local speak = SpeechPipeline.speakInterrupt

local bind = HandlerStack.bind

local function cycle(entryPoint, dir)
    return function()
        speak(entryPoint(dir))
    end
end

local function call(entryPoint)
    return function()
        speak(entryPoint())
    end
end

ScannerHandler.HELP_ENTRIES = {
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_AUTO_MOVE",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_AUTO_MOVE",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN",
        description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN",
    },
}

function ScannerHandler.create()
    local h = {
        name = "Scanner",
        capturesAllInput = false,
        -- Scanner is the top of the hex-viewer stack on the map. Speaking
        -- "map mode" on activation gives the user an audible landmark when
        -- a popup / sub-handler closes and the map cursor becomes live
        -- again. Queued rather than interrupting so a closing handler's
        -- own farewell announcement finishes first; at boot, the
        -- BOOT_INGAME speakInterrupt clears the queue before it plays.
        --
        -- Beacons.resume / Beacons.suspend tie the looping voices to the
        -- map being the input target. onSuspend fires when a popup pushes
        -- above Scanner; onActivate fires when that popup pops back.
        -- Baseline carries the same hooks for the edge case where Scanner
        -- is removed and Baseline becomes the direct top.
        onActivate = function()
            SpeechPipeline.speakQueued(Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"))
            Beacons.resume()
        end,
        onSuspend = function()
            Beacons.suspend()
        end,
        bindings = {
            -- Category axis (triggers rebuild). Outermost hierarchy level,
            -- so top of the modifier ladder.
            bind(Keys.VK_NEXT, MOD_CTRL, cycle(ScannerNav.cycleCategory, 1), "Next category"),
            bind(Keys.VK_PRIOR, MOD_CTRL, cycle(ScannerNav.cycleCategory, -1), "Previous category"),
            -- Subcategory axis.
            bind(Keys.VK_NEXT, MOD_SHIFT, cycle(ScannerNav.cycleSubcategory, 1), "Next subcategory"),
            bind(Keys.VK_PRIOR, MOD_SHIFT, cycle(ScannerNav.cycleSubcategory, -1), "Previous subcategory"),
            -- Item axis (no modifier). Overrides the base game's
            -- world-camera zoom, which has no value to blind players.
            bind(Keys.VK_NEXT, MOD_NONE, cycle(ScannerNav.cycleItem, 1), "Next item"),
            bind(Keys.VK_PRIOR, MOD_NONE, cycle(ScannerNav.cycleItem, -1), "Previous item"),
            -- Instance axis (innermost hierarchy level).
            bind(Keys.VK_NEXT, MOD_ALT, cycle(ScannerNav.cycleInstance, 1), "Next instance"),
            bind(Keys.VK_PRIOR, MOD_ALT, cycle(ScannerNav.cycleInstance, -1), "Previous instance"),
            -- Single-purpose keys.
            bind(Keys.VK_HOME, MOD_NONE, call(ScannerNav.jumpToEntry), "Jump cursor to entry"),
            bind(Keys.VK_END, MOD_NONE, call(ScannerNav.distanceFromCursor), "Distance from cursor to entry"),
            bind(Keys.VK_END, MOD_SHIFT, call(ScannerNav.toggleAutoMove), "Toggle auto-move cursor"),
            bind(Keys.F, MOD_CTRL, call(ScannerNav.openSearch), "Search scanner entries"),
            bind(Keys.VK_BACK, MOD_NONE, call(ScannerNav.returnToPreJump), "Return to pre-jump cell"),
        },
        -- Empty on purpose: BaselineHandler surfaces the scanner keys from
        -- HELP_ENTRIES above so they land between the surveyor and
        -- function-keys sections of the map-mode help list.
        helpEntries = {},
    }
    return h
end

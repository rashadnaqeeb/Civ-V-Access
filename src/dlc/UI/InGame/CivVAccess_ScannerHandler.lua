-- Scanner handler. Sits directly above Baseline on the HandlerStack;
-- capturesAllInput=false so unbound keys (Q/A/S/W/X/... cursor cluster)
-- fall through to Baseline unchanged. Every binding here is an engine-
-- overriding choice documented in docs/hotkey-reference.md and listed
-- in the design doc section 6 rationale column.

ScannerHandler = {}

local MOD_NONE  = 0
local MOD_SHIFT = 1
local MOD_CTRL  = 2
local MOD_ALT   = 4

local function speak(s)
    if s == nil or s == "" then return end
    SpeechPipeline.speakInterrupt(s)
end

local function bind(key, mods, fn, description)
    return { key = key, mods = mods, fn = fn, description = description }
end

local function cycle(entryPoint, dir)
    return function() speak(entryPoint(dir)) end
end

local function call(entryPoint)
    return function() speak(entryPoint()) end
end

function ScannerHandler.create()
    local h = {
        name             = "Scanner",
        capturesAllInput = false,
        bindings = {
            -- Item axis (no modifier). Overrides the base game's
            -- world-camera zoom, which has no value to blind players.
            bind(Keys.VK_PRIOR, MOD_NONE,               cycle(ScannerNav.cycleItem,         1),  "Next item"),
            bind(Keys.VK_NEXT,  MOD_NONE,               cycle(ScannerNav.cycleItem,        -1),  "Previous item"),
            -- Subcategory axis.
            bind(Keys.VK_PRIOR, MOD_SHIFT,              cycle(ScannerNav.cycleSubcategory,  1),  "Next subcategory"),
            bind(Keys.VK_NEXT,  MOD_SHIFT,              cycle(ScannerNav.cycleSubcategory, -1),  "Previous subcategory"),
            -- Category axis (triggers rebuild).
            bind(Keys.VK_PRIOR, MOD_CTRL,               cycle(ScannerNav.cycleCategory,     1),  "Next category"),
            bind(Keys.VK_NEXT,  MOD_CTRL,               cycle(ScannerNav.cycleCategory,    -1),  "Previous category"),
            -- Instance axis.
            bind(Keys.VK_PRIOR, MOD_ALT,                cycle(ScannerNav.cycleInstance,     1),  "Next instance"),
            bind(Keys.VK_NEXT,  MOD_ALT,                cycle(ScannerNav.cycleInstance,    -1),  "Previous instance"),
            -- Single-purpose keys.
            bind(Keys.VK_HOME,  MOD_NONE,  call(ScannerNav.jumpToEntry),         "Jump cursor to entry"),
            bind(Keys.VK_END,   MOD_NONE,  call(ScannerNav.distanceFromCursor), "Distance from cursor to entry"),
            bind(Keys.VK_END,   MOD_SHIFT, call(ScannerNav.toggleAutoMove),     "Toggle auto-move cursor"),
            bind(Keys.F,        MOD_CTRL,  call(ScannerNav.openSearch),         "Search scanner entries"),
            bind(Keys.VK_BACK,  MOD_NONE,  call(ScannerNav.returnToPreJump),    "Return to pre-jump cell"),
        },
        helpEntries = {
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_AUTO_MOVE",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_AUTO_MOVE" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH" },
            { keyLabel   = "TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN",
              description = "TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN" },
        },
    }
    return h
end

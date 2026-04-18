-- Help overlay. Ported from ONI Access OniAccess/Handlers/HelpHandler.cs.
-- Opens a navigable list of bindings reachable from the current handler
-- stack, built from each handler's authored helpEntries via
-- HandlerStack.collectHelpEntries. Dedupe by keyLabel means stacked handlers
-- with overlapping chords surface only the topmost handler's meaning --
-- which matches what the chord actually does in that context.
--
-- The help handler is itself a BaseMenu-created handler: Up/Down navigate,
-- Home/End jump, type-ahead search works, ?/Esc close. Each entry is a
-- non-activatable Button whose label is "keyLabel: description".

Help = {}

-- Entries describing how to navigate the help list itself. Authored rather
-- than derived from Help's own bindings because (a) the chord merging
-- convention ("Up/Down") doesn't survive a per-binding auto-derivation and
-- (b) these are the entries a user sees every time they hit ?, so they
-- deserve a short, curated list.
local HELP_SELF_ENTRIES = {
    { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_AZ09",
      description = "TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH" },
    { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN",
      description = "TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS" },
    { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END",
      description = "TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST" },
    { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC",
      description = "TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE" },
    { keyLabel   = "TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION",
      description = "TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE" },
}

local function resolveEntryLabel(entry)
    local keyLabel    = Text.key(entry.keyLabel)
    local description = Text.key(entry.description)
    return Text.format("TXT_KEY_CIVVACCESS_HELP_ENTRY", keyLabel, description)
end

local function buildItems(entries)
    local items = {}
    for _, e in ipairs(entries) do
        items[#items + 1] = BaseMenuItems.Text({
            labelText = resolveEntryLabel(e),
        })
    end
    return items
end

-- Open the help overlay. Collects entries from the current stack before
-- pushing, so the Help handler itself doesn't mask the list it's about to
-- render. Idempotent-adjacent: the ? hotkey in InputRouter skips re-entry
-- when Help is already on top, so callers don't need to guard.
function Help.open()
    local entries = HandlerStack.collectHelpEntries()
    local handler = BaseMenu.create({
        name             = "Help",
        displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_HELP"),
        items            = buildItems(entries),
        capturesAllInput = true,
        escapePops       = true,
    })

    -- BaseMenu.create auto-populates helpEntries from its own bindings.
    -- Help's entries are about navigating the help list, not about the
    -- BaseMenu chord menu, so replace them with the curated self-list.
    handler.helpEntries = HELP_SELF_ENTRIES

    -- ? while Help is on top closes help. InputRouter's pre-walk ? check
    -- bails when top.name == "Help" so this binding gets a chance to fire.
    -- Windows VK for '/?' is 191; mods bit 1 is Shift (see InputRouter).
    handler.bindings[#handler.bindings + 1] = {
        key = 191, mods = 1, description = "Close help",
        fn  = function() HandlerStack.removeByName("Help", true) end,
    }

    HandlerStack.push(handler)
end

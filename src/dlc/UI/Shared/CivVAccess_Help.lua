-- Help overlay. Opens a navigable list of bindings reachable from the
-- current handler stack, built from each handler's authored helpEntries
-- via HandlerStack.collectHelpEntries. Dedupe by keyLabel means stacked
-- handlers with overlapping chords surface only the topmost handler's
-- meaning -- which matches what the chord actually does in that context.
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
    { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_AZ09", description = "TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH" },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST",
    },
    { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC", description = "TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE" },
    { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION", description = "TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE" },
}

-- External links surfaced under the "More Help" group. Plain string data,
-- not spoken text, so they live as constants rather than TXT_KEY lookups;
-- the spoken labels are the group's button text keys.
local README_URL = "https://github.com/rashadnaqeeb/Civ-V-Access/blob/main/README.md"
local DISCORD_URL = "https://discord.gg/JQQh5j7pFb"

local function resolveEntryLabel(entry)
    local keyLabel = Text.key(entry.keyLabel)
    local description = Text.key(entry.description)
    return Text.format("TXT_KEY_CIVVACCESS_HELP_ENTRY", keyLabel, description)
end

-- Open url in the system browser via the proxy's browser binding. Both
-- failure modes -- the binding absent on a stale proxy, or ShellExecute
-- refusing the launch -- raise, so the Text item's activate pcall logs
-- them and withholds the click ack. A blind user must not hear the success
-- cue when nothing opened.
local function openURL(url)
    Log.check(
        type(browser) == "table" and type(browser.open) == "function",
        "Help.openURL: proxy browser binding missing"
    )
    if not browser.open(url) then
        error("Help.openURL: browser.open refused " .. url)
    end
end

-- Always-present group at the bottom of the help list linking to the mod's
-- documentation and community. Reachable from every Context the help
-- overlay opens in, so it assumes no in-game state.
local function moreHelpGroup()
    return BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_HELP_GROUP_MORE",
        items = {
            BaseMenuItems.Text({
                textKey = "TXT_KEY_CIVVACCESS_HELP_OPEN_README",
                onActivate = function()
                    openURL(README_URL)
                end,
            }),
            BaseMenuItems.Text({
                textKey = "TXT_KEY_CIVVACCESS_HELP_OPEN_DISCORD",
                onActivate = function()
                    openURL(DISCORD_URL)
                end,
            }),
        },
    })
end

local function buildItems(entries)
    local items = {}
    for _, e in ipairs(entries) do
        items[#items + 1] = BaseMenuItems.Text({
            labelText = resolveEntryLabel(e),
        })
    end
    items[#items + 1] = moreHelpGroup()
    return items
end

-- Open the help overlay. Collects entries from the current stack before
-- pushing, so the Help handler itself doesn't mask the list it's about to
-- render. Idempotent-adjacent: the ? hotkey in InputRouter skips re-entry
-- when Help is already on top, so callers don't need to guard.
function Help.open()
    local entries = HandlerStack.collectHelpEntries()
    local handler = BaseMenu.create({
        name = "Help",
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_HELP"),
        items = buildItems(entries),
        capturesAllInput = true,
        escapePops = true,
    })

    -- BaseMenu.create auto-populates helpEntries from its own bindings.
    -- Help's entries are about navigating the help list, not about the
    -- BaseMenu chord menu, so replace them with the curated self-list.
    handler.helpEntries = HELP_SELF_ENTRIES

    -- ? while Help is on top closes help. InputRouter's pre-walk ? check
    -- bails when top.name == "Help" so this binding gets a chance to fire.
    -- Windows VK for '/?' is 191; mods bit 1 is Shift (see InputRouter).
    handler.bindings[#handler.bindings + 1] = {
        key = 191,
        mods = 1,
        description = "Close help",
        fn = function()
            HandlerStack.removeByName("Help", true)
        end,
    }

    HandlerStack.push(handler)
end

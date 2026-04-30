-- Authored help-entry templates for the BaseMenu container and a composer
-- that assembles a per-screen list by consulting the spec. Each template is
-- a list of {keyLabel, description} TXT_KEY pairs describing one binding that
-- BaseMenu.create wires up. Direction-paired bindings collapse into a single
-- human label ("Up/Down") so the dedupe in HandlerStack.collectHelpEntries
-- can drop equivalent entries from stacked handlers.

BaseMenuHelp = {}

BaseMenuHelp.MenuHelpEntries = {
    { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_AZ09", description = "TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH" },
}

BaseMenuHelp.ListNavHelpEntries = {
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG",
    },
}

BaseMenuHelp.NestedNavHelpEntries = {
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP",
    },
}

BaseMenuHelp.TabbedHelpEntries = {
    { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_TAB", description = "TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB" },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB",
    },
}

BaseMenuHelp.ReadHeaderHelpEntry = {
    keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F1",
    description = "TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER",
}

BaseMenuHelp.CivilopediaHelpEntry = {
    keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I",
    description = "TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA",
}

BaseMenuHelp.EscapePopsHelpEntry = {
    keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ESC",
    description = "TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL",
}

local function appendAll(dst, src)
    if type(src) ~= "table" then
        return
    end
    for _, e in ipairs(src) do
        dst[#dst + 1] = e
    end
end

-- Compose the authored help list for a BaseMenu-backed handler, reading the
-- spec to decide which templates apply. spec.helpExtras leads the list so a
-- screen's distinguishing chord (StagingRoom F2, TechTree F6, etc.) reads
-- before the universal nav/search entries it shares with every other menu.
function BaseMenuHelp.buildHelpEntries(spec)
    local list = {}
    appendAll(list, spec.helpExtras)
    appendAll(list, BaseMenuHelp.MenuHelpEntries)
    appendAll(list, BaseMenuHelp.ListNavHelpEntries)
    appendAll(list, BaseMenuHelp.NestedNavHelpEntries)
    if spec.tabs then
        appendAll(list, BaseMenuHelp.TabbedHelpEntries)
    end
    list[#list + 1] = BaseMenuHelp.ReadHeaderHelpEntry
    -- Gate the Civilopedia entry on Game's presence so FrontEnd menus
    -- (no pedia available) don't advertise a chord that no-ops. The
    -- binding in BaseMenu.create is similarly gated. (Events.X is not
    -- a usable gate -- the engine auto-creates event slots on access,
    -- so Events.SearchForPediaEntry is non-nil even in FrontEnd.)
    if Game ~= nil then
        list[#list + 1] = BaseMenuHelp.CivilopediaHelpEntry
    end
    if spec.escapePops then
        list[#list + 1] = BaseMenuHelp.EscapePopsHelpEntry
    end
    return list
end

-- Insert a screen-specific help entry at the top of the handler's help
-- list, after any previously inserted screen keys (and after spec.helpExtras
-- the handler was created with). For post-create wiring of "special keys"
-- that BaseMenu.create couldn't be told about because the binding is added
-- after the handler is built. Maintains insertion order across multiple
-- calls so two added keys read in the order they were added. BaseMenu.create
-- seeds handler._screenKeyCount with #spec.helpExtras so post-create
-- additions stack after the spec extras, not in front of them.
function BaseMenuHelp.addScreenKey(handler, entry)
    if handler.helpEntries == nil then
        handler.helpEntries = {}
    end
    local idx = (handler._screenKeyCount or 0) + 1
    handler._screenKeyCount = idx
    table.insert(handler.helpEntries, idx, entry)
end

return BaseMenuHelp

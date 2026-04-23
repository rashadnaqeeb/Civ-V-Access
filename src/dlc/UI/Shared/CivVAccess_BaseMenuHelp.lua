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
-- spec to decide which templates apply. spec.helpExtras appends handler-
-- specific extras at the tail (for the rare screen with a custom binding).
function BaseMenuHelp.buildHelpEntries(spec)
    local list = {}
    appendAll(list, BaseMenuHelp.MenuHelpEntries)
    appendAll(list, BaseMenuHelp.ListNavHelpEntries)
    appendAll(list, BaseMenuHelp.NestedNavHelpEntries)
    if spec.tabs then
        appendAll(list, BaseMenuHelp.TabbedHelpEntries)
    end
    list[#list + 1] = BaseMenuHelp.ReadHeaderHelpEntry
    -- Gate the Civilopedia entry on the event's presence so FrontEnd
    -- menus (no pedia available) don't advertise a chord that no-ops.
    -- The binding in BaseMenu.create is similarly gated.
    if Events ~= nil and Events.SearchForPediaEntry ~= nil then
        list[#list + 1] = BaseMenuHelp.CivilopediaHelpEntry
    end
    if spec.escapePops then
        list[#list + 1] = BaseMenuHelp.EscapePopsHelpEntry
    end
    appendAll(list, spec.helpExtras)
    return list
end

return BaseMenuHelp

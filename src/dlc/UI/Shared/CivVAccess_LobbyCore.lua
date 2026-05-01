-- Lobby data module. Two public fns:
--   Lobby.buildPickerItems(entryFactory, mainHandlerRef) - picker-tab items
--     for the current g_Listings (one Entry per server), followed by a
--     Sort-by Group over the five engine sort columns, an optional
--     Connect-to-IP textfield (pitboss-internet only), and shell-action
--     Choices for Refresh / Host / Back.
--   Lobby.buildReader(mainHandler, id) - reader-tab leaves for the server
--     identified by id: header fields, member list (one leaf per player),
--     hosted-DLC list, and a Join action.
--
-- g_Listings is populated by base's AddServer on MultiplayerGameListUpdated;
-- each row already carries ServerName, MembersLabelCaption / ToolTip, Map
-- type / size captions, and the DLC tooltip string. We read those directly
-- rather than re-deriving from serverEntry.
--
-- Never cache: every call re-reads g_Listings and the refresh-button label.
-- Sort state (g_SortOptions[i].CurrentDirection) changes under us when the
-- user toggles a sort; entry ids are the stable ServerID (stringified) so
-- PickerReader restores the cursor across SortAndDisplayListings rebuilds,
-- and sort rebuilds land the cursor on the same server.

Lobby = {}

-- --------------------------------------------------------------------------
-- Helpers

-- Decode "server:<id>" back into the ServerID. Returns nil on malformed
-- input (caller logs through its own path).
local function parseId(id)
    local idStr = string.match(id or "", "^server:(.+)$")
    if idStr == nil then
        return nil
    end
    return tonumber(idStr) or idStr
end

local function findListingById(serverID)
    for _, listing in ipairs(g_Listings) do
        if listing.ServerID == serverID then
            return listing
        end
    end
    return nil
end

-- Parse "X/Y" (base's MembersLabelCaption format) into two numbers. Returns
-- nils if the caption is missing or ill-formed; callers fall back to the
-- raw string.
local function parseMemberCounts(caption)
    if caption == nil then
        return nil, nil
    end
    local cur, max = string.match(caption, "^(%d+)/(%d+)$")
    if cur == nil then
        return nil, nil
    end
    return tonumber(cur), tonumber(max)
end

-- Speech-friendly member count. Base emits "3/6" which screen readers
-- announce as "three slash six"; we say "3 of 6" instead.
local function membersLabel(listing)
    local cur, max = parseMemberCounts(listing.MembersLabelCaption)
    if cur ~= nil then
        return Text.format("TXT_KEY_CIVVACCESS_LOBBY_MEMBERS", cur, max)
    end
    return listing.MembersLabelCaption or ""
end

-- Split the base's newline-joined player list back into individual names.
-- ParseServerPlayers (Lobby.lua line 500) replaces ", " separators with
-- the engine's [NEWLINE] token (literal bracketed string, not a control
-- character). Plain-text find is required so the bracket + word letters
-- aren't interpreted as a Lua character class. The trailing "@<id>" is
-- stripped per chunk because base's sighted-path only strips it from
-- names followed by [NEWLINE], leaving the last name's id intact — we
-- normalize so the user never hears "@5868795" read out.
local function playerNames(listing)
    local raw = listing.MembersLabelToolTip
    if raw == nil or raw == "" then
        return {}
    end
    local names = {}
    local start = 1
    while true do
        local a, b = string.find(raw, "[NEWLINE]", start, true)
        local chunk
        if a == nil then
            chunk = string.sub(raw, start)
        else
            chunk = string.sub(raw, start, a - 1)
        end
        local trimmed = chunk:match("^%s*(.-)%s*$")
        if trimmed ~= nil and trimmed ~= "" then
            trimmed = (trimmed:gsub("@%S+$", ""))
            if trimmed ~= "" then
                names[#names + 1] = trimmed
            end
        end
        if a == nil then
            break
        end
        start = b + 1
    end
    return names
end

local addField = SavedGameShared.addField

-- Live label for the Refresh choice. Mirrors base UpdateRefreshButton's
-- text toggle (Lobby.lua lines 157-164) by reading the currently-displayed
-- RefreshButtonLabel. Dynamic via labelFn so the user hears the current
-- state on every focus without a full rebuild.
local function refreshChoiceLabel()
    local l = Controls.RefreshButtonLabel
    if l ~= nil then
        local ok, t = pcall(function()
            return l:GetText()
        end)
        if ok and t ~= nil and t ~= "" then
            return tostring(t)
        end
    end
    return Text.key("TXT_KEY_MULTIPLAYER_REFRESH_GAME_LIST")
end

-- Direction tooltip for the currently-active sort Choice. Base tracks asc /
-- desc per column in g_SortOptions[i].CurrentDirection; nil means "not
-- this column's sort". Non-current choices return nil so they read bare.
local function sortDirectionTooltip(option)
    if option.CurrentDirection == "asc" then
        return Text.key("TXT_KEY_CIVVACCESS_LOBBY_SORT_ASC")
    elseif option.CurrentDirection == "desc" then
        return Text.key("TXT_KEY_CIVVACCESS_LOBBY_SORT_DESC")
    end
    return nil
end

-- --------------------------------------------------------------------------
-- Reader builder

function Lobby.buildReader(mainHandler, id)
    local serverID = parseId(id)
    if serverID == nil then
        Log.error("Lobby: unparseable entry id '" .. tostring(id) .. "'")
        return { items = {} }
    end

    local listing = findListingById(serverID)
    if listing == nil then
        Log.warn("Lobby: listing missing for id '" .. tostring(id) .. "'")
        return { items = {} }
    end

    local leaves = {}

    -- Header: server name, reaffirmed after switch-to-tab.
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = listing.ServerName or "",
    })

    addField(leaves, "TXT_KEY_AD_SETUP_MAP_TYPE", listing.MapTypeCaption)
    addField(leaves, "TXT_KEY_AD_SETUP_MAP_SIZE", listing.MapSizeCaption)
    addField(leaves, "TXT_KEY_MULTIPLAYER_MEMBERS", membersLabel(listing))

    -- Player list. Emit one leaf per name so arrow-navigation steps through
    -- the roster individually (the collapsed tooltip string would force the
    -- user to listen through every name on a single cursor land).
    for _, name in ipairs(playerNames(listing)) do
        leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = name })
    end

    -- Hosted-DLC block. listing.DLCHostedCaption is the Yes / No string;
    -- listing.DLCHostedToolTip is the pre-formatted "Required DLC: A, B, C"
    -- string built by base CreateDlcToolTip. [ICON_BULLET] + [NEWLINE]
    -- tokens are stripped / spaced by TextFilter on announce so the list
    -- reads cleanly without a custom parse here.
    addField(leaves, "TXT_KEY_MULTIPLAYER_DLCHOSTED", listing.DLCHostedCaption)
    if listing.DLCHostedToolTip ~= nil and listing.DLCHostedToolTip ~= "" then
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = listing.DLCHostedToolTip,
        })
    end

    -- Join action. Base gates join on "server selected" (two-click), but
    -- Matchmaking.JoinMultiplayerGame does not require that visual state;
    -- we call ServerListingButtonClick directly which wraps the join call.
    leaves[#leaves + 1] = BaseMenuItems.Choice({
        textKey = "TXT_KEY_MULTIPLAYER_JOIN_GAME",
        activate = function()
            ServerListingButtonClick(serverID)
        end,
    })

    return { items = leaves }
end

-- --------------------------------------------------------------------------
-- Picker builder

local function pickerLabel(listing)
    return Text.format(
        "TXT_KEY_CIVVACCESS_LOBBY_PICKER_ROW",
        listing.ServerName or "",
        membersLabel(listing),
        listing.MapTypeCaption or ""
    )
end

function Lobby.buildPickerItems(entryFactory, mainHandlerRef)
    local items = {}

    for _, listing in ipairs(g_Listings) do
        if listing.ServerID ~= nil then
            items[#items + 1] = entryFactory({
                id = "server:" .. tostring(listing.ServerID),
                labelText = pickerLabel(listing),
                tooltipText = listing.DLCHostedToolTip,
                buildReader = function(handler, id)
                    return Lobby.buildReader(mainHandlerRef(), id)
                end,
            })
        end
    end

    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            textKey = "TXT_KEY_CIVVACCESS_LOBBY_NO_SERVERS",
        })
    end

    -- Sort-by Group. One Choice per base sort column. selectedFn flags the
    -- column whose CurrentDirection is non-nil (base only keeps one active
    -- at a time, enforced by UpdateSortOptionState). Activating the active
    -- column toggles asc / desc; activating any other switches to it at
    -- default direction. Both paths delegate to base's SortOptionSelected
    -- which also calls SortAndDisplayListings — our monkey-patched wrapper
    -- rebuilds the picker afterward.
    local sortChoices = {}
    local sortSpecs = {
        { option = g_SortOptions[1], key = "TXT_KEY_MULTIPLAYER_SERVER_NAME" },
        { option = g_SortOptions[2], key = "TXT_KEY_AD_SETUP_MAP_TYPE" },
        { option = g_SortOptions[3], key = "TXT_KEY_AD_SETUP_MAP_SIZE" },
        { option = g_SortOptions[4], key = "TXT_KEY_MULTIPLAYER_MEMBERS" },
        { option = g_SortOptions[5], key = "TXT_KEY_MULTIPLAYER_DLCHOSTED" },
    }
    for _, spec in ipairs(sortSpecs) do
        local opt = spec.option
        if opt ~= nil then
            sortChoices[#sortChoices + 1] = BaseMenuItems.Choice({
                textKey = spec.key,
                tooltipFn = function()
                    return sortDirectionTooltip(opt)
                end,
                selectedFn = function()
                    return opt.CurrentDirection ~= nil
                end,
                activate = function()
                    SortOptionSelected(opt)
                end,
            })
        end
    end
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_LOAD_SORT_BY",
        items = sortChoices,
    })

    -- Connect-to-IP textfield. Visible only in pitboss-internet lobby mode
    -- (base ShowHide gates Controls.ConnectIPBox on that mode at line 643).
    -- priorCallback fires OnConnectIPEdit on commit; base registered the
    -- same handler on the raw EditBox, which our BaseMenuEditMode wraps.
    items[#items + 1] = BaseMenuItems.Textfield({
        controlName = "ConnectIPEdit",
        visibilityControlName = "ConnectIPBox",
        textKey = "TXT_KEY_MULTIPLAYER_CONNECT_TO_IP",
        tooltipKey = "TXT_KEY_MULTIPLAYER_CONNECT_TO_IP_TT",
        priorCallback = OnConnectIPEdit,
    })

    -- Refresh choice. Label flips between "Refresh Game List" and "Stop
    -- Refresh" per base's UpdateRefreshButton; read live via labelFn so
    -- the user hears current state without a rebuild.
    items[#items + 1] = BaseMenuItems.Choice({
        labelFn = refreshChoiceLabel,
        activate = function()
            RefreshButtonClick()
        end,
    })

    items[#items + 1] = BaseMenuItems.Choice({
        textKey = "TXT_KEY_MULTIPLAYER_HOST_GAME",
        tooltipKey = "TXT_KEY_MULTIPLAYER_HOST_GAME_TT",
        activate = function()
            HostButtonClick()
        end,
    })

    items[#items + 1] = BaseMenuItems.Choice({
        textKey = "TXT_KEY_BACK_BUTTON",
        activate = function()
            BackButtonClick()
        end,
    })

    return items
end

return Lobby

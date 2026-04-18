-- InstalledPanel data module. Two public fns:
--   InstalledPanel.buildPickerItems(entryFactory, handlerRefThunk) - picker-
--     tab items for the current g_SortedMods (one Entry per installed mod
--     that can be activated; Text leaves for download / install progress
--     rows which cannot), followed by Sort-by and Options tail groups.
--   InstalledPanel.buildReader(handlerRef, id) - reader-tab leaves for the
--     mod identified by id: header fields (version, author, supports-SP/MP,
--     affects saves, updated, description), dependency / reference / blocker
--     bullets, and the action leaves (Enable or Disable gated on state,
--     Update when NeedsUpdate, Delete or Unsubscribe gated on ownership).
--
-- Why not query Modding.GetInstalledModDetails during picker build: details
-- are per-mod disk reads and the user only needs them for the row they
-- actually open. Matches base-game UI's lazy-read pattern and keeps the
-- picker responsive with large mod counts.
--
-- Never cache: every buildReader call re-queries GetInstalledModDetails +
-- CanEnableMod + CanUnsubscribeMod + CanDeleteMod. A mod's enable state
-- can change under us (dependent mod disabled, DLC toggled) and stale
-- speech on a write-path action is how bad things happen silently.
--
-- Entry ids encode ModId + Version because row indices in g_SortedMods
-- shift when the engine inserts downloading / installing placeholders at
-- the head on OnUpdate ticks. Stable identity also lets PickerReader
-- restore the cursor across RefreshMods rebuilds.
--
-- The visual DeleteConfirm / OptionsPopup modals are bypassed: the base
-- modals assume a sighted user who can read the effected-mods list on
-- screen; we build speech-friendly Yes/No subs that read the same data.
--
-- Reader tab is always index 2 per PickerReader's install; hardcoded here
-- because the session internals aren't exposed.

InstalledPanel = {}

local READER_TAB_IDX = 2

-- Parallel to base InstalledPanel.lua's tooltips[] table (the indices are
-- set by Modding.CanEnableMod). 0 means the mod can be enabled; any other
-- value picks a reason key. When Enable is blocked, the reader surfaces the
-- reason as a Text leaf rather than offering a disabled action.
local CAN_ENABLE_REASON = {
    [1] = "TXT_KEY_MODDING_MOD_BLOCKED_BY_OTHER_MOD",
    [2] = "TXT_KEY_MODDING_MOD_VERSION_ALREADY_ENABLED",
    [3] = "TXT_KEY_MODDING_MOD_MISSING_DEPENDENCIES",
    [4] = "TXT_KEY_MODDING_MOD_HAS_EXCLUSIVITY_CONFLICTS",
    [5] = "TXT_KEY_MODDING_MOD_BAD_GAMEVERSION",
}

-- --------------------------------------------------------------------------
-- Helpers

-- Decode "mod:<id>:<version>" back to (modId, versionNumber). The ModId
-- itself may contain colons for some Steam Workshop mods, so split from
-- the right: last colon separates version, everything before is id.
local function parseId(id)
    if id == nil or string.sub(id, 1, 4) ~= "mod:" then return nil, nil end
    local body = string.sub(id, 5)
    local lastColon = body:match("^.*()(:)")
    if lastColon == nil then return nil, nil end
    local modId   = body:sub(1, lastColon - 1)
    local version = tonumber(body:sub(lastColon + 1))
    if modId == "" or version == nil then return nil, nil end
    return modId, version
end

-- Look up the g_SortedMods row by stable id (ModId + Version). Returns nil
-- on miss (row may have been deleted or hidden between picker build and
-- reader activation).
local function findRowById(modId, version)
    for _, row in ipairs(g_SortedMods) do
        if row.ModId == modId and row.Version == version then
            return row
        end
    end
    return nil
end

-- Call Modding.CanEnableMod on a single mod. Returns 0 when enable is
-- allowed, otherwise the reason index into CAN_ENABLE_REASON. Pcall-wrapped
-- because the engine API occasionally throws on malformed input in the wild.
local function canEnableReason(modId, version)
    local ok, result = pcall(function()
        return Modding.CanEnableMod({{ modId, version }})
    end)
    if not ok then
        Log.warn("InstalledPanel: CanEnableMod failed for '"
            .. tostring(modId) .. "' v" .. tostring(version)
            .. ": " .. tostring(result))
        return 0
    end
    if type(result) ~= "table" or result[1] == nil then return 0 end
    return result[1]
end

local function addField(leaves, headerKey, value)
    if value == nil or value == "" then return end
    local prefix = ""
    if headerKey ~= nil and headerKey ~= "" then
        prefix = Text.key(headerKey) .. ": "
    end
    leaves[#leaves + 1] = BaseMenuItems.Text({ labelText = prefix .. value })
end

local function yesNoLabel(value)
    if value == "1" then return Text.key("TXT_KEY_MODDING_LABELYES") end
    return Text.key("TXT_KEY_MODDING_LABELNO")
end

-- Strip the engine's "[ICON_BULLET] " prefix from a dependency message.
-- The TextFilter substitutes bullet tokens with spoken text, but a leading
-- bullet carries no information in speech and just adds "bullet" noise
-- before every dependency item.
local function stripBullet(text)
    if text == nil then return "" end
    local stripped = string.gsub(text, "^%s*%[ICON_BULLET%]%s*", "")
    return stripped
end

-- Build dependency / reference / blocker bullets for a mod. Mirrors the
-- body of base ShowInstalledModDetails (lines 623-733) but emits Text
-- leaves instead of writing to the hidden g_DetailsDependentMods stack.
local function dependencyBullets(leaves, modId, version, modDetails)
    local count = 0

    local function add(tmplKey, title)
        if title == nil or title == "" then return end
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.format(tmplKey, title),
        })
        count = count + 1
    end

    if modDetails.Exclusivity == "1" then
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_MODDING_MOD_PARTIALLY_EXCLUSIVE"),
        })
        count = count + 1
    elseif modDetails.Exclusivity == "2" then
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_MODDING_MOD_EXCLUSIVE"),
        })
        count = count + 1
    end

    local modAssoc         = Modding.GetModAssociations(modId, version)
    local dlcAssoc         = Modding.GetDlcAssociations(modId, version)
    local gameVersionAssoc = Modding.GetGameVersionAssociations(modId, version)

    -- Drop the CivVAccess DLC's own GUID from the dependency list so the
    -- user doesn't hear "depends on Civ V Access" for every installed mod.
    for i = #dlcAssoc, 1, -1 do
        if dlcAssoc[i].PackageID == "8871E748-29A4-4910-8C57-8C99E32D0167" then
            table.remove(dlcAssoc, i)
        end
    end

    local function dlcTitleOf(v)
        if v.PackageID == "*" then
            return Text.key("TXT_KEY_MODDING_BLOCKS_ALL_OTHER_DLC")
        end
        local pkg = string.gsub(v.PackageID, "-", "")
        pkg = Locale.ToUpper(pkg)
        return Text.key("TXT_KEY_" .. pkg .. "_DESCRIPTION")
    end

    -- Dependencies (Type == 2).
    for _, v in ipairs(modAssoc) do
        if v.Type == 2 then
            local title = Text.format(
                "TXT_KEY_CIVVACCESS_MODS_VERSION_RANGE",
                v.ModTitle, v.MinVersion, v.MaxVersion)
            add("TXT_KEY_MODDING_DEPENDSON", title)
        end
    end
    for _, v in ipairs(dlcAssoc) do
        if v.Type == 2 then
            add("TXT_KEY_MODDING_DEPENDSON", dlcTitleOf(v))
        end
    end
    for _, v in ipairs(gameVersionAssoc) do
        if v.Type == 2 then
            local title = Text.format(
                "TXT_KEY_MODDING_GAMEVERSION", v.MinVersion, v.MaxVersion)
            add("TXT_KEY_MODDING_DEPENDSON", title)
        end
    end

    -- References (Type == 1).
    for _, v in ipairs(modAssoc) do
        if v.Type == 1 then
            local title = Text.format(
                "TXT_KEY_CIVVACCESS_MODS_VERSION_RANGE",
                v.ModTitle, v.MinVersion, v.MaxVersion)
            add("TXT_KEY_MODDING_REFERENCES", title)
        end
    end
    for _, v in ipairs(dlcAssoc) do
        if v.Type == 1 then
            add("TXT_KEY_MODDING_REFERENCES", dlcTitleOf(v))
        end
    end
    for _, v in ipairs(gameVersionAssoc) do
        if v.Type == 1 then
            local title = Text.format(
                "TXT_KEY_MODDING_GAMEVERSION", v.MinVersion, v.MaxVersion)
            add("TXT_KEY_MODDING_REFERENCES", title)
        end
    end

    -- Blockers (Type == -1).
    for _, v in ipairs(modAssoc) do
        if v.Type == -1 then
            local title = Text.format(
                "TXT_KEY_CIVVACCESS_MODS_VERSION_RANGE",
                v.ModTitle, v.MinVersion, v.MaxVersion)
            add("TXT_KEY_MODDING_BLOCKS", title)
        end
    end
    for _, v in ipairs(dlcAssoc) do
        if v.Type == -1 then
            add("TXT_KEY_MODDING_BLOCKS", dlcTitleOf(v))
        end
    end
    for _, v in ipairs(gameVersionAssoc) do
        if v.Type == -1 then
            local title = Text.format(
                "TXT_KEY_MODDING_GAMEVERSION", v.MinVersion, v.MaxVersion)
            add("TXT_KEY_MODDING_BLOCKS", title)
        end
    end

    if count == 0 then
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_MODDING_NOASSOCIATIONS"),
        })
    end
end

-- Speech-friendly Disable confirmation for the "also disables N other mods"
-- case. Mirrors the body of base DisableMod (lines 346-400) but skips the
-- visual modal. Lists the effected mods as informational leaves before the
-- Yes / No choice so the user knows what they're committing to.
local function pushDisableConfirmSub(mainHandler, modId, version, dependents)
    local displayName = Modding.GetModProperty(modId, version, "Name")
        or tostring(modId)
    local confirmLabel = Text.format(
        "TXT_KEY_CIVVACCESS_MODS_DISABLE_CONFIRM", displayName)
    local subName = mainHandler.name .. "/DisableConfirm"
    local items = {
        BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_WILL_ALSO_DISABLE_MODS"),
        }),
    }
    for _, dep in ipairs(dependents) do
        if dep.ModID ~= modId then
            local depName = Modding.GetModProperty(dep.ModID, dep.Version, "Name")
                or tostring(dep.ModID)
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format(
                    "TXT_KEY_CIVVACCESS_MODS_VERSION_SUFFIX",
                    depName, dep.Version),
            })
        end
    end
    -- No first so arrow-down to Yes is an explicit affirmative step.
    items[#items + 1] = BaseMenuItems.Choice({
        textKey  = "TXT_KEY_NO_BUTTON",
        activate = function()
            HandlerStack.removeByName(subName, true)
        end,
    })
    items[#items + 1] = BaseMenuItems.Choice({
        textKey  = "TXT_KEY_YES_BUTTON",
        activate = function()
            for _, dep in ipairs(dependents) do
                Modding.DisableMod(dep.ModID, dep.Version)
            end
            RefreshMods()
            HandlerStack.removeByName(subName, true)
        end,
    })
    local sub = BaseMenu.create({
        name        = subName,
        displayName = confirmLabel,
        items       = items,
        escapePops  = true,
    })
    HandlerStack.push(sub)
end

-- Speech-friendly Delete confirmation. Offers "Delete" (and "Delete with
-- user data" when the mod has user data) as distinct Yes paths so the user
-- commits to a specific action rather than toggling a checkbox + Yes.
local function pushDeleteConfirmSub(mainHandler, modId, version, displayName)
    local hasUserData = Modding.HasUserData(modId, version)
    local subName     = mainHandler.name .. "/DeleteConfirm"
    local confirmLabel = Text.format(
        "TXT_KEY_CIVVACCESS_MODS_DELETE_CONFIRM", displayName)

    local items = {
        BaseMenuItems.Choice({
            textKey  = "TXT_KEY_NO_BUTTON",
            activate = function()
                HandlerStack.removeByName(subName, true)
            end,
        }),
        BaseMenuItems.Choice({
            textKey  = "TXT_KEY_YES_BUTTON",
            activate = function()
                Modding.DeleteMod(modId, version)
                RefreshMods()
                HandlerStack.removeByName(subName, true)
                mainHandler.setItems({
                    BaseMenuItems.Text({
                        textKey = "TXT_KEY_CIVVACCESS_MODS_DELETED" }),
                }, READER_TAB_IDX)
            end,
        }),
    }
    if hasUserData then
        items[#items + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_CIVVACCESS_MODS_DELETE_WITH_USER_DATA",
            activate = function()
                Modding.DeleteMod(modId, version)
                Modding.DeleteUserData(modId, version)
                RefreshMods()
                HandlerStack.removeByName(subName, true)
                mainHandler.setItems({
                    BaseMenuItems.Text({
                        textKey = "TXT_KEY_CIVVACCESS_MODS_DELETED" }),
                }, READER_TAB_IDX)
            end,
        })
    end

    local sub = BaseMenu.create({
        name        = subName,
        displayName = confirmLabel,
        items       = items,
        escapePops  = true,
    })
    HandlerStack.push(sub)
end

local function pushUnsubscribeConfirmSub(mainHandler, modId, version, displayName)
    local subName = mainHandler.name .. "/UnsubscribeConfirm"
    local confirmLabel = Text.format(
        "TXT_KEY_CIVVACCESS_MODS_UNSUBSCRIBE_CONFIRM", displayName)
    local sub = BaseMenu.create({
        name        = subName,
        displayName = confirmLabel,
        preamble    = Text.key("TXT_KEY_MODDING_UNSUBSCRIBE_CONFIRM"),
        items = {
            BaseMenuItems.Choice({
                textKey  = "TXT_KEY_NO_BUTTON",
                activate = function()
                    HandlerStack.removeByName(subName, true)
                end,
            }),
            BaseMenuItems.Choice({
                textKey  = "TXT_KEY_YES_BUTTON",
                activate = function()
                    Modding.UnsubscribeMod(modId, version)
                    RefreshMods()
                    HandlerStack.removeByName(subName, true)
                    mainHandler.setItems({
                        BaseMenuItems.Text({
                            textKey = "TXT_KEY_CIVVACCESS_MODS_DELETED" }),
                    }, READER_TAB_IDX)
                end,
            }),
        },
        escapePops = true,
    })
    HandlerStack.push(sub)
end

-- --------------------------------------------------------------------------
-- Reader builder

function InstalledPanel.buildReader(mainHandler, id)
    local modId, version = parseId(id)
    if modId == nil then
        Log.error("InstalledPanel: unparseable entry id '" .. tostring(id) .. "'")
        return { items = {} }
    end

    local row = findRowById(modId, version)
    if row == nil then
        Log.warn("InstalledPanel: row missing for '" .. modId .. "' v"
            .. tostring(version))
        return { items = {} }
    end

    local ok, modDetails = pcall(function()
        return Modding.GetInstalledModDetails(modId, version)
    end)
    if not ok or modDetails == nil then
        Log.warn("InstalledPanel: GetInstalledModDetails failed for '"
            .. modId .. "' v" .. tostring(version)
            .. ": " .. tostring(modDetails))
        return { items = {} }
    end

    local leaves = {}

    -- Header: name (already in the picker label too, but the reader tab's
    -- article title is what the user just heard on switch; this line gives
    -- a quick re-confirm on cursor land), then ID for disambiguation when
    -- two mods share a name.
    leaves[#leaves + 1] = BaseMenuItems.Text({
        labelText = modDetails.Name or row.DisplayName or "",
    })

    -- Version (optionally with stability suffix, per base line 585-586).
    local versionStr = tostring(version)
    if modDetails.Stability ~= nil and modDetails.Stability ~= "" then
        versionStr = versionStr .. " - " .. modDetails.Stability
    end
    addField(leaves, "TXT_KEY_MODDING_LABELVERSION", versionStr)
    addField(leaves, "TXT_KEY_MODDING_LABELAUTHOR", modDetails.Authors)
    addField(leaves, "TXT_KEY_MODDING_LABELSPECIALTHANKS",
        modDetails.SpecialThanks)
    addField(leaves, "TXT_KEY_MODDING_LABELSUPPORTSSINGLEPLAYER",
        yesNoLabel(modDetails.SupportsSinglePlayer))
    addField(leaves, "TXT_KEY_MODDING_LABELSUPPORTSMULTIPLAYER",
        yesNoLabel(modDetails.SupportsMultiplayer))
    addField(leaves, "TXT_KEY_MODDING_LABELAFFECTSSAVEDGAMES",
        yesNoLabel(modDetails.AffectsSavedGames))
    addField(leaves, "TXT_KEY_MODDING_LABELUPDATED", modDetails.Updated)

    if modDetails.Description ~= nil and modDetails.Description ~= "" then
        leaves[#leaves + 1] = BaseMenuItems.Text({
            labelText = modDetails.Description,
        })
    end

    dependencyBullets(leaves, modId, version, modDetails)

    -- Current enable state announced as a field so the user knows before
    -- activating Enable / Disable (both actions appear below; only the
    -- relevant one is activatable).
    addField(leaves, "TXT_KEY_CIVVACCESS_MODS_STATE",
        Text.key(row.Enabled and "TXT_KEY_CIVVACCESS_MODS_STATE_ENABLED"
                              or "TXT_KEY_CIVVACCESS_MODS_STATE_DISABLED"))

    -- Action leaves.
    if row.Enabled then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_MODDING_DISABLEMOD",
            activate = function()
                local deps = Modding.GetModsRequiredToDisableMod(modId, version)
                if deps ~= nil and #deps > 1 then
                    pushDisableConfirmSub(mainHandler, modId, version, deps)
                else
                    Modding.DisableMod(modId, version)
                    RefreshMods()
                end
            end,
        })
    else
        local reason = canEnableReason(modId, version)
        if reason == 0 then
            leaves[#leaves + 1] = BaseMenuItems.Choice({
                textKey  = "TXT_KEY_MODDING_ENABLEMOD",
                activate = function()
                    EnableMod(modId, version)
                end,
            })
        else
            leaves[#leaves + 1] = BaseMenuItems.Text({
                labelText = Text.format(
                    "TXT_KEY_CIVVACCESS_MODS_ENABLE_BLOCKED",
                    Text.key(CAN_ENABLE_REASON[reason]
                        or "TXT_KEY_MODDING_MOD_BLOCKED_BY_OTHER_MOD")),
            })
        end
    end

    if row.State == "NeedsUpdate" then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_MODDING_UPDATEMOD",
            activate = function()
                Modding.UpdateMod(modId, version)
                RefreshMods()
            end,
        })
    end

    local displayName = modDetails.Name or row.DisplayName or ""
    if Modding.CanUnsubscribeMod(modId, version) then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_MODDING_UNSUBSCRIBE_MOD",
            activate = function()
                pushUnsubscribeConfirmSub(mainHandler, modId, version, displayName)
            end,
        })
    elseif Modding.CanDeleteMod(modId, version) then
        leaves[#leaves + 1] = BaseMenuItems.Choice({
            textKey  = "TXT_KEY_MODDING_DELETEMOD",
            activate = function()
                pushDeleteConfirmSub(mainHandler, modId, version, displayName)
            end,
        })
    end

    return { items = leaves }
end

-- --------------------------------------------------------------------------
-- Picker builder

-- Build one picker label from a g_SortedMods row. Regular entries include
-- the enable-state suffix ("enabled" / "disabled") so the user can tell at
-- a glance which mods are active without opening each one. Downloading /
-- installing rows use the engine's Teaser string (localized progress text).
local function pickerLabel(row)
    if row.State == "Installed" or row.State == "NeedsUpdate" then
        local stateLabel = Text.key(row.Enabled
            and "TXT_KEY_CIVVACCESS_MODS_STATE_ENABLED"
            or  "TXT_KEY_CIVVACCESS_MODS_STATE_DISABLED")
        if row.State == "NeedsUpdate" then
            return Text.format("TXT_KEY_CIVVACCESS_MODS_PICKER_NEEDS_UPDATE",
                row.DisplayName, stateLabel)
        end
        return Text.format("TXT_KEY_CIVVACCESS_MODS_PICKER_ROW",
            row.DisplayName, stateLabel)
    end
    if row.Teaser ~= nil and row.Teaser ~= "" then
        return row.DisplayName .. ": " .. row.Teaser
    end
    return row.DisplayName
end

function InstalledPanel.buildPickerItems(entryFactory, mainHandlerRef)
    local items = {}

    for _, row in ipairs(g_SortedMods) do
        if (row.State == "Installed" or row.State == "NeedsUpdate")
                and row.ModId ~= nil and row.Version ~= nil then
            items[#items + 1] = entryFactory({
                id          = "mod:" .. row.ModId .. ":" .. tostring(row.Version),
                labelText   = pickerLabel(row),
                buildReader = function(handler, id)
                    return InstalledPanel.buildReader(mainHandlerRef(), id)
                end,
            })
        else
            -- Downloading / Installing rows are informational only; base
            -- clears their Mouse.eLClick callback (InstalledPanel.lua line
            -- 246) and we mirror that by not making them activatable.
            items[#items + 1] = BaseMenuItems.Text({
                labelText = pickerLabel(row),
            })
        end
    end

    if #items == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            textKey = "TXT_KEY_CIVVACCESS_MODS_NO_MODS",
        })
    end

    -- Sort-by Group. Base sort buttons live on Controls.SortbyName /
    -- SortByEnabled and call the global SortListingsBy(option) which
    -- toggles asc/desc on repeat-click. Our Choices do the same by calling
    -- it directly; selectedFn flags the current sort column for the user.
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_MODS_SORT_BY",
        items = {
            BaseMenuItems.Choice({
                textKey    = "TXT_KEY_MODDING_SORT_TITLE",
                selectedFn = function()
                    return g_CurrentSortOption == "Name"
                end,
                activate = function() SortListingsBy("Name") end,
            }),
            BaseMenuItems.Choice({
                textKey    = "TXT_KEY_MODDING_SORT_ENABLED",
                selectedFn = function()
                    return g_CurrentSortOption == "Enabled"
                end,
                activate = function() SortListingsBy("Enabled") end,
            }),
        },
    })

    -- Options Group. ShowDLCMods is the only user-facing option. The base
    -- OK button fires RefreshMods, which our monkey-patched wrapper
    -- re-runs our setItems rebuild -- we trigger the same effect via a
    -- dedicated Choice so the user can apply without digging for the OK
    -- button location. The checkbox's RegisterCheckHandler is captured by
    -- ProbeBoot so BaseMenu.Checkbox activates it directly.
    items[#items + 1] = BaseMenuItems.Group({
        textKey = "TXT_KEY_MODDING_OPTIONS",
        items = {
            BaseMenuItems.Checkbox({
                controlName = "ShowDLCMods",
                textKey     = "TXT_KEY_MODDING_SHOWDLCMODS",
            }),
            BaseMenuItems.Choice({
                textKey  = "TXT_KEY_CIVVACCESS_MODS_APPLY_OPTIONS",
                activate = function() RefreshMods() end,
            }),
        },
    })

    return items
end

return InstalledPanel

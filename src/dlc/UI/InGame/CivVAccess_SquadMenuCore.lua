-- F11 squad menu: an orchestrator BaseMenu listing the squads plus an "add
-- new squad" row, and a per-squad editor BaseMenu (pushed over it) for the
-- one squad's members and settings. Modeled on ScannerFavorites' custom-
-- category menus -- same pushed-editor idiom, same cached=false / setItems
-- liveness, same shared-EditBox rename field.
--
-- Liveness. The editor's member rows are rebuilt via menu.setItems on every
-- removal so a removed unit's row disappears at once. The orchestrator's
-- squad list is rebuilt via setItems on add / delete (the structural changes
-- to the list); a rename only changes a row's label, which the row's labelFn
-- re-reads live on re-exposure, so no list rebuild is needed there.
--
-- The engine holds membership and the synced per-unit end-mode; the roster
-- holds the squad's existence, name, escort flag, and intended wake mode.
-- Escort is read at move time (no engine push). The wake-mode cycler pushes
-- the new mode to every member through the seam so the engine state tracks
-- the roster intent.

SquadMenuCore = {}

local speak = SpeechPipeline.speakInterrupt

-- The live orchestrator handler, captured at open() so the editor's delete /
-- add paths can refresh its squad list after a structural change.
local _orch = nil

-- Forward declaration: buildSquadItems' delete path rebuilds the orchestrator
-- list, and buildTopItems' squad rows open the editor, so the two builders
-- reference each other. Defined below.
local buildTopItems

local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

local function members(num)
    return EngineData.squadMembers(activePlayer(), num)
end

local function repMember(num)
    return members(num)[1]
end

-- Wipe the shared rename EditBox so the field announces the squad's current
-- name via valueFn rather than a name typed for a prior squad (the box keeps
-- a typing buffer GetText reads from). Mirrors ScannerFavorites.openEditor.
local function clearRenameBox()
    local box = Controls.CivVAccessSquadRenameEntry
    if box ~= nil then
        box:ClearString()
        box:SetText("")
    end
end

-- ===== Per-squad editor items =====

local function buildSquadItems(num)
    local items = {}

    -- Live member rows: Enter removes the unit and rebuilds the list so the
    -- removed row disappears at once.
    for _, member in ipairs(members(num)) do
        local unit = member
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return SquadSpeech.unitRow(unit)
            end,
            onActivate = function(_, menu)
                EngineData.removeFromSquad(unit)
                menu.setItems(buildSquadItems(num))
                speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_REMOVED", SquadRoster.getName(num)))
            end,
        })
    end

    -- Escort-civilians toggle. Read at move time, so flipping it needs no
    -- engine push -- it only updates the roster.
    items[#items + 1] = BaseMenuItems.VirtualToggle({
        textKey = "TXT_KEY_CIVVACCESS_SQUAD_ESCORT",
        getValue = function()
            return SquadRoster.getEscort(num)
        end,
        setValue = function(v)
            SquadRoster.setEscort(num, v)
        end,
    })

    -- Wake-mode cycler: sentry on arrival / wake on arrival / wake when all
    -- arrive (0/1/2). Each press advances the mode, re-pushes it to every
    -- member through the seam (the engine can't store a per-squad default),
    -- and speaks the new mode.
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            return Text.format(
                "TXT_KEY_CIVVACCESS_SQUAD_WAKE_LABEL",
                SquadSpeech.wakeModeName(SquadRoster.getWakeMode(num))
            )
        end,
        onActivate = function()
            local next = (SquadRoster.getWakeMode(num) + 1) % 3
            SquadRoster.setWakeMode(num, next)
            local rep = repMember(num)
            if rep ~= nil then
                EngineData.setSquadEndMovementMode(rep, next)
            end
            speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_WAKE_LABEL", SquadSpeech.wakeModeName(next)))
        end,
    })

    -- Rename. Reads the live name through valueFn (the focused EditBox's
    -- buffer is unreliable for display); priorCallback commits on Enter, and
    -- a blank result resets to the default "Squad N" via SquadRoster.rename.
    items[#items + 1] = BaseMenuItems.Textfield({
        controlName = "CivVAccessSquadRenameEntry",
        textKey = "TXT_KEY_MODDING_HEADING_NAME",
        valueFn = function()
            return SquadRoster.getName(num)
        end,
        priorCallback = function(text, _, bIsEnter)
            if bIsEnter then
                SquadRoster.rename(num, text)
            end
        end,
    })

    -- Delete at the bottom: clear the engine-side membership, drop the roster
    -- entry (no renumber), pop the editor, and refresh the orchestrator list.
    items[#items + 1] = BaseMenuItems.Text({
        textKey = "TXT_KEY_CIVVACCESS_SQUAD_DELETE",
        onActivate = function()
            local name = SquadRoster.getName(num)
            for _, unit in ipairs(members(num)) do
                EngineData.removeFromSquad(unit)
            end
            SquadRoster.delete(num)
            HandlerStack.removeByName("SquadEditor", false)
            if _orch ~= nil then
                _orch.setItems(buildTopItems())
            end
            speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_DELETED", name))
        end,
    })

    return items
end

local function openSquad(num)
    clearRenameBox()
    local handler = BaseMenu.create({
        name = "SquadEditor",
        displayName = SquadRoster.getName(num),
        items = buildSquadItems(num),
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(handler)
end

-- ===== Orchestrator items =====

-- Forward-declared above (buildSquadItems references it in the delete path);
-- defined here.
buildTopItems = function()
    local items = {}
    for _, num in ipairs(SquadRoster.getList()) do
        local squadNum = num
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                return SquadRoster.getName(squadNum)
            end,
            onActivate = function()
                openSquad(squadNum)
            end,
        })
    end
    items[#items + 1] = BaseMenuItems.Text({
        textKey = "TXT_KEY_CIVVACCESS_SQUAD_ADD_NEW",
        onActivate = function(_, menu)
            local num = SquadRoster.allocate()
            menu.setItems(buildTopItems())
            -- Land the cursor on the freshly created squad row so the next
            -- Enter opens it.
            local list = SquadRoster.getList()
            for i, n in ipairs(list) do
                if n == num then
                    menu.setIndex(i)
                    break
                end
            end
            speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_CREATED", SquadRoster.getName(num)))
        end,
    })
    return items
end

function SquadMenuCore.open()
    HandlerStack.removeByName("SquadMenu", false)
    local handler = BaseMenu.create({
        name = "SquadMenu",
        displayName = Text.key("TXT_KEY_CIVVACCESS_SQUAD_MENU_NAME"),
        items = buildTopItems(),
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    _orch = handler
    HandlerStack.push(handler)
end

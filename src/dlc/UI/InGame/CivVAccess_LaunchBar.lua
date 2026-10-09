-- Launch bar: Shift+Tab on the map opens one list of every screen the
-- player can reach by hotkey (GameScreens), each row spoken as the screen
-- name and its key. Enter closes the list and opens the screen; Esc or
-- Shift+Tab again closes it. A screen holding the current end-turn blocker
-- (research to choose, a policy to adopt, a World Congress vote) is listed
-- first with the end-turn button's text after its name; the rest follow
-- alphabetically. Screens this game has switched off are left out.
--
-- Rebuilt on every open (no cached rows): availability and the blocker
-- are read live.

LaunchBar = {}

local MENU_NAME = "LaunchBar"

local function keyLabelText(keyLabel)
    return KeyLayout.swapLabel(Text.key(KeyLayout.resolveKeyLabel(keyLabel)))
end

local function close()
    HandlerStack.removeByName(MENU_NAME, false)
end

-- Rows for the current game, attention rows first then alphabetical.
-- Exposed for the test suite.
function LaunchBar.buildItems()
    local player = Players[Game.GetActivePlayer()]
    local blocker = player:GetEndTurnBlockingType()
    local rows = {}
    for _, entry in ipairs(GameScreens.list()) do
        if entry.available == nil or entry.available() then
            local status = nil
            if entry.blockers ~= nil and entry.blockers[blocker] then
                status = Turn.blockerText(player, blocker)
            end
            rows[#rows + 1] = { entry = entry, name = Text.key(entry.nameKey), status = status }
        end
    end
    table.sort(rows, function(a, b)
        if (a.status ~= nil) ~= (b.status ~= nil) then
            return a.status ~= nil
        end
        return Locale.Compare(a.name, b.name) == -1
    end)
    local items = {}
    for i, row in ipairs(rows) do
        local entry = row.entry
        items[i] = BaseMenuItems.Choice({
            labelText = Text.format("TXT_KEY_CIVVACCESS_LAUNCH_BAR_ITEM", row.name, keyLabelText(entry.keyLabel)),
            tooltipText = row.status,
            activate = function()
                -- Close first so the opened screen's handler pushes onto
                -- the map, not over the launch bar.
                close()
                entry.open()
            end,
        })
    end
    return items
end

function LaunchBar.open()
    HandlerStack.removeByName(MENU_NAME, false)
    local handler = BaseMenu.create({
        name = MENU_NAME,
        displayName = Text.key("TXT_KEY_CIVVACCESS_LAUNCH_BAR"),
        items = LaunchBar.buildItems(),
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        -- Shift+Tab toggles the list closed, like the key that opened it.
        onShiftTab = function()
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CANCELED"))
            HandlerStack.removeByName(MENU_NAME, true)
        end,
    })
    -- Layered over the live map cursor the way the unit action menu is;
    -- beacons keep playing underneath instead of cutting out.
    handler.beaconsTransparent = true
    HandlerStack.push(handler)
end

return LaunchBar

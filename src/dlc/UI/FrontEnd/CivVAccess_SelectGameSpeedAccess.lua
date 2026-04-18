-- Select Game Speed accessibility wiring. Flat list of game speeds, sorted
-- by GrowthPercent to match the base-file order.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

local function buildItems()
    local speeds = {}
    for info in GameInfo.GameSpeeds() do
        speeds[#speeds + 1] = info
    end
    table.sort(speeds, function(a, b)
        if a.GrowthPercent == b.GrowthPercent then
            return a.Description < b.Description
        end
        return a.GrowthPercent < b.GrowthPercent
    end)
    local items = {}
    for _, info in ipairs(speeds) do
        local id = info.ID
        items[#items + 1] = BaseMenuItems.Choice({
            labelText   = Text.key(info.Description),
            tooltipText = Text.key(info.Help),
            activate    = function() SpeedSelected(id) end,
        })
    end
    return items
end

BaseMenu.install(ContextPtr, {
    name          = "SelectGameSpeed",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GAME_SPEED"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items         = buildItems(),
})

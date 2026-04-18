-- Select Game Speed accessibility wiring. Flat list of game speeds, sorted
-- by GrowthPercent to match the base-file order.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler
local handler
local sortedIds = {}

local function sortedSpeeds()
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
    return speeds
end

local function currentIndex()
    local current = PreGame.GetGameSpeed()
    for i, id in ipairs(sortedIds) do
        if id == current then return i end
    end
end

local function buildItems()
    local items = {}
    for _, info in ipairs(sortedSpeeds()) do
        local id = info.ID
        sortedIds[#sortedIds + 1] = id
        items[#items + 1] = BaseMenuItems.Choice({
            labelText   = Text.key(info.Description),
            tooltipText = Text.key(info.Help),
            activate    = function() SpeedSelected(id) end,
        })
    end
    return items
end

handler = BaseMenu.install(ContextPtr, {
    name          = "SelectGameSpeed",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GAME_SPEED"),
    priorShowHide = function(bIsHide, bIsInit)
        if priorShowHide ~= nil then priorShowHide(bIsHide, bIsInit) end
        if not bIsHide and handler ~= nil then
            handler.setInitialIndex(currentIndex())
        end
    end,
    priorInput    = priorInput,
    items         = buildItems(),
})

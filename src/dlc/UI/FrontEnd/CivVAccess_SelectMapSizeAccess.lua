-- Select Map Size accessibility wiring.
-- Items gate on the base file's g_WorldSizeControls[type].Root visibility;
-- the base ShowHideHandler toggles those based on current MapType (via
-- Map_Sizes filtering), so isNavigable picks up only sizes legal for the
-- current script.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler
local handler
-- Parallel to items[]: items[1] is the Random entry (id -1), items[i>1]
-- corresponds to sizeIds[i]. Used by currentIndex to map PreGame's world
-- size back to an item slot without re-iterating GameInfo.Worlds.
local sizeIds = {}

local function currentIndex()
    if PreGame.IsRandomWorldSize() then return 1 end
    local current = PreGame.GetWorldSize()
    for i, id in ipairs(sizeIds) do
        if id == current then return i + 1 end
    end
end

local function buildItems()
    local items = {}
    local randomLabel = PreGame.IsMultiplayerGame()
        and "TXT_KEY_ANY_MAP_SIZE" or "TXT_KEY_RANDOM_MAP_SIZE"
    local randomHelp  = PreGame.IsMultiplayerGame()
        and "TXT_KEY_ANY_MAP_SIZE_HELP" or "TXT_KEY_RANDOM_MAP_SIZE_HELP"
    items[#items + 1] = BaseMenuItems.Choice({
        labelText         = Text.key(randomLabel),
        tooltipText       = Text.key(randomHelp),
        visibilityControl = g_RandomSizeControl.Root,
        activate          = function() SizeSelected(-1) end,
    })
    for info in GameInfo.Worlds() do
        local id = info.ID
        sizeIds[#sizeIds + 1] = id
        local entry = g_WorldSizeControls[info.Type]
        items[#items + 1] = BaseMenuItems.Choice({
            labelText         = Text.key(info.Description),
            tooltipText       = Text.key(info.Help),
            visibilityControl = entry and entry.Root or nil,
            activate          = function() SizeSelected(id) end,
        })
    end
    return items
end

handler = BaseMenu.install(ContextPtr, {
    name          = "SelectMapSize",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAP_SIZE"),
    priorShowHide = function(bIsHide, bIsInit)
        if priorShowHide ~= nil then priorShowHide(bIsHide, bIsInit) end
        if not bIsHide and handler ~= nil then
            handler.setInitialIndex(currentIndex())
        end
    end,
    priorInput    = priorInput,
    items         = buildItems(),
})

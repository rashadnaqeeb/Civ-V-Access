-- Select Map Size accessibility wiring.
-- Items gate on the base file's g_WorldSizeControls[type].Root visibility;
-- the base ShowHideHandler toggles those based on current MapType (via
-- Map_Sizes filtering), so isNavigable picks up only sizes legal for the
-- current script.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

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

BaseMenu.install(ContextPtr, {
    name          = "SelectMapSize",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAP_SIZE"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items         = buildItems(),
})

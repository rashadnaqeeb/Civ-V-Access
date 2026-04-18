-- Select Difficulty accessibility wiring. Flat list of handicaps.
-- DifficultySelected is the base-file global; it commits to PreGame and
-- calls OnBack, which SetHide(true)s the child Context and pops our
-- handler via ShowHide.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler
local handler

local function currentIndex()
    local current = PreGame.GetHandicap(0)
    local idx = 0
    for info in GameInfo.HandicapInfos() do
        if info.Type ~= "HANDICAP_AI_DEFAULT" then
            idx = idx + 1
            if info.ID == current then return idx end
        end
    end
end

local function buildItems()
    local items = {}
    for info in GameInfo.HandicapInfos() do
        if info.Type ~= "HANDICAP_AI_DEFAULT" then
            local id = info.ID
            items[#items + 1] = BaseMenuItems.Choice({
                labelText   = Text.key(info.Description),
                tooltipText = Text.key(info.Help),
                activate    = function() DifficultySelected(id) end,
            })
        end
    end
    return items
end

handler = BaseMenu.install(ContextPtr, {
    name          = "SelectDifficulty",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_DIFFICULTY"),
    priorShowHide = function(bIsHide, bIsInit)
        if priorShowHide ~= nil then priorShowHide(bIsHide, bIsInit) end
        if not bIsHide and handler ~= nil then
            handler.setInitialIndex(currentIndex())
        end
    end,
    priorInput    = priorInput,
    items         = buildItems(),
})

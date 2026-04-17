-- WorldPicker accessibility wiring. No ShowHide handler in the game file.
-- InputHandler is named and handles Esc -> ContextPtr:SetHide(true).

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorInput = InputHandler

SimpleListHandler.install(ContextPtr, {
    name        = "WorldPicker",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WORLD_PICKER"),
    priorInput  = priorInput,
    items = {
        { controlName = "DuelWorldSizeButton",     textKey = "TXT_KEY_WORLD_DUEL",
          activate    = function() DuelWorldSizeButtonClick() end },
        { controlName = "TinyWorldSizeButton",     textKey = "TXT_KEY_WORLD_TINY",
          activate    = function() TinyWorldSizeButtonClick() end },
        { controlName = "SmallWorldSizeButton",    textKey = "TXT_KEY_WORLD_SMALL",
          activate    = function() SmallWorldSizeButtonClick() end },
        { controlName = "StandardWorldSizeButton", textKey = "TXT_KEY_WORLD_STANDARD",
          activate    = function() StandardWorldSizeButtonClick() end },
        { controlName = "LargeWorldSizeButton",    textKey = "TXT_KEY_WORLD_LARGE",
          activate    = function() LargeWorldSizeButtonClick() end },
        { controlName = "HugeWorldSizeButton",     textKey = "TXT_KEY_WORLD_HUGE",
          activate    = function() HugeWorldSizeButtonClick() end },
    },
})

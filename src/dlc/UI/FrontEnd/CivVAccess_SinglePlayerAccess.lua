-- SinglePlayer accessibility wiring. ScenariosButton is hidden when no
-- Firaxis scenarios are installed; SimpleListHandler's live :IsHidden()
-- check transparently skips it.
--
-- StartGameButton carries a dynamic settings-summary tooltip set via
-- Controls.StartGameButton:SetToolTipString inside the screen's own
-- ShowHideHandler. There is no Lua API to read that string back, so we
-- recompute the same summary from PreGame at announce time. Ships with the
-- same pieces the game shows in the mouseover: map script, world size,
-- handicap, game speed. Leader/civ is omitted because Play Now defaults to
-- random and a dedicated "Your civ" announcement belongs on its own widget.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

local function playNowSettingsSummary()
    local parts = {}
    if PreGame.IsRandomMapScript() then
        parts[#parts + 1] = Text.key("TXT_KEY_RANDOM_MAP_SCRIPT")
    else
        local savedMapScript = PreGame.GetMapScript()
        for mapScript in GameInfo.MapScripts() do
            if mapScript.FileName == savedMapScript then
                parts[#parts + 1] = Text.key(mapScript.Name or mapScript.Description)
                break
            end
        end
    end
    if PreGame.IsRandomWorldSize() then
        parts[#parts + 1] = Text.key("TXT_KEY_RANDOM_MAP_SIZE")
    else
        local info = GameInfo.Worlds[PreGame.GetWorldSize()]
        if info ~= nil then parts[#parts + 1] = Text.key(info.Description) end
    end
    local handicap = GameInfo.HandicapInfos[PreGame.GetHandicap(0)]
    if handicap ~= nil then parts[#parts + 1] = Text.key(handicap.Description) end
    local speed = GameInfo.GameSpeeds[PreGame.GetGameSpeed()]
    if speed ~= nil then parts[#parts + 1] = Text.key(speed.Description) end
    if #parts == 0 then return nil end
    return table.concat(parts, ", ")
end

SimpleListHandler.install(ContextPtr, {
    name          = "SinglePlayer",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_SINGLE_PLAYER"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        { controlName = "StartGameButton",    textKey = "TXT_KEY_PLAY_NOW",
          tooltipFn   = playNowSettingsSummary,
          activate    = function() StartGameClick() end },
        { controlName = "GameSetupButton",    textKey = "TXT_KEY_SETUP_GAME",
          activate    = function() SetupGameClicked() end },
        { controlName = "LoadGameButton",     textKey = "TXT_KEY_LOAD_GAME",
          activate    = function() LoadGameClick() end },
        { controlName = "ScenariosButton",    textKey = "TXT_KEY_SCENARIOS",
          activate    = function() ScenariosClicked() end },
        { controlName = "LoadTutorialButton", textKey = "TXT_KEY_TUTORIAL",
          activate    = function() LoadTutorialClick() end },
        { controlName = "BackButton",         textKey = "TXT_KEY_MODDING_MENU_BACK",
          activate    = function() BackButtonClick() end },
    },
})

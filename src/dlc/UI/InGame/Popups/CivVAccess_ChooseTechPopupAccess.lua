-- Choose-a-tech popup accessibility. Wraps the in-game TechPopup Context
-- (BUTTONPOPUP_CHOOSETECH for normal / free-tech picks, BUTTONPOPUP_CHOOSE_TECH_TO_STEAL
-- for espionage success) as a flat-list BaseMenu. Label shape and mode
-- filtering live in CivVAccess_ChooseTechLogic so offline tests can exercise
-- them without dofiling this install-side file.
--
-- Entry: Events.SerialEventGameMessagePopup filters by popupInfo.Type. On a
-- match we record the mode (normal / free / stealing) + stealing target,
-- then rebuild the items via setItems. The BaseMenu's default first-navigable
-- start lands the cursor on the first tech; the preamble fn reads live
-- science-per-turn and free/stealing context.
--
-- Commit: Network.SendResearch(techID, numFreeTechs, stealingTargetID, false).
-- Fourth arg is always false because this screen has no queue-append semantic
-- (only the TechTree's shift-click queues). After commit we speak a mode-
-- specific announcement and call ClosePopup() which is the base file's
-- ContextPtr:SetHide(true) + SerialEventGameMessagePopupProcessed call.
--
-- F6 escalates to the full tree via OpenTechTree() which is the base file's
-- close-then-refire-as-BUTTONPOPUP_TECH_TREE helper. The last item in the
-- list does the same thing so users without F6 muscle memory can find it by
-- arrowing to the bottom.
--
-- Currently-researching pin: in free / stealing modes the active research
-- continues while the player picks the free / stolen tech. We pin it as a
-- non-interactive Text item at the top of the list so the player hears
-- "currently researching X, N turns" before the Choice list. In normal mode
-- (the pick-next-research flow) the popup only opens when there's no current
-- research, so the pin is absent.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_ChooseTechLogic")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Populated on each SerialEventGameMessagePopup match; re-read by preamble
-- and commit paths so the mode stays fresh across re-opens (the popup can
-- fire multiple times when N free techs chain).
local _mode = "normal"
local _stealingTargetID = -1

local function currentPlayer()
    return Players[Game.GetActivePlayer()]
end

-- ===== Preamble =====

local function preambleFn()
    local player = currentPlayer()
    if player == nil then
        return ""
    end
    return ChooseTechLogic.buildPreamble(player, _mode, _stealingTargetID)
end

-- ===== Commit =====

local function commitCallback(techID)
    return function()
        local player = currentPlayer()
        if player == nil then
            Log.error("ChooseTechPopupAccess: commit with no active player")
            return
        end
        local techInfo = GameInfo.Technologies[techID]
        local techName = Text.key(techInfo.Description)
        if _mode == "stealing" then
            Network.SendResearch(techID, 0, _stealingTargetID, false)
            SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN", techName))
        elseif _mode == "free" then
            Network.SendResearch(techID, player:GetNumFreeTechs(), -1, false)
            SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE", techName))
        else
            Network.SendResearch(techID, 0, -1, false)
            SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT", techName))
        end
        ClosePopup()
    end
end

-- ===== Entry -> Choice item =====

local function choiceFromEntry(entry)
    return BaseMenuItems.Choice({
        labelFn = function()
            local player = currentPlayer()
            if player == nil then
                return Text.key(entry.info.Description)
            end
            return ChooseTechLogic.buildLabel(entry, player)
        end,
        activate = commitCallback(entry.techID),
        pediaName = Text.key(entry.info.Description),
    })
end

local function buildItems()
    local playerID = Game.GetActivePlayer()
    local player = Players[playerID]
    if player == nil then
        return {}
    end

    Game.SetAdvisorRecommenderTech(playerID)

    local entries, currentEntry = ChooseTechLogic.buildEntries(playerID, _mode, _stealingTargetID)

    local items = {}
    if currentEntry ~= nil then
        local turns = player:GetResearchTurnsLeft(currentEntry.techID, true)
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.format(
                "TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN",
                Text.key(currentEntry.info.Description),
                turns
            ),
        })
    end
    for _, entry in ipairs(entries) do
        items[#items + 1] = choiceFromEntry(entry)
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "OpenTTButton",
        textKey = "TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE",
        activate = function() OpenTechTree() end,
    })

    return items
end

-- ===== BaseMenu install =====

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseTechPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"),
    preamble = preambleFn,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

-- F6 duplicates the bottom-of-list "Open Tech Tree" item so muscle memory
-- works. The baseline handler already passes F6 through to the engine when
-- no popup is up, but once the popup captures input we need our own binding
-- for the same behavior.
table.insert(mainHandler.bindings, {
    key = Keys.VK_F6,
    mods = 0,
    description = "Open Tech Tree",
    fn = function() OpenTechTree() end,
})

-- ===== Popup intercept =====

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    local t = popupInfo.Type
    if t ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSETECH
        and t ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_TECH_TO_STEAL then
        return
    end
    -- Base TechPopup.lua gates on popupInfo.Data1 == active player (line 75);
    -- match the same gate so non-active-player fires don't overwrite our state.
    if popupInfo.Data1 ~= Game.GetActivePlayer() then
        return
    end

    if t == ButtonPopupTypes.BUTTONPOPUP_CHOOSE_TECH_TO_STEAL then
        _mode = "stealing"
        _stealingTargetID = popupInfo.Data2
    else
        _stealingTargetID = -1
        local player = currentPlayer()
        if player ~= nil and player:GetNumFreeTechs() > 0 then
            _mode = "free"
        else
            _mode = "normal"
        end
    end

    mainHandler.setItems(buildItems())
end)

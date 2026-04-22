-- LoadScreen accessibility wiring. The Dawn-of-Man splash between map
-- launch and first turn. The engine plays a pre-recorded voice clip that
-- narrates the civ's DawnOfManQuote, so we open silent (silentFirstOpen)
-- and expose the on-screen elements as BaseMenu items the user can arrow
-- through. F1 re-reads the quote as the preamble; the Begin button sits
-- first so the cursor can hop onto it the moment loading completes.
--
-- Begin button timing: Controls.ActivateButton is hidden until
-- Events.SequenceGameInitComplete fires. isNavigable gates on hidden
-- state, so the cursor falls through to the first informational item
-- during load. Our SequenceGameInitComplete listener (registered after
-- base's, since the override includes this file at the bottom of
-- LoadScreen.lua) moves the cursor to item 1 and speaks the live button
-- label ("Begin Game" / "Continue"). Multiplayer and hotseat auto-
-- activate without showing the button, so the listener no-ops there.
--
-- Unique items: base PopulateUniqueBonuses caps the sighted UI at 2
-- slots, dropping the third unique for civs like Polynesia, Inca, Maya.
-- We query Civilization_UnitClassOverrides /
-- Civilization_BuildingClassOverrides / Improvements.CivilizationType
-- directly and surface every unique as its own item.
--
-- Re-instantiation: the SequenceGameInitComplete listener closes over a
-- shared reference (civvaccess_shared.loadScreenHandler) rather than the
-- local handler upvalue, so if the Context is re-created the latest
-- handler receives the cursor reset and announcement. The install guard
-- keeps the listener from double-registering on the session bus.

include("CivVAccess_FrontendCommon")

-- Base LoadScreen.lua registers its handler under the bare name `ShowHide`
-- (not `ShowHideHandler` like most screens). Reading the wrong global
-- silently yields nil, the base handler never chains, and
-- OnInitScreen / Events.SerialEventDawnOfManShow both stop firing --
-- the civ labels stay blank and the narrator voice never plays.
local priorShowHide = ShowHide
local priorInput = InputHandler

local function controlText(control)
    if control == nil then
        return ""
    end
    local ok, text = pcall(function()
        return control:GetText()
    end)
    if not ok then
        Log.warn("LoadScreenAccess: GetText failed: " .. tostring(text))
        return ""
    end
    return tostring(text or "")
end

local uniqueUnitsQuery = DB.CreateQuery([[SELECT Description FROM Units
    INNER JOIN Civilization_UnitClassOverrides
    ON Units.Type = Civilization_UnitClassOverrides.UnitType
    WHERE Civilization_UnitClassOverrides.CivilizationType = ? AND
    Civilization_UnitClassOverrides.UnitType IS NOT NULL]])

local uniqueBuildingsQuery = DB.CreateQuery([[SELECT Description FROM Buildings
    INNER JOIN Civilization_BuildingClassOverrides
    ON Buildings.Type = Civilization_BuildingClassOverrides.BuildingType
    WHERE Civilization_BuildingClassOverrides.CivilizationType = ? AND
    Civilization_BuildingClassOverrides.BuildingType IS NOT NULL]])

local uniqueImprovementsQuery = DB.CreateQuery([[SELECT Description FROM Improvements WHERE CivilizationType = ?]])

local function activeCiv()
    local civIndex = PreGame.GetCivilization(Game:GetActivePlayer())
    return GameInfo.Civilizations[civIndex]
end

local function uniqueItem(labelKey, description)
    return BaseMenuItems.Text({
        labelText = Text.key(description) .. ", " .. Text.key(labelKey),
    })
end

local function buildItems()
    local items = {}

    -- Begin button first so SequenceGameInitComplete can setIndex(1) and
    -- announce. Unreachable by navigation while ActivateButton is hidden.
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "ActivateButton",
        labelFn = function()
            return controlText(Controls.ActivateButtonText)
        end,
        activate = function()
            OnActivateButtonClicked()
        end,
    })

    -- Leader and civilization names: read live from the base-set labels
    -- so the localized value matches what sighted players see.
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            return controlText(Controls.Leader)
        end,
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            return controlText(Controls.Civilization)
        end,
    })

    -- Trait (unique ability): name + full description as separate items
    -- so the user can tab past the name once they know it.
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local name = controlText(Controls.BonusTitle)
            if name == "" then
                return ""
            end
            return name .. ", " .. Text.key("TXT_KEY_CIVVACCESS_UNIQUE_ABILITY")
        end,
    })
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            return TextFilter.filter(controlText(Controls.BonusDescription))
        end,
    })

    -- Uniques queried directly: base's sighted UI caps at 2 slots, so
    -- reading Controls.BonusUnit / Controls.BonusBuilding would drop the
    -- third unique on civs with three.
    local civ = activeCiv()
    if civ ~= nil then
        for row in uniqueUnitsQuery(civ.Type) do
            items[#items + 1] = uniqueItem("TXT_KEY_CIVVACCESS_UNIQUE_UNIT", row.Description)
        end
        for row in uniqueBuildingsQuery(civ.Type) do
            items[#items + 1] = uniqueItem("TXT_KEY_CIVVACCESS_UNIQUE_BUILDING", row.Description)
        end
        for row in uniqueImprovementsQuery(civ.Type) do
            items[#items + 1] = uniqueItem("TXT_KEY_CIVVACCESS_UNIQUE_IMPROVEMENT", row.Description)
        end
    end

    return items
end

local function buildPreamble()
    local quote = TextFilter.filter(controlText(Controls.Quote))
    if quote == nil or quote == "" then
        return nil
    end
    return quote
end

local handler = BaseMenu.install(ContextPtr, {
    name = "LoadScreen",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LOADING"),
    preamble = buildPreamble,
    silentFirstOpen = true,
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    onShow = function(h)
        h.setItems(buildItems())
    end,
    items = buildItems(),
})

civvaccess_shared.loadScreenHandler = handler

if not civvaccess_shared.loadScreenReadyListenerInstalled then
    civvaccess_shared.loadScreenReadyListenerInstalled = true
    Events.SequenceGameInitComplete.Add(function()
        if PreGame.IsMultiplayerGame() or PreGame.IsHotSeatGame() then
            return
        end
        local h = civvaccess_shared.loadScreenHandler
        if h == nil then
            return
        end
        -- Land on the Begin button (item 1) and run the re-activation
        -- path of onActivate, which speakInterrupts the current item's
        -- announce. The user hears "Begin Game" / "Continue" the moment
        -- Enter will fire.
        h.setIndex(1)
        local ok, err = pcall(h.onActivate)
        if not ok then
            Log.error("LoadScreenAccess: ready re-activate failed: " .. tostring(err))
        end
    end)
end

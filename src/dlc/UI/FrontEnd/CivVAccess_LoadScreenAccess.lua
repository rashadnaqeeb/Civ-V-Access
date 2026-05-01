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
    return Text.controlText(control, "LoadScreenAccess") or ""
end

-- LEFT JOIN onto the default unit/building of the overridden class so
-- each row carries what the unique stands in for. Rows where the override
-- IS the class default (no real replacement) come back with a nil
-- ReplacesDesc and render without the suffix.
local uniqueUnitsQuery = DB.CreateQuery([[SELECT
        UniqueUnit.Description AS UniqueDesc,
        DefaultUnit.Description AS ReplacesDesc
    FROM Civilization_UnitClassOverrides
        INNER JOIN Units AS UniqueUnit
            ON UniqueUnit.Type = Civilization_UnitClassOverrides.UnitType
        INNER JOIN UnitClasses
            ON UnitClasses.Type = Civilization_UnitClassOverrides.UnitClassType
        LEFT JOIN Units AS DefaultUnit
            ON DefaultUnit.Type = UnitClasses.DefaultUnit
    WHERE Civilization_UnitClassOverrides.CivilizationType = ?
        AND Civilization_UnitClassOverrides.UnitType IS NOT NULL]])

local uniqueBuildingsQuery = DB.CreateQuery([[SELECT
        UniqueBuilding.Description AS UniqueDesc,
        DefaultBuilding.Description AS ReplacesDesc
    FROM Civilization_BuildingClassOverrides
        INNER JOIN Buildings AS UniqueBuilding
            ON UniqueBuilding.Type = Civilization_BuildingClassOverrides.BuildingType
        INNER JOIN BuildingClasses
            ON BuildingClasses.Type = Civilization_BuildingClassOverrides.BuildingClassType
        LEFT JOIN Buildings AS DefaultBuilding
            ON DefaultBuilding.Type = BuildingClasses.DefaultBuilding
    WHERE Civilization_BuildingClassOverrides.CivilizationType = ?
        AND Civilization_BuildingClassOverrides.BuildingType IS NOT NULL]])

-- Improvements are additive (Moai, Polder, Feitoria add a new buildable
-- rather than replacing a default), so no Replaces clause here.
local uniqueImprovementsQuery =
    DB.CreateQuery([[SELECT Description AS UniqueDesc FROM Improvements WHERE CivilizationType = ?]])

local function activeCiv()
    local civIndex = PreGame.GetCivilization(Game:GetActivePlayer())
    return GameInfo.Civilizations[civIndex]
end

local function uniqueItem(labelKey, uniqueDesc, replacesDesc)
    local parts = { Text.key(uniqueDesc), Text.key(labelKey) }
    if replacesDesc ~= nil and replacesDesc ~= uniqueDesc then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_REPLACES", Text.key(replacesDesc))
    end
    return BaseMenuItems.Text({ labelText = table.concat(parts, ", ") })
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

    -- Trait (unique ability): name, label, and full description as a
    -- single item. The description is short (one sentence for most
    -- traits) so appending it saves a nav stop.
    items[#items + 1] = BaseMenuItems.Text({
        labelFn = function()
            local name = controlText(Controls.BonusTitle)
            if name == "" then
                return ""
            end
            local out = Text.format("TXT_KEY_CIVVACCESS_UNIQUE_ABILITY_NAMED", name)
            local desc = controlText(Controls.BonusDescription)
            if desc ~= nil and desc ~= "" then
                out = out .. ", " .. desc
            end
            return out
        end,
    })

    -- Uniques queried directly: base's sighted UI caps at 2 slots, so
    -- reading Controls.BonusUnit / Controls.BonusBuilding would drop the
    -- third unique on civs with three.
    local civ = activeCiv()
    if civ ~= nil then
        for row in uniqueUnitsQuery(civ.Type) do
            items[#items + 1] = uniqueItem("TXT_KEY_CIVVACCESS_UNIQUE_UNIT", row.UniqueDesc, row.ReplacesDesc)
        end
        for row in uniqueBuildingsQuery(civ.Type) do
            items[#items + 1] = uniqueItem("TXT_KEY_CIVVACCESS_UNIQUE_BUILDING", row.UniqueDesc, row.ReplacesDesc)
        end
        for row in uniqueImprovementsQuery(civ.Type) do
            items[#items + 1] = uniqueItem("TXT_KEY_CIVVACCESS_UNIQUE_IMPROVEMENT", row.UniqueDesc)
        end
    end

    return items
end

local function buildPreamble()
    local quote = controlText(Controls.Quote)
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
        -- Enter will fire. setIndex clears any live type-ahead search so
        -- a buffer the user typed during the load doesn't route the
        -- next Up/Down through stale match results.
        h.setIndex(1)
        local ok, err = pcall(h.onActivate)
        if not ok then
            Log.error("LoadScreenAccess: ready re-activate failed: " .. tostring(err))
        end
    end)
end

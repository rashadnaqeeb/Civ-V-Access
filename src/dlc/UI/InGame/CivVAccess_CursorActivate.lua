-- Enter on the hex cursor. Builds the list of things on the plot the user
-- can act on (city, active-player units split military-first) and either
-- dispatches the single entry directly, or pops a BaseMenu.create modal
-- so the user can pick which one. Entries in order: city first, military
-- units next, civilian units last. Units are filtered by owner == active
-- player (you can't select someone else's unit), IsInvisible, and IsCargo.
-- Air units are listed (user explicitly wants them pickable from a stack).
--
-- The city entry's action mirrors vanilla's CityBannerManager OnBannerClick
-- fork and matches what Cursor.activate used to do inline: own city opens
-- the city screen (annex popup first if the city is a puppet and the
-- player may annex), a met minor opens the read-only city screen, a met
-- major opens diplomacy (or the deal screen for human opponents) with
-- the same turn-active guard LeaderSelected uses, and unmet foreigners
-- silent no-op. The unit action is just UI.SelectUnit.

CursorActivate = {}

local function collectSelfUnits(plot)
    local activeID = Game.GetActivePlayer()
    local team = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    local military, civilian = {}, {}
    local n = plot:GetNumUnits()
    for i = 0, n - 1 do
        local u = plot:GetUnit(i)
        if u ~= nil and u:GetOwner() == activeID and not u:IsInvisible(team, isDebug) and not u:IsCargo() then
            if u:IsCombatUnit() then
                military[#military + 1] = u
            else
                civilian[#civilian + 1] = u
            end
        end
    end
    return military, civilian
end

local function activateCity(plot)
    local ownerID = plot:GetOwner()
    local activeID = Game.GetActivePlayer()
    if ownerID == activeID then
        local city = plot:GetPlotCity()
        local player = Players[activeID]
        if city:IsPuppet() and not player:MayNotAnnex() then
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_ANNEX_CITY,
                Data1 = city:GetID(),
                Data2 = -1,
                Data3 = -1,
                Option1 = false,
                Option2 = false,
            })
        else
            UI.DoSelectCityAtPlot(plot)
        end
        return
    end
    local activeTeam = Teams[Game.GetActiveTeam()]
    local other = Players[ownerID]
    if not activeTeam:IsHasMet(other:GetTeam()) then
        return
    end
    if other:IsMinorCiv() then
        UI.DoSelectCityAtPlot(plot)
        return
    end
    if not Players[activeID]:IsTurnActive() or Game.IsProcessingMessages() then
        return
    end
    if other:IsHuman() then
        Events.OpenPlayerDealScreenEvent(ownerID)
    else
        UI.SetRepeatActionPlayer(ownerID)
        UI.ChangeStartDiploRepeatCount(1)
        other:DoBeginDiploWithHuman()
    end
end

-- Returns an ordered list of entries for the picker. Each entry:
--   kind  "city" | "unit"
--   label spoken string (CitySpeech.identity / UnitSpeech.info -- same as
--         the 1 key and the S key so the picker reads like the rest of
--         the cursor)
--   act   fn() side-effect when chosen (open city screen / diplo /
--         UI.SelectUnit). The caller is responsible for popping the
--         picker handler before calling act.
local function buildEntries(plot)
    local entries = {}
    if plot:IsCity() then
        local city = plot:GetPlotCity()
        -- Name-first for the picker label. CitySpeech.identity leads
        -- with status tokens / population, which the 1 key wants but
        -- a picker row needs the distinguishing word (the name) first.
        entries[#entries + 1] = {
            kind = "city",
            label = city:GetName() .. ", " .. CitySpeech.identity(city),
            act = function()
                activateCity(plot)
            end,
        }
    end
    local military, civilian = collectSelfUnits(plot)
    for _, u in ipairs(military) do
        entries[#entries + 1] = {
            kind = "unit",
            label = UnitSpeech.info(u),
            act = function()
                UI.SelectUnit(u)
            end,
        }
    end
    for _, u in ipairs(civilian) do
        entries[#entries + 1] = {
            kind = "unit",
            label = UnitSpeech.info(u),
            act = function()
                UI.SelectUnit(u)
            end,
        }
    end
    return entries
end

function CursorActivate.run(plot)
    if plot == nil then
        return
    end
    local entries = buildEntries(plot)
    if #entries == 0 then
        return
    end
    if #entries == 1 then
        entries[1].act()
        return
    end
    local items = {}
    for _, entry in ipairs(entries) do
        local act = entry.act
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = entry.label,
            activate = function()
                HandlerStack.removeByName("CursorActivate", false)
                act()
            end,
        })
    end
    HandlerStack.removeByName("CursorActivate", false)
    local handler = BaseMenu.create({
        name = "CursorActivate",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        -- The first item's label (city name / unit info) already stands
        -- on its own; a "Activate tile" header before it is redundant
        -- noise. F1 still re-reads displayName on demand.
        silentDisplayName = true,
    })
    HandlerStack.push(handler)
end

-- Test seam. Production callers go through run().
CursorActivate._buildEntries = buildEntries

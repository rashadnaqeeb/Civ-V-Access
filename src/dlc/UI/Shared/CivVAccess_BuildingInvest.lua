-- Shared Vox Populi building-investment action: the "can this be invested
-- in right now" probe, the Gold cost label, and the commit + async
-- "production cost reduced by N" follow-up. Two callers share it: the
-- production chooser's Purchase tab (a Gold building entry under
-- BALANCE_BUILDING_INVESTMENTS) and the in-city production queue's per-slot
-- Invest action. Keeping the asynchronous poll in one place matters because
-- its timing assumption is VP-specific and easy to drift if duplicated.
--
-- Engine globals are reached directly (the same purchase APIs the chooser
-- already used outside the seam); only the investment-state reads route
-- through EngineData, which is VP-only and false on vanilla.

BuildingInvest = {}

-- Vox Populi applies a Gold building investment asynchronously:
-- Game.CityPurchaseBuilding routes through the network dispatch
-- (CvGame::CityPurchase -> sendPurchase), so the reduced production-needed
-- is not readable on the same frame. Poll up to this many ticks for the
-- applied investment before giving up (logged, never silent).
local INVEST_POLL_TICKS = 12

-- True when a Gold investment can be committed for this building in this
-- city right now: VP investments enabled, the order is a building, it is
-- not already invested, and the engine's purchase gate (gold on hand,
-- building eligible, cooldown clear) passes for a Gold building purchase.
-- False on vanilla (EngineData.buildingInvestmentsEnabled() is false there)
-- and for non-building orders.
function BuildingInvest.canInvest(city, orderType, buildingID)
    if orderType ~= OrderTypes.ORDER_CONSTRUCT then
        return false
    end
    if EngineData == nil or not EngineData.buildingInvestmentsEnabled() then
        return false
    end
    if EngineData.buildingInvested(city, buildingID) then
        return false
    end
    return city:IsCanPurchase(true, true, -1, buildingID, -1, YieldTypes.YIELD_GOLD)
end

-- "invest, N gold" label. GetBuildingPurchaseCost returns the investment
-- cost under VP. Callers gate on canInvest first.
function BuildingInvest.costLabel(city, buildingID)
    local cost = city:GetBuildingPurchaseCost(buildingID)
    return Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_INVEST_GOLD", cost)
end

-- Commit the investment and announce it. Confirms "invested in X" now, then
-- polls for the engine's asynchronously-applied cost reduction and queues
-- "production cost reduced by N" after the confirmation so it trails --
-- never clobbers -- it. preNeeded is captured before the engine applies the
-- reduction; the poll re-resolves the city by id each tick because the
-- original handle can go stale across the network dispatch. Returns true
-- when the purchase dispatched, false (logged) when the engine refused at
-- commit -- the caller announces the refusal.
function BuildingInvest.perform(city, buildingID)
    if not city:IsCanPurchase(true, true, -1, buildingID, -1, YieldTypes.YIELD_GOLD) then
        Log.error("BuildingInvest: IsCanPurchase false at commit; building=" .. tostring(buildingID))
        return false
    end

    local preNeeded = city:GetBuildingProductionNeeded(buildingID)
    local ownerID, cityID = city:GetOwner(), city:GetID()

    Game.CityPurchaseBuilding(city, buildingID, YieldTypes.YIELD_GOLD)
    Events.SpecificCityInfoDirty(ownerID, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_BANNER)
    Events.SpecificCityInfoDirty(ownerID, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_PRODUCTION)
    Events.AudioPlay2DSound("AS2D_INTERFACE_CITY_SCREEN_PURCHASE")
    SpeechPipeline.speakInterrupt(
        Text.format(
            "TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_INVESTED",
            Text.key(GameInfo.Buildings[buildingID].Description)
        )
    )

    local ticks = 0
    local function poll()
        ticks = ticks + 1
        local player = Players[ownerID]
        local c = player ~= nil and player:GetCityByID(cityID) or nil
        if c == nil then
            Log.warn("BuildingInvest: invest follow-up lost city " .. tostring(cityID))
            return
        end
        if EngineData.buildingInvested(c, buildingID) then
            local reduction = preNeeded - c:GetBuildingProductionNeeded(buildingID)
            if reduction > 0 then
                SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_INVEST_REDUCED", reduction))
            else
                SpeechPipeline.speakQueued(Text.key("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_INVEST_NO_REDUCTION"))
            end
            return
        end
        if ticks < INVEST_POLL_TICKS then
            TickPump.runOnce(poll)
        else
            Log.warn("BuildingInvest: invest follow-up timed out for building " .. tostring(buildingID))
        end
    end
    TickPump.runOnce(poll)
    return true
end

return BuildingInvest

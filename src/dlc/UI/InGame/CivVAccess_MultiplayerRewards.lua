-- !!! MULTIPLAYER-ONLY MODULE !!!
--
-- Civ V's engine suppresses three reward popups in networked multiplayer
-- (the !isNetworkMultiPlayer guard in CvPlayer.cpp / CvUnit.cpp / CvPlot.cpp
-- around BUTTONPOPUP_GOODY_HUT_REWARD, BUTTONPOPUP_BARBARIAN_CAMP_REWARD,
-- BUTTONPOPUP_NATURAL_WONDER_REWARD). In single-player the standard
-- *PopupAccess wrappers (GoodyHutPopup / BarbarianCampPopup /
-- NaturalWonderPopup) read the popup's DescriptionLabel and announce
-- through BaseMenu's preamble. In MP those popups never fire, so a blind
-- player would silently miss every ruin reward, every barbarian-camp
-- reward, and every natural-wonder discovery. This module is the MP
-- fallback that closes that gap and only that gap.
--
-- Hot seat is unaffected: the engine gate is on isNetworkMultiPlayer (not
-- isGameMultiPlayer), so hot seat sees the popups normally and rides the
-- existing access wrappers. This module's MP gate matches: it only fires
-- when Game:IsNetworkMultiPlayer() is true, so single-player and hot seat
-- are no-ops here.
--
-- Signal sources, all unconditional in both SP and MP:
-- * Goody hut: GameEvents.CivVAccessGoodyHutReceived (engine fork hook,
--   src/engine/CvGameCoreDLL_Expansion2/CvPlayer.cpp inside the active-
--   player block of CvPlayer::receiveGoody, marked CIVVACCESS:). Args
--   (playerID, eGoody, iSpecialValue) -- iSpecialValue mirrors what the
--   popup's data2 carries: gold, culture, or faith depending on the goody
--   type.
-- * Barbarian camp: GameEvents.CivVAccessBarbarianCampCleared (engine
--   fork hook, CvUnit.cpp, marked CIVVACCESS:). Args (playerID, iX, iY,
--   iNumGold).
-- * Natural wonder: Events.NaturalWonderRevealed (vanilla, fired
--   unconditionally for the active team via gDLL->GameplayNaturalWonder-
--   Revealed). Args (iX, iY). No engine change needed for this one.
--
-- Speech path: speakQueued + MessageBuffer.append("notification") for
-- every announcement. Queueing matches NotificationAnnounce: these
-- discoveries land in inter-turn waves (a unit move can clear a camp AND
-- pop a goody on the same tick), so an interrupt would clip the prior
-- line. The notification category puts the entry on the same Shift+] /
-- Shift+[ filter as engine-generated notifications, since these events
-- are conceptually the same shape.
--
-- Listeners are re-registered fresh on every onInGameBoot. See
-- CivVAccess_Boot.lua's LoadScreenClose registration for the rationale:
-- load-game-from-game kills the prior Context's env, stranding listeners
-- that captured its closures.

MultiplayerRewards = {}

local function emit(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakQueued(text)
    MessageBuffer.append(text, "notification")
end

-- Goody hut. Mirrors GoodyHutPopup.lua's OnPopup: the description string
-- is formatted with iSpecialValue for goody types whose Description has a
-- {1_Num}-style positional argument (gold / culture / faith), and used
-- bare for the rest (units, techs, population, etc.). We pass the value
-- to Locale either way -- Locale ignores extra args when the template has
-- no placeholders, so unconditional formatting is safe and avoids a
-- per-goody-type branch the engine already differentiates.
function MultiplayerRewards._onGoodyHutReceived(playerID, eGoody, iSpecialValue)
    if not Game:IsNetworkMultiPlayer() then
        return
    end
    if playerID ~= Game.GetActivePlayer() then
        return
    end
    local row = GameInfo.GoodyHuts[eGoody]
    if row == nil or row.Description == nil then
        Log.warn("MultiplayerRewards: missing GoodyHuts row for eGoody=" .. tostring(eGoody))
        return
    end
    emit(Text.format(row.Description, iSpecialValue or 0))
end

-- Barbarian camp cleared. Mirrors BarbarianCampPopup.lua's OnPopup, which
-- calls Locale.ConvertTextKey("TXT_KEY_BARB_CAMP_CLEARED", iNumGold).
function MultiplayerRewards._onBarbarianCampCleared(playerID, _iX, _iY, iNumGold)
    if not Game:IsNetworkMultiPlayer() then
        return
    end
    if playerID ~= Game.GetActivePlayer() then
        return
    end
    emit(Text.format("TXT_KEY_BARB_CAMP_CLEARED", iNumGold))
end

-- Natural wonder. Mirrors NaturalWonderPopup.lua's yieldString
-- composition: feature description in a TT-format wrapper, then per-yield
-- lines from Feature_YieldChanges, then the in-border-happiness tail, the
-- adjacent-unit free-promotion tail, and the finder-gold tail (first vs
-- subsequent finder picks the right key). The bFirst signal isn't on the
-- vanilla event so we recover it from the plot's reveal state: a finder
-- gold > 0 with no team having previously revealed the feature is a
-- first-finder grant. Engine source for this branch:
-- CvGameCoreDLL_Expansion2/CvPlot.cpp around the BUTTONPOPUP_NATURAL_-
-- WONDER_REWARD construction (iFinderGold, bFirstFinder).
--
-- We don't have a Lua-side signal for iFinderGold or bFirstFinder. The
-- popup version takes them from the popupInfo struct that the engine
-- builds; in MP that struct is never built (the popup is the thing that
-- gets suppressed). Best we can do offline is announce the wonder name
-- plus its yields / happiness / promotion, and skip the finder-gold line
-- entirely. The finder gold still lands in the player's treasury (the
-- engine grants it before the popup gate); the player will hear it
-- through the next gold-change cue.
function MultiplayerRewards._onNaturalWonderRevealed(iX, iY)
    if not Game:IsNetworkMultiPlayer() then
        return
    end
    local plot = Map.GetPlot(iX, iY)
    if plot == nil then
        Log.warn(
            "MultiplayerRewards: NaturalWonderRevealed plot nil at (" .. tostring(iX) .. "," .. tostring(iY) .. ")"
        )
        return
    end
    -- Events.NaturalWonderRevealed fires from the engine after the wonder's
    -- feature is set on the plot, so a missing feature here is unexpected
    -- (engine drift or a mid-event mutation). Log loud rather than fall
    -- through silently -- a future regression that strips the feature
    -- before the event fires would otherwise lose the announcement with
    -- no diagnostic.
    local feature = plot:GetFeatureType()
    if feature == nil or feature < 0 then
        Log.warn(
            "MultiplayerRewards: NaturalWonderRevealed plot ("
                .. tostring(iX)
                .. ","
                .. tostring(iY)
                .. ") has no feature; skipping announcement"
        )
        return
    end
    local info = GameInfo.Features[feature]
    if info == nil or not info.NaturalWonder then
        return
    end

    local condition = "FeatureType = '" .. info.Type .. "'"
    local yieldString = Text.format("TXT_KEY_POP_NATURAL_WONDER_FOUND_TT", info.Description)
    local numYields = 0
    for row in GameInfo.Feature_YieldChanges(condition) do
        if row.Yield > 0 then
            numYields = numYields + 1
            yieldString = yieldString .. " " .. tostring(row.Yield) .. " "
            yieldString = yieldString .. GameInfo.Yields[row.YieldType].IconString .. " "
        end
    end
    if numYields == 0 then
        yieldString = yieldString .. " " .. Text.key("TXT_KEY_PEDIA_NO_YIELD")
    end
    if info.InBorderHappiness and info.InBorderHappiness > 0 then
        yieldString = yieldString .. Text.format("TXT_KEY_POP_NATURAL_WONDER_FOUND_HAPPY", info.InBorderHappiness)
    end
    if info.AdjacentUnitFreePromotion then
        local promo = GameInfo.UnitPromotions[info.AdjacentUnitFreePromotion]
        if promo ~= nil and promo.Description ~= nil then
            yieldString = yieldString
                .. Text.format("TXT_KEY_POP_NATURAL_WONDER_FOUND_PROMOTE", Text.key(promo.Description))
        end
    end

    emit(yieldString)
end

-- Registers fresh listeners on every call (onInGameBoot invokes this once
-- per game load). Even though MP-only feature, the boot wiring runs in SP
-- too -- the gates inside each handler reject the events. Cheap to be
-- always-installed: the engine still raises the events in SP, and our
-- handlers return after a single Game:IsNetworkMultiPlayer() check.
function MultiplayerRewards.installListeners()
    Log.installEvent(GameEvents, "CivVAccessGoodyHutReceived",
        MultiplayerRewards._onGoodyHutReceived, "MultiplayerRewards",
        "goody-hut announces disabled in MP (engine fork not deployed?)")
    Log.installEvent(GameEvents, "CivVAccessBarbarianCampCleared",
        MultiplayerRewards._onBarbarianCampCleared, "MultiplayerRewards",
        "barb-camp announces disabled in MP (engine fork not deployed?)")
    Log.installEvent(Events, "NaturalWonderRevealed",
        MultiplayerRewards._onNaturalWonderRevealed, "MultiplayerRewards")
end

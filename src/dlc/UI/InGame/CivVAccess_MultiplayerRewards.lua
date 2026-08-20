-- !!! MULTIPLAYER-ONLY MODULE !!!
--
-- Civ V's engine suppresses several reward / first-contact popups in
-- networked multiplayer (the !isNetworkMultiPlayer guards in CvPlayer.cpp /
-- CvUnit.cpp / CvPlot.cpp / CvMinorCivAI.cpp around BUTTONPOPUP_GOODY_HUT_-
-- REWARD, BUTTONPOPUP_BARBARIAN_CAMP_REWARD, BUTTONPOPUP_NATURAL_WONDER_-
-- REWARD, BUTTONPOPUP_CITY_STATE_GREETING, plus CvDiplomacyAI.cpp's
-- DoFirstContact which gates both the AI leader-greet popup and the human-
-- to-human notification fallback). In single-player the standard
-- *PopupAccess wrappers (GoodyHutPopup / BarbarianCampPopup /
-- NaturalWonderPopup / CityStateGreetingPopup) plus the leader-popup speech
-- cover these. In MP those paths never fire, so a blind player would
-- silently miss every ruin reward, every barbarian-camp reward, every
-- natural-wonder discovery, every city-state meeting gift, and every first
-- contact with a major civ. This module is the MP fallback that closes
-- those gaps and only those gaps.
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
-- * Natural wonder: GameEvents.NaturalWonderDiscovered (stock engine
--   CallHook in CvPlot::setRevealed, fired in the deterministic simulation
--   for every team that reveals a wonder). Args (eTeam, eFeature, iX, iY,
--   bFirst). Stock, so no engine change needed -- but note we deliberately
--   do NOT use Events.NaturalWonderRevealed (the gDLL presentation
--   callback): that visual signal does not cross the MP network boundary
--   reliably, so the active player's own reveal can leave only the generic
--   notification summary, with no wonder name.
-- * City-state meeting gift: GameEvents.CivVAccessCityStateGreeting (engine
--   fork hook, CvMinorCivAI::DoFirstContactWithMajor, marked CIVVACCESS:,
--   fired for the active player after the MP-gated greeting popup). Args
--   (minorCivID, iData2, iData3, bFirst, szSuffix) mirror the popup's data
--   fields; see the handler. The city-state's identity still reaches the
--   player through NOTIFICATION_MET_MINOR (NotificationAnnounce speaks it);
--   only the gift is suppressed in MP, so this handler announces the gift.
-- * Major-civ first contact: GameEvents.TeamMeet (vanilla, fired
--   unconditionally from CvTeam::meet via LuaSupport::CallHook). Args
--   (eTeamMet, eTeamMoving).
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

-- Natural wonder. Mirrors NaturalWonderPopup.lua's yieldString composition:
-- feature description in a TT-format wrapper, then per-yield lines from
-- Feature_YieldChanges, then the in-border-happiness tail, then the
-- adjacent-unit free-promotion tail.
--
-- Driven by GameEvents.NaturalWonderDiscovered, a stock engine CallHook
-- fired in the deterministic simulation for every team that reveals a
-- wonder -- NOT Events.NaturalWonderRevealed, the gDLL presentation
-- callback. The presentation callback does not cross the MP network
-- boundary reliably: in a networked game the active player's own reveal can
-- fail to raise it, leaving only the generic NOTIFICATION summary, which the
-- user hears as a bare "natural wonder discovered" with no name. The
-- CallHook fires on every client for the revealing team, so gating on
-- Game.GetActiveTeam() announces the local player's discoveries exactly as
-- the suppressed popup would. Args (eTeam, eFeature, iX, iY, bFirst) carry
-- the feature type directly, so no plot read is needed; iX, iY (grid coords)
-- are unused.
--
-- The finder-gold tail (which the popup adds when iFinderGold > 0, varying
-- by first vs subsequent finder) is skipped: the hook doesn't carry the
-- gold amount. The finder gold still lands in the player's treasury (the
-- engine grants it regardless); the player will hear it through the next
-- gold-change cue.
function MultiplayerRewards._onNaturalWonderDiscovered(eTeam, eFeature, _iX, _iY, _bFirst)
    if not Game:IsNetworkMultiPlayer() then
        return
    end
    if eTeam ~= Game.GetActiveTeam() then
        return
    end
    local info = GameInfo.Features[eFeature]

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

-- Major-civ first contact. Mirrors the engine's suppressed human-to-human
-- notification path (CvDiplomacyAI.cpp DoFirstContact, gated by
-- !isNetworkMultiPlayer): same TXT_KEY_NOTIFICATION_SUMMARY_MET_MINOR_CIV
-- template, same leader nameKey arg. The key's name is misleading -- it
-- generalizes to "You have met {1_CivName:textkey}" and Firaxis reuses it
-- for human-to-human, which is the path we're standing in for.
--
-- City-states are skipped because NOTIFICATION_MET_MINOR fires uncondi-
-- tionally from CvTeam::makeHasMet (no MP gate) and NotificationAnnounce
-- already speaks it. Barbarians are skipped because first-contact-with-
-- barbarians is not a meaningful announcement.
function MultiplayerRewards._onTeamMeet(eTeamMet, eTeamMoving)
    if not Game:IsNetworkMultiPlayer() then
        return
    end
    local activeTeam = Game.GetActiveTeam()
    local otherTeam
    if eTeamMet == activeTeam then
        otherTeam = eTeamMoving
    elseif eTeamMoving == activeTeam then
        otherTeam = eTeamMet
    else
        return
    end
    local team = Teams[otherTeam]
    if team:IsMinorCiv() or team:IsBarbarian() then
        return
    end
    local leaderID = team:GetLeaderID()
    local leader = Players[leaderID]
    emit(Text.format("TXT_KEY_NOTIFICATION_SUMMARY_MET_MINOR_CIV", leader:GetNameKey()))
end

-- City-state meeting gift. The city-state's name already reaches the player
-- through NOTIFICATION_MET_MINOR; this announces only the first-contact
-- gift, which the suppressed BUTTONPOPUP_CITY_STATE_GREETING would have
-- shown. szSuffix selects the gift shape, matching whichever popup the
-- active engine ships:
--   * empty -- vanilla / LekMod / Community-Patch-with-gifts-off: iData2 is
--     the gold gift, iData3 the faith gift. Formatted with the same
--     TXT_KEY_CITY_STATE_GIFT_* keys the vanilla CityStateGreetingPopup uses.
--   * non-empty -- the Community Patch's richer gift model (GLOBAL_CS_GIFTS,
--     which Vox Populi enables): szSuffix is the trait key (GOLD / FAITH /
--     CULTURE / FOOD / UNIT), iData2 the gift value (or unit type for UNIT),
--     iData3 the friendship boost. Reproduces the modded popup's
--     strGiftString composition, including the friendship-only and
--     nothing-gained fallbacks.
-- Neutral is the fallback rather than silence: this key names the greeting
-- the popup is built around, so it has to resolve to something.
local function minorPersonalityKey(minorCivID)
    return EngineData.minorPersonalityTextKey(minorCivID) or "TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL"
end

local function cityStateGiftString(minorCivID, iData2, iData3, bFirst, szSuffix)
    if szSuffix == nil or szSuffix == "" then
        local parts = {}
        if iData2 > 0 then
            parts[#parts + 1] =
                Text.format(bFirst and "TXT_KEY_CITY_STATE_GIFT_FIRST" or "TXT_KEY_CITY_STATE_GIFT_OTHER", iData2)
        end
        if iData3 > 0 then
            parts[#parts + 1] = Text.format(
                bFirst and "TXT_KEY_CITY_STATE_GIFT_FAITH_FIRST" or "TXT_KEY_CITY_STATE_GIFT_FAITH_OTHER",
                iData3
            )
        end
        return Text.joinNonEmpty(parts)
    end

    local pkey = minorPersonalityKey(minorCivID)
    if iData2 == 0 then
        if iData3 == 0 then
            return Text.key("TXT_KEY_MINOR_CIV_CONTACT_BONUS_NOTHING")
        end
        return Text.format("TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP", iData3, pkey)
    end
    local giftKey = "TXT_KEY_MINOR_CIV_" .. (bFirst and "FIRST_" or "") .. "CONTACT_BONUS_" .. szSuffix
    if szSuffix == "UNIT" then
        return Text.format(giftKey, GameInfo.Units[iData2].Description, pkey)
    end
    return Text.format(giftKey, iData2, pkey)
end

function MultiplayerRewards._onCityStateGreeting(minorCivID, iData2, iData3, iFirstMajorCiv, szSuffix)
    if not Game:IsNetworkMultiPlayer() then
        return
    end
    -- The engine pushes the first-contact flag as 1/0 (project hook
    -- convention), and 0 is truthy in Lua, so normalize before the formatter
    -- branches on it.
    emit(cityStateGiftString(minorCivID, iData2, iData3, iFirstMajorCiv == 1, szSuffix))
end

-- Registers fresh listeners on every call (onInGameBoot invokes this once
-- per game load). Even though MP-only feature, the boot wiring runs in SP
-- too -- the gates inside each handler reject the events. Cheap to be
-- always-installed: the engine still raises the events in SP, and our
-- handlers return after a single Game:IsNetworkMultiPlayer() check.
function MultiplayerRewards.installListeners()
    Log.installEvent(
        GameEvents,
        "CivVAccessGoodyHutReceived",
        MultiplayerRewards._onGoodyHutReceived,
        "MultiplayerRewards",
        "goody-hut announces disabled in MP (engine fork not deployed?)"
    )
    Log.installEvent(
        GameEvents,
        "CivVAccessBarbarianCampCleared",
        MultiplayerRewards._onBarbarianCampCleared,
        "MultiplayerRewards",
        "barb-camp announces disabled in MP (engine fork not deployed?)"
    )
    Log.installEvent(
        GameEvents,
        "NaturalWonderDiscovered",
        MultiplayerRewards._onNaturalWonderDiscovered,
        "MultiplayerRewards"
    )
    Log.installEvent(GameEvents, "TeamMeet", MultiplayerRewards._onTeamMeet, "MultiplayerRewards")
    Log.installEvent(
        GameEvents,
        "CivVAccessCityStateGreeting",
        MultiplayerRewards._onCityStateGreeting,
        "MultiplayerRewards",
        "city-state gift announces disabled in MP (engine fork not deployed?)"
    )
end

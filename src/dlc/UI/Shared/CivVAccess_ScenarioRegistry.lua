-- Firaxis scenarios the mod supports end to end, keyed by the scenario's mod
-- ID as Modding reports it, both in the Scenarios list's entries and in the
-- game's activated mods. The Scenarios list offers only these.
--
-- Each entry names two of the scenario's own text keys: its Briefing button
-- label and the briefing that button opens. The button sits on the
-- scenario's turns-left panel, a mouse-only UI addin out of the mod's reach,
-- so ScenarioBriefing reads the same text instead.

ScenarioRegistry = {}

local SCENARIOS = {
    -- American Civil War
    ["55fd836a-72e5-4aba-bbcf-3395b05a0e70"] = {
        briefingLabel = "TXT_KEY_CIVIL_WAR_SCENARIO_BRIEFING_BUTTON",
        briefingText = "TXT_KEY_CIVIL_WAR_SCENARIO_CIV5_DAWN_TEXT",
    },
    -- Scramble for Africa
    ["f2eb1642-3334-4d2c-8db1-08e6aede3532"] = {
        briefingLabel = "TXT_KEY_SCRAMBLE_AFRICA_BRIEFING_BUTTON",
        briefingText = "TXT_KEY_SCRAMBLE_AFRICA_CIV5_DAWN_TEXT",
    },
    -- Conquest of the New World Deluxe
    ["34fb6c19-10dd-4b65-b143-fd00b2c0826f"] = {
        briefingLabel = "TXT_KEY_NEWWORLD_SCENARIO_BRIEFING",
        briefingText = "TXT_KEY_NEWWORLDDLX_SCENARIO_CIV5_NEWWORLD_BRIEFING_TEXT",
    },
}

function ScenarioRegistry.isSupported(modId)
    return SCENARIOS[modId] ~= nil
end

-- Whether this game is a scenario. A World Builder scenario map says so
-- through PreGame. A supported scenario that builds its map from a script,
-- such as Conquest of the New World Deluxe, leaves that flag off, though its
-- own screens still show the scenario's turn limit and score.
function ScenarioRegistry.inScenario()
    return PreGame.GetLoadWBScenario() or ScenarioRegistry.active() ~= nil
end

-- The supported scenario this game is running, or nil. Read from the game's
-- activated mods on every call.
function ScenarioRegistry.active()
    for _, mod in ipairs(Modding.GetActivatedMods()) do
        local scenario = SCENARIOS[mod.ID]
        if scenario ~= nil then
            return scenario
        end
    end
    return nil
end

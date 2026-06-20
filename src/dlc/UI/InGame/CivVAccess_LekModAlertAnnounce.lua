-- Announces LekMod custom-civ ability feedback (Nabatea discovery gold, New
-- Zealand meeting yields, Italy golden-age-from-political-prowess, the wonder
-- "we love the king" gold, Bolivia, and the rest) through the speech pipeline.
--
-- Why this is not a listener on Events.GameplayAlertMessage. LekMod pushes
-- that ability feedback from its own per-civ Lua (the Lekmod_<civ>.lua scripts
-- it loads via LoadNewContext) via Events.GameplayAlertMessage, and that is the
-- only channel it takes. But the engine's pkDLLInterface->AddMessage floods the
-- SAME event with combat, diplomacy, tech, and voting float text on every
-- engine (vanilla, VP, LekMod alike) -- and every one of those is already
-- announced by a dedicated path (combat by the CivVAccessCombatResolved fork
-- hook, the rest by NotificationAnnounce). A blanket GameplayAlertMessage
-- listener therefore double-announced essentially everything. Origin is not
-- recoverable at the listener: both the engine floats and the LekMod pushes
-- arrive as resolved strings with no type tag.
--
-- So instead the LekMod ability feedback is intercepted at its push site. The
-- vendored per-civ ability files (see tools/vendoring/manifest.json, the
-- Lekmod_<civ>.lua lekmod entries) each shadow their file-local Events so
-- Events.GameplayAlertMessage(text) re-raises the text on
-- LuaEvents.CivVAccessLekModAlert before forwarding to the real engine push
-- (which keeps the on-screen float for a sighted partner). This module is that
-- LuaEvent's listener: it speaks and buffers the ability text, and nothing
-- else. Inert on vanilla / VP, where nothing raises the LuaEvent.
--
-- Queued, not interrupt: ability triggers resolve in inter-turn waves (several
-- can fire on one PlayerDoTurn), so queueing keeps each one audible rather
-- than the burst cutting itself down to the last line -- matching
-- NotificationAnnounce and MultiplayerRewards. Filtering is the pipeline's
-- job: speakQueued runs the text through TextFilter, so the raw markup LekMod
-- sends is stripped before it is spoken, and the same raw text stored in the
-- message buffer is filtered again on read-back. The notification category
-- puts the entry on the same Shift+] / Shift+[ filter as engine notifications,
-- since these rewards are conceptually the same shape.

LekModAlertAnnounce = {}

function LekModAlertAnnounce._onAlert(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakQueued(text)
    MessageBuffer.append(text, "notification")
end

function LekModAlertAnnounce.install()
    Log.installEvent(LuaEvents, "CivVAccessLekModAlert", LekModAlertAnnounce._onAlert, "LekModAlertAnnounce")
    Log.info("LekModAlertAnnounce: installed")
end

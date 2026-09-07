# LekMod accessibility gaps

Working list of LekMod surfaces that carry no accessibility coverage. Each entry names the
surface, where its code lives, what a player gets today, and what coverage would mean.
This is a to-do list, not a design doc: when a gap is closed, delete its entry rather than
annotating it. Architecture and the re-pin runbook live in `lekmod-support.md`.

Entries land here when a re-pin surfaces net-new LekMod content the layer does not read.
The re-pin's job is making the existing layer correct against the new drop; covering new
surfaces is separate work, and this file is where that work is remembered.

## Standardized yield breakdown in the empire status detail

Surfaced by the v35.3 re-pin. LekMod's `TopPanel.lua` (staged under `LEKMOD/Lua/tmp/ui`)
now itemizes the culture, faith, and science tooltips through the yield-family getters
(`GetYieldFromCitiesTimes100`, `GetYieldFromOtherPlayersTimes100`,
`GetYieldFromHappinessTimes100`, `GetYieldFromTraitsTimes100`, `GetYieldFromReligionTimes100`,
`GetYieldFromMinorCivsTimes100`, `GetYieldPenaltiesTimes100`, and the new
`GetYieldPerTurnFromMisc`) under the generic `TXT_KEY_TP_YIELD_FROM_*` keys, one line per
source. Our `CivVAccess_EmpireStatus.lua` details still walk the vanilla per-yield getters,
which LekMod keeps registered and correct (free culture and diplomacy gold now live in the
misc bucket, but the vanilla getters read from it), so every value spoken today is right and
the bare-key totals are unaffected. What a player misses is the itemization LekMod's own
tooltip shows a sighted partner: culture from agreements with other players and from
penalties fold into the golden-age residual line, and faith or science from traits, religion,
happiness, and the misc bucket are not listed at all. Coverage means a LekMod body for the
three details that mirrors the new TopPanel handlers, feature-detected on
`GetYieldPerTurnFromMisc` so vanilla and VP keep their existing breakdowns.

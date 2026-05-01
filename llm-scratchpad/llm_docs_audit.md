# llm-docs audit

Audit of `docs/llm-docs/CLAUDE.md` against the actual contents of `docs/llm-docs/` on branch `claude-mod-cleanup`.

## Verified accurate

- **23 lua-api class files** — confirmed by directory listing of `docs/llm-docs/lua-api/` (excluding `_*` and `README.md`).
- **~1,900 distinct methods** — sum of per-class method counts in `lua-api/README.md` is 1919. Index claim is right.
- **227 `Events.X`** — events-catalog.md has 229 `## ` headers, of which 2 are non-event sections ("Reading the entries" and the `SerialEventGameMessagePopup` ButtonPopupTypes block); 229 minus 2 equals 227. Direction breakdown also confirmed: 147 observable + 54 fire-only + 26 mixed = 227.
- **25 `LuaEvents.X`** — confirmed by header count in luaevents-catalog.md and the file's own "Total events cataloged: 25" line.
- **~5,000 keys** in `txt-keys/ui-text-keys.md` — the file states 5028 keys. Index's "~5,000" is accurate.
- **Player.md spot-check** — file is intact with the structure the index describes (per-method headings, signature lines from real call sites, callsite count, example file:line). Player.md self-reports 6264 callsites across 514 methods, matching `lua-api/README.md`.
- **`docs/hotkey-reference.md`** — exists.
- **Extractor scripts** — both `lua-api/_extract.py` and `txt-keys/_extract.py` exist and the regenerate-from-this-directory instruction is consistent with the scripts' hardcoded `OUT_DIR` / output-next-to-script behavior. Both hardcode `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\Assets` as the input root, matching the local install path used elsewhere in this project.

## Corrected

Edits to `docs/llm-docs/CLAUDE.md`:

1. **Callsite count**: changed "~48k classified call sites" to "~54k". The actual extractor total in `lua-api/README.md` line 7 is 53,709 (and `lua-api/Player.md` alone is 6,264). The "~48k" figure was significantly low. Also softened the count claim with "At last extraction:" framing so it reads as a snapshot.
2. **Fork doc scope**: the index claimed `_civvaccess_fork.md` "lists methods our engine fork adds (Unit / Game)". The fork doc itself only covers Unit and Game bindings plus 5 GameEvents hooks (PlotRevealed, GoodyHutReceived, BarbarianCampCleared, ForeignGoodyCleared, ForeignBarbCampCleared). But `CIVVACCESS:` markers in `src/engine/CvGameCoreDLL_Expansion2/` show the fork has grown to also add Plot Lua bindings (`HasLineOfSight`, expanded `GetBestDefender`), additional Unit bindings (`GetBestBuildRoute`, `GeneratePathBetween`, expanded `MoveUnit`), and several more GameEvents hooks (`NukeStart`, `NukeEnd`, `NukeUnitAffected`, `NukeCityAffected`, `CombatResolved`, `AirSweepNoTarget`, `MissionDispatched`). I updated the index entry to flag that the fork doc is stale and direct readers to grep the `CIVVACCESS:` marker for the canonical current list. I did NOT edit the fork doc itself per the rules (generated/derived doc, not an index).
3. **Dangling `docs/technical-reference.md` reference**: that file does not exist anywhere in the repo. Removed the trailing sentence "Also captures partial answers to the open questions in `docs/technical-reference.md` §12" from the External Resources entry.
4. **Snapshot wording**: added "at last extraction" / "currently covers" framing to the events count and fork-doc entry so readers treat them as snapshots rather than asserted current truth.

## Flagged for user

- **Fork reference doc is stale.** `docs/llm-docs/lua-api/_civvaccess_fork.md` only documents Unit/Game bindings and 5 GameEvents hooks. The current fork (per `CIVVACCESS:` markers in `src/engine/CvGameCoreDLL_Expansion2/`) also adds Plot Lua bindings (`HasLineOfSight`, expanded `GetBestDefender`/`MoveUnit`), more Unit bindings (`GetBestBuildRoute`, `GeneratePathBetween`), and at least 7 more GameEvents hooks (`NukeStart`, `NukeEnd`, `NukeUnitAffected`, `NukeCityAffected`, `CombatResolved`, `AirSweepNoTarget`, `MissionDispatched`). The fix is to hand-edit `_civvaccess_fork.md` (it's hand-authored per its own front matter — the extractor doesn't write it). Out of scope for this audit; index now flags the staleness so readers don't trust it blindly.
- **Screen-inventory count is plausible but not exactly verified.** Index claims "168 unique XML stems across all editions; the inventory has 162 screen entries plus 11 support/include entries" (173 total). The file has 174 top-level `- \`X\`` bullets, broken across roughly the right sectioning. Within rounding tolerance — not corrected, but worth a careful recount if the number ever needs to be authoritative.
- **Extractor regenerate instruction uses `python`, not `py`.** Index says `python _extract.py`. Per user's global preferences (memory: "Use py not python3 on Windows"), the command on this machine is `py _extract.py`. Low priority — `python` may also resolve here — but worth a one-word swap if a contributor hits "command not found" on a fresh Windows checkout.
- **Catalog files not regenerated this session.** events-catalog.md and luaevents-catalog.md both reference the shipped game Lua at extraction time but the repo has no extractor script for them (unlike lua-api and txt-keys). If their counts drift after a Civ V patch, regeneration is manual.

---
name: translate-strings
description: Translate the Civ V Access mod's user-facing strings into a target Civ V locale (fr_FR, de_DE, es_ES, it_IT, ja_JP, ko_KR, pl_PL, ru_RU, zh_Hant_HK). Use when the user asks to translate the mod, ship a translation, generate a locale overlay, or run the translation pipeline for a specific language.
---

# Translate mod strings into a target locale

## Argument

The skill takes one argument: a Civ V supported-locale code, exactly as it appears in `Locale.GetCurrentSpokenLanguage().Type`. Valid values: `fr_FR`, `de_DE`, `es_ES`, `it_IT`, `ja_JP`, `ko_KR`, `pl_PL`, `ru_RU`, `zh_Hant_HK`. If no argument is given or the argument is not in this set, ask which locale before proceeding.

Bind the argument to `<LOCALE>` for the rest of this brief.

## Goal

Translate this mod's user-facing strings into the target locale. The mod is a screen-reader-only accessibility layer for blind Civilization V players: every string is spoken by Tolk to NVDA / JAWS / SAPI, never displayed visually. Accuracy beats tone; a missing or wrong translation has no visual fallback for the user to recover from.

## Read first (working rules)

These are the authoritative conventions; everything below extends them.

- `src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua` lines 1-119 (translator orientation block, in-game).
- `src/dlc/UI/FrontEnd/CivVAccess_FrontEndStrings_en_US.lua` lines 1-101 (orientation, front-end).
- The orientation block's "_ALT keys" bullet is critical: those keys are TextFilter dedup targets, not user-facing speech. Their values must match the literal phrase the engine prints adjacent to the corresponding `[ICON_*]` token in the target locale, NOT a translation of the en_US value. Each such key in the source has an inline comment naming the engine TXT_KEY that drives it; grep that key in the target locale's `CIV5GameTextInfos*.xml` to find the right value. If the engine's emission already starts with the icon's primary spoken form word-for-word, the alias is dormant in that locale and `""` is fine.
- `src/dlc/UI/Shared/CivVAccess_Text.lua`. Mod-authored TXT_KEY_CIVVACCESS_* keys go through a local substitute that does NOT do gender agreement; engine `{N_Adjective}` markup is ignored at runtime for our keys. Phrase any template that substitutes a noun to be gender-neutral. Do not write `le {1_Name}` (or the target-language equivalent) and do not rely on adjective inflection.
- `src/dlc/UI/Shared/CivVAccess_PluralRules.lua`. Read the function for the target locale to confirm which CLDR keywords are required (see "Plural keywords by locale" below as a quick reference).
- `src/dlc/UI/Shared/CivVAccess_StringsLoader.lua`. The locale code is `<LOCALE>` exactly.
- Project CLAUDE.md (auto-loaded). Note especially: never tell the user to deploy, deploy is part of the task; PowerShell scripts are authorized; commit-without-Claude-coauthor.

## Deliverables

Four new files (sibling to the en_US originals, same directory, append `_<LOCALE>` before `.lua`):

- `src/dlc/UI/InGame/CivVAccess_InGameStrings_<LOCALE>.lua`
- `src/dlc/UI/FrontEnd/CivVAccess_FrontEndStrings_<LOCALE>.lua`
- `src/dlc/UI/InGame/CivVAccess_ScannerStrings_<LOCALE>.lua`
- `src/dlc/UI/InGame/CivVAccess_SurveyorStrings_<LOCALE>.lua`

One edit: `src/dlc/UI/Shared/CivVAccess_StringsLoader.lua`. Uncomment the `<LOCALE> = true,` line in the `supportedLocales` table.

## Game baseline (already on disk)

Civ V's localized XML data for the target locale lives at these paths. Filesystem is case-insensitive on Windows; the on-disk casing varies (most locales uppercase, `zh_Hant_HK` mixed-case). Glob case-insensitively with the locale code as written.

- `C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V/Assets/Gameplay/XML/NewText/<LOCALE>/*.xml`
- `C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V/Assets/DLC/*/Gameplay/XML/Text/<LOCALE>/*.xml`
- `C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V/Assets/DLC/Expansion/Gameplay/XML/Text/<LOCALE>/*.xml`
- `C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V/Assets/DLC/Expansion2/Gameplay/XML/Text/<LOCALE>/*.xml`
- `C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V/Assets/DLC/Shared/Gameplay/XML/Text/<LOCALE>/*.xml`

XML format: `<Row Tag="TXT_KEY_X"><Text>Localized text</Text></Row>` inside `<Language_<LOCALE>>`. Grep on the `Tag` attribute.

When a string in our source files refers to a Civ V concept (turn, era, embark, raze, ally, golden age, social policy, ideology, tenet, great work, citizen, wonder, ready / disabled in pre-game lobby UI, etc.), find the matching base-game TXT_KEY in those XMLs and adopt the word the base game uses. Do not invent parallel terminology. Players hear our speech alongside the engine's own TTS-of-screen-text in the same language and any clash sounds wrong.

Pre-flight: glob `**/<LOCALE>/*.xml` under the install root and confirm at least one XML loads. If absent, stop and ask the user to install the language pack via Steam properties.

## Constants (locked before translation begins)

- Locale code: `<LOCALE>`.
- Register: derive from the base game. Spot-check 5 to 10 common base-game TXT keys (e.g. `TXT_KEY_END_TURN_BUTTON_HELP_TEXT`, `TXT_KEY_TUTORIAL_*`, `TXT_KEY_NOTIFICATION_*`) to confirm whether the locale's Civ V text uses formal or informal address, then match it across every translation. For French this is `vous`; German `Sie`; Russian `Вы`; Polish formal `Pan/Pani` constructions; Spanish `tú` (Latin American Civ V text); Italian `tu` or `Lei`; Japanese desu/masu form; Korean haeyo / hapsyo level. Do not assume — check.
- Punctuation: ASCII PUNCTUATION marks only — straight apostrophe `'`, ASCII hyphen `-`, period, comma, colon, parentheses, percent, slash. No smart quotes (no curly `'…'`, no guillemets `«»`, no Asian double quotes `「」`), no em-dashes, no full-width punctuation, no ellipsis character `…`. Reason: Tolk pipes raw bytes to the screen reader; replacing ASCII punctuation with locale-typographic punctuation can change how the TTS engine pronounces the mark, including for CJK locales where TTS engines may pronounce full-width chars distinctly.
- Letters: accented letters in the target language are MANDATORY where the language requires them (`é è ê à â ô î ù û ç` in French; `ä ö ü ß` in German; `ñ á é í ó ú` in Spanish; `à è é ì ò ù` in Italian; `ą ć ę ł ń ó ś ź ż` in Polish; the Cyrillic alphabet plus `ё` in Russian). Lua source files are UTF-8 and the engine handles UTF-8 strings without ceremony. The single most common failure mode in past runs was agents misreading "ASCII only" as forbidding accented letters and emitting "pret" / "preparation" / "tete" instead of "prêt" / "préparation" / "tête". The punctuation rule and the letter rule are independent. Every batch prompt MUST distinguish them explicitly, and prose-heavy slices (especially leader-portrait blocks) regress on this rule first.
- Numerals: ASCII digits.
- Casing: match the source value pattern key by key. If en_US is a lowercase tail token with no terminal punctuation, the translation is the same shape. If en_US is a complete sentence with terminal period, the translation is the same. Apply the target language's capitalisation rules within those constraints; do NOT capitalise tail tokens that are lowercase in the source. (CJK locales: tail tokens have no case; keep them as written.)
- Format placeholders: `{1_Name}`, `{2_Cur}`, etc. The numeric index is positional; you may reorder placeholders to fit target-language word order, but you must NOT renumber. The `_Tag` suffix after the underscore is ignored at runtime; treat it as a translator hint.
- Comment policy in the new files: keep the section-header comments that mark structure (the `===== ... =====` lines and topical headers like `-- Unit speech.`) in English so the orchestrator can concatenate batches by source order. Drop the per-key explanatory comments that justify English-side wording; those are en_US authorship notes, not runtime context, and translating them is wasted effort. The translated file should be much shorter than the en_US source as a result.
- Distinguishing word first (concise-announcement rule): keep when grammatical in the target language. When the language requires a different word order (German subordinate-clause verb-final, Japanese SOV, Korean SOV), defer to grammaticality. Do not produce ungrammatical output to satisfy the rule.

## Plural keywords by locale

Provide every keyword required for the target locale's CLDR rules; omit forms the language doesn't use. Authoritative source: `src/dlc/UI/Shared/CivVAccess_PluralRules.lua` — read the function for the target locale and use the exact keywords it returns.

- `fr_FR`, `de_DE`, `es_ES`, `it_IT`: `one` (n == 0 or 1) plus `other`.
- `pl_PL`: `one`, `few`, `many`, `other`.
- `ru_RU`: `one`, `few`, `many`, `other`.
- `ja_JP`, `ko_KR`, `zh_Hant_HK`: `other` only — no grammatical plural distinction. Plural-form bundles in these locales use a single `other` form.

Verify by reading PluralRules.lua before translating any plural bundle. If a bundle keyword is missing at runtime, the wrapper falls back through `other` to `one` to first-form, but absent forms produce awkward agreement; provide what the language requires.

## Workflow ordering

Run translations in this order, smallest first:

1. Surveyor + Scanner (the two smallest files). Validates the prompt template and per-batch grammar before committing larger work. If these come back with stripped accents — by far the most common failure mode — fix the prompt before launching the rest.
2. FrontEnd (single batch).
3. InGame body — the InGame strings minus the leader-portrait prose. Split into 100-key batches per the Batching section. The `TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_*` keys are carved out and handled separately.
4. Leader-portrait prose — see "Leader-portrait prose: separate workflow" below. Subbatched (~10-12 leaders per batch), translated, then a grammar polish pass. Treat as its own pipeline; the prose is qualitatively different from everything else and the per-key requirements are distinct.
5. Concatenation, validation, deploy.

Don't try to ship all of these in a single dispatch wave. The small-files step is also a feedback loop on the prompt template.

## Vocabulary lock (build first, before any translation batch)

Step 1 of the workflow. Builds the consistency floor that every batch enforces.

1. Scan the four en_US source files for recurring tail tokens: short lowercase phrases that appear standalone or as `, <token>` glue in composed announcements. Likely list (verify by grepping): queued, ready, host, selected, available, locked, blocked, filled, disabled, here, empty, canceled, embarked, razing, paused, resumed, pinned, full, none, all, on, off, ally, neutral, enemy, friendly, hostile, my, mine, theirs.
2. For each, pick one target-language translation. Cross-check against base-game `<LOCALE>` XMLs where the same concept appears. Many of these have canonical base-game equivalents — search the FrontEndScreens / Civilizations / Diplomacy / WorldView text for matches. Examples to look up rather than guess: ready (lobby), embarked (unit status), raze (city action), ally / neutral / enemy / friendly (relation), turn, era, golden age.
3. Keep the lock as a flat dictionary `{ english: <LOCALE>-translation }`. Pass it verbatim to every batch subagent.

## Batching

The InGame strings file cannot fit in one task; input plus output approaches the token ceiling. Split by the natural section-header boundaries already in the source. The file is organised into thematic blocks: unit speech, combat preview, plot/cursor glance, BaseMenu, leader popup, advisor, production, tech, social policies, religion, espionage, league, etc.

FrontEnd, Scanner, and Surveyor each fit in a single task.

Use fresh general-purpose subagents (not forks). Fresh agents avoid cross-batch context drift; the vocabulary lock travels in the prompt.

### Model

Use Sonnet (`model: "sonnet"` on the Agent call), not Opus. Opus thinks longer per token and in past runs timed out at 100-key slices (15+ minute durations, stream idle timeouts, no file written). Sonnet handles a 100-key short-string slice in 2-3 minutes and a prose-heavy slice in 5-9 minutes.

### Slice sizing

- Short-string sections (tail tokens, settings labels, hotkey help, status info, single-line announcements): 100 keys per batch.
- Prose-heavy sections (multi-sentence descriptions, help text): 50-75 keys per batch.

The InGame body's structure mixes these. Inspect the section boundaries before slicing — pure-prose blocks should be carved out and handled separately, not slotted into uniform 100-key batches. The leader-portrait prose specifically gets its own pipeline (see "Leader-portrait prose" below).

### Wave size

Dispatch in waves of 4-5 parallel agents max. Past runs that launched 10 agents in a single message saw cascading stream timeouts. Schedule a wakeup between waves and dispatch the next wave when the current one's outputs have landed.

### Verify on disk, not by self-report

Agents will sometimes self-report key counts inaccurately ("66 keys" when the file actually has 100; or counting plural-bundle forms separately and conflating that with key counts). After each batch's file lands, verify by grepping `CivVAccess_Strings\["` in the output and comparing to a grep of the source slice. Fix mismatches before concatenation.

### Per-subagent prompt template

Orchestrator fills in the angle-bracket placeholders.

    Translate a slice of CivVAccess_InGameStrings_en_US.lua into <LOCALE>.

    The mod is a screen-reader-only accessibility layer for blind Civ V players. Strings are spoken, never displayed. Accuracy over tone.

    Read first: src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua lines 1-119 (the orientation block).

    CRITICAL — accented letters vs ASCII punctuation:
    - Accented letters in <LOCALE> (<orchestrator lists target-language accents, e.g. "é è ê à â ô ù û ç" for French) are MANDATORY where the language requires them. Do NOT strip them. Lua / Civ V handle UTF-8 strings without ceremony.
    - "ASCII only" applies to PUNCTUATION marks: apostrophe, hyphen, period, comma, colon, parentheses. NOT to accented letters. The two rules are independent.

    Anchor — the desired prose style for this locale:
    Source: <orchestrator inserts a short representative source sentence>
    Target: <orchestrator inserts the correctly-translated version with all required accents inline>

    Constants (do not deviate):
    - Register: <orchestrator inserts the register decided in step 1, e.g. "vouvoiement, formal vous">.
    - Punctuation: ASCII only (apostrophe, hyphen, period). No em-dashes, smart quotes, guillemets, full-width chars, ellipsis character.
    - Accented letters: required, see above.
    - Numerals: ASCII digits.
    - Casing: match each source value's pattern. Lowercase tail tokens stay lowercase, no terminal punctuation. Sentences keep their capital and period.
    - Placeholders: {N_Tag}. You may reorder, you must NOT renumber.
    - No gender-agreement markup. Runtime substitutes raw values; the translator can't inflect them. Phrase neutrally; if no neutral phrasing exists, choose mild awkwardness over ungrammatical-for-most-values.
    - Plural-form bundles: provide <orchestrator inserts the CLDR keywords required for this locale>. All required forms must be present.
    - For Civ V proper concepts (turn, era, embark, raze, etc.), grep the base game's <LOCALE> XMLs and adopt the canonical word. Paths: <orchestrator inserts the five paths>. Format: <Row Tag="TXT_KEY_X"><Text>localized</Text></Row>.

    Vocabulary lock (use these exact target-language words for these English tokens, every occurrence; accents inline):
    <orchestrator inserts the flat dictionary built in step 1>

    Forbidden unaccented patterns (must return zero hits in your output's string values):
    <orchestrator inserts the locale-specific list — see "Forbidden patterns by locale" below>

    Slice to translate: lines <X>-<Y> of src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua.

    Output spec:
    - Write raw Lua source to <output path>; do NOT wrap in a fenced block.
    - File starts with: `-- Batch <N> (lines <X>-<Y>): <description>`
    - Same key names, same key set, same source order.
    - Same plural-bundle shape, with the locale's required CLDR keywords.
    - Drop per-key explanatory comments. Keep section-header comments in English so the orchestrator can concatenate by source order.
    - No `CivVAccess_Strings = ...` header line; the orchestrator concatenates and adds the file header once.

    MANDATORY self-validation BEFORE reporting done:
    1. Grep your output for `CivVAccess_Strings\["` and confirm the count matches the source slice's key count.
    2. Grep your output for each forbidden unaccented pattern listed above. Each MUST return zero hits inside string values (matches inside English comments are fine — your output should have dropped those anyway).
    3. If either check fails, fix and re-write. Do NOT report done until both checks pass.

    After validation, return: filename, key count, and one accent-verification spot-check (quote any one translated value containing accented letters).

## Forbidden patterns by locale

These are high-frequency words in the target language that almost always carry an accent. Including them in the batch prompt as a "must return zero hits" list catches the most common accent-stripping failure mode. Build the list during the vocabulary-lock step (it's the same kind of work — identifying recurring high-frequency words). Hand it to every batch agent in the prompt.

- `fr_FR`: `\bcote\b` (côté), `\bapres\b` (après), `\bpres\b` (près), `\btres\b` (très), `\bsiecle\b` (siècle), `\bplutot\b` (plutôt), `\bforet\b` (forêt), `\btete\b` (tête), `\bdeja\b` (déjà), `\bderriere\b` (derrière), `\bpremiere\b` (première), `\bderniere\b` (dernière), `\beleve\b` (élevé), `\bepaule\b` (épaule), `\becharpe\b` (écharpe), `\bpale\b` (pâle when meaning pale), `\bdesactive\b` (désactivé), `\bpret\b` (prêt), `\bportee\b` (portée), `\bapercu\b` (aperçu), `\bantiquite\b` (antiquité), `\bCongres\b` (Congrès).
- `de_DE`: `\bueber\b` (über), `\bfuer\b` (für), `\bschoen\b` (schön), `\bnaeher\b` (näher), `\bgroesser\b` (größer), `\bweiss\b` may be `weiß`.
- `es_ES`: `\bnino\b` (niño), `\bespanol\b` (español), `\baccion\b` (acción), `\bproximo\b` (próximo), `\binformacion\b` (información).
- `it_IT`: `\bperche\b` (perché), `\bpiu\b` (più), `\bcitta\b` (città), `\bgia\b` (già), `\bpoi\b` is fine, `\bcosi\b` (così).
- `pl_PL`: words with stripped diacritics — `\bjuz\b` (już), `\bksiazka\b` (książka), `\bczesc\b` (cześć).
- `ru_RU`: pay attention to `ё` (commonly stripped to `е` in informal text but TTS pronounces them differently); flag specific words such as `\bвсе\b` when the meaning is "everything" (should be `всё`), `\bещё\b` vs `\bеще\b`.
- `ja_JP`, `ko_KR`, `zh_Hant_HK`: full-width vs half-width punctuation is the analogue. Flag any half-width Latin punctuation in CJK strings if the locale convention prefers full-width, and vice versa. There is no accent equivalent.

## Leader-portrait prose: separate workflow

The `TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_*` keys are qualitatively different from everything else in the file. Each is a multi-paragraph English-prose description of a leader portrait, ~150-300 words, spoken in full when the user inspects a portrait. They demand natural-sounding literary prose in the target language, and they're where the translation pass most reliably regresses on accents and gender agreement when slotted into the regular short-string batches.

Treat them as their own pipeline. Do not try to fold them into the InGame body batches.

1. **Extract** the LEADER_DESC keys and their en_US source values into JSON batches under `build/<locale>_translation/`. Roughly 10-12 keys per batch, balanced by character count (the leaders' descriptions vary ~300-1500 chars each). Use a Python script: regex-match `TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_*` keys, dump batches as `_leaders_batch_NN.json` with shape `[{key, en}, ...]`.

2. **Translate** by dispatching one Sonnet agent per batch. Beyond the regular per-batch prompt rules, the leader-prose prompt MUST include:
   - The accents-are-mandatory rule, prominently and with the forbidden-pattern list inline.
   - An anchor example sentence — one English source sentence and its fully-accented target translation — so the agent has a concrete style target. (For French: Napoleon's first sentence is a useful anchor.)
   - A proper-noun policy: which historical figures are translated to native-language forms vs kept in original spelling. For French: Napoléon, Catherine II, Élisabeth, Théodora, Casimir III, Auguste, Soliman are translated; Ahmad al-Mansour, Attila, Gengis Khan, Sejong, Shaka, Wu Zetian stay in original spelling.
   - A foreign-loanword policy: regalia and place names (Szczerbiec, Tsarskoïe Selo, kavuk, sorguç, gonryongpo, ahu'ula, kapanice, mahiole, tagelmust, boubou, etc.) keep their original spelling unchanged.
   - Mandatory self-grep: agent verifies zero hits for the forbidden-pattern list before reporting done.
   - Output: same JSON array shape with `<locale>` field added per entry.

3. **Polish** by dispatching a second wave of Sonnet agents — one per batch — for grammar-only review. The polish-pass prompt:
   - DO NOT touch accents (already correct from step 2).
   - Fix only gender / number agreement on adjectives, past participles, articles, demonstratives, possessives. Subject-verb agreement. Light idiom polish where a calque reads clearly wrong; not heavy stylistic rewriting.
   - Provide a list of common gender pitfalls. For French: feminine — épaule, épaulette, écharpe, couronne, poitrine, main, tête, épée, robe, jupe, ceinture, barbe, peau, gorge, ville. Masculine — cheval, manteau, gilet, pantalon, chapeau, casque, bouclier, trône, sceptre, front, cou, corps, bras, regard, visage. Adapt the list to the target locale.
   - Output: same JSON array shape with a `<locale>_polished` field added.

4. **Merge** the polished values back into the main InGame file. A Python script that, for each LEADER_DESC key, replaces the existing value in the on-disk file via regex substitution. Verify every LEADER_DESC key was patched; warn on any that didn't substitute.

5. **Validate** again (key count, plural shape, placeholder indices, parse-test under Lua 5.1). Re-run `./test.ps1`.

6. **Redeploy** with `./deploy.ps1 -SkipEngine`.

The leader-prose batches typically take 4-9 minutes each on Sonnet (longer than short-string batches). Plan for the longer turnaround when scheduling wakeups between waves.

## Output shape rules per file

- Filename: `<stem>_<LOCALE>.lua` matching the en_US sibling.
- First line: brief locale comment, e.g.: `-- Mod-authored strings, <LOCALE> overlay. Baseline in <stem>_en_US.lua.`
- Then: `CivVAccess_Strings = CivVAccess_Strings or {}`
- Then: key assignments in source order, one per line where the en_US line was a one-line assignment, multi-line for plural bundles.
- Same key set as en_US: every TXT_KEY_CIVVACCESS_* in en_US must appear in the new file. None added, none removed.
- Plural-bundle shape: tables with the locale's required CLDR keywords (see Plural keywords by locale). The keys are different per language; the requirement is "all forms the language needs, none it doesn't."
- Same placeholder index set per key: the set of `{N_...}` index numbers in the new file must equal the set in en_US, ignoring order.

## Validation (before flipping the loader flag)

1. Key-set diff: extract keys from each new file and its en_US counterpart via regex `CivVAccess_Strings\["(TXT_KEY_CIVVACCESS_[A-Z0-9_]+)"\]`. Set diff must be empty in both directions. Missing keys mean a batch lost entries; re-run that batch.
2. Plural-bundle shape diff: for every key whose en_US value is a Lua table, the new value must be a table with at least the locale's required CLDR keywords.
3. Placeholder-index diff per key: the set of `{N_...}` indices in the new file equals the set in en_US.
4. Run `./test.ps1` from the repo root. The new locale has no direct test coverage but a malformed Lua table surfaces as a parse error.
5. Run luacheck on each new file. Strings files are flat assignments; any warning is real.

If 1-5 pass: edit `src/dlc/UI/Shared/CivVAccess_StringsLoader.lua` to uncomment the `<LOCALE> = true,` line in `supportedLocales`. Then run `./deploy.ps1 -SkipEngine` from the repo root (engine DLL is untouched; skip the engine deploy for speed).

## Smoke-test instructions for the user

After deploying, ask the user to:

- Set Civ V's spoken-language to the target locale (in-game options, or `config.ini` with `Language = "<LOCALE>"`).
- Launch the game.
- Front-end Boot announcement (`TXT_KEY_CIVVACCESS_BOOT_FRONTEND`) should speak in the target language. If not, the loader entry isn't flipped or the file isn't in the VFS.
- Enter a game; in-game Boot announcement (`TXT_KEY_CIVVACCESS_BOOT_INGAME`) should speak in the target language.
- Ctrl+Shift+F12 toggles mute; pause / resume should speak in the target language.
- A few cursor announcements over varied terrain to spot-check tail tokens and proper-noun consistency.

User reports back; iterate from there. Expect a follow-up pass to fix tokens that read poorly through the user's TTS voice (homographs, awkward abbreviations, register slips, gendered phrasings that fail on specific noun substitutions).

## What NOT to do

- Do not translate Civ V proper nouns (unit, leader, civilization, building, tech, policy, wonder names). Those flow from the base game's own `<LOCALE>` data through `Locale.ConvertTextKey` at runtime; they are NOT in the strings files we own.
- Do not modify any non-strings file beyond the StringsLoader entry-flip.
- Do not change placeholder indices.
- Do not add CLDR plural keywords the language does not use, and do not omit ones it does.
- Do not add gender-agreement markup (`{N_Adjective}`, `{N_NumNoun}`). It does not apply to mod-authored keys.
- Do not use Opus for the per-batch agents. It times out at 100-key slices. Use Sonnet.
- Do not dispatch 10+ agents in a single wave. Cap at 4-5 parallel.
- Do not trust an agent's self-reported key count or accent count. Verify on disk.
- Do not slot leader-portrait prose into the regular short-string batches. Carve them out and run the separate workflow.
- Do not commit, push, or open a PR. The user reviews first.
- Do not run the game.

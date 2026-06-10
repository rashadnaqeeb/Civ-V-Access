---
name: sync-translations
description: Sync the 10 non-en_US locale strings files to match en_US after en_US has changed. Use when the user asks to sync translations, propagate string changes to locales, update locale files after a feature, or run the translation-sync pipeline. Reads the diff between en_US and the last locale commit, then updates fr_FR / de_DE / es_ES / it_IT / ja_JP / ko_KR / pl_PL / pt_BR / ru_RU / zh_Hant_HK to match.
---

# Sync locale strings with en_US

## Goal

The en_US strings files are the source of truth. The 10 locale overlays (fr_FR, de_DE, es_ES, it_IT, ja_JP, ko_KR, pl_PL, pt_BR, ru_RU, zh_Hant_HK) get updated only by this skill: they should always match the en_US key set, with locale-appropriate translations of every value.

pt_BR is the Civ5-PTBR community language pack (not a Firaxis-shipped locale); the other 9 are official. The sync treatment is identical -- pt_BR is a full peer of the official locales, not an afterthought.

This skill handles three kinds of drift, computed as a diff between en_US-now and en_US-at-last-sync (the most recent commit at which every locale's key set still matched en_US):

- ADDED keys: present in en_US-now, absent at base. Translate fresh into all 10 locales.
- REMOVED keys: present at base, absent in en_US-now. Delete from all 10 locales.
- CHANGED keys: present in both, value differs. Retranslate in all 10 locales using the new English.

The en_US source files are the stems registered in the `STEMS` table of `.claude/skills/sync-translations/diff.py` (mirrored in `validate.py`): the four core UI stems (InGame, FrontEnd, Scanner, Surveyor) plus one description-strings stem per F2 describe feature. The scripts' tables are the authoritative list; when a feature adds a new strings stem, it must be registered in both or the sync silently skips it.

A newly registered stem has no locale siblings yet. Its entire key set arrives in the diff as ADDED, and the per-locale agents must create the `_<LOCALE>.lua` files rather than edit them -- same directory as the en_US file, mirroring the two-line header-comment shape and the `CivVAccess_Strings = CivVAccess_Strings or {}` opener of any existing overlay (e.g. `CivVAccess_GreatWorkDescStrings_de_DE.lua`). Overlay files never call `StringsLoader.loadOverlay`; only the en_US baseline does.

## Read first

- `.claude/skills/translate-strings/SKILL.md`. The translation conventions there apply here unchanged: ASCII punctuation, mandatory accented letters, register match, vocabulary lock from base-game `<LOCALE>` XMLs, no English placeholders, no gender-agreement markup, plural keywords from CivVAccess_PluralRules. This skill is the per-key update path; that skill is the bulk-translate path.
- `src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua` lines 1-119. The translator orientation block; every per-key rule (concise, ASCII punctuation, lead with distinguishing word, mirror plural-bundle shape, etc.) applies.
- `src/dlc/UI/Shared/CivVAccess_PluralRules.lua` for the locale's required CLDR keywords when adding or retranslating a plural-form bundle.
- Project CLAUDE.md (auto-loaded). Note especially: deploy is part of the task; PowerShell is allowed; commit-without-Claude-coauthor.

## Workflow

### Step 1: compute the diff

Run the helper from the repo root:

    py .claude/skills/sync-translations/diff.py

It finds the base rev -- the most recent commit at which every locale's key set still matched en_US -- then dumps a JSON diff for each registered stem: added / removed / changed keys, plus the source order at HEAD. A stem whose locale files don't exist on disk yet (brand-new feature stem) doesn't constrain the base rev; it just diffs as all-added. The base rev is found by walking history, not by taking the latest commit that touched a locale file: a repo-wide formatting or lint commit rewrites the locale files without changing translation content, and taking it as the base would silently hide every en_US change made before it. Pass `--base <rev>` to override the detection.

If it errors with "No prior locale-file commit found", the locales have never been seeded -- hand off to translate-strings instead, this skill is for incremental updates.

Save the output for reference:

    py .claude/skills/sync-translations/diff.py > build/sync-translations/diff.json

### Step 1b: set aside icon dedup aliases

If the diff's added or changed sets contain any `TXT_KEY_CIVVACCESS_ICON_*_ALT` key, drop those keys from the diff before going on. They are not translatable text. An `_ALT` key is a TextFilter dedup target whose value must be the exact word the engine prints next to the icon in each locale, copied from the game's localized XML; translating the English value produces a wrong value that fails silently and is never caught.

These keys are maintained by `tools/icon_dedup_aliases.py`, whose ALIASES table holds the reviewed per-locale values with provenance. An `_ALT` key reaching this diff means that tool was not run: add the key to its table and run `py tools/icon_dedup_aliases.py` (it writes every locale at once), rather than handing it to a translation subagent. translate-strings/SKILL.md states the same rule for the bulk-seed path.

### Step 2: build usage context

For every key in added or changed, grep the codebase to find where it's spoken:

    grep -rn "TXT_KEY_CIVVACCESS_X" src/

Capture for each key:
- Which feature module references it (file path).
- The immediate code context (one or two lines surrounding the reference).
- Any neighboring keys that compose into the same announcement -- shared vocabulary lock.

For removed keys, no usage check is needed; if they're truly gone from en_US they are gone from the codebase too. Spot-check one or two anyway to confirm the en_US-now grep returns empty.

### Step 3: pick inline vs. subagents

Count the total added + changed keys across all stems.

**Inline (do it yourself, no subagents)** when:
- 5 or fewer keys total, AND
- you are confident in the translation for each locale (short tail tokens, well-established mod vocabulary, or near-trivial edits like a punctuation tweak).

For inline, read the existing locale file to confirm the surrounding vocabulary, then Edit the value directly. If you are not confident in any one locale's translation, escalate that single locale to a subagent rather than dropping English placeholder text.

**Subagent dispatch (one Sonnet agent per locale, parallel)** when:
- 6 or more keys total, OR
- the new keys are prose / multi-sentence / domain-loaded, OR
- you are unsure of register or vocabulary in any locale.

Dispatch all 10 in a single message (one Agent call per locale, batched). Ten parallel Sonnet agents run fine in one wave; there is no need to split into smaller waves.

Use `model: "sonnet"` on every Agent call. Opus times out on translation tasks; this is documented in translate-strings.

### Step 4: subagent prompt template

When dispatching, hand each agent a self-contained brief. Fresh agents have zero context.

    Sync the <LOCALE> overlay of CivV Access mod strings with the new en_US baseline.

    The mod is a screen-reader-only accessibility layer for blind Civ V players. Strings are spoken by Tolk through NVDA / JAWS / SAPI, never displayed. Accuracy beats tone.

    Read first:
    - src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua lines 1-119 (translator orientation).
    - src/dlc/UI/InGame/CivVAccess_<LOCALE>* and src/dlc/UI/FrontEnd/CivVAccess_<LOCALE>* -- the existing locale files. The vocabulary you produce must match what's already there (same word for "queued", "ready", "embarked", etc.).
    - src/dlc/UI/Shared/CivVAccess_PluralRules.lua, the function for <LOCALE>, for required CLDR keywords on plural-form bundles.

    Constraints (do not deviate):
    - Register: match what the existing <LOCALE> overlay already uses. Spot-check 5+ existing entries to confirm.
    - Punctuation: ASCII only -- straight apostrophe, ASCII hyphen, period, comma, colon, parentheses. No em-dashes, smart quotes, guillemets, full-width punctuation, ellipsis character. Tolk pipes raw bytes to TTS; locale-typographic punctuation can change pronunciation.
    - Accented letters in <LOCALE> are MANDATORY where the language requires them. (For French: e e e a a o i u u c. For German: a o u s. For Spanish: n a e i o u. For Italian, Polish, Russian: similar rule -- whatever the language requires.) Lua / Civ V handle UTF-8 strings. Do NOT strip accents. The two rules are independent: ASCII applies to PUNCTUATION marks, accented letters in TEXT are required.
    - Numerals: ASCII digits.
    - File encoding: UTF-8 with NO byte-order mark. Never introduce a BOM -- the en_US files have none and Lua's dofile rejects one.
    - Casing: match each source value's pattern. Lowercase tail tokens stay lowercase, no terminal punctuation. Sentences keep their capital and period.
    - Placeholders {N_Tag}: index is positional. You may reorder, you must NOT renumber.
    - No gender-agreement markup. Mod-authored keys bypass engine selectors at runtime; phrase neutrally.
    - Plural-form bundles use the locale's CLDR keywords required by PluralRules.lua. All required forms present, none extra.
    - For Civ V proper concepts (turn, era, embark, raze, golden age, ally, etc.), grep the base game's <LOCALE> XMLs at:
        C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V/Assets/Gameplay/XML/NewText/<LOCALE>/*.xml
        C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V/Assets/DLC/Expansion/Gameplay/XML/Text/<LOCALE>/*.xml
        C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V/Assets/DLC/Expansion2/Gameplay/XML/Text/<LOCALE>/*.xml
        and adopt the canonical word the base game uses. Format: <Row Tag="TXT_KEY_X"><Text>localized</Text></Row>.

    Diff to apply (JSON):
    <orchestrator inserts the per-stem subset of build/sync-translations/diff.json relevant to this locale -- the same diff applies to all locales, so the full JSON is fine>

    Usage context per key:
    <orchestrator inserts the grep results for each added/changed key>

    Locale files to modify (Edit in place; if a file does not exist yet --
    brand-new stem -- CREATE it next to its en_US sibling, mirroring the
    header-comment shape and `CivVAccess_Strings = CivVAccess_Strings or {}`
    opener of an existing overlay; never add a StringsLoader.loadOverlay
    call to an overlay file):
    <orchestrator lists the _<LOCALE>.lua sibling of every stem that has
    entries in this diff>

    For each diff entry:
    - ADDED: insert the translated assignment in source order. Find the en_US-source-order predecessor key (the previous key in head_order that exists in the locale file too) and insert the new line after it. For multiple consecutive new keys, group them.
    - REMOVED: delete the assignment line (and full bundle for plural-form values).
    - CHANGED: Edit the existing assignment's value. The "old" English in the diff is informational -- the existing locale translation is what's literally in the file now. If the English change is small (punctuation, word swap), mirror that change minimally; if it is a full reword, retranslate from scratch.

    Preserve unchanged translations exactly. Do NOT regenerate the whole file. Do NOT touch comments. Do NOT modify keys not in the diff.

    MANDATORY self-validation BEFORE reporting done:
    1. Re-read each modified file; confirm only the diff's keys changed.
    2. Confirm no English text appears in any string value you wrote.
    3. Confirm no forbidden punctuation (em-dash, smart quotes, ellipsis character, guillemets, full-width chars) in any string you wrote.
    4. Confirm every plural bundle has the locale's required CLDR keywords.
    5. Confirm placeholder indices in your translations match the en_US source.
    6. Confirm each file you edited still starts with no UTF-8 BOM.

    Report: filename per file you edited, count of keys added / removed / changed, and one accent-verification spot-check (quote any one translated value containing an accented letter, if the locale uses accents).

### Step 5: validate

After all locale updates land (inline or via agents), run the validator:

    py .claude/skills/sync-translations/validate.py

It checks every registered stem across all 10 locales and reports every problem at once: locale file exists, key set matches en_US (no missing / extra keys), every en_US plural bundle is a bundle in the locale with that locale's required CLDR keywords (and a scalar stays a scalar), `{N_*}` placeholder index sets match en_US per key, and no file carries a UTF-8 BOM. It exits nonzero and lists each failure, or prints OK.

Fix every failure -- edit the locale file directly, or re-dispatch the locale's agent on the broken subset -- and re-run until it prints OK. Strip a BOM by rewriting the file without its first 3 bytes. Do not proceed to deploy while the validator fails.

The validator checks the whole locale set, not just this sync's diff, so a pre-existing structural defect outside the diff will surface here too. Fixing one is correct, but it is a separate change from the sync -- call it out explicitly when reporting in Step 7 rather than folding it in silently.

Then run `./test.ps1` from the repo root; a malformed Lua table surfaces as a parse error. Optionally `luacheck` each modified locale file -- strings files are flat assignments, so any warning is real.

### Step 6: deploy

    ./deploy.ps1 -SkipEngine

Engine DLL is untouched; skip the engine deploy for speed. Per the project CLAUDE.md, deploy is part of the task -- never tell the user to run it; run it yourself.

### Step 7: report

Tell the user:
- The base rev the diff was computed against.
- Counts: added / removed / changed across all stems.
- Whether the work was done inline or via subagents.
- Any pre-existing structural drift the validator surfaced outside the sync diff, and whether you fixed it.
- That deploy.ps1 -SkipEngine ran successfully (or any error from validation / deploy).

Don't commit. Don't open a PR. The user reviews first.

## Constraints

- This skill is for INCREMENTAL updates to existing locale files. If a locale is missing entirely, hand off to translate-strings instead.
- Never use English text as a placeholder in non-en_US files. If a translation is genuinely uncertain, escalate that locale to a Sonnet agent or ask the user.
- Never modify any non-strings file beyond the locale strings you are syncing.
- Never modify a key that is not in the diff. Drift outside the diff is a regression.
- Never change placeholder indices. Reorder freely; renumber never.
- Never add CLDR plural keywords the language does not use, and never omit ones it does.
- Never add gender-agreement markup. It does not apply to mod-authored keys.
- Never translate a `TXT_KEY_CIVVACCESS_ICON_*_ALT` key. Its value is a word copied from the game's localized XML, not a translation; `tools/icon_dedup_aliases.py` owns it. See Step 1b.
- Never run the game.
- Never commit, push, or open a PR. The user reviews first.

## Files

- `.claude/skills/sync-translations/diff.py` -- orchestrator that finds the base rev, dumps en_US strings at base and HEAD via Lua, and emits a JSON diff per stem.
- `.claude/skills/sync-translations/dump_strings.lua` -- the Lua dumper invoked by diff.py and validate.py. Loads a strings file via dofile and emits its CivVAccess_Strings table as JSON.
- `.claude/skills/sync-translations/validate.py` -- structural validator run in Step 5: file existence, key sets, plural-bundle CLDR shape, placeholder indices, and BOM check across every registered stem and all 10 locales.

## What NOT to do

- Do not regenerate locale files from scratch. This is an incremental sync; preserve unchanged translations.
- Do not touch the en_US file -- it is the source of truth, this skill consumes it but never writes to it.
- Do not flip the StringsLoader supportedLocales table. All 10 locales should already be enabled; this skill never adds a new locale (translate-strings handles the 9 official ones; pt_BR is community-seeded).
- Do not use Opus for subagents. It times out on translation work. Sonnet handles a 30-key sync slice in a few minutes.
- Do not trust an agent's self-report on counts; verify on disk against the diff JSON.
- Do not slot prose-heavy changes (multi-sentence descriptions, leader-portrait edits) into the same agent as short-string edits without flagging the prose for extra accent verification. The prose is where accent-stripping regresses first.
- Do not commit, push, or open a PR. The user reviews first.

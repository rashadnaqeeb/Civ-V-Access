"""
Diff en_US strings files between the last-translated commit and HEAD.

Usage: py .claude/skills/sync-translations/diff.py [--base REV]

Output (JSON to stdout):
  {
    "base_rev": "<sha>",
    "stems": {
      "InGame": {
        "path": "src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua",
        "added":   {key: new_value, ...},
        "removed": {key: old_value, ...},
        "changed": {key: {"old": old_value, "new": new_value}, ...},
        "added_order": [keys in source order],
        "head_order":  [all keys at HEAD in source order]
      },
      ... one entry per STEMS entry ...
    }
  }

The "old"/"new"/"value" entries are scalars (strings) or plural-form bundles
({"one": "...", "other": "...", ...}).
"""

import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path


LOCALES = [
    "fr_FR", "de_DE", "es_ES", "it_IT", "ja_JP",
    "ko_KR", "pl_PL", "pt_BR", "ru_RU", "zh_Hant_HK",
]

STEMS = {
    "InGame":   "src/dlc/UI/InGame/CivVAccess_InGameStrings",
    "FrontEnd": "src/dlc/UI/FrontEnd/CivVAccess_FrontEndStrings",
    "Scanner":  "src/dlc/UI/InGame/CivVAccess_ScannerStrings",
    "Surveyor": "src/dlc/UI/InGame/CivVAccess_SurveyorStrings",
    "WonderDesc": "src/dlc/UI/InGame/CivVAccess_WonderDescStrings",
    "NaturalWonderDesc": "src/dlc/UI/InGame/CivVAccess_NaturalWonderDescStrings",
    "GreatWorkDesc": "src/dlc/UI/InGame/CivVAccess_GreatWorkDescStrings",
    "VictoryDesc": "src/dlc/UI/InGame/CivVAccess_VictoryDescStrings",
    "CongressDesc": "src/dlc/UI/InGame/CivVAccess_CongressDescStrings",
    "EraDesc": "src/dlc/UI/InGame/CivVAccess_EraDescStrings",
}

KEY_RE = re.compile(
    r'^CivVAccess_Strings\["(TXT_KEY_CIVVACCESS_[A-Z0-9_]+)"\]',
    re.MULTILINE,
)


def repo_root():
    out = subprocess.check_output(
        ["git", "rev-parse", "--show-toplevel"],
        text=True, encoding="utf-8",
    ).strip()
    return Path(out)


REPO = repo_root()
LUA_BIN = REPO / "third_party" / "lua51" / "lua5.1.exe"
DUMPER = Path(__file__).resolve().parent / "dump_strings.lua"


def git(*args, cwd=None):
    return subprocess.check_output(
        ["git", *args],
        cwd=str(cwd or REPO),
        text=True, encoding="utf-8",
    )


def _locale_paths():
    paths = []
    for stem in STEMS.values():
        for loc in LOCALES:
            paths.append(f"{stem}_{loc}.lua")
    return paths


def _keys_at(rev, path):
    """Set of TXT_KEY_* keys in a strings file at a rev, or None if absent."""
    try:
        text = subprocess.check_output(
            ["git", "show", f"{rev}:{path}"],
            cwd=str(REPO), text=True, encoding="utf-8",
            stderr=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError:
        return None
    return set(extract_order(text))


def _seeded_locales():
    """Per stem, the locales whose overlay file exists on disk now.

    A brand-new stem (en_US committed, locale siblings not yet seeded)
    must not constrain base-rev detection: no rev could ever satisfy
    "locale matches en_US" for it, which would push the base to the
    oldest locale commit and flood the diff with long-synced keys. Such
    a stem simply diffs as all-added against whatever base the seeded
    stems determine.
    """
    seeded = {}
    for stem in STEMS.values():
        locs = [l for l in LOCALES if (REPO / f"{stem}_{l}.lua").exists()]
        if locs:
            seeded[stem] = locs
    return seeded


def _locales_synced_at(rev, seeded):
    """True when every seeded locale strings file matches the en_US key
    set at rev."""
    for stem, locs in seeded.items():
        en_keys = _keys_at(rev, f"{stem}_en_US.lua")
        if en_keys is None:
            return False
        for loc in locs:
            if _keys_at(rev, f"{stem}_{loc}.lua") != en_keys:
                return False
    return True


def find_base_rev():
    """Most recent commit at which the locales were fully in sync with en_US.

    Walking history back rather than taking the single most-recent commit
    that touched a locale file: a repo-wide formatting / lint commit (e.g.
    stylua) rewrites every Lua file, including the locale strings, without
    changing any translation content. Taking that commit as the base would
    diff en_US-at-formatting-commit against en_US-now and silently miss
    every en_US change made before it. The real base is the last commit
    whose locale key sets all equal the en_US key set; a formatting commit
    fails that test whenever en_US has drifted ahead of the locales.
    """
    candidates = git("log", "--format=%H", "--", *_locale_paths()).split()
    seeded = _seeded_locales()
    for rev in candidates:
        if _locales_synced_at(rev, seeded):
            return rev
    if candidates:
        sys.stderr.write(
            "warning: no commit found with locales fully synced to en_US; "
            "using the oldest locale commit as base\n")
        return candidates[-1]
    return None


def file_text_at_rev(rev, path):
    if rev is None:
        with open(REPO / path, encoding="utf-8") as f:
            return f.read()
    try:
        return subprocess.check_output(
            ["git", "show", f"{rev}:{path}"],
            cwd=str(REPO), text=True, encoding="utf-8",
            stderr=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError:
        # The stem's en_US file didn't exist at the base rev (brand-new
        # stem): every key diffs as added.
        return ""


def dump_strings(text):
    """Run dump_strings.lua against the given Lua source. Returns dict."""
    with tempfile.NamedTemporaryFile(
        "w", suffix=".lua", delete=False, encoding="utf-8"
    ) as tf:
        tmp = tf.name
        tf.write(text)
    try:
        out = subprocess.check_output(
            [str(LUA_BIN), str(DUMPER), tmp],
            text=True, encoding="utf-8",
        )
        return json.loads(out)
    finally:
        os.unlink(tmp)


def extract_order(text):
    seen = set()
    order = []
    for m in KEY_RE.finditer(text):
        k = m.group(1)
        if k not in seen:
            seen.add(k)
            order.append(k)
    return order


def diff_stem(stem_path, base_rev):
    path = f"{stem_path}_en_US.lua"
    old_text = file_text_at_rev(base_rev, path)
    new_text = file_text_at_rev(None, path)

    old = dump_strings(old_text)
    new = dump_strings(new_text)
    new_order = extract_order(new_text)

    added = {k: v for k, v in new.items() if k not in old}
    removed = {k: v for k, v in old.items() if k not in new}
    changed = {
        k: {"old": old[k], "new": new[k]}
        for k in new
        if k in old and old[k] != new[k]
    }

    return {
        "path": path,
        "added": added,
        "removed": removed,
        "changed": changed,
        "added_order": [k for k in new_order if k in added],
        "head_order": new_order,
    }


def main():
    base_rev = None
    args = sys.argv[1:]
    if args and args[0] == "--base":
        base_rev = args[1]
    else:
        base_rev = find_base_rev()
        if not base_rev:
            print(json.dumps({
                "error": "No prior locale-file commit found. "
                         "Run translate-strings to seed locales first."
            }))
            sys.exit(1)

    out = {"base_rev": base_rev, "stems": {}}
    for label, stem in STEMS.items():
        out["stems"][label] = diff_stem(stem, base_rev)

    print(json.dumps(out, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()

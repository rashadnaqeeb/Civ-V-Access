"""
Audit locale strings files for completeness against en_US.

Two checks, neither of which find_locale_leaks.py performs reliably:

  1. Key set -- every key defined in an en_US strings file must exist in
     each locale overlay. A missing key is not a crash: StringsLoader's
     overlay is additive, so the locale falls through to the en_US value
     and the player hears English for that string. A key in an overlay
     no longer defined in en_US is stale dead weight.

  2. Plural forms -- a plural bundle ({ one = ..., other = ... }) must
     define every CLDR form its locale's rule in CivVAccess_PluralRules
     can select. A bundle short a form does not crash either: Text.
     formatPlural falls back (requested form -> other -> one -> any), so
     some counts get a wrong-grammar form instead of the right one.

Keys are found by token and bundles by brace block, so multi-line
strings and non-"other" plural tables are read correctly -- the failure
mode that makes find_locale_leaks.py's MISSING column untrustworthy.

Run: py tools/audit_locale_keys.py
"""

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

LOCALES = [
    "cs_CZ", "de_DE", "es_ES", "fr_FR", "it_IT", "ja_JP",
    "ko_KR", "pl_PL", "pt_BR", "ru_RU", "zh_Hant_HK",
]

UI = REPO / "src" / "dlc" / "UI"
EN_SUFFIX = "_en_US.lua"


def discover_stems():
    """stem -> directory, for every en_US strings file under the UI tree.

    Found by walking rather than listed, so a feature that adds a strings
    file is audited without anyone remembering to register it here.
    """
    stems = {}
    for path in sorted(UI.rglob("CivVAccess_*Strings" + EN_SUFFIX)):
        stems[path.name[: -len(EN_SUFFIX)]] = path.parent
    if not stems:
        sys.exit(f"audit_locale_keys: no en_US strings files found under {UI}")
    return stems


STEMS = discover_stems()

# Plural keywords each locale's rule in CivVAccess_PluralRules.lua can
# return for integer counts -- the forms a plural bundle must define.
# Mirror that file; Civ V's locale set is frozen, so this does not drift.
REQUIRED_PLURAL_FORMS = {
    "en_US": {"one", "other"},
    "de_DE": {"one", "other"},
    "es_ES": {"one", "other"},
    "it_IT": {"one", "other"},
    "pt_BR": {"one", "other"},
    "fr_FR": {"one", "other"},
    "pl_PL": {"one", "few", "many"},
    "ru_RU": {"one", "few", "many"},
    "cs_CZ": {"one", "few", "other"},
    "ja_JP": {"other"},
    "ko_KR": {"other"},
    "zh_Hant_HK": {"other"},
}

ASSIGN = re.compile(r'^CivVAccess_Strings\["([^"]+)"\]\s*=\s*(.*)$')
FORM = re.compile(r"^\s*(one|two|few|many|other|zero)\s*=")
INLINE_FORM = re.compile(r"\b(one|two|few|many|other|zero)\s*=")
STRING_LITERAL = re.compile(r'"(?:[^"\\]|\\.)*"')


def parse(path):
    """Map each key to ('string', None) or ('bundle', frozenset(forms)).

    Assumes the stylua-formatted layouts the repo enforces. A plural
    bundle either opens with `= {` and closes with `}` alone on its own
    line, or sits whole on the assignment line (`= { other = "..." }`):
    stylua leaves a table on one line when it was written that way and
    fits the width, which is how a single-form CJK bundle tends to land.
    """
    lines = path.read_text(encoding="utf-8").splitlines()
    result = {}
    n = len(lines)
    i = 0
    while i < n:
        if lines[i].lstrip().startswith("--"):
            i += 1
            continue
        m = ASSIGN.match(lines[i])
        if m is None:
            i += 1
            continue
        key = m.group(1)
        rest = m.group(2).strip()
        # The value may sit on a later line (`["KEY"] =` then the value).
        j = i
        while rest == "" and j + 1 < n:
            j += 1
            rest = lines[j].strip()
        if rest.startswith("{") and rest.endswith("}"):
            # One-line bundle. Scanning ahead for a closing-brace line here
            # would run to the next multi-line bundle (or end of file) and
            # swallow every key in between, reporting them all as missing.
            # Blank the string values first so a form word inside the text
            # is not mistaken for a form.
            forms = set(INLINE_FORM.findall(STRING_LITERAL.sub('""', rest)))
            result[key] = ("bundle", frozenset(forms))
            i = j + 1
        elif rest.startswith("{"):
            forms = set()
            k = j + 1
            while k < n and not lines[k].lstrip().startswith("}"):
                fm = FORM.match(lines[k])
                if fm:
                    forms.add(fm.group(1))
                k += 1
            result[key] = ("bundle", frozenset(forms))
            i = k + 1
        else:
            result[key] = ("string", None)
            i = j + 1
    return result


def main():
    totals = {"missing": 0, "stale": 0, "mismatch": 0, "plural": 0}
    for stem, directory in STEMS.items():
        en = parse(directory / f"{stem}_en_US.lua")

        # en_US baseline: its own bundles must carry one/other.
        en_plural_gaps = []
        for key in sorted(en):
            kind, forms = en[key]
            if kind == "bundle":
                gap = REQUIRED_PLURAL_FORMS["en_US"] - forms
                if gap:
                    en_plural_gaps.append(f"{key} missing {', '.join(sorted(gap))}")
        if en_plural_gaps:
            print(f"\n=== {stem}_en_US.lua ===")
            for line in en_plural_gaps:
                print(f"  PLURAL    {line}")
            totals["plural"] += len(en_plural_gaps)

        for loc in LOCALES:
            path = directory / f"{stem}_{loc}.lua"
            if not path.exists():
                print(f"\n=== {stem}_{loc}.lua: FILE ABSENT ===")
                totals["missing"] += len(en)
                continue
            loc_map = parse(path)
            missing = sorted(set(en) - set(loc_map))
            stale = sorted(set(loc_map) - set(en))
            mismatch = []
            plural = []
            required = REQUIRED_PLURAL_FORMS[loc]
            for key in sorted(set(en) & set(loc_map)):
                en_kind = en[key][0]
                loc_kind, loc_forms = loc_map[key]
                if en_kind != loc_kind:
                    mismatch.append(f"{key} ({en_kind} in en_US, {loc_kind} here)")
                elif en_kind == "bundle":
                    gap = required - loc_forms
                    if gap:
                        plural.append(f"{key} missing {', '.join(sorted(gap))}")
            if missing or stale or mismatch or plural:
                print(f"\n=== {stem}_{loc}.lua ===")
                for k in missing:
                    print(f"  MISSING   {k}")
                for k in stale:
                    print(f"  STALE     {k}")
                for k in mismatch:
                    print(f"  MISMATCH  {k}")
                for k in plural:
                    print(f"  PLURAL    {k}")
            totals["missing"] += len(missing)
            totals["stale"] += len(stale)
            totals["mismatch"] += len(mismatch)
            totals["plural"] += len(plural)

    print(f"\nTotal: {totals['missing']} missing keys, {totals['stale']} stale, "
          f"{totals['mismatch']} type mismatches, {totals['plural']} plural-form gaps")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    main()

"""Validate locale strings files against the en_US baseline, every stem in STEMS.

Run after a sync (Step 5 of the sync-translations skill). Checks every
locale strings file, not just the keys this sync touched -- a pre-existing
structural defect anywhere will surface here.

Per locale per stem:
  1. Key set matches en_US exactly (no missing / extra keys).
  2. A key whose en_US value is a plural bundle is a bundle in the locale
     containing every CLDR keyword the locale's plural rule can return; a
     scalar stays a scalar. A spurious "other" on a 3-form locale is
     allowed (the rule can still return "other" for fractional counts).
  3. The {N_*} placeholder index set per key matches en_US.
  4. The file carries no UTF-8 BOM (an agent Edit can introduce one;
     Lua's dofile rejects it).

Exit 0 and print OK when clean; exit 1 and list every failure otherwise.
"""

import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

DUMPER = Path(__file__).resolve().parent / "dump_strings.lua"
REPO = Path(subprocess.check_output(
    ["git", "rev-parse", "--show-toplevel"],
    text=True, encoding="utf-8").strip())
LUA_BIN = REPO / "third_party" / "lua51" / "lua5.1.exe"

STEMS = {
    "InGame": "src/dlc/UI/InGame/CivVAccess_InGameStrings",
    "FrontEnd": "src/dlc/UI/FrontEnd/CivVAccess_FrontEndStrings",
    "Scanner": "src/dlc/UI/InGame/CivVAccess_ScannerStrings",
    "Surveyor": "src/dlc/UI/InGame/CivVAccess_SurveyorStrings",
    "WonderDesc": "src/dlc/UI/InGame/CivVAccess_WonderDescStrings",
    "NaturalWonderDesc": "src/dlc/UI/InGame/CivVAccess_NaturalWonderDescStrings",
    "GreatWorkDesc": "src/dlc/UI/InGame/CivVAccess_GreatWorkDescStrings",
    "VictoryDesc": "src/dlc/UI/InGame/CivVAccess_VictoryDescStrings",
    "CongressDesc": "src/dlc/UI/InGame/CivVAccess_CongressDescStrings",
}

LOCALES = ["fr_FR", "de_DE", "es_ES", "it_IT", "ja_JP",
           "ko_KR", "pl_PL", "pt_BR", "ru_RU", "zh_Hant_HK"]

# Forms the locale's plural rule (CivVAccess_PluralRules.lua) can return
# for an integer count.
REQUIRED = {
    "fr_FR": {"one", "other"}, "de_DE": {"one", "other"},
    "es_ES": {"one", "other"}, "it_IT": {"one", "other"},
    "pt_BR": {"one", "other"}, "pl_PL": {"one", "few", "many"},
    "ru_RU": {"one", "few", "many"}, "ja_JP": {"other"},
    "ko_KR": {"other"}, "zh_Hant_HK": {"other"},
}

PH = re.compile(r"\{(\d+)_[A-Za-z0-9]+\}")


def has_bom(path):
    with open(path, "rb") as f:
        return f.read(3) == b"\xef\xbb\xbf"


def dump(path):
    """Dump a strings file's CivVAccess_Strings table via the Lua dumper.
    BOM-tolerant: the file is routed through a temp file written as plain
    UTF-8 so a stray BOM does not break the Lua dofile."""
    with open(path, encoding="utf-8-sig") as f:
        text = f.read()
    with tempfile.NamedTemporaryFile(
            "w", suffix=".lua", delete=False, encoding="utf-8") as tf:
        tmp = tf.name
        tf.write(text)
    try:
        out = subprocess.check_output([str(LUA_BIN), str(DUMPER), tmp],
                                      text=True, encoding="utf-8")
        return json.loads(out)
    finally:
        os.unlink(tmp)


def indices(value):
    if isinstance(value, dict):
        s = set()
        for v in value.values():
            s |= set(PH.findall(v))
        return s
    return set(PH.findall(value))


def main():
    failures = []
    for label, stem in STEMS.items():
        en = dump(REPO / f"{stem}_en_US.lua")
        en_keys = set(en)
        for loc in LOCALES:
            path = REPO / f"{stem}_{loc}.lua"
            if has_bom(path):
                failures.append(f"{label}/{loc}: file has a UTF-8 BOM")
            loc_data = dump(path)
            loc_keys = set(loc_data)
            for k in sorted(en_keys - loc_keys):
                failures.append(f"{label}/{loc}: missing key {k}")
            for k in sorted(loc_keys - en_keys):
                failures.append(f"{label}/{loc}: extra key {k}")
            for k in sorted(en_keys & loc_keys):
                ev, lv = en[k], loc_data[k]
                if isinstance(ev, dict) and not isinstance(lv, dict):
                    failures.append(
                        f"{label}/{loc}: {k} is scalar, en_US is a bundle")
                    continue
                if not isinstance(ev, dict) and isinstance(lv, dict):
                    failures.append(
                        f"{label}/{loc}: {k} is a bundle, en_US is scalar")
                    continue
                if isinstance(ev, dict):
                    req = REQUIRED[loc]
                    have = set(lv)
                    miss = req - have
                    bad = have - req - {"other"}
                    if miss:
                        failures.append(
                            f"{label}/{loc}: {k} bundle missing "
                            f"{sorted(miss)}")
                    if bad:
                        failures.append(
                            f"{label}/{loc}: {k} bundle has stray "
                            f"{sorted(bad)}")
                if indices(ev) != indices(lv):
                    failures.append(
                        f"{label}/{loc}: {k} placeholders "
                        f"{sorted(indices(lv))} != en_US "
                        f"{sorted(indices(ev))}")
    if failures:
        print(f"FAIL ({len(failures)})")
        for f in failures:
            print("  " + f)
        sys.exit(1)
    print(f"OK - all 10 locales match en_US across all {len(STEMS)} stems")


if __name__ == "__main__":
    main()

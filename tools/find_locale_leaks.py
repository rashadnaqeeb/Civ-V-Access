"""
Flag translation problems in the locale strings files.

MISSING: a key defined in en_US but absent from a locale overlay, found
by a token-level key scan so value formatting cannot fool it.

IDENTICAL: a key whose locale value is byte-identical to en_US -- a
likely leak (en_US placeholder the translator missed). Best-effort:
trivial false positives are filtered (empty strings, single key names,
pure {1_X} placeholder templates), and genuine cognates ("DLC", "Chat")
still slip through, so IDENTICAL output needs eyeballing.

For a strict key-set and plural-form completeness audit, use
audit_locale_keys.py instead.

Run: py tools/find_locale_leaks.py
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
INGAME = REPO / "src" / "dlc" / "UI" / "InGame"
FRONTEND = REPO / "src" / "dlc" / "UI" / "FrontEnd"

LOCALES = ["de_DE", "es_ES", "fr_FR", "it_IT", "ja_JP", "ko_KR", "pl_PL", "pt_BR", "ru_RU", "zh_Hant_HK"]

# Pairs of (en_US_path, locale_path_template).
GROUPS = [
    (INGAME / "CivVAccess_InGameStrings_en_US.lua",
     lambda loc: INGAME / f"CivVAccess_InGameStrings_{loc}.lua"),
    (INGAME / "CivVAccess_ScannerStrings_en_US.lua",
     lambda loc: INGAME / f"CivVAccess_ScannerStrings_{loc}.lua"),
    (INGAME / "CivVAccess_SurveyorStrings_en_US.lua",
     lambda loc: INGAME / f"CivVAccess_SurveyorStrings_{loc}.lua"),
    (FRONTEND / "CivVAccess_FrontEndStrings_en_US.lua",
     lambda loc: FRONTEND / f"CivVAccess_FrontEndStrings_{loc}.lua"),
]

# Single-line: CivVAccess_Strings["KEY"] = "VALUE"
SINGLE = re.compile(r'CivVAccess_Strings\["([^"]+)"\]\s*=\s*"((?:[^"\\]|\\.)*)"')

# Plural table: CivVAccess_Strings["KEY"] = { ... other = "VALUE", ... }
PLURAL = re.compile(
    r'CivVAccess_Strings\["([^"]+)"\]\s*=\s*\{[^}]*?other\s*=\s*"((?:[^"\\]|\\.)*)"',
    re.DOTALL,
)

# Cross-line concatenation: ["KEY"] = "..." \n .. "..."
# Handle by joining concatenated string literals on the same value line
CONCAT = re.compile(r'CivVAccess_Strings\["([^"]+)"\]\s*=\s*((?:"[^"]*"\s*(?:\.\.\s*)?\n?\s*)+)')

KEY_NAMES = {
    "Tab", "Enter", "Escape", "Esc", "Backspace", "Home", "End", "Space",
    "Up", "Down", "Left", "Right", "Numpad", "Pause", "Insert", "Delete",
    "Shift", "Control", "Ctrl", "Alt", "Caps", "Lock", "Return", "PgUp",
    "PgDown", "PageUp", "PageDown", "Backslash",
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
    "MP", "HP", "AP",
}


def extract(path: Path) -> dict:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    out = {}
    for m in SINGLE.finditer(text):
        out[m.group(1)] = m.group(2)
    for m in PLURAL.finditer(text):
        if m.group(1) not in out:
            out[m.group(1)] = m.group(2)
    return out


# Authoritative key-presence regex. extract() can only see keys whose
# value form its regexes parse; this catches every key by token, so a
# plural table with no `other` field or a multi-line string assignment
# is still recognized as present.
KEY = re.compile(r'CivVAccess_Strings\["([^"]+)"\]')


def key_set(path: Path) -> set:
    if not path.exists():
        return set()
    found = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.lstrip().startswith("--"):
            continue
        found.update(KEY.findall(line))
    return found


def looks_like_keyname_only(val: str) -> bool:
    """True if every alphabetic word in val is a known key-name token."""
    words = re.findall(r"[A-Za-z]+", val)
    if not words:
        return True
    return all(w in KEY_NAMES for w in words)


def has_translatable_content(val: str) -> bool:
    """Decide whether en_US value carries prose worth translating."""
    if not val:
        return False
    # Strip placeholders {1_Name}, {2_Turns} etc.
    stripped = re.sub(r"\{[^}]+\}", "", val)
    # Strip pluralization scaffolding markers (rare, mostly empty)
    stripped = stripped.strip()
    if not stripped:
        return False
    # If it's just punctuation or numbers, skip.
    letters = re.sub(r"[^A-Za-z]", "", stripped)
    if len(letters) < 3:
        return False
    # If every word is a known key-name token, skip.
    if looks_like_keyname_only(stripped):
        return False
    return True


def main():
    leaks_by_locale = {loc: [] for loc in LOCALES}
    for en_path, loc_template in GROUPS:
        en = extract(en_path)
        en_keys = key_set(en_path)
        for loc in LOCALES:
            loc_path = loc_template(loc)
            loc_strings = extract(loc_path)
            loc_keys = key_set(loc_path)
            for key in sorted(en_keys):
                if key not in loc_keys:
                    # Genuinely absent -- the locale speaks English here.
                    leaks_by_locale[loc].append(
                        (loc_path.name, key, "MISSING", en.get(key, "")))
                    continue
                # Key present: best-effort leak check, only on values
                # both extract() could parse. A parse miss is not a leak.
                en_val = en.get(key)
                if en_val is None or not has_translatable_content(en_val):
                    continue
                loc_val = loc_strings.get(key)
                if loc_val is not None and loc_val == en_val:
                    leaks_by_locale[loc].append(
                        (loc_path.name, key, "IDENTICAL", en_val))

    for loc in LOCALES:
        leaks = leaks_by_locale[loc]
        print(f"\n=== {loc} ({len(leaks)} candidates) ===")
        for filename, key, kind, val in leaks:
            short = val if len(val) < 80 else val[:77] + "..."
            print(f"  {filename}  {kind}  {key}  =  {short!r}")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    main()

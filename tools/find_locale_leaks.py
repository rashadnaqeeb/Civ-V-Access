"""
Scan every locale strings file for keys whose value matches en_US verbatim.
Such keys are candidates for translation leaks (en_US placeholder left in
place because the translator missed the entry).

Filters out trivial false positives: empty strings, single key names, pure
placeholder templates (just `{1_X}` substitutions with no prose).

Run: py tools/find_locale_leaks.py
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
INGAME = REPO / "src" / "dlc" / "UI" / "InGame"
FRONTEND = REPO / "src" / "dlc" / "UI" / "FrontEnd"

LOCALES = ["de_DE", "es_ES", "fr_FR", "it_IT", "ja_JP", "ko_KR", "pl_PL", "ru_RU", "zh_Hant_HK"]

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
        for loc in LOCALES:
            loc_path = loc_template(loc)
            loc_strings = extract(loc_path)
            for key, en_val in en.items():
                if not has_translatable_content(en_val):
                    continue
                loc_val = loc_strings.get(key)
                if loc_val is None:
                    leaks_by_locale[loc].append((loc_path.name, key, "MISSING", en_val))
                    continue
                if loc_val == en_val:
                    leaks_by_locale[loc].append((loc_path.name, key, "IDENTICAL", en_val))

    for loc in LOCALES:
        leaks = leaks_by_locale[loc]
        print(f"\n=== {loc} ({len(leaks)} candidates) ===")
        for filename, key, kind, val in leaks:
            short = val if len(val) < 80 else val[:77] + "..."
            print(f"  {filename}  {kind}  {key}  =  {short!r}")


if __name__ == "__main__":
    main()

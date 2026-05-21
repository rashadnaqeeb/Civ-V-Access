"""
Maintain the per-locale icon dedup-alias values for the text filter.

Background
----------
TextFilter substitutes [ICON_*] tokens with a spoken word, then suppresses
the substitution when the icon sits next to the word it labels, so the
screen reader does not hear the word twice ("Movement moves", "culture
Cultural"). The suppression check needs the EXACT word the engine prints
next to the icon, in each locale.

That word is not a translation of the English alias. It is a copy of a
word out of Firaxis's own localized XML. Translating the English alias
("movement" -> "mouvement") guesses a word that may not match what the
engine actually prints, and a mismatch fails silently: the player hears
the doubled word with no error logged. So these values are kept out of
the normal translation sync and maintained here, sourced from the game.

For each alias key the table below records the engine TXT_KEY whose text
carries the icon-plus-word pairing, and the reviewed per-locale value:
the word adjacent to the icon token (the matcher lowercases it at compare
time). An empty value means the locale needs no alias -- either the
icon's primary spoken form already collapses against the adjacent word,
or the localized text places no label word next to the icon at all.

pt_BR is special: Civ V ships no Portuguese. pt_BR players run the
Civ5-PTBR community language pack (github.com/Anpix/Civ5-PTBR), which
registers the pt_BR locale and supplies Portuguese engine text. Its alias
values come from that pack's XML, fetched from the repo -- the --dump
mode below reads the local game install and so covers only the ten
Firaxis locales, not pt_BR.

Adding a new alias key
----------------------
1. Find the engine TXT_KEY whose text pairs the icon with a word.
2. `py tools/icon_dedup_aliases.py --dump TXT_KEY_X` prints that text in
   every game locale.
3. For each locale, read the word touching the [ICON_*] token. If it
   already equals the icon's primary spoken form (see the per-locale
   CivVAccess_*Strings file), leave the value "". Otherwise use the word.
4. Add the key to ALIASES below and register it in CivVAccess_Icons.lua.
5. Re-run with no arguments to write the values into every locale file.

Usage
-----
  py tools/icon_dedup_aliases.py            apply the table to all locales
  py tools/icon_dedup_aliases.py --dump TXT_KEY_X
"""

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
GAME = Path(
    r"C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V"
)

# Locales the script writes. en_US is the source of truth and is edited by
# hand, so it is not in this list.
LOCALES = [
    "de_DE", "es_ES", "fr_FR", "it_IT", "ja_JP",
    "ko_KR", "pl_PL", "pt_BR", "ru_RU", "zh_Hant_HK",
]

# Both Contexts register the icon table, so both carry the alias strings.
CONTEXTS = [
    (REPO / "src" / "dlc" / "UI" / "InGame", "CivVAccess_InGameStrings_{loc}.lua"),
    (REPO / "src" / "dlc" / "UI" / "FrontEnd", "CivVAccess_FrontEndStrings_{loc}.lua"),
]

ALIASES = {
    "TXT_KEY_CIVVACCESS_ICON_MOVEMENT_ALT": {
        "primary": "TXT_KEY_CIVVACCESS_ICON_MOVEMENT",
        "source": "TXT_KEY_TRAIT_VIKING_FURY -- Denmark's Viking Fury trait",
        # en_US: "+1 Movement [ICON_MOVES] and pay just 1 movement point..."
        # fr_FR / ru_RU: the icon sits next to "+1", no label word adjacent.
        # ko_KR: primary spoken form already equals the adjacent word.
        "values": {
            "de_DE": "Fortbew.",      # "+1 Fortbew. [ICON_MOVES] und zahlen..."
            "es_ES": "movimiento",    # "+1 al Movimiento [ICON_MOVES], solo..."
            "fr_FR": "",              # "Mouvement +1 [ICON_MOVES] pour..."
            "it_IT": "movimento",     # "+1 al [ICON_MOVES] movimento."
            "ja_JP": "移動",          # "[ICON_MOVES]移動+1が付与され..."
            "ko_KR": "",              # "[ICON_MOVES] 이동력 +1을..."
            "pl_PL": "ruchu",         # "+1 do [ICON_MOVES] ruchu i..."
            "pt_BR": "movimento",     # Civ5-PTBR: "+1 de [ICON_MOVES]Movimento e gastam..."
            "ru_RU": "",              # "+1 [ICON_MOVES] к ОП и тратят..."
            "zh_Hant_HK": "移動力",   # "[ICON_MOVES]移動力+1且..."
        },
    },
    "TXT_KEY_CIVVACCESS_ICON_CULTURE_ALT": {
        "primary": "TXT_KEY_CIVVACCESS_ICON_CULTURE",
        "source": "TXT_KEY_TECH_RADIO_HELP -- Broadcast Tower tech help",
        # en_US: "...greatly increases the [ICON_CULTURE] Cultural output..."
        # fr_FR / it_IT / ja_JP / ko_KR / zh: primary already collapses.
        "values": {
            "de_DE": "Kulturertrag", # "...den [ICON_CULTURE] Kulturertrag einer Stadt..."
            "es_ES": "cultural",     # "...la producción cultural [ICON_CULTURE] de una ciudad."
            "fr_FR": "",             # "...la production de [ICON_CULTURE] culture d'une ville."
            "it_IT": "",             # "...la produzione di [ICON_CULTURE] Cultura di una città."
            "ja_JP": "",             # "...[ICON_CULTURE]文化力の産出量を..."
            "ko_KR": "",             # "...[ICON_CULTURE] 문화 생성량을..."
            "pl_PL": "kultury",      # "...punktów [ICON_CULTURE] kultury wytwarzanych..."
            "pt_BR": "cultural",     # Civ5-PTBR: "...a produção [ICON_CULTURE]Cultural de uma cidade."
            "ru_RU": "культуры",     # "...рост [ICON_CULTURE] культуры в городе."
            "zh_Hant_HK": "",        # "...城市[ICON_CULTURE]文化值產出的..."
        },
    },
}

COMMENT = (
    "-- Dedup alias copied from the game's localized text, not translated"
    ' (see en_US). "" means the primary spoken form already collapses.'
)


def apply():
    """Write every alias key into every locale strings file. Idempotent."""
    touched = 0
    for alt_key, spec in ALIASES.items():
        primary = spec["primary"]
        for ctx_dir, name_pattern in CONTEXTS:
            for loc in LOCALES:
                path = ctx_dir / name_pattern.format(loc=loc)
                text = path.read_text(encoding="utf-8")
                value = spec["values"][loc]
                lua_value = value.replace("\\", "\\\\").replace('"', '\\"')
                alt_line = f'CivVAccess_Strings["{alt_key}"] = "{lua_value}"'

                existing = re.search(
                    r'^CivVAccess_Strings\["' + re.escape(alt_key) + r'"\].*$',
                    text,
                    re.M,
                )
                if existing:
                    new_text = text[: existing.start()] + alt_line + text[existing.end():]
                else:
                    anchor = re.search(
                        r'^CivVAccess_Strings\["' + re.escape(primary) + r'"\].*$',
                        text,
                        re.M,
                    )
                    if anchor is None:
                        sys.exit(f"ERROR: {path.name}: primary {primary} not found")
                    block = "\n" + COMMENT + "\n" + alt_line
                    new_text = text[: anchor.end()] + block + text[anchor.end():]

                if new_text != text:
                    path.write_text(new_text, encoding="utf-8", newline="\n")
                    touched += 1
    print(f"icon_dedup_aliases: updated {touched} file/key entries")


def dump(txt_key):
    """Print the engine text for txt_key in every game locale."""
    row = re.compile(
        r'<Row\s+Tag="' + re.escape(txt_key) + r'"\s*>(.*?)</Row>',
        re.S,
    )
    # The game stores locale folders with inconsistent casing (en_US vs
    # EN_US) and one is two-part (ZH_Hant_HK); match a known set so all
    # ten resolve to one canonical label.
    canonical = {
        loc.lower(): loc
        for loc in ["en_US"] + LOCALES
    }
    found = {}
    for xml in (GAME / "Assets").rglob("CIV5GameText*.xml"):
        loc = None
        for part in xml.parts:
            if part.lower() in canonical:
                loc = canonical[part.lower()]
                break
        if loc is None or loc in found:
            continue
        hit = row.search(xml.read_text(encoding="utf-8-sig", errors="replace"))
        if hit:
            text = re.sub(r"\s+", " ", hit.group(1)).strip()
            found[loc] = text
    if not found:
        sys.exit(f"{txt_key}: not found in any game locale")
    for loc in sorted(found):
        print(f"{loc}: {found[loc]}")


if __name__ == "__main__":
    # The Windows console defaults to cp1252; dump prints CJK / Cyrillic.
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if len(sys.argv) == 3 and sys.argv[1] == "--dump":
        dump(sys.argv[2])
    elif len(sys.argv) == 1:
        apply()
    else:
        sys.exit(__doc__)

"""Extract UI-relevant TXT_KEY entries from the shipped Civ V text XML.

Scans every en_US text XML under the game install (base, Expansion, Expansion2,
DLC) and emits a markdown index of keys whose text looks like a UI label rather
than long-form content (Civilopedia entries, leader dialog, building help
prose, etc.).

Run from this directory:
    python _extract.py

Output: ui-text-keys.md next to this script.
"""

from __future__ import annotations

import html
import os
import re
import sys
from collections import defaultdict
from pathlib import Path
from xml.etree import ElementTree as ET

CIV_ROOT = Path(
    r"C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\Assets"
)

# Hard length cap. UI labels are tiny; tooltips can run longer but a 120-char
# ceiling lets us catch short hints while filtering pedia paragraphs.
MAX_TEXT_LEN = 120

# Whitelist: a key is a UI-label candidate if any of these substrings appear
# anywhere in the body (everything after TXT_KEY_), case-insensitively.
# This is intentionally narrow — game-data labels (unit/building/civ names,
# ability strings, terrain features) are NOT UI chrome and should be looked
# up by reading GameInfo / the relevant XML directly when needed.
INCLUDE_KEY_SUBSTRINGS = (
    "BUTTON",
    "LABEL",
    "TITLE",
    "HEADER",
    "HEADING",
    "TOOLTIP",
    "TT_",
    "_TT",
    "POPUP",
    "DIALOG",
    "MENU_",
    "_MENU",
    "MAIN_MENU",
    "FRONT_END",
    "FRONTEND",
    "OPTION",
    "SETTING",
    "GAMESETUP",
    "AD_SETUP",
    "ADVANCED_SETUP",
    "PREGAME",
    "MULTIPLAYER",
    "_MP_",
    "LOBBY",
    "STAGING",
    "MATCHMAKING",
    "NETWORK",
    "STEAM_",
    "MOD_",
    "MODDING",
    "EULA",
    "LEGAL",
    "CREDITS",
    "LOAD_GAME",
    "LOADGAME",
    "SAVE_GAME",
    "SAVEGAME",
    "SAVEMENU",
    "AUTOSAVE",
    "QUICKSAVE",
    "QUICKLOAD",
    "REPLAY",
    "HALL_OF_FAME",
    "HALLOFFAME",
    "LEADERBOARD",
    "NOTIFICATION_SUMMARY",
    "NEXT_TURN",
    "END_TURN",
    "TURN_TIMER",
    "WAITING_FOR",
    "TOP_PANEL",
    "TOPPANEL",
    "MINIMAP",
    "CITY_BANNER",
    "CITYBANNER",
    "CITYVIEW",
    "CITY_VIEW",
    "PURCHASE",
    "PRODUCTION_QUEUE",
    "DIPLO_",
    "DIPLOMACY_",
    "LEADERHEAD",
    "DEAL_",
    "TRADE_OVERVIEW",
    "DEMOGRAPHICS",
    "MILITARY_OVERVIEW",
    "ECONOMIC_OVERVIEW",
    "ESPIONAGE_OVERVIEW",
    "TECH_TREE",
    "TECHTREE",
    "PEDIA_",
    "CIVILOPEDIA_",
    "RESEARCH_CHOOSE",
    "POLICY_PICK",
    "PICK_POLICY",
    "BELIEF_PICK",
    "PICK_BELIEF",
    "FOUND_RELIGION",
    "ENHANCE_RELIGION",
    "REFORM_RELIGION",
    "PICK_IDEOLOGY",
    "CONFIRM",
    "CHAT",
    "CHANGE_PASSWORD",
    "PLAYER_CHANGE",
    "GOODY_HUT",
    "NATURAL_WONDER_POPUP",
    "NEW_ERA",
    "VOTE_RESULT",
    "VICTORY_PROGRESS",
    "TUTORIAL_",
    "ADVISOR",
    "KEYBINDING",
    "HOTKEY",
    "ACTION_BAR",
    "_PROMPT",
    "_INSTRUCTION",
)

# Standalone short generic verbs/nouns commonly used as button labels. Only
# matched if the key body equals one of these exactly (or with a _BUTTON
# suffix that's already covered by INCLUDE_KEY_SUBSTRINGS).
INCLUDE_KEY_EXACT = {
    "OK", "CANCEL", "CLOSE", "BACK", "NEXT", "PREV", "PREVIOUS",
    "CONTINUE", "ACCEPT", "DECLINE", "YES", "NO", "RESUME",
    "EXIT", "QUIT", "RETURN", "RETIRE", "RESTART", "RETRY",
    "DELETE", "REMOVE", "ADD", "EDIT", "RESET", "DEFAULT",
    "APPLY", "SAVE", "LOAD", "NEW", "OPEN", "REFRESH", "SEARCH",
    "EMPTY", "NONE", "ALL", "ANY",
}

# Even within whitelisted hits, exclude clear-content suffixes / substrings.
EXCLUDE_KEY_SUBSTRINGS = (
    "_HELP",
    "_STRATEGY",
    "_QUOTE",
    "_HISTORY",
    "_FLAVOR",
    "_FIRSTGREETING",
    "_DEFEATED",
    "_GREETING_",
    "_RESPONSE_",
    "_HOSTILE_",
    "_FRIENDLY_",
    "_NEUTRAL_",
    "PEDIA_TEXT",
    "_CHAPTER",
    "_PARAGRAPH",
)

EXCLUDE_KEY_SUFFIXES = ()

# Exclude DLC GUID-named keys (32 hex chars then _).
GUID_KEY_RE = re.compile(r"^TXT_KEY_[0-9A-F]{32}_", re.IGNORECASE)

# Categorize by leading key fragment after TXT_KEY_. Order matters — first
# match wins. The fragment match is checked against the key without the
# TXT_KEY_ prefix.
CATEGORIES = [
    ("Generic actions", [
        "GENERIC_", "GENERAL_", "OK", "CANCEL", "CLOSE", "CONFIRM",
        "YES", "NO", "BACK", "CONTINUE", "ACCEPT", "DECLINE",
    ]),
    ("Button labels", ["BUTTON"]),  # any key with BUTTON in name (post-prefix)
    ("Main menu / FrontEnd", [
        "MAIN_MENU", "FRONT_END", "MENU_", "OTHER_MENU", "MULTIPLAYER_SELECT",
        "EULA", "LEGAL_", "CREDITS",
    ]),
    ("Game setup", [
        "SETUP_", "GAMESETUP", "ADVANCED_SETUP", "AD_SETUP", "SELECT_CIV",
        "PREGAME", "SCENARIO_", "MOD_", "MODDING_", "CUSTOMMOD",
    ]),
    ("Save / Load", [
        "SAVE_", "LOAD_", "LOADGAME", "AUTO_SAVE", "QUICK_SAVE", "QUICK_LOAD",
        "REPLAY",
    ]),
    ("Multiplayer / lobby", [
        "MP_", "MULTIPLAYER_", "LOBBY", "STAGING", "MATCHMAKING", "STEAM_",
        "NETWORK_", "KICK_", "CHAT", "FRIENDS",
    ]),
    ("Options", [
        "OPTIONS_", "OPTION_", "AUDIO_", "VIDEO_", "GRAPHICS_", "GAMEPLAY_",
        "INTERFACE_", "RESOLUTION", "FULLSCREEN", "BORDERLESS", "VSYNC",
    ]),
    ("Notifications / turn flow", [
        "NOTIFICATION", "NEXT_TURN", "END_TURN", "TURN_", "WAITING_",
    ]),
    ("Popups", ["POPUP_"]),
    ("In-game HUD / panels", [
        "TOP_PANEL", "TOPPANEL", "INFO_TOOLTIP", "MINIMAP", "UNIT_PANEL",
        "CITY_BANNER", "ECON_INFO", "MILITARY_OVERVIEW", "TRADE_OVERVIEW",
        "ESPIONAGE_OVERVIEW", "DEMOGRAPHICS",
    ]),
    ("City screen", ["CITYVIEW", "CITY_VIEW", "PRODUCTION_", "PURCHASE_"]),
    ("Diplomacy", [
        "DIPLO_", "DIPLOMACY_", "LEADERHEAD", "DEAL_", "TRADE_",
        "DOF_", "DECLARE_WAR", "DENOUNCE", "EMBASSY",
    ]),
    ("Tech tree", ["TECH_TREE", "TECHTREE", "RESEARCH_"]),
    ("Civilopedia frame", ["PEDIA_HOMEPAGE", "PEDIA_NAV", "PEDIA_FILTER"]),
    ("Civics / policies / religion", [
        "POLICY_", "POLICIES_", "IDEOLOGY", "RELIGION_", "BELIEFS_",
    ]),
    ("Tooltips / status", ["TOOLTIP_", "STATUS_", "TIP_"]),
]


KEY_RE = re.compile(r'<Row\s+Tag\s*=\s*"(TXT_KEY_[A-Z0-9_]+)"\s*>')


def find_text_files(root: Path) -> list[Path]:
    """All XML files under */en_US/ (case-insensitive)."""
    out: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(root):
        # Cheap filter — only descend dirs whose path contains en_us anywhere
        # OR continue descending so we find nested en_US dirs.
        for fn in filenames:
            if not fn.lower().endswith(".xml"):
                continue
            full = Path(dirpath) / fn
            parts_lower = [p.lower() for p in full.parts]
            if "en_us" in parts_lower:
                out.append(full)
    return sorted(out)


def parse_file(path: Path) -> list[tuple[str, str]]:
    """Yield (tag, text) pairs from a Civ V text XML file.

    Falls back to a regex-driven parse if the XML is malformed (some shipped
    files have unescaped ampersands). The shipped files are well-formed
    enough for ElementTree in nearly all cases.
    """
    try:
        # Some files have a UTF-8 BOM; ET handles that. Others use lowercase
        # <Language_en_US>, which is fine — we just look at <Row> children.
        tree = ET.parse(path)
    except ET.ParseError:
        return _regex_parse(path)

    out: list[tuple[str, str]] = []
    for row in tree.iter("Row"):
        tag = row.get("Tag")
        if not tag or not tag.startswith("TXT_KEY_"):
            continue
        text_el = row.find("Text")
        if text_el is None:
            continue
        text = text_el.text or ""
        out.append((tag, text))
    return out


def _regex_parse(path: Path) -> list[tuple[str, str]]:
    raw = path.read_text(encoding="utf-8", errors="replace")
    out: list[tuple[str, str]] = []
    pattern = re.compile(
        r'<Row\s+Tag\s*=\s*"(TXT_KEY_[A-Z0-9_]+)"\s*>\s*<Text>(.*?)</Text>',
        re.DOTALL,
    )
    for m in pattern.finditer(raw):
        out.append((m.group(1), html.unescape(m.group(2))))
    return out


def is_ui_candidate(tag: str, text: str) -> bool:
    if not text:
        return False
    stripped = text.strip()
    if not stripped:
        return False
    if len(stripped) > MAX_TEXT_LEN:
        return False
    if "[NEWLINE]" in stripped:
        return False
    upper = tag.upper()
    if GUID_KEY_RE.match(upper):
        return False
    for sub in EXCLUDE_KEY_SUBSTRINGS:
        if sub in upper:
            return False
    body = upper[len("TXT_KEY_"):] if upper.startswith("TXT_KEY_") else upper
    if body in INCLUDE_KEY_EXACT:
        return True
    for sub in INCLUDE_KEY_SUBSTRINGS:
        if sub in body:
            return True
    return False


def categorize(tag: str) -> str:
    body = tag[len("TXT_KEY_"):] if tag.startswith("TXT_KEY_") else tag
    body_upper = body.upper()
    for label, fragments in CATEGORIES:
        for frag in fragments:
            if frag in body_upper:
                return label
    return "Other UI labels"


def relpath(p: Path) -> str:
    try:
        return str(p.relative_to(CIV_ROOT)).replace("\\", "/")
    except ValueError:
        return str(p)


def main() -> int:
    if not CIV_ROOT.exists():
        print(f"Civ V install not found at {CIV_ROOT}", file=sys.stderr)
        return 1

    files = find_text_files(CIV_ROOT)
    print(f"Scanning {len(files)} en_US text XML files...", file=sys.stderr)

    # tag -> (text, [source files])
    seen: dict[str, tuple[str, list[str]]] = {}
    for f in files:
        for tag, text in parse_file(f):
            if not is_ui_candidate(tag, text):
                continue
            stripped = text.strip()
            if tag in seen:
                # Same key declared in multiple files (DLC overrides). Keep
                # the first text; record subsequent sources.
                _, srcs = seen[tag]
                rp = relpath(f)
                if rp not in srcs:
                    srcs.append(rp)
            else:
                seen[tag] = (stripped, [relpath(f)])

    # Bucket by category.
    buckets: dict[str, list[tuple[str, str, list[str]]]] = defaultdict(list)
    for tag, (text, srcs) in seen.items():
        buckets[categorize(tag)].append((tag, text, srcs))
    for entries in buckets.values():
        entries.sort(key=lambda e: e[0])

    out_path = Path(__file__).parent / "ui-text-keys.md"
    with out_path.open("w", encoding="utf-8") as f:
        total = sum(len(v) for v in buckets.values())
        f.write("# Civilization V UI Text Keys (EN_US)\n\n")
        f.write(
            "Extracted from the shipped game's English text XML "
            "(`Assets/Gameplay/XML/NewText/EN_US/`, all DLC `Text/EN_US/` "
            "and Expansion `Text/en_US/` dirs). Filter: text length "
            f"<= {MAX_TEXT_LEN} chars, no `[NEWLINE]` markup, "
            "no prose-content key suffixes.\n\n"
        )
        f.write(
            f"{total} keys grouped by inferred category from the key prefix. "
            "Use Ctrl-F to find a label before adding a mod-authored string. "
            "If a key is listed multiple times across DLC text files, all "
            "sources are shown — the engine merges them into one global "
            "table and the last-loaded value wins (in practice the texts "
            "match).\n\n"
        )
        f.write(
            "Lookup at runtime: `Locale.ConvertTextKey(\"TXT_KEY_X\")`. "
            "Returned strings may contain markup tokens (`[ICON_GOLD]`, "
            "`[COLOR_X]`, `{1_n}` placeholders) that need stripping or "
            "filling before reaching Tolk.\n\n"
        )
        f.write("Regenerate with `python _extract.py` from this directory.\n\n")
        f.write("---\n\n")

        # Stable category order (categories defined above, then "Other").
        order = [c[0] for c in CATEGORIES] + ["Other UI labels"]
        for cat in order:
            entries = buckets.get(cat)
            if not entries:
                continue
            f.write(f"## {cat} ({len(entries)})\n\n")
            for tag, text, srcs in entries:
                # Single backtick around text; pipe-escape isn't needed since
                # we're not using tables.
                display_text = text.replace("`", "\\`")
                src_str = ", ".join(f"`{s}`" for s in srcs)
                f.write(f"- `{tag}` — {display_text}  \n  source: {src_str}\n")
            f.write("\n")

    print(
        f"Wrote {total} UI keys across {len(buckets)} categories "
        f"to {out_path}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())

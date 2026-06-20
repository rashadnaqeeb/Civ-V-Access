#!/usr/bin/env python3
"""Dump an engine-merged Civ V cache database into the DLC GameData XML form
that a modpack's Override/ folder ingests.

Two outputs, matching the MPMP_Maker (Gedemon) layout that VP modpacks have
shipped for years:

  CIV5Units.xml         every gameplay table as a <Table> schema declaration
                        followed by <Delete/> + one <Row> per row. The schema
                        must be declared here because the modpack blanks the
                        base-game GameData files with empty stubs, so this file
                        is the sole definition the engine sees.
  CIV5Units_Mongol.xml  the merged en_US text table as <Replace Tag><Text> rows.

Source DBs are the engine's own merge, left in
<Documents>/My Games/Sid Meier's Civilization 5/cache/ after a session:
  Civ5DebugDatabase.db   -> gameplay
  Localization-Merged.db -> text

We dump the engine's already-merged database; we never re-implement the merge.

Tables the reference pack omits (art/audio/mapscript/runtime state); these are
supplied by the embedded mod files or are not gameplay data.
"""
import argparse
import re
import sqlite3
import xml.sax.saxutils as sax
from pathlib import Path

IGNORE_TABLES = {
    "ApplicationInfo", "DownloadableContent", "ScannedFiles",
    "sqlite_sequence", "sqlite_stat1",
    "ArtDefine_LandmarkTypes", "ArtDefine_Landmarks", "ArtDefine_StrategicView",
    "ArtDefine_UnitInfoMemberInfos", "ArtDefine_UnitInfos",
    "ArtDefine_UnitMemberCombatWeapons", "ArtDefine_UnitMemberCombats",
    "ArtDefine_UnitMemberInfos",
    "Audio_2DSounds", "Audio_3DSounds", "Audio_ScriptTypes",
    "Audio_SoundLoadTypes", "Audio_SoundScapeElementScripts",
    "Audio_SoundScapeElements", "Audio_SoundScapes", "Audio_SoundTypes",
    "Audio_Sounds", "Audio_SpeakerChannels",
    "MapScriptOptionPossibleValues", "MapScriptOptions", "MapScriptRequiredDLC",
    "MapScripts", "Map_Folders", "Map_Sizes", "Maps",
}


def parse_create_sql(sql):
    """Return {column_name: {'unique': bool, 'autoincrement': bool}} from a
    CREATE TABLE statement. PRAGMA gives everything else (type, notnull,
    default, pk) more cleanly; only these two flags need the raw SQL."""
    inner = sql[sql.index("(") + 1: sql.rindex(")")]
    out = {}
    # Column boundaries: a comma followed by a quoted column name. Table-level
    # constraints (CONSTRAINT/FOREIGN KEY/...) do not start with a quote.
    for seg in re.split(r"\s*,\s*(?=')", inner):
        m = re.match(r"'([^']+)'\s+(.*)", seg, re.S)
        if not m:
            continue
        name, rest = m.group(1), m.group(2).lower()
        out[name] = {
            "unique": " unique" in (" " + rest),
            "autoincrement": "autoincrement" in rest,
        }
    return out


def col_attrs(con, table):
    """Ordered list of (name, type, attr_string) for a table's columns,
    formatted as the reference dump's <Column> attributes."""
    flags = {}
    row = con.execute(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table,)
    ).fetchone()
    if row and row[0]:
        flags = parse_create_sql(row[0])
    cols = []
    for cid, name, ctype, notnull, dflt, pk in con.execute(
        f'PRAGMA table_info("{table}")'
    ):
        f = flags.get(name, {})
        attrs = []
        if pk:
            attrs.append('primarykey="true"')
            if f.get("autoincrement"):
                attrs.append('autoincrement="true"')
        if f.get("unique"):
            attrs.append('unique="true"')
        if notnull:
            attrs.append('notnull="true"')
        if dflt is not None:
            d = dflt
            # PRAGMA quotes text defaults with single quotes; the XML form drops them.
            if len(d) >= 2 and d[0] == "'" and d[-1] == "'":
                d = d[1:-1]
            attrs.append(f'default="{sax.quoteattr(d)[1:-1]}"')
        cols.append((name, (ctype or "").lower(), " ".join(attrs)))
    return cols


# Custom mod options we force on in the baked modpack regardless of the cache
# value, because the merge session deliberately runs without the upstream UI
# mod that would set them. SQUADS is the accessibility squad layer: VP's own
# "(4a) Squads for VP" mod sets CustomModOptions.SQUADS=1, but it is visual-
# only and collides with our InGame.lua override, so we never load it; the CP
# DLL ships the SQUADS row defaulting to 0. Forcing the value here is the analog
# of BALANCE_VP riding the cache -- a single deterministic feature flag we own,
# not a re-implementation of the merge. The row exists in every CP/VP cache (the
# Community Patch schema inserts it), so this overrides rather than synthesizes;
# a missing row is logged loudly so the bake can't silently ship squads-off.
FORCE_CUSTOM_MOD_OPTIONS = {"SQUADS": 1}

# Enabling SQUADS is NOT just the option row. CP/VP's own core UI overrides
# (Community Patch InGame.lua, Vox Populi WorldView.lua) index
# GameInfo.InterfaceModes.INTERFACEMODE_SQUAD_*.ID whenever MOD_SQUADS is on; a
# nil row there throws and takes down WorldView/InGame -- the whole in-game UI.
# VP's (4a) Squads.sql adds these three interface modes alongside the option;
# we don't load (4a), so inject them here (Type / Description / CursorType only,
# matching (4a); other columns default). Without these the modpack would crash
# on load exactly as the mod-overlay did when SQUADS was set without them.
FORCE_INTERFACE_MODES = [
    ("INTERFACEMODE_SQUAD_UNIT_MANAGEMENT", "TXT_KEY_INTERFACEMODE_SQUAD_UNIT_MANAGEMENT", "CURSOR_DEFAULT"),
    ("INTERFACEMODE_SQUAD_BASE_MANAGEMENT", "INTERFACEMODE_SQUAD_BASE_MANAGEMENT", "CURSOR_DEFAULT"),
    ("INTERFACEMODE_SQUAD_MOVEMENT", "TXT_KEY_INTERFACEMODE_SQUAD_MOVEMENT", "CURSOR_GO_TO"),
]


def dump_gameplay(db_path, out_path):
    con = sqlite3.connect(db_path)
    tables = sorted(
        r[0] for r in con.execute(
            "SELECT name FROM sqlite_master WHERE type='table'"
        )
        if r[0] not in IGNORE_TABLES
    )
    parts = ['<?xml version="1.0" encoding="utf-8"?>',
             "<!-- generated by Civ V Access modpack dumper -->",
             "<GameData>"]
    for t in tables:
        cols = col_attrs(con, t)
        parts.append(f'\t<Table name="{t}">')
        for name, ctype, attrs in cols:
            a = f" {attrs}" if attrs else ""
            parts.append(f'\t\t<Column name="{name}" type="{ctype}"{a} />')
        parts.append("\t</Table>")
        parts.append(f"\t<{t}>")
        parts.append("\t\t<Delete />")
        colnames = [c[0] for c in cols]
        forced_seen = set()
        for row in con.execute(f'SELECT * FROM "{t}"'):
            vals = dict(zip(colnames, row))
            # Override owned feature flags in CustomModOptions to their baked
            # value (see FORCE_CUSTOM_MOD_OPTIONS). Keyed by the option Name.
            if t == "CustomModOptions":
                name = vals.get("Name")
                if name in FORCE_CUSTOM_MOD_OPTIONS:
                    forced = FORCE_CUSTOM_MOD_OPTIONS[name]
                    if vals.get("Value") != forced:
                        print(f"  CustomModOptions: forcing {name}="
                              f"{forced} (cache had {vals.get('Value')})")
                    vals["Value"] = forced
                    forced_seen.add(name)
            cells = []
            for name in colnames:
                val = vals[name]
                if val is None:
                    continue
                cells.append(f"<{name}>{sax.escape(str(val))}</{name}>")
            parts.append("\t\t<Row>" + "".join(cells) + "</Row>")
        if t == "InterfaceModes":
            # Inject the squad interface modes the forced SQUADS option requires
            # (see FORCE_INTERFACE_MODES). Skip any already present in the cache
            # so a future cache that ships them isn't duplicated.
            present = {
                r[0] for r in con.execute('SELECT Type FROM "InterfaceModes"')
            }
            for itype, desc, cursor in FORCE_INTERFACE_MODES:
                if itype in present:
                    continue
                print(f"  InterfaceModes: injecting {itype}")
                parts.append(
                    "\t\t<Row>"
                    f"<Type>{sax.escape(itype)}</Type>"
                    f"<Description>{sax.escape(desc)}</Description>"
                    f"<CursorType>{sax.escape(cursor)}</CursorType>"
                    "</Row>"
                )
        if t == "CustomModOptions":
            missing = set(FORCE_CUSTOM_MOD_OPTIONS) - forced_seen
            if missing:
                # The Community Patch schema always inserts these rows, so a
                # miss means the cache is not a CP/VP merge or the row was
                # renamed upstream. Refuse rather than bake a pack whose
                # squad layer would be silently inert.
                raise SystemExit(
                    "CustomModOptions is missing forced option row(s) "
                    f"{sorted(missing)}; the cache is not a Community "
                    "Patch / Vox Populi merge, or the option was renamed "
                    "upstream. Re-pin or replay a clean CP/VP session.")
        parts.append(f"\t</{t}>")
    parts.append("</GameData>")
    con.close()
    Path(out_path).write_text("\n".join(parts), encoding="utf-8")
    return len(tables)


def dump_text(db_path, out_path):
    con = sqlite3.connect(db_path)
    parts = ['<?xml version="1.0" encoding="utf-8"?>',
             "<!-- generated by Civ V Access modpack dumper -->",
             "<GameData>", "\t<Language_en_US>"]
    n = 0
    for tag, text in con.execute(
        "SELECT Tag, Text FROM Language_en_US ORDER BY Tag"
    ):
        if tag is None or "TURN_REMINDER_EMAIL" in tag:
            continue
        body = sax.escape(text) if text is not None else ""
        parts.append(f'\t\t<Replace Tag="{sax.quoteattr(tag)[1:-1]}">'
                     f"<Text>{body}</Text></Replace>")
        n += 1
    parts.append("\t</Language_en_US>")
    parts.append("</GameData>")
    con.close()
    Path(out_path).write_text("\n".join(parts), encoding="utf-8")
    return n


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--gameplay-db", required=True)
    ap.add_argument("--text-db", required=True)
    ap.add_argument("--out-dir", required=True)
    args = ap.parse_args()
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    nt = dump_gameplay(args.gameplay_db, out / "CIV5Units.xml")
    ns = dump_text(args.text_db, out / "CIV5Units_Mongol.xml")
    print(f"gameplay: {nt} tables -> {out / 'CIV5Units.xml'}")
    print(f"text: {ns} strings -> {out / 'CIV5Units_Mongol.xml'}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Assemble an EUI-free Vox Populi modpack DLC for Civ V Access.

Produces a Gedemon-MPMP-shaped DLC folder, started from the regular Single
Player menu, that bakes Community Patch + Vox Populi into Assets/DLC. Unlike the
community packs this bundles no EUI and embeds our engine fork.

Layout produced (mirrors a working VP modpack):
  <out>/
    MPModsPack.Civ5Pkg     manifest: Expansion2 UISkin, GameplaySkin = UI + Mods,
                           BNW SteamApp/Key, unique GUID, priority 300.
    Override/              merged DB (CIV5Units.xml + CIV5Units_Mongol.xml from
                           dump_db) plus the base-GameData blanking stubs and the
                           audio/dialog Override files.
    Mods/<mod (v N)>/      pristine CP + VP folders from the clone, CP's gamecore
                           DLL replaced by our fork. The engine loads the fork
                           from here (proven 2026-06-14); SetDllPath-style.
    UI/InGame.lua          base InGame plus explicit LoadNewContext calls for the
                           net-new contexts (the stock activated-mod loop is inert
                           under DLC). Shadowed when our DLC is present and carries
                           the appends; active for sighted-partner installs.

The merged database is the engine's own merge (dump_db reads the cache DB); we
never re-implement it. Run a clean CP+VP session (Squads OFF) first so the cache
DB the dumper reads is plain VP.

Self-contained: the Override blanking stubs and the few non-empty Override files
ship with this tool (override_stubs.txt + override_aux/), so no reference pack is
needed. The stub names are base-game GameData files (stable across VP versions);
the aux files are VP's merged audio scripts/defines and leader-dialog fragments.
"""
import argparse
import shutil
import sqlite3
from pathlib import Path

import dump_db


def check_clean_db(gameplay_db, allow_squads, cp_only):
    """Refuse to bake a database that isn't the expected merge.

    Full VP (default): VP balance must be on (BALANCE_VP=1), Squads off.
    CP-only (--community-patch-only): the Community Patch DLL must be present
    (the CustomModOptions table exists, which only the CP/VP DLL creates) but
    VP balance must be OFF (BALANCE_VP != 1) -- otherwise this is a VP merge
    mislabelled, or a plain-vanilla cache. A modpack session's own cache bakes
    whatever that pack carried, so this also guards against a contaminated
    cache."""
    con = sqlite3.connect(gameplay_db)
    try:
        # An empty Civ5DebugDatabase.db is the classic "ValidateGameDatabase=0"
        # trap: the merged database compiles in memory and the session plays
        # fine, but the debug DB the bake reads is only persisted during the
        # validation pass. A real CP/VP merge has hundreds of tables; a near-
        # empty file means no usable merge was captured. Fail here with the fix
        # rather than bake a hollow modpack.
        ntables = con.execute(
            "SELECT count(*) FROM sqlite_master WHERE type='table'").fetchone()[0]
        if ntables < 50:
            raise SystemExit(
                f"Gameplay database has only {ntables} tables -- it was not "
                "populated by a real merge. Set ValidateGameDatabase=1 (and "
                "LoggingEnabled=1) in config.ini, replay a clean CP+VP session "
                "to the map, quit, and re-run. (deploy-vp.ps1 sets the flag for "
                "you; the CP-only path on vanilla needs it set by hand.)")
        def opt(name):
            r = con.execute(
                "SELECT Value FROM CustomModOptions WHERE Name=?", (name,)
            ).fetchone()
            return r[0] if r else None
        try:
            cp_present = con.execute(
                "SELECT count(*) FROM CustomModOptions").fetchone()[0] > 0
            balance, squads = opt("BALANCE_VP"), opt("SQUADS")
        except sqlite3.OperationalError:
            # No CustomModOptions table at all -> plain vanilla cache.
            cp_present, balance, squads = False, None, None
    finally:
        con.close()
    print(f"  cache DB options: CP_present={cp_present} BALANCE_VP={balance} "
          f"SQUADS={squads}")
    if cp_only:
        if not cp_present:
            raise SystemExit(
                "Database has no Community Patch DLL merge (CustomModOptions "
                "absent). Play a clean Community-Patch-only session through the "
                "Mods menu first.")
        if balance == 1:
            raise SystemExit(
                "Database is a Vox Populi merge (BALANCE_VP=1), not Community "
                "Patch only. Enable ONLY (1) Community Patch and replay.")
        return
    if balance != 1:
        raise SystemExit(
            f"Database is not a VP merge (BALANCE_VP={balance}). Play a clean "
            "CP+VP session through the Mods menu first.")
    # The merge session must run with VP's "(4a) Squads for VP" mod OFF -- its
    # UI collides with our InGame.lua override. The baked pack still enables
    # squads: dump_db forces CustomModOptions.SQUADS=1 in the Override (the
    # accessibility squad layer rides our own DLL bindings, not (4a)'s UI). So
    # a SQUADS=1 cache here means (4a) was loaded by mistake, which is what we
    # reject; the bake does not depend on the cache value for squads.
    if squads == 1 and not allow_squads:
        raise SystemExit(
            "Database has Squads enabled (SQUADS=1) in the cache, which means "
            "VP's '(4a) Squads for VP' mod was loaded -- its UI collides with "
            "ours. Disable it and replay a clean CP+VP session (the bake "
            "enables squads itself via dump_db), or pass --allow-squads.")

# Net-new contexts and gameplay/overlay addins, loaded by bare stem. Squads is
# excluded (not part of plain VP). Kept in the reference pack's order. The full
# (VP) list is the union of Community Patch's InGameUIAddin set and Vox Populi's;
# CP_ADDINS is exactly the (1) Community Patch InGameUIAddin set, so a CP-only
# pack loads no Corporations / Vassalage / RandomVC / antiquities-overlay
# contexts (all registered by Vox Populi, not Community Patch).
ADDINS = [
    "CameraView", "EventChoicePopupCity", "CityEventPopup", "Destination",
    "EspionageChoicePopup", "EventPopup", "EventChoicePopup", "EventOverview",
    "GlobalCityBombardRange", "CBP_IncaFunctions", "CorporationsOverview",
    "GlobalArchaeologistDigSites", "OverlayAntiquities_MiniMapOverlayHook",
    "OverlayAntiquities", "RandomVCPopup", "VassalageOverview",
]
CP_ADDINS = [
    "CameraView", "EventChoicePopupCity", "CityEventPopup", "Destination",
    "EspionageChoicePopup", "EventPopup", "EventChoicePopup", "EventOverview",
    "GlobalCityBombardRange",
]

# Mod folders to embed, in load order. Names match the clone's folders.
EMBED_MODS = ["(1) Community Patch", "(2) Vox Populi"]
CP_EMBED_MODS = ["(1) Community Patch"]
# The folder whose gamecore DLL we replace with our fork.
DLL_MOD = "(1) Community Patch"

# Committed Override template (self-contained; no reference-pack dependency).
SCRIPT_DIR = Path(__file__).resolve().parent
STUBS_FILE = SCRIPT_DIR / "override_stubs.txt"   # base-GameData blanking-stub names
AUX_DIR = SCRIPT_DIR / "override_aux"            # the few non-empty Override files VP ships

MANIFEST = """\
<?xml version="1.0" encoding="utf-8"?>
<Civ5Package>
    <GUID>{{{guid}}}</GUID>
    <SteamApp>235580</SteamApp>
    <Version>1</Version>
    <Key>bf6d34a0074b7ad4b1d1716475f7f7fe</Key>
    <Priority>300</Priority>
    <PTags>
        <Tag>Version</Tag>
    </PTags>
    <Name>
        <Value language="en_US">{name}</Value>
    </Name>
    <Description>
        <Value language="en_US">{desc}</Value>
    </Description>
    <UISkin name="Expansion2Primary" set="Expansion2" platform="Common">
        <GameplaySkin>
            <Directory>UI</Directory>
            <Directory>Mods</Directory>
        </GameplaySkin>
    </UISkin>
</Civ5Package>
"""

# Stable GUIDs for our modpack packages, distinct from our DLC's and the
# engine's, and distinct from each other (the VP and CP-only packs are separate
# DLCs and must never collide on the DLC list).
MODPACK_GUID = "C1FAC355-0000-4D0D-9ACC-E550564F5001"
CP_MODPACK_GUID = "C1FAC355-0000-4D0D-9ACC-E550564F5002"

PACK_NAME_VP = "Civ V Access - Vox Populi"
PACK_DESC_VP = "Vox Populi baked as DLC for Civ V Access (no EUI)."
PACK_NAME_CP = "Civ V Access - Community Patch"
PACK_DESC_CP = "Community Patch baked as DLC for Civ V Access (no EUI, no balance overhaul)."


def versioned_name(clone_mod_dir):
    """Folder name matching the proven pack: the modinfo file's stem."""
    infos = list(clone_mod_dir.glob("*.modinfo"))
    if not infos:
        raise SystemExit(f"No .modinfo in {clone_mod_dir}")
    return infos[0].stem


def build_override(out, gameplay_db, text_db):
    ov = out / "Override"
    ov.mkdir(parents=True, exist_ok=True)
    # Empty blanking stubs null out the base-game GameData files so only the
    # merged dump loads. The names are committed (base-game files are stable
    # across VP versions); an empty file replaces the base file by name.
    stubs = [s.strip() for s in STUBS_FILE.read_text(encoding="utf-8").splitlines()
             if s.strip()]
    for name in stubs:
        (ov / name).write_bytes(b"")
    # The few non-empty Override files VP ships (merged audio scripts/defines,
    # leader-dialog blanking fragments), committed under override_aux/.
    aux = 0
    for f in sorted(AUX_DIR.iterdir()):
        if f.is_file():
            shutil.copy2(f, ov / f.name)
            aux += 1
    nt = dump_db.dump_gameplay(gameplay_db, ov / "CIV5Units.xml")
    ns = dump_db.dump_text(text_db, ov / "CIV5Units_Mongol.xml")
    print(f"  Override: {len(stubs)} stubs + {aux} aux + {nt} tables + {ns} strings")


def embed_mods(out, clone, fork_dll, embed_mods_list):
    mods = out / "Mods"
    mods.mkdir(parents=True, exist_ok=True)
    for name in embed_mods_list:
        src = Path(clone) / name
        if not src.is_dir():
            raise SystemExit(f"Clone mod folder missing: {src}")
        dst = mods / versioned_name(src)
        print(f"  embedding {name} -> Mods/{dst.name} ...")
        shutil.copytree(src, dst, dirs_exist_ok=True)
        if name == DLL_MOD:
            shutil.copy2(fork_dll, dst / "CvGameCore_Expansion2.dll")
            print(f"    fork DLL placed in {dst.name}")


def assert_addins_present(out, addins):
    """Fail loudly if an addin stem no longer resolves to a file in the embedded
    Mods tree -- a re-pin that renamed or dropped a context would otherwise bake
    a LoadNewContext for a stem the VFS can't serve, a silent no-op screen."""
    mods = out / "Mods"
    have = {p.stem for p in mods.rglob("*.lua")} | {p.stem for p in mods.rglob("*.xml")}
    missing = [a for a in addins if a not in have]
    if missing:
        raise SystemExit(
            "Addin stems not found in embedded mods (re-pin drift?): "
            + ", ".join(missing))


def build_ui(out, base_ingame, addins):
    ui = out / "UI"
    ui.mkdir(parents=True, exist_ok=True)
    body = Path(base_ingame).read_text(encoding="utf-8", errors="surrogateescape")
    appends = [
        "",
        "-- Civ V Access modpack: net-new VP/CP contexts load via the modinfo",
        "-- InGameUIAddin path, which is inert under a DLC. The stock loop above",
        "-- returns nothing, so load them explicitly by stem. (Our DLC's InGame",
        "-- override carries the same appends and wins by priority when present.)",
    ]
    appends += [f'ContextPtr:LoadNewContext("{a}")' for a in addins]
    out_text = body.rstrip("\n") + "\n" + "\n".join(appends) + "\n"
    (ui / "InGame.lua").write_text(out_text, encoding="utf-8",
                                   errors="surrogateescape")
    print(f"  UI/InGame.lua: base + {len(addins)} addin appends")


def write_manifest(out, guid, name, desc):
    (out / "MPModsPack.Civ5Pkg").write_text(
        MANIFEST.format(guid=guid, name=name, desc=desc), encoding="utf-8")
    print(f"  MPModsPack.Civ5Pkg written ({name})")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--clone", required=True, help="Community-Patch-DLL clone root")
    ap.add_argument("--fork-dll", required=True, help="dist/engine-vp DLL")
    ap.add_argument("--gameplay-db", required=True)
    ap.add_argument("--text-db", required=True)
    ap.add_argument("--base-ingame", required=True,
                    help="base Expansion2 InGame.lua to append addin loads to")
    ap.add_argument("--out", required=True)
    ap.add_argument("--skip-embed", action="store_true",
                    help="skip the heavy Mods/ copy (iterate on the rest)")
    ap.add_argument("--allow-squads", action="store_true",
                    help="bake even if the DB has Squads enabled (not plain VP)")
    ap.add_argument("--community-patch-only", action="store_true",
                    help="bake a Community-Patch-only pack (no Vox Populi mod, "
                         "CP addin set, CP merged DB) instead of full VP")
    args = ap.parse_args()

    cp_only = args.community_patch_only
    addins = CP_ADDINS if cp_only else ADDINS
    embed = CP_EMBED_MODS if cp_only else EMBED_MODS
    guid = CP_MODPACK_GUID if cp_only else MODPACK_GUID
    name = PACK_NAME_CP if cp_only else PACK_NAME_VP
    desc = PACK_DESC_CP if cp_only else PACK_DESC_VP

    print(f"Building {'Community Patch' if cp_only else 'Vox Populi'} modpack "
          f"at {args.out}")
    check_clean_db(args.gameplay_db, args.allow_squads, cp_only)
    out = Path(args.out)
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    build_override(out, args.gameplay_db, args.text_db)
    if not args.skip_embed:
        embed_mods(out, args.clone, args.fork_dll, embed)
        assert_addins_present(out, addins)
    else:
        print("  (skipped Mods/ embed)")
    build_ui(out, args.base_ingame, addins)
    write_manifest(out, guid, name, desc)
    print("Done.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Vendoring tool for the base-game override files under src/dlc/UI.

Every non-CivVAccess_ .lua/.xml under src/dlc/UI is a vendor override:
an engine-shipped file plus our additions. The manifest (manifest.json,
next to this script) records those additions per file as

    committed = prefix + edits(engine body) + suffix

where prefix/suffix are literal text (header comments, prologue includes,
tail includes) and edits are exact-match replacements applied to the
engine body (local-to-global promotions, typo fixes). Refit files are
hand-maintained rewrites the generator never touches.

Commands:
    bootstrap   Build/refresh the manifest from the committed tree by
                matching each override against the vanilla source roots.
                Files that don't fit the prefix+body+suffix model are
                reported for hand-authored edit recipes.
    verify      Regenerate every override from the vanilla roots and
                byte-compare against the committed tree. Any mismatch is
                a hard failure; the committed tree is only trustworthy
                input for other engines while this is green.
    generate    Regenerate the overrides from another engine's source
                roots (currently: vp) into a staging directory, with a
                drift report of which root supplied each file.

Source roots are ordered to mirror VFS precedence; the first root that
ships a stem wins. Mod roots only expose files their .modinfo imports
into the VFS.
"""

import argparse
import difflib
import json
import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(SCRIPT_DIR))
OVERRIDE_BASE = os.path.join(REPO_ROOT, "src", "dlc", "UI")
MANIFEST_PATH = os.path.join(SCRIPT_DIR, "manifest.json")

VENDOR_EXTS = (".lua", ".xml")

DEFAULT_GAME_DIR = (
    r"C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V"
)


def default_mods_dir():
    return os.path.join(
        os.path.expanduser("~"),
        "Documents",
        "My Games",
        "Sid Meier's Civilization 5",
        "MODS",
    )


def default_clone_dir():
    return os.path.join(os.path.dirname(REPO_ROOT), "Community-Patch-DLL")


class VendorError(Exception):
    pass


def fail(msg):
    raise VendorError(msg)


def read_bytes(path):
    with open(path, "rb") as f:
        return f.read()


def to_text(data):
    # latin-1 round-trips arbitrary bytes, so prefix/suffix/edit strings
    # survive JSON storage even if a vendor file isn't UTF-8.
    return data.decode("latin-1")


def to_bytes(text):
    return text.encode("latin-1")


def norm_line(line):
    """Whitespace-insensitive line key: collapse runs, strip ends, drop EOL.
    History: many committed vendor copies were saved through editors that
    converted CRLF to LF, stripped trailing whitespace, or re-indented.
    Lines equal under this key are treated as the same vendor line; the fix
    is always restoring the verbatim vendor bytes, never normalizing
    output."""
    return re.sub(rb"[ \t]+", b" ", line).strip()


def file_eol(data):
    return b"\r\n" if b"\r\n" in data else b"\n"


def convert_eol(data, eol):
    out = eol.join(data.splitlines())
    if data.endswith(b"\n"):
        out += eol
    return out


def derive_entry(vendor, committed):
    """Derive (prefix, suffix, edits) such that
    prefix + edits(vendor) + suffix == canonical restored file.

    Compares line-by-line under norm_line. Returns None when the files are
    too divergent for line matching (e.g. a wholesale reformat) -- those
    need a hand-authored manifest entry. Inserted/changed text is taken
    from the committed file with line endings converted to the vendor's,
    so restored files stay internally consistent."""
    vl = vendor.splitlines(keepends=True)
    cl = committed.splitlines(keepends=True)
    eol = file_eol(vendor)
    sm = difflib.SequenceMatcher(
        None, [norm_line(x) for x in vl], [norm_line(x) for x in cl], autojunk=False
    )
    opcodes = sm.get_opcodes()
    equal = sum(i2 - i1 for tag, i1, i2, _j1, _j2 in opcodes if tag == "equal")
    if vl and equal / len(vl) < 0.6:
        return None

    prefix = b""
    suffix = b""
    edits = []
    for tag, i1, i2, j1, j2 in opcodes:
        if tag == "equal":
            continue
        new_text = convert_eol(b"".join(cl[j1:j2]), eol)
        if tag == "insert" and i1 == 0:
            prefix = new_text
            continue
        if tag == "insert" and i1 == len(vl):
            # If the vendor body lacks a trailing newline but the committed
            # copy terminates that last line before our appended tail, the
            # suffix must carry the newline.
            if vendor and not vendor.endswith(b"\n") and cl[j1 - 1].endswith(b"\n"):
                suffix = eol + new_text
            else:
                suffix = new_text
            continue
        old = b"".join(vl[i1:i2])
        new = new_text
        # Anchor with preceding verbatim vendor lines until the old text
        # matches exactly once (pure insertions start empty and always
        # need an anchor).
        ctx = i1
        while old == b"" or vendor.count(old) != 1:
            if ctx == 0:
                return None
            ctx -= 1
            old = vl[ctx] + old
            new = vl[ctx] + new
        edits.append({"old": to_text(old), "new": to_text(new)})
    return prefix, suffix, edits


class Root:
    """One ordered source layer: a directory tree or a mod's VFS imports."""

    def __init__(self, name, base_dir, files):
        self.name = name
        self.base_dir = base_dir
        # lowercase basename -> list of relpaths (forward slashes)
        self.index = {}
        for rel in files:
            self.index.setdefault(os.path.basename(rel).lower(), []).append(rel)

    def candidates(self, basename):
        return [
            (rel, os.path.join(self.base_dir, rel.replace("/", os.sep)))
            for rel in self.index.get(basename.lower(), [])
        ]


def dir_root(name, base_dir):
    if not os.path.isdir(base_dir):
        fail("source root missing: " + base_dir)
    files = []
    for dirpath, _dirnames, filenames in os.walk(base_dir):
        for fn in filenames:
            if fn.lower().endswith(VENDOR_EXTS):
                rel = os.path.relpath(os.path.join(dirpath, fn), base_dir)
                files.append(rel.replace(os.sep, "/"))
    return Root(name, base_dir, files)


def mod_root(name, mod_dir):
    if not os.path.isdir(mod_dir):
        fail("mod directory missing: " + mod_dir)
    modinfos = [f for f in os.listdir(mod_dir) if f.lower().endswith(".modinfo")]
    if len(modinfos) != 1:
        fail("expected exactly one .modinfo in %s, found %d" % (mod_dir, len(modinfos)))
    text = read_bytes(os.path.join(mod_dir, modinfos[0])).decode("utf-8", "replace")
    files = []
    for m in re.finditer(r"<File\b([^>]*)>([^<]+)</File>", text):
        attrs, rel = m.group(1), m.group(2).strip()
        if 'import="1"' in attrs and rel.lower().endswith(VENDOR_EXTS):
            files.append(rel.replace("\\", "/"))
    # UI addin entry points are loaded from the mod folder by path, not
    # through the VFS, so they carry import="0" -- index them too (the
    # net-new VP/CP screens our vp-only entries override live here),
    # plus the paired .lua/.xml sibling the engine loads alongside a
    # context. Other import="0" files stay unindexed: the engine never
    # serves them, so sourcing an override from one would be wrong.
    for m in re.finditer(r'<EntryPoint\b[^>]*\bfile="([^"]+)"', text):
        rel = m.group(1).strip().replace("\\", "/")
        if not rel.lower().endswith(VENDOR_EXTS):
            continue
        stem, ext = os.path.splitext(rel)
        sibling = stem + (".xml" if ext.lower() == ".lua" else ".lua")
        for cand in (rel, sibling):
            if cand not in files and os.path.isfile(
                os.path.join(mod_dir, cand.replace("/", os.sep))
            ):
                files.append(cand)
    root = Root(name, mod_dir, files)
    root.is_mod = True
    return root


def vanilla_roots(game_dir):
    """The live chain for a BNW-based session is BNW then base. G&K is
    deliberately absent: a UISkin only layers when its `set` matches the
    active expansion, and G&K's set=Expansion1 skin is never active when
    BNW (set=Expansion2) is -- its UI files are dead in every session the
    mod supports."""
    assets = os.path.join(game_dir, "Assets")
    if not os.path.isdir(assets):
        fail("not a Civ V install (no Assets): " + game_dir)
    return [
        dir_root("BNW", os.path.join(assets, "DLC", "Expansion2", "UI")),
        dir_root("base", os.path.join(assets, "UI")),
        # Shared-DLC UI, lowest precedence: consulted only for stems that
        # exist nowhere in BNW or base (e.g. ChangeSmtpPassword, the pitboss
        # SMTP-password modal, which ships only under DLC/Shared). Placed last
        # so it never changes how an existing override resolves -- resolve_source
        # returns the first root that ships a stem, and every other override's
        # stem is found in BNW or base before this root is reached.
        dir_root("shared", os.path.join(assets, "DLC", "Shared", "UI")),
    ]


def vp_roots(game_dir, mods_dir, clone_dir):
    return [
        mod_root("VP", os.path.join(mods_dir, "(2) Vox Populi")),
        mod_root("CP", os.path.join(mods_dir, "(1) Community Patch")),
        dir_root("VPUI", os.path.join(clone_dir, "VPUI")),
    ] + vanilla_roots(game_dir)


def cp_roots(game_dir, mods_dir):
    """The Community-Patch-only chain: CP's mod files over the vanilla
    BNW/base chain, with no (2) Vox Populi folder and no VPUI. Those ship the
    balance overhaul and its UI mod and are absent in a CP-only session, so a
    file VP-but-not-CP overrides falls through to its vanilla body here -- the
    drift report is then exactly the set of CP-divergent files."""
    return [
        mod_root("CP", os.path.join(mods_dir, "(1) Community Patch")),
    ] + vanilla_roots(game_dir)


def collect_overrides():
    """All committed vendor override files, relpaths under src/dlc/UI."""
    out = []
    for dirpath, _dirnames, filenames in os.walk(OVERRIDE_BASE):
        for fn in filenames:
            if not fn.lower().endswith(VENDOR_EXTS):
                continue
            if fn.startswith("CivVAccess_"):
                continue
            rel = os.path.relpath(os.path.join(dirpath, fn), OVERRIDE_BASE)
            out.append(rel.replace(os.sep, "/"))
    return sorted(out)


def resolve_source(entry, rel, roots, engine):
    """First root that ships the stem wins, unless the manifest pins this
    engine's source ("source": {"<engine>": "<root>:<relpath>"} -- used
    where the committed override deliberately ships a copy that VFS-first
    resolution would not pick). Returns (root, (relpath, abspath))."""
    basename = os.path.basename(rel)
    pin = entry.get("source", {}).get(engine)
    if pin is not None:
        root_name, _, forced = pin.partition(":")
        for root in roots:
            if root.name != root_name:
                continue
            cands = [c for c in root.candidates(basename) if c[0] == forced]
            if not cands:
                fail("%s: pinned source %s not found" % (rel, pin))
            return root, cands[0]
        fail("%s: pinned source root %s not in engine %s" % (rel, root_name, engine))
    for root in roots:
        cands = root.candidates(basename)
        if not cands:
            continue
        if len(cands) > 1:
            # Prefer the candidate whose relative path matches ours.
            exact = [c for c in cands if c[0].lower() == rel.lower()]
            if len(exact) == 1:
                return root, exact[0]
            fail(
                "ambiguous stem %s in root %s: %s (disambiguate with a "
                '"source" pin in the manifest)'
                % (basename, root.name, ", ".join(c[0] for c in cands))
            )
        return root, cands[0]
    fail("stem %s not found in any source root" % basename)


def apply_edits(body, edits, engine, rel):
    for edit in edits:
        engines = edit.get("engines")
        if engines is not None and engine not in engines:
            continue
        old = to_bytes(edit["old"])
        new = to_bytes(edit["new"])
        count = edit.get("count", 1)
        found = body.count(old)
        if found != count:
            fail(
                "%s: edit %r matched %d times in %s source, expected %d"
                % (rel, edit["old"][:60], found, engine, count)
            )
        body = body.replace(old, new)
    return body


def build_file(entry, rel, roots, engine):
    """Returns (root, source_relpath, generated_bytes). An engine-named
    sub-object in the entry overrides prefix/suffix/edits for that engine
    (recipes are byte-exact against one engine's source, so another
    engine's rewritten copy usually needs its own). An engine sub-object of
    the form {"alias": "<other>"} reuses that other engine's sub-object
    verbatim -- used where two engines resolve to the identical modded body
    (e.g. a Community-Patch-shipped file Vox Populi does not override, so the
    vp recipe is really a CP-body recipe and cp must apply the same edits)."""
    over = entry.get(engine, {})
    alias = over.get("alias")
    if alias is not None:
        over = entry.get(alias, {})
    root, (src_rel, src_abs) = resolve_source(entry, rel, roots, engine)
    body = read_bytes(src_abs)
    body = apply_edits(body, over.get("edits", entry.get("edits", [])), engine, rel)
    prefix = over.get("prefix", entry.get("prefix", ""))
    suffix = over.get("suffix", entry.get("suffix", ""))
    return root, src_rel, to_bytes(prefix) + body + to_bytes(suffix)


def load_manifest():
    if not os.path.isfile(MANIFEST_PATH):
        fail("no manifest at %s -- run bootstrap first" % MANIFEST_PATH)
    with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
        manifest = json.load(f)
    return manifest


def entry_engines(entry):
    """Engines an entry exists on. Default: every engine. An explicit
    "engines" list marks files with no counterpart elsewhere (net-new mod
    Contexts like the CP event popups exist only under VP); entries
    without "vanilla" have no committed file under src/dlc/UI and are
    skipped by verify/restore."""
    return entry.get("engines")


def on_engine(entry, engine):
    engines = entry_engines(entry)
    return engines is None or engine in engines


def check_completeness(manifest):
    committed = set(collect_overrides())
    listed = set(manifest["files"].keys())
    problems = []
    for rel in sorted(committed - listed):
        problems.append("override not in manifest: " + rel)
    for rel in sorted(listed - committed):
        if not on_engine(manifest["files"][rel], "vanilla"):
            continue  # engine-specific entry; no committed vanilla copy
        problems.append("manifest entry has no committed file: " + rel)
    return problems


# ---------------------------------------------------------------- bootstrap


def cmd_bootstrap(args):
    roots = vanilla_roots(args.game)
    existing = {}
    if os.path.isfile(MANIFEST_PATH):
        with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
            existing = json.load(f).get("files", {})

    files = {}
    unmatched = []
    derived = []
    shadowed = []
    for rel in collect_overrides():
        committed = read_bytes(os.path.join(OVERRIDE_BASE, rel.replace("/", os.sep)))
        prev = existing.get(rel, {})
        if prev.get("hand") or prev.get("refit") or prev.get("owned"):
            # Hand-authored entries survive re-bootstrap untouched.
            files[rel] = prev
            continue
        basename = os.path.basename(rel)
        all_cands = [
            (root, src_rel, src_abs)
            for root in roots
            for src_rel, src_abs in root.candidates(basename)
        ]
        match = None
        how = "clean"
        # Exact containment anywhere beats a derived recipe anywhere: a
        # later root's verbatim copy is the real source, not an earlier
        # root's near-miss.
        for root, src_rel, src_abs in all_cands:
            body = read_bytes(src_abs)
            i = committed.find(body)
            if i >= 0:
                match = (root, src_rel, committed[:i], committed[i + len(body):], [])
                break
        if match is None:
            # Among all derivable candidates, the real source is the one
            # needing the fewest edits (ties resolve in root order).
            best = None
            best_edits = None
            for root, src_rel, src_abs in all_cands:
                got = derive_entry(read_bytes(src_abs), committed)
                if got is not None and (best is None or len(got[2]) < best_edits):
                    best = (root, src_rel) + got
                    best_edits = len(got[2])
            if best is not None:
                match = best
                how = "derived"
        if match:
            root, src_rel, pre, suf, edits = match
            entry = {}
            if pre:
                entry["prefix"] = to_text(pre)
            if suf:
                entry["suffix"] = to_text(suf)
            if edits:
                entry["edits"] = edits
            # If VFS-first resolution would pick a different copy than the
            # one the committed override actually contains, pin it and
            # flag the shadowing: the override is reverting a later
            # engine layer's version of this stem.
            first_root, (first_rel, _) = resolve_source({}, rel, roots, "vanilla")
            if (first_root.name, first_rel) != (root.name, src_rel):
                entry["source"] = {"vanilla": "%s:%s" % (root.name, src_rel)}
                shadowed.append(
                    "%s: ships %s:%s but VFS would serve %s:%s"
                    % (rel, root.name, src_rel, first_root.name, first_rel)
                )
            if "vp" in prev:  # per-engine recipes are hand-authored
                entry["vp"] = prev["vp"]
            files[rel] = entry
            if how == "derived":
                derived.append((rel, len(edits)))
            print("%-8s %-60s <- %s:%s" % (how, rel, root.name, src_rel))
        else:
            unmatched.append(rel)
            files[rel] = prev if prev else {"bootstrap_unmatched": True}

    manifest = {
        "_comment": (
            "Vendor override manifest; see tools/vendoring/vendor.py. "
            "prefix/suffix are literal text around the verbatim engine body; "
            "edits are exact-match replacements applied to the body; "
            "refit files are hand-maintained per engine."
        ),
        "files": {rel: files[rel] for rel in sorted(files)},
    }
    with open(MANIFEST_PATH, "w", encoding="utf-8", newline="\n") as f:
        json.dump(manifest, f, indent=2)
        f.write("\n")
    print("\nmanifest written: %s (%d files)" % (MANIFEST_PATH, len(files)))

    if shadowed:
        print(
            "\n%d override(s) ship a copy that VFS-first resolution would "
            "not pick (pinned in the manifest; each is reverting a later "
            "layer's version and needs a deliberate decision):" % len(shadowed)
        )
        for s in shadowed:
            print("  " + s)
    if derived:
        print(
            "\n%d file(s) got derived recipes (committed copy is not "
            "byte-verbatim vendor; run `restore` to canonicalize, then "
            "review git diff):" % len(derived)
        )
        for rel, n in derived:
            print("  %-60s %d edit(s)" % (rel, n))
    if unmatched:
        print("\n%d file(s) need hand-authored manifest entries:" % len(unmatched))
        for rel in unmatched:
            print("  " + rel)
            report_closest(rel, roots)
        sys.exit(1)


def report_closest(rel, roots):
    """For an unmatched override, show the closest source candidate."""
    committed = read_bytes(os.path.join(OVERRIDE_BASE, rel.replace("/", os.sep)))
    basename = os.path.basename(rel)
    best = None
    for root in roots:
        for src_rel, src_abs in root.candidates(basename):
            body = read_bytes(src_abs)
            ratio = difflib.SequenceMatcher(None, committed, body).quick_ratio()
            if best is None or ratio > best[0]:
                best = (ratio, root.name, src_rel)
    if best:
        print("    closest: %s:%s (ratio %.3f)" % (best[1], best[2], best[0]))
    else:
        print("    no candidate with this basename in any root")


# ---------------------------------------------------------------- restore


def cmd_restore(args):
    """Rewrite every committed override canonically from its manifest entry
    (verbatim vendor body + prefix/suffix/edits). A no-op for files that
    already verify; the one-time fix for copies that drifted through
    editor whitespace normalization or reformatting."""
    manifest = load_manifest()
    roots = vanilla_roots(args.game)
    changed = 0
    for rel, entry in sorted(manifest["files"].items()):
        if entry.get("bootstrap_unmatched"):
            fail("%s: unmatched bootstrap entry; finish the manifest first" % rel)
        if entry.get("owned") or not on_engine(entry, "vanilla"):
            continue
        _root, _src, generated = build_file(entry, rel, roots, "vanilla")
        dest = os.path.join(OVERRIDE_BASE, rel.replace("/", os.sep))
        if read_bytes(dest) != generated:
            with open(dest, "wb") as f:
                f.write(generated)
            changed += 1
            print("restored " + rel)
    print("%d file(s) rewritten" % changed)


# ---------------------------------------------------------------- verify


def cmd_verify(args):
    manifest = load_manifest()
    roots = vanilla_roots(args.game)
    problems = check_completeness(manifest)

    checked = 0
    for rel, entry in sorted(manifest["files"].items()):
        if entry.get("bootstrap_unmatched"):
            problems.append("%s: still unmatched from bootstrap" % rel)
            continue
        if entry.get("owned"):
            continue  # committed bytes ARE the source; nothing to compare
        if not on_engine(entry, "vanilla"):
            continue  # engine-specific entry; generate covers it
        checked += 1
        committed_path = os.path.join(OVERRIDE_BASE, rel.replace("/", os.sep))
        if not os.path.isfile(committed_path):
            continue  # already reported by completeness
        committed = read_bytes(committed_path)
        _root, _src, generated = build_file(entry, rel, roots, "vanilla")
        if generated != committed:
            n = min(len(generated), len(committed))
            diff_at = next(
                (i for i in range(n) if generated[i] != committed[i]), n
            )
            problems.append(
                "%s: regenerated differs at byte %d (generated %d bytes, "
                "committed %d)" % (rel, diff_at, len(generated), len(committed))
            )

    if problems:
        print("verify FAILED (%d problem(s)):" % len(problems))
        for p in problems:
            print("  " + p)
        sys.exit(1)
    print("verify OK: %d overrides reproduce byte-for-byte" % checked)


# ---------------------------------------------------------------- generate


def cmd_generate(args):
    manifest = load_manifest()
    problems = check_completeness(manifest)
    if problems:
        for p in problems:
            print("  " + p)
        fail("manifest out of sync with committed tree; re-run bootstrap")

    if args.engine == "vp":
        roots = vp_roots(args.game, args.mods, args.clone)
    elif args.engine == "cp":
        roots = cp_roots(args.game, args.mods)
    elif args.engine == "vanilla":
        roots = vanilla_roots(args.game)
    else:
        fail("unknown engine: " + args.engine)

    out_dir = os.path.abspath(args.out)
    report = []
    refits = []
    needs_recipe = []
    by_root = {}
    provenance = {}
    mod_root_dirs = {
        r.name: os.path.basename(r.base_dir) for r in roots if getattr(r, "is_mod", False)
    }
    for rel, entry in sorted(manifest["files"].items()):
        if entry.get("bootstrap_unmatched"):
            fail("%s: unmatched bootstrap entry; finish the manifest first" % rel)
        if not on_engine(entry, args.engine):
            continue
        if entry.get("refit") and args.engine != "vanilla":
            root, (src_rel, _) = resolve_source(entry, rel, roots, args.engine)
            refits.append("%-60s %s:%s" % (rel, root.name, src_rel))
            continue
        if entry.get("owned"):
            generated = read_bytes(
                os.path.join(OVERRIDE_BASE, rel.replace("/", os.sep))
            )
            root_name, src_rel = "owned", rel
        else:
            try:
                root, src_rel, generated = build_file(entry, rel, roots, args.engine)
            except VendorError as e:
                needs_recipe.append("%-60s %s" % (rel, e))
                continue
            root_name = root.name
        dest = os.path.join(out_dir, "UI", rel.replace("/", os.sep))
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(generated)
        report.append("%-60s %s:%s" % (rel, root_name, src_rel))
        by_root.setdefault(root_name, []).append(rel)
        provenance[rel] = {"root": root_name, "src_rel": src_rel}

    lines = ["drift report -- engine %s, %d files" % (args.engine, len(report))]
    lines.extend(report)
    if refits:
        lines.append("")
        lines.append("refit files (NOT generated; hand-maintained), with the")
        lines.append("source the engine ships (watch these across re-pins):")
        lines.extend(refits)
    if needs_recipe:
        lines.append("")
        lines.append(
            "%d file(s) NOT generated -- their recipe does not apply to this "
            "engine's source; author a per-engine recipe (%r sub-object) in "
            "the manifest:" % (len(needs_recipe), args.engine)
        )
        lines.extend(needs_recipe)
    lines.append("")
    lines.append("files per root:")
    for name, items in sorted(by_root.items()):
        lines.append("  %-6s %d" % (name, len(items)))

    report_path = os.path.join(out_dir, "vendor-report.txt")
    os.makedirs(out_dir, exist_ok=True)
    with open(report_path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")

    # Machine-readable provenance for the deploy script. Mods beat DLC in
    # the VFS, so any override whose stem a mod ships must additionally be
    # overlaid into that mod's folder (deploy-vp.ps1 reads mod_roots +
    # files to know which staged files go where).
    provenance_path = os.path.join(out_dir, "provenance.json")
    with open(provenance_path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(
            {"engine": args.engine, "mod_roots": mod_root_dirs, "files": provenance},
            f,
            indent=1,
            sort_keys=True,
        )
        f.write("\n")
    print("\n".join(lines))
    print("\nstaged: %s" % out_dir)
    print("report: %s" % report_path)
    print("provenance: %s" % provenance_path)
    if needs_recipe:
        sys.exit(1)


# ---------------------------------------------------------------- main


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--game",
        default=os.environ.get("CIV5_DIR", DEFAULT_GAME_DIR),
        help="Civ V install directory",
    )
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("bootstrap", help="build manifest from the committed tree")
    sub.add_parser(
        "restore", help="rewrite committed overrides canonically from the manifest"
    )
    sub.add_parser("verify", help="regenerate from vanilla and byte-compare")

    gen = sub.add_parser("generate", help="stage overrides for an engine")
    gen.add_argument("--engine", required=True, choices=["vanilla", "vp", "cp"])
    gen.add_argument(
        "--out",
        default=os.path.join(REPO_ROOT, "build", "vendor", "vp"),
        help="staging directory (default build/vendor/vp)",
    )
    gen.add_argument(
        "--mods",
        default=os.environ.get("CIV5_MODS_DIR", default_mods_dir()),
        help="Civ V MODS directory holding (1) Community Patch / (2) Vox Populi",
    )
    gen.add_argument(
        "--clone",
        default=os.environ.get("CPDLL_DIR", default_clone_dir()),
        help="Community-Patch-DLL clone (for the VPUI layer)",
    )

    args = ap.parse_args()
    try:
        if args.cmd == "bootstrap":
            cmd_bootstrap(args)
        elif args.cmd == "restore":
            cmd_restore(args)
        elif args.cmd == "verify":
            cmd_verify(args)
        elif args.cmd == "generate":
            cmd_generate(args)
    except VendorError as e:
        print("ERROR: %s" % e, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

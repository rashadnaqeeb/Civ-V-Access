#!/bin/sh
# Writes dist/release/loadstone-release.json, the release manifest the Loadstone installer reads.
# Loadstone's `package` command freezes loadstone-packages/civ-v-access.json for this version and
# hashes the twelve component zips, each tagged with the install options (profile, state) it
# belongs to, so a player downloads only their setup's components. The release notes are the
# version's CHANGELOG.md section. Run on a Mac after package-release.ps1 has filled dist/release/
# (the folder is shared with the Windows VM). Loadstone is a checkout beside this repo's parent
# folder (../../loadstone, from github.com/rashadnaqeeb/loadstone), or wherever LOADSTONE_DIR points.
set -eu

repo="$(cd "$(dirname "$0")" && pwd)"
loadstone="${LOADSTONE_DIR:-$(cd "$repo/../.." && pwd)/loadstone}"
[ -f "$loadstone/Cargo.toml" ] || {
    echo "Loadstone checkout not found: $loadstone (set LOADSTONE_DIR)" >&2
    exit 1
}
release="$repo/dist/release"
work="$(mktemp -d "${TMPDIR:-/tmp}/civ-loadstone-XXXXXX")"
trap 'rm -rf "$work"' EXIT

# The manifest plus a packaging block naming this release's zips (each component carries its
# own version, from versions.json) and the options each one serves.
version="$(python3 -I - "$repo" "$release" "$work" <<'PY'
import json, os, sys
repo, release, work = sys.argv[1:]
versions = json.load(open(os.path.join(repo, "versions.json"), encoding="utf-8"))
c = versions["components"]
def when(**option):
    return {"option": {k: v for k, v in option.items()}}
components = [
    # The first match is the primary artifact: one core always matches.
    ("core-blind", c["core"], "core-blind", when(profile="blind")),
    ("core-sighted", c["core"], "core-sighted", when(profile="sighted")),
    ("runtime", c["runtime"], "runtime", when(profile="blind")),
    ("cinematics", c["cinematics"], "cinematics", when(profile="blind")),
    ("engine", c["engine"], "engine", when(state="vanilla")),
    ("vp-overlay", c["vp_overlay"], "vp-overlay", when(profile="blind", state="vp")),
    ("cp-overlay", c["cp_overlay"], "cp-overlay", when(profile="blind", state="cp")),
    ("lekmod-overlay", c["lekmod_overlay"], "lekmod-overlay", when(profile="blind", state="lekmod")),
    ("vp-modpack", c["vp_modpack"], "vp-modpack", when(state="vp")),
    ("cp-modpack", c["cp_modpack"], "cp-modpack", when(state="cp")),
    ("vp-runtime", c["vp_runtime"], "vp-runtime", when(state="vp")),
    ("lekmod-dlc", c["lekmod_dlc"], "lekmod-dlc", when(state="lekmod")),
]
artifacts = []
for prefix, ver, artifact_id, cond in components:
    path = os.path.join(release, f"{prefix}-{ver}.zip")
    if not os.path.isfile(path):
        sys.exit(f"Release artifact not found: {path} (run package-release.ps1 first)")
    artifacts.append({"file": path, "id": artifact_id, "when": cond})
manifest = json.load(open(os.path.join(repo, "loadstone-packages", "civ-v-access.json"), encoding="utf-8"))
manifest["packaging"] = {"artifacts": artifacts}
json.dump(manifest, open(os.path.join(work, "civ-v-access.json"), "w", encoding="utf-8"), indent=2)

# The "## [<version>]" section of CHANGELOG.md, up to the next "## " heading.
lines, found = [], False
for line in open(os.path.join(repo, "CHANGELOG.md"), encoding="utf-8"):
    if line.startswith("## "):
        if found:
            break
        found = line.startswith(f"## [{versions['mod']}]")
        continue
    if found:
        lines.append(line)
notes = "".join(lines).strip()
if not notes:
    sys.exit(f"CHANGELOG.md has no non-empty '## [{versions['mod']}]' section")
open(os.path.join(work, "notes.md"), "w", encoding="utf-8").write(notes + "\n")
print(versions["mod"])
PY
)"

(cd "$loadstone" && cargo build -q --release -p loadstone-cli)
cli="$loadstone/target/release/loadstone"
"$cli" package --manifest "$work/civ-v-access.json" --scope "$repo/loadstone-packages" \
    --version "v$version" --notes-file "$work/notes.md" --out "$release/loadstone-release.json"
"$cli" validate --scope "$repo/loadstone-packages" "$release/loadstone-release.json"

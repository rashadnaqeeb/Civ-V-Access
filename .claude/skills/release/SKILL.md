---
name: release
description: Cut a new GitHub Release of Civ V Access. Use when the user says "/release X.Y.Z" or asks to ship/publish a new version. Bumps versions.json (mod plus per-component), updates CHANGELOG.md, rebuilds any changed components, packages the release zips, smoke-tests the local install, commits, tags, pushes, and creates the GitHub Release with all assets attached.
---

# Cut a Civ V Access release

## Goal

Take the maintainer's chosen mod version `X.Y.Z` and produce a published GitHub Release at tag `vX.Y.Z` with the seven assets that the player-facing installer expects: `core-blind-*.zip`, `core-sighted-*.zip`, `engine-*.zip`, `runtime-*.zip`, `cinematics-*.zip`, `SHA256SUMS`, and `CivVAccessInstaller.exe`.

This skill is the executable form of `RELEASING.md`. It does the per-step work end-to-end. The diff vs. the prev tag is enough to decide bump levels and draft the changelog body, so the only human gate is the final push (a remote action). Everything else runs.

## Inputs

`$ARGUMENTS` is the new mod version, e.g. `1.0.1` or `1.1.0`. If absent or not semver-shaped, ask the user for it and stop. Do not invent a version.

## Read first

- `RELEASING.md` at repo root - the canonical step list. This skill mirrors it; if it disagrees with this file, RELEASING.md wins, update this skill afterwards.
- `CLAUDE.md` (auto-loaded). Note especially: PowerShell is allowed (just run it); deploy is part of the task; commits in this repo do NOT carry the Claude Co-Authored-By trailer.
- The most recent tag's release notes via `gh release view <tag>` for tone.

## Workflow

### Step 1: pre-flight

Run these in parallel:

- `git status --porcelain` - working tree should be clean. If dirty, print the status and ask the user whether to abort or continue (the skill commits its own version bump + rebuilds; pre-existing uncommitted work would land in the same commit, which is usually wrong).
- `git tag --list "v*" --sort=-v:refname | head -1` - the previous tag. If empty, this is the first release; treat the prev-tag as empty (initial commit).
- `Get-Content versions.json | ConvertFrom-Json` - the current mod + component versions.

Validate the input version:
- Must match `^\d+\.\d+\.\d+$`.
- Must be strictly greater than the current `mod` field (semver compare, not lexical).

If either check fails, print why and stop.

### Step 2: per-component diffs

For each of the four components, run `git diff --name-only <prev-tag> -- <paths>` and capture whether the diff is empty:

- `core`: `src/dlc sounds`
- `engine`: `src/engine dist/engine`
- `runtime`: `src/proxy dist/proxy third_party/tolk`
- `cinematics`: `"audio described intros"`

Components with empty diffs do NOT bump - they ship under their existing version (the installer's per-asset digest skip handles dedup).

For components with non-empty diffs, decide the bump level from the diff itself. The bump rules (from RELEASING.md):

- **Patch**: fixes that don't change the install-manifest schema, asset naming, or any cross-component contract.
- **Minor**: new features, new engine bindings, new strings or sounds. Anything user-visible that isn't a fix.
- **Major**: install-manifest schema break or asset-naming break. Reserve for "tell players to redownload the installer" events. Never auto-pick major - if the diff genuinely looks like a schema break, stop and ask.

Read the file list and skim `git diff --stat <prev-tag> -- <paths>`. New files under `src/dlc/UI/`, new `TXT_KEY_CIVVACCESS_*` keys, new `CIVVACCESS:` engine bindings, new `.wav` files, or new modules under `src/dlc/UI/Shared/` are minor signals. Pure edits to existing files - typo fixes, string rewording, behavior tweaks, refactors - are patch. Decide and proceed; report the decisions in the final summary so the user can interject if they disagree.

### Step 3: rebuild any changed component artifacts

For each component whose source tree changed since the prev tag, the corresponding `dist/` artifact must be rebuilt before packaging:

- `src/proxy/` changed → `./build-proxy.ps1` (writes `dist/proxy/lua51_Win32.dll`).
- `src/engine/` changed → `./build-engine.ps1` (writes `dist/engine/CvGameCore_Expansion2.dll`, ~1-2 minutes).
- `installer/` changed → `./build-installer.ps1` (writes `dist/installer/CivVAccessInstaller.exe`).

Run these now if needed. Run them sequentially - they each write under `dist/` and the package step in step 6 reads from there. The cinematics and core components don't have a build step; they ship straight from source.

If the diff shows the corresponding `dist/` file is already updated in the working tree (which the pre-flight should have caught - working tree must be clean), trust it and skip the build.

If a build script fails, stop and surface the error. Do not patch around it.

### Step 4: edit versions.json

Update the mod field to the new version. Update each component field per step 2 decisions. Leave unchanged components alone. Preserve formatting (the file uses spaces around colons in the inner block - mirror what's there).

This is the only place the mod's "internal" version is set. `deploy.ps1` and `package-release.ps1` both read `versions.json` and generate `UI/InGame/CivVAccess_Version.lua` into the deployed / staged DLC payload from it; the in-game boot announcement (`TXT_KEY_CIVVACCESS_BOOT_INGAME`) reads `civvaccess_shared.version` set by that file. So bumping `versions.json` here is what makes the boot speech say the new version - no separate manual edit needed in `src/dlc/`. The smoke test below (step 7) confirms the deployed Version.lua reflects the new mod version.

### Step 5: update CHANGELOG.md

If `## [Unreleased]` already has body content, the user wrote it - keep it verbatim. Otherwise, draft a body from `git log --oneline <prev-tag>..HEAD` plus the per-component diff summary. Mirror RELEASING.md's tone: terse, user-visible only, no internal refactors / test changes / build-script tweaks. The body is what the installer shows the player on update, so it reads to a non-developer.

Then rewrite the file: replace the line `## [Unreleased]` with `## [X.Y.Z] - YYYY-MM-DD` (today's date) followed by the body, and prepend a fresh empty `## [Unreleased]` section above it.

The exact `## [X.Y.Z] - YYYY-MM-DD` header format is byte-stable - the installer parses for it. ASCII hyphens, today's date in `YYYY-MM-DD`. Get today's date from the session context (`Today's date is ...` in the system prompt) or `Get-Date -Format yyyy-MM-dd`.

### Step 6: package

Run `./package-release.ps1`. It reads `versions.json`, stages each component, zips them under `dist/release/`, and writes `SHA256SUMS`. It fails up front if any expected build artifact is missing - which means step 3 was incomplete and you need to run the missing builder.

After it succeeds, verify the five expected zips exist with the expected names:

- `dist/release/core-blind-<core-version>.zip`
- `dist/release/core-sighted-<core-version>.zip`
- `dist/release/engine-<engine-version>.zip`
- `dist/release/runtime-<runtime-version>.zip`
- `dist/release/cinematics-<cinematics-version>.zip`
- `dist/release/SHA256SUMS`

### Step 7: smoke test

Wipe the local install, then redeploy from the just-built `dist/` and `src/`:

```
./deploy.ps1 -Uninstall
./deploy.ps1
```

The deploy script auto-detects the game dir via Steam registry / library folders and prints it as `Game dir: <path>` in stdout. Capture that line; don't hardcode the path. Then read the install manifest at `<Game>\Assets\DLC\DLC_CivVAccess\CivVAccess.install.json` and the generated boot-version file at `<Game>\Assets\DLC\DLC_CivVAccess\UI\InGame\CivVAccess_Version.lua`. Verify:

- `mod_version` in the manifest matches the new mod version.
- `components.core.version` matches the core version in versions.json (same for engine, runtime, cinematics).
- `profile` is `blind`.
- `civvaccess_shared.version` in `CivVAccess_Version.lua` matches the new mod version. This is what the in-game boot announcement speaks; if it disagrees with `versions.json`, the player will hear a stale version even though the manifest says otherwise.

If any field doesn't match, stop and investigate - the deploy script reads from versions.json, so a mismatch means the file edit didn't land or the deploy didn't run.

This is the same `dist/` and `src/` content the package script just zipped, so a clean local deploy gives high confidence in what the installer will deliver. Don't try to launch the game; the manifest verification is enough.

### Step 8: commit

Stage and commit. With no rebuilds in step 3 (the common case for a core-only release), the commit is just `versions.json` + `CHANGELOG.md`. With rebuilds, also stage whichever `dist/` artifacts step 3 produced — `git status` lists them under modified, add only the ones that actually changed:

- `versions.json` (always)
- `CHANGELOG.md` (always)
- `dist/proxy/lua51_Win32.dll` (only if `build-proxy.ps1` ran)
- `dist/engine/CvGameCore_Expansion2.dll` (only if `build-engine.ps1` ran)
- `dist/installer/CivVAccessInstaller.exe` (only if `build-installer.ps1` ran)

`dist/release/*.zip` and `SHA256SUMS` are NOT committed - they're release artifacts, not source. They live in `dist/release/` only long enough for `gh release create` to upload them.

Commit message: `Release vX.Y.Z`. Per CLAUDE.md memory, do **not** include the Claude Co-Authored-By trailer; this repo's hooks reject it.

```
git add versions.json CHANGELOG.md <any dist artifacts>
git commit -m "Release vX.Y.Z"
```

### Step 9: tag

```
git tag vX.Y.Z
```

Tag matches the `mod` field exactly, with a leading `v`. No annotation needed (RELEASING.md uses lightweight tags).

### Step 10: push (user confirms)

Pushing is a remote action. Show the user `git log --oneline -1` (the new release commit) and ask them to confirm the push. On confirmation:

```
git push origin main
git push origin vX.Y.Z
```

If push fails (rejected because main moved, etc.), stop and surface the error. Do NOT force-push.

### Step 11: create the GitHub Release

The Bash tool runs `/usr/bin/bash`, so this must be a single-line bash invocation (or use `\` line continuations). **Do not use PowerShell-style backticks for line continuation** - bash interprets backticks as command substitution and the call silently fails to attach assets, leaving an empty release published. If this happens, recover with `gh release edit vX.Y.Z --title "vX.Y.Z" --notes "..."` plus `gh release upload vX.Y.Z <files...>`.

Run it as one line:

```
gh release create vX.Y.Z dist/release/core-blind-*.zip dist/release/core-sighted-*.zip dist/release/engine-*.zip dist/release/runtime-*.zip dist/release/cinematics-*.zip dist/release/SHA256SUMS dist/installer/CivVAccessInstaller.exe --title "vX.Y.Z" --notes "See [CHANGELOG.md](https://github.com/rashadnaqeeb/Civ-V-Access/blob/main/CHANGELOG.md) for details."
```

The body intentionally points at the changelog rather than duplicating it. The installer parses `CHANGELOG.md` for the slice between the player's old and new versions; the GitHub Release body is just a courtesy for humans browsing the Releases page.

After it returns, run `gh release view vX.Y.Z --json name,tagName,assets --jq '{name, tagName, assets: [.assets[].name]}'` and verify all 7 assets are listed.

### Step 12: report and hand off the round-trip check

Tell the user:

- The new mod version, plus per-component versions (which bumped, which stayed).
- The CHANGELOG entry that was committed.
- That the smoke test passed (manifest read back the new versions).
- That the release is published with all 7 assets.
- **Action item for the user**: download `CivVAccessInstaller.exe` from the new release page and run it on a clean machine (or after `./deploy.ps1 -Uninstall` locally). Confirm it detects the game install, asks the profile question on first run, downloads each component, verifies digests, and lands a working install. For an upgrade test, point an existing install at the new release; confirm the digest skip excludes unchanged components and the changelog slice shows what changed.

The installer round-trip can't be automated from this skill - it requires interactive WinForms. The user does it manually and reports back if anything's off.

Don't open a PR. The release commit goes straight on main; tags + GitHub Release are the deliverable.

## Constraints

- Component versions only bump when their source diff vs. the prev tag is non-empty. Bumping a component whose digest is identical to last release just makes the changelog noisier without saving anything.
- Mod version always bumps - it's the release tag and the changelog key.
- Never rotate the engine DLL GUID. It's the multiplayer compatibility key. The engine version in versions.json is independent of the GUID.
- Never rename existing release assets. Don't delete a published release. Players who installed an older version may re-resolve their digests against historical releases as part of a re-verify path.
- Never ship a release whose `versions.json` doesn't match what's actually built. The deploy script and packager both stamp those numbers into install manifests and asset filenames; lying about them strands the installer.
- Major mod bumps are reserved for install-manifest schema breaks. The installer cannot self-update, so a major mod bump is a "tell players to redownload the installer" event. Don't auto-pick major; if the diff looks like a schema break, stop and ask.
- Commits in this repo do NOT carry a Claude Co-Authored-By trailer.
- Pushing and `gh release create` are remote actions. Confirm before pushing. After push, the release create is the natural follow-on, no second confirm needed.

## What NOT to do

- Don't skip step 3 (rebuilds) if a component's source changed. The packager will fail anyway, but the failure mode is downstream and confusing; running the right builder up front is the cheap path.
- Don't skip the smoke test (step 7). It's the last barrier between a typo in versions.json and a stranded installer.
- Don't include `dist/release/` zips or `SHA256SUMS` in the commit. Those are release artifacts, not source; only the `gh release create` upload needs them.
- Don't run `./test.ps1`. It's a Lua harness; it can't see the version bump or the build artifacts. The deploy + manifest read in step 7 is the relevant smoke test.
- Don't force-push. Don't push tags before main. Don't skip the user's push confirmation.
- Don't try to verify the installer round-trip yourself. It's interactive; the user does it.
- Don't draft a long GitHub Release body. The body points at CHANGELOG.md and that's it - by design, so the changelog stays the single source of truth.

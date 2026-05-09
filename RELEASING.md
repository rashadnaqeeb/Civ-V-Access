# Releasing Civ V Access

Maintainer doc. The external installer drives off GitHub Releases; this doc describes how to cut one.

## What a release is

A GitHub Release tagged `vX.Y.Z` with these assets attached:

- `core-blind-X.Y.Z.zip` - mod payload that extracts into `Assets/DLC/DLC_CivVAccess/` for blind players. Versioned by `components.core`.
- `core-sighted-X.Y.Z.zip` - minimal manifest + empty UI dir scaffolding for the sighted-MP partner path. Also versioned by `components.core`.
- `engine-X.Y.Z.zip` - the forked `CvGameCore_Expansion2.dll`. Required on both paths because multiplayer compatibility hinges on a matching engine GUID between host and partner. Versioned by `components.engine`.
- `runtime-X.Y.Z.zip` - `lua51_Win32.dll` proxy plus the Tolk screen-reader bridges. Blind path only. Versioned by `components.runtime`.
- `cinematics-X.Y.Z.zip` - audio-described BNW opening movies. Blind path only. Largest asset (~110 MB). Versioned by `components.cinematics`.
- `SHA256SUMS` - one line per asset, format `<hex>  <filename>`. Informational; GitHub computes its own per-asset digest, exposed through the API as `sha256:<hex>`.
- `CivVAccessInstaller.exe` - the single-file player-facing installer. Same exe attached to every release so a fixed link to "latest" always pulls a working installer; rebuild it (via `./build-installer.ps1`) when `installer/` source has changed since the last release. Players download this once; it self-resolves all subsequent updates from the GitHub Release API.

Component asset versions can lag the mod's. If `components.engine` is `1.0.0` in mod `1.5.0`, the release attaches `engine-1.0.0.zip` (not `engine-1.5.0.zip`). The installer's digest skip means players don't redownload that asset. Asset filename format is enforced by the installer's `AssetMap.Parse` regex - don't deviate.

The release body should point at `CHANGELOG.md` rather than duplicate the entry. The installer parses `CHANGELOG.md` for the slice between the player's old and new versions, so the per-release body is just a courtesy for humans browsing the Releases page.

## Versioning

Versions live in `versions.json` at repo root. Five fields, all semver:

```
{
  "mod":        "X.Y.Z",
  "components": {
    "core":       "X.Y.Z",
    "engine":     "X.Y.Z",
    "runtime":    "X.Y.Z",
    "cinematics": "X.Y.Z"
  }
}
```

`mod` is the release tag and the changelog key. It bumps on every release.

Each component version is independent and bumps only when that component's source tree changed since the last tag. The point: if engine didn't change between mod 1.4.0 and mod 1.5.0, the 1.5.0 release ships `engine-1.0.0.zip` (or whatever the engine's last-changed version is). Same bytes, same digest - the installer's per-asset digest skip means players don't redownload it. core covers both `core-blind` and `core-sighted` since both are zipped from `src/dlc/`; the digest skip handles the case where only the blind payload changed.

Bump rules apply to every version field individually:

- **Patch** (`1.0.0` to `1.0.1`): fixes that don't change the install-manifest schema, asset naming, or any cross-component contract. The common case.
- **Minor** (`1.0.0` to `1.1.0`): new features, new engine bindings, new strings or sounds. Anything user-visible that isn't a fix.
- **Major** (`1.0.0` to `2.0.0`): install-manifest schema break or asset-naming break - things the installer can't transparently upgrade through. Reserve major bumps; the installer cannot self-update, so a major mod bump is a "tell players to redownload the installer" event. Component-level major bumps don't have the same stakes - they're informational since the digest skip is what determines fetch-vs-skip.

What touches each component:

- `core`: `src/dlc/`, `sounds/`. Bumps most often.
- `engine`: `src/engine/`, the rebuilt `dist/engine/CvGameCore_Expansion2.dll`. Rare. The engine DLL GUID never changes across releases - it's the multiplayer compatibility key; rotating it splits MP across mod versions. See `CLAUDE.md`.
- `runtime`: `src/proxy/`, `dist/proxy/lua51_Win32.dll`, `third_party/tolk/dist/x86/`. Almost never.
- `cinematics`: `audio described intros/`. Almost never; ~110 MB so getting this right matters most.

Quick check before editing `versions.json`: `git diff <last-tag> -- src/engine/` (and the same for each component's source tree) tells you whether that component's version needs to bump. If the diff is empty, leave that component's version alone.

## Steps

1. **Bump versions.** Edit `versions.json` at repo root. Always bump `mod`. For each component, run `git diff <last-tag> -- <component-source-tree>` and bump only if the diff is non-empty:
   - `core`: `git diff vX.Y.Z -- src/dlc sounds`
   - `engine`: `git diff vX.Y.Z -- src/engine dist/engine`
   - `runtime`: `git diff vX.Y.Z -- src/proxy dist/proxy third_party/tolk`
   - `cinematics`: `git diff vX.Y.Z -- "audio described intros"`

   If a component didn't change since the last tag, leave its version alone. The packager will name its zip with the unchanged version (e.g. `engine-1.0.0.zip` even when mod is at 1.5.0), and the installer's per-asset digest skip means players don't redownload it.

2. **Prepend a CHANGELOG entry.** Open `CHANGELOG.md`, replace `## [Unreleased]` with the new version header `## [X.Y.Z] - YYYY-MM-DD`, then add a fresh `## [Unreleased]` section above it. List user-visible changes; the installer shows this exact text to the player on update. The version-header format must stay byte-stable because the installer parses it.

3. **Build any changed components.** Run `./build-proxy.ps1` if `src/proxy/` changed since the last release, `./build-engine.ps1` if `src/engine/` changed, and `./build-installer.ps1` if `installer/` changed. All three write into `dist/` and the outputs are committed (proxy + engine; installer is gitignored and rebuilt fresh into `dist/installer/` per release), so unchanged components don't need a rebuild.

4. **Package.** Run `./package-release.ps1`. Produces `dist/release/*.zip` + `SHA256SUMS`. Fails up front if any expected build artifact is missing. Each zip is named with its component's own version pulled from `versions.json`, so unchanged components ship under their previous version number.

5. **Smoke test.** Wipe the local install (`./deploy.ps1 -Uninstall`), then reinstall (`./deploy.ps1`). Confirm the install manifest at `Assets/DLC/DLC_CivVAccess/CivVAccess.install.json` shows the new mod version and the right per-component versions, and confirm the game boots and speech works. The package script's zips are produced from the same `dist/` and `src/` content the deploy script reads, so a clean local deploy gives high confidence in what the installer will deliver.

6. **Commit and tag.** Commit the `versions.json` + CHANGELOG bump. Tag the commit `vX.Y.Z` (matching the `mod` field). Push main and the tag.

   ```
   git add versions.json CHANGELOG.md
   git commit -m "Release vX.Y.Z"
   git tag vX.Y.Z
   git push origin main
   git push origin vX.Y.Z
   ```

7. **Create the GitHub Release.** Drive it from the gh CLI, attaching all five component zips plus `SHA256SUMS` plus the installer exe. The body points at the changelog rather than duplicating it.

   ```
   gh release create vX.Y.Z \
     dist/release/core-blind-*.zip \
     dist/release/core-sighted-*.zip \
     dist/release/engine-*.zip \
     dist/release/runtime-*.zip \
     dist/release/cinematics-*.zip \
     dist/release/SHA256SUMS \
     dist/installer/CivVAccessInstaller.exe \
     --title "vX.Y.Z" \
     --notes "See [CHANGELOG.md](https://github.com/rashadnaqeeb/Civ-V-Access/blob/main/CHANGELOG.md) for details."
   ```

   The installer hits `GET /repos/rashadnaqeeb/Civ-V-Access/releases/latest` to discover the newest release, parses each asset's filename to map it to a component, and downloads only the components whose `sha256:` digest differs from what's recorded in the local install manifest.

8. **Verify the installer round-trip.** On a clean machine (or after `./deploy.ps1 -Uninstall` locally), download `CivVAccessInstaller.exe` from the new release page and run it. Confirm: it detects the game install, asks the profile question on first run, downloads each component, verifies digests, and lands a working install. For an upgrade test, point an existing install at the new release; confirm the digest skip excludes unchanged components and the changelog slice shows what changed.

## What not to do

- Don't rename existing release assets. Players who installed an older version may re-resolve their digests against historical releases as part of a re-verify path.
- Don't delete a published release. Same reason.
- Don't ship a release whose `versions.json` doesn't match what's actually built. The deploy script and packager both stamp those numbers into install manifests and asset filenames; lying about them strands the installer.
- Don't ship a release that breaks the install-manifest schema without a `mod` major bump. The installer keys its parsing off the schema.
- Don't bump a component's version without a corresponding source change. The point of the digest skip is that unchanged bytes never redownload; bumping a version on a component whose digest is identical to last release just makes the changelog noisier without saving anything.

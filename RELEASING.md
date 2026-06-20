# Releasing Civ V Access

Maintainer doc. The external installer drives off GitHub Releases; this doc describes how to cut one.

## What a release is

A GitHub Release tagged `vX.Y.Z` with fourteen assets attached: twelve component zips, `SHA256SUMS`, and `CivVAccessInstaller.exe`. The component zips split into the five vanilla components and the seven mod-state components (Vox Populi, Community-Patch-only, LekMod). See `docs/llm-docs/installer-states.md` for the authoritative component catalog and the state-to-component matrix; this list is the release-side summary.

Vanilla components (every install needs some subset):

- `core-blind-X.Y.Z.zip` - mod payload that extracts into `Assets/DLC/DLC_CivVAccess/` for blind players. Versioned by `components.core`.
- `core-sighted-X.Y.Z.zip` - minimal manifest + empty UI dir scaffolding for the sighted-MP partner path. Also versioned by `components.core`.
- `engine-X.Y.Z.zip` - the forked `CvGameCore_Expansion2.dll`. Required on both vanilla paths because multiplayer compatibility hinges on a matching engine GUID between host and partner. Versioned by `components.engine`.
- `runtime-X.Y.Z.zip` - `lua51_Win32.dll` proxy plus the Tolk screen-reader bridges. Blind path only. Versioned by `components.runtime`.
- `cinematics-X.Y.Z.zip` - audio-described BNW opening movies. Blind path only. Largest asset (~110 MB). Versioned by `components.cinematics`.

Mod-state components (the installer pulls the subset its chosen state needs):

- `vp-overlay-X.Y.Z.zip` / `cp-overlay-X.Y.Z.zip` / `lekmod-overlay-X.Y.Z.zip` - the per-engine vendor-UI delta over `core-blind`, with the matching EngineData seam and the pre-baked InGame.lua addin block. Versioned by `components.vp_overlay` / `cp_overlay` / `lekmod_overlay`.
- `vp-modpack-X.Y.Z.zip` / `cp-modpack-X.Y.Z.zip` - the baked `ZCivVAccess*` packages, each embedding the CP-DLL engine fork. Versioned by `components.vp_modpack` / `cp_modpack`. Large.
- `vp-runtime-X.Y.Z.zip` - the Vox Populi substrate (VPUI DLC, VP `Expansion2.Civ5Pkg`, minor-civ sounds, tips). Two-rooted (game/ and docs/). Versioned by `components.vp_runtime`.
- `lekmod-dlc-X.Y.Z.zip` - LekMod's prebaked DLC, pre-resolved (UI flattened, our LekMod fork swapped in), plus LekMod's Lekmap map scripts. Two-rooted (`dlc/` to `Assets/DLC/LEKMOD`, `maps/` to `Assets/Maps/Lekmap`). Versioned by `components.lekmod_dlc`. Large.

The fork DLLs are not standalone components - they ride inside their hosts (both modpacks embed the CP-DLL fork; the LekMod DLC carries the LekMod fork pre-swapped). `components.engine_vp` and `components.engine_lekmod` track those forks only so the packager's fork-staleness guard can warn when a fork rebuilt without bumping its embedding component (see Versioning below); they do not map to a release asset.

The two non-zip assets:

- `SHA256SUMS` - one line per component zip, format `<hex>  <filename>`. Informational; GitHub computes its own per-asset digest, exposed through the API as `sha256:<hex>`.
- `CivVAccessInstaller.exe` - the single-file player-facing installer. Same exe attached to every release so a fixed link to "latest" always pulls a working installer; rebuild it (via `./build-installer.ps1`) when `installer/` source has changed since the last release. Players download this once; it self-resolves all subsequent updates from the GitHub Release API.

Component asset versions can lag the mod's. If `components.engine` is `1.0.0` in mod `1.5.0`, the release attaches `engine-1.0.0.zip` (not `engine-1.5.0.zip`). For the digest skip to actually fire, the new release's `engine-1.0.0.zip` must be byte-identical to the one shipped in the previous release - GitHub computes a fresh sha256 per asset on upload, and even an mtime change inside the zip yields a different digest. `package-release.ps1` guarantees this by downloading the previous release's same-named asset and re-uploading it verbatim, instead of re-zipping from local source. Authoritative input is `versions.json`: if a component's version field hasn't moved since the previous tag, the script fetches the previous release's bytes; if it has moved, the script rebuilds from source. Asset filename format is enforced by the installer's `AssetMap.Parse` regex - don't deviate.

The release body should point at `CHANGELOG.md` rather than duplicate the entry. The installer parses `CHANGELOG.md` for the slice between the player's old and new versions, so the per-release body is just a courtesy for humans browsing the Releases page.

## Versioning

Versions live in `versions.json` at repo root. All semver:

```
{
  "mod":              "X.Y.Z",
  "supported_vp":     "Release-N.N.N",
  "supported_lekmod": "<upstream commit sha>",
  "components": {
    "core":           "X.Y.Z",
    "engine":         "X.Y.Z",
    "engine_vp":      "X.Y.Z",
    "engine_lekmod":  "X.Y.Z",
    "runtime":        "X.Y.Z",
    "cinematics":     "X.Y.Z",
    "vp_overlay":     "X.Y.Z",
    "cp_overlay":     "X.Y.Z",
    "lekmod_overlay": "X.Y.Z",
    "vp_modpack":     "X.Y.Z",
    "cp_modpack":     "X.Y.Z",
    "vp_runtime":     "X.Y.Z",
    "lekmod_dlc":     "X.Y.Z"
  }
}
```

`mod` is the release tag and the changelog key. It bumps on every release. `supported_vp` and `supported_lekmod` are the upstream pins (not release-asset versions); they move on a re-pin via `resync-vp.ps1` / `resync-lekmod.ps1`, not as part of cutting a release.

Each component version is independent and bumps only when that component's source tree changed since the last tag. The point: if engine didn't change between mod 1.4.0 and mod 1.5.0, the 1.5.0 release ships `engine-1.0.0.zip` (or whatever the engine's last-changed version is). The packager fetches the bytes of that asset from the previous GitHub release and re-uploads them verbatim, so the API digest stays identical and the installer's per-asset digest skip fires. `core` covers both `core-blind` and `core-sighted` since both are zipped from `src/dlc/`; the digest skip handles the case where only the blind payload changed.

`engine_vp` and `engine_lekmod` are not release assets - the forks are embedded in their hosts. They exist so the packager can detect a fork rebuilt without bumping the component that embeds it: `engine_vp` couples to `vp_modpack` and `cp_modpack` (both embed the CP-DLL fork), `engine_lekmod` couples to `lekmod_dlc`. If a fork version moved but its embedding component did not, `package-release.ps1` emits a loud warning - heed it and bump the embedding component, or the release reuses the prior zip with a stale fork inside (a silent MP desync / wrong-numbers ship). The fork version itself never appears in a filename.

Bump rules apply to every version field individually:

- **Patch** (`1.0.0` to `1.0.1`): fixes that don't change the install-manifest schema, asset naming, or any cross-component contract. The common case.
- **Minor** (`1.0.0` to `1.1.0`): new features, new engine bindings, new strings or sounds. Anything user-visible that isn't a fix.
- **Major** (`1.0.0` to `2.0.0`): install-manifest schema break or asset-naming break - things the installer can't transparently upgrade through. Reserve major bumps; the installer cannot self-update, so a major mod bump is a "tell players to redownload the installer" event. Component-level major bumps don't have the same stakes - they're informational since the digest skip is what determines fetch-vs-skip.

What touches each component:

- `core`: `src/dlc/`, `sounds/`. Bumps most often.
- `engine`: `src/engine/`, the rebuilt `dist/engine/CvGameCore_Expansion2.dll`. Rare. The engine DLL GUID never changes across releases - it's the multiplayer compatibility key; rotating it splits MP across mod versions. See `CLAUDE.md`.
- `runtime`: `src/proxy/`, `dist/proxy/lua51_Win32.dll`, `third_party/tolk/dist/x86/`. Almost never.
- `cinematics`: `audio described intros/`. Almost never; ~110 MB so getting this right matters most.
- `vp_overlay` / `cp_overlay` / `lekmod_overlay`: the per-engine vendor delta. Moves when `src/dlc/` changes a vendored file, when the seam (`src/vp/` / `src/lekmod/CivVAccess_EngineData.lua`) changes, or on a re-pin that regenerates `tools/vendoring/`. Note that a `core` change can also shift an overlay (the overlay is the delta against core), so bump the overlays whenever `core` bumps.
- `vp_modpack` / `cp_modpack`: the baked packages. Move on a re-pin (new merged DB) or a CP-DLL fork rebuild (`engine_vp`). Large.
- `vp_runtime`: the VP substrate. Moves on a VP re-pin that changes the VPUI / substrate assets.
- `lekmod_dlc`: the prebaked LekMod DLC plus the bundled Lekmap map scripts. Moves on a LekMod re-pin or a LekMod fork rebuild (`engine_lekmod`), and on any change to how the lekmod-dlc zip is assembled (e.g. the Lekmap maps were added to it). Large.
- `engine_vp` / `engine_lekmod`: the embedded forks. Move on a fork rebuild; not release assets, but bumping one obliges bumping the component(s) that embed it (see the coupling note above).

Quick check before editing `versions.json`: `git diff <last-tag> -- src/engine/` (and the same for each component's source tree) tells you whether that component's version needs to bump. If the diff is empty, leave that component's version alone. The mod-state components also depend on non-committed build trees and upstream pins, so on a re-pin let the `resync-*` scripts set those versions rather than diffing source by hand; a plain mod release that didn't re-pin leaves every mod-state version where it is and the packager re-fetches their prior bytes.

## Steps

1. **Bump versions.** Edit `versions.json` at repo root. Always bump `mod`. For each vanilla component, run `git diff <last-tag> -- <component-source-tree>` and bump only if the diff is non-empty:
   - `core`: `git diff vX.Y.Z -- src/dlc sounds`
   - `engine`: `git diff vX.Y.Z -- src/engine dist/engine`
   - `runtime`: `git diff vX.Y.Z -- src/proxy dist/proxy third_party/tolk`
   - `cinematics`: `git diff vX.Y.Z -- "audio described intros"`

   For the mod-state components, a plain release (no re-pin) leaves their versions alone unless `core` moved or a fork was rebuilt:
   - If `core` bumped, bump `vp_overlay`, `cp_overlay`, and `lekmod_overlay` too - each overlay is the delta against `core`, so a core change shifts them. (`git diff vX.Y.Z -- src/dlc src/vp src/lekmod tools/vendoring` is the broad check.)
   - If `engine_vp` moved since the last tag, bump `vp_modpack` and `cp_modpack` (both embed that fork). If `engine_lekmod` moved, bump `lekmod_dlc`. The packager warns on exactly this coupling if you forget; don't rely on the warning, set it here.
   - `vp_modpack` / `cp_modpack` / `vp_runtime` / `lekmod_dlc` otherwise move only on a re-pin, where `resync-vp.ps1` / `resync-lekmod.ps1` set them. Don't hand-bump them for a plain release.

   If a component didn't change since the last tag, leave its version alone. The packager will see the unchanged version field and pull that component's zip byte-for-byte from the previous GitHub release rather than rebuild it - the API digest then stays stable and the installer's per-asset digest skip fires for that component. (Exception: the very first release that introduces a component has no prior asset to fetch, so that component builds from source regardless - see step 3.)

2. **Prepend a CHANGELOG entry.** Open `CHANGELOG.md`, replace `## [Unreleased]` with the new version header `## [X.Y.Z] - YYYY-MM-DD`, then add a fresh `## [Unreleased]` section above it. List user-visible changes; the installer shows this exact text to the player on update. The version-header format must stay byte-stable because the installer parses it.

3. **Build any changed components.** For the vanilla forks: `./build-proxy.ps1` if `src/proxy/` changed, `./build-engine.ps1` if `src/engine/` changed, `./build-installer.ps1` if `installer/` changed. These write into `dist/` and the outputs are committed - including `dist/installer/CivVAccessInstaller.exe`, which gives players a stable raw URL (see `README.md`) that always serves the current installer. Commit any rebuilt artifact in the same commit as the version + CHANGELOG bump.

   The mod-state components stage from non-committed build trees, and any component being built from source this release (because its version bumped, or because no prior release shipped it) needs its inputs present first. `package-release.ps1` fails up front naming the missing input, but assembling them is the slow part, so do it now:
   - Overlays (`vp-overlay` / `cp-overlay` / `lekmod-overlay`) need `build/vendor/vp`, `build/vendor/cp`, `build/vendor/lekmod` from `py tools/vendoring/vendor.py generate --engine vp` (and `cp`, `lekmod`).
   - `vp-modpack` needs `build/modpack-out` from `./build-modpack.ps1`; `cp-modpack` needs `build/modpack-cp-out` from `./build-modpack-cp.ps1`. Both bakes require a prior manual merged-DB session (a VP one and a CP-only one) - see `docs/llm-docs/cp-vp-support.md`. These are not one-button steps; on a plain release where the modpacks didn't change, leave their versions unbumped so the packager re-fetches the prior zips and you skip the bake entirely.
   - `lekmod-dlc` needs the sibling LekMod clone and `dist/engine-lekmod/CvGameCore_Expansion2.dll` (`./build-engine-lekmod.ps1`).
   - `vp-runtime` needs `build/vp-runtime`, which the packager stages on demand from the sibling Community-Patch-DLL clone (pass `-ClonePath` if it isn't beside the repo).

   On the first release that introduces the mod-state components, all seven build from source (no prior asset to fetch), so every input above must be present. On later plain releases, leaving the mod-state versions unbumped lets the packager re-fetch prior bytes and none of these inputs are needed.

4. **Package.** Run `./package-release.ps1`. Produces twelve `dist/release/*.zip` + `SHA256SUMS`. Fails up front if any expected build artifact is missing. Each zip is named with its component's own version pulled from `versions.json`. Components whose version field is unchanged since the previous tag are downloaded from that previous GitHub release rather than rebuilt - the script reports `(reused from vX.Y.Z)` for those and `(built)` for the rest. Reuse requires `gh` to be authenticated; if it isn't, the fetch fails with a message pointing at `gh auth login`. Watch the output for the fork-staleness warning (`engine_vp changed ... but vp-modpack stayed ...`); if it fires, you under-bumped in step 1 - fix `versions.json` and re-run. To iterate on a single component without re-zipping the large ones, use `-Only <prefix>` (it does not rewrite `SHA256SUMS`, so finish with a full run).

5. **Smoke test.** Wipe the local install (`./deploy.ps1 -Uninstall`), then reinstall (`./deploy.ps1`). Confirm the install manifest at `Assets/DLC/DLC_CivVAccess/CivVAccess.install.json` shows the new mod version and the right per-component versions, and confirm the game boots and speech works. This exercises only the vanilla-blind path; the seven mod-state zips ship unverified by this step (the modpack states can't be auto-deployed - they need the manual merged-DB bakes). The package script's zips are produced from the same `dist/`, `src/`, and build trees the deploy scripts read, so a clean local deploy gives high confidence in the vanilla path; for the mod states, rely on the installer round-trip in step 8 and exercise at least one mod state there.

6. **Commit and tag.** Commit the `versions.json` + CHANGELOG bump, plus any `dist/` artifact step 3 rebuilt (`dist/proxy/lua51_Win32.dll`, `dist/engine/CvGameCore_Expansion2.dll`, `dist/engine-lekmod/CvGameCore_Expansion2.dll`, `dist/installer/CivVAccessInstaller.exe` - add only the ones that actually changed). The `dist/release/*.zip` and `SHA256SUMS` are release artifacts, not source; do not commit them. Tag the commit `vX.Y.Z` (matching the `mod` field). Push main and the tag.

   ```
   git add versions.json CHANGELOG.md  # plus any rebuilt dist artifacts
   git commit -m "Release vX.Y.Z"
   git tag vX.Y.Z
   git push origin main
   git push origin vX.Y.Z
   ```

7. **Create the GitHub Release.** Drive it from the gh CLI, attaching all twelve component zips plus `SHA256SUMS` plus the installer exe (fourteen assets). The body points at the changelog rather than duplicating it. Omitting any mod-state zip strands every player on that state - the installer can't fetch a component the release doesn't carry.

   ```
   gh release create vX.Y.Z \
     dist/release/core-blind-*.zip \
     dist/release/core-sighted-*.zip \
     dist/release/engine-*.zip \
     dist/release/runtime-*.zip \
     dist/release/cinematics-*.zip \
     dist/release/vp-overlay-*.zip \
     dist/release/cp-overlay-*.zip \
     dist/release/lekmod-overlay-*.zip \
     dist/release/vp-modpack-*.zip \
     dist/release/cp-modpack-*.zip \
     dist/release/vp-runtime-*.zip \
     dist/release/lekmod-dlc-*.zip \
     dist/release/SHA256SUMS \
     dist/installer/CivVAccessInstaller.exe \
     --title "vX.Y.Z" \
     --notes "See [CHANGELOG.md](https://github.com/rashadnaqeeb/Civ-V-Access/blob/main/CHANGELOG.md) for details."
   ```

   After it returns, confirm the asset count is fourteen (`gh release view vX.Y.Z --json assets --jq '.assets | length'`). The installer hits `GET /repos/rashadnaqeeb/Civ-V-Access/releases/latest` to discover the newest release, parses each asset's filename to map it to a component, and downloads only the components whose `sha256:` digest differs from what's recorded in the local install manifest.

8. **Verify the installer round-trip.** On a clean machine (or after `./deploy.ps1 -Uninstall` locally), download `CivVAccessInstaller.exe` from the new release page and run it. Confirm: it detects the game install, asks the profile question on first run, downloads each component, verifies digests, and lands a working install. Exercise at least one mod state (Vox Populi, Community Patch, or LekMod) here, since the step 5 smoke test only covers vanilla - this is the only check that the mod-state zips were uploaded and resolve. For an upgrade test, point an existing install at the new release; confirm the digest skip excludes unchanged components and the changelog slice shows what changed.

## What not to do

- Don't rename existing release assets. Players who installed an older version may re-resolve their digests against historical releases as part of a re-verify path.
- Don't delete a published release. Same reason.
- Don't ship a release whose `versions.json` doesn't match what's actually built. The deploy script and packager both stamp those numbers into install manifests and asset filenames; lying about them strands the installer.
- Don't ship a release that breaks the install-manifest schema without a `mod` major bump. The installer keys its parsing off the schema.
- Don't bump a component's version without a corresponding source change. The packager treats a bumped version as "rebuild from source," which produces a fresh digest and forces every player to redownload that component on update - even though the source bytes are identical.
- Don't drop any mod-state zip from the `gh release create` upload. The packager builds all twelve; uploading only the vanilla five leaves VP, CP, and LekMod players unable to fetch their components. Verify fourteen assets after publishing.
- Don't ignore the packager's fork-staleness warning. A fork rebuilt without bumping its embedding component (`vp_modpack` / `cp_modpack` for `engine_vp`, `lekmod_dlc` for `engine_lekmod`) ships the prior zip with a stale fork inside - a silent MP desync.

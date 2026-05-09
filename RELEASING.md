# Releasing Civ V Access

Maintainer doc. The external installer drives off GitHub Releases; this doc describes how to cut one.

## What a release is

A GitHub Release tagged `vX.Y.Z` with these assets attached:

- `core-blind-X.Y.Z.zip` - mod payload that extracts into `Assets/DLC/DLC_CivVAccess/` for blind players.
- `core-sighted-X.Y.Z.zip` - minimal manifest + empty UI dir scaffolding for the sighted-MP partner path.
- `engine-X.Y.Z.zip` - the forked `CvGameCore_Expansion2.dll`. Required on both paths because multiplayer compatibility hinges on a matching engine GUID between host and partner.
- `runtime-X.Y.Z.zip` - `lua51_Win32.dll` proxy plus the Tolk screen-reader bridges. Blind path only.
- `cinematics-X.Y.Z.zip` - audio-described BNW opening movies. Blind path only. Largest asset (~110 MB).
- `SHA256SUMS` - one line per asset, format `<hex>  <filename>`. Informational; GitHub computes its own per-asset digest, exposed through the API as `sha256:<hex>`.

The release body should point at `CHANGELOG.md` rather than duplicate the entry. The installer parses `CHANGELOG.md` for the slice between the player's old and new versions, so the per-release body is just a courtesy for humans browsing the Releases page.

## Versioning

Semver. Bump rules:

- **Patch** (`1.0.0` to `1.0.1`): Lua / payload fixes that don't change the install manifest schema, the engine DLL, or the proxy. The most common kind of release.
- **Minor** (`1.0.0` to `1.1.0`): new features, new engine bindings, new mod-authored strings or sounds. Anything user-visible that isn't a fix.
- **Major** (`1.0.0` to `2.0.0`): install manifest schema break, GitHub asset naming convention break, or other change the installer can't transparently upgrade through. Reserve this; the installer cannot self-update, so a major bump is a "tell players to redownload the installer" event.

The engine DLL GUID never changes across releases. It's the multiplayer compatibility key; rotating it splits MP across mod versions. See the project rules in `CLAUDE.md`.

## Steps

1. **Bump VERSION.** Edit the `VERSION` file at repo root to the new `X.Y.Z`.

2. **Prepend a CHANGELOG entry.** Open `CHANGELOG.md`, replace `## [Unreleased]` with the new version header `## [X.Y.Z] - YYYY-MM-DD`, then add a fresh `## [Unreleased]` section above it. List user-visible changes; the installer shows this exact text to the player on update. The version-header format must stay byte-stable because the installer parses it.

3. **Build any changed components.** Run `./build-proxy.ps1` if `src/proxy/` changed since the last release, or `./build-engine.ps1` if `src/engine/` changed. Both write into `dist/` and the outputs are committed, so unchanged components don't need a rebuild.

4. **Package.** Run `./package-release.ps1`. Produces `dist/release/*.zip` + `SHA256SUMS`. Fails up front if any expected build artifact is missing.

5. **Smoke test.** Wipe the local install (`./deploy.ps1 -Uninstall`), then reinstall (`./deploy.ps1`). Confirm the install manifest at `Assets/DLC/DLC_CivVAccess/CivVAccess.install.json` shows the new version, and confirm the game boots and speech works. The package script's zips are produced from the same `dist/` and `src/` content the deploy script reads, so a clean local deploy gives high confidence in what the installer will deliver.

6. **Commit and tag.** Commit the VERSION + CHANGELOG bump. Tag the commit `vX.Y.Z`. Push both.

7. **Create the GitHub Release.** From the new tag. Upload all five `.zip` files plus `SHA256SUMS`. Set the body to a short pointer like `See [CHANGELOG.md](https://github.com/<owner>/<repo>/blob/main/CHANGELOG.md) for details.` Publish.

   The installer hits `GET /repos/<owner>/<repo>/releases/latest` to discover the newest release, parses each asset's filename to map it to a component, and downloads only the components whose `sha256:` digest differs from what's recorded in the local install manifest.

## What not to do

- Don't rename existing release assets. Players who installed an older version may re-resolve their digests against historical releases as part of a re-verify path.
- Don't delete a published release. Same reason.
- Don't ship a release with a higher VERSION than the source on the tagged commit. The installer trusts VERSION as ground truth for what's currently deployed and what the local deploy script writes into the install manifest.
- Don't ship a release that breaks the install-manifest schema without a major version bump. The installer keys its parsing off the schema.

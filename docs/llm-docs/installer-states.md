# Installer state and component spec

Build spec for the multi-state player installer. The installer fetches prebuilt
components from a GitHub release, keeps them in a persistent content-addressed
cache (LocalAppData, keyed by digest), and applies a target state by removing
the current state's footprint and extracting the target's components. Downloads
happen only on a cache miss, so each state's heavy payload is fetched once ever
and switch-back is offline. Uninstall is the only removal; it tears down the
active state and clears the cache.

The hard correctness surface is the transition: after any flip, nothing from the
old state may remain that makes the new session read stale or wrong data.

## Component catalog

Each component ships as a release asset named `<prefix>-<X.Y.Z>.zip`, versioned
independently in `versions.json` so digest-skip is granular (a vendor-only re-pin
must not re-pull a 600 MB package).

| Prefix | Content | Extracts to | Backup obligation |
| --- | --- | --- | --- |
| `core-blind` | DLC payload (`src/dlc`, vanilla EngineData seam) + sounds | `Assets/DLC/DLC_CivVAccess` (nuke + extract) | none |
| `core-sighted` | empty-UI DLC manifest (DLC-list presence only) | `Assets/DLC/DLC_CivVAccess` (nuke + extract) | none |
| `runtime` | proxy `lua51_Win32.dll` + Tolk DLLs | game root (+ rename stock `lua51_Win32.dll` to `lua51_original.dll`) | `lua51_original.dll` is the backup |
| `cinematics` | audio-described BNW intros | `Assets/DLC/Expansion2` | stock intros to `DLC_CivVAccess.backup/cinematics` |
| `engine` | vanilla fork `CvGameCore_Expansion2.dll` | `Assets/DLC/Expansion2` | stock DLL to `DLC_CivVAccess.backup/...vanilla.dll` |
| `vp-overlay` | VP vendor overlay UI + VP seam + pre-baked InGame.lua addin block | overlaid on top of `core-blind` under `DLC_CivVAccess/UI` | none |
| `cp-overlay` | CP vendor overlay + same seam + CP addin block | same | none |
| `vp-modpack` | baked `ZCivVAccessVP` package (CP-DLL fork embedded) | `Assets/DLC/ZCivVAccessVP` | none |
| `cp-modpack` | baked `ZCivVAccessCP` package (CP-DLL fork embedded) | `Assets/DLC/ZCivVAccessCP` | none |
| `vp-runtime` | VP substrate: VPUI DLC, VP `Expansion2.Civ5Pkg`, `MinorCivSounds_VoxPopuli.xml`, `VPUI_tips_*.xml` | `Assets/DLC/VPUI`; `Assets/DLC/Expansion2/Expansion2.Civ5Pkg`; `.../Sounds/XML/`; `Documents/.../Text/` | stock `Expansion2.Civ5Pkg` to `DLC_CivVAccess.backup/...stock` before overwrite |
| `lekmod-dlc` | LekMod prebaked DLC, UI resolved by stem, our LekMod fork pre-swapped in (LekMod GUID kept) | `Assets/DLC/LEKMOD` | none (shipped whole; removed on flip) |
| `lekmod-overlay` | LekMod vendor overlay + LekMod seam; sets our DLC priority to 350 | overlaid on `core-blind`; our DLC `Priority` raised | none |

Sighted-MP partners of a mod host install the host's heavy component itself
(`vp-modpack` / `cp-modpack` / `lekmod-dlc`) plus the empty-UI `core-sighted`,
which guarantees the DLC-list and engine-GUID match. There are no standalone
fork-DLL components in the installer; the mod-overlay sighted-MP PowerShell
scripts (which place a bare fork into a partner's existing VP/LekMod install)
are a separate, may-lag concern and are not part of the player installer.

Notes:
- The EngineData seam and the InGame.lua addin block are folded into the
  `*-overlay` components and pre-baked at release time. The deploy scripts
  generate the addin block live; the installer ships it static.
- The Expansion2 engine DLL (`engine`) is our vanilla fork in every blind and
  sighted state. The mod states do not overwrite it; they supply their engine
  via their own DLC (modpack package embeds it; LekMod DLC carries it). So the
  Expansion2 DLL is managed only by `engine`, never flipped between states.
- `lekmod-dlc` is shipped pre-resolved (UI flattened, fork swapped). The player
  never runs the clone-side ui_check or DLL swap. This moves that work to the
  maintainer bake.

## State to component matrix

Profile is asked once and persisted; state is the re-pickable axis.

| State | Components |
| --- | --- |
| vanilla-blind | `core-blind`, `runtime`, `engine`, `cinematics` |
| cp+vp-blind | `core-blind`, `runtime`, `cinematics`, `vp-overlay`, `vp-modpack`, `vp-runtime` |
| cp-only-blind | `core-blind`, `runtime`, `cinematics`, `cp-overlay`, `cp-modpack` |
| lekmod-blind | `core-blind`, `runtime`, `cinematics`, `lekmod-overlay`, `lekmod-dlc` |
| vanilla-sighted | `core-sighted`, `engine` |
| cp+vp-sighted | `core-sighted`, `vp-modpack`, `vp-runtime` (same as the host) |
| cp-only-sighted | `core-sighted`, `cp-modpack` (same package as the host) |
| lekmod-sighted | `core-sighted`, `lekmod-dlc` (same tree as the host) |

Every sighted mod state installs the host's gameplay content plus the empty-UI
`core-sighted`, so no accessibility code runs but the DLC list and engine GUID
match the host. cp+vp-sighted also installs `vp-runtime`: the partner needs the
full VP substrate to match the host. cp-only-sighted does not (CP-only never uses
the substrate).

## Removable artifact footprint

Transition is set difference over these artifacts: tear down every artifact the
current state placed that the target state does not, restoring any backed-up
stock file, then apply the target's components.

| Artifact | Placed by states | Teardown |
| --- | --- | --- |
| proxy (our `lua51_Win32.dll` + Tolk; `lua51_original` rename) | all blind | restore `lua51_original.dll`, remove Tolk + our lua51 |
| `DLC_CivVAccess` content | all (blind payload vs sighted empty-UI) | nuke + re-extract on any profile/state change |
| `ZCivVAccessVP` package | cp+vp-blind, cp+vp-sighted | remove dir |
| `ZCivVAccessCP` package | cp-only-blind, cp-only-sighted | remove dir |
| VP substrate (`vp-runtime`) | cp+vp-blind, cp+vp-sighted | remove VPUI; restore stock `Expansion2.Civ5Pkg` from backup; remove minor-civ sounds + tips |
| `LEKMOD` DLC | lekmod-blind, lekmod-sighted | remove `Assets/DLC/LEKMOD*` |

The Expansion2 `engine` DLL and `cinematics` are never torn down between states
(every state wants the same vanilla fork and the intros are harmless); their
stock originals are restored only on full uninstall.

## Transition algorithm

1. Read current `variant` + `profile` from `CivVAccess.install.json`.
2. Compute current footprint and target footprint from the matrices above.
3. For each artifact in (current minus target): tear down, restoring backups.
4. For each component in the target set: apply from cache, or download on a
   cache miss (verify digest), then extract. Order: engine and cinematics
   (backup before overwrite), then runtime (lua51 rename), then core (nuke +
   extract), then overlays, then packages/DLC, then substrate. Clear DLC cache.
5. Write the manifest with the new `variant`, `profile`, and per-component
   versions + digests.

Cleanup is idempotent: every teardown is a no-op when the artifact is absent, so
a partial or repeated flip is safe.

## Release asset zip contracts

The installer extracts each component to a fixed root, so the packaging side must
shape each zip accordingly (entries are paths relative to that root):

- `core-blind` / `core-sighted`: relative to `Assets/DLC/DLC_CivVAccess` (the
  installer nukes and recreates that dir, then extracts).
- `*-overlay`: also relative to `DLC_CivVAccess`, extracted on top of the core.
  The overlay carries the VP/CP/LekMod vendor UI files, the matching EngineData
  seam (`UI/InGame/CivVAccess_EngineData.lua`), and the pre-baked InGame.lua
  addin block. The deploy scripts generate that block live; the release zip ships
  it static.
- `engine` / `cinematics`: relative to `Assets/DLC/Expansion2`.
- `runtime`: relative to the game root (proxy `lua51_Win32.dll` + Tolk DLLs).
- `vp-modpack` / `cp-modpack`: relative to the package dir; the installer nukes
  and extracts into `Assets/DLC/ZCivVAccessVP` / `ZCivVAccessCP`. The fork DLL is
  embedded in the package.
- `lekmod-dlc`: relative to `Assets/DLC/LEKMOD`, shipped pre-resolved (UI
  flattened by stem, our LekMod fork already swapped in).
- `vp-runtime`: two-rooted. Entries under `game/` extract to the game root,
  entries under `docs/` extract to the Civ V Documents dir. So it contains
  `game/Assets/DLC/VPUI/...`, `game/Assets/DLC/Expansion2/Expansion2.Civ5Pkg`,
  `game/Assets/DLC/Expansion2/Sounds/XML/MinorCivSounds_VoxPopuli.xml`, and
  `docs/Text/VPUI_tips_en_us.xml`. The installer backs up the stock
  Expansion2.Civ5Pkg before this overwrites it.

## Packaging

`package-release.ps1` produces all twelve component zips. The five vanilla
components are unchanged; the seven mod-state ones are versioned by the
`vp_overlay` / `cp_overlay` / `lekmod_overlay` / `vp_modpack` / `cp_modpack` /
`vp_runtime` / `lekmod_dlc` fields in `versions.json` (bump on a re-pin or fork
rebuild, same as the engine fields). Each overlay is assembled by the shared
`tools/dlc-assembly.ps1` helper (`New-CivVAccessModdedDlc`, also used by
`deploy-modpack.ps1` and `deploy-lekmod.ps1` so the three never drift) and then
reduced to the delta against the vanilla core. The modpack and LekMod inputs are
the same non-committed build trees the tester bundles use (`build/modpack-out`,
`build/modpack-cp-out`, `build/vendor/*`, `build/vp-runtime`, and the LekMod
clone); the bake / vendor / bundle prerequisites are unchanged. `-Only <names>`
builds a subset for iteration.

## Source of truth and drift policy

Three independent implementations exist; their currency requirements differ:

- The four dev deploy scripts (`deploy.ps1`, `deploy-modpack.ps1` and its
  `-CommunityPatchOnly` form, `deploy-lekmod.ps1`) are the maintainer's daily
  driver for deploying the local working copy after a mod change. They must stay
  current and correct; they are not allowed to lag.
- The player installer (C#) is a parallel implementation that deploys from
  release assets instead of the local repo. It conforms to this document's
  transition matrix, enforced by per-cell tests in `installer-tests`.
- The mod-overlay sighted-MP PowerShell scripts may lag; they are not on the
  player path and not the maintainer's daily driver.

The dev scripts and the installer cannot share code across the PowerShell/C#
boundary, so this document is the shared spec both conform to. When a re-pin or a
mod change alters teardown, update both the dev scripts and this spec; the
installer's tests then catch its own drift against the spec.

## Resolved decisions

- `cp-only-sighted` is needed: `core-sighted` + `cp-modpack` (same package the
  CP host runs).
- A sighted-MP partner of a mod host installs the host's heavy component
  (`vp-modpack` / `cp-modpack` / `lekmod-dlc`) plus `core-sighted`. No standalone
  fork components in the installer.
- A cp+vp-sighted partner also needs `vp-runtime` (the full VP substrate) to
  match the host. cp-only-sighted does not.

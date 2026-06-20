using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Decision summary computed before any download starts. The action dialog
/// renders this; Execute consumes it.
/// </summary>
internal sealed class InstallPlan
{
    public required string GameDir { get; init; }
    public required InstallState TargetState { get; init; }
    public required InstallProfile TargetProfile { get; init; }
    public required GitHubReleases.Release Release { get; init; }
    public required InstallManifest? ExistingManifest { get; init; }

    /// <summary>The state/profile currently deployed (Vanilla/Blind defaults on a fresh machine).</summary>
    public required InstallState CurrentState { get; init; }
    public required InstallProfile CurrentProfile { get; init; }

    /// <summary>
    /// All components for the target (state, profile), in release-asset form.
    /// Empty when the install is already up to date.
    /// </summary>
    public required IReadOnlyList<GitHubReleases.Asset> TargetAssets { get; init; }

    /// <summary>Subset of TargetAssets not already in the local cache: the actual downloads.</summary>
    public required IReadOnlyList<GitHubReleases.Asset> AssetsToDownload { get; init; }

    public required bool ForceAll { get; init; }
    public required bool IsUpToDate { get; init; }

    public bool IsFreshInstall => ExistingManifest == null;
    public bool IsStateChange => CurrentState != TargetState || CurrentProfile != TargetProfile;

    public long TotalBytesToFetch => AssetsToDownload.Sum(a => a.Size);
}

/// <summary>
/// The orchestrator. Resolves a target (state, profile) into prebuilt release
/// components, fetching only what isn't cached, tearing down the current
/// state's footprint, then applying the target's components and recording the
/// manifest. Mirrors the dev deploy scripts at the file-operation level but
/// consumes release zips and a persistent cache instead of the local dist tree.
/// </summary>
internal sealed class Installer : IDisposable
{
    private readonly GitHubReleases _gh = new();
    private readonly ComponentCache _cache = new();

    public Task<GitHubReleases.Release> GetLatestReleaseAsync(CancellationToken ct) =>
        _gh.GetLatestAsync(ct);

    public Task<string> GetChangelogAsync(CancellationToken ct) =>
        _gh.GetChangelogAsync(ct);

    /// <summary>
    /// Compute the plan for moving to (targetState, targetProfile) from the
    /// current install. The install is up to date only when the existing
    /// manifest already names this exact state and profile and every target
    /// component's digest matches the release; otherwise the full target set is
    /// applied (downloading only what the cache lacks).
    /// </summary>
    public InstallPlan BuildPlan(
        string gameDir,
        InstallState targetState,
        InstallProfile targetProfile,
        GitHubReleases.Release release,
        InstallManifest? existing,
        bool forceAll)
    {
        var target = ComponentSet.For(targetState, targetProfile);
        var assetByKind = release.Assets
            .Where(a => a.Kind != null)
            .GroupBy(a => a.Kind!.Value)
            .ToDictionary(g => g.Key, g => g.First());

        var missing = target.Where(k => !assetByKind.ContainsKey(k)).ToList();
        if (missing.Count > 0)
        {
            var names = string.Join(", ", missing.Select(k => k.AssetPrefix()));
            throw new InvalidOperationException(Strings.Format("error.assetMissing", names));
        }

        var currentState = existing?.Variant ?? InstallState.Vanilla;
        var currentProfile = existing?.Profile ?? InstallProfile.Blind;

        bool sameTarget = existing != null
            && existing.Variant == targetState
            && existing.Profile == targetProfile;

        bool upToDate = sameTarget && !forceAll && target.All(kind =>
        {
            var localSha = existing!.GetSha256(kind);
            var assetSha = assetByKind[kind].DigestSha256;
            return localSha != null && assetSha != null &&
                   string.Equals(localSha, assetSha, StringComparison.OrdinalIgnoreCase);
        });

        var targetAssets = upToDate
            ? Array.Empty<GitHubReleases.Asset>()
            : target.Select(k => assetByKind[k]).ToArray();

        var toDownload = targetAssets.Where(a => !_cache.Has(a.DigestSha256)).ToArray();

        return new InstallPlan
        {
            GameDir = gameDir,
            TargetState = targetState,
            TargetProfile = targetProfile,
            Release = release,
            ExistingManifest = existing,
            CurrentState = currentState,
            CurrentProfile = currentProfile,
            TargetAssets = targetAssets,
            AssetsToDownload = toDownload,
            ForceAll = forceAll,
            IsUpToDate = upToDate,
        };
    }

    /// <summary>
    /// Fetch (download + verify, or hit the cache), then tear down the current
    /// footprint not wanted by the target, then apply the target components and
    /// write the manifest. No game file is mutated until every byte is present
    /// and verified, so a failed download cannot corrupt an existing install.
    /// </summary>
    public async Task ExecuteAsync(
        InstallPlan plan,
        IProgress<InstallProgress> progress,
        CancellationToken ct)
    {
        // 1. Ensure every target component is present in the cache.
        var stageMap = new Dictionary<ComponentKind, string>();
        int downloadIndex = 0;
        foreach (var asset in plan.TargetAssets)
        {
            ct.ThrowIfCancellationRequested();

            if (asset.DigestSha256 != null && _cache.Has(asset.DigestSha256))
            {
                stageMap[asset.Kind!.Value] = _cache.PathForDigest(asset.DigestSha256);
                Logger.Info($"Cache hit for {asset.Kind} ({asset.Name}).");
                continue;
            }

            // DownloadVerifyCacheAsync returns the cache path keyed by the
            // verified content hash, which is the only correct key when the
            // GitHub API supplied no digest (asset.DigestSha256 is null).
            stageMap[asset.Kind!.Value] =
                await DownloadVerifyCacheAsync(plan, asset, downloadIndex, progress, ct).ConfigureAwait(false);
            downloadIndex++;
        }

        // 2. Past this point we mutate the game install.
        var layout = new GameLayout(plan.GameDir);

        // A fresh install (no manifest) assumes the worst-case current footprint
        // so strays from a crashed or older install are cleaned. This is
        // deliberately aggressive: it will also remove an unrelated
        // hand-installed VP/LekMod, which is the correct outcome here because the
        // target state cannot share the game tree with a foreign one without
        // producing silent wrong numbers.
        var teardown = plan.IsFreshInstall
            ? TransitionPlanner.ArtifactsToTearDownFromUnknown(plan.TargetState, plan.TargetProfile)
            : TransitionPlanner.ArtifactsToTearDown(
                plan.CurrentState, plan.CurrentProfile, plan.TargetState, plan.TargetProfile);
        if (teardown != ModArtifact.None)
        {
            progress.Report(new InstallProgress { Stage = InstallStage.Preparing });
            ArtifactOps.TearDown(teardown, layout);
        }

        // A modpack / LekMod target runs its fork from the package or LEKMOD tree,
        // so the base Assets/DLC/Expansion2 DLL must be Firaxis-stock. A prior
        // vanilla install swapped our fork in there; the teardown above does not
        // cover it (ModArtifact has no engine entry), so restore it here. Without
        // this, two installs that reached the same state by different paths (clean
        // vs flipped-from-vanilla) would differ in a core always-on DLC. Keep the
        // backup for a later vanilla flip / full uninstall. No-op when absent.
        if (plan.TargetState != InstallState.Vanilla && File.Exists(layout.EngineBackup))
        {
            Logger.Info($"Restoring stock Expansion2 engine DLL (fork rides in the package): {layout.EngineBackup} -> {layout.EngineDll}");
            File.Copy(layout.EngineBackup, layout.EngineDll, overwrite: true);
        }

        // 3. Apply target components in dependency order.
        ApplyAll(plan, stageMap, layout, progress, ct);

        // 4. Manifest, then DLC cache flush.
        progress.Report(new InstallProgress { Stage = InstallStage.WritingManifest });
        WriteManifest(plan);

        progress.Report(new InstallProgress { Stage = InstallStage.ClearingCache });
        ArtifactOps.ClearDlcCache(layout);

        progress.Report(new InstallProgress { Stage = InstallStage.Done });
    }

    /// <summary>
    /// Download the asset, verify its hash, commit it to the cache, and return
    /// its cache path (keyed by the verified content hash). downloadIndex is the
    /// 0-based position among the assets actually being downloaded this run, for
    /// progress display.
    /// </summary>
    private async Task<string> DownloadVerifyCacheAsync(
        InstallPlan plan,
        GitHubReleases.Asset asset,
        int downloadIndex,
        IProgress<InstallProgress> progress,
        CancellationToken ct)
    {
        var temp = _cache.NewTempPath(asset.Name);
        var stepCount = plan.AssetsToDownload.Count;

        progress.Report(new InstallProgress
        {
            Stage = InstallStage.Downloading,
            Component = asset.Kind,
            StepIndex = downloadIndex,
            StepCount = stepCount,
            BytesTotal = asset.Size,
        });

        var byteProgress = new Progress<long>(b => progress.Report(new InstallProgress
        {
            Stage = InstallStage.Downloading,
            Component = asset.Kind,
            StepIndex = downloadIndex,
            StepCount = stepCount,
            BytesSoFar = b,
            BytesTotal = asset.Size,
        }));

        try
        {
            await _gh.DownloadAssetAsync(asset, temp, byteProgress, ct).ConfigureAwait(false);

            progress.Report(new InstallProgress
            {
                Stage = InstallStage.Verifying,
                Component = asset.Kind,
                StepIndex = downloadIndex,
                StepCount = stepCount,
            });

            var actual = await Hasher.Sha256HexAsync(temp, ct).ConfigureAwait(false);
            if (asset.DigestSha256 != null)
            {
                if (!string.Equals(actual, asset.DigestSha256, StringComparison.OrdinalIgnoreCase))
                {
                    throw new InvalidDataException(
                        Strings.Format("error.digestMismatch", asset.Name, asset.DigestSha256, actual));
                }
            }
            else
            {
                Logger.Warn($"No API digest for {asset.Name}; integrity not independently verified.");
            }

            _cache.Commit(temp, actual, asset.Kind!.Value, asset.Version ?? plan.Release.SemVer.ToString(3), asset.Size);
            return _cache.PathForDigest(actual);
        }
        finally
        {
            if (File.Exists(temp))
            {
                try { File.Delete(temp); } catch (Exception ex) { Logger.Warn($"Temp cleanup failed: {ex.Message}"); }
            }
        }
    }

    // ------------------------------------------------------------------
    // Apply.
    // ------------------------------------------------------------------

    private static void ApplyAll(
        InstallPlan plan,
        Dictionary<ComponentKind, string> stageMap,
        GameLayout layout,
        IProgress<InstallProgress> progress,
        CancellationToken ct)
    {
        // Apply order: engine, cinematics (back up before overwrite), runtime
        // (lua51 rename), core (nuke + extract), overlays (over core), packages
        // / LekMod DLC, then the VP substrate.
        foreach (var kind in stageMap.Keys.OrderBy(ApplyRank))
        {
            ct.ThrowIfCancellationRequested();
            var zip = stageMap[kind];
            switch (kind)
            {
                case ComponentKind.Engine:
                    progress.Report(new InstallProgress { Stage = InstallStage.BackingUp, Component = kind });
                    BackupEngine(layout);
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    ExtractZipTo(zip, layout.Expansion2Dir);
                    break;

                case ComponentKind.Cinematics:
                    progress.Report(new InstallProgress { Stage = InstallStage.BackingUp, Component = kind });
                    BackupCinematics(layout);
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    ExtractZipTo(zip, layout.Expansion2Dir);
                    break;

                case ComponentKind.Runtime:
                    progress.Report(new InstallProgress { Stage = InstallStage.SwappingProxy, Component = kind });
                    RenameStockLua51IfNeeded(layout);
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    ExtractZipTo(zip, layout.Root);
                    break;

                case ComponentKind.CoreBlind:
                case ComponentKind.CoreSighted:
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    RemoveLegacyDirs(layout);
                    NukeAndRecreate(layout.ModDlcDir);
                    ExtractZipTo(zip, layout.ModDlcDir);
                    break;

                case ComponentKind.VpOverlay:
                case ComponentKind.CpOverlay:
                case ComponentKind.LekmodOverlay:
                    // Overlays extract on top of the freshly-extracted core.
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    ExtractZipTo(zip, layout.ModDlcDir);
                    break;

                case ComponentKind.VpModpack:
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    NukeAndRecreate(layout.ModpackVpDir);
                    ExtractZipTo(zip, layout.ModpackVpDir);
                    break;

                case ComponentKind.CpModpack:
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    NukeAndRecreate(layout.ModpackCpDir);
                    ExtractZipTo(zip, layout.ModpackCpDir);
                    break;

                case ComponentKind.LekmodDlc:
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    ApplyLekmodDlc(zip, layout);
                    break;

                case ComponentKind.VpRuntime:
                    progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = kind });
                    ApplyVpRuntime(zip, layout);
                    break;

                default:
                    throw new ArgumentOutOfRangeException(nameof(kind), kind, "No apply handler.");
            }
        }
    }

    private static int ApplyRank(ComponentKind kind) => kind switch
    {
        ComponentKind.Engine        => 10,
        ComponentKind.Cinematics    => 20,
        ComponentKind.Runtime       => 30,
        ComponentKind.CoreBlind     => 40,
        ComponentKind.CoreSighted   => 40,
        ComponentKind.VpOverlay     => 50,
        ComponentKind.CpOverlay     => 50,
        ComponentKind.LekmodOverlay => 50,
        ComponentKind.VpModpack     => 60,
        ComponentKind.CpModpack     => 60,
        ComponentKind.LekmodDlc     => 60,
        ComponentKind.VpRuntime     => 70,
        _ => 100,
    };

    /// <summary>
    /// Apply the Vox Populi substrate. The vp-runtime zip is split into two
    /// roots: "game/" entries extract under the game install, "docs/" entries
    /// extract under the Civ V Documents tree (for the loading-screen tips).
    /// The stock BNW Expansion2.Civ5Pkg is backed up before the VP one
    /// overwrites it.
    /// </summary>
    private static void ApplyVpRuntime(string zipPath, GameLayout layout)
    {
        ArtifactOps.BackupStockCiv5Pkg(layout);
        ExtractZipRouted(zipPath, new Dictionary<string, string>
        {
            ["game/"] = layout.Root,
            ["docs/"] = layout.Civ5DocsDir,
        });
    }

    /// <summary>
    /// Apply the LekMod DLC. The lekmod-dlc zip is split into two roots: "dlc/"
    /// entries extract to Assets/DLC/LEKMOD (the prebaked DLC with our fork
    /// swapped in), "maps/" entries to Assets/Maps/Lekmap (LekMod's Lekmap map
    /// scripts). Both are cleared first (the same set teardown removes) so a
    /// re-apply can't leave a stray LEKMOD* dir or stale map.
    /// </summary>
    private static void ApplyLekmodDlc(string zipPath, GameLayout layout)
    {
        ArtifactOps.RemoveLekmodDlc(layout);
        ExtractZipRouted(zipPath, new Dictionary<string, string>
        {
            ["dlc/"]  = layout.LekmodDlcDir,
            ["maps/"] = layout.LekmapMapsDir,
        });
    }

    private static void BackupEngine(GameLayout layout)
    {
        if (File.Exists(layout.EngineBackup))
        {
            Logger.Info($"Engine backup already exists at {layout.EngineBackup}; not overwriting.");
            return;
        }
        if (!File.Exists(layout.EngineDll))
        {
            throw new FileNotFoundException(
                $"Vanilla engine DLL not found at {layout.EngineDll}. Verify the game files in Steam.");
        }
        Directory.CreateDirectory(layout.BackupDir);
        File.Copy(layout.EngineDll, layout.EngineBackup);
        Logger.Info($"Backed up vanilla engine DLL: {layout.EngineDll} -> {layout.EngineBackup}");
    }

    private static void BackupCinematics(GameLayout layout)
    {
        Directory.CreateDirectory(layout.CinematicsBackupDir);
        foreach (var f in GameLayout.CinematicFiles)
        {
            var installed = Path.Combine(layout.Expansion2Dir, f);
            var backup    = Path.Combine(layout.CinematicsBackupDir, f);
            if (File.Exists(installed) && !File.Exists(backup))
            {
                File.Copy(installed, backup);
                Logger.Info($"Backed up vanilla cinematic: {installed} -> {backup}");
            }
        }
    }

    private static void RenameStockLua51IfNeeded(GameLayout layout)
    {
        if (File.Exists(layout.Lua51Original))
        {
            Logger.Info("lua51_original.dll already present; proxy was previously deployed.");
            return;
        }
        if (!File.Exists(layout.Lua51Stock))
        {
            throw new FileNotFoundException(
                $"Neither lua51_Win32.dll nor lua51_original.dll found in {layout.Root}. " +
                "Verify game files in Steam and try again.");
        }
        File.Move(layout.Lua51Stock, layout.Lua51Original);
        Logger.Info($"Renamed stock {layout.Lua51Stock} -> {layout.Lua51Original}");
    }

    private static void RemoveLegacyDirs(GameLayout layout)
    {
        foreach (var p in layout.LegacyPaths())
        {
            if (Directory.Exists(p))
            {
                Logger.Info($"Removing legacy directory: {p}");
                Directory.Delete(p, recursive: true);
            }
        }
    }

    private static void NukeAndRecreate(string dir)
    {
        if (Directory.Exists(dir))
        {
            Logger.Info($"Removing existing directory: {dir}");
            Directory.Delete(dir, recursive: true);
        }
        Directory.CreateDirectory(dir);
    }

    private static void ExtractZipTo(string zipPath, string destDir)
    {
        Directory.CreateDirectory(destDir);
        using var zip = ZipFile.OpenRead(zipPath);
        var destFull = Path.GetFullPath(destDir);
        foreach (var entry in zip.Entries)
        {
            ExtractEntry(entry, destFull, entry.FullName);
        }
        Logger.Info($"Extracted {zipPath} -> {destDir}");
    }

    /// <summary>
    /// Extract a zip whose entries are prefixed (e.g. "game/", "docs/", "dlc/",
    /// "maps/") to a different root per prefix. A file entry matching no prefix
    /// is ignored and logged -- a missing payload is safer surfaced than
    /// silently extracted to the wrong root.
    /// </summary>
    private static void ExtractZipRouted(string zipPath, IReadOnlyDictionary<string, string> routes)
    {
        var fullRoots = routes.ToDictionary(
            kv => kv.Key, kv => Path.GetFullPath(kv.Value), StringComparer.Ordinal);

        using var zip = ZipFile.OpenRead(zipPath);
        foreach (var entry in zip.Entries)
        {
            string name = entry.FullName.Replace('\\', '/');
            var route = routes.Keys.FirstOrDefault(
                p => name.StartsWith(p, StringComparison.OrdinalIgnoreCase));
            if (route != null)
            {
                ExtractEntry(entry, fullRoots[route], name.Substring(route.Length));
            }
            else if (!name.EndsWith("/", StringComparison.Ordinal))
            {
                Logger.Warn($"Routed-zip entry outside {string.Join("/", routes.Keys)} ignored: {entry.FullName}");
            }
        }
        Logger.Info($"Extracted (routed) {zipPath}");
    }

    private static void ExtractEntry(ZipArchiveEntry entry, string destRootFull, string relativeName)
    {
        if (string.IsNullOrEmpty(relativeName)) return;
        var destPath = Path.GetFullPath(Path.Combine(destRootFull, relativeName));
        // Zip-slip guard: refuse entries that escape the destination root.
        var rootWithSep = destRootFull.EndsWith(Path.DirectorySeparatorChar)
            ? destRootFull : destRootFull + Path.DirectorySeparatorChar;
        if (!destPath.StartsWith(rootWithSep, StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(destPath, destRootFull, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidDataException($"Zip entry '{entry.FullName}' would extract outside {destRootFull}.");
        }

        if (relativeName.EndsWith("/", StringComparison.Ordinal) || string.IsNullOrEmpty(entry.Name))
        {
            Directory.CreateDirectory(destPath);
            return;
        }
        Directory.CreateDirectory(Path.GetDirectoryName(destPath)!);
        entry.ExtractToFile(destPath, overwrite: true);
    }

    // ------------------------------------------------------------------
    // Manifest.
    // ------------------------------------------------------------------

    private static void WriteManifest(InstallPlan plan)
    {
        var modVersion = plan.Release.SemVer.ToString(3);

        var manifest = new InstallManifest
        {
            ModVersion = modVersion,
            Profile = plan.TargetProfile,
            Variant = plan.TargetState,
            InstalledAt = DateTime.UtcNow,
        };

        // Record one component entry per applied asset. TargetAssets already
        // pairs each kind with its release asset, so this is the authoritative
        // set actually installed this run (no re-derivation of the component set
        // and no lookup that could miss).
        var kinds = new HashSet<ComponentKind>();
        foreach (var asset in plan.TargetAssets)
        {
            var kind = asset.Kind!.Value;
            kinds.Add(kind);
            manifest.Components[kind.ManifestKey()] = new InstallManifest.ComponentRecord
            {
                Version = asset.Version ?? modVersion,
                Sha256 = asset.DigestSha256,
            };
        }

        const string backupDirRel = "Assets/DLC/DLC_CivVAccess.backup";
        if (kinds.Contains(ComponentKind.Engine))
            manifest.Backups["engine_dll"] = $"{backupDirRel}/CvGameCore_Expansion2.vanilla.dll";
        if (kinds.Contains(ComponentKind.Cinematics))
            manifest.Backups["cinematics"] = $"{backupDirRel}/cinematics";
        if (kinds.Contains(ComponentKind.Runtime))
            manifest.Backups["lua51"] = "lua51_original.dll";
        if (kinds.Contains(ComponentKind.VpRuntime))
            manifest.Backups["civ5pkg"] = $"{backupDirRel}/Expansion2.Civ5Pkg.stock";

        manifest.Write(plan.GameDir);
    }

    public void Dispose() => _gh.Dispose();
}

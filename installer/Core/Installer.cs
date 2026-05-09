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
/// Decision summary computed before any download starts. The Confirm panel
/// renders this; Execute consumes it.
/// </summary>
internal sealed class InstallPlan
{
    public required string GameDir { get; init; }
    public required InstallProfile Profile { get; init; }
    public required GitHubReleases.Release Release { get; init; }
    public required InstallManifest? ExistingManifest { get; init; }

    /// <summary>
    /// Components that need download + apply. Components already at the
    /// release digest are excluded.
    /// </summary>
    public required IReadOnlyList<GitHubReleases.Asset> ComponentsToFetch { get; init; }

    /// <summary>True if forcing a redownload regardless of digest match.</summary>
    public required bool ForceAll { get; init; }

    public bool IsFreshInstall => ExistingManifest == null;
    public bool IsUpToDate => ComponentsToFetch.Count == 0 && !ForceAll;

    public long TotalBytesToFetch => ComponentsToFetch.Sum(a => a.Size);
}

/// <summary>
/// The orchestrator. Mirrors deploy.ps1 (blind profile) and
/// deploy-sighted-multiplayer.ps1 (sighted profile) at the file-operation
/// level, but consumes pre-built component zips from a GitHub Release
/// instead of the local repo's dist/ tree.
/// </summary>
internal sealed class Installer : IDisposable
{
    private readonly GitHubReleases _gh;
    private readonly string _stagingRoot;

    public Installer()
    {
        _gh = new GitHubReleases();
        _stagingRoot = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "CivVAccess", "Installer", "Cache");
        Directory.CreateDirectory(_stagingRoot);
    }

    public Task<GitHubReleases.Release> GetLatestReleaseAsync(CancellationToken ct) =>
        _gh.GetLatestAsync(ct);

    public Task<string> GetChangelogAsync(CancellationToken ct) =>
        _gh.GetChangelogAsync(ct);

    /// <summary>
    /// Compute which components need download for the given (gameDir,
    /// profile, release) tuple. Components whose digest already matches
    /// what's recorded in the install manifest are excluded.
    /// </summary>
    public InstallPlan BuildPlan(
        string gameDir,
        InstallProfile profile,
        GitHubReleases.Release release,
        InstallManifest? existing,
        bool forceAll)
    {
        var needed = ProfileComponents.For(profile);
        var assetByKind = release.Assets
            .Where(a => a.Kind != null)
            .GroupBy(a => a.Kind!.Value)
            .ToDictionary(g => g.Key, g => g.First());

        var missing = needed.Where(k => !assetByKind.ContainsKey(k)).ToList();
        if (missing.Count > 0)
        {
            var names = string.Join(", ", missing.Select(k => k.AssetPrefix()));
            throw new InvalidOperationException(
                Strings.Format("error.assetMissing", names));
        }

        var toFetch = new List<GitHubReleases.Asset>();
        foreach (var kind in needed)
        {
            var asset = assetByKind[kind];
            if (forceAll)
            {
                toFetch.Add(asset);
                continue;
            }
            var localSha = existing?.GetSha256(kind);
            if (localSha != null && asset.DigestSha256 != null &&
                string.Equals(localSha, asset.DigestSha256, StringComparison.OrdinalIgnoreCase))
            {
                Logger.Info($"Skipping {kind} (digest match: {localSha}).");
                continue;
            }
            toFetch.Add(asset);
        }

        return new InstallPlan
        {
            GameDir = gameDir,
            Profile = profile,
            Release = release,
            ExistingManifest = existing,
            ComponentsToFetch = toFetch,
            ForceAll = forceAll,
        };
    }

    /// <summary>
    /// Download all needed components, verify their SHA-256s, then apply
    /// them. The apply phase only starts after every download has verified,
    /// so a failure mid-download does not corrupt an existing install.
    /// </summary>
    public async Task ExecuteAsync(
        InstallPlan plan,
        IProgress<InstallProgress> progress,
        CancellationToken ct)
    {
        var sessionDir = Path.Combine(_stagingRoot, plan.Release.TagName, Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(sessionDir);
        Logger.Info($"Staging session dir: {sessionDir}");

        var stageMap = new Dictionary<ComponentKind, string>();

        try
        {
            // 1. Download + verify, but don't touch the install yet.
            for (int i = 0; i < plan.ComponentsToFetch.Count; i++)
            {
                var asset = plan.ComponentsToFetch[i];
                var stagedZip = Path.Combine(sessionDir, asset.Name);
                stageMap[asset.Kind!.Value] = stagedZip;

                progress.Report(new InstallProgress
                {
                    Stage = InstallStage.Downloading,
                    Component = asset.Kind,
                    StepIndex = i,
                    StepCount = plan.ComponentsToFetch.Count,
                    BytesTotal = asset.Size,
                });

                var byteProgress = new Progress<long>(b => progress.Report(new InstallProgress
                {
                    Stage = InstallStage.Downloading,
                    Component = asset.Kind,
                    StepIndex = i,
                    StepCount = plan.ComponentsToFetch.Count,
                    BytesSoFar = b,
                    BytesTotal = asset.Size,
                }));

                await _gh.DownloadAssetAsync(asset, stagedZip, byteProgress, ct).ConfigureAwait(false);

                progress.Report(new InstallProgress
                {
                    Stage = InstallStage.Verifying,
                    Component = asset.Kind,
                    StepIndex = i,
                    StepCount = plan.ComponentsToFetch.Count,
                });

                if (asset.DigestSha256 != null)
                {
                    var actual = await Hasher.Sha256HexAsync(stagedZip, ct).ConfigureAwait(false);
                    if (!string.Equals(actual, asset.DigestSha256, StringComparison.OrdinalIgnoreCase))
                    {
                        throw new InvalidDataException(
                            Strings.Format("error.digestMismatch", asset.Name, asset.DigestSha256, actual));
                    }
                    Logger.Info($"Verified {asset.Name}: {actual}");
                }
                else
                {
                    Logger.Warn($"No API digest for {asset.Name}; integrity not verified.");
                }
            }

            // 2. Apply. Past this point we are mutating the game install.
            ApplyAll(plan, stageMap, progress, ct);

            // 3. Manifest (with per-component digests).
            progress.Report(new InstallProgress { Stage = InstallStage.WritingManifest });
            WriteManifest(plan);

            progress.Report(new InstallProgress { Stage = InstallStage.Done });
        }
        finally
        {
            try { Directory.Delete(sessionDir, recursive: true); }
            catch (Exception ex) { Logger.Warn($"Could not clean staging dir {sessionDir}: {ex.Message}"); }
        }
    }

    private void ApplyAll(
        InstallPlan plan,
        Dictionary<ComponentKind, string> stageMap,
        IProgress<InstallProgress> progress,
        CancellationToken ct)
    {
        var layout = new GameLayout(plan.GameDir);

        // Engine first (its backup must exist before we overwrite the DLL),
        // then cinematics (same reason), then runtime (lua51 rename), then
        // core (DLC dir nuke + extract). Manifest is written last by Execute.
        if (stageMap.TryGetValue(ComponentKind.Engine, out var engineZip))
        {
            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.BackingUp, Component = ComponentKind.Engine });
            BackupEngine(layout);
            progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = ComponentKind.Engine });
            ExtractZipTo(engineZip, layout.Expansion2Dir, overwriteFiles: true);
        }

        if (stageMap.TryGetValue(ComponentKind.Cinematics, out var cineZip))
        {
            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.BackingUp, Component = ComponentKind.Cinematics });
            BackupCinematics(layout);
            progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = ComponentKind.Cinematics });
            ExtractZipTo(cineZip, layout.Expansion2Dir, overwriteFiles: true);
        }

        if (stageMap.TryGetValue(ComponentKind.Runtime, out var runtimeZip))
        {
            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.SwappingProxy, Component = ComponentKind.Runtime });
            RenameStockLua51IfNeeded(layout);
            progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = ComponentKind.Runtime });
            ExtractZipTo(runtimeZip, layout.Root, overwriteFiles: true);
        }

        // core-blind / core-sighted both extract into ModDlcDir, with the
        // dir nuked-and-recreated first to drop stale files from prior versions.
        ComponentKind? coreKind = stageMap.ContainsKey(ComponentKind.CoreBlind) ? ComponentKind.CoreBlind
                                : stageMap.ContainsKey(ComponentKind.CoreSighted) ? ComponentKind.CoreSighted
                                : (ComponentKind?)null;
        if (coreKind != null)
        {
            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.Extracting, Component = coreKind });
            RemoveLegacyDirs(layout);
            NukeAndRecreate(layout.ModDlcDir);
            ExtractZipTo(stageMap[coreKind.Value], layout.ModDlcDir, overwriteFiles: true);
        }

        progress.Report(new InstallProgress { Stage = InstallStage.ClearingCache });
        ClearDlcCache(layout);
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

    private static void ExtractZipTo(string zipPath, string destDir, bool overwriteFiles)
    {
        Directory.CreateDirectory(destDir);
        using var zip = ZipFile.OpenRead(zipPath);
        foreach (var entry in zip.Entries)
        {
            // ZipArchiveEntry.FullName uses forward slashes per spec.
            var destPath = Path.GetFullPath(Path.Combine(destDir, entry.FullName));
            // Zip-slip guard: refuse entries that escape destDir.
            var fullDest = Path.GetFullPath(destDir) + Path.DirectorySeparatorChar;
            if (!destPath.StartsWith(fullDest, StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(destPath, Path.GetFullPath(destDir), StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidDataException($"Zip entry '{entry.FullName}' would extract outside {destDir}.");
            }

            if (entry.FullName.EndsWith("/", StringComparison.Ordinal) || string.IsNullOrEmpty(entry.Name))
            {
                Directory.CreateDirectory(destPath);
                continue;
            }
            Directory.CreateDirectory(Path.GetDirectoryName(destPath)!);
            entry.ExtractToFile(destPath, overwriteFiles);
        }
        Logger.Info($"Extracted {zipPath} -> {destDir}");
    }

    private static void ClearDlcCache(GameLayout layout)
    {
        if (!Directory.Exists(layout.DlcCacheDir)) return;
        try
        {
            foreach (var file in Directory.EnumerateFiles(layout.DlcCacheDir))
            {
                File.Delete(file);
            }
            Logger.Info($"Cleared DLC cache: {layout.DlcCacheDir}");
        }
        catch (Exception ex)
        {
            // Cache failures aren't fatal; the engine will still find the DLC,
            // it'll just enumerate slower on next launch.
            Logger.Warn($"DLC cache clear failed: {ex.Message}");
        }
    }

    /// <summary>
    /// Build and write the install manifest. Each component records its own
    /// version (parsed from the release asset's filename), not the mod's
    /// version - so a release where engine didn't change still records
    /// engine.version = the engine's true last-changed version. mod_version
    /// at the top level is the release tag (what the changelog is keyed by).
    /// Components fetched this run get the API's digest stamped in;
    /// components that were skipped because they were already current carry
    /// their previous version + digest forward.
    /// </summary>
    private static void WriteManifest(InstallPlan plan)
    {
        var modVersion = plan.Release.SemVer.ToString(3);
        var fetchedByKind = plan.ComponentsToFetch.ToDictionary(a => a.Kind!.Value, a => a);
        var assetByKind = plan.Release.Assets
            .Where(a => a.Kind != null)
            .GroupBy(a => a.Kind!.Value)
            .ToDictionary(g => g.Key, g => g.First());

        var manifest = new InstallManifest
        {
            ModVersion = modVersion,
            Profile = plan.Profile,
            InstalledAt = DateTime.UtcNow,
        };

        foreach (var kind in ProfileComponents.For(plan.Profile))
        {
            string componentVersion;
            string? sha;
            if (fetchedByKind.TryGetValue(kind, out var fetchedAsset))
            {
                // Just downloaded - asset filename carries authoritative version.
                componentVersion = fetchedAsset.Version ?? modVersion;
                sha = fetchedAsset.DigestSha256;
            }
            else
            {
                // Skipped because the local install already matched. The
                // release still names the asset (we just didn't fetch it),
                // so its version is the truth - record that, not whatever
                // the previous manifest happened to say.
                if (assetByKind.TryGetValue(kind, out var releaseAsset))
                {
                    componentVersion = releaseAsset.Version ?? modVersion;
                    sha = plan.ExistingManifest?.GetSha256(kind) ?? releaseAsset.DigestSha256;
                }
                else
                {
                    // Should be unreachable - BuildPlan would have thrown earlier.
                    componentVersion = plan.ExistingManifest?.TryGetComponent(kind, out var prior) == true
                        ? prior.Version : modVersion;
                    sha = plan.ExistingManifest?.GetSha256(kind);
                }
            }

            manifest.Components[kind.ManifestKey()] = new InstallManifest.ComponentRecord
            {
                Version = componentVersion,
                Sha256 = sha,
            };
        }

        var backupDirRel = "Assets/DLC/DLC_CivVAccess.backup";
        if (plan.Profile == InstallProfile.Blind)
        {
            manifest.Backups["engine_dll"] = $"{backupDirRel}/CvGameCore_Expansion2.vanilla.dll";
            manifest.Backups["cinematics"] = $"{backupDirRel}/cinematics";
            manifest.Backups["lua51"]      = "lua51_original.dll";
        }
        else
        {
            manifest.Backups["engine_dll"] = $"{backupDirRel}/CvGameCore_Expansion2.vanilla.dll";
        }

        manifest.Write(plan.GameDir);
    }

    public void Dispose() => _gh.Dispose();
}

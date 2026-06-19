using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Full uninstall: restore the game to its pre-mod state regardless of which
/// install state is active, then clear the component cache. Idempotent; each
/// step is a no-op when its artifact is absent. The profile/variant question is
/// irrelevant here -- we remove every artifact we recognize.
/// </summary>
internal static class UninstallRunner
{
    public static Task RunAsync(
        string gameDir,
        IProgress<InstallProgress> progress,
        CancellationToken ct)
    {
        return Task.Run(() =>
        {
            var layout = new GameLayout(gameDir);

            ct.ThrowIfCancellationRequested();
            // Tear down every removable artifact across all states: proxy, both
            // modpack packages, the VP substrate (restoring the stock
            // Expansion2.Civ5Pkg), and the LekMod DLC. Runs while the backup dir
            // is still intact, so the Civ5Pkg restore can find its backup.
            progress.Report(new InstallProgress { Stage = InstallStage.SwappingProxy });
            ArtifactOps.TearDown(ModArtifact.All, layout);

            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.RemovingDlc });
            RemoveDlcAndLegacy(layout);

            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.Restoring, Component = ComponentKind.Engine });
            RestoreEngine(layout);

            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.Restoring, Component = ComponentKind.Cinematics });
            RestoreCinematics(layout);

            // Backup dir holds no useful state once the restores have run.
            if (Directory.Exists(layout.BackupDir))
            {
                Logger.Info($"Removing backup dir: {layout.BackupDir}");
                try { Directory.Delete(layout.BackupDir, recursive: true); }
                catch (Exception ex) { Logger.Warn($"Could not remove backup dir: {ex.Message}"); }
            }

            progress.Report(new InstallProgress { Stage = InstallStage.ClearingCache });
            ArtifactOps.ClearDlcCache(layout);
            ComponentCache.ClearAll();

            progress.Report(new InstallProgress { Stage = InstallStage.Done });
        }, ct);
    }

    private static void RemoveDlcAndLegacy(GameLayout layout)
    {
        if (Directory.Exists(layout.ModDlcDir))
        {
            Logger.Info($"Removing DLC: {layout.ModDlcDir}");
            try { Directory.Delete(layout.ModDlcDir, recursive: true); }
            catch (Exception ex) { Logger.Warn($"Could not remove DLC dir: {ex.Message}"); }
        }
        foreach (var p in layout.LegacyPaths())
        {
            if (Directory.Exists(p))
            {
                Logger.Info($"Removing legacy: {p}");
                try { Directory.Delete(p, recursive: true); }
                catch (Exception ex) { Logger.Warn($"Could not remove legacy {p}: {ex.Message}"); }
            }
        }
    }

    private static void RestoreEngine(GameLayout layout)
    {
        if (!File.Exists(layout.EngineBackup))
        {
            Logger.Info("No engine DLL backup; nothing to restore.");
            return;
        }
        Logger.Info($"Restoring vanilla engine DLL: {layout.EngineBackup} -> {layout.EngineDll}");
        File.Copy(layout.EngineBackup, layout.EngineDll, overwrite: true);
    }

    private static void RestoreCinematics(GameLayout layout)
    {
        if (!Directory.Exists(layout.CinematicsBackupDir))
        {
            Logger.Info("No cinematics backup; nothing to restore.");
            return;
        }
        foreach (var f in GameLayout.CinematicFiles)
        {
            var backup    = Path.Combine(layout.CinematicsBackupDir, f);
            var installed = Path.Combine(layout.Expansion2Dir, f);
            if (File.Exists(backup))
            {
                Logger.Info($"Restoring vanilla cinematic: {backup} -> {installed}");
                File.Copy(backup, installed, overwrite: true);
            }
        }
    }
}

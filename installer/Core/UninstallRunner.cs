using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Mirror of Invoke-Uninstall in deploy.ps1 / deploy-sighted-multiplayer.ps1.
/// Idempotent: each step checks for the artifact's presence and skips if
/// absent. The profile question is irrelevant here — we remove anything we
/// recognize, blind or sighted.
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
            progress.Report(new InstallProgress { Stage = InstallStage.SwappingProxy });
            RestoreLua51(layout);

            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.RemovingTolk });
            RemoveRuntimeFiles(layout);

            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.RemovingDlc });
            RemoveDlcAndLegacy(layout);

            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.Restoring, Component = ComponentKind.Engine });
            RestoreEngine(layout);

            ct.ThrowIfCancellationRequested();
            progress.Report(new InstallProgress { Stage = InstallStage.Restoring, Component = ComponentKind.Cinematics });
            RestoreCinematics(layout);

            // Backup dir is empty of useful state once both restores have run.
            if (Directory.Exists(layout.BackupDir))
            {
                Logger.Info($"Removing backup dir: {layout.BackupDir}");
                try { Directory.Delete(layout.BackupDir, recursive: true); }
                catch (Exception ex) { Logger.Warn($"Could not remove backup dir: {ex.Message}"); }
            }

            progress.Report(new InstallProgress { Stage = InstallStage.ClearingCache });
            ClearDlcCache(layout);

            progress.Report(new InstallProgress { Stage = InstallStage.Done });
        }, ct);
    }

    private static void RestoreLua51(GameLayout layout)
    {
        if (!File.Exists(layout.Lua51Original))
        {
            Logger.Info("No lua51_original.dll to restore; proxy was never deployed.");
            return;
        }
        if (File.Exists(layout.Lua51Stock))
        {
            Logger.Info($"Removing proxy {layout.Lua51Stock}");
            File.Delete(layout.Lua51Stock);
        }
        Logger.Info($"Restoring {layout.Lua51Original} -> {layout.Lua51Stock}");
        File.Move(layout.Lua51Original, layout.Lua51Stock);
    }

    private static void RemoveRuntimeFiles(GameLayout layout)
    {
        // Skip lua51_Win32.dll here; RestoreLua51 already handles it.
        foreach (var f in GameLayout.RuntimeFiles)
        {
            if (string.Equals(f, "lua51_Win32.dll", StringComparison.OrdinalIgnoreCase)) continue;
            var p = Path.Combine(layout.Root, f);
            if (File.Exists(p))
            {
                Logger.Info($"Removing {p}");
                try { File.Delete(p); }
                catch (Exception ex) { Logger.Warn($"Could not remove {p}: {ex.Message}"); }
            }
        }

        if (File.Exists(layout.ProxyDebugLog))
        {
            try { File.Delete(layout.ProxyDebugLog); }
            catch (Exception ex) { Logger.Warn($"Could not remove proxy_debug.log: {ex.Message}"); }
        }
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
            Logger.Warn($"DLC cache clear failed: {ex.Message}");
        }
    }
}


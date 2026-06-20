using System;
using System.IO;

namespace CivVAccess.Installer.Core;

/// <summary>
/// File-level teardown and restore primitives for the install states. Both the
/// transition flow (state flip) and the uninstaller drive these, so the cleanup
/// logic lives in exactly one place. Every operation is idempotent: a no-op
/// when its artifact is absent. Failures are logged, never swallowed silently.
/// </summary>
internal static class ArtifactOps
{
    /// <summary>
    /// Tear down the given artifacts from the install, restoring any backed-up
    /// stock file. Idempotent and order-independent.
    /// </summary>
    public static void TearDown(ModArtifact artifacts, GameLayout layout)
    {
        if (artifacts.HasFlag(ModArtifact.Proxy))       RemoveProxy(layout);
        if (artifacts.HasFlag(ModArtifact.ModpackVp))   RemoveDir(layout.ModpackVpDir, "VP modpack package");
        if (artifacts.HasFlag(ModArtifact.ModpackCp))   RemoveDir(layout.ModpackCpDir, "CP modpack package");
        if (artifacts.HasFlag(ModArtifact.VpSubstrate)) RemoveVpSubstrate(layout);
        if (artifacts.HasFlag(ModArtifact.LekmodDlc))   RemoveLekmodDlc(layout);
    }

    // ------------------------------------------------------------------
    // Proxy stack.
    // ------------------------------------------------------------------

    public static void RemoveProxy(GameLayout layout)
    {
        RestoreLua51(layout);
        RemoveTolkFiles(layout);
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

    private static void RemoveTolkFiles(GameLayout layout)
    {
        // lua51_Win32.dll is handled by RestoreLua51; skip it here.
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

    // ------------------------------------------------------------------
    // Vox Populi substrate.
    // ------------------------------------------------------------------

    /// <summary>
    /// Back up the stock BNW Expansion2.Civ5Pkg before the VP substrate swaps
    /// it. No-op if the installed pkg is already the VP one (nothing stock to
    /// capture) or a backup already exists.
    /// </summary>
    public static void BackupStockCiv5Pkg(GameLayout layout)
    {
        if (File.Exists(layout.Civ5PkgStockBackup)) return;

        // Only capture a backup when the installed pkg is positively identified
        // as the stock file. If it's the VP one there's nothing stock to save;
        // if it can't be read, do NOT capture it -- backing up a possibly-VP pkg
        // as "stock" would later restore VP over itself and lose the real stock.
        switch (ClassifyCiv5Pkg(layout))
        {
            case Civ5PkgKind.Stock:
                Directory.CreateDirectory(layout.BackupDir);
                Logger.Info($"Capturing stock Expansion2.Civ5Pkg -> {layout.Civ5PkgStockBackup}");
                File.Copy(layout.Expansion2Civ5Pkg, layout.Civ5PkgStockBackup);
                break;
            case Civ5PkgKind.Unreadable:
                Logger.Warn(
                    "Skipping stock Expansion2.Civ5Pkg backup: the file could not be read and may not " +
                    "be the stock manifest.");
                break;
            // Missing or Vp: nothing stock to capture.
        }
    }

    private enum Civ5PkgKind { Missing, Stock, Vp, Unreadable }

    private static Civ5PkgKind ClassifyCiv5Pkg(GameLayout layout)
    {
        if (!File.Exists(layout.Expansion2Civ5Pkg)) return Civ5PkgKind.Missing;
        try
        {
            return File.ReadAllText(layout.Expansion2Civ5Pkg).Contains(GameLayout.VpCiv5PkgMarker)
                ? Civ5PkgKind.Vp
                : Civ5PkgKind.Stock;
        }
        catch (Exception ex)
        {
            Logger.Warn($"Could not read Expansion2.Civ5Pkg: {ex.Message}");
            return Civ5PkgKind.Unreadable;
        }
    }

    private static void RemoveVpSubstrate(GameLayout layout)
    {
        RemoveDir(layout.VpuiDir, "VPUI fake DLC");

        // Restore the stock manifest only when the installed pkg is positively
        // the VP one. An unreadable/stock/missing pkg is left untouched.
        if (ClassifyCiv5Pkg(layout) == Civ5PkgKind.Vp)
        {
            if (File.Exists(layout.Civ5PkgStockBackup))
            {
                Logger.Info($"Restoring stock BNW Expansion2.Civ5Pkg from {layout.Civ5PkgStockBackup}");
                File.Copy(layout.Civ5PkgStockBackup, layout.Expansion2Civ5Pkg, overwrite: true);
            }
            else
            {
                Logger.Warn(
                    "Expansion2.Civ5Pkg is the VP version but no stock backup exists; " +
                    "leaving it in place. Verify game files in Steam to restore the stock manifest.");
            }
        }

        DeleteFile(layout.MinorCivSoundsXml, "minor-civ sound table");
        DeleteFile(layout.VpuiTipsFile, "VP loading-screen tips");
    }

    // ------------------------------------------------------------------
    // LekMod DLC.
    // ------------------------------------------------------------------

    /// <summary>
    /// Remove every LekMod DLC directory (Assets/DLC/LEKMOD*) and the Lekmap map
    /// scripts (Assets/Maps/Lekmap). The two ship in one component and travel
    /// together, so they tear down together. Public so the apply path can clear
    /// strays with the same definition the teardown uses, before re-extracting --
    /// keeping apply and teardown from disagreeing on what "the LekMod DLC" is.
    /// </summary>
    public static void RemoveLekmodDlc(GameLayout layout)
    {
        if (Directory.Exists(layout.AssetsDlcDir))
        {
            foreach (var dir in Directory.EnumerateDirectories(layout.AssetsDlcDir, "LEKMOD*"))
            {
                RemoveDir(dir, "LekMod DLC");
            }
        }
        RemoveDir(layout.LekmapMapsDir, "Lekmap map scripts");
    }

    // ------------------------------------------------------------------
    // Shared helpers.
    // ------------------------------------------------------------------

    /// <summary>
    /// Flush the engine's DLC enumeration cache so a newly added or renamed DLC
    /// isn't held back by stale cache state. Non-fatal on failure (the engine
    /// re-enumerates anyway, just slower).
    /// </summary>
    public static void ClearDlcCache(GameLayout layout)
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

    public static void RemoveDir(string dir, string label)
    {
        if (!Directory.Exists(dir)) return;
        Logger.Info($"Removing {label}: {dir}");
        try { Directory.Delete(dir, recursive: true); }
        catch (Exception ex) { Logger.Warn($"Could not remove {label} ({dir}): {ex.Message}"); }
    }

    private static void DeleteFile(string path, string label)
    {
        if (!File.Exists(path)) return;
        Logger.Info($"Removing {label}: {path}");
        try { File.Delete(path); }
        catch (Exception ex) { Logger.Warn($"Could not remove {label} ({path}): {ex.Message}"); }
    }
}

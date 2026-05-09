using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using Microsoft.Win32;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Locate the Civilization V install directory. Mirrors
/// Resolve-CivVInstallDir in deploy.ps1, plus a generalized drive-search
/// fallback for the rare case the player isn't on Steam.
/// </summary>
internal static class GameDetector
{
    private const string AppName = "Sid Meier's Civilization V";
    private const string CivExe = "CivilizationV.exe";

    /// <summary>
    /// Find a Civ V install directory, or null if none of the candidates
    /// contained CivilizationV.exe. The caller should fall back to a manual
    /// browse picker.
    /// </summary>
    public static string? AutoDetect()
    {
        var candidates = new List<string>();

        AddFromEnv(candidates);
        AddFromUninstallKeys(candidates);
        AddFromHkcuSteam(candidates);
        AddFromHklmSteam(candidates);
        AddDefaultProgramFiles(candidates);
        AddFromDriveSearch(candidates);

        Logger.Debug($"Game-dir candidates ({candidates.Count}):");
        foreach (var c in candidates) Logger.Debug($"  {c}");

        foreach (var candidate in candidates)
        {
            if (LooksLikeCivVInstall(candidate))
            {
                Logger.Info($"Resolved Civ V install: {candidate}");
                return Path.GetFullPath(candidate);
            }
        }
        Logger.Warn("Auto-detect failed for all candidates.");
        return null;
    }

    /// <summary>
    /// Verify a manually-picked path is a Civ V install. Used by the
    /// Browse fallback.
    /// </summary>
    public static bool LooksLikeCivVInstall(string path)
    {
        if (string.IsNullOrWhiteSpace(path)) return false;
        try
        {
            return File.Exists(Path.Combine(path, CivExe));
        }
        catch (Exception ex)
        {
            Logger.Warn($"Path check failed for {path}: {ex.Message}");
            return false;
        }
    }

    /// <summary>
    /// True if the install has Brave New World (Expansion2) directory present.
    /// The mod requires BNW, so a missing one is a fail-fast condition.
    /// </summary>
    public static bool HasBraveNewWorld(string gameDir)
    {
        var bnw = Path.Combine(gameDir, "Assets", "DLC", "Expansion2");
        var engineDll = Path.Combine(bnw, "CvGameCore_Expansion2.dll");
        return Directory.Exists(bnw) && File.Exists(engineDll);
    }

    private static void AddFromEnv(List<string> candidates)
    {
        var explicitDir = Environment.GetEnvironmentVariable("CIV5_DIR");
        Add(candidates, explicitDir);
    }

    private static void AddFromUninstallKeys(List<string> candidates)
    {
        // Steam App 8930 = Sid Meier's Civilization V on Steam.
        var keys = new[]
        {
            @"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 8930",
            @"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 8930",
        };
        foreach (var path in keys)
        {
            try
            {
                using var key = Registry.LocalMachine.OpenSubKey(path);
                if (key == null) continue;
                Add(candidates, key.GetValue("InstallLocation") as string);
            }
            catch (Exception ex)
            {
                Logger.Debug($"Uninstall key {path} read failed: {ex.Message}");
            }
        }
    }

    private static void AddFromHkcuSteam(List<string> candidates)
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(@"Software\Valve\Steam");
            if (key == null) return;
            var steamPath = (key.GetValue("SteamPath") as string)?.Replace('/', '\\').TrimEnd('\\');
            if (string.IsNullOrWhiteSpace(steamPath)) return;

            Add(candidates, Path.Combine(steamPath, "steamapps", "common", AppName));
            AddFromLibraryFoldersVdf(candidates, Path.Combine(steamPath, "steamapps", "libraryfolders.vdf"));
        }
        catch (Exception ex)
        {
            Logger.Debug($"HKCU Steam read failed: {ex.Message}");
        }
    }

    private static void AddFromHklmSteam(List<string> candidates)
    {
        try
        {
            using var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\WOW6432Node\Valve\Steam");
            if (key == null) return;
            var path = (key.GetValue("InstallPath") as string)?.TrimEnd('\\');
            if (string.IsNullOrWhiteSpace(path)) return;
            Add(candidates, Path.Combine(path, "steamapps", "common", AppName));
            AddFromLibraryFoldersVdf(candidates, Path.Combine(path, "steamapps", "libraryfolders.vdf"));
        }
        catch (Exception ex)
        {
            Logger.Debug($"HKLM Steam read failed: {ex.Message}");
        }
    }

    private static void AddFromLibraryFoldersVdf(List<string> candidates, string vdfPath)
    {
        if (!File.Exists(vdfPath)) return;
        try
        {
            var raw = File.ReadAllText(vdfPath);
            // Steam's VDF: lines like   "path"  "C:\\Games\\Steam"
            foreach (Match m in Regex.Matches(raw, "\"path\"\\s*\"([^\"]+)\""))
            {
                var libPath = m.Groups[1].Value.Replace(@"\\", @"\");
                Add(candidates, Path.Combine(libPath, "steamapps", "common", AppName));
            }
        }
        catch (Exception ex)
        {
            Logger.Warn($"libraryfolders.vdf parse failed at {vdfPath}: {ex.Message}");
        }
    }

    private static void AddDefaultProgramFiles(List<string> candidates)
    {
        var pf86 = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
        Add(candidates, Path.Combine(pf86, "Steam", "steamapps", "common", AppName));
        Add(candidates, Path.Combine(pf86, AppName));

        var pf = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        Add(candidates, Path.Combine(pf, AppName));
    }

    /// <summary>
    /// Last-resort search of fixed drive roots for known Steam library
    /// patterns and a couple of non-Steam patterns. Targeted enumeration
    /// rather than recursive descent: a full drive scan would take minutes.
    /// </summary>
    private static void AddFromDriveSearch(List<string> candidates)
    {
        DriveInfo[] drives;
        try { drives = DriveInfo.GetDrives(); }
        catch (Exception ex) { Logger.Warn($"Drive enumeration failed: {ex.Message}"); return; }

        var patterns = new[]
        {
            @"Steam\steamapps\common\" + AppName,
            @"SteamLibrary\steamapps\common\" + AppName,
            @"Games\Steam\steamapps\common\" + AppName,
            @"Program Files (x86)\Steam\steamapps\common\" + AppName,
            @"Program Files\Steam\steamapps\common\" + AppName,
            @"Games\" + AppName,
            @"GOG Games\Civilization V",
        };

        foreach (var d in drives)
        {
            if (d.DriveType != DriveType.Fixed) continue;
            string root;
            try { root = d.RootDirectory.FullName; }
            catch { continue; }

            foreach (var rel in patterns)
            {
                Add(candidates, Path.Combine(root, rel));
            }
        }
    }

    private static void Add(List<string> list, string? path)
    {
        if (string.IsNullOrWhiteSpace(path)) return;
        var normalized = path.Trim().Trim('"');
        if (string.IsNullOrWhiteSpace(normalized)) return;
        if (!list.Contains(normalized, StringComparer.OrdinalIgnoreCase))
        {
            list.Add(normalized);
        }
    }
}

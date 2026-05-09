using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Civ V's user-side config.ini, at
/// %USERPROFILE%\Documents\My Games\Sid Meier's Civilization 5\config.ini.
///
/// The mod's no-silent-failures rule depends on Lua.log being populated,
/// which only happens when LoggingEnabled=1 is set here. The file is created
/// by the game on first launch, so it may not exist yet on a fresh install -
/// in that case we log "skipping, will retry next run" and the next install
/// or update naturally tries again. After enough installer runs the user
/// will eventually have launched the game once and the file will appear.
/// </summary>
internal static class GameConfigIni
{
    public static string ConfigPath { get; } = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
        "Documents", "My Games", "Sid Meier's Civilization 5", "config.ini");

    private static readonly Regex LoggingLine = new(
        @"^(\s*LoggingEnabled\s*=\s*)(\S.*?)(\s*)$",
        RegexOptions.IgnoreCase | RegexOptions.Compiled);

    /// <summary>
    /// Best-effort: enable LoggingEnabled=1 in the user's config.ini. Returns
    /// the outcome rather than throwing - this is auxiliary to install
    /// success and shouldn't fail the run if the config is locked or absent.
    /// </summary>
    public static ConfigUpdateResult TryEnableLogging()
    {
        if (!File.Exists(ConfigPath))
        {
            Logger.Info($"config.ini not found at {ConfigPath}; skipping logging toggle. Will retry on the next installer run once the user has launched the game at least once.");
            return ConfigUpdateResult.Absent;
        }

        try
        {
            var input = File.ReadAllLines(ConfigPath);
            var (output, action) = ApplyLoggingEnabled(input);
            switch (action)
            {
                case ConfigUpdateResult.AlreadyEnabled:
                    Logger.Info("config.ini LoggingEnabled is already 1; nothing to do.");
                    return ConfigUpdateResult.AlreadyEnabled;
                case ConfigUpdateResult.Enabled:
                    BackupOnce();
                    File.WriteAllLines(ConfigPath, output);
                    Logger.Info($"Set LoggingEnabled=1 in {ConfigPath}.");
                    return ConfigUpdateResult.Enabled;
                default:
                    return action;
            }
        }
        catch (Exception ex)
        {
            Logger.Warn($"Could not update config.ini: {ex.Message}");
            return ConfigUpdateResult.Failed;
        }
    }

    /// <summary>
    /// Pure transform exposed for tests. Returns the rewritten line array
    /// and what action was needed. The IO-shaped TryEnableLogging wraps
    /// this in file read/write/backup.
    /// </summary>
    internal static (string[] Output, ConfigUpdateResult Action) ApplyLoggingEnabled(string[] input)
    {
        var lines = new List<string>(input);
        for (int i = 0; i < lines.Count; i++)
        {
            var m = LoggingLine.Match(lines[i]);
            if (!m.Success) continue;

            if (m.Groups[2].Value.Trim() == "1")
            {
                return (input, ConfigUpdateResult.AlreadyEnabled);
            }
            lines[i] = m.Groups[1].Value + "1" + m.Groups[3].Value;
            return (lines.ToArray(), ConfigUpdateResult.Enabled);
        }

        // Key absent - append. Civ V tolerates extra keys at the end.
        lines.Add("LoggingEnabled = 1");
        return (lines.ToArray(), ConfigUpdateResult.Enabled);
    }

    private static void BackupOnce()
    {
        var backup = ConfigPath + ".civvaccess-backup";
        if (File.Exists(backup)) return;
        try
        {
            File.Copy(ConfigPath, backup);
            Logger.Info($"Backed up original config.ini to {backup}.");
        }
        catch (Exception ex)
        {
            // Don't block the toggle if the backup failed - the install
            // matters more, and the user can recover by re-running Steam's
            // Verify Game Files which restores defaults.
            Logger.Warn($"config.ini backup failed: {ex.Message}");
        }
    }
}

internal enum ConfigUpdateResult
{
    Enabled,         // We changed it from off (or absent key) to on.
    AlreadyEnabled,  // Found LoggingEnabled=1 already.
    Absent,          // File doesn't exist yet (game not launched).
    Failed,          // I/O or parse failure - logged.
}

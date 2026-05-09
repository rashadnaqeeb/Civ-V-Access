using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace CivVAccess.Installer.Core;

/// <summary>
/// CivVAccess.install.json read/write. Lives at
/// &lt;game&gt;\Assets\DLC\DLC_CivVAccess\CivVAccess.install.json. Schema mirrors
/// deploy.ps1's Write-InstallManifest, plus an optional sha256 per component
/// the installer adds when it installs (so subsequent updates can skip a
/// component whose digest matches the API's). When deploy.ps1 writes the
/// manifest the sha256 fields are absent; the installer treats absent as
/// "unknown, redownload".
/// </summary>
internal sealed class InstallManifest
{
    public int SchemaVersion { get; set; } = AppVersion.InstallManifestSchemaVersion;
    public string ModVersion { get; set; } = "";
    public InstallProfile Profile { get; set; }
    public DateTime InstalledAt { get; set; } = DateTime.UtcNow;
    public Dictionary<string, ComponentRecord> Components { get; set; } = new();
    public Dictionary<string, string> Backups { get; set; } = new();

    public sealed class ComponentRecord
    {
        public string Version { get; set; } = "";
        public string? Sha256 { get; set; }
    }

    public bool TryGetComponent(ComponentKind kind, out ComponentRecord record)
    {
        return Components.TryGetValue(kind.ManifestKey(), out record!);
    }

    public string? GetSha256(ComponentKind kind) =>
        TryGetComponent(kind, out var rec) ? rec.Sha256 : null;

    /// <summary>
    /// Resolve the manifest path inside a game directory.
    /// </summary>
    public static string PathFor(string gameDir) =>
        Path.Combine(gameDir, "Assets", "DLC", "DLC_CivVAccess", "CivVAccess.install.json");

    public static InstallManifest? TryRead(string gameDir)
    {
        var path = PathFor(gameDir);
        if (!File.Exists(path))
        {
            Logger.Info($"No install manifest at {path}.");
            return null;
        }
        try
        {
            var json = File.ReadAllText(path);
            return Parse(json);
        }
        catch (Exception ex)
        {
            Logger.Warn($"Could not read install manifest at {path}: {ex.Message}");
            return null;
        }
    }

    public static InstallManifest Parse(string json)
    {
        var root = JsonNode.Parse(json) as JsonObject
            ?? throw new InvalidDataException("Install manifest root is not a JSON object.");

        var manifest = new InstallManifest
        {
            SchemaVersion = (int?)root["schema_version"] ?? 1,
            ModVersion = (string?)root["mod_version"] ?? "",
            InstalledAt = ParseUtc((string?)root["installed_at"]) ?? DateTime.UtcNow,
        };

        var profileRaw = (string?)root["profile"];
        manifest.Profile = InstallProfileExtensions.Parse(profileRaw)
            ?? throw new InvalidDataException(
                $"Install manifest has invalid or missing 'profile' field: '{profileRaw}'.");

        if (root["components"] is JsonObject comps)
        {
            foreach (var kv in comps)
            {
                if (kv.Value is not JsonObject obj) continue;
                manifest.Components[kv.Key] = new ComponentRecord
                {
                    Version = (string?)obj["version"] ?? "",
                    Sha256 = (string?)obj["sha256"],
                };
            }
        }

        if (root["backups"] is JsonObject backups)
        {
            foreach (var kv in backups)
            {
                if (kv.Value is JsonValue v && v.TryGetValue<string>(out var s))
                {
                    manifest.Backups[kv.Key] = s;
                }
            }
        }

        return manifest;
    }

    private static DateTime? ParseUtc(string? s)
    {
        if (string.IsNullOrWhiteSpace(s)) return null;
        return DateTime.TryParse(
            s, System.Globalization.CultureInfo.InvariantCulture,
            System.Globalization.DateTimeStyles.AssumeUniversal | System.Globalization.DateTimeStyles.AdjustToUniversal,
            out var dt) ? dt : null;
    }

    public void Write(string gameDir)
    {
        var path = PathFor(gameDir);
        var dir = Path.GetDirectoryName(path)!;
        Directory.CreateDirectory(dir);

        var components = new JsonObject();
        foreach (var kv in Components)
        {
            var rec = new JsonObject
            {
                ["version"] = kv.Value.Version,
            };
            if (!string.IsNullOrWhiteSpace(kv.Value.Sha256))
            {
                rec["sha256"] = kv.Value.Sha256;
            }
            components[kv.Key] = rec;
        }

        var backups = new JsonObject();
        foreach (var kv in Backups)
        {
            backups[kv.Key] = kv.Value;
        }

        var root = new JsonObject
        {
            ["schema_version"] = SchemaVersion,
            ["mod_version"]    = ModVersion,
            ["profile"]        = Profile.ToManifestString(),
            ["installed_at"]   = InstalledAt.ToString("yyyy-MM-ddTHH:mm:ssZ"),
            ["components"]     = components,
            ["backups"]        = backups,
        };

        var opts = new JsonSerializerOptions { WriteIndented = true };
        File.WriteAllText(path, root.ToJsonString(opts));
        Logger.Info($"Wrote install manifest to {path}.");
    }
}

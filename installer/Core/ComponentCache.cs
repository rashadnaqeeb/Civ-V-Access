using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Persistent, content-addressed cache of downloaded component zips, under
/// LocalAppData. A component is fetched over the network only when its digest
/// is not already in the cache, so each state's heavy payload downloads once
/// ever and switching back to a previously-used state is offline. Files are
/// named by their verified SHA-256, so a cache hit is a verified-complete file
/// (the hash is checked before the temp download is committed). The cache is
/// never auto-pruned; full uninstall clears it.
/// </summary>
internal sealed class ComponentCache
{
    private readonly string _root;
    private readonly string _tmpDir;
    private readonly string _indexPath;

    public ComponentCache()
    {
        _root = DefaultRoot();
        _tmpDir = Path.Combine(_root, "tmp");
        _indexPath = Path.Combine(_root, "index.json");
        Directory.CreateDirectory(_root);
        Directory.CreateDirectory(_tmpDir);
    }

    public static string DefaultRoot() => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "CivVAccess", "Installer", "Cache");

    /// <summary>Cache path for a digest. Does not check existence.</summary>
    public string PathForDigest(string sha256) =>
        Path.Combine(_root, sha256.ToLowerInvariant() + ".zip");

    /// <summary>
    /// True if a verified zip with this digest is already cached. Always false
    /// for a null digest (the GitHub API didn't supply one), forcing a fresh
    /// download in that rare case.
    /// </summary>
    public bool Has(string? sha256) =>
        !string.IsNullOrWhiteSpace(sha256) && File.Exists(PathForDigest(sha256));

    /// <summary>A unique temp path for an in-progress download.</summary>
    public string NewTempPath(string assetName) =>
        Path.Combine(_tmpDir, $"{Guid.NewGuid():N}-{assetName}");

    /// <summary>
    /// Atomically move a verified temp download into the cache under its
    /// digest, and record it in the index. Overwrites any pre-existing file
    /// for the digest (identical content by definition).
    /// </summary>
    public void Commit(string tempPath, string sha256, ComponentKind kind, string version, long size)
    {
        var dest = PathForDigest(sha256);
        if (File.Exists(dest))
        {
            File.Delete(tempPath);
        }
        else
        {
            File.Move(tempPath, dest);
        }
        RecordIndex(kind, version, sha256, size);
        Logger.Info($"Cached {kind} {version} ({sha256.Substring(0, Math.Min(12, sha256.Length))}).");
    }

    /// <summary>Delete the entire cache. Called by full uninstall.</summary>
    public static void ClearAll()
    {
        var root = DefaultRoot();
        if (!Directory.Exists(root)) return;
        try
        {
            Directory.Delete(root, recursive: true);
            Logger.Info($"Cleared component cache: {root}");
        }
        catch (Exception ex)
        {
            Logger.Warn($"Could not clear component cache {root}: {ex.Message}");
        }
    }

    // ------------------------------------------------------------------
    // Index (auxiliary: transparency / debugging; correctness rests on the
    // digest-named files, not on this file).
    // ------------------------------------------------------------------

    private void RecordIndex(ComponentKind kind, string version, string sha256, long size)
    {
        try
        {
            var arr = ReadIndexArray();
            // Drop any prior entry for the same digest, then add the fresh one.
            var kept = new JsonArray();
            foreach (var node in arr)
            {
                if (node is JsonObject o && (string?)o["sha256"] == sha256) continue;
                kept.Add(node?.DeepClone());
            }
            kept.Add(new JsonObject
            {
                ["kind"]    = kind.ManifestKey(),
                ["version"] = version,
                ["sha256"]  = sha256,
                ["size"]    = size,
            });
            File.WriteAllText(_indexPath, kept.ToJsonString(new JsonSerializerOptions { WriteIndented = true }));
        }
        catch (Exception ex)
        {
            Logger.Warn($"Could not update cache index: {ex.Message}");
        }
    }

    private JsonArray ReadIndexArray()
    {
        if (!File.Exists(_indexPath)) return new JsonArray();
        try
        {
            return JsonNode.Parse(File.ReadAllText(_indexPath)) as JsonArray ?? new JsonArray();
        }
        catch
        {
            return new JsonArray();
        }
    }
}

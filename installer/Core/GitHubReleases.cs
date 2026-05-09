using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Text.Json.Nodes;
using System.Threading;
using System.Threading.Tasks;

namespace CivVAccess.Installer.Core;

/// <summary>
/// GitHub Releases client. v1 hits the public REST endpoint unauthenticated
/// (60 req/hr/IP, plenty for an installer). User-Agent header is required by
/// the API; without it the server returns 403.
/// </summary>
internal sealed class GitHubReleases : IDisposable
{
    private const string Owner = "rashadnaqeeb";
    private const string Repo = "Civ-V-Access";

    private readonly HttpClient _http;

    public GitHubReleases()
    {
        var handler = new HttpClientHandler
        {
            AutomaticDecompression = System.Net.DecompressionMethods.All,
        };
        _http = new HttpClient(handler);
        _http.DefaultRequestHeaders.UserAgent.ParseAdd($"CivVAccessInstaller/{AppVersion.Display}");
        _http.DefaultRequestHeaders.Accept.ParseAdd("application/vnd.github+json");
        _http.DefaultRequestHeaders.Add("X-GitHub-Api-Version", "2022-11-28");
        _http.Timeout = TimeSpan.FromMinutes(10);
    }

    public sealed record Asset(
        string Name,
        long Size,
        string DownloadUrl,
        string? DigestSha256, // hex, lowercased; null if API didn't compute one
        ComponentKind? Kind,
        string? Version);

    public sealed record Release(
        string TagName,
        Version SemVer,
        string Body,
        IReadOnlyList<Asset> Assets);

    public async Task<Release> GetLatestAsync(CancellationToken ct)
    {
        var url = $"https://api.github.com/repos/{Owner}/{Repo}/releases/latest";
        Logger.Info($"GET {url}");
        var json = await _http.GetStringAsync(url, ct).ConfigureAwait(false);
        return ParseRelease(json);
    }

    internal static Release ParseRelease(string json)
    {
        var root = JsonNode.Parse(json) as JsonObject
            ?? throw new InvalidDataException("GitHub release response is not a JSON object.");

        var tag = (string?)root["tag_name"]
            ?? throw new InvalidDataException("Release JSON has no tag_name.");
        var semver = ParseTagSemver(tag);
        var body = (string?)root["body"] ?? "";

        var assets = new List<Asset>();
        if (root["assets"] is JsonArray arr)
        {
            foreach (var a in arr)
            {
                if (a is not JsonObject obj) continue;
                var name = (string?)obj["name"] ?? "";
                var size = (long?)obj["size"] ?? 0;
                var downloadUrl = (string?)obj["browser_download_url"] ?? "";
                var digest = (string?)obj["digest"];
                var sha256 = ExtractSha256(digest);

                var parsed = AssetMap.Parse(name);
                assets.Add(new Asset(
                    name,
                    size,
                    downloadUrl,
                    sha256,
                    parsed?.Kind,
                    parsed?.Version));
            }
        }

        return new Release(tag, semver, body, assets);
    }

    private static Version ParseTagSemver(string tag)
    {
        // Tag is "vX.Y.Z" per RELEASING.md. Tolerate a missing "v".
        var s = tag.StartsWith("v", StringComparison.OrdinalIgnoreCase) ? tag.Substring(1) : tag;
        if (!Version.TryParse(s, out var v))
        {
            throw new InvalidDataException($"Release tag is not semver-shaped: {tag}");
        }
        return v;
    }

    private static string? ExtractSha256(string? digest)
    {
        if (string.IsNullOrWhiteSpace(digest)) return null;
        // Format per GitHub's API: "sha256:<lowercase-hex>". Be defensive
        // about case and whitespace; future algorithms (sha512, blake3, ...)
        // are silently ignored — we want sha256 specifically.
        var idx = digest.IndexOf(':');
        if (idx <= 0) return null;
        var algo = digest.Substring(0, idx).Trim().ToLowerInvariant();
        if (algo != "sha256") return null;
        return digest.Substring(idx + 1).Trim().ToLowerInvariant();
    }

    /// <summary>
    /// Fetch the repo's CHANGELOG.md from the main branch. Used to render
    /// the slice between the installed version and the new one. Authoritative
    /// source is the repo, not the release body, so the latest changelog text
    /// applies to whichever release the player is moving to.
    /// </summary>
    public async Task<string> GetChangelogAsync(CancellationToken ct)
    {
        var url = $"https://raw.githubusercontent.com/{Owner}/{Repo}/main/CHANGELOG.md";
        Logger.Info($"GET {url}");
        return await _http.GetStringAsync(url, ct).ConfigureAwait(false);
    }

    /// <summary>
    /// Download a release asset to a local file with byte-progress reporting.
    /// Caller is responsible for hashing and verifying afterwards.
    /// </summary>
    public async Task DownloadAssetAsync(
        Asset asset,
        string destinationPath,
        IProgress<long> bytesProgress,
        CancellationToken ct)
    {
        Logger.Info($"GET {asset.DownloadUrl} -> {destinationPath}");
        using var resp = await _http.GetAsync(asset.DownloadUrl, HttpCompletionOption.ResponseHeadersRead, ct)
            .ConfigureAwait(false);
        resp.EnsureSuccessStatusCode();

        Directory.CreateDirectory(Path.GetDirectoryName(destinationPath)!);
        using var src = await resp.Content.ReadAsStreamAsync(ct).ConfigureAwait(false);
        using var dst = new FileStream(destinationPath, FileMode.Create, FileAccess.Write, FileShare.None,
            bufferSize: 81920, useAsync: true);

        var buf = new byte[81920];
        long total = 0;
        int read;
        while ((read = await src.ReadAsync(buf.AsMemory(), ct).ConfigureAwait(false)) > 0)
        {
            await dst.WriteAsync(buf.AsMemory(0, read), ct).ConfigureAwait(false);
            total += read;
            bytesProgress.Report(total);
        }
    }

    public void Dispose() => _http.Dispose();
}

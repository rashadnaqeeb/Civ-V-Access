using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Parses CHANGELOG.md per RELEASING.md's contract: each entry header is
/// "## [X.Y.Z] - YYYY-MM-DD" on its own line. The Unreleased section is
/// skipped. Returns the concatenated body of versions strictly greater than
/// the player's installed version, up to and including the latest.
/// </summary>
internal static class ChangelogParser
{
    private static readonly Regex VersionHeader = new(
        @"^##\s+\[(?<ver>\d+\.\d+\.\d+)\]\s*-\s*\d{4}-\d{2}-\d{2}\s*$",
        RegexOptions.Compiled | RegexOptions.Multiline);

    private static readonly Regex UnreleasedHeader = new(
        @"^##\s+\[Unreleased\]\s*$",
        RegexOptions.Compiled | RegexOptions.Multiline | RegexOptions.IgnoreCase);

    public sealed record Entry(string Version, string Body);

    /// <summary>
    /// Walk the changelog and return entries (newest-first) for versions
    /// matching <paramref name="filter"/>. Filter receives a parsed Version
    /// and returns true if the entry should be included.
    /// </summary>
    public static List<Entry> ParseEntries(string markdown, Func<Version, bool> filter)
    {
        var entries = new List<Entry>();
        var matches = VersionHeader.Matches(markdown);
        for (int i = 0; i < matches.Count; i++)
        {
            var m = matches[i];
            var verStr = m.Groups["ver"].Value;
            if (!Version.TryParse(verStr, out var v)) continue;
            if (!filter(v)) continue;

            int bodyStart = m.Index + m.Length;
            int bodyEnd = i + 1 < matches.Count ? matches[i + 1].Index : markdown.Length;

            // If the next match is preceded by an Unreleased header, that's
            // already after this entry's body too — but we don't include the
            // Unreleased header itself. Trim any trailing whitespace.
            var body = markdown.Substring(bodyStart, bodyEnd - bodyStart).Trim('\r', '\n', ' ', '\t');
            entries.Add(new Entry(verStr, body));
        }
        return entries;
    }

    /// <summary>
    /// Concatenate entries strictly between (installed, latest], newest-first
    /// with version sub-headings. Handles fresh installs (installed == null)
    /// by returning only the latest entry. Returns empty string if no entries
    /// are in scope.
    /// </summary>
    public static string Slice(string markdown, Version? installed, Version latest)
    {
        var matching = ParseEntries(markdown, v =>
        {
            if (v > latest) return false;
            if (installed == null) return v == latest;
            return v > installed;
        });

        if (matching.Count == 0) return string.Empty;

        var sb = new StringBuilder();
        foreach (var e in matching)
        {
            if (sb.Length > 0) sb.AppendLine().AppendLine();
            sb.AppendLine($"## [{e.Version}]");
            sb.AppendLine();
            sb.Append(e.Body);
        }
        return sb.ToString();
    }
}

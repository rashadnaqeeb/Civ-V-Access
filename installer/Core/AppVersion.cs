using System;
using System.Reflection;

namespace CivVAccess.Installer.Core;

/// <summary>
/// The installer's own version. Independent of the mod's VERSION.
/// </summary>
internal static class AppVersion
{
    /// <summary>
    /// Highest mod-release major version this installer can install.
    /// If a fetched release's major exceeds this, the installer refuses
    /// and tells the user to download a newer installer.
    /// </summary>
    public const int SupportedMaxModMajor = 1;

    /// <summary>
    /// Schema version this installer writes into CivVAccess.install.json.
    /// On read, an absent schema_version is treated as 1.
    /// </summary>
    public const int InstallManifestSchemaVersion = 1;

    public static Version Self { get; } =
        Assembly.GetExecutingAssembly().GetName().Version ?? new Version(0, 0, 0, 0);

    public static string Display => $"{Self.Major}.{Self.Minor}.{Self.Build}";
}

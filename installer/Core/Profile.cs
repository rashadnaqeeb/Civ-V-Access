namespace CivVAccess.Installer.Core;

/// <summary>
/// Functional install profile, matching the manifest's "profile" field.
/// "blind" gets the full mod; "sighted" gets the multiplayer-compatibility
/// minimum. Persisted in CivVAccess.install.json so the question is asked
/// once and never re-asked while the manifest is intact.
/// </summary>
internal enum InstallProfile
{
    Blind,
    Sighted,
}

internal static class InstallProfileExtensions
{
    public static string ToManifestString(this InstallProfile profile) =>
        profile == InstallProfile.Blind ? "blind" : "sighted";

    public static InstallProfile? Parse(string? raw) => raw switch
    {
        "blind"   => InstallProfile.Blind,
        "sighted" => InstallProfile.Sighted,
        _         => null,
    };
}

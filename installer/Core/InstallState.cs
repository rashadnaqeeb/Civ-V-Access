namespace CivVAccess.Installer.Core;

/// <summary>
/// The game state an install targets. Mutually exclusive: an install is in
/// exactly one of these, and switching is a deliberate teardown-then-apply.
/// Vanilla is plain BNW; the three mod states layer a community DLL.
///
/// Maps to the manifest's "variant" field, staying compatible with what the
/// dev deploy scripts write (absent = vanilla, "modpack" = Vox Populi modpack,
/// "modpack-cp" = Community-Patch-only modpack, "lekmod" = LekMod).
/// </summary>
internal enum InstallState
{
    /// <summary>Plain Brave New World plus the accessibility layer.</summary>
    Vanilla,

    /// <summary>Community Patch plus the Vox Populi balance overhaul (baked modpack).</summary>
    VoxPopuli,

    /// <summary>Community Patch only, no Vox Populi balance (baked modpack).</summary>
    CommunityPatch,

    /// <summary>LekMod (prebaked DLC overlay).</summary>
    LekMod,
}

internal static class InstallStateExtensions
{
    /// <summary>
    /// Value written to the manifest's "variant" field. Vanilla writes no
    /// variant (returns null), matching deploy.ps1.
    /// </summary>
    public static string? ToManifestVariant(this InstallState state) => state switch
    {
        InstallState.Vanilla        => null,
        InstallState.VoxPopuli      => "modpack",
        InstallState.CommunityPatch => "modpack-cp",
        InstallState.LekMod         => "lekmod",
        _ => throw new System.ArgumentOutOfRangeException(nameof(state)),
    };

    /// <summary>
    /// Parse the manifest's "variant" field into a state. Absent or empty is
    /// vanilla. The maintainer-only mod-overlay variant "vp" maps to VoxPopuli
    /// (best effort; the installer itself only ever writes "modpack"). An
    /// unrecognized value maps to Vanilla so cleanup at least removes the known
    /// vanilla footprint rather than throwing.
    /// </summary>
    public static InstallState ParseVariant(string? raw)
    {
        switch ((raw ?? "").Trim().ToLowerInvariant())
        {
            case "":
            case "vanilla":    return InstallState.Vanilla;
            case "modpack":
            case "vp":         return InstallState.VoxPopuli;
            case "modpack-cp": return InstallState.CommunityPatch;
            case "lekmod":     return InstallState.LekMod;
            default:
                // An unrecognized variant (newer installer's manifest, or a hand
                // edit) is treated as vanilla, but say so: the teardown of the
                // actual on-disk state may then be incomplete.
                Logger.Warn(
                    $"Unrecognized install manifest variant '{raw}'; treating as vanilla. " +
                    "Reinstall or uninstall to fully reset the install state.");
                return InstallState.Vanilla;
        }
    }

    /// <summary>Localization key for the state's display name.</summary>
    public static string NameKey(this InstallState state) => "state." + state switch
    {
        InstallState.Vanilla        => "vanilla",
        InstallState.VoxPopuli      => "voxPopuli",
        InstallState.CommunityPatch => "communityPatch",
        InstallState.LekMod         => "lekmod",
        _ => throw new System.ArgumentOutOfRangeException(nameof(state)),
    };

    /// <summary>Localization key for the state's one-line description.</summary>
    public static string DescKey(this InstallState state) => state.NameKey() + "Desc";
}

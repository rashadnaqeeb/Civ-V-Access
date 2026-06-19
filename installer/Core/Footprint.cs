using System;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Removable artifacts an install state leaves in the game tree. A state flip
/// tears down every artifact the current (state, profile) placed that the
/// target does not, then applies the target's components. Modeling the
/// transition as set difference over these flags keeps the cleanup correct
/// without an N-by-N matrix: see docs/llm-docs/installer-states.md.
///
/// Not included here: the Expansion2 engine DLL and the cinematics, which are
/// never torn down between states (every state wants the same vanilla fork and
/// the intros are harmless); the DLC_CivVAccess payload, which is always
/// nuke-and-re-extracted on apply. Those are handled by the apply flow and by
/// full uninstall, not by transition teardown.
/// </summary>
[Flags]
internal enum ModArtifact
{
    None        = 0,

    /// <summary>The proxy stack (our lua51 + the renamed stock + Tolk DLLs). Blind states only.</summary>
    Proxy       = 1 << 0,

    /// <summary>The baked Vox Populi modpack package at Assets/DLC/ZCivVAccessVP.</summary>
    ModpackVp   = 1 << 1,

    /// <summary>The baked Community-Patch-only modpack package at Assets/DLC/ZCivVAccessCP.</summary>
    ModpackCp   = 1 << 2,

    /// <summary>The Vox Populi substrate: VPUI DLC, swapped Expansion2.Civ5Pkg, minor-civ sounds, tips.</summary>
    VpSubstrate = 1 << 3,

    /// <summary>LekMod's prebaked DLC at Assets/DLC/LEKMOD*.</summary>
    LekmodDlc   = 1 << 4,

    /// <summary>Every removable artifact; the worst-case current footprint when none is known.</summary>
    All = Proxy | ModpackVp | ModpackCp | VpSubstrate | LekmodDlc,
}

internal static class Footprint
{
    /// <summary>
    /// The removable artifacts a given (state, profile) places. The proxy is
    /// present for every blind profile and absent for every sighted one; the
    /// mod artifacts follow the state.
    /// </summary>
    public static ModArtifact For(InstallState state, InstallProfile profile)
    {
        var f = ModArtifact.None;
        if (profile == InstallProfile.Blind)
        {
            f |= ModArtifact.Proxy;
        }

        switch (state)
        {
            case InstallState.Vanilla:
                break;
            case InstallState.VoxPopuli:
                f |= ModArtifact.ModpackVp | ModArtifact.VpSubstrate;
                break;
            case InstallState.CommunityPatch:
                f |= ModArtifact.ModpackCp;
                break;
            case InstallState.LekMod:
                f |= ModArtifact.LekmodDlc;
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(state));
        }
        return f;
    }
}

internal static class TransitionPlanner
{
    /// <summary>
    /// Artifacts to tear down when flipping from (currentState, currentProfile)
    /// to (targetState, targetProfile): everything in the current footprint
    /// that the target footprint does not also place. Returns None when the
    /// target is a superset of the current (nothing to remove first).
    /// </summary>
    public static ModArtifact ArtifactsToTearDown(
        InstallState currentState, InstallProfile currentProfile,
        InstallState targetState, InstallProfile targetProfile)
    {
        var current = Footprint.For(currentState, currentProfile);
        var target = Footprint.For(targetState, targetProfile);
        return current & ~target;
    }

    /// <summary>
    /// Artifacts to tear down for a fresh install with no prior manifest. The
    /// current footprint is unknown, so assume the worst case (everything) and
    /// keep what the target wants. This removes strays from a crashed/older
    /// install and any foreign mod state that would collide with the target.
    /// </summary>
    public static ModArtifact ArtifactsToTearDownFromUnknown(
        InstallState targetState, InstallProfile targetProfile) =>
        ModArtifact.All & ~Footprint.For(targetState, targetProfile);

    /// <summary>
    /// Everything an uninstall must remove from a given install: its full
    /// footprint. Uninstall additionally restores the engine DLL and cinematics
    /// and clears the cache, which are not artifact flags.
    /// </summary>
    public static ModArtifact ArtifactsForUninstall(InstallState state, InstallProfile profile) =>
        Footprint.For(state, profile);
}

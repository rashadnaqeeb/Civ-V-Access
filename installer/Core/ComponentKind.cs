using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace CivVAccess.Installer.Core;

/// <summary>
/// The release components, matching package-release.ps1 zip names. Asset
/// filename convention is "&lt;component&gt;-&lt;version&gt;.zip"; the parser
/// here is what maps a release asset to a known kind. The first five are the
/// vanilla set; the rest are the mod-state components (overlays, baked
/// modpack packages, the VP substrate, the LekMod DLC tree).
/// </summary>
internal enum ComponentKind
{
    CoreBlind,
    CoreSighted,
    Engine,
    Runtime,
    Cinematics,
    VpOverlay,
    CpOverlay,
    LekmodOverlay,
    VpModpack,
    CpModpack,
    VpRuntime,
    LekmodDlc,
}

internal static class ComponentKindExtensions
{
    public static string AssetPrefix(this ComponentKind kind) => kind switch
    {
        ComponentKind.CoreBlind     => "core-blind",
        ComponentKind.CoreSighted   => "core-sighted",
        ComponentKind.Engine        => "engine",
        ComponentKind.Runtime       => "runtime",
        ComponentKind.Cinematics    => "cinematics",
        ComponentKind.VpOverlay     => "vp-overlay",
        ComponentKind.CpOverlay     => "cp-overlay",
        ComponentKind.LekmodOverlay => "lekmod-overlay",
        ComponentKind.VpModpack     => "vp-modpack",
        ComponentKind.CpModpack     => "cp-modpack",
        ComponentKind.VpRuntime     => "vp-runtime",
        ComponentKind.LekmodDlc     => "lekmod-dlc",
        _ => throw new ArgumentOutOfRangeException(nameof(kind)),
    };

    /// <summary>
    /// Manifest "components" key. Mirrors the deploy scripts' keys for the
    /// shared components ("core" for the blind payload, "core_sighted" for the
    /// sighted stub); the mod-state keys are installer-defined.
    /// </summary>
    public static string ManifestKey(this ComponentKind kind) => kind switch
    {
        ComponentKind.CoreBlind     => "core",
        ComponentKind.CoreSighted   => "core_sighted",
        ComponentKind.Engine        => "engine",
        ComponentKind.Runtime       => "runtime",
        ComponentKind.Cinematics    => "cinematics",
        ComponentKind.VpOverlay     => "vp_overlay",
        ComponentKind.CpOverlay     => "cp_overlay",
        ComponentKind.LekmodOverlay => "lekmod_overlay",
        ComponentKind.VpModpack     => "vp_modpack",
        ComponentKind.CpModpack     => "cp_modpack",
        ComponentKind.VpRuntime     => "vp_runtime",
        ComponentKind.LekmodDlc     => "lekmod_dlc",
        _ => throw new ArgumentOutOfRangeException(nameof(kind)),
    };

    public static string DisplayName(this ComponentKind kind) =>
        Localization.Strings.Get("component." + kind switch
        {
            ComponentKind.CoreBlind     => "coreBlind",
            ComponentKind.CoreSighted   => "coreSighted",
            ComponentKind.Engine        => "engine",
            ComponentKind.Runtime       => "runtime",
            ComponentKind.Cinematics    => "cinematics",
            ComponentKind.VpOverlay     => "vpOverlay",
            ComponentKind.CpOverlay     => "cpOverlay",
            ComponentKind.LekmodOverlay => "lekmodOverlay",
            ComponentKind.VpModpack     => "vpModpack",
            ComponentKind.CpModpack     => "cpModpack",
            ComponentKind.VpRuntime     => "vpRuntime",
            ComponentKind.LekmodDlc     => "lekmodDlc",
            _ => throw new ArgumentOutOfRangeException(nameof(kind)),
        });
}

/// <summary>
/// Components needed for each (state, profile). The blind profile gets the full
/// payload for the state; the sighted profile gets the multiplayer-match
/// minimum: the empty-UI core stub plus whatever the host loads as gameplay
/// content (the engine fork for vanilla, the baked package or LekMod tree for
/// the mod states, plus the VP substrate for Vox Populi). See
/// docs/llm-docs/installer-states.md for the authoritative matrix.
/// </summary>
internal static class ComponentSet
{
    public static IReadOnlyList<ComponentKind> For(InstallState state, InstallProfile profile) =>
        profile == InstallProfile.Blind ? Blind(state) : Sighted(state);

    private static IReadOnlyList<ComponentKind> Blind(InstallState state) => state switch
    {
        InstallState.Vanilla => new[]
        {
            ComponentKind.CoreBlind,
            ComponentKind.Runtime,
            ComponentKind.Engine,
            ComponentKind.Cinematics,
        },
        InstallState.VoxPopuli => new[]
        {
            ComponentKind.CoreBlind,
            ComponentKind.Runtime,
            ComponentKind.Cinematics,
            ComponentKind.VpOverlay,
            ComponentKind.VpModpack,
            ComponentKind.VpRuntime,
        },
        InstallState.CommunityPatch => new[]
        {
            ComponentKind.CoreBlind,
            ComponentKind.Runtime,
            ComponentKind.Cinematics,
            ComponentKind.CpOverlay,
            ComponentKind.CpModpack,
        },
        InstallState.LekMod => new[]
        {
            ComponentKind.CoreBlind,
            ComponentKind.Runtime,
            ComponentKind.Cinematics,
            ComponentKind.LekmodOverlay,
            ComponentKind.LekmodDlc,
        },
        _ => throw new ArgumentOutOfRangeException(nameof(state)),
    };

    private static IReadOnlyList<ComponentKind> Sighted(InstallState state) => state switch
    {
        InstallState.Vanilla => new[]
        {
            ComponentKind.CoreSighted,
            ComponentKind.Engine,
        },
        InstallState.VoxPopuli => new[]
        {
            ComponentKind.CoreSighted,
            ComponentKind.VpModpack,
            ComponentKind.VpRuntime,
        },
        InstallState.CommunityPatch => new[]
        {
            ComponentKind.CoreSighted,
            ComponentKind.CpModpack,
        },
        InstallState.LekMod => new[]
        {
            ComponentKind.CoreSighted,
            ComponentKind.LekmodDlc,
        },
        _ => throw new ArgumentOutOfRangeException(nameof(state)),
    };
}

internal static class AssetMap
{
    private static readonly Dictionary<string, ComponentKind> ByPrefix =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ["core-blind"]     = ComponentKind.CoreBlind,
            ["core-sighted"]   = ComponentKind.CoreSighted,
            ["engine"]         = ComponentKind.Engine,
            ["runtime"]        = ComponentKind.Runtime,
            ["cinematics"]     = ComponentKind.Cinematics,
            ["vp-overlay"]     = ComponentKind.VpOverlay,
            ["cp-overlay"]     = ComponentKind.CpOverlay,
            ["lekmod-overlay"] = ComponentKind.LekmodOverlay,
            ["vp-modpack"]     = ComponentKind.VpModpack,
            ["cp-modpack"]     = ComponentKind.CpModpack,
            ["vp-runtime"]     = ComponentKind.VpRuntime,
            ["lekmod-dlc"]     = ComponentKind.LekmodDlc,
        };

    /// <summary>
    /// Parse a release asset filename into (kind, version) per the
    /// "&lt;component&gt;-&lt;X.Y.Z&gt;.zip" convention enforced by
    /// package-release.ps1. Returns null for files that don't match (e.g.,
    /// SHA256SUMS, or any future non-zip asset).
    /// </summary>
    public static (ComponentKind Kind, string Version)? Parse(string assetName)
    {
        // Anchored: prefix-XX.YY.ZZ.zip exactly. Component prefixes may contain
        // hyphens ("core-blind", "vp-modpack"); the version regex anchors the
        // split, so the lazy prefix capture stops at the version's leading dash.
        var m = Regex.Match(assetName,
            @"^(?<prefix>[A-Za-z][A-Za-z0-9_-]*?)-(?<ver>\d+\.\d+\.\d+)\.zip$",
            RegexOptions.IgnoreCase);
        if (!m.Success) return null;

        var prefix = m.Groups["prefix"].Value.ToLowerInvariant();
        var version = m.Groups["ver"].Value;

        return ByPrefix.TryGetValue(prefix, out var kind) ? (kind, version) : null;
    }
}

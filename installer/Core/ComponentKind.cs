using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace CivVAccess.Installer.Core;

/// <summary>
/// The five release components, matching package-release.ps1 zip names.
/// Asset filename convention is "&lt;component&gt;-&lt;version&gt;.zip"; the parser
/// here is what maps a release asset to a known kind.
/// </summary>
internal enum ComponentKind
{
    CoreBlind,
    CoreSighted,
    Engine,
    Runtime,
    Cinematics,
}

internal static class ComponentKindExtensions
{
    public static string AssetPrefix(this ComponentKind kind) => kind switch
    {
        ComponentKind.CoreBlind   => "core-blind",
        ComponentKind.CoreSighted => "core-sighted",
        ComponentKind.Engine      => "engine",
        ComponentKind.Runtime     => "runtime",
        ComponentKind.Cinematics  => "cinematics",
        _ => throw new ArgumentOutOfRangeException(nameof(kind)),
    };

    /// <summary>
    /// Manifest "components" key. The deploy scripts use "core" for the blind
    /// payload and have no entry for the sighted one; we mirror that for the
    /// blind profile and add "core_sighted" only on the sighted profile so the
    /// installer can update-skip.
    /// </summary>
    public static string ManifestKey(this ComponentKind kind) => kind switch
    {
        ComponentKind.CoreBlind   => "core",
        ComponentKind.CoreSighted => "core_sighted",
        ComponentKind.Engine      => "engine",
        ComponentKind.Runtime     => "runtime",
        ComponentKind.Cinematics  => "cinematics",
        _ => throw new ArgumentOutOfRangeException(nameof(kind)),
    };

    public static string DisplayName(this ComponentKind kind) =>
        Localization.Strings.Get("component." + kind switch
        {
            ComponentKind.CoreBlind   => "coreBlind",
            ComponentKind.CoreSighted => "coreSighted",
            ComponentKind.Engine      => "engine",
            ComponentKind.Runtime     => "runtime",
            ComponentKind.Cinematics  => "cinematics",
            _ => throw new ArgumentOutOfRangeException(nameof(kind)),
        });
}

/// <summary>
/// Components needed for each profile. core-sighted is for sighted-MP partners;
/// it's the empty-UI manifest that establishes DLC presence without dragging
/// in mod code that would break a sighted user's game.
/// </summary>
internal static class ProfileComponents
{
    public static IReadOnlyList<ComponentKind> For(InstallProfile profile) => profile switch
    {
        InstallProfile.Blind => new[]
        {
            ComponentKind.CoreBlind,
            ComponentKind.Engine,
            ComponentKind.Runtime,
            ComponentKind.Cinematics,
        },
        InstallProfile.Sighted => new[]
        {
            ComponentKind.CoreSighted,
            ComponentKind.Engine,
        },
        _ => throw new ArgumentOutOfRangeException(nameof(profile)),
    };
}

internal static class AssetMap
{
    /// <summary>
    /// Parse a release asset filename into (kind, version) per the
    /// "&lt;component&gt;-&lt;X.Y.Z&gt;.zip" convention enforced by
    /// package-release.ps1. Returns null for files that don't match (e.g.,
    /// SHA256SUMS, or any future non-zip asset).
    /// </summary>
    public static (ComponentKind Kind, string Version)? Parse(string assetName)
    {
        // Anchored: prefix-XX.YY.ZZ.zip exactly. Component prefix may contain
        // a single hyphen ("core-blind", "core-sighted"); the version regex
        // anchors the split.
        var m = Regex.Match(assetName,
            @"^(?<prefix>[A-Za-z][A-Za-z0-9_-]*?)-(?<ver>\d+\.\d+\.\d+)\.zip$",
            RegexOptions.IgnoreCase);
        if (!m.Success) return null;

        var prefix = m.Groups["prefix"].Value.ToLowerInvariant();
        var version = m.Groups["ver"].Value;

        ComponentKind? kind = prefix switch
        {
            "core-blind"   => ComponentKind.CoreBlind,
            "core-sighted" => ComponentKind.CoreSighted,
            "engine"       => ComponentKind.Engine,
            "runtime"      => ComponentKind.Runtime,
            "cinematics"   => ComponentKind.Cinematics,
            _              => null,
        };
        if (kind == null) return null;
        return (kind.Value, version);
    }
}

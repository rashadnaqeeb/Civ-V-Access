using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text.Json;
using CivVAccess.Installer.Core;

namespace CivVAccess.Installer.Localization;

/// <summary>
/// JSON-backed string lookup. One JSON file per locale, embedded as a
/// resource at build time. Active locale is set once on launch from
/// CultureInfo.CurrentUICulture and may be changed via the Language menu.
/// Lookup is &lt;locale&gt; -&gt; en_US -&gt; key (so missing strings surface as
/// the key, never a silent empty rendering).
/// </summary>
internal static class Strings
{
    private static readonly Dictionary<string, Dictionary<string, string>> Loaded = new();
    private static Dictionary<string, string> _active = new();
    private static Dictionary<string, string> _fallback = new();
    private static string _activeCode = LocaleCatalog.Default;

    public static event Action? LocaleChanged;

    public static string ActiveCode => _activeCode;

    public static void SetLocale(string code)
    {
        if (!LocaleCatalog.IsSupported(code))
        {
            Logger.Warn($"Unsupported locale '{code}' requested; using {LocaleCatalog.Default}.");
            code = LocaleCatalog.Default;
        }

        _fallback = Load(LocaleCatalog.Default);
        _active = code == LocaleCatalog.Default ? _fallback : Load(code);
        _activeCode = code;
        LocaleChanged?.Invoke();
    }

    public static string Get(string key)
    {
        if (_active.TryGetValue(key, out var v)) return v;
        if (_fallback.TryGetValue(key, out var f)) return f;
        Logger.Warn($"Missing string key: {key}");
        return key;
    }

    public static string Format(string key, params object?[] args)
    {
        var template = Get(key);
        try
        {
            return string.Format(template, args);
        }
        catch (FormatException ex)
        {
            Logger.Warn($"Bad format string for key '{key}': {ex.Message}");
            return template;
        }
    }

    private static Dictionary<string, string> Load(string code)
    {
        if (Loaded.TryGetValue(code, out var cached)) return cached;

        var asm = Assembly.GetExecutingAssembly();
        var resourceName = $"CivVAccess.Installer.Localization.Resources.{code}.json";
        using var stream = asm.GetManifestResourceStream(resourceName);
        if (stream == null)
        {
            Logger.Warn($"Locale resource missing: {resourceName}. Falling back to en_US.");
            if (code == LocaleCatalog.Default)
            {
                throw new InvalidOperationException(
                    $"Default locale resource missing: {resourceName}. " +
                    "Build is broken; check Localization/Resources/ embedded files.");
            }
            return Load(LocaleCatalog.Default);
        }

        using var reader = new StreamReader(stream);
        var json = reader.ReadToEnd();
        var dict = JsonSerializer.Deserialize<Dictionary<string, string>>(json)
                   ?? new Dictionary<string, string>();
        Loaded[code] = dict;
        return dict;
    }
}

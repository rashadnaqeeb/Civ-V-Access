using System;
using System.Collections.Generic;
using System.Globalization;

namespace CivVAccess.Installer.Localization;

/// <summary>
/// The 10 locales the mod itself ships strings for. Codes match the mod's
/// CivVAccess_*Strings_&lt;locale&gt;.lua file naming.
/// </summary>
internal static class LocaleCatalog
{
    public const string Default = "en_US";

    public sealed record Entry(string Code, string DisplayName);

    public static readonly IReadOnlyList<Entry> All = new[]
    {
        new Entry("en_US",      "English"),
        new Entry("fr_FR",      "Français"),
        new Entry("de_DE",      "Deutsch"),
        new Entry("es_ES",      "Español"),
        new Entry("it_IT",      "Italiano"),
        new Entry("ja_JP",      "日本語"),
        new Entry("ko_KR",      "한국어"),
        new Entry("pl_PL",      "Polski"),
        new Entry("ru_RU",      "Русский"),
        new Entry("zh_Hant_HK", "繁體中文"),
    };

    /// <summary>
    /// Map a CultureInfo to one of our supported locale codes. Falls back to
    /// en_US for any culture we don't ship a translation for. Matching is by
    /// two-letter language code so any Spanish variant lands on es_ES, etc.
    /// </summary>
    public static string PickForCulture(CultureInfo culture)
    {
        var lang = culture.TwoLetterISOLanguageName.ToLowerInvariant();
        return lang switch
        {
            "en" => "en_US",
            "fr" => "fr_FR",
            "de" => "de_DE",
            "es" => "es_ES",
            "it" => "it_IT",
            "ja" => "ja_JP",
            "ko" => "ko_KR",
            "pl" => "pl_PL",
            "ru" => "ru_RU",
            "zh" => "zh_Hant_HK",
            _    => Default,
        };
    }

    public static bool IsSupported(string code)
    {
        foreach (var e in All)
        {
            if (string.Equals(e.Code, code, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }
        return false;
    }
}

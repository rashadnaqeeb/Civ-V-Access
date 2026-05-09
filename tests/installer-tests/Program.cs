using System;
using System.Linq;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccessInstaller.Tests;

internal static class Program
{
    private static int _passed;
    private static int _failed;

    private static int Main()
    {
        Run("AssetMap parses core-blind", () =>
        {
            var r = AssetMap.Parse("core-blind-1.0.0.zip");
            Assert(r != null && r.Value.Kind == ComponentKind.CoreBlind && r.Value.Version == "1.0.0");
        });
        Run("AssetMap parses core-sighted", () =>
        {
            var r = AssetMap.Parse("core-sighted-1.0.0.zip");
            Assert(r != null && r.Value.Kind == ComponentKind.CoreSighted && r.Value.Version == "1.0.0");
        });
        Run("AssetMap parses engine", () =>
        {
            var r = AssetMap.Parse("engine-2.3.4.zip");
            Assert(r != null && r.Value.Kind == ComponentKind.Engine && r.Value.Version == "2.3.4");
        });
        Run("AssetMap parses runtime", () =>
        {
            var r = AssetMap.Parse("runtime-1.0.0.zip");
            Assert(r != null && r.Value.Kind == ComponentKind.Runtime);
        });
        Run("AssetMap parses cinematics", () =>
        {
            var r = AssetMap.Parse("cinematics-10.20.30.zip");
            Assert(r != null && r.Value.Kind == ComponentKind.Cinematics && r.Value.Version == "10.20.30");
        });
        Run("AssetMap rejects SHA256SUMS", () =>
        {
            Assert(AssetMap.Parse("SHA256SUMS") == null);
        });
        Run("AssetMap rejects unknown prefix", () =>
        {
            Assert(AssetMap.Parse("strangething-1.0.0.zip") == null);
        });

        Run("ChangelogParser slices fresh install to latest only", () =>
        {
            var md = "# Changelog\n\n## [Unreleased]\n\n## [1.2.0] - 2026-06-01\n\nFeature B added.\n\n## [1.1.0] - 2026-05-15\n\nMidway entry.\n\n## [1.0.0] - 2026-05-09\n\nInitial release.\n";
            var slice = ChangelogParser.Slice(md, installed: null, latest: new Version("1.2.0"));
            Assert(slice.Contains("Feature B added"));
            Assert(!slice.Contains("Midway"));
            Assert(!slice.Contains("Initial release"));
        });
        Run("ChangelogParser slices update across multiple versions", () =>
        {
            var md = "## [1.2.0] - 2026-06-01\n\nFeature B added.\n\n## [1.1.0] - 2026-05-15\n\nMidway entry.\n\n## [1.0.0] - 2026-05-09\n\nInitial release.\n";
            var slice = ChangelogParser.Slice(md, installed: new Version("1.0.0"), latest: new Version("1.2.0"));
            Assert(slice.Contains("Feature B added"));
            Assert(slice.Contains("Midway entry"));
            Assert(!slice.Contains("Initial release"));
        });
        Run("ChangelogParser empty when up-to-date", () =>
        {
            var md = "## [1.0.0] - 2026-05-09\n\nInitial.\n";
            var slice = ChangelogParser.Slice(md, installed: new Version("1.0.0"), latest: new Version("1.0.0"));
            Assert(slice == "");
        });
        Run("ChangelogParser ignores Unreleased header", () =>
        {
            var md = "## [Unreleased]\n\nWIP item.\n\n## [1.0.0] - 2026-05-09\n\nInitial.\n";
            var slice = ChangelogParser.Slice(md, installed: null, latest: new Version("1.0.0"));
            Assert(slice.Contains("Initial"));
            Assert(!slice.Contains("WIP"));
        });

        Run("GitHubReleases parses sample JSON", () =>
        {
            var json = "{\"tag_name\": \"v1.0.0\", \"body\": \"hello\", \"assets\": [" +
                "{\"name\": \"core-blind-1.0.0.zip\", \"size\": 1234, \"browser_download_url\": \"https://example.com/cb.zip\", \"digest\": \"sha256:DEADBEEF\"}," +
                "{\"name\": \"engine-1.0.0.zip\", \"size\": 5678, \"browser_download_url\": \"https://example.com/e.zip\", \"digest\": \"sha512:NOPE\"}," +
                "{\"name\": \"SHA256SUMS\", \"size\": 100, \"browser_download_url\": \"https://example.com/s\", \"digest\": null}" +
                "]}";
            var r = GitHubReleases.ParseRelease(json);
            Assert(r.TagName == "v1.0.0");
            Assert(r.SemVer == new Version("1.0.0"));
            Assert(r.Assets.Count == 3);
            var cb = r.Assets.First(a => a.Name == "core-blind-1.0.0.zip");
            Assert(cb.Kind == ComponentKind.CoreBlind);
            Assert(cb.DigestSha256 == "deadbeef");
            var e = r.Assets.First(a => a.Name == "engine-1.0.0.zip");
            Assert(e.Kind == ComponentKind.Engine);
            Assert(e.DigestSha256 == null); // sha512 ignored
            var s = r.Assets.First(a => a.Name == "SHA256SUMS");
            Assert(s.Kind == null);
        });

        Run("InstallManifest round-trips", () =>
        {
            var json = "{\"schema_version\": 1, \"mod_version\": \"1.0.0\", \"profile\": \"blind\", \"installed_at\": \"2026-05-09T12:00:00Z\", \"components\": {\"core\": {\"version\": \"1.0.0\", \"sha256\": \"abc\"}, \"engine\": {\"version\": \"1.0.0\"}}, \"backups\": {\"engine_dll\": \"Assets/DLC/x.dll\"}}";
            var m = InstallManifest.Parse(json);
            Assert(m.ModVersion == "1.0.0");
            Assert(m.Profile == InstallProfile.Blind);
            Assert(m.Components["core"].Sha256 == "abc");
            Assert(m.Components["engine"].Sha256 == null);
            Assert(m.Backups["engine_dll"] == "Assets/DLC/x.dll");
        });

        Run("InstallManifest preserves heterogeneous component versions", () =>
        {
            // mod 1.5.0 release where engine stayed at 1.0.0 and core moved.
            var json = "{\"schema_version\": 1, \"mod_version\": \"1.5.0\", \"profile\": \"blind\", \"installed_at\": \"2026-06-01T00:00:00Z\", \"components\": {\"core\": {\"version\": \"1.5.0\", \"sha256\": \"aa\"}, \"engine\": {\"version\": \"1.0.0\", \"sha256\": \"bb\"}, \"runtime\": {\"version\": \"1.0.0\", \"sha256\": \"cc\"}, \"cinematics\": {\"version\": \"1.0.0\", \"sha256\": \"dd\"}}, \"backups\": {}}";
            var m = InstallManifest.Parse(json);
            Assert(m.ModVersion == "1.5.0");
            Assert(m.Components["core"].Version == "1.5.0");
            Assert(m.Components["engine"].Version == "1.0.0");
            Assert(m.Components["runtime"].Version == "1.0.0");
            Assert(m.Components["cinematics"].Version == "1.0.0");
        });

        Run("AssetMap parses asset version distinct from mod version", () =>
        {
            // Engine zip from a release whose mod is at 1.5.0 but engine stayed 1.0.0.
            var r = AssetMap.Parse("engine-1.0.0.zip");
            Assert(r != null && r.Value.Kind == ComponentKind.Engine && r.Value.Version == "1.0.0");
        });

        Run("GameConfigIni leaves enabled config alone", () =>
        {
            var input = new[] { "Foo = 1", "LoggingEnabled = 1", "Bar = 0" };
            var (output, action) = GameConfigIni.ApplyLoggingEnabled(input);
            Assert(action == ConfigUpdateResult.AlreadyEnabled);
            Assert(output.SequenceEqual(input));
        });

        Run("GameConfigIni flips disabled to 1", () =>
        {
            var input = new[] { "Foo = 1", "LoggingEnabled = 0", "Bar = 0" };
            var (output, action) = GameConfigIni.ApplyLoggingEnabled(input);
            Assert(action == ConfigUpdateResult.Enabled);
            Assert(output[1] == "LoggingEnabled = 1");
            Assert(output[0] == "Foo = 1" && output[2] == "Bar = 0");
        });

        Run("GameConfigIni appends key when missing", () =>
        {
            var input = new[] { "Foo = 1", "Bar = 0" };
            var (output, action) = GameConfigIni.ApplyLoggingEnabled(input);
            Assert(action == ConfigUpdateResult.Enabled);
            Assert(output.Length == 3);
            Assert(output[^1] == "LoggingEnabled = 1");
        });

        Run("GameConfigIni handles odd whitespace", () =>
        {
            var input = new[] { "  LoggingEnabled=0  " };
            var (output, action) = GameConfigIni.ApplyLoggingEnabled(input);
            Assert(action == ConfigUpdateResult.Enabled);
            // The "1" replaces the "0" with the surrounding pattern preserved.
            Assert(output[0].Contains("LoggingEnabled=1"));
        });

        Run("LocaleCatalog maps cultures", () =>
        {
            Assert(LocaleCatalog.PickForCulture(new System.Globalization.CultureInfo("en-GB")) == "en_US");
            Assert(LocaleCatalog.PickForCulture(new System.Globalization.CultureInfo("ja-JP")) == "ja_JP");
            Assert(LocaleCatalog.PickForCulture(new System.Globalization.CultureInfo("zh-TW")) == "zh_Hant_HK");
            Assert(LocaleCatalog.PickForCulture(new System.Globalization.CultureInfo("af-ZA")) == "en_US");
        });

        Run("Strings load and fallback", () =>
        {
            Logger.Init();
            Strings.SetLocale("en_US");
            Assert(!string.IsNullOrEmpty(Strings.Get("app.title")));
            Assert(Strings.Get("does.not.exist") == "does.not.exist");
        });

        Console.WriteLine();
        Console.WriteLine($"{_passed} passed, {_failed} failed.");
        return _failed == 0 ? 0 : 1;
    }

    private static void Run(string name, Action body)
    {
        try
        {
            body();
            _passed++;
            Console.WriteLine($"[ok]   {name}");
        }
        catch (Exception ex)
        {
            _failed++;
            Console.WriteLine($"[FAIL] {name}: {ex.Message}");
        }
    }

    private static void Assert(bool condition, string? message = null)
    {
        if (!condition)
        {
            throw new InvalidOperationException(message ?? "Assertion failed.");
        }
    }
}

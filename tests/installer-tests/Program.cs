using System;
using System.IO;
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

        // ----------------------------------------------------------------
        // Multi-state: AssetMap, ComponentSet, Footprint, transitions.
        // ----------------------------------------------------------------

        Run("AssetMap parses hyphenated mod-state prefixes", () =>
        {
            Assert(AssetMap.Parse("vp-overlay-1.2.3.zip")!.Value.Kind == ComponentKind.VpOverlay);
            Assert(AssetMap.Parse("cp-overlay-1.0.0.zip")!.Value.Kind == ComponentKind.CpOverlay);
            Assert(AssetMap.Parse("lekmod-overlay-1.0.0.zip")!.Value.Kind == ComponentKind.LekmodOverlay);
            Assert(AssetMap.Parse("vp-modpack-4.5.6.zip")!.Value.Kind == ComponentKind.VpModpack);
            Assert(AssetMap.Parse("cp-modpack-1.0.0.zip")!.Value.Kind == ComponentKind.CpModpack);
            Assert(AssetMap.Parse("vp-runtime-1.0.0.zip")!.Value.Kind == ComponentKind.VpRuntime);
            Assert(AssetMap.Parse("lekmod-dlc-9.9.9.zip")!.Value.Kind == ComponentKind.LekmodDlc);
            // Version is split off correctly despite the hyphenated prefix.
            Assert(AssetMap.Parse("vp-modpack-4.5.6.zip")!.Value.Version == "4.5.6");
        });

        Run("ComponentSet blind sets match the spec", () =>
        {
            var van = ComponentSet.For(InstallState.Vanilla, InstallProfile.Blind);
            Assert(van.SequenceEqual(new[] { ComponentKind.CoreBlind, ComponentKind.Runtime, ComponentKind.Engine, ComponentKind.Cinematics }));

            var vp = ComponentSet.For(InstallState.VoxPopuli, InstallProfile.Blind);
            Assert(vp.Contains(ComponentKind.VpOverlay) && vp.Contains(ComponentKind.VpModpack) && vp.Contains(ComponentKind.VpRuntime));
            Assert(!vp.Contains(ComponentKind.Engine)); // mod states layer their own engine

            var cp = ComponentSet.For(InstallState.CommunityPatch, InstallProfile.Blind);
            Assert(cp.Contains(ComponentKind.CpModpack) && cp.Contains(ComponentKind.CpOverlay));
            Assert(!cp.Contains(ComponentKind.VpRuntime)); // CP-only never uses the VP substrate

            var lek = ComponentSet.For(InstallState.LekMod, InstallProfile.Blind);
            Assert(lek.Contains(ComponentKind.LekmodDlc) && lek.Contains(ComponentKind.LekmodOverlay));
        });

        Run("ComponentSet sighted sets are the host-match minimum", () =>
        {
            var van = ComponentSet.For(InstallState.Vanilla, InstallProfile.Sighted);
            Assert(van.SequenceEqual(new[] { ComponentKind.CoreSighted, ComponentKind.Engine }));

            var vp = ComponentSet.For(InstallState.VoxPopuli, InstallProfile.Sighted);
            Assert(vp.SequenceEqual(new[] { ComponentKind.CoreSighted, ComponentKind.VpModpack, ComponentKind.VpRuntime }));

            var cp = ComponentSet.For(InstallState.CommunityPatch, InstallProfile.Sighted);
            Assert(cp.SequenceEqual(new[] { ComponentKind.CoreSighted, ComponentKind.CpModpack }));
            Assert(!cp.Contains(ComponentKind.VpRuntime));

            var lek = ComponentSet.For(InstallState.LekMod, InstallProfile.Sighted);
            Assert(lek.SequenceEqual(new[] { ComponentKind.CoreSighted, ComponentKind.LekmodDlc }));
        });

        Run("Footprint reflects proxy and mod artifacts", () =>
        {
            Assert(Footprint.For(InstallState.Vanilla, InstallProfile.Blind) == ModArtifact.Proxy);
            Assert(Footprint.For(InstallState.Vanilla, InstallProfile.Sighted) == ModArtifact.None);
            Assert(Footprint.For(InstallState.VoxPopuli, InstallProfile.Blind) ==
                   (ModArtifact.Proxy | ModArtifact.ModpackVp | ModArtifact.VpSubstrate));
            Assert(Footprint.For(InstallState.VoxPopuli, InstallProfile.Sighted) ==
                   (ModArtifact.ModpackVp | ModArtifact.VpSubstrate));
            Assert(Footprint.For(InstallState.CommunityPatch, InstallProfile.Blind) ==
                   (ModArtifact.Proxy | ModArtifact.ModpackCp));
            Assert(Footprint.For(InstallState.LekMod, InstallProfile.Blind) ==
                   (ModArtifact.Proxy | ModArtifact.LekmodDlc));
        });

        Run("Transition VP->vanilla tears down VP artifacts, keeps proxy", () =>
        {
            var td = TransitionPlanner.ArtifactsToTearDown(
                InstallState.VoxPopuli, InstallProfile.Blind,
                InstallState.Vanilla, InstallProfile.Blind);
            Assert(td == (ModArtifact.ModpackVp | ModArtifact.VpSubstrate));
            Assert(!td.HasFlag(ModArtifact.Proxy)); // both blind, proxy stays
        });

        Run("Transition VP->LekMod swaps mod artifacts", () =>
        {
            var td = TransitionPlanner.ArtifactsToTearDown(
                InstallState.VoxPopuli, InstallProfile.Blind,
                InstallState.LekMod, InstallProfile.Blind);
            // VP artifacts go; LekMod's DLC is added by apply, not teardown.
            Assert(td == (ModArtifact.ModpackVp | ModArtifact.VpSubstrate));
        });

        Run("Transition CP->VP keeps shared, drops CP package", () =>
        {
            var td = TransitionPlanner.ArtifactsToTearDown(
                InstallState.CommunityPatch, InstallProfile.Blind,
                InstallState.VoxPopuli, InstallProfile.Blind);
            Assert(td == ModArtifact.ModpackCp);
        });

        Run("Transition blind->sighted removes proxy", () =>
        {
            var td = TransitionPlanner.ArtifactsToTearDown(
                InstallState.Vanilla, InstallProfile.Blind,
                InstallState.Vanilla, InstallProfile.Sighted);
            Assert(td == ModArtifact.Proxy);
        });

        Run("Transition same state/profile tears down nothing", () =>
        {
            var td = TransitionPlanner.ArtifactsToTearDown(
                InstallState.VoxPopuli, InstallProfile.Blind,
                InstallState.VoxPopuli, InstallProfile.Blind);
            Assert(td == ModArtifact.None);
        });

        Run("Fresh-install worst-case teardown clears foreign states", () =>
        {
            // Exercises the production path: a fresh install assumes ALL artifacts
            // present, then keeps the target's.
            var td = TransitionPlanner.ArtifactsToTearDownFromUnknown(InstallState.VoxPopuli, InstallProfile.Blind);
            Assert(td == (ModArtifact.ModpackCp | ModArtifact.LekmodDlc));
            Assert(!td.HasFlag(ModArtifact.Proxy)); // target blind keeps proxy
            Assert(!td.HasFlag(ModArtifact.VpSubstrate)); // target wants it
        });

        Run("InstallState variant strings round-trip", () =>
        {
            Assert(InstallState.Vanilla.ToManifestVariant() == null);
            Assert(InstallState.VoxPopuli.ToManifestVariant() == "modpack");
            Assert(InstallState.CommunityPatch.ToManifestVariant() == "modpack-cp");
            Assert(InstallState.LekMod.ToManifestVariant() == "lekmod");
            Assert(InstallStateExtensions.ParseVariant(null) == InstallState.Vanilla);
            Assert(InstallStateExtensions.ParseVariant("modpack") == InstallState.VoxPopuli);
            Assert(InstallStateExtensions.ParseVariant("modpack-cp") == InstallState.CommunityPatch);
            Assert(InstallStateExtensions.ParseVariant("lekmod") == InstallState.LekMod);
            Assert(InstallStateExtensions.ParseVariant("vp") == InstallState.VoxPopuli); // dev mod-overlay
            Assert(InstallStateExtensions.ParseVariant("bogus") == InstallState.Vanilla);
        });

        Run("InstallManifest omits variant for vanilla, writes it for modpack", () =>
        {
            var dir = Path.Combine(Path.GetTempPath(), "civvtest-" + Guid.NewGuid().ToString("N"));
            try
            {
                var van = new InstallManifest { ModVersion = "1.0.0", Profile = InstallProfile.Blind, Variant = InstallState.Vanilla };
                van.Components["core"] = new InstallManifest.ComponentRecord { Version = "1.0.0", Sha256 = "aa" };
                van.Write(dir);
                var vanJson = File.ReadAllText(InstallManifest.PathFor(dir));
                Assert(!vanJson.Contains("variant"));
                Assert(InstallManifest.TryRead(dir)!.Variant == InstallState.Vanilla);

                var vp = new InstallManifest { ModVersion = "1.0.0", Profile = InstallProfile.Blind, Variant = InstallState.VoxPopuli };
                vp.Components["core"] = new InstallManifest.ComponentRecord { Version = "1.0.0", Sha256 = "aa" };
                vp.Write(dir);
                var vpJson = File.ReadAllText(InstallManifest.PathFor(dir));
                Assert(vpJson.Contains("\"variant\": \"modpack\""));
                Assert(InstallManifest.TryRead(dir)!.Variant == InstallState.VoxPopuli);
            }
            finally
            {
                try { Directory.Delete(dir, recursive: true); } catch { /* temp */ }
            }
        });

        Run("ComponentCache reports miss for null digest and formats paths", () =>
        {
            var cache = new ComponentCache();
            Assert(!cache.Has(null));
            Assert(!cache.Has(""));
            Assert(cache.PathForDigest("ABCDEF").EndsWith("abcdef.zip"));
        });

        Run("BackupStockCiv5Pkg backs up a stock manifest, skips a VP one", () =>
        {
            var dir = Path.Combine(Path.GetTempPath(), "civvtest-" + Guid.NewGuid().ToString("N"));
            try
            {
                var layout = new GameLayout(dir);
                Directory.CreateDirectory(Path.GetDirectoryName(layout.Expansion2Civ5Pkg)!);

                // Stock manifest (no VP marker) -> captured.
                File.WriteAllText(layout.Expansion2Civ5Pkg, "<Mod>stock BNW manifest</Mod>");
                ArtifactOps.BackupStockCiv5Pkg(layout);
                Assert(File.Exists(layout.Civ5PkgStockBackup), "stock pkg should be backed up");

                // Backup already exists -> not overwritten by a later VP pkg.
                File.WriteAllText(layout.Expansion2Civ5Pkg, "<Mod>MinorCivSounds_VoxPopuli</Mod>");
                ArtifactOps.BackupStockCiv5Pkg(layout);
                Assert(File.ReadAllText(layout.Civ5PkgStockBackup).Contains("stock BNW"),
                    "existing stock backup must not be overwritten");
            }
            finally { try { Directory.Delete(dir, recursive: true); } catch { /* temp */ } }
        });

        Run("BackupStockCiv5Pkg does not capture a VP manifest as stock", () =>
        {
            var dir = Path.Combine(Path.GetTempPath(), "civvtest-" + Guid.NewGuid().ToString("N"));
            try
            {
                var layout = new GameLayout(dir);
                Directory.CreateDirectory(Path.GetDirectoryName(layout.Expansion2Civ5Pkg)!);
                File.WriteAllText(layout.Expansion2Civ5Pkg, "<Mod>MinorCivSounds_VoxPopuli</Mod>");
                ArtifactOps.BackupStockCiv5Pkg(layout);
                Assert(!File.Exists(layout.Civ5PkgStockBackup), "a VP pkg must never be saved as the stock backup");
            }
            finally { try { Directory.Delete(dir, recursive: true); } catch { /* temp */ } }
        });

        Run("RemoveLekmodDlc clears the LekMod DLC and the Lekmap maps together", () =>
        {
            var dir = Path.Combine(Path.GetTempPath(), "civvtest-" + Guid.NewGuid().ToString("N"));
            try
            {
                var layout = new GameLayout(dir);
                // A canonical LEKMOD dir, a stray LEKMODv99 dir, and the Lekmap maps.
                Directory.CreateDirectory(layout.LekmodDlcDir);
                File.WriteAllText(Path.Combine(layout.LekmodDlcDir, "MPModsPack.Civ5Pkg"), "x");
                var stray = Path.Combine(layout.AssetsDlcDir, "LEKMODv99");
                Directory.CreateDirectory(stray);
                Directory.CreateDirectory(layout.LekmapMapsDir);
                File.WriteAllText(Path.Combine(layout.LekmapMapsDir, "LekmapPangaea.lua"), "x");

                ArtifactOps.RemoveLekmodDlc(layout);

                Assert(!Directory.Exists(layout.LekmodDlcDir), "LEKMOD dir should be removed");
                Assert(!Directory.Exists(stray), "stray LEKMOD* dir should be removed");
                Assert(!Directory.Exists(layout.LekmapMapsDir), "Lekmap maps should be removed");
                // Assets/Maps itself is not ours to remove.
                Assert(Directory.Exists(layout.AssetsMapsDir), "Assets/Maps must be left in place");
            }
            finally { try { Directory.Delete(dir, recursive: true); } catch { /* temp */ } }
        });

        Run("Every locale resolves the new state-picker keys", () =>
        {
            foreach (var entry in LocaleCatalog.All)
            {
                Strings.SetLocale(entry.Code);
                // A missing key returns the key itself; assert real translations exist.
                foreach (var key in new[] { "state.vanilla", "state.voxPopuli", "statePicker.heading",
                                            "confirm.changeState", "component.vpModpack", "result.stateSwitch.heading" })
                {
                    Assert(Strings.Get(key) != key, $"{entry.Code} missing {key}");
                }
                // Format strings with placeholders must still format cleanly.
                Assert(Strings.Format("check.currentState", "X").Contains("X"), $"{entry.Code} check.currentState");
                Assert(Strings.Format("result.stateSwitch.body", "A", "B").Contains("A"), $"{entry.Code} stateSwitch.body");
            }
            Strings.SetLocale("en_US");
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

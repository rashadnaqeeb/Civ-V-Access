using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// The whole installer UI, rendered as a sequence of plain WinForms modal
/// dialogs. Each step opens with ShowDialog() and returns synchronously
/// with a result; the flow class drives them in order.
///
/// Two top-level paths: a fresh-install flow that walks the user through
/// language choice, game-dir detection, profile selection, and (for the
/// sighted profile) a restore-after-MP advisory; and a returning-user
/// flow that lands on a single action dialog with the actions appropriate
/// for the current install state. Both end at a download/install or
/// uninstall progress dialog and a final success/failure message.
/// </summary>
internal sealed class Flow : IDisposable
{
    private readonly Core.Installer _installer = new();

    public void Run()
    {
        try
        {
            // Try a silent up-front detection so we know which top-level
            // flow to enter. If we already have a deployed install, the
            // user is a returning user and we skip the language picker
            // and the welcome / profile dialogs.
            string? autoDetected = GameDetector.AutoDetect();
            if (autoDetected != null && !GameDetector.HasBraveNewWorld(autoDetected))
            {
                autoDetected = null;
            }

            InstallManifest? manifest = autoDetected == null
                ? null
                : InstallManifest.TryRead(autoDetected);

            if (manifest != null)
            {
                RunReturning(autoDetected!, manifest);
            }
            else
            {
                RunFirstInstall(autoDetected);
            }
        }
        catch (Exception ex)
        {
            Logger.Error("Unhandled exception in flow", ex);
            ShowError(Strings.Format("error.unhandled", ex.Message, Logger.LogPath));
        }
    }

    public void Dispose() => _installer.Dispose();

    // ------------------------------------------------------------------
    // First-install flow.
    // ------------------------------------------------------------------

    private void RunFirstInstall(string? autoDetected)
    {
        // Step 1: language picker (welcome + combobox).
        using (var picker = new LanguagePicker())
        {
            if (picker.ShowDialog() != DialogResult.OK) return;
            Strings.SetLocale(picker.SelectedCode);
        }

        // Step 2: locate the game directory. If auto-detect already found a
        // valid BNW install, the "looking" dialog still shows briefly so
        // the user has a moment of feedback - then we move on. Otherwise
        // the dialog runs the detection and on failure we drop into the
        // browse dialog.
        string? gameDir = LocateGameDirectory(autoDetected);
        if (gameDir == null) return;

        // Step 3: now that we have a confirmed install, turn on Lua logging
        // best-effort (idempotent; no-op if config.ini doesn't exist yet).
        GameConfigIni.TryEnableLogging();

        // Step 4: profile question.
        InstallProfile? profile;
        using (var profileForm = new ProfileForm())
        {
            if (profileForm.ShowDialog() != DialogResult.OK) return;
            profile = profileForm.Selected;
        }
        if (profile == null) return;

        // Step 5: sighted profile gets a multiplayer-restore advisory.
        if (profile == InstallProfile.Sighted)
        {
            MessageBox.Show(
                Strings.Get("sighted.advisoryBody"),
                Strings.Get("sighted.advisoryHeading"),
                MessageBoxButtons.OK,
                MessageBoxIcon.Information);
        }

        // Step 6: fetch latest release.
        var release = FetchLatestRelease();
        if (release == null) return;

        if (release.SemVer.Major > AppVersion.SupportedMaxModMajor)
        {
            ShowError(
                Strings.Get("check.unsupportedMajor.heading") + "\n\n" +
                Strings.Format("check.unsupportedMajor.body",
                    AppVersion.SupportedMaxModMajor, release.SemVer.Major));
            return;
        }

        var plan = _installer.BuildPlan(gameDir, profile.Value, release, null, forceAll: false);
        RunInstall(plan);
    }

    private string? LocateGameDirectory(string? autoDetected)
    {
        // Re-run the detection even when we already have a result, so the
        // "looking" dialog has something genuine to do. Adds maybe 50ms;
        // the user gets visible confirmation that the installer is doing
        // its job.
        var (resolved, cancelled, _) = ProgressForm.RunMarquee(
            Strings.Get("welcome.heading"),
            Strings.Get("welcome.locating"),
            (_, ct) => Task.Run<string?>(() =>
            {
                ct.ThrowIfCancellationRequested();
                if (autoDetected != null && GameDetector.HasBraveNewWorld(autoDetected))
                {
                    return autoDetected;
                }
                var found = GameDetector.AutoDetect();
                return (found != null && GameDetector.HasBraveNewWorld(found)) ? found : null;
            }, ct));

        if (cancelled) return null;
        if (resolved != null) return resolved;

        // Detection failed. Drop into the browse dialog loop.
        return BrowseForGameDirectory(Strings.Get("welcome.notFound"));
    }

    private static string? BrowseForGameDirectory(string initialMessage)
    {
        string message = initialMessage;
        while (true)
        {
            var pick = MessageBox.Show(
                message,
                Strings.Get("welcome.heading"),
                MessageBoxButtons.OKCancel,
                MessageBoxIcon.Warning,
                MessageBoxDefaultButton.Button1);
            if (pick != DialogResult.OK) return null;

            using var dlg = new FolderBrowserDialog
            {
                Description = Strings.Get("welcome.notFound"),
                UseDescriptionForTitle = true,
                ShowNewFolderButton = false,
            };
            if (dlg.ShowDialog() != DialogResult.OK) return null;

            var picked = dlg.SelectedPath;
            if (!GameDetector.LooksLikeCivVInstall(picked))
            {
                message = Strings.Get("welcome.invalidFolder");
                continue;
            }
            if (!GameDetector.HasBraveNewWorld(picked))
            {
                message = Strings.Get("welcome.bnwMissing");
                continue;
            }
            return picked;
        }
    }

    // ------------------------------------------------------------------
    // Returning-user flow.
    // ------------------------------------------------------------------

    private void RunReturning(string gameDir, InstallManifest manifest)
    {
        GameConfigIni.TryEnableLogging();

        var release = FetchLatestRelease();
        if (release == null) return;

        if (release.SemVer.Major > AppVersion.SupportedMaxModMajor)
        {
            ShowError(
                Strings.Get("check.unsupportedMajor.heading") + "\n\n" +
                Strings.Format("check.unsupportedMajor.body",
                    AppVersion.SupportedMaxModMajor, release.SemVer.Major));
            return;
        }

        var plan = _installer.BuildPlan(gameDir, manifest.Profile, release, manifest, forceAll: false);

        string heading;
        string body;
        if (plan.IsUpToDate)
        {
            heading = Strings.Get("check.upToDate.heading");
            body = Strings.Format("check.upToDate.body", manifest.ModVersion);
        }
        else
        {
            heading = Strings.Get("check.updateAvailable.heading");
            body = Strings.Format("check.updateAvailable.body", manifest.ModVersion, release.SemVer.ToString(3));
        }

        ActionForm.Action action;
        using (var actionForm = new ActionForm(heading, body, updateAvailable: !plan.IsUpToDate))
        {
            actionForm.ShowDialog();
            action = actionForm.Result;
        }

        switch (action)
        {
            case ActionForm.Action.Update:
                RunInstall(plan);
                break;
            case ActionForm.Action.Reinstall:
                var forced = _installer.BuildPlan(gameDir, manifest.Profile, release, manifest, forceAll: true);
                RunInstall(forced);
                break;
            case ActionForm.Action.Uninstall:
                if (ConfirmUninstall())
                {
                    RunUninstall(gameDir);
                }
                break;
            case ActionForm.Action.Close:
            case ActionForm.Action.None:
                return;
        }
    }

    private bool ConfirmUninstall()
    {
        var pick = MessageBox.Show(
            Strings.Get("confirm.uninstall").Replace("&", "") + "?",
            Strings.Get("app.title"),
            MessageBoxButtons.OKCancel,
            MessageBoxIcon.Warning,
            MessageBoxDefaultButton.Button2);
        return pick == DialogResult.OK;
    }

    // ------------------------------------------------------------------
    // GitHub release fetch (with marquee dialog).
    // ------------------------------------------------------------------

    private GitHubReleases.Release? FetchLatestRelease()
    {
        var (release, cancelled, error) = ProgressForm.RunMarquee(
            Strings.Get("check.heading"),
            Strings.Get("check.contactingGitHub"),
            async (_, ct) =>
            {
                try
                {
                    return await _installer.GetLatestReleaseAsync(ct).ConfigureAwait(false);
                }
                catch (HttpRequestException) { return (GitHubReleases.Release?)null; }
            });

        if (cancelled) return null;
        if (error != null)
        {
            Logger.Error("GitHub fetch failed", error);
            ShowError(Strings.Get("check.networkError"));
            return null;
        }
        if (release == null)
        {
            ShowError(Strings.Get("check.networkError"));
            return null;
        }
        return release;
    }

    // ------------------------------------------------------------------
    // Install / uninstall execution (with percentage progress dialog).
    // ------------------------------------------------------------------

    private void RunInstall(InstallPlan plan)
    {
        if (GameProcess.IsRunning())
        {
            MessageBox.Show(
                Strings.Get("confirm.gameRunning"),
                Strings.Get("app.title"),
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
            return;
        }

        var (_, cancelled, error) = ProgressForm.RunPercentage<bool>(
            Strings.Get("progress.heading"),
            Strings.Get("progress.preparing"),
            async (statusProgress, valueProgress, ct) =>
            {
                var installerProgress = new Progress<InstallProgress>(p =>
                {
                    statusProgress.Report(ProgressMessage(p, isUninstall: false));
                    valueProgress.Report(ComputeProgressValue(p));
                });
                await _installer.ExecuteAsync(plan, installerProgress, ct).ConfigureAwait(false);
                return true;
            });

        if (cancelled) return;
        if (error != null)
        {
            ShowError(Strings.Format("result.failed.body", error.Message, Logger.LogPath));
            return;
        }

        var version = plan.Release.SemVer.ToString(3);
        ShowSuccess(
            plan.IsFreshInstall
                ? Strings.Get("result.installSuccess.heading")
                : Strings.Get("result.updateSuccess.heading"),
            Strings.Format(
                plan.IsFreshInstall ? "result.installSuccess.body" : "result.updateSuccess.body",
                version));
    }

    private void RunUninstall(string gameDir)
    {
        var (_, cancelled, error) = ProgressForm.RunMarquee<bool>(
            Strings.Get("uninstall.heading"),
            Strings.Get("progress.preparing"),
            async (statusProgress, ct) =>
            {
                var installerProgress = new Progress<InstallProgress>(p =>
                {
                    statusProgress.Report(ProgressMessage(p, isUninstall: true));
                });
                await UninstallRunner.RunAsync(gameDir, installerProgress, ct).ConfigureAwait(false);
                return true;
            });

        if (cancelled) return;
        if (error != null)
        {
            ShowError(Strings.Format("result.failed.body", error.Message, Logger.LogPath));
            return;
        }

        ShowSuccess(
            Strings.Get("result.uninstallSuccess.heading"),
            Strings.Get("result.uninstallSuccess.body"));
    }

    // ------------------------------------------------------------------
    // Result dialogs (success / error) and shared helpers.
    // ------------------------------------------------------------------

    private static void ShowSuccess(string heading, string body)
    {
        MessageBox.Show(
            body,
            heading,
            MessageBoxButtons.OK,
            MessageBoxIcon.Information);
    }

    private static void ShowError(string body)
    {
        var pick = MessageBox.Show(
            body + "\n\n" + Strings.Format("result.openLogPrompt.body", Logger.LogPath),
            Strings.Get("result.failed.heading"),
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Error,
            MessageBoxDefaultButton.Button2);
        if (pick == DialogResult.Yes) OpenLog();
    }

    private static void OpenLog()
    {
        try
        {
            Process.Start(new ProcessStartInfo { FileName = Logger.LogPath, UseShellExecute = true });
        }
        catch (Exception ex) { Logger.Warn($"Open log failed: {ex.Message}"); }
    }

    private static string ProgressMessage(InstallProgress p, bool isUninstall)
    {
        var component = p.Component?.DisplayName() ?? "";
        return p.Stage switch
        {
            InstallStage.Preparing       => Strings.Get("progress.preparing"),
            InstallStage.Downloading     => Strings.Format("progress.downloading", component,
                                              FormatBytes(p.BytesSoFar), FormatBytes(p.BytesTotal)),
            InstallStage.Verifying       => Strings.Format("progress.verifying", component),
            InstallStage.Extracting      => Strings.Format("progress.extracting", component),
            InstallStage.BackingUp       => p.Component == ComponentKind.Cinematics
                                              ? Strings.Get("progress.backingUpCinematics")
                                              : Strings.Get("progress.backingUpEngine"),
            InstallStage.SwappingProxy   => isUninstall
                                              ? Strings.Get("uninstall.restoringProxy")
                                              : Strings.Get("progress.swappingProxy"),
            InstallStage.WritingManifest => Strings.Get("progress.writingManifest"),
            InstallStage.ClearingCache   => Strings.Get("progress.cleaningCache"),
            InstallStage.RemovingDlc     => Strings.Get("uninstall.removingDlc"),
            InstallStage.RemovingTolk    => Strings.Get("uninstall.removingTolk"),
            InstallStage.Restoring       => p.Component == ComponentKind.Cinematics
                                              ? Strings.Get("uninstall.restoringCinematics")
                                              : Strings.Get("uninstall.restoringEngine"),
            _                            => Strings.Get("progress.applying"),
        };
    }

    private static string FormatBytes(long bytes)
    {
        if (bytes < 1024) return Strings.Format("size.bytes", bytes);
        if (bytes < 1024 * 1024) return Strings.Format("size.kb", bytes / 1024);
        return Strings.Format("size.mb", bytes / (1024 * 1024));
    }

    private static int ComputeProgressValue(InstallProgress p)
    {
        if (p.StepCount <= 0) return 0;
        double stepFraction = (double)p.StepIndex / p.StepCount;
        double withinStep = p.BytesTotal > 0 ? (double)p.BytesSoFar / p.BytesTotal : 0;
        double total = stepFraction + withinStep / Math.Max(p.StepCount, 1);
        return (int)(Math.Clamp(total, 0, 1) * 1000);
    }
}

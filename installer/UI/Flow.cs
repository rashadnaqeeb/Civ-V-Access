using System;
using System.Collections.Generic;
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
/// The whole installer UI, rendered as a sequence of native Windows
/// TaskDialogs. Each step is one dialog; the user's button choice drives
/// the transition to the next step. TaskDialog announces title + heading
/// + body + button labels through the screen reader without us having to
/// wire AccessibleName on individual controls.
/// </summary>
internal sealed class Flow : IDisposable
{
    private readonly Core.Installer _installer = new();

    private string? _gameDir;
    private InstallProfile? _profile;
    private InstallManifest? _existingManifest;

    public void Run()
    {
        try
        {
            ResolveGameDirectory();
            if (_gameDir == null) return;

            _existingManifest = InstallManifest.TryRead(_gameDir);
            if (_existingManifest != null)
            {
                _profile = _existingManifest.Profile;
            }
            else
            {
                _profile = AskProfile();
                if (_profile == null) return;
            }

            // Best-effort: turn on Lua logging once we have authority over a
            // confirmed install. No-op if config.ini doesn't exist yet.
            GameConfigIni.TryEnableLogging();

            CheckAndAct();
        }
        catch (Exception ex)
        {
            Logger.Error("Unhandled exception in flow", ex);
            ShowError(Strings.Format("error.unhandled", ex.Message, Logger.LogPath));
        }
    }

    public void Dispose() => _installer.Dispose();

    // ------------------------------------------------------------------
    // Step 1: locate the game install (auto-detect, then Browse fallback).
    // ------------------------------------------------------------------

    private void ResolveGameDirectory()
    {
        var detected = GameDetector.AutoDetect();
        if (detected != null && GameDetector.HasBraveNewWorld(detected))
        {
            _gameDir = detected;
            return;
        }

        // Auto-detect failed (or BNW missing) - prompt the user. Pass the
        // key, not the resolved string, so a mid-flow language change can
        // re-translate.
        var initialKey = detected == null ? "welcome.notFound" : "welcome.bnwMissing";
        _gameDir = PromptForGameDirectory(initialKey);
    }

    private string? PromptForGameDirectory(string bodyKey)
    {
        while (true)
        {
            bool browseClicked = false;
            var browse = new TaskDialogCommandLinkButton(Strings.Get("welcome.browse").Replace("&", ""));
            browse.Click += (_, _) => browseClicked = true;

            var page = new TaskDialogPage
            {
                Caption = Strings.Get("app.title"),
                Heading = Strings.Get("welcome.heading"),
                Text = Strings.Get(bodyKey),
                Icon = TaskDialogIcon.Information,
                AllowCancel = true,
                Buttons = { browse, TaskDialogButton.Cancel },
                DefaultButton = browse,
                Footnote = new TaskDialogFootnote
                {
                    Text = $"<a href=\"language\">{Strings.Get("language.dialogTitle")}</a>",
                },
            };
            page.LinkClicked += (_, e) =>
            {
                if (e.LinkHref != "language") return;
                using var picker = new LanguagePicker();
                if (picker.ShowDialog() != DialogResult.OK) return;
                Strings.SetLocale(picker.SelectedCode);

                // Live-update the visible dialog so the user sees the new
                // locale immediately. Caption (window title) can't change
                // while the dialog is open, but the heading, body, button,
                // and footnote can.
                page.Heading = Strings.Get("welcome.heading");
                page.Text = Strings.Get(bodyKey);
                browse.Text = Strings.Get("welcome.browse").Replace("&", "");
                page.Footnote.Text = $"<a href=\"language\">{Strings.Get("language.dialogTitle")}</a>";
            };

            TaskDialog.ShowDialog(page);
            if (!browseClicked) return null;

            string? picked = ShowFolderPicker();
            if (picked == null) continue;

            if (!GameDetector.LooksLikeCivVInstall(picked))
            {
                bodyKey = "welcome.invalidFolder";
                continue;
            }
            if (!GameDetector.HasBraveNewWorld(picked))
            {
                bodyKey = "welcome.bnwMissing";
                continue;
            }
            return picked;
        }
    }

    private static string? ShowFolderPicker()
    {
        using var dlg = new FolderBrowserDialog
        {
            Description = Strings.Get("welcome.notFound"),
            UseDescriptionForTitle = true,
            ShowNewFolderButton = false,
        };
        return dlg.ShowDialog() == DialogResult.OK ? dlg.SelectedPath : null;
    }

    // ------------------------------------------------------------------
    // Step 2: profile question (first install only).
    // ------------------------------------------------------------------

    private InstallProfile? AskProfile()
    {
        var blind = new TaskDialogCommandLinkButton(
            Strings.Get("profile.optionBlind").Replace("&", ""),
            Strings.Get("profile.optionBlindDesc"));
        var sighted = new TaskDialogCommandLinkButton(
            Strings.Get("profile.optionSighted").Replace("&", ""),
            Strings.Get("profile.optionSightedDesc"));

        var page = new TaskDialogPage
        {
            Caption = Strings.Get("app.title"),
            Heading = Strings.Get("profile.heading"),
            Text = Strings.Get("profile.body"),
            Icon = TaskDialogIcon.Information,
            AllowCancel = true,
            Buttons = { blind, sighted, TaskDialogButton.Cancel },
            DefaultButton = blind,
        };

        var clicked = TaskDialog.ShowDialog(page);
        if (clicked == blind) return InstallProfile.Blind;
        if (clicked == sighted) return InstallProfile.Sighted;
        return null;
    }

    // ------------------------------------------------------------------
    // Step 3: contact GitHub, build a plan, present action choices, run them.
    // ------------------------------------------------------------------

    private void CheckAndAct()
    {
        var (release, networkError) = FetchLatestRelease();
        if (release == null)
        {
            if (networkError) ShowError(Strings.Get("check.networkError"));
            return;
        }

        if (release.SemVer.Major > AppVersion.SupportedMaxModMajor)
        {
            ShowError(
                Strings.Get("check.unsupportedMajor.heading") + "\n\n" +
                Strings.Format("check.unsupportedMajor.body",
                    AppVersion.SupportedMaxModMajor, release.SemVer.Major));
            return;
        }

        var plan = _installer.BuildPlan(_gameDir!, _profile!.Value, release, _existingManifest, forceAll: false);
        var changelog = FetchChangelogSlice(release);

        var action = AskUserAction(plan, release, changelog);
        switch (action)
        {
            case UserAction.Install:
            case UserAction.Update:
                RunInstall(plan);
                break;
            case UserAction.Reinstall:
                var forced = _installer.BuildPlan(_gameDir!, _profile!.Value, release, _existingManifest, forceAll: true);
                RunInstall(forced);
                break;
            case UserAction.Uninstall:
                RunUninstall();
                break;
            case UserAction.Close:
                return;
        }
    }

    /// <summary>
    /// Pop a marquee-progress dialog while we hit /releases/latest. The
    /// dialog gives the screen reader something concrete to announce
    /// during the network call and lets the user cancel a hung request.
    /// </summary>
    private (GitHubReleases.Release? Release, bool NetworkError) FetchLatestRelease()
    {
        GitHubReleases.Release? release = null;
        bool networkError = false;
        var cts = new CancellationTokenSource();

        var cancelBtn = new TaskDialogButton(Strings.Get("confirm.cancel").Replace("&", ""));
        cancelBtn.Click += (_, _) => cts.Cancel();

        var page = new TaskDialogPage
        {
            Caption = Strings.Get("app.title"),
            Heading = Strings.Get("check.heading"),
            Text = Strings.Get("check.contactingGitHub"),
            ProgressBar = new TaskDialogProgressBar(TaskDialogProgressBarState.Marquee),
            AllowCancel = true,
            Buttons = { cancelBtn },
        };
        page.Created += async (_, _) =>
        {
            try
            {
                release = await _installer.GetLatestReleaseAsync(cts.Token).ConfigureAwait(true);
            }
            catch (OperationCanceledException) { /* user cancelled */ }
            catch (HttpRequestException ex)
            {
                Logger.Warn($"GitHub fetch failed: {ex.Message}");
                networkError = true;
            }
            catch (Exception ex)
            {
                Logger.Error("GitHub fetch failed", ex);
                networkError = true;
            }
            finally
            {
                CloseTaskDialog(page, cancelBtn);
            }
        };

        TaskDialog.ShowDialog(page);
        if (cts.IsCancellationRequested) return (null, false);
        return (release, networkError);
    }

    private string FetchChangelogSlice(GitHubReleases.Release release)
    {
        // Quick best-effort fetch with a short timeout - if it fails the
        // action page still renders, just without a "what's new" section.
        try
        {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(15));
            var raw = _installer.GetChangelogAsync(cts.Token).GetAwaiter().GetResult();
            Version? installed = null;
            if (_existingManifest != null && Version.TryParse(_existingManifest.ModVersion, out var v))
            {
                installed = v;
            }
            return ChangelogParser.Slice(raw, installed, release.SemVer);
        }
        catch (Exception ex)
        {
            Logger.Warn($"Changelog fetch failed: {ex.Message}");
            return string.Empty;
        }
    }

    private enum UserAction { Install, Update, Reinstall, Uninstall, Close }

    private UserAction AskUserAction(InstallPlan plan, GitHubReleases.Release release, string changelog)
    {
        if (plan.IsUpToDate)
        {
            var reinstall = new TaskDialogCommandLinkButton(
                Strings.Get("confirm.reinstall").Replace("&", ""));
            var uninstall = new TaskDialogCommandLinkButton(
                Strings.Get("confirm.uninstall").Replace("&", ""));
            var close = new TaskDialogButton(Strings.Get("confirm.close").Replace("&", ""));

            var page = new TaskDialogPage
            {
                Caption = Strings.Get("app.title"),
                Heading = Strings.Get("check.upToDate.heading"),
                Text = Strings.Format("check.upToDate.body", release.SemVer.ToString(3)),
                Icon = TaskDialogIcon.Information,
                AllowCancel = true,
                Buttons = { reinstall, uninstall, close },
                DefaultButton = close,
            };

            var clicked = TaskDialog.ShowDialog(page);
            if (clicked == reinstall) return UserAction.Reinstall;
            if (clicked == uninstall && ConfirmUninstall()) return UserAction.Uninstall;
            return UserAction.Close;
        }

        var componentsList = string.Join(Environment.NewLine,
            plan.ComponentsToFetch.Select(a => "  " + FormatComponentLine(a)));

        // Build the body. Heading + version diff above; expandable section
        // below holds the changelog so the dialog stays compact for users
        // who don't want to read it.
        string heading;
        string text;
        TaskDialogCommandLinkButton primary;
        TaskDialogCommandLinkButton? uninstallBtn = null;

        if (plan.IsFreshInstall)
        {
            heading = Strings.Get("check.installFresh.heading");
            text = Strings.Format("check.installFresh.body", release.SemVer.ToString(3));
            primary = new TaskDialogCommandLinkButton(Strings.Get("confirm.install").Replace("&", ""));
        }
        else
        {
            var installedVer = _existingManifest?.ModVersion ?? "?";
            heading = Strings.Get("check.updateAvailable.heading");
            text = Strings.Format("check.updateAvailable.body", installedVer, release.SemVer.ToString(3));
            primary = new TaskDialogCommandLinkButton(Strings.Get("confirm.update").Replace("&", ""));
            uninstallBtn = new TaskDialogCommandLinkButton(Strings.Get("confirm.uninstall").Replace("&", ""));
        }

        var cancel = new TaskDialogButton(Strings.Get("confirm.cancel").Replace("&", ""));

        text += "\n\n" + Strings.Get("check.componentsHeading") + "\n" + componentsList;

        var actionPage = new TaskDialogPage
        {
            Caption = Strings.Get("app.title"),
            Heading = heading,
            Text = text,
            Icon = TaskDialogIcon.Information,
            AllowCancel = true,
            Buttons = { primary },
            DefaultButton = primary,
        };
        if (uninstallBtn != null) actionPage.Buttons.Add(uninstallBtn);
        actionPage.Buttons.Add(cancel);

        if (!string.IsNullOrEmpty(changelog))
        {
            actionPage.Expander = new TaskDialogExpander
            {
                Text = changelog,
                ExpandedButtonText = Strings.Get("check.changelogHeading"),
                CollapsedButtonText = Strings.Get("check.changelogHeading"),
                Position = TaskDialogExpanderPosition.AfterText,
            };
        }

        var result = TaskDialog.ShowDialog(actionPage);
        if (result == primary) return plan.IsFreshInstall ? UserAction.Install : UserAction.Update;
        if (uninstallBtn != null && result == uninstallBtn && ConfirmUninstall()) return UserAction.Uninstall;
        return UserAction.Close;
    }

    private bool ConfirmUninstall()
    {
        var page = new TaskDialogPage
        {
            Caption = Strings.Get("app.title"),
            Heading = Strings.Get("confirm.uninstall").Replace("&", ""),
            Text = Strings.Get("confirm.uninstall").Replace("&", "") + "?",
            Icon = TaskDialogIcon.Warning,
            AllowCancel = true,
            Buttons = { TaskDialogButton.OK, TaskDialogButton.Cancel },
            DefaultButton = TaskDialogButton.Cancel,
        };
        return TaskDialog.ShowDialog(page) == TaskDialogButton.OK;
    }

    // ------------------------------------------------------------------
    // Step 4: run the install / uninstall against a progress dialog.
    // ------------------------------------------------------------------

    private void RunInstall(InstallPlan plan)
    {
        if (GameProcess.IsRunning())
        {
            ShowError(Strings.Get("confirm.gameRunning"));
            return;
        }

        Exception? error = null;
        var cts = new CancellationTokenSource();
        var progressBar = new TaskDialogProgressBar(TaskDialogProgressBarState.Normal)
        {
            Minimum = 0,
            Maximum = 1000,
        };
        var cancelBtn = new TaskDialogButton(Strings.Get("confirm.cancel").Replace("&", ""));
        cancelBtn.Click += (_, _) => cts.Cancel();

        var page = new TaskDialogPage
        {
            Caption = Strings.Get("app.title"),
            Heading = Strings.Get("progress.heading"),
            Text = Strings.Get("progress.preparing"),
            ProgressBar = progressBar,
            AllowCancel = true,
            Buttons = { cancelBtn },
        };

        page.Created += async (_, _) =>
        {
            try
            {
                var progress = new Progress<InstallProgress>(p =>
                {
                    page.Text = ProgressMessage(p, isUninstall: false);
                    progressBar.Value = ComputeProgressValue(p);
                });
                await _installer.ExecuteAsync(plan, progress, cts.Token).ConfigureAwait(true);
            }
            catch (OperationCanceledException) { error = new OperationCanceledException(); }
            catch (Exception ex)
            {
                Logger.Error("Install failed", ex);
                error = ex;
            }
            finally
            {
                CloseTaskDialog(page, cancelBtn);
            }
        };

        TaskDialog.ShowDialog(page);

        if (cts.IsCancellationRequested || error is OperationCanceledException) return;
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

    private void RunUninstall()
    {
        Exception? error = null;
        var cts = new CancellationTokenSource();
        var progressBar = new TaskDialogProgressBar(TaskDialogProgressBarState.Marquee);
        var cancelBtn = new TaskDialogButton(Strings.Get("confirm.cancel").Replace("&", ""));
        cancelBtn.Click += (_, _) => cts.Cancel();

        var page = new TaskDialogPage
        {
            Caption = Strings.Get("app.title"),
            Heading = Strings.Get("uninstall.heading"),
            Text = Strings.Get("progress.preparing"),
            ProgressBar = progressBar,
            AllowCancel = false,
            Buttons = { cancelBtn },
        };

        page.Created += async (_, _) =>
        {
            try
            {
                var progress = new Progress<InstallProgress>(p =>
                {
                    page.Text = ProgressMessage(p, isUninstall: true);
                });
                await UninstallRunner.RunAsync(_gameDir!, progress, cts.Token).ConfigureAwait(true);
            }
            catch (OperationCanceledException) { error = new OperationCanceledException(); }
            catch (Exception ex)
            {
                Logger.Error("Uninstall failed", ex);
                error = ex;
            }
            finally
            {
                CloseTaskDialog(page, cancelBtn);
            }
        };

        TaskDialog.ShowDialog(page);

        if (cts.IsCancellationRequested || error is OperationCanceledException) return;
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

    private void ShowSuccess(string heading, string body)
    {
        var openLog = new TaskDialogButton(Strings.Get("result.openLog").Replace("&", ""));
        var exit = new TaskDialogButton(Strings.Get("result.exit").Replace("&", ""));
        var page = new TaskDialogPage
        {
            Caption = Strings.Get("app.title"),
            Heading = heading,
            Text = body,
            Icon = TaskDialogIcon.ShieldSuccessGreenBar,
            AllowCancel = true,
            Buttons = { exit, openLog },
            DefaultButton = exit,
        };
        var clicked = TaskDialog.ShowDialog(page);
        if (clicked == openLog) OpenLog();
    }

    private void ShowError(string body)
    {
        var openLog = new TaskDialogButton(Strings.Get("result.openLog").Replace("&", ""));
        var exit = new TaskDialogButton(Strings.Get("result.exit").Replace("&", ""));
        var page = new TaskDialogPage
        {
            Caption = Strings.Get("app.title"),
            Heading = Strings.Get("result.failed.heading"),
            Text = body,
            Icon = TaskDialogIcon.Error,
            AllowCancel = true,
            Buttons = { exit, openLog },
            DefaultButton = exit,
        };
        var clicked = TaskDialog.ShowDialog(page);
        if (clicked == openLog) OpenLog();
    }

    private static void OpenLog()
    {
        try
        {
            Process.Start(new ProcessStartInfo { FileName = Logger.LogPath, UseShellExecute = true });
        }
        catch (Exception ex) { Logger.Warn($"Open log failed: {ex.Message}"); }
    }

    private static string FormatComponentLine(GitHubReleases.Asset asset)
    {
        // Mirrors the wizard-version logic: show old -> new when the
        // existing manifest reports a different version, otherwise just
        // the fresh "name version (size)" form.
        var name = asset.Kind!.Value.DisplayName();
        var newVersion = asset.Version ?? "?";
        var size = FormatBytes(asset.Size);
        return Strings.Format("check.components.fresh", name, newVersion, size);
    }

    private static string FormatBytes(long bytes)
    {
        if (bytes < 1024) return Strings.Format("size.bytes", bytes);
        if (bytes < 1024 * 1024) return Strings.Format("size.kb", bytes / 1024);
        return Strings.Format("size.mb", bytes / (1024 * 1024));
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

    private static int ComputeProgressValue(InstallProgress p)
    {
        if (p.StepCount <= 0) return 0;
        double stepFraction = (double)p.StepIndex / p.StepCount;
        double withinStep = p.BytesTotal > 0 ? (double)p.BytesSoFar / p.BytesTotal : 0;
        double total = stepFraction + withinStep / Math.Max(p.StepCount, 1);
        return (int)(Math.Clamp(total, 0, 1) * 1000);
    }

    /// <summary>
    /// Close a TaskDialog from outside its button-click path. The
    /// async-work-finished case calls this from the Created event's finally
    /// block, PerformClicking a button on the dialog. The button is
    /// passed in so the caller can supply whatever button is acting as the
    /// dialog's Cancel/done bail-out (TaskDialogButton instances are not
    /// safe to share across pages).
    /// </summary>
    private static void CloseTaskDialog(TaskDialogPage page, TaskDialogButton button)
    {
        if (page.BoundDialog == null) return;
        button.PerformClick();
    }

}

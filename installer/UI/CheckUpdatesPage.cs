using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

internal sealed class CheckUpdatesPage : WizardPage
{
    private readonly Label _heading;
    private readonly Label _statusLabel;
    private readonly TextBox _changelogBox;
    private readonly Label _componentsLabel;
    private readonly TextBox _componentsBox;
    private readonly FlowLayoutPanel _buttons;
    private readonly CancellationTokenSource _cts = new();
    private readonly Installer.Core.Installer _installer = new();

    private InstallPlan? _plan;
    private GitHubReleases.Release? _release;
    private string? _changelogSlice;

    public CheckUpdatesPage(MainForm host) : base(host)
    {
        var layout = PageScaffold.BuildLayout(out _buttons);

        var stack = new FlowLayoutPanel
        {
            FlowDirection = FlowDirection.TopDown,
            Dock = DockStyle.Fill,
            AutoSize = false,
            WrapContents = false,
        };

        _heading = PageScaffold.Heading(Strings.Get("check.heading"));
        _statusLabel = PageScaffold.Paragraph(Strings.Get("check.contactingGitHub"));
        stack.Controls.Add(_heading);
        stack.Controls.Add(_statusLabel);

        var changelogHeading = PageScaffold.Paragraph(Strings.Get("check.changelogHeading"));
        changelogHeading.Visible = false;
        changelogHeading.Margin = new Padding(0, 12, 0, 4);
        stack.Controls.Add(changelogHeading);

        _changelogBox = new TextBox
        {
            Multiline = true,
            ReadOnly = true,
            ScrollBars = ScrollBars.Vertical,
            Width = 620,
            Height = 200,
            Visible = false,
            WordWrap = true,
            BorderStyle = BorderStyle.FixedSingle,
            BackColor = SystemColors.Window,
            AccessibleRole = AccessibleRole.Text,
            AccessibleName = Strings.Get("check.changelogHeading"),
        };
        stack.Controls.Add(_changelogBox);

        _componentsLabel = PageScaffold.Paragraph(Strings.Get("check.componentsHeading"));
        _componentsLabel.Visible = false;
        _componentsLabel.Margin = new Padding(0, 12, 0, 4);
        stack.Controls.Add(_componentsLabel);

        _componentsBox = new TextBox
        {
            Multiline = true,
            ReadOnly = true,
            ScrollBars = ScrollBars.Vertical,
            Width = 620,
            Height = 90,
            Visible = false,
            WordWrap = true,
            BorderStyle = BorderStyle.FixedSingle,
            BackColor = SystemColors.Window,
            AccessibleRole = AccessibleRole.Text,
            AccessibleName = Strings.Get("check.componentsHeading"),
        };
        stack.Controls.Add(_componentsBox);

        // Track changelog heading visibility tied to changelog box for re-renders.
        _changelogBox.VisibleChanged += (_, _) => changelogHeading.Visible = _changelogBox.Visible;

        layout.Controls.Add(stack, 0, 0);
        Controls.Add(layout);
    }

    public override Control? InitialFocusControl => _statusLabel;

    public override async void OnEntered()
    {
        try
        {
            _release = await _installer.GetLatestReleaseAsync(_cts.Token).ConfigureAwait(true);
            Logger.Info($"Latest release: {_release.TagName}");

            if (_release.SemVer.Major > AppVersion.SupportedMaxModMajor)
            {
                ShowUnsupported(_release.SemVer.Major);
                return;
            }

            var profile = Host.Profile ?? throw new InvalidOperationException("Profile must be set before CheckUpdatesPage.");
            _plan = _installer.BuildPlan(
                Host.GameDir!,
                profile,
                _release,
                Host.ExistingManifest,
                forceAll: false);

            string? changelog = null;
            try
            {
                var raw = await _installer.GetChangelogAsync(_cts.Token).ConfigureAwait(true);
                Version? installed = null;
                if (Host.ExistingManifest != null && Version.TryParse(Host.ExistingManifest.ModVersion, out var v))
                {
                    installed = v;
                }
                changelog = ChangelogParser.Slice(raw, installed, _release.SemVer);
            }
            catch (Exception ex)
            {
                Logger.Warn($"Could not fetch CHANGELOG.md: {ex.Message}");
            }
            _changelogSlice = changelog;

            RenderState();
        }
        catch (OperationCanceledException) { /* user navigated away */ }
        catch (HttpRequestException ex)
        {
            Logger.Error("GitHub fetch failed", ex);
            ShowNetworkError();
        }
        catch (Exception ex)
        {
            Logger.Error("Update check failed", ex);
            ShowGenericError(ex.Message);
        }
    }

    public override void OnLocaleChanged()
    {
        _heading.Text = Strings.Get("check.heading");
        // The state-specific text was set in RenderState; re-run it if we
        // already have a plan.
        if (_plan != null) RenderState();
    }

    private void RenderState()
    {
        if (_plan == null || _release == null) return;

        if (_plan.IsUpToDate)
        {
            _statusLabel.Text =
                Strings.Get("check.upToDate.heading") + "\n\n" +
                Strings.Format("check.upToDate.body", _release.SemVer.ToString(3));
            ShowChangelog(false);
            ShowComponents(false);

            ClearButtons();
            var reinstall = PageScaffold.PrimaryButton(Strings.Get("confirm.reinstall"));
            reinstall.Click += (_, _) => StartInstall(forceAll: true);
            var uninstall = PageScaffold.SecondaryButton(Strings.Get("confirm.uninstall"));
            uninstall.Click += OnUninstallClicked;
            var close = PageScaffold.SecondaryButton(Strings.Get("confirm.close"));
            close.Click += (_, _) => Host.Close();
            _buttons.Controls.Add(reinstall);
            _buttons.Controls.Add(uninstall);
            _buttons.Controls.Add(close);
            reinstall.Focus();
        }
        else if (_plan.IsFreshInstall)
        {
            _statusLabel.Text =
                Strings.Get("check.installFresh.heading") + "\n\n" +
                Strings.Format("check.installFresh.body", _release.SemVer.ToString(3));
            ShowChangelog(true);
            ShowComponents(true);

            ClearButtons();
            var install = PageScaffold.PrimaryButton(Strings.Get("confirm.install"));
            install.Click += (_, _) => StartInstall(forceAll: false);
            var cancel = PageScaffold.SecondaryButton(Strings.Get("confirm.cancel"));
            cancel.Click += (_, _) => Host.Close();
            _buttons.Controls.Add(install);
            _buttons.Controls.Add(cancel);
            install.Focus();
        }
        else
        {
            // Update available.
            var installedVer = Host.ExistingManifest?.ModVersion ?? "?";
            _statusLabel.Text =
                Strings.Get("check.updateAvailable.heading") + "\n\n" +
                Strings.Format("check.updateAvailable.body", installedVer, _release.SemVer.ToString(3));
            ShowChangelog(true);
            ShowComponents(true);

            ClearButtons();
            var update = PageScaffold.PrimaryButton(Strings.Get("confirm.update"));
            update.Click += (_, _) => StartInstall(forceAll: false);
            var uninstall = PageScaffold.SecondaryButton(Strings.Get("confirm.uninstall"));
            uninstall.Click += OnUninstallClicked;
            var cancel = PageScaffold.SecondaryButton(Strings.Get("confirm.cancel"));
            cancel.Click += (_, _) => Host.Close();
            _buttons.Controls.Add(update);
            _buttons.Controls.Add(uninstall);
            _buttons.Controls.Add(cancel);
            update.Focus();
        }
    }

    private void ShowChangelog(bool show)
    {
        _changelogBox.Visible = show && !string.IsNullOrEmpty(_changelogSlice);
        if (_changelogBox.Visible)
        {
            _changelogBox.Text = _changelogSlice ?? "";
        }
    }

    private void ShowComponents(bool show)
    {
        if (!show || _plan == null)
        {
            _componentsBox.Visible = false;
            _componentsLabel.Visible = false;
            return;
        }

        var lines = _plan.ComponentsToFetch.Select(FormatComponentLine).ToList();
        _componentsBox.Text = string.Join(Environment.NewLine, lines);
        _componentsBox.Visible = lines.Count > 0;
        _componentsLabel.Visible = lines.Count > 0;
    }

    /// <summary>
    /// Render one components-to-download line. For an update where the local
    /// install records a different version than the asset, show "name old to
    /// new (size)" so the player knows what's actually moving. For a fresh
    /// install, just "name version (size)".
    /// </summary>
    private string FormatComponentLine(GitHubReleases.Asset asset)
    {
        var name = asset.Kind!.Value.DisplayName();
        var newVersion = asset.Version ?? _release?.SemVer.ToString(3) ?? "?";
        var size = FormatBytes(asset.Size);

        string? oldVersion = null;
        if (Host.ExistingManifest != null &&
            Host.ExistingManifest.TryGetComponent(asset.Kind.Value, out var prior) &&
            !string.IsNullOrEmpty(prior.Version) &&
            !string.Equals(prior.Version, newVersion, StringComparison.Ordinal))
        {
            oldVersion = prior.Version;
        }

        return oldVersion == null
            ? "  " + Strings.Format("check.components.fresh", name, newVersion, size)
            : "  " + Strings.Format("check.components.update", name, oldVersion, newVersion, size);
    }

    private static string FormatBytes(long bytes)
    {
        if (bytes < 1024) return Strings.Format("size.bytes", bytes);
        if (bytes < 1024 * 1024) return Strings.Format("size.kb", bytes / 1024);
        return Strings.Format("size.mb", bytes / (1024 * 1024));
    }

    private void ShowUnsupported(int releaseMajor)
    {
        _statusLabel.Text =
            Strings.Get("check.unsupportedMajor.heading") + "\n\n" +
            Strings.Format("check.unsupportedMajor.body", AppVersion.SupportedMaxModMajor, releaseMajor);
        ShowChangelog(false);
        ShowComponents(false);
        ClearButtons();
        var close = PageScaffold.PrimaryButton(Strings.Get("confirm.close"));
        close.Click += (_, _) => Host.Close();
        _buttons.Controls.Add(close);
        close.Focus();
    }

    private void ShowNetworkError()
    {
        _statusLabel.Text = Strings.Get("check.networkError");
        ShowChangelog(false);
        ShowComponents(false);
        ClearButtons();
        var tryAgain = PageScaffold.PrimaryButton(Strings.Get("confirm.tryAgain"));
        tryAgain.Click += (_, _) => Host.SwapPage(new CheckUpdatesPage(Host));
        var close = PageScaffold.SecondaryButton(Strings.Get("confirm.close"));
        close.Click += (_, _) => Host.Close();
        _buttons.Controls.Add(tryAgain);
        _buttons.Controls.Add(close);
        tryAgain.Focus();
    }

    private void ShowGenericError(string message)
    {
        _statusLabel.Text = Strings.Format("error.unhandled", message, Logger.LogPath);
        ShowChangelog(false);
        ShowComponents(false);
        ClearButtons();
        var close = PageScaffold.PrimaryButton(Strings.Get("confirm.close"));
        close.Click += (_, _) => Host.Close();
        _buttons.Controls.Add(close);
        close.Focus();
    }

    private void ClearButtons()
    {
        foreach (Control c in _buttons.Controls)
        {
            c.Dispose();
        }
        _buttons.Controls.Clear();
    }

    private void StartInstall(bool forceAll)
    {
        if (_plan == null || _release == null) return;
        if (GameProcess.IsRunning())
        {
            MessageBox.Show(Host, Strings.Get("confirm.gameRunning"),
                Strings.Get("app.title"), MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        InstallPlan plan = forceAll
            ? _installer.BuildPlan(Host.GameDir!, Host.Profile!.Value, _release, Host.ExistingManifest, forceAll: true)
            : _plan;

        Host.SwapPage(new ProgressPage(Host, plan));
    }

    private void OnUninstallClicked(object? sender, EventArgs e)
    {
        if (Host.GameDir == null) return;
        var confirm = MessageBox.Show(
            Host,
            Strings.Get("confirm.uninstall") + "?",
            Strings.Get("app.title"),
            MessageBoxButtons.OKCancel,
            MessageBoxIcon.Warning);
        if (confirm != DialogResult.OK) return;
        if (GameProcess.IsRunning())
        {
            MessageBox.Show(Host, Strings.Get("confirm.gameRunning"),
                Strings.Get("app.title"), MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }
        Host.SwapPage(new ProgressPage(Host, isUninstall: true));
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _cts.Cancel();
            _cts.Dispose();
            _installer.Dispose();
        }
        base.Dispose(disposing);
    }
}

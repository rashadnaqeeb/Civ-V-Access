using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Runs install/update or uninstall and reports progress. The user can
/// cancel during download (the apply phase is short and not interruptible).
/// </summary>
internal sealed class ProgressPage : WizardPage
{
    private readonly Label _heading;
    private readonly Label _statusLabel;
    private readonly ProgressBar _progressBar;
    private readonly Button _cancelButton;
    private readonly CancellationTokenSource _cts = new();

    private readonly InstallPlan? _plan;
    private readonly bool _isUninstall;
    private readonly Installer.Core.Installer? _installer;

    public ProgressPage(MainForm host, InstallPlan plan) : this(host)
    {
        _plan = plan;
        _isUninstall = false;
        _installer = new Installer.Core.Installer();
        _heading.Text = Strings.Get("progress.heading");
    }

    public ProgressPage(MainForm host, bool isUninstall) : this(host)
    {
        _isUninstall = isUninstall;
        _heading.Text = Strings.Get("uninstall.heading");
    }

    private ProgressPage(MainForm host) : base(host)
    {
        var layout = PageScaffold.BuildLayout(out var buttons);

        var stack = new FlowLayoutPanel
        {
            FlowDirection = FlowDirection.TopDown,
            Dock = DockStyle.Fill,
            AutoSize = true,
            WrapContents = false,
        };

        _heading = PageScaffold.Heading(Strings.Get("progress.heading"));
        _statusLabel = PageScaffold.Paragraph(Strings.Get("progress.preparing"));
        _progressBar = new ProgressBar
        {
            Width = 620,
            Height = 24,
            Style = ProgressBarStyle.Continuous,
            Minimum = 0,
            Maximum = 1000,
            Margin = new System.Windows.Forms.Padding(0, 8, 0, 0),
        };
        _progressBar.AccessibleName = Strings.Get("progress.heading");

        stack.Controls.Add(_heading);
        stack.Controls.Add(_statusLabel);
        stack.Controls.Add(_progressBar);
        layout.Controls.Add(stack, 0, 0);

        _cancelButton = PageScaffold.SecondaryButton(Strings.Get("progress.cancel"));
        _cancelButton.Click += (_, _) =>
        {
            _cancelButton.Enabled = false;
            _cts.Cancel();
        };
        buttons.Controls.Add(_cancelButton);

        Controls.Add(layout);
    }

    public override Control? InitialFocusControl => _cancelButton;

    public override async void OnEntered()
    {
        var progress = new Progress<InstallProgress>(OnProgress);

        try
        {
            if (_isUninstall)
            {
                await UninstallRunner.RunAsync(Host.GameDir!, progress, _cts.Token).ConfigureAwait(true);
                Host.SwapPage(new ResultPage(Host, ResultPage.Outcome.UninstallSuccess, Host.ExistingManifest?.ModVersion));
            }
            else if (_plan != null && _installer != null)
            {
                await _installer.ExecuteAsync(_plan, progress, _cts.Token).ConfigureAwait(true);
                var version = _plan.Release.SemVer.ToString(3);
                var outcome = _plan.IsFreshInstall ? ResultPage.Outcome.InstallSuccess : ResultPage.Outcome.UpdateSuccess;
                Host.SwapPage(new ResultPage(Host, outcome, version));
            }
        }
        catch (OperationCanceledException)
        {
            Logger.Info("Operation cancelled by user.");
            Host.Close();
        }
        catch (Exception ex)
        {
            Logger.Error("Install/uninstall failed", ex);
            Host.SwapPage(new ResultPage(Host, ResultPage.Outcome.Failed, ex.Message));
        }
    }

    private void OnProgress(InstallProgress p)
    {
        var componentName = p.Component?.DisplayName() ?? "";
        string text = p.Stage switch
        {
            InstallStage.Preparing       => Strings.Get("progress.preparing"),
            InstallStage.Downloading     => Strings.Format("progress.downloading", componentName,
                                              FormatBytes(p.BytesSoFar), FormatBytes(p.BytesTotal)),
            InstallStage.Verifying       => Strings.Format("progress.verifying", componentName),
            InstallStage.Extracting      => Strings.Format("progress.extracting", componentName),
            InstallStage.BackingUp       => p.Component == ComponentKind.Cinematics
                                              ? Strings.Get("progress.backingUpCinematics")
                                              : Strings.Get("progress.backingUpEngine"),
            InstallStage.SwappingProxy   => _isUninstall
                                              ? Strings.Get("uninstall.restoringProxy")
                                              : Strings.Get("progress.swappingProxy"),
            InstallStage.WritingManifest => Strings.Get("progress.writingManifest"),
            InstallStage.ClearingCache   => Strings.Get("progress.cleaningCache"),
            InstallStage.RemovingDlc     => Strings.Get("uninstall.removingDlc"),
            InstallStage.RemovingTolk    => Strings.Get("uninstall.removingTolk"),
            InstallStage.Restoring       => p.Component == ComponentKind.Cinematics
                                              ? Strings.Get("uninstall.restoringCinematics")
                                              : Strings.Get("uninstall.restoringEngine"),
            InstallStage.Done            => Strings.Get("progress.applying"),
            _                            => Strings.Get("progress.applying"),
        };

        _statusLabel.Text = text;
        _statusLabel.AccessibleName = text;

        // Progress mapping: during download, mix step progress with byte progress.
        int value;
        if (p.StepCount > 0)
        {
            double stepFraction = (double)p.StepIndex / p.StepCount;
            double withinStep = p.BytesTotal > 0 ? (double)p.BytesSoFar / p.BytesTotal : 0;
            double total = stepFraction + withinStep / Math.Max(p.StepCount, 1);
            value = (int)(Math.Clamp(total, 0, 1) * 1000);
        }
        else
        {
            value = (int)(p.FractionDone * 1000);
        }
        _progressBar.Value = Math.Clamp(value, 0, 1000);
    }

    private static string FormatBytes(long bytes)
    {
        if (bytes < 1024) return Strings.Format("size.bytes", bytes);
        if (bytes < 1024 * 1024) return Strings.Format("size.kb", bytes / 1024);
        return Strings.Format("size.mb", bytes / (1024 * 1024));
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _cts.Cancel();
            _cts.Dispose();
            _installer?.Dispose();
        }
        base.Dispose(disposing);
    }
}

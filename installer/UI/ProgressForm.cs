using System;
using System.Drawing;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// A modal Form that runs an async task while showing a status label and a
/// progress bar (marquee or percentage). The user can press Cancel to
/// signal a CancellationToken; the form closes automatically when the
/// task completes (success, error, or cancellation).
///
/// Two factory entry points: <see cref="RunMarquee{T}"/> for indeterminate
/// "please wait" steps (game-dir detection, GitHub fetch), and
/// <see cref="RunPercentage{T}"/> for steps with measurable progress
/// (download + install).
/// </summary>
internal sealed class ProgressForm : Form
{
    private readonly Label _statusLabel;
    private readonly ProgressBar _progressBar;
    private readonly Button _cancelButton;
    private readonly CancellationTokenSource _cts = new();

    private ProgressForm(string heading, string initialStatus, ProgressBarStyle style)
    {
        Text = Strings.Get("app.title");
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = false;
        ControlBox = false;
        ShowInTaskbar = true;
        ClientSize = new Size(480, 160);
        Font = SystemFonts.MessageBoxFont!;
        AccessibleName = heading;

        var headingLabel = new Label
        {
            Text = heading,
            Font = new Font(SystemFonts.MessageBoxFont!.FontFamily, 11f, FontStyle.Bold),
            AutoSize = false,
            Location = new Point(12, 12),
            Size = new Size(456, 28),
        };

        _statusLabel = new Label
        {
            Text = initialStatus,
            AutoSize = false,
            Location = new Point(12, 48),
            Size = new Size(456, 36),
            AccessibleName = initialStatus,
        };

        _progressBar = new ProgressBar
        {
            Style = style,
            Location = new Point(12, 92),
            Width = 456,
            Height = 22,
            MarqueeAnimationSpeed = style == ProgressBarStyle.Marquee ? 30 : 0,
            Minimum = 0,
            Maximum = 1000,
        };

        _cancelButton = new Button
        {
            Text = Strings.Get("common.cancel"),
            Location = new Point(388, 124),
            Width = 80,
            TabIndex = 0,
            UseVisualStyleBackColor = true,
        };
        _cancelButton.Click += (_, _) =>
        {
            _cancelButton.Enabled = false;
            _cts.Cancel();
        };

        Controls.Add(headingLabel);
        Controls.Add(_statusLabel);
        Controls.Add(_progressBar);
        Controls.Add(_cancelButton);

        CancelButton = _cancelButton;
    }

    public bool WasCancelled => _cts.IsCancellationRequested;

    /// <summary>
    /// Run an indeterminate task with a marquee bar. The status string can
    /// be mutated mid-flight by reporting from the task's IProgress&lt;string&gt;.
    /// Returns the task's result, or default if cancelled.
    /// </summary>
    public static (T? Result, bool Cancelled, Exception? Error) RunMarquee<T>(
        string heading,
        string initialStatus,
        Func<IProgress<string>, CancellationToken, Task<T>> work)
    {
        return Run(heading, initialStatus, ProgressBarStyle.Marquee, async (statusReporter, _, ct) =>
            await work(statusReporter, ct).ConfigureAwait(false));
    }

    /// <summary>
    /// Run a task with measurable progress. The work function receives a
    /// status reporter, a progress reporter (0..1000), and a cancellation token.
    /// </summary>
    public static (T? Result, bool Cancelled, Exception? Error) RunPercentage<T>(
        string heading,
        string initialStatus,
        Func<IProgress<string>, IProgress<int>, CancellationToken, Task<T>> work)
    {
        return Run(heading, initialStatus, ProgressBarStyle.Continuous, work);
    }

    private static (T? Result, bool Cancelled, Exception? Error) Run<T>(
        string heading,
        string initialStatus,
        ProgressBarStyle style,
        Func<IProgress<string>, IProgress<int>, CancellationToken, Task<T>> work)
    {
        using var form = new ProgressForm(heading, initialStatus, style);

        T? result = default;
        Exception? error = null;

        var statusProgress = new Progress<string>(s =>
        {
            form._statusLabel.Text = s;
            form._statusLabel.AccessibleName = s;
        });
        var valueProgress = new Progress<int>(v =>
        {
            int clamped = Math.Clamp(v, form._progressBar.Minimum, form._progressBar.Maximum);
            form._progressBar.Value = clamped;
        });

        // Kick the work off as soon as the form has its handle. Doing this
        // in Shown rather than the constructor avoids the same handle-not-
        // ready trap we hit before, and the task-pool work is well clear
        // of UI-thread state by the time it runs.
        form.Shown += (_, _) =>
        {
            Task.Run(async () =>
            {
                try
                {
                    result = await work(statusProgress, valueProgress, form._cts.Token).ConfigureAwait(false);
                }
                catch (OperationCanceledException) { /* leave Cancelled true */ }
                catch (Exception ex) { error = ex; }
                finally
                {
                    if (form.IsHandleCreated)
                    {
                        form.BeginInvoke(() => form.Close());
                    }
                }
            });
        };

        form.ShowDialog();
        return (result, form.WasCancelled, error);
    }

    protected override void OnFormClosed(FormClosedEventArgs e)
    {
        base.OnFormClosed(e);
        _cts.Dispose();
    }
}

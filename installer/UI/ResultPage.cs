using System;
using System.Diagnostics;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

internal sealed class ResultPage : WizardPage
{
    public enum Outcome
    {
        InstallSuccess,
        UpdateSuccess,
        UninstallSuccess,
        Failed,
    }

    private readonly Outcome _outcome;
    private readonly string? _detail;
    private readonly Label _heading;
    private readonly Label _body;
    private readonly Button _exitButton;
    private readonly Button _logButton;

    public ResultPage(MainForm host, Outcome outcome, string? detail) : base(host)
    {
        _outcome = outcome;
        _detail = detail;

        var layout = PageScaffold.BuildLayout(out var buttons);

        var stack = new FlowLayoutPanel
        {
            FlowDirection = FlowDirection.TopDown,
            Dock = DockStyle.Fill,
            AutoSize = true,
            WrapContents = false,
        };

        _heading = PageScaffold.Heading(GetHeadingText());
        _body = PageScaffold.Paragraph(GetBodyText());
        stack.Controls.Add(_heading);
        stack.Controls.Add(_body);
        layout.Controls.Add(stack, 0, 0);

        _exitButton = PageScaffold.PrimaryButton(Strings.Get("result.exit"));
        _exitButton.Click += (_, _) => Host.Close();
        _logButton = PageScaffold.SecondaryButton(Strings.Get("result.openLog"));
        _logButton.Click += (_, _) => OpenLog();

        buttons.Controls.Add(_exitButton);
        buttons.Controls.Add(_logButton);

        Controls.Add(layout);
    }

    public override Control? InitialFocusControl => _exitButton;

    private string GetHeadingText() => _outcome switch
    {
        Outcome.InstallSuccess   => Strings.Get("result.installSuccess.heading"),
        Outcome.UpdateSuccess    => Strings.Get("result.updateSuccess.heading"),
        Outcome.UninstallSuccess => Strings.Get("result.uninstallSuccess.heading"),
        Outcome.Failed           => Strings.Get("result.failed.heading"),
        _                        => Strings.Get("result.failed.heading"),
    };

    private string GetBodyText() => _outcome switch
    {
        Outcome.InstallSuccess   => Strings.Format("result.installSuccess.body", _detail ?? ""),
        Outcome.UpdateSuccess    => Strings.Format("result.updateSuccess.body", _detail ?? ""),
        Outcome.UninstallSuccess => Strings.Get("result.uninstallSuccess.body"),
        Outcome.Failed           => Strings.Format("result.failed.body", _detail ?? "", Logger.LogPath),
        _                        => Strings.Format("result.failed.body", _detail ?? "", Logger.LogPath),
    };

    public override void OnLocaleChanged()
    {
        _heading.Text = GetHeadingText();
        _heading.AccessibleName = _heading.Text;
        _body.Text = GetBodyText();
        _body.AccessibleName = _body.Text;
        _exitButton.Text = Strings.Get("result.exit");
        _exitButton.AccessibleName = _exitButton.Text.Replace("&", "");
        _logButton.Text = Strings.Get("result.openLog");
        _logButton.AccessibleName = _logButton.Text.Replace("&", "");
    }

    private void OpenLog()
    {
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = Logger.LogPath,
                UseShellExecute = true,
            });
        }
        catch (Exception ex)
        {
            Logger.Warn($"Open log failed: {ex.Message}");
        }
    }
}

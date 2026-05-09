using System;
using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// First-install profile question. Phrased functionally ("How will you use
/// Civ V Access?") rather than categorically. Persisted in the install
/// manifest by the Installer; never re-asked while the manifest is intact.
/// </summary>
internal sealed class ProfilePage : WizardPage
{
    private readonly RadioButton _blindRadio;
    private readonly RadioButton _sightedRadio;
    private readonly Button _continueButton;
    private readonly Label _heading;
    private readonly Label _body;
    private readonly Label _blindDesc;
    private readonly Label _sightedDesc;

    public ProfilePage(MainForm host) : base(host)
    {
        var layout = PageScaffold.BuildLayout(out var buttons);

        var stack = new FlowLayoutPanel
        {
            FlowDirection = FlowDirection.TopDown,
            Dock = DockStyle.Fill,
            AutoSize = true,
            WrapContents = false,
        };

        _heading = PageScaffold.Heading(Strings.Get("profile.heading"));
        _body = PageScaffold.Paragraph(Strings.Get("profile.body"));
        stack.Controls.Add(_heading);
        stack.Controls.Add(_body);

        _blindRadio = new RadioButton
        {
            Text = Strings.Get("profile.optionBlind"),
            AutoSize = true,
            Checked = true,
            Margin = new Padding(0, 8, 0, 0),
            UseMnemonic = false,
        };
        _blindRadio.AccessibleName = _blindRadio.Text;
        _blindRadio.AccessibleDescription = Strings.Get("profile.optionBlindDesc");
        stack.Controls.Add(_blindRadio);

        _blindDesc = new Label
        {
            Text = Strings.Get("profile.optionBlindDesc"),
            AutoSize = true,
            MaximumSize = new Size(620, 0),
            Margin = new Padding(24, 0, 0, 12),
            ForeColor = SystemColors.ControlDarkDark,
        };
        _blindDesc.AccessibleRole = AccessibleRole.StaticText;
        _blindDesc.AccessibleName = _blindDesc.Text;
        stack.Controls.Add(_blindDesc);

        _sightedRadio = new RadioButton
        {
            Text = Strings.Get("profile.optionSighted"),
            AutoSize = true,
            Margin = new Padding(0, 8, 0, 0),
            UseMnemonic = false,
        };
        _sightedRadio.AccessibleName = _sightedRadio.Text;
        _sightedRadio.AccessibleDescription = Strings.Get("profile.optionSightedDesc");
        stack.Controls.Add(_sightedRadio);

        _sightedDesc = new Label
        {
            Text = Strings.Get("profile.optionSightedDesc"),
            AutoSize = true,
            MaximumSize = new Size(620, 0),
            Margin = new Padding(24, 0, 0, 12),
            ForeColor = SystemColors.ControlDarkDark,
        };
        _sightedDesc.AccessibleRole = AccessibleRole.StaticText;
        _sightedDesc.AccessibleName = _sightedDesc.Text;
        stack.Controls.Add(_sightedDesc);

        layout.Controls.Add(stack, 0, 0);

        _continueButton = PageScaffold.PrimaryButton(Strings.Get("profile.continue"));
        _continueButton.Click += OnContinue;
        buttons.Controls.Add(_continueButton);

        Controls.Add(layout);
    }

    public override Control? InitialFocusControl => _blindRadio;

    public override void OnLocaleChanged()
    {
        _heading.Text = Strings.Get("profile.heading");
        _body.Text = Strings.Get("profile.body");
        _blindRadio.Text = Strings.Get("profile.optionBlind");
        _blindRadio.AccessibleName = _blindRadio.Text;
        _blindRadio.AccessibleDescription = Strings.Get("profile.optionBlindDesc");
        _blindDesc.Text = Strings.Get("profile.optionBlindDesc");
        _blindDesc.AccessibleName = _blindDesc.Text;
        _sightedRadio.Text = Strings.Get("profile.optionSighted");
        _sightedRadio.AccessibleName = _sightedRadio.Text;
        _sightedRadio.AccessibleDescription = Strings.Get("profile.optionSightedDesc");
        _sightedDesc.Text = Strings.Get("profile.optionSightedDesc");
        _sightedDesc.AccessibleName = _sightedDesc.Text;
        _continueButton.Text = Strings.Get("profile.continue");
        _continueButton.AccessibleName = _continueButton.Text.Replace("&", "");
    }

    private void OnContinue(object? sender, EventArgs e)
    {
        Host.Profile = _blindRadio.Checked ? InstallProfile.Blind : InstallProfile.Sighted;
        Logger.Info($"Profile chosen: {Host.Profile}");
        Host.SwapPage(new CheckUpdatesPage(Host));
    }
}

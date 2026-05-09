using System;
using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Profile question. Heading + body text + two radio buttons + OK / Cancel.
/// Native RadioButton + Button controls; the screen reader announces both
/// without any AccessibleName plumbing.
/// </summary>
internal sealed class ProfileForm : Form
{
    private readonly RadioButton _blindRadio;
    private readonly RadioButton _sightedRadio;

    public InstallProfile? Selected { get; private set; }

    public ProfileForm()
    {
        Text = Strings.Get("app.title");
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowInTaskbar = true;
        ClientSize = new Size(560, 280);
        Font = SystemFonts.MessageBoxFont!;

        var heading = new Label
        {
            Text = Strings.Get("profile.heading"),
            Font = new Font(SystemFonts.MessageBoxFont!.FontFamily, 11f, FontStyle.Bold),
            AutoSize = false,
            Location = new Point(12, 12),
            Size = new Size(536, 26),
        };

        var body = new Label
        {
            Text = Strings.Get("profile.body"),
            AutoSize = false,
            Location = new Point(12, 44),
            Size = new Size(536, 36),
        };

        _blindRadio = new RadioButton
        {
            Text = Strings.Get("profile.optionBlind"),
            Location = new Point(12, 88),
            Size = new Size(536, 24),
            Checked = true,
            UseVisualStyleBackColor = true,
            TabIndex = 0,
        };
        var blindDesc = new Label
        {
            Text = Strings.Get("profile.optionBlindDesc"),
            Location = new Point(36, 112),
            Size = new Size(512, 36),
            ForeColor = SystemColors.ControlDarkDark,
        };

        _sightedRadio = new RadioButton
        {
            Text = Strings.Get("profile.optionSighted"),
            Location = new Point(12, 152),
            Size = new Size(536, 24),
            UseVisualStyleBackColor = true,
            TabIndex = 1,
        };
        var sightedDesc = new Label
        {
            Text = Strings.Get("profile.optionSightedDesc"),
            Location = new Point(36, 176),
            Size = new Size(512, 36),
            ForeColor = SystemColors.ControlDarkDark,
        };

        var ok = new Button
        {
            Text = Strings.Get("common.ok"),
            DialogResult = DialogResult.OK,
            Location = new Point(388, 232),
            Width = 80,
            TabIndex = 2,
            UseVisualStyleBackColor = true,
        };
        ok.Click += (_, _) =>
        {
            Selected = _blindRadio.Checked ? InstallProfile.Blind : InstallProfile.Sighted;
        };

        var cancel = new Button
        {
            Text = Strings.Get("common.cancel"),
            DialogResult = DialogResult.Cancel,
            Location = new Point(474, 232),
            Width = 80,
            TabIndex = 3,
            UseVisualStyleBackColor = true,
        };

        Controls.Add(heading);
        Controls.Add(body);
        Controls.Add(_blindRadio);
        Controls.Add(blindDesc);
        Controls.Add(_sightedRadio);
        Controls.Add(sightedDesc);
        Controls.Add(ok);
        Controls.Add(cancel);

        AcceptButton = ok;
        CancelButton = cancel;
    }
}

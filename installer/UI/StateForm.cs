using System;
using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Game-state picker. Heading + body + four radio buttons (one per state) with
/// a one-line description each, plus OK / Cancel. Native RadioButton + Button
/// controls; the screen reader announces them without extra plumbing. The
/// current state (on a switch) is preselected.
/// </summary>
internal sealed class StateForm : Form
{
    private static readonly InstallState[] Order =
    {
        InstallState.Vanilla,
        InstallState.VoxPopuli,
        InstallState.CommunityPatch,
        InstallState.LekMod,
    };

    private readonly RadioButton[] _radios = new RadioButton[Order.Length];

    public InstallState? Selected { get; private set; }

    public StateForm(InstallState current)
    {
        Text = Strings.Get("app.title");
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowInTaskbar = true;
        Font = SystemFonts.MessageBoxFont!;

        var heading = new Label
        {
            Text = Strings.Get("statePicker.heading"),
            Font = new Font(SystemFonts.MessageBoxFont!.FontFamily, 11f, FontStyle.Bold),
            AutoSize = false,
            Location = new Point(12, 12),
            Size = new Size(560, 26),
        };
        var body = new Label
        {
            Text = Strings.Get("statePicker.body"),
            AutoSize = false,
            Location = new Point(12, 42),
            Size = new Size(560, 34),
        };
        Controls.Add(heading);
        Controls.Add(body);

        int y = 84;
        for (int i = 0; i < Order.Length; i++)
        {
            var state = Order[i];
            var radio = new RadioButton
            {
                Text = Strings.Get(state.NameKey()),
                Location = new Point(12, y),
                Size = new Size(560, 24),
                Checked = state == current,
                UseVisualStyleBackColor = true,
                TabIndex = i,
            };
            var desc = new Label
            {
                Text = Strings.Get(state.DescKey()),
                Location = new Point(36, y + 24),
                Size = new Size(536, 34),
                ForeColor = SystemColors.ControlDarkDark,
            };
            _radios[i] = radio;
            Controls.Add(radio);
            Controls.Add(desc);
            y += 66;
        }

        var ok = new Button
        {
            Text = Strings.Get("common.ok"),
            DialogResult = DialogResult.OK,
            Location = new Point(412, y + 6),
            Width = 80,
            TabIndex = Order.Length,
            UseVisualStyleBackColor = true,
        };
        ok.Click += (_, _) =>
        {
            for (int i = 0; i < _radios.Length; i++)
            {
                if (_radios[i].Checked) { Selected = Order[i]; break; }
            }
        };
        var cancel = new Button
        {
            Text = Strings.Get("common.cancel"),
            DialogResult = DialogResult.Cancel,
            Location = new Point(498, y + 6),
            Width = 80,
            TabIndex = Order.Length + 1,
            UseVisualStyleBackColor = true,
        };

        Controls.Add(ok);
        Controls.Add(cancel);

        ClientSize = new Size(590, y + 48);
        AcceptButton = ok;
        CancelButton = cancel;
    }
}

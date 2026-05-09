using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Update-succeeded dialog. Same wording as the MessageBox path, plus a
/// read-only multiline text field that holds the changelog slice between the
/// player's previous version and the one just installed. Falls back to the
/// MessageBox path in Flow.ShowSuccess when the slice is empty (e.g. the
/// changelog fetch failed, or the parser could not find any matching entries).
/// </summary>
internal sealed class UpdateSuccessForm : Form
{
    public UpdateSuccessForm(string heading, string body, string changelogSlice)
    {
        Text = Strings.Get("app.title");
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowInTaskbar = true;
        Font = SystemFonts.MessageBoxFont!;

        var headingLabel = new Label
        {
            Text = heading,
            Font = new Font(SystemFonts.MessageBoxFont!.FontFamily, 11f, FontStyle.Bold),
            AutoSize = false,
            Location = new Point(12, 12),
            Size = new Size(516, 26),
        };

        var bodyLabel = new Label
        {
            Text = body,
            AutoSize = false,
            Location = new Point(12, 44),
            Size = new Size(516, 40),
        };

        var changelogHeadingLabel = new Label
        {
            Text = Strings.Get("check.changelogHeading"),
            Font = new Font(SystemFonts.MessageBoxFont!.FontFamily, 9f, FontStyle.Bold),
            AutoSize = false,
            Location = new Point(12, 92),
            Size = new Size(516, 20),
        };

        // Multiline read-only TextBox: standard control NVDA / JAWS read
        // line-by-line with arrow keys. WordWrap so long entries don't
        // require horizontal scrolling.
        var changelogBox = new TextBox
        {
            Multiline = true,
            ReadOnly = true,
            ScrollBars = ScrollBars.Vertical,
            WordWrap = true,
            Text = changelogSlice,
            Location = new Point(12, 116),
            Size = new Size(516, 220),
            BackColor = SystemColors.Window,
            AccessibleName = Strings.Get("check.changelogHeading"),
        };

        var okBtn = new Button
        {
            Text = Strings.Get("common.ok"),
            Location = new Point(428, 348),
            Size = new Size(100, 28),
            UseVisualStyleBackColor = true,
            DialogResult = DialogResult.OK,
        };

        Controls.Add(headingLabel);
        Controls.Add(bodyLabel);
        Controls.Add(changelogHeadingLabel);
        Controls.Add(changelogBox);
        Controls.Add(okBtn);

        ClientSize = new Size(540, 388);
        AcceptButton = okBtn;
        CancelButton = okBtn;
        // Focus the OK button on open so Enter / Esc both close, but Tab
        // lets the user reach the changelog text box to read it.
        ActiveControl = okBtn;
    }
}

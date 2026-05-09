using System;
using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Returning-user dialog. Body text says either "you are up to date" or
/// "an update is available", and the action buttons reflect that:
/// up-to-date offers Reinstall / Uninstall / Close, while
/// update-available adds Update.
/// </summary>
internal sealed class ActionForm : Form
{
    public enum Action { None, Update, Reinstall, Uninstall, Close }

    public Action Result { get; private set; } = Action.None;

    public ActionForm(string heading, string body, bool updateAvailable)
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
            Size = new Size(516, 60),
        };

        Controls.Add(headingLabel);
        Controls.Add(bodyLabel);

        // Build the button row from right to left. Close is rightmost
        // (default keyboard cancel target); the primary action sits leftmost
        // so it's the natural focus on Enter.
        const int buttonRowY = 120;
        const int buttonWidth = 100;
        const int buttonHeight = 28;
        const int buttonGap = 6;
        int x = 528 - buttonWidth;

        var closeBtn = new Button
        {
            Text = Strings.Get("confirm.close").Replace("&", ""),
            Location = new Point(x, buttonRowY),
            Size = new Size(buttonWidth, buttonHeight),
            UseVisualStyleBackColor = true,
            DialogResult = DialogResult.Cancel,
        };
        closeBtn.Click += (_, _) => Result = Action.Close;
        Controls.Add(closeBtn);
        CancelButton = closeBtn;
        x -= buttonWidth + buttonGap;

        var uninstallBtn = new Button
        {
            Text = Strings.Get("confirm.uninstall").Replace("&", ""),
            Location = new Point(x, buttonRowY),
            Size = new Size(buttonWidth, buttonHeight),
            UseVisualStyleBackColor = true,
            DialogResult = DialogResult.OK,
        };
        uninstallBtn.Click += (_, _) => Result = Action.Uninstall;
        Controls.Add(uninstallBtn);
        x -= buttonWidth + buttonGap;

        var reinstallBtn = new Button
        {
            Text = Strings.Get("confirm.reinstall").Replace("&", ""),
            Location = new Point(x, buttonRowY),
            Size = new Size(buttonWidth, buttonHeight),
            UseVisualStyleBackColor = true,
            DialogResult = DialogResult.OK,
        };
        reinstallBtn.Click += (_, _) => Result = Action.Reinstall;
        Controls.Add(reinstallBtn);

        Button primary;
        if (updateAvailable)
        {
            x -= buttonWidth + buttonGap;
            var updateBtn = new Button
            {
                Text = Strings.Get("confirm.update").Replace("&", ""),
                Location = new Point(x, buttonRowY),
                Size = new Size(buttonWidth, buttonHeight),
                UseVisualStyleBackColor = true,
                DialogResult = DialogResult.OK,
            };
            updateBtn.Click += (_, _) => Result = Action.Update;
            Controls.Add(updateBtn);
            primary = updateBtn;
        }
        else
        {
            primary = reinstallBtn;
        }

        ClientSize = new Size(540, 162);
        AcceptButton = primary;
        ActiveControl = primary;
    }
}

using System;
using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Returning-user dialog. Body text says either "you are up to date" or
/// "an update is available" for the current state, and the action buttons
/// reflect that: up-to-date offers Change state / Reinstall / Uninstall /
/// Close, while update-available adds Update as the primary action.
/// </summary>
internal sealed class ActionForm : Form
{
    public enum Action { None, Update, ChangeState, Reinstall, Uninstall, Close }

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

        const int formWidth = 660;

        var headingLabel = new Label
        {
            Text = heading,
            Font = new Font(SystemFonts.MessageBoxFont!.FontFamily, 11f, FontStyle.Bold),
            AutoSize = false,
            Location = new Point(12, 12),
            Size = new Size(formWidth - 24, 26),
        };

        var bodyLabel = new Label
        {
            Text = body,
            AutoSize = false,
            Location = new Point(12, 44),
            Size = new Size(formWidth - 24, 60),
        };

        Controls.Add(headingLabel);
        Controls.Add(bodyLabel);

        // Button row, right to left. Close is rightmost (default cancel
        // target); the primary action sits leftmost so it's the Enter focus.
        const int buttonRowY = 120;
        const int buttonWidth = 120;
        const int buttonHeight = 28;
        const int buttonGap = 6;
        int x = formWidth - 12 - buttonWidth;

        var closeBtn = MakeButton(Strings.Get("confirm.close"), x, buttonRowY, buttonWidth, buttonHeight);
        closeBtn.DialogResult = DialogResult.Cancel;
        closeBtn.Click += (_, _) => Result = Action.Close;
        Controls.Add(closeBtn);
        CancelButton = closeBtn;
        x -= buttonWidth + buttonGap;

        var uninstallBtn = MakeButton(Strings.Get("confirm.uninstall"), x, buttonRowY, buttonWidth, buttonHeight);
        uninstallBtn.DialogResult = DialogResult.OK;
        uninstallBtn.Click += (_, _) => Result = Action.Uninstall;
        Controls.Add(uninstallBtn);
        x -= buttonWidth + buttonGap;

        var reinstallBtn = MakeButton(Strings.Get("confirm.reinstall"), x, buttonRowY, buttonWidth, buttonHeight);
        reinstallBtn.DialogResult = DialogResult.OK;
        reinstallBtn.Click += (_, _) => Result = Action.Reinstall;
        Controls.Add(reinstallBtn);
        x -= buttonWidth + buttonGap;

        var changeStateBtn = MakeButton(Strings.Get("confirm.changeState"), x, buttonRowY, buttonWidth, buttonHeight);
        changeStateBtn.DialogResult = DialogResult.OK;
        changeStateBtn.Click += (_, _) => Result = Action.ChangeState;
        Controls.Add(changeStateBtn);

        Button primary;
        if (updateAvailable)
        {
            x -= buttonWidth + buttonGap;
            var updateBtn = MakeButton(Strings.Get("confirm.update"), x, buttonRowY, buttonWidth, buttonHeight);
            updateBtn.DialogResult = DialogResult.OK;
            updateBtn.Click += (_, _) => Result = Action.Update;
            Controls.Add(updateBtn);
            primary = updateBtn;
        }
        else
        {
            primary = changeStateBtn;
        }

        ClientSize = new Size(formWidth, 162);
        AcceptButton = primary;
        ActiveControl = primary;
    }

    private static Button MakeButton(string text, int x, int y, int w, int h) => new()
    {
        Text = text.Replace("&", ""),
        Location = new Point(x, y),
        Size = new Size(w, h),
        UseVisualStyleBackColor = true,
    };
}

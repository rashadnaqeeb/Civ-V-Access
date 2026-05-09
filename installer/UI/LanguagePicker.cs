using System;
using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// First dialog the user sees on a fresh install. A welcome message plus a
/// native Win32 ComboBox (DropDownList style) listing the 10 supported
/// locales. Pre-selects the system culture's match. OK / Cancel.
/// </summary>
internal sealed class LanguagePicker : Form
{
    private readonly ComboBox _combo;

    public string SelectedCode { get; private set; } = LocaleCatalog.Default;

    public LanguagePicker()
    {
        Text = Strings.Get("app.title");
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowInTaskbar = true;
        ClientSize = new Size(440, 170);
        Font = SystemFonts.MessageBoxFont!;

        var welcome = new Label
        {
            Text = Strings.Get("welcome.welcomeBody"),
            AutoSize = false,
            Location = new Point(12, 12),
            Size = new Size(416, 50),
        };

        var languageLabel = new Label
        {
            Text = Strings.Get("language.dialogTitle") + ":",
            AutoSize = true,
            Location = new Point(12, 70),
        };

        _combo = new ComboBox
        {
            DropDownStyle = ComboBoxStyle.DropDownList,
            Width = 416,
            Location = new Point(12, 92),
            FlatStyle = FlatStyle.System,
            TabIndex = 0,
        };
        foreach (var entry in LocaleCatalog.All)
        {
            _combo.Items.Add(new Item(entry));
            if (entry.Code == Strings.ActiveCode)
            {
                _combo.SelectedIndex = _combo.Items.Count - 1;
            }
        }

        var ok = new Button
        {
            Text = Strings.Get("common.ok"),
            DialogResult = DialogResult.OK,
            Location = new Point(268, 132),
            Width = 80,
            TabIndex = 1,
            UseVisualStyleBackColor = true,
        };
        ok.Click += (_, _) =>
        {
            if (_combo.SelectedItem is Item item)
            {
                SelectedCode = item.Code;
            }
        };

        var cancel = new Button
        {
            Text = Strings.Get("common.cancel"),
            DialogResult = DialogResult.Cancel,
            Location = new Point(354, 132),
            Width = 80,
            TabIndex = 2,
            UseVisualStyleBackColor = true,
        };

        Controls.Add(welcome);
        Controls.Add(languageLabel);
        Controls.Add(_combo);
        Controls.Add(ok);
        Controls.Add(cancel);

        AcceptButton = ok;
        CancelButton = cancel;
    }

    private sealed class Item
    {
        public LocaleCatalog.Entry Entry { get; }
        public string Code => Entry.Code;
        public Item(LocaleCatalog.Entry entry) { Entry = entry; }
        public override string ToString() => Entry.DisplayName;
    }
}

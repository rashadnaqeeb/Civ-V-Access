using System;
using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Tiny modal Form with a single ComboBox listing the 10 supported locales.
/// Used from the welcome TaskDialog's "Change language" hyperlink.
/// ComboBox (DropDownList style) is a native Win32 control - screen
/// readers announce it as a combo box without any AccessibleName plumbing.
/// </summary>
internal sealed class LanguagePicker : Form
{
    private readonly ComboBox _combo;

    public string SelectedCode { get; private set; } = LocaleCatalog.Default;

    public LanguagePicker()
    {
        Text = Strings.Get("language.dialogTitle");
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterParent;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowInTaskbar = false;
        ClientSize = new Size(380, 140);
        Font = SystemFonts.MessageBoxFont!;

        var label = new Label
        {
            Text = Strings.Get("language.dialogTitle"),
            AutoSize = true,
            Location = new Point(12, 12),
        };

        _combo = new ComboBox
        {
            DropDownStyle = ComboBoxStyle.DropDownList,
            Width = 356,
            Location = new Point(12, 40),
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
            Location = new Point(208, 90),
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
            Location = new Point(296, 90),
            Width = 80,
            TabIndex = 2,
            UseVisualStyleBackColor = true,
        };

        Controls.Add(label);
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

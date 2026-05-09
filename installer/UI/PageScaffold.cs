using System.Drawing;
using System.Windows.Forms;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Helpers for building consistent page layouts. Two-row TableLayoutPanel:
/// row 0 stretches and hosts the page body, row 1 is a fixed-height button
/// strip aligned bottom-right.
/// </summary>
internal static class PageScaffold
{
    public static TableLayoutPanel BuildLayout(out FlowLayoutPanel buttonStrip)
    {
        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 2,
            Padding = new Padding(0),
            AutoSize = false,
        };
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.AutoSize));

        buttonStrip = new FlowLayoutPanel
        {
            FlowDirection = FlowDirection.RightToLeft,
            Dock = DockStyle.Fill,
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink,
            Padding = new Padding(0, 12, 0, 0),
            WrapContents = false,
        };
        layout.Controls.Add(buttonStrip, 0, 1);
        return layout;
    }

    public static Label Heading(string text) => new()
    {
        Text = text,
        Font = new Font(SystemFonts.MessageBoxFont!.FontFamily, 14f, FontStyle.Bold),
        AutoSize = true,
        Margin = new Padding(0, 0, 0, 12),
        AccessibleRole = AccessibleRole.StaticText,
        AccessibleName = text,
    };

    public static Label Paragraph(string text) => new()
    {
        Text = text,
        AutoSize = true,
        MaximumSize = new Size(640, 0),
        Margin = new Padding(0, 0, 0, 12),
        AccessibleRole = AccessibleRole.StaticText,
        AccessibleName = text,
    };

    public static Button PrimaryButton(string text)
    {
        var b = new Button
        {
            Text = text,
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink,
            Margin = new Padding(8, 0, 0, 0),
            UseMnemonic = true,
            Padding = new Padding(12, 4, 12, 4),
        };
        b.AccessibleName = text.Replace("&", "");
        return b;
    }

    public static Button SecondaryButton(string text)
    {
        var b = PrimaryButton(text);
        return b;
    }
}

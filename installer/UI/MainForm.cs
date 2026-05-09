using System;
using System.Diagnostics;
using System.Drawing;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

internal sealed class MainForm : Form
{
    private readonly Panel _content;
    private readonly StatusStrip _statusStrip;
    private readonly ToolStripStatusLabel _statusLabel;
    private readonly MenuStrip _menu;
    private readonly ToolStripMenuItem _languageMenuItem;

    private string? _gameDir;
    private InstallManifest? _existingManifest;
    private InstallProfile? _profile;

    public MainForm()
    {
        Text = Strings.Get("app.title");
        StartPosition = FormStartPosition.CenterScreen;
        ClientSize = new Size(700, 520);
        MinimumSize = new Size(640, 480);
        AutoScaleMode = AutoScaleMode.Dpi;
        Font = SystemFonts.MessageBoxFont!;
        AccessibleName = Strings.Get("app.title");
        AccessibleDescription = Strings.Format("app.subtitle", AppVersion.Display);
        KeyPreview = true;

        _menu = BuildMenu(out _languageMenuItem);
        Controls.Add(_menu);
        MainMenuStrip = _menu;

        _statusStrip = new StatusStrip { Dock = DockStyle.Bottom };
        _statusLabel = new ToolStripStatusLabel(Strings.Format("app.subtitle", AppVersion.Display))
        {
            AccessibleName = Strings.Format("app.subtitle", AppVersion.Display),
        };
        _statusStrip.Items.Add(_statusLabel);
        Controls.Add(_statusStrip);

        _content = new Panel
        {
            Dock = DockStyle.Fill,
            Padding = new Padding(20),
            AccessibleName = Strings.Get("app.heading"),
        };
        Controls.Add(_content);

        Strings.LocaleChanged += OnLocaleChanged;

        SwapPage(new WelcomePage(this));
    }

    public void SetStatus(string text)
    {
        _statusLabel.Text = text;
        _statusLabel.AccessibleName = text;
    }

    public void SwapPage(WizardPage page)
    {
        _content.Controls.Clear();
        page.Dock = DockStyle.Fill;
        _content.Controls.Add(page);
        page.OnEntered();

        // Move keyboard focus to the page so a screen reader announces it.
        if (page.InitialFocusControl != null)
        {
            BeginInvoke(() => page.InitialFocusControl.Focus());
        }
    }

    public string? GameDir
    {
        get => _gameDir;
        set => _gameDir = value;
    }

    public InstallManifest? ExistingManifest
    {
        get => _existingManifest;
        set => _existingManifest = value;
    }

    public InstallProfile? Profile
    {
        get => _profile;
        set => _profile = value;
    }

    private MenuStrip BuildMenu(out ToolStripMenuItem languageItem)
    {
        var strip = new MenuStrip { Dock = DockStyle.Top };

        var fileItem = new ToolStripMenuItem(Strings.Get("menu.file"));
        var exitItem = new ToolStripMenuItem(Strings.Get("menu.exit"))
        {
            ShortcutKeys = Keys.Alt | Keys.F4,
            ShowShortcutKeys = false,
        };
        exitItem.Click += (_, _) => Close();
        fileItem.DropDownItems.Add(exitItem);

        languageItem = new ToolStripMenuItem(Strings.Get("menu.language"));
        foreach (var entry in LocaleCatalog.All)
        {
            var captured = entry;
            var sub = new ToolStripMenuItem(captured.DisplayName)
            {
                Tag = captured.Code,
                Checked = captured.Code == Strings.ActiveCode,
            };
            sub.Click += (_, _) => SwitchLanguage(captured.Code);
            languageItem.DropDownItems.Add(sub);
        }

        var helpItem = new ToolStripMenuItem(Strings.Get("menu.help"));
        var viewLogItem = new ToolStripMenuItem(Strings.Get("menu.viewLog"));
        viewLogItem.Click += (_, _) => OpenLog();
        var aboutItem = new ToolStripMenuItem(Strings.Get("menu.about"));
        aboutItem.Click += (_, _) => MessageBox.Show(
            this, Strings.Format("about.body", AppVersion.Display, Logger.LogPath),
            Strings.Get("menu.about"), MessageBoxButtons.OK, MessageBoxIcon.Information);
        helpItem.DropDownItems.Add(viewLogItem);
        helpItem.DropDownItems.Add(aboutItem);

        strip.Items.Add(fileItem);
        strip.Items.Add(languageItem);
        strip.Items.Add(helpItem);
        return strip;
    }

    private void SwitchLanguage(string code)
    {
        Strings.SetLocale(code);
        Logger.Info($"Locale switched to {code}.");
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
            MessageBox.Show(this, Logger.LogPath, Strings.Get("menu.viewLog"));
        }
    }

    private void OnLocaleChanged()
    {
        // Re-localize headers and menu, then ask the current page to re-render.
        Text = Strings.Get("app.title");
        SetStatus(Strings.Format("app.subtitle", AppVersion.Display));
        // Rebuild menu in place (cheaper than fighting WinForms' caching).
        Controls.Remove(_menu);
        var newMenu = BuildMenu(out _);
        Controls.Add(newMenu);
        MainMenuStrip = newMenu;
        if (_content.Controls.Count > 0 && _content.Controls[0] is WizardPage page)
        {
            page.OnLocaleChanged();
        }
    }

    protected override void OnFormClosed(FormClosedEventArgs e)
    {
        Strings.LocaleChanged -= OnLocaleChanged;
        base.OnFormClosed(e);
        Logger.Close();
    }
}

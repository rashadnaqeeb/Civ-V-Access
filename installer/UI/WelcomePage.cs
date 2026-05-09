using System;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;

namespace CivVAccess.Installer.UI;

/// <summary>
/// First page. Auto-detects the Civ V install. If detected and a manifest
/// is present, advances straight to CheckUpdatesPage. If detected and no
/// manifest, advances to ProfilePage. If detection fails, prompts the user
/// to Browse to it.
/// </summary>
internal sealed class WelcomePage : WizardPage
{
    private readonly Label _heading;
    private readonly Label _body;
    private readonly Button _browseButton;
    private readonly Button _continueButton;

    public WelcomePage(MainForm host) : base(host)
    {
        var layout = PageScaffold.BuildLayout(out var buttons);

        var stack = new FlowLayoutPanel
        {
            FlowDirection = FlowDirection.TopDown,
            Dock = DockStyle.Fill,
            AutoSize = true,
            WrapContents = false,
        };
        _heading = PageScaffold.Heading(Strings.Get("welcome.heading"));
        _body = PageScaffold.Paragraph(Strings.Get("welcome.detecting"));
        stack.Controls.Add(_heading);
        stack.Controls.Add(_body);
        layout.Controls.Add(stack, 0, 0);

        _browseButton = PageScaffold.SecondaryButton(Strings.Get("welcome.browse"));
        _browseButton.Click += OnBrowse;
        _browseButton.Visible = false;

        _continueButton = PageScaffold.PrimaryButton(Strings.Get("welcome.continue"));
        _continueButton.Click += OnContinue;
        _continueButton.Visible = false;
        _continueButton.Enabled = false;

        // RightToLeft flow puts these visually right-to-left; primary stays rightmost.
        buttons.Controls.Add(_continueButton);
        buttons.Controls.Add(_browseButton);

        Controls.Add(layout);
    }

    public override Control? InitialFocusControl => _continueButton.Visible ? _continueButton : _browseButton;

    public override async void OnEntered()
    {
        var detected = await Task.Run(GameDetector.AutoDetect);
        if (detected != null && GameDetector.HasBraveNewWorld(detected))
        {
            ProceedWith(detected);
            return;
        }
        if (detected != null && !GameDetector.HasBraveNewWorld(detected))
        {
            _body.Text = Strings.Get("welcome.bnwMissing");
            _body.AccessibleName = _body.Text;
            ShowBrowseUi();
            return;
        }
        _body.Text = Strings.Get("welcome.notFound");
        _body.AccessibleName = _body.Text;
        ShowBrowseUi();
    }

    public override void OnLocaleChanged()
    {
        _heading.Text = Strings.Get("welcome.heading");
        _browseButton.Text = Strings.Get("welcome.browse");
        _continueButton.Text = Strings.Get("welcome.continue");
        _browseButton.AccessibleName = _browseButton.Text.Replace("&", "");
        _continueButton.AccessibleName = _continueButton.Text.Replace("&", "");
    }

    private void ShowBrowseUi()
    {
        _browseButton.Visible = true;
        _browseButton.Focus();
    }

    private void OnBrowse(object? sender, EventArgs e)
    {
        using var dlg = new FolderBrowserDialog
        {
            Description = Strings.Get("welcome.notFound"),
            UseDescriptionForTitle = true,
            ShowNewFolderButton = false,
        };
        var result = dlg.ShowDialog(this);
        if (result != DialogResult.OK) return;
        var path = dlg.SelectedPath;

        if (!GameDetector.LooksLikeCivVInstall(path))
        {
            _body.Text = Strings.Get("welcome.invalidFolder");
            _body.AccessibleName = _body.Text;
            return;
        }
        if (!GameDetector.HasBraveNewWorld(path))
        {
            _body.Text = Strings.Get("welcome.bnwMissing");
            _body.AccessibleName = _body.Text;
            return;
        }
        ProceedWith(path);
    }

    private void ProceedWith(string gameDir)
    {
        Logger.Info($"Resolved game dir: {gameDir}");
        Host.GameDir = gameDir;
        Host.ExistingManifest = InstallManifest.TryRead(gameDir);
        if (Host.ExistingManifest != null)
        {
            Host.Profile = Host.ExistingManifest.Profile;
        }

        // Best-effort: turn on Lua logging in the user's config.ini. The
        // mod's diagnostic surface (Lua.log) only populates when this is on,
        // so we set it whenever we have authority over a confirmed install.
        // If config.ini doesn't exist (game never launched), this is a
        // no-op and the next installer run retries.
        GameConfigIni.TryEnableLogging();

        _body.Text = Strings.Format("welcome.found", gameDir);
        _body.AccessibleName = _body.Text;
        _browseButton.Visible = false;
        _continueButton.Visible = true;
        _continueButton.Enabled = true;
        _continueButton.Focus();
    }

    private void OnContinue(object? sender, EventArgs e)
    {
        if (Host.GameDir == null) return;

        // Fresh install: ask the profile question once. Existing install:
        // skip straight to update check; profile is whatever the manifest
        // says (we already set it in ProceedWith).
        if (Host.ExistingManifest == null)
        {
            Host.SwapPage(new ProfilePage(Host));
        }
        else
        {
            Host.SwapPage(new CheckUpdatesPage(Host));
        }
    }
}

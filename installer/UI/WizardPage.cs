using System.Drawing;
using System.Windows.Forms;

namespace CivVAccess.Installer.UI;

/// <summary>
/// Base class for the swap-in pages of MainForm. Each subclass owns its
/// own controls and lifecycle hooks.
/// </summary>
internal abstract class WizardPage : UserControl
{
    protected MainForm Host { get; }

    protected WizardPage(MainForm host)
    {
        Host = host;
        AutoSize = false;
        Padding = new Padding(0);
        Font = SystemFonts.MessageBoxFont!;
    }

    /// <summary>
    /// Called immediately after the page is added to the form. Overrides
    /// can kick off async work (game-dir detection, GitHub fetch, etc.)
    /// and update controls when results arrive.
    /// </summary>
    public virtual void OnEntered() { }

    /// <summary>Called when the active locale changes.</summary>
    public virtual void OnLocaleChanged() { }

    /// <summary>
    /// The control that should receive focus when the page enters. Setting
    /// this lets a screen reader announce the page heading on entry.
    /// </summary>
    public virtual Control? InitialFocusControl => null;
}

using System;
using System.Globalization;
using System.Threading;
using System.Windows.Forms;
using CivVAccess.Installer.Core;
using CivVAccess.Installer.Localization;
using CivVAccess.Installer.UI;

namespace CivVAccess.Installer;

internal static class Program
{
    [STAThread]
    private static int Main()
    {
        Logger.Init();
        Logger.Info($"Civ V Access Installer {AppVersion.Display} starting.");

        // Match the system UI culture to one of our 10 supported locales, falling
        // back to en_US. The user can change this later via the Language menu.
        var initial = LocaleCatalog.PickForCulture(CultureInfo.CurrentUICulture);
        Strings.SetLocale(initial);

        Application.SetHighDpiMode(HighDpiMode.PerMonitorV2);
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        try
        {
            using var form = new MainForm();
            Application.Run(form);
            return 0;
        }
        catch (Exception ex)
        {
            Logger.Error("Unhandled exception", ex);
            MessageBox.Show(
                Strings.Format("error.unhandled", ex.Message, Logger.LogPath),
                Strings.Get("app.title"),
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return 1;
        }
    }
}

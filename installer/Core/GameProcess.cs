using System.Diagnostics;
using System.Linq;

namespace CivVAccess.Installer.Core;

internal static class GameProcess
{
    private static readonly string[] Names =
    {
        "CivilizationV",
        "CivilizationV_DX11",
    };

    public static bool IsRunning()
    {
        return Names.Any(n => Process.GetProcessesByName(n).Length > 0);
    }
}

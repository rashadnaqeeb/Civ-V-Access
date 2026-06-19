using System.IO;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Canonical paths under a Civ V install. Centralized so deploy.ps1 and
/// the installer can't drift on directory layout.
/// </summary>
internal sealed class GameLayout
{
    public string Root { get; }

    public GameLayout(string gameDir) { Root = gameDir; }

    public string CivExe          => Path.Combine(Root, "CivilizationV.exe");

    // Proxy + Tolk runtime files live at the game root.
    public string Lua51Stock      => Path.Combine(Root, "lua51_Win32.dll");
    public string Lua51Original   => Path.Combine(Root, "lua51_original.dll");
    public string ProxyDebugLog   => Path.Combine(Root, "proxy_debug.log");

    // BNW Expansion2 directory: vanilla engine DLL and stock cinematics live here.
    public string Expansion2Dir   => Path.Combine(Root, "Assets", "DLC", "Expansion2");
    public string EngineDll       => Path.Combine(Expansion2Dir, "CvGameCore_Expansion2.dll");

    // Mod's DLC dir: payload + install manifest.
    public string ModDlcDir       => Path.Combine(Root, "Assets", "DLC", "DLC_CivVAccess");

    // Sibling backup dir; survives ModDlcDir nuke-and-recreate on redeploy.
    public string BackupDir       => Path.Combine(Root, "Assets", "DLC", "DLC_CivVAccess.backup");
    public string EngineBackup    => Path.Combine(BackupDir, "CvGameCore_Expansion2.vanilla.dll");
    public string CinematicsBackupDir => Path.Combine(BackupDir, "cinematics");

    // Mod-state artifacts under Assets/DLC. The baked modpack packages and the
    // LekMod DLC tree; one of each is present only in its own state.
    public string AssetsDlcDir    => Path.Combine(Root, "Assets", "DLC");
    public string ModpackVpDir    => Path.Combine(AssetsDlcDir, "ZCivVAccessVP");
    public string ModpackCpDir    => Path.Combine(AssetsDlcDir, "ZCivVAccessCP");
    public string LekmodDlcDir    => Path.Combine(AssetsDlcDir, "LEKMOD");

    // Vox Populi substrate: the VPUI fake DLC, the swapped always-active BNW
    // Expansion2.Civ5Pkg (and its stock backup), the minor-civ sound table, and
    // the loading-screen tips that live under the Documents tree.
    public string VpuiDir         => Path.Combine(AssetsDlcDir, "VPUI");
    public string Expansion2Civ5Pkg => Path.Combine(Expansion2Dir, "Expansion2.Civ5Pkg");
    public string Civ5PkgStockBackup => Path.Combine(BackupDir, "Expansion2.Civ5Pkg.stock");
    public string MinorCivSoundsXml =>
        Path.Combine(Expansion2Dir, "Sounds", "XML", "MinorCivSounds_VoxPopuli.xml");

    public string Civ5DocsDir =>
        Path.Combine(
            System.Environment.GetFolderPath(System.Environment.SpecialFolder.UserProfile),
            "Documents", "My Games", "Sid Meier's Civilization 5");
    public string VpuiTipsFile => Path.Combine(Civ5DocsDir, "Text", "VPUI_tips_en_us.xml");

    /// <summary>
    /// Marker substring identifying a VP-swapped Expansion2.Civ5Pkg (vs the
    /// stock BNW one). Mirrors the deploy scripts' content probe.
    /// </summary>
    public const string VpCiv5PkgMarker = "MinorCivSounds_VoxPopuli";

    // Engine's DLC enumeration cache. Cleared on install/uninstall so a
    // newly-added or renamed DLC isn't held back by stale cache state.
    public string DlcCacheDir =>
        Path.Combine(
            System.Environment.GetFolderPath(System.Environment.SpecialFolder.UserProfile),
            "Documents", "My Games", "Sid Meier's Civilization 5", "cache");

    // The install manifest path; canonical name CivVAccess.install.json.
    public string InstallManifestPath => InstallManifest.PathFor(Root);

    /// <summary>
    /// Tolk runtime files copied into the game root for the blind profile,
    /// matching deploy.ps1's $tolkFiles + $ourProxyFiles. The installer needs
    /// this list for uninstall (to know what to remove) since the runtime.zip
    /// content is the source of truth on install.
    /// </summary>
    public static readonly string[] RuntimeFiles =
    {
        "lua51_Win32.dll",
        "Tolk.dll",
        "SAAPI32.dll",
        "dolapi32.dll",
        "nvdaControllerClient32.dll",
        "BoyCtrl.dll",
        "boyctrl.ini",
        "ZDSRAPI.dll",
        "ZDSRAPI.ini",
    };

    /// <summary>
    /// BNW opening cinematic filenames the engine looks for under
    /// Expansion2. Mirrors deploy.ps1's $cinematicFiles list.
    /// </summary>
    public static readonly string[] CinematicFiles =
    {
        "Civ5XP2_Opening_Movie_en_US.wmv",
        "Civ5XP2_Opening_Movie_de_DE.wma",
        "Civ5XP2_Opening_Movie_es_ES.wma",
        "Civ5XP2_Opening_Movie_fr_FR.wma",
        "Civ5XP2_Opening_Movie_it_IT.wma",
        "Civ5XP2_Opening_Movie_pl_PL.wma",
        "Civ5XP2_Opening_Movie_ru_RU.wma",
    };

    /// <summary>
    /// Legacy paths from earlier dev iterations that should be removed on
    /// install or uninstall. Mirrors deploy.ps1.
    /// </summary>
    public string[] LegacyPaths()
    {
        var legacyMods = Path.Combine(
            System.Environment.GetFolderPath(System.Environment.SpecialFolder.UserProfile),
            @"Documents\My Games\Sid Meier's Civilization 5\MODS\Civ-V-Access (v 1)");
        return new[]
        {
            Path.Combine(Root, "CivVAccess"),
            Path.Combine(Root, "Assets", "DLC", "CivVAccess"),
            legacyMods,
        };
    }
}

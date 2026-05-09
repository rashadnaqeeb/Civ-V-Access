using System;

namespace CivVAccess.Installer.Core;

/// <summary>
/// Progress events from the install/uninstall orchestrator. The UI marshals
/// them onto the WinForms thread to update a status label and a progress bar.
/// </summary>
internal enum InstallStage
{
    Preparing,
    Downloading,
    Verifying,
    Extracting,
    BackingUp,
    SwappingProxy,
    WritingManifest,
    ClearingCache,
    Restoring,
    RemovingDlc,
    RemovingTolk,
    Done,
}

internal sealed class InstallProgress
{
    public InstallStage Stage { get; init; }
    public ComponentKind? Component { get; init; }
    public string? Message { get; init; }
    public long BytesSoFar { get; init; }
    public long BytesTotal { get; init; }
    public int StepIndex { get; init; }
    public int StepCount { get; init; }

    public double FractionDone => StepCount == 0 ? 0 : (double)StepIndex / StepCount;
}

using System;
using System.IO;
using System.Text;

namespace CivVAccess.Installer.Core;

/// <summary>
/// File-backed logger. Important for screen-reader users: the log captures
/// the full diagnostic trail since the UI surfaces only short summaries.
/// </summary>
internal static class Logger
{
    private static readonly object Lock = new();
    private static StreamWriter? _writer;

    public static string LogPath { get; private set; } = string.Empty;

    public static void Init()
    {
        var dir = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "CivVAccess",
            "Installer",
            "Logs");
        Directory.CreateDirectory(dir);

        LogPath = Path.Combine(dir, $"installer-{DateTime.Now:yyyyMMdd-HHmmss}.log");
        _writer = new StreamWriter(LogPath, append: false, Encoding.UTF8) { AutoFlush = true };
    }

    public static void Info(string message) => Write("INFO ", message, null);
    public static void Warn(string message, Exception? ex = null) => Write("WARN ", message, ex);
    public static void Error(string message, Exception? ex = null) => Write("ERROR", message, ex);
    public static void Debug(string message) => Write("DEBUG", message, null);

    private static void Write(string level, string message, Exception? ex)
    {
        var line = $"{DateTime.Now:HH:mm:ss.fff} [{level}] {message}";
        if (ex != null)
        {
            line += Environment.NewLine + ex;
        }
        lock (Lock)
        {
            _writer?.WriteLine(line);
        }
    }

    public static void Close()
    {
        lock (Lock)
        {
            _writer?.Dispose();
            _writer = null;
        }
    }
}

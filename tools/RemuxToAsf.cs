// Re-mux/transcode any audio or audio+video file into a Civ V-compatible ASF
// (.wma or .wmv) using Media Foundation's Sink Writer. The Sink Writer
// produces files via the ASF Media Sink, which is Microsoft's own ASF muxer
// and emits all the objects (Stream_Bitrate_Properties, Extended_Stream_Properties,
// Compatibility Object, etc.) that DirectShow's WM ASF Reader filter requires.
//
// Build: csc /target:exe /out:RemuxToAsf.exe RemuxToAsf.cs
// Usage: RemuxToAsf.exe <input> <output.wma|.wmv>
//
// Output format is selected by extension:
//   .wma -> WMA Std v9.2, 44.1 kHz / 128 kbps stereo
//   .wmv -> keeps source video stream (transcoded to WMV9), audio re-encoded to WMA Std

using System;
using System.IO;
using System.Runtime.InteropServices;

internal static class RemuxToAsf
{
    // ---- HRESULT / GUID helpers ----
    static void CheckHr(int hr, string what)
    {
        if (hr < 0)
            throw new InvalidOperationException(string.Format("{0} failed: 0x{1:X8}", what, hr));
    }

    static Guid MFMediaType_Audio       = new Guid("73647561-0000-0010-8000-00AA00389B71");
    static Guid MFMediaType_Video       = new Guid("73646976-0000-0010-8000-00AA00389B71");
    static Guid MFAudioFormat_WMAudioV9 = new Guid("00000162-0000-0010-8000-00AA00389B71");
    static Guid MFAudioFormat_WMAudioV8 = new Guid("00000161-0000-0010-8000-00AA00389B71");
    static Guid MFAudioFormat_PCM       = new Guid("00000001-0000-0010-8000-00AA00389B71");
    static Guid MFAudioFormat_Float     = new Guid("00000003-0000-0010-8000-00AA00389B71");
    static Guid MFVideoFormat_WMV3      = new Guid("33564D57-0000-0010-8000-00AA00389B71");

    // MF attribute GUIDs
    static Guid MF_MT_MAJOR_TYPE             = new Guid("48eba18e-f8c9-4687-bf11-0a74c9f96a8f");
    static Guid MF_MT_SUBTYPE                = new Guid("f7e34c9a-42e8-4714-b74b-cb29d72c35e5");
    static Guid MF_MT_AUDIO_NUM_CHANNELS     = new Guid("37e48bf5-645e-4c5b-89de-ada9e29b696a");
    static Guid MF_MT_AUDIO_SAMPLES_PER_SECOND = new Guid("5faeeae7-0290-4c31-9e8a-c534f68d9dba");
    static Guid MF_MT_AUDIO_AVG_BYTES_PER_SECOND = new Guid("1aab75c8-cfef-451c-ab95-ac034b8e1731");
    static Guid MF_MT_AUDIO_BLOCK_ALIGNMENT  = new Guid("322de230-9eeb-43bd-ab7a-ff412251541d");
    static Guid MF_MT_AUDIO_BITS_PER_SAMPLE  = new Guid("f2deb57f-40fa-4764-aa33-ed4f2d1ff669");
    static Guid MF_MT_FRAME_SIZE             = new Guid("1652c33d-d6b2-4012-b834-72030849a37d");
    static Guid MF_MT_FRAME_RATE             = new Guid("c459a2e8-3d2c-4e44-b132-fee5156c7bb0");
    static Guid MF_MT_PIXEL_ASPECT_RATIO     = new Guid("c6376a1e-8d0a-4027-be45-6d9a0ad39bb6");
    static Guid MF_MT_INTERLACE_MODE         = new Guid("e2724bb8-e676-4806-b4b2-a8d6efb44ccd");
    static Guid MF_MT_AVG_BITRATE            = new Guid("20332624-fb0d-4d9e-bd0d-cbf6786c102e");

    const int MF_VERSION = 0x00020070;
    const int MFSTARTUP_FULL = 0;
    const int MF_SOURCE_READER_FIRST_VIDEO_STREAM = unchecked((int)0xFFFFFFFC);
    const int MF_SOURCE_READER_FIRST_AUDIO_STREAM = unchecked((int)0xFFFFFFFD);
    const int MF_SOURCE_READER_ALL_STREAMS        = unchecked((int)0xFFFFFFFE);
    const int MF_SOURCE_READER_ANY_STREAM         = unchecked((int)0xFFFFFFFE);
    const int MF_SOURCE_READERF_ENDOFSTREAM       = 0x00000002;

    // ---- P/Invoke ----
    [DllImport("mfplat.dll")] static extern int MFStartup(int Version, int dwFlags);
    [DllImport("mfplat.dll")] static extern int MFShutdown();
    [DllImport("mfplat.dll")] static extern int MFCreateMediaType(out IMFMediaType ppMFType);
    [DllImport("mfplat.dll")] static extern int MFCreateAttributes(out IMFAttributes ppMFAttributes, int cInitialSize);
    [DllImport("mfreadwrite.dll", CharSet = CharSet.Unicode)]
        static extern int MFCreateSourceReaderFromURL(string pwszURL, IMFAttributes pAttributes, out IMFSourceReader ppSourceReader);
    [DllImport("mfreadwrite.dll", CharSet = CharSet.Unicode)]
        static extern int MFCreateSinkWriterFromURL(string pwszOutputURL, IntPtr pByteStream, IMFAttributes pAttributes, out IMFSinkWriter ppSinkWriter);

    // ---- COM Interfaces (minimal) ----
    [ComImport, Guid("2cd2d921-c447-44a7-a13c-4adabfc247e3"),
     InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMFAttributes
    {
        // We only need GetItem-style queries for the few we use
        int GetItem(ref Guid guidKey, IntPtr pValue);
        int GetItemType(ref Guid guidKey, out int pType);
        int CompareItem(ref Guid guidKey, IntPtr Value, out bool pbResult);
        int Compare(IMFAttributes pTheirs, int MatchType, out bool pbResult);
        int GetUINT32(ref Guid guidKey, out int punValue);
        int GetUINT64(ref Guid guidKey, out long punValue);
        int GetDouble(ref Guid guidKey, out double pfValue);
        int GetGUID(ref Guid guidKey, out Guid pguidValue);
        int GetStringLength(ref Guid guidKey, out int pcchLength);
        int GetString(ref Guid guidKey, [MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pwszValue, int cchBufSize, IntPtr pcchLength);
        int GetAllocatedString(ref Guid guidKey, out IntPtr ppwszValue, out int pcchLength);
        int GetBlobSize(ref Guid guidKey, out int pcbBlobSize);
        int GetBlob(ref Guid guidKey, [Out] byte[] pBuf, int cbBufSize, out int pcbBlobSize);
        int GetAllocatedBlob(ref Guid guidKey, out IntPtr ppBuf, out int pcbSize);
        int GetUnknown(ref Guid guidKey, ref Guid riid, out IntPtr ppv);
        int SetItem(ref Guid guidKey, IntPtr Value);
        int DeleteItem(ref Guid guidKey);
        int DeleteAllItems();
        int SetUINT32(ref Guid guidKey, int unValue);
        int SetUINT64(ref Guid guidKey, long unValue);
        int SetDouble(ref Guid guidKey, double fValue);
        int SetGUID(ref Guid guidKey, ref Guid guidValue);
        int SetString(ref Guid guidKey, [MarshalAs(UnmanagedType.LPWStr)] string wszValue);
        int SetBlob(ref Guid guidKey, byte[] pBuf, int cbBufSize);
        int SetUnknown(ref Guid guidKey, IntPtr pUnknown);
        int LockStore();
        int UnlockStore();
        int GetCount(out int pcItems);
        int GetItemByIndex(int unIndex, out Guid pguidKey, IntPtr pValue);
        int CopyAllItems(IMFAttributes pDest);
    }

    [ComImport, Guid("44ae0fa8-ea31-4109-8d2e-4cae4997c555"),
     InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMFMediaType : IMFAttributes
    {
        // inherit all IMFAttributes methods, plus:
        new int GetItem(ref Guid guidKey, IntPtr pValue);
        new int GetItemType(ref Guid guidKey, out int pType);
        new int CompareItem(ref Guid guidKey, IntPtr Value, out bool pbResult);
        new int Compare(IMFAttributes pTheirs, int MatchType, out bool pbResult);
        new int GetUINT32(ref Guid guidKey, out int punValue);
        new int GetUINT64(ref Guid guidKey, out long punValue);
        new int GetDouble(ref Guid guidKey, out double pfValue);
        new int GetGUID(ref Guid guidKey, out Guid pguidValue);
        new int GetStringLength(ref Guid guidKey, out int pcchLength);
        new int GetString(ref Guid guidKey, [MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder pwszValue, int cchBufSize, IntPtr pcchLength);
        new int GetAllocatedString(ref Guid guidKey, out IntPtr ppwszValue, out int pcchLength);
        new int GetBlobSize(ref Guid guidKey, out int pcbBlobSize);
        new int GetBlob(ref Guid guidKey, [Out] byte[] pBuf, int cbBufSize, out int pcbBlobSize);
        new int GetAllocatedBlob(ref Guid guidKey, out IntPtr ppBuf, out int pcbSize);
        new int GetUnknown(ref Guid guidKey, ref Guid riid, out IntPtr ppv);
        new int SetItem(ref Guid guidKey, IntPtr Value);
        new int DeleteItem(ref Guid guidKey);
        new int DeleteAllItems();
        new int SetUINT32(ref Guid guidKey, int unValue);
        new int SetUINT64(ref Guid guidKey, long unValue);
        new int SetDouble(ref Guid guidKey, double fValue);
        new int SetGUID(ref Guid guidKey, ref Guid guidValue);
        new int SetString(ref Guid guidKey, [MarshalAs(UnmanagedType.LPWStr)] string wszValue);
        new int SetBlob(ref Guid guidKey, byte[] pBuf, int cbBufSize);
        new int SetUnknown(ref Guid guidKey, IntPtr pUnknown);
        new int LockStore();
        new int UnlockStore();
        new int GetCount(out int pcItems);
        new int GetItemByIndex(int unIndex, out Guid pguidKey, IntPtr pValue);
        new int CopyAllItems(IMFAttributes pDest);
        int GetMajorType(out Guid pguidMajorType);
        int IsCompressedFormat(out bool pfCompressed);
        int IsEqual(IMFMediaType pIMediaType, out int pdwFlags);
        int GetRepresentation(Guid guidRepresentation, out IntPtr ppvRepresentation);
        int FreeRepresentation(Guid guidRepresentation, IntPtr pvRepresentation);
    }

    [ComImport, Guid("c40a00f2-b93a-4d80-ae8c-5a1c634f58e4"),
     InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMFSample
    {
        // We don't call any methods directly on samples — we just hand them off.
    }

    [ComImport, Guid("70ae66f2-c809-4e4f-8915-bdcb406b7993"),
     InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMFSourceReader
    {
        int GetStreamSelection(int dwStreamIndex, out bool pfSelected);
        int SetStreamSelection(int dwStreamIndex, bool fSelected);
        int GetNativeMediaType(int dwStreamIndex, int dwMediaTypeIndex, out IMFMediaType ppMediaType);
        int GetCurrentMediaType(int dwStreamIndex, out IMFMediaType ppMediaType);
        int SetCurrentMediaType(int dwStreamIndex, IntPtr pdwReserved, IMFMediaType pMediaType);
        int SetCurrentPosition(ref Guid guidTimeFormat, IntPtr varPosition);
        int ReadSample(int dwStreamIndex, int dwControlFlags, out int pdwActualStreamIndex, out int pdwStreamFlags, out long pllTimestamp, out IMFSample ppSample);
        int Flush(int dwStreamIndex);
        int GetServiceForStream(int dwStreamIndex, ref Guid guidService, ref Guid riid, out IntPtr ppvObject);
        int GetPresentationAttribute(int dwStreamIndex, ref Guid guidAttribute, IntPtr pvarAttribute);
    }

    [ComImport, Guid("3137f1cd-fe5e-4805-a5d8-fb477448cb3d"),
     InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMFSinkWriter
    {
        int AddStream(IMFMediaType pTargetMediaType, out int pdwStreamIndex);
        int SetInputMediaType(int dwStreamIndex, IMFMediaType pInputMediaType, IMFAttributes pEncodingParameters);
        int BeginWriting();
        int WriteSample(int dwStreamIndex, IMFSample pSample);
        int SendStreamTick(int dwStreamIndex, long llTimestamp);
        int PlaceMarker(int dwStreamIndex, IntPtr pvContext);
        int NotifyEndOfSegment(int dwStreamIndex);
        int Flush(int dwStreamIndex);
        int Finalize_();
        int GetServiceForStream(int dwStreamIndex, ref Guid guidService, ref Guid riid, out IntPtr ppvObject);
        int GetStatistics(int dwStreamIndex, IntPtr pStats);
    }

    static IMFMediaType MakeAudioOutputType()
    {
        // Minimal output type — let MF pick block alignment, bits-per-sample, etc.
        // for the WMA encoder. We only fix codec, channels, sample rate, bitrate.
        IMFMediaType t;
        CheckHr(MFCreateMediaType(out t), "MFCreateMediaType(audio out)");
        Guid maj = MFMediaType_Audio;     CheckHr(t.SetGUID(ref MF_MT_MAJOR_TYPE, ref maj), "audio MAJOR_TYPE");
        Guid sub = MFAudioFormat_WMAudioV8; CheckHr(t.SetGUID(ref MF_MT_SUBTYPE, ref sub), "audio SUBTYPE");
        CheckHr(t.SetUINT32(ref MF_MT_AUDIO_NUM_CHANNELS, 2), "AUDIO_NUM_CHANNELS");
        CheckHr(t.SetUINT32(ref MF_MT_AUDIO_SAMPLES_PER_SECOND, 44100), "AUDIO_SAMPLES_PER_SECOND");
        CheckHr(t.SetUINT32(ref MF_MT_AUDIO_AVG_BYTES_PER_SECOND, 16000), "AUDIO_AVG_BYTES_PER_SECOND"); // 128 kbps
        return t;
    }

    static IMFMediaType MakeAudioInputType()
    {
        // Tell the encoder we'll feed it 44.1k stereo 16-bit PCM. The Source Reader
        // will decode whatever the input is into this format.
        IMFMediaType t;
        CheckHr(MFCreateMediaType(out t), "MFCreateMediaType(audio in)");
        Guid maj = MFMediaType_Audio; CheckHr(t.SetGUID(ref MF_MT_MAJOR_TYPE, ref maj), "audio in MAJOR_TYPE");
        Guid sub = MFAudioFormat_PCM; CheckHr(t.SetGUID(ref MF_MT_SUBTYPE, ref sub), "audio in SUBTYPE");
        CheckHr(t.SetUINT32(ref MF_MT_AUDIO_NUM_CHANNELS, 2), "in NUM_CHANNELS");
        CheckHr(t.SetUINT32(ref MF_MT_AUDIO_SAMPLES_PER_SECOND, 44100), "in SAMPLES_PER_SECOND");
        CheckHr(t.SetUINT32(ref MF_MT_AUDIO_BITS_PER_SAMPLE, 16), "in BITS_PER_SAMPLE");
        CheckHr(t.SetUINT32(ref MF_MT_AUDIO_BLOCK_ALIGNMENT, 4), "in BLOCK_ALIGNMENT");
        CheckHr(t.SetUINT32(ref MF_MT_AUDIO_AVG_BYTES_PER_SECOND, 44100 * 4), "in AVG_BYTES_PER_SECOND");
        return t;
    }

    static IMFMediaType MakeVideoOutputType(IMFMediaType srcType)
    {
        // WMV9 main profile, copy frame size and frame rate from source.
        IMFMediaType t;
        CheckHr(MFCreateMediaType(out t), "MFCreateMediaType(video out)");
        Guid maj = MFMediaType_Video; CheckHr(t.SetGUID(ref MF_MT_MAJOR_TYPE, ref maj), "video MAJOR_TYPE");
        Guid sub = MFVideoFormat_WMV3; CheckHr(t.SetGUID(ref MF_MT_SUBTYPE, ref sub), "video SUBTYPE");
        CheckHr(t.SetUINT32(ref MF_MT_AVG_BITRATE, 3000000), "AVG_BITRATE");
        CheckHr(t.SetUINT32(ref MF_MT_INTERLACE_MODE, 2 /* Progressive */), "INTERLACE_MODE");

        long frameSize, frameRate, par;
        if (srcType.GetUINT64(ref MF_MT_FRAME_SIZE, out frameSize) >= 0)
            t.SetUINT64(ref MF_MT_FRAME_SIZE, frameSize);
        if (srcType.GetUINT64(ref MF_MT_FRAME_RATE, out frameRate) >= 0)
            t.SetUINT64(ref MF_MT_FRAME_RATE, frameRate);
        if (srcType.GetUINT64(ref MF_MT_PIXEL_ASPECT_RATIO, out par) >= 0)
            t.SetUINT64(ref MF_MT_PIXEL_ASPECT_RATIO, par);
        return t;
    }

    static int Main(string[] args)
    {
        if (args.Length != 2)
        {
            Console.Error.WriteLine("Usage: RemuxToAsf.exe <input> <output.wma|.wmv>");
            return 1;
        }
        string inputPath = Path.GetFullPath(args[0]);
        string outputPath = Path.GetFullPath(args[1]);
        string outExt = Path.GetExtension(outputPath).ToLowerInvariant();
        bool wantVideo = (outExt == ".wmv");

        Console.WriteLine("Input:  " + inputPath);
        Console.WriteLine("Output: " + outputPath + " (video=" + wantVideo + ")");

        CheckHr(MFStartup(MF_VERSION, MFSTARTUP_FULL), "MFStartup");
        try
        {
            IMFSourceReader reader;
            CheckHr(MFCreateSourceReaderFromURL(inputPath, null, out reader), "MFCreateSourceReaderFromURL");

            // Remux strategy: do NOT call SetCurrentMediaType on the source. The
            // reader will deliver compressed samples in their native codec, and we
            // tell the sink writer to take the same compressed format on input.
            // The ASF Media Sink then writes proper ASF objects around the existing
            // (ffmpeg-encoded) audio stream — no transcoding, no encoder needed.
            IMFMediaType audioNative;
            CheckHr(reader.GetNativeMediaType(MF_SOURCE_READER_FIRST_AUDIO_STREAM, 0, out audioNative),
                    "GetNativeMediaType(audio)");
            Guid audioSubtype;
            audioNative.GetGUID(ref MF_MT_SUBTYPE, out audioSubtype);
            Console.WriteLine("  source audio subtype: " + audioSubtype);

            IMFMediaType videoNative = null;
            if (wantVideo)
            {
                int hr = reader.GetNativeMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM, 0, out videoNative);
                if (hr < 0)
                    throw new InvalidOperationException("Output requested .wmv but input has no video stream.");
            }

            IMFSinkWriter writer;
            CheckHr(MFCreateSinkWriterFromURL(outputPath, IntPtr.Zero, null, out writer),
                    "MFCreateSinkWriterFromURL");

            // Audio stream: same compressed format on both ends — pass-through
            int audioStreamIndex;
            CheckHr(writer.AddStream(audioNative, out audioStreamIndex), "AddStream(audio passthrough)");
            CheckHr(writer.SetInputMediaType(audioStreamIndex, audioNative, null), "SetInputMediaType(audio passthrough)");

            int videoStreamIndex = -1;
            if (wantVideo)
            {
                CheckHr(writer.AddStream(videoNative, out videoStreamIndex), "AddStream(video passthrough)");
                CheckHr(writer.SetInputMediaType(videoStreamIndex, videoNative, null), "SetInputMediaType(video passthrough)");
            }

            CheckHr(writer.BeginWriting(), "BeginWriting");

            // Pump samples from each stream until end-of-stream.
            int srcAudioIndex = MF_SOURCE_READER_FIRST_AUDIO_STREAM;
            int srcVideoIndex = MF_SOURCE_READER_FIRST_VIDEO_STREAM;
            bool audioDone = false, videoDone = !wantVideo;

            long lastReport = 0;
            while (!audioDone || !videoDone)
            {
                if (!audioDone)
                {
                    int actual, flags; long ts; IMFSample sample;
                    int hr = reader.ReadSample(srcAudioIndex, 0, out actual, out flags, out ts, out sample);
                    if (hr < 0) throw new InvalidOperationException(string.Format("ReadSample(audio) 0x{0:X8}", hr));
                    if ((flags & MF_SOURCE_READERF_ENDOFSTREAM) != 0) audioDone = true;
                    if (sample != null) CheckHr(writer.WriteSample(audioStreamIndex, sample), "WriteSample(audio)");
                    if (sample != null && ts - lastReport > 50000000) // every 5s
                    {
                        Console.WriteLine(string.Format("  audio t={0:F1}s", ts / 10000000.0));
                        lastReport = ts;
                    }
                    if (sample != null) Marshal.ReleaseComObject(sample);
                }
                if (wantVideo && !videoDone)
                {
                    int actual, flags; long ts; IMFSample sample;
                    int hr = reader.ReadSample(srcVideoIndex, 0, out actual, out flags, out ts, out sample);
                    if (hr < 0) throw new InvalidOperationException(string.Format("ReadSample(video) 0x{0:X8}", hr));
                    if ((flags & MF_SOURCE_READERF_ENDOFSTREAM) != 0) videoDone = true;
                    if (sample != null) CheckHr(writer.WriteSample(videoStreamIndex, sample), "WriteSample(video)");
                    if (sample != null) Marshal.ReleaseComObject(sample);
                }
            }

            CheckHr(writer.Finalize_(), "Finalize_");
            Marshal.ReleaseComObject(writer);
            Marshal.ReleaseComObject(reader);
            Console.WriteLine("Done.");
            return 0;
        }
        finally
        {
            MFShutdown();
        }
    }
}

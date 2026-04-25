/**
 *  Product:        Tolk
 *  File:           ScreenReaderDriverBOY.h
 *  Description:    Driver for the BOY screen reader.
 *  Copyright:      (c) 2024, qt06<qt06.com@gmail.com>
 *  License:        LGPLv3
 */

#include "ScreenReaderDriverBOY.h"
#include <windows.h>
#include <string>
#include <algorithm>
#include <cwctype>
#include <fstream>

typedef void(__stdcall *BoyCtrlSetAnyKeyStopSpeakingFunc)(bool);

extern "C" IMAGE_DOS_HEADER __ImageBase;

static int g_speakCompleteReason = -1;

static bool g_speakParam1 = false;
static bool g_speakParam2 = false;
static bool g_speakParam3 = false;
static bool g_stopSpeakValue = false;
static bool g_enableAnyKeyStopFunc = false;

static bool ReadBoolFromIniStrict(const wchar_t* section, const wchar_t* key, bool& outValue, const std::wstring& iniPath)
{
    wchar_t buf[16] = {0};
    GetPrivateProfileStringW(section, key, L"", buf, 16, iniPath.c_str());
    std::wstring val(buf);
    val.erase(std::remove_if(val.begin(), val.end(), [](wchar_t ch){ return std::iswspace(ch) != 0; }), val.end());
    std::transform(val.begin(), val.end(), val.begin(), ::towlower);
    if (val == L"true" || val == L"1")  { outValue = true;  return true; }
    if (val == L"false" || val == L"0") { outValue = false; return true; }
    return false;
}

static bool FileExists(const std::wstring& path)
{
    std::ifstream f(path.c_str());
    return f.good();
}

static void LoadBoyCtrlConfig()
{
    wchar_t modulePath[MAX_PATH] = {0};
    GetModuleFileNameW((HINSTANCE)&__ImageBase, modulePath, MAX_PATH);
    std::wstring dir(modulePath);
    size_t pos = dir.find_last_of(L"\\/");
    if (pos != std::wstring::npos) {
        dir = dir.substr(0, pos + 1);
    }
    std::wstring iniPath = dir + L"boyctrl.ini";

    if (!FileExists(iniPath)) {
        wchar_t cwd[MAX_PATH] = {0};
        GetCurrentDirectoryW(MAX_PATH, cwd);
        iniPath = std::wstring(cwd) + L"\\boyctrl.ini";
    }

    ReadBoolFromIniStrict(L"Config", L"Param1", g_speakParam1, iniPath);
    ReadBoolFromIniStrict(L"Config", L"Param2", g_speakParam2, iniPath);
    ReadBoolFromIniStrict(L"Config", L"Param3", g_speakParam3, iniPath);
    ReadBoolFromIniStrict(L"Config", L"Param4", g_enableAnyKeyStopFunc, iniPath);
    g_stopSpeakValue = g_speakParam1;
}

void __stdcall SpeakCompleteCallback(int reason)
{
    g_speakCompleteReason = reason;
}

ScreenReaderDriverBOY::ScreenReaderDriverBOY()
    : ScreenReaderDriver(L"BoyPCReader", true, false)
#ifdef _WIN64
    , controller(LoadLibrary(L"BoyCtrl-x64.dll"))
#else
    , controller(LoadLibrary(L"BoyCtrl.dll"))
#endif
    , BoyInit(nullptr)
    , BoyUninit(nullptr)
    , BoyIsRunning(nullptr)
    , BoySpeak(nullptr)
    , BoyStopSpeak(nullptr)
{
    if (!controller) {
        return;
    }

    LoadBoyCtrlConfig();

    BoyInit      = reinterpret_cast<BoyCtrlInitialize>(   GetProcAddress(controller, "BoyCtrlInitialize"));
    BoyUninit    = reinterpret_cast<BoyCtrlUninitialize>( GetProcAddress(controller, "BoyCtrlUninitialize"));
    BoyIsRunning = reinterpret_cast<BoyCtrlIsReaderRunning>(GetProcAddress(controller, "BoyCtrlIsReaderRunning"));
    BoySpeak     = reinterpret_cast<BoyCtrlSpeak>(        GetProcAddress(controller, "BoyCtrlSpeak"));
    BoyStopSpeak = reinterpret_cast<BoyCtrlStopSpeaking>(GetProcAddress(controller, "BoyCtrlStopSpeaking"));

    if (BoyInit) {
        BoyInit(nullptr);
    }

    auto pAnyKeyStop = reinterpret_cast<BoyCtrlSetAnyKeyStopSpeakingFunc>(
        GetProcAddress(controller, "BoyCtrlSetAnyKeyStopSpeaking"));

    if (g_enableAnyKeyStopFunc && pAnyKeyStop) {
        pAnyKeyStop(g_stopSpeakValue);
    }
}

ScreenReaderDriverBOY::~ScreenReaderDriverBOY()
{
    if (!controller) {
        return;
    }

    if (BoyUninit) {
        BoyUninit();
    }

    FreeLibrary(controller);
}

bool ScreenReaderDriverBOY::Speak(const wchar_t* str, bool /*interrupt*/)
{
    g_speakCompleteReason = -1;
    if (BoySpeak) {
        return (BoySpeak(str, g_speakParam1, g_speakParam2, g_speakParam3, SpeakCompleteCallback) == 0);
    }
    return false;
}

bool ScreenReaderDriverBOY::Braille(const wchar_t* /*str*/)
{
    return false;
}

bool ScreenReaderDriverBOY::Silence()
{
    if (BoyStopSpeak) {
        BoyStopSpeak(g_stopSpeakValue);
        g_speakCompleteReason = 3;
        return true;
    }
    return false;
}

bool ScreenReaderDriverBOY::IsSpeaking()
{
    return (g_speakCompleteReason == -1);
}

bool ScreenReaderDriverBOY::IsActive()
{
    return (BoyIsRunning ? BoyIsRunning() : false);
}

bool ScreenReaderDriverBOY::Output(const wchar_t* str, bool interrupt)
{
    bool spoke    = Speak(str, interrupt);
    bool brailled = Braille(str);
    return (spoke || brailled);
}

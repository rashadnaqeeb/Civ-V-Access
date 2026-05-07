/*
 * Lua 5.1 Proxy DLL for Civilization V Accessibility
 *
 * Replaces lua51_Win32.dll. Forwards all calls to lua51_original.dll,
 * hooks luaL_openlibs to inject Tolk screen reader bindings into every Lua
 * state, and hooks lua_setfenv to propagate the tolk and civvaccess_shared
 * tables into every sandboxed environment. The accessibility payload itself
 * ships as a DLC at Assets/DLC/DLC_CivVAccess/ and is ingested natively by
 * the engine at boot; the proxy does not activate any mod.
 */
#pragma comment(lib, "User32.lib")
#pragma comment(lib, "Ole32.lib")

#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>

/* === miniaudio single-header library ===
   Only WAV decoding is enabled; we disable encoding / generation / null backend
   and the non-WAV decoders to keep the DLL size down. Implementation macro
   lives here (proxy.c is the only TU in this DLL). */
#define MA_NO_ENCODING
#define MA_NO_GENERATION
#define MA_NO_NULL
#define MA_NO_MP3
#define MA_NO_FLAC
#define MA_NO_VORBIS
#define MINIAUDIO_IMPLEMENTATION
#include "../../third_party/miniaudio/miniaudio.h"

/* === Lua constants === */
#define LUA_GLOBALSINDEX (-10002)
#define LUA_TNIL 0

/* === Minimal Lua types === */
typedef struct lua_State lua_State;
typedef int (*lua_CFunction)(lua_State *L);
typedef void * (*lua_Alloc)(void *ud, void *ptr, size_t osize, size_t nsize);
typedef struct luaL_Reg { const char *name; lua_CFunction func; } luaL_Reg;

/* Accessibility DLC GUID (Assets/DLC/DLC_CivVAccess/CivVAccess_2.Civ5Pkg).
   Retained here only as a comment anchor; the proxy no longer activates
   the DLC -- it is ingested natively by the engine at boot. */
/* {40A9DF7B-AE9F-48DB-ABB5-44AFE0420524} */

/* === Debug log === */
static FILE *g_logfile = NULL;

static void proxy_log(const char *fmt, ...) {
    if (!g_logfile) return;
    va_list ap;
    va_start(ap, fmt);
    vfprintf(g_logfile, fmt, ap);
    va_end(ap);
    fflush(g_logfile);
}

/* === Original DLL === */
static HMODULE hOriginal = NULL;
static HINSTANCE g_hProxyDll = NULL;
static int g_stateCounter = 0;

/* === Function pointer table for ALL exports === */
static FARPROC orig[128] = {0};

/* Index enum - order must match export_names[] exactly */
enum {
    I_luaL_addlstring, I_luaL_addstring, I_luaL_addvalue, I_luaL_argerror,
    I_luaL_buffinit, I_luaL_callmeta, I_luaL_checkany, I_luaL_checkinteger,
    I_luaL_checklstring, I_luaL_checknumber, I_luaL_checkoption, I_luaL_checkstack,
    I_luaL_checktype, I_luaL_checkudata, I_luaL_error, I_luaL_findtable,
    I_luaL_getmetafield, I_luaL_gsub, I_luaL_loadbuffer, I_luaL_loadfile,
    I_luaL_loadstring, I_luaL_newmetatable, I_luaL_newstate, I_luaL_openlib,
    I_luaL_openlibs, I_luaL_optinteger, I_luaL_optlstring, I_luaL_optnumber,
    I_luaL_prepbuffer, I_luaL_pushresult, I_luaL_ref, I_luaL_register,
    I_luaL_typerror, I_luaL_unref, I_luaL_where,
    I_lua_atpanic, I_lua_call, I_lua_checkstack, I_lua_close, I_lua_concat,
    I_lua_cpcall, I_lua_createtable, I_lua_dump, I_lua_equal, I_lua_error,
    I_lua_gc, I_lua_getallocf, I_lua_getfenv, I_lua_getfield, I_lua_gethook,
    I_lua_gethookcount, I_lua_gethookmask, I_lua_getinfo, I_lua_getlocal,
    I_lua_getmetatable, I_lua_getstack, I_lua_gettable, I_lua_gettop,
    I_lua_getupvalue, I_lua_insert, I_lua_iscfunction, I_lua_isnumber,
    I_lua_isstring, I_lua_isuserdata, I_lua_lessthan, I_lua_load,
    I_lua_newstate, I_lua_newthread, I_lua_newuserdata, I_lua_next,
    I_lua_objlen, I_lua_pcall, I_lua_pushboolean, I_lua_pushcclosure,
    I_lua_pushfstring, I_lua_pushinteger, I_lua_pushlightuserdata, I_lua_pushlstring,
    I_lua_pushnil, I_lua_pushnumber, I_lua_pushstring, I_lua_pushthread,
    I_lua_pushvalue, I_lua_pushvfstring, I_lua_rawequal, I_lua_rawget,
    I_lua_rawgeti, I_lua_rawset, I_lua_rawseti, I_lua_remove, I_lua_replace,
    I_lua_resume, I_lua_setallocf, I_lua_setfenv, I_lua_setfield, I_lua_sethook,
    I_lua_setlevel, I_lua_setlocal, I_lua_setmetatable, I_lua_settable,
    I_lua_settop, I_lua_setupvalue, I_lua_status, I_lua_toboolean,
    I_lua_tocfunction, I_lua_tointeger, I_lua_tolstring, I_lua_tonumber,
    I_lua_topointer, I_lua_tothread, I_lua_touserdata, I_lua_type,
    I_lua_typename, I_lua_xmove, I_lua_yield,
    I_COUNT
};

static const char *export_names[] = {
    "luaL_addlstring", "luaL_addstring", "luaL_addvalue", "luaL_argerror",
    "luaL_buffinit", "luaL_callmeta", "luaL_checkany", "luaL_checkinteger",
    "luaL_checklstring", "luaL_checknumber", "luaL_checkoption", "luaL_checkstack",
    "luaL_checktype", "luaL_checkudata", "luaL_error", "luaL_findtable",
    "luaL_getmetafield", "luaL_gsub", "luaL_loadbuffer", "luaL_loadfile",
    "luaL_loadstring", "luaL_newmetatable", "luaL_newstate", "luaL_openlib",
    "luaL_openlibs", "luaL_optinteger", "luaL_optlstring", "luaL_optnumber",
    "luaL_prepbuffer", "luaL_pushresult", "luaL_ref", "luaL_register",
    "luaL_typerror", "luaL_unref", "luaL_where",
    "lua_atpanic", "lua_call", "lua_checkstack", "lua_close", "lua_concat",
    "lua_cpcall", "lua_createtable", "lua_dump", "lua_equal", "lua_error",
    "lua_gc", "lua_getallocf", "lua_getfenv", "lua_getfield", "lua_gethook",
    "lua_gethookcount", "lua_gethookmask", "lua_getinfo", "lua_getlocal",
    "lua_getmetatable", "lua_getstack", "lua_gettable", "lua_gettop",
    "lua_getupvalue", "lua_insert", "lua_iscfunction", "lua_isnumber",
    "lua_isstring", "lua_isuserdata", "lua_lessthan", "lua_load",
    "lua_newstate", "lua_newthread", "lua_newuserdata", "lua_next",
    "lua_objlen", "lua_pcall", "lua_pushboolean", "lua_pushcclosure",
    "lua_pushfstring", "lua_pushinteger", "lua_pushlightuserdata", "lua_pushlstring",
    "lua_pushnil", "lua_pushnumber", "lua_pushstring", "lua_pushthread",
    "lua_pushvalue", "lua_pushvfstring", "lua_rawequal", "lua_rawget",
    "lua_rawgeti", "lua_rawset", "lua_rawseti", "lua_remove", "lua_replace",
    "lua_resume", "lua_setallocf", "lua_setfenv", "lua_setfield", "lua_sethook",
    "lua_setlevel", "lua_setlocal", "lua_setmetatable", "lua_settable",
    "lua_settop", "lua_setupvalue", "lua_status", "lua_toboolean",
    "lua_tocfunction", "lua_tointeger", "lua_tolstring", "lua_tonumber",
    "lua_topointer", "lua_tothread", "lua_touserdata", "lua_type",
    "lua_typename", "lua_xmove", "lua_yield"
};

/* === Naked jump trampolines for forwarded functions === */
#define TRAMPOLINE(name, idx) \
    __declspec(naked) void __cdecl _fwd_##name(void) { \
        __asm { jmp dword ptr [orig + idx * 4] } \
    }

TRAMPOLINE(luaL_addlstring, 0)   TRAMPOLINE(luaL_addstring, 1)
TRAMPOLINE(luaL_addvalue, 2)     TRAMPOLINE(luaL_argerror, 3)
TRAMPOLINE(luaL_buffinit, 4)     TRAMPOLINE(luaL_callmeta, 5)
TRAMPOLINE(luaL_checkany, 6)     TRAMPOLINE(luaL_checkinteger, 7)
TRAMPOLINE(luaL_checklstring, 8) TRAMPOLINE(luaL_checknumber, 9)
TRAMPOLINE(luaL_checkoption, 10) TRAMPOLINE(luaL_checkstack, 11)
TRAMPOLINE(luaL_checktype, 12)   TRAMPOLINE(luaL_checkudata, 13)
TRAMPOLINE(luaL_error, 14)       TRAMPOLINE(luaL_findtable, 15)
TRAMPOLINE(luaL_getmetafield, 16) TRAMPOLINE(luaL_gsub, 17)
TRAMPOLINE(luaL_loadbuffer, 18)  TRAMPOLINE(luaL_loadfile, 19)
TRAMPOLINE(luaL_loadstring, 20)  TRAMPOLINE(luaL_newmetatable, 21)
/* 22 = luaL_newstate - hooked */
TRAMPOLINE(luaL_openlib, 23)
/* 24 = luaL_openlibs - hooked */
TRAMPOLINE(luaL_optinteger, 25)  TRAMPOLINE(luaL_optlstring, 26)
TRAMPOLINE(luaL_optnumber, 27)   TRAMPOLINE(luaL_prepbuffer, 28)
TRAMPOLINE(luaL_pushresult, 29)  TRAMPOLINE(luaL_ref, 30)
TRAMPOLINE(luaL_register, 31)    TRAMPOLINE(luaL_typerror, 32)
TRAMPOLINE(luaL_unref, 33)       TRAMPOLINE(luaL_where, 34)
TRAMPOLINE(lua_atpanic, 35)      TRAMPOLINE(lua_call, 36)
TRAMPOLINE(lua_checkstack, 37)   TRAMPOLINE(lua_close, 38)
TRAMPOLINE(lua_concat, 39)       TRAMPOLINE(lua_cpcall, 40)
TRAMPOLINE(lua_createtable, 41)  TRAMPOLINE(lua_dump, 42)
TRAMPOLINE(lua_equal, 43)        TRAMPOLINE(lua_error, 44)
TRAMPOLINE(lua_gc, 45)           TRAMPOLINE(lua_getallocf, 46)
TRAMPOLINE(lua_getfenv, 47)      TRAMPOLINE(lua_getfield, 48)
TRAMPOLINE(lua_gethook, 49)      TRAMPOLINE(lua_gethookcount, 50)
TRAMPOLINE(lua_gethookmask, 51)  TRAMPOLINE(lua_getinfo, 52)
TRAMPOLINE(lua_getlocal, 53)     TRAMPOLINE(lua_getmetatable, 54)
TRAMPOLINE(lua_getstack, 55)     TRAMPOLINE(lua_gettable, 56)
TRAMPOLINE(lua_gettop, 57)       TRAMPOLINE(lua_getupvalue, 58)
TRAMPOLINE(lua_insert, 59)       TRAMPOLINE(lua_iscfunction, 60)
TRAMPOLINE(lua_isnumber, 61)     TRAMPOLINE(lua_isstring, 62)
TRAMPOLINE(lua_isuserdata, 63)   TRAMPOLINE(lua_lessthan, 64)
TRAMPOLINE(lua_load, 65)
/* 66 = lua_newstate - hooked */
TRAMPOLINE(lua_newthread, 67)    TRAMPOLINE(lua_newuserdata, 68)
TRAMPOLINE(lua_next, 69)         TRAMPOLINE(lua_objlen, 70)
TRAMPOLINE(lua_pcall, 71)        TRAMPOLINE(lua_pushboolean, 72)
TRAMPOLINE(lua_pushcclosure, 73) TRAMPOLINE(lua_pushfstring, 74)
TRAMPOLINE(lua_pushinteger, 75)  TRAMPOLINE(lua_pushlightuserdata, 76)
TRAMPOLINE(lua_pushlstring, 77)  TRAMPOLINE(lua_pushnil, 78)
TRAMPOLINE(lua_pushnumber, 79)   TRAMPOLINE(lua_pushstring, 80)
TRAMPOLINE(lua_pushthread, 81)   TRAMPOLINE(lua_pushvalue, 82)
TRAMPOLINE(lua_pushvfstring, 83) TRAMPOLINE(lua_rawequal, 84)
TRAMPOLINE(lua_rawget, 85)       TRAMPOLINE(lua_rawgeti, 86)
TRAMPOLINE(lua_rawset, 87)       TRAMPOLINE(lua_rawseti, 88)
TRAMPOLINE(lua_remove, 89)       TRAMPOLINE(lua_replace, 90)
TRAMPOLINE(lua_resume, 91)       TRAMPOLINE(lua_setallocf, 92)
/* 93 = lua_setfenv - hooked */
TRAMPOLINE(lua_setfield, 94)
TRAMPOLINE(lua_sethook, 95)      TRAMPOLINE(lua_setlevel, 96)
TRAMPOLINE(lua_setlocal, 97)     TRAMPOLINE(lua_setmetatable, 98)
TRAMPOLINE(lua_settable, 99)     TRAMPOLINE(lua_settop, 100)
TRAMPOLINE(lua_setupvalue, 101)  TRAMPOLINE(lua_status, 102)
TRAMPOLINE(lua_toboolean, 103)   TRAMPOLINE(lua_tocfunction, 104)
TRAMPOLINE(lua_tointeger, 105)   TRAMPOLINE(lua_tolstring, 106)
TRAMPOLINE(lua_tonumber, 107)    TRAMPOLINE(lua_topointer, 108)
TRAMPOLINE(lua_tothread, 109)    TRAMPOLINE(lua_touserdata, 110)
TRAMPOLINE(lua_type, 111)        TRAMPOLINE(lua_typename, 112)
TRAMPOLINE(lua_xmove, 113)       TRAMPOLINE(lua_yield, 114)

/* === Typed pointers for functions we call directly === */
typedef void (__cdecl *pfn_luaL_register)(lua_State *, const char *, const luaL_Reg *);
typedef const char * (__cdecl *pfn_luaL_checklstring)(lua_State *, int, size_t *);
typedef int (__cdecl *pfn_lua_toboolean)(lua_State *, int);
typedef void (__cdecl *pfn_lua_pushboolean)(lua_State *, int);
typedef void (__cdecl *pfn_lua_pushnil)(lua_State *);
typedef void (__cdecl *pfn_lua_pushstring)(lua_State *, const char *);
typedef int (__cdecl *pfn_lua_gettop)(lua_State *);
typedef void (__cdecl *pfn_lua_settop)(lua_State *, int);
typedef void (__cdecl *pfn_lua_getfield)(lua_State *, int, const char *);
typedef void (__cdecl *pfn_lua_setfield)(lua_State *, int, const char *);
typedef int (__cdecl *pfn_lua_type)(lua_State *, int);
typedef void (__cdecl *pfn_lua_createtable)(lua_State *, int, int);
typedef ptrdiff_t lua_Integer;
typedef void (__cdecl *pfn_lua_pushinteger)(lua_State *, lua_Integer);
typedef lua_Integer (__cdecl *pfn_lua_tointeger)(lua_State *, int);
typedef double (__cdecl *pfn_lua_tonumber)(lua_State *, int);

#define ORIG_luaL_register  ((pfn_luaL_register)orig[I_luaL_register])
#define ORIG_luaL_checklstring ((pfn_luaL_checklstring)orig[I_luaL_checklstring])
#define ORIG_lua_toboolean  ((pfn_lua_toboolean)orig[I_lua_toboolean])
#define ORIG_lua_pushboolean ((pfn_lua_pushboolean)orig[I_lua_pushboolean])
#define ORIG_lua_pushnil    ((pfn_lua_pushnil)orig[I_lua_pushnil])
#define ORIG_lua_pushstring ((pfn_lua_pushstring)orig[I_lua_pushstring])
#define ORIG_lua_gettop     ((pfn_lua_gettop)orig[I_lua_gettop])
#define ORIG_lua_settop     ((pfn_lua_settop)orig[I_lua_settop])
#define ORIG_lua_getfield   ((pfn_lua_getfield)orig[I_lua_getfield])
#define ORIG_lua_setfield   ((pfn_lua_setfield)orig[I_lua_setfield])
#define ORIG_lua_type       ((pfn_lua_type)orig[I_lua_type])
#define ORIG_lua_createtable ((pfn_lua_createtable)orig[I_lua_createtable])
#define ORIG_lua_pushinteger ((pfn_lua_pushinteger)orig[I_lua_pushinteger])
#define ORIG_lua_tointeger   ((pfn_lua_tointeger)orig[I_lua_tointeger])
#define ORIG_lua_tonumber    ((pfn_lua_tonumber)orig[I_lua_tonumber])

/* === Tolk === */
static HMODULE hTolk = NULL;
static int g_tolkInit = 0;

typedef void (__cdecl *pfnTolk_Load)(void);
typedef void (__cdecl *pfnTolk_Unload)(void);
typedef void (__cdecl *pfnTolk_TrySAPI)(int);
typedef void (__cdecl *pfnTolk_PreferSAPI)(int);
typedef const wchar_t * (__cdecl *pfnTolk_DetectScreenReader)(void);
typedef int (__cdecl *pfnTolk_HasSpeech)(void);
typedef int (__cdecl *pfnTolk_HasBraille)(void);
typedef int (__cdecl *pfnTolk_Output)(const wchar_t *, int);
typedef int (__cdecl *pfnTolk_Speak)(const wchar_t *, int);
typedef int (__cdecl *pfnTolk_Braille)(const wchar_t *);
typedef int (__cdecl *pfnTolk_Silence)(void);
typedef int (__cdecl *pfnTolk_IsLoaded)(void);
typedef int (__cdecl *pfnTolk_IsSpeaking)(void);

static pfnTolk_Load pTolk_Load;
static pfnTolk_Unload pTolk_Unload;
static pfnTolk_TrySAPI pTolk_TrySAPI;
static pfnTolk_PreferSAPI pTolk_PreferSAPI;
static pfnTolk_DetectScreenReader pTolk_DetectScreenReader;
static pfnTolk_HasSpeech pTolk_HasSpeech;
static pfnTolk_HasBraille pTolk_HasBraille;
static pfnTolk_Output pTolk_Output;
static pfnTolk_Speak pTolk_Speak;
static pfnTolk_Braille pTolk_Braille;
static pfnTolk_Silence pTolk_Silence;
static pfnTolk_IsLoaded pTolk_IsLoaded;
static pfnTolk_IsSpeaking pTolk_IsSpeaking;

static wchar_t *utf8_to_wide(const char *s) {
    int n = MultiByteToWideChar(CP_UTF8, 0, s, -1, NULL, 0);
    wchar_t *w = (wchar_t *)malloc(n * sizeof(wchar_t));
    if (w) MultiByteToWideChar(CP_UTF8, 0, s, -1, w, n);
    return w;
}

static char *wide_to_utf8(const wchar_t *w) {
    int n = WideCharToMultiByte(CP_UTF8, 0, w, -1, NULL, 0, NULL, NULL);
    char *s = (char *)malloc(n);
    if (s) WideCharToMultiByte(CP_UTF8, 0, w, -1, s, n, NULL, NULL);
    return s;
}

static void ensure_tolk(void) {
    if (g_tolkInit) return;
    if (!pTolk_Load) return;
    proxy_log("ensure_tolk: initializing Tolk\n");
    pTolk_TrySAPI(1);
    pTolk_PreferSAPI(0);
    pTolk_Load();
    g_tolkInit = 1;
    proxy_log("ensure_tolk: done\n");
}

/* Lua-callable Tolk wrappers */
static int lt_load(lua_State *L)    { ensure_tolk(); return 0; }
static int lt_unload(lua_State *L)  { if(pTolk_Unload) pTolk_Unload(); g_tolkInit=0; return 0; }
static int lt_trySAPI(lua_State *L) { if(pTolk_TrySAPI) pTolk_TrySAPI(ORIG_lua_toboolean(L,1)); return 0; }
static int lt_preferSAPI(lua_State *L) { if(pTolk_PreferSAPI) pTolk_PreferSAPI(ORIG_lua_toboolean(L,1)); return 0; }

static int lt_detectScreenReader(lua_State *L) {
    ensure_tolk();
    const wchar_t *name = pTolk_DetectScreenReader ? pTolk_DetectScreenReader() : NULL;
    if (name) { char *u=wide_to_utf8(name); if(u){ORIG_lua_pushstring(L,u);free(u);} else ORIG_lua_pushnil(L); }
    else ORIG_lua_pushnil(L);
    return 1;
}

static int lt_hasSpeech(lua_State *L) { ensure_tolk(); ORIG_lua_pushboolean(L, pTolk_HasSpeech?pTolk_HasSpeech():0); return 1; }
static int lt_hasBraille(lua_State *L) { ensure_tolk(); ORIG_lua_pushboolean(L, pTolk_HasBraille?pTolk_HasBraille():0); return 1; }

static int lt_output(lua_State *L) {
    ensure_tolk();
    const char *s = ORIG_luaL_checklstring(L,1,NULL);
    int intr = ORIG_lua_toboolean(L,2);
    int r = 0;
    if (pTolk_Output && s) { wchar_t *w=utf8_to_wide(s); if(w){r=pTolk_Output(w,intr);free(w);} }
    ORIG_lua_pushboolean(L,r); return 1;
}

static int lt_speak(lua_State *L) {
    ensure_tolk();
    const char *s = ORIG_luaL_checklstring(L,1,NULL);
    int intr = ORIG_lua_toboolean(L,2);
    int r = 0;
    if (pTolk_Speak && s) { wchar_t *w=utf8_to_wide(s); if(w){r=pTolk_Speak(w,intr);free(w);} }
    ORIG_lua_pushboolean(L,r); return 1;
}

static int lt_braille(lua_State *L) {
    ensure_tolk();
    const char *s = ORIG_luaL_checklstring(L,1,NULL);
    int r = 0;
    if (pTolk_Braille && s) { wchar_t *w=utf8_to_wide(s); if(w){r=pTolk_Braille(w);free(w);} }
    ORIG_lua_pushboolean(L,r); return 1;
}

static int lt_silence(lua_State *L) { ensure_tolk(); ORIG_lua_pushboolean(L, pTolk_Silence?pTolk_Silence():0); return 1; }
static int lt_isLoaded(lua_State *L) { ORIG_lua_pushboolean(L, pTolk_IsLoaded?pTolk_IsLoaded():0); return 1; }
static int lt_isSpeaking(lua_State *L) { ensure_tolk(); ORIG_lua_pushboolean(L, pTolk_IsSpeaking?pTolk_IsSpeaking():0); return 1; }

static const luaL_Reg tolk_funcs[] = {
    {"load",lt_load}, {"unload",lt_unload}, {"trySAPI",lt_trySAPI},
    {"preferSAPI",lt_preferSAPI}, {"detectScreenReader",lt_detectScreenReader},
    {"hasSpeech",lt_hasSpeech}, {"hasBraille",lt_hasBraille},
    {"output",lt_output}, {"speak",lt_speak}, {"braille",lt_braille},
    {"silence",lt_silence}, {"isLoaded",lt_isLoaded}, {"isSpeaking",lt_isSpeaking},
    {NULL,NULL}
};

static void register_tolk(lua_State *L) {
    proxy_log("register_tolk: L=%p\n", (void*)L);
    int top = ORIG_lua_gettop(L);
    ORIG_luaL_register(L, "tolk", tolk_funcs);
    ORIG_lua_settop(L, top);
    proxy_log("register_tolk: done\n");
}

static void register_civvaccess_shared(lua_State *L) {
    int top = ORIG_lua_gettop(L);
    ORIG_lua_getfield(L, LUA_GLOBALSINDEX, "civvaccess_shared");
    if (ORIG_lua_type(L, -1) != LUA_TNIL) {
        ORIG_lua_settop(L, top);
        return;
    }
    ORIG_lua_settop(L, -2); /* pop nil */
    ORIG_lua_createtable(L, 0, 4);
    ORIG_lua_setfield(L, LUA_GLOBALSINDEX, "civvaccess_shared");
    ORIG_lua_settop(L, top);
    proxy_log("register_civvaccess_shared: L=%p done\n", (void*)L);
}

/* === Audio (miniaudio) ===
   Per-hex terrain cues. Spike surface: audio.load(name) preloads a WAV from
   <gameDir>/Assets/DLC/DLC_CivVAccess/Sounds/<name>.wav and returns an integer
   handle; audio.play(handle) rewinds and plays the preloaded sound. The
   engine is lazy-initialized on first load to keep DllMain free of heavy
   work, and is deliberately NOT uninited on DLL detach -- miniaudio's audio
   thread must not be joined under the loader lock. */

#define AUDIO_BANK_SIZE      32
#define AUDIO_BANK_NAME_MAX  64

static int       g_audioInit = 0;
static ma_engine g_audioEngine;
static ma_sound  g_audioBank[AUDIO_BANK_SIZE];
static int       g_audioBankInUse[AUDIO_BANK_SIZE];
static char      g_audioBankName[AUDIO_BANK_SIZE][AUDIO_BANK_NAME_MAX];
static char      g_soundsDir[MAX_PATH];

static int ensure_audio(void) {
    ma_engine_config engineConfig;
    ma_result r;
    if (g_audioInit) return 1;
    if (g_soundsDir[0] == 0) {
        proxy_log("ensure_audio: g_soundsDir empty, cannot init\n");
        return 0;
    }
    /* Force stereo output. With NULL config the engine inherits the device's
       channel count, which is normally 2 but isn't guaranteed -- and the
       per-sound panner silently no-ops when its channel count is 1
       (miniaudio source line 51227, ma_panner_process_pcm_frames falls
       through to ma_copy_pcm_frames on the channels==1 branch with a comment
       that "panning has no effect on mono streams"). The panner's channel
       count is taken from the engine_node's output channels, which is taken
       from ma_engine_get_channels(pEngine). Pinning channels=2 here makes
       ma_sound_set_pan reliable across audio device configurations. */
    engineConfig = ma_engine_config_init();
    engineConfig.channels = 2;
    r = ma_engine_init(&engineConfig, &g_audioEngine);
    if (r != MA_SUCCESS) {
        proxy_log("ensure_audio: ma_engine_init FAILED r=%d\n", (int)r);
        return 0;
    }
    /* Master volume default. The engine slider from the game UI does not
       reach us -- our mixer runs outside the engine's audio pipeline -- so
       this is the user-perceived master until a mod-side volume control
       lands in the future config menu. */
    ma_engine_set_volume(&g_audioEngine, 0.1f);
    g_audioInit = 1;
    proxy_log("ensure_audio: engine initialized stereo, master=0.1, soundsDir=%s\n", g_soundsDir);
    return 1;
}

/* Allocate a fresh bank slot and decode <name>.wav into it. Returns the
   slot index on success or -1 on failure (bank full, path overflow, decode
   failure). Caller is responsible for any name-dedup it wants; this helper
   always allocates a new slot, so beacon voices that share one WAV file
   can each have their own ma_sound and therefore independent pan / pitch /
   volume. */
static int audio_alloc_slot(const char *name) {
    int i, slot = -1, n;
    char path[MAX_PATH];
    ma_result r;

    for (i = 0; i < AUDIO_BANK_SIZE; i++) {
        if (!g_audioBankInUse[i]) { slot = i; break; }
    }
    if (slot < 0) {
        proxy_log("audio_alloc_slot: bank full, name=%s\n", name);
        return -1;
    }

    n = _snprintf(path, MAX_PATH - 1, "%s\\%s.wav", g_soundsDir, name);
    if (n < 0 || n >= MAX_PATH) {
        proxy_log("audio_alloc_slot: path overflow name=%s\n", name);
        return -1;
    }
    path[MAX_PATH - 1] = '\0';

    /* MA_SOUND_FLAG_NO_SPATIALIZATION is required for ma_sound_set_pan
       to take effect: miniaudio's 3D spatializer is on by default, and
       since both source and listener default to the origin, the
       spatializer washes ma_sound_set_pan's value to zero (the sound
       and listener are co-located). PlotAudio sounds run with pan=0
       (no API caller writes to them), so the only behavioural change
       there is that the same default routing now flows through the
       panner stage instead of the spatializer -- both centered, both
       2D. Beacons need this flag for the pan API to work at all. */
    r = ma_sound_init_from_file(&g_audioEngine, path,
                                MA_SOUND_FLAG_DECODE | MA_SOUND_FLAG_NO_SPATIALIZATION,
                                NULL, NULL,
                                &g_audioBank[slot]);
    if (r != MA_SUCCESS) {
        proxy_log("audio_alloc_slot: ma_sound_init_from_file FAILED name=%s path=%s r=%d\n",
                  name, path, (int)r);
        return -1;
    }
    g_audioBankInUse[slot] = 1;
    strncpy(g_audioBankName[slot], name, AUDIO_BANK_NAME_MAX - 1);
    g_audioBankName[slot][AUDIO_BANK_NAME_MAX - 1] = '\0';
    proxy_log("audio_alloc_slot: name=%s slot=%d path=%s\n", name, slot, path);
    return slot;
}

static int la_load(lua_State *L) {
    const char *name = ORIG_luaL_checklstring(L, 1, NULL);
    int i, slot;

    if (!ensure_audio()) { ORIG_lua_pushnil(L); return 1; }

    /* Dedup: repeated loads of the same name return the existing slot so
       callers can freely call audio.load at different points in boot
       (spike + PlotAudio.loadAll + future config menu) without burning
       bank slots or creating multiple decoded copies of the same WAV.
       Beacons want independent voices for one WAV and use load_voice. */
    for (i = 0; i < AUDIO_BANK_SIZE; i++) {
        if (g_audioBankInUse[i] && strcmp(g_audioBankName[i], name) == 0) {
            ORIG_lua_pushinteger(L, i);
            return 1;
        }
    }

    slot = audio_alloc_slot(name);
    if (slot < 0) {
        ORIG_lua_pushnil(L);
        return 1;
    }
    ORIG_lua_pushinteger(L, slot);
    return 1;
}

/* Same as load but never dedups: every call decodes a fresh ma_sound into
   its own slot, even when the WAV file has already been loaded under
   another slot. The point is independent runtime parameters (pan, pitch,
   volume) per voice, which a shared ma_sound cannot give us. Beacons
   allocate one voice per bookmark slot at boot. */
static int la_load_voice(lua_State *L) {
    const char *name = ORIG_luaL_checklstring(L, 1, NULL);
    int slot;
    if (!ensure_audio()) { ORIG_lua_pushnil(L); return 1; }
    slot = audio_alloc_slot(name);
    if (slot < 0) {
        ORIG_lua_pushnil(L);
        return 1;
    }
    ORIG_lua_pushinteger(L, slot);
    return 1;
}

/* Re-arms a bank slot so the next start fires cleanly regardless of whether
   the sound finished naturally, is currently playing, or has a pending
   future-start scheduled. Stop is a no-op on an already-stopped sound, and
   clearing the start time to 0 (in the past) tells miniaudio "start now" on
   the next ma_sound_start unless a later set_start_time overrides it. */
static void audio_rearm_slot(int slot) {
    ma_sound_stop(&g_audioBank[slot]);
    ma_sound_seek_to_pcm_frame(&g_audioBank[slot], 0);
    ma_sound_set_start_time_in_milliseconds(&g_audioBank[slot], 0);
}

static int la_play(lua_State *L) {
    lua_Integer slot = ORIG_lua_tointeger(L, 1);
    ma_result r;

    if (!g_audioInit) return 0;
    if (slot < 0 || slot >= AUDIO_BANK_SIZE || !g_audioBankInUse[slot]) {
        proxy_log("la_play: invalid slot=%d\n", (int)slot);
        return 0;
    }
    audio_rearm_slot((int)slot);
    r = ma_sound_start(&g_audioBank[slot]);
    if (r != MA_SUCCESS) {
        proxy_log("la_play: ma_sound_start FAILED slot=%d r=%d\n",
                  (int)slot, (int)r);
    }
    return 0;
}

static int la_play_delayed(lua_State *L) {
    lua_Integer slot = ORIG_lua_tointeger(L, 1);
    lua_Integer ms   = ORIG_lua_tointeger(L, 2);
    ma_uint64 now;
    ma_result r;

    if (!g_audioInit) return 0;
    if (slot < 0 || slot >= AUDIO_BANK_SIZE || !g_audioBankInUse[slot]) {
        proxy_log("la_play_delayed: invalid slot=%d\n", (int)slot);
        return 0;
    }
    if (ms < 0) ms = 0;
    audio_rearm_slot((int)slot);
    now = ma_engine_get_time_in_milliseconds(&g_audioEngine);
    ma_sound_set_start_time_in_milliseconds(&g_audioBank[slot],
                                            now + (ma_uint64)ms);
    r = ma_sound_start(&g_audioBank[slot]);
    if (r != MA_SUCCESS) {
        proxy_log("la_play_delayed: start FAILED slot=%d ms=%d r=%d\n",
                  (int)slot, (int)ms, (int)r);
    }
    return 0;
}

/* Cancels every in-flight transient sound but leaves looping voices
   alone. Looping is the marker for "long-running voice, leave me alone"
   (beacons set it at boot); transient cues like the per-hex terrain
   palette never set it and are stopped here. PlotAudio.emit calls
   cancel_all on every cursor move, so without the looping skip beacon
   voices would be silenced once per cursor step. */
static int la_cancel_all(lua_State *L) {
    int i;
    (void)L;
    if (!g_audioInit) return 0;
    for (i = 0; i < AUDIO_BANK_SIZE; i++) {
        if (g_audioBankInUse[i] && !ma_sound_is_looping(&g_audioBank[i])) {
            ma_sound_stop(&g_audioBank[i]);
        }
    }
    return 0;
}

static int la_stop(lua_State *L) {
    lua_Integer slot = ORIG_lua_tointeger(L, 1);
    if (!g_audioInit) return 0;
    if (slot < 0 || slot >= AUDIO_BANK_SIZE || !g_audioBankInUse[slot]) {
        proxy_log("la_stop: invalid slot=%d\n", (int)slot);
        return 0;
    }
    ma_sound_stop(&g_audioBank[slot]);
    return 0;
}

static int la_set_loop(lua_State *L) {
    lua_Integer slot = ORIG_lua_tointeger(L, 1);
    int loop = ORIG_lua_toboolean(L, 2);
    if (!g_audioInit) return 0;
    if (slot < 0 || slot >= AUDIO_BANK_SIZE || !g_audioBankInUse[slot]) {
        proxy_log("la_set_loop: invalid slot=%d\n", (int)slot);
        return 0;
    }
    ma_sound_set_looping(&g_audioBank[slot], loop ? MA_TRUE : MA_FALSE);
    return 0;
}

/* Stereo pan in [-1, +1]. -1 is full left, 0 centered, +1 full right.
   miniaudio's default pan mode is MA_PAN_MODE_BALANCE which attenuates
   the opposite channel rather than crossfading equal-power; that matches
   the bearing semantics here (a beacon due east is silent in the left
   channel) better than equal-power crossfade would. */
static int la_set_pan(lua_State *L) {
    lua_Integer slot = ORIG_lua_tointeger(L, 1);
    double v = ORIG_lua_tonumber(L, 2);
    if (!g_audioInit) return 0;
    if (slot < 0 || slot >= AUDIO_BANK_SIZE || !g_audioBankInUse[slot]) {
        proxy_log("la_set_pan: invalid slot=%d\n", (int)slot);
        return 0;
    }
    if (v < -1.0) v = -1.0;
    if (v > 1.0) v = 1.0;
    ma_sound_set_pan(&g_audioBank[slot], (float)v);
    return 0;
}

/* Pitch is the playback-rate multiplier (1.0 = source rate). Lua side
   computes 2^(semitones/12), so a value of 2 plays one octave above the
   source and 0.5 plays one octave below. Upper bound matches load's 4.0
   ceiling on volume -- generous and bounded. Lower bound nonzero
   (0.0625 = -4 octaves) so the rate never collapses to silence. */
static int la_set_pitch(lua_State *L) {
    lua_Integer slot = ORIG_lua_tointeger(L, 1);
    double v = ORIG_lua_tonumber(L, 2);
    if (!g_audioInit) return 0;
    if (slot < 0 || slot >= AUDIO_BANK_SIZE || !g_audioBankInUse[slot]) {
        proxy_log("la_set_pitch: invalid slot=%d\n", (int)slot);
        return 0;
    }
    if (v < 0.0625) v = 0.0625;
    if (v > 16.0) v = 16.0;
    ma_sound_set_pitch(&g_audioBank[slot], (float)v);
    return 0;
}

static int la_set_master_volume(lua_State *L) {
    double v = ORIG_lua_tonumber(L, 1);
    if (!g_audioInit) return 0;
    if (v < 0.0) v = 0.0;
    if (v > 1.0) v = 1.0;
    ma_engine_set_volume(&g_audioEngine, (float)v);
    proxy_log("la_set_master_volume: %.3f\n", v);
    return 0;
}

static int la_set_volume(lua_State *L) {
    lua_Integer slot = ORIG_lua_tointeger(L, 1);
    double v = ORIG_lua_tonumber(L, 2);
    if (!g_audioInit) return 0;
    if (slot < 0 || slot >= AUDIO_BANK_SIZE || !g_audioBankInUse[slot]) {
        proxy_log("la_set_volume: invalid slot=%d\n", (int)slot);
        return 0;
    }
    if (v < 0.0) v = 0.0;
    /* Per-sound volume is persistent: set once here, every subsequent
       play of this slot inherits it. Multiplied by the engine master.
       Upper bound permits boost (>1.0) so individual cues can sit louder
       than the rest of the palette without rebalancing every other sound;
       4.0 is a generous +12 dB ceiling, kept to bound the API. */
    if (v > 4.0) v = 4.0;
    ma_sound_set_volume(&g_audioBank[slot], (float)v);
    return 0;
}

static const luaL_Reg audio_funcs[] = {
    {"load",              la_load},
    {"load_voice",        la_load_voice},
    {"play",              la_play},
    {"play_delayed",      la_play_delayed},
    {"stop",              la_stop},
    {"cancel_all",        la_cancel_all},
    {"set_master_volume", la_set_master_volume},
    {"set_volume",        la_set_volume},
    {"set_pan",           la_set_pan},
    {"set_pitch",         la_set_pitch},
    {"set_loop",          la_set_loop},
    {NULL, NULL}
};

static void register_audio(lua_State *L) {
    int top = ORIG_lua_gettop(L);
    ORIG_luaL_register(L, "audio", audio_funcs);
    ORIG_lua_settop(L, top);
    proxy_log("register_audio: L=%p done\n", (void*)L);
}

/* === Hooked exports === */

__declspec(dllexport) lua_State * __cdecl luaL_newstate(void) {
    typedef lua_State * (__cdecl *fn)(void);
    lua_State *L = ((fn)orig[I_luaL_newstate])();
    g_stateCounter++;
    proxy_log("luaL_newstate: L=%p count=%d\n", (void*)L, g_stateCounter);
    return L;
}

__declspec(dllexport) lua_State * __cdecl lua_newstate(lua_Alloc f, void *ud) {
    typedef lua_State * (__cdecl *fn)(lua_Alloc, void *);
    lua_State *L = ((fn)orig[I_lua_newstate])(f, ud);
    g_stateCounter++;
    proxy_log("lua_newstate: L=%p count=%d\n", (void*)L, g_stateCounter);
    return L;
}

__declspec(dllexport) void __cdecl luaL_openlibs(lua_State *L) {
    typedef void (__cdecl *fn)(lua_State *);
    proxy_log("luaL_openlibs: L=%p\n", (void*)L);
    ((fn)orig[I_luaL_openlibs])(L);
    register_tolk(L);
    register_civvaccess_shared(L);
    register_audio(L);
    proxy_log("luaL_openlibs: tolk + civvaccess_shared + audio registered in globals\n");
}

__declspec(dllexport) int __cdecl lua_setfenv(lua_State *L, int index) {
    typedef int (__cdecl *fn)(lua_State *, int);

    /* The env table is at the top of the stack, about to be set.
       Inject our tolk table into it so sandboxed scripts can see it. */
    ORIG_lua_getfield(L, LUA_GLOBALSINDEX, "tolk");
    if (ORIG_lua_type(L, -1) == LUA_TNIL) {
        /* tolk not in globals yet - register it now */
        ORIG_lua_settop(L, -2); /* pop nil */
        register_tolk(L);
        ORIG_lua_getfield(L, LUA_GLOBALSINDEX, "tolk");
    }
    if (ORIG_lua_type(L, -1) != LUA_TNIL) {
        /* Stack: ... env_table tolk_table */
        ORIG_lua_setfield(L, -2, "tolk"); /* env.tolk = tolk, pops tolk */
    } else {
        ORIG_lua_settop(L, -2); /* pop nil */
    }

    /* === civvaccess_shared injection (mirrors tolk) === */
    ORIG_lua_getfield(L, LUA_GLOBALSINDEX, "civvaccess_shared");
    if (ORIG_lua_type(L, -1) == LUA_TNIL) {
        ORIG_lua_settop(L, -2);
        register_civvaccess_shared(L);
        ORIG_lua_getfield(L, LUA_GLOBALSINDEX, "civvaccess_shared");
    }
    if (ORIG_lua_type(L, -1) != LUA_TNIL) {
        ORIG_lua_setfield(L, -2, "civvaccess_shared");
    } else {
        ORIG_lua_settop(L, -2);
    }

    /* === audio injection (mirrors tolk) === */
    ORIG_lua_getfield(L, LUA_GLOBALSINDEX, "audio");
    if (ORIG_lua_type(L, -1) == LUA_TNIL) {
        ORIG_lua_settop(L, -2);
        register_audio(L);
        ORIG_lua_getfield(L, LUA_GLOBALSINDEX, "audio");
    }
    if (ORIG_lua_type(L, -1) != LUA_TNIL) {
        ORIG_lua_setfield(L, -2, "audio");
    } else {
        ORIG_lua_settop(L, -2);
    }

    /* Front-end and in-game bootstrap both happen inside Lua now, via the
       DLC's override of selected base-game UI files (see src/dlc/UI/).
       The proxy's only job in this hook is the tolk / civvaccess_shared /
       audio injection performed above. */

    return ((fn)orig[I_lua_setfenv])(L, index);
}

/* === DLL Entry === */

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD reason, LPVOID reserved) {
    if (reason == DLL_PROCESS_ATTACH) {
        char path[MAX_PATH];
        int i;
        char *s;

        DisableThreadLibraryCalls(hinstDLL);
        g_hProxyDll = hinstDLL;

        /* Open debug log in same directory as DLL (truncate on launch) */
        GetModuleFileNameA(hinstDLL, path, MAX_PATH);
        s = strrchr(path, '\\');
        if (s) strcpy(s + 1, "proxy_debug.log");
        g_logfile = fopen(path, "w");
        proxy_log("=== Lua proxy DLL loaded ===\n");

        /* Load original Lua DLL */
        GetModuleFileNameA(hinstDLL, path, MAX_PATH);
        s = strrchr(path, '\\');
        if (s) strcpy(s + 1, "lua51_original.dll");
        hOriginal = LoadLibraryA(path);
        if (!hOriginal) {
            proxy_log("FATAL: could not load lua51_original.dll from %s\n", path);
            return FALSE;
        }
        proxy_log("Loaded lua51_original.dll\n");

        for (i = 0; i < I_COUNT; i++) {
            orig[i] = GetProcAddress(hOriginal, export_names[i]);
            if (!orig[i]) {
                proxy_log("FATAL: could not resolve %s\n", export_names[i]);
            }
        }
        proxy_log("Resolved %d Lua API functions\n", I_COUNT);

        /* Resolve sounds directory: <gameDir>\Assets\DLC\DLC_CivVAccess\Sounds.
           The proxy DLL sits in the game install dir (next to lua51_original.dll),
           so strip the DLL filename and append the DLC-relative path. */
        GetModuleFileNameA(hinstDLL, path, MAX_PATH);
        s = strrchr(path, '\\');
        if (s) {
            *(s + 1) = '\0';
            _snprintf(g_soundsDir, MAX_PATH - 1,
                      "%sAssets\\DLC\\DLC_CivVAccess\\Sounds", path);
            g_soundsDir[MAX_PATH - 1] = '\0';
            proxy_log("Sounds dir: %s\n", g_soundsDir);
        }

        /* Load Tolk */
        GetModuleFileNameA(hinstDLL, path, MAX_PATH);
        s = strrchr(path, '\\');
        if (s) strcpy(s + 1, "Tolk.dll");
        hTolk = LoadLibraryA(path);
        if (hTolk) {
            proxy_log("Loaded Tolk.dll\n");
            pTolk_Load = (pfnTolk_Load)GetProcAddress(hTolk, "Tolk_Load");
            pTolk_Unload = (pfnTolk_Unload)GetProcAddress(hTolk, "Tolk_Unload");
            pTolk_TrySAPI = (pfnTolk_TrySAPI)GetProcAddress(hTolk, "Tolk_TrySAPI");
            pTolk_PreferSAPI = (pfnTolk_PreferSAPI)GetProcAddress(hTolk, "Tolk_PreferSAPI");
            pTolk_DetectScreenReader = (pfnTolk_DetectScreenReader)GetProcAddress(hTolk, "Tolk_DetectScreenReader");
            pTolk_HasSpeech = (pfnTolk_HasSpeech)GetProcAddress(hTolk, "Tolk_HasSpeech");
            pTolk_HasBraille = (pfnTolk_HasBraille)GetProcAddress(hTolk, "Tolk_HasBraille");
            pTolk_Output = (pfnTolk_Output)GetProcAddress(hTolk, "Tolk_Output");
            pTolk_Speak = (pfnTolk_Speak)GetProcAddress(hTolk, "Tolk_Speak");
            pTolk_Braille = (pfnTolk_Braille)GetProcAddress(hTolk, "Tolk_Braille");
            pTolk_Silence = (pfnTolk_Silence)GetProcAddress(hTolk, "Tolk_Silence");
            pTolk_IsLoaded = (pfnTolk_IsLoaded)GetProcAddress(hTolk, "Tolk_IsLoaded");
            pTolk_IsSpeaking = (pfnTolk_IsSpeaking)GetProcAddress(hTolk, "Tolk_IsSpeaking");
            proxy_log("Tolk function pointers: Load=%p, Output=%p\n",
                       (void*)pTolk_Load, (void*)pTolk_Output);
        } else {
            proxy_log("ERROR: could not load Tolk.dll from %s\n", path);
        }

        proxy_log("=== Proxy init complete ===\n");
    }
    else if (reason == DLL_PROCESS_DETACH) {
        if (g_tolkInit && pTolk_Unload) pTolk_Unload();
        if (hTolk) FreeLibrary(hTolk);
        if (hOriginal) FreeLibrary(hOriginal);
        if (g_logfile) { proxy_log("=== Proxy unloading ===\n"); fclose(g_logfile); }
    }
    return TRUE;
}

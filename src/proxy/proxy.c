/*
 * Lua 5.1 Proxy DLL for Civilization V Accessibility
 *
 * Replaces lua51_Win32.dll. Forwards all calls to lua51_original.dll,
 * hooks luaL_openlibs to inject Tolk screen reader bindings into every Lua state,
 * hooks lua_setfenv to propagate tolk into sandboxed environments and auto-enable
 * the accessibility mod on the first environment where Modding is visible.
 */
#pragma comment(lib, "User32.lib")

#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>

/* === Lua constants === */
#define LUA_GLOBALSINDEX (-10002)
#define LUA_TNIL 0

/* === Minimal Lua types === */
typedef struct lua_State lua_State;
typedef int (*lua_CFunction)(lua_State *L);
typedef void * (*lua_Alloc)(void *ud, void *ptr, size_t osize, size_t nsize);
typedef struct luaL_Reg { const char *name; lua_CFunction func; } luaL_Reg;

/* Accessibility mod GUID. Must match the .modinfo file. */
static const char *CIVVACCESS_MOD_ID = "40a9df7b-ae9f-48db-abb5-44afe0420524";
static const int   CIVVACCESS_MOD_VER = 1;

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

/* === Hooked exports === */

__declspec(dllexport) lua_State * __cdecl luaL_newstate(void) {
    typedef lua_State * (__cdecl *fn)(void);
    lua_State *L = ((fn)orig[I_luaL_newstate])();
    proxy_log("luaL_newstate: L=%p\n", (void*)L);
    return L;
}

__declspec(dllexport) lua_State * __cdecl lua_newstate(lua_Alloc f, void *ud) {
    typedef lua_State * (__cdecl *fn)(lua_Alloc, void *);
    lua_State *L = ((fn)orig[I_lua_newstate])(f, ud);
    proxy_log("lua_newstate: L=%p\n", (void*)L);
    return L;
}

__declspec(dllexport) void __cdecl luaL_openlibs(lua_State *L) {
    typedef void (__cdecl *fn)(lua_State *);
    proxy_log("luaL_openlibs: L=%p\n", (void*)L);
    ((fn)orig[I_luaL_openlibs])(L);
    register_tolk(L);
    proxy_log("luaL_openlibs: tolk registered in globals\n");
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

    /* === Auto-enable accessibility mod (once, on first env where Modding is visible) === */
    {
        static int g_mod_enabled = 0;
        if (!g_mod_enabled) {
            int env_idx = ORIG_lua_gettop(L);
            ORIG_lua_getfield(L, env_idx, "Modding");
            int mod_type = ORIG_lua_type(L, -1);
            ORIG_lua_settop(L, env_idx);

            if (mod_type != LUA_TNIL) {
                typedef int (__cdecl *pfn_luaL_loadstring)(lua_State *, const char *);
                typedef int (__cdecl *pfn_lua_pcall)(lua_State *, int, int, int);
                typedef const char * (__cdecl *pfn_lua_tolstring)(lua_State *, int, size_t *);
                typedef void (__cdecl *pfn_lua_pushvalue)(lua_State *, int);
                typedef int (__cdecl *pfn_lua_setfenv_raw)(lua_State *, int);
                pfn_luaL_loadstring pLoadString = (pfn_luaL_loadstring)orig[I_luaL_loadstring];
                pfn_lua_pcall pPcall = (pfn_lua_pcall)orig[I_lua_pcall];
                pfn_lua_tolstring pTolstring = (pfn_lua_tolstring)orig[I_lua_tolstring];
                pfn_lua_pushvalue pPushValue = (pfn_lua_pushvalue)orig[I_lua_pushvalue];
                pfn_lua_setfenv_raw pSetfenvRaw = (pfn_lua_setfenv_raw)orig[I_lua_setfenv];

                g_mod_enabled = 1;

                char code[1024];
                _snprintf(code, sizeof(code),
                    "local modID = '%s'\n"
                    "local modVer = %d\n"
                    "local enabled = Modding.GetEnabledModsByActivationOrder()\n"
                    "local found = false\n"
                    "for _, m in ipairs(enabled) do\n"
                    "  if m.ModID == modID then found = true break end\n"
                    "end\n"
                    "if not found then\n"
                    "  Modding.EnableMod(modID, modVer)\n"
                    "end\n"
                    "Modding.ActivateEnabledMods()\n",
                    CIVVACCESS_MOD_ID, CIVVACCESS_MOD_VER);
                code[sizeof(code)-1] = '\0';

                int err = pLoadString(L, code);
                if (err == 0) {
                    pPushValue(L, env_idx);
                    pSetfenvRaw(L, -2);
                    err = pPcall(L, 0, 0, 0);
                    if (err != 0) {
                        const char *msg = pTolstring(L, -1, NULL);
                        proxy_log("mod_enable: error %d: %s\n", err, msg ? msg : "(no message)");
                        ORIG_lua_settop(L, env_idx);
                    } else {
                        proxy_log("mod_enable: accessibility mod auto-enabled\n");
                        ORIG_lua_settop(L, env_idx);
                    }
                } else {
                    proxy_log("mod_enable: loadstring failed %d\n", err);
                }
            }
        }
    }

    return ((fn)orig[I_lua_setfenv])(L, index);
}

/* === DLL Entry === */

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD reason, LPVOID reserved) {
    if (reason == DLL_PROCESS_ATTACH) {
        char path[MAX_PATH];
        int i;
        char *s;

        DisableThreadLibraryCalls(hinstDLL);

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

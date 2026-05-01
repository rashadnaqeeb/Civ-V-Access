# `src/proxy/proxy.c`

736 lines · The lua51_Win32.dll proxy DLL that forwards all Lua 5.1 exports to lua51_original.dll, hooks luaL_openlibs and lua_setfenv to inject tolk/civvaccess_shared/audio globals into every Lua sandbox, and provides miniaudio-backed WAV playback via an audio table.

## Header comment

```
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
```

## Outline

- L11-18: `#include` block: `<windows.h>`, `<stdlib.h>`, `<string.h>`, `<stdio.h>`, `<stdarg.h>`, miniaudio single-header (WAV only)
- L23-30: `#define` miniaudio feature disables: `MA_NO_ENCODING`, `MA_NO_GENERATION`, `MA_NO_NULL`, `MA_NO_MP3`, `MA_NO_FLAC`, `MA_NO_VORBIS`, `MINIAUDIO_IMPLEMENTATION`
- L34-35: `#define LUA_GLOBALSINDEX (-10002)` / `#define LUA_TNIL 0`
- L37-41: `typedef struct lua_State lua_State` / `typedef int (*lua_CFunction)(...)` / `typedef void * (*lua_Alloc)(...)` / `typedef struct luaL_Reg { ... } luaL_Reg`
- L49: `static FILE *g_logfile = NULL`
- L61: `static HMODULE hOriginal = NULL`
- L62: `static HINSTANCE g_hProxyDll = NULL`
- L63: `static int g_stateCounter = 0`
- L65: `static FARPROC orig[128] = {0}`
- L68-99: `enum { I_luaL_addlstring, ..., I_COUNT }` (index enum matching `export_names[]`)
- L101-130: `static const char *export_names[]` (115 Lua API export name strings)
- L133-136: `#define TRAMPOLINE(name, idx)` (naked jmp trampoline macro)
- L138-198: `TRAMPOLINE(...)` expansions for all 112 forwarded exports (3 hooked exports omitted from trampolines: `luaL_newstate`, `luaL_openlibs`, `lua_setfenv`, `lua_newstate`)
- L200-232: typed function pointer `typedef`s and `#define ORIG_*` accessor macros for the 14 Lua functions called directly by the proxy
- L235-264: Tolk function pointer `typedef`s and `static pfn*` variables for all 13 Tolk exports
- L266: `static wchar_t *utf8_to_wide(const char *s)`
- L273: `static char *wide_to_utf8(const wchar_t *w)`
- L280: `static void ensure_tolk(void)`
- L292: `static int lt_load(lua_State *L)`
- L293: `static int lt_unload(lua_State *L)`
- L294: `static int lt_trySAPI(lua_State *L)`
- L295: `static int lt_preferSAPI(lua_State *L)`
- L297: `static int lt_detectScreenReader(lua_State *L)`
- L305: `static int lt_hasSpeech(lua_State *L)`
- L306: `static int lt_hasBraille(lua_State *L)`
- L308: `static int lt_output(lua_State *L)`
- L317: `static int lt_speak(lua_State *L)`
- L326: `static int lt_braille(lua_State *L)`
- L334: `static int lt_silence(lua_State *L)`
- L335: `static int lt_isLoaded(lua_State *L)`
- L336: `static int lt_isSpeaking(lua_State *L)`
- L338: `static const luaL_Reg tolk_funcs[]`
- L347: `static void register_tolk(lua_State *L)`
- L355: `static void register_civvaccess_shared(lua_State *L)`
- L377-385: audio bank globals: `g_audioInit`, `g_audioEngine`, `g_audioBank[32]`, `g_audioBankInUse[32]`, `g_audioBankName[32][64]`, `g_soundsDir[MAX_PATH]`
- L387: `static int ensure_audio(void)`
- L409: `static int la_load(lua_State *L)`
- L468: `static void audio_rearm_slot(int slot)`
- L474: `static int la_play(lua_State *L)`
- L492: `static int la_play_delayed(lua_State *L)`
- L516: `static int la_cancel_all(lua_State *L)`
- L526: `static int la_set_master_volume(lua_State *L)`
- L536: `static int la_set_volume(lua_State *L)`
- L552: `static const luaL_Reg audio_funcs[]`
- L562: `static void register_audio(lua_State *L)`
- L571: `__declspec(dllexport) lua_State * __cdecl luaL_newstate(void)`
- L579: `__declspec(dllexport) lua_State * __cdecl lua_newstate(lua_Alloc f, void *ud)`
- L587: `__declspec(dllexport) void __cdecl luaL_openlibs(lua_State *L)`
- L597: `__declspec(dllexport) int __cdecl lua_setfenv(lua_State *L, int index)`
- L652: `BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD reason, LPVOID reserved)`

## Notes

- L133 `TRAMPOLINE`: uses a `__declspec(naked)` function with an inline `__asm { jmp dword ptr [orig + idx * 4] }` so the call overhead is a single indirect jump with no stack frame - required because Lua's C-calling-convention functions pass arguments on the stack and a normal wrapper would corrupt the stack.
- L355 `register_civvaccess_shared`: checks whether `civvaccess_shared` already exists in globals before creating it, making the registration idempotent across multiple `luaL_openlibs` calls on different `lua_State`s in the same process.
- L597 `lua_setfenv`: the injection hook for sandboxed environments - injects `tolk`, `civvaccess_shared`, and `audio` into the env table sitting on the stack top before forwarding to the original `lua_setfenv`; this is how every Civ V Lua Context (including mod files) sees these globals even though the engine sandboxes each Context with `setfenv`.
- L468 `audio_rearm_slot`: always stops the sound and seeks to frame 0 before each play, and sets `start_time` to 0 (past) so miniaudio's scheduler treats the next `ma_sound_start` as "play now" - necessary because a sound that finished naturally stays in a "done" state and won't replay without an explicit rewind.
- L409 `la_load`: deduplicates by name before allocating a bank slot, so `audio.load` called multiple times with the same filename returns the existing slot handle without consuming additional bank space or decoding the WAV again.
- L652 `DllMain` `DLL_PROCESS_DETACH`: does NOT uninitialize the miniaudio engine (`ma_engine_uninit`) on detach because miniaudio's audio thread must not be joined while the loader lock is held - the comment explicitly documents this as deliberate.
- L571 `luaL_newstate` / L579 `lua_newstate`: both hooked only to increment `g_stateCounter` for debug logging; neither injects globals (injection happens in `luaL_openlibs` and `lua_setfenv`).

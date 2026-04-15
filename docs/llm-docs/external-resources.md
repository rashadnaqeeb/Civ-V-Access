# External Resources

Pointers to community-maintained Civ V modding references that supplement the local SDK. Fetch on demand; do not mirror here.

## Key references

### Community Lua / API references

- Civfanatics Modiki main Lua reference: https://modiki.civfanatics.com/index.php/Lua_and_UI_Reference_(Civ5) — wiki-form, per-method pages, generally more linkable than the SDK HTML. Initial seed was bot-generated from 2K's wiki and parsed Lua/UI source.
- Modiki API category index: https://modiki.civfanatics.com/index.php?title=Category:Civ5_API
- Modiki "Specificities of Lua in Civ5": https://modiki.civfanatics.com/index.php?title=Specificities_of_the_Lua_implementation_in_Civ5 — notes on the Lua 5.1.4 base, sandbox, globals.
- Modiki `LuaEvents` type: https://modiki.civfanatics.com/index.php/LuaEvents_(Civ5_Type) — explicit note that LuaEvents are the only cross-context channel.
- Modiki `Context` type: https://modiki.civfanatics.com/index.php/Context_(Civ5_Type) — signatures for ContextPtr methods; thin on semantics.
- Modiki `UIManager` type: https://modiki.civfanatics.com/index.php?title=UIManager_(Civ5_Type)
- Modiki debugging page: https://modiki.civfanatics.com/index.php/Debugging_(Civ5) — `LoggingEnabled`, Live Tuner, `Lua.log` conventions.
- aw-3 "Lua & You" primer: https://aw-3.github.io/Lua-Civ5/ — readable tutorial covering ContextPtr / Events / LuaEvents gotchas.

### Whoward's reference work (parsed from DLL C++, more authoritative than HTML scrape)

- BNW Lua API Reference thread (index): https://forums.civfanatics.com/threads/bnw-lua-api-reference.558353/
- XML source on GitHub: https://github.com/whoward69/BNW-Lua-API
- DLL - Extending the Lua API tutorial: https://forums.civfanatics.com/threads/dll-c-extending-the-lua-api.516127/
- DLL - Lua API requests (list of DLL-added methods): https://forums.civfanatics.com/threads/dll-lua-api-requests.527958/
- Check-if-DLL-loaded trick: https://forums.civfanatics.com/threads/dll-lua-check-if-your-dll-is-loaded-from-lua.517500/
- Lua Reference Vault (compendium of threads): https://forums.civfanatics.com/threads/lua-reference-vault.607316/
- UI Functions thread: https://forums.civfanatics.com/threads/ui-functions.453555/

Note: civfanatics.com forum pages are often behind Cloudflare; WebFetch usually gets through here but has been rate-limited in past sessions. Fall back to Playwright if a fetch returns a challenge page.

### Reference mod source repos

- Vox Populi / Community Patch DLL (LoneGazebo, primary upstream): https://github.com/LoneGazebo/Community-Patch-DLL — C++ gamecore DLL plus Lua mod suite; the canonical DLL-mod reference.
- Vox Populi fork with active Lua work (CIVITAS-John): https://github.com/CIVITAS-John/vox-populi
- InGame Editor Plus (active IGE fork): https://github.com/n-core/InGame-Editor-Plus — good reading for runtime UI manipulation patterns.
- Enhanced User Interface (EUI) source: https://github.com/vans163/ui_bc1 — full XML+Lua UI replacement; read for ContextPtr / Controls / popup patterns.
- Gedemon Custom Setup (popup / setup screen patterns): https://github.com/Gedemon/Civ5-Custom-Setup

## Inaccessible / blocked

No Cloudflare walls hit this session; WebFetch succeeded on modiki and civfanatics forum pages I tried. If future fetches return challenge HTML, the ui_bc1, LoneGazebo/Community-Patch-DLL, and n-core/InGame-Editor-Plus repos on GitHub are the richest fallback reading material and are Cloudflare-free.

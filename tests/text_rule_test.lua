-- Static lint enforcing the project's text-localization rule: mod code must
-- route user-facing text through the Text.key / Text.format wrapper
-- (CivVAccess_Text.lua), not through Locale.ConvertTextKey or Locale.Lookup
-- directly. The wrapper logs missing TXT_KEY lookups; raw Locale calls
-- silently return the key string and the screen reader spells it out letter
-- by letter to the user.
--
-- This is a text-scan over mod-authored Lua files; it does not load them.
-- Three files are allow-listed: the wrapper itself, the test polyfill that
-- stubs Locale for the offline harness, and the strings loader. The loader
-- runs before the wrapper exists (it decides which strings the wrapper will
-- serve) and its one lookup is a language probe whose result is compared,
-- never spoken.

local M = {}

local ALLOWED = {
    ["src/dlc/UI/Shared/CivVAccess_Text.lua"] = true,
    ["src/dlc/UI/InGame/CivVAccess_Polyfill.lua"] = true,
    ["src/dlc/UI/Shared/CivVAccess_StringsLoader.lua"] = true,
}

local function repoRelative(absPath)
    local idx = absPath:find("[Ss]rc[\\/][Dd]lc[\\/][Uu][Ii][\\/]")
    if idx == nil then
        return nil
    end
    return absPath:sub(idx):gsub("\\", "/")
end

local function listModFiles()
    -- test.ps1 always runs on Windows; dir /B /S /A:-D enumerates files
    -- recursively, one absolute path per line.
    local handle = io.popen('cmd /c "dir /B /S /A:-D src\\dlc\\UI\\CivVAccess_*.lua"')
    if handle == nil then
        error("text_rule_test: io.popen failed")
    end
    local files = {}
    for line in handle:lines() do
        local rel = repoRelative(line)
        if rel ~= nil then
            files[#files + 1] = { abs = line, rel = rel }
        end
    end
    handle:close()
    return files
end

local function scanFile(absPath)
    local f = io.open(absPath, "r")
    if f == nil then
        return {}
    end
    local hits = {}
    local lineNum = 0
    for line in f:lines() do
        lineNum = lineNum + 1
        local stripped = line:gsub("^%s+", "")
        if not stripped:match("^%-%-") then
            if line:find("Locale%.ConvertTextKey%s*%(") then
                hits[#hits + 1] = {
                    line = lineNum,
                    what = "Locale.ConvertTextKey",
                    code = line:gsub("^%s+", ""):gsub("%s+$", ""),
                }
            end
            if line:find("Locale%.Lookup%s*%(") then
                hits[#hits + 1] = {
                    line = lineNum,
                    what = "Locale.Lookup",
                    code = line:gsub("^%s+", ""):gsub("%s+$", ""),
                }
            end
        end
    end
    f:close()
    return hits
end

function M.test_no_direct_locale_calls_in_mod_code()
    local files = listModFiles()
    if #files == 0 then
        error("text_rule_test: enumerated zero mod files; the FS walk is broken")
    end
    local violations = {}
    for _, entry in ipairs(files) do
        if not ALLOWED[entry.rel] then
            local hits = scanFile(entry.abs)
            for _, h in ipairs(hits) do
                violations[#violations + 1] = {
                    path = entry.rel,
                    line = h.line,
                    what = h.what,
                    code = h.code,
                }
            end
        end
    end
    if #violations > 0 then
        local lines = {
            "found "
                .. #violations
                .. " direct Locale call(s) in mod code; route through Text.key / Text.format (CivVAccess_Text.lua):",
        }
        for _, v in ipairs(violations) do
            lines[#lines + 1] = "  " .. v.path .. ":" .. tostring(v.line) .. " (" .. v.what .. ") " .. v.code
        end
        error(table.concat(lines, "\n"))
    end
end

return M

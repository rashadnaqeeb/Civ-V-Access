-- Dump CivVAccess_Strings as JSON.
-- usage: lua5.1.exe dump_strings.lua <path-to-strings-file>
--
-- Loads the file via dofile (so plural-form bundles, multi-line concat, and
-- any other valid Lua shape parse cleanly) and emits the resulting global
-- CivVAccess_Strings table as JSON to stdout. Used by diff.py to compare an
-- en_US strings file at two git revisions.

CivVAccess_Strings = {}

-- Stub the runtime globals the strings file may touch at load (the InGame and
-- FrontEnd baselines append `include("CivVAccess_StringsLoader")` and a call
-- into StringsLoader.loadOverlay to layer locale overrides on top). The
-- dumper only cares about the assignments executed before those calls, and
-- the calls themselves do nothing useful in this offline context.
include = function() end
StringsLoader = setmetatable({}, { __index = function() return function() end end })

local ok, err = pcall(dofile, arg[1])
if not ok then
    io.stderr:write("dofile failed for " .. tostring(arg[1]) .. ": " .. tostring(err) .. "\n")
    os.exit(2)
end

local function escape_str(s)
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    s = s:gsub("[%z\1-\8\11\12\14-\31]", function(c)
        return string.format("\\u%04x", string.byte(c))
    end)
    return '"' .. s .. '"'
end

local function emit(v)
    local t = type(v)
    if t == "string" then return escape_str(v) end
    if t == "number" or t == "boolean" then return tostring(v) end
    if t == "table" then
        local parts = {}
        local keys = {}
        for k in pairs(v) do keys[#keys + 1] = k end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        for _, k in ipairs(keys) do
            parts[#parts + 1] = escape_str(tostring(k)) .. ":" .. emit(v[k])
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null"
end

io.write(emit(CivVAccess_Strings or {}))

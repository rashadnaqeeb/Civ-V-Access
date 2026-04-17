-- Shared preamble builder for the three Mods* menus. Returns a function
-- the Access file can hand to BaseMenu as spec.preamble so the
-- enabled-mods list is queried at speech time, never cached.

ModListPreamble = {}

local function build()
    local mods = Modding.GetEnabledModsByActivationOrder()
    if mods == nil or #mods == 0 then return nil end
    local parts = {}
    for i, v in ipairs(mods) do
        local name = Modding.GetModProperty(v.ModID, v.Version, "Name") or v.ModID
        parts[#parts + 1] = name
    end
    return Text.key("TXT_KEY_MODS_IN_USE") .. " " .. table.concat(parts, ", ")
end

function ModListPreamble.fn()
    return build
end

-- Shared helpers for the Diplomatic Overview tab wrappers. Both the
-- Relations panel (Your Relations) and the Global panel (Global Politics)
-- compose per-civ speech lines from the same list-join primitive and
-- share the "open trade with this civ" activation path.

DiploCommon = {}

-- Join non-empty parts with ", ". Used to compose per-civ speech lines
-- from a fixed sequence of optional fields; nil or empty entries drop
-- out so a civ with no tradeable resources doesn't read "...,,,".
function DiploCommon.joinParts(parts)
    local out = {}
    for _, p in ipairs(parts) do
        if p ~= nil and p ~= "" then
            out[#out + 1] = tostring(p)
        end
    end
    return table.concat(out, ", ")
end

-- Open trade with the specified civ. Humans go through the PvP deal
-- screen event; AI goes through the begin-diplo path that spins up the
-- leader head + trade screen. Matches base DiploRelationships.lua /
-- DiploGlobalRelationships.lua LeaderSelected.
function DiploCommon.openTradeWith(iOther)
    if Players[iOther]:IsHuman() then
        Events.OpenPlayerDealScreenEvent(iOther)
    else
        UI.SetRepeatActionPlayer(iOther)
        UI.ChangeStartDiploRepeatCount(1)
        Players[iOther]:DoBeginDiploWithHuman()
    end
end

return DiploCommon

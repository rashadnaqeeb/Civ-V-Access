-- Alt+Up/Down section review for dismiss-only "reward" popups: the tech and
-- wonder researched popups, great work created, golden age, goody hut,
-- natural wonder found, league formed, and the like. These popups carry
-- their content in the preamble rather than in navigable items, and several
-- open with silentFirstOpen so BaseMenu never runs its landing-speak and the
-- focused (dismiss) button's section list is never seeded. So the standard
-- per-item Alt+Up/Down review has nothing to walk. This wires the chord to
-- step through the popup's content fragments instead.
--
-- The caller passes fragmentsFn: a function returning the popup's distinct
-- content pieces (the same strings its preamble joins), read live. Each
-- fragment is split on [NEWLINE] / newlines and filtered, so multi-line
-- effect text reviews line by line the way the tech tree does, and a
-- single-line fragment is one section. Reading live on every press keeps the
-- data fresh; a content-signature check restarts the cursor at the first
-- section whenever a different reward opens, so no onShow coordination is
-- needed and a prior reward's cursor position never carries into the next.
--
-- Pair with the existing F1 preamble: build the preamble from the same
-- fragmentsFn (Text.joinNonEmpty) so the joined readout and the section list
-- cannot drift.

RewardReview = {}

local MOD_ALT = 4

-- Split one fragment into reviewable sections: break on [NEWLINE] markup and
-- real newlines, filter each line, drop the ones that filter to empty so the
-- chord never lands on silence.
local function splitFiltered(raw)
    local out = {}
    if raw == nil or raw == "" then
        return out
    end
    local normalized = tostring(raw):gsub("%[NEWLINE%]", "\n")
    for line in (normalized .. "\n"):gmatch("(.-)\n") do
        local f = TextFilter.filter(line)
        if f ~= nil and f ~= "" then
            out[#out + 1] = f
        end
    end
    return out
end

local function liveSections(fragmentsFn)
    local out = {}
    local ok, frags = pcall(fragmentsFn)
    if not ok then
        Log.error("RewardReview fragmentsFn failed: " .. tostring(frags))
        return out
    end
    for _, frag in ipairs(frags) do
        for _, sec in ipairs(splitFiltered(frag)) do
            out[#out + 1] = sec
        end
    end
    return out
end

-- Repoint handler's built-in Alt+Up/Down (which walk the empty per-item
-- section list on these dismiss-only popups) at the reward content. Swapping
-- the existing bindings' fns rather than appending is required: InputRouter
-- walks bindings in order and the built-ins would shadow any appended
-- duplicate.
function RewardReview.install(handler, fragmentsFn)
    local holder = {}
    local lastKey = nil
    local function step(delta)
        local secs = liveSections(fragmentsFn)
        -- Filtered sections never contain \1 (TextFilter strips control
        -- bytes), so it is a safe join sentinel for the change check.
        local key = table.concat(secs, "\1")
        if key ~= lastKey then
            lastKey = key
            BaseMenuItems.SectionReview.set(holder, secs)
        end
        if delta > 0 then
            BaseMenuItems.SectionReview.next(holder)
        else
            BaseMenuItems.SectionReview.prev(holder)
        end
    end
    for _, b in ipairs(handler.bindings) do
        if b.mods == MOD_ALT and b.key == Keys.VK_DOWN then
            b.fn = function()
                step(1)
            end
        elseif b.mods == MOD_ALT and b.key == Keys.VK_UP then
            b.fn = function()
                step(-1)
            end
        end
    end
end

return RewardReview

-- KeyLayout tests. The module is dofiled once in run.lua; here we drive its
-- inputs (the detected profile and the Settings override, both read live from
-- civvaccess_shared) and assert the VK remap, the help-label swap, and the
-- layout-aware '?' key.

local T = require("support")
local M = {}

local VK_A, VK_Q, VK_W, VK_Y, VK_Z = 65, 81, 87, 89, 90
local VK_S, VK_E = 83, 69

local function setup(detected, override)
    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.keyboard_profile = detected
    civvaccess_shared.keyboardProfileOverride = override
end

function M.test_remap_identity_on_qwerty()
    setup("qwerty", nil)
    T.eq(KeyLayout.remap(VK_A), VK_A)
    T.eq(KeyLayout.remap(VK_Z), VK_Z)
end

function M.test_remap_azerty_swaps_aq_and_wz()
    setup("azerty", nil)
    T.eq(KeyLayout.remap(VK_A), VK_Q)
    T.eq(KeyLayout.remap(VK_Q), VK_A)
    T.eq(KeyLayout.remap(VK_W), VK_Z)
    T.eq(KeyLayout.remap(VK_Z), VK_W)
end

function M.test_remap_azerty_leaves_unswapped_keys()
    setup("azerty", nil)
    -- S and E sit in the same place on AZERTY; they must pass through.
    T.eq(KeyLayout.remap(VK_S), VK_S)
    T.eq(KeyLayout.remap(VK_E), VK_E)
end

function M.test_remap_qwertz_swaps_only_zy()
    setup("qwertz", nil)
    T.eq(KeyLayout.remap(VK_Z), VK_Y)
    T.eq(KeyLayout.remap(VK_Y), VK_Z)
    -- W and A do not move on QWERTZ.
    T.eq(KeyLayout.remap(VK_W), VK_W)
    T.eq(KeyLayout.remap(VK_A), VK_A)
end

-- OEM virtual keys, named for readability in the punctuation-cluster tests.
local OEM_1, OEM_PLUS, OEM_COMMA, OEM_MINUS, OEM_PERIOD, OEM_2 = 186, 187, 188, 189, 190, 191
local OEM_4, OEM_5, OEM_6, OEM_8 = 219, 220, 221, 223

function M.test_remap_azerty_punctuation_clusters()
    setup("azerty", nil)
    -- comma/period/slash trio -> unit prev/next/info on the ; : ! keys
    T.eq(KeyLayout.remap(OEM_PERIOD), OEM_COMMA) -- ";" -> previous unit
    T.eq(KeyLayout.remap(OEM_2), OEM_PERIOD) -- ":" -> next unit
    T.eq(KeyLayout.remap(OEM_8), OEM_2) -- "!" -> unit info
    -- message next moves to "="; prev ")" and chat "*" stay native
    T.eq(KeyLayout.remap(OEM_PLUS), OEM_6) -- "=" -> message next
    T.eq(KeyLayout.remap(OEM_4), OEM_4) -- ")" unchanged (message previous)
    T.eq(KeyLayout.remap(OEM_5), OEM_5) -- "*" unchanged (chat)
end

function M.test_remap_qwertz_punctuation_clusters()
    setup("qwertz", nil)
    T.eq(KeyLayout.remap(OEM_MINUS), OEM_2) -- "-" -> unit info
    T.eq(KeyLayout.remap(OEM_1), OEM_4) -- "ü" -> message previous
    T.eq(KeyLayout.remap(OEM_PLUS), OEM_6) -- "+" -> message next
    T.eq(KeyLayout.remap(OEM_2), OEM_5) -- "#" -> chat
    -- comma/period stay native (unit previous/next)
    T.eq(KeyLayout.remap(OEM_COMMA), OEM_COMMA)
    T.eq(KeyLayout.remap(OEM_PERIOD), OEM_PERIOD)
end

function M.test_remap_qwerty_punctuation_identity()
    setup("qwerty", nil)
    T.eq(KeyLayout.remap(OEM_4), OEM_4)
    T.eq(KeyLayout.remap(OEM_2), OEM_2)
    T.eq(KeyLayout.remap(OEM_PLUS), OEM_PLUS)
end

function M.test_remap_italian_leaves_letters_alone()
    setup("italian", nil)
    -- Italian is QWERTY for letters; the movement cluster never moves.
    T.eq(KeyLayout.remap(VK_A), VK_A)
    T.eq(KeyLayout.remap(VK_Q), VK_Q)
    T.eq(KeyLayout.remap(VK_W), VK_W)
    T.eq(KeyLayout.remap(VK_Z), VK_Z)
    T.eq(KeyLayout.remap(VK_Y), VK_Y)
end

function M.test_remap_italian_punctuation_clusters()
    setup("italian", nil)
    -- Same OEM remap as QWERTZ; the comma/period keys stay native.
    T.eq(KeyLayout.remap(OEM_MINUS), OEM_2) -- "-" -> unit info
    T.eq(KeyLayout.remap(OEM_1), OEM_4) -- "è" -> message previous
    T.eq(KeyLayout.remap(OEM_PLUS), OEM_6) -- "+" -> message next
    T.eq(KeyLayout.remap(OEM_2), OEM_5) -- "ù" -> chat
    T.eq(KeyLayout.remap(OEM_COMMA), OEM_COMMA) -- unit previous
    T.eq(KeyLayout.remap(OEM_PERIOD), OEM_PERIOD) -- unit next
end

function M.test_collidesnative_qwerty_none()
    setup("qwerty", nil)
    -- OEM_4 / OEM_2 are the real bracket / slash keys here, never ghosts.
    T.eq(KeyLayout.collidesNative(OEM_4), false)
    T.eq(KeyLayout.collidesNative(OEM_2), false)
end

function M.test_collidesnative_azerty()
    setup("azerty", nil)
    -- The ',' key (questionKey) and the '^' key emit the unit-prev / message-
    -- next VKs natively, away from their intended ; : and = keys.
    T.eq(KeyLayout.collidesNative(OEM_COMMA), true)
    T.eq(KeyLayout.collidesNative(OEM_6), true)
    -- Keys that are both source and target, and plain sources, are not ghosts.
    T.eq(KeyLayout.collidesNative(OEM_PERIOD), false)
    T.eq(KeyLayout.collidesNative(OEM_2), false)
    T.eq(KeyLayout.collidesNative(VK_A), false)
end

function M.test_collidesnative_qwertz()
    setup("qwertz", nil)
    -- ß / ´ / ^° emit message-prev / next / chat VKs natively.
    T.eq(KeyLayout.collidesNative(OEM_4), true)
    T.eq(KeyLayout.collidesNative(OEM_6), true)
    T.eq(KeyLayout.collidesNative(OEM_5), true)
    -- The # key (OEM_2) is a source remapped to chat, not a ghost; ü likewise;
    -- the symmetric Z/Y letter swap is not a collision.
    T.eq(KeyLayout.collidesNative(OEM_2), false)
    T.eq(KeyLayout.collidesNative(OEM_1), false)
    T.eq(KeyLayout.collidesNative(VK_Y), false)
end

function M.test_collidesnative_italian()
    setup("italian", nil)
    -- Same colliding OEM keys as QWERTZ (apostrophe / ì / backslash).
    T.eq(KeyLayout.collidesNative(OEM_4), true)
    T.eq(KeyLayout.collidesNative(OEM_6), true)
    T.eq(KeyLayout.collidesNative(OEM_5), true)
    T.eq(KeyLayout.collidesNative(OEM_2), false)
    T.eq(KeyLayout.collidesNative(OEM_COMMA), false)
end

function M.test_override_beats_detected()
    setup("qwerty", "azerty")
    T.eq(KeyLayout.activeProfile(), "azerty")
    T.eq(KeyLayout.remap(VK_A), VK_Q)
end

function M.test_auto_override_uses_detected()
    setup("azerty", "auto")
    T.eq(KeyLayout.activeProfile(), "azerty")
    T.eq(KeyLayout.remap(VK_A), VK_Q)
end

function M.test_unknown_profile_falls_back_to_qwerty()
    setup("dvorak", nil)
    T.eq(KeyLayout.activeProfile(), "qwerty")
    T.eq(KeyLayout.remap(VK_A), VK_A)
end

function M.test_swaplabel_cluster_azerty()
    setup("azerty", nil)
    T.eq(KeyLayout.swapLabel("Q, W, E, A, S, D, Z, X, C cluster"), "A, Z, E, Q, S, D, W, X, C cluster")
end

function M.test_swaplabel_cluster_qwertz()
    setup("qwertz", nil)
    T.eq(KeyLayout.swapLabel("Q, W, E, A, S, D, Z, X, C cluster"), "Q, W, E, A, S, D, Y, X, C cluster")
end

function M.test_swaplabel_qwerty_unchanged()
    setup("qwerty", nil)
    T.eq(KeyLayout.swapLabel("Q, W, E, A, S, D, Z, X, C cluster"), "Q, W, E, A, S, D, Z, X, C cluster")
end

function M.test_swaplabel_italian_unchanged()
    -- Italian has no letter swap (QWERTY letters), so the cluster label is
    -- left intact -- only the OEM symbol names change, via resolveKeyLabel.
    setup("italian", nil)
    T.eq(KeyLayout.swapLabel("Q, W, E, A, S, D, Z, X, C cluster"), "Q, W, E, A, S, D, Z, X, C cluster")
end

function M.test_swaplabel_swaps_single_letters_only()
    setup("azerty", nil)
    -- The chord prefix words stay; the single-letter key swaps.
    T.eq(KeyLayout.swapLabel("Shift plus W"), "Shift plus Z")
    -- A swappable letter inside a longer word must not be touched.
    T.eq(KeyLayout.swapLabel("Wake"), "Wake")
end

function M.test_resolvekeylabel_qwerty_unchanged()
    setup("qwerty", nil)
    T.eq(KeyLayout.resolveKeyLabel("TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"), "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO")
end

function M.test_resolvekeylabel_picks_profile_variant()
    setup("azerty", nil)
    T.eq(
        KeyLayout.resolveKeyLabel("TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"),
        "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO_AZERTY"
    )
    setup("qwertz", nil)
    T.eq(
        KeyLayout.resolveKeyLabel("TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"),
        "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO_QWERTZ"
    )
end

function M.test_resolvekeylabel_picks_italian_variant()
    setup("italian", nil)
    -- Info moves to the hyphen key on Italian, like QWERTZ, so it has an
    -- _ITALIAN variant.
    T.eq(
        KeyLayout.resolveKeyLabel("TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"),
        "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO_ITALIAN"
    )
    -- Comma/period don't move, so the cycle label stays on the base key.
    T.eq(KeyLayout.resolveKeyLabel("TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"), "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE")
end

function M.test_resolvekeylabel_period_variant_only_on_azerty()
    -- '.' becomes the ';' key on AZERTY but is unchanged on QWERTZ, so the
    -- cycle label has an AZERTY variant and no QWERTZ one.
    setup("azerty", nil)
    T.eq(
        KeyLayout.resolveKeyLabel("TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"),
        "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_AZERTY"
    )
    setup("qwertz", nil)
    T.eq(KeyLayout.resolveKeyLabel("TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"), "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE")
end

function M.test_resolvekeylabel_passes_through_unregistered()
    setup("azerty", nil)
    -- A cluster letter label is handled by swapLabel, not the variant map.
    T.eq(
        KeyLayout.resolveKeyLabel("TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"),
        "TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"
    )
end

function M.test_resolved_variants_have_backing_strings()
    -- Drive the cross-check off the real registry, not a parallel list, so a
    -- newly registered base can't slip through uncovered. A registered base
    -- that resolves to a missing _AZERTY / _QWERTZ key would make the player
    -- hear the raw key name; the base itself must also have a string.
    for profile, bases in pairs(KeyLayout.LABEL_VARIANTS) do
        setup(profile, nil)
        for base in pairs(bases) do
            local resolved = KeyLayout.resolveKeyLabel(base)
            T.truthy(CivVAccess_Strings[resolved], profile .. " variant missing: " .. resolved)
            T.truthy(CivVAccess_Strings[base], "base string missing: " .. base)
        end
    end
end

function M.test_questionkey_per_profile()
    setup("qwerty", nil)
    T.eq(KeyLayout.questionKey(), 191)
    setup("azerty", nil)
    T.eq(KeyLayout.questionKey(), 188)
    setup("qwertz", nil)
    T.eq(KeyLayout.questionKey(), 219)
    -- Italian reaches '?' via Shift + the apostrophe key, same VK as German.
    setup("italian", nil)
    T.eq(KeyLayout.questionKey(), 219)
end

function M.test_activeprofile_italian()
    setup("italian", nil)
    T.eq(KeyLayout.activeProfile(), "italian")
    setup("qwerty", "italian")
    T.eq(KeyLayout.activeProfile(), "italian")
end

return M

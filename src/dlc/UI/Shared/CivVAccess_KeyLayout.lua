-- Keyboard-layout remap policy for the in-game key cluster. The proxy
-- classifies the user's physical keyboard into one of three families and
-- publishes it as civvaccess_shared.keyboard_profile ("qwerty" / "azerty" /
-- "qwertz"); this module owns what that classification means.
--
-- The mod's bindings are all authored in QWERTY virtual-key codes. On a
-- national layout the same physical key emits a different VK, so the 3x3
-- movement cluster (and everything keyed to a cluster position -- unit
-- moves, surveyor scope reads, grow/shrink) would scatter. remap() rewrites
-- the VK the engine delivered back to the QWERTY VK the binding expects, so
-- the whole cluster keeps its physical shape. The swaps are symmetric and
-- tiny: AZERTY swaps A/Q and W/Z, QWERTZ swaps Z/Y, QWERTY is identity.
--
-- Two consumers, two spaces, one source of truth: InputRouter calls remap()
-- in VK space inside the binding walk only (never on the type-ahead path,
-- where the engine-delivered VK already carries the user's intended letter);
-- Help calls swapLabel() in letter space so a key name authored as "W"
-- reads as the keycap the player actually presses ("Z" on AZERTY). Because
-- the pairs are symmetric the same set drives both directions.
--
-- The active profile is the user's Settings override when set, otherwise the
-- detected profile. Everything is read live from civvaccess_shared so a
-- Settings change takes effect on the next keypress with no relaunch.

KeyLayout = {}

-- VK codes for the swapped letters. For A-Z the VK equals the ASCII code,
-- so these double as the letter identities used by swapLabel.
local VK_A, VK_Q, VK_W, VK_Y, VK_Z = 65, 81, 87, 89, 90

-- OEM virtual keys used by the two punctuation clusters' positional remap.
local VK_OEM_1, VK_OEM_PLUS, VK_OEM_COMMA, VK_OEM_MINUS, VK_OEM_PERIOD, VK_OEM_2 = 186, 187, 188, 189, 190, 191
local VK_OEM_4, VK_OEM_5, VK_OEM_6, VK_OEM_8 = 219, 220, 221, 223

-- Input-side remap, engine-delivered VK -> the QWERTY VK the bindings use,
-- per profile. Letter swaps keep the movement cluster's physical 3x3 shape.
-- The OEM entries keep the two punctuation clusters physical too: the
-- comma/period/slash trio (unit previous / next / info) and the
-- bracket/backslash trio (message previous / next, chat). Identity profiles
-- (qwerty) are absent. The map is a plain lookup, not a symmetric swap, so a
-- VK can appear as both a source and a target without conflict.
local VK_SWAP = {
    -- AZERTY: A/Q and W/Z. The physical , . / keys are labelled ; : ! and
    -- carry unit prev/next/info. The [ position is the circumflex dead key,
    -- so message prev/next stay adjacent on the ) and = keys (= overrides
    -- engine zoom-in); chat stays on the * key (already VK_OEM_5).
    azerty = {
        [VK_A] = VK_Q,
        [VK_Q] = VK_A,
        [VK_W] = VK_Z,
        [VK_Z] = VK_W,
        [VK_OEM_PERIOD] = VK_OEM_COMMA, -- ";" key -> unit previous
        [VK_OEM_2] = VK_OEM_PERIOD, -- ":" key -> unit next
        [VK_OEM_8] = VK_OEM_2, -- "!" key -> unit info
        [VK_OEM_PLUS] = VK_OEM_6, -- "=" key -> message next
    },
    -- QWERTZ: Z/Y. Both punctuation clusters are fully positional. The , . keys
    -- carry unit prev/next natively; the - key (physical / position) carries
    -- info. The ü and + keys (physical [ ] positions) carry message prev/next
    -- and # (physical \ position) carries chat. The - and + keys override
    -- engine zoom; vacating ß keeps Shift+ß free as the '?' help key.
    qwertz = {
        [VK_Z] = VK_Y,
        [VK_Y] = VK_Z,
        [VK_OEM_MINUS] = VK_OEM_2, -- "-" key -> unit info
        [VK_OEM_1] = VK_OEM_4, -- "ü" key -> message previous
        [VK_OEM_PLUS] = VK_OEM_6, -- "+" key -> message next
        [VK_OEM_2] = VK_OEM_5, -- "#" key -> chat
    },
}

-- Display-side swaps, keycap letter -> keycap letter, per profile. Same
-- pairs as VK_SWAP, expressed as the single-letter tokens that appear in
-- help key labels.
local LETTER_SWAP = {
    azerty = { A = "Q", Q = "A", W = "Z", Z = "W" },
    qwertz = { Z = "Y", Y = "Z" },
}

-- VK that produces '?' (Shift + this key) per profile, for the help hotkey.
-- US '/?' is VK_OEM_2; AZERTY reaches '?' via Shift + the ',' key
-- (VK_OEM_COMMA), QWERTZ via Shift + the 'ß' key (VK_OEM_4).
local QUESTION_VK = { qwerty = 191, azerty = 188, qwertz = 219 }

-- Profiles offered in the Settings override, in display order. "auto" means
-- "use the detected profile".
KeyLayout.OVERRIDE_PROFILES = { "auto", "qwerty", "azerty", "qwertz" }

local function normalize(name)
    if name == "azerty" or name == "qwertz" then
        return name
    end
    return "qwerty"
end

-- What the proxy detected. Falls back to qwerty when the field is absent
-- (vanilla engine, or a proxy too old to publish it).
function KeyLayout.detectedProfile()
    return normalize(civvaccess_shared.keyboard_profile)
end

-- The profile actually in force: the override unless it is nil/"auto".
function KeyLayout.activeProfile()
    local override = civvaccess_shared.keyboardProfileOverride
    if override ~= nil and override ~= "auto" then
        return normalize(override)
    end
    return KeyLayout.detectedProfile()
end

-- Rewrite an engine-delivered VK to the QWERTY VK the bindings use. Identity
-- on QWERTY and for any key the active profile doesn't swap.
function KeyLayout.remap(vk)
    local swap = VK_SWAP[KeyLayout.activeProfile()]
    if swap == nil then
        return vk
    end
    return swap[vk] or vk
end

-- Rewrite the single-letter key-name tokens in a help label to the keycaps
-- the player presses on the active layout. Multi-letter words (Shift, plus,
-- cluster, ...) are left alone; only standalone letters are swapped.
function KeyLayout.swapLabel(text)
    local map = LETTER_SWAP[KeyLayout.activeProfile()]
    if map == nil then
        return text
    end
    return (text:gsub("%a+", function(run)
        if #run == 1 then
            return map[run]
        end
    end))
end

-- VK whose Shift-chord means '?' on the active layout, for the help hotkey.
function KeyLayout.questionKey()
    return QUESTION_VK[KeyLayout.activeProfile()] or QUESTION_VK.qwerty
end

-- Help labels that name a non-letter OEM key whose keycap moves on a
-- national layout. swapLabel only handles single letters; these symbol /
-- punctuation names are locale-specific words, so each gets a per-profile
-- string variant (base .. "_AZERTY" / "_QWERTZ") rather than a token swap.
-- Listed per profile because some keys only move on one of the two: the ','
-- key keeps its name everywhere, and '.' only moves on AZERTY (it becomes
-- the ';' key), so the cycle / city-hub labels need an AZERTY variant but
-- no QWERTZ one. resolveKeyLabel returns the variant when one is registered
-- for the active profile, otherwise the base key unchanged.
-- Exposed (read-only) so the test suite can drive its strings cross-check
-- off the real registry instead of a parallel hardcoded list. On AZERTY both
-- punctuation clusters move (unit prev/next/info and city prev/next shift to
-- ; : keys, message keys to ) = *). On QWERTZ the comma/period keys don't
-- move, so unit cycle and city prev/next keep their base labels; only info,
-- recenter, the message keys, and chat get QWERTZ variants.
KeyLayout.LABEL_VARIANTS = {
    azerty = {
        TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE = true,
        TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL = true,
        TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO = true,
        TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER = true,
        TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT = true,
        TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV = true,
        TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV = true,
        TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE = true,
        TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER = true,
        TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY = true,
        TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE = true,
    },
    qwertz = {
        TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO = true,
        TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER = true,
        TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV = true,
        TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE = true,
        TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER = true,
        TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY = true,
        TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE = true,
    },
}

-- Pick the layout-specific variant of a help key label when one exists.
function KeyLayout.resolveKeyLabel(baseKey)
    local profile = KeyLayout.activeProfile()
    local set = KeyLayout.LABEL_VARIANTS[profile]
    if set ~= nil and set[baseKey] then
        return baseKey .. "_" .. string.upper(profile)
    end
    return baseKey
end

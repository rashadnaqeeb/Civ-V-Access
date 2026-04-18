-- Icon spoken-text registry. Maps every [ICON_*] token commonly reaching the
-- pedia / tooltip pipeline to a TXT_KEY_CIVVACCESS_ICON_* string, then hands
-- that resolved text to TextFilter.registerIcon. After this include runs the
-- filter's substituteIcons pass replaces bracket tokens in speech with the
-- localizable spoken form (e.g. "[ICON_PRODUCTION]" -> "production").
--
-- Include order requirement: must load AFTER CivVAccess_TextFilter,
-- CivVAccess_<Context>Strings_<locale>, and CivVAccess_Text so Text.key can
-- resolve the TXT_KEYs into mapped strings at registration time. Loading it
-- earlier registers "TXT_KEY_CIVVACCESS_ICON_X" as the literal spoken form,
-- which is worse than the default strip-and-warn behavior.
--
-- Base-game text ships with occasional typo variants of icon names
-- (HAPPINES_4, STRENGHT, ALUMINNUM, CULTUR, GREATPEOPLE, CONNECTION). We map
-- those to the same TXT_KEY as their correctly-spelled counterpart so the
-- screen-reader user never hears a typo or a dropped token.

local ICON_KEYS = {
    -- Yields -------------------------------------------------------------
    ICON_GOLD                    = "TXT_KEY_CIVVACCESS_ICON_GOLD",
    ICON_FOOD                    = "TXT_KEY_CIVVACCESS_ICON_FOOD",
    ICON_PRODUCTION              = "TXT_KEY_CIVVACCESS_ICON_PRODUCTION",
    ICON_CULTURE                 = "TXT_KEY_CIVVACCESS_ICON_CULTURE",
    ICON_CULTUR                  = "TXT_KEY_CIVVACCESS_ICON_CULTURE",
    ICON_SCIENCE                 = "TXT_KEY_CIVVACCESS_ICON_SCIENCE",
    ICON_RESEARCH                = "TXT_KEY_CIVVACCESS_ICON_RESEARCH",
    ICON_FAITH                   = "TXT_KEY_CIVVACCESS_ICON_FAITH",
    -- ICON_PEACE is the pre-BNW faith glyph; pedia still uses it for the
    -- faith-purchase cost on units (costString = cost .. " [ICON_PEACE]").
    ICON_PEACE                   = "TXT_KEY_CIVVACCESS_ICON_FAITH",
    ICON_TOURISM                 = "TXT_KEY_CIVVACCESS_ICON_TOURISM",
    ICON_INFLUENCE               = "TXT_KEY_CIVVACCESS_ICON_INFLUENCE",

    -- Combat / movement --------------------------------------------------
    ICON_STRENGTH                = "TXT_KEY_CIVVACCESS_ICON_STRENGTH",
    ICON_STRENGHT                = "TXT_KEY_CIVVACCESS_ICON_STRENGTH",
    ICON_RANGE_STRENGTH          = "TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH",
    ICON_MOVES                   = "TXT_KEY_CIVVACCESS_ICON_MOVEMENT",
    ICON_MOVEMENT                = "TXT_KEY_CIVVACCESS_ICON_MOVEMENT",
    ICON_SWAP                    = "TXT_KEY_CIVVACCESS_ICON_SWAP",

    -- Happiness (HAPPINESS_1 is the positive face; 3 / 4 are negatives,
    -- and the engine labels them all "unhappy" in context) --------------
    ICON_HAPPINESS_1             = "TXT_KEY_CIVVACCESS_ICON_HAPPY",
    ICON_HAPPINESS               = "TXT_KEY_CIVVACCESS_ICON_UNHAPPY",
    ICON_HAPPINESS_3             = "TXT_KEY_CIVVACCESS_ICON_UNHAPPY",
    ICON_HAPPINESS_4             = "TXT_KEY_CIVVACCESS_ICON_UNHAPPY",
    ICON_HAPPINES_4              = "TXT_KEY_CIVVACCESS_ICON_UNHAPPY",

    -- City / population --------------------------------------------------
    ICON_CAPITAL                 = "TXT_KEY_CIVVACCESS_ICON_CAPITAL",
    ICON_CITIZEN                 = "TXT_KEY_CIVVACCESS_ICON_CITIZEN",
    ICON_CONNECTED               = "TXT_KEY_CIVVACCESS_ICON_CONNECTED",
    ICON_CONNECTION              = "TXT_KEY_CIVVACCESS_ICON_CONNECTED",
    ICON_OCCUPIED                = "TXT_KEY_CIVVACCESS_ICON_OCCUPIED",
    ICON_PUPPET                  = "TXT_KEY_CIVVACCESS_ICON_PUPPET",
    ICON_RAZING                  = "TXT_KEY_CIVVACCESS_ICON_RAZING",
    ICON_RESISTANCE              = "TXT_KEY_CIVVACCESS_ICON_RESISTANCE",
    ICON_BLOCKADED               = "TXT_KEY_CIVVACCESS_ICON_BLOCKADED",

    -- People / diplomacy / trade -----------------------------------------
    ICON_GREAT_PEOPLE            = "TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE",
    ICON_GREATPEOPLE             = "TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE",
    ICON_GREAT_WORK              = "TXT_KEY_CIVVACCESS_ICON_GREAT_WORK",
    ICON_GOLDEN_AGE              = "TXT_KEY_CIVVACCESS_ICON_GOLDEN_AGE",
    ICON_INTERNATIONAL_TRADE     = "TXT_KEY_CIVVACCESS_ICON_TRADE_ROUTE",
    ICON_SPY                     = "TXT_KEY_CIVVACCESS_ICON_SPY",
    ICON_DIPLOMAT                = "TXT_KEY_CIVVACCESS_ICON_DIPLOMAT",
    ICON_TURNS_REMAINING         = "TXT_KEY_CIVVACCESS_ICON_TURNS",

    -- Glyphs / arrows ----------------------------------------------------
    ICON_ARROW_LEFT              = "TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT",
    ICON_ARROW_RIGHT             = "TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT",
    ICON_PLUS                    = "TXT_KEY_CIVVACCESS_ICON_PLUS",
    ICON_MINUS                   = "TXT_KEY_CIVVACCESS_ICON_MINUS",
    ICON_BULLET                  = "TXT_KEY_CIVVACCESS_ICON_BULLET",

    -- Trophies (Diplomatic Victory / leaderboard) -----------------------
    ICON_TROPHY_BRONZE           = "TXT_KEY_CIVVACCESS_ICON_TROPHY_BRONZE",
    ICON_TROPHY_SILVER           = "TXT_KEY_CIVVACCESS_ICON_TROPHY_SILVER",
    ICON_TROPHY_GOLD             = "TXT_KEY_CIVVACCESS_ICON_TROPHY_GOLD",

    -- Victory types ------------------------------------------------------
    ICON_VICTORY_CULTURE         = "TXT_KEY_CIVVACCESS_ICON_VICTORY_CULTURE",
    ICON_VICTORY_DIPLOMACY       = "TXT_KEY_CIVVACCESS_ICON_VICTORY_DIPLOMACY",
    ICON_VICTORY_DOMINATION      = "TXT_KEY_CIVVACCESS_ICON_VICTORY_DOMINATION",
    ICON_VICTORY_SPACE           = "TXT_KEY_CIVVACCESS_ICON_VICTORY_SCIENCE",

    -- Religions ----------------------------------------------------------
    ICON_RELIGION                = "TXT_KEY_CIVVACCESS_ICON_RELIGION",
    ICON_RELIGION_PANTHEON       = "TXT_KEY_CIVVACCESS_ICON_RELIGION_PANTHEON",
    ICON_RELIGION_BUDDHISM       = "TXT_KEY_CIVVACCESS_ICON_RELIGION_BUDDHISM",
    ICON_RELIGION_CHRISTIANITY   = "TXT_KEY_CIVVACCESS_ICON_RELIGION_CHRISTIANITY",
    ICON_RELIGION_CONFUCIANISM   = "TXT_KEY_CIVVACCESS_ICON_RELIGION_CONFUCIANISM",
    ICON_RELIGION_HINDUISM       = "TXT_KEY_CIVVACCESS_ICON_RELIGION_HINDUISM",
    ICON_RELIGION_ISLAM          = "TXT_KEY_CIVVACCESS_ICON_RELIGION_ISLAM",
    ICON_RELIGION_JUDAISM        = "TXT_KEY_CIVVACCESS_ICON_RELIGION_JUDAISM",
    ICON_RELIGION_ORTHODOX       = "TXT_KEY_CIVVACCESS_ICON_RELIGION_ORTHODOX",
    ICON_RELIGION_PROTESTANT     = "TXT_KEY_CIVVACCESS_ICON_RELIGION_PROTESTANT",
    ICON_RELIGION_SHINTO         = "TXT_KEY_CIVVACCESS_ICON_RELIGION_SHINTO",
    ICON_RELIGION_SIKHISM        = "TXT_KEY_CIVVACCESS_ICON_RELIGION_SIKHISM",
    ICON_RELIGION_TAOISM         = "TXT_KEY_CIVVACCESS_ICON_RELIGION_TAOISM",
    ICON_RELIGION_TENGRIISM      = "TXT_KEY_CIVVACCESS_ICON_RELIGION_TENGRI",
    ICON_RELIGION_ZOROASTRIANISM = "TXT_KEY_CIVVACCESS_ICON_RELIGION_ZOROASTRIANISM",

    -- Strategic glyphs shared outside ICON_RES_* (a few early XMLs use
    -- the short form; the resource panel itself uses ICON_RES_*) --------
    ICON_OIL                     = "TXT_KEY_CIVVACCESS_ICON_RES_OIL",
    ICON_HORSE                   = "TXT_KEY_CIVVACCESS_ICON_RES_HORSES",

    -- Resources (ICON_RES_*) --------------------------------------------
    ICON_RES_ALUMINUM            = "TXT_KEY_CIVVACCESS_ICON_RES_ALUMINUM",
    ICON_RES_ALUMINNUM           = "TXT_KEY_CIVVACCESS_ICON_RES_ALUMINUM",
    ICON_RES_ARTIFACTS           = "TXT_KEY_CIVVACCESS_ICON_RES_ARTIFACT",
    ICON_RES_HIDDEN_ARTIFACTS    = "TXT_KEY_CIVVACCESS_ICON_RES_HIDDEN_ARTIFACT",
    ICON_RES_BANANA              = "TXT_KEY_CIVVACCESS_ICON_RES_BANANA",
    ICON_RES_BISON               = "TXT_KEY_CIVVACCESS_ICON_RES_BISON",
    ICON_RES_CITRUS              = "TXT_KEY_CIVVACCESS_ICON_RES_CITRUS",
    ICON_RES_CLOVES              = "TXT_KEY_CIVVACCESS_ICON_RES_CLOVES",
    ICON_RES_COAL                = "TXT_KEY_CIVVACCESS_ICON_RES_COAL",
    ICON_RES_COCOA               = "TXT_KEY_CIVVACCESS_ICON_RES_COCOA",
    ICON_RES_COPPER              = "TXT_KEY_CIVVACCESS_ICON_RES_COPPER",
    ICON_RES_COTTON              = "TXT_KEY_CIVVACCESS_ICON_RES_COTTON",
    ICON_RES_COW                 = "TXT_KEY_CIVVACCESS_ICON_RES_CATTLE",
    ICON_RES_CRAB                = "TXT_KEY_CIVVACCESS_ICON_RES_CRAB",
    ICON_RES_DEER                = "TXT_KEY_CIVVACCESS_ICON_RES_DEER",
    ICON_RES_DYE                 = "TXT_KEY_CIVVACCESS_ICON_RES_DYE",
    ICON_RES_FISH                = "TXT_KEY_CIVVACCESS_ICON_RES_FISH",
    ICON_RES_FUR                 = "TXT_KEY_CIVVACCESS_ICON_RES_FUR",
    ICON_RES_GEMS                = "TXT_KEY_CIVVACCESS_ICON_RES_GEMS",
    ICON_RES_GOLD                = "TXT_KEY_CIVVACCESS_ICON_RES_GOLD_ORE",
    ICON_RES_HORSE               = "TXT_KEY_CIVVACCESS_ICON_RES_HORSES",
    ICON_RES_INCENSE             = "TXT_KEY_CIVVACCESS_ICON_RES_INCENSE",
    ICON_RES_IRON                = "TXT_KEY_CIVVACCESS_ICON_RES_IRON",
    ICON_RES_IVORY               = "TXT_KEY_CIVVACCESS_ICON_RES_IVORY",
    ICON_RES_JEWELRY             = "TXT_KEY_CIVVACCESS_ICON_RES_JEWELRY",
    ICON_RES_MANPOWER            = "TXT_KEY_CIVVACCESS_ICON_RES_MANPOWER",
    ICON_RES_MARBLE              = "TXT_KEY_CIVVACCESS_ICON_RES_MARBLE",
    ICON_RES_NUTMEG              = "TXT_KEY_CIVVACCESS_ICON_RES_NUTMEG",
    ICON_RES_OIL                 = "TXT_KEY_CIVVACCESS_ICON_RES_OIL",
    ICON_RES_PEARLS              = "TXT_KEY_CIVVACCESS_ICON_RES_PEARLS",
    ICON_RES_PEPPER              = "TXT_KEY_CIVVACCESS_ICON_RES_PEPPER",
    ICON_RES_PORCELAIN           = "TXT_KEY_CIVVACCESS_ICON_RES_PORCELAIN",
    ICON_RES_SALT                = "TXT_KEY_CIVVACCESS_ICON_RES_SALT",
    ICON_RES_SHEEP               = "TXT_KEY_CIVVACCESS_ICON_RES_SHEEP",
    ICON_RES_SILK                = "TXT_KEY_CIVVACCESS_ICON_RES_SILK",
    ICON_RES_SILVER              = "TXT_KEY_CIVVACCESS_ICON_RES_SILVER",
    ICON_RES_SPICES              = "TXT_KEY_CIVVACCESS_ICON_RES_SPICES",
    ICON_RES_STONE               = "TXT_KEY_CIVVACCESS_ICON_RES_STONE",
    ICON_RES_SUGAR               = "TXT_KEY_CIVVACCESS_ICON_RES_SUGAR",
    ICON_RES_TRUFFLES            = "TXT_KEY_CIVVACCESS_ICON_RES_TRUFFLES",
    ICON_RES_URANIUM             = "TXT_KEY_CIVVACCESS_ICON_RES_URANIUM",
    ICON_RES_WHALE               = "TXT_KEY_CIVVACCESS_ICON_RES_WHALES",
    ICON_RES_WHEAT               = "TXT_KEY_CIVVACCESS_ICON_RES_WHEAT",
    ICON_RES_WINE                = "TXT_KEY_CIVVACCESS_ICON_RES_WINE",
}

for name, key in pairs(ICON_KEYS) do
    TextFilter.registerIcon(name, Text.key(key))
end

-- Exposed for the test harness to re-register after a TextFilter reload.
-- Offline tests dofile TextFilter fresh to reset its _iconMap closure, so
-- they need a hook to replay the registrations. Not used in-game.
Icons = { _keys = ICON_KEYS }

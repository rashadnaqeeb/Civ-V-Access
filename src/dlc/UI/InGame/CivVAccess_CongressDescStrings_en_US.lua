-- Mod-authored splash painting descriptions for World Congress special
-- sessions and projects, in-game popup Contexts. Every key is prefixed
-- TXT_KEY_CIVVACCESS_CONGRESSDESC_. Extends the shared CivVAccess_Strings
-- table already populated by CivVAccess_InGameStrings_en_US.lua; the
-- league popup wrappers include that baseline (via CivVAccess_PopupBoot)
-- before this file.
--
-- One entry per distinct painting. The three pre-UN special sessions
-- share one painting and resolve to the founding session's key via
-- CivVAccess_CongressDescription's alias table; the United Nations
-- session and the International Space Station project reuse the matching
-- wonder's description string (TXT_KEY_CIVVACCESS_WONDERDESC_*) the same
-- way, so neither has an entry here. The authoring source is
-- docs/congress-descriptions.md; edit there first, then mirror here.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_MISSING"] = "No description for this image."

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_SPECIAL_SESSION_START_WORLD_CONGRESS"] =
    "An assembly in session, viewed from the back of the hall over the heads of its audience. At the front, delegates sit around a long table draped in red on a carpeted platform, a white paper laid at each place. A figure in white robes and a white headdress stands at the head of the table to address the room, with a dark-bearded man at his side. The audience faces them from rows of wooden chairs, turbans and skullcaps and bare heads together. More onlookers watch from between pale columns along the right wall."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_PROJECT_WORLD_FAIR"] =
    "A giant Ferris wheel climbs out of the top of the frame at the right, enclosed passenger cars hanging from its rim. Its base comes down behind a great arch of green riveted iron, which spans a pale wall lettered FERRIS WHEEL. Fairgoers cross the wide dusty promenade below: women in long dresses, men in overcoats and bowler and top hats. Low fair buildings with painted signs line the way off to the left, where a white domed hall rises in the distance under a pale blue sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONGRESSDESC_LEAGUE_PROJECT_WORLD_GAMES"] =
    "The first steps of a race: four runners drive forward off the line, heads down, on a dark track that sweeps across the foreground. Behind them at the left, the starter stands in a long white coat, his pistol raised and still smoking. Packed stands fill the whole background, the crowd dabbed in as flecks of color. White ladder stands and tall posts line the trackside at the right, and the green of the infield runs out beyond them."

StringsLoader.loadOverlay("CivVAccess_CongressDescStrings")

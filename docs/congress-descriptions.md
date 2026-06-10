# World Congress - spoken descriptions

Spoken descriptions for the splash art of Brave New World's World Congress:
the session paintings shown when a special session convenes (the
SessionSplashImage column of the LeagueSpecialSessions table) and the project
paintings shown when an international project completes (the
ProjectSplashImage column of the LeagueProjects table), both in
CIV5Resolutions.xml.

Style follows wonder-descriptions.md: the subject first, then the surrounding
scene, figures, and action, then palette and light, in about three to five
sentences scaled to how busy the scene is. The session or project name is not
repeated because the popup already announces it. Written to be heard, not
read: fresh subjects enter with indefinite articles, sentences carry finite
verbs with at most one short absolute phrase and never a clause coordinated
onto the end of one, no homophone garden paths, period terms glossed inline,
plain punctuation, no em-dashes.

Two descriptions are reused from wonder-descriptions.md, verified against the
art. The United Nations session has no art of its own: its
SessionSplashImage is WonderConceptUN.dds, the United Nations wonder's own
splash texture. The International Space Station project's painting is the
same art as that wonder's splash at a slightly wider crop. Both entries
carry the wonder text verbatim so this file stands alone. As mod strings,
both resolve to the existing wonder description keys (BUILDING_UNITED_NATIONS
and BUILDING_INTERNATIONAL_SPACE_STATION) through the alias table in
CivVAccess_CongressDescription.lua rather than minting new ones, so the
text is not translated twice.

One painting serves the other three special sessions: World Congress
Founded, World Congress Welcomes City-States, and World Congress Expands
Infrastructure all use WorldCongress.dds, so they share one entry.

Each entry: in-game Type (or Types where sessions share art), English name,
the splash texture name, then the description text. The type key is the
stable identifier for turning these into mod strings. Entries are ordered by
texture name. Companion docs: wonder-descriptions.md, leader-descriptions.md,
great-work-descriptions.md, natural-wonder-descriptions.md,
victory-screen-descriptions.md.

---

## 1. LEAGUE_PROJECT_WORLD_GAMES
International Games, International_Games_939x614.dds

The first steps of a race: four runners drive forward off the line, heads down, on a dark track that sweeps across the foreground. Behind them at the left, the starter stands in a long white coat, his pistol raised and still smoking. Packed stands fill the whole background, the crowd dabbed in as flecks of color. White ladder stands and tall posts line the trackside at the right, and the green of the infield runs out beyond them.

## 2. LEAGUE_PROJECT_INTERNATIONAL_SPACE_STATION
International Space Station, International_SpaceStation_939x614.dds

Same painting as the International Space Station wonder splash at a slightly wider crop; description reused from wonder-descriptions.md.

A latticework station hangs in orbit against the black of space: a long central truss crossed by pairs of great blue-grey solar wings, with the chain of white cylindrical modules and docking nodes clustered at its center. A capsule is moored at the near end of the module chain, and radiator panels fan out flat below the truss. Behind it the Earth curves away in deep blue, swirls of cloud bright on its night side. Stars scatter in the black above. The image is clean and photographic: white metal, a blue planet, and no figures anywhere.

## 3. LEAGUE_PROJECT_WORLD_FAIR
World's Fair, International_WorldsFair_939x614.dds

A giant Ferris wheel climbs out of the top of the frame at the right, enclosed passenger cars hanging from its rim. Its base comes down behind a great arch of green riveted iron, which spans a pale wall lettered FERRIS WHEEL. Fairgoers cross the wide dusty promenade below: women in long dresses, men in overcoats and bowler and top hats. Low fair buildings with painted signs line the way off to the left, where a white domed hall rises in the distance under a pale blue sky.

## 4. LEAGUE_SPECIAL_SESSION_START_UNITED_NATIONS
World Congress Becomes United Nations, WonderConceptUN.dds

The session splash is the United Nations wonder's own texture; description reused from wonder-descriptions.md.

A street-level view of United Nations Plaza. The flat glass slab of the Secretariat tower rises at the left, above the long low sweep of the assembly building. A row of flagpoles carries the flags of many nations down the block. The plaza is full of delegates: men and women in business suits mixed with national dress, a figure in white Gulf robes and headdress at the center of the crowd, groups pausing in conversation on their way in. A yellow taxi waits at the curb on the right, and New York's skyline rises behind the flags. It is late afternoon, with long shadows across the pavement and low sun catching the glass.

## 5. LEAGUE_SPECIAL_SESSION_START_WORLD_CONGRESS, LEAGUE_SPECIAL_SESSION_WELCOME_CITY_STATES, LEAGUE_SPECIAL_SESSION_LEADERSHIP_COUNCIL
World Congress Founded / World Congress Welcomes City-States / World Congress Expands Infrastructure, WorldCongress.dds

An assembly in session, viewed from the back of the hall over the heads of its audience. At the front, delegates sit around a long table draped in red on a carpeted platform, a white paper laid at each place. A figure in white robes and a white headdress stands at the head of the table to address the room, with a dark-bearded man at his side. The audience faces them from rows of wooden chairs, turbans and skullcaps and bare heads together. More onlookers watch from between pale columns along the right wall.

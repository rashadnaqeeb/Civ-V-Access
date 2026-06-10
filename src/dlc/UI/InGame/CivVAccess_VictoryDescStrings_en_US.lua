-- Mod-authored background descriptions for the end-of-game screen,
-- in-game popup Contexts. Every key is prefixed
-- TXT_KEY_CIVVACCESS_VICTORYDESC_. Extends the shared CivVAccess_Strings
-- table already populated by CivVAccess_InGameStrings_en_US.lua; the
-- EndGameMenu wrapper includes that baseline (via CivVAccess_PopupBoot)
-- before this file.
--
-- One entry per end-game background painting (five victory types plus
-- defeat; BNW is frozen, so the set is fixed). Keys follow the Victories
-- table Type; DEFEAT is mod-named because the loss art has no Victories
-- row (EndGameMenu.lua hardcodes its texture). Spoken by F2 on the
-- end-of-game screen via CivVAccess_VictoryDescription. The authoring
-- source is docs/victory-screen-descriptions.md, written from the game's
-- full-resolution background art; edit there first, then mirror here.
-- Style: setting first, then figures and action, then palette and light.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_MISSING"] = "No description for this screen."

CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_VICTORY_CULTURAL"] =
    "From a grassy hilltop shaded by a dark tree, two figures sit in silhouette and look out over a golden city. Below them a crowd crosses an arched stone bridge flanked by classical statues on pedestals, a domed hall rising behind it. Beyond a stretch of parkland, the skyline climbs into slender futuristic towers that dissolve into amber haze. People dot the lawns: children run beneath a kite riding high on its string, a figure strolls under a yellow parasol, and white sails show on distant water through the mist. The whole scene is steeped in warm golden light, half late afternoon and half dream, with birds scattered across the sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_VICTORY_DIPLOMATIC"] =
    "A ceremony on a green lawn before the tall white slab of the United Nations headquarters. In the foreground a crowd stands with its back to you, dressed in suits, robes, and headscarves from many nations, while a television cameraman films from a tripod at the right. Flagpoles ring the lawn carrying dozens of national flags, the United States and Mexico recognizable among them. At the center a great stone globe rests on a square pedestal beneath spreading trees, its continents raised in relief. Before it waits a line of children in the folk costumes of different countries; a woman in blue bends to hand something to a small girl in a yellow dress who reaches up for it. Flowerbeds in red and white edge a still pond at the bottom of the frame, and soft gray daylight evens everything out."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_VICTORY_DOMINATION"] =
    "A victory parade painted in poster colors, all gold, olive, and red. In the right foreground a young officer in a white dress uniform with gold braid at the shoulder grips the staff of a huge red flag that billows out across the sky, his peaked cap banded in red with a gold badge. Behind him ranks of soldiers in matching white uniforms stand with bayoneted rifles upright at their shoulders, more red flags rising from the column. Above the parade a bronze statue of a commander on a striding horse stands atop a tall pedestal, a great domed capitol building behind it. Thin red banners stream in ribbons across a glowing yellow-green sky, with dark cypresses and hazy mountains closing off the distance."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_VICTORY_SPACE_RACE"] =
    "Deep space, looking up at a vast orbital station from below. Its dark hull stretches across the top of the frame, rows of tall warm-lit windows and green-glowing bays along its underside. Wisps of vapor drift across the metal. Flat gridded solar arrays spread from the hull on girdered booms, and a long panel-clad truss tower drops from its far end down the right side of the frame. Below, a planet's night side stretches away in deep violet and wine, its horizon arcing across the bottom of the scene. The sun is just breaking over that horizon in a white-gold flare that lights bands of rose and cream cloud along the curve. In the foreground a lone winged ship crosses the dark on a long luminous teal wake, and smaller craft glint green and orange in the distance against the stars."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_VICTORY_TIME"] =
    "The game's own cover art enlarged to fill the screen. A globe pieced from antique sepia maps dominates the frame, the title Sid Meier's Civilization standing across it in raised polished-metal letters threaded through a giant brass Roman numeral five. A worn Finnish postage stamp is pasted at the upper left, a rider on a decorated horse commemorating the Kalevala epic. Faint postmarks are inked around it. Behind the globe lies a collage of teal-stained paper, a brass meridian ring arcs around the globe's lower edge, and the light falls from the upper left as if on a curio under a lamp."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VICTORYDESC_DEFEAT"] =
    "A dead empire under a desert sky. The colossal stone head of a statue lies on its cheek in the sand, eyes closed and face serene, while a broken stone hand reaches out of the ground nearby, fingers curled at the sky. An excavation surrounds it: trenches cut into the foreground earth, a fence line of posts and wire, and a lone figure in pale clothes standing on a wooden stair platform, dwarfed by the face it studies. A pack animal waits off to the left. The empty valley runs back past scattered standing fragments to flat-topped mesas on the horizon. Everything is tan and rust under a thin blue sky, the lone and level sands of Shelley's Ozymandias stretching far away."

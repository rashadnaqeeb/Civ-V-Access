# Victory screens - spoken descriptions

Spoken descriptions for the six full-screen paintings the end-of-game screen
shows: one per victory type, plus defeat. Written from the game's own
background art at full resolution. Style: one paragraph of about four to six
sentences, moving setting first, then figures and action, then palette and
light. The victory type is not repeated because the end-game screen already
announces it; the description's job is the scene and its mood, which the art
carries entirely - triumph reads as triumph and defeat as desolation through
the concrete details alone. Every detail named is visible in the art. Plain
punctuation, no em-dashes.

Each entry: the Victories table Type, the texture name from its
VictoryBackground column, then the description text. The Type is the stable
identifier for turning these into mod strings. Note the mismatched pairs:
VICTORY_TIME uses Victory_Score.dds, VICTORY_SPACE_RACE uses
Victory_Scientific.dds, VICTORY_DOMINATION uses Victory_Military.dds. Defeat
has no Victories row; EndGameMenu.lua hardcodes Victory_Defeat.dds. Companion
docs: leader-descriptions.md, great-work-descriptions.md,
natural-wonder-descriptions.md.

---

## 1. VICTORY_CULTURAL
Victory_Cultural.dds

From a grassy hilltop shaded by a dark tree, two figures sit in silhouette and look out over a golden city. Below them a crowd crosses an arched stone bridge flanked by classical statues on pedestals, a domed hall rising behind it. Beyond the parkland the skyline climbs into slender futuristic towers that dissolve into amber haze. People dot the lawns: children run beneath a kite riding high on its string, a figure strolls under a yellow parasol, and white sails show on the water through the mist. The whole scene is steeped in warm golden light, half late afternoon and half dream, with birds scattered across the sky.

## 2. VICTORY_DIPLOMATIC
Victory_Diplomatic.dds

A ceremony on a green lawn before the tall white slab of the United Nations headquarters. In the foreground a crowd stands with its back to you, dressed in suits, robes, and headscarves from many nations, while a television cameraman films from a tripod at the right. Flagpoles ring the lawn carrying dozens of national flags, the United States and Mexico recognizable among them. At the center a great stone globe rests on a square pedestal beneath spreading trees, its continents raised in relief, and before it waits a line of children in the folk costumes of different countries; a woman in blue bends to hand something to a small girl in a yellow dress who reaches up for it. Flowerbeds in red and white edge a still pond in the foreground, and soft gray daylight evens everything out.

## 3. VICTORY_DOMINATION
Victory_Military.dds

A victory parade painted in poster colors, all gold, olive, and red. In the right foreground a young officer in a white dress uniform with gold braid at the shoulder grips the staff of a huge red flag that billows out across the sky, his peaked cap banded in red with a gold badge. Behind him ranks of soldiers in matching white uniforms stand with bayoneted rifles upright at their shoulders, more red flags rising from the column. Above the parade a bronze equestrian statue of a commander strides atop a tall pedestal, a great domed capitol behind it. Thin red banners stream in ribbons across a glowing yellow-green sky, with dark cypresses and hazy mountains closing the distance.

## 4. VICTORY_SPACE_RACE
Victory_Scientific.dds

Deep space, looking up at a vast orbital station from below. Its dark hull stretches across the top of the frame, rows of tall warm-lit windows and green-glowing bays along its underside, wisps of vapor drifting across the metal. Flat gridded solar arrays spread from the hull on girdered booms, and a long panel-clad truss tower drops from its far end down the right side of the frame. Below, a planet's night side stretches away in deep violet and wine, its horizon arcing across the bottom of the scene, and the sun is just breaking over that horizon in a white-gold flare that lights bands of rose and cream cloud along the curve. In the foreground a lone winged ship crosses the dark on a long luminous teal wake, and smaller craft glint green and orange in the distance against the stars.

## 5. VICTORY_TIME
Victory_Score.dds

The game's own cover art enlarged to fill the screen. A globe pieced from antique sepia maps dominates the frame, the title Sid Meier's Civilization standing across it in raised polished-metal letters threaded through a giant brass Roman numeral five. A worn Finnish postage stamp is pasted at the upper left, a rider on a decorated horse commemorating the Kalevala epic, faint postmarks inked around it. Behind the globe lies a collage of teal-stained paper, a brass meridian ring arcs around the globe's lower edge, and the light falls from the upper left as if on a curio under a lamp.

## 6. Defeat
Victory_Defeat.dds (hardcoded in EndGameMenu.lua; no Victories row)

A dead empire under a desert sky. The colossal stone head of a statue lies on its cheek in the sand, eyes closed and face serene, while a broken stone hand reaches out of the ground nearby, fingers curled at the sky. An excavation surrounds it: trenches cut into the foreground earth, a fence line of posts and wire, and a lone figure in pale clothes standing on a wooden stair platform, dwarfed by the face it studies, a pack animal waiting off to the left. The empty valley runs back past scattered standing fragments to flat-topped mesas on the horizon. Everything is tan and rust under a thin blue sky, the lone and level sands of Shelley's Ozymandias stretching far away.

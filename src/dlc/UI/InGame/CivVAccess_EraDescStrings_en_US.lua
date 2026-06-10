-- Mod-authored splash painting descriptions for era changes, in-game
-- popup Contexts. Every key is prefixed TXT_KEY_CIVVACCESS_ERADESC_.
-- Extends the shared CivVAccess_Strings table already populated by
-- CivVAccess_InGameStrings_en_US.lua; the NewEraPopup wrapper includes
-- that baseline (via CivVAccess_PopupBoot) before this file.
--
-- One entry per era with splash art (seven; ERA_ANCIENT has none because
-- the game starts there, and BNW is frozen, so the set is fixed). Spoken
-- by F2 on the new era popup via CivVAccess_EraDescription. The authoring
-- source is docs/era-descriptions.md, written from the banner paintings
-- the popup shows; edit there first, then mirror here. Style: the scene
-- first, then figures and action.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_MISSING"] = "No description for this era."

CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_ERA_CLASSICAL"] =
    "A great columned temple stands highest on a terraced hilltop; smaller colonnaded halls step down to its right. Gardens climb the slope beneath them, where narrow stairways wind past a pale rock outcrop crowded with cypresses and flowering shrubs. All the marble glows warm gold in the sun."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_ERA_MEDIEVAL"] =
    "Golden wheat fields roll beneath a walled town of pale towers on a hill. Red banners hang from its battlements; the largest carries a black bird with spread wings. It is harvest time: stooped peasants gather the cut grain, others carry tall sheaves on their backs, and workers at the center heap a wagon hitched to a pair of dark oxen. Trees lean in at the top corners under a soft hazy sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_ERA_RENAISSANCE"] =
    "High over the rooftops of Florence, Michelangelo stands on a wooden ladder, carving the colossal white marble David. The statue's head and shoulders alone fill the left of the frame; the sculptor reaches barely past its shoulder. Below, red tiled roofs stretch away to the great dome of Florence Cathedral and a slender bell tower. Behind them, golden light breaks through the storm-dark sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_ERA_INDUSTRIAL"] =
    "A red and white paddle steamer crosses New York Harbor in the foreground, trailing smoke from two black stacks. Passengers line its double decks. Behind it the Statue of Liberty rises green against a hazy amber sky; more ships steam across the water beyond. Smoke and haze tint the whole scene warm sepia and gold."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_ERA_MODERN"] =
    "The viewer looks out from the rooftop of one high-rise across a city full of them. Lit towers recede block after block into golden haze. Far below, elevated highways loop through a sweeping interchange where cars and trucks stream along the curves. The whole painting is one color, gold and sepia like a tinted photograph."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_ERA_POSTMODERN"] =
    "A low sun blazes at the far end of a mid-century downtown street, flooding it with golden light. Men in suits and fedoras walk the right-hand sidewalk with their backs to the viewer, past awnings and a large lettered marquee. Rounded dark sedans park along the curb or roll past. Ahead, the buildings dissolve into the glare."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ERADESC_ERA_FUTURE"] =
    "A futuristic city gleams along a golden coastline, its slender towers receding up the shore into haze. On the left a sleek red and white jet banks over the water; behind it a suspension bridge spans the bay. In the right foreground a dome-topped complex of chrome and glass is built into the sea cliffs themselves. Greenery lines its ledges; a lone figure stands out on a walkway."

StringsLoader.loadOverlay("CivVAccess_EraDescStrings")

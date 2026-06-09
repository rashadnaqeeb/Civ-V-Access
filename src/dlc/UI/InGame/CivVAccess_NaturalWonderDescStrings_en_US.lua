-- Mod-authored portrait descriptions for natural wonders, in-game popup
-- Contexts. Every key is prefixed TXT_KEY_CIVVACCESS_NWDESC_.
-- Extends the shared CivVAccess_Strings table already populated by
-- CivVAccess_InGameStrings_en_US.lua; the NaturalWonderPopup wrapper
-- includes that baseline (via CivVAccess_PopupBoot) before this file.
--
-- One entry per natural wonder in BNW (17 wonders; BNW is frozen, so
-- the set is fixed). Spoken by F2 on the natural wonder discovery popup
-- via CivVAccess_NaturalWonderDescription. The authoring source is
-- docs/natural-wonder-descriptions.md, written from the game's 256px
-- atlas portraits; edit there first, then mirror here. Style: the
-- subject first, then palette and light.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_MISSING"] = "No description for this natural wonder."

CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_CRATER"] =
    "A vast impact crater seen from its rim, a ragged bowl punched into pale desert ground. The near slope is covered in green scrub that drops away into the shadowed pit, whose floor lies in deep brown darkness, and the far rim rises in bands of tan and gold under a hazy sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_EL_DORADO"] =
    "A stepped pyramid of solid gold, with a steep stairway climbing its face to a small shrine at the top. Giant gold ingots are stacked at its base among slender dark trees, and the whole scene glows yellow, the mythical city's treasure made literal. The light rays behind it read as sunrise breaking over the lost city."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_FOUNTAIN_YOUTH"] =
    "A spring of impossibly bright turquoise water wells up from a basin atop dark rock cliffs and spills down as a glowing waterfall into the pool below. Tufts of green grass cling to the black rock, palm fronds frame a warm golden sky, and tiny sparkles in the water mark it as magical rather than natural."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_FUJI"] =
    "A perfect volcanic cone fills the frame, its broad snow cap reaching most of the way down the slopes. The snow is painted in soft white and pale blue against a deep blue sky, and a strip of green brush and misty water lies along the mountain's foot."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_GEYSER"] =
    "A geyser erupts from a craggy pale mound, its white spray fanning out to fill the whole sky with mist against the blue. Dark evergreen forest closes in on both sides, and the foreground is a crust of mineral terraces in tan, ochre, and brown."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_GIBRALTAR"] =
    "A great limestone promontory rises from a flat sea, sheer pale cliffs on its left face and a long slope of dark green vegetation running down its back. The whole scene is washed in gold, the sky and water glowing like late afternoon."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_KILIMANJARO"] =
    "A huge snow-streaked dome fills the upper half of the frame in icy white and blue, with a ring of small clouds drifting at its base. Below it spreads green savanna where two giraffes stand by a pale waterhole, flat-topped trees at the edges of the scene."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_LAKE_VICTORIA"] =
    "A broad turquoise lake stretches back to pale hills on the horizon, hemmed in by rocky tan outcrops on either side. In the center foreground a hippopotamus surfaces, its head and back breaking the rippled water, under a white glow of light filling the sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_MESA"] =
    "A flat-topped mesa of layered red-orange rock rises alone from a dry plain, banded cliff walls above long talus slopes. Sparse green scrub dots the sandy ground at its foot, and the flat summit cuts a hard line against a bright blue sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_MT_KAILASH"] =
    "A pyramid of banded rock and snow rises against a deep blue sky, its striped face lit warm gold on one side. Below it the foreground is all rough snowfield and ice ridges in cold blue shadow."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_MT_SINAI"] =
    "A cluster of craggy desert peaks in orange-brown sandstone, deep gullies scoring their faces, with a soft glow of light breaking from behind the central summit. Scattered boulders litter the sandy flat in the foreground under a clear blue sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_POTOSI"] =
    "A bare reddish-brown mountain whose lower slopes are buried under heaps of grey boulders glinting with silver ore. A trail winds up its flank, rows of dark squared blocks line its base like mine workings, and the dusty summit stands against a blue sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_REEF"] =
    "An underwater scene: coral crowds the left and bottom of the frame in orange, red, purple, and pale blue, with tube sponges standing upright among the branches. Small tropical fish drift through the deep blue water, a bright yellow one at the center, and the light dims into open darkness toward the upper right."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_SOLOMONS_MINES"] =
    "A monumental gatehouse standing in for the legendary mines: a tall dark fortress wall crowned with gold-tipped battlements, a doorway at its center, flanked by tan stone towers. In front of it the pale rock floor is carved into sweeping curves, as if the ground itself had been quarried smooth."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_SRI_PADA"] =
    "A lush green mountain rises to a rounded peak, jungle covering its slopes except where orange-brown rock breaks through in cliffs. Tall blades of grass with small blue flowers fill the foreground, and the sky behind is a vivid tropical turquoise."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_ULURU"] =
    "A great red monolith lies across the middle distance, its rounded sandstone mass furrowed with vertical grooves and glowing orange in the light. In front of it stretches flat outback scrub, red earth patched with low green brush and tufts of grass, under a bright blue sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NWDESC_FEATURE_VOLCANO"] =
    "A dark volcanic cone rises from the sea beyond a strip of pale turquoise water, seen from a jungle shore whose broad green leaves frame the scene. The sky above it burns sulfurous yellow, with a faint curl of smoke over the summit hinting at the eruption to come."

-- Apply the active locale's overlay so every Context that includes this
-- baseline gets the localized overrides (mirrors CivVAccess_GreatWorkDescStrings).
include("CivVAccess_StringsLoader")
StringsLoader.loadOverlay("CivVAccess_NaturalWonderDescStrings")

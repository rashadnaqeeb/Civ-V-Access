# Civilization V UI Text Keys (EN_US)

Extracted from the shipped game's English text XML (`Assets/Gameplay/XML/NewText/EN_US/`, all DLC `Text/EN_US/` and Expansion `Text/en_US/` dirs). Filter: text length <= 120 chars, no `[NEWLINE]` markup, no prose-content key suffixes.

5028 keys grouped by inferred category from the key prefix. Use Ctrl-F to find a label before adding a mod-authored string. If a key is listed multiple times across DLC text files, all sources are shown — the engine merges them into one global table and the last-loaded value wins (in practice the texts match).

Lookup at runtime: `Locale.ConvertTextKey("TXT_KEY_X")`. Returned strings may contain markup tokens (`[ICON_GOLD]`, `[COLOR_X]`, `{1_n}` placeholders) that need stripping or filling before reaching Tolk.

Regenerate with `python _extract.py` from this directory.

---

## Generic actions (473)

- `TXT_KEY_1066_SCENARIO_CIV_NORMANDY_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_CIV_NORWAY_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_ACCEPT_BUTTON` — Accept  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISORINFOPOPUP_BACK` — Go back  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISORS_ECONOMIC_ADV_QUEST` — Why is the economic advisor so great?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_ECONOMIC_HEADING3_BODY` — The Economic Advisor provides advice on building and improving your cities and territory.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_ECONOMIC_HEADING3_TITLE` — Economic  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISOR_COUNSEL_ECONOMIC_NEXT` — Next  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_ECONOMIC_PREV` — Previous  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GREAT_GENERAL_ACTIVATE_BUTTON` — Find Great General  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GREAT_GENERAL_DISPLAY` — Great General  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MODAL_CANCEL` — Let me reconsider  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MODAL_CONFIRM` — I want to attack anyway  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_ECONOMIC_OVERVIEW_DISPLAY` — Economic Overview  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_AD_SETUP_NO_BARBARIANS` — No Barbarians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_NO_BARBARIANS_TT` — Removes all Barbarians from the map.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_BACK_BUTTON` — Back  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_BEGIN_GAME_BUTTON_CONTINUE` — Continue Your Journey  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CANCEL_BUTTON` — Cancel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CHOOSE_IDEOLOGY_CONFIRM` — Are you sure you wish to adopt [COLOR_POSITIVE_TEXT]{@1_PolicyName}[ENDCOLOR]?  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_RELIGION_CONFIRM` — Are you sure you wish to found {1_ReligionName}?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CHOOSE_RELIGION_CONFIRM_ENHANCE` — Are you ready to enhance {1_ReligionName}?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CHOOSE_RELIGION_OK_BUTTON` — Found Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CHOOSE_RELIGION_OK_BUTTON_ENHANCE` — Enhance Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CITIES_NONCOMBATUNITS_HEADING3_TITLE` — Non-Combat Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_SPECIALISTSNOTWORKINGFIELDS_HEADING3_TITLE` — Specialists are Not in the Fields  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_DONOTHING_HEADING3_TITLE` — Doing Nothing  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_ECONOMIC` — Your Economic Advisor recommends building this here.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CITY_STATE_DIPLO_JUST_REVOKED_PROTECTION` — Very well, turn your back on us if you must.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_GENOA_TITLE` — Genoa  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_HANOI_TITLE` — Hanoi  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_HONOR_HEADING` — Honor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_PLANNEDECONOMY_HEADING` — Planned Economy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DYES_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DYES_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DYES_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DYES_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DYES_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_SNOW_TITLE1` — City Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_SNOW_TITLE2` — Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_SNOW_TITLE3` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_SNOW_TITLE4` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_SNOW_TITLE5` — Combat Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_MINOR_CIV_LIST` — City-State List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_TECHNOLOGY_LIST` — Technology List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_CANNON_HEADING` — Cannon  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CLOSE` — Close  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_CONFIRM_BULLY` — Are you sure you want to demand tribute from {1_MinorCivName:textkey}?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_CONFIRM_CHOOSE_TRADE_ROUTE` — Are you sure?  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CONFIRM_DENOUNCE` — Are you sure you want to publicly denounce {@1_LeaderName}?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CONFIRM_DISABLE_MOD` — Are you sure you wish to disable this mod?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CONFIRM_ENABLE_MOD` — Are you sure you wish to enable this mod?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CONFIRM_KICK` — Are you sure you want to kick {1_PlayerName:textkey} from the game?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CONFIRM_KICK_PLAYER_DESC` — Are you sure you wish to kick {1_player} from the game?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_CONFIRM_KICK_PLAYER_TITLE` — Confirm Kick Player  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_CONFIRM_PANTHEON` — Are you sure you wish to adopt [COLOR_GREEN]{1_BeliefName}[ENDCOLOR]?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONFIRM_POLICY` — Are you sure you want to adopt this Social Policy?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CONFIRM_TXT` — This will permanently delete your save file. Are you sure you want to do this?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CONFIRM_WAR` — Are you sure you want to declare war?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CONFIRM_WAR_PROTECTED_CITY_STATE` — Are you sure you want to declare war on {1_CivName:textkey}? They are currently under the protection of:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CO_OPINION_TT_NOT_INFLUENCED` — Not influenced by the Ideology of any other civ.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_DEAL_ACCEPTED` — Deal Accepted  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_ACCEPTED_BY_THEM` — Your offer to {1_Player} has been accepted  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_ACCEPTED_BY_YOU` — You have accepted the offer from {1_Player}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLOMACY_DENOUNCE_ADV_QUEST` — Denounce  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DENOUNCE_HEADING3_TITLE` — Denounce  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLO_ACCEPT` — ACCEPT  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_BACKSTABBED` — [COLOR_NEGATIVE_TEXT]Backstabbed {1_CivName:textkey}[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_BORDER_PROMISE_IGNORED` — [COLOR_NEGATIVE_TEXT]They asked you to stop buying land near them, and you ignored them![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CANCEL` — BACK  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CITY_STATE_PROMISE_IGNORED` — [COLOR_NEGATIVE_TEXT]They asked you to stop attacking a City-State friendly to them, and you ignored them![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CLOSE_CHAT` — Close Chat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_CLOSE_CHAT_TT` — Toggles the Chat Panel.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_DENOUNCED` — [COLOR_NEGATIVE_TEXT]Denounced {1_CivName:textkey}[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DENOUNCED_BY_PEOPLE_WE_TRUST_MORE` — [COLOR_NEGATIVE_TEXT]Other civs that we like more than you have denounced you![ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DENOUNCED_BY_THEM` — [COLOR_NEGATIVE_TEXT]They have denounced us![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DENOUNCED_BY_US` — [COLOR_NEGATIVE_TEXT]We have denounced them![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_CAUGHT_DENOUNCE_FOR_SPYING` — Publicly denounce {1_LeaderName}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_COOP_WAR_NOW` — Let's get this started. (Declares War)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_COOP_WAR_YES` — Yes, let's get this started. (Declares War)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_DENOUNCE` — Publicly denounce {1_LeaderName}.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_OKAY` — Very well.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_NOT_SORRY_FOR_SPY_CAUGHT` — My agents go where they please.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_NOT_SORRY_FOR_SPY_KILLED` — Even death does not stop my ambition!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_NOT_YOUR_BUSINESS` — Our affairs are none of your business.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_NO_DIVIDE` — Very well. I won't let this create a divide between us.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_NO_GO_IT_ALONE` — Sorry, we prefer to go it alone.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_SORRY_NO_INTEREST` — Sorry, we have no interest in this arrangement.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_WE_MEAN_NO_HARM` — We mean no harm. Our units are merely passing through the area.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_YES_LET_US_PREPARE` — Yes, let us begin preparations.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_YES_WORK_TOGETHER` — Yes, let us work together.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISUCSS_ANOTHER_LEADER` — Let us discuss another leader...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_EXPANSION_PROMISE_IGNORED` — [COLOR_NEGATIVE_TEXT]They asked you to stop settling near them, and you ignored them![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HUMAN_DENOUNCED_BY_FRIENDS` — [COLOR_NEGATIVE_TEXT]Your friends found reason to Denounce you![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIEND` — [COLOR_NEGATIVE_TEXT]You have Denounced a leader they made a Declaration of Friendship with![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIENDS` — [COLOR_NEGATIVE_TEXT]You have Denounced leaders you've made Declarations of Friendship with![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HUMAN_FRIEND_DENOUNCED` — [COLOR_NEGATIVE_TEXT]We made a Declarations of Friendship and then denounced them![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_LUX_RESCR_TRADE_NO` — We have no Luxury Resources available to trade.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_LUX_RESCR_TRADE_NO_THEM` — The other leader has no Luxury Resources available to trade.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_LUX_RESCR_TRADE_YES` — We have Luxury Resources available to trade.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_LUX_RESCR_TRADE_YES_THEM` — The other leader has Luxury Resources available to trade.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING` — [COLOR_WARNING_TEXT]DENOUNCING![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MAY_NOT_ATTACK` — May not attack this player until current Peace Treaty expires.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MAY_NOT_ATTACK_MOD` — May not attack this player due to a scenario special rule.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MILITARY_PROMISE_IGNORED` — [COLOR_NEGATIVE_TEXT]You refused to move your troops away from their borders when they asked![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MINOR_ALLY_AT_WAR` — City-State is allied with a player at war with the leader you're speaking with.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MINOR_CIV_DISPUTE` — [COLOR_NEGATIVE_TEXT]You are competing for the favor of the same City-States![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MINOR_OTHER_GUY_WANTS_WAR` — This player has no desire to go to peace with the leader you're speaking with.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MINOR_PERMANENT_WAR` — City-State has declared a permanent war against this player.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MINOR_THIS_GUY_WANTS_WAR` — The leader you're speaking with has no desire to go to peace with this player.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_NOTIFICATION_LOG_TT` — Your Notification History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_NOT_AT_WAR` — These players are not at war.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_NO_CONVERT_PROMISE_BROKEN` — [COLOR_NEGATIVE_TEXT]You made a promise to stop converting their cities, and then broke it![ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_NO_CONVERT_PROMISE_IGNORED` — [COLOR_NEGATIVE_TEXT]They asked you to stop converting their cities, and you ignored them![ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_NO_DIG_PROMISE_BROKEN` — [COLOR_NEGATIVE_TEXT]You excavated artifacts from their land![ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_NO_DIG_PROMISE_IGNORED` — [COLOR_NEGATIVE_TEXT]They asked you to stop excavating their artifacts, and you ignored them![ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_NO_LAND_DISPUTE` — You have no contested borders.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_NO_SETTLE_ASKED` — [COLOR_NEGATIVE_TEXT]You demanded they not settle near your lands![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_NO_WAR_ALLIES` — These players are allies.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_OTHER_PLAYERS_NO_PLAYERS` — We haven't met any third party players.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_OTHER_PLAYERS_NO_PLAYERS_THEM` — The other leader hasn't met any third party players.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_PROTECTED_MINORS_ATTACKED` — [COLOR_NEGATIVE_TEXT]You have attacked City-States under their protection![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_PROTECTED_MINORS_BULLIED` — [COLOR_NEGATIVE_TEXT]You have demanded tribute from City-States under their protection![ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_PROTECTED_MINORS_KILLED` — [COLOR_NEGATIVE_TEXT]You have killed City-States under their protection![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_SIDED_WITH_MINOR` — [COLOR_NEGATIVE_TEXT]They mistreated your protected City-States, and you didn't look the other way![ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_SPY_PROMISE_BROKEN` — [COLOR_NEGATIVE_TEXT]You made a promise to stop spying on them, and then broke it![ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_SPY_PROMISE_IGNORED` — [COLOR_NEGATIVE_TEXT]They asked you to stop spying on them, and you ignored them!.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_STRAT_RESCR_TRADE_NO` — We have no Strategic Resources available to trade.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_STRAT_RESCR_TRADE_NO_THEM` — The other leader has no Strategic Resources available to trade.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_STRAT_RESCR_TRADE_YES` — We have Strategic Resources available to trade.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_STRAT_RESCR_TRADE_YES_THEM` — The other leader has Strategic Resources available to trade.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_TO_TRADE_CITY_NO_THEM` — They don't have any tradeable cities.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_TO_TRADE_CITY_NO_TT` — We don't have any tradeable cities.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_VOTE_TRADE_NO` — We have no Delegate support to trade.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_DIPLO_VOTE_TRADE_NO_THEM` — They have no Delegate support to trade.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_DIPLO_VOTE_TRADE_YES` — We have Delegate support to trade.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_DIPLO_VOTE_TRADE_YES_THEM` — They have Delegate support to trade.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_DIPLO_WARMONGER_THREAT_MINOR` — [COLOR_WARNING_TEXT]They have some early concerns about your warmongering.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_YOU_HAVE_BACKSTABBED` — [COLOR_NEGATIVE_TEXT]BACKSTABBED[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_YOU_HAVE_DENOUNCED` — [COLOR_NEGATIVE_TEXT]DENOUNCED[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_ECONOMIC_OVERVIEW` — Economic Overview  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_EO_CITY_VIEW_DISABLED_NO_CITY_TT` — A spy must be moved to a city to be able to view a city screen.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_SPY_COUP_DISABLED_NO_ALLY_TT` — {1_SpyRank} {2_SpyName} may not attempt a coup in {3_CityName} because no one is currently allied with {4_CityName}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_HONORIUS_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_HONORIUS_SUBTITLE` — Emperor of the Western Roman Empire  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_GAME_OPTION_NO_BARBARIANS` — No Barbarians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_NO_CHANGING_WAR_PEACE` — Permanent War or Peace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_NO_CITY_RAZING` — No City Razing  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_NO_CULTURE_OVERVIEW_UI` — Disable Culture Overview UI  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion2.xml`
- `TXT_KEY_GAME_OPTION_NO_ESPIONAGE` — No Espionage  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`
- `TXT_KEY_GAME_OPTION_NO_GOODY_HUTS` — No Ancient Ruins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_NO_HAPPINESS` — Disable Happiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_NO_LEAGUES` — Disable World Congress  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion2.xml`
- `TXT_KEY_GAME_OPTION_NO_POLICIES` — Disable Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_NO_RELIGION` — Disable Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`
- `TXT_KEY_GAME_OPTION_NO_SCIENCE` — Disable Research  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_NO_TUTORIAL` — Disable Tutorial Popups  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GENERIC_TRADE_DEAL_UNCHANGED_1` — This deal will work as it stands on the table.  
  source: `Gameplay/XML/NewText/EN_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_GENERIC_TRADE_DEAL_UNCHANGED_2` — The deal looks good to me as it is.  
  source: `Gameplay/XML/NewText/EN_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_GENERIC_TRADE_DEAL_UNCHANGED_3` — Looks good to me.  
  source: `Gameplay/XML/NewText/EN_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_GENERIC_TRADE_NO_DEAL_POSSIBLE_1` — I'm sorry, I don't see a way to make this deal work.  
  source: `Gameplay/XML/NewText/EN_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_GENERIC_TRADE_NO_DEAL_POSSIBLE_2` — There is no way to make this work.  
  source: `Gameplay/XML/NewText/EN_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_HONOR_TITLE` — {1_PlayerName:textkey} the Great of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_LEAGUE_NOT_FOUNDED_GAME_SETTINGS` — The World Congress is disabled for this game.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_CONFIRM` — Are you sure?  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_CONFIRM_MISSING_VOTES` — [COLOR_WARNING_TEXT]Some of your Delegates are not assigned.[ENDCOLOR]  Do you want to commit anyway?  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEGAL_CONTINUE` — Click to Continue  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MAP_OPTION_NO` — No  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_NORMAL` — Normal  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_NO_JUNGLES` — No Jungles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_NO_TINY_ISLANDS` — No Tiny Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SPOKE_WIDTH` — Spoke Width  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_YES_10_CIVS_MAX` — Yes (10 Civs Max)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MINOR_QUEST_BLOCKING_TT` — [COLOR_POSITIVE_TEXT]RIGHT-CLICK[ENDCOLOR] to dismiss.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_MODDING_BACK` — Back  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CANCELDOWNLOAD` — Cancel  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CLOSEDOWNLOAD` — Close  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DETAILS_NOTHINGSELECTED` — Nothing selected.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADER_NOTINITIALIZED` — Cannot download because Microsoft BITS has not been started.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_HTTP_FILE_NOT_FOUND` — HTTP 404 error - File not found.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_REQUEST_CANCELLED` — The request was canceled.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_SAVE_DLC_NOT_PURCHASED` — [COLOR_RED]Required DLC has not been purchased.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_EULA_ACCEPT` — Accept  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_EULA_DECLINE` — Decline  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FLAG_NOREASON` — No reason selected  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELNO` — [COLOR_RED]No[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELYES` — [COLOR_GREEN]Yes[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MENU_BACK` — BACK  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_NOACTIVEDOWNLOADS` — Nothing to download.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_NOASSOCIATIONS` — None  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_NOMODSINSTALLED` — No Mods Installed  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_UNSUBSCRIBE_CONFIRM` — Are you sure you wish to unsubscribe from this mod?  Doing so will remove the mod from your computer.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MOVE_SPY_CANCEL_TT` — This cancels the spy's movement and keeps them in their current location.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_MP_PLAYER_CHANGE_CONTINUE` — Continue  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MULTIPLAYER_CANCEL_LOAD_TT` — Cancel Loading a Multiplayer Save.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_LOBBY_NO` — No  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_LOBBY_YES` — Yes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_DIPLO_MAY_NOT_ATTACK_MOD` — May not attack this player until you research the Piracy technology.  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_DIPLO_RESCH_AGREEMENT_NO_TECH` — Trading of research agreements is not allowed in this scenario.  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_MAYA_PANTHEON_CONFIRM` — Are you sure you want to adopt these beliefs?  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NOTIFICATION_AUTOMATIC_FAITH_PURCHASE` — {TXT_KEY_GRAMMAR_UPPER_A_AN << {1_Name}} has been purchased in {2_City}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CITY_RESOURCE_WONDER_MOD_SUMMARY` — {1_CityName:textkey} has {2_ResourceName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_NO_LONGER_INFLUENTIAL_TT` — Your culture is no longer Influential with one or more civs.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_SOMEONE_INFLUENTIAL_ACTIVE_PLAYER_TT` — You are the first civilization to achieve a culture that is Influential with another player.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_UNMET_INFLUENTIAL_TT` — An unmet civilization is the first civilization to achieve a culture that is Influential with another player.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_WITHIN_ONE_ACTIVE_PLAYER_TT` — Your culture only needs to become Influential with 1 more civilization to win a Culture Victory!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_WITHIN_ONE_TT` — {1_CivName} only needs their culture to become Influential with 1 more civilization to win a Culture Victory!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_WITHIN_ONE_UNMET_TT` — An unmet civilization only needs their culture to become Influential with 1 more civilization to win a Culture Victory!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_WITHIN_TWO_ACTIVE_PLAYER_TT` — Your culture only needs to become Influential with 2 more civilizations to win a Culture Victory.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_WITHIN_TWO_TT` — {1_CivName} only needs their culture to become Influential with 2 more civilizations to win a Culture Victory.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_CULTURE_VICTORY_WITHIN_TWO_UNMET_TT` — An unmet civilization only needs their culture to become Influential with 2 more civilizations to win a Culture Victory.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_DEFENSIVE_PACT_FROM_US` — Our Defensive Pact with {1_CivName:textkey} has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_DEFENSIVE_PACT_TO_US` — A deal where {1_CivName:textkey} had a Defensive Pact with us has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_GPT_FROM_US` — A deal where we provided Gold every turn to {1_CivName:textkey} has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_GPT_TO_US` — A deal where {1_CivName:textkey} provided Gold every turn to us has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_OPEN_BORDERS_FROM_US` — A deal where we provided Open Borders to {1_CivName:textkey} has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_OPEN_BORDERS_TO_US` — A deal where {1_CivName:textkey} provided us Opened Borders has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_PEACE` — A peace treaty with {1_CivName:textkey} has ended. Either civilization may now declare war on the other.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_RESEARCH_AGREEMENT_FROM_US` — Our Research Agreement with {1_CivName:textkey} has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_RESEARCH_AGREEMENT_TO_US` — A deal where {1_CivName:textkey} had a Research Agreement with us has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_RESOURCE_FROM_US` — A deal where we provided {2_Resource} to {1_CivName:textkey} has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_RESOURCE_TO_US` — A deal where {1_CivName:textkey} provided {2_Resource} to us has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_TRADE_AGREEMENT_FROM_US` — Our Trade Agreement with {1_CivName:textkey} has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DEAL_EXPIRED_TRADE_AGREEMENT_TO_US` — A deal where {1_CivName:textkey} had a Trade Agreement with us has ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DIPLOMACY_DECLARATION` — Public Declaration from {1_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_DIPLOMAT_EJECTED_TT` — {1_SpyRank} {2_SpyName} fled from {3_CityName} to your hideout due to a declaration of war.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_ENHANCE_RELIGION` — You may now add more beliefs to your religion!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_FAITH_GREAT_PERSON_TT` — You have accumulated enough Faith to earn a Great Person of your choice!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_FOUND_GOODY_HUT` — You have discovered Ancient Ruins! Sending a Unit into the Ruins may uncover hidden secrets!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_FOUND_RELIGION` — You may now found a religion!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_LEAGUE_PROJECT_COMPLETE_TT` — The {@1_ProjectName} project has been completed.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_LEAGUE_VOTING_DONE_TT` — The proposed resolutions to the {1_LeagueName} have been decided on.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_LEAGUE_VOTING_SOON_TT` — The {1_LeagueName} will convene in {2_TurnsUntilSession} turns to deliberate on proposed resolutions:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SPY_STEAL_BLOCKING_TT` — Your spy has gathered enough intelligence to steal a technology from an opponent. Choose which technology to steal.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ADD_REFORMATION_BELIEF` — ADD REFORMATION BELIEF  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ALREADY_CREATED_PANTHEON` — Pantheon already founded  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ALREADY_CREATED_RELIGION` — RELIGION ALREADY FOUNDED  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_AUTOMATIC_FAITH_PURCHASE` — Automatic Faith Purchase  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BARB_CAMP_CONVERTS` — Barbarian Encampment joins you  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BARB_NAVAL_UNIT_CONVERTS` — Barbarian Naval Unit joins you  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_GREAT_PEOPLE_ANOTHER` — {1_CivName:textkey} has the most Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_GREAT_PEOPLE_UNMET` — Unmet Player has the most Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_GREAT_PEOPLE_YOU` — Most Great People!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_POLICIES_ANOTHER` — {1_CivName:textkey} has the most Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_POLICIES_UNMET` — Unmet Player has the most Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_POLICIES_YOU` — Most Social Policies!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_WONDERS_ANOTHER` — {1_CivName:textkey} has the most Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_WONDERS_UNMET` — Unmet Player has the most Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_BEST_IN_WONDERS_YOU` — Most World Wonders!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CHOOSE_ARCHAEOLOGY` — CHOOSE ARCHAEOLOGY  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CHOOSE_IDEOLOGY` — CHOOSE IDEOLOGY  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CITY_CAN_SHOOT` — {1_CityName:textkey} can fire upon an enemy!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CITY_CULTURE_ACQUIRED_NEW_PLOT` — Borders of {1_CityName:textkey} have grown  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CITY_GROWTH` — {1_CityName:textkey} has Grown!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CITY_LOST` — {1_CityName:textkey} captured!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CITY_RESOURCE_DEMAND` — {1_CityName:textkey} demands {2_ResourceName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CITY_STATE_UNIT_SPAWN` — New Unit from {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_CITY_WLTKD` — {1_CityName:textkey} loves the king!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_DEFENSIVE_PACT_FROM_US` — Defensive Pact with {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_DEFENSIVE_PACT_TO_US` — Defensive Pact with {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_GPT_FROM_US` — GPT to {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_GPT_TO_US` — GPT from {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_OPEN_BORDERS_FROM_US` — Open Borders to {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_OPEN_BORDERS_TO_US` — Open Borders from {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_PEACE` — Peace Treaty Expired  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_RESEARCH_AGREEMENT_FROM_US` — Research Agreement with {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_RESEARCH_AGREEMENT_TO_US` — Research Agreement with {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_RESOURCE_FROM_US` — {2_Resource} to {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_RESOURCE_TO_US` — {2_Resource} from {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_TRADE_AGREEMENT_FROM_US` — Trade Agreement with {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DEAL_EXPIRED_TRADE_AGREEMENT_TO_US` — Trade Agreement with {1_CivName:textkey} ended  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_DISCOVER_FREE_TECH` — DISCOVER A FREE TECH  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ENHANCED_RELIGION_IN_USE` — Enhanced religion exists  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ENHANCE_RELIGION` — ENHANCE A RELIGION  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ENOUGH_CULTURE_FOR_POLICY` — May adopt Policy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ENOUGH_FAITH_FOR_MISSIONARY` — May Purchase With Faith  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ENOUGH_FAITH_FOR_PANTHEON` — FOUND A PANTHEON  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ENOUGH_GOLD_TO_BUY_PLOT` — May purchase land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ERA_VICTORY_POINTS` — New Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_FOUND_BARB_CAMP` — Barbarian Encampment discovered  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_FOUND_GOODY_HUT` — Ruins discovered  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_FOUND_NATURAL_WONDER` — Natural Wonder discovered  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_FOUND_RELIGION` — FOUND A RELIGION  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_FOUND_RESOURCE` — {1_ResourceName:textkey} discovered  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_GOLDEN_AGE_BEGUN` — {1_CivName:textkey} Golden Age began.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_GOLDEN_AGE_BEGUN_ACTIVE_PLAYER` — A Golden Age dawns!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_GOLDEN_AGE_ENDED` — {1_CivName:textkey} Golden Age ended.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_GOLDEN_AGE_ENDED_ACTIVE_PLAYER` — Your Golden Age ends.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_GREAT_ARTIST_STOLE_PLOT` — {1_CivName:textkey} stole some of your land!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_GREAT_PERSON` — Great Person born  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_GREAT_WORK_SWAP` — Great Work Swap  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_HEATHEN_CONVERTS` — Heathen Converted  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_IDEOLOGY_CHANGE` — Revolution!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_IDEOLOGY_CHOSEN` — Ideology Adopted  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MET_MINOR_CIV` — You have met {1_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_AGGRESSOR` — City-States Grow Worried  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_ALLIES_STATUS` — Now Ally of {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_ALLIES_STATUS_LOST` — No longer Ally of {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_ALLIES_STATUS_PASSED` — {1_CivName:textkey} now Ally of {2_MinorCivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_BARBS_QUEST` — {1_CivName:textkey} under attack!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_BARBS_QUEST_LOST_CHANCE` — {1_CivName:textkey} cancels request  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_BFF_LOST_RESOURCE` — Lost {2_ResourceNames} from {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_BFF_NEW_RESOURCE` — {2_ResourceNames} from {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_FRIENDSHIP_DECAY` — City-State [ICON_INFLUENCE] Influence Change!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_FRIENDS_STATUS` — Now Friends with {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_FRIENDS_STATUS_LOST` — No longer Friends with {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_GAINED_BEST_RELATIONS_BONUS` — Favored status with {1_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_INTRUSION` — Trespassing in {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_LIBERATION` — {1_CivName:textkey} liberated!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_LOST_BEST_RELATIONS_BONUS` — Favored Status with {1_CivName:textkey} lost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_ROUTE_CONNECTION` — Road to {1_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_WARMONGER` — City-States Become Hostile  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_WARMONGER_OTHER` — City-States Unite Against {1_NameKey:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_WARMONGER_REMINDER` — City-States Request Assistance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_WAR_QUEST` — {1_CivName:textkey} attacked by {2_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_WAR_QUEST_COMPLETED` — {1_CivName:textkey} War complete  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_MINOR_WAR_QUEST_LOST_CHANCE` — {1_CivName:textkey} no longer at War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_NEED_NEW_AUTOMATIC_FAITH_SELECTION` — Need New Automatic Faith Selection  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_NEW_RESEARCH` — Choose Research  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_NOT_ENOUGH_FAITH_FOR_PANTHEON` — Not enough faith  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_NO_RELIGIONS_AVAILABLE` — No religions available  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_OVER_RESOURCE_LIMIT` — You Need {1_Resource:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_PANTHEON_BELIEF_IN_USE` — Belief taken  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_PLAYER_LOST_CAPITAL` — {1_CivName:textkey} lost its [ICON_CAPITAL] Capital  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_PLAYER_RECOVERED_CAPITAL` — {1_CivName:textkey} recovered their [ICON_CAPITAL] Capital  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_BULLY_CITY_STATE` — {2_MinorCivName:textkey} wants {1_TargetName:textkey} bullied  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_BULLY_CITY_STATE` — {1_TargetName:textkey} bullied for {2_MinorCivName:textkey}!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_CONNECT_RESOURCE` — {@1_ResourceName} Connected for {@2_CivName}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_CONSTRUCT_WONDER` — {@1_WonderName} Constructed for {@2_CivName}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_CONTEST_CULTURE` — {1_MinorCivName:textkey} is in awe of you!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_CONTEST_FAITH` — {1_MinorCivName:textkey} is in awe of you!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_CONTEST_TECHS` — {1_MinorCivName:textkey} is in awe of you!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_DENOUNCE_MAJOR` — {1_TargetName:textkey} denounced for {2_MinorCivName:textkey}!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_FIND_NATURAL_WONDER` — Natural Wonder discovered for {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_FIND_PLAYER` — {1_TargetName:textkey} Discovered for {2_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_GIVE_GOLD` — Gold support given to {1_MinorCivName:textkey}!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_GREAT_PERSON` — {2_CivName:textkey} Recognizes Your {1_UnitName}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_INVEST` — {1_MinorCivName:textkey} no longer needs investors  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_KILL_CAMP` — Encampment Cleared for {1_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_KILL_CITY_STATE` — {1_TargetName:textkey} Eliminated for {2_CivName:textkey}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_PLEDGE_TO_PROTECT` — Protection pledged to {1_MinorCivName:textkey}!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_SPREAD_RELIGION` — {@1_ReligionName} spread to {@2_MinorCivName}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_COMPLETE_TRADE_ROUTE` — Trade route established for {@1_MinorCivName}!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_CONNECT_RESOURCE` — {@2_CivName} desires {@1_ResourceName}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_CONSTRUCT_WONDER` — {@2_CivName} desires {@1_WonderName}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_CONTEST_CULTURE` — {1_MinorCivName:textkey} longs for culture!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_CONTEST_FAITH` — {1_MinorCivName:textkey} calls for faith!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_CONTEST_TECHS` — {1_MinorCivName:textkey} searches for science!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_DENOUNCE_MAJOR` — {2_MinorCivName:textkey} seeks justice against {1_TargetName:textkey}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_ENDED_CONSTRUCT_WONDER` — Can no longer Construct {@1_WonderName} for {@2_CivName}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_ENDED_CONTEST_CULTURE` — {1_MinorCivName:textkey} looks elsewhere  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_ENDED_CONTEST_FAITH` — {1_MinorCivName:textkey} looks elsewhere  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_ENDED_CONTEST_TECHS` — {1_MinorCivName:textkey} looks elsewhere  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_ENDED_INVEST` — {1_MinorCivName:textkey} no longer needs investors  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_ENDED_KILL_CITY_STATE` — Can no longer eliminate {1_TargetName:textkey} for {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_ENDED_OTHER` — {1_MinorCivName:textkey} cancels quest  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_ENDED_REVOKED` — {1_MinorCivName:textkey} revokes quests  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_FIND_NATURAL_WONDER` — {1_CivName:textkey} seeks a new Natural Wonder  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_FIND_PLAYER` — {2_CivName:textkey} seeks {1_TargetName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_GIVEN_CONDENSED` — New City-State Quests  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_GIVE_GOLD` — {1_MinorCivName:textkey} is bankrupt!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_GREAT_PERSON` — {2_CivName:textkey} Seeks a {1_UnitName}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_INVEST` — {1_MinorCivName:textkey} seeks investors!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_KILL_CAMP` — {1_CivName:textkey} Targets Nearby Encampment  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_KILL_CITY_STATE` — {2_CivName:textkey} wants {1_TargetName:textkey} eliminated.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_PLEDGE_TO_PROTECT` — {1_MinorCivName:textkey} seeks protection!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_SPREAD_RELIGION` — {@2_MinorCivName} wants {@1_ReligionName}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_START_ROUTE` — {1_CivName:textkey} requests a Road  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_QUEST_START_TRADE_ROUTE` — {@1_MinorCivName} desires trade route  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_RELIGION_IN_USE` — Religion taken  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_RELIGION_NAME_IN_USE` — Religion name in use  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_REMOVED_UNIT` — No room for new unit!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_RESEARCH_AGREEMENT` — New Research Agreement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_ROUTE_TO_CANCELLED` — Route to cancelled!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_SOMEONE_LOST_CAPITAL` — Unmet player lost its [ICON_CAPITAL] Capital  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_SOMEONE_RECOVERED_CAPITAL` — Unmet player recovered its [ICON_CAPITAL] Capital  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_SPY_CREATED` — A spy has been recruited!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_SPY_PROMOTED` — {1_SpyName} promoted!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_TRADE_ROUTE_BROKEN` — [ICON_CONNECTED] City connection broken!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_TRADE_ROUTE_ESTABLISHED` — [ICON_CONNECTED] City connection established!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_UNIT_CAN_GET_PROMOTION` — Unit Promotion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_CATEGORY_FIRST_PLACE` — {1_CivName:textkey} 1st Place in Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_CATEGORY_FIRST_PLACE_YOU` — 1st Place in Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_CATEGORY_FOURTH_PLACE` — {1_CivName:textkey} 4th Place in Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_CATEGORY_FOURTH_PLACE_YOU` — 4th Place in Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_CATEGORY_SECOND_PLACE` — {1_CivName:textkey} 2nd Place in Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_CATEGORY_SECOND_PLACE_YOU` — 2nd Place in Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_CATEGORY_THIRD_PLACE` — {1_CivName:textkey} 3rd Place in Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_CATEGORY_THIRD_PLACE_YOU` — 3rd Place in Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_RACE_WON_SOMEBODY` — {1_CivName:textkey} #{2_Rank} in {3_Victory:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_RACE_WON_UNMET` — Unmet Player #{1_Rank} in {2_Victory:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_RACE_WON_YOU` — #{1_Rank} in {2_Victory:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_VICTORY_WINNER` — {1_CivName:textkey} has Won!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_WONDER_STARTED` — {1_CivName} started building {2_BldgName}.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_WONDER_STARTED_UNKNOWN` — Unmet player started building {1_BldgName}.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_YOU_LOST_CAPITAL` — [ICON_CAPITAL] Capital City lost!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NOTIFICATION_SUMMARY_YOU_RECOVERED_CAPITAL` — [ICON_CAPITAL] Capital City recovered!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NO_BUTTON` — No  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_NO_DIPLO_ACTIONS` — No Diplomatic Actions  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_NO_REPLAYS` — NO REPLAYS AVAILABLE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_NUMBER_OF_CITIES_TT_NORMALLY` — Every (non-occupied) City produces 3 [ICON_HAPPINESS_4] Unhappiness (Normally).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OK_BUTTON` — OK  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_OPSCREEN_CANCEL_BUTTON` — Cancel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_CANCEL_BUTTON_TT` — Return to the Main Menu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_CONFIRM` — Are you sure?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_NO_REWARD_POPUPS` — No Reward Popups  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_NO_REWARD_POPUPS_TT` — Disables Reward Popups (Technology, Ancient Ruins, etc.).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_NO_TILE_RECOMMENDATIONS_TT` — Disables on-map Recommendations when Settlers or Workers are selected.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_EMAIL_ADDRESS_TT` — Email address for receiving Pitboss turn notifications.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_HOST_OPTIONS` — Pitboss Host Turn Notification  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_OPTIONS` — Pitboss Turn Notification  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_HOST_TT` — SMTP server for sending turn notifications as the host.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_PASSWORDS_MATCH_TT` — The SMTP password entries match.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_PASSWORDS_NOT_MATCH_TT` — The SMTP password entries don't match.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_PASSWORD_TT` — Password for SMTP server.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_PORT_TT` — Network port used by SMTP server.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_RETYPE_PASSWORD_TT` — Retype Password  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_TLS_TT` — Use TLS encryption for this SMTP server.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_USERNAME_TT` — Username for SMTP server.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURN_NOTIFY_STEAM_INVITE` — Steam Invite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_DNOTES_LABEL` — Designer's Notes:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_NO_YIELD` — No Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PROMOTION_IGNORE_TERRAIN_COST` — Ignores Terrain Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_NO_CAPTURE` — Unable to Capture Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_NO_DEFENSIVE_BONUSES` — No Defensive Bonuses  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_TECHNOLOGY_NAME` — Technology Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PLAYER_OPTION_NO_UNIT_CYCLING` — No Unit Cycling  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAYER_OPTION_NO_UNIT_RECOMMEND` — No Unit Action Recommendations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAY_NOW_SETTINGS` — Play with the current settings:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_PLAY_NOW_TT` — Play with most recent options  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_POLICYSCREEN_CONFIRM_TENET` — Are you sure you want to adopt [COLOR_GREEN]{1_TenetName}[ENDCOLOR]?  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_POPUP_ENTER_MINOR_CIV_LANDS` — Entering [COLOR_HIGHLIGHT_TEXT]{1_CivAdj}[ENDCOLOR] lands is an unfriendly act of bullying! Are you sure?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_MINOR_BULLY_GOLD_AMOUNT` — Take {1_NumGold} [ICON_GOLD] Gold - will lose {2_NumInfluence} [ICON_INFLUENCE] Influence  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`
- `TXT_KEY_POPUP_MINOR_BULLY_UNIT_AMOUNT` — Enslave a {@1_Unit} - will lose {2_NumInfluence} [ICON_INFLUENCE] Influence  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`
- `TXT_KEY_POPUP_MINOR_GIFT_TILE_IMPROVEMENT` — {1_NumGold} [ICON_GOLD] Gold - Improve a Resource  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`
- `TXT_KEY_POPUP_MINOR_GOLD_GIFT` — You may provide {1_CivName:textkey} a gift of Gold.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POPUP_MINOR_GOLD_GIFT_AMOUNT` — {1_NumGold} [ICON_GOLD] Gold - will earn {2_NumFriendship} [ICON_INFLUENCE] Influence  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POPUP_MINOR_GOLD_GIFT_CANT` — With at least {1_NumGold} Gold, you may provide {2_CivName:textkey} with a gift.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POPUP_NO` — No  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_NO_GOLD_CITY_CAPTURE` — You have acquired {@1_CityName}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_NO_PUPPET` — No, Puppet the City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_VOTES_YES_NO` — {1_VtrName} votes {2_YesNo} ({3_Num} Total)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_YES` — Yes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POP_GIVE_UNIT_CONFIRMATION` — Do you want to give {1_CivName} your {2_UnitName}?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_RETURN_CIVILIAN_CONFIRMATION_RETURN` — Return the Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_RETURN_CIVILIAN_CONFIRMATION_TAKE` — Take It  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_REPLAY_DATA_TECHSKNOWN` — Number of known Techs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_NOGRAPHDATA` — No Graph Data  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SLOTTYPE_CLOSED_TT` — Closed slots can not be used by players.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_SOCIALPOLICY_HONOR_HEADING3_TITLE` — Honor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATGENERAL_HEADING3_TITLE` — Great General  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_ECONOMIC_IMPERIALISM_TITLE` — Economic Imperialism  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_GALVANOMAGNETISM_TITLE` — Galvanomagnetism  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_NOBLESSE_OBLIGE_TITLE` — Noblesse Oblige  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_TECHNOCRACY_TITLE` — Technocracy  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_URANOGRAPHY_TITLE` — Uranography  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAM_CONNECTED_NO` — To play internet games, the game needs to be launched with Steam active and with an active internet connection.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_TECH_ASTRONOMY_TITLE` — Astronomy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_ECONOMIC` — Your Economic Advisor recommends researching this technology.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TECH_ECONOMICS_TITLE` — Economics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_HORSEBACK_RIDING_TITLE` — Horseback Riding  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_NANOTECHNOLOGY_TITLE` — Nanotechnology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_POPUP_CLOSE_RESEARCH` — CLOSE RESEARCH  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_TERRAIN_SNOW_HEADING3_TITLE` — Snow  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TRADE_ROUTE_TT_PLOT_MAJOR_MINOR` — {1_CityName} ({2_CivName}) [ICON_TURNS_REMAINING] {3_CityName} (City-State)  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_UNITS_NONCOMBAT_HEADING2_TITLE` — Non-Combat Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_ANOTHERCIVWINS_HEADING3_TITLE` — Another Civilization Wins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VP_DIPLO_TT_KNOWN_NO_CAPITAL` — {1_PlayerName} has not built a Capital city.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_UNKNOWN_NO_CAPITAL` — An unmet player has not built a Capital city.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_YOU_NO_CAPITAL` — You have not built a Capital city.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_WONDER_NOTREDAME_HEADING` — Notre Dame  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_SCENARIO_ECONOMIC_WONDER_HEADING` — ECONOMIC ([ICON_GOLD] Total Gross Income)  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_YES_BUTTON` — Yes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`

## Button labels (101)

- `TXT_KEY_ADVISOR_ATTACKING_CITY_ACTIVATE_BUTTON` — Find Combat Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_ATTACKING_FORTIFIED_UNITS_ACTIVATE_BUTTON` — Find Combat Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_BARBARIAN_CAMP_ACTIVATE_BUTTON` — Find Barbarian Camp  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_BOMBARD_ACTIVATE_BUTTON` — Find City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_STATES_INTRO_ACTIVATE_BUTTON` — Find City-State  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_STATES_QUEST_ACTIVATE_BUTTON` — Find City-State  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_STATES_TRESPASSING_ACTIVATE_BUTTON` — Find Trespasser  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_STATE_FRIEND_ACTIVATE_BUTTON` — Find Friendly City-State  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_UNDER_ATTACK_ACTIVATE_BUTTON` — Find City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COMBAT_INTRO_ACTIVATE_BUTTON` — Find Combat Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COMBAT_NAVAL_UNIT_ACTIVATE_BUTTON` — Find Naval Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_DISCOVERED_NATURAL_WONDER_ACTIVATE_BUTTON` — Find Natural Wonder  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_EMBARKING_UNITS_ACTIVATE_BUTTON` — Find Embarkable Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_ESPIONAGE_CANT_STEAL_ANYMORE_ACTIVATE_BUTTON` — {TXT_KEY_ADVISOR_FIRST_SPY_ACTIVATE_BUTTON}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_ESPIONAGE_TECH_STOLEN_ACTIVATE_BUTTON` — {TXT_KEY_ADVISOR_FIRST_SPY_ACTIVATE_BUTTON}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_FIRST_SPY_ACTIVATE_BUTTON` — Espionage Overview  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_FIRST_TURN_BUILD_CITY_ACTIVATE_BUTTON` — Find Settler  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_FIRST_TURN_UNIT_MOVE_ACTIVATE_BUTTON` — Find Warrior  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GO_TO_GOODY_HUT_ACTIVATE_BUTTON` — Find Ruin  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GREAT_PERSON_ACTIVATE_BUTTON` — Find Great Person  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_HAPPINESS_RESOURCE_ACTIVATE_BUTTON` — Find Resource  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_HOW_TO_ENGAGE_DIPLOMACY_ACTIVATE_BUTTON` — Find City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_LATER_TURNS_BUILD_CITY_ACTIVATE_BUTTON` — Find Settler  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_LATER_TURN_UNIT_MOVE_ACTIVATE_BUTTON` — Find Idle Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_FOREST_ACTIVATE_BUTTON` — Find Forest  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_HILLS_ACTIVATE_BUTTON` — Find Hill  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_JUNGLE_ACTIVATE_BUTTON` — Find Jungle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_MARSH_ACTIVATE_BUTTON` — Find Marsh  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_MOUNTAIN_ACTIVATE_BUTTON` — Find Mountain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_RIVER_ACTIVATE_BUTTON` — Find River  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_RANGED_UNIT_ACTIVATE_BUTTON` — Find Ranged Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_RECOMMEND_COURTHOUSE_ACTIVATE_BUTTON` — Find Occupied City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_RESEARCH_COURTHOUSE_ACTIVATE_BUTTON` — Find Occupied City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SETTLER_INTRO_ACTIVATE_BUTTON` — Find Settler  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SETTLER_PROTECT_ACTIVATE_BUTTON` — Find Settler  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SIEGE_UNIT_ACTIVATE_BUTTON` — Find Siege Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_TUTORIAL_BUILD_CITY_CHEAT_ACTIVATE_BUTTON` — Find City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_UNIT_HEAL_ACTIVATE_BUTTON` — Find Damaged Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_UPGRADING_UNITS_ACTIVATE_BUTTON` — Find Upgradable Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_INTRO_ACTIVATE_BUTTON` — Find Worker  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_NEED_WORK_ACTIVATE_BUTTON` — Find Worker  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_PROTECT_ACTIVATE_BUTTON` — Find Worker  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKER_NAVAL_UNIT_ACTIVATE_BUTTON` — Find Work Boat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_ZONE_OF_CONTROL_ACTIVATE_BUTTON` — Find Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_BEGIN_GAME_BUTTON` — Begin Your Journey  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CITYVIEW_FOCUS_BUTTON_C_TEXT` — Close City Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_BUTTON_O_TEXT` — Open City Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_BUTTON_TT` — Manage City Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_PRODUCE_BUTTON` — PRODUCE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_PURCHASE_BUTTON` — PURCHASE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_RAZE_BUTTON_DISABLED_BECAUSE_CAPITAL_TT` — Cannot raze a city that was once a capital  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_RAZE_BUTTON_TEXT` — Raze City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_RAZE_BUTTON_TT` — Burn, baby, burn!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_UNRAZE_BUTTON_TEXT` — Stop City Razing  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_UNRAZE_BUTTON_TT` — Halt the razing process  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CIVIL_WAR_SCENARIO_BRIEFING_BUTTON` — Briefing  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_SCENARIO_TECH_BUTTON_1` — Allows cavalry to pillage tiles.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_SCENARIO_TECH_BUTTON_2` — Allows infantry to pillage tiles.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CLEAR_BUTTON` — Clear  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CLEAR_BUTTON_TT` — This will reset the proposed Great Work exchange.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_COMBAT_FORITFYBUTTON_ADV_QUEST` — How does "Fortify Until Healed" work?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_FORITFYBUTTON_HEADING3_TITLE` — The "Fortify Until Healed" Button  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DEFAULT_BUTTON` — Default  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DELETE_BUTTON` — Delete  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_DEMAND_BUTTON` — Demand  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DIPLOMACY_BUTTON` — DIPLOMACY  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_DISCUSS_BUTTON` — Discuss  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_TRADE_BUTTON` — Trade  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_EDIT_BUTTON` — Edit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_EO_SPY_BUTTON_DISABLED_SPY_DEAD_TT` — {1_SpyRank} {2_SpyName} is dead. Leave them in peace.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EXIT_BUTTON` — EXIT  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_FORWARD_BUTTON` — Forward  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_GOODBYE_BUTTON` — Goodbye  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_INVALID_RESOLUTION_BUTTON_TT` — [COLOR_GREY]You may not make this proposal at this time.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_INVALID_RESOLUTION_CHOICE_BUTTON_TT` — [COLOR_GREY]This choice for the proposal is already under consideration, and may not be proposed again.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_PROPOSE_BUTTON` — Click to Propose  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_PROPOSE_BUTTON_TT` — Click here to propose a resolution.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_MENU_LOAD_GAME_BUTTON` — LOAD GAME  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_OPTIONS_BUTTON` — OPTIONS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_QUICK_SAVE_BUTTON` — QUICK SAVE GAME  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_RESTART_GAME_BUTTON` — RESTART GAME  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_SAVE_BUTTON` — SAVE GAME  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_SAVE_MAP_BUTTON` — SAVE MAP  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MOVE_SPY_HIDEOUT_BUTTON` — Move to Hideout  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_MP_SWAP_BUTTON_TT` — Swap to this player slot.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_OPSCREEN_APPLY_BUTTON` — Apply  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_APPLY_BUTTON_TT` — Save Options  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_DEFAULTS_BUTTON` — Defaults  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_DEFAULTS_BUTTON_TT` — Reset all settings to default values.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SAVE_BUTTON` — Accept  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SAVE_BUTTON_TT` — Save Options and return to the Menu.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_POLICYSCREEN_TO_IDEOLOGY_BUTTON` — To Ideology[ICON_ARROW_RIGHT]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_POP_ADOPT_BUTTON` — Adopt  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPORT_BUTTON` — Report  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_SCRAMBLE_AFRICA_BRIEFING_BUTTON` — Briefing  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SEARCH_BUTTON` — Search  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_START_TUTORIAL_BUTTON` — Start Selected Tutorial  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_BRIEFING_BUTTON` — Briefing  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_VSCREEN_BUTTON` — League of Empires  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_SWAP_BUTTON` — Swap  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TECH_AWARD_BUTTON` — Continue  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`

## Main menu / FrontEnd (52)

- `TXT_KEY_CREDITS` — CREDITS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_CREDITS_1_0_0_0` — Credits  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_0_0_0` — Firaxis Games  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_1_0_0` — DESIGN TEAM  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_1_1_0` — Original Creator of Civilization  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_1_1_1` — Sid Meier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_1_2_0` — Designed By  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_1_2_1` — Jon Shafer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_1_3_0` — Additional Design  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_1_3_1` — Ed Beach  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_1_3_2` — Scott Lewis  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_0_0` — PRODUCTION TEAM  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_1_0` — Producer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_1_1` — Dennis Shirk  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_2_0` — Associate Producer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_2_1` — Lisa Miller  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_3_0` — Additional Production  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_3_1` — Clint McCaul  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_3_2` — Michelle Menard  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_4_0` — Writers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_4_1` — Michelle Menard  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_2_2_4_2` — Paul Murphy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Credits.xml`
- `TXT_KEY_CREDITS_TT` — Brought to you by...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_MENU_DLC` — DLC  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_MENU_MODS` — MODS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_MENU_REQUIRED_DLC` — The following DLC is required by this saved game:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_MENU_REQUIRED_MODS` — The following Mods are required by this saved game:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_REPLAY_MENU_INVALID_REPLAY_FILE` — Invalid or outdated replay file.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_REPLAY_MENU_PLEASE_SELECT_REPLAY` — Please select a replay file.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_REPLAY_MENU_SELECT_REPLAY` — Select Replay  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_REPLAY_MENU_TITLE` — SELECT REPLAY  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAIN_MENU` — Open Main Menu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MENU_CAPS` — MENU  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MENU_EXIT_TO_MAIN` — EXIT TO MAIN MENU  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_EXIT_TO_WINDOWS` — EXIT TO WINDOWS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_EXIT_WARN` — This will close Civilization V. Are you sure you want to do this?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_RETURN_EXIT_WARN` — This will close Civilization V without saving your game. Are you sure you want to do this?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_RETURN_MM_WARN` — This will return you to the Main Menu without saving your game. Are you sure you want to do this?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_RETURN_TO_GAME` — RETURN TO GAME  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_SAVE` — Save  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_SAVE_MAP_LOWER` — Save Map  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MENU_TOOLTIP` — Brings up the game menu where you may save the game, exit to the main menu, etc.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MODDING_EULA_TITLE` — EULA  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MOVEMENT_ILLEGAL_ADV_QUEST` — What moves are illegal?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_ILLEGAL_HEADING2_TITLE` — Illegal Moves  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_LEGAL_ADV_QUEST` — What makes moves legal and illegal?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_LEGAL_HEADING3_TITLE` — Legal and Illegal Moves  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MP_MAIN_MENU` — Main Menu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MULTIPLAYER_SELECT_MULTIPLAYER_TYPE` — Multiplayer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_SELECT_SAVED_GAME` — Select Saved Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_OTHER_MENU_VIEW_REPLAYS` — VIEW REPLAYS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_OTHER_MENU_VIEW_REPLAYS_TT` — View replays of previous games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`

## Game setup (534)

- `TXT_KEY_1066_SCENARIO_CIV_DENMARK_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_CIV_ENGLAND_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_LEADER_GODWINSON_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_LEADER_GODWINSON_SUBTITLE` — King of England  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_LEADER_HARDRADA_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_LEADER_HARDRADA_SUBTITLE` — King of Norway  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_LEADER_SWEYN_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_LEADER_SWEYN_SUBTITLE` — King of Denmark  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_LEADER_WILLIAM_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_LEADER_WILLIAM_SUBTITLE` — Duke of Normandy  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_1066_SCENARIO_TITLE` — 1066: Year of Viking Destiny  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/CIV5GameTextInfos_1066_Scenario.xml`
- `TXT_KEY_AD_SETUP_ADD_AI_PLAYER` — Add AI Player  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_ADD_AI_PLAYER_TT` — Add an AI Player.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_ADD_DEFAULT_TT` — Reset Options to Default  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_ADVANCED_OPTIONS` — ADVANCED SETUP  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_CITY_STATES` — City-States: {1_number}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_CIVILIZATION` — Civilizations: {1_count}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_DEFAULT` — Reset  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_GAME_ERA` — Game Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_GAME_OPTIONS` — Game Options  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_GAME_SPEED` — Game Pace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_GAME_TURN_MODE` — Turn Mode  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_HANDICAP` — Difficulty Level  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_MAP` — Map  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_MAP_SIZE` — Map Size  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_MAP_TYPE` — Map Type  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_MAX_TURNS` — Max Turns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_MAX_TURNS_1` — Max Turns: {1_NumTurns}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_MAX_TURNS_TT` — Game will end when max turns is reached.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_NUCLEAR_FIRST_STRIKE` — AI Nuclear First Strike  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_NUCLEAR_FIRST_STRIKE_TT` — Allows the AI to use nuclear weapons before the human player has.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_PLAYER_COUNT` — Players: {1_PlayerCount}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_RAGING_BARBARIANS` — Raging Barbarians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_RAGING_BARBARIANS_TT` — Toggles whether the game has Raging Barbarians.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_REMOVE_AI_PLAYER` — Remove AI  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_REMOVE_AI_PLAYER_TT` — Remove this AI Player.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_SETUP_START_ERA` — Starting Era: {@1_Era}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_CIVIL_WAR_SCENARIO_CIV_ENGLAND_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_CIV_UNITEDSTATES_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_HEADING_2` — Secession  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_HEADING_3` — Fort Sumter  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_HEADING_4` — Limited Resources  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_HEADING_5` — Invasion of the North  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_HEADING_6` — Surrender  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_HEADING_7` — Capture  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_HEADING_8` — Judgement of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_ELIZABETH_SUBTITLE` — Provisional President of the Confederacy  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_GEORGE_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_GEORGE_HEADING_2` — Election  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_GEORGE_HEADING_3` — Fort Sumter  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_GEORGE_HEADING_4` — Emancipation Proclamation  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_GEORGE_HEADING_5` — Gettysburg Address  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_GEORGE_HEADING_6` — Judgement of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_LEADERS_GEORGE_SUBTITLE` — President of the United States of America  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_BALLOON_RECONNAISSANCE_TITLE` — Balloon Reconnaissance  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_CAVALRY_RAIDS_TITLE` — Cavalry Raids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_ENGINEERING_TITLE` — Engineering  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_ENTRENCHMENT_TITLE` — Entrenchment  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_FIELD_HOSPITALS_TITLE` — Field Hospitals  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_INDUSTRIALIZATION_TITLE` — Industrialization  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_IRONCLADS_TITLE` — Ironclads  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_MILITARY_RAILROADS_TITLE` — Military Railroads  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_MILITARY_SCIENCE_TITLE` — Military Science  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_REPEATING_RIFLES_TITLE` — Repeating Rifles  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_RIFLED_ARTILLERY_TITLE` — Rifled Artillery  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TECH_SCORCHED_EARTH_TITLE` — Scorched Earth  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_CivilWarScenario.XML`
- `TXT_KEY_CIVIL_WAR_SCENARIO_TITLE` — American Civil War  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_CivilWarScenario.XML`
- `TXT_KEY_COMBAT_PLOT_MOD_VS_TYPE` — [ICON_BULLET]{1_Resource}% vs. {2_Type}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_DELETE_MOD_TXT` — This will permanently delete this Mod. Are you sure you want to do this?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_EGI_TRADE_ROUTE_MOD_INFO` — {1_Num}% gold modifier  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_EO_POTENTIAL_BUILDING_MOD_ENTRY` — {1_BuildingName}: {2_Num}%  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_POTENTIAL_BUILDING_MOD_TITLE` — Change from buildings and wonders:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_POTENTIAL_POLICY_MOD_ENTRY` — {1_SocialPolicyName}: {2_Num}%  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_POTENTIAL_POLICY_MOD_TITLE` — Change from social policies:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_POTENTIAL_WONDER_MOD_ENTRY` — {1_WonderName}: {2_Num}%  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_POTENTIAL_WONDER_MOD_TITLE` — Change from wonders in other cities:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EUPANEL_ATTACK_MOD_BONUS` — Attack Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_FOR_SCENARIO_BARBARIAN_TITLE` — {@1: gender feminine?Queen; other?King;} {1_PlayerName:textkey} of{@2: plural 1? the ; other? ;}{2_CivName:textkey}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_CIV_BYZANTIUM_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_CIV_FRANCE_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_CIV_GERMANY_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_CIV_PERSIA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_CIV_ROME_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_CIV_SONGHAI_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_ALARIC_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_ALARIC_SUBTITLE` — King of the Visigoths  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_BAHRAM_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_BAHRAM_SUBTITLE` — King of the Sassanids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_CHLODIO_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_CHLODIO_SUBTITLE` — King of the Salian Franks  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_GENSERIC_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_LEADER_GENSERIC_SUBTITLE` — King of the Vandals  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_ROMAN_TITLE` — {@1: gender feminine?Empress; other?Emperor;} {1_PlayerName:textkey} of{@2: plural 1? the ; other? ;}{2_CivName:textkey}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_SASSANID_TITLE` — {@1: gender feminine?Queen; other?King;} {1_PlayerName:textkey} of{@2: plural 1? the ; other? ;}{2_CivName:textkey}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_FOR_SCENARIO_TITLE` — Fall of Rome  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_GAME_ADVANCED_SETUP` — Advanced Setup  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_KOREA_SCENARIO_CIV5_MONGOLIA_KESHIK_HEADING` — Manchu Banner Cavalry  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_KoreanScenario.xml`
- `TXT_KEY_KOREA_SCENARIO_CIV_MANCHURIA_HEADING_1` — History  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_KoreanScenario.xml`
- `TXT_KEY_KOREA_SCENARIO_DIPLO_MY_SCORE_FUTURE_TECH` — {1_Num} from Combat Kills  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_KoreanScenario.xml`
- `TXT_KEY_KOREA_SCENARIO_DIPLO_MY_SCORE_TECH` — {1_Num} from Seoul and Beijing  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_KoreanScenario.xml`
- `TXT_KEY_KOREA_SCENARIO_LEADER_NURHACI_HEADING_1` — History  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_KoreanScenario.xml`
- `TXT_KEY_KOREA_SCENARIO_LEADER_NURHACI_SUBTITLE` — Khan of the Later Jin Dynasty  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_KoreanScenario.xml`
- `TXT_KEY_KOREA_SCENARIO_MAP_TITLE` — East Asia  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_KoreanScenario.xml`
- `TXT_KEY_KOREA_SCENARIO_TITLE` — The Samurai Invasion of Korea  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_KoreanScenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_CIV_ARABIA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_CIV_OTTOMAN_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_CIV_SONGHAI_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_DIPLO_VOTE` — HRE VOTE  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_DIPLO_VOTE_TT` — You must vote to elect the next Holy Roman Emperor!!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_LEADER_ALMANSUR_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_LEADER_ALMANSUR_SUBTITLE` — Emir of the Almohad Dynasty  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_LEADER_FRANCIS_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_LEADER_FRANCIS_SUBTITLE` — King of France  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_LEADER_SALADIN_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_LEADER_SALADIN_SUBTITLE` — First Sultan of Egypt and Syria  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_SPECIFIC_DIPLO_STRING_1` — You follow a different religion.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_SPECIFIC_DIPLO_STRING_2` — You conquered the Holy City for their religion!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_SPECIFIC_DIPLO_STRING_3` — You liberated the Holy City for their religion!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_TITLE` — Into the Renaissance  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_VP_DIPLO_PROJECT_BUILT_BY` — Winning election does not end scenario.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MEDIEVAL_SCENARIO_VP_DIPLO_VOTES_NEEDED` — Vatican City receives 1 extra vote  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_MODDING_ADD_COMMENT` — Additional Comments:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ALREADY_INSTALLED` — ALREADY INSTALLED  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_AUTOUPDATEMODS` — Auto-update mods  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_BLOCKS` — Blocks {1_ModName}  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_BLOCKS_ALL_OTHER_DLC` — All other DLC  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_BROWSER` — BROWSE MODS  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_BROWSER_TITLE` — Mods  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_BROWSER_TT` — Browse installed/online mods.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORIES_ALL` — All  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORIES_HEADER` — CATEGORIES  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_1` — Total Conversion  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_10` — Other  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_11` — Civilizations  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_12` — Graphics  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_13` — Terrain  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_14` — Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_15` — Cities  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_16` — Resources  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_17` — Improvements  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_18` — Leaders  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_2` — Historical  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_20` — Terrain  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_21` — Improvements  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_22` — Resources  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_23` — Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_24` — Ancient Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_25` — Medieval Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_26` — Renaissance Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_27` — Industrial Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_28` — Modern Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_29` — Sci-Fi Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_3` — Sci-Fi  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_30` — Fantasy Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_31` — Other Units  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_32` — Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_33` — Ancient Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_34` — Medieval Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_35` — Renaissance Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_36` — Industrial Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_37` — Modern Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_38` — Sci-Fi Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_39` — Fantasy Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_4` — Fantasy  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_40` — Other Scenarios  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_41` — Maps  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_42` — Historic Maps  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_43` — Fictional Maps  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_44` — Multiplayer Maps  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_45` — Map Scripts  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_46` — Historic Maps  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_47` — Fictional Maps  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_48` — Multiplayer Maps  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_49` — Historical  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_5` — Game Rules  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_50` — Fictional  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_51` — Historical  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_52` — Fictional  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_53` — City Builds  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_54` — Buildings  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_55` — Wonders  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_56` — Projects  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_57` — Other  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_6` — Leaderheads  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_7` — User Interface  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_8` — Skins  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CATEGORY_9` — Widgets  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_COPYRIGHT` — Copyright(c) 2010  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CUSTOMGAME` — CUSTOM GAME  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_CUSTOMGAME_TT` — Create a custom game using mods.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DATABASE_UNAVAILABLE` — The mod database is temporarily down.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DELETEMOD` — Delete  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DEPENDENCIES_HEADER` — Dependencies/References/Blocks  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DEPENDSON` — Depends on {1_ModName}  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DESCRIPTION` — Description  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DISABLEMOD` — Disable  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADING` — DOWNLOADING  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADMOD` — Download  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADS` — Downloads  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_0` — Queued  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_1` — Connecting  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_2` — Transferring  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_3` — Suspended  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_4` — Error  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_5` — Warning  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_6` — Transferred  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_7` — Complete  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_DOWNLOADSTATUS_8` — Canceled  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ENABLEINSTRUCTIONS` — To enable a mod, click on the checkbox icon to the right of an entry.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ENABLEMOD` — Enable  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_ALREADY_RATED` — You have already rated this mod.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_CONNECTION` — A connection error has occurred.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_CONNECTION_TIMEOUT` — The connection has timed out.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_GENERIC` — An error has occurred.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_HTTP_FORBIDDEN` — HTTP 403 error - Forbidden.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_HTTP_REQUEST_REJECTED` — HTTP 4XX error - Request rejected.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_HTTP_SERVER_ERROR` — HTTP 5xx error - Server error.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_HTTP_UNAUTHORIZED` — HTTP 401 error - Unauthorized.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_INVALIDURL` — INVALID URL  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_SAVE_INCOMPATIBLE_MODS` — [COLOR_RED]Currently enabled mods are not compatible with this saved game.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_SAVE_MISSING_DLC` — [COLOR_RED]Required DLC is not available.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_SAVE_MISSING_MODS` — [COLOR_RED]Not all required mods are installed.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ERROR_SERVICE_DISABLED` — Services have been disabled.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FILESIZE_B` — b  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FILESIZE_GB` — gb  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FILESIZE_KB` — kb  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FILESIZE_MB` — mb  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FILTER_LATEST_VERSION` — Show latest version only  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FIRSTPAGE` — First page  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FLAG_MODERATION` — Report  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FLAG_MODERATION_TOOLTIP` — Report offensive content, or content which violates the Terms of Service.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FLAG_REASON_1` — Infringes on Copyright or Trademark  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FLAG_REASON_2` — Malicious (contains a virus or trojan)  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FLAG_REASON_3` — Offensive Content  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_FLAG_REASON_4` — Other  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_GAMEVERSION` — Game versions between {1_LowVersion} and {2_HighVersion}  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_HEADING_DATESTARTED` — Date Started  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_HEADING_NAME` — Name  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_HEADING_PROGRESS` — Progress  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_HEADING_STATE` — State  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_HOVERFORDETAILS` — {1_DownloadStatus} (Mouseover for Details)  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALLED` — Installed  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALLER_COPYING` — Copying Files...  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALLER_ERROR` — There was an error installing mods.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALLER_EXTRACTING` — Extracting Files...  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALLER_FINISHED` — Finished!  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALLER_INSTALLING` — Installing Mods...  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALLER_VALIDATING` — Validating Mods...  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALLER_VERIFYING` — Verifying Files...  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALL_MODS` — Install Mods  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALL_MODS_TT` — Mods are available for install.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_INSTALL_PROGRESS` — {1_ProcessedFiles}/{2_TotalFiles}  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELAFFECTSSAVEDGAMES` — Affects Saved Games?  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELAUTHOR` — Author(s):  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELCATEGORIES` — Categories:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELDOWNLOADS` — Downloads:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELRATING` — Rating:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELSIZE` — Size:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELSPECIALTHANKS` — Special Thanks:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELSTATUS` — Status:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELSUPPORTSMULTIPLAYER` — Multiplayer?  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELSUPPORTSSINGLEPLAYER` — Single Player?  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELTAGS` — Tag(s):  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELUPDATED` — Last Updated:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELUPLOADEDBY` — Uploaded By:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LABELVERSION` — Version:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LASTPAGE` — Last page  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LIKE_IT` — Like it  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LIKE_IT_TOOLTIP` — Give a positive rating.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_LOADGAME` — LOAD GAME  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MAINMENU` — MAIN MENU  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MAPS` — SET UP GAME  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MAPS_TT` — Play a custom map.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MODSTATUS` — Alpha|Beta|Pre-Release|Demo  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MOD_BAD_GAMEVERSION` — [COLOR_RED]This version of the game is not compatible with this mod.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MOD_BLOCKED_BY_OTHER_MOD` — [COLOR_RED]Mod is blocked by another mod.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MOD_EXCLUSIVE` — This is an exclusive mod.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MOD_HAS_EXCLUSIVITY_CONFLICTS` — [COLOR_RED]Mod is blocked by exclusivity.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MOD_MISSING_DEPENDENCIES` — [COLOR_RED]Mod is missing required dependencies.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MOD_PARTIALLY_EXCLUSIVE` — This is a partially exclusive mod.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MOD_VERSION_ALREADY_ENABLED` — [COLOR_RED]Another version of this mod is already enabled.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MULTIPLAYER` — MULTIPLAYER  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_MULTIPLAYER_TT` — Play a modded multiplayer game.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_NEXT` — NEXT  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_NEXTPAGE` — Next page  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_ONLINE` — Online  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_OPTIONS` — Options...  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_PAUSEDOWNLOAD` — Pause  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_PREVPAGE` — Previous page  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_PRIVACYPOLICY` — Privacy Policy  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_PROGRESSNA` — n/a  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_RATING` — {1_Rating}  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_REFERENCES` — References {1_ModName}  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_REPORT` — Report Violation  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_REPORT_REASON` — Please select reason for report:  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_REPORT_SUBMITED` — Thank you for submitting your report.  A 2K representative will address this issue shortly.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_REPORT_TITLE` — Violation Report Form  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_RESULTS_EMPTY` — No mods found.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_RESUMEDOWNLOAD` — Resume  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SAVEDGAMES_TT` — Play a previously saved game.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SCENARIOS` — SCENARIOS  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SCENARIOS_TT` — Play a scenario.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SCENARIO_TITLE` — MODDING SCENARIO SETUP  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SCREENSHOT` — SCREENSHOT VIEWER  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SEARCH_TOOLTIP` — Search for a mod.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SETUP_TITLE` — MODDING GAME SETUP  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SHOWDLCMODS` — Show DLC mods  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SHOW_SCREENSHOT` — Show Screenshot Viewer  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SINGLE_PLAYER` — SINGLE PLAYER  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SINGLE_PLAYER_TT` — Play a modded single player game.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SORT_DOWNLOADS` — Downloads  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SORT_ENABLED` — Enabled  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SORT_NEWEST` — Newest  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SORT_RATING` — Rating  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SORT_RECENTLY_INSTALLED` — Recently Installed  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SORT_TITLE` — Title  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_SUBMIT` — Submitting...  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_TITLE` — Mod Title 1  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_UNSUBSCRIBE_MOD` — Unsubscribe  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_UPDATEMOD` — Update  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_UPDATE_ALL_MODS` — Update All Mods  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_UPDATE_ALL_MODS_TT` — Update all installed mods to the latest online version.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_UPDATE_MOD` — Update Mod  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_UPDATE_MOD_LATEST_TT` — Update mod to latest version.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_UPDATE_MOD_TT` — Update mod to version {1_Version}.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_WORKSHOP` — GET MODS  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_WORKSHOP_TT` — Click to open the Steam overlay and browse available mods.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_YOU_LIKE_IT` — You like it  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MODDING_YOU_LIKE_IT_TOOLTIP` — You and {1} {1: plural 1?other likes; other?others like;} it.  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_MOD_INTERNET_LOBBY` — MOD INTERNET GAMES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MOD_LAN_LOBBY` — MOD LOCAL NETWORK GAMES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MOD_MP_GAME_SETUP_HEADER` — SETUP MOD MULTIPLAYER GAME  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MOD_VERSION_AVAILABLE` — Version {1_VersionNumber} is available.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_MONGOL_SCENARIO_CIV5_GREECE_HEADING_1` — History  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MONGOL_SCENARIO_CIV5_SIAM_HEADING_1` — History  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MONGOL_SCENARIO_CIVILOPEDIA_LEADERS_ALEXANDER_LIVED` — 1224 - 1282 AD  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MONGOL_SCENARIO_CIVILOPEDIA_LEADERS_ALEXANDER_NAME` — Michael VIII  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MONGOL_SCENARIO_CIVILOPEDIA_LEADERS_ALEXANDER_SUBTITLE` — Leader of the Byzantine Empire  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MONGOL_SCENARIO_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_LIVED` — 1168 - 1208 AD  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MONGOL_SCENARIO_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_NAME` — Zhangzong  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MONGOL_SCENARIO_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_SUBTITLE` — Leader of the Jin Dynasty  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MONGOL_SCENARIO_TITLE` — Rise of the Mongols  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_MongolScenario.xml`
- `TXT_KEY_MULTIPLAYER_GAME_SETUP_HEADER` — SETUP MULTIPLAYER GAME  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_NEWWORLDDLX_SCENARIO_TITLE` — Conquest of the New World Deluxe  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_AUTO_FAITH_PURCHASE_DISABLED` — [COLOR_NEGATIVE_TEXT]Disabled for short scenario.[ENDCOLOR]  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_DAWN_INCA_TITLE` — Inca  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_DAWN_SPAIN_TITLE` — Spain  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_FACTOID_HEADING` — Incan Factoids  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_HEADING_2` — Geography and Climate  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_HEADING_3` — Early History: The Kingdom of Cusco  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_HEADING_4` — Continued Expansion  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_HEADING_5` — The White Man Cometh  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_HEADING_6` — The End of an Empire  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_SLINGER_HEADING` — Slinger  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_INCA_TITLE` — Inca  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_FACTOID_HEADING` — Isabella Factoid  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_HEADING_2` — Early Years  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_HEADING_3` — Henry fails at matchmaking  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_HEADING_4` — Ferdinand and the fight for the Throne  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_HEADING_5` — 1492  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_HEADING_6` — No One Expects the Inquisition  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_HEADING_7` — The Later Years  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_HEADING_8` — Legacy in History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_SUBTITLE` — Leader of Spain  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_TITLES_1` — Queen of Castile and Leon  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_ISABELLA_TITLES_2` — Queen Consort of Aragon, Majorca, Naples, and Valencia  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_FACTOID_HEADING` — Factoids  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_10` — The Maya Calendar  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_11` — Colonial Incursion and Decline  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_12` — Contemporary Maya  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_2` — Climate and Terrain  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_3` — Periods in Maya History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_4` — Great Cities of the Maya  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_5` — The Collapse  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_6` — Maya Class Structure  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_7` — Agriculture and Hunting  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_8` — Honoring the Gods  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_HEADING_9` — Maya Culture  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_MAYA_TITLE` — Maya  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_FACTOID_HEADING` — Factoids  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_10` — Dominance of Trade  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_11` — Struggles for Naval Dominance  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_12` — Establishment of the Kingdom  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_13` — The World Wars  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_14` — Modern Netherlands  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_15` — Cultural Icons  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_2` — Geography and Climate  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_3` — Pre-History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_4` — Roman Occupation  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_5` — Frisians and Franks  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_6` — Shifting Empires  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_7` — Transitions of Power  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_8` — Protestant Reformation  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_HEADING_9` — Uprising against Spain  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_NETHERLANDS_TITLE` — The Netherlands  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_PACHACUTI_FACTOID_HEADING` — Pachacuti Factoid  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_PACHACUTI_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_PACHACUTI_HEADING_2` — Ascension to the Throne  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_PACHACUTI_HEADING_3` — Creation of an Empire  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_PACHACUTI_HEADING_4` — Judgement of History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_PACHACUTI_SUBTITLE` — Leader of Inca  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_PACHACUTI_TITLES_1` — Sapa Inca  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Inca_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_POLICY_CITIZENSHIP_HEADING` — Citizenship  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_CONQUISTADOR_HEADING` — Conquistador  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_FACTOID_HEADING` — Spanish Factoids  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_2` — Geography and Climate  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_3` — Early History: From Cro-Magnons to Celts  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_4` — Enter the Romans  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_5` — The Arrival of the Moors  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_6` — The Reconquista, Unification, and Inquistition, Oh My  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_7` — Imperial Spain, Rulers of the New World  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_8` — Troubles and Warfare, or, Spain can't get a break  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_HEADING_9` — The Present and the Future  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_TERCIO_HEADING` — Tercio  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIV5_SPAIN_TITLE` — Spain  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/Civ5Civilopedia_Spain_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIVILOPEDIA_LEADERS_MARIA_I_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_CIVILOPEDIA_LEADERS_MARIA_I_LIVED` — 1507- 1578 AD  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_CIVILOPEDIA_LEADERS_MARIA_I_NAME` — Catherine  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Leaders_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIVILOPEDIA_LEADERS_MARIA_I_SUBTITLE` — Queen of Portugal  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_CIVILOPEDIA_LEADERS_NAPOLEON_HEADING_1` — History  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_CIVILOPEDIA_LEADERS_NAPOLEON_LIVED` — 1494 - 1547 AD  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_CIVILOPEDIA_LEADERS_NAPOLEON_NAME` — Francis I  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leaders_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Leaders_NewWorldDeluxeScenario.xml`
- `TXT_KEY_NEWWORLD_SCENARIO_CIVILOPEDIA_LEADERS_NAPOLEON_SUBTITLE` — King of France  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_DIPLO_MY_SCORE_FUTURE_TECH` — {1_Num} from Treasures  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_DIPLO_MY_SCORE_SCENARIO1` — {1_Num} for Discovering China  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_DIPLO_MY_SCORE_SCENARIO2` — {1_Num} for Faith Earned  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_DIPLO_MY_SCORE_SCENARIO3` — {1_Num} for Gold Earned  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_DIPLO_MY_SCORE_WONDERS` — {1_Num} from Wonders/China  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_TITLE` — Conquest of the New World  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_NEWWORLD_SCENARIO_UNITS_TREASURE_HEADING` — Treasure  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Units_DLC_02.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Units_NewWorldDeluxeScenario.xml`
- `TXT_KEY_PEDIA_COMBATMOD_LABEL` — Combat Modifier:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CEREMONY_TITLE` — Kahuna {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_AHOEITU_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_AHOEITU_LIVED` — 10th Century AD  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_AHOEITU_NAME` — 'Aho'eitu  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_AHOEITU_SUBTITLE` — Tu'i Tonga  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_GANDHI_NAME` — Malietoa Savea  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leaders_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_HIAWATHA_NAME` — Pomare I  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leaders_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_HOTUMATUA_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_HOTUMATUA_LIVED` — c. 300 - 800 AD  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_HOTUMATUA_NAME` — Hotu Matua  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_HOTUMATUA_SUBTITLE` — Explorer from Hiva  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_KAMEHAMEHA_NAME` — Hotu Matua  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leaders_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_MALIETOASAVEA_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_MALIETOASAVEA_LIVED` — Unknown  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_MALIETOASAVEA_NAME` — Malietoa Savea  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_MALIETOASAVEA_SUBTITLE` — King of Samoa  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_MONTEZUMA_NAME` — 'Aho'eitu  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leaders_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_POMARE_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_POMARE_LIVED` — 1742 - 1803 AD  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_POMARE_NAME` — Pomare I  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIVILOPEDIA_LEADERS_POMARE_SUBTITLE` — King of Tahiti  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIV_HIVA_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIV_SAMOA_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIV_TAHITI_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_CIV_TONGA_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_THE_ARTS_TITLE` — Tiki-{1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_POLYNESIAN_SCENARIO_TITLE` — Paradise Found  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/CIV5GameTextInfos_PolynesianScenario.xml`
- `TXT_KEY_SETUP_GAME_TT` — Modify the Game Settings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_CIV_ENGLAND_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_CIV_FRANCE_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_CIV_GERMANY_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_CIV_RUSSIA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_CIV_SWEDEN_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_BISMARCK_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_BISMARCK_SUBTITLE` — Leader of Eruch  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_CATHERINE_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_CATHERINE_SUBTITLE` — Leader of Orlin  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_ELIZABETH_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_ELIZABETH_SUBTITLE` — Leader of Pulias  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_GUSTAVUS_ADOLPHUS_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_GUSTAVUS_ADOLPHUS_SUBTITLE` — Leader of Vedria  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_NAPOLEON_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_LEADER_NAPOLEON_SUBTITLE` — Leader of Dalmace  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_PEDIA_PROMOTION_ANTI_AIR` — Bonus vs fighters and airships (150)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_PEDIA_PROMOTION_ANTI_TANK` — Bonus vs landships (100)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_SPECIFIC_DIPLO_STRING_1` — You have 2 Titles, and pose a threat to them in the League.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_SPECIFIC_DIPLO_STRING_2` — You have more than 2 Titles, and nearly control the League!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_SPECIFIC_DIPLO_STRING_3` — You are competing over the same Titles.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_AIRSHIPS_TITLE` — Airships  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_ANALOG_COMPUTATION_TITLE` — Analog Computation  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_ANALYTICAL_ENGINE_TITLE` — Analytical Engine  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_AUTOMATA_TITLE` — Automata  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_CIVIL_DEFENSE_TITLE` — Civil Defense  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_ERUPTIVES_TITLE` — Eruptives  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_EXPEDITIONARY_SCIENCE_TITLE` — Expedition  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_GOSPEL_OF_WEALTH_TITLE` — Gospel of Wealth  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_INFERNAL_COMBUSTION_TITLE` — Infernal Combustion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_LANDSHIPS_TITLE` — Landships  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_LAND_LEVIATHAN_TITLE` — Land Leviathan  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_PERPETUAL_MOTION_TITLE` — Perpetual Motion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_PROPULSION_TITLE` — Propulsion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_SKY_FORTRESS_TITLE` — Sky Fortress  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_SUBTERRANEAN_EXPLORATION_TITLE` — Subterranean Exploration  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_THE_GRAND_IDEA_TITLE` — The Grand Idea  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TECH_VERTICAL_INTEGRATION_TITLE` — Vertical Integration  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Scenarios_Expansion.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TITLE` — Empires of the Smoky Skies  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TRAIT_INTELLIGENCE_NETWORK` — Receieve 2 extra Spies.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_TRAIT_INTELLIGENCE_NETWORK_SHORT` — Intelligence Network  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_VICTORY_CATEGORY_COMMERCE_TITLE` — Master of Wealth  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_VICTORY_CATEGORY_CULTURE_TITLE` — Lord of Refinement  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_VICTORY_CATEGORY_CULTURE_TT` — Adopt more social policies than your rivals.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_VICTORY_CATEGORY_INDUSTRY_TITLE` — Captain of Industry  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_VICTORY_CATEGORY_LABOR_TITLE` — Grand Philanthropist  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_VICTORY_CATEGORY_MILITARY_TITLE` — Defender of Progress  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_STEAMPUNK_SCENARIO_VICTORY_CATEGORY_UNLOCK_TT` — The Title of [COLOR_POSITIVE_TEXT]{@1_TitleName}[ENDCOLOR] becomes available for all players.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Steampunk_Scenario.xml`
- `TXT_KEY_UNHAPPINESS_MOD_CAPITAL` — Because of your Policies, [ICON_CITIZEN] Citizens in your Capital produce {1_Num}% the usual amount.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_UNHAPPINESS_MOD_MAP` — Because of the game's current map size, they produce {1_Num}% less than usual.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_UNHAPPINESS_MOD_PLAYER` — Because of bonuses your empire has earned, they produce {1_Num}% the usual amount.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_UNHAPPINESS_MOD_SPECIALIST` — Because of bonuses your empire has earned, Specialist citizens produce half the normal [ICON_HAPPINESS_4] Unhappiness.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_UNHAPPINESS_MOD_TRAIT` — Because of your civilization's traits, they produce {1_Num}% the usual amount.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_WONDER_SCENARIO_CIV_HITTITES_HEADING_1` — History  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_CIV_SUMERIA_HEADING_1` — History  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_CULTURAL_WONDER_HEADING` — CULTURAL ([ICON_CULTURE] Culture)  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_DIPLO_MY_SCORE_FUTURE_TECH` — {1_Num} from Wonders Owned  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_DIPLO_MY_SCORE_WONDERS` — {1_Num} from Wonders Built  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_LEADER_GILGAMESH_HEADING_1` — History  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_LEADER_GILGAMESH_SUBTITLE` — King of Sumer  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_LEADER_MUWATALLIS_HEADING_1` — History  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_LEADER_MUWATALLIS_SUBTITLE` — King of the Hittites  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_MILITARY_WONDER_HEADING` — MILITARY (Great General Progress)  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_MYSTICAL_WONDER_HEADING` — MYSTICAL WONDERS  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_POPUP_ORACLE_CONSULTED` — SHOWING: Information revealed by consulting the Oracle  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_POPUP_ORACLE_CONSULTED_BY` — {@1_CivName} has consulted The Oracle!  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_POPUP_ORACLE_EXPIRED` — SHOWING: Information known to your civilization  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_POPUP_WONDER_UNLOCKED` — Thanks to your growing achievements, your civilization has unlocked the power to build {@1_WonderName}!  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_SCIENTIFIC_WONDER_HEADING` — SCIENTIFIC (Technologies)  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`
- `TXT_KEY_WONDER_SCENARIO_TITLE` — Wonders of the Ancient World  
  source: `DLC/DLC_06/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_WonderScenario.XML`

## Save / Load (41)

- `TXT_KEY_ACTION_LOAD_GAME` — Load Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_LOAD_GAME` — Load Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_GAME_TT` — Load a saved game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOAD_MAP_TT` — Load a specific map to play  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_OPSCREEN_BLOCK_LOAD_TT` — The game will remain in the loading screen until all of the terrain in the world is generated graphically.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_RELOAD_UI_TT` — Apply Interface Scale Change  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_BUILDINGMAINTENANCE` — Building Maintenance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_CITYCOUNT` — Number of Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_CULTUREPERTURN` — Culture [ICON_CULTURE] Per Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_EXCESSHAPPINESS` — Excess Happiness [ICON_HAPPINESS_1]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_FOODPERTURN` — Food [ICON_FOOD] Per Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_GOLDAGETURNS` — Golden Age [ICON_GOLDEN_AGE] Turns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_GOLDPERTURN` — Gold [ICON_GOLD] Per Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_GPTCITYCONNECTIONS` — [ICON_GOLD]GPT - City Connections  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_GPTDEALS` — [ICON_GOLD]GPT - Deals  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_HAPPINESS` — Happiness [ICON_HAPPINESS_1]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_IMPROVEDTILES` — Improved Tiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_IMPROVEMENTMAINTENANCE` — Improvement Maintenance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_MILITARYMIGHT` — Military Might  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_NUMBEROFPOLICIES` — Number of Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_NUMBEROFWORKERS` — Number of Workers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_PRODUCTIONPERTURN` — Production [ICON_PRODUCTION] Per Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_SCIENCEPERTURN` — Science [ICON_RESEARCH] Per Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_TOTALCULTURE` — Total Culture [ICON_CULTURE]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_TOTALGOLD` — Total Gold [ICON_GOLD]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_TOTALLAND` — Total Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_TOTALPOPULATION` — Population [ICON_CITIZEN]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_UNHAPPINESS` — Unhappiness [ICON_HAPPINESS_3]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_UNITMAINTENANCE` — Unit Maintenance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_DATA_WORKEDTILES` — Worked Tiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_PLAYPAUSE` — Play/Pause  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_TITLE` — REPLAY  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_VIEWER_GRAPHBY_SCORE` — Score  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_VIEWER_GRAPHS_TITLE` — Graphs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_VIEWER_GRAPHS_TT` — View various graphs of data collected for each player.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_VIEWER_MAP_TITLE` — Map  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_VIEWER_MAP_TT` — View the world map and the growth of territories over time.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_VIEWER_MESSAGES_TITLE` — Messages  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_REPLAY_VIEWER_MESSAGES_TT` — View all important messages which occurred during the game.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SAVE_GAME_CONFIGURATION_TT` — Save the game startup configuration.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_SELECT_SAVE_GAME` — Please select a saved game.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`

## Multiplayer / lobby (112)

- `TXT_KEY_ADVISOR_BARBARIAN_CAMP_DISPLAY` — Barbarian Camp  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_BUILDING_CHATEAU` — Chateau  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Buildings_Scenarios_Expansion.xml`
- `TXT_KEY_BUILD_CHATEAU` — Construct a [LINK=IMPROVEMENT_CHATEAU]Chateau[\LINK]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Objects_Expansion2.xml`
- `TXT_KEY_CHAT_LOG` — Chat Log  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_CITYSTATE_FRIENDS_HEADING4_TITLE` — Friends  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_CAMP_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_CAMP_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_CAMP_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_CAMP_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_FRIENDSHIP_ADV_QUEST` — Declaration of Friendship  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_FRIENDSHIP_HEADING3_TITLE` — Declaration of Friendship  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLO_DECLARATION_OF_FRIENDSHIP` — DECLARATION OF FRIENDSHIP  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DECLARATION_OF_FRIENDSHIP_ALREADY_EXISTS` — A Declaration of Friendship already exists between players.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DECLARATION_OF_FRIENDSHIP_AT_WAR` — Players are at war, a peace treaty must first be agreed to.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_DEC_FRIENDSHIP` — Shall we make a joint Declaration of Friendship?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISUCSS_STRONG_FRIENDSHIP` — I hope that our friendship remains strong.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_FRIENDS_WITH` — [COLOR_POSITIVE_TEXT]Friends with {1_CivName:textkey}[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HUMAN_DECLARED_WAR_ON_FRIENDS` — [COLOR_NEGATIVE_TEXT]You have Declared War on leaders you've made Declarations of Friendship with![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_OPEN_CHAT` — Open Chat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_OPEN_CHAT_TT` — Toggles the Large Chat View.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_GOLD_BUYFRIENDSHIP_HEADING3_TITLE` — Buying Influence with City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GREAT_WORK_LADY_CHATTERLEYS_LOVER` — Lady Chatterley's Lover  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Objects_Expansion2.xml`
- `TXT_KEY_IMPROVEMENT_CHATEAU` — Chateau  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Objects_Expansion2.xml`
- `TXT_KEY_LEADERBOARD_FRIENDS` — FRIENDS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_FRIENDS_TT` — Display leaderboard of you and your friends.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LIST_SERVERS_FRIENDS_TT` — Steam Dedicated Servers hosted by friends on the Internet.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LOBBY_REQUIRED_DLC` — Required DLC:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MODS_SELECT_MULTIPLAYER_TYPE` — Mods Multiplayer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MP_CHANGE_PASSWORD` — Change Password  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MP_NETWORK_CONNECTION_LOST` — Network connection has been lost.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MP_OPTION_ALWAYS_PEACE` — Always Peace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MP_OPTION_SIMULTANEOUS_TURNS` — Simultaneous Turns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MP_OPTION_TAKEOVER_AI` — Take over AI  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MP_OPTION_TURN_TIMER` — Turn Timer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MP_USE_PASSWORD_TT` — Use a password to start the player's turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_AUTOSAVES` — Autosaves  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_BROWSE_GAMES` — Browse Games  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_CONNECT_TO_IP` — Connect to IP Address  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_CONNECT_TO_IP_TT` — Connect to a pitboss game at a given public IP address.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_DEDICATED_SERVER_ROOM` — Dedicated Server Room  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_DEFAULT_PLAYER_NAME` — Player {1_Num}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_DEFAULT_SERVER_NAME` — Server {1_Num}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_DEFAULT_SERVER_PLAYER_NAME` — Server  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME` — Team {1_Num}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_DLCHOSTED` — DLC  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_GAMES_FOUND` — Games Found:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_HOST_GAME` — Host Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_HOST_GAME_TT` — Start a new multiplayer game.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_HOST_LAN` — Host a LAN Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_HOST_PRIVATE_GAME` — Host Private Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_HOTSEAT_GAME` — Hot Seat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_HOTSEAT_GAME_TT` — Play a multiplayer game where players take alternating turns on this machine.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_INTERNET_GAME` — Internet  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_INTERNET_GAME_TT` — Play a multplayer game on the internet.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_INTERNET_LOBBY` — INTERNET GAMES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_INVITE` — Invite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_INVITE_TT` — Invite friends to join your game.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_JOINING_GAMESTATE` — Retrieving Host Information...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_JOINING_HOST` — Connecting to host...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_JOINING_PLAYERS` — Connecting to players...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_JOINING_ROOM` — Joining Room...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_JOIN_GAME` — Join Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_LAN_GAME` — Local Network  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_LAN_GAME_TT` — Play a multiplayer game on the local network.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_LAN_LOBBY` — LOCAL NETWORK GAMES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_LAUNCH_GAME` — Launch Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_MEMBERS` — Members  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_MODSHOSTED` — Mods  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_OBSERVER_TEAM_NAME` — Observers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_OPTIONS` — MULTIPLAYER OPTIONS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MULTIPLAYER_PITBOSS_GAME` — Pitboss  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_PITBOSS_GAME_TT` — Play a multiplayer game where a dedicated server controls the game over a long period of time.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_PITBOSS_LOBBY` — PITBOSS GAMES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_PLAYER_STATUS_READY` — Ready  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_PRIVATE_GAME` — Private Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_RECONNECT` — Reconnect To Last Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_REFRESH_GAME_LIST` — Refresh  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_REFRESH_GAME_LIST_TT` — Retrieve the latest game list information.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_RESUME_LAST_GAME` — Resume Last Game  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_SEARCHING_GAME` — Searching for Games...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_SERVER_NAME` — Server Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STAGING_ROOM` — Staging Room  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STAGING_ROOM_GAME_OPTIONS_TT` — Change game options. (Host Only)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STAGING_ROOM_HEADER_CIVILIZATION` — Civilization  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STAGING_ROOM_HEADER_PLAYER` — Players  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STAGING_ROOM_HEADER_PLAYER_TT` — Display players list.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STANDARD_GAME` — Standard  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STANDARD_GAME_TT` — Play a multiplayer game where players take turns continuously with each other.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STATUS_LISTING` — Status  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STOP_REFRESH_GAME_LIST` — Stop Refresh  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STOP_REFRESH_GAME_LIST_TT` — Stop the game list information retrieval.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_STRING` — MultiPlayer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_TO_ALL` — To All:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_TT` — LAN or internet multiplayer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MULTIPLAYER_UNIT_TT` — {1_PlayerHandle}: {@2_Adjective} {@3_UnitName}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_OPSCREEN_MP_SCORE_LIST` — Multiplayer Score List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MP_SCORE_LIST_TT` — Display the simple score list in multiplayer games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MULTIPLAYER_AUTO_END_TURN` — Multiplayer Auto End Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MULTIPLAYER_AUTO_END_TURN_TT` — Enables auto-turn-cycling when in Multiplayer games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MULTIPLAYER_QUICK_COMBAT` — Multiplayer Quick Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MULTIPLAYER_QUICK_COMBAT_TT` — Enables quick combat resolution in multiplayer games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MULTIPLAYER_QUICK_MOVEMENT` — Multiplayer Quick Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MULTIPLAYER_QUICK_MOVEMENT_TT` — Enables quick unit movement in multiplayer games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PROMOTION_STEAM_POWERED` — Double movement in Coast  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_STAGING_ROOM_TIME_MS` — ms  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_STAGING_ROOM_TIME_S` — s  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_STAGING_ROOM_UNDER_1_MS` — <1ms  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_STEAM_EMPTY_SAVE` — Empty Save Slot  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_TECH_STEAM_POWER` — Steam Power  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_STEAM_POWER_TITLE` — Steam Power  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TURN_REMINDER_EMAIL_STEAM_LINK` — <a href="{1_SteamURL}">Click here to join the game.</a>  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_WORKERS_CAMP_HEADING3_TITLE` — Camp  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`

## Options (192)

- `TXT_KEY_ACTION_OPTIONS_SCREEN` — Options Screen  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_AUDIO_OPTIONS` — AUDIO OPTIONS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_CONGRESS_RESOLUTIONS_HEADING2_TITLE` — Resolutions  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_DEMOGRAPHICS_APPROVAL` — Approval  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_ARMY` — Soldiers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_ARMY_MEASURE` — Soldiers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_FOOD` — Crop Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_FOOD_MEASURE` — Million Bushels  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_GOLD` — GNP  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_GOLD_MEASURE` — Million Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_LAND` — Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_LAND_MEASURE` — Square KM  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_LITERACY` — Literacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_POPULATION` — Population  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_POPULATION_MEASURE` — People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_PRODUCTION` — Manufactured Goods  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_PRODUCTION_MEASURE` — Million Tons  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_RANK` — Rank  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_RIVAL_AVERAGE` — Average  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_RIVAL_BEST` — Best  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_RIVAL_WORST` — Worst  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_TITLE` — DEMOGRAPHICS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_TYPE` — Demographic  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DEMOGRAPHICS_VALUE` — Value  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_GAME_OPTION_ALWAYS_WAR` — Always War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_COMPLETE_KILLS` — Complete Kills  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_DISABLE_START_BIAS` — Disable Start Bias  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_DYNAMIC_TURNS` — Hybrid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED` — Enable Turn Timer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_GAME_OPTION_LOCK_MODS` — Lock Mods  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_NEW_RANDOM_SEED` — New Random Seed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_ONE_CITY_CHALLENGE` — One-City Challenge  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_PERMANENT_ALLIANCES` — Permanent Alliances  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_PITBOSS` — Pitboss  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_GAME_OPTION_POLICY_SAVING` — Allow Policy Saving  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_PROMOTION_SAVING` — Allow Promotion Saving  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_QUICK_COMBAT` — Quick Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_GAME_OPTION_QUICK_MOVEMENT` — Quick Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_GAME_OPTION_RAGING_BARBARIANS` — Raging Barbarians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_RANDOM_PERSONALITIES` — Random Personalities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_GAME_OPTION_SEQUENTIAL_TURNS` — Sequential  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_GAME_OPTION_SIMULTANEOUS_TURNS` — Simultaneous  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_INTERFACE_OPTIONS` — INTERFACE OPTIONS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_ACTIVE_RESOLUTIONS_TT` — Resolutions that are currently in effect, which Civilizations may attempt to repeal.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_INACTIVE_RESOLUTIONS_TT` — Resolutions that Civilizations may attempt to enact.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_INVALID_RESOLUTION_GAMEOPTION` — Not allowed by this game's options.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_OTHER_RESOLUTIONS_TT` — Resolutions that cannot be proposed at this time.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_MAP_OPTIONS_HEX_GRID` — Hex Grid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_HEX_GRID_TT` — Display the grid.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_RECOMMENDATIONS` — Hide Recommendations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_RECOMMENDATIONS_TT` — Hide Civilian Recommendations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_RESOURCE_ICONS` — Resource Icons  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_RESOURCE_ICONS_TT` — Display all resource icons.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_TRADE_ROUTES` — Trade Routes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_TRADE_ROUTES_TT` — Display the trade routes.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_UNIT_FLAGS` — Unit Flags  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_UNIT_FLAGS_TT` — Hide all unit flags.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_YIELD_ICONS` — Yield Icons  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTIONS_YIELD_ICONS_TT` — Display all yield icons.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_OPTION_ABUNDANT` — Abundant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_AMOUNT_OF_TINY_ISLANDS` — Amount of Tiny Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ARCHIPELAGO` — Archipelago  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ARID` — Arid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_BALANCED_RESOURCES` — Balanced  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_BARREN` — Barren  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_BODIES_OF_WATER` — Bodies of Water  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_BUFFER_ZONES` — Buffer Zones  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_CENTER_REGION` — Center Region  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_CLUSTERS` — Clusters  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_CONTINENTS_SIZE` — Continents Size  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_COOL` — Cool  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_COPY` — Copy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_CRAZY` — Crazy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_CYLINDER` — Cylinder  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_DENSE` — Dense  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_DESERT` — Desert  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_DOMINANT_TERRAIN` — Dominant Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_DRY` — Dry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_EXTRAS` — Extras  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_FEW_TINY_ISLANDS` — Few Tiny Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_FIVE_BILLION_YEARS` — 5 Billion Years  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_FIVE_PER_CONTINENT` — 5  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_FLAT` — Flat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_FOUR_BILLION_YEARS` — 4 Billion Years  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_FOUR_CORNERS` — Four Corners  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_FOUR_PER_CONTINENT` — 4  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_GLOBAL_CLIMATE` — Global Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_HIGH` — High  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_HILLS` — Hills  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_HOT` — Hot  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_INVERSION` — Inversion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_IRRATIONAL` — Irrational  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ISLANDS` — Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ISLANDS_MIXED_IN` — Islands Mixed In  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ISLANDS_OVERLAP` — Islands Overlap  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ISLANDS_SIZE` — Islands Size  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ISLAND_REGION_SEPARATE` — Island Region Separate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ISTHMUS_WIDTH` — Isthmus Width  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_JUNGLE` — Jungle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LANDMASS_TYPE` — Landmass Type  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LAND_SHAPE` — Land Shape  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LARGE_CONTINENTS` — Large Continents  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LARGE_ISLANDS` — Large Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LARGE_LAKES` — Large Lakes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LEFT_VS_RIGHT` — Left vs Right  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LEGENDARY_START` — Legendary Start  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LOGICAL` — Logical  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_LOW` — Low  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MANY_TINY_ISLANDS` — Many Tiny Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MAZE_WIDTH` — Maze Width  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MEDIUM` — Medium  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MILD` — Mild  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MIRROR_TYPE` — Mirror Type  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MODERATE` — Moderate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MOUNTAINS` — Mountains  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MOUNTAIN_DENSITY` — Mountain Density  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_MOUNTAIN_PATTERN` — Mountain Pattern  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_NARROW_CONTINENTS` — Narrow Continents  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_NATURAL` — Natural  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_NUMBER_OF_MAIN_ISLANDS` — Number of Main Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_NUM_CONTINENTS` — Number of Continents  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_OCEAN` — Ocean  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ONE_PER_CONTINENT` — One per Continent  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_ONE_PER_PLAYER` — One per Player  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_OPPOSITE` — Opposite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_PANGAEA` — Pangaea  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_PLOTS_WIDE_FIVE` — 5 Plots Wide  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_PLOTS_WIDE_FOUR` — 4 Plots Wide  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_PLOTS_WIDE_ONE` — 1 Plot Wide  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_PLOTS_WIDE_THREE` — 3 Plots Wide  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_PLOTS_WIDE_TWO` — 2 Plots Wide  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_PRESSED` — Pressed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RAINFALL` — Rainfall  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RANDOM` — Random  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RANGES` — Ranges  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_REFLECTION` — Reflection  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RESOURCES` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RESOURCE_APPEARANCE` — Resource Appearance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RIDGELINES` — Ridgelines  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RING_WIDTH` — Ring Width  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RIVERS` — Rivers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_RIVERS_AND_SEAS` — Rivers and Seas  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SCATTERED` — Scattered  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SEAS` — Seas  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SEA_LEVEL` — Sea Level  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SEVERAL_EXTRAS` — Several Extras  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SEVERE` — Severe  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SEVERITY` — Severity of Desert Region  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SIX_PER_CONTINENT` — 6  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SMALL_CONTINENTS` — Small Continents  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SMALL_ISLANDS` — Small Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SMALL_LAKES` — Small Lakes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SOLID` — Solid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_SPARSE` — Sparse  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_STANDARD` — Standard  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_START_ANYWHERE` — Start Anywhere  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_START_SEPERATED` — Start Separated  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_START_TOGETHER` — Start Together  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_STRATEGIC_BALANCE` — Strategic Balance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_TEAM_PLACEMENT` — Team Placement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_TEAM_SETTING` — Team Setting  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_TEMPERATE` — Temperate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_TEMPERATURE` — Temperature  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_THIN` — Thin  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_THREE_BILLION_YEARS` — 3 Billion Years  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_THREE_PER_CONTINENT` — 3  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_TINY_ISLANDS` — Tiny Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_TOP_VS_BOTTOM` — Top vs Bottom  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_TOROID` — Toroid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_TWO_PER_CONTINENT` — 2  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_VARIED` — Varied  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_VARIOUS_TINY_ISLANDS` — Various Tiny Islands  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_WATER_SETTING` — Water Setting  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_WET` — Wet  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_WIDE_CONTINENTS` — Wide Continents  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_WITHOUT_OCEANS` — Without Oceans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_WORLD_AGE` — World Age  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_OPTION_WORLD_WRAP` — World Wrap  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_OPSCREEN_APPLY_RESOLUTION_TT` — Apply Resolution Settings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SKIP_INTRO_VIDEO_TT` — Skips playing the introduction video.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPTIONS_TT` — Game and System Settings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_PLAYER_OPTION_ADVISOR_POPUPS` — Advisor Pop-Ups  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAYER_OPTION_QUICK_COMBAT_DEFENSE` — Quick Combat (Defense)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAYER_OPTION_QUICK_COMBAT_OFFENSE` — Quick Combat (Offense)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAYER_OPTION_QUICK_MOVES` — Quick Moves  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAYER_OPTION_SHOW_ENEMY_MOVES` — Show Enemy Moves  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAYER_OPTION_WAIT_AT_END_OF_TURN` — Wait at End of Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAYER_OPTION_WORKERS_LEAVE_OLD_IMPS` — Automated Workers Leave Old Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLAYER_OPTION_WORKERS_START_AUTO` — Workers Start Automated  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_RESOLUTION_DIPLO_VICTORY` — World Leader  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_STRAT_MAP_OPTIONS_TT` — Toggle map options menu on/off  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VIDEO_OPTIONS` — VIDEO OPTIONS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`

## Notifications / turn flow (27)

- `TXT_KEY_ACPANEL_END_TURN` — END TURN  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_ADVISOR_END_TURN_DISPLAY` — Click Next Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_FIRST_TURN_BUILD_CITY_DISPLAY` — Found a City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_FIRST_TURN_UNIT_MOVE_DISPLAY` — Explore the World  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_LATER_TURN_UNIT_MOVE_DISPLAY` — Explore the World!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CITYVIEW_PERTURN_TEXT` — +{1_perTurn:number "#.##"}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_PERTURN_TEXT_NEGATIVE` — [COLOR_WARNING_TEXT]{1_perTurn:number "#.##"}[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_RETURN_TO_ESPIONAGE` — Return to Espionage  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Inherited_Expansion2.xml`
- `TXT_KEY_CITYVIEW_RETURN_TO_MAP` — Return to Map  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_RETURN_TT` — Return  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CULTURE_PER_TURN_LABEL` — Culture Per Turn: {1_Num} [ICON_CULTURE]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_GOLD_PERTURN_HEADING4_TITLE` — Per Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_MULTIPLETURN_HEADING2_TITLE` — Multiple Turn Move Orders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_NEXT_POLICY_TURN_LABEL` — Next Policy: {1_Num: number #} Turn(s)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NEXT_TURN` — NEXT TURN  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_NEXT_TURN_TT` — End your turn, allowing the other players in the game to act.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_OPSCREEN_END_TURN_TIMER_LENGTH` — End Turn Timer Length: 10 seconds  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_END_TURN_TIMER_SET` — End Turn Timer Length:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SPLAYER_AUTO_END_TURN` — Single Player Auto End Turn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SPLAYER_AUTO_END_TURN_TT` — Enables auto-turn-cycling when in Single Player games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SKIP_TURN_TT` — Tell the currently selected Unit to do nothing this turn.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_TURN_REMINDER_EMAIL_BODY_HEADER` — Hello!<br><br>It is your turn in game "{1_GameName}".<br><br>  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_TURN_TIMER_ACTIVE_TT` — Time remaining in your turn.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_TURN_TIMER_WAITING_TT` — Time until your turn.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_WAITING_FOR_INVITE_RESPONSE` — Waiting for {1_player}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_WAITING_FOR_PLAYERS` — WAITING FOR PLAYERS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_WAITING_FOR_PLAYERS_TT` — The game is waiting for other players to finish their turn.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`

## Popups (34)

- `TXT_KEY_ADVISORINFOPOPUP_CIVILOPEDIA` — Civilopedia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISORINFOPOPUP_FORWARD` — Go forward  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_GREAT_WORK_POPUP_WRITTEN_ARTIFACT` — Written Artifact  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_LEAGUE_PROJECT_POPUP_COMPLETE` — COMPLETED!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_POPUP_ANNEX_CITY` — Annex the City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_ARE_YOU_SURE` — Are you sure?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_ARE_YOU_SURE_ACTION` — Are you sure you want to {@1_ActionName}?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_ARE_YOU_SURE_RAZE` — Are you sure you want to raze this City? (This can be undone)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_CITY_CAPTURE_INFO` — What would you like to do with this City?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_CIVILIZATION` — Civilization  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_POPUP_DETAILS_TITLE` — Your Details  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_DOES_THIS_MEAN_WAR` — Does this mean WAR?!? (vs. {1_Team})  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_DOES_THIS_MEAN_WAR_PROTECTED_CITY_STATE` — Does this mean WAR against {1_Team}?!? They are under the protection of:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_DONT_ANNEX_CITY` — Leave City as a Puppet  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_ELECTION_OPTION` — {@1_VoteName} (Requires {2_ReqNum} of {3_TotNum} Total Votes)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_ENTER_CITY_STATE_WAR` — Entering [COLOR_HIGHLIGHT_TEXT]{1_CivAdj}[ENDCOLOR] will trigger WAR! Are you sure?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_ENTER_LANDS_WAR` — Entering [COLOR_HIGHLIGHT_TEXT]{1_CivAdj}[ENDCOLOR] lands will trigger WAR! Are you sure?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_ENTER_WITH_OPEN_BORDERS` — (You can peacefully enter if you sign an Open Borders Treaty.)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_GAME_DETAILS` — Game Details  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_GOLD_AND_CULTURE_CITY_CAPTURE` — You have pillaged {1_Num} [ICON_GOLD] and {2_Num} [ICON_CULTURE] from the capture of {@3_CityName}!!!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`
- `TXT_KEY_POPUP_GOLD_CITY_CAPTURE` — You have pillaged {1_Num} [ICON_GOLD] from the capture of {@2_CityName}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_GREAT_PERSON_UNIT` — Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POPUP_GREAT_PERSON_VPS` — Civilization Points  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POPUP_LIBERATE_CITY` — Liberate the City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_PUPPET_CAPTURED_CITY` — Create Puppet  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_RAZE_CAPTURED_CITY` — Raze the City!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_VIEW_CITY` — View City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_VIEW_CITY_DETAILS` — Go to the city screen. You may not change anything while inside.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_VOTES_FOR` — {1_VtrName} votes for {2_PlyrName} ({3_Num} Total)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_WHAT_TO_BUILD` — What would you like to build in this city?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_POPUP_WHAT_TO_PURCHASE` — What would you like to purchase in this city?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_RANSOM_POPUP_ABANDON` — It's not worth the Gold. Leave them.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_RANSOM_POPUP_PAY` — Pay the price.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_TECH_POPUP_HEADER` — Please select a new Technology to research and develop for your Civilization.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`

## In-game HUD / panels (34)

- `TXT_KEY_ADVISOR_ESPIONAGE_OVERVIEW_DISPLAY` — This is the Espionage Overview!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_SCREEN_MILITARY_OVERVIEW_DISPLAY` — Military Overview  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CHOOSE_TRADE_ROUTE_TRADE_OVERVIEW` — Trade Overview  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_DEMOGRAPHICS` — Demographics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_MILITARY_OVERVIEW` — Military Overview  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_TOP_PANEL_GOLDEN_AGES_OFF` — Golden Ages: OFF  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_TOP_PANEL_HAPPINESS_OFF` — Happiness: OFF  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES` — [ICON_TURNS_REMAINING] {1_TradeRoutesUsedNum} / {2_TradeRoutesAvailable}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_CITY_STATE_TT` — City State  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_CULTURE_YIELD_TT` — {1_Num} [ICON_CULTURE] Culture  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_ESTABLISHED_BY_OTHER_TT` — Trade routes others established to your civilization  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_ESTABLISHED_BY_PLAYER_TT` — Trade routes you established  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_FAITH_YIELD_TT` — {1_Num} [ICON_FAITH] Faith  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_FOOD_YIELD_TT` — {1_Num} [ICON_FOOD] Food  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_GOLD_YIELD_TT` — {1_Num} [ICON_GOLD] Gold  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_INTERNAL_YOUR_ROUTE_BOTH_TT` — {1_CityName} ({2_ResourcesStr}) [ICON_TURNS_REMAINING] {3_CityName} ({4_ResourcesStr})  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_INTERNAL_YOUR_ROUTE_ONLY_DEST_TT` — {1_CityName} [ICON_TURNS_REMAINING] {2_CityName} ({3_ResourcesStr})  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_INTERNAL_YOUR_ROUTE_ONLY_ORIGIN_TT` — {1_CityName} ({2_ResourcesStr}) [ICON_TURNS_REMAINING] {3_CityName}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_PRODUCTION_YIELD_TT` — {1_Num} [ICON_PRODUCTION] Production  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_SCIENCE_YIELD_TT` — {1_Num} [ICON_RESEARCH] Science  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_TO_YOU_ROUTE_BOTH_TT` — ({1_CivName}) {2_CityName} ({3_ResourcesStr}) [ICON_TURNS_REMAINING] {4_CityName} ({5_ResourcesStr})  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_TO_YOU_ROUTE_ONLY_DEST_TT` — ({1_CivName}) {2_CityName} [ICON_TURNS_REMAINING] {3_CityName} ({4_ResourcesStr})  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_TO_YOU_ROUTE_ONLY_ORIGIN_TT` — ({1_CivName}) {2_CityName} ({3_ResourcesStr}) [ICON_TURNS_REMAINING] {4_CityName}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_YOUR_ROUTE_BOTH_TT` — {1_CityName} ({2_ResourcesStr}) [ICON_TURNS_REMAINING] ({3_CivName}) {4_CityName} ({5_ResourcesStr})  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_YOUR_ROUTE_ONLY_DEST_TT` — {1_CityName} [ICON_TURNS_REMAINING] ({2_CivName}) {3_CityName} ({4_ResourcesStr})  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_ITR_YOUR_ROUTE_ONLY_ORIGIN_TT` — {1_CityName} ({2_ResourcesStr}) [ICON_TURNS_REMAINING] ({3_CivName}) {4_CityName}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_POLICIES_OFF` — Policies: OFF  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_TOP_PANEL_RELIGION_OFF` — Religion: OFF  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_RELIGION_OFF_TOOLTIP` — The Religion system is turned off in this game. No Faith earned. Pantheons and Religions may not be founded.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_SCIENCE_OFF` — Science: OFF  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_TOP_PANEL_SCIENCE_OFF_TOOLTIP` — The Science system is off in this scenario. No new technologies will be gained.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_1` — {1_Num} [ICON_GREAT_WORK] Great Work Slots Filled  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_2` — {1_Num} [ICON_GREAT_WORK] Great Work Slots Available  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_3` — Influential on {1_XofYString} Civilizations needed for Culture Victory  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`

## City screen (96)

- `TXT_KEY_ADVISOR_SCREEN_PRODUCTION_CHOOSER_DISPLAY` — Production Chooser  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CHOOSE_PRODUCTION_TT` — You may select a new construction project for one of your Cities!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CITYVIEW_BLOCKADED_CITY_TILE` — This tile is being blockaded by an enemy.  You may not work it until the blockading enemy is removed.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_BUILDING_LIST` — Building List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_BUILDING_SPECIALIST_YIELD` — {1_NumSpecialists} {2_SpecialistDesc * {1_NumSpecialists}}... {3_YieldString} each  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CITYVIEW_BUYPLOT_TT` — When you have enough [ICON_GOLD] Gold, this will purchase one of the highlighted tiles.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_BUY_PLOT_TEXT` — Buy Plot Text  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_BUY_TILE` — Buy a Tile  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_BUY_TILE_TT` — Spend [ICON_GOLD] Gold to fund your citizens' settlement of a tile adjacent to your borders.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CHANGE_PROD` — CHANGE PRODUCTION  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CHANGE_PROD_TT` — Change what this City's current construction project is.  Only one item at a time may be produced.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CHOOSE_PROD` — CHOOSE PRODUCTION  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CHOOSE_PROD_TT` — Choose what this City's current construction project is.  Only one item at a time may be produced.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CITIZENS_TEXT` — {1_NumCitizens: plural 1?Citizen; other?Citizens;}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_CITYVIEW_CITIZEN_ALLOCATION` — Citizen Management  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CITIZEN_ICON_TT` — Citizen Symbol  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CITYINFO_TEXT` — City Information  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CITY_CENTER` — The City Center is automatically worked for free.  Click here to have governor reassign the workforce.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CITY_COMB_STRENGTH_TT` — City Combat Strength  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CLAIM_NEW_LAND` — Buy this plot of land for {1_Num}[ICON_GOLD] Gold.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_CULTURE_TEXT` — Culture  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_CITYVIEW_EACH` — each  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_EMPTY_SLOT` — Empty Specialist Slot  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_ENEMY_UNIT_CITY_TILE` — This tile has an enemy on it.  You may not work it until the enemy unit is removed.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FAITH_TEXT` — Faith  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Objects_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Objects_Inherited_Expansion2.xml`
- `TXT_KEY_CITYVIEW_FOCUS_AVOID_GROWTH_TEXT` — Avoid Growth  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_AVOID_GROWTH_TT` — Click here to have the city attempt to stay the same population.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_BALANCED_TEXT` — Default Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_BALANCED_TT` — Click here to have this city use the default citizen allocation.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_CULTURE_TEXT` — [ICON_CULTURE] Culture Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_CULTURE_TT` — Click here to have this city emphasize production of [ICON_CULTURE] Culture.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_FAITH_TEXT` — [ICON_PEACE] Faith Focus  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Inherited_Expansion2.xml`
- `TXT_KEY_CITYVIEW_FOCUS_FAITH_TT` — Click here to have this city emphasize production of [ICON_PEACE] Faith.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Inherited_Expansion2.xml`
- `TXT_KEY_CITYVIEW_FOCUS_FOOD_TEXT` — [ICON_FOOD] Food Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_FOOD_TT` — Click here to have this city emphasize production of [ICON_FOOD] Food.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_GOLD_TEXT` — [ICON_GOLD] Gold Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_GOLD_TT` — Click here to have this city emphasize production of [ICON_GOLD] Gold.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_GREAT_PERSON_TEXT` — [ICON_GREAT_PEOPLE] Great Person Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_GREAT_PERSON_TT` — Click here to have this city emphasize production of [ICON_GREAT_PEOPLE] Great People.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_PROD_TEXT` — [ICON_PRODUCTION] Production Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_PROD_TT` — Click here to have this city emphasize production of [ICON_PRODUCTION] Production.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_RESEARCH_TEXT` — [ICON_RESEARCH] Science Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_RESEARCH_TT` — Click here to have this city emphasize production of [ICON_RESEARCH] Science.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_RESET_TEXT` — Reset Tiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOCUS_RESET_TT` — Click here to remove all user locked tiles.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOOD_IN_TURNS` — {1_Num} [ICON_FOOD]/Turn, {2_Num} Turns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FOOD_TEXT` — Food  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_FORCED_WORK_TILE` — You have selected this tile to work.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_GG_PROGRGRESS` — Great General Progress  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_GOLD_TEXT` — Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_CITYVIEW_GP_PROGRGRESS` — Great Person Progress  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_GREAT_PEOPLE_TEXT` — Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_CITYVIEW_GREAT_WORK_BUILDINGS_TEXT` — Great Work Buildings  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Objects_Expansion2.xml`
- `TXT_KEY_CITYVIEW_GUVNA_WORK_TILE` — Your governor has selected this tile to work.  You may click here to override this.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_MAINTENANCE` — Maintenance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_MANUAL_SPEC_CONTROL` — Manual Specialist Control  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_NEED_MONEY_BUY_TILE` — You need {1_Num} [ICON_GOLD] Gold to buy this land.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_OFF` — OFF  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_OTHER` — OTHER  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_PLACEHOLDER_TT` — Placeholder  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_PRODUCE_RESEARCH` — Produce Research  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_PRODUCE_WEALTH` — Produce Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_PROD_METER_TT` — Right-Click for more information  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_PROD_TEXT` — Production  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_CITYVIEW_PURCHASE_TT` — When you have enough [ICON_GOLD] Gold or [ICON_PEACE] Faith, buy a unit or building immediately.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_QUEUE_C` — Hide Queue  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_QUEUE_C_TT` — Close the Production Queue  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_QUEUE_O` — Show Queue  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_QUEUE_O_TT` — Open the Production Queue  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_QUEUE_PROD` — ADD TO QUEUE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_QUEUE_PROD_TT` — Add an additional item to the end of the production queue (up to six items).  Only one item at a time will be produced.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_QUEUE_SELECTION` — Queue Selection  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_Q_DOWN_TEXT` — Move down in the production queue.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_Q_UP_TEXT` — Move up in the production queue.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_Q_X_TEXT` — Remove from the production queue.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_REGULARBUILDING_TEXT` — Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_CITYVIEW_RESEARCH_TEXT` — Science  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_CITYVIEW_RESOURCE_DEMANDED` — Resource Demanded: {1_ResourceName}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_RESOURCE_FULFILLED_TT` — This City is in "We Love the King Day", which increases [ICON_FOOD] growth!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_SPECIALISTCONTROL_TT` — Toggle between manual and AI control of Building Specialists.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_SPECIAL_TEXT` — Specialist Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_CITYVIEW_STAGNATION_TEXT` — [COLOR_YELLOW]STAGNATION[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_STARVATION_TEXT` — [COLOR_WARNING_TEXT]STARVATION[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_TOGGLE_FOCUS_TT` — Toggle City Focus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_TOURISM_TEXT` — Tourism  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CITYVIEW_TURNS_TILL_CITIZEN_TEXT` — {1_Turns:number} {1_Turns: plural 1?Turn; other?Turns;} until a New Citizen is Born  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_TURNS_TILL_TILE_TEXT` — {1_NumTurns:number} {1_NumTurns: plural 1?turn; other?turns;} until Border Growth  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_UNEMPLOYED_TEXT` — Unemployed Citizens  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_UNEMPLOYED_TOOLTIP` — Click here to have governor reassign the workforce.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_WLTKD_COUNTER` — We Love The King Day! ({1_Num})  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITYVIEW_WONDERS_TEXT` — Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_PEDIA_PRODUCTION_LABEL` — Production:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PROGRESS_SCREEN_PRODUCTION_TT` — Ranks players by the amount of [ICON_PRODUCTION] Production generated by all of their cities.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_RO_AUTO_FAITH_PURCHASE_GREAT_PERSON` — Purchase {1_GreatPersonType}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_RO_AUTO_FAITH_PURCHASE_PROPHET` — Purchase Great Prophet  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_HURRYPRODUCTION_HEADING4_TITLE` — Special Ability: Hurry Production  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`

## Diplomacy (388)

- `TXT_KEY_ACTIVE_DEAL_RESOURCE` — {1_Amount} {2_ResourceIcon} {3_ResourceName}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_ADVISOR_HOW_TO_ENGAGE_DIPLOMACY_2_DISPLAY` — Diplomacy Panel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_HOW_TO_ENGAGE_DIPLOMACY_DISPLAY` — Contact a Civ or City-State  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_DIPLOMACY_LIST_DISPLAY` — Diplomacy List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_DIPLOMACY_OVERVIEW_DISPLAY` — Diplomacy Overview  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_LEADER_TRADE_DIALOG_DISPLAY` — Diplomatic Trading  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_TUTORIAL_5_INTRO_DIPLOMACY_DISPLAY` — Basic Diplomacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CHANGE_TRADE_UNIT_HOME_CITY_TITLE` — Change Trade Unit Home City  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_BASE` — Gold base: {1_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_BUILDING` — Gold bonus from buildings in {1_CityName}: {2_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_EXCLUSIVE_CONNECTION` — Exclusive connection bonus: {1_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_GPT_THEIRS` — {1_CityName} Gold per turn: {2_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_GPT_YOURS` — {1_CityName} Gold per turn: {2_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_OTHER_TRAIT` — From {1_CivAdj} trait: {2_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_POLICIES` — Bonus from Social Policies: {1_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_RESOURCE_DIFFERENT` — {1_ResourceIcon} {2_ResourceName:textkey}: {3_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_RESOURCE_HEADER` — Different resources  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_RIVER_MODIFIER` — Next to River: +{1_Num}%  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_THEIR_REVENUE` — THEIR REVENUE  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_THEIR_SCIENCE_GAIN` — THEIR SCIENCE GAIN  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_THEIR_SCIENCE_TOTAL` — {1_CivName} Total: {2_Num} [ICON_RESEARCH] Science  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_TOTAL` — Total: {1_Num} [ICON_GOLD] Gold  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_TRADEE_TOTAL` — {1_CivName} Total: {2_Num} [ICON_GOLD] Gold  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_YOUR_REVENUE` — YOUR REVENUE  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_YOUR_SCIENCE_GAIN` — YOUR SCIENCE GAIN  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_TT_YOUR_SCIENCE_TOTAL` — Total: {1_Num} [ICON_RESEARCH] Science  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_TITLE` — Establish Trade Route  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_FRIENDLY` — Greetings great leader. What brings you to our court today?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_HOSTILE` — What business do you have here?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_IRRATIONAL` — Ahhh, it's you again... excellent.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_NEUTRAL` — Hello again. What are you here to discuss?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_PROTECTED` — Your continued protection is a great comfort to us.  What can we do for you?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_CITY_STATE_DIPLO_HELLO_QUEST_MESSAGE` — Good, our couriers reached you in time.  We have a new quest that may be of interest to you.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_CITY_STATE_DIPLO_HELLO_WAR` — We hope that you have come to end this conflict.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CITY_STATE_DIPLO_HELLO_WARMONGER` — We have no business with bloodthirsty tyrants such as yourself. Begone.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CITY_STATE_DIPLO_JUST_BULLIED` — It appears we have no choice.  Take your gold, just don't hurt us.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_CITY_STATE_DIPLO_JUST_BULLIED_WORKER` — What?  How dare you!  One day you will pay for this.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_CITY_STATE_DIPLO_JUST_SUPPORTED` — Ah, just what we've been looking for.  Thank you for your support.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_CITY_STATE_DIPLO_PEACE_JUST_MADE` — We are glad to see the return of peace.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CIV5_POLICY_CULTURALDIPLOMACY_HEADING` — Cultural Diplomacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CONCEPT_DIPLOMACY_EMBASSY_ADVISOR_QUESTION` — How do I establish an Embassy?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_DIPLOMACY_EMBASSY_DESCRIPTION` — {TXT_KEY_CONCEPT_DIPLOMACY_EMBASSY_TOPIC}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_DIPLOMACY_EMBASSY_TOPIC` — Establishing Embassies  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_DEAL_COUNTER_BY_THEM` — {1_Player} has made you a counter-offer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_COUNTER_BY_YOU` — You have made a counter-offer to {1_Player}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_COUNTER_RECIEVED` — Counter-Offer Received  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_COUNTER_SENT` — Counter-Offer Proposed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_EXPIRED` — Deal Is No Longer Valid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_EXPIRED_FROM_THEM` — Your offer to {1_Player} is no longer valid.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_EXPIRED_FROM_YOU` — Your offer from {1_Player} is no longer valid.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_OFFERED` — Deal Proposed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_OFFERED_BY_THEM` — {1_Player} has offered you a deal  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_OFFERED_BY_YOU` — You have made a proposal to {1_Player}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_REJECTED` — Offer Rejected  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_REJECTED_BY_THEM` — Your offer to {1_Player} has been rejected  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_REJECTED_BY_YOU` — You have rejected the offer from {1_Player}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_WITHDRAWN` — Offer Withdrawn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_WITHDRAWN_BY_THEM` — The offer from {1_Player} has been withdrawn  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DEAL_WITHDRAWN_BY_YOU` — You have withdrawn your offer to {1_Player}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DECLARE_WAR_ALLIES_HEADER` — Allied City-States  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_DECLARE_WAR_DEALS_HEADER` — Deals with {1_CivName}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_DECLARE_WAR_TRADE_ROUTES_HEADER` — Trade Routes  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_DIPLOMACY_ADV_QUEST` — How does diplomacy work?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_ANYTHING_ELSE` — Anything else?  
  source: `Gameplay/XML/NewText/EN_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_DIPLOMACY_DECLAREWAR_ADV_QUEST` — How can you declare war during diplomacy?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DECLAREWAR_HEADING3_BODY` — Click on this button to declare war with the civilization.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DECLAREWAR_HEADING3_TITLE` — Declare War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DECLARINGWAR_ADV_QUEST` — How can you declare war on a civilization or city-state?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DECLARINGWAR_HEADING2_TITLE` — Declaring War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DEFENSIVEPACT_ADV_QUEST` — How does a defensive pact work?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DEFENSIVEPACT_HEADING3_TITLE` — Defensive Pact  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DEMAND_ADV_QUEST` — Can you make demands of other civilizations?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DEMAND_HEADING3_TITLE` — Demand  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DISCUSS_ADV_QUEST` — How can I make informal requests to other civilizations?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DISCUSS_HEADING3_TITLE` — Discuss  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_DISCUSS_WHAT` — What would you like to discuss?  
  source: `Gameplay/XML/NewText/EN_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_DIPLOMACY_EXIT_ADV_QUEST` — How can I leave the diplomacy screen?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_EXIT_HEADING3_BODY` — Press this to exit diplomacy with the leader.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_EXIT_HEADING3_TITLE` — Exit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_HEADING1_TITLE` — Diplomacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_INITIATING_ADV_QUEST` — How can you initiate diplomacy?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_INITIATING_HEADING2_TITLE` — Initiating Diplomacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_NEGOTIATEPEACE_ADV_QUEST` — How can you negotiate peace with a civilization or city state?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_NEGOTIATEPEACE_HEADING2_TITLE` — Negotiating Peace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_NEGOTIATING_ADV_QUEST` — How do you conduct diplomacy with city-states?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_NEGOTIATING_HEADING2_TITLE` — Negotiating With City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_OPENBORDERS_ADV_QUEST` — How does the open borders agreement work?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_OPENBORDERS_HEADING3_TITLE` — Open Borders Agreement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_OTHERPLAYERS_ADV_QUEST` — Can you ask another civilization to declare war or offer peace to another civilization?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_OTHERPLAYERS_HEADING3_TITLE` — Other Players  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_OVERVIEW` — Diplomacy Overview  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_DIPLOMACY_PEACE_ADV_QUEST` — When can you negotiate peace with a civilization?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_PEACE_HEADING3_BODY` — If you're at war with the civ, you can discuss peace.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_PEACE_HEADING3_TITLE` — Negotiate Peace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_RESEARCHAGREE_ADV_QUEST` — How do research agreements work?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_RESEARCHAGREE_HEADING3_TITLE` — Research Agreements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_RESOURCES_HEADING3_ADV_QUEST` — Can you trade resources with another civilization?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_RESOURCES_HEADING3_TITLE` — Resources and Diplomacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_TRADECITIES_ADV_QUEST` — Can you trade cities with other civilizations?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_TRADECITIES_HEADING3_TITLE` — Trading Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_TRADESCREEN_ADV_QUEST` — How does the trade screen work?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_TRADESCREEN_HEADING2_TITLE` — The Trade Screen  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_TRADE_ADV_QUEST` — What does trade mean in diplomacy?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_TRADE_HEADING3_BODY` — You can negotiate a trade deal with the civilization. Clicking on this button will bring up the Trade Screen.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_TRADE_HEADING3_TITLE` — Trade  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_WHOCANCONDUCT_ADV_QUEST` — Who can conduct diplomacy?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_WHOCANCONDUCT_HEADING2_TITLE` — Who Can Conduct Diplomacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_WITHCIVS_ADV_QUEST` — What are the diplomatic options when dealing with a civilization?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLOMACY_WITHCIVS_HEADING2_TITLE` — Diplomacy With Civilizations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_DIPLO_ADDITIONAL` — Additional Information  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_ADOPTING_HIS_RELIGION` — [COLOR_POSITIVE_TEXT]You have adopted their religion in the majority of your cities.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_ADOPTING_MY_RELIGION` — [COLOR_POSITIVE_TEXT]They have happily adopted your religion in the majority of their cities.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_AFRAID` — They fear our great might!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_ALLOW_EMBASSY` — ACCEPT EMBASSY  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_ALLOW_EMBASSY_TT` — Allows Open Border and Defensive Pacts. Also allows you to see the location of the other player's Capital.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_ALREADY_AT_WAR` — These players are already at war.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_ASSISTANCE_FROM_THEM` — [COLOR_NEGATIVE_TEXT]You asked them for help and they provided it.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_ASSISTANCE_TO_THEM` — [COLOR_POSITIVE_TEXT]They asked for help and you provided it.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_AT_WAR` — [COLOR_NEGATIVE_TEXT]You are at war![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_BORDER_PROMISE` — [COLOR_NEGATIVE_TEXT]You made a promise to stop buying land near them, and then broke it![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CAPTURED_CAPITAL` — [COLOR_NEGATIVE_TEXT]You captured their original capital.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CAUGHT_STEALING` — [COLOR_NEGATIVE_TEXT]Your spies were caught trying to steal technology.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_CITIES` — CITIES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_CITIES_LIBERATED` — [COLOR_POSITIVE_TEXT]You have liberated some of their people![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CITY_STATE_PROMISE` — [COLOR_NEGATIVE_TEXT]You made a promise to stop attacking a City-State friendly to them, and then broke it![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CIVILIANS_RETURNED` — [COLOR_POSITIVE_TEXT]You freed their captured citizens![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CIVILIZATION_NAME` — Civilization Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_COMMON_FOE` — [COLOR_POSITIVE_TEXT]We fought together against a common foe.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CSTATE_GIVE_UNIT_TT` — Give this City-State a Unit.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_CSTATE_SPEAK_WITH` — Speak with a City-State.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_CULTURE_BOMB` — [COLOR_NEGATIVE_TEXT]You stole their territory with a Great General![ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CURRENT_GOLD` — Player has {1_Num} [ICON_GOLD] Gold not included in this deal.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_CURRENT_GPT` — Player has {1_Num} [ICON_GOLD] Gold Per Turn not included in this deal.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DECLARES_WAR_TT` — Declares war on this player!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DECLARE_WAR` — DECLARE WAR  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DECLARE_WAR_ON` — DECLARE WAR ON  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DEFAULT_STATUS` — There haven't been any major incidents which have shaped your relationship.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DEF_PACT` — DEFENSIVE PACT  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_CAUGHT_DECLARE_WAR` — Declare war on {1_LeaderName}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_CAUGHT_DEMAND_STOP_SPYING` — We demand that you cease spying on us.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_CAUGHT_FORGIVE_SPYING` — We have decided to let your transgression slide this time.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_CHANGED_MIND` — Sorry, I've changed my mind.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_CLAIM_WHAT_WE_WANT` — We'll claim whatever lands we like.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_COOP_WAR_SOON` — Give us 10 turns to prepare.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_DONT_CARE` — I don't care what you think.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_DONT_FORGIVE_SPYING` — I cannot forgive this offense.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_DONT_STOP_CONVERSIONS` — Our missionaries and prophets go where they please.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_DONT_STOP_DIGGING` — I'll dig wherever I want.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_DIPLO_DISCUSS_DO_WHAT_WE_CAN` — Yes, let us do what we can.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_FORGIVE_SPYING` — I forgive you.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_HOW_DARE_YOU` — How dare you?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MAKE_US` — If you want us to leave you'll have to make us.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_DEAL` — Get over it.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_DECLARE_WAR` — Shall we declare war against...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_DONT_SETTLE` — Don't settle new Cities near us.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_END_WORK_WITH_US` — I'm done working with you.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_SHARE_INTRIGUE` — Share intrigue with {1_LeaderName}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_SHARE_INTRIGUE_TT` — Share pieces of intrigue with {1_LeaderName} that your spies have gathered.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_SORRY` — We're sorry this has caused a divide between us.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_STOP_DIGGING` — Stop digging up my artifacts.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_STOP_SPREADING_RELIGION` — Stop sending missionaries and prophets to my cities.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_STOP_SPYING` — Stop spying on me.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_WORK_AGAINST` — Will you form a Pact of Secrecy against...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_WORK_WITH_US` — Do you want to form a Pact of Cooperation?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_WORK_WITH_US_TT` — A Pact of Cooperation will improve relations with this leader.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_MESSAGE_YOULL_PAY` — You'll pay for this in time.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_OFFER_TO_APPEASE` — Perhaps we can offer you something to keep this from getting out of hand.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_SETTLE_WHAT_WE_PLEASE` — We'll settle what lands we please.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_BULLYING` — Our apologies.  We will leave them alone.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_CLAIMING` — Our apologies, we'll refrain from claiming land near you in the future.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_SETTLING` — Our apologies, we'll refrain from settling near you in the future.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_SPY_CAUGHT` — I swear not to spy on you any more.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_SORRY_FOR_SPY_KILLED` — I swear not to spy on you any more.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_SORRY_OTHER_PLANS` — Sorry, we have other plans.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_STOP_CONVERSIONS` — We will send our missionaries and prophets into other realms.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_DISCUSS_STOP_DIGGING` — We meant no offense when attempting to steal your cultural heritage.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/LeaderDialog/Civ5_Dialog__GENERIC.xml`
- `TXT_KEY_DIPLO_DISCUSS_TIME_TO_DIE` — You're right to worry, and it's time for you to die. (DECLARE WAR)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_WILL_WITHDRAW` — Our apologies. We will withdraw immediately.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISCUSS_YOU_WILL_PAY` — You will pay for this.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISLIKED_OUR_PROPOSAL` — [COLOR_WARNING_TEXT]They disliked our proposal to the World Congress.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_DISUCSS_ATTACK_LEADER` — I'm considering attacking this leader.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISUCSS_DISLIKE_LEADER` — I dislike this leader.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISUCSS_LIKE_LEADER` — I like this leader.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISUCSS_OFFER_TO_STOP` — Perhaps we can offer you something to keep this from getting out of hand.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISUCSS_OPINION_OF_LEADER` — What do you think of this leader?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DISUCSS_STAY_AWAY` — If you're smart, you'll stay away from me.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_DOF` — [COLOR_POSITIVE_TEXT]We have made a public Declaration of Friendship![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_EMBARGO` — EMBARGO  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_EMBARGO_AGAINST` — EMBARGO AGAINST  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_END_CONFLICT` — What deal will end this conflict?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_EXPANSION_PROMISE` — [COLOR_NEGATIVE_TEXT]You made a promise to stop expanding near them, and then broke it![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_FOILED_THEIR_PROPOSAL` — [COLOR_WARNING_TEXT]We helped their proposal fail in the World Congress.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_FORCE_PEACE` — A peace treaty prevents these players from going to war for a period of time.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_FORGAVE_FOR_SPYING` — [COLOR_POSITIVE_TEXT]You forgave them for spying.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_FRIENDLY` — [COLOR_POSITIVE_TEXT]They desire friendly relations with our empire.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_GOLD` — [ICON_GOLD] GOLD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_GOLD_PER_TURN` — [ICON_GOLD] GOLD PER TURN  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_GUARDED` — [COLOR_NEGATIVE_TEXT]They suspect we might be a threat to them.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HAS_EMBASSY` — [COLOR_POSITIVE_TEXT]They have an embassy in your capital.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_HERE_OFFER` — Let's hear your offer...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HOSTILE` — [COLOR_NEGATIVE_TEXT]They don't want anything to do with us right now.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HUMAN_DOF_WITH_ENEMY` — [COLOR_NEGATIVE_TEXT]You have made a Declaration of Friendship with one of their enemies![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_HUMAN_FRIEND_DECLARED_WAR` — [COLOR_NEGATIVE_TEXT]We made a Declarations of Friendship and then declared war on them![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_IRON_LABEL_PH` — [ICON_RES_IRON] IRON  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_ITEMS_LABEL` — {1_PlayerName} Items  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_ITEMS_LUXURY_RESOURCES` — LUXURY RESOURCES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_ITEMS_OTHER_PLAYERS` — OTHER PLAYERS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_ITEMS_STRATEGIC_RESOURCES` — STRATEGIC RESOURCES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_LANDMARKS_BUILT` — [COLOR_POSITIVE_TEXT]You built a Landmark in their territory.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_LAND_DISPUTE` — [COLOR_NEGATIVE_TEXT]They covet lands that you currently own![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_LEADER_NAME` — Leader Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_LEADER_SAYS` — {1_LeaderName} says:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_LIBERATED_CAPITAL` — [COLOR_POSITIVE_TEXT]You liberated their capital.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_LIBERATED_CITY` — [COLOR_POSITIVE_TEXT]You liberated one of their cities.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_LIKED_OUR_PROPOSAL` — [COLOR_POSITIVE_TEXT]They liked our proposal to the World Congress.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_LUXURY_RESOURCES` — LUXURY RESOURCES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID` — AFRAID  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY` — FRIENDLY  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED` — GUARDED  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE` — HOSTILE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED` — RECALLED TO LIFE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL` — NEUTRAL  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR` — [COLOR_WARNING_TEXT]WAR![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MAKE_DEAL_WORK` — What will make this deal work?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MAKE_PEACE` — MAKE PEACE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MAKE_PEACE_WITH` — MAKE PEACE WITH  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MILITARY_PROMISE` — [COLOR_NEGATIVE_TEXT]You made a promise to move your troops from their borders, and then broke it![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MODIFY` — MODIFY  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MODIFY_DEAL` — Modify Deal  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MUTUAL_DOF` — [COLOR_POSITIVE_TEXT]We have made Declarations of Friendship with the same leaders![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MUTUAL_ENEMY` — [COLOR_POSITIVE_TEXT]We have Denounced the same leaders![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_MY_INFO` — Your Information:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MY_SCORE` — Your Score  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MY_SCORE_CITIES` — {1_Num} from Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MY_SCORE_FUTURE_TECH` — {1_Num} from Future Technology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MY_SCORE_GREAT_WORKS` — {1_Num} from Great Works  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_DIPLO_MY_SCORE_LAND` — {1_Num} from Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MY_SCORE_POLICIES` — {1_Num} from Policies  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_DIPLO_MY_SCORE_POPULATION` — {1_Num} from Population  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MY_SCORE_RELIGION` — {1_Num} from Religion  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_DIPLO_MY_SCORE_TECH` — {1_Num} from Technology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_MY_SCORE_WONDERS` — {1_Num} from Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_NAME` — Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_NEGOTIATE_PEACE` — Negotiate Peace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_NEGOTIATE_PEACE_BLOCKED_TT` — You cannot negotiate peace with this player for another {1_Num} turn(s) because of a deal you made with another player.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_NEGOTIATE_PEACE_TT` — Negotiate peace with this player.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_NUKED` — [COLOR_NEGATIVE_TEXT]You nuked them![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_NUM_CSTATE_MET` — Met {1_Num} City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_OPEN_ADVISORS_TT` — Ask your advisors about the current situation.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_OPEN_BORDERS` — OPEN BORDERS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_OPEN_SOCIAL_POLICY_TT` — Your Social Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_OTHER_PLAYERS` — OTHER PLAYERS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_OTHER_PLAYERS_OPEN` — Deal options relating to third party players.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_PAID_TRIBUTE` — [COLOR_NEGATIVE_TEXT]You forced them to pay tribute.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_PAST_WAR_BAD` — [COLOR_NEGATIVE_TEXT]You have gone to war in the past.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_PAST_WAR_NEUTRAL` — You have been at war in the past, but they do not seem to hold a grudge.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_PEACE_TREATY` — PEACE TREATY ({1_Turns} turns)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_PEACE_TREATY_TURNS` — PEACE TREATY ({1_Turns} turns)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_PLUNDERING_OUR_TRADE_ROUTES` — [COLOR_NEGATIVE_TEXT]You plundered their trade routes![ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_PROPOSE` — PROPOSE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_RECKLESS_EXPANDER` — [COLOR_NEGATIVE_TEXT]They believe we are building new cities too aggressively![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_REFUSE` — REFUSE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_REFUSED_REQUESTS` — [COLOR_NEGATIVE_TEXT]You refused a request made by this player after making a Declaration of Friendship![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_RELATION_EMBASSY_SHARED` — SHARED EMBASSIES  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_RELATION_EMBASSY_THEIR` — EMBASSY IN THEIR CAPITAL  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_RELATION_EMBASSY_YOUR` — EMBASSY IN YOUR CAPITAL  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_SHARED` — SHARED OPEN BORDERS  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_THEIR` — THEIR BORDERS ARE OPEN TO YOU  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_YOUR` — YOUR BORDERS ARE OPEN TO THEM  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_REQUEST_INCOMING` — A diplomatic proposal from this civilization that is waiting for your response.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DIPLO_REQUEST_OUTGOING` — This civilization has not yet responded to your diplomatic proposal.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DIPLO_RESCH_AGREEMENT` — RESEARCH AGREEMENT  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_RESCH_AGREEMENT_US` — RESEARCH AGREEMENT ({1_Num}[ICON_GOLD])  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_RESURRECTED` — [COLOR_POSITIVE_TEXT]You restored their civilization after they were annihilated![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_SAME_LATE_POLICY_TREES` — [COLOR_POSITIVE_TEXT]You have both chosen to adopt the {1_PolicyTree} policies.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_SHARED_INTRIGUE` — [COLOR_POSITIVE_TEXT]You have shared intrigue your spies uncovered with them.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_SPEAK_TO` — Choose a leader to speak with...  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_STATUS` — Diplo Status  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_STATUS_TT` — {1_cityName} is currently {2_statusType} : {3_curNumber} / {4_maxNumber} [ICON_INFLUENCE]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DIPLO_STOP_SPYING_ASKED` — [COLOR_NEGATIVE_TEXT]You asked them to not spy on you.[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Inherited_Expansion2.xml`
- `TXT_KEY_DIPLO_STRATEGIC_RESOURCES` — STRATEGIC RESOURCES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_SUPPORTED_THEIR_HOSTING` — [COLOR_POSITIVE_TEXT]We helped relocate the World Congress to their lands.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_SUPPORTED_THEIR_PROPOSAL` — [COLOR_POSITIVE_TEXT]We helped them pass their proposal in the World Congress.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_TO_ALL` — To All:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_TO_PLAYER` — To {1_player}:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_TO_TEAM` — To Team:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_TO_TRADE_CITY_TT` — Trade a city.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_TRADE_AGREEMENT` — TRADE AGREEMENT  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_TRADE_AGREEMENT_TT` — Provides a small bonus to Gold income for both civilizations (20 turns).  Costs each player 250 [ICON_GOLD].  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_TRADE_DEMAND` — [COLOR_NEGATIVE_TEXT]You made a trade demand of them![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_TRADE_PARTNER` — [COLOR_POSITIVE_TEXT]We've traded recently.[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_TURNS` — {1_num} Turns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_VOTE` — UN VOTE  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_VOTE_TT` — You must vote in the United Nations!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DIPLO_WARMONGER_THREAT` — [COLOR_NEGATIVE_TEXT]They believe you are a warmongering menace to the world![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_WARMONGER_THREAT_CRITICAL` — [COLOR_NEGATIVE_TEXT]They fear your warmongering will soon sink the world into a new Dark Age!”[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_WARMONGER_THREAT_MAJOR` — [COLOR_NEGATIVE_TEXT]They clearly see the potential threat posed by your warmongering.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_WARMONGER_THREAT_SEVERE` — [COLOR_NEGATIVE_TEXT]They believe your warmongering has become an issue of global prominence.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_DIPLO_WHAT_GIVE_FOR_THIS` — What will you give me for this?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_WHAT_WANT` — What do you want?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_WHAT_WANT_FOR_THIS` — What do you want for this?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_WITHDRAW` — WITHDRAW  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_WONDER_DISPUTE` — [COLOR_NEGATIVE_TEXT]You built wonders that they coveted![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DIPLO_YOUR_ITEMS_LABEL` — YOUR Items  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_DO_DEAL_BEGAN` — Deal Began On Turn {1_turn}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DO_DEAL_DURATION` — Deal Duration: {1_turn} Turns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DO_DEAL_LASTED` — Deal Lasted For {1_turn} Turns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_DO_DIPLO_LOG` — Diplomatic History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_GOAL_TUTORIAL_5_TRADE_WITH_MAJOR` — Receive marble from a trade with a major civ.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_5_TRADE_WITH_MAJOR_COMPLETE` — Receive marble from a trade with a major civ. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOLD_DIPLOMACY_ADV_QUEST` — How can you gain gold through diplomacy?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_DIPLOMACY_HEADING3_BODY` — You may gain gold - lump sum or an amount each turn for 30 turns - during negotiations with another civ.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_DIPLOMACY_HEADING3_TITLE` — Gold Trading  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_EXPENDING_DIPLOMACY_ADV_QUEST` — How can I use gold in diplomacy?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_EXPENDING_DIPLOMACY_HEADING3_TITLE` — Diplomacy and Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_TRADE_ROUTES_BLOCKADE_HEADING4_TITLE` — Blockade  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_TRADE_ROUTES_HEADING3_TITLE` — City Connections  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_LEAGUE_SPLASH_MESSAGE_ERA_DIPLO_VICTORY_POSSIBLE` — [ICON_BULLET][COLOR_POSITIVE_TEXT]World Leader[ENDCOLOR] proposal on alternating sessions  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_SCRAMBLE_AFRICA_DIPLO_MY_SCORE_SCENARIO1` — {1_Num} for Longest Rail connection between cities  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_DIPLO_MY_SCORE_SCENARIO2` — {1_Num} for Natural Wonder/Artifact discovery  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_DIPLO_MY_SCORE_SCENARIO3` — {1_Num} for Lifetime [ICON_GOLD] Gold earned  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_DIPLO_MY_SCORE_SCENARIO4` — {1_Num} for Lifetime [ICON_CULTURE] Culture earned  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_DIPLO_MY_SCORE_WONDERS` — {1_Num} from Suez Canal  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SPECIFIC_DIPLO_STRING_1` — [COLOR_NEGATIVE_TEXT]Your lands belong to me.[ENDCOLOR]  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_TECH_TRADE_HEADING4_BODY` — {TXT_KEY_DIPLOMACY_RESEARCHAGREE_HEADING3_BODY}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_TRADE_HEADING4_TITLE` — Trade  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TRADE_BOOST_HEADING2_TITLE` — Bonus Income from Buildings  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRADE_CARAVAN_HEADING2_TITLE` — Caravans  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRADE_CARGO_HEADING2_TITLE` — Cargo Ships  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRADE_EXTENDING_HEADING2_TITLE` — Extending Trade Route Range  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRADE_PILLAGE_HEADING2_TITLE` — Pillaging a Trade Route  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRADE_RELIGION_HEADING2_TITLE` — Trade Routes and Religion  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRADE_ROUTES_HEADING2_TITLE` — Trade Routes  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRADE_ROUTE_TT_PLOT_CARAVAN` — {1_CivAdj} Caravan  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRADE_ROUTE_TT_PLOT_CARGO_SHIP` — {1_CivAdj} Cargo Ship  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRADE_ROUTE_TT_PLOT_MAJOR_MAJOR` — {1_CityName} ({2_CivName}) [ICON_TURNS_REMAINING] {3_CityName} ({4_CivName})  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRADE_SCIENCE_HEADING2_TITLE` — Trade Routes and Science  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRADE_WAR_HEADING2_TITLE` — Impact of War  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_TRAIT_DIPLOMACY_GREAT_PEOPLE_SHORT` — Nobel Prize  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Traits_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Traits_Inherited_Expansion2.xml`
- `TXT_KEY_TRAIT_GUNBOAT_DIPLOMACY_SHORT` — Gunboat Diplomacy  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_VP_DIPLO_CAPITALS_ACTIVE_PLAYER_LEADING` — You are leading by controlling {1_num} original [ICON_CAPITAL] Capitals.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_CAPITALS_PLAYER_LEADING` — {1_player} controls {2_num} original [ICON_CAPITAL] Capitals.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_CAPITALS_TEAM_LEADING` — Team {1_Team} controls {2_num} original [ICON_CAPITAL] Capitals.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_CAPITALS_UNMET_PLAYER_LEADING` — An unmet player controls {1_num} original [ICON_CAPITAL] Capitals.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_CIV_RANK` — Civilization Rank  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_CS_VOTES_COL_TT_ALT` — Current number of City-State allies.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_CS_VOTES_TT_ALT` — {@1_CivName} is currently allies with:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_DELEGATES_CONTROLLED` — Delegates you Control:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_DELEGATES_IN_WORLD` — Total Delegates Available:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_DELEGATES_NEEDED` — Delegates to win World Leader proposal:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_DETAILS` — Details  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_LIBERATED_CIV_COL_TT_ALT` — In the previous election, which Civilization was voted for.  (Cannot vote for self.)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_LIBERATED_CIV_TITLE` — Liberated [ICON_CAPITAL]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_LIBERATED_CIV_TITLE_ALT` — Last Vote  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_LIBERATED_TITLE` — Liberated  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_LIBERATED_VOTES_COL_TT_ALT` — Current number of City-States liberated.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_LIBERATED_VOTES_TT_ALT` — {@1_CivName} has most recently liberated:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_MY_VOTES` — Votes for You:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_MY_VOTES_ALT` — Projected Votes for You:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_MY_VOTES_TITLE` — Total Votes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_MY_VOTES_TITLE_ALT` — Projected Votes  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_MY_VOTES_TT_SUMMARY_ALT` — {@1_CivName} has a projected {2_NumProjectedVotes} votes.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_MY_VOTES_TT_UN_ALT` — {@1_CivName} gets 1 vote from building the UN.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_NEW_CAPITALS_REMAINING` — All players are still in control of their original [ICON_CAPITAL] Capitals.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_PROJECT_BUILT_BY` — {1_player} has completed the United Nations.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_PROJECT_PLAYERS_COMPLETE` — {1_NumPlayers} {1_NumPlayers : plural 1?Player has; other?Players have;} completed the {2_apolloProgram}.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_SELF_VOTES_COL_TT_ALT` — In the previous election, the number of votes received from other Civilizations.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_SELF_VOTES_TITLE` — Self Votes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_SELF_VOTES_TITLE_ALT` — Civilizations  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_SELF_VOTES_TT_ALT` — In the last UN election, {@1_CivName} received votes from the Civilizations that had the best relations with them:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_SOCIAL_POLICIES` — {1_player} has completed {2_completedNum} of {3_totalNum} Social Policy Branches.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_SOMEONE_WON` — {1_CivName} has been elected World Leader.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_SUBTITLE_ALT` — Projected Outcome of the next UN Election:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_OTHER_PLAYER_CAPITAL` — {1_PlayerName} controls {2_CityName}, the original [ICON_CAPITAL] Capital of {3_CivName}.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_UNMET_PLAYER_CAPITAL` — {1_PlayerName} controls the original [ICON_CAPITAL] Capital of an unmet civilization.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_OTHER_PLAYER_CONTROLS_YOUR_CAPITAL` — {1_PlayerName} controls {2_CityName}, your original [ICON_CAPITAL] Capital.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_SOMEONE_CONTROLS_THEIR_CAPITAL` — {1_PlayerName} controls {2_CityName}, their original [ICON_CAPITAL] Capital.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_UNMET_CONTROLS_THEIR_CAPITAL` — An unmet civilization controls their original [ICON_CAPITAL] Capital.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_UNMET_PLAYER_CONTROLS_OTHER_PLAYER_CAPITAL` — An unmet player controls {1_CityName}, the original [ICON_CAPITAL] Capital of {2_CivName}.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_UNMET_PLAYER_CONTROLS_UNMET_PLAYER_CAPITAL` — An unmet player controls the original [ICON_CAPITAL] Capital of another unmet civilization.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_YOU_CONTROL_OTHER_PLAYER_CAPITAL` — You control {1_CityName}, the original [ICON_CAPITAL] Capital of {2_CivName}.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TT_YOU_CONTROL_YOUR_CAPITAL` — You control {1_CityName}, your original [ICON_CAPITAL] Capital.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_TURNS_UNTIL_SESSION` — Turns until next World Leader proposal:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_UN_ACTIVE` — The United Nations is active, and Victory is possible.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_UN_INACTIVE` — The United Nations has not yet begun.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_VP_DIPLO_VICTORY_DISABLED` — Diplomatic Victory is disabled.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_VOTES` — Total Available Diplomatic Votes:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_DIPLO_VOTES_NEEDED` — Votes Needed for Diplomatic Victory:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`

## Tech tree (9)

- `TXT_KEY_ADVISOR_RESEARCH_COURTHOUSE_DISPLAY` — Occupied City is Unhappy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_TECH_TREE_DISPLAY` — Tech Tree  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CHOOSE_RESEARCH_TT` — You may select a new research project for your empire!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_OPEN_TECH_TREE` — Open Technology Tree  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_PEDIA_RESEARCH_LABEL` — Research  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_TECH_CHANGERESEARCH_HEADING3_TITLE` — Changing Research  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_CHOOSERESEARCH_HEADING3_TITLE` — The Choose Research Menu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_TECHTREE_ADV_QUEST` — What is this technology tree thing?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_TECHTREE_HEADING2_TITLE` — The Mighty Technology Tree  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`

## Civics / policies / religion (131)

- `TXT_KEY_ADVISOR_CHOOSE_IDEOLOGY_DISPLAY` — A Brave New World!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_RELIGION_FOUND_PANTHEON_DISPLAY` — Choose a Pantheon!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_RELIGION_FOUND_RELIGION_DISPLAY` — You can found a Religion!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_RELIGION_OVERVIEW_DISPLAY` — This is the Religion overview!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_SCREEN_SOCIAL_POLICY_DISPLAY` — Social Policy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CHOOSE_IDEOLOGY_OPTIONS` — Choose one of these Ideologies:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_IDEOLOGY_TITLE` — Ideology Selection  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_POLICY_TT` — You may adopt a new Social Policy!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CHOOSE_RELIGION_NAME_LABEL` — {1_ReligionName} [COLOR_GREEN](Click to customize name)[ENDCOLOR]  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CHOOSE_RELIGION_TITLE` — Found a Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CHOOSE_RELIGION_TITLE_ENHANCE` — Enhance a Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_POLICY_AESTHETICS_HEADING` — Aesthetics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_ARISTOCRACY_HEADING` — Aristocracy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_AUTOCRACY_HEADING` — Autocracy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_CITIZENSHIP_HEADING` — Citizenship  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_CIVILSOCIETY_HEADING` — Civil Society  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_COLLECTIVERULE_HEADING` — Collective Rule  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_COMMERCE_HEADING` — Commerce  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_COMMUNISM_HEADING` — Communism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_CONSTITUTION_HEADING` — Constitution  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_DEMOCRACY_HEADING` — Democracy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_DEPOTISM_HEADING` — Depotism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_DISCIPLINE_HEADING` — Discipline  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_EDUCATEDELITE_HEADING` — Educated Elite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_FASCISM_HEADING` — Fascism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_FREEDOM_HEADING` — Freedom  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_FREERELIGION_HEADING` — Free Religion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_FREESPEECH_HEADING` — Free Speech  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_FREETHOUGHT_HEADING` — Free Thought  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_HUMANISM_HEADING` — Humanism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_LANDEDELITE_HEADING` — Landed Elite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_LEGALISM_HEADING` — Legalism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_LIBERTY_HEADING` — Liberty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_MANDATEOFHEAVEN_HEADING` — Mandate of Heaven  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_MERCANTILISM_HEADING` — Mercantilism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_MERCHANTNAVY_HEADING` — Merchant Navy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_MERITOCRACY_HEADING` — Meritocracy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_MILITARISM_HEADING` — Militarism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_MILITARYCASTE_HEADING` — Military Caste  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_MILITARYTRADITION_HEADING` — Military Tradition  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_MONARCHY_HEADING` — Monarchy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_NATIONALISM_HEADING` — Nationalism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_NAVALTRADITION_HEADING` — Naval Tradition  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_OLIGARCHY_HEADING` — Oligarchy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_ORDER_HEADING` — Order  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_ORGANIZEDRELIGION_HEADING` — Organized Religion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_PATRONAGE_HEADING` — Patronage  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_PHILANTHROPY_HEADING` — Philanthropy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_PIETY_HEADING` — Piety  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_POLICESTATE_HEADING` — Police State  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_POPULISM_HEADING` — Populism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_PROFESSIONALARMY_HEADING` — Professional Army  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_PROTECTIONISM_HEADING` — Protectionism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_RATIONALISM_HEADING` — Rationalism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_REFORMATION_HEADING` — Reformation  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_REPRESENTATION_HEADING` — Representation  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_REPUBLIC_HEADING` — Republic  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_SCHOLASTICISM_HEADING` — Scholasticism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_SCIENTIFICREVOLUTION_HEADING` — Scientific Revolution  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_SECULARISM_HEADING` — Secularism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_SLAVERY_HEADING` — Slavery  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_SOCIALISM_HEADING` — Socialism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_SOVEREIGNTY_HEADING` — Sovereignty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_THEOCRACY_HEADING` — Theocracy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_TOTALWAR_HEADING` — Total War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_TRADEUNIONS_HEADING` — Trade Unions  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_TRADITION_HEADING` — Tradition  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_UNITEDFRONT_HEADING` — United Front  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_UNIVERSALSUFFRAGE_HEADING` — Universal Suffrage  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLICY_WARRIORCODE_HEADING` — Warrior Code  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CONCEPT_CITY_STATE_SPREAD_RELIGION_ADVISOR_QUESTION` — Is there a benefit to spreading my Religion to a City-State?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_BELIEFS_ADVISOR_QUESTION` — What are Beliefs?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_BUILDINGS_ADVISOR_QUESTION` — Do buildings play a role with Religion?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_DEFENDING_ADVISOR_QUESTION` — How do I defend against a Religion?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_ENHANCER_ADVISOR_QUESTION` — What are Enhancer Beliefs?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_ENHANCING_RELIGION_ADVISOR_QUESTION` — How do I enhance my Religion?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_FAITH_EARNING_ADVISOR_QUESTION` — How can I earn Faith?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_FAITH_SPENDING_ADVISOR_QUESTION` — What can I do with Faith?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_FOLLOWER_ADVISOR_QUESTION` — What are Follower Beliefs?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_FOUNDER_ADVISOR_QUESTION` — What are Founder Beliefs?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_FOUNDING_RELIGION_ADVISOR_QUESTION` — How do I found a Religion?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_MAJORITY_ADVISOR_QUESTION` — How does a Religion become the Majority Religion?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_PANTHEONS_ADVISOR_QUESTION` — What is a Pantheon?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_PANTHEON_BELIEFS_ADVISOR_QUESTION` — What are Pantheon Beliefs?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_SPREADING_RELIGION_ADVISOR_QUESTION` — How does Religion spread?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_RELIGION_UNITS_ADVISOR_QUESTION` — Do units play a role in Religion?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CO_OPINION_TT_INFLUENCED_WORLD_IDEOLOGY` — Influenced by the World Ideology as chosen by the World Congress:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_VICTORY_IDEOLOGY_HEADER` — IDEOLOGY  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_VICTORY_IDEOLOGY_HEADER_TT` — Ideology chosen by this Civilization  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CULTURE_ACQUIRESOCIALPOLICY_HEADING2_TITLE` — Acquiring Social Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_EO_SPY_COUNTER_INTEL_POLICY_TT` — {1_Num}% increased chance of killing enemy spies due to Police State policy.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_FREE_POLICIES_LABEL` — # of Free Policies: {1_Num}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_NEXT_POLICY_COST_LABEL` — Next Policy Cost: {1_Num} [ICON_CULTURE]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_OPSCREEN_SHOW_ALL_POLICY_INFO_TT` — All Policies will be displayed in the Social Policy Screen, regardless of Era and what branches have been unlocked.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_BELIEFS_CATEGORY_1` — Religions  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_BELIEFS_CATEGORY_2` — Pantheon Beliefs  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_BELIEFS_CATEGORY_3` — Founder Beliefs  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_BELIEFS_CATEGORY_4` — Follower Beliefs  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_BELIEFS_CATEGORY_5` — Enhancer Beliefs  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_BELIEFS_CATEGORY_6` — Reformation Beliefs  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_BELIEFS_HOMEPAGE_LABEL1` — Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_BELIEFS_PAGE_LABEL` — Religion Home Page  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_POLICIES_PAGE_LABEL` — Policies Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_POLICY_NAME` — Policy Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PREREQ_POLICY_LABEL` — Required Policies:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_POLICYSCREEN_CHANGE_IDEOLOGY_DISABLED_TT` — You may not change Ideologies when your people are [COLOR_POSITIVE_TEXT]Content[ENDCOLOR].  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_POLICYSCREEN_IDEOLOGYPANEL_TITLE` — IDEOLOGY  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_POLICYSCREEN_IDEOLOGY_TITLE` — {1_CivAdjective} {2_IdeologyName}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_POLICY_LEGALISM` — Legalism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_RELIGION_TOOLTIP_LINE` — {1_ReligionIcon} {2_NumFollowers} Followers {3_PressureString}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_RELIGION_TOOLTIP_LINE_WITH_TRADE` — {1_ReligionIcon} {2_NumFollowers} Followers {3_PressureString} ({4_Num} trade routes)  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_SOCIALPOLICY_AESTHETICS_HEADING3_TITLE` — Aesthetics  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SOCIALPOLICY_AUTOCRACY_HEADING3_TITLE` — Autocracy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_BRANCHES_HEADING2_TITLE` — Social Policy Branches  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_COMMERCE_HEADING3_TITLE` — Commerce  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_CULTUREVICTORY_HEADING2_TITLE` — Cultural Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_EXPLORATION_HEADING3_TITLE` — Exploration  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SOCIALPOLICY_FREEDOM_HEADING3_TITLE` — Freedom  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_GAINING_HEADING2_TITLE` — Gaining Social Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_HEADING1_TITLE` — Social Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_IDEOLOGY_HEADING3_TITLE` — Ideologies  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SOCIALPOLICY_LIBERTY_HEADING3_TITLE` — Liberty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_ORDER_HEADING3_TITLE` — Order  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_PATRONAGE_HEADING3_TITLE` — Patronage  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_PIETY_HEADING3_TITLE` — Piety  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_RATIONALISM_HEADING3_TITLE` — Rationalism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIALPOLICY_TRADITION_HEADING3_TITLE` — Tradition  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SOCIAL_POLICIES_SCREEN_TITLE` — SOCIAL POLICIES  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_TRO_COL_FROM_RELIGION_TT` — Click to sort by the religious pressure that the origin city of the trade route would receive from the destination city.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_COL_TO_RELIGION_TT` — Click to sort by the religious pressure that the destination city of the trade route would receive from the origin city.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_UPANEL_SPREAD_RELIGION_USES_TT` — This indicates the remaining number of times this unit can spread its religion to a city.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Inherited_Expansion2.xml`

## Tooltips / status (9)

- `TXT_KEY_CITY_STATE_TITLE_TOOL_TIP_CURRENT` — You currently have {1_Num} [ICON_INFLUENCE] Influence with {2_CityStateName:textkey}. {3_DetailString}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CITY_STATE_TITLE_TOOL_TIP_WAR` — While at war this value is locked at its present level.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_HOLY_CITY_TOOLTIP_LINE` — Holy City for {1_ReligionIcon} {2_ReligionName}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_OPSCREEN_TOOLTIP_1_TIMER_LENGTH` — Map Info Delay: {1_Num} seconds  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TOOLTIP_1_TIMER_LENGTH_TT` — Number of seconds before the map view Tool Tip appears.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TOOLTIP_2_TIMER_LENGTH` — Tool Tip 2 Delay: {1_Num} seconds  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TOOLTIP_2_TIMER_LENGTH_TT` — Number of seconds before map view Tool Tip level 2 appears.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_RESOURCE_TOOLTIP_IMPROVED` — When improved:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_RESOURCE_TOOLTIP_IMPROVED_WORKED` — When worked by a City:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`

## Other UI labels (2795)

- `TXT_KEY_ACTION_BARE_MAP` — Toggle Bare Map  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_ADVANCED_OPTIONS` — Advanced Game Options:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_ADVISORS_ADV_QUEST` — Who are these awesome advisors?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_CONTACTING_ADV_QUEST` — How can I get my advisors on the horn?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_CONTACTING_HEADING2_TITLE` — Contacting An Advisor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_FOREIGN_ADV_QUEST` — The foreign advisor is one pretty girl, but how can she help me?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_FOREIGN_HEADING3_BODY` — The Foreign Advisor advises you on exploration and your relations with city-states, and other civilizations.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_FOREIGN_HEADING3_TITLE` — Foreign  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_HEADING1_TITLE` — Advisors  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_MILITARY_ADV_QUEST` — Why is the military advisor so totally awesome?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_MILITARY_HEADING3_BODY` — The Military Advisor provides advice on combat and all things related to war.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_MILITARY_HEADING3_TITLE` — Military  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_SCIENCE_ADV_QUEST` — This science guy looks nerdy. Does Poindexer do anything cool?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_SCIENCE_HEADING3_BODY` — The Science Advisor gives you advice on science and technology, as well as information on game rules.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_SCIENCE_HEADING3_TITLE` — Science  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_TURNINGOFF_ADV_QUEST` — How can I get the advisors to shut up?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISORS_TURNINGOFF_HEADING2_TITLE` — Turning Off the Advisors  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ADVISOR_ARCH_DISPLAY` — Antiquity Sites Revealed!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_ARTISTS_GUILD_DISPLAY` — You Can Build an Artists' Guild!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_ATTACKING_CITY_DISPLAY` — Besieging Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_ATTACKING_FORTIFIED_UNITS_DISPLAY` — Fortified Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_BAD_ATTACK_2_DISPLAY` — Not Our Finest Hour  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_BAD_ATTACK_DISPLAY` — This Attack May Not End Well  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_BANKRUPTCY_DISPLAY` — Bankrupt!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_BUILD_MORE_MILITARY_DISPLAY` — Need More Military  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_BUILD_NEW_CITY_DISPLAY` — New City?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CHOOSE_ARCHAEOLOGY_DISPLAY` — You've Made a Discovery!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_CHOOSE_TECH_TO_STEAL_DISPLAY` — You can steal a tech!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_CITY_ATTACK_DISPLAY` — Attacking Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_BOMBARD_DISPLAY` — City Bombard  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_FIRST_CONSTRUCTION_DISPLAY` — City Construction Complete  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_SCREEN_DISPLAY` — City Screen  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_STATES_INTRO_DISPLAY` — City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_STATES_QUEST_DISPLAY` — A City-State Needs Help!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_STATES_TRESPASSING_DISPLAY` — Trespassing!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_STATE_FRIEND_DISPLAY` — Look Who Made a Friend!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CITY_UNDER_ATTACK_DISPLAY` — Besieged!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COMBAT_INTRO_DISPLAY` — Melee Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COMBAT_NAVAL_UNIT_DISPLAY` — Naval Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CONGRESS_FOUNDED_DISPLAY` — World Congress Founded!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_CONGRESS_PROPOSE_DISPLAY` — You Can Propose a Resolution!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_CONGRESS_VOTE_DISPLAY` — It's Time to Vote!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_COUNSEL` — Advisor Counsel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_FOREIGN_NEXT` — Next  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_FOREIGN_PREV` — Previous  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_MILITARY_NEXT` — Next  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_MILITARY_PREV` — Previous  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_PAGE_DISPLAY` — {1_Num}/{2_Num}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_SCIENCE_NEXT` — Next  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_SCIENCE_PREV` — Previous  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_COUNSEL_TITLE` — Advisor Counsel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_CULTURE_OVERVIEW_DISPLAY` — Culture Overview  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_DISCOVERED_NATURAL_WONDER_DISPLAY` — Natural Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_DONT_SHOW_AGAIN` — Please don't tell me this again.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_ECON_TITLE` — Economic Advisor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISOR_EMBARKING_UNITS_DISPLAY` — Embarking Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_ESPIONAGE_CANT_STEAL_ANYMORE_DISPLAY` — They have nothing that we need.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_ESPIONAGE_CANT_STEAL_ANYMORE_QUESTION` — What if there is no more technology to steal?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_ESPIONAGE_CANT_STEAL_ANYMORE_TOPIC` — Less Advanced Civilizations  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_ESPIONAGE_TECH_STOLEN_DISPLAY` — Treachery!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_ESPIONAGE_TECH_STOLEN_QUESTION` — How do I use spies to steal technology?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_ESPIONAGE_TECH_STOLEN_TOPIC` — Stealing Technology  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_EXCESS_LUXURY_RESOURCE_DISPLAY` — Trade Luxuries  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_FIRST_CARAVAN_DISPLAY` — You Can Build a Trade Unit!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_FIRST_FAITH_POINT_DISPLAY` — You have Faith!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_FIRST_GREAT_PROPHET_DISPLAY` — A Great Prophet was born!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_FIRST_SPY_DISPLAY` — You have a Spy!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_FOREIGN_TITLE` — Foreign Advisor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISOR_GOOD_ATTACK_2_BODY` — Clever move! We crushed our opponents without taking much damage ourselves!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GOOD_ATTACK_2_DISPLAY` — Smart Attack!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GOOD_ATTACK_BODY` — This a clever move! This attack will do a lot of damage to your opponent without your units taking much damage.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GOOD_ATTACK_DISPLAY` — Smart Attack!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GO_TO_GOODY_HUT_DISPLAY` — Ancient Ruins!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GREAT_ARTIST_DISPLAY` — You Have a Great Artist!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_GREAT_MUSICIAN_DISPLAY` — You Have a Great Musician!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_GREAT_PERSON_DISPLAY` — Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_GREAT_PROPHET_SPAWN_DISPLAY` — Great Prophet Spawned!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_GREAT_WRITER_DISPLAY` — You Have a Great Writer!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_HAPPINESS_DISPLAY` — Happiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_HAPPINESS_RESOURCE_DISPLAY` — Your People are not Happy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_INFLUENTIAL_DISPLAY` — Your Great Works are World-Renowned!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_INFORMATION` — Advisor Information  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_LATER_TURNS_BUILD_CITY_DISPLAY` — Found a City!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_LOST_ALL_MILITARY_DISPLAY` — Need Military to Defend!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_LOTS_OF_MONEY_DISPLAY` — Spend Some Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MILITARY_TITLE` — Military Advisor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISOR_MILITARY_UPKEEP_DISPLAY` — Military Upkeep  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MODAL_DONT_SHOW_ME_AGAIN` — Thanks for the information, but don't remind me again.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MODAL_TITLE` — Combat Information  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_FOREST_DISPLAY` — Movement: Forests  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_HILLS_DISPLAY` — Movement: Hills  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_JUNGLE_DISPLAY` — Movement: Jungles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_MARSH_DISPLAY` — Movement: Marshes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_MOUNTAIN_BODY` — Land units cannot move through mountains; you must move around them. Mountains can be seen from quite a distance away.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_MOUNTAIN_DISPLAY` — Movement: Mountains  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MOVEMENT_RIVER_DISPLAY` — Movement: Crossing Rivers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_MUSIC_GUILD_DISPLAY` — You Can Build a Musicians' Guild!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_ONE_UNIT_PER_TILE_DISPLAY` — One Unit Per Tile  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_RANGED_UNIT_DISPLAY` — Ranged Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_RECOMMEND_COURTHOUSE_DISPLAY` — Occupied City Needs Courthouse  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_RESET_TITLE` — You're Doing Great!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISOR_RIGHT_CLICK_MOVE_DISPLAY` — Right-Click Move  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCIENCE_TITLE` — Science Advisor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISOR_SCREEN_CITY_LIST_DISPLAY` — City List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_CITY_SCREEN_BODY` — blah  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_CITY_SCREEN_DISPLAY` — City Screen  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_TECH_CHOOSER_DISPLAY` — Tech Chooser  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SCREEN_UNIT_LIST_DISPLAY` — Unit List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SETTLER_INTRO_DISPLAY` — Where to Found a City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SETTLER_PROTECT_DISPLAY` — Guard your Settler  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SIEGE_UNIT_DISPLAY` — Siege Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_SPY_SPAWN_DISPLAY` — You have a spy!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_ADVISOR_THANK_YOU` — Thank You  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISOR_TOURISM_DISPLAY` — You're Generating Tourism!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_TUTORIAL_1_INTRO_MOVEMENT_AND_EXPLORATION_DISPLAY` — Movement and Exploration  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_TUTORIAL_2_INTRO_FOUND_CITIES_DISPLAY` — Building Settlers and Founding Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_TUTORIAL_3_INTRO_IMPROVING_CITIES_WITH_WORKERS_DISPLAY` — Using Workers to Improve Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_TUTORIAL_4_INTRO_COMBAT_AND_CONQUERING_DISPLAY` — Combat and Conquering  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_TUTORIAL_BUILD_CITY_CHEAT_DISPLAY` — Extra population  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_TY_TT` — Dismisses Advisor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_ADVISOR_UNIT_HEAL_DISPLAY` — Heal Your Unit!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_UPGRADING_UNITS_DISPLAY` — Upgrading Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_VERY_UNHAPPY_DISPLAY` — Your People are Livid!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WINNING_GAME_DISPLAY` — How to Claim Victory!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_INTRO_DISPLAY` — Workers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_NEED_WORK_DISPLAY` — Worker Needs Work  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_PROTECT_DISPLAY` — Keep Your Workers Safe!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_STOP_TRAINING_BODY` — I think we have enough Workers for the moment. You may want to build something else in your city.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_STOP_TRAINING_DISPLAY` — Stop Making Workers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKERS_TRAIN_DISPLAY` — Build a Worker!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WORKER_NAVAL_UNIT_DISPLAY` — Work Boats  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_ADVISOR_WRITERS_GUILD_DISPLAY` — You Can Build a Writers' Guild!  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_ADVISOR_ZONE_OF_CONTROL_DISPLAY` — Zone of Control  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_AD_GAME_SPEED_SETTING` — Game Pace: {1_gamePace}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_HANDICAP_SETTING` — Difficulty Level: {1_handicap}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_MAP_SIZE_SETTING` — Map Size: {1_mapSize}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AD_MAP_TYPE_SETTING` — Map Type: {1_mapType}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AESTHETICS_TITLE` — {@1: gender feminine?Mistress; other?Master;} {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_AIRPOWER_AIRBASES_HEADING2_TITLE` — Air Bases  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_AIRRANGE_HEADING2_TITLE` — Air Range  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_AIRSTRIKES_HEADING2_TITLE` — Air Strikes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_AIRSTRIKE_HEADING3_BODY` — The air unit attacks a ground target within its air range.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_AIRSTRIKE_HEADING3_TITLE` — Air Strike  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_AIRSWEEPS_HEADING3_TITLE` — Air Sweeps  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_AIRSWEEP_HEADING3_BODY` — The air unit "sweeps" a target tile, disabling "intercepting" units.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_AIRSWEEP_HEADING3_TITLE` — Air Sweep  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_AIRUNITS_HEADING2_TITLE` — Air Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_ALLMISSILES_HEADING4_BODY` — Missiles can be based on player-owned cities, on missile cruisers and on nuclear submarines.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_ALLMISSILES_HEADING4_TITLE` — All Missiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_ANTITANKBONUS_HEADING3_TITLE` — Anti-Tank Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_ATOMICBOMBS_HEADING2_TITLE` — Atomic Bombs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_ATOMIC_HEADING4_BODY` — Atomic bombers can be based on cities and on aircraft carriers.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_ATOMIC_HEADING4_TITLE` — Atomic Bombs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_BASELOCATIONS_HEADING3_BODY` — Different types of crafts may be based in different locations.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_BASELOCATIONS_HEADING3_TITLE` — Base Locations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_BOMBERS_HEADING4_BODY` — Bombers can be based on cities and aircraft carriers.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_BOMBERS_HEADING4_TITLE` — Bombers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_CARRIER_HEADING4_BODY` — A carrier can carry up to three air units (fighters, bombers and atomic bombers).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_CARRIER_HEADING4_TITLE` — Carrier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_CRUISER_HEADING4_BODY` — A missile cruiser can carry up to three missiles of any type.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_CRUISER_HEADING4_TITLE` — Missile Cruiser  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_FIGHTERS_HEADING4_BODY` — Fighters and jet fighters can be based on cities and aircraft carriers.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_FIGHTERS_HEADING4_TITLE` — Fighters and Jet Fighters  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_HEADING1_TITLE` — Air Power  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_HELIGUNSHIPS_HEADING2_TITLE` — Helicopter Gunships  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_INTERCEPTION_HEADING2_TITLE` — Interception  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_INTERCEPTION_HEADING3_TITLE` — Interception  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_MISSILES_HEADING2_TITLE` — Missiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_MISSIONS_HEADING2_TITLE` — Missions  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_MOVEMENT_HEADING3_TITLE` — Gunship Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_NAVALUNIT_HEADING3_BODY` — Some naval units can be used as bases for air units and these naval units may hold more than one air unit.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_NAVALUNIT_HEADING3_TITLE` — Naval Unit Capacity  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_NUCMISSILES_HEADING2_TITLE` — Nuclear Missiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_NUCSUBMARINE_HEADING4_BODY` — A nuclear submarine can carry up to two missiles of any type.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_NUCSUBMARINE_HEADING4_TITLE` — Nuclear Submarine  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_REBASE_HEADING3_BODY` — The air unit moves to a new base within its range.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_REBASE_HEADING3_TITLE` — Rebase  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_RECON_HEADING2_TITLE` — Recon  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_STACKING_HEADING3_TITLE` — Air Stacking  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_STEALTH_HEADING4_BODY` — Stealth bombers can be based on cities only.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AIRPOWER_STEALTH_HEADING4_TITLE` — Stealth Bombers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_AMERICAN_TITLE` — Chief {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_AUTOCRACY_TITLE` — {1_PlayerName:textkey} the Terrible of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_AUTOSAVES` — Autosaves  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_AUTO_UNIT_CYCLE_TT` — Automatically select the next unit after orders are issued.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_BARBARIAN_ANCIENTRUINS_HEADING2_TITLE` — Ancient Ruins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_BARBARIANS_HEADING2_TITLE` — Barbarians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_CAPTURED_HEADING3_TITLE` — Captured Civilians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_CULTURE_HEADING4_BODY` — The ruin provides culture to your civilization.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_CULTURE_HEADING4_TITLE` — Culture from Ancient Ruins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_DESTROYING_HEADING4_TITLE` — Destroying an Encampment  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_ENCAMPMENTS_HEADING3_TITLE` — Barbarian Encampments  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_FREETECH_HEADING4_BODY` — The ruin provides your civilization with a free technology.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_FREETECH_HEADING4_TITLE` — Free Technology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_HEADING1_TITLE` — Ruins and Barbarians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_MAP_HEADING4_BODY` — The ruin provides a map of the surrounding area (lifting the fog of war from a number of tiles).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_MAP_HEADING4_TITLE` — Map  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_NAVALUNITS_HEADING3_TITLE` — Barbarian Naval Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_NEWENCAMPMENTS_HEADING4_TITLE` — New Encampments  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_POINTLIMITS_HEADING3_TITLE` — Experience Points Limitations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_RUINBENEFITS_HEADING3_BODY` — Ancient ruins can provide a number of different benefits.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_RUINBENEFITS_HEADING3_TITLE` — Ruin Benefits  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_SURVIVORS_HEADING4_TITLE` — Survivors  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_THEEND_HEADING2_TITLE` — The End of Barbarians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_TREASURE_HEADING4_BODY` — The ruin provides gold to your civilization!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_TREASURE_HEADING4_TITLE` — Treasure  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_UNITS_HEADING2_TITLE` — Barbarian Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_WEAPONS_HEADING4_BODY` — The unit which enters the tile is upgraded to a more advanced unit (a warrior might become a swordsman, for example).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_WEAPONS_HEADING4_TITLE` — Weapons Upgrade  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_WORKERS_HEADING4_BODY` — On easier difficulty levels, you can also receive free Settlers and Workers from ruins.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BARBARIAN_WORKERS_HEADING4_TITLE` — Settlers and Workers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BELIEF_INTERFAITH_DIALOGUE` — Gain [ICON_RESEARCH] Science when a Missionary or Prophet spreads this religion to cities of other religions  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_BELIEF_INTERFAITH_DIALOGUE_SHORT` — Interfaith Dialogue  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Religion_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Religion_Inherited_Expansion2.xml`
- `TXT_KEY_BIND_MOUSE_TT` — Bind the mouse to the game window.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_BUILDINGS_CAPTUREDCITIES_HEADING2_TITLE` — Captured Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BUILDINGS_HEADING1_TITLE` — Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BUILDINGS_HOWTOCONSTRUCT_HEADING2_TITLE` — How to Construct Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BUILDINGS_MAINTENANCE_HEADING2_TITLE` — Building Maintenance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BUILDINGS_PALACE_HEADING2_TITLE` — The Palace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BUILDINGS_PREREQUISITES_HEADING2_TITLE` — Building Prerequisites  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BUILDINGS_PURCHASING_HEADING3_TITLE` — Change Construction or Purchase  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BUILDINGS_SPECIALISTS_HEADING2_TITLE` — Specialists and Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_BUILDING_MAINTENANCE_TT` — {1_Num} [ICON_GOLD] Gold per turn spent on Building maintenance in this City.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_CHANGE_ADMIRAL_PORT_TITLE` — Change Admiral Port  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_ARCHAEOLOGY_TITLE` — Archaeology Find  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_ARCH_ARTIFACT_HEADER` — Create {1_String} Artifact  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_ARCH_LANDMARK_HEADER` — Create Landmark Improvement  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_ARCH_OPTIONS` — Choose from the options below:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_ARCH_RENAISSANCE_HEADER` — Start Cultural Renaissance  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_ARCH_WRITING_HEADER` — Create {1_String} Writing  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_FAITH_GREAT_PERSON_TT` — You may select one of the following Great People as a benefit from your accumulated Faith!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`
- `TXT_KEY_CHOOSE_FREE_GREAT_PERSON_TT` — You may select a free great person for your empire!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CHOOSE_FREE_TECH_TT` — You may select a free technology for your empire!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CHOOSE_GOODY_HUT_BONUS_DESCRIPTION` — Choose Ancient Ruin Bonus from List  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_GOODY_HUT_BONUS_TITLE` — Choose Ancient Ruin Bonus  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CHOOSE_LONG_COUNT_TT` — You may select a free bonus to celebrate the end of the current b'ak'tun of the Maya Long Count calendar!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`
- `TXT_KEY_CHOOSE_PANTHEON_TITLE` — Found a Pantheon  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CHOOSE_REFORMATION_BELIEF_TITLE` — Add Reformation Belief  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CITIES_ANNEXINGCITY_HEADING3_TITLE` — Annexing the City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_ASSIGNINGCITIZENS_HEADING3_TITLE` — Assigning Citizens to Work the Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_ATTACKINGCITY_HEADING3_TITLE` — Attacking a City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_ATTACKINGRANGEDUNITS_HEADING3_TITLE` — Attacking with Ranged Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_BENEFITSSPECIALISTS_HEADING3_TITLE` — Benefits of Specialists  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CHANGINGCONSTRUCTION_HEADING3_TITLE` — Changing Construction  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CITYBANNER_ADV_QUEST` — What is the city banner?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CITYBANNER_HEADING2_TITLE` — The City Banner  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CITYBUILD_HEADING3_TITLE` — The City Build Menu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CITYCOMBAT_HEADING2_TITLE` — City Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CITYSCREEN_HEADING2_TITLE` — The City Screen  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_COMBATUNITS_HEADING3_TITLE` — Combat Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CONQUERINGCITY_HEADING2_TITLE` — Conquering A City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CONSTRUCTINGBUILDINGS_HEADING3_TITLE` — Constructing Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CONSTRUCTINGUNITS_HEADING3_TITLE` — Constructing Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CONSTRUCTINGWONDERS_HEADING3_TITLE` — Constructing Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_CONSTRUCTIONINCITIES_HEADING2_TITLE` — Construction in Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_DEFENDINGCITY_HEADING2_TITLE` — Defending A City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_DESTROYINGCITY_HEADING3_TITLE` — Destroying the City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_HEADING1_TITLE` — Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_HOWTOBUILD_HEADING2_TITLE` — How to Build Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_IMPROVINGLAND_HEADING3_TITLE` — Improving the Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_INDESTRUCTIBLECITY_HEADING3_TITLE` — Indestructible Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_MAKINGCITYPUPPET_HEADING3_TITLE` — Making the City a Puppet  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_PURCHASINGITEM_HEADING3_TITLE` — Purchasing an Item  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_SPECIALISTS_HEADING2_TITLE` — Specialists  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_SUPPLY_TT` — Provided by Number of Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_CITIES_UNEMPLOYEDCITIZENS_HEADING3_TITLE` — Unemployed Citizens  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_UNITSINCITIES_HEADING2_TITLE` — Units in Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_WHERETOCONSTRUCT_HEADING2_TITLE` — Where to Found Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITIES_WORKINGLAND_HEADING2_TITLE` — Working the Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATES_GREATPROPHET_TITLE` — Great Prophet  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CITYSTATE_ALLIES_HEADING4_TITLE` — Allies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_COMMUNICATEWITH_HEADING2_TITLE` — Communicating with City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_CULTURED_HEADING3_BODY` — A cultured city-state can help you improve your culture.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_CULTURED_HEADING3_TITLE` — Cultured  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_DIPLOVICTORY_HEADING2_TITLE` — City-States and Diplomatic Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_GIVEGOLD_HEADING3_TITLE` — Gold: The Gift That Keeps on Giving!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_GIVEUNITS_HEADING3_TITLE` — Give Them Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_HEADING1_TITLE` — City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_INFLUENCELEVELS_HEADING3_BODY` — There are four influence levels with city-states: war, neutral, friends, and allies.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_INFLUENCELEVELS_HEADING3_TITLE` — Influence Levels  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_INFLUENCE_HEADING2_TITLE` — City-State Influence  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_LIBERATING_HEADING2_TITLE` — Liberating a City-State  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_MARITIME_HEADING3_BODY` — A maritime city-state can provide food to your civilization.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_MARITIME_HEADING3_TITLE` — Maritime  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_MILITARISTIC_HEADING3_BODY` — A militaristic city-state can provide units to your army.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_MILITARISTIC_HEADING3_TITLE` — Militaristic  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_MISSIONS_HEADING2_TITLE` — City-State Missions  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_PERMANENTWAR_HEADING4_TITLE` — Wary  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_TYPES_HEADING2_TITLE` — Types of City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_WAROFTHE_HEADING2_TITLE` — War of the City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITYSTATE_WAR_HEADING4_BODY` — While at war with a City-State, your influence will remain negative and they certainly won't give you any stuff.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CITYSTATE_WAR_HEADING4_TITLE` — War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CITY_ANNEX_TT` — Click to annex this City.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_FOREIGN` — Your Foreign Advisor recommends building this here.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_MILITARY` — Your Military Advisor recommends building this here.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_SCIENCE` — Your Science Advisor recommends building this here.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CITY_CURRENTLY_PRODUCING_99PLUS_TT` — {1_CityName} will produce {TXT_KEY_GRAMMAR_A_AN << {2_BldgName}} in more than 99 turns.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITY_CURRENTLY_PRODUCING_TT` — {1_CityName} will produce {TXT_KEY_GRAMMAR_A_AN << {2_BldgName}} in {3_Num} {3_Num: plural 1?turn; other?turns;}.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITY_HAS_SPY_TT` — {1_SpyName} is occupying this city.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_CITY_RANGE_ATTACK_TT` — Perform a ranged attack against a nearby enemy.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CITY_SCREEN_EXIT_TOOLTIP` — Exit the City Screen and return to the world map.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITY_STARVING_TT` — {1_CityName} [COLOR_WARNING_TEXT]is starving![ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CITY_STOPPED_GROWING_TT` — {1_CityName} has stopped growing and will remain at size {2_Num}.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CIV5_ALMATY_TITLE` — Almaty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_ARCHER_HEADING` — Archer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_BALLISTA_HEADING` — Ballista  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_CATAPULT_HEADING` — Catapult  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_CHARIOTARCHER_HEADING` — Chariot Archer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_COMPANIONCAVALRY_HEADING` — Companion Cavalry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_GALLEY_HEADING` — Hoplite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_HOPLITE_HEADING` — Hoplite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_HORSEMAN_HEADING` — Horseman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_IMMORTAL_HEADING` — Immortals  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_INDIANWARELEPHANT_HEADING` — Indian War Elephant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_JAGUAR_HEADING` — Jaguar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_LEGION_HEADING` — Legion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_MOHAWKWARRIOR_HEADING` — Mohawk Warrior  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_SCOUT_HEADING` — Scout  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_SETTLER_HEADING` — Settler  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_SPEARMAN_HEADING` — Spearman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_SWORDSMAN_HEADING` — Swordsman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_TRIREME_HEADING` — Trireme  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_WARCHARIOT_HEADING` — War Chariot  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_WARRIOR_HEADING` — Warrior  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_WORKBOAT_HEADING` — Workboat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ANTIQUITY_WORKER_HEADING` — Worker  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_FACTOID_HEADING` — Arabian Factoids  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_2` — Climate and Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_3` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_4` — The Umayyads  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_5` — The Abbasids  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_6` — Harun al-Rashid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_7` — The Middle Ages  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_8` — Decline and Fragmentation  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_HEADING_9` — Modern Arabia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ARABIA_TITLE` — Arabia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ASSYRIA_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_HEADING_3` — Early People  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_HEADING_4` — First Assyrian Empire  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_HEADING_5` — Assyrian Resurgence  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_HEADING_6` — A Dark Age  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_HEADING_7` — Neo-Assyrian Empire  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_HEADING_8` — Collapse  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ASSYRIA_TITLE` — Assyria  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_AUSTRIA_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_10` — First Republic of Austria  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_11` — Nazi Annexation  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_12` — The New Republic  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_13` — Modern Austria  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_3` — Origins  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_4` — Initial Boundaries  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_5` — The Counts of Babenberg  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_6` — Rule of the House Habsburg  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_7` — The Austrian Empire  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_8` — Austro-Hungarian Empire  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_HEADING_9` — World War I  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AUSTRIA_TITLE` — Austria  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_AZTECS_FACTOID_HEADING` — Aztec Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_10` — The Fall of the Aztecs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_2` — Climate and Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_3` — Aztec Origins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_4` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_5` — The Triple Alliance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_6` — Montezuma I  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_7` — Tlacaelel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_8` — The Empire Ascendant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_HEADING_9` — The Good Stuff (a.k.a., Human Sacrifice)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_AZTECS_TITLE` — Aztecs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BABYLON_BOWMAN_HEADING` — Babylonian Bowman  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_FACTOID_HEADING` — Babylonian Factoids  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_1` — History  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_2` — Terrain and Climate  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_3` — The Old Babylonian Empire  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_4` — Record-Keeping and Mathematics  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_5` — Intermittent Chaos, with Chance of Massacre  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_6` — The Neo-Babylonian Empire  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_7` — Nebuchadnezzar II  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_8` — The Fall of Babylon  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_HEADING_9` — Conclusion  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_TITLE` — Babylon  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BABYLON_WALLS_HEADING` — Walls of Babylon  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_BARBARIANS_HEADING` — Barbarians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BELGRADE_TITLE` — Belgrade  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BRAZIL_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRAZIL_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRAZIL_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRAZIL_HEADING_3` — Portuguese Colonization  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRAZIL_HEADING_4` — Independence  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRAZIL_HEADING_5` — Empire  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRAZIL_HEADING_6` — Dictatorship  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRAZIL_HEADING_7` — Modern Brazil  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRAZIL_TITLE` — Brazil  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_BRUSSELS_TITLE` — Brussels  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUCHAREST_TITLE` — Bucharest  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUDAPEST_TITLE` — Budapest  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_ARMORY_HEADING` — Armory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_BANK_HEADING` — Bank  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_BARRACKS_HEADING` — Barracks  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_BAZAAR_HEADING` — Bazaar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_BROADCASTTOWER_HEADING` — Broadcast Tower  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_BURIALTOMB_HEADING` — Burial Tomb  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_CASTLE_HEADING` — Castle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_CIRCUS_HEADING` — Circus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_COLISEUM_HEADING` — Colosseum  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_FACTORY_HEADING` — Factory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_FLOATINGGARDENS_HEADING` — Floating Gardens  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_FORGE_HEADING` — Forge  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_GARDEN_HEADING` — Garden  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_GRANARY_HEADING` — Granary  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_HARBOR_HEADING` — Harbor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_HOSPITAL_HEADING` — Hospital  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_HYDROPLANT_HEADING` — Hydro Plant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_LIBRARY_HEADING` — Library  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_LIGHTHOUSE_HEADING` — Lighthouse  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_LONGHOUSE_HEADING` — Longhouse  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MARKET_HEADING` — Market  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MEDICALLAB_HEADING` — Medical Lab  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MILITARYACADEMY_HEADING` — Military Academy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MILITARYBASE_HEADING` — Military Base  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MINT_HEADING` — Mint  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MONASTERY_HEADING` — Monastery  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MONUMENT_HEADING` — Monument  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MUDMOSQUE_HEADING` — Mud Pyramid Mosque  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MUGHALFORT_HEADING` — Mughal Fort  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_MUSEUM_HEADING` — Museum  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_NUCLEARPLANT_HEADING` — Nuclear Plant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_OBSERVATORY_HEADING` — Observatory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_OPERAHOUSE_HEADING` — Opera House  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_PALACE_HEADING` — Palace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_PAPERMAKER_HEADING` — Paper Maker  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_PUBLICSCHOOL_HEADING` — Public School  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_RESEARCHLAB_HEADING` — Research Lab  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_SATRAPCOURT_HEADING` — Satrap's Court  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_SEAPORT_HEADING` — Seaport  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_SOLARPLANT_HEADING` — Solar Plant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_SPACESHIP_HEADING` — Spaceship Factory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_STABLE_HEADING` — Stable  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_STADIUM_HEADING` — Stadium  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_STOCKEXCHANGE_HEADING` — Stock Exchange  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_TEMPLE_HEADING` — Temple  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_THEATRE_HEADING` — Theatre  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_UNIVERSITY_HEADING` — University  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_WALLS_HEADING` — Walls  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_WATERMILL_HEADING` — Water Mill  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_WAT_HEADING` — Wat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_WINDMILL_HEADING` — Wind Mill  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BUILDINGS_WORKSHOP_HEADING` — Workshop  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_BYZANTIUM_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_10` — Exile and Recovery  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_11` — Decline of the Empire  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_2` — Geography and Climate  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_3` — Crisis of the Roman Empire  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_4` — From Four, Two  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_5` — Rule of the Justinians  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_6` — Byzantine Culture  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_7` — Dynasties of the Later Millennium  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_8` — The Macedonians  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_HEADING_9` — The Fourth Crusade  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_BYZANTIUM_TITLE` — Byzantium  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CAPETOWN_TITLE` — Cape Town  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CARTHAGE_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_10` — Decline and Destruction  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_11` — Legacy  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_2` — Geography and Climate  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_3` — Foundation  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_4` — Expansion of Power  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_5` — Wars with Greece  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_6` — Rome: Ally to Adversary  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_7` — Advent of the Punic Wars  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_8` — Mercenary Uprising  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_HEADING_9` — Punic Wars Renewed  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CARTHAGE_TITLE` — Carthage  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_10` — The Celtic Language  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_11` — Modern Ancestry  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_2` — Terrain and Climate  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_3` — Celtic Origins  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_4` — Celts of Britain  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_5` — The Celtiberians  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_6` — The Gauls  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_7` — The Roman Conquest  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_8` — Influence of Celtic Culture  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_HEADING_9` — Celtic Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CELTS_TITLE` — The Celts  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_CHINA_FACTOID_HEADING` — Chinese Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CHINA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CHINA_HEADING_2` — Geography  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CHINA_HEADING_3` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CHINA_HEADING_4` — Later History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CHINA_HEADING_5` — Chinese Inventions  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CHINA_HEADING_6` — China and the World  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CHINA_HEADING_7` — China Today  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_CHINA_TITLE` — China  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_COPENHAGEN_TITLE` — Sydney  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_ARABIA_TITLE` — Arabia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_AZTECS_TITLE` — Aztecs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_BABYLON_TITLE` — Babylon  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Babylon.xml`
- `TXT_KEY_CIV5_DAWN_CHINA_TITLE` — China  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_EGYPT_TITLE` — Egypt  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_ENGLAND_TITLE` — England  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_FRANCE_TITLE` — France  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_GERMANY_TITLE` — Germany  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_GREECE_TITLE` — Greece  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_INCA_TITLE` — Inca  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_DLC_02.xml`
- `TXT_KEY_CIV5_DAWN_INDIA_TITLE` — India  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_IROQUOIS_TITLE` — Iroquois  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_JAPAN_TITLE` — Japan  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_MONGOLIA_TITLE` — Mongolia  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Mongol.xml`
- `TXT_KEY_CIV5_DAWN_OTTOMANS_TITLE` — Ottomans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_PERSIA_TITLE` — Persia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_ROME_TITLE` — Rome  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_RUSSIA_TITLE` — Russia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_SIAM_TITLE` — Siam  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_SONGHAI_TITLE` — Songhai  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DAWN_SPAIN_TITLE` — Spain  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_DLC_02.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_DAWN_UNITEDSTATES_TITLE` — United States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_DENMARK_BERSERKER_HEADING` — Berserker  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_FACTOID_HEADING` — Dannish Factoids  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_2` — Geography and Climate  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_3` — Early History and Origins  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_4` — Age of Vikings  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_5` — Formation of the Kingdom  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_6` — Later History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_7` — World War II  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_8` — Modern Denmark  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_HEADING_9` — Cultural Figures  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_SKI_INFANTRY_HEADING` — Norwegian Ski Infantry  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DENMARK_TITLE` — Denmark  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_DUBLIN_TITLE` — Dublin  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EDINBURGH_TITLE` — Edinburgh  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_FACTOID_HEADING` — Egyptian Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_2` — Geography  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_3` — Origins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_4` — The Early Dynastic Period  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_5` — The Old Kingdom  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_6` — Further Periods  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_7` — Art and Culture  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_8` — Religion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_HEADING_9` — Summary  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_EGYPT_TITLE` — Egypt  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_FACTOID_HEADING` — English Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_10` — The United Kingdom  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_11` — Rule Britannia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_12` — The UK at War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_13` — The Present and Future  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_2` — Geography and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_3` — Early History: Enter The Romans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_4` — The Rise and Fall (And Rise) of The Saxons  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_5` — The Vikings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_6` — The Norman Conquest  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_7` — The Middle Ages  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_8` — Queen Elizabeth I  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_HEADING_9` — The Stuarts  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ENGLAND_TITLE` — England  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ETHIOPIA_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_10` — Italian Occupation  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_11` — The Derg  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_12` — Present-day Ethiopia  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_2` — Geography and Climate  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_3` — Origins of Human Development  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_4` — Pre-History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_5` — Early Kingdoms  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_6` — Return of the Solomonic Dynasty  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_7` — Islamic Invasion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_8` — Age of Princes  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_HEADING_9` — Haile Selassie  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_ETHIOPIA_TITLE` — Ethiopia  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIV5_FEATURES_ATOLL_TITLE1` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_ATOLL_TITLE2` — Combat Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_ATOLL_TITLE3` — Movement Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_ATOLL_TITLE4` — Special Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_ATOLL_TITLE5` — Appears in  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FLOODPLAINS_TITLE1` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FLOODPLAINS_TITLE2` — Combat Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FLOODPLAINS_TITLE3` — Movement Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FLOODPLAINS_TITLE4` — Special Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FLOODPLAINS_TITLE5` — Appears in  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FOREST_TITLE1` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FOREST_TITLE2` — Combat Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FOREST_TITLE3` — Movement Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FOREST_TITLE4` — Special Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_FOREST_TITLE5` — Appears in  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_HEADING` — Terrain Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_JUNGLE_TITLE1` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_JUNGLE_TITLE2` — Combat Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_JUNGLE_TITLE3` — Movement Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_JUNGLE_TITLE4` — Special Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_JUNGLE_TITLE5` — Appears in  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_LAKE_TITLE` — Lakes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_MARSH_TITLE1` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_MARSH_TITLE2` — Combat Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_MARSH_TITLE3` — Movement Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_MARSH_TITLE4` — Special Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_MARSH_TITLE5` — Appears in  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_NATURALWONDER_TITLE1` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_NATURALWONDER_TITLE2` — Combat Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_NATURALWONDER_TITLE3` — Movement Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_NATURALWONDER_TITLE4` — Special Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_NATURALWONDER_TITLE5` — Appears in  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_OASIS_TITLE1` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_OASIS_TITLE2` — Combat Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_OASIS_TITLE3` — Movement Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_OASIS_TITLE4` — Special Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_OASIS_TITLE5` — Appears in  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FEATURES_RIVER_TITLE` — Rivers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FLORENCE_TITLE` — Florence  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_FACTOID_HEADING` — French Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_10` — The Wars of Reformation  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_11` — The Seventeenth Century  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_12` — The Eigtheenth Century  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_13` — The Revolution  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_14` — Napolean Bonaparte  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_15` — The Nineteenth Century  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_16` — The Great War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_17` — World War II  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_18` — Modern France  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_2` — Climate and Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_3` — Early Gaul  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_4` — Later Gaul  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_5` — The Fall of Roman Gaul  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_6` — The Middle Ages  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_7` — Charlemagne and the Holy Roman Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_8` — After the Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_HEADING_9` — The Hundred Years' War (1328 - 1429)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_FRANCE_TITLE` — France  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GENEVA_TITLE` — Geneva  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GENGHIS_FACTOID_HEADING` — Genghis Factoid  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_HEADING_1` — History  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_HEADING_2` — Birth  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_HEADING_3` — Early Life  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_HEADING_4` — Unification Begins  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_HEADING_5` — Outward Expansion  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_HEADING_6` — Succession and Death  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_HEADING_7` — Judgment of History  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_SUBTITLE` — Leader of Mongolia  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GENGHIS_TITLES_1` — Leader of Mongolia  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_GERMANY_FACTOID_HEADING` — German Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_10` — The Fall of Germany (Part I)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_11` — The Rise of Germany (Part II)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_12` — The Fall of Germany (Part II)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_13` — The Rise of Germany (Part III)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_14` — The Fall of Germany (Part III)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_15` — The Rise of Germany (Part IV)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_2` — Climate and Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_3` — Pre-History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_4` — The Romans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_5` — Enter the Huns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_6` — The Franks  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_7` — Charlemagne and the Holy Roman Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_8` — The Rise of Germany (Part I)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_HEADING_9` — The Middle Ages  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GERMANY_TITLE` — Germany  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREATARTISTS_HEADING` — Great Artists  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREATENGINEERS_HEADING` — Great Engineers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREATGENERALS_HEADING` — Great Generals  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREATMERCHANTS_HEADING` — Great Merchants  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREATPEOPLE_HEADING` — Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREATSCIENTISTS_HEADING` — Great Scientists  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_FACTOID_HEADING` — Greek Factoids  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_10` — The Persian Wars  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_11` — The Peloponnesian War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_12` — Philip II and Alexander of Macedonia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_13` — The Conquest of Persia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_14` — After Alexander  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_2` — Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_3` — The Mycenaeans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_4` — The Archaic Period  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_5` — Greek Colonization  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_6` — The Rise of the Polis  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_7` — The Spartans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_8` — The Athenians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_HEADING_9` — Classical Greece (510 BC - 323 BC)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_GREECE_TITLE` — Greece  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_HARALD_FACTOID_HEADING` — Harald Bluetooth Factoid  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_HEADING_1` — History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_HEADING_2` — Early Life  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_HEADING_3` — Uniting Denmark  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_HEADING_4` — Construction Projects  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_HEADING_5` — Conversion to Christianity  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_HEADING_6` — Judgement of History  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_SUBTITLE` — Leader of Denmark  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_TITLES_1` — King of Denmark  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HARALD_TITLES_2` — King of Norway  
  source: `DLC/DLC_04/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Denmark.xml`
- `TXT_KEY_CIV5_HELSINKI_TITLE` — Helsinki  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_HUNS_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_HEADING_3` — Origin of the Huns  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_HEADING_4` — Movement into Europe  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_HEADING_5` — An Intimidating Force  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_HEADING_6` — Leadership of Attila  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_HEADING_7` — After Attila  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_HEADING_8` — Hunnic Society  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_HUNS_TITLE` — The Huns  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ANCIENTRUINS_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ANCIENTRUINS_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ANCIENTRUINS_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ANCIENTRUINS_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_CITYRUINS_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_CITYRUINS_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_CITYRUINS_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_CITYRUINS_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ENCAMPMENT_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ENCAMPMENT_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ENCAMPMENT_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ENCAMPMENT_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FALLOUT_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FALLOUT_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FALLOUT_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FALLOUT_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FARM_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FARM_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FARM_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FARM_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FISHINGBOATS_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FISHINGBOATS_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FISHINGBOATS_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FISHINGBOATS_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FORT_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FORT_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FORT_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_FORT_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_HEADING` — Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_LUMBERMILL_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_LUMBERMILL_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_LUMBERMILL_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_LUMBERMILL_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_MINE_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_MINE_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_MINE_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_MINE_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_OFFSHOREPLATFORM_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_OFFSHOREPLATFORM_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_OFFSHOREPLATFORM_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_OFFSHOREPLATFORM_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_PASTURE_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_PASTURE_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_PASTURE_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_PASTURE_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_PLANTATION_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_PLANTATION_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_PLANTATION_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_PLANTATION_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_QUARRY_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_QUARRY_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_QUARRY_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_QUARRY_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_RAILROAD_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_RAILROAD_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_RAILROAD_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ROAD_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ROAD_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_ROAD_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_SCHOOL_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_SCHOOL_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_SCHOOL_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_SCHOOL_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_TRADINGPOST_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_TRADINGPOST_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_TRADINGPOST_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_TRADINGPOST_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_WELL_TITLE1` — Technology Required  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_WELL_TITLE2` — Where It Can Be Constructed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_WELL_TITLE3` — Yield Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS_WELL_TITLE4` — Resource Accessed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS__TITLE1` — Effect of Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS__TITLE2` — Which Improvement to Construct  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS__TITLE3` — How to Construct an Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS__TITLE4` — Pillaging Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS__TITLE5` — Repairing Pillaged Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IMPROVEMENTS__TITLE6` — Coastal Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INCA_FACTOID_HEADING` — Incan Factoids  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INCA_HEADING_1` — History  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INCA_HEADING_2` — Geography and Climate  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INCA_HEADING_3` — Early History: The Kingdom of Cusco  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INCA_HEADING_4` — Continued Expansion  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INCA_HEADING_5` — The White Man Cometh  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INCA_HEADING_6` — The End of an Empire  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INCA_SLINGER_HEADING` — Slinger  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INCA_TITLE` — Inca  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_INDIA_FACTOID_HEADING` — Indian Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_10` — The Muslims  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_11` — Enter the Europeans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_12` — The British Rule  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_13` — Indian Independence Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_14` — Gandhi  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_15` — Independence  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_16` — Modern India, Pakistan, Bangladesh  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_2` — Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_3` — Pre-History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_4` — The Early Vedic Period  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_5` — Caste  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_6` — The Growth of Indian States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_7` — The Maurya Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_8` — Religion in India  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_HEADING_9` — The Gupta Dynasty and Beyond  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDIA_TITLE` — India  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDONESIA_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_HEADING_3` — Early History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_HEADING_4` — Hindu-Buddhist Kingdoms  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_HEADING_5` — The Islamic States  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_HEADING_6` — The Dutch Period  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_HEADING_7` — Independence  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_HEADING_8` — Modern Indonesia  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDONESIA_TITLE` — Indonesia  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_ANTIAIRCRAFTGUN_HEADING` — Anti-Aircraft Gun  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_ANTITANKGUN_HEADING` — Anti-Tank Gun  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_ARTILLERY_HEADING` — Artillery  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_ATOMICBOMB_HEADING` — Atomic Bomb  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_B17_HEADING` — B17  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_BATTLESHIP_HEADING` — Battleship  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_BOMBER_HEADING` — Bomber  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_CARRIER_HEADING` — Carrier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_DESTROYER_HEADING` — Destroyer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_FIGHTER_HEADING` — Fighter  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_FOREIGNLEGION_HEADING` — Foreign Legion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_INFANTRY_HEADING` — Infantry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_PANZER_HEADING` — Panzer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_PARATROOPER_HEADING` — Paratrooper  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_SUBMARINE_HEADING` — Submarine  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_TANK_HEADING` — Tank  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_INDUSTRIAL_ZERO_HEADING` — Zero  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_FACTOID_HEADING` — Iroquois Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_10` — The End  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_2` — Terrain and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_3` — The Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_4` — The Origin Story  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_5` — The Iroquois Government  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_6` — The Beaver Wars  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_7` — The French Response  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_8` — Enter the English  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_HEADING_9` — The American Revolution  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_IROQUOIS_TITLE` — Iroquois  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ISABELLA_FACTOID_HEADING` — Isabella Factoid  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_HEADING_1` — History  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_HEADING_2` — Early Years  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_HEADING_3` — Henry fails at matchmaking  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_HEADING_4` — Ferdinand and the fight for the Throne  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_HEADING_5` — 1492  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_HEADING_6` — No One Expects the Inquisition  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_HEADING_7` — The Later Years  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_HEADING_8` — Legacy in History  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_SUBTITLE` — Leader of Spain  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_TITLES_1` — Queen of Castile and Leon  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_ISABELLA_TITLES_2` — Queen Consort of Aragon, Majorca, Naples, and Valencia  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_JAPAN_FACTOID_HEADING` — Japanese Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_10` — The Warring States Period  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_11` — Oda Nobunaga and The Unification of Japan  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_12` — The Opening of Japan and the Meiji Restoration  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_13` — The Sino-Japanese War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_14` — The Russo-Japanese War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_15` — Imperial Japan  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_16` — The Slide into World War II  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_17` — World War II  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_18` — Post-War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_19` — Japan Today  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_2` — Terrain and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_3` — Pre-History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_4` — Early Written History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_5` — The Tumulus (Tomb) Period, c.AD 250 - 550  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_6` — The Clan System  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_7` — After Yamato: Confucianism, Buddhism and the Law  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_8` — The Rise of the Samurai  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_HEADING_9` — The Collapse of Central Authority  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_JAPAN_TITLE` — Japan  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_FACTOID_HEADING` — Kamehameha Factoid  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_HEADING_2` — Early Life, One of Prophecy  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_HEADING_3` — First Stop, the Big Island  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_HEADING_4` — More Prophecis, More Conquering  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_HEADING_5` — The Napoleon of the Pacific  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_HEADING_6` — Death of a Legend  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_HEADING_7` — Judgement of History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_SUBTITLE` — Leader of Polynesia  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KAMEHAMEHA_TITLES_1` — King of the Hawaiian Islands  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_KOREA_FACTOID_HEADING` — Korea Factoids  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_1` — History  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_10` — Division of Korea  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_11` — Modern Korea  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_2` — Climate and Terrain  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_3` — Pre-History and the Old Kingdom  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_4` — Rise of the Three  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_5` — Transforming Kingdoms  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_6` — Choson Dynasty  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_7` — Korean Empire  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_8` — Japanese Occupation  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HEADING_9` — Korean War  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_HWACHA_HEADING` — Hwach'a  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Units_Korea.xml`
- `TXT_KEY_CIV5_KOREA_TITLE` — Korea  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_KOREA_TURTLESHIP_HEADING` — Turtle Ship  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Units_Korea.xml`
- `TXT_KEY_CIV5_KUALALAMPUR_TITLE` — Kuala Lampur  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_LHASA_TITLE` — Lhasa  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_MAYA_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_10` — The Maya Calendar  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_11` — Colonial Incursion and Decline  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_12` — Contemporary Maya  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_3` — Periods in Maya History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_4` — Great Cities of the Maya  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_5` — The Collapse  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_6` — Maya Class Structure  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_7` — Agriculture and Hunting  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_8` — Honoring the Gods  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_HEADING_9` — Maya Culture  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MAYA_TITLE` — Maya  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_MONACO_TITLE` — Monaco  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_MONGOLIA_FACTOID_HEADING` — Mongolian Factoids  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_1` — History  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_10` — The Present and Future  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_2` — Geography and Climate  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_3` — Early History  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_4` — Enter Temujin  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_5` — Life in the Mongolian Empire  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_6` — A World Superpower  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_7` — Civil War and the End of an Era  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_8` — Under China  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_HEADING_9` — A New Mongolia  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_KESHIK_HEADING` — Mongolian Keshik  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_KHAN_HEADING` — Mongolian Khan  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MONGOLIA_TITLE` — Mongolia  
  source: `DLC/DLC_01/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Mongolia.xml`
- `TXT_KEY_CIV5_MOROCCO_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_HEADING_3` — Ancient Morocco  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_HEADING_4` — Islamic Morocco  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_HEADING_5` — The Berber Dynasties  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_HEADING_6` — The Saadi Sultans  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_HEADING_7` — The Alouites  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_HEADING_8` — European Protectorates and Independence  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_MOROCCO_TITLE` — Morocco  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_FACTOID_HEADING` — Nebuchadnezzar II Factoid  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_HEADING_1` — History  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_HEADING_2` — Early Years  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_HEADING_3` — Upon Assuming Power  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_HEADING_4` — Diplomacy  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_HEADING_5` — Domestic Policies  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_HEADING_6` — Judgment of History  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_SUBTITLE` — Leader of Babylon  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NEBUCHADNEZZAR_TITLES_1` — Nebuchadnezzar II  
  source: `DLC/DLC_Deluxe/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Babylon.xml`
- `TXT_KEY_CIV5_NETHERLANDS_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_10` — Dominance of Trade  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_11` — Struggles for Naval Dominance  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_12` — Establishment of the Kingdom  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_13` — The World Wars  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_14` — Modern Netherlands  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_15` — Cultural Icons  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_2` — Geography and Climate  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_3` — Pre-History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_4` — Roman Occupation  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_5` — Frisians and Franks  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_6` — Shifting Empires  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_7` — Transitions of Power  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_8` — Protestant Reformation  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_HEADING_9` — Uprising against Spain  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_NETHERLANDS_TITLE` — The Netherlands  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_OSLO_TITLE` — Quebec City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_FACTOID_HEADING` — Ottoman Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_10` — The Decline of the Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_11` — The End  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_12` — Eulogy for a Forgotten Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_2` — Climate and Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_3` — The Beginning  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_4` — The Advance into Europe  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_5` — Tamerlane on the Flank  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_6` — Ottoman Recovery and Expansion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_7` — Janissaries  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_8` — Constantinople  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_HEADING_9` — Suleiman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_OTTOMAN_TITLE` — Ottoman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PACHACUTI_FACTOID_HEADING` — Pachacuti Factoid  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_PACHACUTI_HEADING_1` — History  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_PACHACUTI_HEADING_2` — Ascension to the Throne  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_PACHACUTI_HEADING_3` — Creation of an Empire  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_PACHACUTI_HEADING_4` — Judgement of History  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_PACHACUTI_SUBTITLE` — Leader of Inca  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_PACHACUTI_TITLES_1` — Sapa Inca  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Inca.xml`
- `TXT_KEY_CIV5_PERSIA_FACTOID_HEADING` — Persian Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_2` — Terrain and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_3` — Before the Persians: the Medes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_4` — The Rise of Persia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_5` — Persian Expansion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_6` — Xerxes and the Greek Campaigns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_7` — Persian Stagnation and Decline  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_8` — Philip and Alexander and the End of the Achaemenians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_HEADING_9` — Summary  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_PERSIA_TITLE` — Persia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_POLAND_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_3` — The Founding of Poland  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_4` — The Piasts  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_5` — The Jagiellon Dynasty  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_6` — Polish-Lithuanian Commonwealth  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_7` — Age of Partitions  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_8` — Independence through Iron Curtain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_HEADING_9` — Free Again  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLAND_TITLE` — Poland  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_POLYNESIA_FACTOID_HEADING` — Polynesian Factoids  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_HEADING_1` — History  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_HEADING_2` — Geography and Climate  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_HEADING_3` — Early History: First Settlers  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_HEADING_4` — Navigating the Waters  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_HEADING_5` — Link to the Americas  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_HEADING_6` — Arrival of the Europeans  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_HEADING_7` — The Present and Future  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_MAORI_HEADING` — Maori Warrior  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_POLYNESIA_TITLE` — Polynesia  
  source: `DLC/DLC_03/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Polynesia.xml`
- `TXT_KEY_CIV5_PORTUGAL_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_3` — Ancient History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_4` — Muslim Iberia & Reconquista  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_5` — Founding of Portugal  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_6` — Empire  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_7` — Restoration  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_8` — Revolution and Republic  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_HEADING_9` — A New Order  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_PORTUGAL_TITLE` — Portugal  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_RAGUSA_TITLE` — Ragusa  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCES_HEADING` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCES_TITLE2_TEXT` — There are three types of resources in Civilization V:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCES_TITLE3_TEXT` — Bonus resources increase the food, production or gold output of a hex.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCES__TITLE1` — Resource Visibility  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCES__TITLE2` — Resource Types  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCES__TITLE3` — Bonus Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCES__TITLE4` — Luxury Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCES__TITLE5` — Strategic Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_ALUMINUM_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_ALUMINUM_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_ALUMINUM_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_ALUMINUM_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_ALUMINUM_TITLE5` — Allows  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_BANANAS_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_BANANAS_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_BANANAS_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_BANANAS_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COAL_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COAL_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COAL_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COAL_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COAL_TITLE5` — Allows  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COTTON_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COTTON_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COTTON_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COTTON_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COTTON_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COWS_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COWS_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COWS_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_COWS_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DEER_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DEER_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DEER_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_DEER_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FISH_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FISH_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FISH_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FISH_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FUR_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FUR_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FUR_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FUR_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_FUR_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_GEMS_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_GEMS_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_GEMS_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_GEMS_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_GOLD_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_GOLD_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_GOLD_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_GOLD_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_HORSE_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_HORSE_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_HORSE_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_HORSE_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_HORSE_TITLE5` — Allows  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_INCENSE_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_INCENSE_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_INCENSE_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_INCENSE_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_INCENSE_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IRON_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IRON_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IRON_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IRON_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IRON_TITLE5` — Allows  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IVORY_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IVORY_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IVORY_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IVORY_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_IVORY_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_MARBLE_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_MARBLE_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_MARBLE_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_MARBLE_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_MARBLE_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_OIL_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_OIL_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_OIL_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_OIL_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_OIL_TITLE5` — Allows  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_PEARLS_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_PEARLS_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_PEARLS_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_PEARLS_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_PEARLS_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SHEEP_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SHEEP_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SHEEP_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SHEEP_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILK_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILK_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILK_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILK_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILK_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILVER_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILVER_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILVER_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILVER_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SILVER_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SPICES_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SPICES_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SPICES_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SPICES_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SPICES_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SUGAR_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SUGAR_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SUGAR_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SUGAR_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_SUGAR_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_URANIUM_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_URANIUM_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_URANIUM_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_URANIUM_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_URANIUM_TITLE5` — Allows  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WHALES_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WHALES_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WHALES_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WHALES_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WHEAT_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WHEAT_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WHEAT_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WHEAT_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WINE_TITLE1` — Technology Required to See  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WINE_TITLE2` — Location  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WINE_TITLE3` — Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WINE_TITLE4` — Yield Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RESOURCE_WINE_TITLE5` — Happiness Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RIODEJANEIRO_TITLE` — Rio De Janeiro  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_FACTOID_HEADING` — Roman Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_10` — The Birth of an Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_11` — The Rest is History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_2` — Terrain and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_3` — Early Rome  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_4` — The Republic  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_5` — Roman Expansion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_6` — The First Punic War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_7` — The Second Punic War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_8` — The Third Punic War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_HEADING_9` — Social Unrest and the Fall of the Republic  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ROME_TITLE` — Rome  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_FACTOID_HEADING` — Russian Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_10` — Peter the Great  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_11` — Catherine the Great  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_12` — Russia in the 19th Century  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_13` — The Beginning of the End  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_14` — World War I  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_15` — Back in the USSR  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_16` — Russia Today  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_2` — Terrain and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_3` — Russian Pre-History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_4` — Kievan  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_5` — The Mongol Invasion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_6` — The Golden Horde  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_7` — The Principality of Muscovy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_8` — Ivan the Terrible  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_HEADING_9` — The Romanovs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_RUSSIA_TITLE` — Russia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SEJONG_FACTOID_HEADING` — Sejong Factoids  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_HEADING_1` — History  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_HEADING_2` — Early Life  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_HEADING_3` — Language, Literature, and Science  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_HEADING_4` — The Magnanimous Leader  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_HEADING_5` — Law and the Criminal Justice System  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_HEADING_6` — Military Advancements  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_HEADING_7` — Judgment of History  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_SUBTITLE` — Leader of Korea  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEJONG_TITLES_1` — King of the Choson Dynasty  
  source: `DLC/DLC_05/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Korea.xml`
- `TXT_KEY_CIV5_SEOUL_TITLE` — Kathmandu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SHOSHONE_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_SHOSHONE_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_SHOSHONE_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_SHOSHONE_HEADING_3` — Distribution  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_SHOSHONE_HEADING_4` — Coming of the White Men  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_SHOSHONE_HEADING_5` — Cooperation and Resistance  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_SHOSHONE_HEADING_6` — Reservation Life  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_SHOSHONE_TITLE` — Shoshone  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_SIAM_FACTOID_HEADING` — Siamese Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_10` — Postwar Thailand - "You Say You Want a Revolution?"  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_11` — Thailand Tomorrow  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_2` — Terrain and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_3` — Siamese Pre-History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_4` — Sukhothai and Ramkhamhaeng  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_5` — Ayutthaya  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_6` — Thon Buri  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_7` — Siam Resurgent  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_8` — Siam and the West  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_HEADING_9` — The Twentieth Century  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIAM_TITLE` — Siam  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SIDON_TITLE` — Sidon  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SINGAPORE_TITLE` — Singapore  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_FACTOID_HEADING` — Songhai Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_HEADING_2` — Terrain and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_HEADING_3` — Before the Songhai: The Mali  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_HEADING_4` — The Rise of Songhai  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_HEADING_5` — Sunni Ali Ber  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_HEADING_6` — Muhammad I Askia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_HEADING_7` — The Decline and Fall of Songhai  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_HEADING_8` — Lessons Learned  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SONGHAI_TITLE` — Songhai  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPAIN_CONQUISTADOR_HEADING` — Conquistador  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_FACTOID_HEADING` — Spanish Factoids  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_1` — History  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_2` — Geography and Climate  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_3` — Early History: From Cro-Magnons to Celts  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_4` — Enter the Romans  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_5` — The Arrival of the Moors  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_6` — The Reconquista, Unification, and Inquistition, Oh My  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_7` — Imperial Spain, Rulers of the New World  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_8` — Troubles and Warfare, or, Spain can't get a break  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_HEADING_9` — The Present and the Future  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_TERCIO_HEADING` — Tercio  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPAIN_TITLE` — Spain  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/Civ5CivlopediaDLC_Spain.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/Civ5CivilopediaDLC_Spain_Expansion.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_HEADING` — Special Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_HEADING_TEXT` — There are several "special" terrain types in Civilization V. Each has important effects upon the game.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_HILLS_TITLE1` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_HILLS_TITLE2` — Defensive Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_HILLS_TITLE3` — Movement Cost  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_RIVERS_TITLE1` — River Locations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_RIVERS_TITLE2` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_RIVERS_TITLE3` — Offensive Penalty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SPECIALTERRAIN_RIVERS_TITLE4` — Movement Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_STOCKHOLM_TITLE` — Stockholm  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_SWEDEN_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_10` — Modern Sweden  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_2` — Geography and Climate  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_3` — Pre-History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_4` — The Vikings of Sweden  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_5` — Early Kingdoms  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_6` — The Kalmar Union  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_7` — Rise of Swedish Power  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_8` — Swedish Industrialization  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_HEADING_9` — Advent of Neutrality  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_SWEDEN_TITLE` — Sweden  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIV5_TERRAIN_COAST_TITLE1` — City Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_COAST_TITLE2` — Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_COAST_TITLE3` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_COAST_TITLE4` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_COAST_TITLE5` — Combat Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_DESERT_TITLE1` — City Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_DESERT_TITLE2` — Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_DESERT_TITLE3` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_DESERT_TITLE4` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_DESERT_TITLE5` — Combat Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_GRASSLAND_TITLE1` — City Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_GRASSLAND_TITLE2` — Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_GRASSLAND_TITLE3` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_GRASSLAND_TITLE4` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_GRASSLAND_TITLE5` — Combat Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_HEADING` — Terrain Types  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_OCEAN_TITLE1` — City Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_OCEAN_TITLE2` — Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_OCEAN_TITLE3` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_OCEAN_TITLE4` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_OCEAN_TITLE5` — Combat Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_PLAINS_TITLE1` — City Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_PLAINS_TITLE2` — Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_PLAINS_TITLE3` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_PLAINS_TITLE4` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_PLAINS_TITLE5` — Combat Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_TUNDRA_TITLE1` — City Yield  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_TUNDRA_TITLE2` — Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_TUNDRA_TITLE3` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_TUNDRA_TITLE4` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TERRAIN_TUNDRA_TITLE5` — Combat Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_TYRE_TITLE` — Tyre  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_FACTOID_HEADING` — United States Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_10` — The American Civil War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_11` — Westward Ho  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_12` — The Early 20th Century - The World Intrudes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_13` — The Great Depression  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_14` — The Second World War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_15` — The US at War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_16` — America in the Second Half of the 20th Century  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_17` — The Cold War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_18` — The War Against Terrorism  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_19` — The US in the Future  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_2` — Geography and Climate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_3` — The Native Americans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_4` — Enter the Europeans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_5` — The American Revolution  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_6` — George Washington  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_7` — The Louisiana Purchase  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_8` — The War of 1812  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_HEADING_9` — The Mexican-American War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_UNITEDSTATES_TITLE` — United States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_VENICE_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_VENICE_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_VENICE_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_VENICE_HEADING_3` — Pre-Republic History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_VENICE_HEADING_4` — Venice in the Middle Ages  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_VENICE_HEADING_5` — Renaissance  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_VENICE_HEADING_6` — Decline  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_VENICE_HEADING_7` — After the Republic  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_VENICE_TITLE` — Venice  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_VICTORY_ALTCONQUEST_TITLE` — Alternate Conquest Victory  
  source: `Gameplay/XML/NewText/EN_US/Victory/CIV5_Victory.xml`
- `TXT_KEY_CIV5_VICTORY_CONQUEST_TITLE` — Conquest Victory  
  source: `Gameplay/XML/NewText/EN_US/Victory/CIV5_Victory.xml`
- `TXT_KEY_CIV5_VICTORY_CULTURE_TITLE` — Culture Victory  
  source: `Gameplay/XML/NewText/EN_US/Victory/CIV5_Victory.xml`
- `TXT_KEY_CIV5_VICTORY_DIPLOMATIC_TITLE` — Diplomatic Victory  
  source: `Gameplay/XML/NewText/EN_US/Victory/CIV5_Victory.xml`
- `TXT_KEY_CIV5_VICTORY_LOSS_TITLE` — Loss  
  source: `Gameplay/XML/NewText/EN_US/Victory/CIV5_Victory.xml`
- `TXT_KEY_CIV5_VICTORY_SCIENCE_TITLE` — Science Victory  
  source: `Gameplay/XML/NewText/EN_US/Victory/CIV5_Victory.xml`
- `TXT_KEY_CIV5_VIENNA_TITLE` — Vienna  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_WARSAW_TITLE` — Warsaw  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIV5_ZULU_FACTOID_HEADING` — Factoids  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ZULU_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ZULU_HEADING_2` — Climate and Terrain  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ZULU_HEADING_3` — Rise of the Zulu Kingdom  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ZULU_HEADING_4` — Shaka's Successors  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ZULU_HEADING_5` — Cetshwayo and the Anglo-Zulu War  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ZULU_HEADING_6` — End of the Zulu Kingdom  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ZULU_HEADING_7` — Modern Zululand  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIV5_ZULU_TITLE` — Zulu  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_HEADING_2` — Early Life  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_HEADING_3` — Rise to Power  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_HEADING_4` — Reign  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_HEADING_5` — Judgement of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_LIVED` — c. 1549 - 1603 AD  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_NAME` — Ahmad al-Mansur  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_SUBTITLE` — Leader of Morocco  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AHMAD_ALMANSUR_TITLES_1` — Sultan of the Saadi Dynasty  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_HEADING_2` — Early Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_HEADING_3` — Rise to Power  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_HEADING_4` — The Creation of An Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_HEADING_5` — The Fall of Alexander  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_HEADING_6` — Judgment of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_LIVED` — 356 - 323 BC  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_NAME` — Alexander  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_SUBTITLE` — Leader of The Greeks  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ALEXANDER_TITLES_1` — Alexander the Great  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_HEADING_2` — Early Life  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_HEADING_3` — Reign  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_HEADING_4` — The Library  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_HEADING_5` — Judgment of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_LIVED` — 685 BC - c. 627 BC  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_NAME` — Ashurbanipal  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_SUBTITLE` — Leader of Assyria  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASHURBANIPAL_TITLES_1` — King of Assyria  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_HEADING_2` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_HEADING_3` — Pilgrimage to Mecca  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_HEADING_4` — Military Expansion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_HEADING_5` — Organization of the Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_HEADING_6` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_LIVED` — c. 1440 - 1538 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_NAME` — Askia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_SUBTITLE` — Leader of Songhai  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ASKIA_TITLES_1` — Askia (Usurper)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_HEADING_2` — The Legend of Attila  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_HEADING_3` — Early Life and Campaigns  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_HEADING_4` — Movement Against Rome  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_HEADING_5` — The Story of Honoria  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_HEADING_6` — March on Italy  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_HEADING_7` — Judgment of History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_LIVED` — c. 406 AD - c. 453 AD  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_NAME` — Attila  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_SUBTITLE` — Ruler of the Hunnic Empire  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ATTILA_TITLES_1` — King, General  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_FACT_1` — "More haste, less speed." - Augustus Caesar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_FACT_2` — "Better a safe commander than a bold." - Augustus Caesar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_FACT_3` — "That is done quickly enough which is done well enough." - Augustus Caesar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_HEADING_2` — Early Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_HEADING_3` — Death of Julius Caesar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_HEADING_4` — Antony and Cleopatra  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_HEADING_5` — Octavius Becomes Augustus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_HEADING_6` — Augustus at Home  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_HEADING_7` — Roman Expansion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_HEADING_8` — Judgment of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_LIVED` — 63 BC - 14 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_NAME` — Augustus Caesar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_SUBTITLE` — Leader of The Romans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_AUGUSTUS_TITLES_1` — Princeps  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_HEADING_2` — Early Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_HEADING_3` — Foreign Policy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_HEADING_4` — Domestic Policy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_HEADING_5` — Judgment of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_LIVED` — 1815 - 1898 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_NAME` — Bismarck  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_SUBTITLE` — Leader of The Germans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_TITLES_1` — Chancellor of the German Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARCK_TITLES_2` — "Iron Chancellor"  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BISMARK_FACT_2` — "Laws are like sausages, it is better not to see them being made."  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BOUDICCA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BOUDICCA_HEADING_2` — Judgment of History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BOUDICCA_LIVED` — Unknown - c. 61 AD  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BOUDICCA_NAME` — Boudicca  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BOUDICCA_SUBTITLE` — Leader of the Celts  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_BOUDICCA_TITLES_1` — Queen of the Iceni  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_HEADING_2` — Early Reign  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_HEADING_3` — Domestic Affairs  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_HEADING_4` — Foreign Successes  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_HEADING_5` — Judgment of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_LIVED` — 1310 - 1370 AD  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_NAME` — Casimir III  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_SUBTITLE` — Leader of Poland  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CASIMIR_TITLES_1` — King of Poland  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_HEADING_2` — Early Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_HEADING_3` — Rise to Power  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_HEADING_4` — Foreign Policy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_HEADING_5` — Domestic Policy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_HEADING_6` — The Arts  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_HEADING_7` — The Scandal  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_HEADING_8` — Judgment of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_LIVED` — 1729 - 1796 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_NAME` — Catherine  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_SUBTITLE` — Leader of The Russians  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_CATHERINE_TITLES_1` — Tsarina of Russia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_HEADING_2` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_HEADING_3` — Securing Persia's Borders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_HEADING_4` — Darius the Ruler  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_HEADING_5` — War With Greece  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_HEADING_6` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_LIVED` — 550 - 486 BC  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_NAME` — Darius I  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_SUBTITLE` — Leader of Persia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DARIUS_TITLES_1` — King Darius the Great  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DIDO_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DIDO_HEADING_2` — Judgment of History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DIDO_LIVED` — c. 800 BC  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DIDO_NAME` — Dido  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DIDO_SUBTITLE` — Leader of Carthage  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_DIDO_TITLES_1` — Queen of Carthage  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_HEADING_2` — Early Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_HEADING_3` — Queen Elizabeth I  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_HEADING_4` — Patron of the Arts  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_HEADING_5` — Foreign Relations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_HEADING_6` — Judgment of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_LIVED` — 1533 - 1603 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_NAME` — Elizabeth I  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_SUBTITLE` — Leader of England  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_TITLES_1` — Gloriana  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_TITLES_2` — The Virgin Queen  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ELIZABETH_TITLES_3` — Good Queen Bess  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_HEADING_2` — Early Life  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_HEADING_3` — Reign  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_HEADING_4` — The Fourth Crusade  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_HEADING_5` — Judgement of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_LIVED` — 1107 - 1205 AD  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_NAME` — Enrico Dandolo  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_SUBTITLE` — Leader of Venice  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ENRICO_DANDOLO_TITLES_1` — Doge of Venice  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_HEADING_2` — Rise to Power  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_HEADING_3` — Prime Minister of Majapahit  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_HEADING_4` — Conquests  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_HEADING_5` — Judgment of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_LIVED` — c. 1290 AD - 1364 AD  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_NAME` — Gajah Mada  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_SUBTITLE` — Leader of Indonesia  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GAJAH_MADA_TITLES_1` — Prime Minister and General of Majapahit Empire  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_FACT_1` — Gandhi had a set of false teeth, which he carried in a fold of his loin cloth - he only took them out for meals.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_HEADING_2` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_HEADING_3` — South Africa  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_HEADING_4` — Return to India  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_HEADING_5` — Partition  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_HEADING_6` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_LIVED` — 1869 - 1948 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_NAME` — Gandhi  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_SUBTITLE` — Leader of India  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GANDHI_TITLES_1` — Mahatma  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_HEADING_2` — Early Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_HEADING_3` — French and Indian War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_HEADING_4` — Home Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_HEADING_5` — Pre-Revolution Activities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_HEADING_6` — Commander of the Continental Army  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_HEADING_7` — President of the United States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_HEADING_8` — Washington's Place in History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_LIVED` — 1732 - 1799 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_NAME` — George Washington  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_SUBTITLE` — Leader of the United States of America  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_TITLES_1` — Commander-in-Chief of Colonial Armies (during American Revolution)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GEORGE_TITLES_2` — President of the United States of America (1789-1797)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_FACT_1` — Gustavus Adolphus Day is celebrated on November 6th of each year in Sweden, Estonia and Finland.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_HEADING_2` — Conflicts of his Father  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_HEADING_3` — Early Reign  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_HEADING_4` — Political Reforms  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_HEADING_5` — Military Innovations  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_HEADING_6` — On the Battlefield  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_HEADING_7` — Judgment of History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_LIVED` — 1594 AD - 1632 AD  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_NAME` — Gustavus Adolphus  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_SUBTITLE` — Leader of Sweden  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_GUSTAVUS_ADOLPHUS_TITLES_1` — King  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_FACT_1` — In the Sierra game Quest for Glory II, the sultan who adopts the Hero as his son is named Harun al-Rashid.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_HEADING_2` — Early Reign  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_HEADING_3` — Baghdad Renaissance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_HEADING_4` — Wealth of Harun and Arabia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_HEADING_5` — Foreign Relations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_HEADING_6` — Death of Harun  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_HEADING_7` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_LIVED` — 763 - 809 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_NAME` — Harun al-Rashid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_SUBTITLE` — Leader of Arabia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_TITLES_1` — Caliph  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HARUN_TITLES_2` — "The One Following the Right Path"  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HIAWATHA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HIAWATHA_HEADING_2` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HIAWATHA_LIVED` — c. 1550 AD?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HIAWATHA_NAME` — Hiawatha  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HIAWATHA_SUBTITLE` — Leader of Iroquois  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_HIAWATHA_TITLES_1` — Chief  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_HEADING_2` — Early Reign  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_HEADING_3` — Holy Roman Empress  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_HEADING_4` — The Seven Years War  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_HEADING_5` — State Reforms  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_HEADING_6` — Maternal Instincts  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_HEADING_7` — Judgment of History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_HEADING_2` — Early Life  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_HEADING_3` — Accession  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_HEADING_4` — Madness  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_HEADING_5` — Escape to Brazil  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_HEADING_6` — Judgment of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_LIVED` — 1734 - 1816 AD  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_NAME` — Maria I  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_SUBTITLE` — Leader of Portugal  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_I_TITLES_1` — Queen-Regent of Portugal, Brazil and the Algarves  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_LIVED` — 1717 AD - 1780 AD  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_NAME` — Maria Theresa  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_SUBTITLE` — Leader of Austria  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MARIA_TITLES_1` — Empress of the Holy Roman Empire, Queen of the Habsburg Empire  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_2` — Early Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_3` — A Modest Lifestyle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_4` — Domestic Policy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_5` — Sumptuary Laws  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_6` — Religious Changes  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_7` — Foreign Policy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_8` — Death  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_HEADING_9` — Judgment of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_LIVED` — c.1397-1469 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_NAME` — Montezuma I  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_SUBTITLE` — Leader of The Aztecs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_MONTEZUMA_TITLES_1` — Emperor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_HEADING_2` — Early Life  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_HEADING_3` — Rise to Power  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_HEADING_4` — Vive l'Empereur!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_HEADING_5` — The Russian Campaign  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_HEADING_6` — Napoleon's Fall  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_HEADING_7` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_LIVED` — 1769 - 1821 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_NAME` — Napoleon Bonaparte  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_SUBTITLE` — Leader of France  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_TEXT_1` — It is virtually impossible to overstate the military genius of Napoleon Bonaparte.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_TITLES_1` — First Consul of the First French Republic  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_NAPOLEON_TITLES_2` — Emperor Napoleon I of the First French Empire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_HEADING_2` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_HEADING_3` — Rise to Power  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_HEADING_4` — Further Conquests  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_HEADING_5` — Death of Nobunaga  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_HEADING_6` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_LIVED` — 1534 - 1582 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_NAME` — Oda Nobunaga  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_SUBTITLE` — Leader of Japan  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_ODA_TITLES_1` — Daimyo  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_FACT_1` — The name Pacal means "Shield," or "Sun Shield," in Mayan.  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_HEADING_2` — Early Life  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_HEADING_3` — Rejuvenation of Palenque  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_HEADING_4` — Judgment of History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_LIVED` — 603 AD - 683 AD  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_NAME` — Pacal  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_SUBTITLE` — Leader of the Maya  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PACAL_TITLES_1` — King  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_HEADING_2` — Youth  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_HEADING_3` — Reign  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_HEADING_4` — Overthrow  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_HEADING_5` — Judgment of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_LIVED` — 1825 - 1891 AD  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_NAME` — Pedro II  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_SUBTITLE` — Leader of Brazil  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_PEDRO_TITLES_1` — Emperor of Brazil  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_HEADING_2` — Early Life  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_HEADING_3` — Defiance  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_HEADING_4` — Reservation  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_HEADING_5` — Judgment of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_LIVED` — 1815 - 1884 AD  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_NAME` — Pocatello  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_SUBTITLE` — Leader of the Shoshone  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_POCATELLO_TITLES_1` — Chief of the Shoshone  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_2` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_3` — Military Campaigns  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_4` — Peace with the Hittites  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_5` — Pi-Ramesses  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_6` — Public Works  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_7` — Biblical Connection  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_8` — Death and Burial  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_HEADING_9` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_LIVED` — c. 1303 - 1213 BC  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_NAME` — Ramesses II  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_SUBTITLE` — Leader of Egypt  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_TITLES_1` — Ramesses The Great  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMESSES_TITLES_2` — The Great Ancestor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_HEADING_2` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_HEADING_3` — King Ramkhamhaeng  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_HEADING_4` — Arts and Culture  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_HEADING_5` — Ramkhamhaeng's Death  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_HEADING_6` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_LIVED` — 1240 - 1298 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_NAME` — Ramkhamhaeng  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_SUBTITLE` — Leader of Siam  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_RAMKHAMHAENG_TITLES_1` — "Rama the Bold"  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_HEADING_2` — Early Life and Politics  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_HEADING_3` — Emperor to Exile  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_HEADING_4` — Return to Power  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_HEADING_5` — Decades of Rule  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_HEADING_6` — Imprisonment and Death  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_HEADING_7` — Rastafarian God  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_HEADING_8` — Judgment of History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_LIVED` — 1892 - 1975 AD  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_NAME` — Haile Selassie  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_SUBTITLE` — Leader of Ethiopia  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SELASSIE_TITLES_1` — Emperor of Ethiopia  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_HEADING_2` — Early Life  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_HEADING_3` — Reign  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_HEADING_4` — Assassination  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_HEADING_5` — Judgment of History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_LIVED` — c. 1787 - 1828 AD  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_NAME` — Shaka  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_SUBTITLE` — Leader of the Zulu Kingdom  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SHAKA_TITLES_1` — Chieftain of the Zulus  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_FACT_1` — Suleiman kept numerous fancy breeds of pigeons at his palace in Istanbul.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_HEADING_2` — Early History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_HEADING_3` — Military Ambitions in Europe  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_HEADING_4` — Military Adventures in Persia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_HEADING_5` — Domestic Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_HEADING_6` — Culture, Religion and the Arts  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_HEADING_7` — Verdict of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_LIVED` — 1494 - 1566 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_NAME` — Suleiman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_SUBTITLE` — Leader of the Ottomans  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_TITLES_1` — The Magnificent  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_SULEIMAN_TITLES_2` — The Lawmaker  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_FACT_3` — The former settlement of Olbia, Libya, was at one time known as "Theodorias," named after the Empress Theodora.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_HEADING_1` — History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_HEADING_2` — Early Life  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_HEADING_3` — Ascension to the Throne  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_HEADING_4` — Political Influence  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_HEADING_5` — Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_HEADING_6` — The Nika Revolt  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_HEADING_7` — Judgment of History  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_LIVED` — c. 497 AD - 548 AD  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_NAME` — Theodora  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_SUBTITLE` — Empress of the Byzantine Empire  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_THEODORA_TITLES_1` — Empress  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_HEADING_1` — History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_HEADING_2` — Noble Upbringing  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_HEADING_3` — Roots of Rebellion  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_HEADING_4` — The Uprising Begins  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_HEADING_5` — Outbreak of War  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_HEADING_6` — Roots of Independence  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_HEADING_7` — Assassination Attempts  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_HEADING_8` — Judgment of History  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_LIVED` — 1533 AD - 1584 AD  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_NAME` — William of Orange  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_SUBTITLE` — Leader of the Netherlands  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WILLIAM_TITLES_1` — Prince of Orange  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_Civilopedia_NewWorldDeluxeScenario.xml`, `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_HEADING_1` — History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_HEADING_2` — Concubine Wu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_HEADING_3` — Empress Consort Wu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_HEADING_4` — Dowager Empress Wu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_HEADING_5` — Emperor Wu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_HEADING_6` — Judgment of History  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_LIVED` — c. 625 - 705 AD  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_NAME` — Wu Zetian  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_SUBTITLE` — Leader of China  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_LEADERS_WUZETIAN_TITLES_1` — Empress Regnant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_BUILDING_LIST` — Building List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_IMPROVEMENT_LIST` — Improvement List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_PROMOTIONS_LIST` — Promotion List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_RESOURCES_LIST` — Resource List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_SOCIAL_POLICIES` — Social Policy List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_SPECIALISTS_AND_GREAT_PEOPLE` — Specialists and Great People List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_TERRAIN_LIST` — Terrain and Feature List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_UNITS_LIST` — Unit List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SHORTCUT_WONDER_LIST` — Wonder List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_CIVILOPEDIA_SPECIALABILITIES_YIELDCHANGES` — {@1_ImprovementDescription} {@2_YieldDescription} {TXT_KEY_ABLTY_YIELD_IMPRVD_STRING} {3_Yield}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_TOOLTIP` — Open the Civilopedia, which explains a variety of game elements.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_FUTURE_SSBOOSTER_HEADING` — SS Booster  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_FUTURE_SSCOCKPIT_HEADING` — SS Cockpit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_FUTURE_SSENGINE_HEADING` — SS Engine  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_FUTURE_SSSTASISCHAMBER_HEADING` — SS Stasis Chamber  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_HUN_SCOURGE_OF_GOD_TEXT` — The "Scourge of God" is the nickname given to Attila. These units represent his leadership on the battlefield.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_FoR_Scenario.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_CAMELARCHER_HEADING` — Camel Archer (Arabia)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_CARAVEL_HEADING` — Caravel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_CHUKONU_HEADING` — Chu-Ko-Nu (China)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_CROSSBOWMAN_HEADING` — Crossbowman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_JANISSARY_HEADING` — Janissary (Ottomans)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_KNIGHT_HEADING` — Knight  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_LANDSKNECHT_HEADING` — Landsknecht (Germany)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_LONGBOWMAN_HEADING` — Longbowman (England)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_LONGSWORDSMAN_HEADING` — Longswordsman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_MINUTEMAN_HEADING` — Minuteman (America)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_MUSKETEER_HEADING` — Musketeer (France)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_MUSKETMAN_HEADING` — Musketman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_MUSLIMCAVALRY_HEADING` — Mandekalu Cavalry (Songhai)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_PIKEMAN_HEADING` — Pikeman  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_SAMURAI_HEADING` — Samurai (Japan)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_SIAMESEWARELEPHANT_HEADING` — Siamese War Elephant (Siam)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MEDIEVAL_TREBUCHET_HEADING` — Trebuchet  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_GUIDEDMISSLE_HEADING` — Guided Missile  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_HELICOPTERGUNSHIP_HEADING` — Helicopter Gunship  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_JETFIGHTER_HEADING` — Jet Fighter  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_MECHANIZEDINFANTRY_HEADING` — Mechanized Infantry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_MECH_HEADING` — Mech  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_MISSLECRUISER_HEADING` — Missile Cruiser  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_MOBILEROCKETARTILLERY_HEADING` — Mobile Rocket Artillery  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_MOBILESAMLAUNCHER_HEADING` — Mobile SAM Launcher  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_MODERNARMOR_HEADING` — Modern Armor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_NUCLEARMISSLE_HEADING` — Nuclear Missile  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_NUCLEARSUBMARINE_HEADING` — Nuclear Submarine  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_MODERN_STEALTHBOMBER_HEADING` — Stealth Bomber  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_CAVALRY_HEADING` — Cavalry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_COSSACK_HEADING` — Cossack (Russia)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_FRIGATE_HEADING` — Frigate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_IRONCLAD_HEADING` — Ironclad  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_LANCER_HEADING` — Lancer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_RIFLEMEN_HEADING` — Riflemen  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_SHIPOFTHELINE_HEADING` — Ship of the Line (England)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CIVILOPEDIA_UNITS_RENAISSANCE_SIPAHI_HEADING` — Sipahi (Ottomans)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_ACQUIRINGXP_HEADING3_TITLE` — Acquiring XPs Through Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_ALERTORDER_HEADING4_TITLE` — The "Alert" Order  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_ATTACKUNIT_HEADING3_TITLE` — Attacking Another Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_ATTACKWITHMELEECOMBAT_HEADING3_TITLE` — Attacking Cities with Melee Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_ATTACKWITHRANGEDUNITS_HEADING3_TITLE` — Attacking Cities with Ranged Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_CAPTURINGCITIES_HEADING3_TITLE` — Capturing Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_CITYCOMBATSTATS_HEADING3_TITLE` — City Combat Stats  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_CITYCOMBATSTRENGTH_HEADING4_TITLE` — City Combat Strength  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_CITYFIRINGATTACKERS_HEADING3_TITLE` — Cities Firing at Attackers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_CITYHITPOINTS_HEADING4_TITLE` — City Hit Points  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_CITY_HEADING2_TITLE` — City Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_COMBATBONUS_HEADING2_TITLE` — Combat Bonuses  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_COMBATDAMAGE_HEADING2_TITLE` — Combat Damage  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_COMBATRESULTS_HEADING3_TITLE` — Ranged Combat Results  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_COMBATSTRENGTH_HEADING3_TITLE` — Combat Strength  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_COMBATTABLE_HEADING3_TITLE` — Combat Information Table  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_DECLAREWAR_HEADING2_TITLE` — Declaring War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_DIPLODECLAREWAR_HEADING3_TITLE` — Diplomatically Declaring War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_ENDWAR_HEADING2_TITLE` — Ending a War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_ENTERTERRITORY_HEADING3_TITLE` — Entering a Civilization's Territory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_EXPENDING_HEADING3_TITLE` — Expending XPs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_EXPERIENCEPOINTS_HEADING2_TITLE` — Experience Points and Promotions  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_FORTIFICATIONBONUS_HEADING4_TITLE` — Fortification Bonuses  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_FORTIFICATION_HEADING3_TITLE` — Fortification  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_FORTIFY_HEADING4_TITLE` — Which Units Can Fortify  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_FORT_HEADING3_TITLE` — Fort  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_GARRISONINCITIES_HEADING3_TITLE` — Garrison Units in Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_GREATGENERALS_HEADING2_TITLE` — Great Generals  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_HEADING1_TITLE` — Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_HEALINGDAMAGE_HEADING3_TITLE` — Healing Damage to Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_HEALTINGDAMAGE_HEADING3_TITLE` — Healing Damage  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_HITPOINTS_HEADING3_TITLE` — Hit Points  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_INITIATINGMELEE_HEADING3_TITLE` — Initiating Melee Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_INITIATINGRANGE_HEADING3_BODY` — With the ranged unit active, right-click on the target, and the attack will commence.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_INITIATINGRANGE_HEADING3_TITLE` — Initiating Ranged Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_LINEOFSIGHT_HEADING3_TITLE` — Line of Sight  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_MELEECOMBATSTRENGTH_HEADING3_TITLE` — Resolving Melee Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_MELEERESULTS_HEADING3_TITLE` — Melee Combat Results  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_MELEE_HEADING2_TITLE` — Melee Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_METHODSOFXP_HEADING3_TITLE` — Other Methods of Getting XPs  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_MULTIPLECOMBAT_HEADING3_TITLE` — Multiple Units in Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_NAVALDAMAGE_HEADING3_BODY` — Naval units cannot heal unless in Friendly territory, where they heal 20 HPs per turn.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_NAVALDAMAGE_HEADING3_TITLE` — Naval Units Healing Damage  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_NAVAL_HEADING2_TITLE` — Naval Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_PROMOTIONSLIST_HEADING3_TITLE` — Promotions List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_RANGECOMBATSTRENGTH_HEADING3_TITLE` — Ranged Combat Strength  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_RANGEDSTRENGTH_HEADING3_TITLE` — Ranged Combat Strength  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_RANGED_HEADING2_TITLE` — Ranged Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_RANGESTAT_HEADING3_TITLE` — Range  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_RANGE_HEADING3_TITLE` — Range  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_RECEIVEWAR_HEADING3_TITLE` — An Enemy Declaration of War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_SEIGEWEAPONS_HEADING2_TITLE` — Siege Weapons  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_SPECIALCITYCAPTURE_HEADING4_TITLE` — Special City Capture Rules  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_TERRAINBONUS_HEADING3_TITLE` — Terrain Bonuses  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_UNITCOMBATSTATS_HEADING2_TITLE` — Unit Combat Statistics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMBAT_WHICHUNITSFIGHT_HEADING2_TITLE` — Which Units Can Fight  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_COMMERCE_TITLE` — Doge {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_CONCEPT_CITY_STATE_BULLYING_ADVISOR_QUESTION` — How do you ask for tribute?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_CITY_STATE_MERCANTILE_ADVISOR_QUESTION` — What does it mean for a city-state to be mercantile?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_CITY_STATE_RELIGIOUS_ADVISOR_QUESTION` — What does it mean for a city-state to be religious?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_COUNTER_INTEL_ADVISOR_QUESTION` — How do I stop other spies?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_GETTING_CAUGHT_ADVISOR_QUESTION` — How do I find out if someone is spying on me?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_GREAT_FIREWALL_ADVISOR_QUESTION` — How can I slow the progress of an enemy spy?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_MORE_ADVISOR_QUESTION` — How do I get more spies?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_MOVING_SPIES_ADVISOR_QUESTION` — How do I move my spies?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_NATIONAL_INTELLIGENCE_ADVISOR_QUESTION` — How can I get additional spies?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_POLICE_STATION_ADVISOR_QUESTION` — How can I slow the progress of an enemy spy?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_PROMOTIONS_ADVISOR_QUESTION` — Do my spies gain experience?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_RIG_ELECTION_ADVISOR_QUESTION` — How do I use spies with City-States?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_SPIES_ADVISOR_QUESTION` — What is a spy?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONCEPT_ESPIONAGE_SURVEILLANCE_ADVISOR_QUESTION` — How do I establish surveillance?  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_CONGRESS_DELEGATES_HEADING2_TITLE` — Delegates  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CONGRESS_HEADING2_TITLE` — {TXT_KEY_TOPIC_CONGRESS}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CONGRESS_INTRIGUE_HEADING2_TITLE` — Intrigue  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CONGRESS_PROJECTS_HEADING2_TITLE` — International Projects  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CONGRESS_SESSIONS_HEADING2_TITLE` — Sessions  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CONGRESS_TRADING_HEADING2_TITLE` — Trading Support  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CONGRESS_UN_HEADING2_TITLE` — United Nations  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CONGRESS_VICTORY_HEADING2_TITLE` — Diplomatic Victory  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CO_CIVILIZATION_HEADER` — CIVILIZATION  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_CLICK_TO_MOVE_TT` — Left click on great works to move them from location to another.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_CLICK_TO_VIEW_TT` — Left click on great works to view them.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_CULTURE_HEADER_TT` — [ICON_CULTURE] Culture Produced by this City  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_GREAT_WORK_HEADER` — [ICON_GREAT_WORK]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_GREAT_WORK_HEADER_TT` — [ICON_GREAT_WORK] Great Works in City  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_GREAT_WORK_SLOTS_TT_ENTRY` — {1_Num}/{2_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_INFLUENCE_MODIFIERS_HEADER_TT` — Modifiers to Tourism [ICON_TOURISM] output to target civ  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_INFLUENCE_PERCENT_HEADER_TT` — Lifetime [ICON_TOURISM] Tourism as a percentage of target civ's lifetime [ICON_CULTURE] Culture  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_INFLUENCE_TOURISM_HEADER_TT` — Adjusted Tourism [ICON_TOURISM] output  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_INFLUENTIAL_HEADER` — INFLUENTIAL  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_INFLUENTIAL_TURNS_TT` — Influential in {1_Num} Turns (assuming Tourism output remains unchanged)  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_LEVEL_HEADER` — LEVEL  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_MODIFIERS_HEADER` — +/- %  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_OPINION_TT_INFLUENCED_BY` — Influenced by the Ideology of these civs:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_OPINION_TT_UNHAPPINESS_LINE1` — Public Opinion is generating {1_Num} [ICON_HAPPINESS_4]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_PERCENT_HEADER` — [ICON_TOURISM] vs. [ICON_CULTURE]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_TOURISM_HEADER` — [ICON_TOURISM]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_TOURISM_HEADER_TT` — [ICON_TOURISM] Tourism Produced by this City  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_TREND_HEADER` — TREND  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_VICTORY_EXCESS_HAPPINESS_HEADER` — OVERALL [ICON_HAPPINESS_1]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_VICTORY_PUBLIC_OPINION_HEADER` — PUBLIC OPINION  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_VICTORY_PUBLIC_OPINION_UNHAPPINESS_HEADER` — [ICON_HAPPINESS_4]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CO_VICTORY_TOURISM_HEADER_TT` — [ICON_TOURISM] Tourism Produced by this Civilization  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CULTURE_ANTIQUITY_HEADING2_TITLE` — Antiquity Sites  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_ARCH_HEADING2_TITLE` — Archaeology  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_ARTIFACTS_HEADING2_TITLE` — Artifacts  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_EXPANDTERRITORY_HEADING2_TITLE` — Expanding Territory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CULTURE_GETTING_HEADING2_TITLE` — Getting Culture  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CULTURE_GREAT_WORKS_HEADING2_TITLE` — Great Works  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_GREAT_WORK_ART_HEADING2_TITLE` — Great Work of Art  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_GREAT_WORK_MUSIC_HEADING2_TITLE` — Great Work of Music  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_GREAT_WORK_WRITING_HEADING2_TITLE` — Great Work of Writing  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_HEADING1_TITLE` — Culture  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CULTURE_MANAGE_GREAT_WORKS_HEADING2_TITLE` — Managing Great Works  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_OVERVIEW_TT` — Culture Overview  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_CULTURE_TOURISM_AND_CULTURE_HEADING2_TITLE` — Tourism and the Culture Victory  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_TOURISM_BENEFITS_HEADING2_TITLE` — Benefits of Tourism  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_TOURISM_HEADING2_TITLE` — Tourism  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_CULTURE_VICTORY_HEADING2_TITLE` — Cultural Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_CURRENT_CULTURE_LABEL` — Current Culture: {1_Num} [ICON_CULTURE]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_DRAG_SPEED_TT` — Accelerates/Decelerates movement when dragging the map.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_EMPTY` — Empty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_EO_CITY_CIV_CITY_STATE_TT` — {1_CityName} is a [COLOR_POSITIVE_TEXT]{2_CityStateTraitAdj}[ENDCOLOR] City-State.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_CITY_CIV_TT` — {1_CityName} is controlled by {@2_CivShortDesc}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_CITY_NAME_CITY_STATE_TT` — {1_CityName} is a [COLOR_POSITIVE_TEXT]{2_CityStateTraitAdj}[ENDCOLOR] City-State.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_CITY_NAME_TT` — {1_CityName} is controlled by {@2_CivShortDesc}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_CITY_POPULATION_TT` — The population of {1_CityName} is {2_Num}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_PENALTY_TT` — Penalty From Gold Deficit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_EO_RELOCATE_TOOLTIP` — Relocate  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_EO_SPY_COUNTER_INTEL_SPY_RANK_TT` — {1_Num}% increased chance of killing enemy spies due to the rank of {2_RankName} {3_SpyName}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_SPY_COUNTER_INTEL_SUM_TT` — {1_Num}% total chance to kill enemy spy.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_SPY_COUP_DISABLED_WAIT_TT` — {1_SpyRank} {2_SpyName} may not attempt a coup in {3_CityName} yet because they have not completed surveillance there.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_SPY_COUP_DISABLED_YOU_ALLY_TT` — {1_SpyRank} {2_SpyName} may not attempt a coup in {3_CityName} because you are currently allies with the City-State!  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_SPY_LOCATION_TT` — {1_SpyRank} {2_SpyName} is currently in {3_CityName}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_SPY_NEEDS_ASSIGNMENT_TT` — Move your spy to a city so it can begin doing dastardly deeds.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_SPY_TRAVELLING_TT` — {1_RankName} {2_SpyName} is currently moving to {3_CityName}.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Inherited_Expansion2.xml`
- `TXT_KEY_EO_TITLE` — Espionage Overview  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_EO_VIEW_TOOLTIP` — View City  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_ESCAPE_TITLE` — Escape  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_EUROPEAN_TITLE` — {@1: gender feminine?Queen; other?King;} {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_EXIT_MOVE_TITLE` — Exit Move Mode  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_EXIT_TT` — Exit to windows.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_EXPERIENCE_POPUP` — [COLOR_XP_BLUE]+{1_Num} XP[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_EXPLORATION_TITLE` — Captain {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_FOGOFWAR_FOG_HEADING3_TITLE` — Fog of War on a Tile  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOGOFWAR_HEADING1_TITLE` — Fog of War  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOGOFWAR_INDIRECTFIRE_HEADING2_TITLE` — Indirect Fire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOGOFWAR_OBSCURINGTERRAIN_HEADING2_TITLE` — Obscuring Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOGOFWAR_REVEALED_HEADING3_TITLE` — Revealed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOGOFWAR_SEEN_HEADING2_TITLE` — What Is Seen  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOGOFWAR_THREESTATES_HEADING2_BODY` — The three states of tile visibility are visible, revealed, and fog of war.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOGOFWAR_THREESTATES_HEADING2_TITLE` — The Three States of Visibility  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOGOFWAR_VISIBLE_HEADING3_TITLE` — Visible  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_ASSIGNINGCITIZENS_HEADING3_TITLE` — Manually Assigning Citizens to Work the Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_BESTTILES_HEADING3_BODY` — The tile types that provide a lot of food include Oasis, Floodplains, and Grassland.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_BESTTILES_HEADING3_TITLE` — Best Food Tiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_BONUS_HEADING4_TITLE` — Bonus Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_BUCKET_HEADING3_TITLE` — The City Growth Bucket  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_BUILDINGWONDERSOCIAL_HEADING3_TITLE` — Buildings, Wonders and Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_CITIES_HEADING2_TITLE` — Cities and Food  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_CITYGROWTH_HEADING2_TITLE` — City Growth  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_FLOODPLAINS_HEADING4_BODY` — Flood plains provide a lot of food, particularly if improved with a farm.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_FLOODPLAINS_HEADING4_TITLE` — Flood Plains  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_GETFOOD_HEADING2_TITLE` — Getting More Food  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_GRASSLAND_HEADING4_BODY` — These tiles also provide a good amount of food.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_GRASSLAND_HEADING4_TITLE` — Grassland and Jungle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_HEADING1_TITLE` — Food and City Growth  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_IMPROVEMENTS_HEADING3_BODY` — Workers can construct farms on most tiles to improve their food output.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_IMPROVEMENTS_HEADING3_TITLE` — Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_MARITIME_HEADING3_TITLE` — Maritime City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_OASIS_HEADING4_BODY` — Oasis provide a lot of food, particularly when compared with the desert in which they're usually found.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_OASIS_HEADING4_TITLE` — Oasis  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_SETTLERS_HEADING2_TITLE` — Settlers And Food Production  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_UNHAPPINESS_HEADING3_TITLE` — City Unhappiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FOOD_WELOVEKING_HEADING3_TITLE` — We Love the King Day  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_FORCE_CONTROL_OPTIONS` — Force Game Options  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_FREEDOM_TITLE` — President {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_FREE_TENETS_LABEL` — Number of Free Tenets: {1_Num}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_GAME_OPTIONS` — GAME OPTIONS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_GOAL_TUTORIAL_1_ANCIENT_RUINS` — Find all {1_Num} Ancient Ruins.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_1_ANCIENT_RUINS_PROGRESS` — Explore all {1_Num} Ancient Ruins. ({2_Num} explored, {3_Num} remaining)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_2_DISCOVER_NATURAL_WONDERS` — Discover {1_Num} Natural Wonders.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_2_DISCOVER_NATURAL_WONDERS_COMPLETE` — Found {1_Num} Natural Wonders. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_2_DISCOVER_NATURAL_WONDERS_PROGRESS` — Discover {1_Num} Natural Wonders. ({2_Num} discovered, {3_Num} remaining)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_2_FOUND_CITIES` — Found {1_Num} cities.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_2_FOUND_CITIES_COMPLETE` — Found {1_Num} cities. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_2_FOUND_CITIES_PROGRESS` — Found {1_Num} cities. ({2_Num} founded, {3_Num} remaining)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_BUILD_FARMS` — Build {1_Num} farms that yield at least {2_Num} [ICON_FOOD] food.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_BUILD_FARMS_COMPLETE` — Build {1_Num} farms that yield at least {2_Num} [ICON_FOOD] food. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_BUILD_MINES` — Build {1_Num} mines that yield at least {2_Num} [ICON_PRODUCTION] production.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_BUILD_MINES_COMPLETE` — Build {1_Num} mines that yield at least {2_Num} [ICON_PRODUCTION] production. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_CONNECT_ROADS` — Connect {1_Num} cities using roads to your capital.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_CONNECT_ROADS_COMPLETE` — Connect {1_Num} cities using roads to your capital. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_CONNECT_ROADS_PROGRESS` — Connect {1_Num} cities using roads to your capital. ({2_Num} connected, {3_Num} remaining)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_IMPROVE_RESOURCES` — Build improvements on {1_Num} resources.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_IMPROVE_RESOURCES_COMPLETE` — Build improvements on {1_Num} resources. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_3_IMPROVE_RESOURCES_PROGRESS` — Build improvements on {1_Num} resources. ({2_Num} resources improved, {3_Num} remaining)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_4_CONQUER_CITY` — Conquer enemy city.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_4_CONQUER_CITY_COMPLETE` — Conquer enemy city. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_4_DESTROY_BARB_CAMPS` — Destroy {1_Num} barbarian camps.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_4_DESTROY_BARB_CAMPS_COMPLETE` — Destroy {1_Num} barbarian camps. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_4_DESTROY_BARB_CAMPS_PROGRESS` — Destroy {1_Num} barbarian camps. ({2_Num} have been destroyed, {3_Num} remaining)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_5_MOST_FAVORED_CIV` — Become allied with a City State by giving them [ICON_GOLD]gold and completing quests.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOAL_TUTORIAL_5_MOST_FAVORED_CIV_COMPLETE` — Become allied with a City State by giving them [ICON_GOLD]gold and completing quests. Complete!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_GOLD_ANCIENTRUINS_HEADING3_BODY` — An ancient ruin may provide gold when it is explored.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_ANCIENTRUINS_HEADING3_TITLE` — Ancient Ruins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_BARBARIAN_HEADING3_BODY` — You'll earn gold each time you disperse a Barbarian Encampment.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_BARBARIAN_HEADING3_TITLE` — Barbarian Encampment  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_BUILDINGS_HEADING3_TITLE` — Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_CAPTURE_HEADING3_BODY` — You may gain a bunch of gold when you capture a city (city-state or civilization's possession).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_CAPTURE_HEADING3_TITLE` — Capturing Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_CITYSTATES_HEADING3_TITLE` — City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_EXPENDING_HEADING2_BODY` — There's lots of stuff to spend gold on.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_EXPENDING_HEADING2_TITLE` — Expending Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_FLATFEE_HEADING4_BODY` — A "Flat Fee" exchange is just that. You give or receive a one-time lump sum of gold, and then you're done.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_FLATFEE_HEADING4_TITLE` — Flat Fee  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_HEADING1_TITLE` — Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_LOSECITY_HEADING3_BODY` — If a civilization or city-state captures one of your cities, they take some of your gold (as well as the city).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_LOSECITY_HEADING3_TITLE` — Losing a City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_MAINTENANCE_HEADING3_TITLE` — Unit and Building Maintenance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_PILLAGE_HEADING3_BODY` — Pillaging an enemy improvement will heal your unit by 25 points, as well as give you a modest amount of gold.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_PILLAGE_HEADING3_TITLE` — Pillage Enemy Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_PLUNDERED_HEADING3_TITLE` — Getting Plundered  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_PURCHASETILES_ADV_QUEST` — How can you expand your borders using gold?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_PURCHASETILES_HEADING3_TITLE` — Purchase Tiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_PURCHASEUNITS_ADV_QUEST` — How can you use gold to units, buildings, or wonders?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_PURCHASEUNITS_HEADING3_TITLE` — Buying Units, Buildings or Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_RESOURCES_HEADING3_BODY` — All Luxury resources (especially gold!) provide gold when worked.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_RESOURCES_HEADING3_TITLE` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_ROAD_HEADING3_TITLE` — Road Maintenance  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_RUNNINGOUT_HEADING2_TITLE` — Running Out of Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_TERRAIN_HEADING3_TITLE` — Terrain Types and Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_TRADEMISSION_HEADING3_TITLE` — Perform a "Trade Mission"  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_TRADINGPOST_HEADING3_BODY` — Construct a trading post improvement in a tile to increase its gold output.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_TRADINGPOST_HEADING3_TITLE` — The Trading Post  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_UPGRADE_UNITS_HEADING3_TITLE` — Upgrading Obsolete Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_WHERETOGET_HEADING2_TITLE` — Where To Get Gold  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GOLD_WONDERS_HEADING3_TITLE` — Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_GREAT_PERSON_F_SCOTT_FITZGERALD` — F. Scott Fitzgerald  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Units_Expansion2.xml`
- `TXT_KEY_GREAT_WORK_SLOT_ART_ARTIFACT_EMPTY_TOOLTIP` — Empty Great Work of Art or Artifact Slot  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion2.xml`
- `TXT_KEY_GREAT_WORK_SLOT_ART_ARTIFACT_SLOTS_TOOLTIP` — [ICON_GREAT_WORK] Great Work of Art or Artifact slots: {1_NumSlots}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_GREAT_WORK_SLOT_LITERATURE_EMPTY_TOOLTIP` — Empty Great Work of Writing Slot  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion2.xml`
- `TXT_KEY_GREAT_WORK_SLOT_LITERATURE_SLOTS_TOOLTIP` — [ICON_GREAT_WORK] Great Work of Writing slots: {1_NumSlots}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_GREAT_WORK_SLOT_MUSIC_EMPTY_TOOLTIP` — Empty Great Work of Music Slot  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion2.xml`
- `TXT_KEY_GREAT_WORK_SLOT_MUSIC_SLOTS_TOOLTIP` — [ICON_GREAT_WORK] Great Work of Music slots: {1_NumSlots}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_HALL_OF_FAME` — HALL OF FAME  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_HALL_OF_FAME_EMPTY` — You have not yet completed any games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_HALL_OF_FAME_TT` — Highest scores.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_HANDICAP_SUPPLY_TT` — Provided by Difficulty Setting  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_HAPPINESS_CAUSESUNHAPPINESS_HEADING2_TITLE` — What Causes Unhappiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_HAPPINESS_CAUSES_HEADING2_TITLE` — What Causes Happiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_HAPPINESS_HEADING1_TITLE` — Happiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_HAPPINESS_LEVELSUNHAPPINESS_HEADING2_TITLE` — Levels of Unhappiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_HAPPINESS_REVOLT_HEADING3_TITLE` — Revolt  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_HAPPINESS_STARTING_HEADING2_TITLE` — Starting Happiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_HAPPINESS_UNHAPPY_HEADING3_ADV_QUEST` — What does an "unhappy" population mean?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_HAPPINESS_UNHAPPY_HEADING3_TITLE` — Unhappy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_HAPPINESS_VERYUNHAPPY_HEADING3_TITLE` — Unrest  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_HOF_SETTINGS` — Settings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_IMPROVEMENT_GOODY_HUT` — Ancient Ruins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_INVALID_MAP_TITLE` — [COLOR_RED]{1_MapName}[ENDCOLOR]  
  source: `Gameplay/XML/NewText/EN_US/Modding/CIV5ModdingText.xml`
- `TXT_KEY_LATEST_NEWS_TT` — Read the Latest News (Requires Active Internet Connection).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD` — LEADERBOARDS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_CIV5BASE_NAME` — Civilization 5  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_CIV5EXP1_NAME` — Gods & Kings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_CIV5EXP2_NAME` — Brave New World  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_GLOBAL` — GLOBAL  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_GLOBAL_TT` — Display leaderboard of the top players in the world.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_PERSONAL` — PERSONAL  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_PERSONAL_TT` — Display leaderboard of your position on the global leaderboard.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_PULLDOWN` — Leaderboards  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_PULLDOWN_TT` — Leaderboards for all currently installed game content, DLC, and mods.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_RANKING` — Ranking  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_REFRESH_TT` — Retrieve the latest leaderboard scores.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEADERBOARD_TT` — Compare scores with your friends and the world (Requires Active Internet Connection).  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_EFFECT_SUMMARY_TITLE` — Current Effects  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_PROPOSAL_ON_HOLD_TT` — This proposal is on hold until the World Congress concludes its Special Session.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_OVERVIEW_RENAME_TT` — Choose a new name for the World Congress  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LEAGUE_SPLASH_TITLE_FOUNDED` — World Congress Founded  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Leagues_Expansion2.xml`
- `TXT_KEY_LIBERTY_TITLE` — Consul {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_LIST_LOBBIES_INTERNET_TT` — Steam Lobbies on the Internet.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LIST_SERVERS_FAVORITES_TT` — Steam Dedicated Servers marked as Favorites.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LIST_SERVERS_INTERNET_TT` — Steam Dedicated Servers on the Internet.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_LIST_SERVERS_LAN_TT` — Steam Dedicated Servers on the local LAN.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_AMER_TITLE` — Americas  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_MapAmer.xml`
- `TXT_KEY_MAP_ASIA_TITLE` — Asia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_MapAsia.xml`
- `TXT_KEY_MAP_EARTH_TITLE` — Earth  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MAP_FOLDER_DLC_1_TITLE` — Explorers  
  source: `DLC/Shared/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_DLC_SP_Maps.xml`
- `TXT_KEY_MAP_FOLDER_DLC_2_TITLE` — Scrambled Continents  
  source: `DLC/Shared/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_DLC_SP_Maps_2.xml`
- `TXT_KEY_MAP_FOLDER_DLC_3_TITLE` — Scrambled Nations  
  source: `DLC/Shared/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_DLC_SP_Maps_3.xml`
- `TXT_KEY_MAP_MED_TITLE` — Mediterranean  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_MapMed.xml`
- `TXT_KEY_MAP_MESO_TITLE` — Mesopotamia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_MapMeso.xml`
- `TXT_KEY_MAP_OPTIONS` — Map Options  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_MAP_TITLE` — Select Modded Map  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MAP_TYPE_TITLE` — Select Map Type  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MISSION_ENHANCE_RELIGION` — Enhance Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_MISSION_FOUND_RELIGION` — Found a Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_MODS_TT` — Access User-Created Mods  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_MOVEMENT_ATTACKORDERS_HEADING3_TITLE` — Attack Orders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_COMBAT_HEADING2_BODY` — Movement rules are modified when enemy forces are involved.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_COMBAT_HEADING2_TITLE` — Movement During Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_CONTROLZONES_HEADING3_TITLE` — Zones of Control  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_EMBARKING_HEADING3_TITLE` — Embarking Land Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_EXPENDINGPOINTS_HEADING3_TITLE` — Expending Movement Points  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_HEADING1_TITLE` — Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_HOWTOORDER_HEADING2_BODY` — There are two ways to move a unit: using right-click and move mode.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_HOWTOORDER_HEADING2_TITLE` — How to Order a Unit to Move  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_MOVEMODE_HEADING3_BODY` — You can also click on the "Move Mode" Action button, then left-click on a target space.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_MOVEMODE_HEADING3_TITLE` — Move Mode  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_NAVAL_HEADING2_TITLE` — Naval Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_POINTS_HEADING2_TITLE` — Movement Points  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_RAILANDROADS_HEADING2_TITLE` — Road and Railroads  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_RIGHTCLICK_HEADING3_BODY` — When a unit is active, you can right-click anywhere on the map to order the unit to move there.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_RIGHTCLICK_HEADING3_TITLE` — Right-Click  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_RIVERS_HEADING3_TITLE` — Rivers and Roads/Railroads  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVEMENT_STACKINGLIMITS_HEADING3_TITLE` — Stacking Limitations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_MOVE_SPY_INSTRUCTIONS` — Choose a city to move {1_SpyRank} {2_SpyName} into to begin operations.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Espionage_Expansion.xml`
- `TXT_KEY_MOVE_STACKED_UNIT_TT` — Select a unit that is stacked with another unit of the same type.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_MOVE_TITLE` — Moving Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_MULTIPLAYER` — MULTIPLAYER  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_NAME_CITY_TITLE` — Name Your City!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_NAME_CIV_TITLE` — Name Your Civilization!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_NAME_UNIT_TITLE` — Name Your Unit!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_NUMBER_OF_CITIES_HANDICAP_TT` — Because of the game's current difficulty level, they produce {1_Num}% less than usual.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_NUMBER_OF_CITIES_TT` — Every (non-occupied) City produces 3 [ICON_HAPPINESS_4] Unhappiness.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_NUMBER_OF_OCCUPIED_CITIES_TT` — Every [ICON_OCCUPIED] Occupied City produces 5 [ICON_HAPPINESS_4] Unhappiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OCCUPIED_POP_UNHAPPINESS_TT` — Every [ICON_CITIZEN] Citizen in an [ICON_OCCUPIED] Occupied City produces 1.34 [ICON_HAPPINESS_4] Unhappiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_ADVISOR_COUNSEL` — Advisor Counsel Popup  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_ADVISOR_COUNSEL_TT` — Periodic Advice From Your Counsel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_AUTOSIZE_UI_TT` — The game picks the interface size it believes fits your screen resolution best.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_AUTO_WORKERS_DONT_REPLACE_TT` — Automated workers don't replace existing improvements.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_CIVILIAN_YIELDS_TT` — Display on-map Yield information when Civilian Units are selected.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_DYNAMIC_BORDERS_TT` — Enables advanced culture borders. It is more taxing on your computer hardware.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_DYNAMIC_CAMERA_ZOOM_TT` — When zooming OUT, the camera will pull straight back instead of remaining anchored to the cursor.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_ENABLE_MAP_INERTIA_TT` — Enables inertia when dragging the map.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_FADE_SHADOWS_TT` — Allow shadows to fade out at far zooms. Improves performance at those zoom levels.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_GPU_TEXTURE_DECODE_TT` — The GPU will be used to decode compressed textures when appropriate.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MAX_AUTOSAVES_KEPT` — Max Autosaves Kept:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MAX_AUTOSAVES_KEPT_TT` — The largest number of autosaves kept before the game begins deleting old ones.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_MINIMIZE_GRAY_TILES_TT` — Minimize gray tiles seen while scrolling around the map. This can cause stuttering.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_ONE_UNIT_TT` — Display Only One Unit In A Group  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_QUICK_COMBAT_TT` — Resolve Combat Without Animations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_QUICK_MOVEMENT_TT` — Units move instantly to their destination  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_RESET_TUTORIAL_TT` — Resets the Advisor system so that all the Advisor messages will reappear.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_RESTART_REQ_TT` — You Must Restart For Changes To Take Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SCORE_LIST_TT` — Display the simple score list in single player games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SETTINGS_HIGH` — High  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SETTINGS_LOW` — Low  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SETTINGS_MEDIUM` — Medium  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SETTINGS_MINIMUM` — Minimum  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SETTINGS_OFF` — Off  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SPLAYER_QUICK_COMBAT_TT` — Enables quick combat resolution in single player games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_SPLAYER_QUICK_MOVEMENT_TT` — Enables quick unit movement in single player games.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURNS_FOR_AUTOSAVES` — Turns Between Autosave:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TURNS_FOR_AUTOSAVES_TT` — How often the game automatically saves the game.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TUTORIAL_HIGH` — Experienced Player  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TUTORIAL_LEVEL` — Advisor Level  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TUTORIAL_LEVEL_TT` — Amount of advice you receive from your Advisors.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TUTORIAL_LOW` — New to Civ  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TUTORIAL_MEDIUM` — New to Civ 5  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_TUTORIAL_NEW_TO_XP` — New to Expansion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_OPSCREEN_TUTORIAL_NEW_TO_XP2` — New to Brave New World  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_OPSCREEN_TUTORIAL_OFF` — No Advice  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPSCREEN_USE_SMALL_UI_TT` — Forces the game to use the smaller version of the interface.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_OPTIONS` — OPTIONS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_ORDER_TITLE` — Chairman {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_OTHER_TT` — Other information  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_PATRONAGE_TITLE` — {1_PlayerName:textkey} the Enlightened of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_PEACE_BLOCKED_CSTATE_TT` — You are at war with the ally of {1_CityStateName:textkey}, which means it will not make peace with you!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PEDIA_ABILITIES_LABEL` — Special Abilities:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_ALWAYS_VISIBLE` — Always Visible  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_A_OR_B` — {@1_a} or {@2_b}  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_BLDG_UNLOCK_LABEL` — Buildings Unlocked:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_BUILDINGS_PAGE_LABEL` — Buildings Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_10_LABEL` — Civilizations and Leaders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_11_LABEL` — City-States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_12_LABEL` — Terrain and Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_13_LABEL` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_14_LABEL` — Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_15_LABEL` — Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_CATEGORY_16_LABEL` — World Congress  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_CATEGORY_1_LABEL` — Civilopedia Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_2_LABEL` — Game Concepts  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_3_LABEL` — Technologies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_4_LABEL` — Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_5_LABEL` — Promotions  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_6_LABEL` — Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_7_LABEL` — Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_8_LABEL` — Social Policies  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CATEGORY_9_LABEL` — Specialists and Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CITY_STATES_PAGE_LABEL` — City-States Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CIVILIZATIONS_LABEL` — Civilization:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CIVILIZATIONS_PAGE_LABEL` — Civ and Leaders Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CIVILIZATION_ADJECTIVE` — Civilization Adjective  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CIVILIZATION_NAME` — Civilization Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CIVILIZATION_SHORT_NAME` — Civilization Short Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_COMBATTYPE_LABEL` — Combat Type:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_COMBAT_LABEL` — Combat:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_COST_LABEL` — Cost:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_CULTURE_LABEL` — Culture:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_DEFENSE_HITPOINTS` — +{1_DefenseHP} HP  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_DEFENSE_LABEL` — Defense:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_EXTENDED_LABEL` — Extended Information:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_FACTOID` — Factoid  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_FAITH_LABEL` — Faith:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_FEATURES_LABEL` — Features on:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_FEATURE_NAME` — Feature Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_FOOD_LABEL` — Food:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_FOUNDON_LABEL` — Can Be Built On:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_FREEPROMOTIONS_LABEL` — Abilities:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_GAME_CONCEPT_PAGE_LABEL` — Game Concepts Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_GAME_INFO_LABEL` — Game Info:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_GOLD_LABEL` — Gold:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_GP_LABEL` — Great People:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_GREAT_WORKS_LABEL` — Great Works:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_HAPPINESS_LABEL` — Happiness:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_HISTORICAL_LABEL` — Historical Info:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_HOME_PAGE_LABEL` — Civilopedia Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_HOME_PAGE_VERSION_LABEL` — Version Information  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_HOME_PAGE_VERSION_TEXT` — You are currently running Civilization V v.1.0.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_IMPASSABLE` — Impassable  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_IMPROVEMENTS_LABEL` — Improved by:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_IMPROVEMENTS_PAGE_LABEL` — Improvements Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_IMPROVEMENT_NAME` — Improvement Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_IMPROVES_RESRC_LABEL` — Improves Resources:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_LEADERS_LABEL` — Leaders:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_LEADER_NAME` — Leader Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_LEADS_TO_TECH_LABEL` — Leads to Techs:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_LEAGUE_PROJECT_REWARD` — {1_TrophyIcon} {2_RewardDescription}: {3_RewardHelp}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_LIVED_LABEL` — Lived:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_LOCAL_RESOURCE_NAME` — Local Resource Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_LOCAL_RESRC_LABEL` — Local Resources Required:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_MAINT_LABEL` — Maintenance:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_MOUNTAINADJYIELD_LABEL` — Nearby Mountain Bonus:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_MOVECOST_LABEL` — Movement Cost:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_MOVEMENT_LABEL` — Movement:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_OBSOLETE_TECH_LABEL` — Becomes Obsolete with:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PEOPLE_PAGE_LABEL` — Specialists and Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_POLICYBRANCH_LABEL` — Policy Branch:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PREREQ_ERA_LABEL` — Prerequisite Era:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PREREQ_TECH_LABEL` — Prerequisite Techs:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PROJ_UNLOCK_LABEL` — Projects Unlocked:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PROMOTIONS_PAGE_LABEL` — Promotions Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PROMOTION_AIR_RECON` — Air Recon  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_AIR_SWEEP` — Air Sweep  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ANTI_AIR` — Bonus vs Aircraft/Helicopters (150)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ANTI_FIGHTER` — Bonus vs Fighters (33)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ANTI_HELICOPTER` — Bonus vs Helicopters (150)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ANTI_MOUNTED_I` — Bonus vs Mounted (50)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ANTI_MOUNTED_II` — Bonus vs Mounted (100)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ANTI_SUBMARINE_I` — Bonus vs Submarines (33)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ANTI_SUBMARINE_II` — Bonus vs Submarines (100)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ANTI_TANK` — Bonus vs Tanks (100)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ATTACK_BONUS` — Combat Bonus When Attacking (25)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CAN_MOVE_AFTER_ATTACKING` — Can Move After Attacking  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CAN_MOVE_IMPASSABLE` — May Enter Ice Tiles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CARGO_I` — Can Carry 1 Cargo  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CARGO_II` — Can Carry 2 Cargo  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CARGO_III` — Can Carry 3 Cargo  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CARGO_IV` — Can Carry 4 Cargo  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CITY_ASSUALT` — Bonus vs Cities (300)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CITY_PENALTY` — Penalty Attacking Cities (33)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_CITY_SIEGE` — Bonus vs Cities (200)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_DEFENSE_PENALTY` — Penalty on Defense (33)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_EVASION_I` — Evasion (50)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_EVASION_II` — Evasion (100)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_FASTER_HEAL` — Heals at Double Rate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_FLAT_MOVEMENT_COST` — All Tiles Cost 1 Move  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_FOLIAGE_IMPASSABLE` — Cannot Enter Forest or Jungle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_FOREIGN_LANDS` — Foreign Lands Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_FREE_PILLAGE_MOVES` — Free Pillage  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_GREAT_GENERAL` — Leadership  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_HEAL_IF_DESTROY_ENEMY` — Heals 50 Damage If Kills a Unit  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_HOVERING_UNIT` — Hovering Unit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_INTERCEPTION_I` — Interception (20)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_INTERCEPTION_II` — Interception (40)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_INTERCEPTION_III` — Interception (50)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_INTERCEPTION_IV` — Interception (100)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_INVISIBLE_SUBMARINE` — Is Invisible (Submarine)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_JAGUAR` — Combat Bonus in Forest/Jungle (33)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_MOHAWK` — Combat Bonus in Forest/Jungle (33)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_MOUNTED_PENALTY` — Penalty vs Mounted (33)  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_MUST_SET_UP` — Must Set Up to Ranged Attack  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_NAME` — Promotion Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_PROMOTION_NAVAL_PENALTY` — Penalty vs Naval  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_OCEAN_IMPASSABLE` — Cannot Enter Deep Ocean  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_OCEAN_IMPASSABLE_ASTRO` — Astronomy Needed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_OCEAN_MOVEMENT` — Naval Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ONLY_DEFENSIVE` — May Not Melee Attack  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_OPEN_TERRAIN` — Combat Bonus in Open Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_PARADROP` — May Paradrop  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_PARTIAL_HEAL_IF_DESTROY_ENEMY` — Heals 25 Damage If Kills a Unit  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_RANGED_SUPPORT_FIRE` — Ranged Support Fire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_RIVAL_TERRITORY` — Can Enter Rival Territory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_ROUGH_TERRAIN_ENDS` — Rough Terrain Penalty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_SCURVY` — Loses Health outside Friendly Lands  
  source: `DLC/DLC_02/Gameplay/XML/Text/en_US/CIV5GameTextInfos_NewWorldScenario.xml`, `DLC/DLC_07/Gameplay/XML/Text/EN_US/CIV5GameTextInfos_NewWorldDeluxeScenario.XML`
- `TXT_KEY_PEDIA_PROMOTION_SECOND_ATTACK` — May Attack Twice  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_SEE_INVISIBLE_SUBMARINE` — Can See Submarines  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_SIGHT_PENALTY` — Limited Visibility  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_SPAWN_GENERALS_I` — Great Generals I  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_SPAWN_GENERALS_II` — Great Generals II  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_STRONGER_VS_DAMAGED` — Damaged Enemy Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_WEAK_RANGED` — Weak Ranged Attack  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_XTRA_MOVES_I` — 1 Extra Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_XTRA_SIGHT_I` — Extra Sight (1)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_XTRA_SIGHT_II` — Extra Sight (2)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_XTRA_SIGHT_III` — Extra Sight (3)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_PROMOTION_XTRA_SIGHT_IV` — Extra Sight (4)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_PEDIA_RANGEDCOMBAT_LABEL` — Ranged Combat:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_RANGE_LABEL` — Range:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_RELATED_ARTICLES_LABEL` — Related Articles:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_RELATED_IMAGES_LABEL` — Related Images:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_RELIGIOUS` — Religious  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Inherited_Expansion2.xml`
- `TXT_KEY_PEDIA_REPLACES_LABEL` — Replaces:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_REPLACE_NAME` — Replace Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_REQUIRED_BUILDING_NAME` — Required Building Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_REQ_BLDG_LABEL` — Required Buildings:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_REQ_PROMOTIONS_LABEL` — Required Promotions:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_REQ_RESRC_LABEL` — Required Resources:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_RESOURCESFOUND_LABEL` — Resources Found On:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_RESOURCES_PAGE_LABEL` — Resources Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_RESOURCE_NAME` — Resource Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_RESRC_RVL_LABEL` — Resources Revealed:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_REVEAL_TECH_LABEL` — Revealed by:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_SCIENCE_LABEL` — Science:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_SOUND_BITE_LABEL` — Play Sound Bite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_SPEC_LABEL` — Specialists:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_SPEC_NAME` — Specialist Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_SUMMARY_LABEL` — Summary:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TECH_PAGE_LABEL` — Technologies Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TECH_SECTION` — Technology Section  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TENET_LEVEL` — Ideological Tenet Level  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_TERRAINS_LABEL` — Terrains Found On:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TERRAIN_FEATURES_LABEL` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TERRAIN_LABEL` — Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TERRAIN_NAME` — Terrain Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TERRAIN_PAGE_LABEL` — Terrain Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TITLES_LABEL` — Titles:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TRAITS_LABEL` — Unique Traits:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_TRAIT_NAME` — Trait Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNIQUEBLDG_LABEL` — Unique Buildings:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNIQUEBLDG_NAME` — Unique Building Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNIQUEIMPRV_LABEL` — Unique Improvements:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNIQUEIMPR_NAME` — Unique Improvement Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNIQUEUNIT_LABEL` — Unique Units:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNIQUEUNIT_NAME` — Unique Unit Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNITS_PAGE_LABEL` — Units Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNIT_UNLOCK_LABEL` — Units Unlocked:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNLKED_PROJECT_NAME` — Unlocked Project Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_UNLOCKED_UNIT_NAME` — Unlocked Unit Name  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_WONDERS_PAGE_LABEL` — Wonders Home Page  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_WORKER_ACTION_LABEL` — Worker Actions Allowed:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_WORKER_ACTION_NAME` — "Worker Action Name"  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PEDIA_WORLD_CONGRESS_CATEGORY_1` — Resolutions  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_WORLD_CONGRESS_CATEGORY_2` — International Projects  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_WORLD_CONGRESS_CATEGORY_3` — Special Sessions  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_WORLD_CONGRESS_HOMEPAGE_LABEL1` — World Congress  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_WORLD_CONGRESS_PAGE_LABEL` — World Congress Home Page  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_PEDIA_YIELD_LABEL` — Yields:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_PERMANENT_WAR_CSTATE_TT` — You have attacked so many City-States that {1_CityStateName:textkey} will never make peace with you!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PIETY_TITLE` — {1_PlayerName:textkey} the Pious of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_PINCH_SPEED_TT` — Accelerates/Decelerates movement when zooming the map.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_PLEASE_WAIT_TT` — The game is currently processing other players' turns.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POLICYSCREEN_NEED_L1_TENETS_TOOLTIP` — [COLOR_NEGATIVE_TEXT]Need one more Level 1 tenet to unlock the ability to gain this Level 2 tenet.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_POLICYSCREEN_NEED_L2_TENETS_TOOLTIP` — [COLOR_NEGATIVE_TEXT]Need one more Level 2 tenet to unlock the ability to gain this Level 3 tenet.[ENDCOLOR]  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Jon_Expansion2.xml`
- `TXT_KEY_POPULATION_SUPPLY_TT` — Provided by Total Population  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_POP_CSTATE_GIFT_GOLD_TT` — You may spend [ICON_GOLD] Gold to improve your [ICON_INFLUENCE] Influence with this City-State.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_POP_CSTATE_STOP_UNITS_TT` — Clicking this will tell the Militaristic City State to either stop or resume gifting Units to you.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_POP_NEW_ERA_DESCRIPTION` — Welcome to the {@1_EraDescription}!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_NEW_ERA_TITLE` — New Era  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_STRATEGIC_VIEW_TT` — Toggles between the Strategic View and Normal Game View.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_UNHAPPINESS_TT` — Every [ICON_CITIZEN] Citizen in a (non-occupied) City produces 1 [ICON_HAPPINESS_4] Unhappiness  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_POP_UN_ELEC_VOTE_TT_CIV_ALT` — {@1_VotingCivName} voted for {@2_RecipientCivName}, the Civilization it has best relations with.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Inherited_Expansion2.xml`
- `TXT_KEY_POP_UN_TEAM_LABEL` — Team {1_TeamNum}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_VOTE_RESULTS_UNMET_PLAYER` — Unmet Player  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_VOTE_RESULTS_UNMET_TEAM` — Unmet Team  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_VOTE_RESULTS_YOU` — You  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_POP_VOTE_RESULTS_YOUR_TEAM` — Your Team  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_PROGRESS_SCREEN_CITY_TOURISM_TT` — Ranks cities by [ICON_TOURISM] Tourism output.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_PROGRESS_SCREEN_CULTURAL_INFLUENCE_TT` — Ranks players by the number of Civs over whom their [ICON_CULTURE] Culture has become Influential.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_PROGRESS_SCREEN_CULTURE_TT` — Ranks players by the number of Social Policies they've adopted.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PROGRESS_SCREEN_FOOD_TT` — Ranks players by the average [ICON_FOOD] Food surplus in all of their cities.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PROGRESS_SCREEN_GOLD_TT` — Ranks players by the amount of [ICON_GOLD] Gold in their treasury.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PROGRESS_SCREEN_HAPPINESS_TT` — Ranks players by how [ICON_HAPPINESS_1] Happy their people are.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PROGRESS_SCREEN_POWER_TT` — Ranks players by their military power.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PROGRESS_SCREEN_SCIENCE_TT` — Ranks players by the number of Technologies they possess.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PROGRESS_SCREEN_TITLE` — {1_Name:textkey} has completed his greatest work, the list of:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PROGRESS_SCREEN_WONDERS_TT` — Ranks players by the number of Wonders they've constructed.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_PROMOTION_GOODY_HUT_PICKER` — Native Tongue  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion2.xml`
- `TXT_KEY_RANKING_TITLE` — RANKING  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_RATIONALISM_TITLE` — {1_PlayerName:textkey} the Wise of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_REFRESH_GAME_LIST_TT` — Return to Game Setup  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_RESOURCES_BONUSLIST_HEADING3_TITLE` — Bonus (Improvement Needed)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_BONUS_HEADING2_BODY` — Bonus resources increase the food and gold output of a hex. Bonus resources cannot be traded to other civilizations.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_BONUS_HEADING2_TITLE` — Bonus Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_CITYREQUESTS_HEADING3_TITLE` — "We Love the King Day"  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_HEADING1_TITLE` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_LIST_HEADING2_TITLE` — Resource List  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_LUXURYLIST_HEADING3_TITLE` — Luxury (Improvement Needed)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_LUXURY_HEADING2_TITLE` — Luxury Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_STRATEGICLIST_HEADING3_TITLE` — Strategic (Improvement Needed)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RESOURCES_STRATEGIC_HEADING2_TITLE` — Strategic Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_RETIRE` — Retire  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Jon.xml`
- `TXT_KEY_RETURN` — Return  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_RO_AUTO_FAITH_PROMPT` — Remind me later  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_RO_AUTO_FAITH_PURCHASE` — Automatic [ICON_PEACE] Faith Purchase:  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_RO_FAITH_TOOLTIP` — Need minimum of {1_MinFaith} [ICON_PEACE] Faith for next Great Prophet  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Inherited_Expansion2.xml`
- `TXT_KEY_SCORE_CURRENTSCORE_HEADING2_TITLE` — Your Current Score  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SCORE_ELIMINATION_HEADING2_BODY` — If you are eliminated from the game, your score is zero. (Sorry.)  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SCORE_ELIMINATION_HEADING2_TITLE` — Elimination  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SCORE_HEADING1_TITLE` — Game Score  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SCORE_MAPSIZE_HEADING3_TITLE` — Map Size and Game Difficulty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SCORE_TIMETOVICTORY_HEADING2_BODY` — If you achieve victory before 2050, you receive a "score multiplier." The earlier the victory, the better.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SCORE_TIMETOVICTORY_HEADING2_TITLE` — Time to Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SCORE_VICTORYPOINTS_HEADING2_TITLE` — Victory Points  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SCRAMBLE_AFRICA_CIV_BELGIUM_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_CIV_BOERS_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_CIV_ITALY_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_EUROPEAN_TITLE` — Most esteemed {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_AHMAD_ALMANSUR_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_AHMAD_ALMANSUR_SUBTITLE` — Sultan of Morocco  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_AUGUSTUS_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_AUGUSTUS_SUBTITLE` — General, Politician of Italy  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_BISMARCK_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_BISMARCK_SUBTITLE` — Chancellor of the German Empire  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_ELIZABETH_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_ELIZABETH_SUBTITLE` — Queen of the United Kingdom  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_MARIA_I_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_MARIA_I_SUBTITLE` — Queen Consort of Portugal  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_NAPOLEON_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_NAPOLEON_SUBTITLE` — President of France  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_PEDRO_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_PEDRO_SUBTITLE` — King of the Belgians and the Congo  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_RAMESSES_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_RAMESSES_SUBTITLE` — Khedive of Egypt and Sudan  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_SELASSIE_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_SELASSIE_SUBTITLE` — Emperor of Ethiopia  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_SHAKA_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_SHAKA_SUBTITLE` — King of the Zulu Kingdom  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_SULEIMAN_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_SULEIMAN_SUBTITLE` — Sultan of the Ottoman Empire  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_WASHINGTON_HEADING_1` — History  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_LEADER_WASHINGTON_SUBTITLE` — President of the South African Republic  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_N_AFRICAN_TITLE` — {1_PlayerName:textkey}, Sovereign of {2_CivName:textkey}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_SUB_SAHARAN_TITLE` — {1_PlayerName:textkey} the Bold of {2_CivName:textkey}  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCRAMBLE_AFRICA_TITLE` — Scramble for Africa  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_ScrambleAfricaScenario.XML`
- `TXT_KEY_SCROLLING_TITLE` — Scrolling and Panning  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_SEARCH` — Search  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SLOTTYPE_AI_TT` — AI Player  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_SLOTTYPE_HUMANREQ_TT` — Human Required slots require a human player before the game can start.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_SLOTTYPE_HUMAN_TT` — Human Player  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_SLOTTYPE_OBSERVER_TT` — Observers view the game without participating as a civilization.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_SLOTTYPE_OPEN_TT` — Open slots can be occupied by joining players.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_SPECIALISTSANDGP_ABILITIES_HEADING3_TITLE` — Great Peoples' Abilities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_ACADEMY_HEADING4_TITLE` — Special Improvement: Academy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_ARTIST_HEADING3_TITLE` — Artist  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_ART_CREATEGW_HEADING4_TITLE` — Special Ability: Great Work  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_ASSIGNING_HEADING3_TITLE` — Assigning Specialists  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_CITADEL_HEADING4_TITLE` — Special Improvement: Citadel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_COMBATBONUS_HEADING4_TITLE` — Special Ability: Combat Bonus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_CONCERT_TOUR_HEADING4_TITLE` — Special Ability: Concert Tour  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_CULTUREBOMB_HEADING4_TITLE` — Special Ability: Golden Age  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_CUSTOMSHOUSE_HEADING4_TITLE` — Special Improvement: Custom House  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_EFFECTSOFASSIGNING_HEADING3_TITLE` — Effects of Assigning Specialists  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_ENGINEER_HEADING3_TITLE` — Engineer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GENERATING_HEADING3_TITLE` — Generating Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GOLDENAGE_HEADING4_TITLE` — Golden Age  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATADMIRAL_ABILITY2_TITLE` — Special Ability: Repair Fleet  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATADMIRAL_ABILITY_TITLE` — Special Ability: Combat Bonus  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATADMIRAL_TITLE` — Great Admiral  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATARTIST_HEADING3_BODY` — The great artist is one talented artist.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATARTIST_HEADING3_TITLE` — Great Artist  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATENGINEER_HEADING3_BODY` — The great engineer is one talented engineer.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATENGINEER_HEADING3_TITLE` — Great Engineer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATMERCHANT_HEADING3_BODY` — The great merchant is one talented merchant.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATMERCHANT_HEADING3_TITLE` — Great Merchant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATMUSICIAN_HEADING3_BODY` — The great musician is one talented musician, and very important for the cultural victory.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATMUSICIAN_HEADING3_TITLE` — Great Musician  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATPEOPLE_HEADING2_TITLE` — Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATPROPHET_ABILITY_TITLE` — Special Ability: Spread Religion  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATPROPHET_IMPROVEMENT_TITLE` — Special Improvement: Holy Site  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATPROPHET_TITLE` — Great Prophet  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATSCIENTIST_HEADING3_BODY` — A great scientist is one talented scientist.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATSCIENTIST_HEADING3_TITLE` — Great Scientist  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATWRITER_HEADING3_BODY` — The Great Writer, like his Artist and Musician brethren, are very important for the cultural victory.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_GREATWRITER_HEADING3_TITLE` — Great Writer  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_HEADING1_TITLE` — Specialists and Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_LANDMARK_HEADING4_BODY` — A Landmark Improvement provides loads of culture to the city.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_LANDMARK_HEADING4_TITLE` — Special Improvement: Landmark  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_LEARNNEWTECH_HEADING4_TITLE` — Special Ability: Free Science  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos2_Inherited_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_MANUFACTORY_HEADING4_TITLE` — Special Improvement: Manufactory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_MERCHANT_HEADING3_TITLE` — Merchant  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_MOVINGGREATPEOPLE_HEADING2_TITLE` — Moving Great People  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_MUSICIAN_CREATEGW_HEADING4_TITLE` — Special Ability: Great Work  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_MUSICIAN_TITLE` — Musician  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_SCIENTIST_HEADING3_TITLE` — Scientist  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_SPECIALABILITY_HEADING4_TITLE` — Special Ability  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_SPECIALIMPROVEMENT_HEADING4_TITLE` — Special Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_SPECIALISTS_HEADING2_TITLE` — Specialists  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_TRADEMISSION_HEADING4_TITLE` — Special Ability: Trade Mission  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_SPECIALISTSANDGP_TREATISE_HEADING4_TITLE` — Special Ability: Political Treatise  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_WRITER_CREATEGW_HEADING4_TITLE` — Special Ability: Great Work  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALISTSANDGP_WRITER_TITLE` — Writer  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`
- `TXT_KEY_SPECIALIST_ARTIST_TITLE` — Great Artist Points:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_SPECIALIST_ENGINEER_TITLE` — Great Engineer Points:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_SPECIALIST_MERCHANT_TITLE` — Great Merchant Points:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_SPECIALIST_MUSICIAN_TITLE` — Great Musician Points:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Units_Expansion2.xml`
- `TXT_KEY_SPECIALIST_SCIENTIST_TITLE` — Great Scientist Points:  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Objects.xml`
- `TXT_KEY_SPECIALIST_WRITER_TITLE` — Great Writer Points:  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Units_Expansion2.xml`
- `TXT_KEY_SP_MAP_PACK_BERING_TITLE` — Bering Strait  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_SP_MAP_PACK_BRITISH_ISLES_TITLE` — British Isles  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_SP_MAP_PACK_CARRIBEAN_TITLE` — Caribbean  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_SP_MAP_PACK_EUS_TITLE` — Eastern United States  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_SP_MAP_PACK_JAPAN_TITLE` — Japanese Mainland  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_SUPPLY_CAP_TT` — Total Supply Generated  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SUPPLY_DEFICIT_PENALTY_TT` — Penalty Incured From Supply Deficit  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SUPPLY_DEFICIT_TT` — Units Exceeding Supply  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SUPPLY_REMAINING_TT` — Supply Available for New Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SUPPLY_TITLE` — Unit Supply  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SUPPLY_USE_TT` — Supply Used by Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_SWAP_ARTIFACT_HEADER` — Artifact  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_SWAP_ART_HEADER` — Art  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_SWAP_MUSIC_HEADER` — Music  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_SWAP_WRITING_HEADER` — Writing  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TECH_ACOUSTICS_TITLE` — Acoustics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ADVANCED_BALLISTICS_TITLE` — Advanced Ballistics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_AGRICULTURE_TITLE` — Agriculture  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ANCIENTRUINS_HEADING4_TITLE` — Ancient Ruins  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_ANIMAL_HUSBANDRY_TITLE` — Animal Husbandry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ARCHAEOLOGY_TITLE` — Archaeology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ARCHERY_TITLE` — Archery  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ARCHITECTURE_TITLE` — Architecture  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Inherited_Expansion2.xml`
- `TXT_KEY_TECH_ATOMIC_THEORY_TITLE` — Atomic Theory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_AVAILABLETECH_HEADING2_TITLE` — Which Technologies Are Available  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_AWARD_TITLE` — You Have Researched A New Technology!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_TECH_BALLISTICS_TITLE` — Ballistics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_BANKING_TITLE` — Banking  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_BEAKERS_HEADING2_TITLE` — Where Do Beakers Come From?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_BIOLOGY_TITLE` — Biology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_BRONZE_WORKING_TITLE` — Bronze Working  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_BUILDINGS_HEADING4_TITLE` — Buildings  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_CALCULUS_TITLE` — Calculus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_CALENDAR_TITLE` — Calendar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_CHEMISTRY_TITLE` — Chemistry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_CHIVALRY_TITLE` — Chivalry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_FOREIGN` — Your Foreign Advisor recommends researching this technology.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_MILITARY` — Your Military Advisor recommends researching this technology.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TECH_CHOOSER_ADVISOR_RECOMMENDATION_SCIENCE` — Your Science Advisor recommends researching this technology.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TECH_CHOOSINGTECH_HEADING2_TITLE` — Choosing A Technology To Study  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_CIVIL_SERVICE_TITLE` — Civil Service  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_COMBINED_ARMS_TITLE` — Combined Arms  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Inherited_Expansion2.xml`
- `TXT_KEY_TECH_COMBUSTION_TITLE` — Combustion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_COMPASS_TITLE` — Compass  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_COMPUTERS_TITLE` — Computers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_CONSTRUCTION_TITLE` — Construction  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_CURRENCY_TITLE` — Currency  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_DRAMA_TITLE` — Drama and Poetry  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Inherited_Expansion2.xml`
- `TXT_KEY_TECH_DYNAMITE_TITLE` — Dynamite  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ECOLOGY_TITLE` — Ecology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_EDUCATION_TITLE` — Education  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ELECTRICITY_TITLE` — Electricity  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ELECTRONICS_TITLE` — Electronics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ENGINEERING_TITLE` — Engineering  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_EXPLORATION_TITLE` — Exploration  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_TECH_FERTILIZER_TITLE` — Fertilizer  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_FLIGHT_TITLE` — Flight  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_FUTURE_TECH_TITLE` — Future Tech  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_GLOBALIZATION_TITLE` — Globalization  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_GREATSCIENTIST_HEADING4_TITLE` — Great Scientist  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_GUILDS_TITLE` — Guilds  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Inherited_Expansion2.xml`
- `TXT_KEY_TECH_GUNPOWDER_TITLE` — Gunpowder  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_HEADING1_TITLE` — Technology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_HUMANISM_TITLE` — Humanism  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Medieval_Scenario.xml`
- `TXT_KEY_TECH_HYDROELECTRICS_TITLE` — Hydroelectrics  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion.xml`
- `TXT_KEY_TECH_INCREASINGBEAKERS_HEADING3_TITLE` — Increasing Beakers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_INDUSTRIALIZATION_TITLE` — Industrialization  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Inherited_Expansion2.xml`
- `TXT_KEY_TECH_INTERNET_TITLE` — The Internet  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion2.xml`
- `TXT_KEY_TECH_IRON_WORKING_TITLE` — Iron Working  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_LASERS_TITLE` — Lasers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_MACHINERY_TITLE` — Machinery  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_MASONRY_TITLE` — Masonry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_MASS_MEDIA_TITLE` — Mass Media  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_MATHEMATICS_TITLE` — Mathematics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_METALLURGY_TITLE` — Metallurgy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_METAL_CASTING_TITLE` — Metal Casting  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_MILITARY_SCIENCE_TITLE` — Military Science  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_MINING_TITLE` — Mining  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_MOBILE_TACTICS_TITLE` — Mobile Tactics  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Inherited_Expansion2.xml`
- `TXT_KEY_TECH_NAVIGATION_TITLE` — Navigation  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_NUCLEAR_FISSION_TITLE` — Nuclear Fission  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_NUCLEAR_FUSION_TITLE` — Nuclear Fusion  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_OPTICS_TITLE` — Optics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_PARTICLE_PHYSICS_TITLE` — Particle Physics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_PATRONAGE_TITLE` — Patronage  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_PENICILIN_TITLE` — Penicillin  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_PHILOSOPHY_TITLE` — Philosophy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_PHYSICS_TITLE` — Physics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_PLASTICS_TITLE` — Plastics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_POTTERY_TITLE` — Pottery  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_PRINTING_PRESS_TITLE` — Printing Press  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_PUBLISHING_TITLE` — Publishing  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_RADAR_TITLE` — Radar  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_RADIO_TITLE` — Radio  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_RAILROAD_TITLE` — Railroad  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_RATIONALISM_HEADING4_TITLE` — The Rationalism Branch  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_REFRIGERATION_TITLE` — Refrigeration  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_REPLACEABLE_PARTS_TITLE` — Replaceable Parts  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_RIFLING_TITLE` — Rifling  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ROBOTICS_TITLE` — Robotics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_ROCKETRY_TITLE` — Rocketry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_SAILING_TITLE` — Sailing  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_SATELLITES_TITLE` — Satellites  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_SCIENTIFIC_THEORY_TITLE` — Scientific Theory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_STEALTH_TITLE` — Stealth  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_STEEL_TITLE` — Steel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_TECHANDBEAKERS_HEADING2_TITLE` — Technology and Beakers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_TECHVICTORY_HEADING2_TITLE` — Technology and Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_TELECOM_TITLE` — Telecommunications  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Techs_Inherited_Expansion2.xml`
- `TXT_KEY_TECH_TELEGRAPH_TITLE` — Telegraph  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_THEOLOGY_TITLE` — Theology  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_THE_WHEEL_TITLE` — The Wheel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_TRAPPING_TITLE` — Trapping  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TECH_WONDERS_HEADING4_TITLE` — Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TECH_WRITING_TITLE` — Writing  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Techs.xml`
- `TXT_KEY_TERRAIN_CITYYIELDMODIFIER_HEADING3_BODY` — Rivers give +1 gold to adjacent tiles.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_CITYYIELDMODIFIER_HEADING3_TITLE` — City Yield Modifier  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_COAST_HEADING3_TITLE` — Coast  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_DESERT_HEADING3_TITLE` — Desert  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_EXPLAINVALUES_HEADING3_TITLE` — Explanation of Terrain Values  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_FALLOUT_HEADING3_TITLE` — Fallout  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_FEATURES_HEADING2_TITLE` — Features  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_FEATUREVALUES_HEADING3_BODY` — Like terrain, features also have values for city yield, movement, and combat.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_FEATUREVALUES_HEADING3_TITLE` — Feature Values  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_FLOODPLAINS_HEADING3_TITLE` — Flood Plains  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_FOREST_HEADING3_TITLE` — Forest  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_GRASSLAND_HEADING3_TITLE` — Grassland  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_HEADING1_TITLE` — Terrain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_HILLS_HEADING3_TITLE` — Hills  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_ICE_HEADING3_TITLE` — Ice  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_JUNGLE_HEADING3_TITLE` — Jungle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_MARSH_HEADING3_TITLE` — Marsh  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_MOUNTAIN_HEADING3_TITLE` — Mountain  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_MOVEMENTEFFECT_HEADING3_TITLE` — Movement Effect  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_NATURALWONDERS_HEADING3_TITLE` — Natural Wonders  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_OASIS_HEADING3_TITLE` — Oasis  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_OCEAN_HEADING3_TITLE` — Ocean  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_OFFENSIVEPENALTY_HEADING3_BODY` — When attacking across a river, the attacking unit gets a 20% penalty to its combat strength.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_OFFENSIVEPENALTY_HEADING3_TITLE` — Offensive Penalty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_PLAINS_HEADING3_TITLE` — Plains  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_RESOURCES_HEADING2_TITLE` — Resources  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_RIVERLOCATIONS_HEADING3_TITLE` — River Locations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_RIVERS_HEADING2_TITLE` — Rivers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_TABLES_HEADING2_TITLE` — The Terrain Tables  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_TUNDRA_HEADING3_TITLE` — Tundra  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_TYPES_HEADING2_BODY` — There are 9 basic terrain types in the game: coast, desert, grassland, hills, mountain, ocean, plains, snow, tundra.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TERRAIN_TYPES_HEADING2_TITLE` — Terrain Types  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TITLE_BAR` — Title  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_TITLE_BODY_DESCRIPTION` — Body for things that need to have a body of text under their title  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_TOOL_TIPS_TITLE` — Tool Tips and Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`
- `TXT_KEY_TOPIC_ADVISORS` — Advisors  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_TO_AVAILABLE_TR_TT` — Lists all the trade routes that may be established, including those you have already established.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TO_EXISTING_TR_TT` — Lists the trade routes you have established with other cities.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TO_OTHERS_TR_TT` — List of all the trade routes others have established with your cities.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRADITION_TITLE` — {@1: gender feminine?Lady; other?Lord;} {1_PlayerName:textkey} of {2_CivName:textkey}  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_TRO_COL_FROM_CITY_TT` — Click to sort by which city the trade route is coming from.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_COL_FROM_CIV_TT` — Click to sort by which civilization the trade route is coming from.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_COL_TO_CITY_TT` — Click to sort by which city the trade route is going to.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_COL_TO_CIV_TT` — Click to sort by which civilization the trade route is going to.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_COL_TO_FOOD_TT` — Click to sort by the amount of [ICON_FOOD] Food that the destination city would receive from this trade route.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_COL_TO_GPT_TT` — Click to sort by the amount of [ICON_GOLD] Gold that the destination civilization would receive from this trade route.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_COL_TURNS_REMAINING_TT` — Click to sort by the turns remaining on the trade route.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_LAND_DOMAIN_TT` — Caravan  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TRO_SEA_DOMAIN_TT` — Cargo Ship  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_InGameScreens_Expansion2.xml`
- `TXT_KEY_TUTORIAL0_TITLE_ONLY` — Learn as you play  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL1_TITLE` — Movement and Exploration  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL1_TITLE_ONLY` — Movement and Exploration  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL2_TITLE` — Founding Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL2_TITLE_ONLY` — Founding Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL3_TITLE` — Improving Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL3_TITLE_ONLY` — Improving Cities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL4_TITLE` — Combat and Conquest  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL4_TITLE_ONLY` — Combat and Conquest  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL5_TITLE` — Basic Diplomacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL5_TITLE_ONLY` — Basic Diplomacy  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL_1_COMPLETE` — You Completed the Movement and Exploration tutorial! Nice job!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL_2_COMPLETE` — You Completed the Found Cities tutorial! Nice job!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL_3_COMPLETE` — You Completed the Improving Cities tutorial! Nice job!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL_4_COMPLETE` — You Completed the Combat and Conquest tutorial! Nice job!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL_5_COMPLETE` — You Completed the Basic Diplomacy tutorial! Nice job!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Advisors.xml`
- `TXT_KEY_TUTORIAL_INSTRUCT` — Tutorial - Learn as you Play!  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_TUTORIAL_TITLE_BAR` — Tutorial  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_TUTORIAL_TT` — Scenarios to introduce gameplay concepts  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_UNAVAILABLE_LEADER_TT` — Leader is unavailable because some players do not have the required DLC package '{1_string}'.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_FrontEndScreens.xml`
- `TXT_KEY_UNITS_AIR_HEADING3_TITLE` — Air Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_CHARACTERISTICS_HEADING2_BODY` — All units have three basic statistics ("stats"): movement speed, combat strength, and promotions.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_CHARACTERISTICS_HEADING2_TITLE` — Unit Characteristics  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_COMBATSTRENGTH_HEADING3_TITLE` — Combat Strength  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_COMBATUNITS_HEADING2_TITLE` — Combat Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_CONSTRUCTING_HEADING2_TITLE` — Constructing Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_HEADING1_TITLE` — Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_MOVEMENT_HEADING2_TITLE` — Unit Movement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_MOVESPEED_HEADING3_TITLE` — Movement Speed  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_NATIONAL_HEADING2_TITLE` — National Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_NAVAL_HEADING3_TITLE` — Naval Units  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_SPECIALABILITIES_HEADING2_TITLE` — Unit Special Abilities  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNITS_UNITCOMBAT_HEADING2_TITLE` — Unit Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_UNIT_NEEDS_ORDERS_TT` — Select a unit that needs orders before the turn can end.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_UNIT_PROMOTION_TT` — Select a unit that is awaiting promotion. All units must be promoted before you may end the turn.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos.xml`
- `TXT_KEY_UPANEL_CARGO_CAPACITY_TT` — Number of units that can be transported by the {1_UnitName}.  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion2.xml`
- `TXT_KEY_UPANEL_MOVEMENT_TT` — The number of tiles this Unit may move in a turn.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_UPANEL_RANGEMOVEMENT_TT` — The number of tiles this Unit may fly in a turn.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_UPANEL_RELIGIOUS_STRENGTH_TT` — This indicates the strength of the religious unit (1000 is average).  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Inherited_Expansion2.xml`
- `TXT_KEY_UPANEL_REMOVE_HERESY_USES_TT` — This indicates the remaining number of times this unit can remove heresy from a city.  
  source: `DLC/Expansion/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Expansion.xml`, `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_WorldView_Inherited_Expansion2.xml`
- `TXT_KEY_UPANEL_SET_HITPOINTS_TT` — {1_Num}/{2_Num} Hit Points  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_UPANEL_STRENGTH_TT` — This indicates the combat strength of the Unit.  The higher this number the better the Unit will perform in combat.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_UPANEL_UNIT_PROMOTED_TT` — Reveals promotions your Unit may select.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_WorldView.xml`
- `TXT_KEY_VICTORY_2050ARRIVES_HEADING3_TITLE` — 2050 Arrives  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_CAPITAL_HEADING4_TITLE` — Current Capital vs. Original Capital  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_CITYSTATES_HEADING2_BODY` — City-States cannot win a game of Civilization V. Only major civilizations can do so.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_CITYSTATES_HEADING2_TITLE` — City-States And Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_CULTURAL_HEADING3_TITLE` — Cultural Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_DESTROYING_HEADING4_TITLE` — Destroying an Original Capital  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_DIPLOMATIC_HEADING3_TITLE` — Diplomatic Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_DOMINATION_HEADING3_TITLE` — Domination Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_ENDOFTIME_HEADING2_TITLE` — The End of Time  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_HEADING1_TITLE` — Victory and Defeat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_HOWTOLOSE_HEADING2_TITLE` — How To Lose  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_HOWTOWIN_HEADING2_TITLE` — How To Win  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_LIBERATION_HEADING4_TITLE` — Liberation  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_LOSINGCITY_HEADING3_TITLE` — Losing your Last City  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_SCIENCE_HEADING3_TITLE` — The Science Victory  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_SPACESHIP_HEADING4_TITLE` — Spaceship Parts  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_VICTORYPOINTS_HEADING3_TITLE` — Determining Score  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VICTORY_WHOVOTES_HEADING4_TITLE` — Delegates  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_VP_TITLE` — VICTORY PROGRESS  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_TT` — Victory Progress  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_VP_TURNS_TT` — Turns Before the Game Ends  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_InGameScreens.xml`
- `TXT_KEY_WONDER_ANGKORWAT_HEADING` — Angkor Wat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_BIGBEN_HEADING` — Big Ben  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_BRANDENBURGGATE_HEADING` — Brandenburg Gate  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_CHICHENITZA_HEADING` — Chichen Itza  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_COLOSSUS_HEADING` — The Colossus  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_CRISTOREDENTOR_HEADING` — Cristo Redentor  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_EIFFELTOWER_HEADING` — Eiffel Tower  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_FORBIDDENPALACE_HEADING` — The Forbidden Palace  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_GREATLIBRARY_HEADING` — The Great Library  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_GREATLIGHTHOUSE_HEADING` — The Great Lighthouse  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_GREATWALL_HEADING` — The Great Wall  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_HAGIASOPHIA_HEADING` — The Hagia Sophia  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_HANGINGGARDENS_HEADING` — The Hanging Gardens  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_HIMEJICASTLE_HEADING` — Himeji Castle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_KREMLIN_HEADING` — The Kremlin  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_LOUVRE_HEADING` — The Louvre  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_MACHUPICCHU_HEADING` — Machu Picchu  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_ORACLE_HEADING` — The Oracle  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_PENTAGON_HEADING` — Pentagon  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_PORCELAINTOWER_HEADING` — The Porcelain Tower  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_PYRAMIDS_HEADING` — The Pyramids  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_SISTINECHAPEL_HEADING` — Sistine Chapel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_STATUEOFLIBERTY_HEADING` — Statue of Liberty  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_STONEHENGE_HEADING` — Stonehenge  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_TAJMAHAL_HEADING` — Taj Mahal  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WONDER_UNITEDNATIONS_HEADING` — United Nations  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_ACTIONPANEL_HEADING2_TITLE` — The Worker Action Panel  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_BUILDINGROADS_HEADING2_TITLE` — Building Roads  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_CLEARINGLAND_HEADING2_TITLE` — Clearing Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_COMBAT_HEADING2_TITLE` — Workers in Combat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_CONSTRUCTROAD_HEADING3_BODY` — It takes a worker 3 turns to construct a road in any tile.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_CONSTRUCTROAD_HEADING3_TITLE` — Time to Construct a Road  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_CREATING_HEADING2_BODY` — Workers are built in cities, just like other units.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_CREATING_HEADING2_TITLE` — Creating Workers  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_DURATIONTOCONSTRUCT_HEADING3_TITLE` — Duration to Construct  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_FARM_HEADING3_TITLE` — Farm Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_FISHINGBOATSOILPLATFORMS_HEADING3_TITLE` — Fishing Boats and Oil Platforms  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_FISHINGBOAT_HEADING3_TITLE` — Fishing Boat  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_GREATPEOPLE_HEADING2_BODY` — Great People can construct special improvements. See their rules for details.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_GREATPEOPLE_HEADING2_TITLE` — Great People Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_HEADING1_TITLE` — Workers and Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_IMPROVEMENTS_HEADING2_BODY` — Once a civilization has learned the appropriate technology, its workers can construct improvements.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_IMPROVEMENTS_HEADING2_TITLE` — Constructing Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_LEAVINGANDRESUMING_HEADING3_TITLE` — Leaving and Resuming Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_LUMBERMILL_HEADING3_TITLE` — Lumber Mill  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_MINE_HEADING3_TITLE` — Mine Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_OFFSHOREPLATFORM_HEADING3_TITLE` — Offshore Platform  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_OILWELL_HEADING3_TITLE` — Oil Well  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_PASTURE_HEADING3_TITLE` — Pasture  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_PILLAGINGROADS_HEADING2_TITLE` — Pillaging Roads and Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_PLANTATION_HEADING3_TITLE` — Plantation  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_QUARRY_HEADING3_TITLE` — Quarry  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_REPAIRINGROADS_HEADING3_BODY` — A worker may repair a pillaged road or improvement. It takes a worker 3 turns to repair any road or improvement.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_REPAIRINGROADS_HEADING3_TITLE` — Repairing Roads and Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_SPECIALFORT_HEADING3_TITLE` — The Special Fort Improvement  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_TIMELEFT_HEADING3_BODY` — Hover your cursor over a worker to see how much time is remaining on the current construction job.  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_TIMELEFT_HEADING3_TITLE` — How Much Time is Left?  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_TIMETOCLEARLAND_HEADING3_TITLE` — Time to Clear Land  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_TRADEROUTES_HEADING3_TITLE` — Roads and Trade Routes  
  source: `DLC/Expansion2/Gameplay/XML/Text/en_US/CIV5GameTextInfos_Civilopedia_Expansion2.xml`, `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_TRADINGPOST_HEADING3_TITLE` — Trading Post  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_WHERETOCONSTRUCT_HEADING3_TITLE` — Where to Construct Improvements  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_WORKERS_WORKBOATS_HEADING2_TITLE` — Work Boats  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos_Civilopedia.xml`
- `TXT_KEY_ZOOM_TITLE` — Zoom Controls  
  source: `Gameplay/XML/NewText/EN_US/CIV5GameTextInfos2.xml`


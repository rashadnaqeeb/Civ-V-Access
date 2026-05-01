# `tests/suite_city_speech.lua`

768 lines · Tests for `CivVAccess_CitySpeech` covering all three cursor number-key formatters (identity, development, politics) across ownership tiers (own/team/visible enemy/unmet) and the full set of city status flags, city-state trait/friendship combinations, HP bands, production states, and espionage.

## Header comment

```
-- CitySpeech formatter tests. Covers the three cursor number keys
-- (identity + combat, development, politics) across ownership tiers
-- (own / team / visible enemy / unmet) and across the status flags
-- and city-state trait / friendship combinations the banner exposes.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L13: `local function mkCity(opts)`
- L162: `local function setup()`
- L231: `local function installForeignMajor(teamId, ownerId, opts)`
- L261: `local function installMinorCiv(teamId, ownerId, traitType, opts)`
- L303: `function M.test_identity_speaks_unmet_for_unmet_city()`
- L326: `function M.test_development_speaks_unmet_for_unmet_city()`
- L346: `function M.test_politics_speaks_unmet_for_unmet_city()`
- L369: `function M.test_identity_major_capital_speaks_capital_token()`
- L379: `function M.test_identity_city_state_capital_does_not_speak_capital_token()`
- L392: `function M.test_identity_can_attack_prepends_on_own_city_with_strike_ready()`
- L399: `function M.test_identity_can_attack_not_spoken_on_enemy_city()`
- L409: `function M.test_identity_city_state_speaks_trait_and_friendship_tier()`
- L418: `function M.test_identity_city_state_friend_tier()`
- L424: `function M.test_identity_city_state_war_tier_overrides_friends()`
- L435: `function M.test_identity_city_state_permanent_war_tier_leads()`
- L443: `function M.test_identity_city_state_neutral_default()`
- L452: `function M.test_identity_razing_speaks_turns_remaining()`
- L458: `function M.test_identity_resistance_speaks_turns_remaining()`
- L464: `function M.test_identity_occupied_gated_on_no_occupied_unhappiness()`
- L476: `function M.test_identity_puppet_and_blockaded_flags()`
- L484: `function M.test_identity_status_flag_order_razing_resistance_occupied_puppet_blockaded()`
- L510: `function M.test_identity_population_and_defense_tokens()`
- L518: `function M.test_identity_team_city_speaks_hp_fraction()`
- L524: `function M.test_identity_enemy_city_speaks_hp_full()`
- L530: `function M.test_identity_enemy_city_hp_band_matches_thresholds()`
- L549: `function M.test_identity_team_city_speaks_garrison_name()`
- L561: `function M.test_identity_enemy_city_omits_garrison()`
- L577: `function M.test_identity_team_non_capital_speaks_connected_when_route_home()`
- L588: `function M.test_identity_enemy_city_omits_connected_token()`
- L601: `function M.test_development_returns_not_visible_on_enemy_city()`
- L607: `function M.test_development_producing_item_with_turns()`
- L622: `function M.test_development_not_producing_when_empty_key()`
- L636: `function M.test_development_process_omits_turns_and_progress()`
- L654: `function M.test_development_stopped_growing_when_food_diff_zero()`
- L659: `function M.test_development_starving_when_food_diff_negative()`
- L666: `function M.test_development_grows_in_turns_normal_case()`
- L674: `function M.test_development_includes_production_per_turn()`
- L684: `function M.test_politics_speaks_no_info_when_peace_no_religion_no_spy()`
- L689: `function M.test_politics_speaks_religion_when_majority_exists()`
- L695: `function M.test_politics_speaks_warmonger_preview_when_at_war()`
- L705: `function M.test_politics_omits_liberation_when_original_owner_same()`
- L712: `function M.test_politics_speaks_liberation_when_original_differs()`
- L730: `function M.test_politics_speaks_spy_with_name_and_rank()`
- L742: `function M.test_politics_distinguishes_diplomat_from_spy()`
- L753: `function M.test_politics_skips_spy_on_wrong_tile()`
- L768: `return M`

## Notes

- L484 `test_identity_status_flag_order_razing_resistance_occupied_puppet_blockaded`: Asserts positional ordering of all five status flags in a single city with every flag set simultaneously, checking that cascade order matches `CityBannerManager`.
- L530 `test_identity_enemy_city_hp_band_matches_thresholds`: Calls `setup()` and `installForeignMajor` three times within the same test to reset global state between band-threshold assertions.

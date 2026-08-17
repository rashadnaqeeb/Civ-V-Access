# LekMod accessibility gaps

Working list of LekMod surfaces that carry no accessibility coverage. Each entry names the
surface, where its code lives, what a player gets today, and what coverage would mean.
This is a to-do list, not a design doc: when a gap is closed, delete its entry rather than
annotating it. Architecture and the re-pin runbook live in `lekmod-support.md`.

Entries land here when a re-pin surfaces net-new LekMod content the layer does not read.
The re-pin's job is making the existing layer correct against the new drop; covering new
surfaces is separate work, and this file is where that work is remembered.

## Staging-room civ draft and ban system

Added in v35. The host sets draft rules (bans and picks per player, vanilla-only, seasonal
exclusions, guaranteed coastal and inland counts), every player bans civs out of the pool,
the host creates the draft, and each player is dealt a hand of civs and may swap picks with
another player. Draft state syncs between clients as chat messages carrying a `#LDRAFT#`
prefix.

The logic is `LEKMOD/Lua/Utilities/Lekmod_drafter.lua` (a per-civ tag table plus the deal
function). The UI is `Lekmod_staging_draft.lua`, included by `StagingRoom.lua`, which is the
screen we already override.

Today none of it is spoken: the per-player ban column, the per-player status text
("Selecting bans...", "Bans ready", "Draft locked"), the dealt hand, the host's create,
clear, reset, and restore controls, the delegate-bans-to-host button, and the swap flow are
all silent. Coverage means the draft becomes drillable state on the staging room's existing
handler, with the player's own bans and hand reachable and other players' readiness
readable on demand.

v35 also rebuilt the lobby into three pages (players, draft, options) and added a compact
layout below 1320 pixels that hides the summary strip. Page mode is state a blind host has
no way to perceive, so whatever covers the draft has to announce the current page and make
switching pages reachable.

## Combat preview could use LekMod's own predictor

v35 added `Game.GetCombatDamage`, which takes the full matchup (attacker and defender units
or cities, interceptor, plot, and the ranged / bombing / air-sweep flags) and resolves the
damage through the engine's own combat info. Our preview instead re-enumerates modifiers by
explicit named-binding calls, which is why each LekMod drop's new modifier lines have to be
added by hand. Routing the preview through this binding on LekMod would remove that
per-drop coupling. It is an accuracy and maintenance win, not a missing surface, so it is
lower priority than the two gaps above.

## City-state personalities

Added in v35. A `LEKMOD_MINOR_CIV_PERSONALITIES` table assigns every city-state one of ten
personalities (friendly, neutral, hostile, irrational, wealthy, impoverished, pirate
republic, theocratic, pacifistic, isolationist). It changes the greeting line the city-state
speaks, and swaps the gift and bully button labels and their tooltips.

`LEKMOD/Lua/UI/CityStatePersonalityHelper.lua` composes the display. It is consumed by
`CityStateDiploPopup`, which we override. Note it lives under `Lua/UI` directly rather than
in the `tmp/ui` staging tree, so `ui_check.bat` preserves it across its own regeneration
instead of copying it in.

Today the personality reaches the player only as tooltip text and as a colored name inside
that tooltip, so it is effectively invisible. Coverage means the personality is part of what
the city-state diplo popup speaks, since it changes how worthwhile gifting and bullying are.

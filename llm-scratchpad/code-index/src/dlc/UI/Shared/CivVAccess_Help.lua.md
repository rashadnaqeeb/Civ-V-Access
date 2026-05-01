# `src/dlc/UI/Shared/CivVAccess_Help.lua`

80 lines · Help overlay that collects authored `helpEntries` from the current `HandlerStack` and presents them as a navigable, searchable `BaseMenu` list opened via Shift+?.

## Header comment

```
-- Help overlay. Opens a navigable list of bindings reachable from the
-- current handler stack, built from each handler's authored helpEntries
-- via HandlerStack.collectHelpEntries. Dedupe by keyLabel means stacked
-- handlers with overlapping chords surface only the topmost handler's
-- meaning -- which matches what the chord actually does in that context.
--
-- The help handler is itself a BaseMenu-created handler: Up/Down navigate,
-- Home/End jump, type-ahead search works, ?/Esc close. Each entry is a
-- non-activatable Button whose label is "keyLabel: description".
```

## Outline

- L11: `Help = {}`
- L18: `local HELP_SELF_ENTRIES = { ... }`
- L32: `local function resolveEntryLabel(entry)`
- L38: `local function buildItems(entries)`
- L52: `function Help.open()`

## Notes

- L52 `Help.open`: collects entries from the stack before pushing the Help handler itself, so Help's own bindings don't mask the list it is about to render.
- L65: replaces `handler.helpEntries` with `HELP_SELF_ENTRIES` after `BaseMenu.create` returns, overriding the auto-populated entries with a curated navigation guide.
- L70: adds a `Shift+?` close binding directly to the handler so pressing `?` again toggles the overlay off; `InputRouter`'s pre-walk guard bails when `top.name == "Help"` to let this fire.

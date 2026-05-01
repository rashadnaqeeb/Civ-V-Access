# `src/dlc/UI/Shared/CivVAccess_BaseMenuHelp.lua`

121 lines · Authored help-entry templates and composer for the BaseMenu container, building a per-screen list of key/description pairs from the spec.

## Header comment

```
-- Authored help-entry templates for the BaseMenu container and a composer
-- that assembles a per-screen list by consulting the spec. Each template is
-- a list of {keyLabel, description} TXT_KEY pairs describing one binding that
-- BaseMenu.create wires up. Direction-paired bindings collapse into a single
-- human label ("Up/Down") so the dedupe in HandlerStack.collectHelpEntries
-- can drop equivalent entries from stacked handlers.
```

## Outline

- L8: `BaseMenuHelp = {}`
- L10: `BaseMenuHelp.MenuHelpEntries = {...}`
- L14: `BaseMenuHelp.ListNavHelpEntries = {...}`
- L37: `BaseMenuHelp.NestedNavHelpEntries = {...}`
- L44: `BaseMenuHelp.TabbedHelpEntries = {...}`
- L52: `BaseMenuHelp.ReadHeaderHelpEntry = {...}`
- L57: `BaseMenuHelp.CivilopediaHelpEntry = {...}`
- L62: `BaseMenuHelp.EscapePopsHelpEntry = {...}`
- L67: `local function appendAll(dst, src)`
- L80: `function BaseMenuHelp.buildHelpEntries(spec)`
- L112: `function BaseMenuHelp.addScreenKey(handler, entry)`
- L121: `return BaseMenuHelp`

## Notes

- L112 `BaseMenuHelp.addScreenKey`: inserts at position `handler._screenKeyCount + 1` (after spec.helpExtras but before the universal nav entries), not at the tail of the list.

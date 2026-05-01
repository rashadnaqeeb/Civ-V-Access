"""One-shot script to collapse the standard CivVAccess popup include preamble
into a single include("CivVAccess_PopupBoot"). Preserves any extra includes
that aren't in the bundle's set so popups needing CameraTracker / TabbedShell
/ BaseTableCore keep them after the bundle reference."""

import os
import re

POPUPBOOT_SET = {
    'CivVAccess_Polyfill', 'CivVAccess_Log', 'CivVAccess_TextFilter',
    'CivVAccess_InGameStrings_en_US', 'CivVAccess_PluralRules',
    'CivVAccess_Text', 'CivVAccess_Icons', 'CivVAccess_SpeechEngine',
    'CivVAccess_SpeechPipeline', 'CivVAccess_HandlerStack',
    'CivVAccess_InputRouter', 'CivVAccess_TickPump', 'CivVAccess_Nav',
    'CivVAccess_BaseMenuItems', 'CivVAccess_TypeAheadSearch',
    'CivVAccess_BaseMenuHelp', 'CivVAccess_BaseMenuTabs',
    'CivVAccess_BaseMenuCore', 'CivVAccess_BaseMenuInstall',
    'CivVAccess_BaseMenuEditMode', 'CivVAccess_Help',
}

popup_dir = 'src/dlc/UI/InGame/Popups'
include_re = re.compile(r'include\("([^"]+)"\)')

converted_count = 0
skipped = []

for filename in sorted(os.listdir(popup_dir)):
    if not filename.startswith('CivVAccess_') or not filename.endswith('.lua'):
        continue
    if filename == 'CivVAccess_PopupBoot.lua':
        continue

    path = os.path.join(popup_dir, filename)
    with open(path, 'r', encoding='utf-8', newline='') as f:
        content = f.read()
    lines = content.splitlines(keepends=True)

    # Find the contiguous block of include("CivVAccess_*") lines starting
    # from the first include("CivVAccess_Polyfill") line.
    start = None
    for i, line in enumerate(lines):
        if line.strip() == 'include("CivVAccess_Polyfill")':
            start = i
            break
    if start is None:
        skipped.append((filename, 'no Polyfill include'))
        continue

    end = start
    block_includes = []
    while end < len(lines):
        m = include_re.match(lines[end].strip())
        if not m:
            break
        block_includes.append(m.group(1))
        end += 1

    # Sanity: must include CivVAccess_BaseMenuInstall (definition of the
    # canonical popup preamble). Skip files that don't.
    if 'CivVAccess_BaseMenuInstall' not in block_includes:
        skipped.append((filename, 'no BaseMenuInstall'))
        continue

    # Categorise the block: which entries belong to the bundle, which are
    # extras to preserve.
    bundle_entries = [n for n in block_includes if n in POPUPBOOT_SET]
    extras = [n for n in block_includes if n not in POPUPBOOT_SET]

    # Need at least most of the bundle present to be confident this is the
    # canonical popup preamble vs some other ordering.
    if len(bundle_entries) < 18:
        skipped.append((filename, f'only {len(bundle_entries)} bundle entries'))
        continue

    # Build replacement: bundle reference, then any extras in their original
    # relative order (so a CameraTracker that lived between Nav and BaseMenu
    # Items stays in roughly the right spot — we just put all extras after
    # the bundle reference; load order between extras and bundle members is
    # not load-bearing because the bundle's stems are loaded first via the
    # bundle file).
    replacement = ['include("CivVAccess_PopupBoot")\n']
    for extra in extras:
        replacement.append('include("{}")\n'.format(extra))

    new_lines = lines[:start] + replacement + lines[end:]
    new_content = ''.join(new_lines)

    if new_content == content:
        skipped.append((filename, 'unchanged'))
        continue

    with open(path, 'w', encoding='utf-8', newline='') as f:
        f.write(new_content)
    converted_count += 1
    print('Converted: {} (bundle={}, extras={})'.format(filename, len(bundle_entries), extras))

print()
print('Total converted: {}'.format(converted_count))
print('Skipped:')
for name, reason in skipped:
    print('  {} -- {}'.format(name, reason))

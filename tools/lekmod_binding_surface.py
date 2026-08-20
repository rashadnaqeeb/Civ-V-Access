"""Check that every engine binding our Lua calls still exists on LekMod.

A re-pin's value audit compares numbers, so it cannot see a binding that
stopped existing: the call simply errors at speech time, inside an event
handler the engine swallows. v35 removed Unit:GetMaxRangedCombatStrength
that way, by moving its Method() registration into the arm of an #if that
the combat-predictor define turns off, and nothing caught it.

So this walks the clone's Lua binding registrations with the preprocessor
state resolved from _Defines.h, keeps the ones that actually compile, and
fails on any name our own Lua calls that is not among them. Vanilla's SDK
registrations are the vocabulary of names to watch, which keeps arbitrary
Lua table lookups (Controls, our own modules) out of the comparison.

Usage:
    py tools/lekmod_binding_surface.py [--clone <path>] [--sdk <path>]

Reports removals we do not depend on as informational lines and exits 0;
exits 1 only when a name we call has gone away.
"""

import argparse
import os
import re
import sys

DEFAULT_CLONE = os.path.expanduser("~/Documents/Lekmod")
DEFAULT_SDK = (
    "C:/Program Files (x86)/Steam/steamapps/common/"
    "Sid Meier's Civilization V SDK/CvGameCoreSource/CvGameCoreDLL_Expansion2"
)
LUA_SOURCE_DIRS = ("src/dlc", "src/lekmod")
# The one file a LekMod deploy replaces wholesale: its vanilla body never
# runs on LekMod, so the calls in it are not calls LekMod has to satisfy.
SWAPPED_ON_DEPLOY = "src/dlc/UI/InGame/CivVAccess_EngineData.lua"

METHOD_RE = re.compile(r"^\s*Method\((\w+)\)")
DEFINE_RE = re.compile(r"^\s*#\s*define\s+(\w+)")
CALL_RE = re.compile(r"[:.](\w+)\s*\(")


def read_defines(path):
    names = set()
    with open(path, encoding="utf-8", errors="replace") as handle:
        for line in handle:
            match = DEFINE_RE.match(line)
            if match:
                names.add(match.group(1))
    return names


def condition_state(condition, defines):
    """True / False for a condition we understand, None for anything else."""
    text = condition.strip()
    match = re.fullmatch(r"defined\s*\(\s*(\w+)\s*\)", text)
    if match:
        return match.group(1) in defines
    match = re.fullmatch(r"!\s*defined\s*\(\s*(\w+)\s*\)", text)
    if match:
        return match.group(1) not in defines
    return None


def registered_methods(lua_dir, defines, ignore_conditions=False):
    """Method() names that survive the preprocessor in this binding tree."""
    found = set()
    for name in sorted(os.listdir(lua_dir)):
        if not name.startswith("CvLua") or not name.endswith(".cpp"):
            continue
        stack = []
        with open(os.path.join(lua_dir, name), encoding="utf-8", errors="replace") as handle:
            for line in handle:
                text = line.strip()
                if text.startswith("#if "):
                    stack.append(condition_state(text[4:], defines))
                elif text.startswith("#ifdef "):
                    stack.append(text.split()[1] in defines)
                elif text.startswith("#ifndef "):
                    stack.append(text.split()[1] not in defines)
                elif text.startswith("#else"):
                    if stack:
                        previous = stack.pop()
                        stack.append(None if previous is None else not previous)
                elif text.startswith("#endif"):
                    if stack:
                        stack.pop()
                else:
                    match = METHOD_RE.match(text)
                    # An unresolvable condition counts as live: this gate is
                    # for removals we can prove, not for guesses.
                    if match and (ignore_conditions or not any(state is False for state in stack)):
                        found.add(match.group(1))
    return found


def called_names(root):
    """Method names our own Lua calls, comment lines excluded."""
    calls = {}
    for directory in LUA_SOURCE_DIRS:
        base = os.path.join(root, directory)
        for current, _dirs, files in os.walk(base):
            for name in files:
                if not (name.startswith("CivVAccess_") and name.endswith(".lua")):
                    continue
                path = os.path.join(current, name)
                relative = os.path.relpath(path, root).replace("\\", "/")
                if relative == SWAPPED_ON_DEPLOY:
                    continue
                with open(path, encoding="utf-8", errors="replace") as handle:
                    for number, line in enumerate(handle, 1):
                        if line.lstrip().startswith("--"):
                            continue
                        for match in CALL_RE.finditer(line):
                            calls.setdefault(match.group(1), []).append("%s:%d" % (relative, number))
    return calls


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--clone", default=DEFAULT_CLONE)
    parser.add_argument("--sdk", default=DEFAULT_SDK)
    args = parser.parse_args()

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    clone_core = os.path.join(args.clone, "LEKMOD_DLL", "CvGameCoreDLL_Expansion2")
    clone_lua = os.path.join(clone_core, "Lua")
    sdk_lua = os.path.join(args.sdk, "Lua")

    for path in (clone_lua, sdk_lua):
        if not os.path.isdir(path):
            print("missing binding tree: %s" % path)
            return 2

    defines = read_defines(os.path.join(clone_core, "_Defines.h"))
    lekmod = registered_methods(clone_lua, defines)
    # Every name the vanilla tree could register counts as one to watch, so
    # its own conditions are ignored rather than resolved.
    vanilla = registered_methods(sdk_lua, set(), ignore_conditions=True)

    removed = sorted(vanilla - lekmod)
    calls = called_names(root)

    broken = [name for name in removed if name in calls]
    for name in removed:
        if name not in calls:
            print("note: LekMod no longer registers %s (we do not call it)" % name)
    for name in broken:
        print("BROKEN: LekMod no longer registers %s, called from:" % name)
        for site in calls[name][:10]:
            print("    %s" % site)

    if broken:
        print("")
        print("%d binding(s) our Lua calls are gone on this LekMod pin." % len(broken))
        return 1
    print("GOOD: every vanilla binding our Lua calls is still registered on LekMod.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

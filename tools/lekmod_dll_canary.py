"""Smoke-check a built LekMod CvGameCore_Expansion2.dll before committing it.

The VP canary (vp_dll_canary.py) guards a clang-specific va_start miscompile.
LekMod builds on VC9 (the same MSVC toolchain as the vanilla fork), which has
no such bug -- MSVC's va_start is the native one the engine expects -- so the
varargs guard is not needed here. This canary instead checks the things that
can actually go wrong with a VC9 LekMod build:

  1. The output is a valid 32-bit (x86) PE DLL.
  2. LekMod's DllVersion GUID is intact. The GUID must inherit LekMod's and
     never rotate (rotating it splits multiplayer compatibility); this catches
     an accidental rotation in our fork.
  3. Our port's engine additions are actually in THIS binary -- the CivVAccess
     LuaEvent hook names are string literals unique to our overlay. A build
     that picked up the wrong branch, or a merge that silently dropped our
     additions, fails here even though it would otherwise load fine.

This is a static check; whether the DLL actually boots in-game (the DllMain
heartbeat in the log) is the in-game gate, since FINAL_RELEASE strips the
OutputDebugString entry-point markers that an offline check could look for.

Run after every engine rebuild, before committing dist/engine-lekmod:

    py tools/lekmod_dll_canary.py dist/engine-lekmod/CvGameCore_Expansion2.dll

Needs the pefile package. If a re-pin ever changes LekMod's GUID (it should
not), update LEKMOD_GUID_BYTES below from CvDllVersion.h's NQM_GUID branch.
"""
import sys
import pefile

# LekMod's NQM_GUID from LEKMOD_DLL/.../CvDllVersion.h, little-endian as stored
# in the binary: {0x13c6ca53,0x50ff,0x4a66,{0x94,0x1b,0x5d,0x5d,0xaa,0x90,0xc6,0x84}}.
LEKMOD_GUID_BYTES = bytes([
    0x53, 0xca, 0xc6, 0x13, 0xff, 0x50, 0x66, 0x4a,
    0x94, 0x1b, 0x5d, 0x5d, 0xaa, 0x90, 0xc6, 0x84,
])

# A representative slice of the LuaEvent hook names our overlay registers. All
# of them should be present; we check a few distinctive ones so a partial-port
# build is caught without coupling the canary to the full set.
PORT_MARKERS = [
    b'CivVAccessNukeCityAffected',
    b'CivVAccessCombatResolved',
    b'CivVAccessMissionDispatched',
    b'CivVAccessUnitMoved',
    b'CivVAccessCityStateGreeting',
]


def main(dll):
    try:
        pe = pefile.PE(dll, fast_load=True)
    except Exception as e:  # noqa: BLE001 - report any parse failure verbatim
        print('FAIL: not a valid PE file: %s' % e)
        return 2

    machine = pe.FILE_HEADER.Machine
    if machine != 0x14c:  # IMAGE_FILE_MACHINE_I386
        print('FAIL: not an x86 (0x14c) image; Machine=0x%x' % machine)
        return 2
    if not (pe.FILE_HEADER.Characteristics & 0x2000):  # IMAGE_FILE_DLL
        print('FAIL: PE is not marked as a DLL')
        return 2

    data = open(dll, 'rb').read()
    problems = []

    if data.find(LEKMOD_GUID_BYTES) < 0:
        problems.append("LekMod DllVersion GUID not found -- GUID may have been "
                        "rotated (must stay LekMod's, never rotate)")

    missing = [m.decode() for m in PORT_MARKERS if data.find(m) < 0]
    if missing:
        problems.append('our engine additions missing from this binary: %s '
                        '(wrong branch built, or merge dropped the port)'
                        % ', '.join(missing))

    if problems:
        print('BAD:')
        for p in problems:
            print('  -', p)
        return 1

    print('GOOD: valid x86 DLL, LekMod GUID intact, '
          'CivVAccess port markers found.')
    return 0


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('usage: py tools/lekmod_dll_canary.py <path-to-CvGameCore_Expansion2.dll>')
        sys.exit(2)
    sys.exit(main(sys.argv[1]))

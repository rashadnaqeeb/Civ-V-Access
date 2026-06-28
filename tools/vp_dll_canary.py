"""Check a built VP CvGameCore_Expansion2.dll for the va_start miscompile and
that our engine bindings are actually in the binary.

If the engine build resolves VC9's stdarg.h ahead of clang's builtin headers,
va_start compiles to MSVC's raw pointer arithmetic instead of @llvm.va_start,
and LLVM then deletes the variadic arguments of every va_start function
(build_vp_clang_sdk.py carries the /imsvc fix on the civvaccess branch; this
script is the regression check for it). The DLL fails to load in-game with
LoadLibrary error 1114, dying in DllMain's first CUSTOMLOG.

Two checks, both must pass:

  1. va_start: find the DllMain startup CUSTOMLOG format string in .rdata,
     locate the code referencing it, and report whether the call site pushes
     the real variadic arguments (the version number 150 / 0x96 is the
     telltale) or synthesizes a bogus va_list.
  2. Port markers: distinctive string literals our overlay bakes in (CivVAccess
     LuaEvent hook names plus our added Lua method names) must be present, so a
     re-pin rebase that silently dropped a binding -- or a wrong-branch build --
     fails here even though va_start is fine. When a re-pin adds a binding, add
     its marker below.

Run it against clang-output/Release after every engine rebuild, before copying
the DLL to dist/engine-vp:

    py tools/vp_dll_canary.py <path-to-CvGameCore_Expansion2.dll>

Needs the pefile package and llvm-objdump. The mod-version immediate (0x96)
tracks upstream's MOD_DLL_VERSION_NUMBER; if a re-pin changes that number,
update VERSION_IMM below.
"""
import subprocess, sys
import pefile

OBJDUMP = r'C:\Program Files\LLVM\bin\llvm-objdump.exe'
VERSION_IMM = '$0x96'  # MOD_DLL_VERSION_NUMBER (150) as it appears in the disassembly

# Distinctive string literals our fork bakes in: CivVAccess LuaEvent hook names
# and the Lua method names our bindings register (Method(X) emits "X"). A few
# representative ones, including the newest bindings, so a re-pin rebase that
# dropped the port is caught without coupling to the full set.
PORT_MARKERS = [
    b'CivVAccessCityStateGreeting',
    b'CivVAccessCombatResolved',
    b'CivVAccessUnitMoved',
    b'GetSquadDestination',
    b'GeneratePathWithFlags',
]

def main(dll):
    pe = pefile.PE(dll, fast_load=True)
    data = open(dll, 'rb').read()
    off = data.find(b'%s - Startup (Version')
    if off < 0:
        print('FAIL: startup format string not found')
        return 2
    va = None
    for s in pe.sections:
        if s.PointerToRawData <= off < s.PointerToRawData + s.SizeOfRawData:
            va = off - s.PointerToRawData + s.VirtualAddress + pe.OPTIONAL_HEADER.ImageBase
    imm = '$0x%x' % va
    disasm = subprocess.run([OBJDUMP, '-d', '--no-show-raw-insn', dll],
                            capture_output=True, text=True).stdout
    lines = disasm.splitlines()
    refs = [i for i, l in enumerate(lines) if imm in l]
    if not refs:
        print('FAIL: no code reference to the startup string')
        return 2
    ok = False
    for i in refs:
        window = lines[max(0, i - 8):i + 2]
        if any(VERSION_IMM in w for w in window):
            ok = True
            print('GOOD call site (args pushed):')
            for w in window:
                print('   ', w.strip())
    if not ok:
        print('BAD: no version-number immediate (' + VERSION_IMM + ') near any reference - va_list likely synthesized:')
        for i in refs[:2]:
            for w in lines[max(0, i - 8):i + 2]:
                print('   ', w.strip())
        return 1

    missing = [m.decode() for m in PORT_MARKERS if data.find(m) < 0]
    if missing:
        print('BAD: CivVAccess port markers missing from this binary: %s '
              '(wrong branch built, or a re-pin rebase dropped the port)'
              % ', '.join(missing))
        return 1

    print('GOOD: va_start args intact and CivVAccess port markers found.')
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))

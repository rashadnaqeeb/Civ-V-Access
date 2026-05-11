"""Generate sounds/scanner_beep.wav for the scanner directional beep.

A single short tone the scanner fires once per cycle, encoding the displacement
from origin to target via the beacon's pan / pitch / volume math (see
CivVAccess_Beacons.updateBeaconParams). One beep per cycle, non-looping; pitch
is modulated +/-1 octave by the consumer at playback time, so the source
frequency lives in the middle of that range.

Tuning mirrors ONI Access's ScannerDirectionEarcon defaults, with two
deviations after in-game playtesting:
  * fundamental 457 Hz -- ONI's middle (horizontal) tone, picked here as the
    pitch-center so the +/-1 octave modulation lands on musically sensible
    edges (228 Hz at -12 semitones, 914 Hz at +12).
  * pure sine (DefaultHarmonics = { 1.0 }).
  * 75 ms total duration (ONI's 55 ms felt too brief in a cycle-keystroke
    context; an extra 20 ms makes the tone register without dragging on the
    next cycle), 5 ms linear fade-in and 5 ms fade-out. The fade kills the
    click an abrupt start / stop would produce when the cycle key fires the
    beep mid-cursor-step.

Sample rate / channels match beacon.wav: 44100 Hz mono 16-bit PCM. The peak
is 8640/32767 -- 20 percent above beacon.wav's 7200 peak. The beep fires once
per cycle keystroke and competes with the spoken readout for the user's
attention, so it sits slightly hotter than the continuously-running beacon
loop. Sliders downstream (BeaconVolume.MAX = 2.0) cannot drive this anywhere
near 32k -- 8640 * 2 = 17280 leaves ~7 dB of headroom against the int16
ceiling. Non-looping -- the proxy's set_loop(false) is the runtime guarantee,
but the WAV itself carries no loop marker either.

Run from the repo root:
    py tools/generate-scanner-beep.py
"""

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100

FREQ_HZ = 457.0
DURATION_SEC = 0.075
FADE_SEC = 0.005

PEAK = 8640

NUM_SAMPLES = int(SAMPLE_RATE * DURATION_SEC)
FADE_SAMPLES = int(SAMPLE_RATE * FADE_SEC)

OUTPUT_PATH = Path(__file__).resolve().parent.parent / "sounds" / "scanner_beep.wav"


def main() -> None:
    samples = []
    for i in range(NUM_SAMPLES):
        t = i / SAMPLE_RATE
        v = math.sin(2 * math.pi * FREQ_HZ * t)
        if i < FADE_SAMPLES:
            env = i / FADE_SAMPLES
        elif i > NUM_SAMPLES - FADE_SAMPLES:
            env = (NUM_SAMPLES - i) / FADE_SAMPLES
        else:
            env = 1.0
        samples.append(int(round(v * env * PEAK)))

    data = struct.pack("<" + "h" * NUM_SAMPLES, *samples)
    with wave.open(str(OUTPUT_PATH), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(data)

    print(f"Wrote {OUTPUT_PATH} ({NUM_SAMPLES} samples, {DURATION_SEC * 1000:.0f} ms, peak {PEAK})")


if __name__ == "__main__":
    main()

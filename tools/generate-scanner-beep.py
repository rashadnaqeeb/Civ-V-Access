"""Generate sounds/scanner_beep.wav for the scanner directional beep.

A single short tone the scanner fires once per cycle, encoding the displacement
from origin to target via the beacon's pan / pitch / volume math (see
CivVAccess_Beacons.updateBeaconParams). One beep per cycle, non-looping; pitch
is modulated +/-1 octave by the consumer at playback time, so the source
frequency lives in the middle of that range.

Tuning mirrors ONI Access's ScannerDirectionEarcon shape, with three
deviations after in-game playtesting:
  * fundamental 700 Hz, with 2nd / 3rd harmonics at 1400 / 2100 Hz and
    amplitude ratios 1.00 / 0.55 / 0.18 (ONI ships a pure sine at 457 Hz).
    The earlier 457 Hz fundamental sat below the ~500 Hz threshold where
    human stereo localization runs primarily on ILD (interaural level
    difference); at the -12 semitone rail it dropped to 228 Hz, deep into
    the ITD-dominant band where short transient tones pan poorly. 700 Hz
    keeps the fundamental near the ILD threshold at the center rail and
    pushes most spectral energy through the 2nd harmonic at 1400 Hz, which
    stays in the ILD-dominant band across the full +/-1 octave pitch range
    (700 Hz at -12, 2800 Hz at +12). The 0.55 ratio on the 2nd harmonic
    (vs the prior 0.22) is the load-bearing change for panning audibility;
    the 3rd harmonic at 0.18 adds the same edge-vs-beacon-loop character
    that the prior 3-partial design intended. Below-threshold energy still
    exists at the -12 rail (350 Hz fundamental) but no longer dominates.
    Frequencies are integer multiples of 700 Hz so the spatial-audio
    family's timbre stays harmonically clean -- a shift in pitch center,
    not a wholly different sound.
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

FUND_HZ = 700.0
HARM2_HZ = FUND_HZ * 2
HARM3_HZ = FUND_HZ * 3
HARM2_RATIO = 0.55
HARM3_RATIO = 0.18

DURATION_SEC = 0.075
FADE_SEC = 0.005

PEAK = 8640

NUM_SAMPLES = int(SAMPLE_RATE * DURATION_SEC)
FADE_SAMPLES = int(SAMPLE_RATE * FADE_SEC)

OUTPUT_PATH = Path(__file__).resolve().parent.parent / "sounds" / "scanner_beep.wav"


def main() -> None:
    # Normalize by the theoretical worst-case sum so the actual peak after
    # PEAK scaling lands at PEAK rather than overshooting on the instant
    # where all partials align in phase. Matches beacon.wav's normalization.
    norm = 1.0 + HARM2_RATIO + HARM3_RATIO
    samples = []
    for i in range(NUM_SAMPLES):
        t = i / SAMPLE_RATE
        v = (
            math.sin(2 * math.pi * FUND_HZ * t)
            + HARM2_RATIO * math.sin(2 * math.pi * HARM2_HZ * t)
            + HARM3_RATIO * math.sin(2 * math.pi * HARM3_HZ * t)
        ) / norm
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

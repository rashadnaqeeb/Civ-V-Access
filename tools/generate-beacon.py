"""Generate sounds/beacon.wav as a constant-amplitude looping tone.

The original beacon.wav carried a ~3.5 Hz tremolo whose pulsing was audible
once the looping voice held the source for more than a second. Stripping the
envelope and keeping the same fundamental gives a steady tone the listener
can hunt by pan, pitch, and volume without an unrelated AM layer beating
against the cursor movement.

Tuning (extracted from the prior beacon.wav via DFT on the loudest window):
  * fundamental ~160 Hz, second harmonic ~320 Hz at ~22% of the fundamental
    magnitude. The resulting tone is sine-dominant with a faint warmth from
    the 2nd harmonic, matching the perceived timbre of the original without
    its tremolo envelope.

Loop seam: duration is exactly 1 second and both partials are integer
multiples of 1 Hz, so the waveform at sample 0 equals the value at sample
44100 by phase. No fade-in / fade-out -- those would reintroduce an
envelope, which is what we're removing.

Output amplitude: peak ~7200/32767 (about -13 dBFS), close to the running
RMS of the original tremolo'd source so the BeaconVolume slider's existing
calibration carries over.

Run from the repo root:
    py tools/generate-beacon.py
"""

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100
DURATION_SEC = 1.0
NUM_SAMPLES = int(SAMPLE_RATE * DURATION_SEC)

FUND_HZ = 160
HARM_HZ = 320
HARM_RATIO = 0.22

PEAK = 7200

OUTPUT_PATH = Path(__file__).resolve().parent.parent / "sounds" / "beacon.wav"


def main() -> None:
    samples = []
    for i in range(NUM_SAMPLES):
        t = i / SAMPLE_RATE
        v = math.sin(2 * math.pi * FUND_HZ * t) + HARM_RATIO * math.sin(2 * math.pi * HARM_HZ * t)
        # Normalize by the (1 + HARM_RATIO) theoretical peak so the actual
        # output peak lands at PEAK rather than overshooting.
        v = v / (1.0 + HARM_RATIO)
        samples.append(int(round(v * PEAK)))

    data = struct.pack("<" + "h" * NUM_SAMPLES, *samples)
    with wave.open(str(OUTPUT_PATH), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(data)

    print(f"Wrote {OUTPUT_PATH} ({NUM_SAMPLES} samples, {DURATION_SEC} s, peak {PEAK})")


if __name__ == "__main__":
    main()

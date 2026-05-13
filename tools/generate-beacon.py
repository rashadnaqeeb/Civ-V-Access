"""Generate sounds/beacon.wav as a looping tone with a slow AM tremolo.

The beacon's stereo position, pitch, and volume are mutated in real time on
every cursor move (see CivVAccess_Beacons.updateBeaconParams). Two cue
families contribute to localization, and the source carries both: spectral
content above ~800 Hz (where human ILD panning reads cleanly), and periodic
onset transients from AM modulation (the precedence-effect cue that lets
the auditory system pick out the leading edge of each pulse). The partial
stack delivers the first; the tremolo envelope delivers the second.

Partial structure (harmonic series of 160 Hz, magnitudes pre-normalization):
  * 160 Hz (1st)  at 1.00  -- fundamental, identity anchor
  *  320 Hz (2nd)  at 0.35  -- warmth
  *  480 Hz (3rd)  at 0.20  -- fills the lower mid
  *  800 Hz (5th)  at 0.40  -- start of the ILD-strong localization band
  * 1280 Hz (8th)  at 0.35  -- the workhorse for stereo pan
  * 1760 Hz (11th) at 0.15  -- top-end brilliance, kept low so the
                               sustained tone does not turn strident

AM envelope: 2 Hz tremolo at 0.3 modulation depth, so the instantaneous
amplitude swings between 0.7 and 1.0 of the partial-sum peak. Reads as a
slow breathing rather than a pulse -- enough periodic onset for the
auditory system's leading-edge localization cue, without the throbbing
quality that a faster / deeper tremolo produces on long holds.

The tremolo is safe under cursor moves because the beacon voice runs
continuously after toggle-on -- only set_pan / set_pitch / set_volume fire
on cursor moves, no replay -- so the envelope evolves without resets.
ma_sound_set_pitch is a resampler rate change applied to the whole signal,
so the tremolo rate co-varies with row displacement (1 Hz at -12 semitones,
4 Hz at +12) as a passive side cue.

Loop seam: duration is 2 seconds. The 2 Hz tremolo closes at exactly 4
cycles, and every partial is an integer Hz multiple (so phase returns to
zero at t = 2 s for both the carrier sum and the envelope). The decoded
WAV lives in memory after ma_sound_init_from_file, so the slightly larger
loop (176 KB instead of 88 KB) is a non-issue.

Output amplitude: partial-sum peak ~7200/32767 (about -13 dBFS) at the
envelope's max (1.0). BeaconVolume slider calibration carries over.

Run from the repo root:
    py tools/generate-beacon.py
"""

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100
DURATION_SEC = 2.0
NUM_SAMPLES = int(SAMPLE_RATE * DURATION_SEC)

PARTIALS = [
    (160, 1.00),
    (320, 0.35),
    (480, 0.20),
    (800, 0.40),
    (1280, 0.35),
    (1760, 0.15),
]

TREMOLO_HZ = 2.0
TREMOLO_DEPTH = 0.3

PEAK = 7200

OUTPUT_PATH = Path(__file__).resolve().parent.parent / "sounds" / "beacon.wav"


def main() -> None:
    norm = sum(mag for _, mag in PARTIALS)
    samples = []
    for i in range(NUM_SAMPLES):
        t = i / SAMPLE_RATE
        carrier = sum(mag * math.sin(2 * math.pi * freq * t) for freq, mag in PARTIALS)
        carrier = carrier / norm
        envelope = 1.0 - TREMOLO_DEPTH * 0.5 * (1.0 - math.cos(2 * math.pi * TREMOLO_HZ * t))
        v = carrier * envelope
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

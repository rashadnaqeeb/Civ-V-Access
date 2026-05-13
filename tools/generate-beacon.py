"""Generate sounds/beacon.wav from sounds/ambient_zone.wav.

The source asset is a warm ambient pad (1.5 s, dual-mono, 44.1 kHz / 16-bit)
with most of its energy below 500 Hz -- strong 110 Hz fundamental plus
harmonics at 165, 220, 330, 440 Hz. That character is exactly what we
want for a pleasant beacon (no drone-y sustained tone, fades in and out
each loop), but human stereo localization runs mostly on ILD above
~500 Hz, so the source alone does not pan decisively.

This script downmixes the source to mono, normalizes its peak to the
historic beacon level (so the BeaconVolume slider stays calibrated), and
overlays a low-amplitude sheen layer of three sine partials in the ILD-
strong band. The sheen frequencies are integer multiples of the source's
110 Hz fundamental, so they blend with the existing harmonic series
rather than reading as a separate tone.

Sheen partials (frequency Hz, magnitude pre-normalization):
  *  880 Hz (8th  harmonic of 110) at 1.00
  * 1320 Hz (12th harmonic of 110) at 0.65
  * 1760 Hz (16th harmonic of 110) at 0.40

The sheen sits at ~25% of the source's normalized peak, low enough that
the source's body dominates the perceived timbre while the auditory
system still gets clear ILD content in the localizable band.

Loop seam: source loops cleanly (sample 0 and sample N are both zero;
the source has its own fade-in / fade-out built in). The sheen frequencies
are chosen so f * 1.5 is integer (1320, 1980, 2640 cycles per loop), so
the sheen layer is also phase-continuous at the seam. The generator
asserts this rather than trusting it silently.

Pitch interaction: ma_sound_set_pitch resamples the whole signal, so the
fade-in / fade-out cadence co-varies with cursor row, same as the prior
beacon iterations. The 1.5 s loop becomes 0.75 s at +12 semitones and 3 s
at -12, a passive side cue.

Run from the repo root:
    py tools/generate-beacon.py
"""

import math
import struct
import wave
from pathlib import Path

SOURCE_PATH = Path(__file__).resolve().parent.parent / "sounds" / "ambient_zone.wav"
OUTPUT_PATH = Path(__file__).resolve().parent.parent / "sounds" / "beacon.wav"

# Historic beacon peak: ~7200/32767 ≈ -13 dBFS. Keep this so the existing
# BeaconVolume slider settings produce the same loudness as before.
SOURCE_TARGET_PEAK = 7200

# Sheen peak as a fraction of SOURCE_TARGET_PEAK. 0.25 sits the sheen at
# -12 dB relative to the source body, audible enough to localize but
# quiet enough not to dominate the timbre.
SHEEN_PEAK_FRACTION = 0.25

SHEEN_PARTIALS = [
    (880, 1.00),
    (1320, 0.65),
    (1760, 0.40),
]


def read_source(path):
    w = wave.open(str(path), "rb")
    nchannels = w.getnchannels()
    sample_width = w.getsampwidth()
    framerate = w.getframerate()
    nframes = w.getnframes()
    frames = w.readframes(nframes)
    w.close()
    if sample_width != 2:
        raise ValueError(f"expected 16-bit PCM, got sample width {sample_width}")
    samples = struct.unpack("<" + "h" * (len(frames) // 2), frames)
    if nchannels == 1:
        mono = list(samples)
    elif nchannels == 2:
        mono = [(samples[2 * i] + samples[2 * i + 1]) // 2 for i in range(nframes)]
    else:
        raise ValueError(f"unsupported channel count {nchannels}")
    return mono, framerate


def main() -> None:
    source, framerate = read_source(SOURCE_PATH)
    n = len(source)
    duration = n / framerate

    for freq, _ in SHEEN_PARTIALS:
        cycles = freq * duration
        if abs(cycles - round(cycles)) > 1e-6:
            raise ValueError(
                f"sheen partial {freq} Hz does not close the loop seam: "
                f"{cycles} cycles in {duration} s, must be integer"
            )

    source_peak = max(abs(s) for s in source)
    if source_peak == 0:
        raise ValueError("source is silent")
    source_scale = SOURCE_TARGET_PEAK / source_peak

    sheen_norm = sum(amp for _, amp in SHEEN_PARTIALS)
    sheen_peak_target = SOURCE_TARGET_PEAK * SHEEN_PEAK_FRACTION

    out = []
    for i in range(n):
        t = i / framerate
        sheen_v = sum(amp * math.sin(2 * math.pi * f * t) for f, amp in SHEEN_PARTIALS)
        sheen_v = (sheen_v / sheen_norm) * sheen_peak_target
        combined = source[i] * source_scale + sheen_v
        c = int(round(combined))
        if c > 32767:
            c = 32767
        elif c < -32768:
            c = -32768
        out.append(c)

    data = struct.pack("<" + "h" * n, *out)
    with wave.open(str(OUTPUT_PATH), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(framerate)
        w.writeframes(data)

    print(f"Wrote {OUTPUT_PATH} ({n} samples, {duration:.3f} s)")


if __name__ == "__main__":
    main()

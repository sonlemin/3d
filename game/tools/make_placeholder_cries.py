#!/usr/bin/env python3
"""Write the ear test's placeholder cries: 2 mono 16-bit WAVs per level.

    python3 game/tools/make_placeholder_cries.py

Python standard library only, fixed seeds, so every run writes the same files.
No AI is involved anywhere: each cry is plain additive synthesis or filtered noise.

  above  -> shriek-like: 1.2-2.5 kHz pitch glide, vibrato, harsh harmonics, sharp attack
  inside -> sob-like:    ~330 -> 220 Hz falling voiced tone with hiccup stutters
  below  -> whisper-like: band-limited breathy noise shaped into syllables

Real clips replace these later: drop them into game/audio/cries/<level>/, delete the
placeholder_*.wav files there, log the source in game/audio/cries/CREDITS.md, then run
`godot --headless --path game --import`.
"""

import math
import os
import random
import struct
import wave

SAMPLE_RATE = 44100
TARGET_RMS_DBFS = -18.0
PEAK_LIMIT_DBFS = -1.0
TWO_PI = 2.0 * math.pi

CRIES_DIR = os.path.normpath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "audio", "cries")
)


# ---------------------------------------------------------------- helpers


def lerp(a, b, u):
    return a + (b - a) * u


def smoothstep(u):
    u = min(max(u, 0.0), 1.0)
    return u * u * (3.0 - 2.0 * u)


def normalize(samples):
    """Scale to the target RMS, then pull down if the peak would clip."""
    rms = math.sqrt(sum(s * s for s in samples) / len(samples))
    peak = max(abs(s) for s in samples)
    if rms <= 0.0 or peak <= 0.0:
        return samples
    gain = (10.0 ** (TARGET_RMS_DBFS / 20.0)) / rms
    peak_limit = 10.0 ** (PEAK_LIMIT_DBFS / 20.0)
    if peak * gain > peak_limit:
        gain = peak_limit / peak
    return [s * gain for s in samples]


def fade_edges(samples, fade_s=0.004):
    """Tiny fades so no clip starts or ends on a click."""
    n = min(int(fade_s * SAMPLE_RATE), len(samples) // 2)
    for i in range(n):
        g = i / n
        samples[i] *= g
        samples[-1 - i] *= g
    return samples


def write_wav(path, samples):
    ints = [max(-32767, min(32767, int(round(s * 32767.0)))) for s in samples]
    with wave.open(path, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(struct.pack("<%dh" % len(ints), *ints))


class BandPass:
    """RBJ-cookbook band-pass biquad (constant 0 dB peak gain)."""

    def __init__(self, center_hz, q):
        self.x1 = self.x2 = self.y1 = self.y2 = 0.0
        self.set(center_hz, q)

    def set(self, center_hz, q):
        w0 = TWO_PI * center_hz / SAMPLE_RATE
        alpha = math.sin(w0) / (2.0 * q)
        a0 = 1.0 + alpha
        self.b0 = alpha / a0
        self.b2 = -alpha / a0
        self.a1 = -2.0 * math.cos(w0) / a0
        self.a2 = (1.0 - alpha) / a0

    def process(self, x):
        y = self.b0 * x + self.b2 * self.x2 - self.a1 * self.y1 - self.a2 * self.y2
        self.x2, self.x1 = self.x1, x
        self.y2, self.y1 = self.y1, y
        return y


# ---------------------------------------------------------------- above: shriek


def shriek(rng, duration, f_start, f_peak, f_end, peak_at, vibrato_hz, vibrato_depth):
    n = int(duration * SAMPLE_RATE)
    out = []
    phase = 0.0
    jitter = 0.0
    attack_s = 0.006
    release_s = duration * 0.3
    for i in range(n):
        t = i / SAMPLE_RATE
        u = t / duration
        if u < peak_at:
            f = lerp(f_start, f_peak, smoothstep(u / peak_at))
        else:
            f = lerp(f_peak, f_end, smoothstep((u - peak_at) / (1.0 - peak_at)))
        jitter = 0.995 * jitter + 0.005 * rng.uniform(-1.0, 1.0)
        f *= 1.0 + vibrato_depth * math.sin(TWO_PI * vibrato_hz * t) + 0.02 * jitter
        phase = (phase + TWO_PI * f / SAMPLE_RATE) % TWO_PI
        s = (
            math.sin(phase)
            + 0.55 * math.sin(2.0 * phase)
            + 0.40 * math.sin(3.0 * phase)
            + 0.25 * math.sin(4.0 * phase)
            + 0.15 * math.sin(5.0 * phase)
        )
        s = math.tanh(2.2 * s)  # hard drive: harsh, buzzy upper harmonics
        s += 0.06 * rng.uniform(-1.0, 1.0)  # rasp
        if t < attack_s:
            env = t / attack_s
        elif t > duration - release_s:
            env = (duration - t) / release_s
        else:
            env = 1.0
        out.append(s * env)
    return out


# ---------------------------------------------------------------- inside: sob


def sob(rng, duration, f_start, f_end, hiccup_times):
    n = int(duration * SAMPLE_RATE)
    hiccups = [h + rng.uniform(-0.03, 0.03) for h in hiccup_times]
    gap_s = 0.07  # the "catch": the voice cuts out
    regain_s = 0.09  # then comes back quickly, with a pitch blip
    out = []
    phase = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        u = t / duration
        f = f_start * (f_end / f_start) ** u
        f *= 1.0 + 0.012 * math.sin(TWO_PI * 5.5 * t)
        amp = 1.0
        for h in hiccups:
            dt = t - h
            if 0.0 <= dt < gap_s:
                amp = min(amp, 0.04)
            elif gap_s <= dt < gap_s + regain_s:
                k = (dt - gap_s) / regain_s
                amp = min(amp, 0.04 + 1.2 * math.sin(math.pi * 0.5 * min(k * 2.0, 1.0)))
                f *= 1.0 + 0.08 * (1.0 - k)
        phase = (phase + TWO_PI * f / SAMPLE_RATE) % TWO_PI
        s = 0.0
        for k in range(1, 11):
            hz = f * k
            formant = 1.0 + 1.5 * math.exp(-(((hz - 750.0) / 300.0) ** 2))
            s += formant * math.sin(k * phase) / k
        s += 0.04 * rng.uniform(-1.0, 1.0)  # breath
        env = min(1.0, t / 0.04) * min(1.0, (duration - t) / 0.25)
        out.append(s * amp * env)
    return out


# ---------------------------------------------------------------- below: whisper


def whisper(rng, duration, syllables):
    """syllables: list of (start_s, length_s, centre_hz)."""
    n = int(duration * SAMPLE_RATE)
    low_band = [BandPass(1000.0, 1.6), BandPass(1000.0, 1.6)]
    high_band = BandPass(2200.0, 2.0)
    current = None
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = 0.0
        active = None
        for idx, (start, length, centre) in enumerate(syllables):
            if start <= t < start + length:
                active = idx
                k = (t - start) / length
                attack, release = 0.15, 0.45
                if k < attack:
                    env = 0.5 - 0.5 * math.cos(math.pi * k / attack)
                elif k > 1.0 - release:
                    env = 0.5 + 0.5 * math.cos(math.pi * (k - (1.0 - release)) / release)
                else:
                    env = 1.0
                break
        if active is not None and active != current:
            current = active
            centre = syllables[active][2]
            for band in low_band:
                band.set(centre, 1.6)
            high_band.set(centre * 2.1, 2.0)
        x = rng.uniform(-1.0, 1.0)
        y = low_band[1].process(low_band[0].process(x))
        y += 0.45 * high_band.process(x)
        out.append(y * env)
    return out


# ---------------------------------------------------------------- the six clips


def build_all():
    clips = {
        "above/placeholder_above_1.wav": shriek(
            random.Random(1101), 1.8, 1200.0, 2450.0, 1700.0, 0.35, 7.0, 0.03
        ),
        "above/placeholder_above_2.wav": shriek(
            random.Random(1102), 2.4, 1350.0, 2350.0, 1250.0, 0.55, 9.5, 0.025
        ),
        "inside/placeholder_inside_1.wav": sob(
            random.Random(2101), 2.6, 330.0, 220.0, [0.45, 0.95, 1.35, 1.9]
        ),
        "inside/placeholder_inside_2.wav": sob(
            random.Random(2102), 3.0, 310.0, 225.0, [0.35, 0.75, 1.4, 1.8, 2.35]
        ),
        "below/placeholder_below_1.wav": whisper(
            random.Random(3101),
            2.2,
            [(0.05, 0.30, 900.0), (0.42, 0.22, 1400.0), (0.70, 0.35, 1100.0),
             (1.18, 0.25, 1700.0), (1.55, 0.50, 800.0)],
        ),
        "below/placeholder_below_2.wav": whisper(
            random.Random(3102),
            2.8,
            [(0.05, 0.25, 1200.0), (0.36, 0.30, 850.0), (0.80, 0.20, 1600.0),
             (1.08, 0.40, 1000.0), (1.62, 0.28, 1350.0), (2.02, 0.65, 750.0)],
        ),
    }
    for rel_path, samples in clips.items():
        path = os.path.join(CRIES_DIR, rel_path)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        write_wav(path, fade_edges(normalize(samples)))
        print("wrote %s  (%.2f s, mono, 16-bit, %d Hz)"
              % (os.path.relpath(path), len(samples) / SAMPLE_RATE, SAMPLE_RATE))


if __name__ == "__main__":
    build_all()

#!/usr/bin/env python3
"""Cut the source recordings in source_audio/cries/<kind>/ into ear-test clips.

    python3 game/tools/cut_cries.py [--replace-placeholders]

Sources are .wav (PCM 16/24/32-bit) or .ogg/.mp3, which are decoded through Godot first
(tools/decode_audio.gd). For each recording it cuts rumble below 80 Hz, picks the densest CLIP_S-long stretches of voice
(up to 2 per recording; 1 if it is short), mixes to mono, removes DC, normalizes like the
placeholders (-18 dBFS RMS over the voiced part, peaks kept under -1 dBFS), fades the edges and
writes 16-bit 44.1 kHz WAVs as game/audio/cries/<kind>/<id>_<user>_<n>.wav.

Per-recording overrides live in source_audio/cries/cuts.json, keyed by the Freesound ID:
  {"790475": {"range": [0.0, 14.0], "clips": 2}}   (use only 0-14 s, at most 2 clips)

Every run rewrites the generated clips (files named <digits>_*.wav) in the three level folders.
Placeholders (placeholder_*.wav) are left alone unless --replace-placeholders deletes them.
Afterwards: run the Godot import, then tools/measure_loudness.gd, and update CREDITS.md.

Needs numpy, and Godot 4.7 on PATH (or $GODOT) for compressed sources. No AI anywhere.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import wave

import numpy as np

RATE = 44100
CLIP_S = 4.3  # a little over the 4 s cry window, so a clip never loops within a trial
FRAME_S = 0.05
ACTIVE_BELOW_PEAK_DB = 30.0  # a frame counts as voice when within this much of the loudest frame
SECOND_CLIP_MIN_ACTIVE = 0.6  # a second clip only if at least this much of it is voice
TARGET_RMS_DBFS = -18.0
PEAK_LIMIT_DBFS = -1.0
## Rumble cut before anything else: below this a voice has nothing, but mic drift and
## handling noise can hold most of a recording's energy and throw off the normalizing.
HIGH_PASS_HZ = 80.0
FADE_IN_S = 0.01
FADE_OUT_S = 0.06
KINDS = ["above", "inside", "below"]

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
SOURCE_DIR = os.path.join(ROOT, "source_audio", "cries")
GAME_DIR = os.path.join(ROOT, "game")
CLIPS_DIR = os.path.join(GAME_DIR, "audio", "cries")
GENERATED = re.compile(r"^\d+_.+\.wav$")


def read_wav(path):
    """Returns (mono float64 samples, rate)."""
    with wave.open(path, "rb") as w:
        channels, width, rate, n = w.getnchannels(), w.getsampwidth(), w.getframerate(), w.getnframes()
        raw = w.readframes(n)
    if width == 2:
        x = np.frombuffer(raw, "<i2").astype(np.float64) / 32768.0
    elif width == 3:
        b = np.frombuffer(raw, np.uint8).reshape(-1, 3).astype(np.int32)
        v = b[:, 0] | (b[:, 1] << 8) | (b[:, 2] << 16)
        x = np.where(v >= 1 << 23, v - (1 << 24), v).astype(np.float64) / float(1 << 23)
    elif width == 4:
        x = np.frombuffer(raw, "<i4").astype(np.float64) / float(1 << 31)
    else:
        raise ValueError("%s: %d-bit WAV not supported" % (path, width * 8))
    return x.reshape(-1, channels).mean(axis=1), rate


def resample(x, rate):
    """FFT resampling of the whole recording to RATE."""
    if rate == RATE:
        return x
    n = int(round(len(x) * RATE / rate))
    spectrum = np.fft.rfft(x)
    keep = min(len(spectrum), n // 2 + 1)
    out = np.zeros(n // 2 + 1, complex)
    out[:keep] = spectrum[:keep]
    return np.fft.irfft(out, n) * (n / len(x))


def decode_compressed(paths, workdir):
    """Decodes .ogg/.mp3 sources through Godot; returns {source: decoded wav}."""
    godot = os.environ.get("GODOT") or shutil.which("godot") or os.path.expanduser("~/.local/bin/godot")
    pairs, args = {}, []
    for path in paths:
        target = os.path.join(workdir, os.path.basename(path) + ".wav")
        pairs[path] = target
        args += [os.path.abspath(path), target]
    if args:
        result = subprocess.run([godot, "--headless", "--path", GAME_DIR, "-s", "res://tools/decode_audio.gd", "--"] + args,
                                capture_output=True, text=True)
        if result.returncode != 0:
            sys.exit("decode failed:\n" + result.stdout + result.stderr)
    return pairs


def high_pass(x):
    """Removes everything below HIGH_PASS_HZ (raised-cosine edge over the octave below it)."""
    spectrum = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1.0 / RATE)
    edge = np.clip((f - HIGH_PASS_HZ / 2.0) / (HIGH_PASS_HZ / 2.0), 0.0, 1.0)
    return np.fft.irfft(spectrum * (0.5 - 0.5 * np.cos(np.pi * edge)), len(x))


def frame_db(x):
    hop = int(FRAME_S * RATE)
    frames = x[: len(x) // hop * hop].reshape(-1, hop)
    return 20.0 * np.log10(np.sqrt((frames ** 2).mean(axis=1)) + 1e-12)


def pick_windows(x, max_clips):
    """Start samples of up to max_clips non-overlapping CLIP_S windows, densest voice first."""
    db = frame_db(x)
    active = db > db.max() - ACTIVE_BELOW_PEAK_DB
    n = int(round(CLIP_S / FRAME_S))
    if len(active) <= n:  # shorter than one clip: use it all, from the first voiced frame
        first = int(np.argmax(active))
        return [max(0, first * int(FRAME_S * RATE) - int(0.03 * RATE))], [float(active.mean())]
    taken = np.zeros(len(active), bool)
    starts, scores = [], []
    for k in range(max_clips):
        best, best_score = -1, -1.0
        for s in range(0, len(active) - n + 1):
            if taken[s:s + n].any():
                continue
            score = active[s:s + n].mean()
            if score > best_score:
                best, best_score = s, score
        if best < 0 or (k > 0 and best_score < SECOND_CLIP_MIN_ACTIVE):
            break
        # Start at the first voiced frame in the window (a clip never opens on silence).
        onset = best + int(np.argmax(active[best:best + n]))
        onset = min(onset, len(active) - n)
        if taken[onset:onset + n].any():
            onset = best
        taken[onset:onset + n] = True
        starts.append(max(0, onset * int(FRAME_S * RATE) - int(0.03 * RATE)))
        scores.append(float(active[onset:onset + n].mean()))
    return starts, scores


def finish(clip):
    clip = clip - clip.mean()
    db = frame_db(clip)
    voiced = db > db.max() - ACTIVE_BELOW_PEAK_DB
    hop = int(FRAME_S * RATE)
    frames = clip[: len(clip) // hop * hop].reshape(-1, hop)[voiced]
    rms = np.sqrt((frames ** 2).mean()) if len(frames) else np.sqrt((clip ** 2).mean())
    gain = 10 ** (TARGET_RMS_DBFS / 20.0) / max(rms, 1e-9)
    peak = np.abs(clip).max() * gain
    if peak > 10 ** (PEAK_LIMIT_DBFS / 20.0):
        gain *= 10 ** (PEAK_LIMIT_DBFS / 20.0) / peak
    clip = clip * gain
    fade_in, fade_out = int(FADE_IN_S * RATE), int(FADE_OUT_S * RATE)
    clip[:fade_in] *= np.linspace(0.0, 1.0, fade_in)
    clip[-fade_out:] *= np.linspace(1.0, 0.0, fade_out)
    return clip


def write_wav(path, x):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((np.clip(x, -1.0, 1.0) * 32767.0).round().astype("<i2").tobytes())


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--replace-placeholders", action="store_true",
                        help="delete placeholder_*.wav (and their .import files) in the level folders")
    args = parser.parse_args()
    cuts_path = os.path.join(SOURCE_DIR, "cuts.json")
    cuts = json.load(open(cuts_path)) if os.path.exists(cuts_path) else {}

    sources = {k: sorted(f for f in os.listdir(os.path.join(SOURCE_DIR, k))
                         if f.lower().endswith((".wav", ".ogg", ".mp3"))) for k in KINDS}
    if not any(sources.values()):
        sys.exit("no sources in %s/<kind>/" % SOURCE_DIR)
    with tempfile.TemporaryDirectory() as work:
        compressed = [os.path.join(SOURCE_DIR, k, f) for k in KINDS for f in sources[k] if not f.lower().endswith(".wav")]
        decoded = decode_compressed(compressed, work)
        for kind in KINDS:
            folder = os.path.join(CLIPS_DIR, kind)
            for f in sorted(os.listdir(folder)):
                if not f.endswith(".wav"):
                    continue  # .import files go with their .wav below
                if GENERATED.match(f) or (args.replace_placeholders and f.startswith("placeholder_")):
                    os.remove(os.path.join(folder, f))
                    if os.path.exists(os.path.join(folder, f + ".import")):
                        os.remove(os.path.join(folder, f + ".import"))
            for name in sources[kind]:
                path = os.path.join(SOURCE_DIR, kind, name)
                sid, user = (name.split("__") + ["", ""])[:2]
                x, rate = read_wav(decoded.get(path, path))
                x = high_pass(resample(x, rate))
                rule = cuts.get(sid, {})
                if "range" in rule:
                    a, b = rule["range"]
                    x = x[int(a * RATE): int(b * RATE)]
                max_clips = rule.get("clips", 2 if len(x) >= 2.5 * CLIP_S * RATE else 1)
                starts, scores = pick_windows(x, max_clips)
                for i, (start, score) in enumerate(zip(starts, scores), 1):
                    clip = finish(x[start:start + int(CLIP_S * RATE)].copy())
                    out = "%s_%s_%d.wav" % (sid, re.sub(r"[^a-z0-9]+", "-", user.lower()).strip("-"), i)
                    write_wav(os.path.join(folder, out), clip)
                    print("%-6s %-34s from %5.2f s  %.2f s  voiced %3d%%"
                          % (kind, out, start / RATE + rule.get("range", [0])[0], len(clip) / RATE, round(score * 100)))


if __name__ == "__main__":
    main()

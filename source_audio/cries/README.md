# Source recordings for the ear-test cries

The uncut recordings behind the clips in `game/audio/cries/<level>/`. They stay outside `game/`
so Godot doesn't import them. Each folder holds one kind of cry: `above/` shrieks, `inside/`
sobs, `below/` whispers (the test mixes the kinds across levels).

All 11 are **CC0 1.0** human recordings from Freesound (license checked on each sound's page on
2026-11-19; no AI, synthesis or text-to-speech). `sources.json` lists each one's title, author
and page.

**These are Freesound's public previews** (hq Ogg Vorbis, lossy), named
`<id>__<user>__<title>.preview.ogg`. They're fine for the ear test. For the released game,
download the originals (a free Freesound account is needed), put them in the same folder with
the name Freesound gives them (same ID), delete the `.preview.ogg`, and re-cut.

## Re-cutting

```
python3 game/tools/cut_cries.py                                    # rewrites the clips
godot --headless --path game --import
godot --headless --path game -s res://tools/measure_loudness.gd -- --write   # ~6.5 s per clip per level
godot --headless --path game -s res://tools/measure_loudness.gd -- --verify
```

`cut_cries.py` decodes .ogg/.mp3 through Godot (WAV sources are read directly), removes rumble
below 80 Hz, cuts the densest 4.3 s of voice (up to 2 clips per recording), mixes to mono and
normalizes. `cuts.json` holds per-recording overrides (for example, only the first take of
`790475`). Then update `game/audio/cries/CREDITS.md`.

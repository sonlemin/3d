# Cry credits

Every clip under `audio/cries/<level>/` needs an entry here before it is used in a test session.
No AI-generated audio.

## Placeholders

The `placeholder_*.wav` files are synthesized by `game/tools/make_placeholder_cries.py`
(Python standard library, fixed seeds). No recordings, no third-party audio, no AI.
Delete them once real clips are in place for that level.

## Entry template

Copy this block once per clip:

```
### <level>/<file name>.wav
- Source: <library / site / recorded by whom>
- Original file or URL: <...>
- Author: <...>
- License: <e.g. CC0 1.0 / CC BY 4.0 / own recording>
- Attribution text (if the license requires it): <...>
- Edits: <trimmed, converted to mono 16-bit WAV, normalized, ...>
- Added by / date: <...>
```

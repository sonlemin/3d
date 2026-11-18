# Cry credits

Every clip under `audio/cries/<level>/` needs an entry here before it is used in a test session.
No AI-generated audio.

## Current clips (all CC0 1.0, from Freesound)

All are human recordings (checked: no AI, synthesis or text-to-speech in any description or tag).
CC0 needs no attribution; the authors are credited anyway. The license was checked on each
sound's Freesound page on 2026-11-19.

Source files are Freesound's public **previews** (hq Ogg Vorbis, lossy), kept uncut in
`source_audio/cries/` with `sources.json`. `game/tools/cut_cries.py` turned them into these clips:
decoded through Godot, rumble below 80 Hz removed, mixed to mono, the densest 4.3 s of voice cut
out, normalized to -18 dBFS RMS (peaks under -1 dBFS), 10 ms fade in and 60 ms fade out, saved as
16-bit 44.1 kHz WAV. For the released game, replace the previews with the original downloads
(same IDs) and re-run the tool.

| Clip | Sound | Author | Source |
|---|---|---|---|
| `above/319258_the-sound-side_1.wav` | woman screaming of fear | The_Sound_Side | [freesound.org/s/319258](https://freesound.org/people/The_Sound_Side/sounds/319258/) |
| `above/320740_aderumoro_1.wav` | Horror shrieks woman | AderuMoro | [freesound.org/s/320740](https://freesound.org/people/AderuMoro/sounds/320740/) |
| `above/384213_vidrik_1.wav` | Woman scream | Vidrik | [freesound.org/s/384213](https://freesound.org/people/Vidrik/sounds/384213/) |
| `above/384213_vidrik_2.wav` | Woman scream | Vidrik | [freesound.org/s/384213](https://freesound.org/people/Vidrik/sounds/384213/) |
| `above/520285_hisoul_1.wav` | Zisa, Cry, Scream, Sad, Weep, Hysteric_7 | hisoul | [freesound.org/s/520285](https://freesound.org/people/hisoul/sounds/520285/) |
| `inside/172738_alucardsbride_1.wav` | crying woman | AlucardsBride | [freesound.org/s/172738](https://freesound.org/people/AlucardsBride/sounds/172738/) |
| `inside/172738_alucardsbride_2.wav` | crying woman | AlucardsBride | [freesound.org/s/172738](https://freesound.org/people/AlucardsBride/sounds/172738/) |
| `inside/218184_mvvoiceacting_1.wav` | Girl Crying | mvVoiceActing | [freesound.org/s/218184](https://freesound.org/people/mvVoiceActing/sounds/218184/) |
| `inside/849642_iamthecomet_1.wav` | sobbing | iamthecomet | [freesound.org/s/849642](https://freesound.org/people/iamthecomet/sounds/849642/) |
| `below/193812_geoneo0_1.wav` | Four_Voices_Whispering_6 | geoneo0 | [freesound.org/s/193812](https://freesound.org/people/geoneo0/sounds/193812/) |
| `below/271633_carmsie_1.wav` | Do you want to know a secret | carmsie | [freesound.org/s/271633](https://freesound.org/people/carmsie/sounds/271633/) |
| `below/790475_greasyplastic_1.wav` | Female Whisper: You better run | GreasyPlastic | [freesound.org/s/790475](https://freesound.org/people/GreasyPlastic/sounds/790475/) |
| `below/832739_evamusik_1.wav` | LongWhisper | EvaMusik | [freesound.org/s/832739](https://freesound.org/people/EvaMusik/sounds/832739/) |

`790475` ("You better run"): only the first, unprocessed take is used (0 to 14 s); the repeat
has a phone EQ and room reverb. Set in `source_audio/cries/cuts.json`.

## Placeholders (no longer in use)

`game/tools/make_placeholder_cries.py` synthesizes stand-ins (Python standard library, fixed
seeds, no recordings, no AI) for a checkout with no clips. It refuses folders that hold real clips.

## Entry template

For a clip added by hand rather than by `cut_cries.py`:

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

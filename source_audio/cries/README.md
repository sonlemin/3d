# Source recordings for the ear-test cries

Original, uncut downloads go here. They stay outside `game/`, so Godot doesn't import the long
raw files. Claude cuts them into 4-6 s mono clips in `game/audio/cries/<level>/` and logs them
in `game/audio/cries/CREDITS.md`.

Every file below is **CC0** on Freesound (checked 2026-11-19 on each sound's page). Download the
**original WAV** (the download button needs a free Freesound account) and keep the file name
Freesound gives it (it starts with the sound's ID).

## `above/`: shrieks

- [ ] [Woman scream, Vidrik](https://freesound.org/people/Vidrik/sounds/384213/) (28 s)
- [ ] [woman screaming of fear, The_Sound_Side](https://freesound.org/people/The_Sound_Side/sounds/319258/) (16 s)
- [ ] [Zisa, Cry, Scream, Sad, Weep, Hysteric_7, hisoul](https://freesound.org/people/hisoul/sounds/520285/) (5 s)
- [ ] optional: [Horror shrieks woman, AderuMoro](https://freesound.org/people/AderuMoro/sounds/320740/) (8 s)

## `inside/`: sobs

- [ ] [crying woman, AlucardsBride](https://freesound.org/people/AlucardsBride/sounds/172738/) (27 s)
- [ ] [sobbing, iamthecomet](https://freesound.org/people/iamthecomet/sounds/849642/) (44 s)
- [ ] [Girl Crying, mvVoiceActing](https://freesound.org/people/mvVoiceActing/sounds/218184/) (35 s)

## `below/`: whispers

- [ ] [LongWhisper, EvaMusik](https://freesound.org/people/EvaMusik/sounds/832739/) (6 s)
- [ ] [Female Whisper "You better run", GreasyPlastic](https://freesound.org/people/GreasyPlastic/sounds/790475/) (28 s; only the first, bare take is used)
- [ ] [Do you want to know a secret, carmsie](https://freesound.org/people/carmsie/sounds/271633/) (12 s)
- [ ] optional: [Four_Voices_Whispering_6, geoneo0](https://freesound.org/people/geoneo0/sounds/193812/) (10 s)

WAV only, please: the server has no decoder for MP3, FLAC or other formats.

## Sending them to the server

From your laptop clone:

```
git pull
# put the files into source_audio/cries/above, inside and below
git add source_audio
git commit -m "Add CC0 cry recordings"
git push origin HEAD:clips
```

That pushes to a new `clips` branch on the server (the server's working copy is on
`ear-test-prototype`, so it can't receive a push to that branch directly).

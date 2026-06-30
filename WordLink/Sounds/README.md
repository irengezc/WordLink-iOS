# Sound effects

Drop optional `.wav` files in **this folder** to override the built-in
synthesized cues. This is a blue *folder reference* in the Xcode project, so any
file you add here is bundled automatically — no project edits needed.

`SoundManager` looks for these names (each falls back to a synth tone if absent):

| File                  | Cue                              | Length    |
|-----------------------|----------------------------------|-----------|
| `tap.wav`             | letter tapped                    | < 0.2s    |
| `snap.wav`            | two halves snap into a link      | < 0.3s    |
| `success.wav`         | chain link completed             | < 1s      |
| `level_complete.wav`  | level finished (fanfare)         | ~2s       |
| `wrong.wav`           | wrong answer (optional)          | < 0.5s    |
| `hint.wav`            | hint revealed (optional)         | < 0.3s    |

Source free SFX from [freesound.org](https://freesound.org) or
[kenney.nl](https://kenney.nl). Keep them mono and trimmed.

A single mute toggle (the speaker button on the Home screen) silences both the
`.wav` and synthesized paths and persists across launches.

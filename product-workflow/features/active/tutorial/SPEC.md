# Feature: First-Time Tutorial

Status: implementation
Owner: product
Last updated: 2026-06-19

## Problem

A new player opening WordLink sees a "LINK WORD" and a row of letter tiles with
no explanation of the core mechanic — that they must guess the hidden word which
forms a compound/collocation with the link word (e.g. `GO` + `UP`). The
concept, the tile reading (revealed letter + `?` + letter count), the hint
system, and the scoring are all undiscovered. We need an onboarding flow that
makes a first-timer confident within ~60–90 seconds.

## Approach: guided real game (reuse the live interface)

The tutorial is **the real game on the real `GameView`**, run in a guided mode —
not a separate tutorial screen. Same top bar (close / score / hint), same
progress bar, same letter tiles, same flashcards, same keyboard, and the same
real Results screen at the end. There is nothing tutorial-specific for the player
to relearn when they start their first real game.

Guidance is layered on top of the live screen as:
- A **coach banner** under the progress bar whose copy is derived directly from
  game state (`GameViewModel.tutorialCoach`), so it always stays in sync.
- A labeled **Hint** pill in the top bar, with a spotlight during the second
  link to teach hints once.
- A small active-card phrase preview (`GO + U_`) so the relationship between the
  link word and target word is visible before the user solves.

**Gating comes for free from the game loop:** you cannot reach link 2 until link
1 is solved. No artificial per-step gates or touch-swallowing overlays are
needed — the strict "can't skip ahead" behavior is inherent to the game.

To guarantee no one is trapped, solve steps have two safety nets: the first
coach prompt gives away the first answer, and after 3 wrong guesses an extra
letter is auto-revealed for free (no point cost); if the word becomes fully
revealed it auto-completes. The tutorial also nudges the Hint button after 3
seconds of inactivity. The tutorial always ends in a win.

### Tutorial chain (hand-authored, not a reservoir pull)

`GO → UP → SIDE → WALK` (3 connections, on the Easy budget).

- GO UP — to move higher or increase
- UPSIDE — the positive part of a situation
- SIDEWALK — a path beside a road for people walking

The first target is intentionally almost solved (`U_`) so new players cannot
stall before they understand the mechanic. The progress bar reflects the chain
length (3) via `GameViewModel.totalWords`, which is now derived from the loaded
chain rather than the fixed `GameConstants.maxWords`.

### Coach flow (state-driven, not a step machine)

| Game state | Coach copy teaches |
|------------|--------------------|
| Link 1 (`GO`) | The link-word concept + first answer in prompt + typing the rest |
| Link 2 (`UP`), no hint used | Solved pairs become flashcards + tap Hint once |
| Link 2, after a hint | Hint cost/effect + finish the word |
| Last link (`SIDE`) | Finish to complete the chain |
| Game over | → real Results screen |

## Success criteria (maps to the original questions)

1. **Accessible after first pass** — `hasSeenTutorial` flag in `StorageService`
   (UserDefaults). Auto-shown once on first launch. Permanently re-launchable
   from a **How to Play** button on `HomeView`.
2. **Gist + confidence** — player does real solves on the real interface, not
   passive slides; what they learn transfers 1:1 to actual play.
3. **Length** — 3 connections, ~60–90s, not all 8.
4. **Coverage** — link-word concept, reading tiles, typing/auto-submit, hints
   (cost + effect via the real hint button), scoring (real score updates live),
   flashcard/pronunciation payoff (real flashcards + spoken answer).
5. **Completion check** — the game loop gates progression; the safety net
   guarantees completion; flag set on completion **or** on early exit/replay.

## Files

- `WordLink/ViewModels/GameViewModel.swift` — `isTutorial` guided-mode flag,
  hand-authored chain, `startTutorial()`, `tutorialCoach`, chain-derived
  `totalWords`, tutorial safety net in `processWrongGuess`, first-launch routing,
  and tutorial-aware `finishGame` / `goHome` (mark seen, skip history save).
- `WordLink/Views/GameView.swift` — coach banner, labeled hint pill,
  hint spotlight/pulse, 3-second idle nudge, and progress bar driven by
  `vm.totalWords`.
- `WordLink/Views/Components/WordDisplayView.swift` — active-card phrase
  preview.
- `WordLink/Services/StorageService.swift` — `hasSeenTutorial` get/set.
- `WordLink/Views/HomeView.swift` — How to Play button → `goToTutorial()`.

## Out of scope (v1)

- A separate tutorial screen / `TutorialView` (removed — we reuse `GameView`).
- Strict artificial per-step gates with touch-swallowing overlays.
- Localization of coach copy.

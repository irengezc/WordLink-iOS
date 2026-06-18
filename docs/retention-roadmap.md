# Retention Roadmap

## Goal

Give players a reason to come back after the initial 24 levels / roughly 150
chains are exhausted. Retention matters directly for both learning outcomes and
ad revenue.

## Priority

Daily challenge and content depth are the second product priority, after the
first monetization pass and before ASO iteration becomes the main loop.

Daily challenge is intentionally pulled ahead of battle mode and flashcards.
Battle mode adds social/multiplayer complexity, while flashcards strengthen the
learning loop but do not by themselves create a daily habit.

## Daily Challenge

Product intent:

- One shared challenge per calendar day.
- Fast, repeatable session that builds habit.
- Preserve the ESL angle through clear phrase explanations after completion.

Recommended first version:

- One daily chain.
- Difficulty can start as medium or use a rotating difficulty schedule.
- Show completion state for today.
- Save daily result locally and, when backend support exists, per anonymous user.
- Add share text that includes the date, difficulty, and score without spoiling
  answers.

Open product decisions:

- Whether all users receive exactly the same daily chain globally.
- Whether daily reset should be device-local, UTC, or user-local timezone.
- Whether missed days matter. Avoid streak pressure until the core loop is
  validated.

## Content Library Expansion

The app needs more pre-generated chains to support both daily challenge and
regular play.

Committed constraint:

- Keep content pre-generated.
- Do not generate the primary gameplay chain live in-app.
- Continue duplicate checking before inserting chains.

Fast-loading direction:

- Use the local bundled reservoir as the first source for normal game starts.
- Keep starts instant even when Supabase is slow, expired, or offline.
- Treat Supabase as optional refill/sync/backend infrastructure rather than a
  hard dependency before the first puzzle appears.
- Expand the bundled starter reservoir substantially beyond the current 45
  chains so early users can play for a while.

Current repo verification:

- `WordLink/reservoir.json` exists and currently contains a cleaned 45-chain
  seed: 15 easy, 15 medium, and 15 hard.
- `ReservoirService` tracks used reservoir indices locally by difficulty.
- `GameViewModel.startGame` now uses `ReservoirService` first, then falls back to
  Supabase edge functions and live generation.
- `reservoir.json` is included in the Xcode resources phase.
- No `generate-chains.js` script exists in this repository.
- The README says chain generation is through a Supabase Edge Function powered
  by DeepSeek.
- The handover says a Node.js script used the Anthropic API to populate
  Supabase. This content pipeline needs verification outside this repo.

Implementation notes:

- Confirm the actual source of truth for the chain generation script.
- Add metadata that daily challenge selection can use, such as date, difficulty,
  or daily eligibility, only after confirming the current Supabase schema.
- Avoid exposing future daily answers in a way that is easy to scrape from the
  client.

## Likely Technical Touchpoints

| Need | Current / Expected Path |
|---|---|
| Game flow | `WordLink/ViewModels/GameViewModel.swift` |
| Local reservoir | `WordLink/reservoir.json`, `WordLink/Services/ReservoirService.swift` |
| Difficulty model | `WordLink/Models/Models.swift` |
| Local completion history | `WordLink/Services/StorageService.swift` |
| Backend game start | `WordLink/Services/SupabaseGameService.swift` |
| Chain progress RPC wrapper | `WordLink/Services/PhraseService.swift` |
| Results/share flow | `WordLink/Views/ResultsView.swift` |

## Acceptance Criteria For First Daily Challenge

- Player can start today's challenge from the home flow.
- Player cannot accidentally replay the same daily as a new daily result.
- Completion state survives app relaunch.
- Result sharing does not reveal answers.
- Daily logic does not break normal difficulty-based play.
- Any backend schema or RPC change is documented before implementation.

## Deferred

- Battle mode.
- Flashcards.
- Pronunciation drills beyond the current speech behavior.
- Streaks, calendars, and push notifications until the daily core loop is proven.

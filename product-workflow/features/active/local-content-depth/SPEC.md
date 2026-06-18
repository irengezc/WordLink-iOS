# Local Content Depth

> Living spec for expanding WordLink's bundled puzzle reservoir while preserving
> the ESL-quality bar and local-first gameplay.

## Status

- Stage: exploring
- Owner: Cheng Zheng
- Current code workspace or branch: main repository
- Last updated: 2026-06-18

## Problem

### User Problem

WordLink starts quickly because normal games use the bundled local reservoir
first, but the current bundled content is only a cleaned 45-chain seed: 15 easy,
15 medium, and 15 hard. That is enough to prove the mechanism, but too small
for a satisfying v1 starter library.

For English learners, low-quality chains are worse than no chain. Awkward
examples, suffix fragments, and invented compounds can teach unnatural English
and weaken the product's fluency promise.

### Desired Outcome

Players can play a meaningful number of fast, offline-capable games across all
three difficulties, and every accepted pair feels natural, teachable, and
aligned with its difficulty tier.

### Scope

**Included**

- Expand `WordLink/reservoir.json` from the current 45-chain clean seed.
- Preserve 9-word chains with 8 explanations.
- Keep difficulty meanings aligned with `Difficulty.easy`, `.medium`, and
  `.hard`.
- Strengthen validator coverage for newly discovered bad patterns.
- Keep docs synchronized with the accepted content target and validation
  results.

**Not included**

- Live in-app chain generation as the primary path.
- A new backend schema.
- Formal login or account creation.
- Daily challenge scheduling, unless separately scoped after content expansion.
- Monetization.

## Exploration

| Option | Benefits | Risks | Decision |
|---|---|---|---|
| Expand to 50 chains per difficulty | Creates a useful v1 starter pack while staying reviewable. | Requires careful human QA and duplicate checking. | open |
| Expand only to 30 chains per difficulty | Faster and lower review burden. | May still feel shallow for early users. | open |
| Rely on Supabase after local seed | Reduces app bundle content work. | Backend/auth remains unverified and first play should stay local-first. | rejected for primary v1 path |

Detailed exploration: `assets/exploration/`

## Selected Direction

Not yet selected. Current lean is a staged expansion: first reach a modest
reviewable target such as 30 per difficulty, validate, then continue toward 50
per difficulty if quality remains high.

### Product Prototype

- Status: not started
- Code workspace or branch: main repository
- Device or preview notes: not applicable unless UI changes are introduced
- Real components and tokens reused: existing gameplay and flashcard views
- Intentional prototype limitations: none
- Feedback:
- Approval:

## Requirements

| ID | Requirement | Status |
|---|---|---|
| R1 | The app still starts normal games from `ReservoirService` before network calls. | confirmed |
| R2 | Each accepted chain has 9 uppercase words and 8 explanations. | confirmed |
| R3 | New chains pass `node tools/validate-reservoir.js WordLink/reservoir.json`. | confirmed |
| R4 | Known-bad pairs and suffix fragments fail validation, not just manual review. | confirmed |
| R5 | New pairs avoid awkward ESL examples, invented compounds, and misleading closed-compound spacing. | confirmed |
| R6 | Updated docs record the final counts and validation result. | confirmed |

### Required States

- Empty: If the reservoir is missing or exhausted, existing fallback behavior
  can continue, but v1 should not rely on it for normal play.
- Loading: Existing `GameViewModel.startGame` loading state remains unchanged.
- Success: Starting a game for any difficulty returns a clean local chain when
  available.
- Error: Validator errors must block content acceptance.
- Edge cases: Duplicate adjacent pairs, repeated chains, malformed explanation
  labels, fragment-like words, and known weak pairs.

## Implementation Notes

- Relevant code paths:
  - `WordLink/reservoir.json`
  - `WordLink/Services/ReservoirService.swift`
  - `WordLink/ViewModels/GameViewModel.swift`
  - `WordLink/Models/Models.swift`
  - `tools/validate-reservoir.js`
  - `docs/reservoir-audit.md`
  - `docs/retention-roadmap.md`
  - `docs/progress.md`
- Existing patterns to reuse:
  - Keep reservoir bucket keys as `easy`, `medium`, and `hard`.
  - Keep `ReservoirService.next(for:)` random unused selection behavior.
  - Keep local usage tracking in UserDefaults unless a separate feature changes
    progress semantics.
- Expected files to change:
  - `WordLink/reservoir.json`
  - `tools/validate-reservoir.js` if quality rules expand
  - Relevant docs under `docs/`
- Technical constraints:
  - Product chains are 9 words, while `GameConstants.maxWords` currently tracks
    8 guess/progress steps.
  - Supabase remains optional for first play.
  - The current repo does not contain the historical chain-generation script.
- Stop and ask if:
  - A proposed approach requires backend schema changes.
  - A proposed approach makes live generation the primary gameplay path.
  - Content quality requires accepting unnatural or disputed English pairs.

## Progress

### Completed

- Added local-first game loading before network fallback.
- Cleaned the reservoir to a 45-chain seed with 15 chains per difficulty.
- Added `tools/validate-reservoir.js`.
- Recorded forbidden examples and quality rules in `docs/reservoir-audit.md`.

### Validation

- Current docs report:
  - Counts: easy=15, medium=15, hard=15, total=45
  - Errors: 0
  - Warnings: 0
  - Quality flags: 0

Detailed test evidence: `assets/testing/`

Detailed review findings: `assets/review/`

### Known Issues And Deferred Work

- Content is clean but shallow.
- The actual external generation pipeline is unresolved.
- Chain IDs should be considered before the reservoir becomes large.
- Daily challenge selection metadata is deferred.

## Decisions

| Decision | Why | Date |
|---|---|---|
| Keep bundled reservoir first. | Fast local play protects the core puzzle loop from backend availability. | 2026-06-17 |
| Treat awkward ESL pairs as blocking quality failures. | The product teaches English; unnatural examples damage trust. | 2026-06-17 |
| Defer monetization until v2. | Keeps v1 upload simpler and avoids SDK/privacy complexity. | 2026-06-17 |

## Next Action

- Choose the first expansion target, generate or draft candidate chains in small
  batches, run the validator, and human-review every accepted pair before
  updating `WordLink/reservoir.json`.

# Local Content Depth

> Living spec for expanding WordLink's bundled puzzle reservoir while preserving
> the ESL-quality bar and local-first gameplay.

## Status

- Stage: exploring
- Owner: Cheng Zheng
- Current code workspace or branch: main repository
- Last updated: 2026-07-01

## Problem

### User Problem

WordLink starts quickly because normal games use the bundled local reservoir
first. The current bundled content is a CEFR-re-tiered 86-chain seed: 28 easy,
29 medium, and 29 hard. That is enough to prove the mechanism, but still too
small for a satisfying v1 starter library.

For English learners, low-quality chains are worse than no chain. Awkward
examples, suffix fragments, and invented compounds can teach unnatural English
and weaken the product's fluency promise.

### Desired Outcome

Players can play a meaningful number of fast, offline-capable games across all
three difficulties, and every accepted pair feels natural, teachable, and
aligned with its difficulty tier.

### Scope

**Included**

- Expand `WordLink/reservoir.json` from the current 86-chain reviewed seed.
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

Selected direction: use the three-layer reservoir model documented in
`docs/long-term-reservoir-strategy.md`.

The next technical milestone is to make the content format scalable before
expanding heavily: add stable chain IDs, track seen IDs instead of array
indices, and split or manifest local packs. After that, expand in reviewed
batches toward 150 local chains per difficulty, then grow the canonical reviewed
library toward 300+ chains per difficulty.

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
| R7 | Gameplay accepts supported US/UK spelling variants while displaying canonical US target length. | confirmed |
| R8 | Reservoir evaluation distinguishes `split_word`, `hyphenated_compound`, and `two_word_phrase` links. | confirmed |

### Required States

- Empty: If the reservoir is missing or exhausted, existing fallback behavior
  can continue, but v1 should not rely on it for normal play.
- Loading: Existing `GameViewModel.startGame` loading state remains unchanged.
- Success: Starting a game for any difficulty returns a clean local chain when
  available.
- Error: Validator errors must block content acceptance.
- Edge cases: Duplicate adjacent pairs, repeated chains, malformed explanation
  labels, fragment-like words, missing link-type metadata, and known weak pairs.

## Implementation Notes

- Relevant code paths:
  - `WordLink/reservoir.json`
  - `data/reservoir-pair-bank.json`
  - `data/reservoir-candidate-queue.json`
  - `WordLink/Services/SpellingVariants.swift`
  - `WordLink/Services/ReservoirService.swift`
  - `WordLink/ViewModels/GameViewModel.swift`
  - `WordLink/Models/Models.swift`
  - `tools/validate-reservoir.js`
  - `tools/extract-pair-bank.js`
  - `tools/generate-chain-candidates.js`
  - `tools/export-approved-candidates.js`
  - `docs/reservoir-audit.md`
  - `docs/cost-efficient-reservoir-pipeline.md`
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
- Rebuilt the easy tier for learner-friendly links, replaced medium C1
  blockers, and added variant-aware guess acceptance.
- Added per-link `linkTypes` metadata and expanded the reservoir to 69 chains:
  23 easy, 23 medium, and 23 hard.
- Exported a July 1 reviewed checkpoint to 84 chains, then re-tiered three
  candidates upward to satisfy the CEFR gate: 26 easy, 29 medium, and 29 hard.
- Replaced the remaining duplicate-pair warnings, resolved all quality flags
  through reviewed classifications, and exported one more easy chain for an
- Reached a 702-row pair bank, generated one additional easy chain from it, and
  exported an 86-chain zero-warning checkpoint.
- Confirmed the current 702-row pair bank cannot produce more candidates without
  new unused connector pairs.

### Validation

- Current docs report:
  - Counts: easy=28, medium=29, hard=29, total=86
  - Errors: 0
  - Warnings: 0
  - Quality flags: 0
  - CEFR gate: easy B2+ blocks, easy B1 flags, medium C1+ blocks, hard uncapped

Detailed test evidence: `assets/testing/`

Detailed review findings: `assets/review/`

### Known Issues And Deferred Work

- Content is CEFR-gated but shallow.
- Two repeated-pair validator warnings remain for human review:
  `WINDOW SHOPPING` and `PARTY LINE`.
- The actual external generation pipeline is unresolved.
- The current pair bank has crossed 700 rows but cannot produce more candidates
  until new unused connector pairs are added.
- Chain IDs should be considered before the reservoir becomes large.
- Daily challenge selection metadata is deferred.

## Decisions

| Decision | Why | Date |
|---|---|---|
| Keep bundled reservoir first. | Fast local play protects the core puzzle loop from backend availability. | 2026-06-17 |
| Treat awkward ESL pairs as blocking quality failures. | The product teaches English; unnatural examples damage trust. | 2026-06-17 |
| Defer monetization until v2. | Keeps v1 upload simpler and avoids SDK/privacy complexity. | 2026-06-17 |

## Next Action

- Implement the scalable reservoir shape first: stable chain IDs, ID-based
  progress tracking, and sharded or manifested local packs. Per-link type
  metadata is already present. For content expansion, build the cost-efficient
  pair-bank pipeline in `docs/cost-efficient-reservoir-pipeline.md`, then add
  unused candidate pairs and use it to expand toward 150 reviewed chains per
  difficulty.

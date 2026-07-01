# Progress

Keep this file as the short working ledger for project-level cleanup and
pre-launch preparation.

## Current Sequence

1. Config and credential cleanup.
2. Local-first game loading and content depth.
3. Supabase verification or explicit backend disablement.
4. Daily challenge foundation.
5. GitHub Pages landing/privacy/support page.
6. ASO and App Store submission assets.
7. Pre-upload validation.
8. Monetization in version 2.

## Completed

| Item | Outcome | Date |
|---|---|---|
| Initial context doc set | Added the project context docs that now live under `product-workflow/`. | 2026-06-17 |
| Supabase client config cleanup | Added `WordLink/AppConfig.swift` and updated app services/tests to read Supabase client config from one place. | 2026-06-17 |
| App Store upload pre-flight | Updated the app bundle ID to `com.wordlinkgame.app`, verified Release settings, archived successfully, and uploaded the build to App Store Connect for processing. | 2026-06-17 |
| App Store submission | App Store submission work is complete. | 2026-07-01 |

## In Progress

| Item | Current State | Next Action |
|---|---|---|
| Game loading and content backend path | Normal game starts now use the bundled reservoir before network. Supabase may still be expired and the local reservoir is still small. | Expand the bundled reservoir and decide whether to remove or de-emphasize live generation fallback. |
| Supabase project | Project host is reachable and `start-game` returned a valid response. Anonymous sign-in currently returns `422` because anonymous sign-ins are disabled. | Enable anonymous sign-ins if `AuthService`/progress sync will ship, or keep those paths disabled for v1. |
| Reservoir QA | Added `tools/validate-reservoir.js`, replaced the old reservoir with a cleaned seed, added per-link type metadata, expanded the reservoir to 86 chains, and currently validates with zero errors, zero warnings, and zero quality flags. | Move to stable chain IDs, then continue expanding content in reviewed batches toward 150 chains per difficulty. |

## Decisions To Revisit

| Decision | Current Lean | Why |
|---|---|---|
| Fast game loading | Local bundled reservoir is now first. | Starts games instantly and avoids blocking gameplay on Supabase availability. |
| Large content reservoir | Use a three-layer reservoir: bundled starter pack, on-device reviewed cache, and canonical reviewed content pipeline. Target at least 150 local chains per difficulty. | Supports fast starts and at least one month of play without repeating chains for users who favor one difficulty. |
| Reservoir quality | Clean before expanding. | Current reservoir has many artificial splits and closed-compound spacing issues that are risky for ESL users. |
| Awkward ESL examples | Strictly forbidden. | Examples like `SHOP PING`, `MOVE MENT`, `SHIFT ER`, and `PLAN NET` teach unnatural English. |
| User reservoir review | Added user-flagged weak pairs to the forbidden list and replaced them in the reservoir. | Keep using human review alongside the validator. |
| Supabase role | Use as refill/sync/backend infrastructure, not startup dependency. | Backend availability should not block the core puzzle loop. |
| Version 1 monetization | Ship without ads or remove-ads IAP. | Keeps first App Store upload simpler; add monetization in version 2. |
| Long-term reservoir | Documented in `docs/long-term-reservoir-strategy.md`. | Stable IDs and sharded local packs should come before large-scale expansion. |
| Cost-efficient expansion | Use a reviewed pair bank plus candidate generator instead of hand-authoring full chains. | This should make the remaining 381-chain expansion much faster while preserving ESL quality. |
| Pair-bank tooling | Added extraction, candidate-generation, and approved-candidate export scripts. Synced 702 reviewed pair-bank rows from the current reservoir after the 86-chain checkpoint; the generator added zero candidates from this bank. | Add/import unused connector pairs before rerunning the generator. |
| AI reservoir workflow | Added `docs/ai-reservoir-workflow.md` with prompts and autonomy rules for AI-assisted pair generation, review, candidate generation, export, validation, and progress updates. | Use this file as the handoff prompt for future AI expansion sessions. |

## Validation Notes

- `swiftc -parse` passed for touched app Swift files after config cleanup.
- `xcodebuild` could not run because the active developer directory points to
  Command Line Tools, not full Xcode.
- `node tools/validate-reservoir.js WordLink/reservoir.json` currently reports
  86 total chains, zero errors, zero warnings, zero quality flags, and enforced
  link types: `split_word`, `hyphenated_compound`, and `two_word_phrase`.

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
| Initial context doc set | Added `CLAUDE.md` and docs for monetization, retention, ASO, and web funnel. | 2026-06-17 |
| Supabase client config cleanup | Added `WordLink/AppConfig.swift` and updated app services/tests to read Supabase client config from one place. | 2026-06-17 |

## In Progress

| Item | Current State | Next Action |
|---|---|---|
| Game loading and content backend path | Normal game starts now use the bundled reservoir before network. Supabase may still be expired and the local reservoir is still small. | Expand the bundled reservoir and decide whether to remove or de-emphasize live generation fallback. |
| App Store pre-upload readiness | Added a must-do checklist for backend, Apple account, monetization, quality, and validation. | User needs to confirm Apple Developer enrollment and Supabase project status when available. |
| Supabase project | Project host is reachable and `start-game` returned a valid response. Anonymous sign-in currently returns `422` because anonymous sign-ins are disabled. | Enable anonymous sign-ins if `AuthService`/progress sync will ship, or keep those paths disabled for v1. |
| Reservoir QA | Added `tools/validate-reservoir.js`, replaced the old reservoir with a cleaned 45-chain seed, and validated with zero errors/warnings/quality flags. | Continue expanding content from this clean baseline. |

## Decisions To Revisit

| Decision | Current Lean | Why |
|---|---|---|
| Fast game loading | Local bundled reservoir is now first. | Starts games instantly and avoids blocking gameplay on Supabase availability. |
| Large content reservoir | Expand bundled starter pack beyond the current 45 cleaned chains. | Current local reservoir is fast and clean, but still should grow before v1 upload. |
| Reservoir quality | Clean before expanding. | Current reservoir has many artificial splits and closed-compound spacing issues that are risky for ESL users. |
| Awkward ESL examples | Strictly forbidden. | Examples like `SHOP PING`, `MOVE MENT`, `SHIFT ER`, and `PLAN NET` teach unnatural English. |
| User reservoir review | Added user-flagged weak pairs to the forbidden list and replaced them in the reservoir. | Keep using human review alongside the validator. |
| Supabase role | Use as refill/sync/backend infrastructure, not startup dependency. | Backend availability should not block the core puzzle loop. |
| Version 1 monetization | Ship without ads or remove-ads IAP. | Keeps first App Store upload simpler; add monetization in version 2. |

## Validation Notes

- `swiftc -parse` passed for touched app Swift files after config cleanup.
- `xcodebuild` could not run because the active developer directory points to
  Command Line Tools, not full Xcode.

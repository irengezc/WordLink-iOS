# WordLink Project Context

This is the durable project context for future agent sessions. Treat it as the
first file to read before product or engineering work.

## Product

WordLink is a native iOS word puzzle game. Players solve 9-word chains by
guessing the hidden connecting word between adjacent compound phrases. Each
chain has 8 connections to solve.

The product is aimed at English learners as well as casual word-game players.
The ESL / fluency angle is intentional: explanations, pronunciation, future
flashcards, and card-flip learning interactions should reinforce that position.

Difficulty has three tiers:

| Difficulty | Product Meaning | Code |
|---|---|---|
| Easy | Common phrases and simple connections | `Difficulty.easy` |
| Medium | Idioms and everyday collocations | `Difficulty.medium` |
| Hard | Complex idioms and abstract links | `Difficulty.hard` |

The current game flow is native SwiftUI: home, difficulty selection, loading,
gameplay, results, and history.

## Current Architecture

| Area | Current State |
|---|---|
| Platform | Native iOS app, Swift / SwiftUI, Xcode project |
| Minimum iOS | Verified in `WordLink.xcodeproj/project.pbxproj` as `IPHONEOS_DEPLOYMENT_TARGET = 16.0` |
| Bundle ID | `com.wordlink.app` |
| Apple Team ID | `XVW2C26TQX` |
| Version | `MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 1` |
| Backend | Supabase |
| Auth | Supabase anonymous auth with persisted UserDefaults tokens |
| Local persistence | Game history in UserDefaults via `StorageService` |
| Support URL | `https://irengezc.github.io/WordLink/` |
| GitHub account | `irengezc` |
| Official correspondence name | Cheng Zheng |

Important code paths:

| Need | Path |
|---|---|
| App entry | `WordLink/WordLinkApp.swift` |
| App/backend config | `WordLink/AppConfig.swift` |
| Main state machine | `WordLink/ViewModels/GameViewModel.swift` |
| Models and constants | `WordLink/Models/Models.swift` |
| Supabase anonymous auth | `WordLink/Services/AuthService.swift` |
| Supabase game edge functions | `WordLink/Services/SupabaseGameService.swift` |
| Chain RPC / progress service | `WordLink/Services/PhraseService.swift` |
| Fallback edge function generation | `WordLink/Services/GeminiService.swift` |
| Local bundled chain reservoir | `WordLink/reservoir.json`, `WordLink/ReservoirService.swift` |
| Local history | `WordLink/Services/StorageService.swift` |
| Integration tests | `WordLinkTests/SupabaseIntegrationTests.swift` |

## Content And Backend Direction

The committed product constraint is pre-generated content, not live in-app chain
generation. Chains should be generated ahead of time, duplicate-checked, inserted
into Supabase, and then served to the app. Do not move toward real-time
generation as the primary gameplay path; it adds latency, repeated API cost, and
duplicate-delivery risk.

Known backend concepts from the handover:

- `chains` table: approximately 150 pre-generated chains.
- `user_progress` table: tracks completed chains by `(user_id, chain_id)`.
- Anonymous auth is deliberate for now. Formal login is deferred.
- A `get_chain` RPC is expected to return an unseen chain for a user and record
  progress.

Live-code note: normal games now try the local bundled reservoir first via
`ReservoirService.next(for:)`, so starts can be instant and do not depend on
Supabase availability. If the local reservoir is empty or exhausted, the app
falls back to Supabase edge functions via
`SupabaseGameService.startGame(difficulty:)`, then to
`GeminiService.generateWordChain(difficulty:)`. `PhraseService` contains a
`get_chain` RPC wrapper but is not currently used by `GameViewModel`.

Current `reservoir.json` contains a cleaned 45-chain seed set. It validates with
zero reservoir QA errors, warnings, or quality flags, but is still too small for
a deep starter library. The next content investment should expand the bundled
reservoir substantially.

Content quality rule: strictly forbid awkward ESL examples, suffix fragments,
and synthetic connector pairs such as `SHOP PING`, `MOVE MENT`, `SHIFT ER`, and
`PLAN NET`. Also forbid weak invented compounds such as `AID KIT`,
`BLADE RUNNER`, `CAP SIZE`, `THROAT CLEARING`, and `DRIVER LICENSE`. The
reservoir validator should fail known-bad pairs before content is accepted.

## Committed Near-Term Product Sequence

Version 1 preparation order:

1. Local-first gameplay and content depth.
2. Supabase verification or explicit backend disablement before upload.
3. Daily challenge foundation if scope allows before v1.
4. GitHub Pages support/privacy/landing page.
5. ASO and App Store submission assets.
6. Monetization in version 2.

The web funnel can proceed in parallel because it is independent, but only Tier
1 is committed now. See `docs/web-funnel.md`.

## Key Product Decisions

- Version 1 ships without ads and without remove-ads IAP. Monetization is
  deferred to version 2.
- When monetization is added later, keep the model simple: free app plus
  interstitial ads between levels, with a one-time remove-ads purchase.
- Do not use a subscription until the product has stronger user trust and repeat
  value.
- Pull daily challenge ahead of battle mode and flashcards because it is the
  highest-leverage habit loop.
- Treat App Store search as the primary acquisition channel for a solo founder
  with no ad budget.
- Use web as a marketing funnel to the App Store, not as a second full product.
- Do not architect the iOS app for web reuse now.

## Current Known Issues And Verification Notes

Verified against the repository on 2026-06-17:

- The deployment target is currently `16.0`; the previous handover warning about
  an iOS `26.0` target appears fixed.
- Supabase client config is centralized in `WordLink/AppConfig.swift`.
- `reservoir.json` is included as an app resource and normal game starts use it
  before network calls.
- Supabase host is reachable and `start-game` returned a valid response on
  2026-06-17. Anonymous sign-in currently returns `422` because anonymous
  sign-ins are disabled.
- No AdMob, StoreKit remove-ads, or ATT usage-description integration is visible
  in the current repository.
- The README has been updated to describe the local-first reservoir path and
  centralized Supabase config.
- The handover says chain generation used an Anthropic-powered Node script. The
  current repo does not contain `generate-chains.js`; the README says the edge
  function is powered by DeepSeek. Treat this as unresolved until verified
  against the backend/content pipeline outside this repo.

## Documentation Map

- `docs/monetization.md`: ads, remove-ads IAP, ATT, and credential prerequisites.
- `docs/retention-roadmap.md`: daily challenge and content expansion.
- `docs/aso-checklist.md`: App Store discoverability checklist.
- `docs/web-funnel.md`: landing-page funnel and deferred playable demo.
- `docs/progress.md`: current cleanup/pre-launch sequence and status.
- `docs/pre-upload-checklist.md`: must-do checks before App Store upload.
- `docs/app-store-submission.md`: App Store listing copy and screenshot plan.
- `docs/privacy-policy-draft.md`: draft privacy policy for the support site.
- `docs/supabase-verification.md`: backend verification checklist.
- `docs/reservoir-audit.md`: content QA findings for the bundled reservoir.

## Working Rules For Agents

- Verify technical facts against the live code before changing or repeating them.
- Keep user-facing gameplay native iOS first.
- Do not introduce backend schema changes, new monetization SDKs, or new auth
  flows without making the migration plan explicit.
- Before monetization work, keep new SDK IDs and public client config centralized
  rather than duplicating literals across services. Never put server-side secrets
  in the app.
- For small fixes, update code and README if needed. For standard features,
  update the relevant doc in `docs/` as part of the work.

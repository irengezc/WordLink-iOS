# Technical Context

This is a concise reference for implementation agents, not a full architecture
document. Verify facts against live code before making changes.

## Repository

| Repository | Role | Default branch |
|---|---|---|
| `/Users/zhengcheng/Documents/🌰 Nutstore/🍊Personal project_coding/WordLink-iOS` | Native iOS app and product docs. | current local branch |

## Stack And Commands

| Need | Choice or command |
|---|---|
| Platform | Native iOS app |
| Language / UI | Swift, SwiftUI |
| Project | `WordLink.xcodeproj` |
| Minimum iOS | `IPHONEOS_DEPLOYMENT_TARGET = 16.0` |
| Bundle ID | `com.wordlinkgame.app` |
| Backend | Supabase, optional for v1 first play |
| Local persistence | UserDefaults via `StorageService` and reservoir usage tracking |
| Reservoir validation | `node tools/validate-reservoir.js WordLink/reservoir.json` |
| Xcode build | Open `WordLink.xcodeproj` in full Xcode and build/run |
| Integration tests | `WordLinkTests/SupabaseIntegrationTests.swift` when Supabase remains enabled |

## Important Paths

| Need | Path |
|---|---|
| App entry | `WordLink/WordLinkApp.swift` |
| App/backend config | `WordLink/AppConfig.swift` |
| Main state machine | `WordLink/ViewModels/GameViewModel.swift` |
| Models and constants | `WordLink/Models/Models.swift` |
| Local bundled reservoir | `WordLink/reservoir.json` |
| Local reservoir service | `WordLink/Services/ReservoirService.swift` |
| Reservoir validator | `tools/validate-reservoir.js` |
| Supabase anonymous auth | `WordLink/Services/AuthService.swift` |
| Supabase edge functions | `WordLink/Services/SupabaseGameService.swift` |
| Chain RPC wrapper | `WordLink/Services/PhraseService.swift` |
| AI fallback generation | `WordLink/Services/GeminiService.swift` |
| Local history | `WordLink/Services/StorageService.swift` |
| Home screen | `WordLink/Views/HomeView.swift` |
| Difficulty screen | `WordLink/Views/DifficultySelectView.swift` |
| Gameplay screen | `WordLink/Views/GameView.swift` |
| Word tiles | `WordLink/Views/Components/WordDisplayView.swift` |
| Phrase flashcard | `WordLink/Views/Components/PhraseFlashcardView.swift` |
| Results | `WordLink/Views/ResultsView.swift` |
| History | `WordLink/Views/HistoryView.swift` |

## Current Gameplay Loading Path

`GameViewModel.startGame(difficulty:)` currently:

1. Tries `ReservoirService.shared.next(for:)`.
2. Falls back to `SupabaseGameService.startGame(difficulty:)`.
3. Falls back to `GeminiService.generateWordChain(difficulty:)`.

`PhraseService` contains a `get_chain` RPC wrapper, but it is not currently used
by `GameViewModel`.

## Backend Notes

- Supabase config is centralized in `WordLink/AppConfig.swift`.
- `start-game` returned a valid response on 2026-06-17.
- Anonymous sign-in returned `422` because anonymous sign-ins were disabled.
- Before relying on `AuthService` or progress sync, enable and verify anonymous
  auth or disable those shipping paths for v1.
- See `docs/supabase-verification.md`.

## Content Notes

- `WordLink/reservoir.json` currently has a cleaned 45-chain seed: 15 easy, 15
  medium, and 15 hard.
- The reservoir validates with zero errors, warnings, and quality flags as of
  the current docs.
- Keep content pre-generated and duplicate-checked.
- Strictly reject awkward ESL examples, suffix fragments, and known weak pairs.
- See `docs/reservoir-audit.md`.

## Important Nuance

Product language says each puzzle is a 9-word chain with 8 connections. In code,
`GameConstants.maxWords` is currently set to `8` and is used as the number of
guess/progress steps, not the visible chain length.

## Boundaries

- Do not make live generation the primary gameplay path.
- Do not make Supabase required for first play unless a new product decision is
  recorded.
- Do not introduce backend schema changes without a migration plan.
- Do not introduce monetization SDKs, StoreKit remove-ads, or ATT prompts for
  v1 unless the product decision changes.
- Do not duplicate public client config across services.
- Never put server-side secrets in the app.

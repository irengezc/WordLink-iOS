# WordLink iOS

Native SwiftUI word-chain puzzle game for iOS 16+.

## Requirements

- Xcode 15+
- iOS 16.0+

## Setup

1. Open `WordLink.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘R)

## Architecture

MVVM with `ObservableObject` + `@Published`.

- `Views/` — SwiftUI screens and components
- `ViewModels/` — Game logic and state
- `Models/` — Data types
- `Services/` — API and persistence layer

## Content Loading

Version 1 is local-first. Normal games start from the bundled
`WordLink/reservoir.json` through `ReservoirService`, so the puzzle loop remains
fast and playable without network access.

Supabase config is centralized in `WordLink/AppConfig.swift`. Supabase may be
used as optional backend infrastructure once verified, but it should not block
first play.

## Version 1 Release Scope

- No ads
- No in-app purchases
- No subscriptions
- No account required

See `CLAUDE.md` and `docs/pre-upload-checklist.md` for release-prep context.

## Reservoir QA

Run the local reservoir validator before changing bundled puzzle content:

```bash
node tools/validate-reservoir.js WordLink/reservoir.json
```

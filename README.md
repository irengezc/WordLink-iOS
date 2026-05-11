# WordLink iOS

Native SwiftUI word chain game for iOS 16+.

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

## Word Chain Generation

Chains are generated via a Supabase Edge Function powered by the DeepSeek API.
The function endpoint is configured in `Services/WordChainService.swift`.

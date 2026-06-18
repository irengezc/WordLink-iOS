# Design System

Keep this as a concise reference map and set of usage rules. The authoritative
source is the SwiftUI code.

## Sources Of Truth

| Area | Source | Reference |
|---|---|---|
| Navigation and app flow | SwiftUI switch in app shell | `WordLink/ContentView.swift`, `WordLink/ViewModels/GameViewModel.swift` |
| Home and difficulty visual language | Existing SwiftUI screens | `WordLink/Views/HomeView.swift`, `WordLink/Views/DifficultySelectView.swift` |
| Gameplay layout | Existing SwiftUI screen and components | `WordLink/Views/GameView.swift`, `WordLink/Views/Components/WordDisplayView.swift` |
| Learning/review cards | Existing flashcard component | `WordLink/Views/Components/PhraseFlashcardView.swift` |
| Results and sharing | Existing SwiftUI screen | `WordLink/Views/ResultsView.swift` |
| App icon / launch assets | Xcode asset catalog | `WordLink/Assets.xcassets/` |

## Current Visual Language

- Home and difficulty selection use a deep purple gradient with white controls.
- Gameplay uses iOS system backgrounds, compact top bars, progress strips,
  letter tiles, and card-like phrase review.
- Results use a green gradient and a white-on-color score summary.
- Interactions lean on spring animations, haptics, audio feedback, and speech.
- Difficulty cards use distinct semantic color families: green for easy, amber
  for medium, red for hard.

## Usage Rules

- Preserve the fast native iOS game feel; avoid web-like landing-page UI inside
  the app.
- Use existing SwiftUI system symbols for action buttons where possible.
- Keep gameplay screens dense enough for repeated play, with clear progress and
  minimal instructional copy.
- Keep phrase explanations learner-friendly and visible through flashcard or
  review interactions.
- Keep home/selection screens expressive, but keep gameplay functional and easy
  to scan.
- Avoid adding ornamental screens that do not show real game state or learning
  value.

## Best Existing References

| Pattern | Reference | Why |
|---|---|---|
| First-run game entry | `WordLink/Views/HomeView.swift` | Shows the current brand treatment and primary actions. |
| Difficulty choice | `WordLink/Views/DifficultySelectView.swift` | Defines difficulty colors, copy, and card behavior. |
| Active puzzle | `WordLink/Views/GameView.swift` | Defines the compact gameplay structure and scrolling behavior. |
| Letter input | `WordLink/Views/Components/WordDisplayView.swift` | Defines tile sizing, revealed-letter state, feedback, and shake animation. |
| Learning card | `WordLink/Views/Components/PhraseFlashcardView.swift` | Defines the card-flip learning interaction. |

## Recent Shared Decisions

| Decision | Why | Source feature | Date |
|---|---|---|---|
| Keep v1 local-first and native iOS first. | Prevent backend latency or availability from blocking first play. | project context | 2026-06-17 |
| Preserve ESL quality as a product requirement, not just a content preference. | Bad phrase pairs can teach unnatural English. | reservoir audit | 2026-06-17 |


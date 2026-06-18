# Approved Preferences

These preferences apply across WordLink features. Add only repeated, approved
patterns that should influence future work.

## Collaboration

- Verify technical facts against live code before changing or repeating them.
- Keep explanations concise and connected to the deliverable.
- For meaningful product or design choices, present multiple options with
  tradeoffs before implementation.
- For small fixes, update code and README if needed. For standard features,
  update the relevant doc under `docs/`.

## Product And Design Decisions

- Keep user-facing gameplay native iOS first.
- Preserve the ESL / vocabulary-learning angle through explanations,
  pronunciation, flashcard-style review, and clear phrase quality.
- Treat App Store search as the primary early acquisition channel.
- Use web as an App Store funnel, not as a second full product.
- Pull daily challenge ahead of battle mode and flashcards when v1 scope allows.
- Ship version 1 without ads, in-app purchases, subscriptions, or an account
  requirement.

## Implementation

- Prefer focused, reviewable changes.
- Do not silently expand scope.
- Keep Supabase optional for first play unless the product decision changes.
- Keep public client config centralized in `WordLink/AppConfig.swift`.
- Never place server-side secrets in the app.


# WordLink Agent Start File

This is the only file you need to give an AI agent when starting a new
WordLink session.

Canonical path:

`/Users/zhengcheng/Documents/🌰 Nutstore/🍊Personal project_coding/WordLink-iOS/product-workflow/AGENTS.md`

The `product-workflow/` folder is the source of truth for product context,
feature specs, agent instructions, and durable project decisions. Do not use
root-level `AGENTS.md` or `CLAUDE.md` files; they are intentionally not part of
this workflow.

Read this file first, then read only the additional files it directs you to
based on the task.

## Product Snapshot

WordLink is a native iOS word puzzle game. Players solve 9-word chains by
guessing the hidden connecting word between adjacent compound phrases. Each
chain has 8 connections to solve.

The product is for English learners and casual word-game players. The ESL /
fluency angle is intentional: explanations, pronunciation, flashcard-style
review, and future learning interactions should reinforce that position.

Version 1 is local-first: normal gameplay should start from the bundled
reservoir before any network call. Supabase can remain optional backend support,
but it must not block first play.

Version 1 ships without ads, in-app purchases, subscriptions, or required login.

## Start Every Session

The user should provide a feature name and mode when the task is feature work.

- Feature name
- Mode: `exploration`, `product prototype`, `implementation`, or `review`

If any of these are missing and the task cannot be safely inferred, ask before
proceeding.

Then:

1. Use `ACTIVE.md` only to locate the named feature and confirm its next action.
2. Read the named feature's `SPEC.md`.
3. Follow the mode-specific reading order below.
4. Read only relevant codebase files and docs. Do not read unrelated feature
   folders unless the user asks.

For small code fixes that do not belong to a feature spec, read:

1. `foundation/technical-context.md`
2. `foundation/product.md` if the behavior affects product direction
3. `foundation/design-system.md` if the behavior affects UI
4. Relevant code files in the iOS repository

For new product decisions, update the relevant feature spec or foundation file
inside `product-workflow/`. Do not recreate context in the repo root.

## Mode: Exploration

Goal: understand the problem, compare directions, and select a direction.

Read in this order:

1. Named feature's `SPEC.md`
2. `foundation/product.md`
3. `foundation/design-system.md` for UI work
4. Relevant assets under the named feature
5. Relevant existing product components and pages
6. `preferences.md` when presenting meaningful choices
7. `foundation/technical-context.md` to evaluate feasibility

Rules:

- Ask questions until important requirements and constraints are understood.
- Present meaningful options with benefits, risks, and tradeoffs.
- Standalone HTML, sketches, and screenshots may be used for fast comparison.
- Store concept artifacts under the named feature's
  `assets/exploration/concepts/`.
- Do not modify production code unless the user switches to implementation.
- Record explored options, feedback, and the selected direction in `SPEC.md`.

## Mode: Product Prototype

Goal: confirm the selected direction inside the real product environment.

Read in this order:

1. Named feature's `SPEC.md`, especially Selected Direction and Requirements
2. `foundation/design-system.md`
3. `foundation/technical-context.md`
4. Relevant SwiftUI screens, models, services, and assets
5. Selected concept assets only

Rules:

- Rebuild only the selected direction using the real iOS app stack.
- Reuse existing SwiftUI patterns, colors, motion, and state shape.
- Mock data and limited happy-path behavior are acceptable.
- Do not implement production backend behavior unless explicitly requested.
- Record the branch, preview device, limitations, feedback, and approval in
  `SPEC.md`.

## Mode: Implementation

Goal: build the approved feature behavior.

Read in this order:

1. Named feature's `SPEC.md`, especially Selected Direction, Requirements,
   Implementation Notes, and Product Prototype
2. `foundation/technical-context.md`
3. `foundation/design-system.md` for UI work
4. Relevant codebase files and tests
5. Existing implementation docs under `docs/` only when they contain current
   technical checklists that must stay synchronized

Rules:

- Implement only the approved selected direction and named scope.
- Keep gameplay native iOS first.
- Keep version 1 local-first; do not make Supabase required for first play.
- Do not introduce backend schema changes, new monetization SDKs, or new auth
  flows without an explicit migration plan.
- Never put server-side secrets in the app.
- Validate the implementation against the requirements before finishing.

## Current Project Map

| Need | File |
|---|---|
| Active feature index | `ACTIVE.md` |
| Product foundation | `foundation/product.md` |
| Technical architecture and paths | `foundation/technical-context.md` |
| UI/design patterns | `foundation/design-system.md` |
| Durable collaboration/product preferences | `preferences.md` |
| Reusable feature spec template | `features/_TEMPLATE/SPEC.md` |
| Current content-depth spec | `features/active/local-content-depth/SPEC.md` |

## Codebase Map

| Need | Path |
|---|---|
| App entry | `../WordLink/WordLinkApp.swift` |
| App/backend config | `../WordLink/AppConfig.swift` |
| Main state machine | `../WordLink/ViewModels/GameViewModel.swift` |
| Models and constants | `../WordLink/Models/Models.swift` |
| Local bundled reservoir | `../WordLink/reservoir.json` |
| Local reservoir service | `../WordLink/Services/ReservoirService.swift` |
| Supabase auth | `../WordLink/Services/AuthService.swift` |
| Supabase edge functions | `../WordLink/Services/SupabaseGameService.swift` |
| Chain RPC wrapper | `../WordLink/Services/PhraseService.swift` |
| AI fallback generation | `../WordLink/Services/GeminiService.swift` |
| Local history | `../WordLink/Services/StorageService.swift` |
| Reservoir validator | `../tools/validate-reservoir.js` |
| Integration tests | `../WordLinkTests/SupabaseIntegrationTests.swift` |

## Non-Negotiable Rules

- Verify technical facts against live code before changing or repeating them.
- Keep user-facing gameplay native iOS first.
- Keep version 1 local-first unless a new product decision is recorded.
- Do not introduce backend schema changes, new monetization SDKs, or new auth
  flows without an explicit migration plan.
- Keep public client config centralized in `../WordLink/AppConfig.swift`.
- Never put server-side secrets in the app.
- Treat English phrase quality as a product requirement. Reject awkward ESL
  examples, suffix fragments, and synthetic connector pairs.
- For standard or major features, update the relevant `SPEC.md` as part of the
  work.

## Mode: Review

Goal: verify the work matches the selected direction and requirements.

Read in this order:

1. Named feature's complete `SPEC.md`
2. Implementation diff and changed files
3. Relevant tests and validation output
4. `foundation/design-system.md` for visual changes

Rules:

- Check requirements, required states, selected direction, scope, and known
  limitations.
- Separate pre-existing failures from failures caused by the change.
- Record findings and validation results in `SPEC.md`.

## Working Rules

- Keep exploration, selected direction, and implementation status clearly
  separated inside `SPEC.md`.
- Keep `SPEC.md` concise and current. It is a decision document, not a session
  transcript.
- Replace outdated status and next actions instead of appending every update.
- Summarize findings in `SPEC.md`; store detailed exploration, test output, and
  review reports under the named feature's `assets/`.
- Do not treat rejected options as implementation requirements.
- Stop before unexpected scope expansion, new dependencies, backend changes, or
  shared design-system changes.

## Before Finishing

Update the active feature's `SPEC.md`:

- Current status
- Progress
- Decisions and why they were made
- Validation results, when relevant
- Product-prototype branch, device, or preview notes, when relevant
- Known issues or deferred work
- Next action

Then update only that feature's row in `ACTIVE.md`.

Suggest possible additions to `preferences.md`, but do not add them without
approval.

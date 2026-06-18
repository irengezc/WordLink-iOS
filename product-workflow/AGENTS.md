# Agent Instructions

This is the canonical WordLink product-spec workspace. Read and update the
original files here directly. Do not create a duplicate product spec or context
document inside a temporary workspace.

Before changing app code, also read the repository root `AGENTS.md` because it
contains durable project rules, shipping constraints, and code-path references.

## Start Every Session

The user should provide:

- Feature name
- Mode: `exploration`, `product prototype`, `implementation`, or `review`
- Canonical spec workspace path

If any of these are missing and the task cannot be safely inferred, ask before
proceeding.

Then:

1. Use `ACTIVE.md` only to locate the named feature and confirm its next action.
2. Read the named feature's `SPEC.md`.
3. Follow the mode-specific reading order below.
4. Read only relevant codebase files and docs. Do not read unrelated feature
   folders unless the user asks.

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
5. Existing docs under `docs/` that should stay synchronized

Rules:

- Implement only the approved selected direction and named scope.
- Keep gameplay native iOS first.
- Keep version 1 local-first; do not make Supabase required for first play.
- Do not introduce backend schema changes, new monetization SDKs, or new auth
  flows without an explicit migration plan.
- Never put server-side secrets in the app.
- Validate the implementation against the requirements before finishing.

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


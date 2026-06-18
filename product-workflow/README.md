# WordLink Agent Product Workflow

A private product-design and product-building workspace for WordLink agents.
Use this folder to keep feature decisions, product context, and implementation
handoff notes close to the iOS repository without mixing them into app code.

## Core Rule

One standard or major feature gets one living `SPEC.md`.

Small local fixes can stay in code and the existing `docs/` files. Anything
that needs product direction, UI exploration, backend tradeoffs, or multi-step
implementation should get a feature folder under `features/active/`.

## Folder Structure

```text
product-workflow/
  AGENTS.md
  CLAUDE.md
  ACTIVE.md
  preferences.md

  foundation/
    product.md
    design-system.md
    technical-context.md

  features/
    _TEMPLATE/
      SPEC.md
      assets/
        exploration/
          concepts/
          references/
          product-prototype/
        testing/
        review/
    active/
      local-content-depth/
        SPEC.md
        assets/
    archive/
```

## Start A Feature

1. Copy `features/_TEMPLATE/`.
2. Rename the copy and place it in `features/active/`.
3. Fill the Problem, Scope, Requirements, and Next Action sections.
4. Add one row to `ACTIVE.md`.
5. Keep detailed sketches, screenshots, test output, and review notes in that
   feature's `assets/` folder.

## Current WordLink Priorities

The near-term product order is:

1. Local-first gameplay and content depth.
2. Supabase verification or explicit backend disablement before upload.
3. Daily challenge foundation if scope allows before v1.
4. GitHub Pages support/privacy/landing page.
5. ASO and App Store submission assets.
6. Monetization in version 2.

The first active spec is `features/active/local-content-depth/SPEC.md`.

## How To Prompt An Agent

Exploration:

```text
Work on `local-content-depth` in exploration mode.
The canonical spec workspace is:
`/Users/zhengcheng/Documents/🌰 Nutstore/🍊Personal project_coding/WordLink-iOS/product-workflow`.
Read AGENTS.md and follow its instructions. Update the original SPEC.md directly.
```

Implementation:

```text
Work on `local-content-depth` in implementation mode.
The canonical spec workspace is:
`/Users/zhengcheng/Documents/🌰 Nutstore/🍊Personal project_coding/WordLink-iOS/product-workflow`.
Read AGENTS.md and follow its instructions. Update the original SPEC.md directly.
```

Before finishing, ask the agent to update the active feature's `SPEC.md` and
the matching row in `ACTIVE.md`.


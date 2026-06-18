# Product Foundation

## Mission

WordLink is a native iOS word puzzle game that helps players build English
phrase fluency through short, satisfying word-chain puzzles.

Players solve a 9-word chain by guessing the hidden connecting word between
adjacent compound phrases, idioms, or collocations. Each chain has 8
connections to solve.

## Primary Users

| User | Goal | Product Need |
|---|---|---|
| English learners | Learn phrases in context instead of memorizing isolated words. | Natural phrase pairs, concise explanations, pronunciation, and review. |
| Casual word-game players | Play quick puzzles with clear progression and satisfying feedback. | Fast start, clean difficulty tiers, hints, scoring, and history. |
| Solo founder / operator | Ship a focused iOS v1 and grow through App Store search. | Low operational complexity, local-first content, clear ASO and support docs. |

## Core Product Surfaces

| Surface | Purpose | Status |
|---|---|---|
| Home | Start play or view history. | live |
| Difficulty selection | Choose easy, medium, or hard. | live |
| Gameplay | Guess each next word in the chain with hints and feedback. | live |
| Phrase flashcards | Review completed phrase pairs and explanations. | live |
| Results | Show score, completed phrases, sharing, and replay. | live |
| History | Review previous games stored locally. | live |
| Daily challenge | Give players a habit loop. | planned |
| Support / privacy site | Support App Store review and marketing funnel. | planned |

## Difficulty Meaning

| Difficulty | Product Meaning | Code |
|---|---|---|
| Easy | Common phrases and simple connections. | `Difficulty.easy` |
| Medium | Idioms and everyday collocations. | `Difficulty.medium` |
| Hard | Complex idioms and abstract links. | `Difficulty.hard` |

## Product Principles

- First play should be fast, local-first, and not blocked by the backend.
- Content quality matters more than volume because the app teaches English.
- Every accepted phrase pair should feel natural to English speakers and useful
  to learners.
- Gameplay should remain native iOS; do not architect for web reuse now.
- Version 1 should stay simple: no ads, no IAP, no subscription, no required
  account.
- Web should drive App Store installs, not become a parallel product.

## Non-Goals

- Do not make live in-app generation the primary gameplay path.
- Do not build a full playable web game for v1.
- Do not add battle mode before daily challenge and content depth.
- Do not add monetization before the first v1 upload unless the product decision
  changes.

## Source Docs

- Root project context: `AGENTS.md`
- Current progress: `docs/progress.md`
- Retention and content roadmap: `docs/retention-roadmap.md`
- Web funnel: `docs/web-funnel.md`
- App Store submission: `docs/app-store-submission.md`


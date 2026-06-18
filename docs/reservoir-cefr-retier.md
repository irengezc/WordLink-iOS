# Reservoir CEFR Re-tier — Working Doc

> Branch: `irengezc/reservoir-word-levels`
> Goal: make difficulty tiers match CEFR levels so "easy" is actually friendly
> to A1–A2 second-language learners.
> Started: 2026-06-18

## Problem

The current `WordLink/reservoir.json` tiers do not match learner difficulty.
The "easy" tier uses common words but many *links* require native/cultural
knowledge (e.g. `BARRIER REEF`, `BRIDGE LOAN`, `PLAYER PIANO`, `CABIN FEVER`),
so it plays much harder than A1–A2.

## Game mechanic (why difficulty ≠ word rarity alone)

Each puzzle is a 9-word chain; every adjacent pair is a real compound/
collocation. The player sees the current word + the **first letter + length**
(`?` placeholders) of the next word and types the rest. Difficulty is driven by:

1. Word frequency (how common the words are).
2. Link guessability (can the player predict the next word?).
3. Concept abstractness (concrete everyday vs. abstract/specialized jargon).

## CEFR rubric

| Tier | CEFR | Word frequency | Link type | Concepts |
|---|---|---|---|---|
| Easy | A1–A2 | top ~1–2k everyday words | transparent everyday compounds a beginner uses daily | concrete, physical |
| Medium | B1–B2 | top ~3–5k | common collocations + light idioms | some abstract |
| Hard | C1–C2 | low-frequency / specialized | idioms, figurative, domain jargon | abstract (finance/legal/literary) |

Extra rule for easy: every link must be plausibly guessable from the prompt
word + first letter. If it needs trivia, it is not easy.

## Decisions (confirmed with user 2026-06-18)

1. Keep 15/15/15 counts for this branch. Expansion deferred.
2. Rebuild easy from scratch; re-tier medium/hard.
3. Add an automated CEFR frequency gate to `tools/validate-reservoir.js`.
4. Content stays US-canonical, but gameplay accepts both US and UK spellings.
   Input cap = longest accepted variant; displayed `?` length stays US.

## Plan / Task tracker

- [x] T1. Acquire/bundle CEFR-graded word list at `tools/cefr-wordlist.json`
      (A1/A2/B1/B2/C1 bands). 4924 words. word → level map, lowercase keys.
- [x] T2. Extend `tools/validate-reservoir.js` with the frequency gate:
      easy B2+ = error, easy B1 = quality flag, medium C1+ = error, hard
      uncapped. Spelling-insensitive lookup. Missing-from-list = quality flag
      because the list is incomplete.
- [ ] T3. Rebuild easy tier (15 chains) against the rubric + gate.
- [ ] T4. Re-tier / rebalance medium and hard to 15 each.
- [ ] T5. Rewrite explanations to match new links.
- [ ] T6. Dual-spelling acceptance: `SpellingVariants` helper + GameViewModel
      guess check + input-length cap. (Code change for decision 4.)
- [ ] T7. Run validator until clean; capture counts.
- [ ] T8. Update `docs/reservoir-audit.md` and the local-content-depth SPEC.
- [ ] T9. Human-review pass before commit.

## Gate design decisions (refined during execution)

- Level rank: A1=1, A2=2, B1=3, B2=4, C1=5, C2=6. Error caps: easy allows
  B1 but errors on B2+, medium≤B2, hard uncapped. Easy still flags B1 for
  human review because the target is A1–A2.
- Lookup is lowercase + spelling-insensitive (US/UK variant forms both resolve).
- The Oxford-derived list does **not** contain closed compounds (RAINBOW,
  PLAYGROUND, SNOWMAN) nor every common short word; some split parts are also
  oddly scored (e.g. `bow`=C1 inside RAINBOW). So:
  - Easy word found at B2+ → **error**.
  - Easy word found at B1 → **quality flag**.
  - Medium word found at C1+ → **error**.
  - Word **missing** from list → **quality flag** (human-verify), not an error,
    because the list is incomplete. Easy chains are built to minimise these.
- Practical consequence: easy chains use words that resolve ≤A2 where possible
  and avoid known-high split parts like BOW.

## Dual-spelling implementation notes (T6)

- `wordLength`/displayed `?` count stay **canonical (US)**.
- Accept guess if `(prefix+input)` equals the canonical target **or any
  spelling variant**.
- Input cap = length of the **longest** accepted variant (so longer UK forms
  like JUDGEMENT, CATALOGUE are typeable).
- Auto-submit currently fires only at `maxInputLength`. With a raised cap the
  shorter US form would never auto-submit, so also auto-submit as soon as the
  typed string forms a **complete accepted variant**.
- Variant rules: `-or/-our`, `-er/-re`, `-ize/-ise`, `-og/-ogue`, `-se/-ce`,
  plus explicit irregular list. Words in current data needing variants: CENTER,
  DEFENSE, JUDGMENT, CATALOG (and any new ones introduced).

## Progress log

- 2026-06-18: Plan confirmed. Doc created. T1 wordlist bundled (4924 words).
- 2026-06-19: Resumed. Gate design refined (missing-word handling). Starting T2.
- 2026-06-19: T2 implemented. Current reservoir fails as expected: 14 errors,
  0 warnings, 42 quality flags. Added `.context/difficulty-levels-handoff.md`
  for Conductor workspace resume context.

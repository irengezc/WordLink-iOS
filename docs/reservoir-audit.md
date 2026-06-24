# Reservoir Audit

Audit date: 2026-06-24

## Summary

The current reservoir is structurally valid and has been re-tiered for a
learner-facing 45-chain seed. The easy tier was rebuilt to avoid the old
native-heavy links that made it too difficult for A1-A2 learners.

Structural validation after CEFR re-tier:

- Easy: 15 chains.
- Medium: 15 chains.
- Hard: 15 chains.
- Total: 45 chains.
- No JSON/schema errors found.
- Every chain has 9 words.
- Every chain has 8 explanations.
- No CEFR blocking errors.
- 2 repeated-pair warnings remain for human review.
- 30 quality flags remain under the pragmatic gate, mostly missing word-list
  entries in medium/hard and a few B1-but-everyday easy words.

Content quality:

- The old reservoir proved the local reservoir mechanism but included native
  or domain-heavy easy links such as `BARRIER REEF`, `BRIDGE LOAN`,
  `CABIN FEVER`, and `STROKE COUNT`.
- The current reservoir keeps the 15/15/15 seed size, rebuilds easy around
  concrete everyday links, and removes medium-tier C1 blockers.
- Continue human review before accepting new chains because the validator cannot
  fully judge natural English usage.

## Quality Bar

Acceptable pairs should be one of:

- A common open compound: `HIGH SCHOOL`, `BUS STOP`.
- A common closed compound that is still teachable as a compound relationship,
  used carefully and explained clearly.
- A common phrasal verb: `BACK UP`, `WORK OUT`.
- A common idiom/collocation: `COLD FEET`, `SILVER LINING`.

Avoid:

- Splitting a single word into misleading chunks: `SHOP PING`, `MOVE MENT`,
  `SHIFT ER`.
- Rare or unnatural adjacent pairs created only to bridge a chain.
- Pairs whose explanation invents a meaning that English speakers would not
  naturally recognize.
- Too many closed compounds displayed as separated words if the app is teaching
  ESL learners.

Hard rule:

- Awkward ESL examples and synthetic connector pairs are forbidden. Examples
  include `SHOP PING`, `MOVE MENT`, `SHIFT ER`, `PLAN NET`, `WIRE LESS`,
  `LESS ON`, `ER BOARD`, and similar suffix/fragment constructions.
- Weak or invented standalone compounds are also forbidden. Examples include
  `AID KIT`, `BLADE RUNNER`, `CAP SIZE`, `THROAT CLEARING`, and
  `DRIVER LICENSE`.
- The validator should fail on known-bad pairs rather than allowing them as
  warnings.

## Automated QA

Added `tools/validate-reservoir.js`.

Run:

```bash
node tools/validate-reservoir.js WordLink/reservoir.json
```

Current result after cleanup:

```text
Counts: easy=15, medium=15, hard=15, total=45
CEFR gate: on (easy: B2+ error / B1 flag, medium<=B2, hard uncapped; 4924 words)
Errors: 0
Warnings: 2
Quality flags: 30
```

The script checks:

- Required `easy`, `medium`, and `hard` buckets.
- 9 words per chain.
- 8 explanations per chain.
- Uppercase alphabetic words.
- Duplicate chains.
- Repeated adjacent pairs.
- Explanation labels that do not match adjacent pairs.
- Fragment-like words such as `PING`, `LESS`, `MENT`, and `ER`.
- Known forbidden pairs such as `SHOP PING`, `MOVE MENT`, `SHIFT ER`, and
  `PLAN NET`.
- Review-discovered forbidden pairs such as `AID KIT`, `BLADE RUNNER`,
  `CAP SIZE`, `THROAT CLEARING`, and `DRIVER LICENSE`.
- CEFR frequency caps: easy B2+ fails, easy B1 is flagged for review,
  medium C1+ fails, and hard is uncapped.

## Old Repeated Pairs

These repeated pairs appeared in the old reservoir and were removed during the
cleanup.

| Pair | Notes |
|---|---|
| `WORK SHOP` | Repeats in easy chains. Also should likely be `WORKSHOP` or avoided. |
| `BOARD GAME` | Repeats across easy/medium/hard. |
| `PLAY GROUND` | Repeats; likely should be `PLAYGROUND` or avoided. |
| `LINE DANCE` | Repeats in medium. |
| `SHARP SHOOTER` | Repeats in hard; likely `SHARPSHOOTER` as a closed compound. |
| `PROOF READ` | Repeats; likely `PROOFREAD` or avoided. |
| `LIFT OFF` | Repeats; acceptable but duplicated. |
| `OFF BEAT` | Repeats; likely `OFFBEAT` or avoided. |
| `BACK FIRE` | Repeats; likely `BACKFIRE` or avoided. |

## Old High-Priority Replacement Candidates

These pairs were the clearest issues in the old reservoir because they looked
like fragments or invented phrases. Known-bad pairs are now rejected by the
validator.

| Bucket | Chain | Problem Pairs |
|---|---:|---|
| Easy | 1 | `SHOP PING` |
| Easy | 2 | `LUCK KEY`, `PLAN NET` |
| Easy | 10 | `WORKS SHOP`, `KEEPER NET`, `NET WORK` |
| Medium | 3 | `WIRE LESS`, `LESS ON`, `ON LINE` |
| Medium | 6 | `BACKER BOARD`, `CHANGER OVER` |
| Medium | 7 | `COACH WORK`, `LOAD STONE` |
| Medium | 9 | `DANCE MOVE`, `MOVE MENT`, `MENT WIDE` |
| Medium | 10 | `CHASER SCENE` |
| Medium | 11 | `MINDED SET` |
| Medium | 12 | `HOLDER ON`, `PIECE MEAL` |
| Hard | 3 | `CLAD SECRET`, `KEEPER SAKE`, `SAKE BOMB`, `SHOCKED AWE` |
| Hard | 4 | `SHOOTER GAME` |
| Hard | 5 | `MAKER SHIFT`, `AROUND CLOCK`, `CLOCK WISE` |
| Hard | 6 | `SHOOTER PROOF`, `LINES MAN` |
| Hard | 7 | `BEAT NICK` |
| Hard | 9 | `DOCTOR OFFICE`, `HOLDER BACK` |
| Hard | 10 | `MATE SHIP`, `SHIFT ER`, `ER BOARD` |

## Closed-Compound / Spacing Review

These may be recognizable concepts, but displaying them as two words can teach
the wrong spelling or feel unnatural. Keep only if the explanation intentionally
teaches the compound relationship.

Examples:

- `SUN FLOWER`
- `KEY BOARD`
- `FIRE PLACE`
- `BOARD WALK`
- `SIDE WALK`
- `BOOK SHELF`
- `ROOM MATE`
- `PLAY GROUND`
- `WORK FORCE`
- `BACK PACK`
- `STAR FISH`
- `WATER PROOF`
- `PAPER BACK`
- `FIRE WORKS`
- `SWITCH BOARD`
- `BOARD ROOM`
- `OUT BREAK`
- `BREAK DOWN`
- `DOWN TOWN`
- `HALL MARK`
- `SHORT CUT`
- `HOUSE HOLD`
- `UP BEAT`
- `DEAD LINE`
- `LINE BACKER`
- `MASTER MIND`
- `MIND SET`
- `SET BACK`
- `BACK STAGE`
- `GROUND BREAKING`
- `BRAIN STORM`
- `SUN RISE`
- `OPEN MINDED`
- `RAIL ROAD`
- `ROAD BLOCK`
- `MARKET PLACE`
- `PLACE HOLDER`
- `CENTER PIECE`
- `MEAL TIME`
- `HAND SHAKE`
- `SHAKE DOWN`
- `DOWN FALL`
- `OUT CAST`
- `STAND OFF`
- `OFF HAND`
- `HAND PICKED`
- `OUT FOXED`
- `SMOKE SCREEN`
- `SCREEN PLAY`
- `PLAY MAKER`
- `WORK AROUND`
- `WILD CARD`
- `CARD BOARD`
- `FACE LIFT`
- `CAMP FIRE`
- `FIRE SIDE`
- `SIDE TRACK`
- `SPIN DOCTOR`
- `FIRE STORM`
- `STORM DRAIN`
- `BLIND SPOT`
- `SPOT CHECK`
- `CHECK MATE`
- `SHIP SHAPE`
- `SHAPE SHIFT`

## Next Content Plan

1. Expand the cleaned v1 seed reservoir with only natural, teachable pairs.
2. Keep the next target modest but useful, such as 50 easy, 50 medium, and 50
   hard.
3. Add chain IDs before the reservoir becomes large, so progress tracking is not
   tied to array indices.
4. Run `tools/validate-reservoir.js` before every reservoir change.
5. Add a human review pass for ESL quality before App Store upload.

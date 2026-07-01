# Cost-Efficient Reservoir Expansion Pipeline

## Problem

Hand-authoring full 9-word chains is too slow for the 450-chain local target.
It also burns review effort on chain construction instead of the part that
matters most: whether each adjacent link is natural, teachable English.

The faster path is to stop writing chains directly and build a reviewed link
bank first.

## Target

Reach the one-month local reservoir goal:

- 150 easy chains.
- 150 medium chains.
- 150 hard chains.
- 450 total chains.

Current state:

- 28 easy.
- 29 medium.
- 29 hard.
- 86 total.

Remaining target:

- 122 more easy.
- 121 more medium.
- 121 more hard.
- 364 more total.

## Recommended Pipeline

Use a four-stage pipeline.

### 1. Build A Pair Bank

Create a source-of-truth table of approved adjacent links.

Each row should represent one playable link:

```json
{
  "left": "PART",
  "right": "TIME",
  "canonical": "PART-TIME",
  "linkType": "hyphenated_compound",
  "difficulty": "medium",
  "cefrMax": "A1",
  "explanation": "PART-TIME: Work or study for only part of the normal time.",
  "status": "approved"
}
```

Why this is cheaper:

- A pair can be reviewed once and reused as a graph edge.
- Bad pairs can be rejected before they contaminate a full chain.
- The generator can assemble hundreds of chain candidates from a smaller bank.

### 2. Generate Chain Candidates From The Pair Graph

Treat words as graph nodes and approved pairs as directed edges.

Rules for generated chains:

- 9 words.
- 8 approved pair edges.
- No repeated pair in the playable reservoir.
- No repeated full chain.
- Match one difficulty.
- Prefer varied topics and starting words.
- Avoid chains with too many `split_word` links.
- Keep `hyphenated_compound` links rare and clearly explained.

This turns the task from "write 381 chains" into "review a large candidate
queue and accept the best chains."

### 3. Batch Review Instead Of Batch Author

Review generated candidates in batches of 30-50.

For each candidate, check:

- Does every pair sound natural?
- Does every explanation teach the real canonical form?
- Is the chain too weird or too technical for its tier?
- Does it overuse closed-compound splits?
- Is there any fake bridge pair?

Expected acceptance rate:

- Easy: 30-50% because CEFR and naturalness are stricter.
- Medium: 50-70%.
- Hard: 60-80%, as long as the links are real.

### 4. Export Reservoir JSON

Only approved chains should be exported into `WordLink/reservoir.json`.

The export step should:

- Add `chain`.
- Add `explanations`.
- Add `linkTypes`.
- Preserve stable IDs once implemented.
- Run `node tools/validate-reservoir.js WordLink/reservoir.json`.
- Update counts in `docs/reservoir-audit.md` and `docs/progress.md`.

## Cost-Efficient Content Sources

Use source types in this order.

| Source | Cost | Quality | Recommended Use |
|---|---:|---:|---|
| Existing reservoir pairs | Very low | High | Seed the pair bank immediately. |
| Curated manual pair bank | Medium | Highest | Best for easy tier and ESL quality. |
| AI-generated candidate pairs | Low | Medium | Use only as draft candidates, never direct export. |
| Public phrase/compound lists | Low | Medium | Useful if license/source is clean; still needs review. |
| Live in-app generation | Low upfront, high product risk | Low | Do not use for primary gameplay. |

## Practical Batch Plan

### Batch A: Build The Tooling

1. Extract all current reservoir links into a pair-bank JSON file.
2. Add a small chain-candidate generator.
3. Add a review queue file for candidate chains.
4. Add an exporter that writes approved candidates back to reservoir format.

Status: built.

Current files:

- `tools/extract-pair-bank.js`
- `tools/generate-chain-candidates.js`
- `tools/export-approved-candidates.js`
- `data/reservoir-pair-bank.json`
- `data/reservoir-candidate-queue.json`
- `docs/ai-reservoir-workflow.md`

Current seed result:

- Pair bank rows: 702 reviewed links extracted from the 86-chain reservoir.
- Candidate queue rows: 17 exported rows from the July 1 checkpoint. The first
  generator run from the old 550-row bank produced zero candidates because that
  bank only contained pairs already used in playable chains, and the generator
  refuses to reuse existing playable pairs by default.
- Latest generator stop: with 702 pair-bank rows and the current 86-chain
  reservoir, `CANDIDATES_PER_DIFFICULTY=10 CANDIDATE_ATTEMPTS=20000` added zero
  easy, medium, or hard candidates. Add unused connector pairs before rerunning
  the generator.

Useful commands:

```bash
node tools/extract-pair-bank.js WordLink/reservoir.json data/reservoir-pair-bank.json
node tools/generate-chain-candidates.js data/reservoir-pair-bank.json WordLink/reservoir.json data/reservoir-candidate-queue.json
node tools/export-approved-candidates.js data/reservoir-candidate-queue.json WordLink/reservoir.json
node tools/validate-reservoir.js WordLink/reservoir.json
```

Next content step: add or import unused candidate pair rows into
`data/reservoir-pair-bank.json` with `status: "candidate"`, prioritizing
connectors that share useful middle words but do not repeat playable pairs.
Then run the generator. After reviewing generated chains, change accepted queue
rows to `status: "approved"` and run the exporter.

For an autonomous AI-agent workflow with step-by-step prompts, use
`docs/ai-reservoir-workflow.md`.

### Batch B: Grow To 50 Per Difficulty

Use the pair bank plus generator to reach:

- 50 easy.
- 50 medium.
- 50 hard.
- 150 total.

This is the first useful content-depth milestone.

### Batch C: Grow To 100 Per Difficulty

Use larger candidate batches and review only the best outputs.

Target:

- 100 easy.
- 100 medium.
- 100 hard.
- 300 total.

### Batch D: Grow To 150 Per Difficulty

Fill gaps in topics and difficulty balance.

Target:

- 150 easy.
- 150 medium.
- 150 hard.
- 450 total.

## Review Budget

Manual method:

- 381 chains remaining.
- 8 links each.
- 3,048 link decisions hidden inside full-chain drafting.
- Very slow and easy to fatigue.

Pair-bank method:

- Review roughly 900-1,200 pair candidates once.
- Auto-assemble chain candidates.
- Human review focuses on final chain flow and suspicious links.
- Much faster, and rejected pairs stay rejected permanently.

## Recommended Next Build Step

Grow the pair bank with unused candidate links.

Best next target:

- Add 200 easy candidate pairs.
- Add 250 medium candidate pairs.
- Add 250 hard candidate pairs.
- Generate 30-50 candidate chains per difficulty.
- Review only the best candidates for export.

This should get the project to the 50/50/50 milestone much faster than direct
chain drafting.

# AI Reservoir Expansion Workflow

Use this file to give another AI agent enough structure to expand the WordLink
reservoir without asking for approval at every step.

## Objective

Grow `WordLink/reservoir.json` toward the local one-month target:

- 150 easy chains.
- 150 medium chains.
- 150 hard chains.
- 450 total chains.

Current checkpoint:

- 28 easy.
- 29 medium.
- 29 hard.
- 86 total.

## Autonomy Rules

The agent may proceed without asking the user when all of these are true:

- It only changes reservoir-related files listed in this workflow.
- It keeps `node tools/validate-reservoir.js WordLink/reservoir.json` at
  `Errors: 0`.
- It does not increase repeated-pair warnings unless the reason is documented
  and the pair is intentionally allowed.
- It treats all AI-generated content as candidates until reviewed.
- It rejects fake, awkward, or synthetic English even if the validator permits
  it.
- It updates docs after each clean checkpoint.

The agent must stop and ask before:

- Weakening `tools/validate-reservoir.js`.
- Accepting a disputed pair only to make a chain work.
- Changing app gameplay code.
- Changing backend/Supabase behavior.
- Touching unrelated files or Nutstore conflict files.
- Pushing, committing, or deleting files.

## Files

Primary files:

- `WordLink/reservoir.json`
- `tools/validate-reservoir.js`
- `tools/extract-pair-bank.js`
- `tools/generate-chain-candidates.js`
- `tools/export-approved-candidates.js`
- `data/reservoir-pair-bank.json`
- `data/reservoir-candidate-queue.json`

Docs to update:

- `docs/progress.md`
- `docs/reservoir-audit.md`
- `docs/cost-efficient-reservoir-pipeline.md`
- `product-workflow/features/active/local-content-depth/SPEC.md`

Do not touch unless explicitly asked:

- `CLAUDE.nssyncsc`
- `README-NSConflict-*`
- unrelated feature specs

## Link Types

Every link must be one of:

- `split_word`: two visible real parts join into one standard English word.
- `hyphenated_compound`: canonical form uses a hyphen.
- `two_word_phrase`: a natural open compound, phrase, idiom, collocation, or
  phrasal verb.

Forbidden:

- suffix fragments such as `PING`, `MENT`, `ER`, `LESS`
- fake bridge pairs
- unnatural pairs that exist only to connect a chain
- misleading explanations
- hidden hyphenated spelling for `hyphenated_compound`

## Step 1: Generate Candidate Pairs

Use this prompt with an AI model to generate pair-bank rows.

```text
You are generating candidate English word-link pairs for WordLink, an ESL word-chain puzzle.

Return only valid JSON: an array of objects.

Each object must have:
{
  "left": "WORD",
  "right": "WORD",
  "canonical": "CANONICAL FORM",
  "linkType": "split_word|hyphenated_compound|two_word_phrase",
  "difficulty": "easy|medium|hard",
  "explanation": "PAIR: short learner-friendly explanation.",
  "status": "candidate"
}

Generate 200 rows for DIFFICULTY = <easy|medium|hard>.

Rules:
- Use uppercase A-Z words for left and right.
- No fake phrases.
- No suffix fragments like PING, MENT, ER, LESS.
- split_word must join into one standard English word, and both visible parts must be real teachable words.
- hyphenated_compound must have a canonical form with a hyphen, such as PART-TIME.
- two_word_phrase must be natural English: open compound, collocation, idiom, or phrasal verb.
- Easy should use common learner-friendly words and concrete ideas.
- Medium can use everyday B1-B2 phrases, workplace phrases, travel, school, technology, and common idioms.
- Hard can use abstract, technical, legal, business, scientific, or idiomatic phrases, but must still be real English.
- Prefer boring naturalness over cleverness.
- Explanation must start with the playable label. For hyphenated compounds, start with the hyphenated canonical label.
- Avoid duplicates within this response.
```

Recommended batches:

- 200 easy candidate pairs.
- 250 medium candidate pairs.
- 250 hard candidate pairs.

## Step 2: Merge Candidate Pairs

Add generated rows into `data/reservoir-pair-bank.json`.

Rules:

- Preserve existing approved rows.
- Add new rows with `status: "candidate"`.
- De-duplicate by `left + "_" + right`.
- Do not overwrite an existing `approved` row with a candidate row.
- Reject rows with missing fields.
- Reject rows with invalid `linkType`.
- Reject rows where `left` or `right` is not uppercase A-Z.

Useful command before merging:

```bash
node tools/extract-pair-bank.js WordLink/reservoir.json data/reservoir-pair-bank.json
```

## Step 3: Review Pair Candidates

Use this prompt to review pair-bank candidates.

```text
Review these WordLink pair-bank rows for ESL puzzle quality.

Return JSON array with the same rows, changing only:
- status: "approved" or "rejected"
- optional reviewNote: short reason

Approval criteria:
- The pair is real, natural English.
- The explanation is accurate and learner-friendly.
- The difficulty is reasonable.
- split_word joins into a real standard word.
- hyphenated_compound teaches the canonical hyphenated spelling.
- two_word_phrase is a natural phrase, collocation, idiom, open compound, or phrasal verb.

Reject:
- fake bridge pairs
- rare phrases that feel invented
- awkward ESL examples
- suffix fragments
- misleading closed-compound splits
- explanations that invent a meaning
```

Automation rule:

- The agent may approve obvious, common pairs.
- The agent should reject questionable pairs rather than keep them.
- If uncertain, set `status: "rejected"` with `reviewNote: "uncertain naturalness"`.

## Step 4: Generate Chain Candidates

Run:

```bash
node tools/generate-chain-candidates.js data/reservoir-pair-bank.json WordLink/reservoir.json data/reservoir-candidate-queue.json
```

Optional larger run:

```bash
CANDIDATES_PER_DIFFICULTY=50 CANDIDATE_ATTEMPTS=20000 node tools/generate-chain-candidates.js data/reservoir-pair-bank.json WordLink/reservoir.json data/reservoir-candidate-queue.json
```

Expected result:

- Candidate chains are added to `data/reservoir-candidate-queue.json`.
- If it adds zero candidates, the pair bank is not connected enough. Generate
  more candidate pairs that share useful middle words.

Good connector words:

- easy: `BOOK`, `CARD`, `BOX`, `SHOP`, `HOME`, `SCHOOL`, `ROOM`, `TIME`,
  `GAME`, `WATER`, `FOOD`, `DAY`
- medium: `MARKET`, `SERVICE`, `SYSTEM`, `PROJECT`, `FIELD`, `GROUP`,
  `CONTROL`, `REVIEW`, `REPORT`, `CENTER`, `POINT`
- hard: `MODEL`, `SIGNAL`, `NETWORK`, `POLICY`, `STATE`, `AGENT`, `ERROR`,
  `RISK`, `POWER`, `VALUE`, `SYSTEM`

## Step 5: Review Chain Candidates

Use this prompt to review chain candidates.

```text
Review these WordLink chain candidates.

Return JSON array with the same objects, changing only:
- status: "approved" or "rejected"
- optional reviewNote

Approval criteria:
- All 8 links are natural English.
- The chain does not feel like random glue.
- The difficulty is coherent.
- Easy is concrete and learner-friendly.
- Medium is everyday but a bit richer.
- Hard may be abstract or technical, but still teachable.
- Explanations are accurate and concise.
- split_word and hyphenated_compound links teach canonical forms clearly.

Reject chains with:
- any fake bridge pair
- too many split_word links
- awkward transitions
- repeated idea fatigue
- one link that only exists to make the graph work
```

Automation rule:

- Approve only high-confidence candidates.
- Prefer rejecting too many over exporting weak chains.
- A batch acceptance rate under 50% is acceptable.

## Step 6: Export Approved Candidates

After marking good candidate chains as `status: "approved"`, run:

```bash
node tools/export-approved-candidates.js data/reservoir-candidate-queue.json WordLink/reservoir.json
node tools/validate-reservoir.js WordLink/reservoir.json
```

If validation reports `Errors: 0`, continue.

If validation reports errors:

- Fix or remove the exported candidates.
- Do not weaken the validator.
- Re-run validation.

## Step 7: Update Docs

After a clean export checkpoint, update:

- counts in `docs/progress.md`
- counts and validation output in `docs/reservoir-audit.md`
- current state in `docs/cost-efficient-reservoir-pipeline.md`
- current state in `product-workflow/features/active/local-content-depth/SPEC.md`

Record:

- easy count
- medium count
- hard count
- total count
- validator errors/warnings/quality flags
- link-type counts if changed substantially

## Step 8: Stop Conditions

Stop after each clean milestone:

- 50/50/50
- 100/100/100
- 150/150/150

Also stop if:

- the generator cannot produce candidates after 700+ pair rows
- validation errors cannot be fixed by rejecting candidates
- easy quality starts requiring awkward or rare links
- repeated-pair warnings increase materially

## Final Acceptance

A reservoir expansion checkpoint is acceptable only when:

```bash
node tools/validate-reservoir.js WordLink/reservoir.json
```

reports:

- `Errors: 0`
- no unexplained increase in repeated-pair warnings
- counts documented in progress/audit docs

Do not push or commit without explicit user request.

#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const reservoirPath = process.argv[2] || path.join("WordLink", "reservoir.json");
const expectedBuckets = ["easy", "medium", "hard"];
const fragmentLikeWords = new Set([
  "ER",
  "LESS",
  "MENT",
  "PING",
]);
const forbiddenPairs = new Set([
  "AID KIT",
  "BACKER BOARD",
  "BLADE RUNNER",
  "CAP SIZE",
  "CHANGER OVER",
  "CHASER SCENE",
  "CLAD SECRET",
  "COACH WORK",
  "DANCE MOVE",
  "DOCTOR OFFICE",
  "DRIVER LICENSE",
  "ER BOARD",
  "HOLDER BACK",
  "HOLDER ON",
  "KEEPER NET",
  "KEEPER SAKE",
  "LESS ON",
  "LUCK KEY",
  "MAKER SHIFT",
  "MENT WIDE",
  "MINDED SET",
  "MOVE MENT",
  "PLAN NET",
  "SAKE BOMB",
  "SHIFT ER",
  "SHOP PING",
  "SHOOTER GAME",
  "SHOOTER PROOF",
  "THROAT CLEARING",
  "WIRE LESS",
  "WORKS SHOP",
]);

// CEFR frequency gate ------------------------------------------------------
// The `easy` tier targets A1–A2 but tolerates the occasional B1 word inside an
// otherwise transparent everyday compound (a strict all-A2 rule is topologically
// impossible for 9-word chains: only ~15 A1/A2 words act as compound
// pass-throughs, so chains cannot avoid heavy repetition). So:
//   easy   : B2+ = ERROR (blocks the real offenders, e.g. BARRIER/FILTER/LOAN),
//            B1   = quality flag (above the A1–A2 target; human-review).
//   medium : C1+ = ERROR (cap B2).
//   hard   : uncapped.
// Lookup is lowercase + spelling-insensitive (US/UK forms both resolve). Words
// missing from the (incomplete) word list are quality flags for human review.
const cefrWordlistPath = path.join(__dirname, "cefr-wordlist.json");
const levelRank = { A1: 1, A2: 2, B1: 3, B2: 4, C1: 5, C2: 6 };
const tierErrorCap = { easy: 3, medium: 4, hard: 6 };
const tierFlagCap = { easy: 2 };

// Explicit irregular spelling pairs not covered by the rule-based swaps below.
const irregularSpellings = {
  judgment: ["judgement"],
  judgement: ["judgment"],
  catalog: ["catalogue"],
  catalogue: ["catalog"],
  gray: ["grey"],
  grey: ["gray"],
  plow: ["plough"],
  plough: ["plow"],
  tire: ["tyre"],
  tyre: ["tire"],
  check: ["cheque"],
  donut: ["doughnut"],
  doughnut: ["donut"],
};

// Generate plausible US/UK spelling variants of a lowercase word.
function spellingVariants(word) {
  const variants = new Set([word]);
  const swaps = [
    [/our\b/g, "or"],
    [/or\b/g, "our"],
    [/re\b/g, "er"],
    [/er\b/g, "re"],
    [/ise\b/g, "ize"],
    [/ize\b/g, "ise"],
    [/isation\b/g, "ization"],
    [/ization\b/g, "isation"],
    [/ogue\b/g, "og"],
    [/og\b/g, "ogue"],
    [/se\b/g, "ce"],
    [/ce\b/g, "se"],
  ];
  for (const [pattern, replacement] of swaps) {
    if (pattern.test(word)) {
      variants.add(word.replace(pattern, replacement));
    }
  }
  for (const variant of irregularSpellings[word] || []) {
    variants.add(variant);
  }
  return variants;
}

function loadWordlist() {
  if (!fs.existsSync(cefrWordlistPath)) return null;
  try {
    return JSON.parse(fs.readFileSync(cefrWordlistPath, "utf8"));
  } catch (error) {
    fail(`Invalid JSON in ${cefrWordlistPath}: ${error.message}`);
  }
}

// Return the lowest (most lenient) CEFR rank among the word's spelling
// variants, or null if none are in the list.
function lookupLevel(wordlist, word) {
  const lower = word.toLowerCase();
  let best = null;
  let bestLevel = null;
  for (const variant of spellingVariants(lower)) {
    const level = wordlist[variant];
    if (level && (best === null || levelRank[level] < best)) {
      best = levelRank[level];
      bestLevel = level;
    }
  }
  return bestLevel;
}

function fail(message) {
  console.error(`Error: ${message}`);
  process.exit(1);
}

function readReservoir(filePath) {
  let raw;
  try {
    raw = fs.readFileSync(filePath, "utf8");
  } catch (error) {
    fail(`Could not read ${filePath}: ${error.message}`);
  }

  try {
    return JSON.parse(raw);
  } catch (error) {
    fail(`Invalid JSON in ${filePath}: ${error.message}`);
  }
}

function normalizePair(left, right) {
  return `${left.trim().toUpperCase()} ${right.trim().toUpperCase()}`;
}

function validateEntry(entry, bucket, index, seenChains, seenPairs, report, wordlist) {
  const label = `${bucket}[${index}]`;

  if (!entry || typeof entry !== "object" || Array.isArray(entry)) {
    report.errors.push(`${label}: entry must be an object`);
    return;
  }

  if (!Array.isArray(entry.chain)) {
    report.errors.push(`${label}: chain must be an array`);
    return;
  }

  if (!Array.isArray(entry.explanations)) {
    report.errors.push(`${label}: explanations must be an array`);
    return;
  }

  if (entry.chain.length !== 9) {
    report.errors.push(`${label}: expected 9 chain words, got ${entry.chain.length}`);
  }

  if (entry.explanations.length !== 8) {
    report.errors.push(`${label}: expected 8 explanations, got ${entry.explanations.length}`);
  }

  const normalizedWords = entry.chain.map((word, wordIndex) => {
    if (typeof word !== "string") {
      report.errors.push(`${label}: chain[${wordIndex}] must be a string`);
      return "";
    }

    const normalized = word.trim().toUpperCase();
    if (!/^[A-Z]+$/.test(normalized)) {
      report.errors.push(`${label}: chain[${wordIndex}] "${word}" must contain only letters`);
    }

    if (word !== normalized) {
      report.warnings.push(`${label}: chain[${wordIndex}] "${word}" should be uppercase with no surrounding whitespace`);
    }

    if (normalized.length <= 1 || fragmentLikeWords.has(normalized)) {
      report.qualityFlags.push(`${label}: "${normalized}" looks fragment-like; verify it forms natural phrases`);
    }

    if (wordlist && normalized.length > 1) {
      const errorCap = tierErrorCap[bucket];
      const flagCap = tierFlagCap[bucket];
      const level = lookupLevel(wordlist, normalized);
      if (level === null) {
        report.qualityFlags.push(`${label}: "${normalized}" not in CEFR word list; verify it fits the ${bucket} tier`);
      } else if (errorCap !== undefined && levelRank[level] > errorCap) {
        report.errors.push(`${label}: "${normalized}" is ${level}, above the ${bucket}-tier cap`);
      } else if (flagCap !== undefined && levelRank[level] > flagCap) {
        report.qualityFlags.push(`${label}: "${normalized}" is ${level}, above the A1–A2 target for ${bucket} (review)`);
      }
    }

    return normalized;
  });

  const chainKey = normalizedWords.join(">");
  if (seenChains.has(chainKey)) {
    report.errors.push(`${label}: duplicate chain also appears at ${seenChains.get(chainKey)}`);
  } else {
    seenChains.set(chainKey, label);
  }

  const pairCount = Math.min(normalizedWords.length - 1, entry.explanations.length);
  for (let pairIndex = 0; pairIndex < pairCount; pairIndex += 1) {
    const pair = normalizePair(normalizedWords[pairIndex], normalizedWords[pairIndex + 1]);
    const explanation = entry.explanations[pairIndex];

    if (forbiddenPairs.has(pair)) {
      report.errors.push(`${label}: pair "${pair}" is forbidden because it is awkward or synthetic`);
    }

    if (seenPairs.has(pair)) {
      report.warnings.push(`${label}: pair "${pair}" also appears at ${seenPairs.get(pair)}`);
    } else {
      seenPairs.set(pair, `${label} explanation[${pairIndex}]`);
    }

    if (typeof explanation !== "string" || explanation.trim().length === 0) {
      report.errors.push(`${label}: explanation[${pairIndex}] must be a non-empty string`);
      continue;
    }

    const explanationLabel = explanation.split(":")[0].trim().toUpperCase();
    if (explanationLabel !== pair) {
      report.warnings.push(
        `${label}: explanation[${pairIndex}] starts with "${explanationLabel}", expected "${pair}"`
      );
    }
  }
}

const reservoir = readReservoir(reservoirPath);
const report = {
  counts: {},
  errors: [],
  warnings: [],
  qualityFlags: [],
};
const seenChains = new Map();
const seenPairs = new Map();
const wordlist = loadWordlist();

for (const bucket of expectedBuckets) {
  const entries = reservoir[bucket];
  if (!Array.isArray(entries)) {
    report.errors.push(`${bucket}: expected an array`);
    report.counts[bucket] = 0;
    continue;
  }

  report.counts[bucket] = entries.length;
  entries.forEach((entry, index) => validateEntry(entry, bucket, index + 1, seenChains, seenPairs, report, wordlist));
}

for (const key of Object.keys(reservoir)) {
  if (!expectedBuckets.includes(key)) {
    report.warnings.push(`Unexpected top-level bucket "${key}"`);
  }
}

const total = expectedBuckets.reduce((sum, bucket) => sum + report.counts[bucket], 0);

console.log("Reservoir validation");
console.log(`File: ${reservoirPath}`);
console.log(`Counts: ${expectedBuckets.map((bucket) => `${bucket}=${report.counts[bucket]}`).join(", ")}, total=${total}`);
console.log(`CEFR gate: ${wordlist ? `on (easy: B2+ error / B1 flag, medium<=B2, hard uncapped; ${Object.keys(wordlist).length} words)` : "off (no word list)"}`);
console.log(`Errors: ${report.errors.length}`);
console.log(`Warnings: ${report.warnings.length}`);
console.log(`Quality flags: ${report.qualityFlags.length}`);

function printList(title, items) {
  if (items.length === 0) return;
  console.log("");
  console.log(title);
  for (const item of items) {
    console.log(`- ${item}`);
  }
}

printList("Errors", report.errors);
printList("Warnings", report.warnings);
printList("Quality flags", report.qualityFlags);

process.exit(report.errors.length > 0 ? 1 : 0);

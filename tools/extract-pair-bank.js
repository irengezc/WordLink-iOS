#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const reservoirPath = process.argv[2] || path.join("WordLink", "reservoir.json");
const outputPath = process.argv[3] || path.join("data", "reservoir-pair-bank.json");
const buckets = ["easy", "medium", "hard"];

function readJson(filePath, fallback = null) {
  if (!fs.existsSync(filePath)) return fallback;
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function pairId(left, right) {
  return `${left}_${right}`.toLowerCase();
}

function pairLabel(left, right) {
  return `${left} ${right}`;
}

function canonicalFor(left, right, linkType, explanation) {
  const explanationLabel = String(explanation || "").split(":")[0].trim().toUpperCase();
  if (linkType === "hyphenated_compound" && explanationLabel.includes("-")) {
    return explanationLabel;
  }
  if (linkType === "split_word") {
    return `${left}${right}`;
  }
  return pairLabel(left, right);
}

function existingBankById(bank) {
  const map = new Map();
  for (const row of bank || []) {
    if (row && row.id) map.set(row.id, row);
  }
  return map;
}

const reservoir = readJson(reservoirPath);
const priorBank = readJson(outputPath, []);
const rows = existingBankById(priorBank);

for (const difficulty of buckets) {
  const entries = reservoir[difficulty] || [];
  entries.forEach((entry, chainIndex) => {
    const chain = entry.chain || [];
    const explanations = entry.explanations || [];
    const linkTypes = entry.linkTypes || [];

    for (let pairIndex = 0; pairIndex < Math.min(chain.length - 1, explanations.length); pairIndex += 1) {
      const left = String(chain[pairIndex]).trim().toUpperCase();
      const right = String(chain[pairIndex + 1]).trim().toUpperCase();
      const linkType = linkTypes[pairIndex] || "two_word_phrase";
      const id = pairId(left, right);
      const source = {
        difficulty,
        chainIndex: chainIndex + 1,
        pairIndex: pairIndex + 1,
      };

      const prior = rows.get(id);
      const row = prior || {
        id,
        left,
        right,
        canonical: canonicalFor(left, right, linkType, explanations[pairIndex]),
        linkType,
        difficulties: [],
        explanation: explanations[pairIndex],
        status: "approved",
        sourceChains: [],
      };

      if (!row.difficulties.includes(difficulty)) row.difficulties.push(difficulty);
      if (!row.sourceChains.some((item) => (
        item.difficulty === source.difficulty
        && item.chainIndex === source.chainIndex
        && item.pairIndex === source.pairIndex
      ))) {
        row.sourceChains.push(source);
      }

      rows.set(id, row);
    }
  });
}

const output = Array.from(rows.values()).sort((a, b) => a.id.localeCompare(b.id));
writeJson(outputPath, output);

console.log(`Pair bank written: ${outputPath}`);
console.log(`Pairs: ${output.length}`);

#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const queuePath = process.argv[2] || path.join("data", "reservoir-candidate-queue.json");
const reservoirPath = process.argv[3] || path.join("WordLink", "reservoir.json");
const buckets = ["easy", "medium", "hard"];

function readJson(filePath, fallback = null) {
  if (!fs.existsSync(filePath)) return fallback;
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function pairKey(left, right) {
  return `${left} ${right}`;
}

function chainKey(words) {
  return words.join(">");
}

function collectExisting(reservoir) {
  const chains = new Set();
  const pairs = new Set();
  for (const difficulty of buckets) {
    for (const entry of reservoir[difficulty] || []) {
      const words = entry.chain || [];
      chains.add(chainKey(words));
      for (let index = 0; index < words.length - 1; index += 1) {
        pairs.add(pairKey(words[index], words[index + 1]));
      }
    }
  }
  return { chains, pairs };
}

function validateCandidate(candidate, existing) {
  const label = candidate.id || "(missing id)";
  if (!buckets.includes(candidate.difficulty)) return `${label}: invalid difficulty`;
  if (!Array.isArray(candidate.chain) || candidate.chain.length !== 9) return `${label}: expected 9 words`;
  if (!Array.isArray(candidate.explanations) || candidate.explanations.length !== 8) return `${label}: expected 8 explanations`;
  if (!Array.isArray(candidate.linkTypes) || candidate.linkTypes.length !== 8) return `${label}: expected 8 linkTypes`;
  if (existing.chains.has(chainKey(candidate.chain))) return `${label}: duplicate chain`;

  for (let index = 0; index < candidate.chain.length - 1; index += 1) {
    const key = pairKey(candidate.chain[index], candidate.chain[index + 1]);
    if (existing.pairs.has(key)) return `${label}: pair already exists in reservoir: ${key}`;
  }

  return null;
}

const queue = readJson(queuePath, []);
const reservoir = readJson(reservoirPath);
const existing = collectExisting(reservoir);
const approved = queue.filter((candidate) => candidate.status === "approved");
const exported = [];
const errors = [];

for (const candidate of approved) {
  const error = validateCandidate(candidate, existing);
  if (error) {
    errors.push(error);
    continue;
  }

  const entry = {
    chain: candidate.chain,
    explanations: candidate.explanations,
    linkTypes: candidate.linkTypes,
  };

  reservoir[candidate.difficulty].push(entry);
  existing.chains.add(chainKey(candidate.chain));
  for (let index = 0; index < candidate.chain.length - 1; index += 1) {
    existing.pairs.add(pairKey(candidate.chain[index], candidate.chain[index + 1]));
  }
  candidate.status = "exported";
  candidate.exportedAt = new Date().toISOString();
  exported.push(candidate.id);
}

if (errors.length > 0) {
  console.error("Export blocked:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

writeJson(reservoirPath, reservoir);
writeJson(queuePath, queue);

console.log(`Exported candidates: ${exported.length}`);
for (const id of exported) console.log(`- ${id}`);

#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const pairBankPath = process.argv[2] || path.join("data", "reservoir-pair-bank.json");
const reservoirPath = process.argv[3] || path.join("WordLink", "reservoir.json");
const outputPath = process.argv[4] || path.join("data", "reservoir-candidate-queue.json");
const buckets = ["easy", "medium", "hard"];
const targetPerDifficulty = Number(process.env.CANDIDATES_PER_DIFFICULTY || 30);
const maxAttempts = Number(process.env.CANDIDATE_ATTEMPTS || 5000);
const maxSplitWordsPerChain = Number(process.env.MAX_SPLIT_WORDS_PER_CHAIN || 3);

function readJson(filePath, fallback = null) {
  if (!fs.existsSync(filePath)) return fallback;
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function pairKey(left, right) {
  return `${left} ${right}`;
}

function chainKey(words) {
  return words.join(">");
}

function shuffle(items) {
  const copy = items.slice();
  for (let index = copy.length - 1; index > 0; index -= 1) {
    const swapIndex = Math.floor(Math.random() * (index + 1));
    [copy[index], copy[swapIndex]] = [copy[swapIndex], copy[index]];
  }
  return copy;
}

function existingState(reservoir) {
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

function difficultyAllows(row, difficulty) {
  if (row.status !== "approved" && row.status !== "candidate") return false;
  if (Array.isArray(row.difficulties) && row.difficulties.includes(difficulty)) return true;
  return row.difficulty === difficulty;
}

function buildGraph(pairBank, difficulty, usedPairs) {
  const graph = new Map();
  for (const row of pairBank) {
    if (!difficultyAllows(row, difficulty)) continue;
    const left = String(row.left || "").trim().toUpperCase();
    const right = String(row.right || "").trim().toUpperCase();
    if (!left || !right) continue;
    if (usedPairs.has(pairKey(left, right))) continue;
    const edges = graph.get(left) || [];
    edges.push({ ...row, left, right });
    graph.set(left, edges);
  }
  return graph;
}

function makeCandidateId(difficulty, words) {
  const stem = words.join("-").toLowerCase();
  return `${difficulty}-${stem}`;
}

function tryWalk(graph, difficulty, existingChains) {
  const starts = shuffle(Array.from(graph.keys()));
  for (const start of starts) {
    const words = [start];
    const edges = [];
    const localPairs = new Set();
    let splitCount = 0;

    while (words.length < 9) {
      const current = words[words.length - 1];
      const nextEdges = shuffle(graph.get(current) || []).filter((edge) => {
        const key = pairKey(edge.left, edge.right);
        if (localPairs.has(key)) return false;
        if (edge.linkType === "split_word" && splitCount >= maxSplitWordsPerChain) return false;
        return true;
      });

      if (nextEdges.length === 0) break;

      const edge = nextEdges[0];
      edges.push(edge);
      localPairs.add(pairKey(edge.left, edge.right));
      if (edge.linkType === "split_word") splitCount += 1;
      words.push(edge.right);
    }

    if (words.length !== 9) continue;
    if (existingChains.has(chainKey(words))) continue;

    return {
      id: makeCandidateId(difficulty, words),
      difficulty,
      status: "candidate",
      chain: words,
      explanations: edges.map((edge) => edge.explanation),
      linkTypes: edges.map((edge) => edge.linkType),
      pairIds: edges.map((edge) => edge.id),
    };
  }
  return null;
}

const pairBank = readJson(pairBankPath, []);
const reservoir = readJson(reservoirPath);
const existingQueue = readJson(outputPath, []);
const { chains: existingChains, pairs: existingPairs } = existingState(reservoir);
const queueById = new Map((existingQueue || []).map((item) => [item.id, item]));

for (const difficulty of buckets) {
  const graph = buildGraph(pairBank, difficulty, existingPairs);
  let attempts = 0;
  let added = 0;
  while (attempts < maxAttempts && added < targetPerDifficulty) {
    attempts += 1;
    const candidate = tryWalk(graph, difficulty, existingChains);
    if (!candidate || queueById.has(candidate.id)) continue;
    queueById.set(candidate.id, candidate);
    existingChains.add(chainKey(candidate.chain));
    added += 1;
  }
  console.log(`${difficulty}: added ${added} candidates`);
}

const output = Array.from(queueById.values()).sort((a, b) => a.id.localeCompare(b.id));
writeJson(outputPath, output);
console.log(`Candidate queue written: ${outputPath}`);
console.log(`Candidates: ${output.length}`);

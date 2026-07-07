import { readFile } from "node:fs/promises";
import { cosineSimilarity, hasPermission, localEmbedding, openAIEmbedding } from "./lib.mjs";

const actor = process.argv[2] || "alice";
const query = process.argv.slice(3).join(" ") || "What do we know about the production outage?";

const [docs, users] = await Promise.all([
  readFile(new URL("../data/docs.json", import.meta.url), "utf8").then(JSON.parse),
  readFile(new URL("../data/users.json", import.meta.url), "utf8").then(JSON.parse),
]);

let index;
try {
  index = await readFile(new URL("../.cache/embeddings.json", import.meta.url), "utf8").then(JSON.parse);
} catch {
  index = {
    provider: "local",
    embeddings: docs.map((doc) => ({
      docId: doc.id,
      provider: "local",
      model: "local-hash-embedding",
      embedding: localEmbedding(`${doc.title}\n${doc.body}`),
    })),
  };
}

const user = users.find((candidate) => candidate.id === actor);
if (!user) {
  console.error(`Unknown actor '${actor}'. Try one of: ${users.map((candidate) => candidate.id).join(", ")}`);
  process.exit(1);
}

let queryEmbedding;
if (index.provider === "openai") {
  if (!process.env.OPENAI_API_KEY) {
    throw new Error("This index was built with OpenAI embeddings. Set OPENAI_API_KEY before querying it.");
  }
  queryEmbedding = await openAIEmbedding({
    apiKey: process.env.OPENAI_API_KEY,
    model: index.embeddings[0]?.model || process.env.EMBEDDING_MODEL || "text-embedding-3-small",
    text: query,
  });
} else {
  queryEmbedding = localEmbedding(query, index.embeddings[0]?.embedding.length || 96);
}
const scored = docs
  .map((doc) => {
    const indexed = index.embeddings.find((entry) => entry.docId === doc.id);
    const score = indexed ? cosineSimilarity(queryEmbedding, indexed.embedding) : 0;
    return {
      id: doc.id,
      title: doc.title,
      score: Number(score.toFixed(4)),
      requiredPermission: doc.permission,
      decision: hasPermission(user, doc.permission) ? "allow" : "deny",
    };
  })
  .sort((a, b) => b.score - a.score)
  .slice(0, 5);

console.log(
  JSON.stringify(
    {
      actor,
      query,
      embeddingProvider: index.provider || "local",
      retrievalCandidates: scored,
      contextSentToModel: scored.filter((doc) => doc.decision === "allow").map((doc) => doc.id),
      withheldFromModel: scored.filter((doc) => doc.decision === "deny").map((doc) => doc.id),
    },
    null,
    2
  )
);

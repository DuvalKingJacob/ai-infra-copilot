import { mkdir, readFile, writeFile } from "node:fs/promises";
import { localEmbedding, openAIEmbedding } from "./lib.mjs";

const docs = JSON.parse(await readFile(new URL("../data/docs.json", import.meta.url), "utf8"));
const apiKey = process.env.OPENAI_API_KEY;
const model = process.env.EMBEDDING_MODEL || "text-embedding-3-small";

const provider = apiKey ? "openai" : "local";
const embeddings = [];

for (const doc of docs) {
  const text = `${doc.title}\n${doc.body}`;
  const embedding = apiKey ? await openAIEmbedding({ apiKey, model, text }) : localEmbedding(text);
  embeddings.push({
    docId: doc.id,
    provider,
    model: apiKey ? model : "local-hash-embedding",
    embedding,
  });
}

await mkdir(new URL("../.cache", import.meta.url), { recursive: true });
await writeFile(
  new URL("../.cache/embeddings.json", import.meta.url),
  JSON.stringify({ generatedAt: new Date().toISOString(), provider, embeddings }, null, 2)
);

console.log(`Built ${embeddings.length} ${provider} embedding(s).`);

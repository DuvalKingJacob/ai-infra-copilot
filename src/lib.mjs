import { createHash } from "node:crypto";

export function cosineSimilarity(a, b) {
  const length = Math.min(a.length, b.length);
  let dot = 0;
  let normA = 0;
  let normB = 0;

  for (let index = 0; index < length; index += 1) {
    dot += a[index] * b[index];
    normA += a[index] * a[index];
    normB += b[index] * b[index];
  }

  if (normA === 0 || normB === 0) return 0;
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}

export function localEmbedding(text, dimensions = 96) {
  const vector = Array.from({ length: dimensions }, () => 0);
  const tokens = text
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, " ")
    .split(/\s+/)
    .filter(Boolean);

  for (const token of tokens) {
    const hash = createHash("sha256").update(token).digest();
    for (let offset = 0; offset < 6; offset += 1) {
      const bucket = hash[offset] % dimensions;
      const sign = hash[offset + 6] % 2 === 0 ? 1 : -1;
      vector[bucket] += sign;
    }
  }

  return normalize(vector);
}

export function normalize(vector) {
  const norm = Math.sqrt(vector.reduce((sum, value) => sum + value * value, 0));
  if (norm === 0) return vector;
  return vector.map((value) => value / norm);
}

export function hasPermission(user, permission) {
  return user.permissions.includes(permission);
}

export function canUseTool(user, tool) {
  return (
    hasPermission(user, tool.permission) ||
    Boolean(tool.fallbackPermission && hasPermission(user, tool.fallbackPermission))
  );
}

export async function openAIEmbedding({ apiKey, model, text }) {
  const response = await fetch("https://api.openai.com/v1/embeddings", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      input: text,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`OpenAI embeddings request failed: ${response.status} ${body}`);
  }

  const payload = await response.json();
  return payload.data[0].embedding;
}

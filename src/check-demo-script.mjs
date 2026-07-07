import { readFile } from "node:fs/promises";

const html = await readFile(new URL("../demo/index.html", import.meta.url), "utf8");
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map((match) => match[1]);

for (const script of scripts) {
  new Function(script);
}

console.log(`Compiled ${scripts.length} browser script block(s).`);

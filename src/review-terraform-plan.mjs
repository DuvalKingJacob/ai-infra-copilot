import { readFile } from "node:fs/promises";
import { reviewTerraformPlan } from "./terraform-plan-reviewer.mjs";

const planPath = process.argv[2] || "data/terraform-plan.prod-network.json";
const plan = await readFile(new URL(`../${planPath}`, import.meta.url), "utf8").then(JSON.parse);

console.log(
  JSON.stringify(reviewTerraformPlan(plan), null, 2)
);

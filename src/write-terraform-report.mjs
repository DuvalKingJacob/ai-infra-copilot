import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { reviewTerraformPlan } from "./terraform-plan-reviewer.mjs";

const planPath = process.argv[2] || "data/terraform-plan.prod-network.json";
const outputPath = process.argv[3] || "outputs/terraform-plan-review-report.md";
const plan = await readFile(new URL(`../${planPath}`, import.meta.url), "utf8").then(JSON.parse);
const review = reviewTerraformPlan(plan);

function formatCount(count) {
  return count || 0;
}

function findingRows(findings) {
  if (findings.length === 0) {
    return "No high-risk findings were detected.";
  }

  return [
    "| Severity | Policy | Resource | Action | Finding |",
    "| --- | --- | --- | --- | --- |",
    ...findings.map(
      (finding) =>
        `| ${finding.severity} | ${finding.policy} | \`${finding.address}\` | ${finding.actions.join(", ")} | ${finding.reason} |`
    ),
  ].join("\n");
}

function policyRows(policyChecks) {
  return [
    "| Policy | Decision |",
    "| --- | --- |",
    ...policyChecks.map((check) => `| \`${check.policy}\` | ${check.decision} |`),
  ].join("\n");
}

function blastRadiusBullets(blastRadius) {
  if (!blastRadius.length) {
    return "No major blast-radius concerns were detected by this sample review.";
  }

  return blastRadius.map((item) => `- ${item}`).join("\n");
}

const report = `# Terraform Plan Review Report

## Summary

- Workspace: \`${review.workspace}\`
- Run: \`${review.runId}\`
- Terraform version: \`${review.terraformVersion}\`
- Resources changed: ${review.resourcesChanged}
- Creates: ${formatCount(review.changedActions.create)}
- Updates: ${formatCount(review.changedActions.update)}
- Deletes: ${formatCount(review.changedActions.delete)}
- Replacements: ${formatCount(review.changedActions.replace)}
- Recommendation: \`${review.recommendation}\`

## Risk Findings

${findingRows(review.findings)}

## Policy Checks

These are Sentinel-style policy checks represented locally for the demo. In a production Terraform Enterprise workflow, these controls would run in the policy phase.

${policyRows(review.policyChecks)}

## Blast Radius

${blastRadiusBullets(review.blastRadius)}

## Approval Required

${review.approvalRequired ? "Yes. A human reviewer should approve or reject this plan before apply." : "No high-risk approval gate was triggered by this sample review."}

## What The Agent Did Not Do

- It did not run \`terraform apply\`.
- It did not mutate cloud infrastructure.
- It did not bypass Terraform policy checks.
- It did not bypass authorization to inspect production context.
- It produced an explainable review artifact for a human-controlled workflow.

## Architecture Note

SpiceDB/AuthZed answers whether the actor is allowed to access the plan review capability. Sentinel-style policy answers whether the Terraform change itself is acceptable.
`;

await mkdir(dirname(outputPath), { recursive: true });
await writeFile(outputPath, report);

console.log(
  JSON.stringify(
    {
      status: "written",
      outputPath,
      recommendation: review.recommendation,
      findings: review.findings.length,
    },
    null,
    2
  )
);

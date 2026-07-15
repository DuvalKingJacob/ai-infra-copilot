import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { triageDriftEvents } from "./drift-triage.mjs";

const inputPath = process.argv[2] || "data/drift-events.json";
const outputPath = process.argv[3] || "outputs/drift-triage-report.md";
const input = await readFile(new URL(`../${inputPath}`, import.meta.url), "utf8").then(JSON.parse);
const triage = triageDriftEvents(input);

function severitySummary(counts) {
  return ["critical", "high", "medium", "low", "informational"]
    .map((severity) => `- ${severity}: ${counts[severity] || 0}`)
    .join("\n");
}

function findingRows(findings) {
  if (findings.length === 0) {
    return "No drift events were found.";
  }

  return [
    "| Severity | Workspace | Resource | Category | Recommendation | Owner |",
    "| --- | --- | --- | --- | --- | --- |",
    ...findings.map(
      (finding) =>
        `| ${finding.severity} | \`${finding.workspace}\` | \`${finding.resource}\` | ${finding.category} | ${finding.recommendation} | ${finding.owner} |`
    ),
  ].join("\n");
}

function detailSections(findings) {
  return findings
    .map(
      (finding) => `### ${finding.id}: ${finding.resource}

- Workspace: \`${finding.workspace}\`
- Project: \`${finding.project}\`
- Environment: \`${finding.environment}\`
- Owner: \`${finding.owner}\`
- Severity: \`${finding.severity}\`
- Category: \`${finding.category}\`
- Recommendation: \`${finding.recommendation}\`
- Reason: ${finding.reason}
- Summary: ${finding.summary}
- Last run status: \`${finding.hcpTerraformContext.lastRunStatus}\`
- Last policy result: \`${finding.hcpTerraformContext.lastPolicyResult}\`${
        finding.hcpTerraformContext.incidentReference
          ? `\n- Incident reference: \`${finding.hcpTerraformContext.incidentReference}\``
          : ""
      }`
    )
    .join("\n\n");
}

const report = `# AI-Assisted Drift Triage Report

## Summary

- Source: \`${triage.source}\`
- Generated at: \`${triage.generatedAt}\`
- Drift events reviewed: ${triage.totalEvents}
- Approval required: ${triage.approvalRequired ? "Yes" : "No"}

## Severity Queue

${severitySummary(triage.countsBySeverity)}

## Prioritized Findings

${findingRows(triage.findings)}

## Findings Detail

${detailSections(triage.findings)}

## Recommended Operating Model

This report treats drift as a review workflow:

1. HCP Terraform or Terraform Enterprise detects that real infrastructure diverged from Terraform-managed state.
2. The assistant classifies and prioritizes the drift event using workspace, ownership, environment, run, and policy context.
3. A human decides whether to ignore, investigate, import, update code, plan remediation, or escalate.
4. Any infrastructure change goes back through Terraform runs, policy checks, approvals, state, and audit.

## What The Agent Did Not Do

- It did not run \`terraform apply\`.
- It did not mutate cloud infrastructure.
- It did not automatically remediate drift.
- It did not bypass HCP Terraform or Terraform Enterprise run governance.
- It produced an explainable triage artifact for human review.

## Architecture Note

Plan review and drift triage share the same operating boundary: tools retrieve authorized context, AI can classify, explain, and propose, and Terraform remains the execution and audit control point.
`;

await mkdir(dirname(outputPath), { recursive: true });
await writeFile(outputPath, report);

console.log(
  JSON.stringify(
    {
      status: "written",
      outputPath,
      events: triage.totalEvents,
      approvalRequired: triage.approvalRequired,
      critical: triage.countsBySeverity.critical || 0,
      high: triage.countsBySeverity.high || 0,
    },
    null,
    2
  )
);

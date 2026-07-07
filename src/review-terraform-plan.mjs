import { readFile } from "node:fs/promises";

const planPath = process.argv[2] || "data/terraform-plan.prod-network.json";
const plan = await readFile(new URL(`../${planPath}`, import.meta.url), "utf8").then(JSON.parse);

function includesWildcard(value) {
  if (Array.isArray(value)) return value.some(includesWildcard);
  if (value && typeof value === "object") return Object.values(value).some(includesWildcard);
  return value === "*" || value === "0.0.0.0/0";
}

function findRisks(change) {
  const risks = [];
  const actions = change.change?.actions || [];
  const after = change.change?.after || {};

  if (actions.includes("delete") && change.type.includes("alarm")) {
    risks.push({
      severity: "high",
      reason: "Deletes monitoring or alerting resource during a production change.",
    });
  }

  if (change.type === "aws_security_group" && includesWildcard(after.ingress || [])) {
    risks.push({
      severity: "critical",
      reason: "Introduces public ingress with 0.0.0.0/0.",
    });
  }

  if (change.type.includes("iam") && includesWildcard(after.policy || after)) {
    risks.push({
      severity: "critical",
      reason: "Introduces wildcard IAM permissions or resources.",
    });
  }

  if (actions.includes("delete")) {
    risks.push({
      severity: "medium",
      reason: "Deletes infrastructure; confirm rollback and owner approval.",
    });
  }

  return risks;
}

const findings = plan.resource_changes.flatMap((change) =>
  findRisks(change).map((risk) => ({
    address: change.address,
    type: change.type,
    actions: change.change?.actions || [],
    ...risk,
  }))
);

const severityRank = { critical: 4, high: 3, medium: 2, low: 1 };
const maxSeverity = findings.reduce(
  (max, finding) => (severityRank[finding.severity] > severityRank[max] ? finding.severity : max),
  "low"
);

const recommendation =
  severityRank[maxSeverity] >= severityRank.high
    ? "block_apply_pending_review"
    : "allow_plan_with_review";

console.log(
  JSON.stringify(
    {
      workspace: plan.workspace,
      runId: plan.run_id,
      resourcesChanged: plan.resource_changes.length,
      findings,
      recommendation,
      approvalRequired: recommendation === "block_apply_pending_review",
      note:
        "This reviewer never applies Terraform. It produces an explainable risk review for a human-controlled workflow.",
    },
    null,
    2
  )
);

const severityRank = { critical: 4, high: 3, medium: 2, low: 1 };

export function includesWildcard(value) {
  if (Array.isArray(value)) return value.some(includesWildcard);
  if (value && typeof value === "object") return Object.values(value).some(includesWildcard);
  return value === "*" || value === "0.0.0.0/0";
}

export function findRisks(change) {
  const risks = [];
  const actions = change.change?.actions || [];
  const before = change.change?.before || {};
  const after = change.change?.after || {};

  if (actions.includes("delete") && actions.includes("create")) {
    risks.push({
      severity: "high",
      policy: "review-prod-replacement",
      reason: "Replaces infrastructure; confirm downtime, data safety, and rollback plan.",
    });
  }

  if (actions.includes("delete") && change.type.includes("alarm")) {
    risks.push({
      severity: "high",
      policy: "no-prod-monitoring-delete",
      reason: "Deletes monitoring or alerting resource during a production change.",
    });
  }

  if (change.type === "aws_lb" && before.internal === true && after.internal === false) {
    risks.push({
      severity: "critical",
      policy: "no-internet-facing-lb",
      reason: "Changes an internal load balancer to internet-facing.",
    });
  }

  if (change.type === "aws_lb" && actions.includes("create") && after.internal === false) {
    risks.push({
      severity: "critical",
      policy: "no-internet-facing-lb",
      reason: "Creates an internet-facing production load balancer.",
    });
  }

  if (change.type === "aws_security_group" && includesWildcard(after.ingress || [])) {
    risks.push({
      severity: "critical",
      policy: "no-public-ingress",
      reason: "Introduces public ingress with 0.0.0.0/0.",
    });
  }

  if (change.type === "aws_db_instance" && actions.includes("delete") && actions.includes("create")) {
    risks.push({
      severity: "critical",
      policy: "no-prod-db-replacement",
      reason: "Replaces a production database instance.",
    });
  }

  if (change.type === "aws_db_instance" && before.deletion_protection === true && after.deletion_protection === false) {
    risks.push({
      severity: "high",
      policy: "require-db-deletion-protection",
      reason: "Disables deletion protection on a database.",
    });
  }

  if (
    change.type === "aws_ecs_service" &&
    typeof before.desired_count === "number" &&
    typeof after.desired_count === "number" &&
    before.desired_count >= 3 &&
    after.desired_count < 2
  ) {
    risks.push({
      severity: "high",
      policy: "minimum-prod-service-capacity",
      reason: `Reduces service desired count from ${before.desired_count} to ${after.desired_count}.`,
    });
  }

  if (change.type === "aws_ecs_service" && actions.includes("create") && after.desired_count < 2) {
    risks.push({
      severity: "high",
      policy: "minimum-prod-service-capacity",
      reason: `Creates a production service with desired count ${after.desired_count}.`,
    });
  }

  if (after && typeof after === "object" && after.tags) {
    const requiredTags = ["Environment", "Owner", "ManagedBy"];
    const missingTags = requiredTags.filter((tag) => !after.tags[tag]);
    if (missingTags.length > 0) {
      risks.push({
        severity: "medium",
        policy: "require-prod-tags",
        reason: `Missing required production tags: ${missingTags.join(", ")}.`,
      });
    }
  }

  if (change.type.includes("iam") && includesWildcard(after.policy || after)) {
    risks.push({
      severity: "critical",
      policy: "no-wildcard-iam",
      reason: "Introduces wildcard IAM permissions or resources.",
    });
  }

  if (actions.includes("delete")) {
    risks.push({
      severity: "medium",
      policy: "review-prod-destroy",
      reason: "Deletes infrastructure; confirm rollback and owner approval.",
    });
  }

  return risks;
}

export function reviewTerraformPlan(plan) {
  const findings = plan.resource_changes.flatMap((change) =>
    findRisks(change).map((risk) => ({
      address: change.address,
      type: change.type,
      actions: change.change?.actions || [],
      ...risk,
    }))
  );

  const maxSeverity = findings.reduce(
    (max, finding) => (severityRank[finding.severity] > severityRank[max] ? finding.severity : max),
    "low"
  );

  const recommendation =
    severityRank[maxSeverity] >= severityRank.high
      ? "block_apply_pending_review"
      : "allow_plan_with_review";

  const changedActions = plan.resource_changes.reduce(
    (counts, change) => {
      const actions = change.change?.actions || [];
      if (actions.includes("delete") && actions.includes("create")) {
        counts.replace += 1;
      }
      for (const action of actions) {
        counts[action] = (counts[action] || 0) + 1;
      }
      return counts;
    },
    { create: 0, update: 0, delete: 0, replace: 0 }
  );

  return {
    workspace: plan.workspace,
    runId: plan.run_id,
    terraformVersion: plan.terraform_version,
    resourcesChanged: plan.resource_changes.length,
    changedActions,
    findings,
    maxSeverity,
    recommendation,
    approvalRequired: recommendation === "block_apply_pending_review",
    policyChecks: summarizePolicyChecks(findings),
    blastRadius: summarizeBlastRadius(findings),
    note:
      "This reviewer never applies Terraform. It produces an explainable risk review for a human-controlled workflow.",
  };
}

function summarizePolicyChecks(findings) {
  const policies = [
    "no-internet-facing-lb",
    "no-public-ingress",
    "no-wildcard-iam",
    "no-prod-db-replacement",
    "require-db-deletion-protection",
    "minimum-prod-service-capacity",
    "no-prod-monitoring-delete",
    "require-prod-tags",
    "review-prod-replacement",
    "review-prod-destroy",
  ];

  return policies.map((policy) => ({
    policy,
    decision: findings.some((finding) => finding.policy === policy) ? "fail" : "pass",
  }));
}

function summarizeBlastRadius(findings) {
  const summaries = new Map([
    ["no-internet-facing-lb", "Network exposure: an internal service boundary may become internet-facing."],
    ["no-public-ingress", "Network exposure: public ingress can expose a production service to the internet."],
    ["no-wildcard-iam", "Identity blast radius: wildcard IAM can expand what the deployment identity can do."],
    ["no-prod-db-replacement", "Data-plane risk: replacing a production database can cause data loss or downtime."],
    [
      "require-db-deletion-protection",
      "Data safety risk: disabling deletion protection makes destructive database changes easier.",
    ],
    [
      "minimum-prod-service-capacity",
      "Availability risk: reducing service capacity can degrade or interrupt production traffic.",
    ],
    [
      "no-prod-monitoring-delete",
      "Observability risk: deleting monitoring reduces visibility during or after the change.",
    ],
    ["require-prod-tags", "Governance risk: missing tags weaken ownership, cost, and incident routing."],
    ["review-prod-replacement", "Operational risk: replacement requires downtime and rollback review."],
    ["review-prod-destroy", "Operational risk: deleted resources require owner approval and rollback review."],
  ]);

  const seen = new Set();
  return findings
    .map((finding) => summaries.get(finding.policy))
    .filter(Boolean)
    .filter((summary) => {
      if (seen.has(summary)) return false;
      seen.add(summary);
      return true;
    });
}

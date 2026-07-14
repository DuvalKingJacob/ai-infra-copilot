const severityRank = { critical: 5, high: 4, medium: 3, low: 2, informational: 1 };

const kindRules = {
  security_exposure: {
    severity: "critical",
    category: "security_drift",
    recommendation: "escalate_to_security_and_block_auto_remediation",
    reason: "Public exposure appeared outside the declared Terraform configuration.",
  },
  identity_expansion: {
    severity: "critical",
    category: "security_drift",
    recommendation: "escalate_to_security_and_block_auto_remediation",
    reason: "Identity permissions expanded outside Terraform review.",
  },
  data_safety: {
    severity: "high",
    category: "data_safety_drift",
    recommendation: "open_remediation_plan_pending_owner_approval",
    reason: "A data safety control changed outside Terraform.",
  },
  capacity_change: {
    severity: "high",
    category: "availability_drift",
    recommendation: "investigate_incident_context_before_remediation",
    reason: "Production capacity changed outside the normal Terraform run workflow.",
  },
  monitoring_change: {
    severity: "medium",
    category: "observability_drift",
    recommendation: "review_with_service_owner",
    reason: "Monitoring behavior changed and may reduce incident visibility.",
  },
  tag_change: {
    severity: "low",
    category: "governance_drift",
    recommendation: "review_or_reconcile_in_code",
    reason: "Tag drift affects ownership, cost, or routing metadata but is not immediately dangerous.",
  },
};

export function triageDriftEvents(input) {
  const events = input.events || [];
  const findings = events.map(triageEvent).sort(compareFindings);
  const countsBySeverity = countBy(findings, "severity");
  const countsByRecommendation = countBy(findings, "recommendation");
  const countsByCategory = countBy(findings, "category");

  return {
    generatedAt: input.generated_at,
    source: input.source,
    totalEvents: events.length,
    countsBySeverity,
    countsByCategory,
    countsByRecommendation,
    findings,
    approvalRequired: findings.some((finding) => ["critical", "high"].includes(finding.severity)),
    note:
      "This drift triage assistant classifies and prioritizes drift for human review. It does not remediate drift or apply Terraform.",
  };
}

function triageEvent(event) {
  const baseRule = kindRules[event.change?.kind] || {
    severity: "informational",
    category: "unknown_drift",
    recommendation: "investigate",
    reason: "The drift type is not yet classified by this demo.",
  };

  const prodEscalation = event.environment === "prod" && baseRule.severity === "medium" ? "high" : baseRule.severity;
  const severity = event.environment === "prod" && baseRule.severity === "low" ? "medium" : prodEscalation;

  return {
    id: event.id,
    workspace: event.workspace,
    project: event.project,
    environment: event.environment,
    owner: event.owner,
    resource: event.resource,
    resourceType: event.resource_type,
    detectedAt: event.detected_at,
    summary: event.summary,
    severity,
    category: baseRule.category,
    recommendation: baseRule.recommendation,
    reason: baseRule.reason,
    hcpTerraformContext: {
      lastRunStatus: event.context?.last_run_status || "unknown",
      lastPolicyResult: event.context?.last_policy_result || "unknown",
      incidentReference: event.context?.incident_reference || null,
    },
  };
}

function compareFindings(a, b) {
  const severityDelta = severityRank[b.severity] - severityRank[a.severity];
  if (severityDelta !== 0) return severityDelta;
  return a.detectedAt.localeCompare(b.detectedAt);
}

function countBy(items, key) {
  return items.reduce((counts, item) => {
    counts[item[key]] = (counts[item[key]] || 0) + 1;
    return counts;
  }, {});
}

import { readFile } from "node:fs/promises";
import { cosineSimilarity, localEmbedding } from "./lib.mjs";
import { localCheck } from "./local-authz.mjs";
import { SpiceDBClient, toSpiceDBObjectId } from "./spicedb-client.mjs";
import { reviewTerraformPlan } from "./terraform-plan-reviewer.mjs";

const actor = process.argv[2] || "alice";
const providerFlag = process.argv.find((arg) => arg.startsWith("--provider="));
const provider = providerFlag?.split("=")[1] || "local";
const prompt =
  process.argv
    .slice(3)
    .filter((arg) => !arg.startsWith("--provider="))
    .join(" ") || "Should we apply the Terraform change?";

const docs = await readFile(new URL("../data/docs.json", import.meta.url), "utf8").then(JSON.parse);
const tools = await readFile(new URL("../data/tools.json", import.meta.url), "utf8").then(JSON.parse);
const plan = await readFile(new URL("../data/terraform-plan.prod-network.json", import.meta.url), "utf8").then(
  JSON.parse
);

const spiceDB = provider === "spicedb" ? new SpiceDBClient() : null;

function classifyIntent(text) {
  const normalized = text.toLowerCase();
  return {
    needsRag: ["outage", "runbook", "incident", "customer", "production"].some((term) =>
      normalized.includes(term)
    ),
    needsTerraformReview: ["terraform", "plan", "apply", "change", "rollback"].some((term) =>
      normalized.includes(term)
    ),
    needsKubernetesStatus: ["kubernetes", "service", "healthy", "payments"].some((term) =>
      normalized.includes(term)
    ),
    requestsMutation: ["apply", "execute", "mutate", "deploy"].some((term) => normalized.includes(term)),
  };
}

async function check({ resourceType, resourceId, permission }) {
  if (spiceDB) {
    return spiceDB.checkPermission({
      resourceType,
      resourceId: toSpiceDBObjectId(resourceId),
      permission,
      subjectId: actor,
    });
  }

  return localCheck({ actor, resource: `${resourceType}:${resourceId}`, permission });
}

async function retrieveContext() {
  const queryEmbedding = localEmbedding(prompt);
  const candidates = await Promise.all(
    docs.map(async (doc) => {
      const docEmbedding = localEmbedding(`${doc.title}\n${doc.body}`);
      const allowed = await check({ resourceType: "document", resourceId: doc.id, permission: "read" });
      return {
        id: doc.id,
        title: doc.title,
        score: Number(cosineSimilarity(queryEmbedding, docEmbedding).toFixed(4)),
        decision: allowed ? "allow" : "deny",
      };
    })
  );

  return candidates.sort((a, b) => b.score - a.score).slice(0, 5);
}

async function callTool(toolName) {
  const tool = tools.find((candidate) => candidate.name === toolName);
  if (!tool) throw new Error(`Unknown tool '${toolName}'.`);

  const allowed = await check({ resourceType: "tool", resourceId: toolName, permission: "call" });
  return {
    tool: toolName,
    decision: allowed ? "allow" : "deny",
    requiredPermission: tool.permission,
    output: allowed ? toolOutput(toolName) : null,
  };
}

function toolOutput(toolName) {
  if (toolName === "terraform.get_recent_changes") {
    return "prod-network changed aws_security_group.payments_ingress and deploy-bot IAM permissions.";
  }

  if (toolName === "terraform.review_plan") {
    return reviewTerraformPlan(plan);
  }

  if (toolName === "terraform.create_rollback_plan") {
    return "Rollback proposal: restore internal-only ingress, scoped IAM actions, and latency alarm.";
  }

  if (toolName === "kubernetes.get_service_status") {
    return "payments-api is serving traffic; latency is recovering.";
  }

  return null;
}

function synthesize({ intent, context, toolCalls }) {
  const allowedDocs = context.filter((doc) => doc.decision === "allow").map((doc) => doc.id);
  const deniedDocs = context.filter((doc) => doc.decision === "deny").map((doc) => doc.id);
  const allowedTools = toolCalls.filter((tool) => tool.decision === "allow");
  const deniedTools = toolCalls.filter((tool) => tool.decision === "deny");
  const planReview = allowedTools.find((tool) => tool.tool === "terraform.review_plan")?.output;
  const rollbackTool = toolCalls.find((tool) => tool.tool === "terraform.create_rollback_plan");

  let proposal = null;
  if (rollbackTool?.decision === "deny") {
    proposal = {
      status: "denied",
      reason: "The actor is not authorized to create a rollback proposal.",
    };
  } else if (intent.requestsMutation || planReview?.recommendation === "block_apply_pending_review") {
    proposal = {
      status: "requires_human_approval",
      reason:
        "The agent can explain risk and propose next steps, but production-impacting changes must go through approval.",
    };
  }

  return {
    summary:
      "Agent workflow completed with explicit authorization checks before context assembly and tool output.",
    allowedDocs,
    deniedDocs,
    allowedTools: allowedTools.map((tool) => tool.tool),
    deniedTools: deniedTools.map((tool) => tool.tool),
    planReview: planReview || null,
    proposal,
  };
}

async function main() {
  const intent = classifyIntent(prompt);
  const context = intent.needsRag || intent.needsTerraformReview ? await retrieveContext() : [];
  const toolCalls = [];

  if (intent.needsTerraformReview) {
    toolCalls.push(await callTool("terraform.get_recent_changes"));
    toolCalls.push(await callTool("terraform.review_plan"));
  }

  if (intent.needsKubernetesStatus) {
    toolCalls.push(await callTool("kubernetes.get_service_status"));
  }

  if (intent.requestsMutation || prompt.toLowerCase().includes("rollback")) {
    toolCalls.push(await callTool("terraform.create_rollback_plan"));
  }

  const response = synthesize({ intent, context, toolCalls });

  console.log(
    JSON.stringify(
      {
        actor,
        prompt,
        provider,
        stages: {
          plan: intent,
          retrieve: context,
          tools: toolCalls,
          synthesize: response,
        },
        audit: {
          modelVisibleDocuments: response.allowedDocs,
          withheldDocuments: response.deniedDocs,
          returnedToolResults: response.allowedTools,
          withheldToolResults: response.deniedTools,
          mutationExecuted: false,
        },
      },
      null,
      2
    )
  );
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});

import { readFile } from "node:fs/promises";
import { localCheck } from "./local-authz.mjs";
import { SpiceDBClient } from "./spicedb-client.mjs";

const [actor, toolName, ...args] = process.argv.slice(2);
const provider = args.find((arg) => arg.startsWith("--provider="))?.split("=")[1] || "local";

if (!actor || !toolName) {
  console.error("Usage: node src/tool-call.mjs <actor> <tool-name> [--provider=local|spicedb]");
  process.exit(1);
}

const tools = await readFile(new URL("../data/tools.json", import.meta.url), "utf8").then(JSON.parse);
const tool = tools.find((candidate) => candidate.name === toolName);

if (!tool) {
  console.error(`Unknown tool '${toolName}'.`);
  process.exit(1);
}

const readOnlyResults = {
  "terraform.get_recent_changes": {
    mode: "read-only",
    result:
      "prod-network workspace changed aws_security_group.payments_ingress at 14:08 UTC. Last apply altered ingress from the payments load balancer.",
    officialMcpHandoff:
      "In production, this request would be routed to the official HashiCorp Terraform MCP Server after authorization.",
  },
  "terraform.create_rollback_plan": {
    mode: "proposal-only",
    result:
      "Rollback plan would restore the previous ingress rule. Apply is blocked pending approval and controlled workflow handoff.",
    officialMcpHandoff:
      "In production, this should create a plan or proposal, not directly apply Terraform from an agent response.",
  },
  "kubernetes.get_service_status": {
    mode: "read-only",
    result:
      "payments-api in prod is serving traffic. Error rate is normal, p95 latency is recovering, and two pods restarted after rollback.",
    officialMcpHandoff:
      "A production version would call a Kubernetes MCP server or internal platform API after authorization.",
  },
};

try {
  let allowed;
  if (provider === "spicedb") {
    const client = new SpiceDBClient();
    allowed = await client.checkPermission({
      resourceType: "tool",
      resourceId: toolName,
      permission: "call",
      subjectId: actor,
    });
  } else if (provider === "local") {
    allowed = await localCheck({ actor, resource: `tool:${toolName}`, permission: "call" });
  } else {
    throw new Error(`Unknown provider '${provider}'.`);
  }

  console.log(
    JSON.stringify(
      {
        actor,
        tool: toolName,
        provider,
        requiredPermission: tool.permission,
        fallbackPermission: tool.fallbackPermission || null,
        decision: allowed ? "allow" : "deny",
        output: allowed ? readOnlyResults[toolName] : null,
        denialReason: allowed ? null : "Actor is not authorized to call this MCP-style tool.",
      },
      null,
      2
    )
  );
} catch (error) {
  console.error(error.message);
  process.exit(1);
}

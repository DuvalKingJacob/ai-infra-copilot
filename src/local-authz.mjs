import { readFile } from "node:fs/promises";

export async function localCheck({ actor, resource, permission }) {
  const [resourceType, resourceId] = resource.split(":");
  const [docs, tools, users] = await Promise.all([
    readFile(new URL("../data/docs.json", import.meta.url), "utf8").then(JSON.parse),
    readFile(new URL("../data/tools.json", import.meta.url), "utf8").then(JSON.parse),
    readFile(new URL("../data/users.json", import.meta.url), "utf8").then(JSON.parse),
  ]);

  const user = users.find((candidate) => candidate.id === actor);
  if (!user) throw new Error(`Unknown actor '${actor}'.`);

  if (resourceType === "document" && permission === "read") {
    const doc = docs.find((candidate) => candidate.id === resourceId);
    if (!doc) throw new Error(`Unknown document '${resourceId}'.`);
    return user.permissions.includes(doc.permission);
  }

  if (resourceType === "tool" && permission === "call") {
    const tool = tools.find((candidate) => candidate.name === resourceId);
    if (!tool) throw new Error(`Unknown tool '${resourceId}'.`);
    return (
      user.permissions.includes(tool.permission) ||
      Boolean(tool.fallbackPermission && user.permissions.includes(tool.fallbackPermission))
    );
  }

  if (resourceType === "proposal" && permission === "approve") {
    return user.permissions.includes("incident.remediation.approve");
  }

  if (resourceType === "proposal" && permission === "create") {
    return user.permissions.includes("terraform.plan.rollback");
  }

  return false;
}

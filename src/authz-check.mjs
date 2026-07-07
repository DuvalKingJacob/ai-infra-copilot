import { localCheck } from "./local-authz.mjs";
import { parseResource, SpiceDBClient } from "./spicedb-client.mjs";

const [actor, resource, permission, ...flags] = process.argv.slice(2);
const provider = flags.find((flag) => flag.startsWith("--provider="))?.split("=")[1] || "spicedb";

if (!actor || !resource || !permission) {
  console.error("Usage: node src/authz-check.mjs <actor> <type:id> <permission> [--provider=spicedb|local]");
  process.exit(1);
}

let allowed;
if (provider === "local") {
  allowed = await localCheck({ actor, resource, permission });
} else if (provider === "spicedb") {
  const { resourceType, resourceId } = parseResource(resource);
  const client = new SpiceDBClient();
  allowed = await client.checkPermission({
    resourceType,
    resourceId,
    permission,
    subjectId: actor,
  });
} else {
  throw new Error(`Unknown provider '${provider}'.`);
}

console.log(
  JSON.stringify(
    {
      actor,
      resource,
      permission,
      decision: allowed ? "allow" : "deny",
      provider,
    },
    null,
    2
  )
);

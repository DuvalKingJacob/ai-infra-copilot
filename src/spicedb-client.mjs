import { readFile } from "node:fs/promises";

const DEFAULT_ENDPOINT = "http://localhost:8443";
const DEFAULT_KEY = "dev-secret";

export class SpiceDBClient {
  constructor({
    endpoint = process.env.SPICEDB_HTTP_ENDPOINT || DEFAULT_ENDPOINT,
    presharedKey = process.env.SPICEDB_PRESHARED_KEY || DEFAULT_KEY,
  } = {}) {
    this.endpoint = endpoint.replace(/\/$/, "");
    this.presharedKey = presharedKey;
  }

  async request(path, body) {
    const response = await fetch(`${this.endpoint}${path}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.presharedKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    const text = await response.text();
    const payload = text ? JSON.parse(text) : {};

    if (!response.ok) {
      throw new Error(`SpiceDB request failed: ${response.status} ${text}`);
    }

    return payload;
  }

  async writeSchema(schema) {
    return this.request("/v1/schema/write", { schema });
  }

  async writeRelationships(relationships) {
    return this.request("/v1/relationships/write", {
      updates: relationships.map((relationship) => ({
        operation: "OPERATION_TOUCH",
        relationship,
      })),
    });
  }

  async checkPermission({ resourceType, resourceId, permission, subjectType = "user", subjectId }) {
    const payload = await this.request("/v1/permissions/check", {
      resource: {
        objectType: resourceType,
        objectId: resourceId,
      },
      permission,
      subject: {
        object: {
          objectType: subjectType,
          objectId: subjectId,
        },
      },
      consistency: {
        minimizeLatency: true,
      },
    });

    return payload.permissionship === "PERMISSIONSHIP_HAS_PERMISSION";
  }
}

export async function loadSchema() {
  return readFile(new URL("../spicedb/schema.zed", import.meta.url), "utf8");
}

export async function loadRelationshipStrings() {
  const source = await readFile(new URL("../spicedb/relationships.yaml", import.meta.url), "utf8");
  return source
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.startsWith("- "))
    .map((line) => line.replace(/^- /, "").replace(/^"|"$/g, ""));
}

export function parseRelationship(source) {
  const match = source.match(
    /^(?<resourceType>[^:]+):(?<resourceId>[^#]+)#(?<relation>[^@]+)@(?<subjectType>[^:]+):(?<subjectId>.+)$/
  );

  if (!match?.groups) {
    throw new Error(`Invalid relationship: ${source}`);
  }

  return {
    resource: {
      objectType: match.groups.resourceType,
      objectId: match.groups.resourceId,
    },
    relation: match.groups.relation,
    subject: {
      object: {
        objectType: match.groups.subjectType,
        objectId: match.groups.subjectId,
      },
    },
  };
}

export function parseResource(resource) {
  const [resourceType, resourceId] = resource.split(":");
  if (!resourceType || !resourceId) {
    throw new Error(`Resource must look like type:id. Received '${resource}'.`);
  }
  return { resourceType, resourceId };
}

import { loadRelationshipStrings, parseRelationship } from "./spicedb-client.mjs";

const objectIdPattern = /^(([a-zA-Z0-9/_|\-=+]{1,})|\*)$/;
const relationships = await loadRelationshipStrings();
const violations = [];

for (const source of relationships) {
  const relationship = parseRelationship(source);
  const fields = [
    ["resource.objectId", relationship.resource.objectId],
    ["subject.object.objectId", relationship.subject.object.objectId],
  ];

  for (const [field, value] of fields) {
    if (!objectIdPattern.test(value)) {
      violations.push({ relationship: source, field, value });
    }
  }
}

if (violations.length > 0) {
  console.error(JSON.stringify({ status: "invalid", violations }, null, 2));
  process.exit(1);
}

console.log(
  JSON.stringify(
    {
      status: "valid",
      relationships: relationships.length,
    },
    null,
    2
  )
);

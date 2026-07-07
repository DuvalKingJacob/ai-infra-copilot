import {
  loadRelationshipStrings,
  loadSchema,
  parseRelationship,
  SpiceDBClient,
} from "./spicedb-client.mjs";

const client = new SpiceDBClient();
const schema = await loadSchema();
const relationshipStrings = await loadRelationshipStrings();
const relationships = relationshipStrings.map(parseRelationship);

await client.writeSchema(schema);
await client.writeRelationships(relationships);

console.log(
  JSON.stringify(
    {
      provider: "spicedb",
      schema: "loaded",
      relationships: relationships.length,
      endpoint: client.endpoint,
    },
    null,
    2
  )
);

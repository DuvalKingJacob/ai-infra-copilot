# OIDC Authentication Plan

The current demo uses a local actor selector. That is acceptable for teaching the authorization flow, but production needs real identity.

## Goal

Replace the local user selector with OIDC-backed identity.

## Flow

1. User signs in through an identity provider.
2. Backend validates the ID token.
3. Backend extracts stable claims:
   - subject
   - email
   - groups
   - organization
   - tenant
4. Backend maps those claims to authorization subjects.
5. Every RAG retrieval, MCP tool call, memory access, and action proposal uses that actor context.

## Why Not Put This In The Static Demo

OIDC requires a backend callback, client configuration, redirect URIs, token validation, and secret management. Adding fake OIDC to a static file would make the project look less serious, not more serious.

The right next step is a small backend that validates tokens and passes actor context into the existing authorization layer.

## Claims To Authorization Mapping

Example:

```json
{
  "sub": "auth0|alice",
  "email": "alice@example.com",
  "groups": ["platform", "production-readers"]
}
```

Maps to:

```text
user:alice
team:platform#member@user:alice
environment:production#reader@team:platform#member
```

## Security Notes

- Never trust browser-provided role names.
- Validate issuer, audience, expiration, and signature.
- Use backend sessions or short-lived tokens.
- Keep API keys and MCP server credentials server-side.
- Log authorization subjects and decisions, not raw tokens.


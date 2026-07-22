# Monday Kickoff

Use this note to restart quickly without reopening the whole planning thread.

## Current Priority

Finish the first practitioner walkthrough episode:

```text
Building Your First Terraform Stack
```

Do not add new repo features before this walkthrough is smooth enough to record.

## Execution Order

1. Building Your First Terraform Stack.
2. Adding Policy, Identity, and Cost Gates.
3. Detecting and Remediating Drift in HCP Terraform.
4. AI Should Review Terraform Plans, Not Apply Them.

## Monday Checklist

- Re-read `docs/building-your-first-terraform-stack-walkthrough.md`.
- Sanity-check the HashiBank Stacks repo as the primary recording path.
- Confirm `components.tfcomponent.hcl` and `deployments.tfdeploy.hcl` are the spine of the video.
- Confirm this repo's provider-light Stacks scaffold still works as the fallback path.
- Decide whether Episode 2 policy / identity / cost needs a one-page outline next.
- Capture any Steve / Apoorva feedback before changing the roadmap again.

## Things Not To Do First

- Do not make `tf-migrate` or workspace migration the first Stacks walkthrough.
- Do not turn the Stacks walkthrough into an AI video.
- Do not add new MCP or agent features until the recording path is clean.
- Do not reintroduce production scripts or teleprompter copy into GitHub.

## Definition Of Ready

The Stacks walkthrough is ready when a practitioner can follow the HashiBank Stack, understand the old workspace-shaped problem, see the Stack component model, and explain why HCP Terraform / Terraform Enterprise becomes the governed control plane. The local scaffold only needs to be good enough as a fallback and teaching aid.

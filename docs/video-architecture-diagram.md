# Video Architecture Diagram

Use this diagram for:

- the first video
- blog post
- README excerpt
- conference/demo slide

## AI-Assisted Terraform Review Workflow

```mermaid
flowchart LR
  Actor["Actor"] --> Authz["Authorization check\nSpiceDB/AuthZed"]
  Actor --> Request["Prompt / review request"]

  Request --> Plan["Terraform plan JSON"]
  Plan --> Reviewer["AI-assisted plan reviewer"]

  Authz --> ToolGate["Tool access decision"]
  ToolGate -->|allow| Reviewer
  ToolGate -->|deny| Withheld["Withhold context/tool output"]

  Reviewer --> Policy["Policy signals\nSentinel-style checks"]
  Policy --> Report["Review report\nfindings + blast radius"]
  Report --> Proposal["Proposal\napprove / block / investigate"]
  Proposal --> Approval["Human approval gate"]
  Approval --> Handoff["Controlled Terraform workflow\nHCP Terraform / CI/CD"]

  Reviewer --> Audit["Audit trail"]
  Authz --> Audit
  Policy --> Audit
  Approval --> Audit
```

## Talk Track

Terraform remains the source of proposed infrastructure change. The assistant reviews the plan and explains risk, but it does not apply. Authorization controls who can inspect context or call tools. Policy controls whether the change is acceptable. Human approval controls whether anything proceeds to a controlled Terraform workflow.

## Short Version

```text
Terraform plan
  -> authorized AI review
  -> policy findings
  -> blast-radius report
  -> human approval
  -> controlled apply
```


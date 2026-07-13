SHELL := /bin/sh

PLAN ?= data/terraform-plan.prod-network.json
REPORT ?= outputs/terraform-plan-review-report.md
APP_PLAN := data/terraform-plan.app-platform.json
APP_REPORT := outputs/app-platform-plan-review-report.md
LIVE_TERRAFORM_DIR ?= terraform/app-platform
LIVE_PLAN_OUT ?= $(CURDIR)/outputs/live-app-platform.tfplan
LIVE_PLAN_JSON ?= outputs/live-app-platform-plan.json
LIVE_REPORT ?= outputs/live-app-platform-plan-review-report.md
LIVE_RISKY_TFVARS ?= risky.tfvars.example
LIVE_RISKY_PLAN_OUT ?= $(CURDIR)/outputs/live-risky-app-platform.tfplan
LIVE_RISKY_PLAN_JSON ?= outputs/live-risky-app-platform-plan.json
LIVE_RISKY_REPORT ?= outputs/live-risky-app-platform-plan-review-report.md
SENTINEL_BIN ?= /Users/jacobplicque/Documents/Codex/bin/sentinel

.PHONY: help validate review report review-app report-app terraform-live-init terraform-live-plan terraform-live-export terraform-live-report terraform-live-review terraform-live-risky-plan terraform-live-risky-export terraform-live-risky-report terraform-live-risky-review demo ci agent agent-tfctl sentinel-check spicedb-up authz-load authz-check tool-check tool-check-local tool-check-tfctl clean-reports

help:
	@printf '%s\n' 'AI-Assisted Terraform Operations'
	@printf '%s\n' ''
	@printf '%s\n' 'Primary demo targets:'
	@printf '%s\n' '  make validate      Run local checks'
	@printf '%s\n' '  make review        Review the default Terraform plan'
	@printf '%s\n' '  make report        Write the default Markdown review report'
	@printf '%s\n' '  make review-app    Review the SRE-style app-platform plan'
	@printf '%s\n' '  make report-app    Write the app-platform Markdown review report'
	@printf '%s\n' '  make demo          Run the main local demo path'
	@printf '%s\n' '  make ci            Run the non-cloud CI checks'
	@printf '%s\n' ''
	@printf '%s\n' 'Live Terraform plan targets:'
	@printf '%s\n' '  make terraform-live-init    Initialize the live Terraform scenario'
	@printf '%s\n' '  make terraform-live-plan    Run terraform plan and write a local .tfplan'
	@printf '%s\n' '  make terraform-live-export  Export the live plan to JSON'
	@printf '%s\n' '  make terraform-live-report  Review the exported live plan JSON'
	@printf '%s\n' '  make terraform-live-review  Plan, export, and write the review report'
	@printf '%s\n' '  make terraform-live-risky-review  Run a risky plan-only demo and write the report'
	@printf '%s\n' ''
	@printf '%s\n' 'Authorization and policy:'
	@printf '%s\n' '  make sentinel-check  Check Sentinel policy formatting'
	@printf '%s\n' '  make spicedb-up      Start SpiceDB'
	@printf '%s\n' '  make authz-load      Validate and load SpiceDB fixtures'
	@printf '%s\n' '  make tool-check      Show Alice/Bob plan-review tool decisions'
	@printf '%s\n' '  make tool-check-local Show Alice/Bob decisions with local fixtures'
	@printf '%s\n' '  make tool-check-tfctl Show authorized read-only tfctl context path'
	@printf '%s\n' '  make agent-tfctl     Run the agent with optional tfctl context'
	@printf '%s\n' ''
	@printf '%s\n' 'Override examples:'
	@printf '%s\n' '  make review PLAN=data/terraform-plan.app-platform.json'
	@printf '%s\n' '  make report PLAN=data/terraform-plan.app-platform.json REPORT=outputs/app-platform-plan-review-report.md'

validate:
	node src/check-demo-script.mjs
	terraform -chdir=terraform/prod-network fmt -check -diff
	terraform -chdir=terraform/app-platform fmt -check -diff
	terraform fmt -recursive -check -diff terraform/workspace-to-stacks

review:
	node src/review-terraform-plan.mjs $(PLAN)

report:
	node src/write-terraform-report.mjs $(PLAN) $(REPORT)

review-app:
	$(MAKE) review PLAN=$(APP_PLAN)

report-app:
	$(MAKE) report PLAN=$(APP_PLAN) REPORT=$(APP_REPORT)

terraform-live-init:
	terraform -chdir=$(LIVE_TERRAFORM_DIR) init

terraform-live-plan:
	mkdir -p outputs
	terraform -chdir=$(LIVE_TERRAFORM_DIR) plan -out=$(LIVE_PLAN_OUT)

terraform-live-export:
	terraform -chdir=$(LIVE_TERRAFORM_DIR) show -json $(LIVE_PLAN_OUT) > $(LIVE_PLAN_JSON)

terraform-live-report:
	$(MAKE) report PLAN=$(LIVE_PLAN_JSON) REPORT=$(LIVE_REPORT)

terraform-live-review: terraform-live-plan terraform-live-export terraform-live-report

terraform-live-risky-plan:
	mkdir -p outputs
	terraform -chdir=$(LIVE_TERRAFORM_DIR) plan -var-file=$(LIVE_RISKY_TFVARS) -out=$(LIVE_RISKY_PLAN_OUT)

terraform-live-risky-export:
	terraform -chdir=$(LIVE_TERRAFORM_DIR) show -json $(LIVE_RISKY_PLAN_OUT) > $(LIVE_RISKY_PLAN_JSON)

terraform-live-risky-report:
	$(MAKE) report PLAN=$(LIVE_RISKY_PLAN_JSON) REPORT=$(LIVE_RISKY_REPORT)

terraform-live-risky-review: terraform-live-risky-plan terraform-live-risky-export terraform-live-risky-report

demo: validate review report review-app report-app agent

ci: validate review report review-app report-app agent tool-check-local sentinel-check

agent:
	node src/agent-workflow.mjs alice "Should we apply the Terraform change?" --provider=local

agent-tfctl:
	node src/agent-workflow.mjs alice "Should we apply the Terraform change?" --provider=local --terraform-context=tfctl

sentinel-check:
	PATH="$$(dirname $(SENTINEL_BIN)):$$PATH" sentinel fmt -check policies/sentinel/*.sentinel

spicedb-up:
	docker compose up -d spicedb

authz-load:
	node src/validate-spicedb-fixtures.mjs
	node src/load-spicedb.mjs

authz-check:
	node src/authz-check.mjs alice document:postmortem-platform-204 read --provider=spicedb
	node src/authz-check.mjs bob document:postmortem-platform-204 read --provider=spicedb

tool-check:
	node src/tool-call.mjs alice terraform.review_plan --provider=spicedb
	node src/tool-call.mjs bob terraform.review_plan --provider=spicedb

tool-check-local:
	node src/tool-call.mjs alice terraform.review_plan --provider=local
	node src/tool-call.mjs bob terraform.review_plan --provider=local

tool-check-tfctl:
	node src/tool-call.mjs alice terraform.review_plan --provider=local --terraform-context=tfctl

clean-reports:
	rm -f outputs/terraform-plan-review-report.md outputs/app-platform-plan-review-report.md outputs/live-*

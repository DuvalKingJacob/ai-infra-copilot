SHELL := /bin/sh

PLAN ?= data/terraform-plan.prod-network.json
REPORT ?= outputs/terraform-plan-review-report.md
APP_PLAN := data/terraform-plan.app-platform.json
APP_REPORT := outputs/app-platform-plan-review-report.md
SENTINEL_BIN ?= /Users/jacobplicque/Documents/Codex/bin/sentinel

.PHONY: help validate review report review-app report-app demo agent sentinel-check spicedb-up authz-load authz-check tool-check tool-check-local clean-reports

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
	@printf '%s\n' ''
	@printf '%s\n' 'Authorization and policy:'
	@printf '%s\n' '  make sentinel-check  Check Sentinel policy formatting'
	@printf '%s\n' '  make spicedb-up      Start SpiceDB'
	@printf '%s\n' '  make authz-load      Validate and load SpiceDB fixtures'
	@printf '%s\n' '  make tool-check      Show Alice/Bob plan-review tool decisions'
	@printf '%s\n' '  make tool-check-local Show Alice/Bob decisions with local fixtures'
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

demo: validate review report review-app report-app agent

agent:
	node src/agent-workflow.mjs alice "Should we apply the Terraform change?" --provider=local

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

clean-reports:
	rm -f outputs/terraform-plan-review-report.md outputs/app-platform-plan-review-report.md

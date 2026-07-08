# Sentinel Local Setup

Sentinel is optional for this local demo. The repo includes Sentinel-style policy examples, while the runnable review path uses the local Terraform plan reviewer.

## Install

Install Sentinel from the official HashiCorp release page:

https://developer.hashicorp.com/sentinel/install

As of July 8, 2026, the HashiCorp install page lists Sentinel `0.41.0` as the latest release and provides macOS ARM64 and AMD64 binary downloads.

After downloading the macOS binary, this local copy was installed at:

```bash
/Users/jacobplicque/Documents/Codex/bin/sentinel
```

Use it in a shell with:

```bash
export PATH="/Users/jacobplicque/Documents/Codex/bin:$PATH"
sentinel version
```

Or from this repo:

```bash
sh scripts/use-local-sentinel.sh
```

Use the AMD64 archive instead of ARM64 if your Mac requires it. To install globally later, move the binary into a normal PATH directory such as `/usr/local/bin` or `/opt/homebrew/bin`.

## Why Sentinel Is Optional Here

The local demo separates three concerns:

1. SpiceDB/AuthZed checks who can inspect production context or call a tool.
2. The local Terraform plan reviewer explains risk and emits policy-like findings.
3. Sentinel examples show where Terraform Enterprise policy checks would live in production.

That lets the demo run anywhere while still showing the production control-plane shape.

## Future Work

A production version could add:

- Sentinel test fixtures generated from Terraform plan JSON.
- `sentinel test` examples for each policy.
- Terraform Enterprise policy set examples.
- A report section that includes real Sentinel pass/fail output.
